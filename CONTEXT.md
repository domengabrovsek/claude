# Claude Config

The domain language for this repo's agent-orchestration model: how the main session delegates parallel work to spawned agents, and the two coordination shapes that delegation can take.

## Language

**Teammate**:
A named agent spawned via the Agent tool (the `name` parameter makes it addressable). Both coordination modes spawn named teammates.
_Avoid_: "subagent" when the agent is named - reserve subagent for the generic Agent-tool spawn mechanism.

**Lane mode**:
Parallel teammates in isolated git worktrees, each owning disjoint files, running in the background and reporting to the parent via completion notifications with no peer messaging.
_Avoid_: "fan-out mode", "worktree mode".

**Panel mode**:
Named read-only teammates that coordinate peer-to-peer via SendMessage to challenge each other, then converge into one synthesis for the parent.
_Avoid_: "round-table", "team mode".

## Relationships

- A **Teammate** runs in either **Lane mode** or **Panel mode**.
- **Lane mode** is for mutating work (build/implementation); **Panel mode** is for read-only work (research, grilling, design).
- The distinguishing axis is coordination topology: **Lane mode** is a star (teammates report only to the parent), **Panel mode** is a mesh (teammates also message each other). Worktree isolation follows from this: lanes mutate files so they need worktrees, panels are read-only so they do not.
- Background execution (`run_in_background`) is orthogonal to mode - either mode can run in the background.

## Example dialogue

> **Dev:** "I'm running /build on three file-isolated tracks - should the teammates talk to each other?"
> **Maintainer:** "No, that's lane mode - each owns its files, runs in a worktree, and reports back via notification. Peer messaging is panel mode, for /research and /grill where teammates need to challenge each other's findings before converging."

## Flagged ambiguities

- "subagent" was used for both the generic spawn mechanism and a named agent - resolved: a named agent is a **Teammate**; "subagent" refers only to the generic Agent-tool spawn.
- "in the background" was conflated with "spawned as a team" - resolved: background execution is orthogonal to coordination mode.
