import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { basename } from "node:path";
import notifier from "node-notifier";

const SOUNDS = {
	idle: "Glass",
	error: "Basso",
	question: "Submarine",
	permission: "Submarine",
} as const;

const QUESTION_TOOLS = new Set(["ask_user", "question"]);
const DEDUPE_MS = 1500;
const recentNotifications = new Map<string, number>();
let lastQuestionAt = 0;
let lastIdleAt = 0;
const activeQuestionToolCalls = new Set<string>();

function focusTerminalApp(): void {
	if (process.env.PI_NOTIFICATIONS_FOCUS_TERMINAL === "0") return;

	const app = process.env.PI_NOTIFICATIONS_TERMINAL_APP || (process.env.KITTY_WINDOW_ID ? "kitty" : undefined);
	if (!app) return;

	execFile("open", ["-a", app], { timeout: 2000 }, () => {});
}

function focusHerdrPane(): void {
	if (process.env.PI_NOTIFICATIONS_CLICK_FOCUS === "0") return;
	if (process.env.HERDR_ENV !== "1") return;

	const paneId = process.env.HERDR_PANE_ID;
	if (!paneId) return;

	const herdr = process.env.HERDR_BIN_PATH || "herdr";
	execFile(herdr, ["agent", "focus", paneId], { timeout: 2000 }, () => {
		focusTerminalApp();
	});
}

function notificationWasClicked(response: unknown): boolean {
	if (typeof response !== "string") return false;
	const normalized = response.toLowerCase().trim();
	return normalized === "activate" || normalized === "click" || normalized === "clicked";
}

function notificationGroup(): string | undefined {
	const paneId = process.env.HERDR_PANE_ID;
	return paneId ? `pi:${paneId}` : undefined;
}

function nativeNotification(title: string, body: string, sound: string): void {
	notifier.notify({ title, message: body, sound, wait: true, timeout: 300, group: notificationGroup() }, (_error, response) => {
		if (notificationWasClicked(response)) focusHerdrPane();
	});
}

function notificationsEnabled(ctx: ExtensionContext): boolean {
	return ctx.mode === "tui" && process.env.PI_NOTIFICATIONS !== "0";
}

function shouldNotify(key: string, windowMs = DEDUPE_MS): boolean {
	const now = Date.now();
	for (const [existingKey, timestamp] of recentNotifications) {
		if (now - timestamp >= windowMs) recentNotifications.delete(existingKey);
	}

	const last = recentNotifications.get(key);
	if (last !== undefined && now - last < windowMs) return false;

	recentNotifications.set(key, now);
	return true;
}

function notify(ctx: ExtensionContext, kind: keyof typeof SOUNDS, title: string, body: string): void {
	if (!notificationsEnabled(ctx)) return;
	nativeNotification(title, body, SOUNDS[kind]);
}

function getLastAssistantMessage(messages: unknown[]): Record<string, unknown> | undefined {
	for (let index = messages.length - 1; index >= 0; index--) {
		const message = messages[index];
		if (!message || typeof message !== "object") continue;
		const maybeMessage = message as { role?: unknown };
		if (maybeMessage.role === "assistant") return message as Record<string, unknown>;
	}
	return undefined;
}

function errorDetailFromMessages(messages: unknown[]): string | undefined {
	const assistant = getLastAssistantMessage(messages);
	if (!assistant) return undefined;

	const stopReason = typeof assistant.stopReason === "string" ? assistant.stopReason : undefined;
	const errorMessage = typeof assistant.errorMessage === "string" ? assistant.errorMessage : undefined;
	if (errorMessage) return errorMessage;
	if (stopReason === "error" || stopReason === "aborted") return `Agent stopped: ${stopReason}`;
	return undefined;
}

function sessionTitle(pi: ExtensionAPI, ctx: ExtensionContext): string {
	return pi.getSessionName() || basename(ctx.cwd) || "Pi";
}

function setHerdrBlocked(pi: ExtensionAPI, active: boolean): void {
	pi.events.emit("herdr:blocked", { active, label: "waiting for user" });
}

function clearHerdrQuestionBlocks(pi: ExtensionAPI): void {
	for (const _toolCallId of activeQuestionToolCalls) {
		setHerdrBlocked(pi, false);
	}
	activeQuestionToolCalls.clear();
}

export default function notifications(pi: ExtensionAPI) {
	pi.on("tool_execution_start", async (event, ctx) => {
		if (!QUESTION_TOOLS.has(event.toolName)) return;

		activeQuestionToolCalls.add(event.toolCallId);
		setHerdrBlocked(pi, true);

		const key = `question:${event.toolCallId}`;
		if (!shouldNotify(key)) return;

		lastQuestionAt = Date.now();
		notify(ctx, "question", "Pi - Question", "Needs your input");
	});

	pi.on("tool_execution_end", async (event) => {
		if (!activeQuestionToolCalls.delete(event.toolCallId)) return;
		setHerdrBlocked(pi, false);
	});

	pi.on("agent_start", async () => {
		clearHerdrQuestionBlocks(pi);
	});

	pi.on("session_shutdown", async () => {
		clearHerdrQuestionBlocks(pi);
	});

	pi.on("after_provider_response", async (event, ctx) => {
		if (event.status < 400) return;
		if (!shouldNotify(`provider:${event.status}`, 5000)) return;

		notify(ctx, "error", "Pi - Provider Error", `HTTP ${event.status}`);
	});

	pi.on("agent_end", async (event, ctx) => {
		const errorDetail = errorDetailFromMessages(event.messages as unknown[]);
		if (errorDetail) {
			if (shouldNotify(`agent-error:${errorDetail}`, 5000)) {
				notify(ctx, "error", "Pi - Error", errorDetail.slice(0, 120));
			}
			return;
		}

		if (process.env.PI_NOTIFICATIONS_IDLE === "0") return;

		const now = Date.now();
		if (now - lastQuestionAt < DEDUPE_MS) return;
		if (now - lastIdleAt < DEDUPE_MS) return;
		lastIdleAt = now;

		notify(ctx, "idle", "Pi - Awaiting Input", sessionTitle(pi, ctx));
	});

	pi.registerCommand("notify-test", {
		description: "Send a test notification: idle, question, or error.",
		handler: async (args, ctx) => {
			const kind = args.trim().toLowerCase();
			if (kind === "idle") {
				notify(ctx, "idle", "Pi - Awaiting Input", sessionTitle(pi, ctx));
				return;
			}
			if (kind === "question") {
				notify(ctx, "question", "Pi - Question", "Needs your input");
				return;
			}
			if (kind === "error") {
				notify(ctx, "error", "Pi - Error", "Test error notification");
				return;
			}

			ctx.ui.notify("Usage: /notify-test [idle|question|error]", "error");
		},
	});
}
