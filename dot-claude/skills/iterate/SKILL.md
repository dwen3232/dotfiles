---
name: iterate
description: Orchestrate planner → implementer → evaluator pipeline to take a task from prompt to reviewed, working code.
argument-hint: <task description>
allowed-tools: Agent(planner), Agent(implementer), Agent(evaluator), Read(**), AskUserQuestion
---

# Iterate

Runs the full plan → implement → evaluate loop for `$ARGUMENTS`.

## Instructions

You are the orchestrator. Run the following pipeline using the Agent tool. Each agent is a subagent — pass context via files, not conversation.

### Step 1: Plan

Invoke the `planner` agent with this prompt:

> Plan the following task for this codebase: `$ARGUMENTS`
> Produce a PLAN.md with goal, approach, and a pass/fail success criteria checklist.

Wait for it to complete and confirm PLAN.md was written before continuing.

### Step 2: Implement

Invoke the `implementer` agent with this prompt:

> Implement the task described in PLAN.md. Follow the plan exactly. Append an "## Implementation Notes" section to PLAN.md when done.

Wait for it to complete before continuing.

### Step 3: Evaluate

Invoke the `evaluator` agent with this prompt:

> Evaluate the implementation against the success criteria in PLAN.md. To verify correctness, infer the test command from the project (look for package.json scripts, Makefile, justfile, pytest, etc.) and run it. Produce a structured evaluation report with a PASS / FAIL / PARTIAL verdict.

### Step 4: Loop or finish

- If the verdict is **PASS**: inform the user the task is complete. Show a brief summary of what was built.
- If the verdict is **FAIL** or **PARTIAL**: invoke the `implementer` agent again with this prompt:

  > The evaluator found the following issues: <paste blocking issues from evaluation report>. Fix them. The success criteria are in PLAN.md.

  Then re-run the `evaluator`. Repeat up to **3 total implementation attempts**. If still failing after 3 attempts, stop and report the remaining issues to the user — do not loop indefinitely.

## Notes

- Do not summarize or narrate each step excessively. Let the agents do the work.
- If `$ARGUMENTS` is empty, use AskUserQuestion to ask what to build before starting.
- If the planner flags the task as high-risk or significantly more complex than it appears, pause and show the plan to the user for confirmation before invoking the implementer.
