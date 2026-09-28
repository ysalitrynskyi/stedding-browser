#!/usr/bin/env python3
"""Drive the live Stedding window with synthetic input; used by tooling/drive.

    drive-window.py PID STEPS        run the steps against the window PID owns
    drive-window.py --check STEPS    read and check the steps; posts nothing

Every step is read and checked before the first event is posted: an unknown
op, a bad argument, a drag with no dragend or a keydown with no keyup exits 2
with nothing sent. A refusal while running, a failed shot or a missing window
exits non-zero too. Coordinates are window points; the window is the one owned
by that pid (or a child) and is never raised. Input is posted only when that
pid is frontmost, and a press only where that pid's window is the topmost one
on screen -- for a drag, at every point the steps name, before the button goes
down -- so nothing reaches another app's window. A mouse button or a modifier
this script pressed is released on every exit: an error, Ctrl-C or SIGTERM.
See tooling/drive for the step grammar.
"""
#   click X Y [mods] | rclick X Y [mods] | dblclick X Y [mods] | hover X Y | drag X1 Y1 X2 Y2
#   dragstart X Y | dragmove X Y | dragend      a drag in steps, so a shot can land mid-drag
#   key <name>[+cmd][+shift][+ctrl][+alt]      (names: KEYS below)
#   keydown <name> | keyup <name>              a modifier (or key) held across steps
#   type <text> | wait <sec> | shot <file.png> | activate

import math
import os
import signal
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
CAPTURE = os.path.join(HERE, "capture-windows")

KEYS = {'a': 0, 's': 1, 'd': 2, 'f': 3, 'h': 4, 'g': 5, 'z': 6, 'x': 7, 'c': 8, 'v': 9, 'b': 11,
        'q': 12, 'w': 13, 'e': 14, 'r': 15, 'y': 16, 't': 17, '1': 18, '2': 19, '3': 20, '4': 21,
        '6': 22, '5': 23, '9': 25, '7': 26, '8': 28, '0': 29, 'o': 31, 'u': 32, 'i': 34, 'p': 35,
        'l': 37, 'j': 38, 'k': 40, 'n': 45, 'm': 46, 'enter': 36, 'tab': 48, 'space': 49,
        'esc': 53, 'left': 123, 'right': 124, 'down': 125, 'up': 126, 'backspace': 51,
        'delete': 117, 'home': 115, 'end': 119, 'pageup': 116, 'pagedown': 121}
MOD_KEYS = {'cmd': 55, 'shift': 56, 'alt': 58, 'ctrl': 59}
PUNCT = {'.': 47, '/': 44, '-': 27, ' ': 49}
KEY_MODS = ('cmd', 'shift', 'ctrl', 'alt')
# Ctrl is not here on purpose: macOS reads a Ctrl-click as a right-click.
MOUSE_MODS = ('cmd', 'shift', 'alt')
# Steps allowed while a stepwise drag holds the button down.
DURING_DRAG = ('dragmove', 'dragend', 'wait', 'shot', 'key', 'keydown', 'keyup')


class StepsError(Exception):
    """Every problem in a steps file, one message per problem."""


def _number(text):
    try:
        value = float(text)
    except ValueError:
        raise ValueError("%r is not a number" % text) from None
    if not math.isfinite(value):
        raise ValueError("%r is not a finite number" % text)
    return value


def _mods(text, allowed):
    names = text.split('+') if text else []
    bad = [m for m in names if m not in allowed]
    if bad:
        raise ValueError("unknown modifier %s (known: %s)" % (
            ", ".join(repr(m) for m in bad), ", ".join(allowed)))
    return names


def parse_steps(path):
    """Every step as (line number, line, op, args). Raises StepsError naming
    each problem; nothing is posted until the whole file reads clean."""
    try:
        with open(path, encoding="utf-8") as handle:
            lines = handle.read().splitlines()
    except (OSError, UnicodeDecodeError) as exc:
        raise StepsError(["%s: cannot read: %s" % (path, exc)])
    steps, errors = [], []
    drag = None   # (line number, the dragstart step's targets) while a drag is down
    held = {}     # key name -> line number of its keydown

    for number, raw in enumerate(lines, 1):
        line = raw.strip()
        if not line or line.startswith('#'):
            continue
        op, _, rest = line.partition(' ')
        words = rest.split()
        where = "%s:%d: " % (path, number)
        if drag and op not in DURING_DRAG:
            errors.append(where + "'%s' while the drag from line %d holds the button; end it"
                          " with dragend first  (%s)" % (op, drag[0], line))
            continue
        try:
            if op in ('click', 'rclick', 'dblclick'):
                if len(words) not in (2, 3):
                    raise ValueError("%s takes X Y and optional modifiers (%s, joined by +)"
                                     % (op, ", ".join(MOUSE_MODS)))
                args = (_number(words[0]), _number(words[1]),
                        _mods(words[2] if len(words) == 3 else '', MOUSE_MODS))
            elif op in ('hover', 'dragstart', 'dragmove'):
                if len(words) != 2:
                    raise ValueError("%s takes X Y" % op)
                args = (_number(words[0]), _number(words[1]))
                if op == 'dragstart':
                    args = args + ([],)
                    drag = (number, args[2])
                elif op == 'dragmove':
                    if not drag:
                        raise ValueError("dragmove with no dragstart before it")
                    drag[1].append(args)
            elif op == 'drag':
                if len(words) != 4:
                    raise ValueError("drag takes X1 Y1 X2 Y2")
                args = tuple(_number(w) for w in words)
            elif op == 'dragend':
                if words:
                    raise ValueError("dragend takes nothing")
                if not drag:
                    raise ValueError("dragend with no dragstart before it")
                drag = None
                args = ()
            elif op == 'key':
                if len(words) != 1:
                    raise ValueError("key takes one name, modifiers joined by +, e.g. key t+cmd")
                name, _, mods = words[0].partition('+')
                if name not in KEYS:
                    raise ValueError("unknown key %r (known: %s)" % (name, " ".join(sorted(KEYS))))
                if words[0].endswith('+'):
                    raise ValueError("empty modifier in %r" % words[0])
                args = (name, _mods(mods, KEY_MODS))
            elif op in ('keydown', 'keyup'):
                if len(words) != 1 or (words[0] not in MOD_KEYS and words[0] not in KEYS):
                    raise ValueError("%s takes one key name, e.g. %s cmd" % (op, op))
                name = words[0]
                if op == 'keydown':
                    if name in held:
                        raise ValueError("%s is already held (keydown on line %d)" % (name, held[name]))
                    held[name] = number
                else:
                    if name not in held:
                        raise ValueError("keyup %s with no keydown %s before it" % (name, name))
                    del held[name]
                args = (name,)
            elif op == 'type':
                if not rest:
                    raise ValueError("type takes the text to type")
                args = (rest,)
            elif op == 'wait':
                if len(words) != 1 or _number(words[0]) < 0:
                    raise ValueError("wait takes a number of seconds")
                args = (_number(words[0]),)
            elif op == 'shot':
                if not rest.strip():
                    raise ValueError("shot takes the file to write")
                args = (rest.strip(),)
            elif op == 'activate':
                if words:
                    raise ValueError("activate takes nothing")
                args = ()
            else:
                raise ValueError("unknown op %r" % op)
        except ValueError as exc:
            errors.append(where + "%s  (%s)" % (exc, line))
            continue
        steps.append((number, line, op, args))

    if drag:
        errors.append("%s:%d: the drag that starts here has no dragend; the button would stay down"
                      % (path, drag[0]))
    for name, number in sorted(held.items(), key=lambda item: item[1]):
        errors.append("%s:%d: keydown %s has no keyup %s after it; the key would stay held"
                      % (path, number, name, name))
    if errors:
        raise StepsError(errors)
    return steps


class Driver:
    """Posts the steps' events to the window a pid owns, and keeps count of
    every button and key it pressed so release_all() can let go of them."""

    WIGGLE = ((1, 1), (2, 3), (3, 6), (4, 9))

    def __init__(self, pid):
        import Quartz
        from AppKit import (NSApplicationActivateIgnoringOtherApps, NSRunningApplication,
                            NSWorkspace)
        from window_by_pid import pids_in_tree, windows_for_pid
        self.q = Quartz
        self.pid = pid
        self.activate_option = NSApplicationActivateIgnoringOtherApps
        self.running_app = NSRunningApplication
        self.workspace = NSWorkspace
        self.pids_in_tree = pids_in_tree
        self.windows_for_pid = windows_for_pid
        self.buttons = {}   # CG button -> (x, y) of its last event while it is down
        self.keys = {}      # key name -> key code, held by keydown
        self.chord = None   # (code, flags, text) of a key or typed character that is down
        self.drag_at = None
        q = Quartz
        self.down = {q.kCGMouseButtonLeft: q.kCGEventLeftMouseDown,
                     q.kCGMouseButtonRight: q.kCGEventRightMouseDown}
        self.up = {q.kCGMouseButtonLeft: q.kCGEventLeftMouseUp,
                   q.kCGMouseButtonRight: q.kCGEventRightMouseUp}
        self.mouse_flags = {'cmd': q.kCGEventFlagMaskCommand,
                            'shift': q.kCGEventFlagMaskShift,
                            'alt': q.kCGEventFlagMaskAlternate}
        self.key_flags = dict(self.mouse_flags, ctrl=q.kCGEventFlagMaskControl)

    # -- where input may go ---------------------------------------------------

    def origin(self):
        best, area = None, 0
        for window in self.windows_for_pid(self.pid):
            if not window.get("kCGWindowIsOnscreen"):
                continue
            bounds = window.get("kCGWindowBounds", {})
            size = bounds.get("Width", 0) * bounds.get("Height", 0)
            if size > area and size > 100000:
                best, area = bounds, size
        if not best:
            sys.exit("no window owned by pid %s; not sending input" % self.pid)
        return best["X"], best["Y"]

    def to_screen(self, x, y):
        ox, oy = self.origin()
        return float(x) + ox, float(y) + oy

    def front_pid(self):
        app = self.workspace.sharedWorkspace().frontmostApplication()
        return -1 if app is None else int(app.processIdentifier())

    def require_keys(self):
        # HID key events go to whichever process is frontmost, not to a window id.
        if not self.windows_for_pid(self.pid):
            sys.exit("no window owned by pid %s; not sending keys" % self.pid)
        front = self.front_pid()
        if front not in self.pids_in_tree(self.pid):
            sys.exit("frontmost pid %s is not %s; not sending keys" % (front, self.pid))

    def require_mouse_at(self, x, y):
        # A mouse event lands on whatever window is on top at that point. Post it
        # only when this pid is frontmost and its window is the topmost one there.
        owners = self.pids_in_tree(self.pid)
        front = self.front_pid()
        if front not in owners:
            sys.exit("frontmost pid %s is not %s; not sending mouse input" % (front, self.pid))
        q = self.q
        onscreen = q.CGWindowListCopyWindowInfo(
            q.kCGWindowListOptionOnScreenOnly, q.kCGNullWindowID) or []
        for window in onscreen:  # front to back
            bounds = window.get("kCGWindowBounds", {})
            if (bounds.get("X", 0) <= x < bounds.get("X", 0) + bounds.get("Width", 0) and
                    bounds.get("Y", 0) <= y < bounds.get("Y", 0) + bounds.get("Height", 0)):
                if int(window.get("kCGWindowOwnerPID", -1)) in owners:
                    return
                sys.exit("(%s, %s) is covered by %s's window; not sending mouse input"
                         % (x, y, window.get("kCGWindowOwnerName", "another app")))
        sys.exit("no window at (%s, %s); not sending mouse input" % (x, y))

    # -- raw events, no checks; every press is remembered ---------------------

    def post_mouse(self, kind, x, y, button, clicks=1, flags=0):
        q = self.q
        if kind in self.down.values():
            # Remembered before it is posted: a release that finds nothing to
            # release is harmless, a press nobody remembers is not.
            self.buttons[button] = (x, y)
        event = q.CGEventCreateMouseEvent(None, kind, (x, y), button)
        # A created mouse event inherits the last chord's modifiers too (trap 10
        # in docs/HANDOFF.md): after Ctrl-Cmd-F a plain click became Ctrl-click,
        # which macOS treats as a right-click. Explicit flags every time.
        q.CGEventSetFlags(event, flags)
        q.CGEventSetIntegerValueField(event, q.kCGMouseEventClickState, clicks)
        q.CGEventPost(q.kCGHIDEventTap, event)
        if kind in self.up.values():
            self.buttons.pop(button, None)
        elif button in self.buttons:
            self.buttons[button] = (x, y)

    def post_key(self, code, down, flags=0, text=None):
        q = self.q
        event = q.CGEventCreateKeyboardEvent(None, code, down)
        q.CGEventSetFlags(event, flags)
        if text is not None:
            q.CGEventKeyboardSetUnicodeString(event, len(text), text)
        q.CGEventPost(q.kCGHIDEventTap, event)

    def tap_key(self, code, flags=0, text=None, pause=0.05):
        """One key down and up. The key is remembered while it is down, and
        the up goes out whatever happened since the down."""
        self.chord = (code, flags, text)
        self.post_key(code, True, flags, text)
        time.sleep(pause)
        self.post_key(code, False, flags, text)
        self.chord = None
        time.sleep(pause)

    def release_all(self):
        """Lets go of every button and key this run pressed. No checks: a
        release goes out even when the run is stopping because a check failed."""
        for button, (x, y) in list(self.buttons.items()):
            self.post_mouse(self.up[button], x, y, button)
        self.buttons.clear()
        if self.chord is not None:
            code, flags, text = self.chord
            self.post_key(code, False, flags, text)
            self.chord = None
        for name, code in list(self.keys.items()):
            self.post_key(code, False)
            del self.keys[name]

    # -- steps -----------------------------------------------------------------

    def click(self, x, y, button, clicks, mods):
        q = self.q
        flags = 0
        for mod in mods:
            flags |= self.mouse_flags[mod]
        sx, sy = self.to_screen(x, y)
        self.require_mouse_at(sx, sy)
        self.post_mouse(q.kCGEventMouseMoved, sx, sy, q.kCGMouseButtonLeft)
        time.sleep(0.2)
        for i in range(clicks):
            self.require_mouse_at(sx, sy)
            self.post_mouse(self.down[button], sx, sy, button, i + 1, flags)
            time.sleep(0.08)
            # The release goes out whatever happened since the press.
            self.post_mouse(self.up[button], sx, sy, button, i + 1, flags)
            time.sleep(0.12)

    def hover(self, x, y):
        q = self.q
        sx, sy = self.to_screen(x, y)
        self.require_mouse_at(sx, sy)
        self.post_mouse(q.kCGEventMouseMoved, sx, sy, q.kCGMouseButtonLeft)

    def drag(self, x1, y1, x2, y2):
        q = self.q
        left = q.kCGMouseButtonLeft
        sx1, sy1 = self.to_screen(x1, y1)
        sx2, sy2 = self.to_screen(x2, y2)
        # Both ends before the button goes down: an end found covered halfway
        # would stop the run with the button held. The moves in between belong
        # to the window that took the press.
        self.require_mouse_at(sx1, sy1)
        self.require_mouse_at(sx2, sy2)
        self.post_mouse(q.kCGEventMouseMoved, sx1, sy1, left)
        time.sleep(0.3)
        self.post_mouse(q.kCGEventLeftMouseDown, sx1, sy1, left)
        time.sleep(0.3)
        for dx, dy in self.WIGGLE:
            self.post_mouse(q.kCGEventLeftMouseDragged, sx1 + dx,
                            sy1 + (dy if sy2 > sy1 else -dy), left)
            time.sleep(0.1)
        for i in range(1, 41):
            t = i / 40
            self.post_mouse(q.kCGEventLeftMouseDragged, sx1 + (sx2 - sx1) * t,
                            sy1 + (sy2 - sy1) * t, left)
            time.sleep(0.06)
        time.sleep(0.8)
        self.post_mouse(q.kCGEventLeftMouseUp, sx2, sy2, left)

    def drag_start(self, x, y, targets):
        q = self.q
        left = q.kCGMouseButtonLeft
        sx, sy = self.to_screen(x, y)
        # Every point this drag will reach, before the button goes down.
        self.require_mouse_at(sx, sy)
        for tx, ty in targets:
            self.require_mouse_at(*self.to_screen(tx, ty))
        self.post_mouse(q.kCGEventMouseMoved, sx, sy, left)
        time.sleep(0.3)
        self.post_mouse(q.kCGEventLeftMouseDown, sx, sy, left)
        time.sleep(0.3)
        for dx, dy in self.WIGGLE:
            self.post_mouse(q.kCGEventLeftMouseDragged, sx + dx, sy + dy, left)
            time.sleep(0.1)
        self.drag_at = (sx + 4, sy + 9)

    def drag_move(self, x, y):
        q = self.q
        sx1, sy1 = self.drag_at
        sx2, sy2 = self.to_screen(x, y)
        for i in range(1, 31):
            t = i / 30
            self.post_mouse(q.kCGEventLeftMouseDragged, sx1 + (sx2 - sx1) * t,
                            sy1 + (sy2 - sy1) * t, q.kCGMouseButtonLeft)
            time.sleep(0.05)
        self.drag_at = (sx2, sy2)
        time.sleep(0.5)

    def drag_end(self):
        q = self.q
        sx, sy = self.drag_at
        self.post_mouse(q.kCGEventLeftMouseUp, sx, sy, q.kCGMouseButtonLeft)
        self.drag_at = None

    def key(self, name, mods):
        flags = 0
        for mod in mods:
            flags |= self.key_flags[mod]
        self.require_keys()
        self.tap_key(KEYS[name], flags)

    def key_hold(self, name, down):
        # A modifier held on its own (Cmd for the row numbers, tabs R11): one
        # flagsChanged-style event, the flag set while it is down.
        code = MOD_KEYS.get(name, KEYS.get(name))
        flags = self.key_flags.get(name, 0) if down and name in MOD_KEYS else 0
        if down:
            self.require_keys()
            self.keys[name] = code
        self.post_key(code, down, flags)
        if not down:
            self.keys.pop(name, None)
        time.sleep(0.05)

    def type_text(self, text):
        # Real key codes where we have them (Chromium keys off the virtual code), the
        # unicode-string path only for characters outside the table.
        q = self.q
        for ch in text:
            self.require_keys()
            code = KEYS.get(ch.lower(), PUNCT.get(ch))
            if code is not None:
                # Explicit flags every time: a created event otherwise inherits the
                # modifier state left behind by the last chord (Cmd stuck after Cmd+T).
                # The character rides along too: with a non-Latin input source
                # active on the machine, the virtual code alone typed Cyrillic
                # into the address bar (docs/HANDOFF.md trap 18). Chromium keys
                # accelerators off the code and text off the characters.
                self.tap_key(code, q.kCGEventFlagMaskShift if ch.isupper() else 0, ch, 0.03)
            else:
                self.tap_key(0, 0, ch, 0.03)

    def shot(self, path):
        time.sleep(0.6)
        result = subprocess.run([sys.executable, CAPTURE, "--largest", str(self.pid), path])
        if result.returncode != 0:
            sys.exit(result.returncode or 1)

    def activate(self):
        app = self.running_app.runningApplicationWithProcessIdentifier_(self.pid)
        if app is None or not app.activateWithOptions_(self.activate_option):
            sys.exit("could not activate pid %s; not sending input" % self.pid)
        time.sleep(1.2)
        self.require_keys()

    def run(self, op, args):
        q = self.q
        if op == 'click':
            self.click(args[0], args[1], q.kCGMouseButtonLeft, 1, args[2])
        elif op == 'rclick':
            self.click(args[0], args[1], q.kCGMouseButtonRight, 1, args[2])
        elif op == 'dblclick':
            self.click(args[0], args[1], q.kCGMouseButtonLeft, 2, args[2])
        elif op == 'hover':
            self.hover(*args)
        elif op == 'drag':
            self.drag(*args)
        elif op == 'dragstart':
            self.drag_start(*args)
        elif op == 'dragmove':
            self.drag_move(*args)
        elif op == 'dragend':
            self.drag_end()
        elif op == 'key':
            self.key(*args)
        elif op == 'keydown':
            self.key_hold(args[0], True)
        elif op == 'keyup':
            self.key_hold(args[0], False)
        elif op == 'type':
            self.type_text(args[0])
        elif op == 'wait':
            time.sleep(args[0])
        elif op == 'shot':
            self.shot(args[0])
        elif op == 'activate':
            self.activate()
        else:  # parse_steps lets no other op through
            raise AssertionError(op)


def _stop(signum, _frame):
    # SIGTERM and SIGHUP end the run through SystemExit, so the finally below
    # still lets go of what was pressed.
    sys.exit(128 + signum)


def main(argv):
    if len(argv) == 3 and argv[1] == "--check":
        try:
            steps = parse_steps(argv[2])
        except StepsError as exc:
            print("\n".join(exc.args[0]), file=sys.stderr)
            return 2
        print("%s: %d steps, all well formed" % (argv[2], len(steps)))
        return 0
    if len(argv) != 3:
        print("usage: drive-window.py PID STEPS | drive-window.py --check STEPS", file=sys.stderr)
        return 2
    try:
        steps = parse_steps(argv[2])
    except StepsError as exc:
        print("\n".join(exc.args[0]), file=sys.stderr)
        print("nothing sent", file=sys.stderr)
        return 2

    sys.path.insert(0, HERE)
    from window_by_pid import parse_pid
    try:
        pid = parse_pid(argv[1])
    except ValueError as exc:
        print(exc, file=sys.stderr)
        return 2

    driver = Driver(pid)
    signal.signal(signal.SIGTERM, _stop)
    signal.signal(signal.SIGHUP, _stop)
    try:
        for _, line, op, args in steps:
            driver.run(op, args)
            print("ok", line, flush=True)
    finally:
        driver.release_all()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
