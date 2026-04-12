# Parallel Work with Agent Worktrees

When a task can be split into independent pieces, parallelize by spawning multiple agents in isolated git worktrees. This dramatically reduces wall-clock time for multi-part work.

## When to Parallelize

Spawn parallel agents when ALL of these are true:

- The task has 2+ independent sub-tasks that touch different files or modules
- Each sub-task takes meaningful effort (not a one-liner fix)
- The sub-tasks do not need to read each other's output to proceed
- The overall task would take significantly longer done sequentially

Good candidates:

- Implementing features across multiple modules (e.g., API endpoint + frontend page + tests)
- Writing tests for several unrelated modules
- Fixing multiple independent bugs in one batch
- Refactoring several files that do not depend on each other
- Adding similar functionality to different parts of the codebase (e.g., validation to 5 different endpoints)
- Research tasks that explore different parts of the codebase

## When NOT to Parallelize

Do NOT spawn parallel agents when:

- The task is a single focused change (one file, one module)
- Sub-tasks are tightly coupled - one must see the other's output before it can start
- The work is strictly sequential (step 2 depends on step 1's result)
- The task is trivial enough to finish in under 2 minutes sequentially
- Changes will inevitably conflict (e.g., multiple agents editing the same file)
- There are only cosmetic or config changes

## How to Split Work

- **File-level isolation**: Each agent should own a distinct set of files. NEVER assign two agents to edit the same file.
- **Module boundaries**: Split along natural module/package/directory boundaries
- **Vertical slices**: Prefer giving an agent a complete vertical slice (e.g., "add the /users endpoint including route, controller, service, and tests") over horizontal slices (e.g., "write all controllers")
- **Self-contained units**: Each agent's task must be completable and testable in isolation
- **Shared dependencies**: If sub-tasks share a dependency that needs to be created first, either create it before spawning agents or assign it to one agent and make the others wait

## Worktree Isolation

Every parallel agent MUST use worktree isolation:

- Set `isolation: "worktree"` on every Agent tool call for parallel work
- Each agent gets its own full copy of the repo via git worktree
- Each agent works on its own branch - no risk of stepping on other agents' changes
- NEVER run parallel agents without worktree isolation - concurrent edits to the same working directory will cause corruption

## Background Execution

- Spawn agents with `run_in_background: true` so they execute concurrently
- Launch all independent agents in a single message with multiple Agent tool calls
- After spawning, wait for automatic completion notifications - do NOT poll or check repeatedly
- Continue with other non-conflicting work while agents run, if possible

## Merging Results

After all agents complete:

1. Review each agent's changes for correctness
2. Merge branches one at a time into the main working branch
3. After each merge, check for conflicts and resolve immediately
4. Run the full test suite, typecheck, and lint after all merges are complete
5. If a merge conflict arises, resolve it manually - do NOT re-spawn an agent for conflict resolution

## Agent Prompt Quality

Each agent's prompt MUST be self-contained. The agent cannot see the parent conversation. Include:

- **Goal**: Exactly what the agent must accomplish - be specific and unambiguous
- **Context**: Relevant background (why this change is needed, what the broader task is)
- **File paths**: Exact files to read and modify - do not make the agent search blindly
- **Constraints**: Patterns to follow, styles to match, things to avoid
- **Verification**: How the agent should verify its work (run tests, typecheck, lint)

Bad prompt: "Add validation to the API"

Good prompt: "Add Zod input validation to the POST /api/users endpoint in src/routes/users.ts. Follow the existing validation pattern in src/routes/projects.ts. Create the schema in src/schemas/users.ts. Add tests in src/routes/\_\_tests\_\_/users.test.ts. Run `npm test -- users` to verify. Work on branch parallel/users-validation."

## Limits

- **Target: 4 parallel agents.** Most real tasks decompose cleanly into 2-4 truly independent units; beyond that you're usually inventing artificial seams.
- **Hard ceiling: 5 parallel agents.** Only go this high when the task genuinely has 5 clean independent slices.
- If a task splits into more than 5 pieces, batch them into rounds rather than spawning more concurrently.
- Always prefer 3 well-scoped agents over 6 narrowly-scoped ones.

Why these numbers:

- **Merge conflict surface** scales as n*(n-1)/2. 4 agents = 6 pair combinations, 5 = 10, 8 = 28. The jump from 4 to 5 is acceptable; past 5 it gets painful fast.
- **Review bandwidth**: reviewing 4 separate diffs in one sitting is the upper edge of what a human can do without quality dropping into rubber-stamping.
- **API rate limits**: parent + 4 children = 5 concurrent token streams, which leaves headroom on standard tiers. 8+ regularly hits throttling and silently serializes the "parallel" work.
- **Local resources**: each worktree is a full repo copy plus tool processes. 4 is comfortable on a typical Mac; 8+ starts to matter for large monorepos.
- **Diminishing wall-clock returns**: the slowest agent dictates total time. With 4 agents you already capture ~80% of the theoretical speedup; more mostly buys coordination overhead, not speed.
