---
name: pr-review
description: >
  Load this skill when the user asks to review a GitHub pull request diff
  locally without posting anything to GitHub. Use it for PR review requests by
  PR number, PR URL, or the current branch's open PR.

  Examples of when to load this skill:
  - "review PR #123"
  - "review this branch's PR"
  - "check the pull request diff for bugs"
  - "look over https://github.com/org/repo/pull/123"
  - "do a read-only PR review"
---

# GitHub PR Review

Use the bundled script at `scripts/pr-review.sh` from this skill's base
directory to gather PR metadata and diff. Do not use a GitHub PR subagent for
this workflow.

## Objective

Review a GitHub pull request without posting anything to GitHub.

## Behavior

1. Run `scripts/pr-review.sh <user arguments>` to resolve the PR and fetch metadata plus patch diff.
2. If the request contains a PR number or PR URL, review that PR.
3. If no PR number or URL is provided, assume the current branch's open PR.
4. Inspect PR metadata and diff from the script output.
5. Report findings first, ordered by severity, with file and line references when available.
6. Do not submit a GitHub review, comment, approval, or request changes.

## Output

- Prioritize bugs, behavioral regressions, missing tests, and maintainability risks.
- Order findings by severity.
- Include file and line references when available.
- If there are no findings, state that explicitly and mention residual risks or missing context.
