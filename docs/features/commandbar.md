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
| K2 | Tabs from every Space are listed, with the Space named when it is not the active one; choosing one switches Space and activates it (spaces B13). A row holds its tab, not a place in the strip: a tab closed while the bar is open never puts another tab under the row, and a row whose tab has closed does nothing. With Hide Other Spaces on, only the active Space's tabs and archived tabs are listed (judged by the Space's id, not its name), and actions mode has no Move row naming another Space (share coat Sc3). | `CommandBarViewTest.ChoosingATabInAnotherSpaceSwitchesToIt`, `CommandBarViewTest.EnterFollowsTheTabNotItsIndex`, `CommandBarViewTest.ShareCoatFiltersToTheActiveSpace`; browser: `CommandBarTest.HidingOtherSpacesHidesThemFromTheBar`; browser: `CommandBarKeysTest.TheHighlightedRowIsTheOneThatRuns` | built |
| K3 | Typed text is classified the way the address bar classifies it: "example.com" opens, "dfsfsfsdfdsfcvv3233" searches. | `CommandBarViewTest.TypedTextWithoutAClassifierBecomesASearch` (fallback); live on the classifier | built |
| K4 | Below the tabs, the omnibox providers' suggestions (history, bookmarks, search suggestions) appear as they arrive, labelled Search / History / Bookmark / Open. | live | built |
| K5 | ↑/↓ move the chosen row and scroll it into view; Enter takes it (or the typed text when it is the chosen row). One list of rows is what the bar draws, what the arrows move through and what Enter runs. | `CommandBarViewTest.ArrowKeysKeepTheChosenRowInView`, `CommandBarViewTest.EnterRunsTheHighlightedArchivedRow`; browser: `CommandBarKeysTest.TheHighlightedRowIsTheOneThatRuns` (Down n times and Enter runs the highlighted row for every n: the typed text, each tab, each archived tab), `CommandBarKeysTest.TheHighlightedRowStaysInView` (fifteen Downs in actions mode), `CommandBarKeysTest.ATabClosedUnderTheBar` | built |
| K6 | The bar takes the theme's dialog colours with a quiet text-tinted highlight. | capture | built |
| K7 | The "Open"/"Search" row always shows what Enter does with the typed text; in ⌘L's bar it reads "Go" (K12). | `CommandBarViewTest.CmdLEditsTheCurrentTab` (the "Go" row); live | built |
| K8 | In an empty bar, ⇥ (or a leading ">") switches to actions mode: rows are commands, not tabs; ⇧⌘P opens the bar already in actions mode. | `CommandBarViewTest.TabFiltersToActions` (⇥ and the leading ">"); ⇧⌘P through `IDC_STEDDING_COMMAND_PALETTE`, listed by `ShortcutReferenceTest.*`; live capture | built |
| K9 | Actions mode lists Stedding's verbs (Move tab to a Space, Pin or Unpin, Move to New Folder, Sleep Tab, New Space, Independent Session, Focus, Hide Other Spaces, one on/off row per Stedding preference, Peek's excepted while Peek is withdrawn: nothing offers to turn it on, PLAN.md CMD-4) and one table of window commands: Clear this Space, Next and Previous Space, the captures, Copy Link and Copy Link as Markdown, the sidebar, the address row, New Blank Window, and an allow-list of Chromium's commands (new window, new private window, reopen closed tab, duplicate tab, move tab to a new window, close tab, close window, reload, find, print, save page, zoom, full screen, view source, developer tools, history, downloads, extensions, settings, clear browsing data). A command row is listed only while its command is enabled in the window. Chromium's action registry is not walked: no page actions and no toolbar pin or unpin. Rename and "Archive idle tabs now" are not rows. | `CommandBarViewTest.ActionRowsListSpacesAndCaptures`, `CommandBarViewTest.CommandRowsFollowTheWindowsCommands`, `CommandBarViewTest.PopupWindowsHaveNoCommandRows`; browser: `CommandBarActionsTest.EveryRowRunsInANormalWindow`, `CommandBarActionsTest.EveryRowRunsInAPrivateWindow` (⇧⌘P, then Enter on every listed row through the field's own key path, "Close Window" last; "Save Page As", "Print", full screen and "Import from Arc" are not run, each for its stated reason; no row names Google, Shopping or Peek) | built |
| K10 | Rows match the typed text as a case-insensitive part of the label; the accelerator is drawn at the right of the row from the window's AcceleratorProvider; Enter on a command row runs it through the window's command controller. | `CommandBarViewTest.MoveToSpaceRowMovesTheTab`, `CommandBarViewTest.ActionRowsCarryAccelerators` (an injected provider), `CommandBarViewTest.CommandRowsFollowTheWindowsCommands` | built |
| K11 | Every later feature that adds a command adds its row here; the empty actions state reads "No matching command" (never a blank panel). | the empty state is `RebuildRows`'s "No matching command" row; capture | built |
| K12 | ⌘L opens the bar prefilled with the page's address as the address bar shows it for editing, selected; the typed row reads "Go", and Enter on it or on a suggestion navigates that tab. The search chord (⌥⌘F on the Mac, Ctrl+E or Ctrl+K on Windows) opens the same bar empty. Escape returns to the page unchanged. A click on the address row's URL text is not routed to the bar yet. | `CommandBarViewTest.CmdLEditsTheCurrentTab`, `CommandBarViewTest.FocusSearchOpensTheBarForThisTab` (both through `chrome::ExecuteCommand`, with the bar in a stand-in for the BrowserView) | partial · the address-row click is not routed yet |
| K13 | ⇥ with text already typed filters that text against actions (Arc); ⇧⇥ returns to tabs mode with the text kept. | CommandBarViewTest.TabWithTextFiltersActions | built |
| K14 | Escape in actions mode returns to tabs mode, listing the tabs that match the text in the field; a second Escape closes the bar. | `CommandBarViewTest.EscapeLeavesActionsModeThenCloses`, `CommandBarViewTest.EscapeShowsTheTabsForTheTypedText`; browser: `CommandBarKeysTest.EscapeFromActionsKeepsTheText` | built |
| K15 | In a private window actions mode lists only the table's commands that belong in a private window and are enabled there: no Space, pin, folder, archive or preference rows, no history and no clearing of browsing data (B14, V2). A popup window has no command bar and no command rows. | `CommandBarViewTest.PrivateWindowListsItsCommands`, `CommandBarViewTest.PopupWindowsHaveNoCommandRows`; browser: `CommandBarActionsTest.EveryRowRunsInAPrivateWindow` | built |
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
