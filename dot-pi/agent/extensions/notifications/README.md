# Pi Notifications Extension

Desktop notifications for Pi TUI sessions, with click-to-focus support for Herdr panes.

## Behavior

- Idle: notifies when Pi finishes a turn and is awaiting input.
- Question: notifies when `ask_user` or `question` tools need input.
- Permission: notifies when `@gotgenes/pi-permission-system` emits `permissions:ui_prompt`.
- Errors: notifies on provider errors and failed agent turns.

Question and permission prompts also emit `herdr:blocked` so Herdr can show the pane as blocked until the prompt resolves. The root UI session also reports the state directly to Herdr when running inside Herdr, because command-triggered custom events may not reliably update the managed Herdr bridge in all Pi contexts. Child/subagent sessions do not direct-report parent pane state.

## Permission prompts

The permission integration listens to the permission-system event bus:

- `permissions:ui_prompt` starts a permission blocker and sends `Pi - Permission Required`.
- `permissions:decision` clears the matching permission blocker.

Matching prefers `requestId` when available. If the decision payload does not include `requestId`, the extension falls back to `agentName + surface + value`, then to the oldest active user-driven permission prompt. Forwarded subagent prompts are also cleared when their forwarding request file disappears after the parent writes a response. Any stale prompt bookkeeping is cleared on agent start and session shutdown.

Notification bodies use only the permission-system display projection (`surface`, `value`, `message`, and forwarding context) and truncate long values.

## Test commands

Run inside Pi after `/reload`:

```text
/notify-test idle
/notify-test question
/notify-test permission
/notify-test permission-notification
/notify-test permission-clear
/notify-test error
```

`/notify test permission` is also supported as an alias for `/notify-test permission`.

Use `permission` to verify Herdr enters blocked state, then `permission-clear` to verify it clears. Use `permission-notification` when you want to send only the desktop notification without changing Herdr state.

Set `PI_NOTIFICATIONS=0` to disable notifications. Set `PI_NOTIFICATIONS_CLICK_FOCUS=0` to disable click-to-focus. Set `PI_NOTIFICATIONS_HERDR_DIRECT=0` to disable the direct Herdr state-report fallback.
