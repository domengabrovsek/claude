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

After saving the diary, run `~/.claude/scripts/worktree-prune.sh --apply` against the current repo. The script applies the conservative rule (upstream-gone OR merged into default) and reports what was removed vs kept. Locked worktrees are auto-unlocked iff safely removable. Anything with unpushed work or open PR is preserved.

The same hook fires automatically at SessionEnd, so this step is mostly for explicit closure and surface visibility.
