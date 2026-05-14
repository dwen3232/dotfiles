---
description: "Create or update PR: /pr-upsert [PR_NUMBER|PR_URL] [title/body guidance]"
agent: github-pr-writer
subtask: true
---

Create or update a GitHub pull request.

Arguments: $ARGUMENTS

Behavior:
- If the arguments contain a PR number or PR URL, update that PR.
- If no PR number or URL is provided, assume the current branch.
- If the current branch has an open PR, update it.
- If the current branch has no open PR, create one.
- Treat remaining arguments as guidance for the title and body.
- Inspect branch status, remote tracking state, commits, and diff before drafting title and body.
- When creating a PR, push the branch first if needed.
- Use a Conventional Commit PR title, such as `feat(auth): add session refresh` or `fix: handle empty review comments`.
- Prefer Conventional Commit types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, and `revert`.
- Keep the PR body under 100 words, using short high-level bullet points.
- Ask me to approve or edit the title and body before creating or updating the PR.

Question contract:
- Before running `gh pr create` or `gh pr edit`, call `question` with a confirmation prompt.
- If creating a PR, the question must show only the action (`create`), target branch, proposed title, and proposed body.
- If updating a PR, the question must show only the action (`update`), target PR, current title, proposed title, current body, and proposed body.
- Provide options: `Approve`, `Revise`, and `Cancel`.
- Explain that freeform input is revision guidance, not exact replacement text.
- If I choose `Approve`, use the latest proposed title and body unchanged.
- If I choose `Cancel`, stop without making GitHub changes.
- If I choose `Revise` or type freeform guidance, revise the proposal according to that guidance and ask for confirmation again.
- Repeat until I approve or cancel.
- Keep every revised proposal compliant with the PR title/body rules: Conventional Commit title, high-level bullet body, under 100 words.

Example update confirmation:
- Question: `Update PR #123?\n\nCurrent title:\nchore: add opencode commands\n\nProposed title:\nfeat(opencode): add GitHub PR commands\n\nCurrent body:\n- Adds command files\n\nProposed body:\n- Add PR upsert, comments, and review commands\n- Route GitHub work through scoped subagents\n- Require approval before PR create/update`
- Options: `Approve`, `Revise`, `Cancel`
- If I type `make the title a chore and mention subtask isolation in the body`, revise the proposal and ask again instead of using that text verbatim.

Output:
- Action: `created` or `updated`
- PR URL
- Confirmed title
- Short summary of the confirmed body
