# Feature: Command bar

Status: **K1–K11, K13–K18 built**; **K12 partial** (round 6, `docs/ROUND6-PLAN.md` R6-11, patch 0022).
Owner docs: `docs/PRODUCT.md` ("Command bar"). Patch: `0005`.

⌘T opens a bar over the page. It lists open tabs from every Space, then the omnibox's own
suggestions; typing a URL opens it, anything else searches with the default engine.

On Windows every chord below is the Mac's with ⌘ read as Ctrl and ⌥⌘ as Ctrl+Alt
(Alt+1–9 for the Spaces themselves); the full map is `docs/features/windows.md` N7.

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
| K9 | Actions mode lists Stedding's own commands only: Move tab to a Space, Pin or Unpin, Move to New Folder, Clear this Space, Capture, Toggle sidebar, New Space, Independent Session, Focus, Hide Other Spaces, Copy Link, and one on/off row per Stedding preference. Chromium's action registry is not listed. Rename and "Archive idle tabs now" are not rows. | `CommandBarViewTest.ActionRowsListSpacesAndCaptures`, `CommandBarViewTest.PopupWindowsHaveNoCommandRows` | built |
| K10 | Rows fuzzy-match on label; the accelerator is drawn at the right of the row from the window's AcceleratorProvider; Enter runs chrome::ExecuteCommand or ActionItem::InvokeAction. | `CommandBarViewTest.MoveToSpaceRowMovesTheTab`, `CommandBarViewTest.ActionRowsCarryAccelerators` (an injected provider) | built |
| K11 | Every later feature that adds a command adds its row here; the empty actions state reads "No matching command" (never a blank panel). | the empty state is `RebuildRows`'s "No matching command" row; capture | built |
| K12 | ⌘L opens the bar prefilled with the page URL, selected, and Enter navigates that tab. Escape returns to the page unchanged. A click on the address row's URL text is not routed to the bar yet. | `CommandBarViewTest.CmdLPrefillsTheUrlSelected` | partial · the address-row click is not routed yet |
| K13 | ⇥ with text already typed filters that text against actions (Arc); ⇧⇥ returns to tabs mode with the text kept. | CommandBarViewTest.TabWithTextFiltersActions | built |
| K14 | Escape in actions mode returns to tabs mode; a second Escape closes the bar. | CommandBarViewTest.EscapeLeavesActionsModeThenCloses | built |
| K15 | In private and popup windows the actions list is empty: no Space, pin, folder or archive rows, and none of Chromium's action registry (B14, V2). | `CommandBarViewTest.PopupWindowsHaveNoCommandRows` | built |
| K16 | A row whose target is absent is hidden: Move to Space for an essentials tab, tab-scoped rows while a peek is open. | `CommandBarViewTest.RowsWithoutATargetAreHidden` (the essentials case), `CommandBarViewTest.TabRowsStepAsideWhileAPeekIsOpen` (the peek case, through a seam the test window needs; live: `w2_bar_peek`). | built |
| K17 | A dropdown preference appears as one cycling row ("Archive after: 12 hours ▸"): Enter advances to the next value and the row re-reads. | CommandBarViewTest.DropdownPrefRowCycles | built |
| K18 | Typed `keyword query` whose first token is a search-engine keyword (`TemplateURL`) navigates that engine's `%s` template. An unknown keyword still uses the default engine. | `CommandBarViewTest.KeywordQueryUsesThatEngine`; `CommandBarViewTest.UnknownKeywordStaysADefaultSearch` | built |
| K19 | `@Work rust` filters open and archived rows to Spaces whose name starts with that prefix. History stays profile-wide. | `SpaceQueryTest.AtSpacePrefixFiltersOpenAndArchived` | built |

## Notes from the live check (2026-09-05)

- On the Mac the focus manager sees a key before the focused view does, so a
  plain Textfield never receives ⇥: focus moved to the toolbar and the bar closed
  while `CommandBarViewTest.TabFiltersToActions`, which calls the controller
  directly, stayed green. The bar's field claims ⇥ and ⇧⇥ in
  `SkipDefaultKeyEventProcessing` (the omnibox does the same); the test asserts
  the claim (`docs/HANDOFF.md` trap 20).
- The panel takes the height of its rows on every rebuild, up to the 320 DIP clip:
  a mode switch from a two-tab list to a hundred commands used to keep the
  open-time height and show two rows. `CommandBarViewTest.PanelGrowsWithTheRows`.
