---
description: "Review PR diff locally: /pr-review [PR_NUMBER|PR_URL]"
agent: github-pr-reader
subtask: true
---

Review a GitHub pull request without posting anything to GitHub.

Arguments: $ARGUMENTS

Behavior:
- If the arguments contain a PR number or PR URL, review that PR.
- If no PR number or URL is provided, assume the current branch's open PR.
- Inspect PR metadata and diff.
- Report findings first, ordered by severity, with file and line references when available.
- Do not submit a GitHub review, comment, approval, or request changes.

Output:
- Prioritize bugs, behavioral regressions, missing tests, and maintainability risks.
- Order findings by severity.
- Include file and line references when available.
- If there are no findings, state that explicitly and mention residual risks or missing context.
