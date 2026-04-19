#!/bin/sh
# ANSI color codes
RESET='\033[0m'
BOLD='\033[1m'
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
DIM='\033[2m'

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
folder=$(basename "$cwd")

# Git branch
branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

# Git dirty indicator: fast porcelain check, limit output to avoid slow large repos
if [ -n "$branch" ]; then
  dirty=$(git -C "$cwd" -c core.hooksPath=/dev/null status --porcelain 2>/dev/null | head -1)
  if [ -n "$dirty" ]; then
    git_color="$RED"
    git_marker="*"
  else
    git_color="$GREEN"
    git_marker=""
  fi
fi

# Node version: prefer .nvmrc (fast file read), fall back to node -v
node_version=""
if [ -f "$cwd/.nvmrc" ]; then
  node_version="v$(cat "$cwd/.nvmrc" | tr -d '[:space:]')"
elif command -v node >/dev/null 2>&1; then
  node_version=$(node -v 2>/dev/null)
fi

# Build output
printf "${BOLD}${CYAN}%s${RESET}" "$folder"

if [ -n "$branch" ]; then
  printf " ${DIM}on${RESET} ${git_color}%s%s${RESET}" "$branch" "$git_marker"
fi

if [ -n "$node_version" ]; then
  printf " ${DIM}node${RESET} ${YELLOW}%s${RESET}" "$node_version"
fi
