# Two coordination modes for parallel agents: lane and panel

## Status

Accepted - 2026-06-30

## Context

ADR 0003 (Accepted 2026-05-09) established that specialized agents are spawned as subagents via the Agent tool, with the parent acting on each subagent's returned summary. `rules/parallel-agents.md` then encoded a single shape for all parallel work: worktree-isolated, file-disjoint teammates running in the background, reporting to the parent via completion notifications. Two of its bullets - "wait for automatic completion notifications, do NOT poll" and "NEVER run parallel agents without worktree isolation" - apply that one shape to every parallel task.

That shape is correct for implementation, but wrong for research and grilling. Both 0003 and `parallel-agents.md` predate two Claude Code features that changed what is possible: nested subagents (2.1.172, 2026-06-10) and implicit agent teams with named, addressable teammates that message each other via SendMessage (2.1.178, 2026-06-15). Neither document contemplated teammates coordinating peer-to-peer, so the config has no vocabulary for it and the "wait for notifications" rule actively suppresses it.

The observable symptom: a prompt like "build this plan in parallel via domain expert subagents" produced a coordinated team only about 60% of the time. A transcript analysis across 49 agent-spawning sessions confirmed the cause is not the word "subagent" (neutral in the data) but the absence of an entry-point that selects a coordination shape, combined with the standing "wait for notifications" rule biasing every spawn toward fire-and-forget.

## Decision

This is an additive decision. ADR 0003's loading model (spawn subagents, do not read persona files into the main conversation; parent acts on summaries) stays valid and untouched. What is new is the coordination topology, which now has two named modes.

**Lane mode** - for mutating work (build/implementation). Parallel teammates in isolated git worktrees, each owning disjoint files, running in the background, reporting to the parent via completion notifications, with no peer messaging. This is a star topology. It is exactly the workflow `rules/parallel-agents.md` already describes and that `drive-fleet` (ADR 0004) orchestrates; the "wait for notifications" and "worktree MUST" rules are scoped to this mode.

**Panel mode** - for read-only work (research, grilling, design). Named teammates that coordinate peer-to-peer via SendMessage to challenge each other, then converge. This is a mesh topology. Because the work is read-only, no worktrees are needed. Panel mode follows a structured protocol with a stop condition:

1. **Independent pass** - each teammate explores its area or forms its position alone.
2. **Cross-challenge round** - each teammate sees the others' outputs and sends targeted SendMessage challenges. Bounded to one pass for research; iterate-to-convergence for grilling and design.
3. **Parent converges** - the main session synthesizes the result (research: the artifact; grill: the next question to the user). The parent owns convergence because it holds the user relationship and the artifact; there is no "lead teammate".

The distinguishing axis between the modes is coordination topology (star vs mesh) plus isolation (worktree vs read-only), not whether teammates are named - both modes name their teammates so they are addressable.

**Read-only enforcement** differs by surface, deliberately:

- **Research panels** spawn as the `Explore` agent type, whose toolset excludes Edit/Write/NotebookEdit. The read-only guarantee is mechanical.
- **Grill and design panels** use the domain-expert agent types from `rules/agent-routing.md` for their personas, with an explicit read-only brief. The Agent tool has no per-spawn tool-restriction parameter, so the guarantee here is soft (brief-level). This is accepted because the value is expert adversarial framing, the work is investigative, and the parent reviews everything before any mutation happens in a later build.

**Mode-selection lives at the entry points**, not only in the reference, so the right mode is pulled without per-prompt wording:

- `commands/research.md` declares panel mode (Explore teammates).
- `skills/grill-with-docs/SKILL.md` may convene a panel (domain-expert teammates), while keeping the user-facing one-question-at-a-time cadence.
- `skills/build/SKILL.md` declares that a multi-lane plan maps to one lane-mode teammate per file-isolated lane.

## Consequences

- "Build in parallel" becomes deterministic: a multi-lane plan pulls lane mode at the build entry-point instead of being a per-prompt coin-flip.
- Research and grilling gain sanctioned peer-to-peer coordination with a stop condition, instead of either fire-and-forget subagents or unbounded mesh chatter.
- Panel mode's "no worktree" safety rests on the read-only guarantee, which is mechanical for research (Explore) and brief-level for grill/design. A domain-expert panel that ignores its read-only brief could mutate files; the parent's pre-build review is the backstop.
- `rules/parallel-agents.md` bullets that were unconditional become mode-scoped, removing the contradiction that biased every spawn toward fire-and-forget.
- ADR 0004 (drive-fleet) is unchanged; it is the canonical lane-mode orchestration and 0005 only references it.

## Considered alternatives

- **Supersede ADR 0003.** Rejected: 0003's loading-model decision is independent of coordination topology and remains correct. Panel mode adds a topology; it does not reverse how agents are loaded.
- **Free-form mesh chatter for panels.** Rejected: no stop condition, burns tokens, and can loop. The structured independent-then-cross-challenge protocol preserves the peer-challenge value with a bound.
- **A hard mechanical read-only guarantee everywhere** (Explore/Plan agent types for grill too). Rejected: it would strip the domain-expert personas that make adversarial grilling valuable. Soft read-only plus the pre-build review is the accepted trade-off for grill/design.
- **Describe the modes only in `rules/parallel-agents.md`.** Rejected: that is what exists today, and it is why mode-selection was a coin-flip. Anchoring selection at the command/skill entry-points is the change that fixes it.
