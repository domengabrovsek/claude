# Drop the cross-session repo-lock machinery

## Status

Accepted - 2026-05-09

## Context

The original system shipped a multi-piece subsystem to prevent two Claude sessions from corrupting each other's working tree on the same repo: a `SessionStart` lock claim, a `PreToolUse` guard that hard-blocked mutations when another session held the lock, a `PostToolUse` heartbeat that refreshed the lock, a `SessionEnd` release, plus a `repo-lock.sh` manager script, an `isolation.md` rule, and a `/user:locks` command. Twelve pieces in total.

Auditing actual usage produced clear answers:

- The user runs multiple Claude sessions concurrently, but each is in a **different repo**. Two sessions on the same checkout - the exact race the lock was built for - does not happen.
- There is no recall of the guard ever blocking a mutation that was about to corrupt state. No evidence the machinery has earned its keep.
- Worktrees are not used as a habit by the user; they only get reached for when the system pushes them into one.

`CLAUDE.md` itself prohibits this kind of speculative engineering: *"Don't add features beyond what the task requires. Don't design for hypothetical future requirements."* The lock subsystem is exactly that anti-pattern.

## Decision

Delete the cross-session lock subsystem entirely. Specifically:

- `hooks/repo-lock-status.sh`, `hooks/repo-lock-guard.sh`, `hooks/repo-lock-heartbeat.sh`, `hooks/repo-lock-release.sh`
- `scripts/repo-lock.sh`
- `commands/locks.md`
- `rules/isolation.md`
- All `repo-lock-*` hook entries in `settings.json` (PreToolUse Bash + Write/Edit, PostToolUse Write/Edit + Bash, SessionStart startup/resume)
- The `Cross-session isolation` bullet under Behavioral Rules in `CLAUDE.md`

The "always worktree for non-trivial work" prescription in `rules/isolation.md` is also dropped. Its motivating force was lock collision avoidance, which no longer applies. Worktrees become opt-in: useful for parallel sub-agents (still covered by `rules/parallel-agents.md`) and for personal preference, not because the system pushes the user into them.

## What stays

- `hooks/worktree-cleanup.sh` - lock-independent. It opportunistically prunes safely-disposable worktrees at SessionEnd via `worktree-prune.sh`. Useful regardless of locking.
- `scripts/worktree-prune.sh` - the engine for `/user:worktrees-prune` and `/user:worktrees-audit`.
- `/user:worktree`, `/user:worktree-merge`, `/user:worktrees-prune`, `/user:worktrees-audit` - worktree creation and hygiene commands. Their value is independent of the lock subsystem.
- `rules/parallel-agents.md` - parallel sub-agents still need worktrees to avoid stepping on each other.

`commands/worktree-merge.md` is edited to drop its lock-release step.

## Trade-offs accepted

- **Lost**: a defensive layer against a race condition. If the user's workflow ever changes - e.g. starts running two long-lived sessions on the same checkout - they would need to either rebuild this or accept the risk of partial-edit corruption.
- **Gained**: ~12 fewer pieces of machinery to maintain, no fork-per-tool-call latency from the guard and heartbeat, no false-positive blocks in legitimate single-session work, simpler `settings.json`, simpler `CLAUDE.md`.

The reversal cost is bounded: if the race ever becomes a real problem, the lock subsystem can be reconstructed from this branch's pre-deletion state in git history.

## Considered alternatives

- **Keep the machinery as-is.** Rejected: 12 pieces of surface area for a problem the user does not have.
- **Demote the guard from blocking to advisory.** Rejected: still leaves the heartbeat fork on every tool call and the surface area in commands and rules. If we are not blocking, the lock is just telemetry, and the user has no need to inspect it.
- **Keep only the SessionStart status check as a gentle warning.** Rejected on the same grounds: a warning the user does not act on is noise.
