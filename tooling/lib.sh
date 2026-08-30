#!/usr/bin/env bash
# Shared environment for Stedding tooling. Source this; do not execute it.
#
# Layout (all paths overridable by environment variable):
#
#   $STEDDING_ROOT        this repository            (default: parent of tooling/)
#   $DEPOT_TOOLS_DIR      Chromium's depot_tools     (default: ~/depot_tools)
#   $CHROMIUM_ROOT        gclient checkout root      (default: ~/chromium)
#   $CHROMIUM_SRC         Chromium source tree       (default: $CHROMIUM_ROOT/src)
#
# The Chromium tree lives OUTSIDE this repository and is never committed here.

set -euo pipefail

STEDDING_ROOT="${STEDDING_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DEPOT_TOOLS_DIR="${DEPOT_TOOLS_DIR:-$HOME/depot_tools}"
CHROMIUM_ROOT="${CHROMIUM_ROOT:-$HOME/chromium}"
CHROMIUM_SRC="${CHROMIUM_SRC:-$CHROMIUM_ROOT/src}"
export STEDDING_ROOT DEPOT_TOOLS_DIR CHROMIUM_ROOT CHROMIUM_SRC

# shellcheck source=./chromium-version
. "$STEDDING_ROOT/tooling/chromium-version"
export CHROMIUM_TAG CHROMIUM_MILESTONE CHROMIUM_COMMIT CHROMIUM_CHANNEL CHROMIUM_PIN_DATE

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# Put depot_tools first on PATH. Chromium's build requires its bundled python,
# ninja, gn and git wrappers to shadow any system copies.
add_depot_tools_to_path() {
  [ -d "$DEPOT_TOOLS_DIR" ] || die "depot_tools not found at $DEPOT_TOOLS_DIR — run tooling/bootstrap-depot-tools"
  case ":$PATH:" in
    *":$DEPOT_TOOLS_DIR:"*) ;;
    *) PATH="$DEPOT_TOOLS_DIR:$PATH" ;;
  esac
  export PATH
}

# Free space in GB on the volume holding $1.
free_gb() {
  df -Pk "$1" | awk 'NR==2 { printf "%d", $4 / 1024 / 1024 }'
}

require_free_gb() {
  local path="$1" need="$2" have
  mkdir -p "$path"
  have="$(free_gb "$path")"
  if [ "$have" -lt "$need" ]; then
    die "need ${need} GB free on the volume holding $path, have ${have} GB"
  fi
  log "disk check: ${have} GB free on the volume holding $path (need ${need} GB)"
}

require_macos_arm64() {
  [ "$(uname -s)" = "Darwin" ] || die "this script currently supports macOS only (got $(uname -s))"
  [ "$(uname -m)" = "arm64" ]  || die "this script currently supports arm64 only (got $(uname -m))"
}
