# 2026-06-04 - Rule enforcement architecture

## What this session was

Started as a pentla-api BYPASSRLS bug fix, turned into a broader audit of how rules in the claude repo are enforced and ended with a five-layer enforcement architecture shipped across five PRs.

## What changed in the claude repo

| PR | Title | Notes |
|---|---|---|
| [#74](https://github.com/domengabrovsek/claude/pull/74) | feat(rules,hook): relax comment policy and enforce var/TODO bans | Walked back the over-strict "no multi-line comments at all" rule from #72/#73. New rule: multi-line WHY is allowed, must use `/* */` (or SQL `/* */`), never consecutive `//` or `--`. Added hook checks for `var` declarations and TODO/FIXME/XXX/HACK markers. Fixed a regex bug in the existing `/*`-opener check that missed bare `/*` on its own line. |
| [#75](https://github.com/domengabrovsek/claude/pull/75) | feat(rules): rule-enforcement architecture - meta-policy + marker pass (alpha1) | New `rules/rule-authoring.md` codifying the five-layer taxonomy. Marker pass on every normative bullet in `rules/*.md`, `CLAUDE.md`, and `RTK.md`. |
| [#76](https://github.com/domengabrovsek/claude/pull/76) | feat(agents): tag persona guardrails per rule-authoring policy (alpha2) | Marker pass on 16 persona files in `agents/`. All persona bullets land as `(review-time)` because they're domain expertise. |
| [#77](https://github.com/domengabrovsek/claude/pull/77) | feat(skills): tag normative bullets per rule-authoring policy (alpha3) | Marker pass on 17 skill files in `skills/`. Three workflow steps in `fix-issue` land as `(hook)`; everything else `(review-time)`. |
| [#78](https://github.com/domengabrovsek/claude/pull/78) | feat(hooks): add Co-Authored-By, conventional-commit, SELECT *, :latest gates (beta) | Closed the loop by adding hook checks for every `(hook)`-tagged rule that didn't have one. Two new commit-msg gates (Co-Authored-By, conventional-commit format), two new post-edit checks (`SELECT *`, `:latest` Docker tag). |

## The five-layer taxonomy (lives in rules/rule-authoring.md)

| Tag | Where enforced | Cost when violated |
|---|---|---|
| `(hook)` | `~/.claude/hooks/*.sh` via `~/.claude/settings.json` | ~1s, fed back to Claude as a tool result |
| `(lint)` | Repo biome/eslint/markdownlint configs | `npm run check` run |
| `(CI)` | GitHub Actions, pentla-shared reusables | PR cycle |
| `(persona)` | A persona file's guardrail section | Subagent compliance, not global |
| `(review-time: <why>)` | Human or Claude attention | Open-ended |

Every normative bullet in `rules/*.md`, `CLAUDE.md`, `agents/*.md`, `skills/**/SKILL.md`, `RTK.md` ends with one of these tags. `(review-time)` requires an inline justification answering "why can't a hook catch this?".

## Active hook checks after this session

`hooks/post-edit-lint.sh` (9 checks):

1. Em-dash auto-fix
2. Tracker refs in comments
3. Consecutive `//` in JS/TS
4. Consecutive `--` in SQL
5. Tracker refs in Terraform `description = "..."`
6. `var` declarations in JS/TS
7. TODO/FIXME/XXX/HACK in any code file
8. `SELECT *` in SQL
9. `:latest` Docker tag in Dockerfile / compose / k8s yamls

`hooks/pre-commit-branch-gate.sh` (existed before): block commits on main/master.

`hooks/pre-commit-coauthor-gate.sh` (new): block commits with Co-Authored-By trailer.

`hooks/pre-commit-conventional-gate.sh` (new): block commits whose subject doesn't match conventional-commits regex.

`hooks/pre-push-gate.sh` (existed before): block push if lint/typecheck/test/build fails.

All bypassable via `SKIP_<NAME>=1` env vars; comment-policy hooks bypass via `SKIP_POST_EDIT_LINT=1`.

## Why this matters

The session demonstrated repeatedly that rules in CLAUDE.md and rules/ get forgotten or misread, even when they're loaded into every session. The new layering is honest about what depends on attention vs what's mechanically guaranteed. Every `(review-time)` bullet is a known reliability gap; the justification format means the reviewer can audit the set and promote rules to `(hook)` when they become mechanizable.

## Plan that drove the work

`.claude/state/plans/2026-06-04-rule-enforcement-architecture.md` (grilled out via `/grill-with-docs`).

## In-flight elsewhere

This session also opened pentla-api PR #1397 (BYPASSRLS / bootstrap consolidation, not merged), pentla-api PR #1398 (local-dev seed, blocked on #1397), and pentla-infra PR #229 (db-bootstrap-sa provisioning). The claude work was a tangent that became its own major thread.
