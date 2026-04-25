---
description: "Identify and (with --apply) remove safely-disposable git worktrees in the current repo. Conservative: only removes worktrees whose branch is upstream-gone or merged into default."
---

Run `~/.claude/scripts/worktree-prune.sh` against the current repo: $ARGUMENTS

## Defaults

- Without `--apply`, this is **dry-run**: prints SAFE / KEEP verdicts and exits without changes.
- With `--apply`, removes safe worktrees and deletes their local branches.

## Flags passed through

- `--apply` - actually remove. Without it, only report.
- `--repo <path>` - target a different repo than `$PWD`.

## Safety rule

A worktree is "safe to remove" only if its branch is:

- **upstream-gone** (the remote branch was deleted, typically after PR merge), OR
- **merged into the repo's default branch** (origin/HEAD or main/master).

Locked worktrees are unlocked iff they pass the safety rule. Default-branch checkouts are never removed. Worktrees with unmerged commits or open PRs are kept.

## Tip

Run `git fetch --prune origin` in the repo first to refresh remote-tracking branches. Otherwise `[gone]` detection lags behind the remote.

## Recommendation

If the dry-run output looks right, re-run with `--apply`. The SessionEnd hook does this opportunistically too, so for actively-used repos you rarely need to run it manually.
