#!/usr/bin/env python3
"""Performance measurement harness for the budgets in docs/QUALITY.md.

The budgets are expressed as *overhead relative to vanilla Chromium at the same
pinned version, same build configuration, same hardware*. So this harness is built to
measure two app bundles the same way and subtract, not to produce impressive absolute
numbers. Absolute numbers are reported because they are needed to check the two
absolute budgets, and are otherwise not promises.

What is measured, precisely:

  startup-cold   Time from process launch to the first animation frame painted by a
                 trivial local page, with a brand new profile directory. This is the
                 operational reading of "launch to first accepted input": the browser
                 cannot accept input into a page it has not painted.

  startup-warm   The same measurement against a profile that has already been used and
                 is restoring the ten-site list.

  memory         Resident set size summed across every process belonging to the app
                 bundle, after loading the ten-site list and idling, per QUALITY.md.

Anything requiring Stedding features that do not exist yet (sidebar tab switching,
command bar) is deliberately absent rather than stubbed.

Usage:
    tooling/measure/harness.py all       --app /path/to/Chromium.app --out results.json
    tooling/measure/harness.py startup   --app ... --mode cold --runs 10
    tooling/measure/harness.py memory    --app ... --runs 5
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import plistlib
import queue
import shutil
import socket
import statistics
import subprocess
import sys
import tempfile
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

HERE = Path(__file__).resolve().parent
SITES_FILE = HERE / "sites.txt"

# Time budget for a single run before it is declared failed rather than slow.
RUN_TIMEOUT_S = 90
# QUALITY.md: "after loading a fixed 10-site list and idling 60 s".
IDLE_SECONDS = 60


# --------------------------------------------------------------------- local server

PAINT_PAGE = b"""<!doctype html>
<meta charset="utf-8">
<title>startup probe</title>
<style>html,body{margin:0;height:100%;background:#111}</style>
<body>
<script>
// Report the first frame the compositor actually presents. rAF fires before paint,
// so the report is deferred one further frame to land after it.
requestAnimationFrame(function () {
  requestAnimationFrame(function () {
    navigator.sendBeacon('/painted', '1');
  });
});
</script>
"""


class ProbeHandler(BaseHTTPRequestHandler):
    """Records the moment the browser reports its first painted frame."""

    def do_GET(self):  # noqa: N802 - required by BaseHTTPRequestHandler
        if self.path == "/start":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(PAINT_PAGE)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(PAINT_PAGE)
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):  # noqa: N802
        if self.path == "/painted":
            self.server.painted.put(time.perf_counter())  # type: ignore[attr-defined]
        length = int(self.headers.get("Content-Length") or 0)
        if length:
            self.rfile.read(length)
        self.send_response(204)
        self.end_headers()

    def log_message(self, *_args):
        pass  # Silence the default stderr access log.


def start_probe_server() -> tuple[HTTPServer, int]:
    server = HTTPServer(("127.0.0.1", 0), ProbeHandler)
    server.painted = queue.Queue()  # type: ignore[attr-defined]
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server, server.server_address[1]


# ------------------------------------------------------------------------ app tools

def app_executable(app: Path) -> Path:
    """The main binary inside a macOS .app bundle."""
    info = app / "Contents" / "Info.plist"
    if not info.is_file():
        raise SystemExit(f"{app} does not look like an .app bundle (no Info.plist)")
    with info.open("rb") as fh:
        name = plistlib.load(fh)["CFBundleExecutable"]
    exe = app / "Contents" / "MacOS" / name
    if not exe.is_file():
        raise SystemExit(f"executable {exe} not found")
    return exe


def app_version(app: Path) -> str:
    info = app / "Contents" / "Info.plist"
    with info.open("rb") as fh:
        data = plistlib.load(fh)
    return str(data.get("CFBundleShortVersionString") or data.get("CFBundleVersion") or "unknown")


def base_flags(profile: Path) -> list[str]:
    """Flags shared by every run.

    Kept to the minimum that makes a measurement reproducible. Nothing here changes
    what is being measured: no feature toggles, no renderer tuning, no benchmarking
    mode. A flag that would make the browser faster than a user's browser has no
    business in a baseline.
    """
    return [
        f"--user-data-dir={profile}",
        "--no-first-run",
        "--no-default-browser-check",
        # Suppress the "restore pages?" bubble, which otherwise steals focus and
        # differs between cold and warm runs for reasons unrelated to startup cost.
        "--disable-session-crashed-bubble",
    ]


def wait_for_exit(proc: subprocess.Popen, timeout: float = 20.0) -> None:
    try:
        proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait(timeout=10)


def app_processes(app: Path) -> list[int]:
    """PIDs of every process running out of this app bundle."""
    out = subprocess.run(
        ["ps", "-Ao", "pid=,comm="], capture_output=True, text=True, check=True
    ).stdout
    prefix = str(app.resolve())
    pids = []
    for line in out.splitlines():
        line = line.strip()
        if not line:
            continue
        pid_s, _, comm = line.partition(" ")
        if comm.strip().startswith(prefix):
            try:
                pids.append(int(pid_s))
            except ValueError:
                pass
    return pids


def total_rss_bytes(pids: list[int]) -> int:
    if not pids:
        return 0
    out = subprocess.run(
        ["ps", "-o", "rss=", "-p", ",".join(str(p) for p in pids)],
        capture_output=True, text=True, check=False,
    ).stdout
    # ps reports RSS in kilobytes on macOS.
    return sum(int(v) * 1024 for v in out.split() if v.isdigit())


def read_sites() -> list[str]:
    sites = [
        line.strip()
        for line in SITES_FILE.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.startswith("#")
    ]
    if len(sites) != 10:
        raise SystemExit(f"{SITES_FILE} must contain exactly 10 sites, found {len(sites)}")
    return sites


# ----------------------------------------------------------------------- startup

def measure_startup_once(app: Path, profile: Path, extra_urls: list[str]) -> float | None:
    """One launch. Returns seconds from exec to first painted frame, or None."""
    server, port = start_probe_server()
    try:
        probe_url = f"http://127.0.0.1:{port}/start"
        argv = [str(app_executable(app)), *base_flags(profile), *extra_urls, probe_url]

        # Drain anything stale before timing.
        while not server.painted.empty():
            server.painted.get_nowait()

        launched = time.perf_counter()
        proc = subprocess.Popen(argv, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            painted = server.painted.get(timeout=RUN_TIMEOUT_S)
        except queue.Empty:
            return None
        finally:
            proc.terminate()
            wait_for_exit(proc)
        return painted - launched
    finally:
        server.shutdown()
        server.server_close()


def measure_startup(app: Path, mode: str, runs: int) -> dict:
    """Cold: a new profile per run. Warm: one profile, pre-warmed, reused.

    "Cold" in QUALITY.md means a cold *profile*, not a cold machine. The very first
    launch of a binary additionally pays to fault the executable and its frameworks
    into the OS page cache — measured here at roughly three seconds against one on
    subsequent launches. That cost is real but it is paid once per machine, not once
    per browser start, and including it would swamp the overhead we are trying to
    detect. So one launch is performed and discarded before timing begins.
    """
    samples: list[float] = []
    failures = 0

    with tempfile.TemporaryDirectory(prefix="stedding-warmup-") as tmp:
        print("  warmup launch (discarded) ...", file=sys.stderr)
        measure_startup_once(app, Path(tmp), [])
    time.sleep(2)

    if mode == "cold":
        for i in range(runs):
            with tempfile.TemporaryDirectory(prefix="stedding-cold-") as tmp:
                value = measure_startup_once(app, Path(tmp), [])
            _report(i, runs, value)
            if value is None:
                failures += 1
            else:
                samples.append(value)
    else:
        sites = read_sites()
        with tempfile.TemporaryDirectory(prefix="stedding-warm-") as tmp:
            profile = Path(tmp)
            # Prime the profile: one run that opens the ten sites, so subsequent
            # launches restore a realistic session and a populated disk cache.
            print("  priming profile with the ten-site list ...", file=sys.stderr)
            prime = measure_startup_once(app, profile, sites)
            if prime is None:
                print("  priming run did not report a painted frame", file=sys.stderr)
            time.sleep(3)
            for i in range(runs):
                value = measure_startup_once(app, profile, [])
                _report(i, runs, value)
                if value is None:
                    failures += 1
                else:
                    samples.append(value)
                time.sleep(1)

    return _summarise(samples, failures, unit="s")


def _report(i: int, runs: int, value: float | None) -> None:
    shown = f"{value * 1000:8.1f} ms" if value else "   failed"
    print(f"  run {i + 1:>2}/{runs}: {shown}", file=sys.stderr)


# ------------------------------------------------------------------------- memory

def measure_memory_once(app: Path) -> int | None:
    sites = read_sites()
    with tempfile.TemporaryDirectory(prefix="stedding-mem-") as tmp:
        argv = [str(app_executable(app)), *base_flags(Path(tmp)), *sites]
        proc = subprocess.Popen(argv, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            # Give the ten tabs time to load, then idle exactly as QUALITY.md says.
            time.sleep(30)
            time.sleep(IDLE_SECONDS)
            pids = app_processes(app)
            if not pids:
                return None
            return total_rss_bytes(pids)
        finally:
            proc.terminate()
            wait_for_exit(proc)
            time.sleep(2)


def measure_memory(app: Path, runs: int) -> dict:
    samples: list[float] = []
    failures = 0
    for i in range(runs):
        value = measure_memory_once(app)
        if value:
            samples.append(value / (1024 * 1024))
            print(f"  run {i + 1:>2}/{runs}: {value / (1024 * 1024):8.1f} MB", file=sys.stderr)
        else:
            failures += 1
            print(f"  run {i + 1:>2}/{runs}:    failed", file=sys.stderr)
    return _summarise(samples, failures, unit="MB")


# ------------------------------------------------------------------------ reporting

def _summarise(samples: list[float], failures: int, unit: str) -> dict:
    if not samples:
        return {"unit": unit, "runs": 0, "failures": failures, "median": None}
    return {
        "unit": unit,
        "runs": len(samples),
        "failures": failures,
        "median": round(statistics.median(samples), 4),
        "min": round(min(samples), 4),
        "max": round(max(samples), 4),
        "stdev": round(statistics.stdev(samples), 4) if len(samples) > 1 else 0.0,
        "samples": [round(s, 4) for s in samples],
    }


def environment(app: Path) -> dict:
    def sh(*cmd: str) -> str:
        try:
            return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            return "unknown"

    return {
        "app": str(app),
        "app_version": app_version(app),
        "machine": sh("sysctl", "-n", "machdep.cpu.brand_string"),
        "cpu_count": os.cpu_count(),
        "memory_bytes": int(sh("sysctl", "-n", "hw.memsize") or 0),
        "os": f"{platform.system()} {sh('sw_vers', '-productVersion')} {platform.machine()}",
        "measured_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("what", choices=["all", "startup", "memory"])
    parser.add_argument("--app", required=True, type=Path, help="path to a .app bundle")
    parser.add_argument("--mode", choices=["cold", "warm"], default="cold")
    parser.add_argument("--runs", type=int, default=None)
    parser.add_argument("--out", type=Path, help="write results as JSON here")
    args = parser.parse_args()

    app = args.app.resolve()
    if not app.is_dir():
        raise SystemExit(f"no app bundle at {app}")
    if platform.system() != "Darwin":
        raise SystemExit("this harness currently supports macOS only")
    if shutil.which("ps") is None:
        raise SystemExit("ps not found")

    results: dict = {"environment": environment(app), "measurements": {}}
    print(f"app:     {app}", file=sys.stderr)
    print(f"version: {results['environment']['app_version']}", file=sys.stderr)

    if args.what in ("all", "startup"):
        for mode in (["cold", "warm"] if args.what == "all" else [args.mode]):
            runs = args.runs or 10  # QUALITY.md: median of 10.
            print(f"\nstartup ({mode}), {runs} runs:", file=sys.stderr)
            results["measurements"][f"startup_{mode}"] = measure_startup(app, mode, runs)

    if args.what in ("all", "memory"):
        runs = args.runs or 5  # QUALITY.md: median of 5.
        print(f"\nmemory, 10 tabs, {runs} runs (each ~{30 + IDLE_SECONDS}s):", file=sys.stderr)
        results["measurements"]["memory_10_tabs"] = measure_memory(app, runs)

    text = json.dumps(results, indent=2)
    if args.out:
        args.out.write_text(text + "\n", encoding="utf-8")
        print(f"\nwrote {args.out}", file=sys.stderr)
    else:
        print(text)

    incomplete = [k for k, v in results["measurements"].items() if v.get("median") is None]
    if incomplete:
        print(f"\nno usable samples for: {', '.join(incomplete)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
