# Feature: Settings surface

Status: **T1–T5 built and tested**; T6 is a gap (`S-36`).
Owner docs: `docs/PRODUCT.md` (settings), `docs/ROADMAP.md` M5. Patch: `0010`.

Stedding's own settings live in one section of chrome://settings, listed first and
carrying the Stedding mark. Every row is one profile preference declared in
`chrome/browser/ui/stedding/stedding_prefs.h`, read by exactly one feature, and on by
default: the section exists to turn a behaviour off, never to enable one. A feature that
gains a preference adds a row here and a behaviour in its own spec.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| T1 | chrome://settings/stedding exists, is the first entry in the settings menu, and is titled "Stedding" with the Stedding mark. | live: capture; `tooling/probes/settings.json` | built |
| T2 | Every Stedding preference registers on every profile and defaults to on, so every toggle starts on. | `SteddingPrefsTest.EveryPreferenceRegistersAndDefaultsToOn` | built |
| T3 | "Open links that leave a pinned tab's site in a peek" off makes pinned tabs follow links (peek P10). | `ShouldPeekTest.SettingOffFollowsLinks` | built |
| T4 | "Show the command-bar hint on the new tab page" off removes the hint line (new-tab N3). | live: toggle, open a new tab, the hint probe in `tooling/probes/ntp.json` fails as it should | built |
| T5 | "Show most-visited shortcuts on the new tab page" off leaves an empty page (new-tab N5). | live: toggle, then the new tab page puts `hidden` on its shortcut row, the same attribute mechanism T4 proves (a fresh profile has no shortcuts to see either way) | built |
| T6 | Sidebar and Spaces settings (width, auto-archive, Space management) once those behaviours exist. | none yet | gap |
