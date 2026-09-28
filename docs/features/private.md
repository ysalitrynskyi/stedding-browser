# Feature: Private windows wear a different coat

Status: **V3, V6 built; V1, V2 and V7 planned, written, not yet run** (one test for "private", `PLAN.md` WIN-4); **V4 and V5 dropped** (round 6, `docs/ROUND6-PLAN.md` R6-32).
Owner docs: `docs/PRIVACY.md`, `docs/PRODUCT.md` §7. Patch: 0034.

A private window (⇧⌘N) must be told apart at a glance and must leave nothing in the
sidebar's model, the session or the archive. It paints a flat graphite ground with no
Space tint, its title row reads "Private", it has no Space switcher, and Chromium's
"Incognito" badge is back for it alone.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| V1 | A private window paints a flat graphite ground in both schemes: no gradient, no Space tint; the mat, the page bar and the command bar follow through the colour mixer. Private is decided once, by `stedding::IsPrivateWindow` (an incognito profile), and the window says so on its colour key: `BrowserWidget::GetColorProviderKey` puts Stedding's private mark in the key's app-controller slot, and the mixer paints graphite for that key alone. It used to infer "private" from a dark, grayscale key, which is also a normal window in dark mode with Chrome's Grey colour: that window, which keeps history, was painted graphite (`PLAN.md` WIN-F8). | `SteddingColorMixerTest.PrivateWindowsAreGraphite`, `SteddingColorMixerTest.GreyInDarkModeIsNotPrivate`, `PrivateWindowTest.IncognitoIsPrivate`; captures `w4_private_dark`, `w4_private_light` | built |
| V2 | The Space title row reads "Private" with the incognito glyph and opens no menu; the switcher row shows no chips and no "+"; the window title carries " – Private". The label and the title follow `stedding::IsPrivateWindow`, the same test as the coat (V1), so a Guest window has neither (V7). | `SpaceWindowTest.PrivateWindowHasNoSpaceModel` (no model, so no switcher and no chords), `PrivateWindowTest.*`; capture `w4_private_dark` (the row and the title) | built |
| V3 | No `SpaceModel` and no `TabArchiver` for a private window: the archiver never closes a private tab, and nothing private reaches the sidebar model or the session's extra data. | `TabArchiverTest.SkipsOffTheRecordWindows`, `SpaceWindowTest.PrivateWindowHasNoSpaceModel` | built |
| V4 | Chromium's avatar badge ("Incognito") shows again for private windows only; every other window keeps the toolbar without it. | none yet | gap · dropped: the address row keeps Chromium's avatar button hidden; the coat, the title row's glyph and the window title say what the window is |
| V5 | The local new tab page adds one line under the hint: "Private window: history, cookies and site data are forgotten when the last private window closes". | none yet | gap · dropped: a private window shows Chromium's own incognito new tab page, which already says what is forgotten; Stedding's local page never appears there |
| V6 | Peek and its promotion into a split stay inside the private window. | by construction: `PeekView::PromoteToTab` and `PromoteToSplit` insert into the peek's own window; live: ⌘O on a private peek stays private | built |
| V7 | A Guest window is not private. Its profile is off the record, so it has no Spaces and no archive, and it gets the private window's rows -- the New Tab row, the Clear line, no Space switcher, no "+" pill -- but it wears the ordinary coat (the sand or navy ground, not graphite), its title row stays empty, and its window title has no " – Private". It was labelled "Private" without the coat (`PLAN.md` WIN-F8). | `PrivateWindowTest.OffTheRecordAloneIsNotPrivate`; live: a Guest window's ground and title | partial · the flag is tested; a Guest window's ground and title are not yet seen on a build |
| V8 | ⇧⌘K (and the Clear rows of the menus) closes a private window's tabs and keeps the window and its private session, with one New Tab; the window has no Spaces, so no pinned run and no Clear line (spaces B17). The command was disabled there, because it read the window as having no Spaces to clear (PLAN.md CMD-3). | browser: `ClearSpaceTest.ClearingAPrivateWindowKeepsIt` | built |

## Notes

- Chromium forces a dark, grayscale colour key for incognito, and a normal window with
  Chrome's Grey colour in dark mode gets the same key, so the key's colour fields cannot
  say "private". The window says it instead: `BrowserWidget` puts Stedding's private
  mark (`SteddingPrivateWindowMark()`) in the key's app-controller slot for a window
  `stedding::IsPrivateWindow` calls private, and `AddSteddingColorMixer` paints graphite
  for that key. When private windows get a page colour (`PLAN.md` WIN-6) the mark and
  the page bar's supplier must share that slot.
- The Space chords (⌃1–9, ⌥⌘←/→) do nothing in a private window: there is no model to
  act on (spaces B29).
- "Private" as the title row's text is a VoiceOver label too (critic #31).
