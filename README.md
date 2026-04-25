# Claude Code Configuration

Custom configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that turns it into a disciplined engineering partner with structured workflows, strict guardrails, and domain-specific expertise.

## Why

Out of the box, Claude Code is capable but generic. This configuration adds opinionated defaults - a mandatory research-plan-implement workflow, security boundaries, code standards, and 16 expert agents that activate automatically based on task context. The result is more consistent, reviewable, and safe output.

## Repository Structure

```text
CLAUDE.md                      # Core rules (workflow, security, behavioral constraints)
settings.json                  # Global settings (hooks, deny list, permissions)
agents/                        # 16 expert agent personas
commands/                      # Slash commands for frequent workflows
hooks/                         # Automation scripts (formatting, typechecking)
rules/                         # Modular instruction files (always-loaded + path-scoped)
scripts/                       # Utility scripts (notifications)
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
ln -sf ~/dev/claude/scripts ~/.claude/scripts
ln -sf ~/dev/claude/settings.json ~/.claude/settings.json
ln -sf ~/dev/claude/RTK.md ~/.claude/RTK.md
ln -sf ~/dev/claude/scripts/statusline.sh ~/.claude/statusline.sh

# Configure smudge/clean filter to strip ephemeral state from settings.json
git config filter.strip-ephemeral-state.clean 'jq "del(.feedbackSurveyState)" 2>/dev/null || cat'
git config filter.strip-ephemeral-state.smudge cat
```

> **Note**: Claude Code writes ephemeral state (e.g. `feedbackSurveyState`) to `settings.json` at runtime. The smudge/clean filter in `.gitattributes` automatically strips this before git sees it, so `git status` stays clean.

## RTK (Token Optimization)

[RTK](https://github.com/rtk-ai/rtk) is a CLI proxy written in Rust that sits between Claude Code and the shell. It intercepts common commands (`git status`, `npm test`, `grep`, `docker`, etc.), strips noise the model doesn't need (passing tests, progress bars, ASCII borders), and returns a compressed version. Reported savings are 60-90% tokens on typical dev operations, which translates to more exchanges per session before hitting rate limits.

The integration lives in this repo:

- `RTK.md` - meta-command reference, imported into every session via `@RTK.md` in `CLAUDE.md`
- `rtk/config.toml` - tracked config with tee mode on (`failures`), telemetry off, default exclusions
- `settings.json` - `PreToolUse` Bash hook that rewrites commands transparently

### Installing RTK

```bash
# Install the binary and initialize the Claude Code hook
brew install rtk
rtk init -g --hook-only   # hook-only: the repo provides RTK.md

# Symlink the tracked config (macOS)
mkdir -p ~/Library/Application\ Support/rtk
ln -sf ~/dev/claude/rtk/config.toml ~/Library/Application\ Support/rtk/config.toml

# Verify
rtk --version
rtk config          # should print the symlinked config
rtk gain            # token savings analytics
```

### Safety note

RTK filters what the model sees. During complex debugging (e.g. correlating timeouts across services), compression can hide patterns that matter. Two mitigations are configured:

- **Tee mode** (`failures`) preserves the full unfiltered output whenever a command fails, so raw data is always recoverable.
- **`exclude_commands`** in `rtk/config.toml` lets you bypass filtering for specific commands when raw output is non-negotiable (prod DB sessions, incident log tailing).

Use `rtk proxy <cmd>` for a one-shot unfiltered run without editing config.

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
| `engineering-principles.md` | Always | Every session (sizing, slicing, exploration) |
| `state-persistence.md` | Always | Every session (artifact saving, naming) |
| `typescript.md` | `**/*.ts,**/*.tsx` | Editing TypeScript files |
| `tests.md` | `**/*.test.ts,**/*.spec.ts` | Editing test files |
| `database.md` | `**/migrations/**,**/*.sql` | Editing database/migration files |
| `infrastructure.md` | `**/Dockerfile,**/*.tf` | Editing infrastructure files |

### Agents (`agents/`)

16 expert agent personas across 5 categories. Each follows a 9-section structure with strict guardrails, review checklists, and red-flag detection. Loaded automatically via the routing table in `rules/agent-routing.md`.

See [Agent Reference](docs/agents.md) for the full listing.

### Skills (`skills/`)

Reusable workflows invoked on-demand. Cost ~200 tokens when idle (metadata only) vs. full cost if in CLAUDE.md.

| Skill | Trigger | Purpose |
| --- | --- | --- |
| `spec` | `/spec <topic>` | Define requirements before planning |
| `build` | `/build` | Implement approved plan incrementally with quality gates |
| `test` | `/test <target>` | Write tests using TDD (RED-GREEN-REFACTOR) or prove-it pattern |
| `ship` | `/ship` | Pre-launch validation and release workflow |
| `fix-issue` | `/fix-issue 1234` | Full issue resolution: fetch, research, plan, implement, test, PR |
| `review-pr` | `/review-pr 567` | Structured PR review with BLOCKER/ISSUE/SUGGESTION/NIT/PRAISE severity |
| `ci` | `/ci` | Monitor CI pipeline status, analyze failures, propose fixes. Use with `/loop 2m /ci` for auto-polling |
| `mr` | `/mr` | Create MR/PR with template, conventional commit checks, and stacked MR/PR dependency support |
| `debug` | `/debug <error\|alert>` | Structured incident investigation: evidence, ranked hypotheses, minimal fix, regression test |

### Commands (`commands/`)

Slash commands for frequent workflows. Available as `/user:<name>`.

| Command | Trigger | Purpose |
| --- | --- | --- |
| `research` | `/user:research <topic>` | Phase 1: explore codebase, save findings to `.claude/state/research/` |
| `plan` | `/user:plan` | Phase 2: create implementation plan, save to `.claude/state/plans/` |
| `summarize` | `/user:summarize` | Save session diary to `.claude/state/sessions/` |
| `typecheck` | `/user:typecheck` | Run tsc and fix all type errors |
| `verify-done` | `/user:verify-done` | Full quality gate before declaring work done (lint + typecheck + test + build + git status) |
| `locks` | `/user:locks [--prune\|--release <hash>]` | List active Claude session locks across repos; prune stale; force-release |

### Hooks (`hooks/`)

Automation scripts triggered at lifecycle events. Configured in `settings.json` (symlinked to `~/.claude/settings.json`).

| Hook | Event | Purpose |
| --- | --- | --- |
| `pre-pr-test-gate.sh` | PreToolUse (gh pr create) | Block PR creation if tests fail |
| `pre-push-gate.sh` | PreToolUse (git push) | Hard-block `git push` if lint/typecheck/test/build fail. Bypass with `SKIP_PUSH_GATE=1` |
| `repo-lock-status.sh` | SessionStart (startup\|resume) | Claim the repo lock for this session (or notice if held by another live session). Advisory, never blocks. |
| `repo-lock-heartbeat.sh` | PostToolUse (Write\|Edit\|Bash) | Refresh lock `last_seen` so the session stays alive. Throttled to 60s via lock mtime. Never blocks. |
| `repo-lock-release.sh` | SessionEnd | Release the repo lock if owned by this session. Idempotent. |
| `repo-lock-guard.sh` | PreToolUse (Write\|Edit\|Bash mutations) | Hard-block mutations when another live session holds the lock and current session is not in a worktree. Bypass with `SKIP_LOCK=1`. |
| `auto-format.sh` | PostToolUse (Write/Edit) | Auto-format files with project formatter (Biome/Prettier) |
| `post-edit-typecheck.sh` | PostToolUse (Write/Edit) | Run typecheck and lint on .ts/.tsx files after edits |
| `watch-pr-checks.sh` | PostToolUse (gh pr create) | Poll CI checks in background, notify on pass/fail |
| Notification | Notification | macOS desktop notification when Claude needs input |
| Compact reminder | SessionStart (compact) | Re-inject workflow context after compaction |

### Scripts (`scripts/`)

Utility scripts referenced by skills and hooks.

| Script | Purpose |
| --- | --- |
| `notify.sh` | Send macOS desktop notification unless a terminal or IDE is in the foreground |
| `statusline.sh` | Status line showing model, repo, branch, and node version. Symlink to `~/.claude/statusline.sh` |
| `repo-lock.sh` | Repo lock manager. `claim/release/check/list/prune` against `~/.claude/locks/<sha1>.json`. Used by isolation hooks. |

### State (`.claude/state/` per project)

Session artifacts saved at the project level so they persist across sessions and machines.

```text
.claude/state/
  research/    # Research artifacts from Phase 1
  specs/       # Specification documents from /spec
  plans/       # Implementation plans from Phase 2
  sessions/    # Session diary entries from Phase 5
```

## Security

- Comprehensive deny list in `settings.json` blocking 35+ sensitive file patterns (env files, SSH/GPG keys, credentials, cloud configs, shell history)
- Bash command restrictions blocking destructive operations (`rm -rf`, `git push --force`, `sudo`, `DROP TABLE`)
- Lock file protection prevents edits to `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- PreToolUse gate blocks PR creation when tests fail
- PostToolUse formatting hook validates files before processing
- Agent guardrails enforce security checks across all domains

## CI

Markdown linting runs on every push and PR via GitHub Actions.

## Documentation

- [Agent Reference](docs/agents.md) - full agent listing and structure
