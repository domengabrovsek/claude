# Lean personas with rules inheritance; advisory personas read-only via tools frontmatter

## Status

Accepted - 2026-07-31

## Context

The persona files in `agents/` grew to ~130-150 lines each on a shared template (Identity with fabricated CVs, Core Expertise, Thinking Approach, Response Style, long Strict Guardrails, Tools & Frameworks, Integration with Workflow). Much of that content is either recall the model already has (OWASP taxonomies, GDPR article numbers) or a restatement of `rules/*.md`, which custom subagents already receive: Claude Code injects the user's CLAUDE.md and its `@`-imported rules into every custom subagent's context. Duplicating a rule in a persona buys no compliance and creates a second copy to drift. Separately, panel mode (ADR 0005) relied on brief-level discipline to keep domain-expert panelists read-only, because every persona had the full toolset.

## Decision

Personas are lean spawn-time briefs (roughly 50-75 lines): a role statement, working method, repo-specific guardrails tagged `(persona)`, red flags, and an output contract. Guardrails that duplicate `rules/` or generic domain knowledge are deleted, because custom subagents inherit CLAUDE.md and the imported rules. Review and compliance personas (PR Reviewer, Cybersecurity Expert, GDPR Expert) are advisory: their frontmatter `tools` list excludes Edit/Write/NotebookEdit, so the read-only guarantee is mechanical, not brief-level.

## Consequences

- Personas must not restate `rules/` content; a persona bullet earns its place only by being repo-specific or non-obvious. Rule changes now propagate to subagents automatically instead of requiring persona edits.
- The lean shape depends on the inheritance mechanism: if Claude Code ever stops injecting CLAUDE.md and imported rules into custom subagents, persona guardrails lose their backing and this ADR must be superseded.
- Advisory personas cannot serve as lane-mode writers; spawning one for mutating work fails at the tool layer, which is intended. Lane mode requires writer personas.
- Panel mode's read-only guarantee upgrades from prompt discipline to tool enforcement for the advisory personas, closing the soft gap noted in ADR 0005.

## Considered alternatives

- **Keep the full template, prune only the worst recitations.** Rejected: the template's fixed sections (Identity, Core Expertise, Response Style) invite padding back in, and the rules/ duplication problem remains structural rather than incidental.
- **Enforce read-only via brief text instead of tools frontmatter.** Rejected: brief-level guarantees depend on the model's attention under load; the tools list is enforced by the harness and cannot be talked around.
- **Move persona guardrails into rules/ entirely and delete personas.** Rejected: rules/ is global and loads into every session; domain-specific review judgment (attack scenarios, lawful-basis analysis) only pays for itself in the matching subagent's context.
