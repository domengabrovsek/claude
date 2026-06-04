#!/bin/bash
# Pre-commit Co-Authored-By gate.
# PreToolUse hook on Bash(git commit *). Blocks the commit when the command
# string contains a Co-Authored-By trailer in any case. Per
# rules/git-conventions.md: never add Co-Authored-By or any AI attribution.
# Exit 2 blocks the action and feeds the message back to Claude.
# Bypass with SKIP_COAUTHOR_GATE=1.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

case "$COMMAND" in
  *"git commit --help"*|*"git commit -h"*) exit 0 ;;
  *"git commit"*) ;;
  *) exit 0 ;;
esac

[ "$SKIP_COAUTHOR_GATE" = "1" ] && exit 0

# Match Co-Authored-By in any case anywhere in the command (covers -m, heredocs,
# and -F file paths whose name might leak the trailer, though that's edge-case).
if echo "$COMMAND" | grep -qiE '\bco-authored-by:'; then
  echo "[pre-commit-coauthor-gate] Refusing to commit with Co-Authored-By trailer." >&2
  echo "Per rules/git-conventions.md, never add Co-Authored-By or any AI attribution to commits." >&2
  echo "Remove the trailer from the commit message and re-run." >&2
  echo "(Bypass: SKIP_COAUTHOR_GATE=1)" >&2
  exit 2
fi

exit 0
