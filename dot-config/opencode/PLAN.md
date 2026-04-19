# opencode-plugin-codefmt — Build Plan

## Overview

A published npm plugin for OpenCode that automatically formats and lints files after the agent completes a turn. Inspired by `conform.nvim` (formatting) and `nvim-lint` (linting). Fills a gap that exists in both the OpenCode and Claude Code ecosystems — no equivalent published plugin exists for either.

---

## Design Principles

- **Never hijack the prompt for infra errors** — config problems log to stderr only
- **Format then lint, always** — formatting can affect lint output, so order matters
- **Batch at `session.idle`** — collect edits across the whole turn, act once at the end
- **Schema-driven registry** — linters and formatters are data, not special cases in the runner
- **cwd-aware** — walk up from each edited file to find the nearest config root, fall back to `process.cwd()` if none found
- **User config wins** — project-level config overrides user-level config entirely, no merging magic

---

## Execution Flow

```
Agent turn in progress
  └── tool.execute.after fires on each edit/write
        └── track filePath in pendingFiles set

Agent finishes turn → session.idle fires
  └── 1. Format all files in pendingFiles (sequential per file, silent)
  └── 2. Lint all files in pendingFiles (sequential per file)
  └── 3. Collect any lint errors
  └── 4. If errors exist → single client.session.prompt with consolidated report
  └── 5. Clear pendingFiles
```

Formatting happens silently between turns. The agent starts its next turn with correctly formatted files on disk and a single lint report if there's anything to fix.

---

## Configuration

Two config file locations, project overrides user entirely:

```
.opencode/codefmt.json         ← project-level
~/.config/opencode/codefmt.json ← user-level (default)
```

### Config Shape

```json
{
  "$schema": "https://unpkg.com/opencode-plugin-codefmt/codefmt.schema.json",

  "formatters_by_ext": {
    ".ts": ["prettier"],
    ".tsx": ["prettier"],
    ".py": ["isort", "black"],
    ".go": ["gofmt"],
    ".rs": ["rustfmt"]
  },

  "linters_by_ext": {
    ".ts": ["eslint"],
    ".tsx": ["eslint"],
    ".py": ["ruff"],
    ".go": ["golangci-lint"]
  },

  "disabled": [],

  "formatters": {
    "prettier": {
      "cmd": "prettier",
      "args": ["--write"],
      "markers": [".prettierrc", ".prettierrc.json", ".prettierrc.js", "prettier.config.js", "package.json"],
      "require_markers": false
    },
    "biome": {
      "cmd": "biome",
      "args": ["format", "--write"],
      "markers": ["biome.json", "biome.jsonc"],
      "require_markers": true
    }
  },

  "linters": {
    "eslint": {
      "args": ["--max-warnings", "0"]
    }
  }
}
```

### Config Field Reference

| Field | Description |
|---|---|
| `formatters_by_ext` | Which formatters to run per file extension, in order, all run sequentially |
| `linters_by_ext` | Which linters to run per file extension, in order, all run sequentially |
| `disabled` | Formatter or linter names to skip globally |
| `formatters[name].cmd` | Override binary path, defaults to linter name on `$PATH` |
| `formatters[name].args` | Arguments passed to the formatter |
| `formatters[name].markers` | Files to look for when walking up the tree to find config root |
| `formatters[name].require_markers` | If `true`, skip silently when no markers found (default `false`) |
| `linters[name].cmd` | Override binary path |
| `linters[name].args` | Extra arguments appended to the linter command |
| `linters[name].markers` | Files to look for when walking up the tree to find config root |
| `linters[name].env` | Environment variables to set for this tool's process |

---

## Root Detection

For each edited file, walk up the directory tree looking for the tool's `markers`. Run the tool from the first directory where a marker is found. If no marker is found:

- `require_markers: false` → run from `process.cwd()`, tool uses its own built-in defaults
- `require_markers: true` → skip silently

```
src/components/Button.tsx
  └── src/components/   no .prettierrc
  └── src/              no .prettierrc
  └── ./                found .prettierrc ✓ → run prettier from ./
```

This handles monorepos naturally — nested configs are discovered per-file.

---

## Built-in Registry Defaults

The plugin ships default definitions for common tools. Users override via config.

### Formatters

| Name | Ext defaults | `require_markers` | Default args |
|---|---|---|---|
| `prettier` | `.js .ts .jsx .tsx .css .html .json .md .yaml` | `false` | `--write` |
| `biome` | `.js .ts .jsx .tsx .json` | `true` | `format --write` |
| `black` | `.py` | `false` | (filename only) |
| `isort` | `.py` | `false` | (filename only) |
| `gofmt` | `.go` | `false` | `-w` |
| `rustfmt` | `.rs` | `false` | (filename only) |
| `stylua` | `.lua` | `false` | (filename only) |
| `shfmt` | `.sh` | `false` | `-w` |

### Linters

| Name | Ext defaults | `require_markers` | Default args |
|---|---|---|---|
| `eslint` | `.js .ts .jsx .tsx` | `false` | `--format json` |
| `biome` | `.js .ts .jsx .tsx .json` | `true` | `check` |
| `ruff` | `.py` | `false` | `check --output-format json` |
| `golangci-lint` | `.go` | `false` | `run --out-format json` |
| `shellcheck` | `.sh` | `false` | `--format json` |
| `hadolint` | `Dockerfile` | `false` | `-f json` |
| `markdownlint` | `.md` | `false` | (filename only) |

---

## Zod Schema

```typescript
import { z } from "zod";

const ToolOverrideSchema = z.object({
  cmd: z.string().optional()
    .describe("Override the binary path. Defaults to the tool name on $PATH."),
  args: z.array(z.string()).optional()
    .describe("Arguments passed to the tool command."),
  markers: z.array(z.string()).optional()
    .describe("Files that indicate the project root. Plugin walks up from the edited file to find them."),
  require_markers: z.boolean().optional()
    .describe("If true, skip this tool silently when no markers are found. Default false."),
  env: z.record(z.string()).optional()
    .describe("Environment variables to set for this tool's process."),
});

export const CodefmtConfigSchema = z.object({
  formatters_by_ext: z.record(z.array(z.string())).optional()
    .describe("Which formatters to run per file extension. All run sequentially."),
  linters_by_ext: z.record(z.array(z.string())).optional()
    .describe("Which linters to run per file extension. All run sequentially."),
  disabled: z.array(z.string()).optional()
    .describe("Tool names to disable globally."),
  formatters: z.record(ToolOverrideSchema).optional()
    .describe("Per-formatter overrides. Keys are formatter names."),
  linters: z.record(ToolOverrideSchema).optional()
    .describe("Per-linter overrides. Keys are linter names."),
});

export type CodefmtConfig = z.infer<typeof CodefmtConfigSchema>;
export type ToolOverride = z.infer<typeof ToolOverrideSchema>;
```

---

## Plugin Skeleton

```typescript
import type { Plugin } from "@opencode-ai/plugin";
import path from "path";
import fs from "fs";

export const CodefmtPlugin: Plugin = async ({ client, $ }) => {
  const config = loadConfig();
  const pendingFiles = new Set<string>();

  return {
    "tool.execute.after": async ({ tool, args }) => {
      if (tool !== "edit" && tool !== "write") return;
      pendingFiles.add(args.filePath as string);
    },

    event: async ({ event }) => {
      if (event.type !== "session.idle" || pendingFiles.size === 0) return;

      const files = [...pendingFiles];
      pendingFiles.clear();

      // 1. Format all edited files
      for (const filePath of files) {
        await runTools(filePath, "formatters", config, $);
      }

      // 2. Lint all edited files, collect errors
      const errors: string[] = [];
      for (const filePath of files) {
        const fileErrors = await runTools(filePath, "linters", config, $);
        if (fileErrors) errors.push(fileErrors);
      }

      // 3. Report lint errors in one prompt
      if (errors.length > 0) {
        await client.session.prompt(
          `Lint errors to fix:\n\n${errors.join("\n\n")}`
        );
      }
    },
  };
};

export default CodefmtPlugin;
```

---

## File Structure

```
opencode-plugin-codefmt/
├── src/
│   ├── index.ts          # Plugin entry, exports default
│   ├── config.ts         # Config loading, JSONC parsing, Zod validation
│   ├── registry.ts       # Built-in formatter and linter definitions
│   ├── runner.ts         # Generic tool runner, root detection
│   └── schema.ts         # Zod schema + type exports
├── codefmt.schema.json   # Generated JSON Schema for editor autocomplete
├── package.json
├── tsconfig.json
└── README.md
```

---

## Publishing

```json
{
  "name": "opencode-plugin-codefmt",
  "version": "0.1.0",
  "main": "dist/index.js",
  "files": ["dist", "codefmt.schema.json"],
  "scripts": {
    "build": "bun build src/index.ts --outdir dist",
    "schema": "bun run scripts/generate-schema.ts"
  },
  "peerDependencies": {
    "@opencode-ai/plugin": "*"
  },
  "dependencies": {
    "zod": "^3",
    "zod-to-json-schema": "^3"
  }
}
```

Users install via their `opencode.json`:

```json
{
  "plugins": ["opencode-plugin-codefmt"]
}
```

---

## Open Questions

- **Formatter output handling** — most formatters write in place (`--write`), but some print to stdout. The runner needs to handle both cases.
- **Error vs no-op distinction** — if a formatter exits non-zero, is that a real error or just "nothing to format"? Needs per-tool handling.
- **Filename-only linters** — some linters don't support `--format json`. The runner should capture raw stderr/stdout and pass it through as-is to the agent prompt.
- **Claude Code compatibility** — the oh-my-opencode CC compat layer reads `PostToolUse` hooks from `~/.claude/settings.json`. Consider whether to support that config path as a third source.
