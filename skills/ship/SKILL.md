---
name: ship
description: "Pre-launch validation and release workflow. Use when the user says 'ship', 'release', 'deploy', or 'ready to merge'."
---

Validate and ship: $ARGUMENTS

## Pre-Ship Checklist

Run these checks in order. Stop at the first failure.

### 1. Code Quality (run /verify-done)

- [ ] `npx tsc --noEmit` passes (zero type errors)
- [ ] Linting passes (zero errors, zero warnings)
- [ ] All tests pass (unit + integration + E2E)
- [ ] Build succeeds
- [ ] No debugging artifacts (`console.log`, `debugger`, `.only()`, `TODO` without issue link)

### 2. Git Hygiene

- [ ] Branch is rebased onto target: `git fetch origin main && git rebase origin/main`
- [ ] No uncommitted changes: `git status` is clean
- [ ] Commits follow conventional format (`feat:`, `fix:`, `refactor:`, etc.)
- [ ] Each commit is atomic (one logical change per commit)
- [ ] No merge conflict markers in code
- [ ] No sensitive files staged (`.env`, credentials, keys)

### 3. Security Review (see `references/security-checklist.md`)

- [ ] No secrets in code or commit history
- [ ] Dependencies clean: `npm audit` with zero critical/high
- [ ] Input validation at system boundaries
- [ ] Auth/authorization checks on new endpoints
- [ ] Security headers configured if applicable

### 4. Change Review

- [ ] Summarize what changed (files, lines added/removed)
- [ ] Flag risky changes: auth logic, migrations, public API changes, config changes
- [ ] Verify backward compatibility for API changes
- [ ] If migrations exist: verify they are reversible and backward-compatible

### 5. Documentation

- [ ] README updated if public API or setup steps changed
- [ ] Changelog or release notes drafted if applicable
- [ ] Architecture Decision Record written if a significant technical decision was made

### 6. Version (if applicable)

- Determine version bump from conventional commits:
  - `fix:` commits = PATCH bump
  - `feat:` commits = MINOR bump
  - `BREAKING CHANGE:` = MAJOR bump
- Update version in package.json if needed

## Ship It

If all checks pass:

1. Create PR with `gh pr create` - include summary, test plan, and any deployment notes
2. Link related issues in the PR description
3. Request reviewers if specified
4. Report: "READY TO SHIP - all pre-launch checks passed"

If any check fails:

1. List failures with specific details
2. Stop - do NOT create the PR until all checks pass
