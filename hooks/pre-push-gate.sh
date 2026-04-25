#!/bin/bash
# Pre-push gate: block `git push` if lint/typecheck/test/build fail.
# Runs as a PreToolUse hook on Bash(git push *).
# Exit code 2 blocks the action and sends the error message to Claude.
# Bypass with SKIP_PUSH_GATE=1 in the environment.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only gate on `git push` (and not `git push --help`, etc.)
case "$COMMAND" in
  *"git push --help"*|*"git push -h"*) exit 0 ;;
  *"git push"*) ;;
  *) exit 0 ;;
esac

# Honor escape hatch
if [ "$SKIP_PUSH_GATE" = "1" ]; then
  echo "SKIP_PUSH_GATE=1 - bypassing pre-push gate." >&2
  exit 0
fi

# Find project root: walk up looking for package.json or *.tf
DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
PROJECT_ROOT=""
PROJECT_TYPE=""
while [ "$DIR" != "/" ] && [ -n "$DIR" ]; do
  if [ -f "$DIR/package.json" ]; then
    PROJECT_ROOT="$DIR"
    PROJECT_TYPE="node"
    break
  fi
  if ls "$DIR"/*.tf >/dev/null 2>&1; then
    PROJECT_ROOT="$DIR"
    PROJECT_TYPE="terraform"
    break
  fi
  DIR=$(dirname "$DIR")
done

# No matching project - skip silently (Claude config repo, dotfiles, docs-only)
[ -z "$PROJECT_ROOT" ] && exit 0

cd "$PROJECT_ROOT" || exit 0

run_step() {
  local label="$1"
  local cmd="$2"
  echo "[pre-push-gate] $label..." >&2
  if command -v rtk >/dev/null 2>&1; then
    OUT=$(rtk proxy bash -c "$cmd" 2>&1)
  else
    OUT=$(bash -c "$cmd" 2>&1)
  fi
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "[pre-push-gate] $label FAILED. Fix before pushing (or set SKIP_PUSH_GATE=1 to bypass):" >&2
    echo "$OUT" | tail -40 >&2
    exit 2
  fi
}

if [ "$PROJECT_TYPE" = "node" ]; then
  has_script() {
    node -e "const p=require('./package.json'); process.exit(p.scripts?.['$1'] ? 0 : 1)" 2>/dev/null
  }
  has_script lint && run_step "lint" "CI=true npm run lint --silent"
  has_script typecheck && run_step "typecheck" "CI=true npm run typecheck --silent"
  has_script test && run_step "test" "CI=true npm test --silent"
  has_script build && run_step "build" "CI=true npm run build --silent"
fi

if [ "$PROJECT_TYPE" = "terraform" ]; then
  command -v terraform >/dev/null 2>&1 || exit 0
  run_step "terraform fmt" "terraform fmt -check -recursive"
  run_step "terraform validate" "terraform validate"
fi

echo "[pre-push-gate] All checks passed." >&2
exit 0
