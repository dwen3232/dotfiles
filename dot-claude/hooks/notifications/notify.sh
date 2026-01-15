#!/bin/bash

# Get event type from first argument
event_type="${1:-unknown}"

# Extract repository name
repo_name=$(basename "$CLAUDE_PROJECT_DIR" 2>/dev/null || echo "unknown-project")

# Get current git branch
branch=$(git -C "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Build notification title based on event type
if [ "$event_type" = "AskUserQuestion" ]; then
  title="Claude Code - Awaiting Input"
elif [ "$event_type" = "Stop" ]; then
  title="Claude Code - Stopped"
elif [ "$event_type" = "unknown" ]; then
  title="Claude Code - Notification"
else
  # If it's not a known hook event, it's likely a tool name from PermissionRequest
  title="Claude Code - Permission Required"
fi

# Format message with repo and branch info
if [ -n "$branch" ]; then
  message="${repo_name}:${branch}"
else
  message="${repo_name}:(no git repository)"
fi

# Launch terminal-notifier if available
if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title "$title" \
    -message "$message" \
    -group "claude-code" \
    -sound default \
    -ignoreDnD
fi
