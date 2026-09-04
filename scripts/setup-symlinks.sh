#!/bin/bash
# Backward-compatible Claude-only bootstrap.
#
# The historical command applies immediately and adopts conflicts by moving
# them to timestamped adjacent backups. Dry-run aliases remain report-only.

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SETUP_HOSTS="$SCRIPT_DIR/setup-hosts.sh"

case "${1:-}" in
  "")
    exec bash "$SETUP_HOSTS" --apply --adopt --host claude
    ;;
  --check|-n|--dry-run)
    exec bash "$SETUP_HOSTS" --check --host claude
    ;;
  --help|-h)
    echo "Usage: $0 [--check|-n|--dry-run]"
    echo ""
    echo "Without arguments, configures Claude and safely adopts conflicts."
    exit 0
    ;;
  *)
    echo "Unknown flag: $1" >&2
    echo "Usage: $0 [--check|-n|--dry-run]" >&2
    exit 2
    ;;
esac
