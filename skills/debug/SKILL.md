---
name: debug
description: "Structured production-incident investigation. Forces evidence-first hypothesis ranking before any code change. Use when given an error message, Sentry alert, failing log, or 'investigate <X>' request."
---

Investigate the issue: $ARGUMENTS

Hard rule: do NOT write any fix until Phase 3 is reached and the user (or the evidence in Phase 2) has confirmed the root cause.

## Phase 1 - Evidence

Gather, do not theorize. Save findings to `.claude/state/research/YYYY-MM-DD-debug-<short-slug>.md`.

- Reproduce locally if feasible. Capture exact error, stack trace, request ID, timestamp.
- Pull logs (Sentry, Cloud Run, container, browser console) for the affected window.
- `git log -p --since='2 weeks ago' -- <suspect-paths>` to surface recent changes that touched the code path.
- Confirm scope: how many users / requests / environments are affected.
- Check related state: env vars set on the deployed service, DB row state, feature flags, recent deploys.

If the user already supplied a hypothesis, treat it as a candidate but still gather evidence to confirm or reject.

## Phase 2 - Hypotheses

List 2-3 possible root causes ranked by evidence strength. For each:

- **Hypothesis** - one line.
- **Evidence for** - log lines, commits, or code paths that support it (with file:line refs).
- **Evidence against** - what would have to be true that isn't.
- **Cheapest verification** - what one command, query, or read would confirm or rule it out.

Pick the top candidate. If two are tied or the user has a strong prior, ask the user to choose. Do not proceed to Phase 3 on a guess.

## Phase 3 - Fix

- Minimal change first per CLAUDE.md (1-5 lines, ideally). State the change before applying it.
- Add a regression test that reproduces the original failure and now passes.
- Run `/user:verify-done` (lint + typecheck + test + build).
- Commit on a feature branch with a conventional message that names the root cause.
- Open a PR per `mr` skill. PR body: link to the alert/log, root cause statement with evidence, and why this fix is correct.

## Anti-patterns - reject these

- Adding retry / fallback / try-catch as a "fix" before root cause is confirmed.
- Introducing new abstractions, services, or workspaces as part of a debug fix.
- Editing logs to make the symptom disappear.
- Expanding scope ("while I'm here, let me also...").
- Pushing before all checks pass green locally.
