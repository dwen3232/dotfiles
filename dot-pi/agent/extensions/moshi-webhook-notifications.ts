import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent"

const QUESTION_TOOLS = new Set(["ask_user", "ask-user", "question", "functions.ask_user"])
const WEBHOOK_URL = "https://api.getmoshi.app/api/webhook"
const DEDUPE_MS = 1500
const COMPLETE_DEDUPE_MS = 5000
const REQUEST_TIMEOUT_MS = 5000
const MESSAGE_LIMIT = 180

const recent = new Map<string, number>()
let lastContext: ExtensionContext | undefined

type PushKind = "question" | "permission" | "complete" | "error"

function token(): string | undefined {
  return process.env.MOSHI_WEBHOOK_TOKEN || process.env.MOSHI_PUSH_TOKEN || process.env.MOSHI_API_TOKEN
}

function notificationsRequired(): boolean {
  return process.env.MOSHI_WEBHOOK_NOTIFICATIONS === "1"
}

function notificationsEnabled(): boolean {
  return process.env.MOSHI_WEBHOOK_NOTIFICATIONS !== "0" && !!token()
}

function completionEnabled(): boolean {
  return process.env.MOSHI_WEBHOOK_NOTIFY_COMPLETE === "1"
}

function unifiedPushEnabled(): boolean {
  return process.env.MOSHI_WEBHOOK_UNIFIED === "1"
}

function debugEnabled(): boolean {
  return process.env.MOSHI_WEBHOOK_DEBUG === "1"
}

function debug(message: string): void {
  if (debugEnabled()) console.error(`[moshi-webhook-notifications] ${message}`)
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
  return value && typeof value === "object" ? (value as Record<string, unknown>) : undefined
}

function firstString(...values: unknown[]): string {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) return value.trim()
  }
  return ""
}

function truncate(value: string, max = MESSAGE_LIMIT): string {
  return value.length > max ? `${value.slice(0, max - 1)}…` : value
}

function redactSensitive(value: string): string {
  return value
    .replace(/(\b--?(?:token|api[-_]?key|password|secret)\b(?:\s+|=))["']?[^\s"']+["']?/gi, "$1[REDACTED]")
    .replace(/(\b(?:token|api[-_]?key|password|secret)\b\s*[:=]\s*)["']?[^\s"']+["']?/gi, "$1[REDACTED]")
    .replace(/(Authorization:\s*Bearer\s+)[^\s"']+/gi, "$1[REDACTED]")
}

function safeMessage(value: string): string {
  return truncate(redactSensitive(value))
}

function sessionTitle(ctx?: ExtensionContext): string {
  const cwd = ctx?.cwd || process.cwd()
  return cwd.split("/").filter(Boolean).pop() || "Pi"
}

function shouldSend(key: string, windowMs = DEDUPE_MS): boolean {
  const now = Date.now()
  for (const [existingKey, timestamp] of recent) {
    if (now - timestamp >= windowMs) recent.delete(existingKey)
  }

  const last = recent.get(key)
  if (last !== undefined && now - last < windowMs) return false
  recent.set(key, now)
  return true
}

function isQuestionTool(toolName: unknown): boolean {
  if (typeof toolName !== "string") return false
  const normalized = toolName.toLowerCase()
  return QUESTION_TOOLS.has(normalized) || normalized.endsWith(".ask_user") || normalized.endsWith("/ask_user")
}

function questionText(event: Record<string, unknown>): string {
  const args = asRecord(event.args) || asRecord(event.input) || {}
  const nested = asRecord(args.question)
  return firstString(
    args.question,
    args.prompt,
    args.message,
    args.text,
    args.title,
    nested?.question,
    nested?.prompt,
    nested?.message,
    nested?.text,
    nested?.title,
    event.question,
    event.prompt,
    event.message,
    "Pi needs input",
  )
}

function permissionText(event: Record<string, unknown>): string {
  const forwarding = asRecord(event.forwarding)
  return firstString(
    event.surface && event.value ? `${event.surface}: ${event.value}` : undefined,
    event.value,
    event.message,
    forwarding?.requesterAgentName ? `${forwarding.requesterAgentName} requested permission` : undefined,
    "Permission required",
  )
}

function errorDetail(messages: unknown[]): string | undefined {
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = asRecord(messages[index])
    if (!message || message.role !== "assistant") continue

    const errorMessage = firstString(message.errorMessage)
    if (errorMessage) return errorMessage

    const stopReason = firstString(message.stopReason)
    if (stopReason === "error" || stopReason === "aborted") return `Agent stopped: ${stopReason}`

    return undefined
  }

  return undefined
}

async function sendPush(kind: PushKind, title: string, message: string, ctx?: ExtensionContext): Promise<void> {
  const pushToken = token()
  if (!pushToken || process.env.MOSHI_WEBHOOK_NOTIFICATIONS === "0") return

  const sanitizedMessage = safeMessage(message)
  const key = `${kind}:${title}:${sanitizedMessage}`
  if (!shouldSend(key, kind === "complete" ? COMPLETE_DEDUPE_MS : DEDUPE_MS)) return

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS)

  try {
    const response = await fetch(WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      signal: controller.signal,
      body: JSON.stringify({
        token: pushToken,
        title,
        message: sanitizedMessage,
        source: "pi",
        category: kind,
        project: sessionTitle(ctx),
        unified: unifiedPushEnabled() || undefined,
      }),
    })

    if (!response.ok) debug(`webhook failed: ${response.status} ${response.statusText}`)
  } catch (error) {
    debug(`webhook error: ${error instanceof Error ? error.message : String(error)}`)
  } finally {
    clearTimeout(timeout)
  }
}

export default function moshiWebhookNotifications(pi: ExtensionAPI): void {
  pi.on("session_start", (_event, ctx) => {
    lastContext = ctx
    if (notificationsRequired() && !notificationsEnabled()) {
      ctx.ui.notify("Moshi webhook notifications requested but MOSHI_WEBHOOK_TOKEN is not set.", "info")
    }
  })

  pi.on("agent_start", (_event, ctx) => {
    lastContext = ctx
  })

  pi.on("tool_execution_start", (event, ctx) => {
    lastContext = ctx
    if (!isQuestionTool(event.toolName)) return

    const eventObj = asRecord(event) || {}
    void sendPush("question", "Pi needs input", questionText(eventObj), ctx)
  })

  pi.events.on("permissions:ui_prompt", (event) => {
    const eventObj = asRecord(event) || {}
    void sendPush("permission", "Pi permission required", permissionText(eventObj), lastContext)
  })

  pi.on("agent_end", (event, ctx) => {
    lastContext = ctx
    const messages = Array.isArray(event.messages) ? event.messages : []
    const detail = errorDetail(messages)

    if (detail) {
      void sendPush("error", "Pi error", detail, ctx)
    } else if (completionEnabled()) {
      void sendPush("complete", "Pi turn complete", sessionTitle(ctx), ctx)
    }
  })

  pi.on("session_shutdown", () => {
    lastContext = undefined
  })
}
