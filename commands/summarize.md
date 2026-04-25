Summarize the current session's work and save it to `.claude/state/sessions/YYYY-MM-DD-<topic>.md` (use today's date and a brief topic slug).

Format the file as:

```markdown
# Session: <date> - <topic>

## What was done

- List of completed changes with file paths

## Files changed

- List of all modified/created/deleted files

## What remains

- Any incomplete work or follow-up tasks

## Open questions

- Unresolved decisions or blockers

## Key decisions

- Important choices made during this session and why
```

Also output the summary to the conversation. Keep it concise - suitable for a standup update or handoff to another session.

## Worktree auto-cleanup

After saving the diary, scan worktrees owned by this repo and remove ones that are safely disposable:

1. `git worktree list --porcelain` to list every worktree.
2. For each non-main worktree, check its branch:
   - If the branch's upstream is `gone` (remote branch deleted, e.g. PR merged) - safe to remove.
   - If `git rev-list --count <branch>@{upstream}..<branch>` is 0 (no unpushed commits) - safe to remove.
   - Otherwise (unpushed work, no upstream, or uncommitted changes) - skip and tell the user the worktree was preserved with a one-line reason.
3. For each safe worktree: `git worktree remove <path>` and `git branch -d <branch>`. Release the lock with `~/.claude/scripts/repo-lock.sh release <path>` if needed.

Never force-remove. Never delete a branch with unpushed commits. If in doubt, preserve and report.
