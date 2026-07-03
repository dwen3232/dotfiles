import { complete, type UserMessage } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATE_ENTRY_TYPE = "session-rename-state";
const AUTO_AFTER_USER_TURNS = 3;
const MAX_TITLE_LENGTH = 80;
const MAX_TRANSCRIPT_CHARS = 6000;

const TITLE_SYSTEM_PROMPT = [
	"You create short, descriptive titles for Pi coding-agent sessions.",
	"Rules:",
	"- 3 to 7 words",
	"- Title Case",
	"- No quotes",
	"- No emojis",
	"- No trailing punctuation",
	"- Name the work, not the conversation",
	"- Return only the title",
].join("\n");

type TextContent = string | Array<{ type?: string; text?: string }>;

type SessionEntry = {
	type: string;
	customType?: string;
	data?: unknown;
	message?: {
		role?: string;
		content?: TextContent;
	};
};

type RenameState = {
	kind: "manual" | "auto";
	name: string;
	timestamp: number;
};

function notify(ctx: Pick<ExtensionContext, "hasUI" | "ui">, message: string, level: "info" | "warning" | "error") {
	if (ctx.hasUI) ctx.ui.notify(message, level);
}

function sanitizeTitle(raw: string): string {
	const line = raw
		.split(/\r?\n/)
		.map((part) => part.trim())
		.find(Boolean);

	if (!line) return "";

	let title = line.replace(/^["'`]+|["'`]+$/g, "");
	title = title.replace(/\s+/g, " ").trim();
	title = title.replace(/[.!?:;]+$/g, "").trim();

	if (title.length > MAX_TITLE_LENGTH) {
		title = title.slice(0, MAX_TITLE_LENGTH).trimEnd();
	}

	return title;
}

function extractText(content: TextContent | undefined): string {
	if (!content) return "";
	if (typeof content === "string") return content;

	return content
		.filter((part) => part?.type === "text" && typeof part.text === "string")
		.map((part) => part.text as string)
		.join("\n");
}

function getBranch(ctx: Pick<ExtensionContext, "sessionManager">): SessionEntry[] {
	return ctx.sessionManager.getBranch() as SessionEntry[];
}

function getChronologicalBranch(ctx: Pick<ExtensionContext, "sessionManager">): SessionEntry[] {
	return [...getBranch(ctx)].reverse();
}

function countUserTurns(ctx: Pick<ExtensionContext, "sessionManager">): number {
	return getBranch(ctx).filter((entry) => {
		if (entry.type !== "message" || entry.message?.role !== "user") return false;
		return extractText(entry.message.content).trim().length > 0;
	}).length;
}

function buildTranscript(ctx: Pick<ExtensionContext, "sessionManager">): string {
	const sections: string[] = [];

	for (const entry of getChronologicalBranch(ctx)) {
		if (entry.type !== "message") continue;
		const role = entry.message?.role;
		if (role !== "user" && role !== "assistant") continue;

		const text = extractText(entry.message.content).trim();
		if (!text) continue;

		sections.push(`${role === "user" ? "User" : "Assistant"}: ${text}`);
	}

	const transcript = sections.join("\n\n");
	if (transcript.length <= MAX_TRANSCRIPT_CHARS) return transcript;
	return transcript.slice(transcript.length - MAX_TRANSCRIPT_CHARS).trimStart();
}

function parseRenameState(data: unknown): RenameState | null {
	if (!data || typeof data !== "object") return null;
	const state = data as Partial<RenameState>;
	if (state.kind !== "manual" && state.kind !== "auto") return null;
	if (typeof state.name !== "string") return null;
	if (typeof state.timestamp !== "number") return null;
	return {
		kind: state.kind,
		name: state.name,
		timestamp: state.timestamp,
	};
}

function latestRenameState(ctx: Pick<ExtensionContext, "sessionManager">): RenameState | null {
	let latest: RenameState | null = null;

	for (const entry of getBranch(ctx)) {
		if (entry.type !== "custom" || entry.customType !== STATE_ENTRY_TYPE) continue;
		const state = parseRenameState(entry.data);
		if (!state) continue;
		if (!latest || state.timestamp > latest.timestamp) latest = state;
	}

	return latest;
}

async function generateTitle(ctx: ExtensionContext): Promise<string | null> {
	if (!ctx.model) {
		notify(ctx, "No selected model available for session auto-rename.", "warning");
		return null;
	}

	const transcript = buildTranscript(ctx);
	if (!transcript) return null;

	const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
	if (!auth.ok) {
		notify(ctx, auth.error, "warning");
		return null;
	}

	const apiKey = auth.apiKey ?? (await ctx.modelRegistry.getApiKeyForProvider(ctx.model.provider));
	if (!apiKey) {
		notify(ctx, `No API key for ${ctx.model.provider}; session auto-rename skipped.`, "warning");
		return null;
	}

	const userMessage: UserMessage = {
		role: "user",
		content: [
			{
				type: "text",
				text: ["Create a title for this session transcript:", "", "<transcript>", transcript, "</transcript>"].join("\n"),
			},
		],
		timestamp: Date.now(),
	};

	try {
		const response = await complete(
			ctx.model,
			{ systemPrompt: TITLE_SYSTEM_PROMPT, messages: [userMessage] },
			{ apiKey, headers: auth.headers, env: auth.env, maxTokens: 64, signal: ctx.signal },
		);

		if (response.stopReason === "aborted") return null;
		if (response.stopReason === "error") {
			notify(ctx, `Session auto-rename failed: ${response.errorMessage ?? "model error"}`, "warning");
			return null;
		}

		const rawTitle = response.content
			.filter((part): part is { type: "text"; text: string } => part.type === "text")
			.map((part) => part.text)
			.join("\n");

		const title = sanitizeTitle(rawTitle);
		return title || null;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		notify(ctx, `Session auto-rename failed: ${message}`, "warning");
		return null;
	}
}

export default function sessionRename(pi: ExtensionAPI) {
	let manualRenameSeen = false;
	let autoRenameCompleted = false;
	let autoRenameInProgress = false;
	let failedAutoAttempts = 0;
	let lastAutoAttemptUserTurns = 0;

	function restoreState(ctx: ExtensionContext) {
		manualRenameSeen = false;
		autoRenameCompleted = false;
		autoRenameInProgress = false;
		failedAutoAttempts = 0;
		lastAutoAttemptUserTurns = 0;

		const state = latestRenameState(ctx);
		if (state?.kind === "manual") manualRenameSeen = true;
		if (state?.kind === "auto") autoRenameCompleted = true;

		if (pi.getSessionName() && !state) {
			manualRenameSeen = true;
		}
	}

	function setManualName(name: string, ctx: ExtensionContext) {
		pi.setSessionName(name);
		pi.appendEntry<RenameState>(STATE_ENTRY_TYPE, { kind: "manual", name, timestamp: Date.now() });
		manualRenameSeen = true;
		autoRenameCompleted = false;
		notify(ctx, `Session renamed: ${name}`, "info");
	}

	async function maybeAutoRename(ctx: ExtensionContext) {
		if (manualRenameSeen || autoRenameCompleted || autoRenameInProgress) return;
		if (pi.getSessionName()) return;

		const userTurns = countUserTurns(ctx);
		if (userTurns < AUTO_AFTER_USER_TURNS) return;
		if (failedAutoAttempts >= 2) return;
		if (failedAutoAttempts > 0 && userTurns <= lastAutoAttemptUserTurns) return;

		autoRenameInProgress = true;
		lastAutoAttemptUserTurns = userTurns;
		try {
			const title = await generateTitle(ctx);
			if (!title) {
				failedAutoAttempts += 1;
				return;
			}

			if (pi.getSessionName() || manualRenameSeen) return;

			pi.setSessionName(title);
			pi.appendEntry<RenameState>(STATE_ENTRY_TYPE, { kind: "auto", name: title, timestamp: Date.now() });
			autoRenameCompleted = true;
			notify(ctx, `Session auto-renamed: ${title}`, "info");
		} finally {
			autoRenameInProgress = false;
		}
	}

	pi.registerCommand("rename", {
		description: "Set the current session name (usage: /rename [name])",
		handler: async (args, ctx) => {
			let name = sanitizeTitle(args);

			if (!name) {
				if (ctx.hasUI) {
					const currentName = pi.getSessionName() ?? "";
					const entered = await ctx.ui.input("Rename session:", currentName);
					name = sanitizeTitle(entered ?? "");
				}

				if (!name) {
					notify(ctx, "Usage: /rename <name>", "warning");
					return;
				}
			}

			setManualName(name, ctx);
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		restoreState(ctx);
	});

	pi.on("agent_end", async (_event, ctx) => {
		await maybeAutoRename(ctx);
	});
}
