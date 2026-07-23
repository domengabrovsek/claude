# Vendor-and-adapt upstream skills; orchestration stays model-invoked

## Status

Accepted - 2026-07-13

## Context

We vendor five skills from [mattpocock/skills](https://github.com/mattpocock/skills) (`grill-with-docs`, `handoff`, `improve-codebase-architecture`, `write-a-skill`, `to-issues`). Upstream shipped a v1.1 restructure into a composable pipeline - `grill-with-docs -> to-spec -> to-tickets -> implement -> code-review` - where the orchestration skills are **user-invoked** (`disable-model-invocation: true`, the human types each stage and enforces context hygiene by hand) and the reusable disciplines (`tdd`, `code-review`, `domain-modeling`, `codebase-design`, `prototype`, `diagnosing-bugs`) are **model-invoked**, plus `wayfinder` (an on-ramp for too-big efforts) and `ask-matt` (a router over the user-invoked skills).

Our workflow (ADR 0001) puts orchestration at the **model-invoked** layer: the model auto-enters Research -> Grill -> Implement -> Summarize by skill `description`. We evaluated adopting the pipeline wholesale.

The decisive finding: the reusable-discipline layer is model-invoked on both sides - that is the compatible seam. All the conflict sits at the orchestration layer, where upstream is user-invoked and we are model-invoked.

## Decision

Vendor-and-adapt, not verbatim.

- **Keep orchestration model-invoked.** Our `grill-with-docs` and `build` keep auto-firing as workflow phases; the panel-grilling addition and enforcement-layer tag convention are preserved.
- **Merge upstream's disciplines into our existing skills** rather than importing them standalone: `test` gains the seams discipline + anti-patterns (tautological, horizontal-slicing); `debug` gains the build-a-red-loop-first gate, the minimise step, falsifiable-prediction format, and tagged-instrumentation cleanup; `review-pr` gains the spec-axis pass (does the diff match what the issue asked?); `improve-codebase-architecture` gains the testability and deep-vs-shallow content in its `LANGUAGE.md`.
- **Add two new skills** where we had no equivalent: `prototype` (a model-invoked discipline - throwaway spike to de-risk one decision, then discard) and `wayfinder` (the sole new user-invoked on-ramp for too-big multi-session efforts, re-homed onto file-based decision maps under `.claude/state/` because we run no issue tracker).
- **Keep our skill names** (`write-a-skill`, `to-issues`); adopt the upstream content and repoint the `> Source:` links.

Explicitly NOT adopted: the user-invoked staging layer (`to-spec` / `to-tickets` / `implement` as separately typed stages); `ask-matt` (a router only earns its keep once orchestration is user-invoked); `triage` (multi-maintainer OSS intake, not a single-operator config); `code-review`'s Standards axis (redundant with `review-pr` + `prune` + the built-in `/code-review`); the HTML-report output mode (external CDNs conflict with our self-contained norms - the Artifact tool is the correct path if visual output is ever wanted); and `disable-model-invocation` across the board.

## Consequences

- "Adopt the pipeline" resolves to adopting its **composability** (small reusable disciplines) without its **user-invoked orchestration** - the part that conflicted.
- We forgo upstream's context-hygiene staging (one unbroken window until tickets, fresh context per ticket) and its tracker-based ticketing. Our `.claude/state/` artifacts remain the cross-session state carrier.
- `wayfinder` fills a real gap (the effort too big for one session) but loses native blocking edges and claim-by-assignment; acceptable for a single operator, and the panel/lane model (ADR 0005) covers the rare multi-agent case.
- Vendored skills stay drifted from upstream by design (our tags, `> Source:` lines, name choices). Re-vendoring is manual - no pinned upstream SHA - so future syncs repeat this cherry-pick judgment rather than fast-forwarding.

## Considered alternatives

- **Full pipeline verbatim (all user-invoked) + `ask-matt`.** Rejected: inverts our auto-phase workflow, forces the human to sequence every stage, and needs a tracker plus router upkeep. The retraining cost is not justified for a single-operator config.
- **Hybrid: model-enters / user-steps-stages, or user-kicks-off / model-runs.** Rejected: mixed mental model (the model auto-enters then stalls waiting for a manual next stage); the user-kicks variant also loses the context-hygiene that was the pipeline's main draw.
- **Adopt the grill split (`grilling` + `domain-modeling`).** Rejected: strands our thin orchestrator pointing at two skills we would then have to vendor, duplicates our inline `CONTEXT.md` / ADR discipline, and discards our panel-grilling addition for zero capability gain.
