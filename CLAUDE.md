# Global Rules

These rules apply to every project. Project-level CLAUDE.md files override where they conflict.

## Workflow: Research - Plan - Implement

1. **Research**: read every relevant file, produce a research artifact. Save to `.claude/state/research/`. No solutions yet.
2. **Plan**: produce a plan with goal, approach, file-by-file changes, task checklist. Save to `.claude/state/plans/`. Wait for approval.
3. **Annotate**: user annotates the plan. Address every annotation, re-present. Repeat until explicit approval.
4. **Implement**: execute the approved plan task by task. Run typecheck continuously. Build + lint + test must pass before done.
5. **Summarize**: save a session diary entry to `.claude/state/sessions/` when work is complete.

For trivial changes (typos, one-liner fixes, config tweaks): skip straight to implementation. If in doubt about whether something is trivial, it is not - follow the full workflow.

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
- Never reference issue, PR, or ticket numbers in code comments (no `owner/repo#535`, `PR #561`, `(#545)`, `Fixes #123`, `JIRA-1234`, etc.). They rot as soon as trackers move, and the PR description or git blame is the right place for that context. Comments should describe the WHY in self-contained prose.
- Detailed standards are in rules/ (typescript, tests, database, infrastructure, security)

## Docs Sync

- Engineering docs live in each repo's `/docs/` tree, organized by [Diataxis](https://diataxis.fr/) (explanation, reference, how-to, tutorials) plus an `adr/` folder for Architecture Decision Records
- When code changes affect behavior documented in `docs/`, update the relevant docs in the same PR
- Use the `/document` slash command to create or refresh docs - it embeds the quality rules and Diataxis routing
- Never let docs drift from implementation - if you change it, document it
- Only update docs that describe behavior actually changed in this session - no forward-looking references, planned features, or speculative content
- Diagrams are Mermaid only (text-based, GitHub-rendered, AI-readable). No draw.io, no PNGs
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
- **Cross-session isolation**: before non-trivial work, isolate this session in a git worktree to avoid colliding with other Claude sessions on the same repo. See `rules/isolation.md`. The `/user:worktree <slug>` command does this. The PreToolUse guard will block mutations if another live session holds the lock and you are not in a worktree.

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
