#!/bin/sh

set -eu

event_type="${1:-unknown}"
hook_input_file="$(mktemp "${TMPDIR:-/tmp}/claude-notification-hook.XXXXXX")" || exit 0
trap 'rm -f "$hook_input_file"' EXIT HUP INT TERM
cat >"$hook_input_file" 2>/dev/null || true

python3 - "$event_type" "$hook_input_file" <<'PY'
import json
import os
import shlex
import shutil
import subprocess
import sys

_event_type = sys.argv[1] if len(sys.argv) > 1 else "unknown"
_hook_input_file = sys.argv[2] if len(sys.argv) > 2 else ""

try:
    with open(_hook_input_file, encoding="utf-8") as handle:
        raw = handle.read()
    hook_input = json.loads(raw) if raw.strip() else {}
except Exception:
    hook_input = {}

project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
repo_name = os.path.basename(project_dir.rstrip(os.sep)) or "Claude"
try:
    branch = subprocess.check_output(
        ["git", "-C", project_dir, "rev-parse", "--abbrev-ref", "HEAD"],
        stderr=subprocess.DEVNULL,
        text=True,
        timeout=1,
    ).strip()
except Exception:
    branch = ""

if _event_type == "question":
    title = "Claude Code - Awaiting Input"
    sound = "Submarine"
elif _event_type == "permission":
    title = "Claude Code - Permission Required"
    sound = "Submarine"
elif _event_type == "stop":
    title = "Claude Code - Awaiting Input"
    sound = "Glass"
else:
    title = "Claude Code - Notification"
    sound = "Glass"

if _event_type == "permission":
    tool_name = hook_input.get("tool_name")
    if isinstance(tool_name, str) and tool_name:
        message = f"{repo_name}:{branch} - {tool_name}" if branch else f"{repo_name} - {tool_name}"
    else:
        message = f"{repo_name}:{branch}" if branch else repo_name
else:
    message = f"{repo_name}:{branch}" if branch else repo_name

pane_id = os.environ.get("HERDR_PANE_ID", "")
group = f"claude:{pane_id}" if pane_id else "claude-code"

terminal_notifier = shutil.which("terminal-notifier")
if not terminal_notifier:
    raise SystemExit(0)

args = [
    terminal_notifier,
    "-title", title,
    "-message", message,
    "-group", group,
    "-sound", sound,
    "-ignoreDnD",
]

if (
    os.environ.get("CLAUDE_NOTIFICATIONS_CLICK_FOCUS") != "0"
    and os.environ.get("HERDR_ENV") == "1"
    and pane_id
):
    herdr_env = os.environ.get("HERDR_BIN_PATH") or "herdr"
    herdr = shutil.which(herdr_env) if os.sep not in herdr_env else herdr_env
    if herdr:
        commands = [f"{shlex.quote(herdr)} agent focus {shlex.quote(pane_id)}"]
    else:
        commands = []
    if os.environ.get("CLAUDE_NOTIFICATIONS_FOCUS_TERMINAL") != "0":
        terminal_app = os.environ.get("CLAUDE_NOTIFICATIONS_TERMINAL_APP")
        if not terminal_app and os.environ.get("KITTY_WINDOW_ID"):
            terminal_app = "kitty"
        if terminal_app:
            commands.append(f"/usr/bin/open -a {shlex.quote(terminal_app)}")
    if commands:
        args.extend(["-execute", "; ".join(commands)])

try:
    subprocess.run(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=2)
except Exception:
    pass
PY
