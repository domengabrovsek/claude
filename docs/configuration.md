# Configuration Guide

## CLAUDE.md

[`CLAUDE.md`](../CLAUDE.md) defines the core rules loaded every session. Kept intentionally lean (~50 lines) - detailed standards live in `rules/` to save tokens.

### Workflow: Research - Plan - Implement - Summarize

Every non-trivial task follows a 5-phase workflow:

1. **Research** - read all relevant files, produce a research artifact. Save to `.claude/state/research/`. No solutions yet.
2. **Plan** - produce a detailed plan with goal, approach, file-by-file changes, and task checklist. Save to `.claude/state/plans/`. Wait for approval.
3. **Annotate** - user annotates the plan. Address every annotation and re-present. Repeat until explicit approval.
4. **Implement** - execute the approved plan task by task. Run typecheck continuously. Build + lint + test must pass before done.
5. **Summarize** - save a session diary entry to `.claude/state/sessions/`.

Trivial changes (typos, one-liner fixes, config tweaks) can skip straight to implementation.

### Security

- Never read or process files containing secrets, credentials, API keys, or private keys
- Sensitive file patterns: `.env*`, `*.pem`, `*.key`, `credentials.json`, `service-account*.json`
- Home directory secrets (`~/.aws`, `~/.ssh`, `~/.config/gcloud`, `~/.kube`) are off-limits
- Ask the user to provide only non-sensitive parts when needed for debugging

### Code Standards

Detailed standards live in path-scoped rule files that only load when relevant:

- [`rules/typescript.md`](../rules/typescript.md) - TypeScript conventions (loads for `**/*.ts,**/*.tsx`)
- [`rules/tests.md`](../rules/tests.md) - testing standards (loads for `**/*.test.ts,**/*.spec.ts`)
- [`rules/database.md`](../rules/database.md) - database conventions (loads for `**/migrations/**,**/*.sql`)
- [`rules/infrastructure.md`](../rules/infrastructure.md) - infra standards (loads for `**/Dockerfile,**/*.tf`)

### Behavioral Rules

- **Scope** - only implement what was asked, no drive-by refactors or unsolicited improvements
- **Decisions** - ask before making architectural choices
- **Cost** - warn before any change that increases costs
- **Verification** - build + typecheck + lint + tests must all pass before considering work done
- **Existing patterns** - follow codebase conventions over personal preference

## Rules (`rules/`)

Modular instruction files split by concern. Two types:

### Always-loaded (no frontmatter)

These load every session alongside CLAUDE.md:

- [`agent-routing.md`](../rules/agent-routing.md) - agent selection table and loading rules
- [`git-conventions.md`](../rules/git-conventions.md) - conventional commits, semver, PR templates, `gh` CLI
- [`file-naming.md`](../rules/file-naming.md) - `YYYY-MM-DD-descriptive-name.md` convention
- [`state-persistence.md`](../rules/state-persistence.md) - artifact saving to `.claude/state/`

### Path-scoped (with `globs:` frontmatter)

These only load when Claude works on matching files, saving tokens:

- [`typescript.md`](../rules/typescript.md) - loads for `**/*.ts,**/*.tsx`
- [`tests.md`](../rules/tests.md) - loads for `**/*.test.ts,**/*.spec.ts`
- [`database.md`](../rules/database.md) - loads for `**/migrations/**,**/*.sql,**/prisma/**`
- [`infrastructure.md`](../rules/infrastructure.md) - loads for `**/Dockerfile,**/*.tf,**/.github/workflows/**`

## Skills (`skills/`)

Reusable workflows with supporting files. Auto-invoked when Claude recognizes a matching task, or triggered manually via slash command. Cost ~200 tokens when idle (metadata only).

### fix-issue

**Trigger:** `/fix-issue 1234`

Full issue resolution workflow: fetch issue details, research codebase, reproduce with failing test, propose fix plan, implement, test, commit, create PR. Saves research and plans to `.claude/state/`.

### review-pr

**Trigger:** `/review-pr 567`

Structured PR review using the pr-reviewer agent methodology. Outputs findings as BLOCKER > ISSUE > SUGGESTION > NIT > PRAISE with a verdict. Includes a detailed [checklist](../skills/review-pr/checklist.md) covering correctness, type safety, security, GDPR/privacy, database, testing, performance, code quality, and scope.

## Commands (`commands/`)

Slash commands for frequent workflows. Available as `/user:<name>`.

| Command | Purpose |
| --- | --- |
| [`research`](../commands/research.md) | Start Phase 1 - explore codebase, save to `.claude/state/research/` |
| [`plan`](../commands/plan.md) | Start Phase 2 - create implementation plan, save to `.claude/state/plans/` |
| [`summarize`](../commands/summarize.md) | Save session diary to `.claude/state/sessions/` |
| [`typecheck`](../commands/typecheck.md) | Run tsc and fix all type errors iteratively |
| [`ci-check`](../commands/ci-check.md) | Run local CI checks (lint + typecheck + test + build) |
| [`verify-done`](../commands/verify-done.md) | Full quality gate before declaring work done |

## Hooks (`hooks/`)

Automation scripts triggered at lifecycle events. Configured in `~/.claude/settings.json` (not in repo - personal config).

### auto-format.sh

**Event:** PostToolUse (Write|Edit)

Automatically formats files after Claude edits them. Detects the project's formatter (Biome > Prettier > fallback) and validates the file exists and is text before formatting. Timeout: 30 seconds.

### watch-pr-checks.sh

**Event:** PostToolUse (Bash, when `gh pr create` runs)

Spawns in the background after PR creation. Polls `gh pr checks` every 30 seconds and sends a macOS notification with sound when checks pass (Glass) or fail (Basso). Times out after 30 minutes.

### Other hooks (in settings.json)

- **Notification** (permission_prompt|idle_prompt) - macOS desktop notification when Claude needs input
- **SessionStart** (compact) - re-injects workflow reminder after context compaction
- **Stop** - safe no-op hook (placeholder for future task verification)

## Settings (`~/.claude/settings.json`)

Not in the repo (contains personal config). Key sections:

### Permissions deny list

35+ patterns blocking reads/edits/writes of sensitive files:

- Environment files (`.env*`)
- SSH/GPG keys (`~/.ssh/**`, `~/.gnupg/**`)
- Cloud credentials (`~/.aws/**`, `~/.config/gcloud/**`, `~/.kube/**`, `~/.azure/**`)
- Terraform state (`**/.terraform.tfstate*`, `~/.terraformrc`)
- Package manager tokens (`~/.npmrc`, `~/.yarnrc.yml`, `~/.pnpmrc`)
- Git credentials (`~/.git-credentials`, `~/.gitconfig`)
- Shell history (`~/.zsh_history`, `~/.bash_history`)
- IDE secrets (`~/.config/Code/User/globalStorage/**`)
- Certificates and keys (`*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`)

### Bash command restrictions

Blocked destructive commands: `rm -rf`, `sudo`, `dd`, `mkfs`, `shred`, `git push --force`, `git reset --hard`, `git clean -f`, `chmod` on sensitive directories.

## State (`.claude/state/`)

Session artifacts saved at the project level (not global). Created on demand in each project's `.claude/` directory.

```text
.claude/state/
  research/    # Research artifacts from Phase 1
  plans/       # Implementation plans from Phase 2
  sessions/    # Session diary entries from Phase 5
```

Naming convention: `YYYY-MM-DD-descriptive-name.md`

## Expert Agents

Claude loads expert agents automatically based on task context via the routing table in [`rules/agent-routing.md`](../rules/agent-routing.md).

Key rules:

- Always load agents before the research phase
- Load multiple agents when a task crosses domains
- Feature planning always includes the product-manager agent
- UI work always includes frontend + ux + qa agents
- EU data handling always includes the gdpr agent
- Guardrails from all loaded agents apply simultaneously
- Skip agent loading for trivial changes

See [Agent Reference](agents.md) for the full list and structure.

## Environment

- macOS, zsh, Node.js (check `.nvmrc`), npm
- Docker for local services
- Cloud: GCP primary, AWS secondary
- Git + GitHub for version control and CI/CD
- `gh` CLI for all GitHub operations
