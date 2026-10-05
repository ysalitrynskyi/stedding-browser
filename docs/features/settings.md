# Feature: Settings surface

Status: **T1, T2, T4–T10 built; T11, T12 partial**; **T3 withdrawn** while Peek is rebuilt (round 6, `docs/ROUND6-PLAN.md` R6-09, backlog S-43).
Owner docs: `docs/PRODUCT.md` (settings), `docs/ROADMAP.md` M5. Patch: `0010`.

Stedding's own settings live in one section of chrome://settings, listed first and
carrying the Stedding mark. Every row is one profile preference — Stedding's own in `chrome/browser/ui/stedding/stedding_prefs.h`
(with the default its feature spec names), or a Chromium preference for a behaviour Stedding leans on — read by
exactly one feature. A feature that
gains a preference adds a row here and a behaviour in its own spec.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| T1 | chrome://settings/stedding exists, is the first entry in the settings menu, and is titled "Stedding" with the Stedding mark. | live: capture; `tooling/probes/settings.json` | built |
| T2 | Every Stedding preference registers on every profile with the default its spec names: on, except Peek (off while it is rebuilt), "Hide the address row with the sidebar" (off since 2026-10-01, toolbar T8 and T12) and the Space sleep timer (Never until sleep is gated). | `SteddingPrefsTest.EveryPreferenceRegistersWithItsDefault` | built |
| T3 | "Open links that leave a pinned tab's site in a peek": the row is hidden while Peek is rebuilt (PLAN.md CMD-4, CMD-9); the preference stays off. | none | withdrawn · returns with Peek |
| T4 | "Show the command-bar hint on the new tab page" off removes the hint line (new-tab N3). | live: toggle, open a new tab, the hint probe in `tooling/probes/ntp.json` fails as it should | built |
| T5 | "Show most-visited shortcuts on the new tab page" off leaves an empty page (new-tab N5). | live: toggle, then the new tab page puts `hidden` on its shortcut row, the same attribute mechanism T4 proves (a fresh profile has no shortcuts to see either way) | built |
| T6 | "Expand the collapsed sidebar when the pointer rests on it" binds Chromium's own `vertical_tabs.expand_on_hover` (off by default upstream); the row sits with the sidebar behaviours, before the new-tab rows. Chromium named the pref `vertical_tabs.expand_on_hover_enabled` before M155; from the move to 155.0.8059.12 (2026-09-24) until 2026-09-29 the row still asked for the old name, so the switch did nothing and the page threw. | browser: `SettingsSpacesTest.EveryControlHasItsPreference` (every control on the rendered page is bound to a preference the settings page can read; with the old name it fails and names it); live: capture 2026-09-02 | built |
| T7 | A "Sidebar width" slider (126–480, Chromium's clamp) binds `vertical_tabs.uncollapsed_width`; moving it resizes the sidebar at once, and dragging the sidebar's edge moves the slider. | live: `tooling/drive` clicks at three slider positions, content edge measured at three widths (2026-09-02) | built |
| T8 | "Archive tabs nobody has looked at for" dropdown (Never, 6 h, 12 h, 1 day, 3 days) binds `stedding.archive.idle_hours`; the archiver reads it at every sweep (archive A5). | `TabArchiverTest.ZeroHoursDisables`; capture | built |
| T9 | A "Spaces" list in the section shows this window's Spaces with swatch and icon; typing a new name renames the Space (the switcher pill follows), the bin deletes one and is disabled for the last; the list refreshes when the sidebar adds, renames or removes a Space. A toggle per Space is Independent session (sessions S10), which asks first when open pages would reload. The list follows its tab: moved to another window, whose first window then closes, the page still lists that window's Spaces, and reloading or closing it is quiet (PLAN.md SPC-1, WEB-2). | live: `tooling/drive` adds a Space from the sidebar, renames it from settings, reads the switcher pill, deletes it (2026-09-02); browser: `SettingsSpacesTest.TheListFollowsTheTabToAnotherWindow` | built |
| T10 | chrome://settings/help reads "Stedding <VERSION> · Chromium <pin>" with no "(Developer Build)" modifier; `VERSION` (through a GN argument the build tooling sets) and `tooling/chromium-version` are the sources. | `SteddingVersionTest.AboutStringNamesBothVersions`; capture of the About page, dark and light | built |
| T11 | "Open the collapsed sidebar on hover" dropdown -- after 0.35 seconds (Chromium's timing), 1, 2 or 5 seconds -- writes `stedding.sidebar.hover_delay_ms` (sidebar Y11). | none yet; live: `w9_hover_setting` (Windows, 2026-09-09) | partial · no unit test yet (S-49) |
| T12 | No "Theme" row on chrome://settings/appearance: it opened Chromium's Customize Chrome panel, whose colours barely reach a window the Space tints (spaces B11) and whose promos point at the Web Store, one of them a toast in white on white (operator, 2026-09-09). Hidden through the page-visibility rule the Google sections use (`page_visibility.ts`, patch 0044); the colour scheme, toolbar, font and zoom rows stay. | none; live: `w10_appearance` (Windows, 2026-09-10) | partial · no unit test yet (S-49) |
