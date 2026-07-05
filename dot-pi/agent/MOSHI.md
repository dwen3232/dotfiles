# Moshi setup

Setup notes for a new Mac using Moshi to reach Pi inside Herdr with Mosh transport and iOS notifications.

## Install

```sh
just bootstrap
```

This installs the Homebrew dependencies from `Brewfile`, trusts the `rjyo/moshi` tap, syncs submodules, installs Oh My Zsh, and stows dotfiles.

Relevant packages:

- `mosh`
- `moshi-hook`
- `herdr`

## Shell path for non-interactive probes

`dot-zshenv` is stowed to `~/.zshenv` and keeps PATH minimal for non-interactive SSH probes:

```zsh
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:$HOME/bin:$PATH"
```

This lets Moshi find `herdr`, `mosh-server`, and `moshi-hook` when it connects without loading interactive `.zshrc` setup.

Verify:

```sh
zsh -fc 'command -v herdr; command -v mosh-server; command -v moshi-hook'
```

## Agent hook pairing

Pair the local Moshi hook daemon from the token shown in Moshi:

```sh
moshi-hook pair --token '<pairing token>'
just setup-moshi-services
moshi-hook install --target pi
moshi-hook status
```

Expected status:

- `status: paired`
- `pi current ~/.pi/agent/extensions/moshi-hooks.ts`
- `moshi-hook` running under Homebrew services

`dot-pi/agent/extensions/moshi-hooks.ts` is customized from the generated hook to keep Moshi lifecycle events portable across Apple Silicon and Intel Homebrew paths.

## Host access over Mosh

Mosh does not have a persistent daemon. Moshi connects over SSH, starts `mosh-server` on the Mac, then switches the session to UDP.

The Mac needs:

- macOS Remote Login enabled
- `mosh-server` installed and on non-interactive PATH
- Moshi host access pairing

Start the local services and enable Remote Login:

```sh
just setup-moshi-services
```

Pair host access:

```sh
moshi-hook host setup
moshi-hook host list
```

Expected: `moshi-hook host list` shows at least one local host pairing.

## Pi notifications

Native `moshi-hook pi-hook` handles lifecycle events such as turn completion. Question and permission events are sent through a separate webhook extension:

- `dot-pi/agent/extensions/moshi-webhook-notifications.ts`
- `dot-pi/agent/extensions/moshi-webhook-notifications.md`

Set the webhook token in a private per-machine file such as `~/.zshrc.personal`; do not commit it:

```zsh
export MOSHI_WEBHOOK_TOKEN='<token from Moshi Settings -> Push Notifications>'
```

Tracked `.zshrc` sets non-secret defaults:

```zsh
export MOSHI_WEBHOOK_NOTIFICATIONS=1
export MOSHI_WEBHOOK_NOTIFY_COMPLETE=0
export MOSHI_WEBHOOK_UNIFIED=0
export MOSHI_WEBHOOK_DEBUG=0
```

Restart the Pi/Herdr shell after setting the token so Pi inherits the environment, then run `/reload`.

Webhook notifications sent:

- `ask_user` / `question` start -> `Pi needs input`
- permission prompt -> `Pi permission required`
- agent error -> `Pi error`

`MOSHI_WEBHOOK_UNIFIED=1` fans webhook pushes out to every opted-in device on the same Moshi license. Keep it `0` for single-device delivery.

## Validation

```sh
just check-deps
just setup-moshi-services
moshi-hook status
moshi-hook host list
zsh -fc 'command -v herdr; command -v mosh-server; command -v moshi-hook'
```

Expected Moshi Pro note on non-Pro installs: diff viewer and browser preview are unavailable, while host access and notifications still work.
