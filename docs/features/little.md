# Feature: Little window

Status: **E4, E5 built; E1–E3, E6 partial** (round 6, `docs/ROUND6-PLAN.md` R6-30). The Mac only: on Windows, links from other applications open as tabs (`BACKLOG.md` S-56).
Owner docs: `docs/PRODUCT.md` §5. Patch: 0035.

On the Mac, a link from another application opens small: a popup-type window with
no sidebar, the way Little Arc does. On Windows it opens as an ordinary tab and the
setting is not shown (`BACKLOG.md` S-56).
⌘O moves the page into the last-active window. A little window has no Space
commands. Escape closes it.
A route (routing D1) wins over the little window, and the setting off opens such links as
ordinary tabs.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| E1 | A link from another application opens a `stedding::LittleWindow`, a TYPE_POPUP browser (no Spaces) with a thin bar: back/forward/reload, the centred host, and Pin; unless a route matches (routing D3: the route wins). The command bar does not open in a little window; ⌘O is how the page reaches the main window (E2). | `LittleWindowTest.ExternalUrlOpensLittleWindow`, `LittleWindowTest.MatchingRouteSkipsIt`; live: `w4_little` (`open -a Stedding` with the setting on) | partial · the window, its size and place, and the route rule are built; its bar is Chromium's popup bar (back, forward, reload, the address), not a thin bar of its own |
| E2 | ⌘O moves the WebContents into the last-active window's active Space (insert, then membership, no reload); ⇧⌘O into a split with its active tab, or into a tab of its own when that tab is already split, pinned or outside the active Space; Escape closes. The window is marked little before its first tab, and its ⇧⌘O and Escape commands follow the mark. A little window has no Space commands: ⌃1–9 do nothing there, and there is no "Open in <Space>" row. | `LittleWindowTest.PromoteMovesContentsIntoSpace`, `LittleWindowTest.ShiftCmdOSplitsOrOpensATab`, `LittleWindowTest.EscapeClosesIt` (the last two through `chrome::ExecuteCommand`); live: ⌘O in `w4_little_promoted` | partial · Escape's command is enabled, but on the Mac a bare Escape does not reach it (traced in code, not seen on a device): AppKit sends only modified keys down the path that reads the hidden-shortcut table, and the window's own Escape accelerator is Chromium's stop-or-close-find. It needs a BrowserView accelerator for the little window (PLAN CMD-15) |
| E3 | A little window and a popup are never closed for being idle, including when a second tab is open: nothing sweeps them. The archiver is made for normal windows only, and the little window's own idle close was cut (PLAN.md WEB-32). | none: by construction (`browser_window_features.cc` builds the archiver for a normal window alone) | partial · holds by construction; no test |
| E4 | The setting off (`stedding.little.enabled`) opens external links as ordinary tabs in the Space for links from other apps (routing D3). | `LittleWindowTest.SettingOffOpensATab`; the toggle: `w4_little_settings` | built |
| E5 | No chord opens one in this cut; ⌥⌘N stays the split (welcome W6 advertises it) and the divergence from Arc's ⌥⌘N is a row in the shortcut reference. | `docs/features/shortcuts.md` (the note); the reference lists ⇧⌘O and Escape inside a little window | built |
| E6 | The little window opens in the profile upstream's tab path would use: with private windows forced by policy that profile is a private one, which has no little windows, and the link opens the ordinary way; a profile that may not open a window (shutting down, forced private) gets none instead of a crash. An address from another app that nothing vouches for (a custom scheme) opens with an opaque initiator, so it sends no SameSite=Strict cookie and says it came from another site (PLAN.md CMD-7). | browser: `LittleWindowTest.AnUntrustedAddressOpensAsCrossSite`, `LittleWindowTest.ATrustedAddressOpensAsTyped`, `LittleWindowTest.AProfileThatMayNotOpenWindowsGetsNone`; the policy path through `application:openURLs:` is live only | partial · the refusal and the opaque initiator are tested; the policy path through `application:openURLs:` is checked by reading the code only |

## Notes

- The little window is Chromium's popup window with Chromium's popup bar; Stedding's
  thin bar (the host, Pin) is not built (E1). Its size is 1000 × 700 at most, centred
  over the window that would have taken the link.
- "Last-active window" is the last activated normal window; with the registry (ADR 0016)
  every normal window shares the Spaces, so the choice only decides where the tab lands.
- VoiceOver, once the thin bar is built (E1): a toolbar with named buttons, the host
  label its title (critic #31).
