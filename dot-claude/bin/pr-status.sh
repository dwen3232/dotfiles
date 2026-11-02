#!/usr/bin/env bash
# Shared PR/stack status lookup for a git worktree directory.
# Used by both ~/.claude/statusline.sh and the bare-repo control panel's
# ./.claude/bin/workspace, so the two surfaces never show different badges
# for the same branch.
#
# Usage: pr-status.sh <dir>
# Prints one line, e.g. "📚 🟢 2/3  [○]✓·" (stacked) or "🔀 🟣 #1396" (single
# PR), or nothing if there's no branch, no gh, or no PR.
dir="$1"

command -v gh >/dev/null 2>&1 || exit 0
git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

branch=$(git -C "$dir" branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -z "$branch" ] && exit 0

stack_json=$(cd "$dir" && gh stack view --json 2>/dev/null)
if [ -n "$stack_json" ]; then
  pr_list_json=$(cd "$dir" && gh pr list --state all --json number,isDraft 2>/dev/null)
  [ -z "$pr_list_json" ] && pr_list_json="[]"
  stack_str=$(jq -n --argjson stack "$stack_json" --argjson prs "$pr_list_json" -r '
    def icon(b):
      if b.needsRebase then "⚠"
      elif b.isMerged then "✓"
      elif b.isQueued then "◎"
      elif b.pr != null and b.pr.state == "OPEN" then "○"
      else "·" end;
    ($prs | map({(.number|tostring): .isDraft}) | add // {}) as $draftmap
    | ($stack.branches | map(select(.pr != null))) as $withpr
    | ($withpr | map(select(.pr.state != "MERGED"))) as $active
    | (if ($withpr | length) == 0 then ""
       elif ($active | length) == 0 then "🟣 "
       elif ($active | map($draftmap[(.pr.number|tostring)] == true) | any) then "⚪ "
       else "🟢 "
       end) as $status
    | ($stack.branches | length) as $total
    | (($stack.branches | map(.isCurrent) | index(true)) + 1) as $position
    | $status + ($position|tostring) + "/" + ($total|tostring) + "  " + ([$stack.branches[] |
        (if .isCurrent then "[" + icon(.) + "]" else icon(.) end)
      ] | join(""))
  ')
  [ -n "$stack_str" ] && printf "📚 %s\n" "$stack_str"
else
  pr_json=$(cd "$dir" && gh pr view --json number,state,isDraft 2>/dev/null)
  if [ -n "$pr_json" ]; then
    pr_str=$(echo "$pr_json" | jq -r '
      (if .state == "MERGED" then "🟣"
       elif .state == "CLOSED" then "🔴"
       elif .isDraft then "⚪"
       else "🟢" end) as $badge
      | $badge + " #" + (.number|tostring)
    ')
    printf "🔀 %s\n" "$pr_str"
  fi
fi
exit 0
