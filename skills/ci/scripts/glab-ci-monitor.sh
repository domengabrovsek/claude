#!/usr/bin/env bash
# Monitor GitLab CI status for the current branch.
# Emits a line to stdout ONLY when status changes.
# Exits when the pipeline reaches a terminal state.
set -euo pipefail

prev_state=""
prev_first=""
error_count=0

while true; do
  raw=$(glab ci status 2>/dev/null) || raw=""

  if [ -z "$raw" ]; then
    error_count=$((error_count + 1))
    if [ "$error_count" -ge 5 ]; then
      echo "error|persistent-failure"
      exit 1
    fi
    sleep 30
    continue
  fi
  error_count=0

  # Source of truth: the trailing "Pipeline state: <state>" line.
  # `glab ci status` lists jobs above it; the first job line can be a
  # `manual`/`skipped` outlier that does not reflect overall progress.
  # Take the LAST match via awk's END block (no SIGPIPE risk under
  # pipefail) and strip the label prefix so we tolerate extra fields.
  state_line=$(awk '/^Pipeline state:/ { line = $0 } END { print line }' <<<"$raw")
  state="${state_line##*: }"
  first="${raw%%$'\n'*}"

  if [ "$first" != "$prev_first" ]; then
    echo "$first"
    prev_first="$first"
  fi

  if [ "$state" != "$prev_state" ] && [ -n "$state" ]; then
    case "$state" in
      success|failed|canceled|skipped|manual)
        # Terminal from the monitor's POV: nothing more will happen
        # automatically. `manual` means all automatic jobs completed and
        # the pipeline is paused on a manual gate awaiting human action,
        # so treat it as semi-done and stop watching.
        # Emit a structured marker so the consumer can branch on outcome
        # without re-parsing glab's free-form job lines. Mirrors the
        # `completed|<conclusion>` contract of gh-ci-monitor.sh.
        echo "completed|$state"
        exit 0
        ;;
    esac
    prev_state="$state"
  fi

  sleep 30
done
