# branding/

Assets that replace Chromium's before the build. Copied over the checkout by
`tooling/apply-branding`; **nothing here is a patch**, which is the point — see the
Branding section of [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

| Path here | Replaces in the Chromium checkout |
|---|---|
| `BRANDING` | `chrome/app/theme/chromium/BRANDING` |
| `mac/app.icns` | `chrome/app/theme/chromium/mac/app.icns` |
| `mac/AppIcon.icon` | `chrome/app/theme/chromium/mac/AppIcon.icon` |
| `mac/Assets.car` | `chrome/app/theme/chromium/mac/Assets.car` |
| `product_logo/*` | `chrome/app/theme/chromium/product_logo*` (the About page, the Dock, the installer) |
| `product_logo/scaled_100/*`, `scaled_200/*` | `chrome/app/theme/default_{100,200}_percent/chromium/product_logo_{16,32,name_22,name_22_white}.png` (the scaled logos WebUI serves as `chrome://theme/current-channel-logo`: settings header, About page, profile picker) |
| `vector_icons/chrome_product.icon` | `components/omnibox/browser/vector_icons/chrome_product.icon` (the chrome:// page chip, the app menu) |
| `webui_images/chrome_logo_dark.svg` | `ui/webui/resources/images/chrome_logo_dark.svg` (the white product logo WebUI pages show: settings header, history, downloads) |

Upstream's branding switch is boolean — `chromium/` or `google_chrome/` — and grit
includes hardcode `chromium/`, so there is no third directory to add. Our files
overwrite the `chromium/` tree in place, which is why the copy must happen before
`gn gen`.

## The BRANDING file format

`BRANDING` is a data file in a format Chromium defines, not one of ours. Chromium's
`build/util/version.py` reads it with `line.split('=', 1)` on **every** line, so:

- Every line must be `KEY=VALUE`.
- **No comments. No blank lines.** Either throws.

A malformed file does not fail where you edited it. It fails much later inside
`gn gen`, as `branding.gni: Script returned non-zero exit code` plus a Python
traceback, which is a long way from the cause. `tooling/apply-branding` therefore
validates the file the same way upstream will, before installing it.

That is why the explanations live in this README rather than in the file itself.

## Generated, not authored

Everything except `BRANDING` is produced by:

```bash
python3 tooling/brand/generate.py
```

from the single geometry definition in `tooling/brand/mark.py`. Do not hand-edit
the SVGs, PNGs, `app.icns` or `Assets.car` — change the mark and re-run. Hand-
edited derivatives drift apart from each other; generated ones cannot.

`public/` is a drop-in web brand folder (favicons, social card, logo variants)
and `public/_preview.html` shows every asset, with the small sizes at actual
size. `public/README.md` has the palette and the reasoning.

## The macOS icon needs three files, not one

Replacing `app.icns` alone leaves the old icon showing. Modern macOS reads the
compiled asset catalog:

| File | What reads it |
|---|---|
| `mac/app.icns` | older macOS, some tooling |
| `mac/Assets.car` | modern macOS — compiled from `mac/Assets.xcassets` with `actool` |
| `mac/AppIcon.icon` | macOS 26's vector format, authored in Icon Composer |

## Status

`BRANDING`, `app.icns` and `Assets.car` are real and applied.

**`AppIcon.icon` is still Chromium's.** It is macOS 26's new vector icon format,
which is authored in Icon Composer rather than generated from an SVG, so ours
does not exist yet. `tooling/apply-branding` reports it as absent on every run
rather than substituting a placeholder — a placeholder icon is exactly the kind
of thing that survives to a release.

## Reverting

The files this overwrites are tracked in the Chromium repository, so
`tooling/apply-branding --revert` restores them with `git checkout`. Applying
branding leaves the Chromium checkout dirty by design: that is what makes it
visible in `git status` and trivially reversible.
