---
description: "List active Claude session locks across all repos. Shows live sessions, stale locks, and pruning controls."
---

Run `~/.claude/scripts/repo-lock.sh list` and report:

- Each lock's repo path, session_id, pid, branch, claimed_at, last_seen, and live/stale flag
- Sessions that hold a lock on the current repo (if any)

If $ARGUMENTS contains:

- `--prune` - run `~/.claude/scripts/repo-lock.sh prune` to remove stale locks
- `--release <hash>` or `--release <repo-path>` - run with FORCE=1 to free a stuck lock

Otherwise just show the listing. Do not modify anything without an explicit flag.
