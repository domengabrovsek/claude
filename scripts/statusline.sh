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
  node_version="v$(cat "$cwd/.nvmrc" | tr -d '[:space:]' | sed 's/^v//')"
elif command -v node >/dev/null 2>&1; then
  node_version=$(node -v 2>/dev/null)
fi

# Context: only present after first API call (current_usage non-null)
has_usage=$(echo "$input" | jq -r '.context_window.current_usage // empty')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Compact a raw token number to e.g. "45.2k" or "999"
compact_tokens() {
  echo "$1" | awk '{
    if ($1 >= 1000) {
      val = $1 / 1000
      # One decimal place, strip trailing .0
      s = sprintf("%.1fk", val)
      sub(/\.0k$/, "k", s)
      print s
    } else {
      printf "%d", $1
    }
  }'
}

# Build output
printf "${BOLD}${CYAN}%s${RESET}" "$folder"

if [ -n "$branch" ]; then
  printf " ${DIM}on${RESET} ${git_color}%s%s${RESET}" "$branch" "$git_marker"
fi

if [ -n "$node_version" ]; then
  printf " ${DIM}node${RESET} ${YELLOW}%s${RESET}" "$node_version"
fi

# Context block: render from the start, defaulting to 0 before the first API call
if [ -n "$has_usage" ] && [ -n "$ctx_pct" ]; then
  pct_int=$(echo "$ctx_pct" | awk '{printf "%d", $1}')
  used_tokens=$(echo "$input" | jq -r '
    (.context_window.current_usage.input_tokens // 0)
    + (.context_window.current_usage.cache_read_input_tokens // 0)
    + (.context_window.current_usage.cache_creation_input_tokens // 0)
  ')
else
  pct_int=0
  used_tokens=0
fi

if [ "$pct_int" -ge 80 ]; then
  pct_color="$RED"
elif [ "$pct_int" -ge 50 ]; then
  pct_color="$YELLOW"
else
  pct_color="$GREEN"
fi

used_label=$(compact_tokens "$used_tokens")

printf " ${DIM}context${RESET} ${pct_color}%s (%d%%)${RESET}" \
  "$used_label" "$pct_int"
