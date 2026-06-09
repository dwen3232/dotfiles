---
name: pr-comments
description: >
  Load this skill when the user asks to fetch, list, summarize, or show feedback
  comments for a GitHub pull request. Use it for PR review comments, issue
  comments, and review-level comments by PR number, PR URL, or the current
  branch's open PR.

  Examples of when to load this skill:
  - "show comments on PR #123"
  - "list outstanding PR feedback"
  - "summarize the review comments for this PR"
  - "make a table of pull request comments"
  - "what feedback is on the current branch's PR?"
---

# GitHub PR Comments

Use the bundled script at `scripts/pr-comments.sh` from this skill's base
directory. Do not use a GitHub PR subagent for this workflow.

## Objective

Fetch GitHub pull request comments and display them as a table.

## Behavior

1. Run `scripts/pr-comments.sh <user arguments>` to resolve the PR and fetch comments.
2. If the request contains a PR number or PR URL, inspect that PR.
3. If no PR number or URL is provided, assume the current branch's open PR.
4. Include review comments, issue comments, and review-level comments when available.
5. Return the script's Markdown table suitable for reviewing outstanding feedback.

## Output

- Use columns: `Type`, `Author`, `File`, `Line`, `State`, `Summary`, `URL`.
- Use `Type` values like `review comment`, `issue comment`, or `review`.
- Keep summaries short and actionable.
- If there are no comments, say that explicitly.
