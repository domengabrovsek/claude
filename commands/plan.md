Start Phase 2 (Plan) based on the most recent research artifact or the topic: $ARGUMENTS

Check `.claude/state/research/` for a related research artifact first.

Save the plan to `.claude/state/plans/YYYY-MM-DD-plan-<topic>.md` (use today's date) containing:

- **Goal**: what we're trying to achieve
- **Approach**: the chosen strategy and why
- **File-by-file changes**: exact file paths, line ranges, and code snippets for each change
- **Task checklist**: ordered list of implementation steps (use `- [ ]` checkboxes)
- **Risks**: what could go wrong, trade-offs, alternatives considered

Flag anything that needs user input. Do NOT implement yet - wait for explicit approval.
