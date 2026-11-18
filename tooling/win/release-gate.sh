#!/usr/bin/env bash
# The Windows release gate on the PC, in one detached job: every build, the whole suites on the
# shipping build, the installer, the update from the previous release, the installer's cycle,
# the acceptance parts, then the DCHECK and ASan builds' suites. One log, one finish line.
#
#   tooling/win/release-gate.sh <version> <previous version> [--tree <hash>] [--no-drive] [--no-sanitizers]
#
# Start it in the operator's session, detached (docs/AGENT-LOOP.md, "Long jobs"; trap 40):
#   powershell -File tooling\win\run-in-session.ps1 -Script tooling\win\release-gate.sh -Arguments '0.6.1 0.6.0'
# Wait for its log, %TEMP%\stedding-gate\gate-<version>.log, to end in GATE_DONE. Markers on
# the way: BUILDS_DONE, RELEASE_DONE, INSTALLER_DONE, ACCEPTANCE_DONE, CHECKS_DONE, ASAN_DONE.
#
# --tree <hash>    stop unless the checkout's tree is that one (the Mac's, after a bundle sync)
# --no-drive       skip the acceptance parts, which press real keys (ask the operator first;
#                  AGENTS.md, red lines)
# --no-sanitizers  skip the win-checks and win-asan builds and their suites
#
# Needs STEDDING_CHROMIUM_SRC (the checkout, as Windows writes it), STEDDING_DEPOT_TOOLS and
# STEDDING_VPYTHON_ROOT, as tooling/win/build.ps1 does. dist\Stedding-<previous>-win-x64.exe must be
# there for the update and the cycle (`gh release download v<previous> -p '*win-x64.exe' -D dist`).
# VERSION is set to <version> for the run and put back at the end; a run that is killed leaves
# it set: `git checkout -- VERSION`.
set -u

usage() { sed -n '6,7p' "$0" | sed 's/^# *//' >&2; exit 2; }
[ $# -ge 2 ] || usage
version="$1" from="$2"
shift 2
tree="" drive=1 sanitizers=1
while [ $# -gt 0 ]; do
  case "$1" in
    --tree) tree="${2:-}"; shift ;;
    --no-drive) drive=0 ;;
    --no-sanitizers) sanitizers=0 ;;
    *) usage ;;
  esac
  shift
done

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
: "${STEDDING_CHROMIUM_SRC:?set it to the Chromium checkout, as Windows writes it}"
: "${STEDDING_DEPOT_TOOLS:?set it as for tooling/win/build.ps1}"
: "${STEDDING_VPYTHON_ROOT:?set it as for tooling/win/build.ps1}"
CHROMIUM_SRC="$(cygpath -u "$STEDDING_CHROMIUM_SRC")"
export CHROMIUM_SRC STEDDING_CHROMIUM_SRC STEDDING_DEPOT_TOOLS STEDDING_VPYTHON_ROOT
export STEDDING_TEST_BUDGET_S="${STEDDING_TEST_BUDGET_S:-18000}"
D="$(cygpath -u "${TEMP:-/tmp}")/stedding-gate"
mkdir -p "$D"
LOG="$D/gate-$version.log"
exec >"$LOG" 2>&1
win() { cygpath -w "$1"; }
mark() { echo "== $* $(date +%T)"; }

PICK='==> [a-z_]+: [0-9]+ tests|SUCCESS|tests? (failed|crashed|timed out)|^\[  FAILED  \]|^    [A-Za-z]+Test\.|Tests took|again alone|fails alone|passed alone|DCHECK|dangling|AddressSanitizer|Check failed'

mark "gate $from -> $version, tree $(git -C "$CHROMIUM_SRC" rev-parse 'HEAD^{tree}')"
if [ -n "$tree" ] && [ "$(git -C "$CHROMIUM_SRC" rev-parse 'HEAD^{tree}')" != "$tree" ]; then
  mark "the checkout is not on tree $tree: stop"
  mark GATE_DONE
  exit 1
fi
cd "$ROOT" || exit 1
mark "repo $(git log --oneline -1 | cut -c1-80)"
old_version="$(cat VERSION)"
printf '%s\n' "$version" >VERSION
restore_version() { printf '%s\n' "$old_version" >VERSION; }
trap restore_version EXIT

build() {  # <config> <jobs> <targets>
  mark "build $1 $3"
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(win "$ROOT/tooling/win/build-until-done.ps1")" \
    -Config "$1" -Jobs "$2" -ChunkMinutes 60 -MaxChunks 8 -Src "$STEDDING_CHROMIUM_SRC" -Targets "$3" 2>&1 | tail -1
  if ! grep -a 'SUPERVISOR_EXIT=' "$CHROMIUM_SRC/out/$1/supervisor.log" | tail -1 | grep -q 'SUPERVISOR_EXIT=0'; then
    mark "$1 BUILD FAILED"
    grep -a -E 'error' "$CHROMIUM_SRC/out/$1/build.log" | grep -v clang-cl | tail -20
    return 1
  fi
}
legs() {  # <config> <leg>...
  local cfg="$1" leg
  shift
  for leg in "$@"; do
    STEDDING_TEST_OUT="$cfg" STEDDING_TEST_LOG="$D/gate-$version-$cfg-$leg" \
      tooling/dev test "$leg" --no-build >"$D/gate-$version-$cfg-$leg.out" 2>&1
    mark "$cfg $leg exit=$?"
    grep -aE "$PICK" "$D/gate-$version-$cfg-$leg.out" | cut -c1-240 | tail -40
  done
}
clean() {
  local _ r
  for _ in 1 2 3; do
    r="$(powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(win "$ROOT/tooling/win/leftovers.ps1")" \
      -Clean -Src "$STEDDING_CHROMIUM_SRC" 2>&1 | tr -d '\r')"
    printf '%s\n' "$r" | tail -1
    printf '%s\n' "$r" | grep -q 'nothing left over' && break
    sleep 15
  done
}
run_ps() { powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(win "$ROOT/tooling/win/$1")" "${@:2}"; }

ok_release=0 ok_checks=0 ok_asan=0
build win-release 14 chrome,unit_tests,stedding_browser_tests,mini_installer && ok_release=1
if [ "$sanitizers" -eq 1 ]; then
  build win-checks 14 unit_tests,stedding_browser_tests && ok_checks=1
  # ASan at 10 jobs: more ran the PC out of memory.
  build win-asan 10 unit_tests,stedding_browser_tests && ok_asan=1
fi
mark "BUILDS_DONE release=$ok_release checks=$ok_checks asan=$ok_asan"
if [ "$ok_release" -ne 1 ]; then
  mark GATE_DONE
  exit 1
fi
clean
legs win-release unit browser
mark RELEASE_DONE

run_ps package-installer.ps1 -Config win-release -Src "$STEDDING_CHROMIUM_SRC" 2>&1 | tail -2
mark "packaged: $(cat "dist/Stedding-$version-win-x64.exe.sha256" 2>/dev/null)"
if [ -f "dist/Stedding-$from-win-x64.exe" ]; then
  run_ps installer-gate.ps1 -Version "$version" -From "$from" -Log "$(win "$D/installer-$version.log")"
  grep -a -E 'refusing|installed:|after install|pill:|before the update|pins after|pin store|application dir|uninstall entry|^---|INSTALLER_GATE_DONE' \
    "$D/installer-$version.log" | cut -c1-240
else
  mark "no dist/Stedding-$from-win-x64.exe: the update and the cycle did not run"
fi
mark INSTALLER_DONE

if [ "$drive" -eq 1 ]; then
  sleep 120
  for part in tst7 tst9 tst6; do
    run_ps quiet-desktop.ps1
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(win "$ROOT/tooling/acceptance/win/s173-live.ps1")" \
      -Part "$part" -Exe "${LOCALAPPDATA:?}\\Stedding\\Application\\chrome.exe" 2>&1 | tail -1
    results="$(cygpath -u "$TEMP")/stedding-s173/results.txt"
    cp "$results" "$D/gate-$version-acceptance-$part.txt" 2>/dev/null
    mark "acceptance $part: pass=$(grep -a -c ' PASS ' "$results") fail=$(grep -a -c ' FAIL ' "$results")"
    grep -a -E ' FAIL |REFUSED' "$results" | cut -c1-200 | head -12
    sleep 90
  done
fi
mark ACCEPTANCE_DONE

if [ "$ok_checks" -eq 1 ]; then
  clean
  legs win-checks unit browser
fi
mark CHECKS_DONE
if [ "$ok_asan" -eq 1 ]; then
  clean
  legs win-asan unit browser
fi
mark ASAN_DONE
clean
mark GATE_DONE
