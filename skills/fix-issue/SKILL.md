---
name: fix-issue
description: "Investigate and fix a GitHub issue. Use when given an issue number or URL, or when the user says 'fix issue'."
---

Fix the GitHub issue: $ARGUMENTS

Follow this workflow:

1. **Fetch**: run `gh issue view $ARGUMENTS --json title,body,labels,assignees,comments` to get full issue details
2. **Load agents**: based on the issue domain, load the relevant expert agents from `~/.claude/agents/` (see `rules/agent-routing.md`). Their guardrails apply throughout the fix.
3. **Research**: use subagents to explore the codebase and understand the problem area. Read linked files, related tests, and recent git history. Save findings to `.claude/state/research/YYYY-MM-DD-issue-<number>.md`.
4. **Reproduce**: if possible, write a failing test that reproduces the issue
5. **Scope check**: before planning the fix, state the minimal change that would resolve the issue (ideally 1-5 lines). If a larger change is needed, explain why the minimal fix is insufficient. The plan must build from this minimal baseline.
6. **Plan**: propose a fix plan and save to `.claude/state/plans/YYYY-MM-DD-fix-issue-<number>.md` with:
   - Root cause analysis
   - Files to change (with specific line ranges)
   - Risks and edge cases
   - Wait for user approval before implementing
7. **Implement**: make the changes following the approved plan
8. **Test**: write or update tests verifying the fix. Run the test suite.
9. **Verify**: run typecheck (`npx tsc --noEmit`), lint, and full test suite
10. **Commit**: create a conventional commit (e.g., `fix(scope): description`) referencing the issue
11. **PR**: push the branch and create a PR linking the issue with `gh pr create`
