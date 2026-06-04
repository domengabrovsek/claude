# Rule Authoring Policy

**When to apply:** writing or editing any normative bullet in `rules/*.md`, `CLAUDE.md`, `agents/*.md`, `skills/**/SKILL.md`, or `RTK.md`.

## Why this exists

Rules sitting in text files are loaded into every Claude session, but loading is not enforcement. Compliance failures happen when the agent forgets or misreads. The cure isn't more rules - it's making the enforcement layer of each rule explicit so the reader (human or LLM) knows what's mechanically backed and what's attention-dependent. Where mechanical backing is possible, we add it. Where it isn't, we own that the rule depends on attention.

## The five enforcement layers

Ranked by reliability (earliest catch wins per the shift-left principle):

| Tag | Where enforced | Cost when violated |
|---|---|---|
| `(hook)` | `~/.claude/hooks/*.sh` via `~/.claude/settings.json` | ~1s, fed back to Claude as a tool result |
| `(lint)` | Repo `biome.json` / `eslint.config.js` / `.markdownlint*` | `npm run check` run |
| `(CI)` | `.github/workflows/`, pentla-shared reusables | PR cycle |
| `(persona)` | A `~/.claude/agents/*.md` persona file's guardrail section | Subagent compliance, not global |
| `(review-time: <why>)` | Human attention or Claude attention at review or response time | Open-ended |

## The marker requirement

Every **normative** bullet in an in-scope file ends with a tag. A normative bullet asserts a "do X" or "don't Y" - the rule itself. Prose paragraphs (motivation, examples, prerequisites) carry no tag.

Format: backtick-wrapped, single space before, end of line.

```markdown
- No `var` in JS/TS - use `const` or `let` `(hook)`
- Prefer interface over type for object shapes `(lint)`
- Lead with your recommendation when you have one `(review-time: subjective phrasing, not pattern-matchable)`
```

## The `(review-time)` justification

`(review-time)` is the weakest layer and the easiest place for rules to silently accumulate. To gate that:

- Every `(review-time)` tag MUST include a colon-prefixed justification: `(review-time: <one-line why>)`.
- The justification answers: *why can't a hook, linter, or CI check catch this?*
- If many bullets in a single section share the same justification, write the justification once as a `**why-not-mechanizable:**` paragraph immediately under the section heading, then use `(review-time: see section note)` on each bullet.
- If you can't write a one-line justification, the rule is probably either mechanizable (write the hook instead) or not worth keeping.

## Multi-layer conventions

- A rule with **multiple distinct aspects** belonging to different layers gets split into separate bullets, each with its own tag.
- A rule whose **single aspect** happens to be caught at multiple layers gets the strongest tag only (hook beats lint beats CI beats persona beats review-time). No `(hook + lint)` compound tags - the strongest layer is the source of truth.

## In-scope files

- `rules/*.md`
- `CLAUDE.md`
- `agents/*.md` (only the normative-guardrail sections; persona prose stays untagged)
- `skills/**/SKILL.md` (only the normative bullets; procedure / steps / examples stay untagged)
- `RTK.md` (only the normative bullets)

Out of scope: `MEMORY.md`, `keybindings.json`, `settings.json`, `docs/`, `README.md`, generic `scripts/` files.

## Lifecycle - moving a rule between layers

- Adding a new rule: pick the layer at authoring time, mark it. If `(review-time)`, write the justification.
- Mechanising an existing rule (moving up the table): change the tag and add the hook / lint config / CI check in the same PR. PR description notes the layer change in one line.
- Demoting a rule (moving down): rare but valid (e.g., a hook becomes unmaintainable). PR description notes the demotion.
- Removing a rule: just delete it. No tombstone.
