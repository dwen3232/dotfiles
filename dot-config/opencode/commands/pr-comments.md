---
description: "Show PR feedback table: /pr-comments [PR_NUMBER|PR_URL]"
agent: github-pr-reader
subtask: true
---

Fetch GitHub pull request comments and display them as a table.

Arguments: $ARGUMENTS

Behavior:
- If the arguments contain a PR number or PR URL, inspect that PR.
- If no PR number or URL is provided, assume the current branch's open PR.
- Include review comments, issue comments, and review-level comments when available.
- Return a Markdown table suitable for reviewing outstanding feedback.

Output:
- Use columns: `Type`, `Author`, `File`, `Line`, `State`, `Summary`, `URL`.
- Use `Type` values like `review comment`, `issue comment`, or `review`.
- Keep summaries short and actionable.
- If there are no comments, say that explicitly.
