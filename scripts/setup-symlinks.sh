#!/bin/bash
# Bootstrap the symlinks from a Claude config dir to the dotfiles repo.
# Idempotent: safe to run multiple times.
#
# Target config dir resolves from $CLAUDE_CONFIG_DIR (default ~/.claude), so the
# same script seeds a second account's dir, e.g.:
#   CLAUDE_CONFIG_DIR="$HOME/.claude-personal" bash scripts/setup-symlinks.sh
#
# Per entry:
#   - If already symlinked to the correct target -> skipped.
#   - If symlinked to a different target -> the wrong link is removed and
#     replaced with the correct one (no backup; symlinks have no content).
#   - If a real file/dir exists at that path -> backed up to
#     <path>.bak.<timestamp>, then replaced with the symlink.
#   - If nothing exists at the path -> a new symlink is created.
#
# Repo location resolves in this order:
#   1. $CLAUDE_DOTFILES_REPO if set
#   2. The script's own directory (../ from scripts/) if it is a git repo
#   3. ~/dev/claude
#
# Usage:
#   bash scripts/setup-symlinks.sh           # apply
#   bash scripts/setup-symlinks.sh --check   # dry-run (report only, no changes)
#
# Exit 0 on success, 1 if any entry failed.

set -u

MODE="apply"
case "${1:-}" in
  --check|-n|--dry-run) MODE="check" ;;
  --help|-h)
    sed -n '2,26p' "$0"
    exit 0
    ;;
  "") ;;
  *)
    echo "Unknown flag: $1" >&2
    echo "Usage: $0 [--check]" >&2
    exit 2
    ;;
esac

# Resolve repo
if [ -n "${CLAUDE_DOTFILES_REPO:-}" ]; then
  REPO="$CLAUDE_DOTFILES_REPO"
else
  SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
  CANDIDATE=$(cd "$SCRIPT_DIR/.." && pwd)
  if [ -d "$CANDIDATE/.git" ] || git -C "$CANDIDATE" rev-parse --git-dir >/dev/null 2>&1; then
    REPO="$CANDIDATE"
  else
    REPO="$HOME/dev/claude"
  fi
fi

if [ ! -d "$REPO" ]; then
  echo "Repo not found at $REPO." >&2
  echo "Set CLAUDE_DOTFILES_REPO to override, or clone the dotfiles repo first." >&2
  exit 1
fi

LIVE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$LIVE_DIR"

# name | repo-side target (relative to $REPO)
ENTRIES=(
  "CLAUDE.md|CLAUDE.md"
  "settings.json|settings.json"
  "agents|agents"
  "commands|commands"
  "hooks|hooks"
  "rules|rules"
  "skills|skills"
  "docs|docs"
  "references|references"
  "statusline.sh|scripts/statusline.sh"
  "pull_request_template.md|.github/pull_request_template.md"
)

TS=$(date +%Y%m%d-%H%M%S)
FAILED=0

printf "%-16s %-12s %s\n" "PATH" "STATE" "ACTION"
printf "%-16s %-12s %s\n" "----" "-----" "------"

for ENTRY in "${ENTRIES[@]}"; do
  NAME="${ENTRY%%|*}"
  REL_TARGET="${ENTRY##*|}"
  TARGET="$REPO/$REL_TARGET"
  LIVE="$LIVE_DIR/$NAME"

  if [ ! -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
    printf "%-16s %-12s %s\n" "$NAME" "MISSING-SRC" "skip ($TARGET does not exist in repo)"
    FAILED=$((FAILED+1))
    continue
  fi

  if [ -L "$LIVE" ]; then
    GOT=$(readlink "$LIVE")
    if [ "$GOT" = "$TARGET" ]; then
      printf "%-16s %-12s %s\n" "$NAME" "OK" "already correct"
      continue
    fi
    if [ "$MODE" = "check" ]; then
      printf "%-16s %-12s %s\n" "$NAME" "WRONG-LINK" "would replace ($GOT -> $TARGET)"
      continue
    fi
    rm "$LIVE" && ln -s "$TARGET" "$LIVE" \
      && printf "%-16s %-12s %s\n" "$NAME" "RELINKED" "$GOT -> $TARGET" \
      || { printf "%-16s %-12s %s\n" "$NAME" "FAILED" "could not relink"; FAILED=$((FAILED+1)); }
    continue
  fi

  if [ -e "$LIVE" ]; then
    # Real file or directory
    if [ "$MODE" = "check" ]; then
      printf "%-16s %-12s %s\n" "$NAME" "REAL-FILE" "would backup to $LIVE.bak.$TS and link"
      continue
    fi
    BACKUP="$LIVE.bak.$TS"
    mv "$LIVE" "$BACKUP" \
      && ln -s "$TARGET" "$LIVE" \
      && printf "%-16s %-12s %s\n" "$NAME" "REPLACED" "backed up to $(basename "$BACKUP")" \
      || { printf "%-16s %-12s %s\n" "$NAME" "FAILED" "could not replace"; FAILED=$((FAILED+1)); }
    continue
  fi

  # Nothing exists at LIVE
  if [ "$MODE" = "check" ]; then
    printf "%-16s %-12s %s\n" "$NAME" "MISSING" "would create symlink"
    continue
  fi
  ln -s "$TARGET" "$LIVE" \
    && printf "%-16s %-12s %s\n" "$NAME" "CREATED" "$TARGET" \
    || { printf "%-16s %-12s %s\n" "$NAME" "FAILED" "could not create"; FAILED=$((FAILED+1)); }
done

echo ""
if [ "$MODE" = "check" ]; then
  echo "Dry run complete. Re-run without --check to apply."
elif [ "$FAILED" -eq 0 ]; then
  echo "All symlinks in place. Repo: $REPO"
else
  echo "$FAILED entr(ies) failed. See output above." >&2
  exit 1
fi
