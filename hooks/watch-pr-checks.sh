#!/bin/bash
# Watch PR CI checks in the background and send a macOS notification when done.
# Usage: watch-pr-checks.sh [pr-number-or-url]
# If no argument, detects the PR for the current branch.

PR_REF="${1:-}"

# If no PR ref given, try to get it from the current branch
if [ -z "$PR_REF" ]; then
  PR_REF=$(gh pr view --json number -q '.number' 2>/dev/null)
fi

if [ -z "$PR_REF" ]; then
  exit 0
fi

PR_TITLE=$(gh pr view "$PR_REF" --json title -q '.title' 2>/dev/null || echo "PR #$PR_REF")

# Poll every 30 seconds, max 60 attempts (30 minutes)
MAX_ATTEMPTS=60
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  ATTEMPT=$((ATTEMPT + 1))
  sleep 30

  # Get check status
  CHECKS=$(gh pr checks "$PR_REF" 2>/dev/null)
  if [ $? -ne 0 ]; then
    continue
  fi

  # Count statuses
  PENDING=$(echo "$CHECKS" | grep -c "pending\|queued\|in_progress" 2>/dev/null || echo "0")
  FAILED=$(echo "$CHECKS" | grep -c "fail" 2>/dev/null || echo "0")

  # If nothing is pending, checks are done
  if [ "$PENDING" -eq 0 ]; then
    if [ "$FAILED" -gt 0 ]; then
      osascript -e "display notification \"$FAILED check(s) failed on: $PR_TITLE\" with title \"PR Checks Failed\" sound name \"Basso\""
    else
      osascript -e "display notification \"All checks passed on: $PR_TITLE\" with title \"PR Checks Passed\" sound name \"Glass\""
    fi
    exit 0
  fi
done

# Timeout
osascript -e "display notification \"Timed out waiting for checks on: $PR_TITLE\" with title \"PR Checks Timeout\""
exit 0
