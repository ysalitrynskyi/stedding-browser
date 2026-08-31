#!/usr/bin/env python3
"""Capture a single on-screen window by owner name.

Takes the largest window owned by a process whose name contains `owner`, and
writes a PNG of just that window. Windows on another macOS Space, or behind
other windows, still capture correctly, so this never needs to raise the window
and never catches anything else on the screen.
"""

import subprocess
import sys

from Quartz import (  # type: ignore[import-not-found]
    CGWindowListCopyWindowInfo,
    kCGNullWindowID,
    kCGWindowListOptionAll,
)

# Below this, a "window" is a shadow, a tooltip, or an off-screen 1x1 helper.
MIN_WINDOW_AREA = 100_000


def largest_window_for(owner: str) -> int | None:
    best_id, best_area = None, 0
    for window in CGWindowListCopyWindowInfo(kCGWindowListOptionAll,
                                             kCGNullWindowID):
        if owner.lower() not in window.get("kCGWindowOwnerName", "").lower():
            continue
        bounds = window.get("kCGWindowBounds", {})
        area = bounds.get("Width", 0) * bounds.get("Height", 0)
        if area >= MIN_WINDOW_AREA and area > best_area:
            best_id, best_area = int(window["kCGWindowNumber"]), area
    return best_id


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(f"usage: {argv[0]} OWNER OUTPUT.png", file=sys.stderr)
        return 2
    owner, output = argv[1], argv[2]

    window_id = largest_window_for(owner)
    if window_id is None:
        print(f"no window owned by {owner!r}", file=sys.stderr)
        return 1

    # -x: no capture sound. -o: no window shadow, so the image is the window.
    subprocess.run(["screencapture", "-x", "-o", "-l", str(window_id), output],
                   check=True)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
