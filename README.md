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

### CLAUDE.md

Core rules loaded every session (~50 lines). Kept lean - detailed standards live in `rules/`.

- 4-phase workflow: Research (optional) - Grill - Implement - Summarize. See [ADR 0001](docs/adr/0001-grill-driven-workflow.md) for the rationale and the priority order (`quality > consistent > efficient > fast`)
- Security boundaries
- Behavioral constraints (scope discipline, verification gates)

### Rules (`rules/`)

Modular instruction files. **Always-loaded** rules have no frontmatter. **Path-scoped** rules use `globs:` frontmatter and only load when editing matching files, saving tokens.

| Rule | Scope | Loads when... |
| --- | --- | --- |
| `agent-routing.md` | Always | Every session (subagent_type lookup + cross-domain combinations) |
| `git-conventions.md` | Always | Every session (commits, PRs, semver) |
| `engineering-principles.md` | Always | Every session (sizing, slicing, exploration) |
| `state-persistence.md` | Always | Every session (artifact saving, naming) |
| `typescript.md` | `**/*.ts,**/*.tsx` | Editing TypeScript files |
| `tests.md` | `**/*.test.ts,**/*.spec.ts` | Editing test files |
| `database.md` | `**/migrations/**,**/*.sql` | Editing database/migration files |
| `infrastructure.md` | `**/Dockerfile,**/*.tf` | Editing infrastructure files |
| `diagrams.md` | Always | Every session (mermaid-default + drawio-for-complex policy, file convention, MCP usage) |
| `parallel-agents.md` | Always | Every session (worktree pattern for self-spawned parallel agents) |

### Agents (`agents/`)

16 expert agent personas across 5 categories. Each follows a 9-section structure with strict guardrails, review checklists, and red-flag detection. Spawned as subagents via the Agent tool when a task touches a specialized domain. The routing table in `rules/agent-routing.md` maps domain triggers to `subagent_type` values. See [ADR 0003](docs/adr/0003-agents-via-subagent-spawn.md) for the loading model.

See [Agent Reference](docs/agents.md) for the full listing.

### Skills (`skills/`)

Reusable workflows invoked on-demand. Cost ~200 tokens when idle (metadata only) vs. full cost if in CLAUDE.md.

Skills tagged *(mattpocock)* below are vendored from [mattpocock/skills](https://github.com/mattpocock/skills). They were imported on 2026-05-08 and are not kept in sync upstream - they may diverge over time as they get adapted to this workflow. To pull a newer upstream version, copy it manually and re-review the diff.

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
| `diagram` | `/diagram <topic>` | Pick mermaid vs drawio per `rules/diagrams.md`, write the source, preview via drawio MCP |
| `grill-with-docs` | `/grill-with-docs` | *(mattpocock)* Default alignment phase. Real-time Q&A walking the decision tree, updating `CONTEXT.md` and writing ADRs inline as decisions land. Replaces the old Plan + Annotate phases. |
| `to-issues` | `/to-issues` | *(mattpocock)* Break a plan/PRD into independently-grabbable vertical-slice issues on the project tracker. |
| `improve-codebase-architecture` | `/improve-codebase-architecture` | *(mattpocock)* Surface deepening opportunities (shallow-module refactors) using deletion-test heuristics. |
| `write-a-skill` | `/write-a-skill` | *(mattpocock)* Scaffold a new skill with proper frontmatter, triggers, and progressive disclosure. |
| `handoff` | `/handoff <focus>` | *(mattpocock)* Compact the current conversation into a handoff document so a fresh agent can pick up the work. |

### Commands (`commands/`)

Slash commands for frequent workflows. Available as `/user:<name>`.

| Command | Trigger | Purpose |
| --- | --- | --- |
| `research` | `/user:research <topic>` | Optional Phase 1: explore codebase, save findings to `.claude/state/research/` |
| `summarize` | `/user:summarize` | Save session diary to `.claude/state/sessions/` |
| `typecheck` | `/user:typecheck` | Run tsc and fix all type errors |
| `verify-done` | `/user:verify-done` | Full quality gate before declaring work done (lint + typecheck + test + build + git status) |
| `worktree` | `/user:worktree <slug>` | Create a git worktree on a fresh branch and switch into it. Useful for parallel sub-agent setup. |
| `worktree-merge` | `/user:worktree-merge` | Clean up the current worktree after its branch is merged. Removes worktree dir, deletes local branch. |
| `worktrees-prune` | `/user:worktrees-prune [--apply]` | Per-repo dry-run / apply: remove worktrees whose branch is upstream-gone or merged into default. |
| `worktrees-audit` | `/user:worktrees-audit [--root <path>] [--apply]` | Cross-repo scan under `~/dev/`, verdict per worktree, optional bulk apply. |

### Hooks (`hooks/`)

Automation scripts triggered at lifecycle events. Configured in `settings.json` (symlinked to `~/.claude/settings.json`).

| Hook | Event | Purpose |
| --- | --- | --- |
| `pre-pr-test-gate.sh` | PreToolUse (gh pr create) | Block PR creation if tests fail |
| `pre-push-gate.sh` | PreToolUse (git push) | Hard-block `git push` if lint/typecheck/test/build fail. Bypass with `SKIP_PUSH_GATE=1` |
| `auto-format.sh` | PostToolUse (Write/Edit) | Auto-format files with project formatter (Biome/Prettier) |
| `post-edit-typecheck.sh` | PostToolUse (Write/Edit) | Run typecheck and lint on .ts/.tsx files after edits |
| `watch-pr-checks.sh` | PostToolUse (gh pr create) | Poll CI checks in background, notify on pass/fail |
| `worktree-cleanup.sh` | SessionEnd | Opportunistic safe-prune of merged worktrees. Conservative; never blocks. Disable per-session with `CLAUDE_DISABLE_WORKTREE_CLEANUP=1`. |
| Notification | Notification | macOS desktop notification when Claude needs input |
| Compact reminder | SessionStart (compact) | Re-inject workflow context after compaction |

### Scripts (`scripts/`)

Utility scripts referenced by skills and hooks.

| Script | Purpose |
| --- | --- |
| `notify.sh` | Send macOS desktop notification unless a terminal or IDE is in the foreground |
| `statusline.sh` | Status line showing repo, branch (red if dirty), node version, and context usage (`145.7k (15%)`, color-graded green/yellow/red). Symlink to `~/.claude/statusline.sh` |
| `worktree-prune.sh` | Identify and (with `--apply`) remove safely-disposable worktrees. Conservative rule: upstream-gone OR merged into default. `audit-all` mode walks `~/dev/`. |

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

- [Cheatsheet](CHEATSHEET.md) - intent -> slash command map. Skim when you wonder "is there a slash for X?"
- [Agent Reference](docs/agents.md) - full agent listing and structure
- [ADRs](docs/adr/) - architectural decisions and their rationale
