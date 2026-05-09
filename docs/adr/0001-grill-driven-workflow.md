# Grill-driven workflow replaces Plan + Annotate

## Status

Accepted - 2026-05-09

## Context

The original workflow was 5-phase: Research → Plan → Annotate → Implement → Summarize. Alignment between user and assistant happened asynchronously: the assistant wrote a plan to `.claude/state/plans/`, the user annotated it, the assistant addressed each annotation, and the loop repeated until explicit approval. The plan artifact then aged out as the work shipped.

Two problems with that shape:

1. The async write-read-annotate cycle had high latency and produced a single document that conflated three different things - domain language, architectural decisions, and task-level mechanics - all destined to rot.
2. Nothing accumulated. Each plan was a one-shot artifact. There was no growing glossary, no decision log a future session could read.

The `grill-with-docs` skill (imported from mattpocock/skills) does alignment via real-time Q&A and writes durable artifacts as decisions land: domain terms to `CONTEXT.md`, architectural decisions to ADRs.

## Decision

Replace Plan + Annotate with a single Grill phase. New workflow:

```text
[Research]  optional pre-grill orientation, manual /user:research
    ↓
Grill       /grill-with-docs - real-time Q&A
    ↓       emits CONTEXT.md updates + ADRs (durable) + execution plan (throwaway)
Implement   /build - explicit handoff after grill exits
    ↓
Summarize   /user:summarize - session diary
```

Priority order when goals conflict: **quality > consistent > efficient > fast**. The grill optimizes alignment depth and durable-doc accumulation over speed-of-output, which matches that ordering.

The grill is self-pacing: heaviness scales with alignment complexity, not with a separate "is this big enough" threshold. Trivial bypass narrows to changes the user is 100% sure are trivial (typo, version bump, config tweak). Everything else enters the grill, which exits in two turns when there's nothing to align on.

Composition is by **explicit handoff** between phases - no auto-chain. The user's "ready" at the end of the grill is the approval gate that replaces the old Plan annotation loop.

## Consequences

Changes that follow from this decision:

- `/grill-me` skill dropped - subsumed by `/grill-with-docs`, which gracefully degrades when there are no terms or ADRs to write.
- `/user:plan` command dropped - the execution plan is now emitted by the grill.
- `/spec` skill stays available for product/feature work but is not part of the default workflow. It is an optional Phase 0 when requirements are genuinely fuzzy.
- `/mr` skill hardens its pre-PR gate: auto-invokes `/user:verify-done`, hard-fails on non-conventional commit messages instead of advising, and regex-validates the PR title against `^(feat|fix|chore|docs|test|refactor|perf|style|build|ci|revert)(\(.+\))?!?: .+` before calling `gh pr create` / `glab mr create`.

Trade-offs accepted:

- Lost: async-friendliness. The grill needs the user present to answer questions in real time. The old Plan + Annotate could be split across days.
- Lost: a single re-readable plan artifact. Replaced by CONTEXT.md + ADRs (durable) and a short execution plan in `.claude/state/plans/` (throwaway, exists for the next 1-2 sessions).
- Gained: real-time alignment depth, decisions captured at the right grain, durable docs accumulate across sessions.

## Considered alternatives

- **Keep the 5-phase as-is.** Rejected: the async overhead and lack of durable docs are the problems we are trying to solve.
- **Auto-handoff Grill → Implement with no explicit confirmation.** Rejected: loses a cheap, high-value checkpoint where the user can pause or grill another branch.
- **Grill subsumes Research entirely.** Rejected: when entering an unfamiliar codebase, a written orientation artifact is high-leverage and re-readable later. The grill conversation is too dense to use as re-orientation.
