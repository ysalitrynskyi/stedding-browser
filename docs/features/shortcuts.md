# Feature: Shortcut reference

Status: **Z1–Z5 built** (round 6, `docs/ROUND6-PLAN.md` R6-01); **Z6 partial** (round 9, every platform).
Owner docs: `docs/QUALITY.md` ("UX completeness"), `docs/ROADMAP.md` M6. Patches: round 6 wave 1; `0043` (every platform).

chrome://settings/stedding carries a read-only "Shortcuts" block: every chord Stedding
adds and every Chromium chord Stedding rebinds, read from the accelerator tables at
startup so the list cannot drift from the binary. Items that remap a chord add their
divergence row here, in their own patch; nothing is hand-typed. Remapping by the user
(`docs/PRODUCT.md` §12, 1.0) is out of scope.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Z1 | chrome://settings/stedding carries a "Shortcuts" block listing every Stedding chord and every Chromium chord Stedding remaps, built from the accelerator tables (the Mac's `accelerators_cocoa.mm` and `global_keyboard_shortcuts_mac.mm`, the views `accelerator_table.cc` elsewhere, Z6) at startup, never hand-typed; it is the in-product shortcut reference `docs/QUALITY.md` and `docs/ROADMAP.md` cite. | `ShortcutReferenceTest.EverySteddingCommandWithAnAcceleratorIsListed`; capture, dark and light | built |
| Z2 | Every remapped Chromium chord has a divergence row: the chord, what Chromium binds it to, what Stedding binds it to (⌘S and ⇧⌘S from round 5; ⌘D, ⇧⌘C, ⌥⌘↑/↓, ⇧⌘K from round 6). Items record divergences here, not in `docs/QUALITY.md`. | `ShortcutReferenceTest.DivergenceRowsNameBothBindings` | built |
| Z3 | A note row records that ⌃1–⌃9 collide with macOS Mission Control "Switch to Desktop N" once a second desktop exists (plan D5); on Windows the note is Alt's -- a tap of Alt alone still focuses the app menu -- and a second one says what AltGr does to a Ctrl+Alt chord. | `ShortcutReferenceTest.SpaceKeysNoteIsPresent`; capture | built |
| Z4 | The block is found by settings search ("shortcuts"); welcome step 5 (W6) links to it. The ⌘T action "Show keyboard shortcuts" arrives with R6-11 (wave 2). | live: settings search; welcome link | built |
| Z5 | Remapping (`docs/PRODUCT.md` §12 "Keyboard shortcut customisation", 1.0) is out of scope for round 6; the block is read-only. | spec row | built |
| Z6 | The reference is the platform's: chords come from `GetAcceleratorForCommandId`, which reads the Mac's menu tables there and the views accelerator table on Windows; the divergence rows name what Chromium bound on that platform (Ctrl+Shift+P was the system print dialog, Ctrl+Shift+C Inspect) and the notes are the platform's (Z3). The handler, its test and the block on chrome://settings/stedding build everywhere (windows N5, N7). | `ShortcutReferenceTest.EverySteddingCommandWithAnAcceleratorIsListed`, `ShortcutReferenceTest.DivergenceRowsNameBothBindings`, `ShortcutReferenceTest.SpaceKeysNoteIsPresent`; live: `w10_shortcuts` (Windows, 2026-09-10) | partial · the tests run on the Mac, not yet on a Windows runner (S-49) |

## Running the tests

```bash
tooling/dev test shortcuts
```

- ⇧⌘D shows or hides the address row on its own (toolbar T10); Chromium had no
  chord on it in Stedding's tables, and Bookmark All Tabs keeps its menu item.
- Inside a little window (little E2), ⌘O sends the page into a tab (Open File
  elsewhere), ⇧⌘O into a split and Escape closes the window; ⌥⌘N stays the split
  (welcome W6), where Arc opens a little window: a divergence recorded here, the
  decision left for later (little E5).
