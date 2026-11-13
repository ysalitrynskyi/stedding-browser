# Feature: New tab page

Status: **N1–N5 and N9 built; N6–N8 planned** (BACKLOG S-61).
Owner: `docs/PRIVACY.md`, `docs/PRODUCT.md`. Patches: 0003, 0044.

A new tab opens Chromium's local third-party page, whichever search engine is the default. Nothing on that page leaves the machine. It is a place to press the command-bar shortcut.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| N1 | A new tab opens the local page (`chrome://new-tab-page-third-party`), never a search engine's remote new-tab page, Google included. `NewTabURLDetails::ForProfile` returns that URL for every provider. | `search.cc` (`kUseProviderNewTabPage` false); live: `tooling/probes/ntp.json` | built |
| N2 | The shortcut row is most-visited sites, so a fresh profile has no tile and there is no built-in Chrome Web Store shortcut. | live: `tooling/probes/ntp.json` | built |
| N3 | The page says how to open the command bar: "Press ⌘T to search, open a URL, or find a tab" on the Mac, and Ctrl+T elsewhere (the platform accelerator for T). "Show the command-bar hint on the new tab page" (`stedding.new_tab.show_hint`, on by default) off removes the line (settings T4). | live: `tooling/probes/ntp.json`; settings T4 | built |
| N4 | The page background is Stedding's new-tab colour: white (`#FFFFFF`) in a light window and `#36383F` in a dark one, not the Space's tint and not Google's new-tab colours (`kNewTabLight`, `kNewTabDark` in `stedding_color_mixer.cc`; spaces B11). | `tooling/probes/ntp.json` (a dark window) | built |
| N5 | "Show most-visited shortcuts on the new tab page" (`stedding.new_tab.show_shortcuts`, on by default) off hides the shortcut row (settings T5). | settings T5 | built |
| N6 | A new tab in a Space lists that Space's pins, recents and yesterday's archive. No feed, no network (N1). | `MorningDigestTest.CardIsForTheTabsSpace` (not written yet) | planned · BACKLOG S-61 |
| N7 | After local midnight, one card of local facts: archived, slept with a recorded reason, downloads started in that Space. Counts and titles, never a generated paragraph. It can be turned off. | `MorningDigestTest.EmptySpaceHasNoCard` (not written yet) | planned · BACKLOG S-61 |
| N8 | Visits in a Space's own session do not rank in ⌘T of another Space unless a modifier is held. `@Space` in the command bar is commandbar K19, which is built and is not this. | its own test is not written yet | planned · BACKLOG S-61 |
| N9 | The New Tab page's bookmarks bar lists no tab groups: "Show tab groups" (`bookmark_bar.show_tab_groups`) is off at first. The sidebar lists a window's groups in their Space. A group the profile saved, one an extension made to drive a tab included, had put a chip and the tab groups button on the New Tab page of every Space, and with no bookmarks they alone brought the bar out (the owner, 2026-11-04; BACKLOG S-408). | browser: `DefaultsTest.ASavedTabGroupBringsNoBarToTheNewTab` | built |
