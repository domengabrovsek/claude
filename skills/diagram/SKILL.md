---
name: diagram
description: "Create or update a diagram. Picks mermaid vs drawio per rules/diagrams.md, writes the source file, previews via MCP. Use when the user says 'diagram', '/diagram', or asks for a flowchart/architecture/sequence/state diagram."
---

Create or update the diagram for: $ARGUMENTS

## Step 1 - Pick the format

Read `rules/diagrams.md` if uncertain. Default to **mermaid** unless one of these triggers fires - then use **drawio**:

- Custom shapes, icons, or cloud provider symbols requested
- Precise grid / column layout (network topology, rack diagrams)
- More than 2 swimlanes, or nested swimlanes
- Multi-layer architecture (stacked data/control planes)
- Color or styling carries semantic weight that mermaid cannot express
- The user explicitly says "drawio" or "complex"

If the diagram is borderline, ask the user before committing to drawio.

## Step 2 - Locate the doc

- Identify the doc this diagram belongs to. If `docs/` does not exist, ask the user where to put it.
- Slug the topic from $ARGUMENTS or the parent doc's filename.

## Step 3 - Mermaid path

1. Write the mermaid source inline in the target doc using ```` ```mermaid ```` fenced blocks (one block per diagram).
2. Match diagram type to purpose: `flowchart` / `sequenceDiagram` / `stateDiagram-v2` / `erDiagram` / `classDiagram` / `gitGraph` / `journey`.
3. Keep node labels short. Long descriptions go in adjacent prose.
4. Verify with `mcp__drawio__open_drawio_mermaid` if you want a quick render check (optional).
5. Commit the doc.

## Step 4 - Drawio path

1. Generate drawio XML for the diagram. Use `mcp__drawio__open_drawio_xml` reference (in the tool description) for shape catalogue, edge routing, swimlanes, containers.
2. Write the source to `docs/diagrams/<slug>.drawio`.
3. Call `mcp__drawio__open_drawio_xml` with the XML content - opens in the browser editor for the user to review and export PNG.
4. Instruct the user: `File > Export As > PNG > save to docs/diagrams/<slug>.png`. They commit both files.
5. In the consuming doc, embed:

   ```markdown
   ![<topic>](diagrams/<slug>.png)
   *Source: [`<slug>.drawio`](diagrams/<slug>.drawio)*
   ```

## Step 5 - Drift / update

If updating an existing diagram:

- For mermaid: edit the inline block, keep the same diagram type unless the change requires a different one.
- For drawio: edit the `.drawio` source, re-open via MCP, re-export PNG, replace both files. Same commit.

## Anti-patterns

- Do not generate ASCII art instead of a real diagram.
- Do not write more than one mermaid block per doc unless the doc is explicitly an architecture overview.
- Do not commit a `.drawio` file without its `.png` (GitHub reviewers need the preview).
- Do not ship a `.png` without its `.drawio` source (next maintainer needs to edit it).
- Do not invent layout coordinates manually for drawio - rely on its auto-layout. Set node ids, labels, edges, lanes; let drawio route.
