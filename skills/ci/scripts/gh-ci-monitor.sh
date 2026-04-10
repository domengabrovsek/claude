#!/usr/bin/env bash
# Monitor GitHub CI status for the current branch.
# Emits a line to stdout ONLY when status changes.
# Exits when the pipeline reaches a terminal state.
set -euo pipefail

branch=$(git branch --show-current)
prev=""
error_count=0

while true; do
  cur=$(gh run list --branch "$branch" --limit 1 --json status,conclusion \
    --jq '.[0] | "\(.status)|\(.conclusion)"' 2>/dev/null) || cur="error|unknown"

  # No CI runs found — jq produces "null|null"
  if [ "$cur" = "null|null" ]; then
    echo "no-runs|$branch"
    exit 0
  fi

  # Track consecutive errors
  if [[ "$cur" == error* ]]; then
    error_count=$((error_count + 1))
    if [ "$error_count" -ge 5 ]; then
      echo "error|persistent-failure"
      exit 1
    fi
  else
    error_count=0
  fi

  if [ "$cur" != "$prev" ]; then
    echo "$cur"
    prev="$cur"
    # Exit on any completed status regardless of conclusion
    if [[ "$cur" == completed\|* ]]; then
      exit 0
    fi
  fi

  sleep 30
done
