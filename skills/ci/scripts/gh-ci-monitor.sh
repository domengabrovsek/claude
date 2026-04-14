#!/usr/bin/env bash
# Monitor GitHub CI status for the current branch.
# Uses `gh pr checks` to aggregate ALL checks for the PR.
# Falls back to `gh run list` (all runs, not just one) when no PR exists.
# Emits a line to stdout ONLY when status changes.
# Exits when the pipeline reaches a terminal state.
set -euo pipefail

branch=$(git branch --show-current)
pr_number=$(gh pr view --json number --jq '.number' 2>/dev/null) || pr_number=""
prev=""
error_count=0

while true; do
  if [ -n "$pr_number" ]; then
    # Primary path: aggregate all PR checks via gh pr checks
    gh pr checks "$pr_number" >/dev/null 2>&1
    ec=$?
    case $ec in
      0) cur="completed|success" ;;
      1) cur="completed|failure" ;;
      8) cur="in_progress|null" ;;
      *) cur="error|exit-$ec" ;;
    esac
  else
    # Fallback: no PR yet — check ALL runs for the branch, not just one
    lines=$(gh run list --branch "$branch" --json status,conclusion \
      --jq '.[] | "\(.status)|\(.conclusion)"' 2>/dev/null) || lines=""

    if [ -z "$lines" ]; then
      echo "no-runs|$branch"
      exit 0
    fi

    # Aggregate: any in_progress → in_progress; any failure → failure; all success → success
    has_pending=false
    has_failure=false
    all_completed=true

    while IFS='|' read -r status conclusion; do
      if [ "$status" != "completed" ]; then
        all_completed=false
        has_pending=true
      elif [ "$conclusion" != "success" ] && [ "$conclusion" != "skipped" ]; then
        has_failure=true
      fi
    done <<< "$lines"

    if [ "$all_completed" = true ] && [ "$has_failure" = true ]; then
      cur="completed|failure"
    elif [ "$all_completed" = true ]; then
      cur="completed|success"
    elif [ "$has_pending" = true ]; then
      cur="in_progress|null"
    else
      cur="error|unknown"
    fi

    # Re-check for PR in case it was created after push
    pr_number=$(gh pr view --json number --jq '.number' 2>/dev/null) || pr_number=""
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
