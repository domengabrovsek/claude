# Pi adapter vendors settings and extensions into every agent dir

## Status

Accepted - 2026-09-04

## Context

The multi-host bootstrap (ADR 0008) linked `AGENTS.md` and shared skills for Pi, but left the resources that make Pi personal unmanaged. The `statusline.ts` footer extension lived untracked in a Pi agent dir, and Pi's `settings.json` was hand-maintained with a manual symlink chain. Neither was visible to `setup-hosts.sh --check`, and neither survived a new machine without tribal steps. Adopted from [LukaPrebil/harness-config](https://github.com/LukaPrebil/harness-config) (ADR 0009, decided by Luka Prebil Grintal).

## Decision

Link `pi/extensions/` and `pi/settings.json` into every configured Pi agent dir alongside `AGENTS.md`, selected by `PI_CONFIG_DIRS` (space-separated list). The default is the base dir plus the personal-account dir (`~/.pi/agent ~/.pi-personal/agent`). The single-dir `PI_CODING_AGENT_DIR` override still wins when set. Consumption stays symlink-based; Pi-specific files live under `pi/` because the repo root keeps the inherited Claude layout.

## Consequences

- One `setup-hosts.sh --apply` configures every Pi agent dir; `--check` sees them all.
- `pi/settings.json` follows the Claude pattern: tracked, with `strip-ephemeral-state` dropping runtime keys so rewrites stay git-clean.
- The checkout path becomes load-bearing on every machine: moving or deleting it breaks all linked hosts at once.
- New harnesses join by adding an adapter dir plus a host selector, not a second repo.

## Alternatives considered

- **Pi package (`pi install git:`)**: versioned pins and a Pi-managed clone, but the edit loop becomes commit-push-update, and the shared skills link double-loads skills. Rejected for a single-operator repo; the root layout stays package-shaped so a later switch costs one `pi install`.
- **Personal-dir chaining** (the personal dir symlinking the base dir's files): worked, but was invisible to `--check` and needed machine-specific memory. Rejected for the explicit dual-dir loop.
- **Symmetric adapter dirs for every host** (`claude/` alongside `pi/`): cleaner shape, but moves the most-churned files and turns future syncs into rename conflicts. Deferred.
