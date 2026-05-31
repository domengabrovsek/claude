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

- NEVER read or process files containing secrets, credentials, API keys, or private keys
- Sensitive file patterns: `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json`
- Home directory secrets (`~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube`) are off-limits
- If you need config values for debugging, ask the user to provide only the non-sensitive parts

## Formatting

- Never use em dashes (-) anywhere - in code, text, translations, or documentation. Use a regular hyphen/dash (-) instead.

## Code Standards

- Use the project's formatter/linter (Biome, ESLint, Prettier - whatever is configured)
- Complete code only - no TODOs, no placeholders, no incomplete implementations
- Use Context7 MCP to pull latest docs when working with specific technologies (NestJS, PostgreSQL, Drizzle, etc.) - don't rely on potentially outdated training knowledge
- Default to writing no comments. Prefer readable, explicit code (well-named variables, functions, and types) over commentary. A comment is justified only when it explains a non-obvious WHY: hidden constraint, subtle invariant, workaround for a known bug, or surprising behavior a future reader would otherwise misread. Comments that restate WHAT the code does are forbidden, including multiline narrative blocks. JSDoc/docstring format (`/** */`) is allowed only when its content is WHY - the format alone does not earn an exemption.
- Never reference issue, PR, ticket, or ADR numbers in code comments (no `owner/repo#535`, `PR #561`, `(#545)`, `Fixes #123`, `JIRA-1234`, `ADR-0042`, etc.). They rot as soon as trackers move or decisions are superseded. The PR description, the ADR document itself, and git blame are the right places for that context. Comments should describe the WHY in self-contained prose.
- Detailed standards are in rules/ (typescript, tests, database, infrastructure, security)

## Docs Sync

- Engineering docs live in each repo's `/docs/` tree, organized by [Diataxis](https://diataxis.fr/) (explanation, reference, how-to, tutorials) plus an `adr/` folder for Architecture Decision Records
- When code changes affect behavior documented in `docs/`, update the relevant docs in the same PR
- Use the `/document` slash command to create or refresh docs - it embeds the quality rules and Diataxis routing
- Never let docs drift from implementation - if you change it, document it
- Only update docs that describe behavior actually changed in this session - no forward-looking references, planned features, or speculative content
- Diagrams default to Mermaid (text-based, GitHub-rendered, AI-readable). Use drawio when the diagram needs custom shapes, multi-layer architecture, >2 swimlanes, or precise layout - see `rules/diagrams.md` for the policy and `/diagram` skill for the workflow
- ADRs are immutable once Accepted - a reversed decision creates a new ADR that supersedes the old one

## Behavioral Rules

- **Scope**: only implement what was asked - no drive-by refactors, extra features, or unsolicited improvements
- **Minimal fix**: for bug fixes, identify the root cause and state the smallest possible change first (ideally 1-5 lines). Only expand the scope if the minimal fix is provably insufficient. Never introduce new abstractions, files, or patterns as part of a bug fix unless the user explicitly asks
- **Decisions**: ask before making architectural choices - never silently pick a pattern, library, or approach
- **Cost**: warn before any change that increases costs (new cloud resources, paid services, upgraded tiers)
- **Testing**: always write tests when implementing a new feature or fixing a bug - no exceptions
- **Conciseness**: be direct and terse during implementation - save explanations for when asked
- **Existing patterns**: follow the conventions already in the codebase - consistency over personal preference
- **Context first**: before choosing an approach, check how similar problems are already solved in the codebase - grep for existing patterns, read neighboring files, and follow established conventions rather than guessing
- **Verification**: always run `/user:verify-done` before pushing - never push without all checks passing
- **Atomic feature unit**: "implement" means implement + commit on a feature branch + push + open PR. Never stop after the code change. Never commit to `main`/`master` directly. If on a protected branch, create a feature branch first.
- **Parallelization**: when a task has 2+ independent sub-tasks touching different files, split across multiple agents using git worktrees - see `rules/parallel-agents.md`

Detailed git, testing, and exploration rules are in `rules/` (git-conventions, engineering-principles).

## Learning from Mistakes

- When corrected, update the relevant CLAUDE.md or rule file so the mistake is not repeated
- Check if an existing rule already covers the correction - update it rather than adding a duplicate

## Environment

- macOS, zsh, Node.js (check `.nvmrc`), npm
- Docker for local services
- Cloud: GCP primary, AWS secondary
- Current year: 2026 - verify when generating dates, timestamps, or date-dependent logic
- Access boundaries: .env files, credentials, and secrets are blocked by deny rules - do not attempt workarounds. For Sentry, staging databases, and external services requiring auth, ask the user for credentials or URLs rather than trying to authenticate

@RTK.md
