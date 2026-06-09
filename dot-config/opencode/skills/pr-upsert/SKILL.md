---
name: pr-upsert
description: >
  Load this skill when the user asks to create, open, publish, update, rewrite,
  or upsert a GitHub pull request for the current branch or for a specified PR
  number or PR URL. Gather context directly, then use the bundled pr-upsert
  script to create or update the PR after user confirmation.

  Examples of when to load this skill:
  - "create a PR for this branch"
  - "update PR #123 with a better title and body"
  - "upsert the PR and mention the auth fixes"
  - "open a pull request for the current branch"
  - "refresh the PR description from the branch diff"
---

# GitHub PR Upsert

Use normal git and `gh` inspection commands to gather context. Use the installed
script at `~/.config/opencode/skills/pr-upsert/scripts/pr-upsert.sh` only for
the confirmed create or update operation. Do not use a GitHub PR subagent for
this workflow.

## Objective

Create or update a GitHub pull request.

## Behavior

1. If the request contains a PR number or PR URL, update that PR.
2. If no PR number or URL is provided, assume the current branch.
3. If the current branch has an open PR, update it.
4. If the current branch has no open PR, create one.
5. Gather enough context directly with git and `gh` commands to draft the PR title and body.
6. Treat any remaining user guidance as direction for the title and body.
7. Use a Conventional Commit PR title, such as `feat(auth): add session refresh` or `fix: handle empty review comments`.
8. Prefer Conventional Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, and `revert`.
9. Keep the PR body under 100 words, using short high-level bullet points.
10. Ask the user to approve or edit the title and body before creating or updating the PR.
11. After approval, run `~/.config/opencode/skills/pr-upsert/scripts/pr-upsert.sh apply --action <create|update> --target <PR_NUMBER_OR_URL> --title <TITLE>` and pass the approved body on stdin. Omit `--target` for current-branch creates or current-branch updates.

## Confirmation Contract

Before running `~/.config/opencode/skills/pr-upsert/scripts/pr-upsert.sh apply`, call `question` with a confirmation
prompt.

- If creating a PR, show only the action (`create`), target branch, proposed title, and proposed body.
- If updating a PR, show only the action (`update`), target PR, current title, proposed title, current body, and proposed body.
- Provide options: `Approve`, `Revise`, and `Cancel`.
- Explain that freeform input is revision guidance, not exact replacement text.
- If the user chooses `Approve`, use the latest proposed title and body unchanged.
- If the user chooses `Cancel`, stop without making GitHub changes.
- If the user chooses `Revise` or types freeform guidance, revise the proposal according to that guidance and ask for confirmation again.
- Repeat until the user approves or cancels.
- Keep every revised proposal compliant with the PR title/body rules: Conventional Commit title, high-level bullet body, under 100 words.

Use this command shape after approval:

```bash
~/.config/opencode/skills/pr-upsert/scripts/pr-upsert.sh apply --action create --title "feat(scope): concise title" <<'EOF'
- High-level bullet
- Another high-level bullet
EOF
```

For updates, add `--target <PR_NUMBER_OR_URL>` when the user provided an
explicit PR target.

## Example Update Confirmation

- Question: `Update PR #123?\n\nCurrent title:\nchore: add opencode commands\n\nProposed title:\nfeat(opencode): add GitHub PR commands\n\nCurrent body:\n- Adds command files\n\nProposed body:\n- Add PR upsert, comments, and review commands\n- Route GitHub work through scoped subagents\n- Require approval before PR create/update`
- Options: `Approve`, `Revise`, `Cancel`
- If the user types `make the title a chore and mention subtask isolation in the body`, revise the proposal and ask again instead of using that text verbatim.

## Output

- Action: `created` or `updated`
- PR URL
- Confirmed title
- Short summary of the confirmed body
