---
name: fix-issue
description: "Investigate and fix a GitHub issue. Use when given an issue number or URL, or when the user says 'fix issue'."
---

Fix the GitHub issue: $ARGUMENTS

Follow this workflow:

1. **Fetch**: run `gh issue view $ARGUMENTS --json title,body,labels,assignees,comments` to get full issue details
2. **Research**: use subagents to explore the codebase and understand the problem area. Read linked files, related tests, and recent git history for the affected code.
3. **Reproduce**: if possible, write a failing test that reproduces the issue
4. **Plan**: propose a fix plan with:
   - Root cause analysis
   - Files to change (with specific line ranges)
   - Risks and edge cases
   - Wait for user approval before implementing
5. **Implement**: make the changes following the approved plan
6. **Test**: write or update tests verifying the fix. Run the test suite.
7. **Verify**: run typecheck (`npx tsc --noEmit`), lint, and full test suite
8. **Commit**: create a conventional commit (e.g., `fix(scope): description`) referencing the issue
9. **PR**: push the branch and create a PR linking the issue with `gh pr create`
