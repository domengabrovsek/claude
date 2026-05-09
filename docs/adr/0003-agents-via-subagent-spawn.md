# Agents are spawned as subagents, not read into the main conversation

## Status

Accepted - 2026-05-09

## Context

The original `rules/agent-routing.md` instructed Claude to *"Always load agents before research phase - read the files before forming opinions"*. In practice that meant 3-4K tokens of agent persona content was injected into the main conversation any time a task touched a specialized domain. Cross-domain work loaded multiple agents into the same thread, often 12-15K tokens of guardrails, biases, and frame-of-reference for one phase of work that would persist for the rest of the session.

The Agent tool's `subagent_type` parameter exposes the same agent personas as full subagents with their own context window. The parent receives the subagent's summary, not the agent's full guidance. This is structurally cheaper and cleaner: the Postgres expert's biases live in a Postgres-shaped subagent and don't bleed into the frontend work an hour later.

The cost driver is also the routing table itself. The previous version had 27 rows mapping topic triggers to agent files, with redundant "Domain trigger" and "Load when..." columns - ~3.5K tokens always-loaded.

## Decision

Two structural changes:

1. **Loading model.** When a task touches a specialized domain, spawn a subagent via the Agent tool with the matching `subagent_type`. Do not read agent files into the main conversation. The subagent's summary is what the parent acts on.

2. **Routing table slimmed.** Collapsed from 27 trigger-keyed rows to 16 agent-keyed rows (one per agent), with one combined trigger column instead of two. Cross-domain combinations (UI work, perf work, EU data handling, etc.) moved to a separate, smaller section. Net: ~50% reduction in always-loaded routing tokens.

Trivial changes still skip subagent spawning entirely.

## Consequences

- Cost in the main conversation drops to ~0 per agent invocation. Cost moves into the subagent's bounded context.
- Cleaner separation of concerns: agent guardrails apply in the subagent, not as an indelible bias on the parent thread.
- Multiple agents on one task become cheap: spawn them in parallel via a single message with multiple Agent tool calls.
- Sub-agents see none of the parent conversation, so the parent must write self-contained prompts (goal, file paths, constraints, verification command). This is already covered in `rules/parallel-agents.md`.

## Considered alternatives

- **Keep the read-into-main pattern but slim the agent files.** Rejected: the structural problem is loading specialist content into a generalist context, not file size. Slimming files is a separate, lower-leverage optimization that is now mostly moot under subagent loading.
- **Drop agents entirely and rely on `CLAUDE.md` + `rules/`.** Rejected: the user values having 16 specialized personas available situationally. The agent files are not dead weight; the dead weight was loading them eagerly.
- **Auto-spawn subagents based on keyword detection.** Rejected: speculative routing would over-trigger. The model deciding when a task is specialized enough to warrant a subagent is the right judgment call.
