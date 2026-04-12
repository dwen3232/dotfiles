---
name: iterate
description: Load this skill when the user says "iterate on", "iterate until", "do X and iterate", or otherwise asks for a plan → implement → evaluate loop with automated retries. Runs planner, implementer, and evaluator subagents. Supports parallel execution across multiple independent tasks.
---

# Iterate

Runs structured plan → implement → evaluate pipelines via the `iterate-orchestrator` subagent.

## Instructions

### Single task

If given one task, generate a short slug for it (e.g. `auth-fix`, `payments`, `a`) and invoke one `iterate-orchestrator` agent:

> Task: {task description}
> Pipeline ID: {slug}

Wait for the result and report it to the user.

### Multiple tasks (parallel)

If given multiple independent tasks, generate a unique slug for each and invoke all `iterate-orchestrator` agents simultaneously in a single turn — do not wait for one to finish before starting the next.

Example for three tasks:
- Invoke `iterate-orchestrator` with task A and ID `a`
- Invoke `iterate-orchestrator` with task B and ID `b`
- Invoke `iterate-orchestrator` with task C and ID `c`

Wait for all to complete, then report a summary of each.

### Slug rules

- Lowercase, hyphen-separated, max 16 chars
- Derived from the task (e.g. "fix auth token expiry" → `auth-token`)
- Must be unique across concurrent pipelines

### Reporting

After all pipelines finish, show the user:

```
## Iterate results

### {slug} — PASS | FAIL
{summary or blocking issues}
```

## Notes

- If no task is provided, use the `question` tool to ask what to build before starting.
- If the planner flags a task as high-risk, the iterate-orchestrator will surface it — relay that to the user and ask for confirmation before re-invoking.
- Artifact files (PLAN-*.md, CHANGES-*.md, EVAL-*.md) are written to the project root. Clean them up after a successful run if the user doesn't need them.
