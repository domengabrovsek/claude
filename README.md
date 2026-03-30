# Claude Code Configuration

Custom configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that turns it into a disciplined engineering partner with structured workflows, strict guardrails, and domain-specific expertise.

## Why

Out of the box, Claude Code is capable but generic. This configuration adds opinionated defaults - a mandatory research-plan-implement workflow, security boundaries, code standards, and 15 expert agents that activate automatically based on task context. The result is more consistent, reviewable, and safe output.

## Repository Structure

```text
CLAUDE.md                      # Core rules (workflow, security, behavioral constraints)
agents/                        # 15 expert agent personas
commands/                      # Slash commands for frequent workflows
hooks/                         # Automation scripts (formatting, PR watching)
rules/                         # Modular instruction files (always-loaded + path-scoped)
skills/                        # Reusable workflows with supporting files
docs/                          # Reference documentation
pull_request_template.md       # Default PR template
.github/workflows/             # CI (markdown linting)
```

## Setup

Symlink the repo contents to `~/.claude/` so changes auto-sync:

```bash
# Clone the repo
git clone git@github.com:domengabrovsek/claude.git ~/dev/claude

# Symlink to ~/.claude/
ln -sf ~/dev/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dev/claude/agents ~/.claude/agents
ln -sf ~/dev/claude/rules ~/.claude/rules
ln -sf ~/dev/claude/skills ~/.claude/skills
ln -sf ~/dev/claude/commands ~/.claude/commands
ln -sf ~/dev/claude/hooks ~/.claude/hooks
```

## Components

### CLAUDE.md

Core rules loaded every session (~50 lines). Kept lean - detailed standards live in `rules/`.

- 5-phase workflow: Research - Plan - Annotate - Implement - Summarize
- Security boundaries
- Behavioral constraints (scope discipline, verification gates)

### Rules (`rules/`)

Modular instruction files. **Always-loaded** rules have no frontmatter. **Path-scoped** rules use `globs:` frontmatter and only load when editing matching files, saving tokens.

| Rule | Scope | Loads when... |
| --- | --- | --- |
| `agent-routing.md` | Always | Every session (agent selection table) |
| `git-conventions.md` | Always | Every session (commits, PRs, semver) |
| `file-naming.md` | Always | Every session (timestamp convention) |
| `state-persistence.md` | Always | Every session (artifact saving) |
| `typescript.md` | `**/*.ts,**/*.tsx` | Editing TypeScript files |
| `tests.md` | `**/*.test.ts,**/*.spec.ts` | Editing test files |
| `database.md` | `**/migrations/**,**/*.sql` | Editing database/migration files |
| `infrastructure.md` | `**/Dockerfile,**/*.tf` | Editing infrastructure files |

### Agents (`agents/`)

15 expert agent personas across 5 categories. Each follows a 9-section structure with strict guardrails, review checklists, and red-flag detection. Loaded automatically via the routing table in `rules/agent-routing.md`.

See [Agent Reference](docs/agents.md) for the full listing.

### Skills (`skills/`)

Reusable workflows invoked on-demand. Cost ~200 tokens when idle (metadata only) vs. full cost if in CLAUDE.md.

| Skill | Trigger | Purpose |
| --- | --- | --- |
| `fix-issue` | `/fix-issue 1234` | Full issue resolution: fetch, research, plan, implement, test, PR |
| `review-pr` | `/review-pr 567` | Structured PR review with BLOCKER/ISSUE/SUGGESTION/NIT/PRAISE severity |

### Commands (`commands/`)

Slash commands for frequent workflows. Available as `/user:<name>`.

| Command | Trigger | Purpose |
| --- | --- | --- |
| `research` | `/user:research <topic>` | Phase 1: explore codebase, save findings to `.claude/state/research/` |
| `plan` | `/user:plan` | Phase 2: create implementation plan, save to `.claude/state/plans/` |
| `summarize` | `/user:summarize` | Save session diary to `.claude/state/sessions/` |
| `typecheck` | `/user:typecheck` | Run tsc and fix all type errors |
| `ci-check` | `/user:ci-check` | Run local CI checks (lint + typecheck + test + build) |
| `verify-done` | `/user:verify-done` | Full quality gate before declaring work done |

### Hooks (`hooks/`)

Automation scripts triggered at lifecycle events. Configured in `~/.claude/settings.json`.

| Hook | Event | Purpose |
| --- | --- | --- |
| `auto-format.sh` | PostToolUse (Write/Edit) | Auto-format files with project formatter (Biome/Prettier) |
| `watch-pr-checks.sh` | PostToolUse (gh pr create) | Poll CI checks in background, notify on pass/fail |
| Notification | Notification | macOS desktop notification when Claude needs input |
| Compact reminder | SessionStart (compact) | Re-inject workflow context after compaction |

### State (`.claude/state/` per project)

Session artifacts saved at the project level so they persist across sessions and machines.

```text
.claude/state/
  research/    # Research artifacts from Phase 1
  plans/       # Implementation plans from Phase 2
  sessions/    # Session diary entries from Phase 5
```

## Security

- Comprehensive deny list in `settings.json` blocking 35+ sensitive file patterns
- Bash command restrictions blocking destructive operations (`rm -rf`, `git push --force`, `sudo`)
- PostToolUse formatting hook validates files before processing
- Agent guardrails enforce security checks across all domains

## CI

Markdown linting runs on every push and PR via GitHub Actions.

## Documentation

- [Agent Reference](docs/agents.md) - full agent listing and structure
- [Configuration Guide](docs/configuration.md) - detailed walkthrough of all settings
