# Moshi webhook notifications

Pi extension that sends Moshi webhook pushes when Pi needs human input.

Uses Moshi's documented webhook endpoint:

```text
POST https://api.getmoshi.app/api/webhook
```

Docs: <https://getmoshi.app/docs/notifications>

## Required local environment

Set one of these in a local, non-repo shell config or secret manager:

```zsh
export MOSHI_WEBHOOK_TOKEN="<token from Moshi Settings -> Push Notifications>"
```

Aliases also accepted:

```zsh
export MOSHI_PUSH_TOKEN="<token>"
export MOSHI_API_TOKEN="<token>"
```

Do not commit the token. The host pairing token used by `moshi-hook pair` is different from this push/webhook token.

## Events

Always sends when a token is present:
- `ask_user` / `question` start -> `Pi needs input`
- `permissions:ui_prompt` -> `Pi permission required`
- agent error -> `Pi error`

Optional completion notifications:

```zsh
export MOSHI_WEBHOOK_NOTIFY_COMPLETE=1
```

Optional fan-out to all opted-in devices on the same Moshi license:

```zsh
export MOSHI_WEBHOOK_UNIFIED=1
```

Request notifications explicitly and warn if the token is missing:

```zsh
export MOSHI_WEBHOOK_NOTIFICATIONS=1
```

Disable without removing the extension:

```zsh
export MOSHI_WEBHOOK_NOTIFICATIONS=0
```

Debug webhook failures to stderr:

```zsh
export MOSHI_WEBHOOK_DEBUG=1
```

Notification messages are truncated and common token/password/API-key patterns are redacted before sending.
