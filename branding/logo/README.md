# branding/logo/

`stedding-mark.svg` is the source of truth for the app mark. Everything else —
the `.icns`, the `Assets.car`, favicons, the site — is generated from it.

## What it is

An arch sheltering a warm point of light. A *stedding* is a haven where outside
power cannot reach (`../../docs/NAMING.md`), so the mark is the shelter and the
person at rest inside it, rather than a drawing of either.

## Why it is not a picture of a person

A browser icon spends most of its life at 16px, in a tab strip and a Dock. A
drawn figure at 16px is four grey pixels. Two more literal directions were tried
— a figure standing inside an arch, and a seated form under a roof — and both
became unreadable at the size where the icon actually gets used. The abstract
mark keeps its meaning down to 16px because it is two shapes, not twelve.

Judge any future revision at 16px first. If it does not survive there, it does
not matter how it looks at 512.

## Colours

| | | |
|---|---|---|
| Shelter | `#2F4858` | deep slate — the ground, the safe dark |
| Arch | `#F2E9DE` | warm off-white — stone, not clinical white |
| Hearth | `#E8B04B` | amber — the one warm note, the person at rest |

Deliberately not blue. Every Chromium browser is blue, and looking like the
thing you forked from is a poor way to be recognisable.

## Still to do

The `.icns` and `Assets.car` are **not generated yet**, so builds still carry
Chromium's icon. `tooling/apply-branding` reports them as absent rather than
substituting a placeholder — see `../README.md` for why that is deliberate.
