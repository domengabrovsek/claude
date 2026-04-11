#!/usr/bin/env bash
# Monitor GitLab CI status for the current branch.
# Emits a line to stdout ONLY when status changes.
# Exits when the pipeline reaches a terminal state.
set -euo pipefail

prev=""
error_count=0

while true; do
  raw=$(glab ci status 2>/dev/null) || raw="error|unknown"
  cur="${raw%%$'\n'*}"

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
    case "$cur" in
      *passed*|*failed*|*canceled*|*skipped*) exit 0 ;;
    esac
  fi

  sleep 30
done
