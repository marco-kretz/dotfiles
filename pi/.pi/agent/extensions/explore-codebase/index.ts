import { spawn } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join, resolve } from "node:path";
import { Type } from "typebox";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type ExplorerSettings = {
	provider: string;
	model: string;
	thinkingLevel: string;
};

type JsonEvent = {
	type?: string;
	message?: {
		role?: string;
		content?: Array<{ type?: string; text?: string; name?: string }>;
		stopReason?: string;
		errorMessage?: string;
	};
	messages?: Array<{
		role?: string;
		content?: Array<{ type?: string; text?: string }>;
		stopReason?: string;
		errorMessage?: string;
	}>;
	toolName?: string;
	isError?: boolean;
};

const DEFAULT_EXPLORER_PROVIDER = "openai-codex";
const DEFAULT_EXPLORER_MODEL = "gpt-5.3-codex";
const DEFAULT_EXPLORER_THINKING = "medium";
const DEFAULT_MAX_OUTPUT_CHARS = 32_000;

function getConfigDir(): string {
	return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
}

function readExplorerSettings(): ExplorerSettings {
	let fileSettings: Partial<ExplorerSettings> = {};
	const settingsPath = join(getConfigDir(), "settings.json");
	if (existsSync(settingsPath)) {
		try {
			const settings = JSON.parse(readFileSync(settingsPath, "utf8"));
			const explorer = settings?.subagents?.explorer ?? {};
			fileSettings = {
				provider: explorer.provider,
				model: explorer.model ?? explorer.modelId,
				thinkingLevel: explorer.thinkingLevel ?? explorer.reasoningEffort,
			};
		} catch {
			// Ignore malformed settings here; pi itself will report config problems elsewhere.
		}
	}

	return {
		provider: process.env.PI_EXPLORER_PROVIDER || fileSettings.provider || DEFAULT_EXPLORER_PROVIDER,
		model: process.env.PI_EXPLORER_MODEL || fileSettings.model || DEFAULT_EXPLORER_MODEL,
		thinkingLevel: process.env.PI_EXPLORER_THINKING || fileSettings.thinkingLevel || DEFAULT_EXPLORER_THINKING,
	};
}

function truncate(text: string, maxChars: number): string {
	if (text.length <= maxChars) return text;
	return `${text.slice(0, Math.max(0, maxChars))}\n\n[explore_codebase output truncated to ${maxChars} characters]`;
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
	return `You are a read-only codebase exploration sub-agent.

Your job is to inspect the repository and return the smallest useful set of grounded findings that lets the main agent continue safely. You are a scanner, not an implementer.

Rules:
- Use only read-only tools to inspect files, names, and search results.
- Do not implement changes, refactor, or give broad architectural advice unless explicitly asked.
- Do not speculate beyond evidence in the code. If you are unsure, say so.
- Only mention files you actually inspected or matched.
- Prefer exact paths, line references, symbol names, routes, commands, configs, tests, and call sites.
- Prefer grep for broad codebase searches. The grep tool is backed by ripgrep/rg and respects .gitignore.
- Use find/ls for file discovery, then read only the most relevant files needed to verify findings.
- When the task is broad, first identify likely search terms and entry points, then inspect only the most relevant files.
- Do not summarize the whole repository, include full file contents, or output irrelevant matches.
- Separate confirmed facts from assumptions or uncertainty.
- Do not ask follow-up questions.

Output format:
## Summary
2-5 sentences.

## Relevant files
- \`path\`: relevance, symbols, why it matters, key findings.

## Entry points
- Routes, commands, controllers, handlers, events, or other entry points found.

## Data flow
- Concise flow if found.

## Tests
- Relevant tests found, or say none found.

## Risks / side effects
- Concrete risks grounded in code.

## Open questions
- Missing or uncertain context.

## Confidence
low | medium | high

Current working directory: ${cwd}`;
}

function createUserPrompt(cwd: string, query: string, mode?: string, paths?: string[]): string {
	const focus = paths?.length ? `\n\nFocus paths requested by the main agent:\n${paths.map((p) => `- ${p}`).join("\n")}` : "";
	const modeLine = mode ? `\n\nExplore mode: ${mode}` : "";
	return `Explore the codebase for the main agent.

Working directory: ${cwd}${modeLine}

Question / task:
${query}${focus}

Return only grounded findings relevant to the task. Prefer the minimal set of files and symbols needed to understand the requested behavior or impact. Do not modify files.`;
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
			env: { ...process.env, PI_SUBAGENT: "explore_codebase" },
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
				// pi may print non-JSON diagnostics; keep stderr for real errors.
			}
		};

		const abort = () => {
			child.kill("SIGTERM");
			setTimeout(() => {
				if (!child.killed) child.kill("SIGKILL");
			}, 2_000).unref();
			settle(() => reject(new Error("Explorer sub-agent aborted")));
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
		name: "explore_codebase",
		label: "explore",
		description:
			"Start a read-only sub-agent to explore/search the codebase and return a concise findings report to the main agent. Use this when answering requires understanding repository structure, implementations, dependencies, or relationships across files.",
		promptSnippet: "Delegate codebase exploration to a read-only sub-agent and receive summarized findings",
		promptGuidelines: [
			"When a user request requires non-trivial codebase exploration, use explore_codebase before making claims about the repository.",
			"Use explore_codebase for broad searches or multi-file investigations; use direct read/edit tools for already-known specific files.",
			"For explore_codebase, pass mode when helpful: targeted_search for concrete symbols/features, impact_analysis for possible change impact, behavior_trace for request/command/event flow.",
		],
		parameters: Type.Object({
			query: Type.String({ description: "The codebase question or exploration task for the sub-agent." }),
			mode: Type.Optional(
				Type.String({ description: "Optional exploration mode: targeted_search, impact_analysis, or behavior_trace." }),
			),
			paths: Type.Optional(Type.Array(Type.String({ description: "Optional relevant files or directories to focus on." }))),
			maxOutputChars: Type.Optional(
				Type.Number({ description: `Maximum characters returned to the main agent (default: ${DEFAULT_MAX_OUTPUT_CHARS}).` }),
			),
		}),
		prepareArguments(args) {
			if (!args || typeof args !== "object") return args;
			const record = args as Record<string, unknown>;
			if (record.query === undefined && record.question !== undefined) return { ...record, query: record.question };
			if (record.query === undefined && record.task !== undefined) return { ...record, query: record.task };
			return record;
		},
		async execute(_toolCallId, { query, mode, paths, maxOutputChars }, signal, onUpdate, ctx) {
			const explorer = readExplorerSettings();
			const cwd = ctx?.cwd ? resolve(ctx.cwd) : process.cwd();
			const prompt = createUserPrompt(cwd, query, mode, paths);
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
				explorer.provider,
				"--model",
				explorer.model,
				"--thinking",
				explorer.thinkingLevel,
				"--system-prompt",
				createSystemPrompt(cwd),
				prompt,
			];

			onUpdate?.({
				content: [{ type: "text", text: `Explorer starting ${explorer.provider}/${explorer.model}...` }],
				details: { model: `${explorer.provider}/${explorer.model}`, thinkingLevel: explorer.thinkingLevel },
			});

			const result = await runPiJson(args, cwd, signal);
			const failedTool = result.events.find((event) => event.type === "tool_execution_end" && event.isError);
			if (result.exitCode !== 0) {
				throw new Error(`Explorer exited with code ${result.exitCode}${result.stderr ? `: ${result.stderr.trim()}` : ""}`);
			}
			if (failedTool) {
				throw new Error(`Explorer tool failed: ${failedTool.toolName ?? "unknown"}`);
			}

			const report = lastAssistantText(result.events) || "Explorer completed without text findings.";
			const output = truncate(report, Math.max(1_000, maxOutputChars ?? DEFAULT_MAX_OUTPUT_CHARS));
			return {
				content: [{ type: "text", text: output }],
				details: {
					model: `${explorer.provider}/${explorer.model}`,
					thinkingLevel: explorer.thinkingLevel,
					mode: mode ?? null,
					paths: paths ?? [],
					eventCount: result.events.length,
				},
			};
		},
	});
}
