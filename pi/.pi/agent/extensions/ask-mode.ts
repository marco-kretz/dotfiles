import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const ASK_MODE_ENTRY = "ask-mode";
const ASK_MODE_TOOLS = ["read", "grep", "find", "ls", "ffgrep", "fffind", "fff-multi-grep"] as const;
const ASK_MODE_TOOL_SET = new Set<string>(ASK_MODE_TOOLS);
const ASK_MODE_PROMPT =
	"Ask mode is active: answer project questions precisely; inspect the project before answering; cite file paths and line numbers where useful; distinguish facts from uncertainty; ask for clarification when needed. Strictly read-only: never modify files, execute implementation, or use tools outside the read-only inspection allowlist.";

interface AskModeState {
	enabled: boolean;
	toolsBeforeAskMode?: string[];
}

export default function askModeExtension(pi: ExtensionAPI): void {
	let askModeEnabled = false;
	let toolsBeforeAskMode: string[] | undefined;

	function availableAskTools(): string[] {
		const available = new Set(pi.getAllTools().map((tool) => tool.name));
		return ASK_MODE_TOOLS.filter((name) => available.has(name));
	}

	function applyAskModeTools(): void {
		pi.setActiveTools(availableAskTools());
	}

	function updateStatus(ctx: ExtensionContext): void {
		ctx.ui.setStatus("ask-mode", askModeEnabled ? "🔎 ask" : undefined);
	}

	function persistState(): void {
		pi.appendEntry<AskModeState>(ASK_MODE_ENTRY, {
			enabled: askModeEnabled,
			toolsBeforeAskMode,
		});
	}

	function enterAskMode(ctx: ExtensionContext): void {
		if (toolsBeforeAskMode === undefined) {
			toolsBeforeAskMode = [...pi.getActiveTools()];
		}
		askModeEnabled = true;
		applyAskModeTools();
		updateStatus(ctx);
		persistState();
	}

	function exitAskMode(ctx: ExtensionContext): void {
		if (toolsBeforeAskMode !== undefined) {
			pi.setActiveTools(toolsBeforeAskMode);
		}
		askModeEnabled = false;
		toolsBeforeAskMode = undefined;
		updateStatus(ctx);
		persistState();
	}

	pi.registerCommand("ask", {
		description: "Enter strict read-only Ask mode or ask a project question",
		handler: async (args, ctx) => {
			const text = args.trim();
			const command = text.toLowerCase();

			if (command === "" || command === "start" || command === "on") {
				enterAskMode(ctx);
				return;
			}

			if (command === "off" || command === "exit") {
				exitAskMode(ctx);
				return;
			}

			enterAskMode(ctx);
			if (ctx.isIdle()) {
				pi.sendUserMessage(text);
			} else {
				pi.sendUserMessage(text, { deliverAs: "followUp" });
			}
		},
	});

	pi.on("tool_call", async (event) => {
		if (!askModeEnabled || ASK_MODE_TOOL_SET.has(event.toolName)) return;

		return {
			block: true,
			reason: `Ask mode is strictly read-only; tool "${event.toolName}" is blocked. Use /ask off to leave Ask mode.`,
		};
	});

	pi.on("before_agent_start", async (event) => {
		if (!askModeEnabled) return;

		applyAskModeTools();
		return { systemPrompt: `${event.systemPrompt}\n\n${ASK_MODE_PROMPT}` };
	});

	pi.on("session_start", async (_event, ctx) => {
		askModeEnabled = false;
		toolsBeforeAskMode = undefined;

		const savedEntry = [...ctx.sessionManager.getBranch()]
			.reverse()
			.find((entry) => entry.type === "custom" && entry.customType === ASK_MODE_ENTRY) as
			{ data?: AskModeState } | undefined;
		const savedState = savedEntry?.data;

		if (savedState?.enabled === true) {
			askModeEnabled = true;
			toolsBeforeAskMode = Array.isArray(savedState.toolsBeforeAskMode)
				? [...savedState.toolsBeforeAskMode]
				: [...pi.getActiveTools()];
			applyAskModeTools();
		}

		updateStatus(ctx);
	});
}
