"""The Windows icons, from the same mark as everything else in branding/.

Windows reads the application icon from an .ico with every size it may draw
(the taskbar, the title bar, Explorer, the Start menu, the Alt-Tab switcher)
and Chromium ships three: the application, the HTML document and the PDF
document. The Windows 8 tile PNGs sit beside them. All are derived here from
the 256 px product logo the generator writes, so they cannot drift from it.

Usage:
  python3 tooling/brand/win_icons.py            # writes branding/win/
"""
import pathlib
import sys

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[2]
SOURCE = ROOT / "branding" / "product_logo" / "product_logo_256.png"
OUT = ROOT / "branding" / "win"
SIZES = [16, 20, 24, 32, 40, 48, 64, 96, 128, 256]


def ico(path: pathlib.Path, source: Image.Image) -> None:
    frames = [source.resize((s, s), Image.LANCZOS) for s in SIZES]
    # Pillow writes one file with every size listed; the 256 px frame is PNG
    # compressed, as Windows expects.
    frames[-1].save(path, format="ICO", sizes=[(s, s) for s in SIZES],
                    append_images=frames[:-1])


def tile(path: pathlib.Path, source: Image.Image, size: int) -> None:
    # A tile is the mark on a transparent square; Windows paints the colour.
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    mark = source.resize((int(size * 0.7), int(size * 0.7)), Image.LANCZOS)
    offset = ((size - mark.width) // 2, (size - mark.height) // 2)
    canvas.alpha_composite(mark, offset)
    canvas.save(path, format="PNG")


def main() -> int:
    if not SOURCE.exists():
        print(f"missing {SOURCE}: run tooling/brand/generate.py first", file=sys.stderr)
        return 1
    OUT.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE).convert("RGBA")
    ico(OUT / "app.ico", source)
    ico(OUT / "doc.ico", source)
    ico(OUT / "pdf.ico", source)
    tile(OUT / "Logo.png", source, 150)
    tile(OUT / "SmallLogo.png", source, 70)
    for p in sorted(OUT.iterdir()):
        print(f"  {p.relative_to(ROOT)}  {p.stat().st_size} bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
