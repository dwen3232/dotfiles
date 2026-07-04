# Monty for Agent Scratch Code

Date: 2026-07-04

## Goal

Agents often use random ad-hoc scripting runtimes (`node`, `python`, `perl`, etc.) for quick logic or verification. The target policy is:

- Bash remains allowed for shell orchestration and project commands.
- Agents should use Monty whenever they want a throwaway general-purpose script.
- Project-native runtimes remain allowed when testing/building the project itself.
- Revisit this once the official Monty CLI is publicly installable.

## Monty status

Repository: <https://github.com/pydantic/monty>

Monty is an experimental, minimal, secure Python interpreter written in Rust for AI-generated code. It is designed to run a constrained subset of Python without exposing host filesystem, environment, network, subprocesses, or third-party packages unless the host explicitly exposes controlled functionality.

Useful supported capabilities:

- Python-like expressions and control flow for calculations, parsing, filtering, sorting, transforms, and verification.
- Functions, async functions, closures, decorators.
- `if`, `for`, `while`, `try`/`except`/`finally`, `raise`, `assert`, `return`, `global`, `nonlocal`.
- List/dict/set comprehensions.
- f-strings.
- Limited imports from bundled modules only.
- Resource limits for memory, allocations, recursion depth, and duration.
- Snapshot/serialization support.
- Python, JavaScript/TypeScript, and Rust bindings.

Bundled stdlib modules documented in the repo:

- `asyncio`
- `datetime`
- `json`
- `math`
- `os`
- `pathlib`
- `re`
- `sys`
- `typing`

Implemented builtins documented in `limitations/builtins.md`:

```text
abs, all, any, bin, chr, divmod, enumerate, filter,
getattr, hasattr, hash, hex, id, isinstance, len, map,
max, min, next, oct, open, ord, pow, print, repr,
reversed, round, setattr, sorted, sum, type, zip
```

Implemented constructors:

```text
bool, bytes, dict, float, frozenset, int, list, range,
set, slice, str, tuple
```

Important limitations:

- No third-party Python libraries.
- No `eval`, `exec`, `compile`, `__import__`, `globals`, `locals`, `vars`, or `dir`.
- No `class` definitions yet.
- No `match` statements.
- No `yield` / generators.
- No walrus operator.
- No common unsafe or broad modules such as `subprocess`, `socket`, `urllib`, `random`, `itertools`, `functools`, `collections`, etc.
- Filesystem access requires explicit host mounts. Without mounts, `open()` and pathlib I/O fail.

Local smoke check with `uv run --with pydantic-monty` confirmed:

- `pydantic_monty.Monty('1+2').run()` returns `3`.
- `open('/etc/passwd').read()` fails under standard execution.
- `os.environ` fails under standard execution.
- `import subprocess` fails with `ModuleNotFoundError`.

## Installation research

### Python package

PyPI publishes `pydantic-monty`:

```bash
pip install pydantic-monty
```

Source: <https://pypi.org/project/pydantic-monty/>

This currently installs Python bindings, not a `monty` executable. Verified locally:

```bash
uvx --from pydantic-monty monty --version
```

Result:

```text
Package `pydantic-monty` does not provide any executables.
```

### JavaScript package

NPM publishes `@pydantic/monty`:

```bash
npm install @pydantic/monty
```

Source: <https://www.npmjs.com/package/@pydantic/monty>

This provides JS/TS bindings. The package has no `bin` entry, so it is not a global CLI.

### Official CLI in source

The repo contains a `monty-cli` crate with a binary named `monty`. CLI capabilities in source include:

```bash
monty
monty -c "print('hello world')"
monty script.py
monty --type-check -c "..."
monty --mount /host/path::/virtual/path::ro -c "..."
monty --max-duration 0.5 --max-memory 10MB -c "..."
```

Source files:

- <https://github.com/pydantic/monty/blob/main/crates/monty-cli/README.md>
- <https://github.com/pydantic/monty/blob/main/crates/monty-cli/src/main.rs>

The repo also contains packaging docs for `pydantic-monty-cli`, intended to install the compiled `monty` binary into the environment scripts directory. At research time, the package was not publicly available:

```bash
uvx --from pydantic-monty-cli monty --version
```

Result:

```text
Because pydantic-monty-cli was not found in the package registry ...
```

Cargo registry state also did not provide a usable CLI package; crates were placeholders such as `monty-cli = "0.0.0"`.

The source repo declares `rust-version = "1.95"`, while the local toolchain was `rustc 1.88.0`, so source installation is not currently convenient here.

## Preferred future install path

Once `pydantic-monty-cli` is public, prefer one of:

```bash
uv tool install pydantic-monty-cli
```

or:

```bash
pipx install pydantic-monty-cli
```

Then verify:

```bash
monty --version
monty -c 'sum([1, 2, 3])'
```

If a Homebrew formula appears later, add it to `Brewfile` instead.

## Deferred implementation approach

Do not roll a custom wrapper unless the need becomes urgent. Once the official CLI exists:

1. Add the install method to `Brewfile`, `Justfile`, or bootstrap docs.
2. Add `monty` to allowed agent shell commands.
3. Add global agent instructions that require Monty for scratch logic.
4. Add permission nudges for obvious ad-hoc runtime one-liners.
5. Leave project-native commands alone.

Suggested global instruction block:

```md
## Ad-hoc Code Execution

- Use `monty` for all ad-hoc computational logic, data transformation, parsing, sorting, filtering, arithmetic, or verification that would otherwise be written as a throwaway `python`, `python3`, `node`, `perl`, `ruby`, or `php` script.
- Bash remains allowed for shell orchestration: running project commands, piping existing CLIs, file discovery, process management, and simple text commands.
- Do not use `node -e`, `python -c`, `python <<EOF`, `perl -e`, `ruby -e`, or temporary scripts in general-purpose scripting languages for scratch logic. Use `monty -c '...'` or pipe code into `monty`.
- Project-native commands are allowed when they are the thing being tested or built, e.g. `npm test`, `pnpm build`, `python -m pytest`, `uv run ...`, Rails/Ruby test commands, or repository scripts.
- If Monty cannot express the logic because of a documented limitation, state the limitation briefly and use the project-native runtime only for that specific need.
```

Suggested Claude Code permission nudges:

```json
"Bash(monty:*)",
"Bash(monty *)",
"Bash(node -e:*)",
"Bash(node -e *)",
"Bash(python -c:*)",
"Bash(python -c *)",
"Bash(python3 -c:*)",
"Bash(python3 -c *)",
"Bash(perl -e:*)",
"Bash(perl -e *)"
```

Use `ask` rather than `deny` for ad-hoc interpreter patterns if the tool supports it. This preserves escape hatches for project-runtime reproduction while making the policy visible.

Suggested OpenCode permission nudges:

```json
"monty": "allow",
"monty *": "allow",
"node -e *": "ask",
"python -c *": "ask",
"python3 -c *": "ask",
"perl -e *": "ask"
```

Avoid shadowing `python`, `node`, or `perl` with wrapper binaries or aliases. That would break legitimate project commands, package managers, shebangs, tests, and tooling.

## Places to apply policy later

- Pi global instructions: `dot-pi/agent/AGENTS.md`
- OpenCode global instructions: `dot-config/opencode/AGENTS.md`
- Claude Code global instructions: create `dot-claude/CLAUDE.md` for `~/.claude/CLAUDE.md`
- Claude permissions: `dot-claude/settings.json`
- OpenCode permissions: `dot-config/opencode/opencode.json`
