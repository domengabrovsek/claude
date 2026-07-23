# Claude Code Configuration

Custom configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that turns it into a disciplined engineering partner with structured workflows, strict guardrails, and domain-specific expertise.

Out of the box, Claude Code is capable but generic. This repo adds opinionated defaults: a research -> grill -> build -> ship workflow, security boundaries, code standards, and 16 expert subagents that spawn based on task context. The result is more consistent, reviewable, and safe output.

The whole config is symlinked into `~/.claude/`, so edits to this repo apply to every Claude Code session. It contains global rules (`CLAUDE.md`, `rules/`), automation hooks, slash commands, subagent personas, and reusable workflow skills.

## Quick start

```bash
# Clone the repo - the setup script auto-detects its own location
git clone git@github.com:domengabrovsek/claude.git
cd claude

# Dry-run first to see what would change, then apply
bash scripts/setup-symlinks.sh --check
bash scripts/setup-symlinks.sh

# Strip ephemeral state Claude Code writes to settings.json at runtime
git config filter.strip-ephemeral-state.clean 'jq "del(.feedbackSurveyState)" 2>/dev/null || cat'
git config filter.strip-ephemeral-state.smudge cat
```

Re-runs are safe: existing files are backed up to `<path>.bak.<timestamp>` before being replaced. A `SessionStart` hook warns if a symlink drifts later.

## What's inside

- **`CLAUDE.md`** - core rules loaded every session (workflow, security, code standards). See [ADR 0001](docs/adr/0001-grill-driven-workflow.md).
- **`rules/`** - modular instruction files `@`-imported into `CLAUDE.md`.
- **`agents/`** - expert subagent personas spawned via the Agent tool. Routing in [`rules/agent-routing.md`](rules/agent-routing.md); full list in [`docs/agents.md`](docs/agents.md). See [ADR 0003](docs/adr/0003-agents-via-subagent-spawn.md).
- **`skills/`** - reusable `/<skill>` workflows (`/grill-with-docs`, `/build`, `/ship`, `/debug`, `/prototype`, `/wayfinder`, …). Skills carrying a `> Source:` line are vendored from [mattpocock/skills](https://github.com/mattpocock/skills) and adapted to this repo's conventions (see ADR 0006).
- **`commands/`** - thin slash invocations (`/research`, `/verify-done`, `/worktree`, …).
- **`hooks/`** - shell scripts wired into `settings.json` for `PreToolUse`, `PostToolUse`, `SessionStart`, `SessionEnd` events.
- **`scripts/`** - utilities used by hooks and skills (`setup-symlinks.sh`, `statusline.sh`, `notify.sh`, `worktree-prune.sh`).
- **`docs/adr/`** - Architecture Decision Records.
- **`references/`** - long-form checklists (security, testing) loaded by skills on demand.
- **`templates/`** - boilerplate for new ADRs and docs.

## More

- **Security boundaries** - deny list, Bash restrictions, and lock-file protection live in [`settings.json`](settings.json).
- **CI** - markdown linting on push/PR (`.github/workflows/`).
