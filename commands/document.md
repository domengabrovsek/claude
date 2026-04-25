---
description: "Create or refresh technical engineering docs in the current repo's /docs/ tree. Diataxis layout, mermaid diagrams, ADR support, drift audit."
---

Generate or update engineering documentation for: $ARGUMENTS

This command writes docs that are dual-audience: engineers reading on GitHub AND Claude agents reading the repo. Apply the rules below without exception.

## Subcommands

Parse the first word of `$ARGUMENTS` as the subcommand:

- `explain <topic>` - create/update `docs/explanation/<topic>.md` (the *why* and *how it fits together*)
- `reference <topic>` - create/update `docs/reference/<topic>.md` (lookup tables, env vars, schemas, enums)
- `how-to <task>` - create/update `docs/how-to/<task>.md` (a recipe to do one thing)
- `tutorial <topic>` - create/update `docs/tutorials/<topic>.md` (learning path, onboarding)
- `adr "<title>"` - draft the next-numbered ADR in `docs/adr/`
- `diagram <type> <topic>` - add or update a mermaid diagram inside the matching doc
- `audit` - read every `docs/**/*.md`, compare against current code, produce a drift report (read-only, no edits)
- `bootstrap` - create the full `docs/` skeleton in a repo that has none yet (uses `~/.claude/templates/docs-readme.md` and `~/.claude/templates/adr.md`)

If no subcommand matches, ask the user which one they meant before writing anything.

## Diataxis routing

If a topic does not clearly fit one quadrant, ask. Do not split a single topic across quadrants.

| Quadrant | Use when... | Don't use when... |
|----------|-------------|-------------------|
| explanation | Reader asks *why does this exist* or *how does this fit together* | They want to do a concrete task |
| reference | Reader needs to look up an exact value, name, or signature | They want narrative context |
| how-to | Reader has a goal and needs steps | They are still trying to understand the concept |
| tutorial | Reader is new and learning end-to-end | They already know the system |

## Quality rules (apply to every doc you write)

1. **One topic per file.** If two H1-worthy ideas appear, split into two files.
2. **Lead with TL;DR** in 3 sentences or fewer, before any heading. Body expands.
3. **Cite source files** with backticked relative paths (`src/foo/bar.ts`). Link, do not paste. Inline code blocks longer than 15 lines are forbidden - link to the file instead.
4. **Tables over prose** for any list of more than 3 parallel items.
5. **Diagrams for relationships only.** No diagram if a 3-row table conveys it. Mermaid only - no draw.io, no PNGs.
6. **Why before how.** Every explanation doc opens with the problem the thing solves.
7. **No forward-looking content.** Document only behavior that exists now. No "we plan to", no "in the future".
8. **No issue/PR/ticket numbers.** They rot. Put them in PR descriptions and git history, not docs.
9. **ADRs are immutable once Accepted.** A new decision = a new ADR with `Status: Supersedes NNNN`. Never edit the body of an Accepted ADR.
10. **Max 300 lines per doc.** If longer, split by sub-topic.
11. **No emoji** unless the user explicitly asked for them.
12. **No em dashes.** Use a regular hyphen.

## Mermaid conventions

- Use ` ```mermaid ` fenced blocks. GitHub renders them natively.
- Diagram type by purpose:
  - `flowchart TD` for high-level architecture and decision trees
  - `sequenceDiagram` for request flows, auth flows, async messaging
  - `erDiagram` for data models
  - `stateDiagram-v2` for state machines (order status, sync status)
  - `flowchart LR` with subgraphs for C4-context (services, queues, datastores)
- Keep node labels short. Put long descriptions in adjacent prose, not in the diagram.
- One diagram per doc maximum, unless the doc is explicitly an architecture doc.

## File layout the command produces or expects

```text
<repo>/
  docs/
    README.md             # index grouped by Diataxis quadrant
    explanation/
    reference/
    how-to/
    tutorials/
    adr/
      README.md           # ADR index, table of {NNNN, title, status, date}
      NNNN-<slug>.md
    diagrams/             # optional shared .mmd snippets, only if reused
```

## ADR procedure

When `adr "<title>"`:

1. Scan `docs/adr/` for highest existing number. New file = `NNNN-<kebab-title>.md`, zero-padded to 4 digits.
2. Use `~/.claude/templates/adr.md` as the body. Fill `<Title>`, today's date, status `Proposed`.
3. Append a row to `docs/adr/README.md` table.
4. Ask the user for Context, Decision, Consequences before finalizing - never invent a decision.

## Audit procedure

When `audit`:

1. Walk `docs/**/*.md`.
2. For each doc, extract source-file citations (backticked paths). Verify they exist with `Glob`/`Read`. Report missing files.
3. For each ADR, verify `Status` is one of {Proposed, Accepted, Superseded by NNNN, Deprecated}. Flag malformed ADRs.
4. For each `docs/reference/*.md`, scan referenced enums/configs (e.g. `src/**/enums/*.ts`) and report mismatches between doc tables and code.
5. Report doc files exceeding 300 lines.
6. Report any `docs/**/*.md` not linked from `docs/README.md`.
7. Output a report only - do NOT edit files. The user runs targeted subcommands afterward to fix drift.

## CLAUDE.md integration

After bootstrapping or significant doc changes, update the repo's `CLAUDE.md` so it points to `docs/README.md` in its Documentation section. This keeps Claude's auto-discovery working.

## Verification before finishing

- `markdownlint-cli2 docs/**/*.md` if the repo has it configured (check for `.markdownlint*` files).
- All mermaid blocks are syntactically valid (rough check: balanced fences, recognized diagram type).
- All source-file citations resolve.
- The doc fits the quality rules above.

If any check fails, fix it before reporting done.

## Out of scope for this command

- Generated API references (Swagger/OpenAPI, TypeDoc) - separate tooling.
- Product specs - those live in `pentla-specs`.
- Anything outside `docs/` in the current repo.
