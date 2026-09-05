# Feature: Page card

Status: **U1–U8 planned** (round 6, `docs/ROUND6-PLAN.md` R6-05, R6-06).
Owner docs: `docs/UI-SPEC.md`. Patch: TBD.

The content card is one surface: the link status bubble is a pill inside it, the find
bar takes the dialog colours and the card's right edge, and split panes carry no ring
(Arc draws none; the page-coloured bar, toolbar T3, says which pane is active).

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| U1 | In Stedding mode the link status bubble is a pill inside the card: inset 8 DIP from the card's left and bottom edges, radius = height/2 on all four corners, background and text from `kColorStatusBubble*` mapped to the card surface and secondary text, a hairline in the toolbar-separator tint. Chromium's slide-away-from-the-mouse and expand-on-hover stay. | a hovered-link probe (`tooling/drive` hovers a link, shot): pill luma at the inset, card corner still rounded beneath | built |
| U2 | The pill never touches the card edge at any window size, including immersive fullscreen. | capture at 1400×880 and in ⌃⌘F | partial · verified at 1400×880 (pill 8 DIP from the card edges); immersive fullscreen moves the window to its own macOS desktop, which the capture harness cannot photograph |
| U3 | `kColorFindBarBackground` / `Foreground` / `MatchCount` / `ButtonIcon*` map to the dialog colours the command bar uses (commandbar K6), so the ⌘F bubble follows light, dark and the Space tint. | a colour probe on a ⌘F capture, dark and light | built |
| U4 | The find bubble's right edge aligns with the content card's right edge (the `card_gutter`, toolbar T2). | probe | built |
| U5 | No position, width, checkbox or hide settings: Arc has one placement for each and shows the hovered link. | spec row | built |
| U6 | `kColorMultiContentsViewActiveContentOutline` and `InactiveContentOutline` map to the row-text tint at 0x18 (the selected-row value) so light, dark and Space tint follow; no Material ring. | a probe on a split capture at the pane edge: no Material outline luma | built |
| U7 | The 3 px highlight (`ContentsContainerOutline::UpdateState(is_active, is_highlighted)`) stays for the drag-and-drop target only. | existing split browsertests unchanged | built |
| U8 | The inactive pane's mini toolbar is captured against Arc in the same pass and left alone unless it clashes (a separate row if it changes). | capture | built |
