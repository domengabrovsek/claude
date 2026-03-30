---
name: review-pr
description: "Review a pull request with structured severity-based feedback. Use when asked to review a PR, code review, or given a PR number/URL."
---

Review the pull request: $ARGUMENTS

Follow this process:

1. **Fetch PR details**: run `gh pr view $ARGUMENTS --json title,body,files,commits,additions,deletions,baseRefName,headRefName`
2. **Read the diff**: run `gh pr diff $ARGUMENTS` to see all changes
3. **Understand intent**: read the PR description, linked issues, and commit messages before reviewing code
4. **Load relevant agents**: based on the files changed, load the appropriate expert agents from `~/.claude/agents/` for domain-specific review
5. **Review systematically** using the checklist in @checklist.md
6. **Produce structured output** in this format:

```
## Summary
<1-2 sentence overall assessment>

## Verdict: APPROVE / REQUEST_CHANGES / NEEDS_DISCUSSION
<reason>

## Findings

### BLOCKER (must fix before merge)
- **[file:line]** - Description. Why it matters. Suggested fix.

### ISSUE (should fix, may approve with commitment to follow-up)
- **[file:line]** - Description. Recommendation.

### SUGGESTION (take it or leave it)
- **[file:line]** - Description. Alternative approach.

### NIT (style/preference, non-blocking)
- **[file:line]** - Description.

### PRAISE (good patterns worth highlighting)
- **[file:line]** - What's done well and why.
```

If no `$ARGUMENTS` provided, review changes in the current branch against the base branch using `git diff main...HEAD`.
