#!/bin/bash
# Claude Code status line - version controlled, symlink to ~/.claude/statusline.sh
# Setup: ln -sf ~/dev/claude/scripts/statusline.sh ~/.claude/statusline.sh

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // empty')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // empty')

# Git info (if in a repo)
BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
REPO=$(basename "$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)

# Node version (if .nvmrc or package.json exists)
NODE_V=""
if [ -f "$DIR/.nvmrc" ] || [ -f "$DIR/package.json" ]; then
  NODE_V=$(node -v 2>/dev/null)
fi

# Build status line
parts=""
[ -n "$MODEL" ] && parts="$MODEL"
[ -n "$REPO" ] && parts="$parts | $REPO"
[ -n "$BRANCH" ] && parts="$parts ($BRANCH)"
[ -n "$NODE_V" ] && parts="$parts | node $NODE_V"

echo "$parts"
