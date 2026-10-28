#!/usr/bin/env python3
"""Clear a Windows capture's corners the way Windows 11 rounds a top-level window.

tooling/win/capture.ps1 renders the window's full rectangle with PrintWindow. On screen
Windows 11 clips each corner of a top-level window to a radius of 8 px at scale 1, so the
capture's corner pixels are never seen there; left in, they show as square corners of the
window's ground. This makes them transparent, anti-aliased by supersampling. The Mac's
captures need nothing: tooling/capture-windows already takes the window with its own
rounded, transparent corners.

    tooling/readme/round-corners.py <in.png> <out.png> [radius in px, default 8]
"""
from __future__ import annotations

import sys

try:
    import numpy
    from PIL import Image, ImageDraw
except ImportError:  # pragma: no cover
    print("round-corners needs Pillow and NumPy: python3 -m pip install pillow numpy", file=sys.stderr)
    sys.exit(2)

SUPERSAMPLE = 8


def main() -> int:
    if len(sys.argv) not in (3, 4):
        print(__doc__.strip().splitlines()[-1].strip(), file=sys.stderr)
        return 2
    src, dst = sys.argv[1], sys.argv[2]
    radius = float(sys.argv[3]) if len(sys.argv) == 4 else 8.0
    image = Image.open(src).convert("RGBA")
    width, height = image.size
    big = Image.new("L", (width * SUPERSAMPLE, height * SUPERSAMPLE), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        (0, 0, width * SUPERSAMPLE - 1, height * SUPERSAMPLE - 1),
        radius=radius * SUPERSAMPLE, fill=255)
    mask = big.resize((width, height), Image.LANCZOS)
    alpha = numpy.minimum(numpy.array(image.getchannel("A")), numpy.array(mask))
    image.putalpha(Image.fromarray(alpha))
    image.save(dst, optimize=True)
    print("%s: %dx%d, corners cleared at a radius of %g px" % (dst, width, height, radius))
    return 0


if __name__ == "__main__":
    sys.exit(main())
