# Claude Code Configuration

Custom configuration for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that turns it into a disciplined engineering partner with structured workflows, strict guardrails, and domain-specific expertise.

## Why

Out of the box, Claude Code is capable but generic. This configuration adds opinionated defaults - a mandatory research-plan-implement workflow, security boundaries, code standards, and 15 expert agents that activate automatically based on task context. The result is more consistent, reviewable, and safe output.

## What's Included

- **[`CLAUDE.md`](CLAUDE.md)** - global rules: workflow phases, security, code standards, behavioral constraints, agent routing
- **[`agents/`](agents/)** - 15 expert agent personas across engineering, infrastructure, security, compliance, analytics, and product/design
- **[`.github/pull_request_template.md`](.github/pull_request_template.md)** - PR template
- **[`.github/workflows/`](.github/workflows/)** - CI workflow for markdown linting

## Quick Start

```bash
cp CLAUDE.md ~/.claude/CLAUDE.md
cp -r agents/ ~/.claude/agents/
```

## Agents

15 agents organized into 5 categories: Engineering, Infrastructure & Data, Marketing & Analytics, Security & Compliance, and Product & Design. Each agent includes strict guardrails, review checklists, and red-flag detection.

See the [Agent Reference](docs/agents.md) for the full listing and structure.

## Configuration

`CLAUDE.md` defines research-plan-implement workflow, security rules, TypeScript code standards, behavioral constraints (scope discipline, conventional commits, semver), and automatic agent routing.

See the [Configuration Guide](docs/configuration.md) for a detailed walkthrough.

## CI

Markdown linting runs on every push and PR via GitHub Actions.
