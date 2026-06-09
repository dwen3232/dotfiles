#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  pr-upsert.sh apply --action <create|update> [--target PR_NUMBER|PR_URL] --title TITLE [--body BODY]

When --body is omitted for apply, the PR body is read from stdin.
EOF
}

die() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || true
}

default_branch() {
  gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
}

apply() {
  local action='' target='' title='' body=''

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --action)
        action=${2:-}
        shift 2
        ;;
      --target)
        target=${2:-}
        shift 2
        ;;
      --title)
        title=${2:-}
        shift 2
        ;;
      --body)
        body=${2:-}
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "unknown argument: $1"
        ;;
    esac
  done

  [[ "$action" == "create" || "$action" == "update" ]] || die '--action must be create or update'
  [[ -n "$title" ]] || die '--title is required'
  if [[ -z "$body" && ! -t 0 ]]; then
    body=$(</dev/stdin)
  fi
  [[ -n "$body" ]] || die '--body or stdin body is required'

  if [[ "$action" == "update" ]]; then
    if [[ -z "$target" ]]; then
      target=$(gh pr view --json number --jq '.number')
    fi
    gh pr edit "$target" --title "$title" --body "$body" >/dev/null
    printf 'Action: updated\n'
    printf 'PR URL: %s\n' "$(gh pr view "$target" --json url --jq '.url')"
    printf 'Confirmed title: %s\n' "$title"
    return 0
  fi

  local branch default url
  branch=$(current_branch)
  default=$(default_branch)
  [[ -n "$branch" && "$branch" != "HEAD" ]] || die 'not on a branch'
  [[ "$branch" != "$default" ]] || die "refusing to create a PR from the default branch: $default"

  if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    git push
  else
    git push -u origin "$branch"
  fi

  url=$(gh pr create --title "$title" --body "$body")
  printf 'Action: created\n'
  printf 'PR URL: %s\n' "$url"
  printf 'Confirmed title: %s\n' "$title"
}

main() {
  local command=${1:-}
  case "$command" in
    apply)
      shift
      apply "$@"
      ;;
    -h|--help|'')
      usage
      ;;
    *)
      die "unknown command: $command"
      ;;
  esac
}

main "$@"
