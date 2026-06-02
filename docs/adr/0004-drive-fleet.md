# Drive-fleet: a manager-only loop that drives a fleet of MRs/PRs to done

## Status

Accepted - 2026-06-02

## Context

Multi-MR / multi-lane work (often spanning sibling repos) was being driven ad hoc: the main session edited, reviewed, and rebased branches itself while holding the whole fleet's state in one context. That context fills fast, edits in one lane stomp another, and CI polling blocks the turn. The subagent-spawn model (ADR 0003) and worktree isolation (`rules/parallel-agents.md`) already exist to avoid this, but nothing tied them into a repeatable end-to-end workflow with a stop condition.

Claude Code's built-in `/goal` command supplies the missing piece: a plain-English completion condition that keeps a session working across turns and auto-clears when met. That makes a hands-off "drive the fleet to done" loop possible without any custom Stop-hook machinery.

Two existing skills create tension with a hands-off loop. `/mr` enforces a human approval gate at MR/PR creation "even when auto mode is active", and `/ci` requires proposing fixes to the user and flagging flaky/infra failures rather than auto-fixing. A fully autonomous loop would contradict gates that were built deliberately.

## Decision

Introduce a `drive-fleet` skill encoding a two-phase workflow:

1. **Plan via grills** (`/grill-with-docs`) - pressure-test the approach, emit CONTEXT.md + ADRs inline, and write an execution plan to `.claude/state/plans/` that proves the lanes are file-isolated.
2. **Drive with `/goal`** - the operator opens a fresh manager session and sets a `/goal` (the agent cannot start its own session or set its own goal). That single session then runs an orchestration loop that delegates ALL edit / review / rebase / conflict work to worktree-isolated domain-expert subagents. It never mutates a working tree and never spawns nested sessions; `/goal` plus context compaction sustain the one loop until the condition holds.

The skill is platform-neutral: all VCS/CI mechanics delegate to `/mr` and `/ci`. Repo-specifics (target branch, verification command, any post-completion job such as `notify_reviewers`) live in a per-repo block, not in the skill body.

Authorization is reconciled with the existing gates by **batching, not bypassing**: the human approves the fleet's MRs once - preserving `/mr`'s outward-facing, memory-valued create gate - and setting the `/goal` pre-authorizes in-scope downstream iteration (auto-fix, flaky-retry, rebase, review fixes). Three conditions always hard-stop and escalate instead of plowing ahead: a plan-invalidating conflict, a structural CI failure (3x the same issue), and the outward `post_completion_action`.

## Consequences

- Multi-MR work runs hands-off after a single batched approval, with the manager's context staying small (state lives in subagents and worktrees).
- The deviation from `/mr`'s per-MR gate and `/ci`'s per-fix gate is deliberate and scoped: the gate is batched to MR creation, and autonomy is bounded by the approved plan plus the three escalation carve-outs.
- The workflow depends on `/goal` (built into Claude Code) and on the lanes being genuinely file-isolated; a plan that fails the isolation proof is not safe to run.
- Cross-repo runs under a non-git parent require manual per-repo worktree management.

## Considered alternatives

- **Preserve every gate** (surface each MR-create and each fix for approval). Rejected: it defeats the hands-off premise; `/goal` would just keep the session alive across a wall of checkpoints.
- **Full blanket pre-authorization** (no gate at all). Rejected: MR creation is outward-facing and the standing preference is to always route through `/mr`'s gate. Batching the gate keeps one human checkpoint where it matters without serializing the rest.
- **Build a custom `/goal` command + Stop hook.** Rejected: `/goal` already ships in Claude Code and does exactly this; custom machinery would be redundant.
