#!/usr/bin/env bash
# Shared by capture-stills.sh and record-demo.sh. Sourced, never executed.
#
# The pages the README's media show, the local servers behind the two local
# development pages, the seeded profiles, and the checks both scripts make before
# they start a browser. Written for macOS's own bash 3.2: no associative arrays,
# and an array that may be empty is expanded as ${a[@]+"${a[@]}"}.
# The variables below are read by the scripts that source this file.
# shellcheck disable=SC2034

READMEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source-path=SCRIPTDIR
# shellcheck source=../lib.sh
. "$READMEDIR/../lib.sh"

MEDIA_PY="$READMEDIR/media.py"
FFMPEG="${FFMPEG:-$(command -v ffmpeg || echo /opt/homebrew/bin/ffmpeg)}"
FFPROBE="${FFPROBE:-$(command -v ffprobe || echo /opt/homebrew/bin/ffprobe)}"
FEATURE="SteddingArcStyleWindow"

# Real sites that are stable, need no sign-in and show no consent banner, and
# two local pages of this directory (docs/images/readme/STORYBOARD.md, "Pages").
# github.com stands in for any example page (never rust-lang.org).
URL_REPO="https://github.com/ysalitrynskyi/stedding-browser"
URL_MDN="https://developer.mozilla.org/en-US/"
URL_DDG="https://duckduckgo.com/"
URL_HN="https://news.ycombinator.com/"
# One day's front page, for a still that shows Hacker News itself: today's front page
# changes by the hour and can carry politics; this day's top stories are technology, and
# the page stays the same for every retake.
URL_HN_DAY="https://news.ycombinator.com/front?day=2026-10-24"
URL_MDN_CSS="https://developer.mozilla.org/en-US/docs/Web/CSS"
URL_PY_TUTORIAL="https://docs.python.org/3/tutorial/"
URL_DJANGO="https://www.djangoproject.com/"
URL_PYTHON="https://www.python.org/"
URL_TRENDING="https://github.com/trending"
# The stills' front page: GitHub's trending page, the week's Swift projects, which
# leaned to Mac apps when the main trending list leaned to AI tools (2026-10-23).
URL_TRENDING_FRONT="https://github.com/trending/swift?since=weekly"
URL_LOBSTERS="https://lobste.rs/"
URL_OSM="https://www.openstreetmap.org/"
URL_WIKI_COOKIE="https://en.wikipedia.org/wiki/HTTP_cookie"
URL_ARXIV="https://arxiv.org/"
URL_PYPI="https://pypi.org/"
# Reading's two pages, the split scene's: NASA's home, dark along its top, and
# Wikipedia's Apollo 11 article, white (the owner, 2026-10-23: the Linux pages before
# them looked dated).
URL_NASA="https://www.nasa.gov/"
URL_APOLLO="https://en.wikipedia.org/wiki/Apollo_11"
URL_MDN_JS="https://developer.mozilla.org/en-US/docs/Web/JavaScript"
URL_WEB_APP="https://squoosh.app/"
SAMPLE_APP_PORT=5173
SAMPLE_API_PORT=8797
URL_SAMPLE_APP="http://localhost:$SAMPLE_APP_PORT/"
URL_SAMPLE_API="http://localhost:$SAMPLE_API_PORT/"

# The demo's fixture, in the order setup.steps files it: four essentials, a folder
# with a nested one, Work's other pages, then the four that move to Personal and
# Reading (the last one first). Work's two pins have a strong colour along their top
# edge and nothing that moves on its own (python.org's rotating examples moved, and
# threw the captions' sync). Reading's two pages are the split scene's, one dark along
# the top and one white, at half the window's width too (the TypeScript handbook put a
# white cookie notice on top there), so the row over the split shows two colours.
DEMO_URLS=("$URL_TRENDING_FRONT" "$URL_MDN" "$URL_DDG" "$URL_HN"
           "$URL_MDN_CSS" "$URL_PY_TUTORIAL"
           "$URL_DJANGO" "$URL_PYPI" "$URL_SAMPLE_APP" "$URL_REPO"
           "$URL_LOBSTERS" "$URL_OSM" "$URL_NASA" "$URL_APOLLO")
# The same window without the pages that leave Work, for the stills. A GitHub
# trending page is the one on screen: the repository's own page put a star count
# and a file list on the site that went stale (the owner, 2026-10-23).
WORK_URLS=("$URL_TRENDING_FRONT" "$URL_MDN" "$URL_DDG" "$URL_HN"
           "$URL_MDN_CSS" "$URL_PY_TUTORIAL"
           "$URL_DJANGO" "$URL_PYPI" "$URL_SAMPLE_APP" "$URL_REPO")
DEMO_PARAMS="$FEATURE:pin_tabs/4/folder_tabs/6"
# Every launch: no search-engine chooser over the window (run-mac.sh passes the same).
BROWSER_ARGS=(--disable-search-engine-choice-screen)

# OUT, WORKDIR and LOGS are set by the script that sources this file.
OUT=""
WORKDIR=""
LOGS=""
BUILD="release"
APP=""
SERVER_PIDS=()

# Refuses the repository's docs/ and tooling/ (and the root): pictures go into
# docs/images/readme/ by hand, after a look at each.
refuse_repo_dir() {
  local root
  root="$(cd "$STEDDING_ROOT" && pwd -P)"
  case "$1" in
    ''|/|"$STEDDING_ROOT"|"$STEDDING_ROOT"/docs|"$STEDDING_ROOT"/docs/*|"$STEDDING_ROOT"/tooling|"$STEDDING_ROOT"/tooling/*|"$root"|"$root"/docs|"$root"/docs/*|"$root"/tooling|"$root"/tooling/*)
      die "write the media outside the repository's docs/ and tooling/ (got $1); copy the chosen files into docs/images/readme/ afterwards" ;;
  esac
}

# Makes $1 the output directory: checked, created, absolute, with work/ and logs/ in it.
set_out_dir() {
  local wanted
  [ -n "$1" ] || die "the output directory is missing"
  wanted="$(absolute_path "$1")"
  refuse_repo_dir "$wanted"
  mkdir -p "$wanted" || die "cannot create $wanted"
  OUT="$(cd "$wanted" && pwd -P)"
  # Again with links resolved.
  refuse_repo_dir "$OUT"
  WORKDIR="$OUT/work"
  LOGS="$OUT/logs"
  mkdir -p "$WORKDIR" "$LOGS"
}

# Deletes a directory this run made under $OUT, and nothing else.
remove_ours() {
  case "$1" in
    "$OUT"/?*) rm -rf "$1" ;;
    *) die "refusing to delete $1: not under $OUT" ;;
  esac
}

# An installed copy instead of out/<build>: tooling/drive and tooling/capture-state
# look for the bundle in $CHROMIUM_SRC/out/<build>, so a stand-in directory holding a
# link to the app becomes CHROMIUM_SRC (as tooling/acceptance/mac/run-mac.sh does).
use_app() {
  local app="$1" stand_in="$WORKDIR/stand-in"
  [ -d "$app" ] || die "no app at $app"
  app="$(cd "$app" && pwd -P)"
  remove_ours "$stand_in"
  mkdir -p "$stand_in/out/release"
  ln -s "$app" "$stand_in/out/release/$(basename "$app")"
  CHROMIUM_SRC="$stand_in"
  export CHROMIUM_SRC
  BUILD="release"
}

# The checks before any browser starts: macOS, PyObjC, the app, and no other
# Stedding running (tooling/drive and capture-state check that again per launch).
preflight_browser() {
  [ "$(uname -s)" = Darwin ] || die "macOS only"
  require_pyobjc
  APP="$(find_app_bundle "$CHROMIUM_SRC/out/$BUILD" || true)"
  [ -n "$APP" ] && [ -d "$APP" ] ||
    die "no app bundle in $CHROMIUM_SRC/out/$BUILD: build one (tooling/dev build) or pass --app"
  require_no_other_instance "$APP"
  local size width height
  size="$(python3 "$MEDIA_PY" screen)" || die "cannot read the display's size"
  width="${size%% *}"
  height="$(printf '%s' "$size" | awk '{print $2}')"
  if [ "$width" -lt 1400 ] || [ "$height" -lt 880 ]; then
    die "the main display shows ${width}x${height} points under the menu bar; the window needs 1400x880"
  fi
}

require_ffmpeg() {
  [ -x "$FFMPEG" ] || die "no ffmpeg at $FFMPEG (brew install ffmpeg, or set FFMPEG)"
  [ -x "$FFPROBE" ] || die "no ffprobe at $FFPROBE (it comes with ffmpeg; or set FFPROBE)"
}

# The version of the app the media show, for the manifest.
app_version() {
  plutil -extract CFBundleShortVersionString raw -o - "$APP/Contents/Info.plist" 2>/dev/null || echo unknown
}

# A fresh profile with a fixture's Spaces: seed_profile <dir> <fixture> [media.py seed options].
seed_profile() {
  local dir="$1" fixture="$2"
  shift 2
  remove_ours "$dir"
  python3 -I "$MEDIA_PY" seed "$dir" --fixture "$fixture" \
    --version-file "$STEDDING_ROOT/VERSION" "$@" >>"$LOGS/seed.txt" ||
    die "could not seed $dir (see $LOGS/seed.txt)"
}

# The two local development pages, each on its own port of this machine. A port
# someone else listens on stops the run: their server is not ours to stop.
start_local_servers() {
  local pair port dir pid _
  for pair in "$SAMPLE_APP_PORT:sample-app" "$SAMPLE_API_PORT:sample-api"; do
    port="${pair%%:*}"
    dir="${pair#*:}"
    if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
      die "port $port is in use; stop what listens there (lsof -nP -iTCP:$port -sTCP:LISTEN) and run again"
    fi
    python3 -I -m http.server "$port" --bind 127.0.0.1 --directory "$READMEDIR/pages/$dir" \
      >"$LOGS/server-$port.txt" 2>&1 &
    pid=$!
    SERVER_PIDS+=("$pid")
  done
  for port in "$SAMPLE_APP_PORT" "$SAMPLE_API_PORT"; do
    for _ in $(seq 1 40); do
      curl -fsS -o /dev/null "http://127.0.0.1:$port/" 2>/dev/null && continue 2
      sleep 0.25
    done
    die "the local server on port $port did not answer (see $LOGS/server-$port.txt)"
  done
  log "local pages on ports $SAMPLE_APP_PORT and $SAMPLE_API_PORT"
}

stop_local_servers() {
  local pid
  for pid in ${SERVER_PIDS[@]+"${SERVER_PIDS[@]}"}; do
    kill "$pid" 2>/dev/null || true
  done
  SERVER_PIDS=()
}

# Seconds since anyone last touched the keyboard or the pointer.
hid_idle() {
  ioreg -c IOHIDSystem | awk '/HIDIdleTime/ && !done { print int($NF / 1000000000); done = 1 }'
}

# Waits until nobody has touched the Mac for $1 seconds, at most $2 seconds
# (default ten minutes); then the run may move the pointer and press keys.
wait_for_empty_chair() {
  local need="$1" limit="${2:-600}" waited=0 idle
  log "hands off the Mac now: the run starts after ${need} s with no keyboard or pointer input (Ctrl-C stops it)"
  while :; do
    idle="$(hid_idle)"
    [ -n "$idle" ] || die "cannot read the HID idle time"
    [ "$idle" -ge "$need" ] && return 0
    [ "$waited" -lt "$limit" ] || die "someone kept using the Mac for ${limit} s; nothing was started"
    sleep 1
    waited=$((waited + 1))
  done
}

# Between two driven runs, as run-mac.sh checks: the run's own pointer and keys
# reset the idle time when it ended, so anyone else's input since then shows here.
still_empty() {
  local idle
  sleep 4
  idle="$(hid_idle)"
  if [ "${idle:-0}" -lt 3 ]; then
    warn "someone is using the Mac (idle ${idle:-0} s): stopping before $1"
    exit 3
  fi
}
