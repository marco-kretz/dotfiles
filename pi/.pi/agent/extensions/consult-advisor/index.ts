import { spawn } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join, resolve } from "node:path";
import { Type } from "typebox";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type AdvisorSettings = {
	provider: string;
	model: string;
	thinkingLevel: string;
};

type JsonEvent = {
	type?: string;
	message?: {
		role?: string;
		content?: Array<{ type?: string; text?: string }>;
	};
	messages?: Array<{
		role?: string;
		content?: Array<{ type?: string; text?: string }>;
	}>;
	toolName?: string;
	isError?: boolean;
};

const DEFAULT_ADVISOR_PROVIDER = "openai-codex";
const DEFAULT_ADVISOR_MODEL = "gpt-5.5";
const DEFAULT_ADVISOR_THINKING = "xhigh";
const DEFAULT_MAX_OUTPUT_CHARS = 24_000;

function getConfigDir(): string {
	return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
}

function readAdvisorSettings(): AdvisorSettings {
	let fileSettings: Partial<AdvisorSettings> = {};
	const settingsPath = join(getConfigDir(), "settings.json");
	if (existsSync(settingsPath)) {
		try {
			const settings = JSON.parse(readFileSync(settingsPath, "utf8"));
			const advisor = settings?.subagents?.advisor ?? {};
			fileSettings = {
				provider: advisor.provider,
				model: advisor.model ?? advisor.modelId,
				thinkingLevel: advisor.thinkingLevel ?? advisor.reasoningEffort,
			};
		} catch {
			// Ignore malformed settings here; pi itself will report config problems elsewhere.
		}
	}

	return {
		provider: process.env.PI_ADVISOR_PROVIDER || fileSettings.provider || DEFAULT_ADVISOR_PROVIDER,
		model: process.env.PI_ADVISOR_MODEL || fileSettings.model || DEFAULT_ADVISOR_MODEL,
		thinkingLevel: process.env.PI_ADVISOR_THINKING || fileSettings.thinkingLevel || DEFAULT_ADVISOR_THINKING,
	};
}

function truncate(text: string, maxChars: number): string {
	if (text.length <= maxChars) return text;
	return `${text.slice(0, Math.max(0, maxChars))}\n\n[consult_advisor output truncated to ${maxChars} characters]`;
}

function textFromMessage(message: JsonEvent["message"]): string {
	return (message?.content ?? [])
		.filter((part) => part.type === "text" && typeof part.text === "string")
		.map((part) => part.text)
		.join("\n")
		.trim();
}

function lastAssistantText(events: JsonEvent[]): string {
	for (let i = events.length - 1; i >= 0; i--) {
		const event = events[i];
		if (event.type === "agent_end" && event.messages) {
			for (let j = event.messages.length - 1; j >= 0; j--) {
				const message = event.messages[j];
				if (message.role === "assistant") return textFromMessage(message as JsonEvent["message"]);
			}
		}
		if (event.message?.role === "assistant") {
			const text = textFromMessage(event.message);
			if (text) return text;
		}
	}
	return "";
}

function createSystemPrompt(cwd: string): string {
	return `You are a high-reasoning advisor sub-agent for a main coding agent.

Your job is to provide independent, in-depth advice when the main agent needs stronger reasoning, design critique, debugging strategy, risk analysis, or a second opinion.

You advise; you do not implement.

Rules:
- Do not edit files or suggest exact code patches unless explicitly asked.
- Use only read-only tools when code inspection is useful.
- Be concise, but reason deeply where it matters.
- Challenge assumptions and identify hidden risks.
- Ground code-related claims in inspected files, paths, symbols, or command output.
- If you did not inspect the code, say your advice is based only on the provided context.
- Prefer practical recommendations over broad architecture essays.
- State uncertainty and what evidence would change your recommendation.
- Do not ask follow-up questions; list open questions instead.

Output format:
## Recommendation
Clear recommendation or position.

## Reasoning
Key reasoning, trade-offs, and evidence.

## Risks / pitfalls
Concrete risks or failure modes.

## Checks
Specific checks, tests, commands, or files the main agent should verify.

## Open questions
Missing context or uncertainty.

## Confidence
low | medium | high

Current working directory: ${cwd}`;
}

function createUserPrompt(cwd: string, question: string, mode?: string, context?: string, paths?: string[]): string {
	const modeLine = mode ? `\n\nAdvisor mode: ${mode}` : "";
	const contextBlock = context ? `\n\nContext from main agent:\n${context}` : "";
	const focus = paths?.length ? `\n\nRelevant paths or files to inspect if needed:\n${paths.map((p) => `- ${p}`).join("\n")}` : "";
	return `Consult for the main agent.

Working directory: ${cwd}${modeLine}

Question / decision / problem:
${question}${contextBlock}${focus}

Return an independent advisory response for the main agent. Keep it grounded, practical, and concise.`;
}

function getPiInvocation(args: string[]): { command: string; args: string[] } {
	const currentScript = process.argv[1];
	if (currentScript && !currentScript.startsWith("/$bunfs/root/") && existsSync(currentScript)) {
		return { command: process.execPath, args: [currentScript, ...args] };
	}

	const execName = basename(process.execPath).toLowerCase();
	if (!/^(node|bun)(\.exe)?$/.test(execName)) {
		return { command: process.execPath, args };
	}

	return { command: "pi", args };
}

function runPiJson(args: string[], cwd: string, signal?: AbortSignal): Promise<{ events: JsonEvent[]; stderr: string; exitCode: number | null }> {
	return new Promise((resolvePromise, reject) => {
		const invocation = getPiInvocation(args);
		const child = spawn(invocation.command, invocation.args, {
			cwd,
			stdio: ["ignore", "pipe", "pipe"],
			env: { ...process.env, PI_SUBAGENT: "consult_advisor" },
		});

		const events: JsonEvent[] = [];
		let stdoutBuffer = "";
		let stderr = "";
		let settled = false;

		const settle = (fn: () => void) => {
			if (settled) return;
			settled = true;
			signal?.removeEventListener("abort", abort);
			fn();
		};

		const parseLine = (line: string) => {
			const trimmed = line.trim();
			if (!trimmed) return;
			try {
				events.push(JSON.parse(trimmed));
			} catch {
				// pi may print non-JSON diagnostics; stderr is kept for real errors.
			}
		};

		const abort = () => {
			child.kill("SIGTERM");
			setTimeout(() => {
				if (!child.killed) child.kill("SIGKILL");
			}, 2_000).unref();
			settle(() => reject(new Error("Advisor sub-agent aborted")));
		};

		signal?.addEventListener("abort", abort, { once: true });

		child.stdout.on("data", (chunk) => {
			stdoutBuffer += chunk.toString("utf8");
			let newline = stdoutBuffer.indexOf("\n");
			while (newline >= 0) {
				parseLine(stdoutBuffer.slice(0, newline));
				stdoutBuffer = stdoutBuffer.slice(newline + 1);
				newline = stdoutBuffer.indexOf("\n");
			}
		});

		child.stderr.on("data", (chunk) => {
			stderr += chunk.toString("utf8");
		});

		child.on("error", (error) => settle(() => reject(error)));
		child.on("close", (exitCode) => {
			if (stdoutBuffer.trim()) parseLine(stdoutBuffer);
			settle(() => resolvePromise({ events, stderr, exitCode }));
		});
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "consult_advisor",
		label: "advisor",
		description:
			"Consult a high-reasoning read-only advisor sub-agent for deeper reasoning, design critique, debugging strategy, risk analysis, or second opinions. Use when the current model may need stronger reasoning, independent review, or is unsure/in doubt.",
		promptSnippet: "Consult a high-reasoning advisor sub-agent for deeper analysis or second opinions",
		promptGuidelines: [
			"Use consult_advisor when a task needs deeper reasoning, design critique, debugging strategy, risk analysis, or an independent second opinion.",
			"Use consult_advisor when you are unsure, in doubt, see multiple plausible approaches, or want a second opinion before making a risky decision.",
			"Do not use consult_advisor for simple code lookups; use explore_codebase or direct read/grep instead.",
			"Pass concise context to consult_advisor, including current plan, uncertainty, relevant errors, and paths when available.",
		],
		parameters: Type.Object({
			question: Type.String({ description: "The decision, problem, plan, or reasoning question for the advisor." }),
			context: Type.Optional(Type.String({ description: "Concise context from the main agent: current plan, constraints, errors, findings, or uncertainty." })),
			mode: Type.Optional(
				Type.String({ description: "Optional advisor mode: deep_reasoning, plan_review, debug_strategy, risk_analysis, or architecture_review." }),
			),
			paths: Type.Optional(Type.Array(Type.String({ description: "Optional files or directories the advisor may inspect read-only." }))),
			maxOutputChars: Type.Optional(
				Type.Number({ description: `Maximum characters returned to the main agent (default: ${DEFAULT_MAX_OUTPUT_CHARS}).` }),
			),
		}),
		prepareArguments(args) {
			if (!args || typeof args !== "object") return args;
			const record = args as Record<string, unknown>;
			if (record.question === undefined && record.query !== undefined) return { ...record, question: record.query };
			if (record.question === undefined && record.task !== undefined) return { ...record, question: record.task };
			return record;
		},
		async execute(_toolCallId, { question, context, mode, paths, maxOutputChars }, signal, onUpdate, ctx) {
			const advisor = readAdvisorSettings();
			const cwd = ctx?.cwd ? resolve(ctx.cwd) : process.cwd();
			const prompt = createUserPrompt(cwd, question, mode, context, paths);
			const args = [
				"--mode",
				"json",
				"--print",
				"--no-session",
				"--no-extensions",
				"--no-skills",
				"--no-prompt-templates",
				"--no-context-files",
				"--tools",
				"read,grep,find,ls",
				"--provider",
				advisor.provider,
				"--model",
				advisor.model,
				"--thinking",
				advisor.thinkingLevel,
				"--system-prompt",
				createSystemPrompt(cwd),
				prompt,
			];

			onUpdate?.({
				content: [{ type: "text", text: `Advisor starting ${advisor.provider}/${advisor.model}...` }],
				details: { model: `${advisor.provider}/${advisor.model}`, thinkingLevel: advisor.thinkingLevel, mode: mode ?? null },
			});

			const result = await runPiJson(args, cwd, signal);
			const failedTool = result.events.find((event) => event.type === "tool_execution_end" && event.isError);
			if (result.exitCode !== 0) {
				throw new Error(`Advisor exited with code ${result.exitCode}${result.stderr ? `: ${result.stderr.trim()}` : ""}`);
			}
			if (failedTool) {
				throw new Error(`Advisor tool failed: ${failedTool.toolName ?? "unknown"}`);
			}

			const report = lastAssistantText(result.events) || "Advisor completed without text findings.";
			const output = truncate(report, Math.max(1_000, maxOutputChars ?? DEFAULT_MAX_OUTPUT_CHARS));
			return {
				content: [{ type: "text", text: output }],
				details: {
					model: `${advisor.provider}/${advisor.model}`,
					thinkingLevel: advisor.thinkingLevel,
					mode: mode ?? null,
					paths: paths ?? [],
					eventCount: result.events.length,
				},
			};
		},
	});
}
