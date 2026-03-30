# Global Rules

These rules apply to every project. Project-level CLAUDE.md files override where they conflict.

## Workflow: Research - Plan - Implement

1. **Research**: read every relevant file, produce a research artifact with findings and open questions. No solutions yet.
2. **Plan**: produce a plan with goal, approach, file-by-file changes (with code snippets), task checklist. Include exact paths and line ranges. Flag risks. Wait for approval.
3. **Annotate**: user annotates the plan. Address every annotation, re-present. Repeat until explicit approval.
4. **Implement**: execute the approved plan task by task. Run typecheck continuously. Build + lint + test must pass before done.

For trivial changes (typos, one-liner fixes, config tweaks): skip straight to implementation. If in doubt, ask.

## Security

- NEVER read or process files containing secrets, credentials, API keys, or private keys
- Sensitive file patterns: `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json`
- Home directory secrets (`~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube`) are off-limits
- If you need config values for debugging, ask the user to provide only the non-sensitive parts

## Formatting

- Never use em dashes (-) anywhere - in code, text, translations, or documentation. Use a regular hyphen/dash (-) instead.

## Code Standards

- TypeScript: no `any` or `unknown` - use proper types. 2-space indent, single quotes
- Use the project's formatter/linter (Biome, ESLint, Prettier - whatever is configured)
- Zod schemas for runtime validation at system boundaries
- Database: soft delete only, explicit migrations only - never auto-sync schemas
- Tests: Vitest preferred, mock external deps, manual class instantiation over DI in tests
- Complete code only - no TODOs, no placeholders, no incomplete implementations

## Behavioral Rules

- **Scope**: only implement what was asked - no drive-by refactors, extra features, or unsolicited improvements
- **Decisions**: ask before making architectural choices - never silently pick a pattern, library, or approach
- **Cost**: warn before any change that increases costs (new cloud resources, paid services, upgraded tiers)
- **Verification**: build + typecheck + lint + tests must all pass before considering work done
- **Conciseness**: be direct and terse during implementation - save explanations for when asked
- **Existing patterns**: follow the conventions already in the codebase - consistency over personal preference

## Learning from Mistakes

- When corrected, update the relevant CLAUDE.md or rule file so the mistake is not repeated
- Check if an existing rule already covers the correction - update it rather than adding a duplicate

## Environment

- macOS, zsh, Node.js (check `.nvmrc`), npm
- Docker for local services
- Cloud: GCP primary, AWS secondary
