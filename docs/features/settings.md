# Feature: Settings surface

Status: **T1–T8 built and tested**; T9 is a gap (`S-36`).
Owner docs: `docs/PRODUCT.md` (settings), `docs/ROADMAP.md` M5. Patch: `0010`.

Stedding's own settings live in one section of chrome://settings, listed first and
carrying the Stedding mark. Every row is one profile preference — Stedding's own in `chrome/browser/ui/stedding/stedding_prefs.h`
(on by default), or a Chromium preference for a behaviour Stedding leans on — read by
exactly one feature. A feature that
gains a preference adds a row here and a behaviour in its own spec.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| T1 | chrome://settings/stedding exists, is the first entry in the settings menu, and is titled "Stedding" with the Stedding mark. | live: capture; `tooling/probes/settings.json` | built |
| T2 | Every Stedding preference registers on every profile and defaults to on, so every toggle starts on. | `SteddingPrefsTest.EveryPreferenceRegistersAndDefaultsToOn` | built |
| T3 | "Open links that leave a pinned tab's site in a peek" off makes pinned tabs follow links (peek P10). | `ShouldPeekTest.SettingOffFollowsLinks` | built |
| T4 | "Show the command-bar hint on the new tab page" off removes the hint line (new-tab N3). | live: toggle, open a new tab, the hint probe in `tooling/probes/ntp.json` fails as it should | built |
| T5 | "Show most-visited shortcuts on the new tab page" off leaves an empty page (new-tab N5). | live: toggle, then the new tab page puts `hidden` on its shortcut row, the same attribute mechanism T4 proves (a fresh profile has no shortcuts to see either way) | built |
| T6 | "Expand the collapsed sidebar when the pointer rests on it" binds Chromium's own `vertical_tabs.expand_on_hover_enabled` (off by default upstream); the row sits with the sidebar behaviours, before the new-tab rows. | live: capture 2026-09-02 | built |
| T7 | A "Sidebar width" slider (126–480, Chromium's clamp) binds `vertical_tabs.uncollapsed_width`; moving it resizes the sidebar at once, and dragging the sidebar's edge moves the slider. | live: `tooling/drive` clicks at three slider positions, content edge measured at three widths (2026-09-02) | built |
| T8 | "Archive tabs nobody has looked at for" dropdown (Never, 6 h, 12 h, 1 day, 3 days) binds `stedding.archive.idle_hours`; the archiver reads it at every sweep (archive A5). | `TabArchiverTest.ZeroHoursDisables`; capture | built |
| T9 | Space management (rename, reorder, delete Spaces from settings) once a Space management surface exists. | none yet | gap |
