# Feature: Folders

Status: **F1–F9 built and tested**; F10–F11 are gaps (`S-4`, `S-3` for the live restart).
Owner docs: `docs/decisions/0013-folders-are-a-collection-type.md` (model). Patch: `0008` (the whole feature; the series is per feature since `S-11`).

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
| F5 | Folder tree (ids, titles, collapse state, nesting) survives session restore through per-tab extra data. | `FolderSessionTest.RebuildsNestedFoldersFromParkedPaths` | built |
| F6 | Closing a window with folders does not crash (the last tab leaves its folder before the folder is peeled). | `FolderSessionTest.FoldersSurviveBrowserFixtureTeardown` | built |
| F7 | Dropping a dragged tab on a folder header moves it to the end of that folder, keeps it active, and highlights the header while hovered. A folder's only tab dropped on its own header stays in the strip. | `FolderDragTargetTest.DroppingOnAFolderHeaderMovesTheTabIntoIt`, `FolderDragTargetTest.DroppingNowhereLeavesTheTabAlone`, `FolderDragTargetTest.DraggingAFoldersOnlyTabOntoItselfKeepsTheTab`, `TabStripModelTest.MoveTabsToFolderAppendsNestsAndRefusesPins` | built |
| F8 | Essentials (pinned) tabs never enter a folder; a pinned tab dropped on a folder goes back to the essentials row. | `FolderDragTargetTest.APinnedTabStaysPinnedAndOutOfTheFolder`, `TabStripModelTest.MoveTabsToFolderAppendsNestsAndRefusesPins` | built |
| F9 | Tabs move into a folder one by one, so the tree stays valid even when every tab of an outer folder is moved into a folder nested inside it. | `TabStripModelTest.MoveTabsToFolderAppendsNestsAndRefusesPins` | built |
| F10 | Dragging a tab between two tabs inside an expanded folder places it there (the strip's own reorder is folder-aware). | none yet | gap |
| F11 | The tab-strip mojom carries a Folder variant instead of mapping FOLDER to the plain container. | none yet | gap |

## Running the tests

```bash
tooling/dev test folders
```
