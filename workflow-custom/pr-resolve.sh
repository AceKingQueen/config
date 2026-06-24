#!/usr/bin/env bash
# Shared helper for the PR-review scripts.
#
# resolve_pr <identifier>
#   Turns a PR number, branch name, or JIRA ticket into a canonical PR number.
#   On success: prints the PR number to stdout, returns 0.
#   On failure (not found / ambiguous): prints guidance to stderr, returns 1.
#
# Resolution order:
#   1. all digits            -> treat as the PR number (no network call)
#   2. branch name / PR URL  -> `gh pr view` resolves it directly
#   3. TICKET-123 pattern    -> search open+closed PRs by branch name and title
#   4. otherwise             -> error

resolve_pr() {
  local input="$1"

  if [[ -z "$input" ]]; then
    echo "resolve_pr: no identifier given" >&2
    return 1
  fi

  # 1) Already a PR number.
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$input"
    return 0
  fi

  # 2) Branch name or PR URL — gh resolves these directly to a PR.
  local num
  if num="$(gh pr view "$input" --json number -q .number 2>/dev/null)" && [[ -n "$num" ]]; then
    printf '%s\n' "$num"
    return 0
  fi

  # 3) JIRA ticket (e.g. UH-235): search PRs whose branch or title contains it.
  if [[ "$input" =~ ^[A-Za-z][A-Za-z0-9]*-[0-9]+$ ]]; then
    # Server-side --search spans full PR history (not just recent); the --jq
    # post-filter rejects GitHub's fuzzy over-matches by confirming the ticket
    # actually appears in the branch name or title.
    local q lines count
    q="$(printf '%s' "$input" | tr '[:upper:]' '[:lower:]')"
    lines="$(gh pr list --state all --search "$input" --limit 100 \
      --json number,headRefName,title,state \
      --jq ".[] | select((.headRefName|ascii_downcase|contains(\"$q\")) or (.title|ascii_downcase|contains(\"$q\"))) | \"\(.number)\t\(.state)\t\(.headRefName)\t\(.title)\"" \
      2>/dev/null || true)"

    if [[ -z "$lines" ]]; then
      echo "❌ No PR found for ticket '$input' (searched open + closed branch names and titles)." >&2
      echo "   If the PR exists, pass its number directly." >&2
      return 1
    fi

    count="$(printf '%s\n' "$lines" | grep -c .)"
    if [[ "$count" -eq 1 ]]; then
      printf '%s\n' "$lines" | cut -f1
      return 0
    fi

    echo "❌ Ticket '$input' matches $count PRs — re-run with a specific PR number:" >&2
    printf '%s\n' "$lines" | while IFS=$'\t' read -r n state branch title; do
      printf '   #%s  [%s]  %s  — %s\n' "$n" "$state" "$branch" "$title" >&2
    done
    return 1
  fi

  echo "❌ Couldn't resolve '$input' to a PR (not a number, a branch, or TICKET-123 format)." >&2
  return 1
}
