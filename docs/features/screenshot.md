# Feature: Screenshots

Status: **C1–C4 built**; C5 is a gap.
Owner docs: `docs/PRODUCT.md`. Patch: `0013`.

Three shortcuts capture the active tab without a share sheet or an extension: the page
as shown, a region the user drags out, or the whole document. The result is a PNG in the
profile's Downloads folder, named after the site and the time, and the same image on the
clipboard.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| C1 | ⇧⌘2 captures the visible page (`RenderWidgetHostView::CopyFromSurface`), writes `Stedding <host> <time>.png` to Downloads and copies it to the clipboard. | live: file appears, `pngpaste` reads the clipboard | built |
| C2 | ⇧⌘3 dims the page for a drag-to-select rectangle (Chromium's `ScreenshotFlow`); Escape cancels; the crop is delivered like C1. | live | built |
| C3 | ⇧⌘4 captures the full document through the DevTools protocol (`Page.captureScreenshot`, beyond the viewport) from a trusted in-browser client: no "being debugged" bar, no attach conflicts with the user's own DevTools once done. | live on a long page: height > viewport | built |
| C4 | File names never overwrite: a second capture in the same second gets " 2". | code | built |
| C5 | A brief toast with a thumbnail and "Copied · Saved to Downloads". | none yet | gap |
