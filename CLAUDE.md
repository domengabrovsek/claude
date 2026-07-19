# Global Rules

These rules apply to every project. Project-level CLAUDE.md files override where they conflict.

## Priority order

When goals conflict: **quality > consistent > efficient > fast**. Shipped bugs cost more than slow shipping. Consistency is the entire point of a global config. Token efficiency compounds. Speed of output matters least when shipping serious work.

## Workflow: Research - Grill - Implement - Summarize

1. **Research** (optional): orientation pass when entering unfamiliar code. Read every relevant file, produce a research artifact at `.claude/state/research/`. Skip when the area is already familiar - the grill will explore inline.
2. **Grill**: invoke `/grill-with-docs <topic>` for real-time alignment. The grill walks the decision tree question by question, emits CONTEXT.md updates (domain terms) and ADRs (architectural decisions) inline, and ends by writing a short execution plan to `.claude/state/plans/`. The user's confirmation at grill exit is the approval gate.
3. **Implement**: explicit handoff after grill exits. Invoke `/build` to walk the execution plan task by task. Run typecheck continuously. Build + lint + test must pass before done.
4. **Summarize**: save a session diary entry to `.claude/state/sessions/` when work is complete.

The grill is self-pacing: heaviness scales with alignment complexity, not a separate threshold. When there is nothing to align on, the grill exits in two turns. So the trivial bypass narrows.

Trivial bypass (skip everything, go straight to implement, skip Summarize): typos, single-line fixes, version bumps, config tweaks. Only when you are 100% sure. If in doubt, enter the grill - it is cheap when there is nothing to grill on.

Other intents are first-class workflows with their own shapes, not stripped-down versions of the implementation workflow: `/debug` for incidents, `/zoom-out` for codebase exploration, `/review-pr` for reviewing others' code, `/document` for docs, `/spec` for feature requirements.

## Security

- NEVER read or process files containing secrets, credentials, API keys, or private keys `(review-time: backed by permissions.deny in settings.json which blocks the path patterns below)`
- Sensitive file patterns: `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json` `(review-time: descriptive list, blocked by permissions.deny)`
- Home directory secrets (`~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube`) are off-limits `(review-time: blocked by permissions.deny)`
- If you need config values for debugging, ask the user to provide only the non-sensitive parts `(review-time: conversational pattern)`

## Formatting

- Never use em dashes (-) anywhere - in code, text, translations, or documentation. Use a regular hyphen/dash (-) instead. `(hook)`

## Code Standards

- Use the project's formatter/linter (Biome, ESLint, Prettier - whatever is configured) `(review-time: per-repo configuration choice)`
- Complete code only - no TODOs, no placeholders, no incomplete implementations `(hook)`
- **Comments**: see [`rules/comments.md`](rules/comments.md). `(review-time: pointer, the substance is enforced in the linked file)`
- Detailed standards are in rules/ (typescript, tests, database, infrastructure, security, jira, comments) `(review-time: pointer to detailed rule files)`

## Docs Sync

- Engineering docs live in each repo's `/docs/` tree, organized by [Diataxis](https://diataxis.fr/) (explanation, reference, how-to, tutorials) plus an `adr/` folder for Architecture Decision Records `(review-time: directory-layout convention)`
- When code changes affect behavior documented in `docs/`, update the relevant docs in the same PR `(review-time: requires recognizing behavior-doc impact)`
- Use the `/document` slash command to create or refresh docs - it embeds the quality rules and Diataxis routing `(review-time: workflow guidance)`
- Never let docs drift from implementation - if you change it, document it `(review-time: drift recognition)`
- Only update docs that describe behavior actually changed in this session - no forward-looking references, planned features, or speculative content `(review-time: session-scope discipline)`
- Diagrams default to Mermaid (text-based, GitHub-rendered, AI-readable). Use drawio when the diagram needs custom shapes, multi-layer architecture, >2 swimlanes, or precise layout - see `rules/diagrams.md` for the policy and `/diagram` skill for the workflow `(review-time: diagram-tool selection)`
- ADRs are immutable once Accepted - a reversed decision creates a new ADR that supersedes the old one `(review-time: ADR lifecycle convention, overridden per-repo)`

## Behavioral Rules

- **Scope**: only implement what was asked - no drive-by refactors, extra features, or unsolicited improvements `(review-time: scope judgment)`
- **Minimal fix**: for bug fixes, identify the root cause and state the smallest possible change first (ideally 1-5 lines). Only expand the scope if the minimal fix is provably insufficient. Never introduce new abstractions, files, or patterns as part of a bug fix unless the user explicitly asks `(review-time: minimal-fix judgment)`
- **Decisions**: ask before making architectural choices - never silently pick a pattern, library, or approach `(review-time: requires recognizing an architectural choice point)`
- **Cost**: warn before any change that increases costs (new cloud resources, paid services, upgraded tiers) `(review-time: cost-impact recognition)`
- **Testing**: always write tests when implementing a new feature or fixing a bug - no exceptions `(review-time: per-PR judgment about test coverage of the change)`
- **Conciseness**: be direct and terse during implementation - save explanations for when asked `(review-time: phrasing-length judgment)`
- **Existing patterns**: follow the conventions already in the codebase - consistency over personal preference `(review-time: pattern-recognition in surrounding code)`
- **Context first**: before choosing an approach, check how similar problems are already solved in the codebase - grep for existing patterns, read neighboring files, and follow established conventions rather than guessing `(review-time: workflow discipline)`
- **Verification**: always run `/verify-done` before pushing - never push without all checks passing `(hook)`
- **Atomic feature unit**: "implement" means implement + commit on a feature branch + push + open PR. Never stop after the code change. Never commit to `main`/`master` directly. If on a protected branch, create a feature branch first. `(hook)`
- **Parallelization**: when a task has 2+ independent sub-tasks touching different files, split across multiple agents using git worktrees - see `rules/parallel-agents.md` `(review-time: parallelization judgment, see rules/parallel-agents.md)`
- **One question at a time**: when asking the user a clarifying question, ask only one per turn and wait for the answer before asking the next - no stacked or bundled questions, even closely related ones. See `rules/communication.md` `(review-time: conversational cadence)`

Detailed git, testing, and exploration rules are in `rules/` (git-conventions, engineering-principles).

## Learning from Mistakes

- When corrected, update the relevant CLAUDE.md or rule file so the mistake is not repeated `(review-time: meta-process for rule maintenance)`
- Check if an existing rule already covers the correction - update it rather than adding a duplicate `(review-time: dedup discipline)`

## Environment

- macOS, zsh, Node.js (check `.nvmrc`), npm `(review-time: environment description, not a rule per se)`
- Docker for local services `(review-time: environment description)`
- Cloud: GCP primary, AWS secondary `(review-time: provider preference)`
- Current year: 2026 - verify when generating dates, timestamps, or date-dependent logic `(review-time: requires knowing whether a date is involved)`
- Access boundaries: .env files, credentials, and secrets are blocked by deny rules - do not attempt workarounds. For staging databases and external services requiring auth, ask the user for credentials or URLs rather than trying to authenticate `(review-time: backed by permissions.deny; "do not attempt workarounds" is behavioral)`
- Sentry: read access is available via the `sentry-issue` skill (uses the local `sentry-cli` token, org-agnostic). When given a Sentry issue ID or URL, use that skill - do not ask the user to paste issue contents and never print the token `(review-time: routing to a skill; token non-disclosure is behavioral)`

## Imported rules

The files below are loaded into every session via these `@`-imports. Edit the individual rule files in `rules/` - they are the source of truth, not this list.

@rules/agent-routing.md
@rules/comments.md
@rules/communication.md
@rules/context7.md
@rules/rule-authoring.md
@rules/database.md
@rules/diagrams.md
@rules/engineering-principles.md
@rules/git-conventions.md
@rules/infrastructure.md
@rules/jira.md
@rules/parallel-agents.md
@rules/state-persistence.md
@rules/tests.md
@rules/typescript.md
