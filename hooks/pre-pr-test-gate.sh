#!/bin/bash
# Pre-PR test gate: block PR creation if tests fail.
# Runs as a PreToolUse hook on Bash(gh pr create *).
# Exit code 2 blocks the action and sends the error message to Claude.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only gate on gh pr create
case "$COMMAND" in
  *"gh pr create"*) ;;
  *) exit 0 ;;
esac

# Find project root (look for package.json)
DIR="${CLAUDE_PROJECT_DIR:-.}"
PROJECT_ROOT=""
while [ "$DIR" != "/" ]; do
  [ -f "$DIR/package.json" ] && PROJECT_ROOT="$DIR" && break
  DIR=$(dirname "$DIR")
done

# No package.json - skip (not a JS/TS project)
[ -z "$PROJECT_ROOT" ] && exit 0

cd "$PROJECT_ROOT" || exit 0

# Check if a test script exists
HAS_TEST=$(node -e "const p = require('./package.json'); process.exit(p.scripts?.test ? 0 : 1)" 2>/dev/null && echo yes || echo no)

if [ "$HAS_TEST" != "yes" ]; then
  exit 0
fi

# Run tests
echo "Running tests before PR creation..."
TEST_OUTPUT=$(npm test 2>&1)
TEST_EXIT=$?

if [ $TEST_EXIT -ne 0 ]; then
  echo "Tests failed - fix before creating PR:"
  echo "$TEST_OUTPUT" | tail -20
  exit 2
fi

echo "All tests passed."
exit 0
