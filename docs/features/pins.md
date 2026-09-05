# Feature: Pinned tabs

Status: **H1–H12 built** (H1–H11 round 6, `docs/ROUND6-PLAN.md` R6-16, patches 0020 and 0024; H12 round 7, `docs/ARC-ROUND2.md`, 2026-09-05).
Owner docs: `docs/PRODUCT.md` §1, `docs/features/spaces.md` (the two tiers). Patches: 0020, 0024, 0037 (H12).

Arc's pinned-tab lifecycle: a pin remembers its home page, ⌘W puts it to sleep
instead of closing it, a drifted pin shows a dot and resets from its favicon.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| H1 | Both pin tiers record a home URL at pin time: SpaceModel::SetSpacePinned(tab, true) stores handle → GURL (space_pinned_ becomes a map), and Chromium's pinned bit flipping on (OnTabStripModelChanged) records it for essentials. | SpaceModelTest.PinRecordsHomeUrl. | built |
| H2 | The home URL is written to per-tab session extra data beside stedding.spacepin through SessionExtraDataForTab and re-emitted by AppendRebuildCommands, so it survives a rebuilt session log (HANDOFF trap 4). | SessionRebuildTest.PinnedUrlSurvivesRebuild; live: tooling/drive quit and relaunch three times. | built |
| H3 | ⌘W (IDC_CLOSE_TAB) on a Space-pinned or essentials tab sleeps it instead of closing (item 7's look; activation moves to the next visible row in the Space); a sleeping pinned tab is left alone; removal is Unpin. | SpaceWindowTest.CloseOnPinnedTabSleepsIt, SpaceWindowTest.CloseOnSleepingPinnedTabIsANoOp. | built |
| H4 | When the tab's committed URL differs from home (origin or path), TabIcon paints a 5 DIP 'navigated away' dot at the favicon's corner (the attention-indicator geometry) on an essentials card or a collapsed-rail row; a row with a title shows the slash instead (H12); it clears when the tab is home again. | `PinLifecycleTest.*` (drift = origin or path differs); capture of the dot | built |
| H5 | A click on the favicon column of a pinned tab (not the row) loads home; ⌥-click also reloads. | live: tooling/drive click on the favicon of a drifted pin, URL read back. | built |
| H6 | Tab context menu 'Reset to Pinned Page' and 'Make This the Pinned Page'; both are ⌘T actions. | `TabMenuModelTest.SteddingOrder` lists both rows; the collection controller enables them on a pinned row | built |
| H7 | Peek reads the stored home URL's eTLD+1 as the pinned site (P2), so a drifted pin stops peeking the wrong site. | ShouldPeekTest.UsesTheStoredPinnedSite. | built |
| H8 | The hover card of a pinned tab gains a line 'Pinned in <Space> · home <host>' (no thumbnail). | TabHoverCardBubbleViewTest.SteddingPinLineJoinsTheDomain (the line joins the domain row, eliding at the tail); live: `w2_hovercard_screen` (a Space-pinned row: "Pinned in Space 1 · home example.com"). | built |
| H9 | Setting off returns ⌘W to closing (Unpin implied). | SpaceWindowTest.CloseSleepsSettingOffCloses. | built |
| H10 | A click on a drifted essentials card activates it; the reset control appears on hover of the card (Arc), and a click on it loads home (D8). The critic's unsure line asks for a side-by-side check in Arc before H5 and H10 are written; do it first. | live: `w2_card_reset_hover` (the ↺ control in the card's corner once it drifted, while the pointer rests on it), `w2_card_reset_after` (a click loads home). Option-click on the favicon still works (H5). | built |
| H11 | ⌘W on the last visible tab of a Space that holds only pins sleeps it and the Space shows its new-tab row (B4): intended (D8). | SpaceWindowTest.CloseOnLastPinnedTabSleepsItAndShowsTheNewTabRow. | built |
| H12 | A Space-pinned row away from its home shows Arc's slash between the favicon and the title, in a muted tone, so the row reads "favicon / where you are"; the dot (H4) stays for an essentials card and the collapsed rail, which have no title to precede. | `TabRowRulesTest.DriftShowsASlashOnRowsAndADotOnCards`; live: `r7_drift_slash` (a Space-pinned row navigated to another page: the slash before the title) | built |
