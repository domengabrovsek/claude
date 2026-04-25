#!/bin/bash
# Repo lock manager. Tracks active Claude sessions per repo to prevent
# cross-session collisions. Locks live at ~/.claude/locks/<sha1>.json.
# Subcommands: claim, release, check, list, prune.
# Exit codes: 0 = success, 1 = held by other live session, 2 = bad usage.

set -u

LOCK_DIR="${CLAUDE_LOCK_DIR:-$HOME/.claude/locks}"
STALE_SECONDS="${CLAUDE_LOCK_STALE:-1800}" # 30 min default

mkdir -p "$LOCK_DIR"

repo_root() {
  local start="${1:-$PWD}"
  ( cd "$start" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null )
}

repo_hash() {
  printf '%s' "$1" | shasum | awk '{print $1}'
}

lock_path() {
  local repo="$1"
  echo "$LOCK_DIR/$(repo_hash "$repo").json"
}

now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

epoch_now() {
  date -u +%s
}

iso_to_epoch() {
  # macOS date - tolerant parser
  date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null
}

is_live() {
  # Liveness = last_seen within STALE_SECONDS. PID is informational only;
  # heartbeat (Phase 2) refreshes last_seen via PostToolUse. If PID is
  # provably dead AND it matches the stored pid, treat as stale early.
  local file="$1"
  [ -f "$file" ] || return 1
  local pid last_seen ts age
  pid=$(jq -r '.pid // empty' "$file" 2>/dev/null)
  last_seen=$(jq -r '.last_seen // empty' "$file" 2>/dev/null)
  [ -z "$last_seen" ] && return 1
  ts=$(iso_to_epoch "$last_seen") || return 1
  age=$(( $(epoch_now) - ts ))
  [ "$age" -ge "$STALE_SECONDS" ] && return 1
  # Within freshness window. If the stored pid is dead AND last_seen is older
  # than 60s with no heartbeat catching up, declare stale early.
  if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null && [ "$age" -gt 60 ]; then
    return 1
  fi
  return 0
}

build_lock_json() {
  local repo="$1"
  local sid="${CLAUDE_SESSION_ID:-$$-$(epoch_now)}"
  local branch
  branch=$( cd "$repo" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown" )
  local in_worktree="false"
  if [ "$( cd "$repo" && git rev-parse --git-common-dir 2>/dev/null )" != "$( cd "$repo" && git rev-parse --git-dir 2>/dev/null )" ]; then
    in_worktree="true"
  fi
  # Store parent PID - the script subshell dies immediately, so $$ is useless.
  # PPID is the Claude bash-tool wrapper or shell, which lives longer.
  local owner_pid="${CLAUDE_PARENT_PID:-$PPID}"
  jq -n \
    --arg repo "$repo" \
    --arg sid "$sid" \
    --arg branch "$branch" \
    --argjson pid "$owner_pid" \
    --argjson worktree "$in_worktree" \
    --arg now "$(now_iso)" \
    '{repo_path:$repo, session_id:$sid, pid:$pid, branch:$branch, worktree:$worktree, claimed_at:$now, last_seen:$now}'
}

cmd_claim() {
  local repo
  repo=$(repo_root "${1:-$PWD}") || { echo "not in a git repo" >&2; exit 2; }
  [ -z "$repo" ] && { echo "not in a git repo" >&2; exit 2; }
  local lock; lock=$(lock_path "$repo")

  if [ -f "$lock" ] && is_live "$lock"; then
    local owner_sid; owner_sid=$(jq -r '.session_id' "$lock")
    if [ "$owner_sid" = "${CLAUDE_SESSION_ID:-}" ]; then
      # refresh heartbeat
      jq --arg now "$(now_iso)" '.last_seen=$now' "$lock" > "$lock.tmp" && mv "$lock.tmp" "$lock"
      cat "$lock"
      exit 0
    fi
    echo "held by another session" >&2
    cat "$lock" >&2
    exit 1
  fi

  build_lock_json "$repo" > "$lock"
  cat "$lock"
}

cmd_release() {
  local repo
  repo=$(repo_root "${1:-$PWD}") || exit 0
  [ -z "$repo" ] && exit 0
  local lock; lock=$(lock_path "$repo")
  [ -f "$lock" ] || exit 0
  local owner_sid; owner_sid=$(jq -r '.session_id // empty' "$lock" 2>/dev/null)
  if [ -n "${CLAUDE_SESSION_ID:-}" ] && [ "$owner_sid" != "$CLAUDE_SESSION_ID" ] && [ "${FORCE:-0}" != "1" ]; then
    echo "lock owned by $owner_sid - use FORCE=1 to override" >&2
    exit 1
  fi
  rm -f "$lock"
}

cmd_check() {
  local repo
  repo=$(repo_root "${1:-$PWD}") || { echo "not in a git repo" >&2; exit 2; }
  [ -z "$repo" ] && { echo "not in a git repo" >&2; exit 2; }
  local lock; lock=$(lock_path "$repo")
  if [ -f "$lock" ] && is_live "$lock"; then
    cat "$lock"
    exit 1
  fi
  if [ -f "$lock" ]; then
    jq '. + {stale:true}' "$lock"
    exit 0
  fi
  echo '{"status":"free"}'
  exit 0
}

cmd_list() {
  shopt -s nullglob 2>/dev/null
  local any=0
  for f in "$LOCK_DIR"/*.json; do
    any=1
    if is_live "$f"; then
      jq '. + {live:true}' "$f"
    else
      jq '. + {live:false, stale:true}' "$f"
    fi
  done
  [ $any -eq 0 ] && echo '[]'
}

cmd_prune() {
  shopt -s nullglob 2>/dev/null
  local removed=0
  for f in "$LOCK_DIR"/*.json; do
    if ! is_live "$f"; then
      rm -f "$f"
      removed=$((removed+1))
    fi
  done
  echo "pruned $removed stale locks"
}

case "${1:-}" in
  claim)   shift; cmd_claim "$@" ;;
  release) shift; cmd_release "$@" ;;
  check)   shift; cmd_check "$@" ;;
  list)    shift; cmd_list ;;
  prune)   shift; cmd_prune ;;
  *) echo "usage: repo-lock.sh {claim|release|check|list|prune} [repo-path]" >&2; exit 2 ;;
esac
