#!/bin/bash
# Post-edit lint hook for Write|Edit. Backs rules/comments.md.
#
# Checks (exit 2 = Claude must address; exit 0 = clean or auto-fixed):
#   1. Em-dash ban                                          - auto-fix
#   2. Ticket / PR / JIRA / ADR refs in comments            - exit 2
#   3. JSDoc blocks in JS/TS files                          - exit 2
#   4. Multi-line /* */ block openers (non-JSDoc, JS/TS/CSS) - exit 2
#   5. Consecutive // comment lines (JS/TS)                  - exit 2
#   6. Consecutive -- SQL comment lines (.sql)              - exit 2
#
# Bypass with SKIP_POST_EDIT_LINT=1 in the environment.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# No file path or file vanished - bail.
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# Escape hatch.
[ "$SKIP_POST_EDIT_LINT" = "1" ] && exit 0

# Skip noisy / generated / vendored files.
case "$FILE" in
  *package-lock.json|*yarn.lock|*pnpm-lock.yaml) exit 0 ;;
  *.min.js|*.min.css|*.map|*.bundle.js) exit 0 ;;
  */node_modules/*|*/.git/*|*/dist/*|*/build/*) exit 0 ;;
esac

# --- 1. Em-dash auto-fix (whole file, idempotent, silent) ---
# Applies to ALL file types. The em-dash ban from CLAUDE.md is universal.
if LC_ALL=C grep -q $'\xe2\x80\x94' "$FILE" 2>/dev/null; then
  # macOS sed in-place without backup.
  sed -i '' $'s/\xe2\x80\x94/-/g' "$FILE"
fi

# --- Comment / JSDoc checks only run on code files in git repos ---
# Skip docs/text: false positives from markdown headings (# Foo) and prose em-dashes are not relevant here.
case "$FILE" in
  *.md|*.markdown|*.txt|*.rst|*.adoc|*.tex) exit 0 ;;
esac

FILE_DIR=$(dirname "$FILE")
if ! git -C "$FILE_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  # Not in a git repo - skip diff-based checks.
  exit 0
fi

# Collect lines added by this edit (vs HEAD).
# If the file is untracked, treat the whole file as added.
if git -C "$FILE_DIR" ls-files --error-unmatch "$FILE" >/dev/null 2>&1; then
  ADDED=$(git -C "$FILE_DIR" diff --unified=0 HEAD -- "$FILE" 2>/dev/null | grep -E '^\+[^+]' | sed 's/^\+//')
else
  ADDED=$(cat "$FILE")
fi

[ -z "$ADDED" ] && exit 0

VIOLATIONS=""

# --- 2. Ticket / PR / JIRA / ADR refs inside comments ---
# Looks for a comment marker (// # /* *) somewhere before a tracker ref on the same line.
# Tracker refs: UPPERCASE-### (e.g. JIRA-123), #digits, owner/repo#digits, ADR-####, Fixes/Closes/Refs/Resolves <ref>.
TICKETS=$(echo "$ADDED" | grep -nE \
  '(//|#|/\*|^\s*\*).*(\b[A-Z]{2,}-[0-9]+\b|[[:space:]]#[0-9]+\b|\b[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+\b|\bADR-[0-9]+\b|\b(Fixes|Closes|Refs|Resolves)[[:space:]]+(#|[A-Z]{2,}-))' \
  2>/dev/null || true)

if [ -n "$TICKETS" ]; then
  VIOLATIONS+="Ticket / PR / JIRA / ADR reference detected in newly added comment(s). Remove the ref - those belong in PR descriptions, ADR files, and git blame, not in code:
$TICKETS

"
fi

# --- 3. New JSDoc blocks in JS/TS files ---
case "$FILE" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
    JSDOC=$(echo "$ADDED" | grep -nE '^[[:space:]]*/\*\*' 2>/dev/null || true)
    if [ -n "$JSDOC" ]; then
      VIOLATIONS+="JSDoc block added. rules/comments.md: default no comments; only one-line WHY. Remove and move rationale to docs/:
$JSDOC

"
    fi
    ;;
esac

# --- 4. Multi-line /* */ block openers (non-JSDoc) in JS/TS/CSS ---
case "$FILE" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.css|*.scss)
    CBLOCK=$(echo "$ADDED" | grep -nE '^[[:space:]]*/\*[^*]' | grep -vE '\*/' 2>/dev/null || true)
    if [ -n "$CBLOCK" ]; then
      VIOLATIONS+="Multi-line /* */ comment block opener. rules/comments.md: comments must be one line. Use a single-line // for one-line WHY; move multi-line rationale to docs/:
$CBLOCK

"
    fi
    ;;
esac

# --- 5. Consecutive // comment lines in JS/TS ---
case "$FILE" in
  *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs)
    CONSEC_SLASH=$(echo "$ADDED" | awk '
      /^[[:space:]]*\/\// { if (prev) print NR": "$0; prev=1; next }
      { prev=0 }
    ' 2>/dev/null || true)
    if [ -n "$CONSEC_SLASH" ]; then
      VIOLATIONS+="Consecutive // comment lines. rules/comments.md: comments must be one line. Move multi-line rationale to docs/:
$CONSEC_SLASH

"
    fi
    ;;
esac

# --- 6. Consecutive -- SQL comment lines ---
case "$FILE" in
  *.sql)
    CONSEC_DASH=$(echo "$ADDED" | awk '
      /^[[:space:]]*--/ { if (prev) print NR": "$0; prev=1; next }
      { prev=0 }
    ' 2>/dev/null || true)
    if [ -n "$CONSEC_DASH" ]; then
      VIOLATIONS+="Consecutive -- SQL comment lines. rules/comments.md: comments must be one line. Move multi-line rationale to docs/:
$CONSEC_DASH

"
    fi
    ;;
esac

if [ -n "$VIOLATIONS" ]; then
  echo "[post-edit-lint] $FILE" >&2
  echo "$VIOLATIONS" >&2
  exit 2
fi

exit 0
