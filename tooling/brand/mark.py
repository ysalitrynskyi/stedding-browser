"""The Stedding mark, defined once.

Every asset in branding/ is generated from the geometry here, so there is exactly
one place to change the logo. Hand-edited derivatives drift; generated ones cannot.

Geometry is authored on a 120x120 grid and scaled. An arch sheltering a warm point
of light: the haven, and someone at rest inside it.
"""

# Palette. Deliberately not blue — every Chromium browser is blue, and looking
# like the thing you forked from is a poor way to be recognisable.
SLATE = "#2F4858"   # the safe dark: shelter, ground
CREAM = "#F2E9DE"   # warm off-white: stone, not clinical white
AMBER = "#E8B04B"   # the one warm note: the person at rest
INK   = "#1C2B33"   # near-black, for hairlines on light grounds

BOX = 120.0
CORNER = 26.0        # tile radius at 120
ARCH_STROKE = 11.0
HEARTH_R = 11.0


def arch_path(s=1.0):
    """The arch, as an SVG path. s scales the 120-grid geometry."""
    def n(v):
        v = v * s
        return f"{v:.3f}".rstrip("0").rstrip(".")
    return (f"M{n(26)} {n(98)} V{n(58)} "
            f"a{n(34)} {n(34)} 0 0 1 {n(68)} 0 V{n(98)}")


def mark(s=1.0, arch=CREAM, hearth=AMBER, dx=0.0, dy=0.0):
    """The arch plus hearth, without any background."""
    def n(v):
        return f"{v:.3f}".rstrip("0").rstrip(".")
    g = (f'<path d="{arch_path(s)}" fill="none" stroke="{arch}" '
         f'stroke-width="{n(ARCH_STROKE * s)}" stroke-linecap="round" '
         f'stroke-linejoin="round"/>'
         f'<circle cx="{n(60 * s)}" cy="{n(79 * s)}" r="{n(HEARTH_R * s)}" '
         f'fill="{hearth}"/>')
    if dx or dy:
        return f'<g transform="translate({n(dx)},{n(dy)})">{g}</g>'
    return g


def svg(body, w, h, title, desc):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" '
            f'width="{w}" height="{h}" role="img" aria-labelledby="t d">'
            f'<title id="t">{title}</title><desc id="d">{desc}</desc>'
            f'{body}</svg>\n')


DESC = ("An arch sheltering a warm point of light: a haven with someone at rest "
        "inside it.")
