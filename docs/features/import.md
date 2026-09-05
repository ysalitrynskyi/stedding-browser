# Feature: Import from Arc

Status: **I1–I12 planned** (round 6, `docs/ROUND6-PLAN.md` R6-22); **I13–I20 planned**
(R6-28, R6-29).
Owner docs: `docs/PRODUCT.md` §1, `docs/ROADMAP.md`. Patch: TBD.

An Arc user opens Stedding and gets their sidebar back: Spaces with their icon and
colour, the essentials row, the pinned runs, folders with nesting, and the unpinned
tabs — read from Arc's own `StorableSidebar.json`, summarised before anything is
applied, inserted unloaded so a big sidebar costs nothing until a tab is opened.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| I1 | `spaces::ArcSidebarImporter` parses `~/Library/Application Support/Arc/StorableSidebar.json` (`sidebar.containers[]`: `spaces` and `items` as lists that alternate an id and its object; a Space's `containerIDs` name its pinned and unpinned containers; `customInfo.iconType.emoji_v2` and `customInfo.windowTheme.primaryColorPalette.midTone`; items of kind `tab` (`savedURL`, `savedTitle`), `list` (a folder; `childrenIds` nest) and `itemContainer`; `topAppsContainerIDs` name the essentials) into a plan: Spaces with icon and colour, essentials, and per Space the pinned and unpinned nodes. | ArcSidebarImporterTest.ParsesSpacesFoldersAndEssentials | planned |
| I2 | The plan is summarised ("3 Spaces, 12 pinned tabs, 2 folders, 30 tabs · 2 essentials") before anything is applied; Skip applies nothing. | ArcSidebarImporterTest.SummaryCountsThePlan; live on the welcome flow | planned |
| I3 | Apply: a Space per Arc Space (`AddSpace` / `SetSpaceIcon` / `SetSpaceColor`; a lone unnamed default Space is taken over by the first), `SetTabPinned` for the essentials, `SetSpacePinned` for the loose tabs of the pinned run (recording the home URL, pins H1), `AddToNewFolder` recursively for lists, and every tab inserted unloaded — a restored navigation entry with the title, `WasDiscarded` set — so 400 tabs cost no memory until opened. Folders inside Arc's pinned section become folders (their tabs are not Space-pinned). | ArcSidebarImporterTest.AppliesSpacesPinsAndFolders | planned |
| I4 | Entry points: an "Arc" row on welcome step 2 when the file exists (checkboxes for Spaces, pinned tabs, unpinned tabs), "Import from Arc…" in chrome://settings/stedding under the Spaces list, and a ⌘T action "Import from Arc". | live: tooling/drive on a fresh profile with `--stedding-welcome`; the settings capture | planned |
| I5 | Memory and warm-start after a 400-tab import stay inside the QUALITY budgets (a strip holding 400 hidden rows is the risk). | tooling/measure/harness.py warm and memory legs on an imported profile | planned |
| I6 | Phase two, a TYPE_CHROMIUM-shaped importer for Arc's History and Login Data, is a separate row and patch. | TBD | planned |
| I7 | Arc split-view items become split rows (R6-19 J1); archived items go to the archive (R6-24 A8) with their Space and folder path and a reason of "import". | ArcSidebarImporterTest.SplitsBecomeSplitRowsAndArchivedItemsGoToTheArchive | planned · D9 |
| I8 | The per-Space profile binding is dropped and named in the import summary (I2). | ArcSidebarImporterTest.SummaryNamesDroppedProfileBindings | planned · D9 |
| I9 | The importer reads a copy of the file (Arc rewrites it while running) and warns when Arc is running. | ArcSidebarImporterTest.ReadsACopy; live with Arc open | planned · D9 |
| I10 | `windowTheme` maps to the nearest of the five Stedding swatches (`kSpaceColors`). | ArcSidebarImporterTest.ThemeMapsToTheNearestSwatch | planned · D9 |
| I11 | Favorites are capped at twelve essentials (nothing in the tree caps essentials); the rest stay where they are and the summary counts them. | ArcSidebarImporterTest.FavoritesCapAtTwelve | planned · D9 |
| I12 | A second import is idempotent: Arc's ids are remembered in the profile (`stedding.import.arc_ids`, `stedding.import.arc_spaces`) and nothing already present is created again. | ArcSidebarImporterTest.SecondImportAddsNothing | planned · D9 |
| I13 | Bookmarks imported on welcome W3 or from chrome://settings/importData become Space-pinned tabs in the active Space: each bookmark folder a folder, each bookmark a Space-pinned tab inserted unloaded, the bookmark-bar root first. | TBD | planned · draft |
| I14 | After the conversion the bookmark bar, the star and the Bookmarks submenu are hidden; Import Bookmarks and Settings stays reachable from the app menu. | capture | planned · draft |
| I15 | The import step says what happens, with a count; Skip leaves the bookmark model as Chromium filled it. | live | planned · draft |
| I16 | A profile that already holds bookmarks when it upgrades: TBD. | TBD | planned · draft |
| I17 | Stedding writes a JSON snapshot of the sidebar into the profile directory on a schedule; the file is this importer's plan format. | TBD | planned · draft |
| I18 | An export is an import in reverse; a restore applies through the importer's apply path (I3, I12). | SidebarBackupTest.RoundTripIsIdentity | planned · draft |
| I19 | "Restore sidebar…" lists snapshots by time; a restore never closes an open tab. | SidebarBackupTest.RestoreClosesNothing | planned · draft |
| I20 | "Export Space…" and "Import sidebar…": the file-based answer to sync, with no account. | SidebarBackupTest.ExportOneSpaceImportsBack | planned · draft |

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
