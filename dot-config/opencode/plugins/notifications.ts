/**
 * Desktop notifications for OpenCode events that require human attention.
 *
 * Events handled:
 *   question.asked    - AI is asking a structured question (early via tool.execute.before)
 *   permission.asked  - AI needs permission to use a tool
 *   session.idle      - Session finished a turn, awaiting input (parent sessions only)
 *   session.error     - Session encountered an error (parent sessions only)
 */
import { appendFileSync } from "node:fs";
import type { Plugin } from "@opencode-ai/plugin";
import type { Event } from "@opencode-ai/sdk/v2";
import notifier from "node-notifier";

const LOG_FILE = "/tmp/opencode-notify.log";
function log(msg: string, extra?: unknown): void {
  const line = `[${new Date().toISOString()}] ${msg}${extra !== undefined ? " " + JSON.stringify(extra) : ""}\n`;
  try {
    appendFileSync(LOG_FILE, line);
  } catch {}
}

const SOUNDS = {
  idle: "Glass",
  error: "Basso",
  permission: "Submarine",
  question: "Submarine",
} as const;

const QUESTION_DEDUPE_MS = 1500;
const recentQuestions = new Map<string, number>();

function notify(title: string, message: string, sound: string): void {
  notifier.notify({ title, message, sound });
}

function dedupeQuestion(key: string): boolean {
  const now = Date.now();
  for (const [k, t] of recentQuestions) {
    if (now - t >= QUESTION_DEDUPE_MS) recentQuestions.delete(k);
  }
  const last = recentQuestions.get(key);
  if (last !== undefined && now - last < QUESTION_DEDUPE_MS) return false;
  recentQuestions.set(key, now);
  return true;
}

export const NotificationsPlugin: Plugin = async ({ client }) => {
  log("plugin loaded");

  const getSessionTitle = async (sessionID: string): Promise<string> => {
    try {
      const result = await client.session.get({ path: { id: sessionID } });
      return result.data?.title?.slice(0, 60) || "OpenCode";
    } catch (e) {
      log("getSessionTitle error", e);
      return "OpenCode";
    }
  };

  const isParentSession = async (sessionID: string): Promise<boolean> => {
    try {
      const result = await client.session.get({ path: { id: sessionID } });
      const isParent = !result.data?.parentID;
      log("isParentSession", {
        sessionID,
        parentID: result.data?.parentID,
        isParent,
      });
      return isParent;
    } catch (e) {
      log("isParentSession error", e);
      return true; // fail open: notify rather than miss
    }
  };

  return {
    "tool.execute.before": async (input) => {
      if (input.tool === "question") {
        const key = `${input.sessionID}:${input.callID}`;
        log("tool.execute.before question", { key });
        if (dedupeQuestion(key)) {
          log("notifying question (tool.execute.before)");
          notify("OpenCode - Question", "Needs your input", SOUNDS.question);
        } else {
          log("question deduplicated (tool.execute.before)");
        }
      }
    },
    event: async ({ event: _event }) => {
      // Cast to v2 Event — workaround for @opencode-ai/plugin using v1 SDK types
      // https://github.com/anomalyco/opencode/issues/7147
      const event = _event as unknown as Event;
      log("event received", { type: event.type });
      if (event.type === "question.asked") {
        // Backup path: fires after tool.execute.before in most cases.
        // Deduplicated so no double-notification when both trigger.
        const { sessionID, tool, id } = event.properties;
        const key = tool ? `${sessionID}:${tool.callID}` : `${sessionID}:${id}`;
        if (dedupeQuestion(key)) {
          log("notifying question (event)");
          notify("OpenCode - Question", "Needs your input", SOUNDS.question);
        } else {
          log("question deduplicated (event)");
        }
      } else if (event.type === "permission.asked") {
        const { permission, patterns } = event.properties;
        const detail = patterns.length
          ? `${permission}: ${patterns.join(", ")}`
          : permission;
        log("notifying permission", { detail });
        notify("OpenCode - Permission Required", detail, SOUNDS.permission);
      } else if (event.type === "session.idle") {
        const { sessionID } = event.properties;
        log("session.idle received", { sessionID });
        if (!(await isParentSession(sessionID))) {
          log("session.idle suppressed (child session)");
          return;
        }
        const title = await getSessionTitle(sessionID);
        log("notifying session.idle", { title });
        notify("OpenCode - Awaiting Input", title, SOUNDS.idle);
      } else if (event.type === "session.error") {
        const { sessionID, error } = event.properties;
        log("session.error received", { sessionID });
        if (sessionID && !(await isParentSession(sessionID))) {
          log("session.error suppressed (child session)");
          return;
        }
        const detail = error
          ? `${error.name}: ${"message" in error.data ? String(error.data.message) : error.name}`
          : "Unknown error";
        log("notifying session.error", { detail });
        notify("OpenCode - Error", detail, SOUNDS.error);
      }
    },
  };
};
