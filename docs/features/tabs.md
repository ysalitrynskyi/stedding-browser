# Feature: Tab rows

Status: **R1–R3, R18 planned** (round 6, `docs/ROUND6-PLAN.md` R6-03); **R4–R8, R10–R17, R19–R23 built, R22 partial** (wave 2: R6-13, R6-15, R6-17, R6-20).
Owner docs: `docs/UI-SPEC.md`. Patch: TBD.

The rows of the sidebar follow Arc: the close glyph appears only while the pointer is
on the row or its close button has keyboard focus (Arc's active row carries none, as a
side-by-side capture of Arc confirmed on 2026-09-04), the title never re-elides when the
glyph appears, and an essentials card that plays audio keeps its favicon.

On Windows every chord below is the Mac's with ⌘ read as Ctrl and ⌥⌘ as Ctrl+Alt
(Alt+1–9 for the Spaces themselves); the full map is `docs/features/windows.md` N7.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| R1 | Under `stedding::kArcStyleWindow` the close button is laid out only while the row is hovered or its close button has keyboard focus; the active row carries no permanent glyph. | `TabRowRulesTest.ActiveUnhoveredHidesClose`, `HoveredShowsClose`, `FocusedShowsClose` (the rules are pure functions in `stedding_tab_row_rules.cc`; `TabViewVerticalLayout::IsChildVisible` asks them); capture | built |
| R2 | The close slot stays reserved on every expanded row, active or not, so the title does not re-elide when the glyph appears. | `TabRowRulesTest.TitleWidthUnchangedByHover` | built |
| R3 | Essentials cards and the collapsed rail never show the close glyph (⌘W and the menu close). | `TabRowRulesTest.PinnedAndCollapsedNeverShowClose` | built |
| R18 | A playing or muted essentials card keeps its favicon and shows the alert as a corner badge; a click on the badge mutes; a right-click on a silent tab's row offers Mute Site; the badge works on a split row. | `TabRowRulesTest.PlayingEssentialKeepsItsFavicon`; live: `tooling/drive` on a page with audio, capture in dark and light | built |
| R4 | A discarded row draws its title at 55% alpha of the row's text colour and hides the close glyph until hover. Chromium's discard ring is not drawn in the Stedding window. The favicon is not greyscale. | `TabRowRulesTest.SleptRowDimsTitleAndIcon` | built |
| R5 | Tab context menu 'Sleep Tab' and 'Sleep Other Tabs in This Space' call the tab lifecycle unit. Sleep Tab on the active row activates a neighbour that stays awake first. Sleep Others never takes the active row. There is no command-bar row for these. | `SpaceWindowTest.SleepOthersInSpaceSkipsActiveAndOtherSpaces` | built |
| R6 | 'Put a Space to sleep after leaving it' (Never / 5 min / 15 min / 1 h). The default is Never. A timer started from SpaceModel::Observer::OnActiveSpaceChanged, cancelled on return; essentials are exempt (SetAutoDiscardable(false)); Space-pinned tabs sleep too. Sleep skips a tab that is audible, being captured, in picture-in-picture, showing a fullscreen video, carrying a beforeunload handler, or holding form input, and it skips the on-screen pane of the active split. | `SpaceModelTest.SleepTimerFiresForTheSpaceTheUserLeft` (the timer), `SpaceWindowTest.SpaceSleepSkipsEssentials` (the exemption), `SteddingPrefsTest` (default Never) | built |
| R7 | A folder whose every tab sleeps dims its header the same way. | live: `w2_folder_dim` (the folder's only tab put to sleep; the header dims to the slept title colour). `FolderView::UpdateSleptLook`, called by each row as its own look changes. | built |
| R8 | Setting: the dropdown above; the look itself has no switch (it is one visual state of the row). | SteddingPrefsTest default. | built |
| R10 | chrome::SelectNumberedTab and SelectLastTab skip TabStripModel::IsTabHidden tabs (Space predicate, collapsed folders) and count in sidebar order: essentials, the Space-pinned run, then the rest; ⌘9 is the last visible tab. Today IsTabSelectable (browser_commands.cc:549) never asks IsTabHidden, so ⌘2 in Space B can activate a tab of Space A. | SpaceWindowTest.NumberedTabSkipsOtherSpaces, SpaceWindowTest.LastTabIsLastVisible (hidden tabs first in the strip). | built |
| R11 | Holding ⌘ for 250 ms shows badges on the visible rows: 1–8 on the first eight, and 9 on the last visible row (the row ⌘9 selects). A ⌃N badge sits on each Space chip. The badges fade in over 80 ms (motion gate, item 24) and vanish on key-up; favicons never move. Modifier-only presses reach the strip through a ui::EventMonitor on the browser widget. | `TabNumbersTest.NumbersFollowTheVisibleRowsAndStopAtNine`, `TabRowRulesTest.NumberBadgePlacement`; live: `tooling/drive` holds ⌘ (`keydown cmd`), shot, releases | built |
| R12 | Setting off leaves the fix (R10) and removes the badges. | SteddingPrefsTest default; live toggle. | built |
| R13 | Welcome step 5 and the settings hint list ⌘1–9. | capture. | built |
| R19 | Essentials cards show the number in a corner badge and the collapsed rail beside the icon; a split row counts as one number (R6-19 J2); sleeping rows are numbered like the rest (D7). | `TabRowRulesTest.NumberBadgePlacement`; capture of the grid and the rail | built · the card and the row captured with ⌘ held; the collapsed rail takes the same corner rule |
| R14 | Double-click a row's title, or the context menu 'Rename…', swaps the title for a text field in the same slot. Enter commits, Escape cancels, an empty string restores the page title. There is no command-bar row for rename. | `TabNamesTest.NameIsPreferredAndEmptyRestores` | built |
| R15 | The custom title lives in TabUIHelper (GetTitle prefers it), so the row, the hover card, the command bar and the ⌃⇥ strip read it; ⌘T matches the custom name first and the page title second. | CommandBarViewTest.MatchesCustomTitle. | built |
| R16 | The title is written as per-tab session extra data under stedding.title and re-emitted by a rebuild provider (AddSessionRebuildProvider), so it survives a rebuilt session log. | SessionRebuildTest.TitleSurvivesRebuild. | built |
| R17 | Names persist for every tab, whatever the tier, and survive pin/unpin; essentials keep theirs for the hover card. | `TabNamesTest.NameSurvivesPinToggle` | built |
| R20 | ⌘-click adds a row to the selection and ⇧-click extends it (Chromium's selection model); a selected row keeps the round-5 selected tint; a selection never spans Spaces because hidden rows cannot be selected. | existing Chromium selection tests; capture | built |
| R21 | With more than one row selected, every verb acts on the selection: close, pin and unpin (both tiers), Move to Space, Move to Folder, Sleep, Mute, archive, Copy Link (form TBD, R6-04). Rename is the exception and acts on the clicked row. Menu labels take the plural ("Close 3 Tabs", "Move 3 Tabs to ▸"). | `SpaceWindowTest.CmdDPinsTheSelection`; the plural labels come from the ICU strings the short menu uses; capture of the menu on a selection | built |
| R22 | Chords act on the selection the same way (⌘W, ⌘D, ⌥⇧⌘←/→); a ⌘T action from the bar acts on the selection when the bar was opened with one. | `SpaceWindowTest.CmdDPinsTheSelection`; `CommandBarViewTest.ActionAppliesToTheSelection` (R6-11) | partial · the chords act on the selection (`SpaceWindowTest.CmdDPinsTheSelection`); the command-bar half lands with R6-11 |
| R23 | An inactive row has no fill of its own, in either colour mode and whatever Chromium's tab-strip mixers hand out: the ground shows through, the essentials card included; the active row, a hovered row and a selected row keep their tints of the row's text colour (`stedding_color_mixer.cc`, patch 0042). Chromium's Material mixer gives inactive rows `kColorSysHeader`, and its field-trial testing config had been hiding that in every beta up to 4 -- beta 4's own app draws the fill when run with `--disable-field-trial-config` -- so the first build with the config off (privacy Q10) filled every row and card on the Mac, found on the first multi-tab capture there (2026-09-10). | `SteddingColorMixerTest.InactiveRowsHaveNoFill`; live: the beta 4 / beta 6 pair `ab-old` / `ab-new` (2026-09-10) | built |

## Running the tests

```bash
tooling/dev test tabs
```
