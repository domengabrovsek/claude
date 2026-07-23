# Claude Config

The domain language for this repo's agent-orchestration model (how the main session delegates parallel work to spawned agents, and the two coordination shapes that delegation can take) and its skill model (how skills are invoked and layered).

## Language

### Agent orchestration

**Teammate**:
A named agent spawned via the Agent tool (the `name` parameter makes it addressable). Both coordination modes spawn named teammates.
_Avoid_: "subagent" when the agent is named - reserve subagent for the generic Agent-tool spawn mechanism.

**Lane mode**:
Parallel teammates in isolated git worktrees, each owning disjoint files, running in the background and reporting to the parent via completion notifications with no peer messaging.
_Avoid_: "fan-out mode", "worktree mode".

**Panel mode**:
Named read-only teammates that coordinate peer-to-peer via SendMessage to challenge each other, then converge into one synthesis for the parent.
_Avoid_: "round-table", "team mode".

### Skill model

**Model-invoked skill**:
A skill the model may auto-invoke because its `description` carries trigger phrasing; the default for reusable disciplines.
_Avoid_: "auto skill".

**User-invoked skill**:
A skill only a human can start (`disable-model-invocation: true`, human-facing description); reserved for orchestration a human should sequence deliberately.
_Avoid_: "manual skill", "slash-only skill".

**Orchestrator**:
A skill that sequences other skills into a workflow.
_Avoid_: "pipeline", "flow".

**Reusable discipline**:
A single-purpose skill holding one repeatable practice, invoked by an orchestrator or the model.
_Avoid_: "helper skill".

**Seam**:
The agreed point where a test exercises behaviour; chosen highest and fewest, fixed during spec and reused by test and build.
_Avoid_: "mock point".

**Decision ticket**:
A wayfinder map entry that resolves to a decision, not a deliverable.
_Avoid_: "task", "story".

**Prototype detour**:
A throwaway spike taken to de-risk one decision, after which the code is discarded and only the learning kept.
_Avoid_: "spike task", "POC".

## Relationships

- A **Teammate** runs in either **Lane mode** or **Panel mode**.
- Our repo keeps **Orchestrators** at the **Model-invoked** layer (grill and build auto-fire as workflow phases); only `wayfinder` is a **User-invoked** orchestrator.
- A **Reusable discipline** is always **Model-invoked**; an **Orchestrator** may invoke disciplines.
- `wayfinder` resolves **Decision tickets** one per session until the fog clears, then hands to the spec stage.
- **Lane mode** is for mutating work (build/implementation); **Panel mode** is for read-only work (research, grilling, design).
- The distinguishing axis is coordination topology: **Lane mode** is a star (teammates report only to the parent), **Panel mode** is a mesh (teammates also message each other). Worktree isolation follows from this: lanes mutate files so they need worktrees, panels are read-only so they do not.
- Background execution (`run_in_background`) is orthogonal to mode - either mode can run in the background.

## Example dialogue

> **Dev:** "I'm running /build on three file-isolated tracks - should the teammates talk to each other?"
> **Maintainer:** "No, that's lane mode - each owns its files, runs in a worktree, and reports back via notification. Peer messaging is panel mode, for /research and /grill where teammates need to challenge each other's findings before converging."

## Flagged ambiguities

- "subagent" was used for both the generic spawn mechanism and a named agent - resolved: a named agent is a **Teammate**; "subagent" refers only to the generic Agent-tool spawn.
- "in the background" was conflated with "spawned as a team" - resolved: background execution is orthogonal to coordination mode.
- "skill" was used for both sequencing workflows and single practices - resolved: a sequencing skill is an **Orchestrator**, a single-practice skill is a **Reusable discipline**.
