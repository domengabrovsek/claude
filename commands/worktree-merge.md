---
description: "Clean up a worktree after its branch has been merged. Removes the worktree dir, deletes the local branch, releases the lock."
---

Clean up the current worktree: $ARGUMENTS

## Preconditions

- Current `$PWD` must be inside a worktree (not the main checkout). Verify with `git rev-parse --git-dir != --git-common-dir`.
- The worktree's branch must be safely removable: either merged into the default branch upstream, or its upstream is `gone` (PR was merged and remote branch deleted), or the user explicitly passes `--force`.

If the branch is not safe to remove, stop and explain what's still pending (unpushed commits, open PR, etc.). Never auto-delete unmerged work.

## Steps

1. Capture worktree path and branch name:

   ```bash
   WORKTREE=$(git rev-parse --show-toplevel)
   BRANCH=$(git rev-parse --abbrev-ref HEAD)
   ```

2. Move out of the worktree to the main checkout (`cd "$(git rev-parse --git-common-dir)/.."`).
3. Release the lock for the worktree path: `~/.claude/scripts/repo-lock.sh release "$WORKTREE"` (the SessionEnd hook will also do this; explicit release here is for the immediate cleanup).
4. Remove the worktree: `git worktree remove "$WORKTREE"`. If it has uncommitted changes and `--force` was passed, use `git worktree remove --force "$WORKTREE"`.
5. Delete the local branch: `git branch -d "$BRANCH"` (or `-D` with `--force`).
6. Report what was cleaned up.

## After cleanup

The next session can claim the lock on the main checkout cleanly. If the user has more work, suggest `/user:worktree <new-slug>` for the next task rather than mutating the main checkout.
