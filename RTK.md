# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

**Name collision**: if `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Re-installing / upgrading without clobbering configs

**Always pass `--hook-only`** to `rtk init`:

```bash
rtk init -g --hook-only
```

Plain `rtk init -g` (without the flag) would overwrite `~/.claude/RTK.md` (this file, symlinked to the dotfiles repo) with the 10-line stock version, and prompt to patch `~/.claude/settings.json` (also symlinked). If you ever see `Patch existing ... settings.json? [y/N]`, answer **N**: the repo's `settings.json` already has the `rtk hook claude` registration.

Drift recovery: if a symlink already got replaced with a real file, run `bash ~/dev/claude/scripts/setup-symlinks.sh` to back up the bad version (`.bak.<timestamp>`) and restore the symlink.

## Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

Refer to CLAUDE.md for full command reference.

## Hook Bailouts to Avoid

The RTK hook silently falls back to raw output when a command contains shell
operators it cannot parse cleanly. To keep adoption high:

- **Do not append `2>&1`** - RTK filters already surface stderr usefully; the
  redirect suppresses the rewrite and loses the savings. Let failure output
  flow through naturally. `(review-time: requires recognizing the redirect in the command being composed)`
- Avoid command substitution (`$(...)`), pipes into interpreters
  (`| python -c`, `| node -e`), and compound commands (`&&`, `;`) when a
  simpler single-command form exists. `(review-time: command-shape choice)`

**Exception: `glab`** - RTK has no `glab` filter yet (tracked upstream at
rtk-ai/rtk#1085). Until that ships, `glab` commands bypass RTK regardless of
redirects, so `2>&1` is harmless there.

## When NOT to reach for `rtk proxy`

`rtk proxy <cmd>` strips all RTK filtering, including adapter-specific
summaries (vitest failures, tsc error grouping, lint diagnostics). That
makes it a scalpel, not a session-wide shield. Reach for it only when an
rtk adapter is provably broken for one specific command.

- **Default**: bare `npm` / bare tool invocation. Trust RTK filters to
  surface failures. Do not prefix `rtk proxy` out of habit. `(review-time: command-composition discipline)`
- **When one adapter misbehaves** (e.g. the lint adapter on a Biome
  project emitting `ESLint output (JSON parse failed: EOF ...)`), scope
  `rtk proxy` to just that one command (`rtk proxy npm run lint`). Leave
  every other command on bare invocation so their adapters keep working. `(review-time: requires recognising adapter failure)`
- **A quiet proxied run is not a validated run**. `rtk proxy` shows raw
  end-of-stream output, which can look like success even when a coverage
  gate, typecheck, or integration assertion failed mid-stream. If you
  used `rtk proxy`, re-read the raw output yourself; do not trust the
  tail. `(review-time: output-reading discipline)`
- **Before reaching for proxy, dry-run the rewrite**: `rtk hook check
  "<cmd>"` prints what rtk will rewrite the command to. If it routes to
  an adapter that does not match the actual tool (`biome check` ->
  `rtk lint check`), that is the collision to scope a proxy around. `(review-time: workflow step)`
