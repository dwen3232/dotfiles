#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  pr-review.sh [PR_NUMBER|PR_URL]

Fetches PR metadata and patch diff for a local, read-only review.
EOF
}

extract_target() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" =~ ^https://github\.com/[^[:space:]]+/[^[:space:]]+/pull/[0-9]+ ]]; then
      printf '%s\n' "$arg"
      return 0
    fi
    if [[ "$arg" =~ ^[0-9]+$ ]]; then
      printf '%s\n' "$arg"
      return 0
    fi
  done
}

if [[ "${1:-}" == '-h' || "${1:-}" == '--help' ]]; then
  usage
  exit 0
fi

target=$(extract_target "$@" || true)
view_args=()
if [[ -n "$target" ]]; then
  view_args=("$target")
fi

printf '# PR Review Context\n\n'
printf 'Repository: %s\n' "$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
printf 'Current branch: %s\n' "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [[ -n "$target" ]]; then
  printf 'Target: %s\n' "$target"
fi

printf '\n## PR Metadata\n\n'
gh pr view "${view_args[@]}" --json number,title,url,state,isDraft,author,baseRefName,headRefName,mergeable,reviewDecision,body

printf '\n## Local Branch Status\n\n'
git status --short --branch || true

printf '\n## PR Diff\n\n'
gh pr diff "${view_args[@]}" --patch
