#!/bin/bash
# PostToolUse hook: refresh the repo lock's last_seen timestamp so it stays
# alive while this session is active. Throttled to once per CLAUDE_LOCK_HEARTBEAT
# seconds (default 60) using lock file mtime. Cheap - skips fast in the common
# case. Never blocks (always exits 0).

set -u

THROTTLE="${CLAUDE_LOCK_HEARTBEAT:-60}"

SCRIPT="$CLAUDE_PROJECT_DIR/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || SCRIPT="$HOME/.claude/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || exit 0

# Only inside git repos
REPO=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -z "$REPO" ] && exit 0

# Pull session_id from stdin (PostToolUse payload includes it)
INPUT=$(cat 2>/dev/null || true)
SID_FROM_STDIN=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$SID_FROM_STDIN" ]; then
  export CLAUDE_SESSION_ID="$SID_FROM_STDIN"
fi

# Compute lock path inline (avoids invoking the manager when throttled)
LOCK_DIR="${CLAUDE_LOCK_DIR:-$HOME/.claude/locks}"
HASH=$(printf '%s' "$REPO" | shasum | awk '{print $1}')
LOCK="$LOCK_DIR/$HASH.json"

if [ -f "$LOCK" ]; then
  # mtime check: skip if refreshed within throttle window
  MTIME=$(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK" 2>/dev/null || echo 0)
  NOW=$(date -u +%s)
  AGE=$((NOW - MTIME))
  if [ "$AGE" -lt "$THROTTLE" ]; then
    exit 0
  fi
  # Only refresh if we own the lock - never silently steal another session's lock
  OWNER=$(jq -r '.session_id // empty' "$LOCK" 2>/dev/null)
  if [ -n "$OWNER" ] && [ "$OWNER" != "${CLAUDE_SESSION_ID:-}" ]; then
    exit 0
  fi
fi

# Claim (also acts as heartbeat refresh when owned by this session)
"$SCRIPT" claim >/dev/null 2>&1 || true
exit 0
