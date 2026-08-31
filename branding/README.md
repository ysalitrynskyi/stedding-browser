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

## Status

`BRANDING` is real. **The icons are not written yet** and this directory does not
contain them; `tooling/apply-branding` copies whatever is present and reports what is
missing rather than substituting anything. A build with no icon here keeps Chromium's,
which is honest and obvious, rather than shipping a placeholder that might survive to
a release.

Icon requirements when they are made: `app.icns` needs the full set of sizes macOS
expects (16 through 1024 at 1x and 2x). `AppIcon.icon` is the newer vector source and
is compiled at build time; `Assets.car` is prebuilt and simply copied.

## Reverting

The files this overwrites are tracked in the Chromium repository, so
`tooling/apply-branding --revert` restores them with `git checkout`. Applying branding
leaves the Chromium checkout dirty by design: that is what makes it visible in
`git status` and trivially reversible.
