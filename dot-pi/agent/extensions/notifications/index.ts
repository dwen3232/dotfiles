import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { execFile } from "node:child_process";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";
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
let lastPermissionAt = 0;
let lastIdleAt = 0;
let lastNotificationContext: ExtensionContext | undefined;
let generatedPermissionPromptId = 0;
let directHerdrSeq = Date.now() * 1000;
let agentActive = false;
let rootUiSession = false;
let rootSessionId: string | undefined;
const activeQuestionToolCalls = new Set<string>();
const activePermissionPrompts = new Map<string, { signature?: string; forwardedPoll?: ReturnType<typeof setInterval> }>();

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
	lastNotificationContext = ctx;
	nativeNotification(title, body, SOUNDS[kind]);
}

function notifyWithLastContext(kind: keyof typeof SOUNDS, title: string, body: string): void {
	if (!lastNotificationContext) return;
	notify(lastNotificationContext, kind, title, body);
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

function nextDirectHerdrSeq(): string {
	directHerdrSeq = Math.max(directHerdrSeq + 1, Date.now() * 1000);
	return String(directHerdrSeq);
}

function reportHerdrStateDirect(state: "working" | "blocked" | "idle", message?: string): void {
	if (!rootUiSession) return;
	if (process.env.PI_NOTIFICATIONS_HERDR_DIRECT === "0") return;
	if (process.env.HERDR_ENV !== "1") return;

	const paneId = process.env.HERDR_PANE_ID;
	if (!paneId) return;

	const herdr = process.env.HERDR_BIN_PATH || "herdr";
	const args = ["pane", "report-agent", paneId, "--source", "herdr:pi", "--agent", "pi", "--state", state, "--seq", nextDirectHerdrSeq()];
	if (message) args.push("--message", message);
	execFile(herdr, args, { timeout: 2000 }, () => {});
}

function hasActiveHumanBlockers(): boolean {
	return activeQuestionToolCalls.size > 0 || activePermissionPrompts.size > 0;
}

function reportCurrentHerdrStateDirect(blockedMessage = "waiting for user"): void {
	if (hasActiveHumanBlockers()) {
		reportHerdrStateDirect("blocked", blockedMessage);
		return;
	}
	reportHerdrStateDirect(agentActive ? "working" : "idle");
}

function setHerdrBlocked(pi: ExtensionAPI, active: boolean, label = "waiting for user"): void {
	pi.events.emit("herdr:blocked", { active, label });
	reportCurrentHerdrStateDirect(label);
}

function clearHerdrQuestionBlocks(pi: ExtensionAPI): void {
	for (const _toolCallId of activeQuestionToolCalls) {
		setHerdrBlocked(pi, false);
	}
	activeQuestionToolCalls.clear();
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
	return value && typeof value === "object" ? (value as Record<string, unknown>) : undefined;
}

function stringField(record: Record<string, unknown>, key: string): string | undefined {
	const value = record[key];
	return typeof value === "string" && value.trim() ? value : undefined;
}

function nullableStringField(record: Record<string, unknown>, key: string): string | undefined {
	const value = record[key];
	return typeof value === "string" ? value : undefined;
}

function truncateText(value: string, maxLength = 120): string {
	return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
}

function permissionSignature(event: PermissionEventSummary): string | undefined {
	if (!event.surface && !event.value) return undefined;
	return [event.agentName || "", event.surface || "", event.value || ""].join("\u0000");
}

function permissionPromptKey(event: PermissionEventSummary): string {
	return event.requestId || permissionSignature(event) || `generated:${++generatedPermissionPromptId}`;
}

function permissionBody(event: PermissionEventSummary): string {
	const requester = event.requesterAgentName || event.agentName;
	const prefix = requester ? `${requester}: ` : "";
	if (event.surface && event.value) return truncateText(`${prefix}${event.surface}: ${event.value}`);
	if (event.value) return truncateText(`${prefix}${event.value}`);
	if (event.message) return truncateText(`${prefix}${event.message}`);
	return `${prefix}Permission required`;
}

function permissionBlockLabel(event: PermissionEventSummary): string {
	return event.surface ? `permission: ${event.surface}` : "permission required";
}

function normalizeForwarding(record: Record<string, unknown>): string | undefined {
	const forwarding = asRecord(record.forwarding);
	return forwarding ? nullableStringField(forwarding, "requesterAgentName") : undefined;
}

type PermissionEventSummary = {
	requestId?: string;
	surface?: string;
	value?: string;
	agentName?: string;
	requesterAgentName?: string;
	forwarded?: boolean;
	message?: string;
	resolution?: string;
};

function normalizePermissionEvent(raw: unknown): PermissionEventSummary {
	const record = asRecord(raw);
	if (!record) return {};
	const forwarding = asRecord(record.forwarding);
	return {
		requestId: stringField(record, "requestId"),
		surface: nullableStringField(record, "surface") || undefined,
		value: nullableStringField(record, "value") || undefined,
		agentName: nullableStringField(record, "agentName") || undefined,
		requesterAgentName: forwarding ? nullableStringField(forwarding, "requesterAgentName") : undefined,
		forwarded: !!forwarding,
		message: stringField(record, "message"),
		resolution: stringField(record, "resolution"),
	};
}

function forwardedPermissionRequestPath(requestId: string): string | undefined {
	if (!rootSessionId) return undefined;
	return join(homedir(), ".pi", "agent", "sessions", "permission-forwarding", "sessions", encodeURIComponent(rootSessionId), "requests", `${requestId}.json`);
}

function monitorForwardedPermissionPrompt(pi: ExtensionAPI, key: string, event: PermissionEventSummary): void {
	if (!event.forwarded || !event.requestId) return;
	const requestPath = forwardedPermissionRequestPath(event.requestId);
	if (!requestPath) return;

	const forwardedPoll = setInterval(() => {
		if (existsSync(requestPath)) return;
		clearPermissionPrompt(pi, key);
	}, 250);
	forwardedPoll.unref?.();
	const prompt = activePermissionPrompts.get(key);
	if (prompt) prompt.forwardedPoll = forwardedPoll;
}

function startPermissionPrompt(pi: ExtensionAPI, raw: unknown): void {
	const event = normalizePermissionEvent(raw);
	const key = permissionPromptKey(event);
	if (activePermissionPrompts.has(key)) return;

	const signature = permissionSignature(event);
	activePermissionPrompts.set(key, { signature });
	monitorForwardedPermissionPrompt(pi, key, event);
	setHerdrBlocked(pi, true, permissionBlockLabel(event));

	const notifyKey = `permission:${key}`;
	if (!shouldNotify(notifyKey, 5000)) return;

	lastPermissionAt = Date.now();
	notifyWithLastContext("permission", "Pi - Permission Required", permissionBody(event));
}

function decisionCanClearPrompt(event: PermissionEventSummary): boolean {
	if (!event.resolution) return false;
	return event.resolution.startsWith("user_") || event.resolution === "confirmation_unavailable";
}

function findPermissionPromptKey(event: PermissionEventSummary): string | undefined {
	if (event.requestId && activePermissionPrompts.has(event.requestId)) return event.requestId;
	if (!decisionCanClearPrompt(event)) return undefined;

	const signature = permissionSignature(event);
	if (signature) {
		for (const [key, prompt] of activePermissionPrompts) {
			if (prompt.signature === signature) return key;
		}
	}

	return activePermissionPrompts.keys().next().value;
}

function clearPermissionPrompt(pi: ExtensionAPI, key: string): void {
	const prompt = activePermissionPrompts.get(key);
	if (!prompt) return;
	if (prompt.forwardedPoll) clearInterval(prompt.forwardedPoll);
	activePermissionPrompts.delete(key);
	setHerdrBlocked(pi, false);
}

function clearPermissionPromptForDecision(pi: ExtensionAPI, raw: unknown): void {
	const event = normalizePermissionEvent(raw);
	const key = findPermissionPromptKey(event);
	if (!key) return;
	clearPermissionPrompt(pi, key);
}

function clearHerdrPermissionBlocks(pi: ExtensionAPI): void {
	for (const key of Array.from(activePermissionPrompts.keys())) {
		clearPermissionPrompt(pi, key);
	}
}

function startTestPermissionPrompt(pi: ExtensionAPI, ctx: ExtensionContext): void {
	lastNotificationContext = ctx;
	startPermissionPrompt(pi, {
		requestId: "notify-test:permission-block",
		surface: "bash",
		value: "test permission prompt",
		message: "Allow test permission prompt?",
	});
}

function handleNotifyTestCommand(pi: ExtensionAPI, args: string, ctx: ExtensionContext): void {
	const kind = args.trim().toLowerCase().replace(/^test\s+/, "");
	if (kind === "idle") {
		notify(ctx, "idle", "Pi - Awaiting Input", sessionTitle(pi, ctx));
		return;
	}
	if (kind === "question") {
		notify(ctx, "question", "Pi - Question", "Needs your input");
		return;
	}
	if (kind === "permission" || kind === "permission-block") {
		startTestPermissionPrompt(pi, ctx);
		ctx.ui.notify("Permission test blocker started. Run /notify-test permission-clear to clear it.", "info");
		return;
	}
	if (kind === "permission-notification") {
		notify(ctx, "permission", "Pi - Permission Required", "bash: test permission prompt");
		return;
	}
	if (kind === "permission-clear") {
		clearPermissionPrompt(pi, "notify-test:permission-block");
		ctx.ui.notify("Permission test blocker cleared.", "info");
		return;
	}
	if (kind === "error") {
		notify(ctx, "error", "Pi - Error", "Test error notification");
		return;
	}

	ctx.ui.notify("Usage: /notify-test [idle|question|permission|permission-notification|permission-clear|error]", "error");
}

export default function notifications(pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		rootUiSession = ctx?.hasUI === true || ctx?.mode === "tui";
		try {
			const sessionId = ctx?.sessionManager?.getSessionId?.();
			rootSessionId = typeof sessionId === "string" && sessionId.trim() ? sessionId.trim() : undefined;
		} catch {
			rootSessionId = undefined;
		}
		if (notificationsEnabled(ctx)) lastNotificationContext = ctx;
	});

	pi.events.on("permissions:ui_prompt", (event) => {
		startPermissionPrompt(pi, event);
	});

	pi.events.on("permissions:decision", (event) => {
		clearPermissionPromptForDecision(pi, event);
	});

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
		agentActive = true;
		clearHerdrQuestionBlocks(pi);
		clearHerdrPermissionBlocks(pi);
		reportCurrentHerdrStateDirect();
	});

	pi.on("session_shutdown", async () => {
		agentActive = false;
		clearHerdrQuestionBlocks(pi);
		clearHerdrPermissionBlocks(pi);
		lastNotificationContext = undefined;
		rootUiSession = false;
		rootSessionId = undefined;
	});

	pi.on("after_provider_response", async (event, ctx) => {
		if (event.status < 400) return;
		if (!shouldNotify(`provider:${event.status}`, 5000)) return;

		notify(ctx, "error", "Pi - Provider Error", `HTTP ${event.status}`);
	});

	pi.on("agent_end", async (event, ctx) => {
		agentActive = false;
		reportCurrentHerdrStateDirect();
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
		if (now - lastPermissionAt < DEDUPE_MS) return;
		if (now - lastIdleAt < DEDUPE_MS) return;
		lastIdleAt = now;

		notify(ctx, "idle", "Pi - Awaiting Input", sessionTitle(pi, ctx));
	});

	pi.registerCommand("notify-test", {
		description: "Send a test notification or permission blocker.",
		handler: async (args, ctx) => handleNotifyTestCommand(pi, args, ctx),
	});

	pi.registerCommand("notify", {
		description: "Alias for /notify-test. Accepts /notify test permission.",
		handler: async (args, ctx) => handleNotifyTestCommand(pi, args, ctx),
	});
}
