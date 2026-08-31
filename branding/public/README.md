# Stedding brand assets

Everything here is **generated** from `tooling/brand/mark.py` by
`tooling/brand/generate.py`. Do not hand-edit — change the mark and re-run:

```bash
python3 tooling/brand/generate.py
```

Hand-edited derivatives drift apart from each other; generated ones cannot.

## The mark

An arch sheltering a warm point of light. A *stedding* is a haven where outside
power cannot reach (`../../docs/NAMING.md`), so the mark is the shelter and the
person at rest inside it, rather than a drawing of either.

**Judge every revision at 16px before 512.** A browser icon spends most of its
life in a tab strip and a Dock. Three more literal directions were drawn first —
a standing figure inside an arch, a seated form under a roof, a figure with a
ground line — and all three became unreadable at the size where the icon is
actually used. The mark is two shapes because two shapes survive.

## Palette

| Role | Hex | |
|---|---|---|
| Shelter | `#2F4858` | deep slate — the ground, the safe dark |
| Arch | `#F2E9DE` | warm off-white — stone, not clinical white |
| Hearth | `#E8B04B` | amber — the one warm note, the person at rest |
| Ink | `#1C2B33` | near-black, hairlines on light grounds |

Deliberately **not blue**. Every Chromium browser is blue, and looking like the
thing you forked from is a poor way to be recognisable.

## Contents

```
favicon.svg              the mark, for browsers that take SVG
favicon.ico              16/32/48 only — no browser asks a .ico for 256
apple-touch-icon.png     180px
og-image.svg / .png      1200x630 social card
svg/   icon-{tile,square,circle}-{slate,cream}.svg
       icon-glyph-{slate,cream}.svg          mark alone, no background
       icon-glyph-mono-{slate,cream}.svg     single colour, for stamps and print
       logo-horizontal-{light,dark}.svg      mark plus wordmark
png/   icon-{16..1024}.png
```

The macOS app assets live one level up in `../mac/`: `app.icns`, `Assets.car`
(compiled with `actool`) and the `Assets.xcassets` it is built from. Replacing
only `app.icns` is not enough — modern macOS reads the compiled catalog, so a
build with just the `.icns` swapped still shows the old icon.

## Still upstream's

`AppIcon.icon` is macOS 26's vector icon format, authored in Icon Composer. Ours
is not made yet, so that one file is still Chromium's. `tooling/apply-branding`
reports it as absent on every run rather than substituting a placeholder.
