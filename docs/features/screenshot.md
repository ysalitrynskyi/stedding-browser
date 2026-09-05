# Feature: Screenshots

Status: **C1–C4 built**; **C5–C7 planned** (round 6, `docs/ROUND6-PLAN.md` R6-07, backlog S-40).
Owner docs: `docs/PRODUCT.md`. Patch: `0014`.

Three shortcuts capture the active tab without a share sheet or an extension: the page
as shown (⇧⌘2), a region the user drags out (⌥⇧⌘2), or the whole document (⇧⌘1).
⇧⌘3 to ⇧⌘6 belong to macOS's own screenshot keys and never reach an application,
which is why the region and full-page captures do not sit on them. The result is a PNG in the
profile's Downloads folder, named after the site and the time, and the same image on the
clipboard.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| C1 | ⇧⌘2 captures the visible page (`RenderWidgetHostView::CopyFromSurface`), writes `Stedding <host> <time>.png` to Downloads and copies it to the clipboard. | live: file appears, `pngpaste` reads the clipboard | built |
| C2 | ⌥⇧⌘2 dims the page for a drag-to-select rectangle (Chromium's `ScreenshotFlow`); Escape cancels; the crop is delivered like C1. | live | built |
| C3 | ⇧⌘1 captures the full document through the DevTools protocol (`Page.captureScreenshot`, beyond the viewport) from a trusted in-browser client: no "being debugged" bar, no attach conflicts with the user's own DevTools once done. | live on a long page: height > viewport | built |
| C4 | File names never overwrite: a second capture in the same second gets " 2". | code | built |
| C5 | After ⇧⌘2 / ⌥⇧⌘2 / ⇧⌘1 a toast reads "Copied · Saved to Downloads" with an action "Show in Finder", raised from the shared ending in `screenshot_capture.cc` (clipboard, then Downloads) through a Stedding `ToastId` registered in `toast_service.cc`; the capture icon rides in the icon slot. | live: `tooling/drive` ⇧⌘2, shot within 2 s shows the toast; none after 8 s | built |
| C6 | `ToastView`'s colours come from `stedding_color_mixer.cc` so the toast matches the window (dialog colours, readable in light and dark); hover pauses the dismiss (Chromium's behaviour). This is the one style for every later Stedding toast (the copy-link confirmation L5). | colour probe on the capture | built |
| C7 | No toast for a ⌘-clicked link: the sidebar row is the feedback, as in Arc. | spec row | built |
