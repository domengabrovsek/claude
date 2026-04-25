#!/bin/bash
# SessionStart hook: claim the repo lock for this session if free, or
# surface a notice if another live session already holds it. Does NOT
# block (advisory). PreToolUse guard (Phase 3) is what actually blocks.

set -u

SCRIPT="$CLAUDE_PROJECT_DIR/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || SCRIPT="$HOME/.claude/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || exit 0

# Only run inside a git repo
git -C "$PWD" rev-parse --show-toplevel >/dev/null 2>&1 || exit 0

# Pull session id from stdin JSON if present, fall back to env
INPUT=$(cat 2>/dev/null || true)
SID_FROM_STDIN=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$SID_FROM_STDIN" ]; then
  export CLAUDE_SESSION_ID="$SID_FROM_STDIN"
fi

# Try to claim. Suppress stdout. Capture stderr.
ERR=$("$SCRIPT" claim 2>&1 >/dev/null)
STATUS=$?

if [ $STATUS -eq 0 ]; then
  exit 0
fi

# Held by another live session - surface notice
OUT=$("$SCRIPT" check 2>/dev/null)
PID=$(echo "$OUT" | jq -r '.pid')
BRANCH=$(echo "$OUT" | jq -r '.branch')
CLAIMED=$(echo "$OUT" | jq -r '.claimed_at')
SID=$(echo "$OUT" | jq -r '.session_id')

cat <<EOF
NOTICE: another Claude session is active on this repo.
  pid=$PID  session=$SID  branch=$BRANCH  claimed_at=$CLAIMED
Recommend: isolate via worktree before mutating files. Use 'git worktree add ../$(basename "$PWD")-<slug> -b feat/<slug>' or run /user:locks for status.
EOF

exit 0
