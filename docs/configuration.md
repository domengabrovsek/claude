# Configuration Guide

[`CLAUDE.md`](../CLAUDE.md) defines the global rules that apply across all projects. Project-level `CLAUDE.md` files can override where they conflict.

## Workflow: Research - Plan - Implement

Every non-trivial task follows a strict 4-phase workflow:

1. **Research** - read all relevant files, produce a research artifact with findings and open questions. No solutions yet.
2. **Plan** - produce a detailed plan with goal, approach, file-by-file changes (with code snippets), and a task checklist. Wait for approval.
3. **Annotation Cycle** - the user annotates the plan with notes, questions, or corrections. Address every annotation and re-present. Repeat until explicit approval.
4. **Implement** - execute the approved plan task by task. Run typecheck continuously. Build + lint + test must pass before done.

Trivial changes (typos, one-liner fixes, config tweaks) can skip straight to implementation.

Research and plan files use the naming convention `YYYY-MM-DD-descriptive-name.md`.

## Security

- Never read or process files containing secrets, credentials, API keys, or private keys
- Sensitive file patterns: `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json`
- Home directory secrets (`~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube`) are off-limits
- Ask the user to provide only non-sensitive parts when needed for debugging

## Code Standards

- TypeScript: no `any` or `unknown` - use proper types. 2-space indent, single quotes
- Use the project's formatter/linter (Biome, ESLint, Prettier - whatever is configured)
- Zod schemas for runtime validation at system boundaries
- Database: soft delete only, explicit migrations only - never auto-sync schemas
- Tests: Vitest preferred, mock external deps, manual class instantiation over DI in tests
- Complete code only - no TODOs, no placeholders, no incomplete implementations

## Behavioral Rules

- **Scope** - only implement what was asked, no drive-by refactors or unsolicited improvements
- **Decisions** - ask before making architectural choices
- **Cost** - warn before any change that increases costs
- **Git** - never auto-commit or push, use conventional commits, follow semver
- **PR descriptions** - bullet points in the summary, use the repo's PR template if available
- **Verification** - build + typecheck + lint + tests must all pass before considering work done
- **Existing patterns** - follow codebase conventions over personal preference

## Expert Agents

Claude Code automatically loads expert agents based on task context. The routing table in `CLAUDE.md` maps domain triggers (e.g., "React, components, CSS") to agent files (e.g., `frontend-staff-engineer.md`).

Key rules:

- Always load agents before the research phase
- Load multiple agents when a task crosses domains
- Feature planning always includes the product-manager agent
- UI work always includes frontend + ux + qa agents
- EU data handling always includes the gdpr agent
- Guardrails from all loaded agents apply simultaneously

See [Agent Reference](agents.md) for the full list and structure.

## Learning from Mistakes

When corrected by the user, the relevant `CLAUDE.md` is updated so the mistake is not repeated. Global corrections go in the global file; project-specific corrections go in the project's `CLAUDE.md`.

## Environment

- macOS, zsh, Node.js (check `.nvmrc`), npm
- Docker for local services
- Cloud: GCP primary, AWS secondary
- Git + GitHub for version control and CI/CD
- `gh` CLI for all GitHub operations
