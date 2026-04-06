#!/bin/bash
# Post-edit hook: run typecheck and lint for .ts/.tsx files
# Uses npm scripts if available, falls back to npx tsc / npm run lint

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only process .ts and .tsx files
case "$FILE" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Walk up to find the nearest package.json
DIR=$(dirname "$FILE")
while [[ "$DIR" != "/" && "$DIR" != "." ]]; do
  if [[ -f "$DIR/package.json" ]]; then
    cd "$DIR"

    # Typecheck: prefer npm script, fall back to npx tsc
    HAS_TYPECHECK=$(node -e "const p = require('./package.json'); process.exit(p.scripts?.typecheck ? 0 : 1)" 2>/dev/null && echo yes || echo no)
    if [[ "$HAS_TYPECHECK" == "yes" ]]; then
      npm run typecheck 2>&1
    else
      npx tsc --noEmit 2>&1
    fi
    TC_EXIT=$?

    # Lint: prefer lint:fix, fall back to lint
    HAS_LINT_FIX=$(node -e "const p = require('./package.json'); process.exit(p.scripts?.['lint:fix'] ? 0 : 1)" 2>/dev/null && echo yes || echo no)
    HAS_LINT=$(node -e "const p = require('./package.json'); process.exit(p.scripts?.lint ? 0 : 1)" 2>/dev/null && echo yes || echo no)
    if [[ "$HAS_LINT_FIX" == "yes" ]]; then
      npm run lint:fix 2>&1
    elif [[ "$HAS_LINT" == "yes" ]]; then
      npm run lint 2>&1
    fi
    LF_EXIT=$?

    if [[ $TC_EXIT -ne 0 ]]; then
      exit $TC_EXIT
    fi
    exit $LF_EXIT
  fi
  DIR=$(dirname "$DIR")
done
