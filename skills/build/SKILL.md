---
name: build
description: "Implement code incrementally with quality gates. Use when the user says 'build', 'implement', or when starting the implementation phase of an approved plan."
---

Implement the approved plan incrementally: $ARGUMENTS

Follow these disciplines:

## Before Starting

**why-not-mechanizable:** skill workflow guidance; each step requires understanding the surrounding context (repo, task shape, prior state).

- Verify an approved plan exists (in `.claude/state/plans/` or the current conversation) `(review-time: see section note)`
- If no plan exists, stop and ask the user to run /plan first `(review-time: see section note)`
- Read the plan and identify the task list `(review-time: see section note)`
- Load relevant expert agents based on the plan's domain (see `rules/agent-routing.md`) - their guardrails apply to every increment `(review-time: see section note)`

## Increment Rules

For each task in the plan:

1. **Ask**: "What is the simplest thing that could work?" `(review-time: see section note)`
2. **Scope**: touch only what the task requires - no drive-by refactors, no "while I'm here" changes `(review-time: see section note)`
3. **Follow `rules/engineering-principles.md`**: vertical slicing, change sizing (~100 lines per commit, max 300, split at 1000+), and anti-rationalization rules all apply `(review-time: see section note)`
4. **Compile continuously**: the project must build after every increment. Run typecheck after each file change. `(review-time: see section note)`
5. **Test alongside**: write tests as part of the increment, not as a separate step afterward `(review-time: see section note)`
6. **Checkpoint**: after completing each task: `(review-time: see section note)`
   - Run `/verify-done` (typecheck + lint + tests + build) - do not rely on post-edit hooks alone `(review-time: see section note)`
   - If all pass, commit with a conventional commit message `(review-time: see section note)`
   - If any fail, fix before moving to the next task - never accumulate errors across tasks `(review-time: see section note)`

## Feature Flags

If the feature is large and will take multiple sessions:

- Use a feature flag to keep incomplete work behind a toggle `(review-time: see section note)`
- Each increment should be independently mergeable (behind the flag) `(review-time: see section note)`
- The flag is removed only when the full feature is complete and tested `(review-time: see section note)`

## Completion

After all tasks are done:

- Run `/verify-done` one final time `(review-time: see section note)`
- Summarize what was built and what changed `(review-time: see section note)`
- Flag any deferred items or follow-up work as issues `(review-time: see section note)`
