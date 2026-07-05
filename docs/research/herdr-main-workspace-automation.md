# Herdr Main Workspace Automation

Date: 2026-07-04

## Goal

Use one Herdr workspace as the control plane for agent work. The main workspace contains a Pi session that can spin up task-specific Herdr workspaces with the right Git worktree, panes, agents, servers, test runners, and layout already prepared.

Target workflow:

1. Start from the main/control workspace.
2. Ask Pi to create a task workspace.
3. Pi creates or opens a Git worktree through Herdr.
4. Pi applies a known pane layout.
5. Pi starts the right commands and agent sessions.
6. Pi can monitor agent status, read pane output, and route follow-up work.

This makes Herdr the runtime shell/workspace layer and Pi the orchestration agent.

## Suitability

Herdr is well suited for this pattern. Its API exposes the right primitives:

- Workspace lifecycle: create, list, focus, rename, close.
- Worktree lifecycle: create, open, list, remove.
- Tab lifecycle: create, list, focus, rename, close.
- Pane control: split, move, swap, resize, zoom, rename, read, close, send input.
- Agent control: start, send, read, focus, wait, inspect status.
- Coordination: wait for output, wait for agent status, subscribe to lifecycle events through the raw socket API.
- Layout primitives: export current tab layout and apply a declarative layout tree.

The best first implementation layer is the Herdr CLI. It prints JSON for most control commands, which makes it easy for Pi or scripts to parse IDs and continue.

Use the raw socket API later if an orchestration process needs long-lived event subscriptions or lower-level request/response control.

Reference: <https://herdr.dev/docs/socket-api/>

## Control workspace pattern

Keep one long-lived workspace named something like `main`, `control`, or `ops`. It should contain:

- A primary Pi session.
- Optional notes or dashboard pane.
- Optional log/monitor pane.
- Scripts or commands for creating task workspaces.

The primary Pi session should be the only place that creates new task workspaces by default. That keeps orchestration decisions centralized and avoids multiple agents racing to mutate the same Herdr session.

Example control command shape:

```bash
herdr-spawn-task \
  --repo /Users/davidwen/Repositories/configs \
  --branch work/herdr-layouts \
  --base main \
  --label herdr-layouts \
  --layout pi-task \
  --prompt "Implement saved layout helpers for Herdr workspaces"
```

The script should:

1. Find or create the worktree workspace.
2. Apply the requested layout preset.
3. Start the required panes.
4. Send the initial prompt to the agent pane.
5. Print the workspace, tab, and important pane IDs.

## Worktree-backed task workspaces

Herdr has first-class worktree helpers:

```bash
herdr worktree create \
  --workspace "$MAIN_WORKSPACE_ID" \
  --branch "work/task-name" \
  --base main \
  --label "task-name" \
  --no-focus \
  --json
```

Useful behavior:

- Creates a Git worktree and opens it as a Herdr workspace.
- Returns the new workspace, tab, root pane, and worktree metadata.
- If the branch already exists locally, it checks out that branch.
- `worktree.open` can reopen an existing checkout and returns the already-open workspace when applicable.
- `worktree.remove` removes the linked checkout but does not delete the branch.

This maps cleanly to per-task agent workspaces: one worktree per implementation attempt, review pass, experiment, or issue.

## Pane and agent setup

After the worktree workspace exists, use the returned root pane as the anchor for splits.

Example imperative setup:

```bash
ROOT_PANE="w2:p1"
WT_PATH="/Users/davidwen/Repositories/configs-worktrees/herdr-layouts"

TESTS_PANE=$(herdr pane split "$ROOT_PANE" \
  --direction right \
  --ratio 0.4 \
  --cwd "$WT_PATH" \
  --no-focus \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')

herdr pane rename "$TESTS_PANE" tests
herdr pane run "$TESTS_PANE" "npm test -- --watch"

AGENT_PANE=$(herdr pane split "$ROOT_PANE" \
  --direction down \
  --ratio 0.5 \
  --cwd "$WT_PATH" \
  --no-focus \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')

herdr pane rename "$AGENT_PANE" pi
herdr pane run "$AGENT_PANE" "pi"
```

Prefer `herdr agent start` for direct agent launches when possible:

```bash
herdr agent start pi \
  --cwd "$WT_PATH" \
  --workspace "$WORKSPACE_ID" \
  --split right \
  --no-focus \
  -- pi
```

Then coordinate with waits:

```bash
herdr wait output "$TESTS_PANE" --match "ready" --timeout 30000
herdr wait agent-status "$AGENT_PANE" --status done --timeout 120000
herdr pane read "$AGENT_PANE" --source recent --lines 100
```

## Layout presets

Herdr does not currently expose a high-level `herdr layout save` / `herdr layout load` CLI command, but the socket API supports layout save/apply behavior through:

- `layout.export`
- `layout.apply`

`layout.export` returns a portable layout tree for a tab. The tree includes panes, labels, cwd, optional commands, split directions, and split ratios.

`layout.apply` creates a fresh tab from a declarative tree. It restores structure, labels, cwd, env, and optional commands. It does not preserve live PTYs, scrollback, or running processes.

Practical approach: keep named layout preset files under a user-controlled directory, for example:

```text
~/.config/herdr/layouts/pi-task.json
~/.config/herdr/layouts/web-dev.json
~/.config/herdr/layouts/review.json
```

Example layout preset:

```json
{
  "tab_label": "dev",
  "root": {
    "type": "split",
    "direction": "right",
    "ratio": 0.65,
    "first": {
      "type": "pane",
      "label": "agent",
      "cwd": "${WORKTREE_PATH}",
      "command": ["pi"]
    },
    "second": {
      "type": "split",
      "direction": "down",
      "ratio": 0.5,
      "first": {
        "type": "pane",
        "label": "tests",
        "cwd": "${WORKTREE_PATH}",
        "command": ["sh", "-c", "npm test -- --watch"]
      },
      "second": {
        "type": "pane",
        "label": "server",
        "cwd": "${WORKTREE_PATH}",
        "command": ["sh", "-c", "npm run dev"]
      }
    }
  }
}
```

The spawn script can substitute `${WORKTREE_PATH}` before calling `layout.apply`.

## Recommended scripts

### `herdr-spawn-task`

Creates a task workspace from a branch and layout preset.

Responsibilities:

- Validate repo path and base ref.
- Create or open a Herdr worktree workspace.
- Resolve a layout preset.
- Substitute workspace variables into the preset.
- Apply the layout.
- Start the agent prompt if provided.
- Print structured JSON with created IDs.

Inputs:

```text
--repo PATH
--branch NAME
--base REF
--label TEXT
--layout NAME
--prompt TEXT
--focus / --no-focus
```

Output:

```json
{
  "workspace_id": "w2",
  "tab_id": "w2:t1",
  "worktree_path": "/path/to/worktree",
  "agent_pane_id": "w2:p1",
  "test_pane_id": "w2:p2"
}
```

### `herdr-layout-apply`

Applies a named layout preset to an existing workspace or tab.

Responsibilities:

- Load `~/.config/herdr/layouts/<name>.json`.
- Substitute variables such as `${WORKTREE_PATH}` and `${REPO_PATH}`.
- Call `layout.apply` through the socket API.
- Return new tab and pane IDs.

### `herdr-task-status`

Summarizes task workspaces from the control workspace.

Responsibilities:

- List workspaces and panes.
- Show labels, branches/worktrees, and agent status.
- Read recent output for blocked/done agents.
- Optionally focus or close completed workspaces.

## Plugin option

Herdr plugins can package reusable workflow actions and event hooks. A future plugin could expose actions like:

- `Create task workspace`
- `Apply layout preset`
- `Bootstrap new worktree`
- `Open task dashboard`

Event hooks can run when Herdr emits events such as `worktree.created`. This could automatically install dependencies or apply metadata when a new worktree workspace appears.

Treat plugins as a second phase. Start with scripts around the CLI/socket API because they are easier to inspect, debug, and evolve.

## Caveats

- Herdr public IDs are live-session IDs. Re-read IDs from Herdr instead of treating them as durable.
- `layout.apply` creates a fresh tab; it does not snapshot running processes.
- Text-driving interactive agents through `pane run` can be brittle. Prefer `agent.start` or wrapper commands where possible.
- `worktree.remove` removes the worktree checkout but does not delete the branch.
- Multiple orchestration agents can race. Keep one main/control Pi responsible for workspace creation unless there is a lock file or queue.
- Raw socket clients need to handle unknown fields gracefully and check server protocol/version when relying on newer methods.

## Minimal implementation plan

1. Create `~/.config/herdr/layouts/pi-task.json` with a standard agent/tests/server layout.
2. Write `herdr-spawn-task` as a shell, Python, or TypeScript script.
3. Use Herdr CLI wrappers for workspace/worktree/pane operations.
4. Use raw socket calls only for `layout.apply` until a layout CLI exists.
5. Add `herdr-task-status` once there are several active task workspaces.
6. Consider a Herdr plugin after the script workflow stabilizes.
