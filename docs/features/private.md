# Feature: Private windows wear a different coat

Status: **V1–V3, V6 built, V4 and V5 dropped** (round 6, `docs/ROUND6-PLAN.md` R6-32).
Owner docs: `docs/PRIVACY.md`, `docs/PRODUCT.md` §7. Patch: 0034.

A private window (⇧⌘N) must be told apart at a glance and must leave nothing in the
sidebar's model, the session or the archive. It paints a flat graphite ground with no
Space tint, its title row reads "Private", it has no Space switcher, and Chromium's
"Incognito" badge is back for it alone.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| V1 | An off-the-record window paints a flat graphite ground in both schemes: no gradient, no Space tint; the mat, the page bar and the command bar follow through the colour mixer. | `SteddingColorMixerTest.PrivateWindowsAreGraphite`; captures `w4_private_dark`, `w4_private_light` | built |
| V2 | The Space title row reads "Private" with the incognito glyph and opens no menu; the switcher row shows no chips and no "+"; the window title carries " – Private". | `SpaceWindowTest.PrivateWindowHasNoSpaceModel` (no model, so no switcher and no chords); capture `w4_private_dark` (the row and the title) | built |
| V3 | No `SpaceModel` and no `TabArchiver` for a private window: the archiver never closes a private tab, and nothing private reaches the sidebar model or the session's extra data. | `TabArchiverTest.SkipsOffTheRecordWindows`, `SpaceWindowTest.PrivateWindowHasNoSpaceModel` | built |
| V4 | Chromium's avatar badge ("Incognito") shows again for private windows only; every other window keeps the toolbar without it. | none yet | gap · dropped: the address row keeps Chromium's avatar button hidden; the coat, the title row's glyph and the window title say what the window is |
| V5 | The local new tab page adds one line under the hint: "Private window: history, cookies and site data are forgotten when the last private window closes". | none yet | gap · dropped: a private window shows Chromium's own incognito new tab page, which already says what is forgotten; Stedding's local page never appears there |
| V6 | Peek and its promotion into a split stay inside the private window. | by construction: `PeekView::PromoteToTab` and `PromoteToSplit` insert into the peek's own window; live: ⌘O on a private peek stays private | built |

## Notes

- Chromium already forces a dark, grayscale colour key for incognito; Stedding's mixer
  reads that key (`ColorProviderKey::ColorMode` and the incognito bit) and paints
  graphite instead of the navy gradient.
- The Space chords (⌃1–9, ⌥⌘←/→) do nothing in a private window: there is no model to
  act on (spaces B29).
- "Private" as the title row's text is a VoiceOver label too (critic #31).
