# Share agent configuration across hosts

## Status

Accepted - 2026-09-04

## Context

The repo carried Claude-only configuration, while the same workflows now run on Codex and Pi. Duplicating guidance per host drifts. This decision is adopted from [LukaPrebil/harness-config](https://github.com/LukaPrebil/harness-config), where it proved out first.

## Decision

Use the root `AGENTS.md` as the concise shared instruction source and `skills/` as the shared skill library for Claude Code, Codex, and Pi. `CLAUDE.md` imports the shared instructions and keeps only Claude-specific loading. The host bootstrap (`scripts/setup-hosts.sh`) links each host's native paths to the same files. Hooks, permissions, and teammate mechanics stay in host-specific adapters. Hosts without `@` imports reach `rules/` through the `rulebook` skill.

## Consequences

- One edit updates every host; no duplicated guidance.
- `scripts/setup-symlinks.sh` becomes a Claude-only compatibility wrapper.
- Shared skills keep Claude notation; `AGENTS.md` defines the compatibility mapping other hosts apply.
