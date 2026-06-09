#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  pr-comments.sh [PR_NUMBER|PR_URL]

Prints review comments, issue comments, and review-level comments as a Markdown table.
EOF
}

parse_url() {
  local arg=$1
  if [[ "$arg" =~ ^https://github\.com/([^/[:space:]]+)/([^/[:space:]]+)/pull/([0-9]+) ]]; then
    printf '%s/%s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
    return 0
  fi
  return 1
}

extract_number() {
  local arg
  for arg in "$@"; do
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

repo=''
number=''

for arg in "$@"; do
  if parsed=$(parse_url "$arg"); then
    repo=${parsed% *}
    number=${parsed##* }
    break
  fi
done

if [[ -z "$number" ]]; then
  number=$(extract_number "$@" || true)
fi

if [[ -z "$repo" ]]; then
  repo=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
fi

if [[ -z "$number" ]]; then
  number=$(gh pr view --json number --jq '.number')
fi

pr_url=$(gh pr view "$number" --repo "$repo" --json url --jq '.url')
pr_title=$(gh pr view "$number" --repo "$repo" --json title --jq '.title')

jq_clean='def clean: tostring | gsub("\\r|\\n|\\t"; " ") | gsub("\\|"; "\\\\|") | .[0:120];'

review_comment_rows=$(gh api --paginate "repos/$repo/pulls/$number/comments" --jq "$jq_clean .[] | \"| review comment | \((.user.login // \"\") | clean) | \((.path // \"\") | clean) | \(((.line // .original_line // \"\") | tostring) | clean) | \((if .position == null then \"outdated\" else \"active\" end) | clean) | \((.body // \"\") | clean) | \((.html_url // \"\") | clean) |\"" || true)
issue_comment_rows=$(gh api --paginate "repos/$repo/issues/$number/comments" --jq "$jq_clean .[] | \"| issue comment | \((.user.login // \"\") | clean) |  |  | open | \((.body // \"\") | clean) | \((.html_url // \"\") | clean) |\"" || true)
review_rows=$(gh api --paginate "repos/$repo/pulls/$number/reviews" --jq "$jq_clean .[] | (.body // \"\") as \$body | \"| review | \((.user.login // \"\") | clean) |  |  | \((.state // \"\") | clean) | \((if \$body == \"\" then (\"Review state: \" + (.state // \"\")) else \$body end) | clean) | \((.html_url // \"\") | clean) |\"" || true)

all_rows=$review_comment_rows
if [[ -n "$issue_comment_rows" ]]; then
  all_rows=${all_rows:+$all_rows$'\n'}$issue_comment_rows
fi
if [[ -n "$review_rows" ]]; then
  all_rows=${all_rows:+$all_rows$'\n'}$review_rows
fi

printf 'PR: [%s](%s)\n\n' "$pr_title" "$pr_url"

if [[ -z "$all_rows" ]]; then
  printf 'No comments found.\n'
  exit 0
fi

printf '| Type | Author | File | Line | State | Summary | URL |\n'
printf '| --- | --- | --- | --- | --- | --- | --- |\n'
printf '%s\n' "$all_rows"
