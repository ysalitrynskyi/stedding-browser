# Feature: Screenshots

Status: **C1–C4 and C8 planned, written, not yet run** (the capture's lifetimes rebuilt, `PLAN.md` WIN-2); **C5–C7 planned** (round 6, `docs/ROUND6-PLAN.md` R6-07, backlog S-40).
Owner docs: `docs/PRODUCT.md`. Patch: `0014`.

Three shortcuts capture the active tab without a share sheet or an extension: the page
as shown (⇧⌘2), a region the user drags out (⌥⇧⌘2), or the whole document (⇧⌘1).
⇧⌘3 to ⇧⌘6 belong to macOS's own screenshot keys and never reach an application,
which is why the region and full-page captures do not sit on them. The result is a PNG in the
profile's Downloads folder, named after the site and the time, and the same image on the
clipboard.

On Windows every chord below is the Mac's with ⌘ read as Ctrl and ⌥⌘ as Ctrl+Alt
(Alt+1–9 for the Spaces themselves); the full map is `docs/features/windows.md` N7.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| C1 | ⇧⌘2 captures the visible page (`RenderWidgetHostView::CopyFromSurface`), writes `Stedding <host> <time>.png` to Downloads and copies it to the clipboard. The folder, the name and whether the window is off the record are fixed when the capture starts, before anything it waits for, so nothing later reads the tab or its profile (`PLAN.md` WIN-2). The host is made safe for a file name: an IPv6 literal's colons failed the write on Windows. A private or Guest window's image is marked off the record on the clipboard (clipboard Cf4). | `ScreenshotFileTest.NamedAfterTheSiteAndTheTime`, `ScreenshotFileTest.TheHostIsSafeForAFileName`, `ScreenshotFileTest.MakesTheFolder`; live: file appears, `pngpaste` reads the clipboard; on Windows, on the machine's own clipboard, `CopyLinkClipboardHistoryTest.APrivateScreenshotIsKeptOutOfWindowsHistory` and `CopyLinkClipboardHistoryTest.AnOrdinaryScreenshotIsLeftToTheHistory` (the private image carries the two zero flags Windows' clipboard history and cloud clipboard honour, the ordinary one neither; seen red with the mark taken out, 2026-09-29) | built |
| C2 | ⌥⇧⌘2 dims the page for a drag-to-select rectangle (Chromium's `ScreenshotFlow`); Escape cancels; the crop is delivered like C1. A second ⌥⇧⌘2 while the overlay is up does nothing (C8): it used to stack a second overlay that one Escape could not take away. | live | planned · written, not yet run |
| C3 | ⇧⌘1 captures the full document through the DevTools protocol (`Page.captureScreenshot`, beyond the viewport) from a trusted in-browser client: no "being debugged" bar, no attach conflicts with the user's own DevTools once done. The client reports itself to DevTools' metrics as "Other" ("Stedding" failed a DCHECK in every debug build), is built and then started in a second step, gives up after 15 seconds with nothing, and deletes itself in a task of its own, never inside a call from the DevTools host. | live on a long page: height > viewport; debug build: ⇧⌘1 saves a file with no DCHECK | planned · written, not yet run |
| C4 | File names never overwrite: a second capture in the same second gets " 2", and so on to " 99"; past that the capture is not saved rather than written over a file. Taking a name and writing to it are one step (an exclusive create), on one writer sequence, so two captures cannot pick the same name. | `ScreenshotFileTest.TwoCapturesInOneSecondLeaveTwoFiles`, `ScreenshotFileTest.NeverReplacesAFile` | built |
| C5 | After ⇧⌘2 / ⌥⇧⌘2 / ⇧⌘1 a toast reads "Copied · Saved to Downloads" with an action "Show in Finder", raised from the shared ending in `screenshot_capture.cc` (clipboard, then Downloads) through a Stedding `ToastId` registered in `toast_service.cc`; the capture icon rides in the icon slot. | live: `tooling/drive` ⇧⌘2, shot within 2 s shows the toast; none after 8 s | built |
| C6 | `ToastView`'s colours come from `stedding_color_mixer.cc` so the toast matches the window (dialog colours, readable in light and dark); hover pauses the dismiss (Chromium's behaviour). This is the one style for every later Stedding toast (the copy-link confirmation L5). | colour probe on the capture | built |
| C7 | No toast for a ⌘-clicked link: the sidebar row is the feedback, as in Arc. | spec row | built |
| C8 | One capture per tab at a time, in every mode: the capture lives on the tab it captures, so everything it waits for -- the region overlay, the surface copy, the DevTools reply -- goes with the tab, and a tab or a private window closed mid-capture leaves nothing pointing at it (it held raw pointers across the copy until `PLAN.md` WIN-2). A picture asked for while the tab's capture runs waits its turn and is written to a file of its own, so ⇧⌘2 pressed twice leaves two files; a region request then is ignored (C2). A capture that does not answer within 15 seconds ends, so the tab can capture again. | browser: `ScreenshotCaptureTest.ClosingTheTabMidCaptureIsSafe`, `ScreenshotCaptureTest.ClosingAPrivateWindowMidCaptureIsSafe`, `ScreenshotCaptureTest.TwoQuickCapturesLeaveTwoFiles`, all four `ScreenshotCaptureTest` cases clean under ASan and with DCHECKs and the dangling-pointer detector on (Windows, 2026-09-30); live: Ctrl+Alt+Shift+2 twice with the real keys dims the page once and one Escape clears it (`tooling\win\drive.ps1`) | built |
