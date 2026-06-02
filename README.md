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

# Bootstrap the symlinks (idempotent, safe to re-run, dry-run via --check)
bash ~/dev/claude/scripts/setup-symlinks.sh

# Configure smudge/clean filter to strip ephemeral state from settings.json
cd ~/dev/claude
git config filter.strip-ephemeral-state.clean 'jq "del(.feedbackSurveyState)" 2>/dev/null || cat'
git config filter.strip-ephemeral-state.smudge cat
```

The setup script handles all 9 expected symlinks (CLAUDE.md, RTK.md, settings.json, agents, commands, hooks, rules, skills, statusline.sh). If something already exists at one of those paths:

- Correctly symlinked already -> skipped.
- Symlinked to a wrong target -> the wrong link is removed and replaced.
- A real file or directory -> backed up to `<path>.bak.<timestamp>` before being replaced. Your local-only content is preserved next to the new symlink for you to inspect.

Run `bash ~/dev/claude/scripts/setup-symlinks.sh --check` first if you want a dry-run showing exactly what each step would do.

Once the symlinks are in place, the `symlink-check.sh` SessionStart hook (in `hooks/`) will warn on stderr if any of them drift later.

**Note**: Claude Code writes ephemeral state (e.g. `feedbackSurveyState`) to `settings.json` at runtime. The smudge/clean filter in `.gitattributes` automatically strips this before git sees it, so `git status` stays clean.

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

Each top-level directory is the canonical source for what it contains. Edit the source files; this README only points.

- **`CLAUDE.md`** - core rules loaded every session: priority order, workflow, security boundaries, code standards, behavioral constraints. See [ADR 0001](docs/adr/0001-grill-driven-workflow.md) for the workflow rationale.
- **`rules/`** - 13 modular rule files (agent-routing, communication, context7, database, diagrams, engineering-principles, git-conventions, infrastructure, jira, parallel-agents, state-persistence, tests, typescript). All `@`-imported into `CLAUDE.md` so they load in every session.
- **`agents/`** - 16 expert subagent personas (Staff Engineer, PR Reviewer, PostgreSQL Expert, ...). Spawned via the Agent tool; routing in [`rules/agent-routing.md`](rules/agent-routing.md). Full grouped listing in [`docs/agents.md`](docs/agents.md). See [ADR 0003](docs/adr/0003-agents-via-subagent-spawn.md) for the loading model.
- **`skills/`** - reusable workflows invoked as `/<skill>` (`/grill-with-docs`, `/build`, `/ship`, `/debug`, ...). Each lives in `skills/<name>/SKILL.md`. Skills marked `(mattpocock)` in their description are vendored from [mattpocock/skills](https://github.com/mattpocock/skills) and may diverge from upstream.
- **`commands/`** - thin slash invocations for one-shot operations: `/research`, `/summarize`, `/verify-done`, `/worktree`, `/worktree-merge`, `/worktrees`. Anything more substantive than a thin invocation belongs in `skills/`.
- **`hooks/`** - shell scripts wired into `settings.json` for `PreToolUse`, `PostToolUse`, `SessionStart`, `SessionEnd` events (pre-pr-test-gate, pre-push-gate, pre-commit-branch-gate, auto-format, post-edit-typecheck, post-edit-lint, watch-pr-checks, worktree-cleanup, symlink-check).
- **`scripts/`** - utilities referenced by hooks and skills: `setup-symlinks.sh` (bootstrap), `statusline.sh`, `notify.sh`, `worktree-prune.sh`.
- **`docs/adr/`** - Architecture Decision Records.
- **`references/`** - longer-form checklists (security, testing patterns) referenced by skills and agents.
- **`templates/`** - boilerplate for new ADRs and docs.

For a quick "is there a slash for X?" lookup, see [CHEATSHEET.md](CHEATSHEET.md).

Per-project session state (not in this repo) lives under each consuming project's `.claude/state/{research,specs,plans,sessions}/`. Conventions in [`rules/state-persistence.md`](rules/state-persistence.md).

## Security

- Comprehensive deny list in `settings.json` blocking 35+ sensitive file patterns (env files, SSH/GPG keys, credentials, cloud configs, shell history)
- Bash command restrictions blocking destructive operations (`rm -rf`, `git push --force`, `sudo`, `DROP TABLE`)
- Lock file protection prevents edits to `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- PreToolUse gate blocks PR creation when tests fail
- PostToolUse formatting hook validates files before processing
- Agent guardrails enforce security checks across all domains

## CI

Markdown linting runs on every push and PR via GitHub Actions.
