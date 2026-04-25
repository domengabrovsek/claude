#!/bin/bash
# SessionStart hook (Phase 1, advisory only): if another live Claude session
# holds the repo lock, surface a notice. Does NOT block. Phase 2 will add
# claim + heartbeat; Phase 3 will add a PreToolUse guard.

set -u

SCRIPT="$CLAUDE_PROJECT_DIR/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || SCRIPT="$HOME/.claude/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || exit 0

# Only run inside a git repo
git -C "$PWD" rev-parse --show-toplevel >/dev/null 2>&1 || exit 0

OUT=$("$SCRIPT" check 2>/dev/null)
STATUS=$?

if [ $STATUS -eq 1 ]; then
  PID=$(echo "$OUT" | jq -r '.pid')
  BRANCH=$(echo "$OUT" | jq -r '.branch')
  CLAIMED=$(echo "$OUT" | jq -r '.claimed_at')
  SID=$(echo "$OUT" | jq -r '.session_id')
  cat <<EOF
NOTICE: another Claude session is active on this repo.
  pid=$PID  session=$SID  branch=$BRANCH  claimed_at=$CLAIMED
Recommend: isolate via worktree before mutating files. Use 'git worktree add ../$(basename "$PWD")-<slug> -b feat/<slug>' or run /user:locks for status.
EOF
fi

exit 0
