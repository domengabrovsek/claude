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
