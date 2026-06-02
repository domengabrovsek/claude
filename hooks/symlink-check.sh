#!/bin/bash
# SessionStart hook (matcher: startup).
# Warns to stderr when expected ~/.claude/* symlinks to the dotfiles repo are
# missing, replaced by a real file, or pointing to the wrong target. Non-blocking.
# Bypass with SKIP_SYMLINK_CHECK=1 in the environment.

[ "$SKIP_SYMLINK_CHECK" = "1" ] && exit 0

REPO="${CLAUDE_DOTFILES_REPO:-$HOME/dev/claude}"
[ -d "$REPO" ] || exit 0

EXPECTED=(
  "CLAUDE.md|$REPO/CLAUDE.md"
  "RTK.md|$REPO/RTK.md"
  "settings.json|$REPO/settings.json"
  "agents|$REPO/agents"
  "commands|$REPO/commands"
  "hooks|$REPO/hooks"
  "rules|$REPO/rules"
  "skills|$REPO/skills"
  "statusline.sh|$REPO/scripts/statusline.sh"
)

ISSUES=()
for ENTRY in "${EXPECTED[@]}"; do
  NAME="${ENTRY%%|*}"
  WANT="${ENTRY##*|}"
  LIVE="$HOME/.claude/$NAME"

  if [ ! -e "$LIVE" ] && [ ! -L "$LIVE" ]; then
    ISSUES+=("MISSING:       $LIVE  (expected -> $WANT)")
  elif [ ! -L "$LIVE" ]; then
    ISSUES+=("NOT-A-SYMLINK: $LIVE  is a real file (expected -> $WANT)")
  else
    GOT=$(readlink "$LIVE")
    if [ "$GOT" != "$WANT" ]; then
      ISSUES+=("WRONG-TARGET:  $LIVE -> $GOT  (expected -> $WANT)")
    fi
  fi
done

if [ ${#ISSUES[@]} -gt 0 ]; then
  echo "[symlink-check] dotfiles symlinks have drifted from $REPO:" >&2
  for ISSUE in "${ISSUES[@]}"; do echo "  - $ISSUE" >&2; done
  echo "" >&2
  echo "Fix each path with:" >&2
  echo "  unlink <path> 2>/dev/null; rm -rf <path> 2>/dev/null; ln -s <expected-target> <path>" >&2
  echo "" >&2
  echo "(Override repo location: CLAUDE_DOTFILES_REPO=/path/to/repo. Bypass this check: SKIP_SYMLINK_CHECK=1.)" >&2
fi

exit 0
