# Global Rules

These rules apply to every project. Project-level CLAUDE.md files override where they conflict.

## Workflow: Research - Plan - Implement

1. **Research**: read every relevant file, produce a research artifact. Save to `.claude/state/research/`. No solutions yet.
2. **Plan**: produce a plan with goal, approach, file-by-file changes, task checklist. Save to `.claude/state/plans/`. Wait for approval.
3. **Annotate**: user annotates the plan. Address every annotation, re-present. Repeat until explicit approval.
4. **Implement**: execute the approved plan task by task. Run typecheck continuously. Build + lint + test must pass before done.
5. **Summarize**: save a session diary entry to `.claude/state/sessions/` when work is complete.

For trivial changes (typos, one-liner fixes, config tweaks): skip straight to implementation. If in doubt, ask.

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
- Detailed standards are in rules/ (typescript, tests, database, infrastructure, security)

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
