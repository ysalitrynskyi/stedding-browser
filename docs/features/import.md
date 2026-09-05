# Feature: Import from Arc

Status: **I1–I4, I8–I20 built**, **I5–I7 planned** (round 6, `docs/ROUND6-PLAN.md`
R6-22, R6-28, R6-29).
Owner docs: `docs/PRODUCT.md` §1, `docs/ROADMAP.md`. Patches: 0026 (I1–I12), 0032
(I13–I16), 0033 (I17–I20).

An Arc user opens Stedding and gets their sidebar back: Spaces with their icon and
colour, the essentials row, the pinned runs, folders with nesting, and the unpinned
tabs — read from Arc's own `StorableSidebar.json`, summarised before anything is
applied, inserted unloaded so a big sidebar costs nothing until a tab is opened.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| I1 | `spaces::ArcSidebarImporter` parses `~/Library/Application Support/Arc/StorableSidebar.json` (`sidebar.containers[]`: `spaces` and `items` as lists that alternate an id and its object; a Space's `containerIDs` name its pinned and unpinned containers; `customInfo.iconType.emoji_v2` and `customInfo.windowTheme.primaryColorPalette.midTone`; items of kind `tab` (`savedURL`, `savedTitle`), `list` (a folder; `childrenIds` nest) and `itemContainer`; `topAppsContainerIDs` name the essentials) into a plan: Spaces with icon and colour, essentials, and per Space the pinned and unpinned nodes. | ArcSidebarImporterTest.ParsesSpacesFoldersAndEssentials | built |
| I2 | The plan is summarised ("3 Spaces, 12 pinned tabs, 2 folders, 30 tabs · 2 essentials") before anything is applied; Skip applies nothing. | ArcSidebarImporterTest.SummaryCountsThePlan; live: `w3_arc_welcome` (the row on the welcome flow's import step, with the summary line) | built |
| I3 | Apply: a Space per Arc Space (`AddSpace` / `SetSpaceIcon` / `SetSpaceColor`; a lone unnamed default Space is taken over by the first), `SetTabPinned` for the essentials, `SetSpacePinned` for the loose tabs of the pinned run (recording the home URL, pins H1), `AddToNewFolder` recursively for lists, and every tab inserted unloaded — a restored navigation entry with the title, `WasDiscarded` set — so 400 tabs cost no memory until opened. Folders inside Arc's pinned section become folders (their tabs are not Space-pinned). | ArcSidebarImportWindowTest.AppliesSpacesPinsAndFolders | built |
| I4 | Entry points: an "Arc" row on welcome step 2 when the file exists (checkboxes for Spaces, pinned tabs, unpinned tabs), "Import from Arc…" in chrome://settings/stedding under the Spaces list, and a ⌘T action "Import from Arc". | live: `w3_arc_welcome` (welcome step 2), `w3_arc_settings` and `w3_arc_settings_after` (the settings row, then the Spaces list after Import… on a real Arc file), `w3_arc_imported` (that profile relaunched: the essentials, the Space title, the pins, the folders, eight chips), `w3_arc_bar` (the ⌘T action on the first bar) | built |
| I5 | Memory and warm-start after a 400-tab import stay inside the QUALITY budgets (a strip holding 400 hidden rows is the risk). | tooling/measure/harness.py warm and memory legs on an imported profile | planned |
| I6 | Phase two, a TYPE_CHROMIUM-shaped importer for Arc's History and Login Data, is a separate row and patch. | TBD | planned |
| I7 | Arc split-view items become split rows (R6-19 J1); archived items go to the archive (R6-24 A8) with their Space and folder path and a reason of "import". | ArcSidebarImporterTest.SplitsBecomeSplitRowsAndArchivedItemsGoToTheArchive | planned · D9 |
| I8 | The per-Space profile binding is dropped and named in the import summary (I2). | ArcSidebarImporterTest.ParsesSpacesFoldersAndEssentials (the binding is named), ArcSidebarImporterTest.SummaryCountsThePlan (the summary says so) | built |
| I9 | The importer reads a copy of the file (Arc rewrites it while running) and warns when Arc is running. | ArcSidebarImporterTest.ReadsACopy; live: `w3_arc_welcome` was taken with Arc running and the row says so | built |
| I10 | `windowTheme` maps to the nearest of the five Stedding swatches (`kSpaceColors`). | ArcSidebarImporterTest.ThemeMapsToTheNearestSwatch | built |
| I11 | Favorites are capped at twelve essentials (nothing in the tree caps essentials); the rest stay where they are and the summary counts them. | ArcSidebarImportWindowTest.FavoritesCapAtTwelve | built |
| I12 | A second import is idempotent: Arc's ids are remembered in the profile (`stedding.import.arc_ids`, `stedding.import.arc_spaces`) and nothing already present is created again. | ArcSidebarImportWindowTest.SecondImportAddsNothing | built |
| I13 | After an import that included bookmarks (welcome W3 or chrome://settings/importData), the bookmark tree becomes pins in the active Space: the bookmark bar's bookmarks first, then Other bookmarks; each folder a folder, each bookmark a Space-pinned tab inserted unloaded with the bookmark as its home (pins H1); through the Arc importer's apply path, idempotent on the bookmark ids. | `BookmarksToPinsTest.FolderTreeBecomesPinnedFolders` | built |
| I14 | After the conversion the bookmark bar never shows (`stedding.bookmarks.converted`) and the star leaves the address row; the Bookmarks submenu is already gone under short menus (menus M3); Import Bookmarks and Settings stays in the app menu. | `BookmarksToPinsTest.ConversionHidesTheBar` (the preference the bar and the star read); capture `w3_bookmarks_pins` | built |
| I15 | The welcome flow's import step says "Bookmarks become pinned tabs and folders in your first Space"; Skip converts nothing and the bookmark model stays as Chromium filled it (the bar stays hidden by default, as before). | live: `w3_arc_welcome` (the line under the import row) | built |
| I16 | A profile that already holds bookmarks converts them on demand: the ⌘T action "Turn Bookmarks into Pinned Tabs" runs the same conversion; no offer on start. | live: `w3_bookmarks_pins` (the bar action on a profile with a bookmark) | built |
| I17 | Stedding writes a JSON snapshot of the sidebar into the profile directory on a schedule; the file is this importer's plan format. | `SidebarBackupTest.SnapshotCarriesEveryField`, `SidebarBackupScheduleTest.KeepsTenTodayThenDaysWeeksMonths`, `SidebarBackupScheduleTest.FileNamesCarryTheirTime` | built |
| I18 | An export is an import in reverse; a restore applies through the importer's apply path (I3, I12). | `SidebarBackupTest.RoundTripIsIdentity` | built |
| I19 | "Restore sidebar…" lists snapshots by time; a restore never closes an open tab. | `SidebarBackupTest.RestoreClosesNothing` (a merge: a Space named by its own id is that Space, an open tab is skipped); live: `w3_backups` (the list and Restore) | built |
| I20 | "Export Space…" and "Import sidebar…": the file-based answer to sync, with no account. | `SidebarBackupTest.ExportOneSpaceImportsBack`; live: `w3_backups` (Export Space… writes to Downloads; Import sidebar… reads a file) | built |

## Notes

- The Arc file on a real Mac (looked at for its shape only, never copied into the
  repo): `sidebar.containers` holds two entries, one `{global: …}` and one with
  `spaces`, `items` and `topAppsContainerIDs`; `spaces` and `items` alternate a
  string id and a dict; item `data` is one of `{tab: {savedURL, savedTitle, …}}`,
  `{list: {}}` and `{itemContainer: {containerType: {spaceItems: …} | {topApps: …}}}`;
  containers have no parent and list their children in order; a Space's
  `containerIDs` reads `["unpinned", id, "pinned", id]`. The test fixture is a
  synthetic file in that shape.
- Every tab is inserted through a restored navigation entry, the way session
  restore creates tabs it does not load: the row shows the saved title, the page
  loads on the first activation, and `WasDiscarded` gives it the slept look
  (tabs R4).
- Idempotence (I12) keys on Arc's item ids: `stedding.import.arc_ids` lists every
  id brought over and `stedding.import.arc_spaces` maps an Arc Space id to the
  Stedding Space it became, so a re-import after Arc gained a tab adds that tab
  to the right Space and nothing else. A Space deleted in Stedding stays deleted:
  its id is still remembered.
- A folder inside Arc's pinned section becomes a folder whose tabs are plain
  (not Space-pinned); a list with no tab of its own cannot be made (a folder
  needs a tab), so its sub-lists come out beside it.
- The ⌘T row appears once the bar has learned the file exists (a check off the UI
  thread the first time a bar is built), so it is absent from the very first bar
  of a session.
- Backups (I17–I20) are the plan written in Arc's own shape, so one parser serves
  Arc's file, a Stedding snapshot and an exported Space. A snapshot names Spaces by
  their ids and tabs by their session ids; the importer treats a Space it already
  holds as that Space and skips a tab that is still open, which is what makes a
  restore a merge. A tab's user-given name comes back as its title, not as a name
  (tabs R15 stays TBD across a restore).
