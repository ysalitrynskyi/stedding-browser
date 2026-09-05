# Feature: Command bar

Status: **K1–K11, K13–K15, K17 built**; **K12, K16 partial** (round 6, `docs/ROUND6-PLAN.md` R6-11, patch 0022).
Owner docs: `docs/PRODUCT.md` ("Command bar"). Patch: `0005`.

⌘T opens a bar over the page. It lists open tabs from every Space, then the omnibox's own
suggestions; typing a URL opens it, anything else searches with the default engine.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| K1 | ⌘T opens the bar; Escape or a click outside closes it. | `CommandBarViewTest.*`; live | built |
| K2 | Tabs from every Space are listed, with the Space named when it is not the active one; choosing one switches Space and activates it (spaces B13). | `CommandBarViewTest.ChoosingATabInAnotherSpaceSwitchesToIt` | built |
| K3 | Typed text is classified the way the address bar classifies it: "example.com" opens, "dfsfsfsdfdsfcvv3233" searches. | `CommandBarViewTest.TypedTextWithoutAClassifierBecomesASearch` (fallback); live on the classifier | built |
| K4 | Below the tabs, the omnibox providers' suggestions (history, bookmarks, search suggestions) appear as they arrive, labelled Search / History / Bookmark / Open. | live | built |
| K5 | ↑/↓ move the chosen row; Enter takes it (or the typed text when it is the chosen row). | live | built |
| K6 | The bar takes the theme's dialog colours with a quiet text-tinted highlight. | capture | built |
| K7 | The "Open"/"Search" row always shows what Enter does with the typed text. | live | built |
| K8 | In an empty bar, ⇥ (or a leading ">") switches to actions mode: rows are commands, not tabs; ⇧⌘P opens the bar already in actions mode. | `CommandBarViewTest.TabFiltersToActions` (⇥ and the leading ">"); ⇧⌘P through `IDC_STEDDING_COMMAND_PALETTE`, listed by `ShortcutReferenceTest.*`; live capture | built |
| K9 | The action list is Chromium's own registry (every ActionItem under BrowserActions::root_action_item() with text, icon, accelerator) plus Stedding's rows: Move tab to <Space> (one row per SpaceModel::spaces()), Pin/Unpin to This Space, Move to New Folder, Clear this Space, Archive idle tabs now (TabArchiver::Sweep), Capture page/region/full document, Toggle sidebar, New Space, Rename tab, and one on/off row per stedding.* preference. | `CommandBarViewTest.ActionRowsListSpacesAndCaptures` | partial · Chromium's registry plus the Space, pin, folder, sleep, Clear, capture, sidebar, New Space, Copy Link and preference rows; "Archive idle tabs now" and "Rename tab" are not in yet (no window accessor for the archiver; the rename field is the strip's) |
| K10 | Rows fuzzy-match on label; the accelerator is drawn at the right of the row from the window's AcceleratorProvider; Enter runs chrome::ExecuteCommand or ActionItem::InvokeAction. | `CommandBarViewTest.MoveToSpaceRowMovesTheTab`, `CommandBarViewTest.ActionRowsCarryAccelerators` (an injected provider) | built |
| K11 | Every later feature that adds a command adds its row here; the empty actions state reads "No matching command" (never a blank panel). | the empty state is `RebuildRows`'s "No matching command" row; capture | built |
| K12 | ⌘L opens the bar prefilled with the page URL, selected; Escape returns to the page unchanged; a click on the address row's URL text opens the bar the same way. The address row stays the page's top (the operator's round-5 design, ARC-ROUND2 round 5 #5); the K7 row says that Enter navigates this tab (the cue the skipped "Add new tab urlbar icon" asked for). | `CommandBarViewTest.CmdLPrefillsTheUrlSelected`; live: ⌘L, Escape, URL unchanged | partial · ⌘L opens the bar with the URL selected (`CommandBarViewTest.CmdLPrefillsTheUrlSelected`; `IDC_FOCUS_LOCATION` in the command controller); the address-row click is not routed yet |
| K13 | ⇥ with text already typed filters that text against actions (Arc); ⇧⇥ returns to tabs mode with the text kept. | CommandBarViewTest.TabWithTextFiltersActions | built |
| K14 | Escape in actions mode returns to tabs mode; a second Escape closes the bar. | CommandBarViewTest.EscapeLeavesActionsModeThenCloses | built |
| K15 | In private and popup windows the actions list holds Chromium's actions only: no Space, pin, folder or archive rows (B14, V2). | `CommandBarViewTest.PopupWindowsListChromiumActionsOnly` | built |
| K16 | A row whose target is absent is hidden: Move to Space for an essentials tab, tab-scoped rows while a peek is open. | `CommandBarViewTest.RowsWithoutATargetAreHidden` | partial · the essentials case (`CommandBarViewTest.RowsWithoutATargetAreHidden`); the peek case is not handled yet |
| K17 | A dropdown preference appears as one cycling row ("Archive after: 12 hours ▸"): Enter advances to the next value and the row re-reads. | CommandBarViewTest.DropdownPrefRowCycles | built |

## Notes from the live check (2026-09-05)

- On the Mac the focus manager sees a key before the focused view does, so a
  plain Textfield never receives ⇥: focus moved to the toolbar and the bar closed
  while `CommandBarViewTest.TabFiltersToActions`, which calls the controller
  directly, stayed green. The bar's field claims ⇥ and ⇧⇥ in
  `SkipDefaultKeyEventProcessing` (the omnibox does the same); the test asserts
  the claim (`docs/HANDOFF.md` trap 15).
- The panel takes the height of its rows on every rebuild, up to the 320 DIP clip:
  a mode switch from a two-tab list to a hundred commands used to keep the
  open-time height and show two rows. `CommandBarViewTest.PanelGrowsWithTheRows`.
