# Engineering Principles

Universal principles that apply to all implementation work, regardless of domain or language.

## Change Sizing

- **Target ~100 lines per commit** - small changes are easier to review, test, and revert
- **300 lines is acceptable** for cohesive changes that cannot be split without losing context
- **1000+ lines must be split** - no exceptions. Break into sequential PRs or stacked commits
- **PRs touching 15+ files need justification** - rename/migration is fine; "I was in the area" is not

## Vertical Slicing

Implement features as thin end-to-end slices, not horizontal layers.

- **Good**: one complete feature path (UI + API + DB + test) that a user can interact with
- **Bad**: "all database models first, then all API routes, then all UI components"
- Each slice should be independently deployable and testable
- If a slice is too large, narrow the scope (fewer fields, simpler validation, fewer edge cases)

## Chesterton's Fence

Before removing or changing existing code, understand why it exists.

- Run `git blame` and read the commit message that introduced the code
- Check linked issues or PRs for context
- If no context exists and the code seems unnecessary, ask - do not silently remove
- "I don't understand why this is here" is a reason to investigate, not a reason to delete

## Shift Left

Catch problems as early as possible in the development cycle.

Priority order (earliest to latest):

1. **Type system** - catch at compile time
2. **Linting rules** - catch at save/commit time
3. **Unit tests** - catch at test time
4. **Integration tests** - catch at CI time
5. **Runtime validation** - catch at execution time
6. **Monitoring/alerting** - catch in production

Prefer solutions higher on this list. If something can be caught by the type system, don't write a test for it - fix the types.

## Context Hierarchy

When information conflicts, follow this priority order:

1. **Rules files** (rules/, CLAUDE.md) - highest authority
2. **Specifications** (.claude/state/specs/) - agreed requirements
3. **Source code** - current implementation
4. **Error output** - runtime signals
5. **Conversation history** - may be stale or misremembered

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
