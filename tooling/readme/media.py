#!/usr/bin/env python3
"""Helpers for the README's media; capture-stills.sh and record-demo.sh call them.

    media.py seed PROFILE --fixture demo|spaces|isolated --version-file VERSION
                  [--scheme light|dark|system] [--collapsed] [--dark-pages]
                  [--pref dotted.name=JSON ...]
    media.py render OUT.steps --scenes a,b,... --marks DIR --shots DIR
    media.py check-captions --keys a,b,...
    media.py captions DIR --width W --height H --keys a,b,...     (PyObjC)
    media.py rect PID                                              (PyObjC)
    media.py screen                                                (PyObjC)
    media.py timeline --marks DIR --scenes a,b,... --t0 T --lane DIR
                      [--offset S | --changes FILE] --out DIR
    media.py lane --keys a,b,... --starts S1,S2,... --total T --lane DIR --out FILE

seed writes a fresh profile: the Space registry of a fixture (names, colours,
icons, an Independent session), the welcome flow marked as shown, the colour
scheme, and Local State's last-run version, so neither the welcome flow nor a
thank-you page opens. It refuses a directory that already holds a profile.

render joins the scenes' steps files (steps/<scene>.steps) into one file for
tooling/drive, fills in @MARKS@ and @SHOTS@, and expands the one step this
directory adds to tooling/drive's language:

    glide X Y [SECONDS]           the pointer moves from where the last step left
    glide X1 Y1 X2 Y2 [SECONDS]   it (or from X1 Y1) to X Y along an eased path
                                  (tooling/drive's move), so it never jumps across
                                  the window in the recording; half a second by
                                  default

Every recorded scene's first step is `shot @MARKS@/<scene>.png`; the end
scene's last step is `shot @MARKS@/stop.png`. The times those files are
written are the scene boundaries timeline uses.

timeline reads those times and the recording's start time (t0, wall clock),
and writes the trim points (timeline.env), the caption lane for ffmpeg's
concat demuxer (lane.txt) and a table for people (timeline.txt).
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
STEPS_DIR = os.path.join(HERE, "steps")
CAPTIONS = os.path.join(HERE, "captions.tsv")

# chrome/browser/ui/spaces/space_colors.h, kSpaceColors.
SWATCHES = {
    "slate": (0x5B, 0x6B, 0x8C),
    "plum": (0x7A, 0x5B, 0x8C),
    "moss": (0x5B, 0x8C, 0x74),
    "clay": (0x8C, 0x6B, 0x5B),
    "rose": (0x8C, 0x5B, 0x63),
}

# (name, swatch, icon, own session). The first Space is the one a new window
# shows. Ids and the jar token are fixed, so a fixture is the same every run.
FIXTURES = {
    "demo": [
        ("Work", "moss", "\U0001F4BC", False),
        ("Personal", "plum", "\U0001F3E0", True),
        ("Reading", "clay", "\U0001F4DA", False),
    ],
    "spaces": [
        ("Work", "moss", "\U0001F4BC", False),
        ("Personal", "plum", "\U0001F3E0", True),
        ("Reading", "clay", "\U0001F4DA", False),
        ("Travel", "rose", "✈️", False),
        ("Side project", "slate", "\U0001F6E0️", False),
    ],
    "isolated": [
        ("Personal", "plum", "\U0001F3E0", True),
        ("Work", "moss", "\U0001F4BC", False),
        ("Reading", "clay", "\U0001F4DA", False),
    ],
}
ID_PREFIX = "5EDD1A6000000000000000000000"
JAR_TOKEN = "5EDD1A60000000000000000000000A11"
SCHEMES = {"system": None, "light": 1, "dark": 2}


def fail(message: str) -> int:
    print(message, file=sys.stderr)
    return 2


def sk_color(rgb: tuple[int, int, int]) -> int:
    """An opaque SkColor as the registry stores it: a signed 32-bit int."""
    value = 0xFF000000 | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2]
    return value - (1 << 32) if value >= (1 << 31) else value


# ------------------------------------------------------------------- seed

def cmd_seed(args: argparse.Namespace) -> int:
    default = os.path.join(args.profile, "Default")
    prefs_path = os.path.join(default, "Preferences")
    if os.path.exists(prefs_path):
        return fail("%s already holds a profile; use a new directory" % args.profile)
    with open(args.version_file, encoding="utf-8") as handle:
        version = handle.read().strip()
    registry = []
    for index, (name, swatch, icon, own) in enumerate(FIXTURES[args.fixture], 1):
        registry.append({
            "id": "%s%04X" % (ID_PREFIX, index),
            "name": name,
            "color": sk_color(SWATCHES[swatch]),
            "color_chosen": True,
            "icon": icon,
            "isolated": own,
            "pins_collapsed": False,
            "profile": JAR_TOKEN if own else "",
        })
    prefs: dict = {
        "stedding": {
            "welcome": {"shown": True},
            "spaces": {"registry": registry},
        },
    }
    scheme = SCHEMES[args.scheme]
    if scheme is not None:
        # prefs::kBrowserColorScheme, as tooling/capture-state's --seed writes it.
        prefs["browser"] = {"theme": {"color_scheme2": scheme}}
    if args.collapsed:
        prefs["vertical_tabs"] = {"collapsed_state": True}
    if args.dark_pages:
        # Dark pages' switch is Chromium's own preference
        # (prefs::kWebKitForceDarkModeEnabled).
        prefs["webkit"] = {"webprefs": {"force_dark_mode_enabled": True}}
    # Any other preference a still needs, such as a setting a release brought:
    # --pref stedding.sidebar.address_in_sidebar=true.
    for pref in args.pref:
        name, sep, raw = pref.partition("=")
        if not sep or not name:
            return fail("--pref %s: give dotted.name=JSON" % pref)
        try:
            value = json.loads(raw)
        except ValueError:
            return fail("--pref %s: the value is not JSON" % pref)
        node = prefs
        *path, leaf = name.split(".")
        for key in path:
            node = node.setdefault(key, {})
            if not isinstance(node, dict):
                return fail("--pref %s: %s is not a dictionary" % (pref, key))
        node[leaf] = value
    os.makedirs(default, exist_ok=True)
    with open(prefs_path, "w", encoding="utf-8") as handle:
        json.dump(prefs, handle, ensure_ascii=False)
    with open(os.path.join(args.profile, "Local State"), "w", encoding="utf-8") as handle:
        json.dump({"stedding": {"updates": {"last_run_version": version}}}, handle)
    print("seeded %s: %s (%s)" % (args.profile, ", ".join(s[0] for s in FIXTURES[args.fixture]),
                                  args.scheme))
    return 0


# ----------------------------------------------------------------- render

POINTER_OPS = ("click", "rclick", "dblclick", "hover", "dragstart", "dragmove")


def expand_glide(words: list[str], where: str, at) -> list[str]:
    """glide X Y [SECONDS] from where the pointer is (the last step that moved it),
    or glide X1 Y1 X2 Y2 [SECONDS] from a point given."""
    try:
        numbers = [float(w) for w in words[1:]]
    except ValueError:
        raise ValueError("%s: glide takes numbers" % where) from None
    if len(numbers) in (2, 3):
        if at is None:
            raise ValueError("%s: glide X Y needs a step before it that put the pointer"
                             " somewhere; give the start: glide X1 Y1 X2 Y2" % where)
        (x1, y1), (x2, y2) = at, numbers[0:2]
        seconds = numbers[2] if len(numbers) == 3 else 0.5
    elif len(numbers) in (4, 5):
        x1, y1, x2, y2 = numbers[0:4]
        seconds = numbers[4] if len(numbers) == 5 else 0.5
    else:
        raise ValueError("%s: glide takes X Y [SECONDS] or X1 Y1 X2 Y2 [SECONDS]" % where)
    if not (0 < seconds <= 5) or not all(math.isfinite(v) for v in (x1, y1, x2, y2)):
        raise ValueError("%s: a glide lasts more than 0 and at most 5 seconds" % where)
    return ["move %d %d %d %d %g" % (round(x1), round(y1), round(x2), round(y2), seconds)]


def pointer_after(words: list[str], at):
    """Where the pointer is after a step of tooling/drive's language."""
    try:
        if words[0] in POINTER_OPS and len(words) >= 3:
            return float(words[1]), float(words[2])
        if words[0] == "drag" and len(words) == 5:
            return float(words[3]), float(words[4])
        if words[0] == "move" and len(words) == 6:
            return float(words[3]), float(words[4])
    except ValueError:
        pass
    return at


def cmd_render(args: argparse.Namespace) -> int:
    scenes = [s for s in args.scenes.split(",") if s]
    if not scenes:
        return fail("no scenes")
    out_lines: list[str] = []
    errors: list[str] = []
    at = None  # the pointer, as far as the steps say
    for scene in scenes:
        path = os.path.join(STEPS_DIR, scene + ".steps")
        if not os.path.isfile(path):
            errors.append("no steps file for scene %r (%s)" % (scene, path))
            continue
        with open(path, encoding="utf-8") as handle:
            lines = handle.read().splitlines()
        steps = [l.strip() for l in lines if l.strip() and not l.strip().startswith("#")]
        marker = "shot @MARKS@/%s.png" % scene
        recorded = scene not in ("setup", "preroll")
        if recorded and (not steps or steps[0] != marker):
            errors.append("%s: a recorded scene starts with `%s`" % (path, marker))
        if scene == "end" and (not steps or steps[-1] != "shot @MARKS@/stop.png"):
            errors.append("%s: the end scene ends with `shot @MARKS@/stop.png`" % path)
        out_lines.append("# ---- %s" % scene)
        for number, raw in enumerate(lines, 1):
            line = raw.replace("@MARKS@", args.marks).replace("@SHOTS@", args.shots)
            words = line.split()
            if words and words[0] == "glide":
                try:
                    out_lines.extend(expand_glide(words, "%s:%d" % (path, number), at))
                except ValueError as exc:
                    errors.append(str(exc))
                    continue
                at = pointer_after(out_lines[-1].split(), at)
            else:
                out_lines.append(line)
                if words and not words[0].startswith("#"):
                    at = pointer_after(words, at)
    if errors:
        return fail("\n".join(errors))
    with open(args.out, "w", encoding="utf-8") as handle:
        handle.write("\n".join(out_lines) + "\n")
    print("%s: %s" % (args.out, ", ".join(scenes)))
    return 0


# --------------------------------------------------------------- captions

def read_captions() -> dict[str, tuple[str, str]]:
    table: dict[str, tuple[str, str]] = {}
    with open(CAPTIONS, encoding="utf-8") as handle:
        for line in handle.read().splitlines():
            if not line.strip() or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) != 3:
                raise ValueError("captions.tsv: three tab-separated columns per row: %r" % line)
            table[parts[0]] = (parts[1].strip(), parts[2].strip())
    return table


def cmd_check_captions(args: argparse.Namespace) -> int:
    table = read_captions()
    missing = [k for k in args.keys.split(",") if k and k not in table]
    if missing:
        return fail("captions.tsv has no row for: %s" % ", ".join(missing))
    return 0


def hex_color(text: str):
    from AppKit import NSColor  # type: ignore[import-not-found]
    value = int(text.lstrip("#"), 16)
    return NSColor.colorWithSRGBRed_green_blue_alpha_(
        ((value >> 16) & 255) / 255.0, ((value >> 8) & 255) / 255.0, (value & 255) / 255.0, 1.0)


def render_caption(path: str, width: int, height: int, keys: str, text: str) -> None:
    """One caption strip: the brand's slate ground, the keys in a light slate,
    the words near white, centred; the font shrinks until the line fits."""
    from AppKit import (  # type: ignore[import-not-found]
        NSAttributedString, NSBitmapImageRep, NSDeviceRGBColorSpace, NSFont,
        NSFontAttributeName, NSFontWeightMedium, NSFontWeightSemibold,
        NSForegroundColorAttributeName, NSGraphicsContext, NSMakeRect,
        NSMutableAttributedString, NSRectFill)
    ground, keys, words = hex_color("#2F4858"), hex_color("#99F6E4"), hex_color("#F1F5F9")
    rep = NSBitmapImageRep.alloc().initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel_(  # noqa: E501
        None, width, height, 8, 4, True, False, NSDeviceRGBColorSpace, 0, 0)
    context = NSGraphicsContext.graphicsContextWithBitmapImageRep_(rep)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.setCurrentContext_(context)
    ground.set()
    NSRectFill(NSMakeRect(0, 0, width, height))
    size = height * 0.40
    while True:
        line = NSMutableAttributedString.alloc().init()
        if keys:
            line.appendAttributedString_(NSAttributedString.alloc().initWithString_attributes_(
                keys + " ", {
                    NSFontAttributeName: NSFont.systemFontOfSize_weight_(size, NSFontWeightSemibold),
                    NSForegroundColorAttributeName: keys}))
        if text:
            line.appendAttributedString_(NSAttributedString.alloc().initWithString_attributes_(
                text, {
                    NSFontAttributeName: NSFont.systemFontOfSize_weight_(size, NSFontWeightMedium),
                    NSForegroundColorAttributeName: words}))
        bounds = line.size()
        if bounds.width <= width - 2 * height or size <= 10:
            break
        size -= 1
    line.drawAtPoint_(((width - bounds.width) / 2, (height - bounds.height) / 2))
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    data = rep.representationUsingType_properties_(4, {})  # NSBitmapImageFileTypePNG
    if not data or not data.writeToFile_atomically_(path, True):
        raise OSError("could not write %s" % path)


def cmd_captions(args: argparse.Namespace) -> int:
    table = read_captions()
    os.makedirs(args.dir, exist_ok=True)
    render_caption(os.path.join(args.dir, "blank.png"), args.width, args.height, "", "")
    for key in [k for k in args.keys.split(",") if k]:
        if key not in table:
            return fail("captions.tsv has no row for %r" % key)
        keys, text = table[key]
        render_caption(os.path.join(args.dir, "cap-%s.png" % key), args.width, args.height, keys, text)
    print("captions in %s" % args.dir)
    return 0


# ------------------------------------------------------------- the window

def cmd_rect(args: argparse.Namespace) -> int:
    """x y w h scale screen_w screen_h of the largest on-screen window the pid
    owns, in the global top-left points Quartz uses; nothing while it has none."""
    sys.path.insert(0, os.path.dirname(HERE))
    from AppKit import NSScreen  # type: ignore[import-not-found]
    from window_by_pid import parse_pid, windows_for_pid
    best, area = None, 0
    for window in windows_for_pid(parse_pid(args.pid)):
        if not window.get("kCGWindowIsOnscreen") or window.get("kCGWindowLayer", 0) != 0:
            continue
        bounds = window.get("kCGWindowBounds", {})
        size = bounds.get("Width", 0) * bounds.get("Height", 0)
        if size > area and size > 100000:
            best, area = bounds, size
    if not best:
        return 1
    screens = NSScreen.screens()
    main_height = screens[0].frame().size.height
    cx = best["X"] + best["Width"] / 2
    cy = best["Y"] + best["Height"] / 2
    chosen = screens[0]
    for screen in screens:
        frame = screen.frame()
        top = main_height - (frame.origin.y + frame.size.height)
        if frame.origin.x <= cx < frame.origin.x + frame.size.width and top <= cy < top + frame.size.height:
            chosen = screen
    frame = chosen.frame()
    print("%d %d %d %d %g %d %d" % (best["X"], best["Y"], best["Width"], best["Height"],
                                     chosen.backingScaleFactor(), frame.size.width, frame.size.height))
    return 0


def cmd_screen(_args: argparse.Namespace) -> int:
    """The main display's visible frame (menu bar and Dock left out), in points,
    and its backing scale: width height scale."""
    from AppKit import NSScreen  # type: ignore[import-not-found]
    screen = NSScreen.screens()[0]
    visible = screen.visibleFrame()
    print("%d %d %g" % (visible.size.width, visible.size.height, screen.backingScaleFactor()))
    return 0


# --------------------------------------------------------------- timeline

def scene_changes(path: str) -> list[tuple[float, float]]:
    """(time, score) pairs from ffmpeg's metadata=print output of scene scores."""
    found: list[tuple[float, float]] = []
    time = None
    with open(path, encoding="utf-8", errors="replace") as handle:
        for line in handle:
            m = re.search(r"pts_time:([0-9.]+)", line)
            if m:
                time = float(m.group(1))
                continue
            m = re.search(r"lavfi\.scene_score=([0-9.]+)", line)
            if m and time is not None:
                found.append((time, float(m.group(1))))
    return found


def ffconcat_path(path: str) -> str:
    """A path quoted for ffmpeg's concat demuxer."""
    return "'%s'" % path.replace("'", "'\\''")


def lane_lines(keys: list[str], starts: list[float], total: float, lane_dir: str) -> list[str]:
    """The caption lane for the concat demuxer: caption k from starts[k] to the
    next start (the last to `total`), with a short blank before and after each so
    one caption never runs straight into the next."""
    gap = 0.2
    lane = ["ffconcat version 1.0"]

    def put(name: str, seconds: float) -> None:
        if seconds > 0.01:
            lane.append("file %s" % ffconcat_path(os.path.join(lane_dir, name)))
            lane.append("duration %.3f" % seconds)

    for index, key in enumerate(keys):
        begin = starts[index]
        end = starts[index + 1] if index + 1 < len(keys) else total
        if end - begin > 2 * gap + 0.4:
            put("blank.png", gap)
            put("cap-%s.png" % key, end - begin - 2 * gap)
            put("blank.png", gap)
        else:
            put("cap-%s.png" % key, end - begin)
    # The concat demuxer drops the last entry's duration unless the file repeats.
    lane.append(lane[-2])
    return lane


def cmd_lane(args: argparse.Namespace) -> int:
    keys = [k for k in args.keys.split(",") if k]
    starts = [float(x) for x in args.starts.split(",") if x]
    if len(keys) != len(starts) or not keys:
        return fail("one start per key")
    with open(args.out, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lane_lines(keys, starts, args.total, args.lane)) + "\n")
    return 0


def cmd_timeline(args: argparse.Namespace) -> int:
    scenes = [s for s in args.scenes.split(",") if s]
    marks = []
    for scene in scenes + ["stop"]:
        path = os.path.join(args.marks, scene + ".png")
        if not os.path.isfile(path):
            return fail("no marker %s: did the run reach that scene?" % path)
        marks.append(os.stat(path).st_mtime - args.t0)
    for earlier, later in zip(marks, marks[1:]):
        if later <= earlier:
            return fail("the markers are out of order; was a marks directory reused?")

    # The recorder's first frame comes a little after t0. The command bar opening
    # right after the bar scene's marker is the largest change on screen in the
    # seconds before it; how far before the naive time it shows is that delay.
    # ffmpeg's screen input starts about 1.8 s late on the Mac of 2026-10-21: a
    # window reaching 1.6 s back missed the bar and synced on the typing instead.
    offset, how = 0.0, "none (no --offset and no command bar scene to sync on)"
    if args.offset is not None:
        offset, how = args.offset, "given (--offset)"
    elif args.changes and "bar" in scenes:
        naive = marks[scenes.index("bar")]
        window = [(t, s) for t, s in scene_changes(args.changes) if naive - 3.0 <= t <= naive + 0.6]
        if window:
            seen = max(window, key=lambda item: item[1])[0]
            # The bar opens about 0.15 s after the marker is written.
            offset, how = seen - (naive + 0.15), "synced on the command bar opening"
        else:
            how = "none (no change seen where the command bar opens)"
    video = [m + offset for m in marks]
    start, stop = video[0], video[-1]
    if start < 0:
        return fail("the first scene starts before the recording does (%.2f s)" % start)

    starts = [v - start for v in video[:-1]]
    lane = lane_lines(scenes, starts, stop - start, args.lane)
    table = ["scene        starts   length", "-----------  -------  ------"]
    for index, scene in enumerate(scenes):
        begin = starts[index]
        end = video[index + 1] - start
        table.append("%-11s  %6.2fs  %5.2fs" % (scene, begin, end - begin))
    length = stop - start
    table.append("total        %6.2fs" % length)
    table.append("offset       %+.2fs  %s" % (offset, how))
    if not 25 <= length <= 40:
        table.append("note: the storyboard asks for 25 to 40 seconds")
    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, "lane.txt"), "w", encoding="utf-8") as handle:
        handle.write("\n".join(lane) + "\n")
    with open(os.path.join(args.out, "timeline.txt"), "w", encoding="utf-8") as handle:
        handle.write("\n".join(table) + "\n")
    with open(os.path.join(args.out, "timeline.env"), "w", encoding="utf-8") as handle:
        handle.write("TRIM_START=%.3f\nTRIM_END=%.3f\nDURATION=%.3f\nOFFSET=%.3f\n"
                     % (start, stop, length, offset))
    print("\n".join(table))
    return 0


# ------------------------------------------------------------------- main

def cmd_lights(args: argparse.Namespace) -> int:
    """ffmpeg's geq expression for an active window's three traffic lights, red, yellow
    and green, on a transparent strip at the recording's scale: what record-demo.sh
    paints over the system's capture badge (measured in points on 2026-10-23)."""
    s = args.scale
    centres = [(19.75 * s, 15.75 * s), (42.75 * s, 15.75 * s), (65.75 * s, 15.75 * s)]
    dist = "min(min({0},{1}),{2})".format(
        *["hypot(X-%.2f,Y-%.2f)" % c for c in centres])
    left, middle = int(31 * s), int(54 * s)

    def channel(red: int, yellow: int, green: int) -> str:
        return "if(lt(X,%d),%d,if(lt(X,%d),%d,%d))" % (left, red, middle, yellow, green)

    parts = {
        "r": channel(255, 254, 40),
        "g": channel(95, 188, 200),
        "b": channel(87, 46, 64),
        "a": "clip((%.2f-%s)*255,0,255)" % (6.6 * s, dist),
    }
    # Commas inside a filter's option are escaped for ffmpeg's filter parser.
    print(":".join("%s='%s'" % (k, v.replace(",", "\\,")) for k, v in parts.items()))
    return 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("seed")
    p.add_argument("profile")
    p.add_argument("--fixture", choices=sorted(FIXTURES), required=True)
    p.add_argument("--version-file", required=True)
    p.add_argument("--scheme", choices=sorted(SCHEMES), default="light")
    p.add_argument("--collapsed", action="store_true")
    p.add_argument("--dark-pages", action="store_true")
    p.add_argument("--pref", action="append", default=[], metavar="NAME=JSON")
    p.set_defaults(func=cmd_seed)

    p = sub.add_parser("render")
    p.add_argument("out")
    p.add_argument("--scenes", required=True)
    p.add_argument("--marks", required=True)
    p.add_argument("--shots", required=True)
    p.set_defaults(func=cmd_render)

    p = sub.add_parser("check-captions")
    p.add_argument("--keys", required=True)
    p.set_defaults(func=cmd_check_captions)

    p = sub.add_parser("captions")
    p.add_argument("dir")
    p.add_argument("--width", type=int, required=True)
    p.add_argument("--height", type=int, required=True)
    p.add_argument("--keys", required=True)
    p.set_defaults(func=cmd_captions)

    p = sub.add_parser("rect")
    p.add_argument("pid")
    p.set_defaults(func=cmd_rect)

    p = sub.add_parser("screen")
    p.set_defaults(func=cmd_screen)

    p = sub.add_parser("lights")
    p.add_argument("scale", type=float)
    p.set_defaults(func=cmd_lights)

    p = sub.add_parser("lane")
    p.add_argument("--keys", required=True)
    p.add_argument("--starts", required=True)
    p.add_argument("--total", type=float, required=True)
    p.add_argument("--lane", required=True)
    p.add_argument("--out", required=True)
    p.set_defaults(func=cmd_lane)

    p = sub.add_parser("timeline")
    p.add_argument("--marks", required=True)
    p.add_argument("--scenes", required=True)
    p.add_argument("--t0", type=float, required=True)
    p.add_argument("--lane", required=True)
    p.add_argument("--offset", type=float)
    p.add_argument("--changes")
    p.add_argument("--out", required=True)
    p.set_defaults(func=cmd_timeline)

    args = parser.parse_args(argv[1:])
    try:
        return args.func(args)
    except (OSError, ValueError) as exc:
        return fail(str(exc))


if __name__ == "__main__":
    sys.exit(main(sys.argv))
