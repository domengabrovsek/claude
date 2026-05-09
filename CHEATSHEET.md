# Cheatsheet

Intent → slash command. Skim when you wonder *"is there a slash for X?"*.

For full descriptions of each tool see the [README](README.md).

## "I want to..."

| Intent | Tool |
| --- | --- |
| Understand an unfamiliar code area | `/user:research <topic>` |
| Define formal requirements before planning | `/spec <topic>` |
| Stress-test a plan / reach alignment before code | `/grill-with-docs <topic>` |
| Build the agreed plan | `/build` |
| Write tests for code (TDD or prove-it) | `/test <target>` |
| Investigate a prod incident with evidence-first hypothesis ranking | `/debug <error>` |
| Resolve a GitHub issue end-to-end | `/fix-issue 1234` |
| Review someone's PR | `/review-pr 567` |
| Verify everything before pushing | `/user:verify-done` |
| Open a PR/MR (auto-runs verify-done first, regex-checks the title) | `/mr` |
| Watch CI on the latest PR | `/ci` (or `/loop 2m /ci`) |
| Cut a release | `/ship` |
| Make a diagram (mermaid or drawio) | `/diagram <topic>` |
| Save the session's work as a diary entry | `/user:summarize` |
| Run typecheck and fix errors | `/user:typecheck` |
| Refresh a library's API docs (React, Prisma, Next.js, etc.) | mention the library by name - Context7 auto-fires |
| Break a plan/PRD into independently-grabbable tracker issues | `/to-issues` |
| Find architectural deepening opportunities in a codebase | `/improve-codebase-architecture` |
| Scaffold a new skill | `/write-a-skill` |
| Create a worktree for parallel sub-agent work | `/user:worktree <slug>` |
| Clean up a worktree after its branch merged | `/user:worktree-merge` |
| Prune dead worktrees in this repo | `/user:worktrees-prune [--apply]` |
| Audit worktrees across all repos under `~/dev/` | `/user:worktrees-audit [--apply]` |

## When the slash IS the value

Some skills enforce a discipline plain English would skip. Use the slash when you want the structure:

- `/grill-with-docs` - the decision-tree walk is the point
- `/debug` - evidence-first hypothesis ranking before any code change
- `/build` - quality gates per task
- `/test` - red-green-refactor or prove-it pattern
- `/spec` - stakeholder-framed requirements doc
- `/user:verify-done` - every CI step in CI's exact order
- `/mr` - verify-done + commit-format + title-regex gates before opening
- `/ship` - pre-launch validation checklist
- `/fix-issue` - full issue resolution flow
- `/review-pr` - severity-tagged review scaffolding

## When plain English is fine

Lightweight helpers; structure is minimal:

- `/diagram`, `/ci`, `/loop`, `/schedule`

## Workflow phases (4-phase, post-#46)

```text
[/user:research]  optional orientation
        ↓
/grill-with-docs  alignment - emits CONTEXT.md + ADRs + execution plan
        ↓
/build            walk the execution plan
        ↓
/user:verify-done full quality gate
        ↓
/mr               open PR (gate runs again)
        ↓
/ci               watch pipeline
        ↓
/user:summarize   session diary
```

## Other intents

These run independently of the implementation workflow:

- `/debug` for incidents
- `/review-pr` for reviewing others' code
- `/document` for engineering docs
- `/diagram` for architecture or sequence diagrams
- `/zoom-out` (deleted, just describe what you want in plain English)

## Agents

Agents auto-spawn via `rules/agent-routing.md` when a task touches a specialized domain (Postgres, GCP, security, etc.). You don't invoke them directly. See [ADR 0003](docs/adr/0003-agents-via-subagent-spawn.md) for the loading model.
