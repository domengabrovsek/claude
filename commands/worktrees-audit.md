---
description: "Cross-repo worktree audit. Scans ~/dev/ (or --root <path>) for git repos and reports their worktrees with SAFE / KEEP verdicts. With --apply, removes the safe ones across every repo found."
---

Run a cross-repo worktree audit: $ARGUMENTS

## Behavior

`~/.claude/scripts/worktree-prune.sh audit-all [--root <path>] [--apply]`

- Walks `--root <path>` (default `~/dev/`) up to 4 levels deep, finds every git repo (skipping nested worktree dirs that share their parent's git common dir).
- For each repo: same dry-run (or apply) report as `/user:worktrees-prune`.

## Use cases

- After a long stretch where multiple repos accumulated stale worktrees.
- Periodic hygiene pass (run weekly with `--apply` if the dry-run output looks correct).
- Diagnosing "where did all my worktrees go" - the audit shows you everything in one pass.

## Tip

Run `git fetch --prune origin` in each repo first if you want upstream-gone detection to be current. The script does NOT fetch automatically (network cost across many repos). The `merged-into-default` check works offline.

## Safety

Conservative rule: only worktrees whose branch is **upstream-gone** OR **merged into default** are marked SAFE. Locked ones are unlocked iff safe. Anything with unpushed work or an open PR is preserved.
