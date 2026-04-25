# Cross-Session Repo Isolation

Concurrent Claude sessions on the same repo collide on working tree state, branch checkout, and partial edits. The repo-lock system (Phases 1-3) and this rule together prevent that.

## Decision Tree (apply at session start, before first mutation)

1. **Read-only session** (only Read / Grep / Glob, no Edit / Write / git mutation): no action. Skip the rest.
2. **Light edit** (1-2 files, <5 min expected, no plan file): SessionStart hook already claims the lock. If it printed a `NOTICE: another Claude session is active` message, **stop and ask the user** whether to wait, share the existing session, or isolate via worktree. Do not start mutating.
3. **Non-trivial work** (plan file exists, multi-file changes, branch+commit+push expected): always isolate via worktree before the first mutation. Run `/user:worktree <slug>`.

## Slug Convention

- Branch name, worktree dir basename, and lock id share one slug.
- Source the slug from the plan filename if a plan exists (e.g. `2026-04-25-agent-isolation.md` → slug `agent-isolation`).
- Otherwise: `<topic>-<6char-hex>`.
- Branch: `feat/<slug>` (or `fix/<slug>` for bug fixes, `chore/<slug>` for cleanups).
- Worktree dir: `../<repo-basename>-<slug>` (sibling of main checkout).

## When the Guard Blocks You

The PreToolUse guard refuses mutating Edit / Write / Bash when another live session holds the lock and you are not in a worktree. Remediation in priority order:

1. **`/user:worktree <slug>`** - the right answer almost always. Isolates this session, no race risk.
2. **`/user:locks --prune`** - if the other session is genuinely dead (machine crashed, process killed, last_seen >30 min old).
3. **`SKIP_LOCK=1 <command>`** - one-shot bypass. Use only when you know the other session is in a different part of the repo and won't collide. Risky.

Never silently retry past the guard. Never instruct the user to disable the hooks.

## Worktree Lifecycle

- Create: `/user:worktree <slug>` (which runs `git worktree add ../<repo>-<slug> -b <slug>` and `cd`s into it).
- Work: commit + push from the worktree as normal. The branch lives upstream.
- Merge back: open a PR from the worktree's branch. Once merged, run `/user:worktree-merge` to remove the worktree and release its lock.
- Auto-cleanup on `/user:summarize`: removes worktrees whose branch is `gone` upstream or has zero unpushed commits. Worktrees with unpushed work persist.

## Why Worktrees Over Locks Alone

Locks are advisory - races and stale locks happen. Worktrees physically isolate working trees. Cost: one disk-clone of the repo + per-worktree `node_modules`. For non-trivial work this cost is trivial vs. the cost of a corrupted main checkout mid-session.
