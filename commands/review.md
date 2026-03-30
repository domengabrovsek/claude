Review the current branch's changes against the base branch. Use `git diff main...HEAD` to see all changes.

Load the pr-reviewer agent methodology from `~/.claude/agents/pr-reviewer.md`. Output findings in the structured format: BLOCKER > ISSUE > SUGGESTION > NIT > PRAISE. Include a verdict (APPROVE / REQUEST_CHANGES / NEEDS_DISCUSSION).

If `$ARGUMENTS` is provided, review that specific PR using `gh pr diff $ARGUMENTS` instead.
