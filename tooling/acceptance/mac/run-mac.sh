#!/bin/bash
# The live half of BACKLOG S-173 on the Mac: the core-loop acceptance script (TST-6),
# the drags (TST-7) and the core keyboard (TST-9), through tooling/drive. It moves the
# real pointer and presses real keys: run it only with nobody at the Mac, and with your
# own Stedding closed (tooling/drive refuses to start while any copy runs).
#
# Usage:
#   run-mac.sh layout            seed a profile and run the fixture only; read the
#                                coordinates marked GUESS in templates/ from
#                                shots/setup-02-open.png and shots/setup-03-rail.png
#   run-mac.sh all [app]         TST-6 (three runs), TST-7 and TST-9, each on a fresh
#                                profile of its own
#   run-mac.sh tst6|tst7|tst9 [app]
#
# [app] drives an installed copy (e.g. /Applications/Stedding.app) instead of
# out/release: tooling/drive looks for the bundle in $CHROMIUM_SRC/out/release, so a
# stand-in directory holding a link to the app is passed as CHROMIUM_SRC.
# The steps are rendered from templates/ into the run's directory ($RUN_DIR, default
# runs/<date-time> here), with its shots and the pages' paths filled in. The repository
# is $STEDDING_REPO, or three levels up when this sits in tooling/acceptance/mac.
# Written for macOS's own bash 3.2.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd -P)"
REPO="${STEDDING_REPO:-$(cd "$HERE/../../.." 2>/dev/null && pwd -P)}"
[ -x "$REPO/tooling/drive" ] || { echo "no tooling/drive under $REPO: set STEDDING_REPO"; exit 2; }
RUN="${RUN_DIR:-$HERE/runs/$(date +%Y%m%d-%H%M%S)}"
URLS=()
for name in a b c d e f; do URLS+=("file://$HERE/pages/$name.html"); done
# No network beyond the pages: Chromium's time query to clients2.google.com, from a newly
# signed copy, raises a firewall prompt that stays over the screen and stops the driver
# (docs/HANDOFF.md trap 85).
EXTRA=(--disable-search-engine-choice-screen --disable-features=NetworkTimeServiceQuerying
  --disable-background-networking --disable-component-update)

mode="${1:-}"
app="${2:-}"
case "$mode" in
  layout|tst6|tst7|tst9|all) ;;
  *) sed -n '2,22p' "$0"; exit 2 ;;
esac
if [ -n "$app" ]; then
  [ -d "$app" ] || { echo "no app at $app"; exit 2; }
  mkdir -p "$RUN/stand-in/out/release"
  ln -sfn "$app" "$RUN/stand-in/out/release/$(basename "$app")"
  export CHROMIUM_SRC="$RUN/stand-in"
fi

mkdir -p "$RUN/steps" "$RUN/shots" "$RUN/logs" "$RUN/profiles"
for template in "$HERE"/templates/*.steps; do
  sed -e "s#@SHOTS@#$RUN/shots#g" -e "s#@PAGES@#$HERE/pages#g" "$template" \
    > "$RUN/steps/$(basename "$template")"
done

# Our own pointer and keys reset the HID idle time; anyone else's input since the
# previous run ended stops the next one.
idle() { ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}'; }

# drive <profile> <steps name> [args...]: one tooling/drive run, its output in logs/.
drive() {
  local profile="$1" name="$2" status=0 i
  shift 2
  sleep 4
  i="$(idle)"
  if [ "$i" -lt 3 ]; then
    echo "someone is using the Mac (idle ${i}s): stopping before $name"
    exit 3
  fi
  (cd "$REPO" && tooling/drive "$profile" "$RUN/steps/$name.steps" "$@") \
    > "$RUN/logs/$(basename "$profile")-$name.log" 2>&1 || status=$?
  echo "$name on $(basename "$profile"): exit $status"
  [ "$status" -eq 0 ] || exit "$status"
}

# fresh <name>: a seeded profile with the fixture built by 10-setup, in $PROFILE. Each
# part's fixture keeps its own captures (<name>-setup-*.png): with one set of names, `all`
# kept only the last part's.
fresh() {
  PROFILE="$RUN/profiles/$1"
  python3 -I "$HERE/seed-profile.py" "$PROFILE" || exit 1
  sed -e "s#$RUN/shots/setup-#$RUN/shots/$1-setup-#g" "$RUN/steps/10-setup.steps" \
    > "$RUN/steps/10-setup-$1.steps"
  drive "$PROFILE" "10-setup-$1" "${EXTRA[@]}" "${URLS[@]}"
}

if [ "$mode" = layout ]; then
  fresh layout
fi
if [ "$mode" = tst6 ] || [ "$mode" = all ]; then
  fresh tst6
  drive "$PROFILE" 20-core-loop "${EXTRA[@]}"
  # Step 11: the run above ended with tooling/drive's quit; this one is the relaunch.
  drive "$PROFILE" 30-relaunch "${EXTRA[@]}"
fi
if [ "$mode" = tst7 ] || [ "$mode" = all ]; then
  fresh tst7
  # The drags hold the pointer on the rail longer than its hover pause: with
  # expand-on-hover on, the rail opens under the drag and the rail half tests
  # the open sidebar again. The setting goes off for this run.
  python3 -I - "$PROFILE/Default/Preferences" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d.setdefault("vertical_tabs", {})["expand_on_hover"] = False
json.dump(d, open(p, "w"))
PY
  drive "$PROFILE" 40-tst7-drags "${EXTRA[@]}"
fi
if [ "$mode" = tst9 ] || [ "$mode" = all ]; then
  fresh tst9
  drive "$PROFILE" 50-tst9-keys "${EXTRA[@]}"
fi
echo "run: $RUN (shots/, logs/)"
