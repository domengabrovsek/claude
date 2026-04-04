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

## Increment Rules

For each task in the plan:

1. **Ask**: "What is the simplest thing that could work?"
2. **Scope**: touch only what the task requires - no drive-by refactors, no "while I'm here" changes
3. **Slice vertically**: implement one user-visible slice at a time (UI + API + DB + test), not horizontal layers
4. **Size check**: each increment should change ~100 lines. If approaching 300, stop and split. Never exceed 1000 lines in a single commit.
5. **Compile continuously**: the project must build after every increment. Run typecheck after each file change.
6. **Test alongside**: write tests as part of the increment, not as a separate step afterward
7. **Checkpoint**: after completing each task:
   - Run /verify-done (typecheck + lint + tests + build)
   - If all pass, commit with a conventional commit message
   - If any fail, fix before moving to the next task

## Anti-Rationalization

Refuse these shortcuts regardless of justification:

- "I'll add tests later" - write them now, as part of this increment
- "This is too simple to test" - if it has logic, it gets a test
- "I'll clean this up in a follow-up" - clean it now or create an issue
- "Let me just use `any` for now" - use proper types from the start
- "I'll skip error handling for the happy path first" - handle errors as you go
- "Let me do all the scaffolding first" - vertical slices, not horizontal layers

## Feature Flags

If the feature is large and will take multiple sessions:

- Use a feature flag to keep incomplete work behind a toggle
- Each increment should be independently mergeable (behind the flag)
- The flag is removed only when the full feature is complete and tested

## Completion

After all tasks are done:

- Run /verify-done one final time
- Summarize what was built and what changed
- Flag any deferred items or follow-up work as issues
