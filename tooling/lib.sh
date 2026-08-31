#!/usr/bin/env bash
# Shared environment for Stedding tooling. Source this; do not execute it.
#
# Layout (all paths overridable by environment variable):
#
#   $STEDDING_ROOT        this repository            (default: parent of tooling/)
#   $DEPOT_TOOLS_DIR      Chromium's depot_tools     (default: ~/depot_tools)
#   $CHROMIUM_ROOT        gclient checkout root      (default: ~/chromium)
#   $CHROMIUM_SRC         Chromium source tree       (default: $CHROMIUM_ROOT/src)
#   $GIT_CACHE_PATH       depot_tools git cache      (default: $CHROMIUM_ROOT/.git-cache)
#
# The Chromium tree lives OUTSIDE this repository and is never committed here.

set -euo pipefail

STEDDING_ROOT="${STEDDING_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# A checkout that is not in the default location has to stay found. Requiring
# CHROMIUM_ROOT=... on the front of every command is a trap: sync-chromium would use
# the override and build-chromium, run without it, would look somewhere else entirely
# and report that there is no checkout. So the first successful sync records the
# location here, and every later command picks it up.
#
# Precedence: environment beats the recorded value, which beats the default.
# The file is local state, not configuration to be committed.
STEDDING_LOCAL="$STEDDING_ROOT/.stedding-local"
if [ -z "${CHROMIUM_ROOT:-}" ] && [ -f "$STEDDING_LOCAL" ]; then
  # Parsed, never sourced. Sourcing it executes it: a path with a space in it made
  # bash read the remainder as a command and run it, and any other line in the file
  # would run outright. This reads one key and takes its value verbatim, spaces and
  # all, with no expansion of anything the file contains.
  CHROMIUM_ROOT="$(sed -n 's/^CHROMIUM_ROOT=//p' "$STEDDING_LOCAL" | tail -1)"
  [ -n "$CHROMIUM_ROOT" ] || warn_pending_local="$STEDDING_LOCAL names no CHROMIUM_ROOT; using the default"
fi

DEPOT_TOOLS_DIR="${DEPOT_TOOLS_DIR:-$HOME/depot_tools}"
CHROMIUM_ROOT="${CHROMIUM_ROOT:-$HOME/chromium}"
CHROMIUM_SRC="${CHROMIUM_SRC:-$CHROMIUM_ROOT/src}"

# depot_tools' git cache is not an optimisation here, it is the only route that works.
# Cloning chromium/src over the git protocol stalls for a very long time in the
# server-side ref advertisement; the cache bootstraps from a prepackaged bundle on
# Google Storage over plain HTTP instead. gclient picks this up for every dependency
# as well, so it is set for all tooling rather than in one script.
# See docs/ARCHITECTURE.md, "Known failure modes".
GIT_CACHE_PATH="${GIT_CACHE_PATH:-$CHROMIUM_ROOT/.git-cache}"

export STEDDING_ROOT DEPOT_TOOLS_DIR CHROMIUM_ROOT CHROMIUM_SRC GIT_CACHE_PATH

# chromium-version is data, not code; shellcheck cannot resolve the runtime path.
# shellcheck disable=SC1091
. "$STEDDING_ROOT/tooling/chromium-version"
export CHROMIUM_TAG CHROMIUM_MILESTONE CHROMIUM_COMMIT CHROMIUM_CHANNEL CHROMIUM_PIN_DATE

# Upstream source of truth.
CHROMIUM_URL="https://chromium.googlesource.com/chromium/src.git"
export CHROMIUM_URL

# Path the git cache uses for a given repository URL.
git_cache_dir() {
  git cache exists --cache-dir "$GIT_CACHE_PATH" "$1" 2>/dev/null
}

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

[ -n "${warn_pending_local:-}" ] && warn "$warn_pending_local"
unset warn_pending_local

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

# Chromium's TypeScript build resolves modules the way node does: by walking up
# parent directories looking for node_modules. A stray node_modules ABOVE the
# checkout therefore leaks its @types into the build, and ts_library.py fails with
# "Undeclared dependencies to definition files" naming packages nobody asked for.
#
# The failure arrives after the whole checkout has been made and several minutes into
# a build, and names the packages rather than the cause, so it is checked here instead.
require_no_ancestor_node_modules() {
  local path="$1" dir found=""
  dir="$(cd "$path" 2>/dev/null && pwd || echo "$path")"
  # The checkout root counts too: node resolution starts there, not at its parent.
  [ -e "$dir/node_modules" ] && found="$dir/node_modules"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    dir="$(dirname "$dir")"
    [ -e "$dir/node_modules" ] && found="$dir/node_modules"
  done
  [ -z "$found" ] && return 0
  die "found $found

     Chromium's TypeScript build walks up parent directories looking for
     node_modules, so this directory's @types leak into the build and it fails
     with 'Undeclared dependencies to definition files'.

     Put the checkout somewhere with no node_modules in any ancestor directory:

         CHROMIUM_ROOT=/Users/Shared/chromium tooling/sync-chromium

     Deleting the offending node_modules also works, but it is not ours to delete."
}

# Record where the checkout actually lives, so later commands do not need the override.
remember_chromium_root() {
  local target="$STEDDING_ROOT/.stedding-local"
  # Persist an absolute path. A relative one resolves against whatever directory the
  # next command happens to start in, which is not the one it was recorded from.
  CHROMIUM_ROOT="$(cd "$CHROMIUM_ROOT" 2>/dev/null && pwd || printf '%s' "$CHROMIUM_ROOT")"
  [ "$CHROMIUM_ROOT" = "$HOME/chromium" ] && { rm -f "$target"; return 0; }
  cat > "$target" <<EOF
# Written by tooling/sync-chromium. Local state, not committed.
# Delete this file to go back to the default (~/chromium).
CHROMIUM_ROOT=$CHROMIUM_ROOT
EOF
  log "recorded CHROMIUM_ROOT=$CHROMIUM_ROOT in .stedding-local"
  log "later commands will find the checkout without the override"
}

require_macos_arm64() {
  [ "$(uname -s)" = "Darwin" ] || die "this script currently supports macOS only (got $(uname -s))"
  [ "$(uname -m)" = "arm64" ]  || die "this script currently supports arm64 only (got $(uname -m))"
}
