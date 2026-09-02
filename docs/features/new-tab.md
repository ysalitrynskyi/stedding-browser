# Feature: New tab page

Status: **N1–N4 built**; N5 is a gap (`S-33`).
Owner docs: `docs/PRIVACY.md` (no request on a new tab), `docs/UI-SPEC.md`. Patch: `0003`
(the de-Google patch: default search, choice screen, local new tab page).

The new tab page is Chromium's local "third-party" page, always, whatever the default
search engine offers: nothing on it leaves the machine. It is a calm place to press the
command-bar shortcut, not a feed.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| N1 | A new tab opens the local page, never a search engine's remote new tab page, whichever engine is the default. | `search.cc` hunk (`kUseProviderNewTabPage`); live: `tooling/drive` on a fresh profile with DuckDuckGo shows the local page | built |
| N2 | A fresh profile has no Chrome Web Store shortcut; the shortcut row shows only sites the user visited. | live: capture of a fresh profile shows no tile | built |
| N3 | The page says how to open the command bar, using the platform's own shortcut glyphs (⌘T on macOS, Ctrl+T elsewhere). | live: capture; `tooling/probes/ntp.json` | built |
| N4 | The page's background follows the theme (sand in light, the gradient's ground in dark), with no hard-coded Google colours. | `tooling/probes/ntp.json` | built |
| N5 | A setting to hide the shortcut row entirely, for users who want Arc's empty page. | none yet | gap |
