# Global Rules

These rules apply to every project. Project-level CLAUDE.md files override where they conflict.

## Workflow: Research → Plan → Implement

### Phase 1: Research

- Read every relevant file before forming opinions — no guessing
- Produce a `research.md` artifact summarizing findings, open questions, and constraints
- Do NOT propose solutions yet

### Phase 2: Plan

- Produce a `plan.md` with: goal, approach, file-by-file changes (with code snippets), task checklist
- Include exact file paths and line ranges for every change
- Flag risks, trade-offs, and alternatives
- Wait for approval before proceeding — say **"don't implement yet"** if tempted

### Phase 3: Annotation Cycle

- User annotates `plan.md` with notes, questions, or corrections
- Address every annotation, update the plan, and re-present
- Repeat until user explicitly approves — do NOT skip ahead to implementation
- This phase may take multiple rounds; that is expected

### Phase 4: Implement

- Execute the approved plan task by task, marking each done in `plan.md`
- Do not stop mid-implementation to ask questions already answered in the plan
- Run typecheck continuously as you go (`npx tsc --noEmit` or project equivalent)
- After all tasks: build + lint + test must pass before declaring done

### Skipping Phases

For trivial changes (typos, one-liner fixes, config tweaks): skip straight to implementation. If in doubt, ask.

## Security

- NEVER read or process files containing secrets, credentials, API keys, or private keys
- Sensitive file patterns: `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json`
- Home directory secrets (`~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube`) are off-limits
- If you need config values for debugging, ask the user to provide only the non-sensitive parts

## Code Standards

- TypeScript: no `any` or `unknown` — use proper types. 2-space indent, single quotes
- Use the project's formatter/linter (Biome, ESLint, Prettier — whatever is configured)
- Zod schemas for runtime validation at system boundaries
- Database: soft delete only, explicit migrations only — never auto-sync schemas
- Tests: Vitest preferred, mock external deps, manual class instantiation over DI in tests
- Complete code only — no TODOs, no placeholders, no incomplete implementations

## Behavioral Rules

- **Scope**: only implement what was asked — no drive-by refactors, extra features, or unsolicited improvements
- **Decisions**: ask before making architectural choices — never silently pick a pattern, library, or approach
- **Cost**: warn before any change that increases costs (new cloud resources, paid services, upgraded tiers)
- **Git**: never auto-commit or push — wait for explicit instructions
- **Verification**: build + typecheck + lint + tests must all pass before considering work done
- **Conciseness**: be direct and terse during implementation — save explanations for when asked
- **Existing patterns**: follow the conventions already in the codebase — consistency over personal preference

## Learning from Mistakes

- When corrected by the user, update the relevant CLAUDE.md (global or project-level) so the mistake is not repeated
- Before updating, check if an existing rule already covers the correction — update it rather than adding a duplicate
- Corrections to general behavior go in this global file; project-specific corrections go in the project's CLAUDE.md

## Environment

- macOS, zsh, Node.js (check `.nvmrc`), npm
- Docker for local services
- Cloud: GCP primary, AWS secondary
- Git + GitHub for version control and CI/CD
