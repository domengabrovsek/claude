#!/bin/bash
# Pre-commit branch gate.
# Blocks `git commit` when HEAD is on main or master.
# PreToolUse hook for Bash(git commit *) and Bash(git -C *). Exit 2 blocks the
# action and feeds the message back to Claude as a tool result.
# Bypass with SKIP_COMMIT_BRANCH_GATE=1 in the environment.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

case "$COMMAND" in
  *"git commit --help"*|*"git commit -h"*) exit 0 ;;
  *"git commit"*|*"git -C "*) ;;
  *) exit 0 ;;
esac

[ "$SKIP_COMMIT_BRANCH_GATE" = "1" ] && exit 0

# `git -C <path> commit` never contains the literal "git commit", so the repo
# must come from the -C argument. Best-effort parse: unquoted path with the
# commit subcommand directly after it. A garbled extraction fails open below,
# because rev-parse on a non-directory yields an empty branch.
C_PATH=$(printf '%s\n' "$COMMAND" | sed -n 's/.*git -C  *\([^ ]*\)  *commit.*/\1/p' | head -1)

case "$COMMAND" in
  *"git commit"*) ;;
  *) [ -z "$C_PATH" ] && exit 0 ;;
esac

# A leading `cd <path> && git commit` moves the commit's repo away from the
# recorded tool cwd, which reflects the shell's directory before the cd runs.
CD_PATH=""
case "$COMMAND" in
  "cd "*)
    CD_PATH=${COMMAND#cd }
    CD_PATH=${CD_PATH%%"&&"*}
    CD_PATH=${CD_PATH%%";"*}
    CD_PATH=$(printf '%s\n' "$CD_PATH" | sed "s/^[[:space:]]*//;s/[[:space:]]*\$//;s/^[\"']//;s/[\"']\$//")
    ;;
esac

# Resolve the repo: `git -C` target, then a leading cd prefix, then the tool
# call's cwd (worktree agents commit from feature-branch worktrees while the
# shared checkout sits on main), then CLAUDE_PROJECT_DIR.
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
DIR="${C_PATH:-${CD_PATH:-${CWD:-${CLAUDE_PROJECT_DIR:-$PWD}}}}"
BRANCH=$(git -C "$DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Not in a git repo, or detached HEAD - let it through. Caller handles their own state.
[ -z "$BRANCH" ] && exit 0
[ "$BRANCH" = "HEAD" ] && exit 0

case "$BRANCH" in
  main|master)
    echo "[pre-commit-branch-gate] Refusing to commit directly to '$BRANCH'." >&2
    echo "Create a feature branch first, e.g.:" >&2
    echo "  git checkout -b <type>/<short-description>" >&2
    echo "(Bypass: SKIP_COMMIT_BRANCH_GATE=1)" >&2
    exit 2
    ;;
esac

exit 0
