# Engineering Principles

**When to apply:** every implementation task, regardless of domain or language.

## Change Sizing

- **Target ~100 lines per commit** - small changes are easier to review, test, and revert `(review-time: line-count thresholds vary; mechanical check would block legitimate work)`
- **300 lines is acceptable** for cohesive changes that cannot be split without losing context `(review-time: judging cohesion)`
- **1000+ lines must be split** - no exceptions. Break into sequential PRs or stacked commits `(review-time: same; could be CI warning but too rigid)`
- **PRs touching 15+ files need justification** - rename/migration is fine; "I was in the area" is not `(review-time: judging "drive-by" vs "needed")`

## Vertical Slicing

Implement features as thin end-to-end slices, not horizontal layers.

- **Good**: one complete feature path (UI + API + DB + test) that a user can interact with `(review-time: example, structural advice)`
- **Bad**: "all database models first, then all API routes, then all UI components" `(review-time: example, anti-pattern)`
- Each slice should be independently deployable and testable `(review-time: slice-shape judgment)`
- If a slice is too large, narrow the scope (fewer fields, simpler validation, fewer edge cases) `(review-time: scope judgment)`

## Chesterton's Fence

Before removing or changing existing code, understand why it exists.

- Run `git blame` and read the commit message that introduced the code `(review-time: workflow step)`
- Check linked issues or PRs for context `(review-time: workflow step)`
- If no context exists and the code seems unnecessary, ask - do not silently remove `(review-time: requires recognizing absence of context)`
- "I don't understand why this is here" is a reason to investigate, not a reason to delete `(review-time: meta-principle, not a pattern)`

## Shift Left

Catch problems as early as possible in the development cycle.

Priority order (earliest to latest):

1. **Type system** - catch at compile time
2. **Linting rules** - catch at save/commit time
3. **Unit tests** - catch at test time
4. **Integration tests** - catch at CI time
5. **Runtime validation** - catch at execution time
6. **Monitoring/alerting** - catch in production

Prefer solutions higher on this list. If something can be caught by the type system, don't write a test for it - fix the types. `(review-time: meta-principle informing the layer policy)`

## Context Hierarchy

When information conflicts, follow this priority order:

1. **Rules files** (rules/, CLAUDE.md) - highest authority `(review-time: source-of-truth ranking)`
2. **Specifications** (.claude/state/specs/) - agreed requirements `(review-time: source-of-truth ranking)`
3. **Source code** - current implementation `(review-time: source-of-truth ranking)`
4. **Error output** - runtime signals `(review-time: source-of-truth ranking)`
5. **Conversation history** - may be stale or misremembered `(review-time: source-of-truth ranking)`

## Anti-Rationalization

Never accept these shortcuts, regardless of justification:

| Shortcut | Common excuse | Why it's wrong |
| --- | --- | --- |
| Skip tests | "It's too simple to break" | Simple code becomes complex; the test catches regressions |
| Use `any` type | "I'll fix it later" | Later never comes; `any` spreads through the codebase |
| Skip error handling | "This can't fail" | Everything can fail; unhandled errors crash production |
| Hardcode values | "It's just for now" | Hardcoded values become permanent; extract to config immediately |
| Leave TODOs | "I'll come back to it" | TODOs without issue links are dead code; create a ticket or fix it now |
| Copy-paste with tweaks | "It's faster" | Duplication diverges; extract a shared function or accept the repetition consciously |
| Skip the spec/plan | "I already know what to do" | You know what you think you need to do; the spec catches what you missed |

## Exploration Guard Rails

- For open-ended tasks (seed scripts, data generation, exploratory refactors): explore briefly, then start writing code - partial progress beats perfect plans `(review-time: time-budget judgment)`
- If you've been reading files for more than 5 minutes without producing code, stop exploring and implement with what you know - we can iterate `(review-time: requires self-tracking)`
- Never spend an entire session on analysis without producing a working artifact `(review-time: session-shape judgment)`
