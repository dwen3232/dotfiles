---
name: github
description: Use when interacting with GitHub repositories, branches, or PRs. Automatically triggered for PR viewing, code review, and repo inspection tasks.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(gh pr view:*)
  - Bash(gh pr list:*)
  - Bash(gh pr status:*)
  - Bash(gh pr checks:*)
  - Bash(gh pr diff:*)
  - Bash(gh api:*)
  - Bash(gh repo view:*)
  - Bash(gh issue view:*)
  - Bash(gh issue list:*)
  - Bash(gh run view:*)
  - Bash(gh run list:*)
  - Bash(gh workflow view:*)
  - Bash(gh workflow list:*)
  - Bash(gh browse:*)
  - Bash(gh status:*)
---

# GitHub Skill

Use the GitHub CLI (`gh`) for viewing and inspecting GitHub resources. This skill allows read-only operations by default.

## Pull Requests

### View PR Details
```bash
# View PR by number
gh pr view 123

# View with web browser
gh pr view 123 --web

# View PR in JSON format
gh pr view 123 --json title,body,author,state,number,url

# View specific PR fields
gh pr view 123 --json comments,reviews,commits
```

### List PRs
```bash
# List open PRs
gh pr list

# List PRs with filters
gh pr list --state all
gh pr list --author username
gh pr list --label bug
gh pr list --base main

# List PRs in JSON format
gh pr list --json number,title,author,state,url
```

### PR Status and Checks
```bash
# Check PR status
gh pr status

# View PR CI checks
gh pr checks 123

# View checks for a specific PR in detail
gh pr checks 123 --watch

# View PR diff
gh pr diff 123
```

### Get PR Comments and Reviews
```bash
# Get PR comments using GitHub API
gh api repos/OWNER/REPO/pulls/123/comments

# Get PR reviews
gh api repos/OWNER/REPO/pulls/123/reviews

# Get PR review comments
gh api repos/OWNER/REPO/pulls/123/comments

# Get issue comments (also includes PR comments)
gh api repos/OWNER/REPO/issues/123/comments
```

## Repository Information

```bash
# View repository details
gh repo view

# View specific repo
gh repo view OWNER/REPO

# View repo in browser
gh browse
```

## Issues

```bash
# List issues
gh issue list

# View issue details
gh issue view 123

# View issue in browser
gh issue view 123 --web
```

## Workflows and Actions

```bash
# List workflow runs
gh run list

# View workflow run details
gh run view RUN_ID

# View run logs
gh run view RUN_ID --log

# List workflows
gh workflow list

# View workflow details
gh workflow view WORKFLOW_NAME
```

## Common Patterns

### Inspecting a PR for Review
```bash
# Get full PR context
gh pr view 123 --json title,body,author,commits,comments,reviews

# View the code changes
gh pr diff 123

# Check CI status
gh pr checks 123
```

### Finding PRs to Review
```bash
# List open PRs
gh pr list --state open

# List PRs by author
gh pr list --author @me

# List PRs with specific label
gh pr list --label "needs-review"
```

## Notes

- This skill allows read-only `gh` commands by default
- Mutating operations (create, merge, close, etc.) require explicit user permission
- Use `gh api` for advanced queries not covered by `gh pr` commands
- The GitHub CLI uses the repository context from the current directory 
