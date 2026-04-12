---
name: 1password
description: >
  Load this skill only when the user explicitly mentions 1Password or "1pass". Do not load for general secrets or credential management unless 1Password is specifically referenced.

  Examples of when to load this skill:
  - "read the database password from 1Password"
  - "use 1pass to inject secrets into the config file"
  - "run the dev server with secrets from 1Password"
  - "get the API key from 1pass and set it as an env var"
  - "save the new token to 1Password"
  - "pull the staging credentials out of 1pass and run the migration"
  - "set up the .env file using our 1Password vault"
  - "what's the secret reference syntax for 1pass?"
---

# 1Password CLI (`op`)

Manages secrets from 1Password vaults. Run `op [command] --help` for full details on any command.

## Secret reference syntax

The core concept. References follow the format:

```
op://<vault>/<item>/<field>
```

Examples:
```
op://app-prod/db/password
op://app-prod/db/username
op://app-prod/ssh-key/private key?ssh-format=openssh
op://app-prod/db/one-time password?attribute=otp
```

## Key commands

### Read a single secret
```
op read op://app-prod/db/password
op read -n op://app-prod/db/password   # no trailing newline, good for subshells
```

### Run a process with secrets as env vars
Scans env vars for `op://` references and resolves them before running the command:
```
export DB_PASSWORD="op://app-prod/db/password"
op run -- node server.js

# Or with a .env file containing op:// references
op run --env-file=.env -- npm start
```

### Inject secrets into a config template
Template uses `{{ op://vault/item/field }}` syntax:
```
op inject -i config.yml.tpl -o config.yml
echo "db_url: {{ op://prod/db/url }}" | op inject
```

### Item management
```
op item get <item-name> --vault <vault>
op item get <item-name> --fields password,username
op item list --vault <vault>
op item create --template <file>
op item edit <item-name> field=value
```

## Global flags

- `--vault <name>` — target a specific vault
- `--account <shorthand>` — target a specific account
- `--format json` — machine-readable output
- `--no-newline` / `-n` — suppress trailing newline (useful in subshells)

## Never do

- **Never read a secret value directly** — do not run `op read` and use the output in conversation, logs, or files. Secret values must only flow into processes via `op run` or `op inject`, never through the model's context.
- **Never print secrets to stdout** — if using `op run`, do not pass `--no-masking`. Leave masking on.
- **Never hardcode a resolved secret** — do not substitute a secret value into a file manually. Always use `op inject` with a template so the plaintext never appears in source.
- **Never commit a resolved config file** — files produced by `op inject` contain live secrets and must not be committed or left on disk longer than needed.
- **Never store secrets in environment files that are checked in** — `.env` files used with `op run` should contain `op://` references only, never resolved values.

## Common patterns

**Subshell injection:**
```
docker login -u $(op read op://prod/docker/username) -p $(op read op://prod/docker/password)
```

**Environment-aware references using variables:**
```
# .env
DB_PASSWORD=op://$APP_ENV/db/password

APP_ENV=prod op run --env-file=.env -- npm start
```

**Save output to file (e.g. SSH key, certificate):**
```
op read --out-file ./key.pem op://prod/server/ssh/private-key
```
