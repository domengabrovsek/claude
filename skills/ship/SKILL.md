---
name: ship
description: "Pre-launch validation and release workflow. Use when the user says 'ship', 'release', 'deploy', or 'ready to merge'."
---

Validate and ship: $ARGUMENTS

## Pre-Ship Checklist

Run these checks in order. Stop at the first failure.

### 1. Code Quality

**why-not-mechanizable:** skill workflow guidance; each step requires understanding the surrounding context (repo, task shape, prior state).

- [ ] Run `/verify-done` - stop on first failure (typecheck + lint + tests + build) `(review-time: see section note)`
- [ ] No debugging artifacts (`console.log`, `debugger`, `.only()`, `TODO` without issue link) `(review-time: see section note)`

### 2. Git Hygiene

- [ ] Branch is rebased onto target: `git fetch origin main && git rebase origin/main` `(review-time: see section note)`
- [ ] No uncommitted changes: `git status` is clean `(review-time: see section note)`
- [ ] Commits follow conventional format (`feat:`, `fix:`, `refactor:`, etc.) `(review-time: see section note)`
- [ ] Each commit is atomic (one logical change per commit) `(review-time: see section note)`
- [ ] No merge conflict markers in code `(review-time: see section note)`
- [ ] No sensitive files staged (`.env`, credentials, keys) `(review-time: see section note)`

### 3. Security Review (see `references/security-checklist.md`; invoke `cybersecurity-expert` agent for risky changes)

- [ ] No secrets in code or commit history `(review-time: see section note)`
- [ ] Dependencies clean: `npm audit` with zero critical/high `(review-time: see section note)`
- [ ] Input validation at system boundaries `(review-time: see section note)`
- [ ] Auth/authorization checks on new endpoints `(review-time: see section note)`
- [ ] Security headers configured if applicable `(review-time: see section note)`

### 4. Change Review

- [ ] Summarize what changed (files, lines added/removed) `(review-time: see section note)`
- [ ] Flag risky changes: auth logic, migrations, public API changes, config changes `(review-time: see section note)`
- [ ] Verify backward compatibility for API changes `(review-time: see section note)`
- [ ] If migrations exist: verify they are reversible and backward-compatible `(review-time: see section note)`

### 5. Documentation

- [ ] README updated if public API or setup steps changed `(review-time: see section note)`
- [ ] Changelog or release notes drafted if applicable `(review-time: see section note)`
- [ ] Architecture Decision Record written if a significant technical decision was made `(review-time: see section note)`

### 6. Version (if applicable)

- Determine version bump from conventional commits: `(review-time: see section note)`
  - `fix:` commits = PATCH bump `(review-time: see section note)`
  - `feat:` commits = MINOR bump `(review-time: see section note)`
  - `BREAKING CHANGE:` = MAJOR bump `(review-time: see section note)`
- Update version in package.json if needed `(review-time: see section note)`

## Ship It

If all checks pass:

1. Create PR with `gh pr create` - include summary, test plan, and any deployment notes `(review-time: see section note)`
2. Link related issues in the PR description `(review-time: see section note)`
3. Request reviewers if specified `(review-time: see section note)`
4. Report: "READY TO SHIP - all pre-launch checks passed" `(review-time: see section note)`

If any check fails:

1. List failures with specific details `(review-time: see section note)`
2. Stop - do NOT create the PR until all checks pass `(review-time: see section note)`
