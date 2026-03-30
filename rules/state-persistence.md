# State Persistence

All work artifacts must be saved to the project-level `.claude/state/` directory so they persist across sessions and machines.

## Directories

- `.claude/state/research/` - research artifacts from Phase 1
- `.claude/state/plans/` - implementation plans from Phase 2
- `.claude/state/sessions/` - session diary entries from Phase 5 (Summarize)

## Rules

- Create `.claude/state/` directories if they don't exist before writing
- Use naming convention: `YYYY-MM-DD-descriptive-name.md`
- Every non-trivial session should end with a summary saved to `.claude/state/sessions/`
- Plans and research are per-project, not global
- Check `.claude/state/` for relevant past work before starting new research
