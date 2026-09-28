#!/usr/bin/env python3
"""Capture one on-screen window owned by a pid.

Takes the largest window owned by that pid or a descendant, and writes a PNG
of just that window. Windows on another macOS Space, or behind other windows,
still capture correctly, so this never needs to raise the window and never
catches anything else on the screen.

    tooling/capture-window.py PID OUTPUT.png
"""

import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from window_by_pid import parse_pid, windows_for_pid

# Below this, a "window" is a shadow, a tooltip, or an off-screen helper the
# pid filter did not already drop. 1x1 and menu-bar-height windows are dropped
# in window_by_pid.py.
MIN_WINDOW_AREA = 100_000


def largest_window_for(pid: int) -> int | None:
    best_id, best_area = None, 0
    for window in windows_for_pid(pid):
        bounds = window.get("kCGWindowBounds", {})
        area = bounds.get("Width", 0) * bounds.get("Height", 0)
        if area >= MIN_WINDOW_AREA and area > best_area:
            best_id, best_area = int(window["kCGWindowNumber"]), area
    return best_id


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(f"usage: {argv[0]} PID OUTPUT.png", file=sys.stderr)
        return 2
    try:
        pid = parse_pid(argv[1])
    except ValueError as exc:
        print(exc, file=sys.stderr)
        return 2

    window_id = largest_window_for(pid)
    if window_id is None:
        print(f"no window owned by pid {pid}", file=sys.stderr)
        return 1

    # -x: no capture sound. -o: no window shadow, so the image is the window.
    subprocess.run(["screencapture", "-x", "-o", "-l", str(window_id), argv[2]],
                   check=True)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
