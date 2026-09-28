#!/usr/bin/env python3
"""Quartz windows owned by one pid, or by a process it started.

Callers pass the pid they launched. Nothing here matches on owner name, so a
second Stedding on the same Mac is not a window of this one.
"""

from __future__ import annotations

import subprocess
import sys

from Quartz import (  # type: ignore[import-not-found]
    CGWindowListCopyWindowInfo,
    kCGNullWindowID,
    kCGWindowListOptionAll,
)


def parse_pid(value: object) -> int:
    """A process id, or ValueError. A name is not a pid."""
    if isinstance(value, bool) or value is None:
        raise ValueError("pid is missing; refusing")
    if isinstance(value, int):
        if value <= 0:
            raise ValueError("pid is missing; refusing")
        return value
    text = str(value).strip()
    if not text.isdigit():
        raise ValueError(f"expected a pid, got {text!r}; refusing")
    pid = int(text)
    if pid <= 0:
        raise ValueError("pid is missing; refusing")
    return pid


def pids_in_tree(root: int) -> set[int]:
    """`root` and every descendant, from one `ps` listing."""
    root = parse_pid(root)
    listing = subprocess.run(
        ["ps", "-ax", "-o", "pid=,ppid="],
        check=True, capture_output=True, text=True,
    ).stdout
    children: dict[int, list[int]] = {}
    for line in listing.splitlines():
        parts = line.split()
        if len(parts) < 2:
            continue
        try:
            pid, ppid = int(parts[0]), int(parts[1])
        except ValueError:
            continue
        children.setdefault(ppid, []).append(pid)
    found: set[int] = set()
    stack = [root]
    while stack:
        current = stack.pop()
        if current in found:
            continue
        found.add(current)
        stack.extend(children.get(current, ()))
    return found


def menu_bar_height() -> float:
    """Main-display menu bar in points. A bad read falls back to 25."""
    try:
        from AppKit import NSScreen  # type: ignore[import-not-found]
        screen = NSScreen.mainScreen()
        if screen is not None:
            frame = screen.frame()
            visible = screen.visibleFrame()
            height = float(frame.size.height - (visible.origin.y + visible.size.height))
            if 0 < height <= 80:
                return height
    except Exception:
        pass
    return 25.0


def is_helper_window(bounds: dict, menu_height: float) -> bool:
    """1x1 placeholders, and strips only as tall as the menu bar."""
    try:
        width = float(bounds.get("Width", 0) or 0)
        height = float(bounds.get("Height", 0) or 0)
    except (TypeError, ValueError):
        return True
    if width <= 1 or height <= 1:
        return True
    if height <= menu_height + 0.5:
        return True
    return False


def windows_for_pid(pid: int) -> list:
    """Quartz window dicts whose owner pid is `pid` or a descendant.

    Off-screen windows are included (another Space still captures). Callers
    apply their own size and on-screen floors on top of the helper-window skip.
    """
    owners = pids_in_tree(pid)
    menu_height = menu_bar_height()
    info = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID) or []
    found = []
    for window in info:
        try:
            owner = int(window.get("kCGWindowOwnerPID", -1))
        except (TypeError, ValueError):
            continue
        if owner not in owners:
            continue
        bounds = window.get("kCGWindowBounds") or {}
        if is_helper_window(bounds, menu_height):
            continue
        found.append(window)
    return found


def terminate_pid(pid: int) -> bool:
    """Apple Event quit to this pid only, not to every process of the same name."""
    pid = parse_pid(pid)
    from AppKit import NSRunningApplication  # type: ignore[import-not-found]
    app = NSRunningApplication.runningApplicationWithProcessIdentifier_(pid)
    if app is None:
        return False
    return bool(app.terminate())


def main(argv: list[str]) -> int:
    if len(argv) == 3 and argv[1] == "--quit":
        try:
            pid = parse_pid(argv[2])
        except ValueError as exc:
            print(exc, file=sys.stderr)
            return 2
        return 0 if terminate_pid(pid) else 1
    print(f"usage: {argv[0]} --quit PID", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
