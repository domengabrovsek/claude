# Parallel Work with Agent Worktrees

**When to apply:** when a task has 2+ independent sub-tasks that touch different files / modules and can run concurrently.

When a task can be split into independent pieces, parallelize by spawning multiple named teammates. This dramatically reduces wall-clock time for multi-part work. How those teammates coordinate depends on the mode.

## Two modes of parallel work

Parallel work runs in one of two coordination modes (see `CONTEXT.md` for the glossary). Pick by whether the work mutates files.

- **Lane mode** - mutating work (build / implementation). Teammates run in isolated git worktrees, each owning disjoint files, in the background, reporting to the parent via completion notifications, with no peer messaging (star topology). Choose lane mode when teammates write code. `(review-time: mode-selection judgment)`
- **Panel mode** - read-only work (research, grilling, design). Named teammates coordinate peer-to-peer via SendMessage to challenge each other, then converge (mesh topology). No worktrees needed because the work is read-only. Choose panel mode when teammates investigate or argue but do not write. `(review-time: mode-selection judgment)`

The distinguishing axis is coordination topology (star vs mesh) plus isolation (worktree vs read-only), not whether teammates are named - both modes name their teammates. Background execution (`run_in_background`) is orthogonal; either mode can run in the background. `(review-time: mode classification, not a code pattern)`

The rest of this file - splitting, worktree isolation, merging - governs **lane mode**. Panel mode has its own section below.

## When to Parallelize

**why-not-mechanizable:** every condition below requires understanding the task shape ("independent", "meaningful effort", "would take significantly longer"). The harness can't see what the task is until I describe it.

Spawn parallel agents when ALL of these are true:

- The task has 2+ independent sub-tasks that touch different files or modules `(review-time: see section note)`
- Each sub-task takes meaningful effort (not a one-liner fix) `(review-time: see section note)`
- The sub-tasks do not need to read each other's output to proceed `(review-time: see section note)`
- The overall task would take significantly longer done sequentially `(review-time: see section note)`

Good candidates:

- Implementing features across multiple modules (e.g., API endpoint + frontend page + tests) `(review-time: example, not a strict rule)`
- Writing tests for several unrelated modules `(review-time: example)`
- Fixing multiple independent bugs in one batch `(review-time: example)`
- Refactoring several files that do not depend on each other `(review-time: example)`
- Adding similar functionality to different parts of the codebase (e.g., validation to 5 different endpoints) `(review-time: example)`
- Research tasks that explore different parts of the codebase `(review-time: example)`

## When NOT to Parallelize

Do NOT spawn parallel agents when:

- The task is a single focused change (one file, one module) `(review-time: task-shape judgment)`
- Sub-tasks are tightly coupled - one must see the other's output before it can start `(review-time: task-shape judgment)`
- The work is strictly sequential (step 2 depends on step 1's result) `(review-time: task-shape judgment)`
- The task is trivial enough to finish in under 2 minutes sequentially `(review-time: time-estimate)`
- Changes will inevitably conflict (e.g., multiple agents editing the same file) `(review-time: conflict prediction)`
- There are only cosmetic or config changes `(review-time: task-shape judgment)`

## How to Split Work

- **File-level isolation**: Each agent should own a distinct set of files. NEVER assign two agents to edit the same file. `(review-time: requires knowing the file plan)`
- **Module boundaries**: Split along natural module/package/directory boundaries `(review-time: module-boundary recognition)`
- **Vertical slices**: Prefer giving an agent a complete vertical slice (e.g., "add the /users endpoint including route, controller, service, and tests") over horizontal slices (e.g., "write all controllers") `(review-time: slice-shape choice)`
- **Self-contained units**: Each agent's task must be completable and testable in isolation `(review-time: completability judgment)`
- **Shared dependencies**: If sub-tasks share a dependency that needs to be created first, either create it before spawning agents or assign it to one agent and make the others wait `(review-time: dependency-graph reasoning)`

## Worktree Isolation

Worktree isolation applies to **lane mode** (file-mutating work). Panel mode is read-only and needs no worktrees. Every lane-mode teammate MUST use worktree isolation:

- Set `isolation: "worktree"` on every Agent tool call for lane-mode parallel work `(review-time: tool-call parameter choice; not currently hook-gated on Agent calls)`
- Each teammate gets its own full copy of the repo via git worktree `(review-time: descriptive of the mechanism)`
- Each teammate works on its own branch - no risk of stepping on other teammates' changes `(review-time: descriptive of the mechanism)`
- NEVER run file-mutating parallel teammates without worktree isolation - concurrent edits to the same working directory will cause corruption `(review-time: tool-call parameter choice; not currently hook-gated)`

## Background Execution

- Spawn teammates with `run_in_background: true` so they execute concurrently `(review-time: tool-call parameter)`
- Launch all independent teammates in a single message with multiple Agent tool calls `(review-time: message-shape choice)`
- In **lane mode**, after spawning, wait for automatic completion notifications - do NOT poll or check repeatedly `(review-time: behavioral discipline)`
- In **panel mode**, this rule is inverted: actively coordinate via SendMessage during the cross-challenge round rather than waiting silently for notifications `(review-time: behavioral discipline, mode-dependent)`
- Continue with other non-conflicting work while teammates run, if possible `(review-time: requires identifying non-conflicting work)`

## Merging Results

After all agents complete:

1. Review each agent's changes for correctness `(review-time: code review)`
2. Merge branches one at a time into the main working branch `(review-time: workflow step)`
3. After each merge, check for conflicts and resolve immediately `(review-time: workflow step)`
4. Run the full test suite, typecheck, and lint after all merges are complete `(review-time: workflow step; pre-push-gate.sh enforces at push)`
5. If a merge conflict arises, resolve it manually - do NOT re-spawn an agent for conflict resolution `(review-time: subagent-use choice)`
6. After all branches are merged into the integration branch, prune the agent worktrees: `~/.claude/scripts/worktree-prune.sh --apply`. The conservative rule will only remove worktrees whose branch is upstream-gone or merged into the default - exactly the post-merge state. Locked worktrees will auto-unlock if safe. Anything still active is preserved. `(review-time: cleanup step)`

## Agent Prompt Quality

Each agent's prompt MUST be self-contained. The agent cannot see the parent conversation. Include:

- **Goal**: Exactly what the agent must accomplish - be specific and unambiguous `(review-time: prompt-quality)`
- **Context**: Relevant background (why this change is needed, what the broader task is) `(review-time: prompt-quality)`
- **File paths**: Exact files to read and modify - do not make the agent search blindly `(review-time: prompt-quality)`
- **Constraints**: Patterns to follow, styles to match, things to avoid `(review-time: prompt-quality)`
- **Verification**: How the agent should verify its work (run tests, typecheck, lint) `(review-time: prompt-quality)`

Bad prompt: "Add validation to the API"

Good prompt: "Add Zod input validation to the POST /api/users endpoint in src/routes/users.ts. Follow the existing validation pattern in src/routes/projects.ts. Create the schema in src/schemas/users.ts. Add tests in src/routes/\_\_tests\_\_/users.test.ts. Run `npm test -- users` to verify. Work on branch parallel/users-validation."

## Panel mode

Panel mode is for read-only parallel work where teammates need to challenge each other: research, grilling a plan, and design exploration. It follows a structured protocol with a stop condition - free-form mesh chatter is forbidden because it has no bound and burns tokens.

- **Independent pass**: each teammate explores its area or forms its position alone `(review-time: protocol step)`
- **Cross-challenge round**: each teammate sees the others' outputs and sends targeted SendMessage challenges or contradictions - bounded to one pass for research, iterate-to-convergence for grilling and design `(review-time: protocol step, intensity is a judgment call)`
- **Parent converges**: the main session synthesizes the result (research: the artifact; grill: the next question to the user) - there is no lead teammate, because the parent holds the user relationship and the artifact `(review-time: protocol step)`

Read-only enforcement differs by surface, deliberately:

- **Research panels** spawn as the `Explore` agent type, whose toolset excludes Edit / Write / NotebookEdit - the read-only guarantee is mechanical `(review-time: agent-type selection)`
- **Grill and design panels** use the domain-expert agent types from `rules/agent-routing.md` for their personas, with an explicit read-only brief - the guarantee is soft (brief-level), backstopped by the parent's review before any later build `(review-time: agent-type selection plus prompt discipline)`
- NEVER let a panel teammate mutate files - if a task needs writes, it is lane mode, not panel mode `(review-time: mode-selection judgment)`

See ADR 0005 for the rationale and CONTEXT.md for the glossary.

## Limits

- **Target: 4 parallel agents.** Most real tasks decompose cleanly into 2-4 truly independent units; beyond that you're usually inventing artificial seams. `(review-time: parallelism target)`
- **Hard ceiling: 5 parallel agents.** Only go this high when the task genuinely has 5 clean independent slices. `(review-time: parallelism ceiling)`
- If a task splits into more than 5 pieces, batch them into rounds rather than spawning more concurrently. `(review-time: batching strategy)`
- Always prefer 3 well-scoped agents over 6 narrowly-scoped ones. `(review-time: scope-vs-count trade-off)`

Why these numbers:

- **Merge conflict surface** scales as n*(n-1)/2. 4 agents = 6 pair combinations, 5 = 10, 8 = 28. The jump from 4 to 5 is acceptable; past 5 it gets painful fast.
- **Review bandwidth**: reviewing 4 separate diffs in one sitting is the upper edge of what a human can do without quality dropping into rubber-stamping.
- **API rate limits**: parent + 4 children = 5 concurrent token streams, which leaves headroom on standard tiers. 8+ regularly hits throttling and silently serializes the "parallel" work.
- **Local resources**: each worktree is a full repo copy plus tool processes. 4 is comfortable on a typical Mac; 8+ starts to matter for large monorepos.
- **Diminishing wall-clock returns**: the slowest agent dictates total time. With 4 agents you already capture ~80% of the theoretical speedup; more mostly buys coordination overhead, not speed.
