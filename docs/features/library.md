# Feature: Library

Status: **Lb1–Lb7 planned**. Owner docs: `docs/PRODUCT.md` §9. Patch: none yet.

One bottom-left door for archive, captures and downloads. Easels stay deferred
(ADR 0012). No model.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Lb1 | The switcher's leading control opens the Library overlay, not Chromium's download bubble. The Archived row above the switcher is not laid out. The download progress ring stays on this control. | `LibraryButtonTest.OpensThePanelNotTheBubble` | planned |
| Lb2 | The overlay is a layered child of the page card. Escape or a click on the scrim closes it. It does not cover the sidebar. | `LibraryViewTest.BoundsMatchTheCard` | planned |
| Lb3 | Three shelves — Archived, Captures, Downloads. Last-used shelf is a profile pref. | `LibraryViewTest.ShelfChoice` | planned |
| Lb4 | Each screenshot appends an index row (path, url, host, time, kind). The Captures shelf lists that index. Files stay in Downloads. | `CaptureIndexTest.CaptureAppendsARow` | planned |
| Lb5 | Finished downloads group by day, then by kind from MIME/extension. In-flight rows sit ungrouped at the top of Today. | `LibraryDownloadsTest.GroupsByDayAndKind` | planned |
| Lb6 | The Archived shelf is `ListArchivedTabs` (archive A8–A11). Restore recreates a missing Space. | `LibraryViewTest.RestoreFromTheShelf` | planned |
| Lb7 | Hovering a Library row shows a local preview (capture thumbnail, download type, archived title). No live site fetch. | `LibraryViewTest.HoverShowsPreview` | planned |
