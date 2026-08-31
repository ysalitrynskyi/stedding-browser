#!/usr/bin/env python3
"""Generate the whole Stedding brand system from tooling/brand/mark.py.

Writes branding/ (the source assets and the macOS icon set the build consumes)
and branding/public/ (a drop-in web brand folder).

Everything here is derived. Do not hand-edit the output — change mark.py and
re-run, or the derivatives drift apart from each other.
"""
import os, shutil, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mark as M

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
BRAND = os.path.join(ROOT, "branding")
PUB = os.path.join(BRAND, "public")


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    return path


def tile(bg, arch, hearth, radius=M.CORNER, size=120):
    s = size / M.BOX
    body = (f'<rect width="{size}" height="{size}" rx="{radius * s:.3f}" fill="{bg}"/>'
            + M.mark(s, arch, hearth))
    return M.svg(body, size, size, "Stedding", M.DESC)


def circle(bg, arch, hearth, size=120):
    s = size / M.BOX
    body = (f'<circle cx="{size/2}" cy="{size/2}" r="{size/2}" fill="{bg}"/>'
            + M.mark(s, arch, hearth))
    return M.svg(body, size, size, "Stedding", M.DESC)


def glyph(arch, hearth, size=120):
    s = size / M.BOX
    return M.svg(M.mark(s, arch, hearth), size, size, "Stedding", M.DESC)


def wordmark(bg, arch, hearth, text_color, w=520, h=140):
    """Mark plus the name, for headers and README banners."""
    s = 96 / M.BOX
    body = (("" if bg is None else f'<rect width="{w}" height="{h}" fill="{bg}"/>')
            + f'<g transform="translate(28,22)">'
            + f'<rect width="96" height="96" rx="{M.CORNER * s:.2f}" fill="{M.SLATE if bg != M.SLATE else M.INK}"/>'
            + M.mark(s, arch, hearth) + '</g>'
            + f'<text x="150" y="86" font-family="Helvetica Neue, Helvetica, Arial, sans-serif" '
              f'font-size="52" font-weight="500" letter-spacing="1.5" fill="{text_color}">Stedding</text>')
    return M.svg(body, w, h, "Stedding", M.DESC)


def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit(f"failed: {' '.join(cmd)}\n{r.stderr[:400]}")


def main():
    for d in (os.path.join(BRAND, "logo"), PUB):
        shutil.rmtree(d, ignore_errors=True)

    svgs = {
        "icon-tile-slate":   tile(M.SLATE, M.CREAM, M.AMBER),
        "icon-tile-cream":   tile(M.CREAM, M.SLATE, M.AMBER),
        "icon-square-slate": tile(M.SLATE, M.CREAM, M.AMBER, radius=0),
        "icon-square-cream": tile(M.CREAM, M.SLATE, M.AMBER, radius=0),
        "icon-circle-slate": circle(M.SLATE, M.CREAM, M.AMBER),
        "icon-circle-cream": circle(M.CREAM, M.SLATE, M.AMBER),
        "icon-glyph-cream":  glyph(M.CREAM, M.AMBER),
        "icon-glyph-slate":  glyph(M.SLATE, M.AMBER),
        "icon-glyph-mono-cream": glyph(M.CREAM, M.CREAM),
        "icon-glyph-mono-slate": glyph(M.SLATE, M.SLATE),
        "logo-horizontal-light": wordmark(None, M.CREAM, M.AMBER, M.INK),
        "logo-horizontal-dark":  wordmark(M.SLATE, M.CREAM, M.AMBER, M.CREAM),
    }
    for name, text in svgs.items():
        write(os.path.join(PUB, "svg", f"{name}.svg"), text)

    # The canonical mark, and the favicon, at the top level where tools look.
    write(os.path.join(BRAND, "logo", "stedding-mark.svg"), svgs["icon-tile-slate"])
    write(os.path.join(PUB, "favicon.svg"), svgs["icon-tile-slate"])
    write(os.path.join(PUB, "og-image.svg"),
          wordmark(M.SLATE, M.CREAM, M.AMBER, M.CREAM, w=1200, h=630))

    src_tile = os.path.join(PUB, "svg", "icon-tile-slate.svg")

    # PNG ladder. 16 first, deliberately: if it fails there it fails where it counts.
    png_dir = os.path.join(PUB, "png")
    sizes = [16, 32, 48, 64, 96, 128, 180, 192, 256, 512, 1024]
    for n in sizes:
        out = os.path.join(png_dir, f"icon-{n}.png")
        os.makedirs(png_dir, exist_ok=True)
        run(["rsvg-convert", "-w", str(n), "-h", str(n), src_tile, "-o", out])

    shutil.copy(os.path.join(png_dir, "icon-180.png"),
                os.path.join(PUB, "apple-touch-icon.png"))
    # 16/32/48 only, and PNG-compressed. Including a raw 256 layer inflates the
    # file about twentyfold for a size no browser asks a .ico for — favicon.svg
    # covers the large case.
    run(["magick",
         os.path.join(png_dir, "icon-16.png"),
         os.path.join(png_dir, "icon-32.png"),
         os.path.join(png_dir, "icon-48.png"),
         "-compress", "zip",
         os.path.join(PUB, "favicon.ico")])
    run(["rsvg-convert", "-w", "1200", "-h", "630",
         os.path.join(PUB, "og-image.svg"), "-o",
         os.path.join(PUB, "og-image.png")])

    # macOS .icns — what the app bundle actually wears.
    iconset = os.path.join(BRAND, "mac", "stedding.iconset")
    shutil.rmtree(iconset, ignore_errors=True)
    os.makedirs(iconset, exist_ok=True)
    for base in (16, 32, 128, 256, 512):
        run(["rsvg-convert", "-w", str(base), "-h", str(base), src_tile,
             "-o", os.path.join(iconset, f"icon_{base}x{base}.png")])
        run(["rsvg-convert", "-w", str(base * 2), "-h", str(base * 2), src_tile,
             "-o", os.path.join(iconset, f"icon_{base}x{base}@2x.png")])
    run(["iconutil", "-c", "icns", iconset,
         "-o", os.path.join(BRAND, "mac", "app.icns")])
    shutil.rmtree(iconset, ignore_errors=True)

    # Assets.car — what modern macOS actually reads for the app icon. The build
    # copies a prebuilt catalog rather than compiling one, so we compile ours
    # here with actool and ship the .car alongside app.icns. Replacing only
    # app.icns leaves the old icon showing on macOS 11 and later.
    xc = os.path.join(BRAND, "mac", "Assets.xcassets")
    shutil.rmtree(xc, ignore_errors=True)
    appicon = os.path.join(xc, "AppIcon.appiconset")
    os.makedirs(appicon, exist_ok=True)
    write(os.path.join(xc, "Contents.json"),
          '{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')
    for n in (16, 32, 64, 128, 256, 512, 1024):
        run(["rsvg-convert", "-w", str(n), "-h", str(n), src_tile,
             "-o", os.path.join(appicon, f"appicon_{n}.png")])
    entries = []
    for size, scale, fname in (
            (16, "1x", 16), (16, "2x", 32), (32, "1x", 32), (32, "2x", 64),
            (128, "1x", 128), (128, "2x", 256), (256, "1x", 256),
            (256, "2x", 512), (512, "1x", 512), (512, "2x", 1024)):
        entries.append('    {\n      "filename" : "appicon_%d.png",\n'
                       '      "idiom" : "mac",\n      "scale" : "%s",\n'
                       '      "size" : "%dx%d"\n    }' % (fname, scale, size, size))
    write(os.path.join(appicon, "Contents.json"),
          '{\n  "images" : [\n' + ",\n".join(entries) +
          '\n  ],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')
    carbuild = os.path.join(BRAND, "mac", ".carbuild")
    shutil.rmtree(carbuild, ignore_errors=True)
    os.makedirs(carbuild, exist_ok=True)
    run(["xcrun", "actool", "--compile", carbuild, "--platform", "macosx",
         "--minimum-deployment-target", "11.0", "--app-icon", "AppIcon",
         "--output-partial-info-plist", os.path.join(carbuild, "partial.plist"),
         xc])
    shutil.copy(os.path.join(carbuild, "Assets.car"),
                os.path.join(BRAND, "mac", "Assets.car"))
    shutil.rmtree(carbuild, ignore_errors=True)

    print("generated:")
    for d in (BRAND, PUB):
        for dirpath, _, files in os.walk(d):
            if "public" in dirpath and d == BRAND:
                continue
            for f in sorted(files):
                p = os.path.join(dirpath, f)
                print(f"  {os.path.relpath(p, ROOT):<58} {os.path.getsize(p):>8} B")


if __name__ == "__main__":
    main()
