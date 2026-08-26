#!/bin/bash
# Tests for hooks/prose-gate.sh.
#
# Two parts:
#   fixtures  strings that must block, and strings that must pass
#   corpus    every markdown file in the repo must pass
#
# The corpus pass is the regression guard that matters. The tier split was
# chosen because these words had zero hits in this repo; the corpus pass is
# what keeps that true, and what catches a new pattern that starts firing on
# writing we consider correct.
#
# Usage: bash hooks/prose-gate.test.sh

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATE="$ROOT/hooks/prose-gate.sh"
cd "$ROOT"

PASSED=0
FAILED=0

fail() {
  echo "  FAIL: $1" >&2
  FAILED=$((FAILED + 1))
}

ok() {
  PASSED=$((PASSED + 1))
}

# run_commit <text> -> exit status of the gate on that commit message
run_commit() {
  printf '%s' "$1" | python3 -c '
import json, sys
print(json.dumps({"tool_input": {"command": "git commit -m " + json.dumps(sys.stdin.read())}}))
' | "$GATE" commit >/dev/null 2>&1
  echo $?
}

# ---------------------------------------------------------------------------
# Must block
# ---------------------------------------------------------------------------
echo "== must block =="
MUST_BLOCK=(
  "feat: a pivotal refactor"
  "feat: this will facilitate the rollout"
  "fix: numerous edge cases"
  "docs: showcase the new flow"
  "docs: a testament to the design"
  "feat: crucial change to the loader"
  "refactor: the intricate interplay of modules"
  "feat: utilize the shared client"
  "feat: a seamless migration"
  "refactor: delve into the parser"
  "docs: the enduring landscape of vibrant tapestry"
  "feat: it serves as the entry point"
  "feat: the module boasts three exports"
  "refactor: move the substrate to a new nexus"
  "docs: the bedrock of the endgame"
  "docs: our north star for the flywheel"
  "chore: in the event that the build fails"
  "chore: skipped due to the fact that CI was red"
  "docs: it is important to run the gate first"
  "docs: it's worth noting the ordering constraint"
  "fix: done. Let me know if you need anything else"
  "fix: I hope this helps"
  "docs: Great question, here is the answer"
  "fix: this could potentially break the loader"
  "docs: a holistic paradigm with real synergy"
  "refactor: extract the salient orthogonal parts"
)

for t in "${MUST_BLOCK[@]}"; do
  st=$(run_commit "$t")
  if [ "$st" = "2" ]; then ok; else fail "expected block, got exit $st: $t"; fi
done

# ---------------------------------------------------------------------------
# Must pass - terms of art and ordinary engineering prose
# ---------------------------------------------------------------------------
echo "== must pass =="
MUST_PASS=(
  "feat(hooks): add the prose gate"
  "refactor(rules): cut the always-loaded rule surface"
  "feat: reduce the attack surface of the upload path"
  "feat: add three features behind a flag"
  "fix: the feature flag defaulted to on"
  "fix: normalise the vector before comparing"
  "test: add a harness for the retry path"
  "docs: describe the injection surface"
  "fix: guard against a null pointer in the parser"
  "perf: cut p99 from 840ms to 120ms"
  "refactor: move the loader into its own module"
  "chore: pin the node version to 22.11.0"
  "fix: the compiler validates queries at build time"
  "docs: record why the ordering constraint exists"
)

for t in "${MUST_PASS[@]}"; do
  st=$(run_commit "$t")
  if [ "$st" = "0" ]; then ok; else fail "expected pass, got exit $st: $t"; fi
done

# ---------------------------------------------------------------------------
# Advisory words warn but never block
# ---------------------------------------------------------------------------
echo "== advisory passes =="
ADVISORY=(
  "feat: a robust retry policy"
  "docs: a comprehensive guide"
  "refactor: leverage the shared client"
  "chore: bump deps in order to fix the audit"
  "refactor: replace the scaffolding with a real loader"
)

for t in "${ADVISORY[@]}"; do
  st=$(run_commit "$t")
  if [ "$st" = "0" ]; then ok; else fail "advisory must not block, got exit $st: $t"; fi
done

# ---------------------------------------------------------------------------
# Bypass and mode plumbing
# ---------------------------------------------------------------------------
echo "== plumbing =="
st=$(SKIP_PROSE_GATE=1 bash -c 'printf "%s" "$0" | python3 -c "
import json, sys
print(json.dumps({\"tool_input\": {\"command\": \"git commit -m \" + json.dumps(sys.stdin.read())}}))
" | '"$GATE"' commit >/dev/null 2>&1; echo $?' "feat: a pivotal refactor")
if [ "$st" = "0" ]; then ok; else fail "SKIP_PROSE_GATE=1 should bypass, got exit $st"; fi

echo '{"tool_input":{"command":"git commit --amend --no-edit"}}' | "$GATE" commit >/dev/null 2>&1
if [ $? = 0 ]; then ok; else fail "amend/no-edit should be skipped"; fi

echo '{"tool_input":{"command":"npm test"}}' | "$GATE" commit >/dev/null 2>&1
if [ $? = 0 ]; then ok; else fail "non-commit command should be ignored"; fi

echo '{"tool_input":{"command":"gh pr create --title x --body \"a pivotal change\""}}' | "$GATE" pr >/dev/null 2>&1
if [ $? = 2 ]; then ok; else fail "pr mode should block a pivotal body"; fi

echo '{"tool_input":{"file_path":"/nonexistent/file.md"}}' | "$GATE" file >/dev/null 2>&1
if [ $? = 0 ]; then ok; else fail "missing file should exit 0"; fi

echo '{"tool_input":{}}' | "$GATE" badmode >/dev/null 2>&1
if [ $? = 1 ]; then ok; else fail "unknown mode should exit 1"; fi

# ---------------------------------------------------------------------------
# Corpus - every markdown file in the repo must pass
# ---------------------------------------------------------------------------
echo "== corpus =="
CORPUS_FAILED=0
while IFS= read -r f; do
  out=$("$GATE" corpus "$f" 2>&1)
  if [ $? -eq 2 ]; then
    echo "  FAIL: $f" >&2
    echo "$out" | grep "line " | sed 's/^/      /' >&2
    CORPUS_FAILED=$((CORPUS_FAILED + 1))
  fi
done < <(find . -path ./.git -prune -o -name '*.md' -print | sort)

if [ "$CORPUS_FAILED" -eq 0 ]; then
  ok
else
  FAILED=$((FAILED + CORPUS_FAILED))
  echo "  $CORPUS_FAILED markdown file(s) trip the block tier." >&2
  echo "  Reword them, or move the pattern to the advisory tier in prose-gate.sh." >&2
fi

# ---------------------------------------------------------------------------
echo
echo "passed: $PASSED   failed: $FAILED"
[ "$FAILED" -eq 0 ] || exit 1
echo "OK"
