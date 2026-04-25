#!/bin/bash
# PreToolUse guard: refuse mutating actions when another live Claude session
# holds the repo lock and the current session is NOT working in a worktree.
# Exit code 2 blocks the action and surfaces the message to Claude.
# Bypass with SKIP_LOCK=1 in the environment.

set -u

SCRIPT="$CLAUDE_PROJECT_DIR/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || SCRIPT="$HOME/.claude/scripts/repo-lock.sh"
[ -x "$SCRIPT" ] || exit 0

# Escape hatch
if [ "${SKIP_LOCK:-0}" = "1" ]; then
  exit 0
fi

# Pull stdin payload once
INPUT=$(cat 2>/dev/null || true)

# Extract session_id from stdin (PreToolUse payload includes it)
SID_FROM_STDIN=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$SID_FROM_STDIN" ]; then
  export CLAUDE_SESSION_ID="$SID_FROM_STDIN"
fi

# For Bash tools, only gate the dangerous-mutation subset. Reads, lints,
# tests, etc. don't need the guard.
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ "$TOOL_NAME" = "Bash" ]; then
  case "$COMMAND" in
    *"git commit"*|*"git push"*|*"git checkout"*|*"git switch"*|\
    *"git rebase"*|*"git merge"*|*"git reset"*|*"git cherry-pick"*|\
    *"git stash"*|*"git restore"*|*"git apply"*|*"git am"*|\
    *"git tag"*|*"git branch -D"*|*"git branch -d"*|*"gh pr merge"*) ;;
    *) exit 0 ;;
  esac
fi

# Only run inside a git repo
REPO=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -z "$REPO" ] && exit 0

# Are we currently in a worktree (not the main checkout)? If so, allow.
GIT_DIR=$(git -C "$REPO" rev-parse --git-dir 2>/dev/null)
GIT_COMMON_DIR=$(git -C "$REPO" rev-parse --git-common-dir 2>/dev/null)
if [ -n "$GIT_DIR" ] && [ -n "$GIT_COMMON_DIR" ] && [ "$GIT_DIR" != "$GIT_COMMON_DIR" ]; then
  exit 0
fi

# Check lock state
OUT=$("$SCRIPT" check 2>/dev/null)
STATUS=$?

# Free or stale - allow (Phase 2 SessionStart should have claimed already)
[ $STATUS -eq 0 ] && exit 0

# Held - allow only if owned by this session
OWNER=$(echo "$OUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ "$OWNER" = "${CLAUDE_SESSION_ID:-}" ]; then
  exit 0
fi

# Held by another live session - block
PID=$(echo "$OUT" | jq -r '.pid')
BRANCH=$(echo "$OUT" | jq -r '.branch')
CLAIMED=$(echo "$OUT" | jq -r '.claimed_at')
LAST_SEEN=$(echo "$OUT" | jq -r '.last_seen')

cat >&2 <<EOF
[repo-lock-guard] BLOCKED: another live Claude session holds this repo.
  pid=$PID  session=$OWNER  branch=$BRANCH
  claimed_at=$CLAIMED  last_seen=$LAST_SEEN

To proceed, isolate yourself in a worktree:
  git worktree add ../$(basename "$REPO")-<slug> -b feat/<slug>
  cd ../$(basename "$REPO")-<slug>

Or one-shot bypass:
  SKIP_LOCK=1 <command>

Or, if the other session is genuinely dead:
  /user:locks --prune
EOF

exit 2
