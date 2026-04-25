---
name: build
description: "Implement code incrementally with quality gates. Use when the user says 'build', 'implement', or when starting the implementation phase of an approved plan."
---

Implement the approved plan incrementally: $ARGUMENTS

Follow these disciplines:

## Before Starting

- Verify an approved plan exists (in `.claude/state/plans/` or the current conversation)
- If no plan exists, stop and ask the user to run /plan first
- Read the plan and identify the task list
- Load relevant expert agents based on the plan's domain (see `rules/agent-routing.md`) - their guardrails apply to every increment

## Increment Rules

For each task in the plan:

1. **Ask**: "What is the simplest thing that could work?"
2. **Scope**: touch only what the task requires - no drive-by refactors, no "while I'm here" changes
3. **Follow `rules/engineering-principles.md`**: vertical slicing, change sizing (~100 lines per commit, max 300, split at 1000+), and anti-rationalization rules all apply
4. **Compile continuously**: the project must build after every increment. Run typecheck after each file change.
5. **Test alongside**: write tests as part of the increment, not as a separate step afterward
6. **Checkpoint**: after completing each task:
   - Run `/user:verify-done` (typecheck + lint + tests + build) - do not rely on post-edit hooks alone
   - If all pass, commit with a conventional commit message
   - If any fail, fix before moving to the next task - never accumulate errors across tasks

## Feature Flags

If the feature is large and will take multiple sessions:

- Use a feature flag to keep incomplete work behind a toggle
- Each increment should be independently mergeable (behind the flag)
- The flag is removed only when the full feature is complete and tested

## Completion

After all tasks are done:

- Run `/user:verify-done` one final time
- Summarize what was built and what changed
- Flag any deferred items or follow-up work as issues
