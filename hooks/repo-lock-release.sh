#!/bin/bash
# SessionEnd / Stop hook: release the repo lock if owned by this session.
# Idempotent and never blocks.

set -u

SCRIPT="$CLAUDE_PROJECT_DIR/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || SCRIPT="$HOME/.claude/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || exit 0

# Only inside git repos
git -C "$PWD" rev-parse --show-toplevel >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
SID_FROM_STDIN=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$SID_FROM_STDIN" ]; then
  export CLAUDE_SESSION_ID="$SID_FROM_STDIN"
fi

"$SCRIPT" release >/dev/null 2>&1 || true
exit 0
