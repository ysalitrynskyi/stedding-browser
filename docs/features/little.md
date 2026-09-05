# Feature: Little window

Status: **E1–E5 planned** (round 6, `docs/ROUND6-PLAN.md` R6-30).
Owner docs: `docs/PRODUCT.md` §5. Patch: TBD.

A link from another application opens small: a popup-type window with a thin bar
(back, forward, reload, the host, "Open in ▸ Space", Pin) and no sidebar, the way Little
Arc does. ⌘O moves the page into the last-active window's active Space; Escape closes it.
A route (routing D1) wins over the little window, and the setting off opens such links as
ordinary tabs.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| E1 | A link from another application opens a `stedding::LittleWindow`, a TYPE_POPUP browser (no Spaces) with a thin bar: back/forward/reload, the centred host, "Open in ▸ <Space>" from the last-active normal window's Space model, and Pin; unless a route matches (routing D3: the route wins). | `LittleWindowTest.ExternalUrlOpensLittleWindow`, `LittleWindowTest.MatchingRouteSkipsIt` | planned |
| E2 | ⌘O moves the WebContents into the last-active window's active Space (insert, then membership, no reload); ⇧⌘O into a split with its active tab; Escape closes; ⌃1–9 inside it send the page to Space N. The verbs mirror the peek's promotions. | `LittleWindowTest.PromoteMovesContentsIntoSpace`, `LittleWindowTest.CtrlDigitSendsToSpaceN` | planned |
| E3 | The archiver gets a per-window threshold: little windows archive at 6 hours (`stedding.little.idle_hours`) against 12 for tabs. | `TabArchiverTest.LittleWindowUsesItsOwnThreshold` | planned |
| E4 | The setting off (`stedding.little.enabled`) opens external links as ordinary tabs in the Space for links from other apps (routing D3). | `LittleWindowTest.SettingOffOpensATab` | planned |
| E5 | No chord opens one in this cut; ⌥⌘N stays the split (welcome W6 advertises it) and the divergence from Arc's ⌥⌘N is a row in the shortcut reference. | the shortcut reference row | planned |

## Notes

- The little window is Chromium's popup window with Stedding's bar in place of the
  popup's location bar; its size is 1000 × 700 at most, centred over the window that
  would have taken the link.
- "Last-active window" is the last activated normal window; with the registry (ADR 0016)
  every normal window shares the Spaces, so the choice only decides where the tab lands.
- VoiceOver: the thin bar is a toolbar with named buttons; the host label is its title
  (critic #31).
