# Feature: Folders

Status: **F1–F9, F11, F12 built and tested**; F10 is a gap. F12 is round 7 (`docs/ARC-ROUND2.md`, 2026-09-05).
Owner docs: `docs/decisions/0013-folders-are-a-collection-type.md` (model). Patches: `0008` (the whole feature; the series is per feature since `S-11`), `0037` (F12, round 7).

A folder is a named, collapsible container of tabs in the sidebar. Folders nest. A folder is
a collection type in the tab tree, not a tab group, so Chrome's groups keep working and a
folder's membership cannot be overwritten by an outer group (ADR 0013).

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| F1 | "Move Tab to New Folder" on a tab's context menu wraps it in a new folder. No tab is lost. | `TabStripModelTest.AddToNewFolderKeepsTabsAndNests` | built |
| F2 | The same command on a tab already in a folder nests a new folder inside it. The outer folder still counts the nested tab. | `TabStripModelTest.AddToNewFolderKeepsTabsAndNests` | built |
| F3 | A collapsed folder hides its tabs, nested folders included, from the sidebar and from tab traversal. | `TabStripModelTest.*Hidden*` via `IsTabHidden`; capture | built |
| F4 | Double-clicking a folder header renames it in place; Enter commits, Escape cancels. | capture (`folder_tabs/2`) | built |
| F5 | Folder tree (ids, titles, collapse state, nesting) survives session restore through per-tab extra data, and survives the session log being rebuilt from scratch. | `FolderSessionTest.RebuildsNestedFoldersFromParkedPaths`, `FolderSessionTest.RebuildReemitsFolderPaths` | built |
| F6 | Closing a window with folders does not crash (the last tab leaves its folder before the folder is peeled). | `FolderSessionTest.FoldersSurviveBrowserFixtureTeardown` | built |
| F7 | Dropping a dragged tab on a folder header moves it to the end of that folder, keeps it active, and highlights the header while hovered (live: `tooling/drive` with `dragstart`/`dragmove`/`shot`/`dragend`). A folder's only tab dropped on its own header stays in the strip. | `FolderDragTargetTest.DroppingOnAFolderHeaderMovesTheTabIntoIt`, `FolderDragTargetTest.DroppingNowhereLeavesTheTabAlone`, `FolderDragTargetTest.DraggingAFoldersOnlyTabOntoItselfKeepsTheTab`, `TabStripModelTest.MoveTabsToFolderAppendsNestsAndRefusesPins` | built |
| F8 | Essentials (pinned) tabs never enter a folder; a pinned tab dropped on a folder goes back to the essentials row. | `FolderDragTargetTest.APinnedTabStaysPinnedAndOutOfTheFolder`, `TabStripModelTest.MoveTabsToFolderAppendsNestsAndRefusesPins` | built |
| F9 | Tabs move into a folder one by one, so the tree stays valid even when every tab of an outer folder is moved into a folder nested inside it. | `TabStripModelTest.MoveTabsToFolderAppendsNestsAndRefusesPins` | built |
| F10 | Dragging a tab between two tabs inside an expanded folder places it there (the strip's own reorder is folder-aware). | none yet | gap |
| F11 | The tab-strip mojom carries a Folder variant (id, title, collapse state) instead of mapping FOLDER to the plain container. | live: a window with nested folders under the API observer, no crash; `TabStripModelTest.AddToNewFolder*` drives the converter | built |
| F12 | Arc's folder row: a folder glyph (closed, or open with the folder) in place of the chevron, a semibold title, and the tab rows' hover tint and radius on the header. The header never reads a folder that has left the tree: a node that no longer names a collection gives no folder, and the window's page-colour re-theme is posted one turn after the tab strip's change instead of running inside it (closing every tab at quit reached a header whose folder was gone and aborted on the variant, 2026-09-05). | `FolderViewTest.HeaderShowsAFolderGlyphAndASemiboldTitle`, `FolderViewTest.HeaderSurvivesANodeThatIsNotAFolder`, `PageThemeColorControllerTest.*`; live: `r7_folder` (the glyph and the title); a `folder_tabs/2` launch quit through the AppleEvent under lldb with no abort (done, 2026-09-05 18:02) | built |

## Running the tests

```bash
tooling/dev test folders
```
