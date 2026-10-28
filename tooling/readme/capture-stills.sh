#!/usr/bin/env bash
# The README's stills, each one tooling/capture-state run: no pointer, no keys, no
# focus change, so this runs while someone works at the Mac (macOS only).
#
# Usage:
#   tooling/readme/capture-stills.sh <out-dir> [options] [still ...]
#   tooling/readme/capture-stills.sh --list
#
# With no still named, every still of the current build is taken; --with-new adds
# the stills of this round's features (dark-pages, local-tabs, isolated-space,
# web-app), which show what they should only once those features are built.
#
# Options:
#   --app PATH        photograph an installed copy (e.g. /Applications/Stedding.app)
#                     instead of out/<build>; quit your own Stedding first either way
#   --build DIR       the output directory under out/ (default release); the capture
#                     params need a build that is not an official one
#   --scheme S        light (default) or dark, for every still but hero-dark
#   --with-new        also the stills of this round's features
#                     file: the step lists that profile's Spaces and counts
#   --keep-profiles   keep the seeded profiles (work/profiles/) for a look afterwards
#   --settle S        wait S seconds for the pages before each capture (capture-state's
#                     default, 18, can leave a tab's icon still loading on a slow page)
#
# Writes, under <out-dir>:
#   raw/<still>.png      the window as captured (Retina size, transparent corners),
#                        raw/<still>-2.png for a second window, raw/<still>.log the
#                        browser's log
#   <still>.png          1800 px wide, the size docs/images/readme/ keeps
#   captures.tsv         still, file, app version, date, fixture, arguments
#   logs/                each capture-state run's output
# Running it again replaces what it wrote; nothing outside <out-dir> is touched
# (capture-state's own temporary profile is deleted by capture-state).
#
# The window's state comes from three places, all of them input-free: a seeded
# profile (media.py seed: the Spaces with their names, colours and icons, a Space
# with its own session, the colour scheme, the rail, dark pages), passed to the
# browser as a second --user-data-dir that overrides capture-state's empty one
# (Chromium keeps the last value of a repeated switch); the SteddingArcStyleWindow
# params (pin_tabs, folder_tabs, space_pin_tabs, drift_tabs, open_command_bar);
# and Chromium switches (--incognito, --stedding-welcome=<step>, --app=<url>).
# Each still's settings are a first choice: look at every image after the first
# run and adjust its function below.

# shellcheck source-path=SCRIPTDIR
# shellcheck source=./common.sh
. "$(cd "$(dirname "$0")" && pwd -P)/common.sh"

STILLS=(hero hero-dark spaces command-bar folders pins rail private
        welcome-search welcome-import welcome-appearance welcome-behaviour
        welcome-default welcome-keys)
NEW_STILLS=(dark-pages local-tabs isolated-space web-app)

SCHEME="light"
KEEP_PROFILES=0
SETTLE=""
FAILED=""
PROFILE=""
RAW=""
META=""

# One capture: shoot <still> <fixture or -> [capture-state options] [browser args and URLs].
# The browser args start at the first argument capture-state does not know.
shoot() {
  local name="$1" fixture="$2" status=0 extra
  shift 2
  log "still: $name"
  rm -f "$RAW/$name.png" "$RAW/$name.log" "$OUT/$name.png"
  for extra in "$RAW/$name"-[0-9].png "$OUT/$name"-[0-9].png; do
    [ -f "$extra" ] && rm -f "$extra"
  done
  "$STEDDING_ROOT/tooling/capture-state" --out "$RAW/$name.png" --build "$BUILD" \
    --size 1400x880 ${SETTLE:+--settle "$SETTLE"} "$@" >"$LOGS/$name.txt" 2>&1 || status=$?
  if [ -n "$PROFILE" ] && [ "$KEEP_PROFILES" -eq 0 ]; then
    remove_ours "$PROFILE"
  fi
  PROFILE=""
  if [ "$status" -ne 0 ] || [ ! -f "$RAW/$name.png" ]; then
    warn "$name: capture-state exited $status; see $LOGS/$name.txt and $RAW/$name.log"
    FAILED="$FAILED $name"
    return 0
  fi
  fit "$RAW/$name.png" "$OUT/$name.png"
  for extra in "$RAW/$name"-[0-9].png; do
    [ -f "$extra" ] || continue
    fit "$extra" "$OUT/$(basename "$extra")"
  done
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$name.png" "$(app_version)" \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$fixture" "$*" > "$META/$name.tsv"
}

# The README's width: 1800 px, from the 2800 px a Retina capture is. A smaller
# window (a web app's) is copied as it is.
fit() {
  local width
  width="$(sips -g pixelWidth "$1" 2>/dev/null | awk '/pixelWidth/ { print $2 }')"
  if [ -n "$width" ] && [ "$width" -gt 1800 ]; then
    sips --resampleWidth 1800 "$1" --out "$2" >/dev/null || die "sips could not resize $1"
  else
    cp "$1" "$2"
  fi
}

# A seeded profile for the next shoot: seeded <still> <fixture> [media.py seed options].
# Sets PROFILE; its path goes to the browser as --user-data-dir.
seeded() {
  local name="$1" fixture="$2"
  shift 2
  PROFILE="$WORKDIR/profiles/$name"
  seed_profile "$PROFILE" "$fixture" "$@"
}

# ---------------------------------------------------------------- the stills

# The window as a person keeps it: four essentials, a folder holding a nested one,
# Work's pages with the local sample app among them, three Spaces at the foot.
still_hero() {
  seeded hero demo --scheme "$SCHEME"
  shoot hero demo --features "$FEATURE:pin_tabs/4/folder_tabs/6" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" "${WORK_URLS[@]}"
}

# The same in dark: the README shows it to a reader whose GitHub is dark.
still_hero_dark() {
  seeded hero-dark demo --scheme dark
  shoot hero-dark demo --features "$FEATURE:pin_tabs/4/folder_tabs/6" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" "${WORK_URLS[@]}"
}

# Five Spaces, each with its colour and icon, in the switcher.
still_spaces() {
  seeded spaces spaces --scheme "$SCHEME"
  shoot spaces spaces --features "$FEATURE:pin_tabs/2" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" \
    "$URL_REPO" "$URL_MDN" "$URL_DJANGO" "$URL_PYTHON" "$URL_TRENDING"
}

# The command bar open over the page, listing the open tabs.
still_command_bar() {
  seeded command-bar demo --scheme "$SCHEME"
  shoot command-bar demo --features "$FEATURE:pin_tabs/4/open_command_bar/true" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" "${WORK_URLS[@]}"
}

# Two essentials, then a folder of two pages holding a nested folder of one.
still_folders() {
  seeded folders demo --scheme "$SCHEME"
  shoot folders demo --features "$FEATURE:pin_tabs/2/folder_tabs/5" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" \
    "$URL_REPO" "$URL_MDN" "$URL_MDN_CSS" "$URL_MDN_JS" "$URL_PY_TUTORIAL" \
    "$URL_DJANGO" "$URL_TRENDING"
}

# Three pins of the Space, the first one wandered off to the next one's page: the
# slash between its icon and the page it shows now.
still_pins() {
  seeded pins demo --scheme "$SCHEME"
  shoot pins demo --features "$FEATURE:space_pin_tabs/3/drift_tabs/1" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" \
    "$URL_DJANGO" "$URL_PY_TUTORIAL" "$URL_REPO" "$URL_MDN_CSS" "$URL_TRENDING"
}

# The sidebar closed to the rail, the address row still across the top.
still_rail() {
  seeded rail demo --scheme "$SCHEME" --collapsed
  shoot rail demo --features "$FEATURE:pin_tabs/4/folder_tabs/6" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" "${WORK_URLS[@]}"
}

# A private window in its own colours (capture-state's own empty profile).
still_private() {
  shoot private - --seed "$SCHEME" "${BROWSER_ARGS[@]}" --incognito "$URL_REPO"
}

# The welcome flow on one step (capture-state's own empty profile). The dialog may
# come as a second window: raw/<still>-2.png.
welcome() {
  local step="$1" url="${2:-$URL_REPO}"
  shoot "welcome-$step" - --seed "$SCHEME" "${BROWSER_ARGS[@]}" \
    "--stedding-welcome=$step" "$url"
}
still_welcome_search() { welcome search; }
still_welcome_appearance() { welcome appearance; }
still_welcome_behaviour() { welcome behaviour; }
still_welcome_default() { welcome default; }
still_welcome_keys() { welcome keys; }
# The import step reads the Arc sidebar under the home folder, and showed this Mac's
# own profile (docs/history/plan-2026-09-26.md DOC-P18; a beta's README did, its counts
# included, until 2026-10-22). It runs with a scratch home holding a made-up sidebar
# (arc-demo-sidebar.py), whatever this Mac has.
still_welcome_import() {
  local home="$RAW/arc-home"
  rm -rf "$home"
  python3 "$STEDDING_ROOT/tooling/readme/arc-demo-sidebar.py" "$home" >/dev/null ||
    { warn "welcome-import: could not write the demo Arc sidebar"; FAILED="$FAILED welcome-import"; return 0; }
  # GitHub's trending page behind the dialog: the repository's file list showed under
  # the dialog, and GitHub's home page shows its advertising around it.
  STEDDING_LAUNCH_ENV="HOME=$home CFFIXED_USER_HOME=$home" welcome import "$URL_TRENDING_FRONT"
  rm -rf "$home"
}

# This round's: dark pages on (Chromium's own preference is the switch). The page on
# screen is Hacker News (one day's front page, URL_HN_DAY), white by design with no dark
# theme of its own, so what is dark is dark pages' doing; GitHub would show its own.
still_dark_pages() {
  seeded dark-pages demo --scheme "$SCHEME" --dark-pages
  shoot dark-pages demo --features "$FEATURE:pin_tabs/4" \
    "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" \
    "$URL_HN_DAY" "$URL_REPO" "$URL_MDN" "$URL_DDG" "$URL_DJANGO" "$URL_PYTHON" "$URL_TRENDING"
}

# This round's: two pages on local servers, the first on screen (the outline shows
# on the tab on screen). CONFIRM once built: the dashed outline and host:port.
still_local_tabs() {
  seeded local-tabs demo --scheme "$SCHEME"
  shoot local-tabs demo "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" \
    "$URL_SAMPLE_APP" "$URL_SAMPLE_API" "$URL_REPO" "$URL_DJANGO" "$URL_PYTHON"
}

# This round's: the Space on screen has its own session (the fixture puts Personal
# first). CONFIRM once built: the mark on its chip and title row.
still_isolated_space() {
  seeded isolated-space isolated --scheme "$SCHEME"
  shoot isolated-space isolated "--user-data-dir=$PROFILE" "${BROWSER_ARGS[@]}" \
    "$URL_OSM" "$URL_WIKI_COOKIE" "$URL_LOBSTERS"
}

# This round's: a page in a window of its own. Chromium's --app window stands in
# for an app made from a page. CONFIRM once built: an app made with the feature has
# the same window; if not, take this still from an installed app instead.
still_web_app() {
  shoot web-app - --seed "$SCHEME" "${BROWSER_ARGS[@]}" "--app=$URL_WEB_APP"
}

# ------------------------------------------------------------------------ main

cleanup() {
  stop_local_servers
}

main() {
  local wanted=() name fn app="" done_list=""
  if [ "${1:-}" = "--list" ]; then
    printf '%s\n' "${STILLS[@]}" "${NEW_STILLS[@]}"
    exit 0
  fi
  case "${1:-}" in
    ''|-h|--help|-*) sed -n '2,44p' "$0"; exit 2 ;;
  esac
  set_out_dir "$1"
  shift
  while [ $# -gt 0 ]; do
    case "$1" in
      --app) app="${2:-}"; shift 2 ;;
      --build) BUILD="${2:-}"; shift 2 ;;
      --scheme) SCHEME="${2:-}"; shift 2 ;;
      --with-new) wanted+=("${STILLS[@]}" "${NEW_STILLS[@]}"); shift ;;
      --keep-profiles) KEEP_PROFILES=1; shift ;;
      --settle) SETTLE="${2:-}"; shift 2 ;;
      -*) die "unknown option $1" ;;
      *) wanted+=("$1"); shift ;;
    esac
  done
  case "$SCHEME" in light|dark) ;; *) die "--scheme takes light or dark" ;; esac
  [ "${#wanted[@]}" -gt 0 ] || wanted=("${STILLS[@]}")
  for name in "${wanted[@]}"; do
    case " ${STILLS[*]} ${NEW_STILLS[*]} " in
      *" $name "*) ;;
      *) die "no still named $name (--list shows them)" ;;
    esac
  done

  [ -z "$app" ] || use_app "$app"
  preflight_browser
  RAW="$OUT/raw"
  META="$WORKDIR/meta"
  mkdir -p "$RAW" "$META" "$WORKDIR/profiles"
  trap cleanup EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  start_local_servers
  log "photographing $(basename "$APP") $(app_version) into $OUT"

  for name in "${wanted[@]}"; do
    case " $done_list " in *" $name "*) continue ;; esac
    done_list="$done_list $name"
    fn="still_$(printf '%s' "$name" | tr '-' '_')"
    "$fn"
  done

  {
    printf 'still\tfile\tapp version\ttaken (UTC)\tfixture\targuments\n'
    for name in "${STILLS[@]}" "${NEW_STILLS[@]}"; do
      [ -f "$META/$name.tsv" ] && cat "$META/$name.tsv"
    done
  } > "$OUT/captures.tsv"
  [ -z "$FAILED" ] || warn "not taken:$FAILED"
  log "stills in $OUT (captures.tsv lists them); look at each before it goes into docs/images/readme/"
  [ -z "$FAILED" ]
}

main "$@"
