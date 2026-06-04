---
name: debug
description: "Structured production-incident investigation. Forces evidence-first hypothesis ranking before any code change. Use when given an error message, Sentry alert, failing log, or 'investigate <X>' request."
---

Investigate the issue: $ARGUMENTS

Hard rule: do NOT write any fix until Phase 3 is reached and the user (or the evidence in Phase 2) has confirmed the root cause.

## Phase 1 - Evidence

**why-not-mechanizable:** skill workflow guidance; each step requires understanding the surrounding context (repo, task shape, prior state).

Gather, do not theorize. Save findings to `.claude/state/research/YYYY-MM-DD-debug-<short-slug>.md`.

- Reproduce locally if feasible. Capture exact error, stack trace, request ID, timestamp. `(review-time: see section note)`
- Pull logs (Sentry, Cloud Run, container, browser console) for the affected window. `(review-time: see section note)`
- `git log -p --since='2 weeks ago' -- <suspect-paths>` to surface recent changes that touched the code path. `(review-time: see section note)`
- Confirm scope: how many users / requests / environments are affected. `(review-time: see section note)`
- Check related state: env vars set on the deployed service, DB row state, feature flags, recent deploys. `(review-time: see section note)`

If the user already supplied a hypothesis, treat it as a candidate but still gather evidence to confirm or reject.

## Phase 2 - Hypotheses

List 2-3 possible root causes ranked by evidence strength. For each:

- **Hypothesis** - one line. `(review-time: see section note)`
- **Evidence for** - log lines, commits, or code paths that support it (with file:line refs). `(review-time: see section note)`
- **Evidence against** - what would have to be true that isn't. `(review-time: see section note)`
- **Cheapest verification** - what one command, query, or read would confirm or rule it out. `(review-time: see section note)`

Pick the top candidate. If two are tied or the user has a strong prior, ask the user to choose. Do not proceed to Phase 3 on a guess.

## Phase 3 - Fix

- Minimal change first per CLAUDE.md (1-5 lines, ideally). State the change before applying it. `(review-time: see section note)`
- Add a regression test that reproduces the original failure and now passes. `(review-time: see section note)`
- Run `/verify-done` (lint + typecheck + test + build). `(review-time: see section note)`
- Commit on a feature branch with a conventional message that names the root cause. `(review-time: see section note)`
- Open a PR per `mr` skill. PR body: link to the alert/log, root cause statement with evidence, and why this fix is correct. `(review-time: see section note)`

## Anti-patterns - reject these

- Adding retry / fallback / try-catch as a "fix" before root cause is confirmed. `(review-time: see section note)`
- Introducing new abstractions, services, or workspaces as part of a debug fix. `(review-time: see section note)`
- Editing logs to make the symptom disappear. `(review-time: see section note)`
- Expanding scope ("while I'm here, let me also..."). `(review-time: see section note)`
- Pushing before all checks pass green locally. `(review-time: see section note)`
