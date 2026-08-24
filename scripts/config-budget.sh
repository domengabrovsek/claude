#!/bin/bash
# Budget gate for the always-loaded rule surface: CLAUDE.md plus every file it
# @-imports. The config reached ~8,300 words one reasonable bullet at a time;
# this fails the build when it starts growing back. Raising a budget is a
# deliberate edit to this file, reviewed in the same PR as the rule that needs it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

MAX_WORDS=3800
MAX_REVIEW_TIME=100

# bash 3.2 on macOS has no mapfile, so build the list the portable way.
FILES=(CLAUDE.md)
while IFS= read -r line; do
  [ -n "$line" ] && FILES+=("$line")
done < <(grep -oE '^@rules/[A-Za-z0-9._-]+\.md' CLAUDE.md | sed 's/^@//')

missing=0
for f in "${FILES[@]}"; do
  [ -f "$f" ] || { echo "MISSING import target: $f" >&2; missing=1; }
done
[ "$missing" -eq 1 ] && exit 1

total=0
printf '%-38s %6s\n' "file" "words"
for f in "${FILES[@]}"; do
  w=$(wc -w < "$f" | tr -d ' ')
  total=$((total + w))
  printf '%-38s %6s\n' "$f" "$w"
done
printf '%-38s %6s  (~%s tokens)\n' "TOTAL" "$total" "$((total * 4 / 3))"

review=$(grep -hoE '\(review-time' "${FILES[@]}" | wc -l | tr -d ' ')
hook=$(grep -hoE '\(hook\)' "${FILES[@]}" | wc -l | tr -d ' ')
echo
echo "review-time bullets: $review (budget $MAX_REVIEW_TIME)"
echo "hook-backed bullets: $hook"

fail=0
if [ "$total" -gt "$MAX_WORDS" ]; then
  echo "FAIL: always-loaded surface is $total words, budget is $MAX_WORDS." >&2
  echo "Cut a rule, move one behind a paths: trigger or a skill, or raise the budget here on purpose." >&2
  fail=1
fi
if [ "$review" -gt "$MAX_REVIEW_TIME" ]; then
  echo "FAIL: $review review-time bullets, budget is $MAX_REVIEW_TIME." >&2
  echo "Attention-dependent rules are the ones that get missed. Hook it, scope it, or drop it." >&2
  fail=1
fi

[ "$fail" -eq 0 ] && echo "OK: within budget."
exit "$fail"
