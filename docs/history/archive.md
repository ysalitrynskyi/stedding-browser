# Closed backlog items

Every item that left [BACKLOG.md](../../BACKLOG.md), with how it closed. Ids are never reused;
specs, patches and notes cite them, and `tooling/check-repo` resolves every id cited in the
docs here or in the backlog. What each feature does now is its spec under
[features/](../features/); the 2026-09-26 audit, whose ids the code cites, is
[plan-2026-09-26.md](plan-2026-09-26.md).

| Id | Item | Closed by |
|---|---|---|
| S-355 | ⇧⌘T does not reopen a closed little window | Closed 2026-10-30, declined (the owner): a little window is meant to be thrown away, and closing one leaves nothing for ⇧⌘T, since Chromium records closed normal and app windows only and a closed tab only from a window with a tab strip (seen 2026-10-29, S-354's attempt). |
| S-362 | Manifest V2 extensions (GitHub issue 59) | Closed 2026-10-30, declined for now (the owner). Chromium 157 still has the code: one switch, `ShouldDisableLegacyExtensions()` in `extensions/browser/manifest_v2_handler.cc`, returns true outside tests. Turning it back on would be a patch every Chromium update could break, kept for one kind of extension. `docs/FAQ.md` ("Does uBlock Origin work?") points to uBlock Origin Lite and the built-in blocker. |
| S-363 | Duplicate in the short tab menu (GitHub issue 63) | Closed 2026-10-30 (patch 0110; tabs R64, menus M1), after 0.4.0 beta 2, for the next release. The short menu offers Chromium's Duplicate above Copy Link, on every kind of row. Its copy of an essential or a Space pin is a plain tab, added where a new tab opens (the owner's choice, 2026-10-30): Chromium put the copy beside the tab it copies, so an essential's copy was a second essential. `PinnedRunTest.ADuplicateOfAPinIsAPlainTab` and `SidebarClickTest.TheTabMenuFitsEachRowAndActsOnTheRowsShown` failed before the fix and pass after it; the Mac's whole sweep on the release build passed. On the Mac's release build, through each row's menu, an essential's and a Space pin's Duplicate each opened a plain tab at the end of the list and left the essential and the pin alone, and a plain tab's copy landed right after it. Not yet built or run on Windows. |
| S-356 | A pin a collapsed folder keeps listed stays listed after it is put to sleep (GitHub issue 35, a comment on 0.4.0 beta 1) | Closed 2026-10-29 (patch 0112; folders F3), after 0.4.0 beta 2, for the next release: `SpaceTabVisibilityController` redraws the rows when a tab in a collapsed folder changes as a whole, as a sleep reports it. `FolderTabsTest.AnAwakePinFoldsAwayWhenItSleeps` failed before the fix and passes after it on the Mac and on Windows. On the Mac's release build, a pinned page in a collapsed pinned folder stayed listed while another tab was on screen, and its − put it to sleep and folded its row away at once. |
| S-352 | An extension's keyword in the command bar is not handed to the extension | Closed 2026-10-29 (patch 0109; commandbar K18): the omnibox API sets a handler in a target with no dependencies (`//chrome/browser/ui/stedding:extension_keyword`), and the bar's typed row hands "keyword query" to the extension through `chrome.omnibox.onInputEntered`. On the Mac release build of the Chromium 157 series, with an unpacked extension whose keyword is "ek", typing "ek hello world" in ⌘T's bar showed the row "Keyword Echo", and Enter gave the extension "hello world" (currentTab, over an untouched New Tab, K21). Tests: `CommandBarViewTest.AnExtensionsKeywordIsHandedToTheExtension`, `CommandBarActionsTest.AnExtensionsKeywordGetsTheQuery`, seen failing first; `mac-checks` and `win-checks` clean. |
| S-354 | A little window brought back with ⇧⌘T comes back as a plain popup | Not reproduced 2026-10-29: a browser test opened a little window, closed it and ran ⇧⌘T on the release build of the Chromium 157 series. Nothing came back: one window, its one tab, as before. A popup leaves no entry for ⇧⌘T at all (`unload_controller.cc`, `BrowserTabStripModelDelegate::CreateHistoricalTab`). Whether it should is S-355, for the owner. |
| S-309 | Docs brought up to date and trimmed | Done 2026-10-28: every document checked against the patches and rewritten, the records cut (`docs/PROJECT-LOG.md`, 2026-10-28). |
| S-304 | A pinned tab in a folder stays listed while it is open (issue 35) | Built 2026-10-28 on the owner's word: a collapsed folder keeps a pin that is awake listed (folders F3, patch 0112). |
| S-332 | A pinned tab's x removes it, after asking (issue 50) | Released 2026-10-28 in 0.3.0 beta 22: on a pin that is not on screen the x asks before it removes the pin, and on the pin on screen the button is a minus that sleeps it. The same day on main, patch 0110 (pins H29) changed that: a minus on every awake pin, an x once it is asleep. |
| S-316 | Sidebar row text shifted when a page's colour arrived | Fixed in patch 0105 (`SteddingColorMixerTest.APagesColourLeavesTheRowsTextAlone`); closed 2026-10-28. |
| S-313 | Settings › Stedding reorganised | Built in patch 0109: a card for each group, with jump buttons (settings T13); closed 2026-10-28. |
| S-312 | Sync through a folder says what to pick (issue 38's follow-up) | Built in patch 0106 (sidebar-file Sf42), released in 0.3.0 beta 18. |
| S-311 | The command bar's rows show the pointer | Built in patch 0105 (commandbar K37); closed 2026-10-28. |
| S-310 | A neutral palette, no amber | Built in patch 0105: the Space colour on the sidebar's ground, a slate scale for the light ground and the welcome page; closed 2026-10-28. |
| S-308 | Peek, explained | Built in patch 0106: the first-peek note and the welcome line (peek P19), released in 0.3.0 beta 18. |
| S-307 | A read-only review of all code and tests (2026-10-26) | Done 2026-10-26; its open findings are S-314 and S-315, the rest landed in patches 0105, 0106, 0108 and 0109. |
| S-256 | The pin moves to Chrome 156's stable release | Done 2026-10-21 (156.0.8078.48, first shipped in 0.3.0 beta 1); the pin has since moved to 157.0.8103.31 (S-278). |
| S-106 | An ASan run of patches 0058 to 0063 | Covered by the later `win-asan` run on patch 0071: no AddressSanitizer report, DCHECK or dangling pointer; closed 2026-10-28. |
| S-99 | Space colours and icons, freely chosen | Built: spaces B41 to B44 (any emoji, one colour or a light and dark pair); closed 2026-10-28. |
| S-89 | Clean links on every page opened | Built in patch 0089 (clean-links Cl1 to Cl14), released in 0.3.0 beta 16. |
| S-321 | Numbered Space keys on ⌘ (issue 13) | Released 2026-10-28 in 0.3.0 beta 22 (shortcuts Z23, patch 0100). |
| S-325 | Copy Link in the little window (issue 48) | Released 2026-10-28 in 0.3.0 beta 22 (copy-link L7, little E8, patch 0083). |
| S-324 | ⌘T on a folder’s last tab joined the folder | Fixed 2026-10-27 in patch 0057 (folders F25): that ⌘T stays out of the folder. |
| S-322 | Crash after ⌘Y, then ⌘S (issue 44) | Fixed 2026-10-27 (sidebar-panels Pn4): ⌘S waits until the panel has gone. |
| S-319 | Two Peek findings from the fifth review | Closed 2026-10-26: a key ends a held press (peek P18, patch 0102); Open as Tab follows P7. |
| S-305 | Hide a drifted pin’s dot and reset (issue 36) | Built 2026-10-26, off by default (pins H28, settings T36). The menu’s Reset stays. |
| S-317 | Which row a pin’s ⌘W and Sleep Tab show | Decided 2026-10-26: both show the row a close would (pins H3, tabs R5). |
| S-301 | A close skipped the essential (issue 30) | Changed 2026-10-24 (tabs R33): the essential used last can come back. |
| S-298 | A link from an essential shoved the pins (issue 29) | Fixed 2026-10-24 in patch 0070 (pins H14): the new tab passes a pinned folder. |
| S-299 | No drop on the first row under Clear (issue 26) | Fixed 2026-10-24 in patch 0083 (tabs R63): that drop stays under the line. |
| S-300 | No drop between a folder’s rows (issue 27) | Fixed 2026-10-24 in patch 0083 (folders F40): the pointer’s place is kept. |
| S-81 | Import from Arc on Windows | Shipped in 0.3.0 beta 13 (import I27); seen on Arc for Windows, 2026-10-24. |
| S-296 | Google Pay used the shared session (issue 25) | Fixed 2026-10-24 in patch 0067 (sessions S36): an own session is offered no payment app. |
| S-289 | Animated drag into the essentials (issue 16) | Built 2026-10-24 in patch 0086 (pins H27): the drag becomes a card, then a row. |
| S-292 | The restore bar’s close did nothing (issue 24) | Fixed 2026-10-24 (sidebar Y29): an infobar there takes its own press. |
| S-293 | The address field changed width (issue 14) | Fixed 2026-10-24 (toolbar T34): hovered, focused and edited, the field is the whole row. |
| S-294 | The site chip looked hovered at rest | Fixed 2026-10-24 (toolbar T44): an icon-only chip has no capsule until hover. |
| S-295 | The “Not Secure” icon sat low | Fixed 2026-10-24 (toolbar T44): a short chip lays its icon and text out in its own height. |
| S-290 | A tab drag moved the address row with it | Fixed 2026-10-24 (tabs R61): during the drag the row stays on the page on screen. |
| S-287 | The top essentials row moved the window (issue 23) | Fixed 2026-10-23 in patch 0077 (sidebar Y29). Released in 0.3.0 beta 11. |
| S-275 | The address jumped left on focus (issue 14) | Fixed 2026-10-23 in patch 0078 (toolbar T18). Released in 0.3.0 beta 11. |
| S-285 | A press to drag opened the tab first | Fixed 2026-10-23 (tabs R61, splits J10): the press waits; the page stays. Released in 0.3.0 beta 11. |
| S-288 | New tabs at the top of the list (issue 22) | Built 2026-10-23 in patch 0087, off by default (tabs R62, settings T30). Released in 0.3.0 beta 11. |
| S-281 | A pinned-run drag test tore the tab off | Fixed 2026-10-23 in the tests (patch 0077): the window stays above others. No product change. |
| S-280 | A chip test timed out under AddressSanitizer | Fixed 2026-10-23 in the test (patch 0079). Passed in 0.3.0 beta 10’s Windows ASan run. |
| S-277 | Drag a tab into the essentials and out (issue 16) | Built 2026-10-22 in patch 0086 (pins H27). |
| S-276 | Essentials shrink as more are added (issue 15) | Built 2026-10-22 in patch 0085 (sidebar Y33): up to four, then two rows. |
| S-274 | Every new Space can have its own session (issue 8) | Built 2026-10-22 in patch 0084, off by default (sessions S35, settings T29). |
| S-273 | Copy Link kept its hover after a click (issue 11) | Fixed 2026-10-22 in patch 0083 (copy-link L7): the press ends when the copy runs. |
| S-271 | A drop among pins unpinned the last pin | Fixed 2026-10-22 in patch 0083 (pins H14): a row takes the pin of the side it is dropped on. |
| S-269 | A tab group crashed with animations off | Fixed 2026-10-22 in patch 0071 (spaces B33): the callback exists before layout. |
| S-268 | A hover state on the New Tab row (issue 12) | Built 2026-10-22 in patch 0083 (sidebar Y32). |
| S-259 | A Copy Link button in the address field (issue 11) | Built 2026-10-22 in patch 0083 (copy-link L7, settings T28). On by default. |
| S-260 | A held drag onto a Space chip switches | Built 2026-10-22 in patch 0083 (spaces B12): half a second on the chip switches. |
| S-261 | A folder dragged into another folder | Built 2026-10-22 in patch 0083 (folders F38, F39). |
| S-262 | The tab list ended against the sidebar’s edge | Built 2026-10-22 in patch 0083 (sidebar Y30): a long list scrolls half the list’s height past the end. |
| S-263 | A pin sent home kept the last page’s title | Fixed 2026-10-22 in patch 0083 (pins H1, H3): the row shows the home at once. |
| S-264 | A link’s tab sat a level to the right | Changed 2026-10-22 in patch 0083 (settings T26, tabs R57): nesting is off by default. |
| S-265 | Every folder looked grey | Fixed 2026-10-22 in patch 0083 (tabs R7, folders F12): a header is never drawn asleep. |
| S-266 | A link from a nested pinned folder unpinned it | Fixed 2026-10-22 in patch 0083 (folders F38): the new tab leaves for under the line. |
| S-267 | Memory, CPU and network in the hover card | Built 2026-10-22 in patch 0083 (pins H25): the line appears after 2 seconds. |
| S-230 | The command bar listed an open tab as archived | Done 2026-10-20 in patch 0072 (archive A13). Passed on Windows with 0.3.0 beta 2. |
| S-220 | A test left a profile in the real data folder | Fixed 2026-10-19 in patch 0072: tests use a temporary data folder, and tooling/dev warns. |
| S-254 | Essentials per Space (issue 8) | Built 2026-10-22 in patch 0083 (ADR 0028, spaces B6): an own session has its own essentials. |
| S-252 | A drag test read the machine’s real pointer | Closed 2026-10-22 in patch 0077: the test window stays clear of that pointer. |
| S-253 | Turning vertical tabs on as a drag ended crashed | Fixed 2026-10-21 in patch 0077. Passed in 0.3.0 beta 2’s Mac and Windows sweeps. |
| S-104 | Hidden address-row controls in the command bar | Built 2026-10-20 in patch 0075 (toolbar T39, T40, commandbar K31–K33). |
| S-110 | At launch, only the selected tab loads | Built 2026-10-20 in patch 0075 (tabs R45–R48, settings T22). |
| S-111 | Tabs sleep on a timer and under memory pressure | Built 2026-10-20 in patch 0075 (tabs R39–R44, settings T21). |
| S-112 | Which tab is selected after a close | Settled 2026-10-22 (tabs R33): the row used last, while it is in view. |
| S-113 | Make a split by dropping a tab on the page | Built 2026-10-20 (splits J10–J15, issue 7). |
| S-115 | A picture of the page in the hover card | Built 2026-10-20 in patch 0075 (pins H19–H23): in memory only. |
| S-214 | A label painted on a layer that was not opaque | Fixed 2026-10-18 (folders F36, spaces B17). Checked on 0.2.0 beta 20, 2026-10-20. |
| S-144 | Badges hide, and one list for ⌘1–9 | Fixed 2026-10-18 (tabs R10, R11); chord chips widened 2026-10-20 (patch 0072). |
| S-143 | A slept row lost its dim, and hover rebuilt it | Fixed 2026-10-18 (tabs R4, R7). A false hover was fixed 2026-10-20 (patch 0072). |
| S-222 | Deleting a Space another window showed stopped the browser | Fixed 2026-10-18 (spaces B5). Checked on 0.2.0 beta 20, 2026-10-20. |
| S-139 | Move to Space on a tab inside a folder | Fixed 2026-10-18 (folders F37): the tab leaves every folder. Checked 2026-10-20. |
| S-223 | A one-pixel line under the address row in full screen | Fixed 2026-10-18 (toolbar T32). Gone on 0.2.0 beta 20, checked 2026-10-20. |
| S-224 | The Clear line sat under the traffic lights | Fixed 2026-10-18 (sidebar Y17). The sidebar keeps its top row. Checked 2026-10-20. |
| S-229 | A restored tab’s row lost its title | Fixed 2026-10-19 in patch 0072 (tabs R31). Held on 0.2.0 beta 20. |
| S-232 | A rail drop on a folder glyph landed after it | Fixed 2026-10-19 in patch 0072. The drop joins the folder on 0.2.0 beta 20. |
| S-149 | Rename in the title row and on the rail | Done 2026-10-18 (spaces B16): each rename edits where it was asked. |
| S-250 | Mac checks: a dangling tab pointer, two slow tests | Fixed 2026-10-20 in patch 0071: a closed tab is told of its detach once. |
| S-236 | Chrome’s launched defaults that Stedding lacked | Done 2026-10-20 in patch 0074. TcpPortRandomizationMac left off; its fix was not in that pin. |
| S-237 | Certificate Transparency enforcement | Done 2026-10-20 in patch 0074 (docs/PRIVACY.md): enforced, audit reports off. |
| S-240 | Read Chrome’s field trials at every pin move | Done 2026-10-19: tooling/field-trials, a standing step (docs/AGENT-LOOP.md). |
| S-71 | Uninstall left the PDF handler’s ProgId | Fixed 2026-10-19 in patch 0073 (windows N6): the uninstaller deletes that key. |
| S-249 | Windows updater leftovers from the beta 19 review | Fixed 2026-10-19 in patch 0073 (updates Up14–Up22). |
| S-212 | A tab pinned while selected restored unselected | Fixed 2026-10-18 (pins H18). Shipped in 0.2.0 beta 20. |
| S-213 | The welcome test hook missed the Windows checks build | Closed 2026-10-19: 0.2.0 beta 20’s checks build passed WelcomeFlowTest. |
| S-66 | Crashes, triaged from macOS crash reports | Closed 2026-10-19: 0.2.0 beta 20 carried the last fix the reports tied to (S-134). |
| S-134 | Skipping the engine step opened Chromium’s chooser | Fixed 2026-10-18 (welcome W2): skip records DuckDuckGo. 0.2.0 beta 18 Windows, beta 20 Mac. |
| S-79 | Arc, while it runs, takes ⌥⌘N | Fixed 2026-10-18 (shortcuts Z3): on the Mac the split is ⌃⌘N. Shipped in 0.2.0 beta 20. |
| S-55 | Network service restarted at startup | Closed 2026-10-18: the line came from an old Windows build configuration, not the series. |
| S-138 | The Clear line when nothing is pinned | Fixed 2026-10-18 (spaces B17): the line shows whenever rows follow it. Shipped in 0.2.0 beta 20. |
| S-219 | The sidebar slid out again after the toggle | Fixed 2026-10-18 (sidebar Y11). Shipped to the Mac in 0.2.0 beta 20. |
| S-221 | A right-hand sidebar test was flaky on Windows | Closed 2026-10-19 in patch 0072. Passed in 0.2.0 beta 20’s three Windows runs. |
| S-226 | A private window’s row never took the page colour | Fixed 2026-10-18 (toolbar T21): a transparent sample is no colour. Passed on 0.2.0 beta 20’s ASan run. |
| S-227 | The infobar container kept its height | Fixed 2026-10-19 in patch 0072. Passed in 0.2.0 beta 20’s Windows runs. |
| S-225 | A replaced split came back apart after Restore | Fixed 2026-10-18 (splits J1, sessions S12). Shipped in 0.2.0 beta 20. |
| S-248 | Later Windows acceptance parts started behind other apps | Tooling, 2026-10-19: the fixture brings the window forward before it waits. |
| S-215 | The Windows updater | Built 2026-10-19 in patch 0073 (updates Up14–Up22, ADR 0023). First in 0.2.0 beta 19. |
| S-72 | A second Windows release on one pin installed as a repair | Fixed 2026-10-19 in patch 0073 (updates Up22): each build carries Stedding’s own version. |
| S-245 | Turning dark pages on stopped a checks build | Fixed 2026-10-19 in patch 0072: a page with no edge read is left alone. |
| S-246 | The horizontal strip’s spinner was coloured against black | Fixed 2026-10-19 in patch 0072 (tabs R23): the strip’s ground is the frame. |
| S-244 | A toast covered an infobar’s text | Fixed 2026-10-19 in patch 0072 (toolbar T38): a window toast sits under the infobars. |
| S-242 | This round’s features failed ten Windows browser tests | Fixed 2026-10-19 in patch 0072: the failures were in the tests (HANDOFF traps 113–115). |
| S-228 | Escape cannot cancel Ctrl+Tab on Windows | Decided 2026-10-19 (switcher X3): no system-wide hook; Ctrl+Esc keeps the Start menu. |
| S-231 | A hidden address row left a one-pixel line on Windows | Fixed 2026-10-19 in patch 0072: the hidden row is laid out at no height. |
| S-233 | The Windows acceptance runner stalled at its pin step | Tooling, 2026-10-19: each DevTools call has a three-second limit. |
| S-243 | The essentials cards had a coloured edge | Fixed 2026-10-19 in patch 0072 (tabs R32): a card is a frosted tile with no edge. |
| S-154 | Full screen, two looks still missing | Fixed 2026-10-18 in patch 0071 (toolbar T32): a tab switch re-themes the row. |
| S-47 | An input-free settings probe | Tooling, 2026-10-18: tooling/capture-state opens chrome://settings/stedding with no pointer (settings T13). |
| S-218 | Ctrl+Alt+arrows from the address bar on Windows | Fixed 2026-10-18 in the driver (spaces B19, windows N7): the arrow is the extended key. |
| S-74 | Automatic updates, the Mac first | Built 2026-10-16 in patch 0068 (ADR 0022, updates.md). 0.2.0 beta 17 was the first offered. |
| S-217 | Take 156.0.8078.36 | Pinned 2026-10-16 (ADR 0007). Main moved to 157.0.8103.31 on 2026-10-28; that pin is not released. |
| S-211 | The default favicon was Chromium’s grey globe | Branding, 2026-10-15: Tabler’s world-www globe (branding/README.md). |
| S-179 | sessionStorage lost, and a crash restore dropped Spaces | Fixed 2026-10-15 in patch 0067 (sessions S28, S29). |
| S-180 | A Space’s workers acted in the wrong jar | Fixed 2026-10-15 in patch 0067 (sessions S30). |
| S-181 | A restored tab’s Space came back on a window move | Fixed 2026-10-15 in patch 0067 (spaces B2): the saved Space is read once. |
| S-182 | A Space-pinned split sat under the Clear line | Fixed 2026-10-15 in patch 0067 (pins H14). |
| S-183 | The Arc import’s edge cases | Fixed 2026-10-15 in patch 0067 (import I3, I22, I23): a repeated Space name is one Space. |
| S-184 | The welcome behaviour step redrew over a click | Fixed 2026-10-15 in patch 0067 (welcome W12): a late answer keeps the click. |
| S-185 | Sleep and the archive could drop unseen edits | Fixed 2026-10-15 in patch 0067 (tabs R6, archive A12, sessions S21). |
| S-186 | The welcome bookmarks-file row did nothing | Fixed 2026-10-15 in patch 0067 (welcome W3): the row opens the file chooser. |
| S-187 | The archive page and the welcome swatch read the wrong things | Fixed 2026-10-15 in patch 0067 (archive A9, welcome W7). |
| S-188 | WebUI handlers trusted the page’s message shape | Fixed 2026-10-15 in patch 0067: a message of the wrong shape is dropped. |
| S-189 | Two Ctrl+Alt chords did nothing on an AltGr layout | Fixed 2026-10-15 in patch 0067 (windows N13, N14). |
| S-210 | An unnamed tab group showed a blank bar | Fixed 2026-10-15 in patch 0066 (folders F36): the header shows the tab count. |
| S-201 | A typed address took another app’s open mark | Fixed 2026-10-15 in patch 0066 (routing D3): only the other app’s tab spends the mark. |
| S-202 | A Chrome shortcut file opened as a file URL | Fixed 2026-10-15 in patch 0066 (routing D3, little E1): the shortcut’s target is what opens. |
| S-203 | A host route missed IPv6 and the default port | Fixed 2026-10-15 in patch 0066 (routing D1). |
| S-204 | The welcome flow dropped focus when a label changed | Fixed 2026-10-15 in patch 0066 (welcome W12): each control keeps a stable key. |
| S-205 | Clear was out of reach of Tab and VoiceOver | Fixed 2026-10-15 in patch 0066 (spaces B17): Clear is a button while its label shows. |
| S-206 | A deleted Space’s jar could stay after a quit | Fixed 2026-10-15 in patch 0066 (sessions S17): the next window finishes the wipe. |
| S-207 | Undo of a folder’s last tab could enter a group | Fixed 2026-10-15 in patch 0066 (tabs R27): a tab from no group comes back in none. |
| S-208 | A failed profile move reused Chromium’s keychain key | Fixed 2026-10-15 in patch 0066 (windows N8): the empty profile makes its own key. |
| S-209 | Tests that passed without what they check | Fixed 2026-10-15 in patch 0066: each step fails on its own. |
| S-190 | Closing one pane of a split crashed | Fixed 2026-10-15 in patch 0065 (splits J9): the row’s layer is made once it has a parent. |
| S-191 | Grouping a tab inside a folder crashed | Fixed 2026-10-15 in patch 0065 (folders F35): the group goes after the outermost folder. |
| S-192 | The Arc import crashed on a blocked login | Fixed 2026-10-15 in patch 0065 (import I22, I23): a blocked row is saved bare. |
| S-193 | Deleting a Space wiped its jar under open pages | Fixed 2026-10-15 in patch 0065 (sessions S17): the wipe waits for those pages. |
| S-194 | Autofill asked Google about every form | Fixed 2026-10-15 in patch 0065 (privacy Q14): server communication is off. |
| S-195 | The command bar opened scopes it refuses | Fixed 2026-10-15 in patch 0065 (commandbar K7, K17, K18). |
| S-196 | Shift ignored by History’s Restore Folder | Fixed 2026-10-15 in patch 0065 (folders F19): Shift restores into a new window. |
| S-197 | A split switched to stacked kept side-by-side corners | Fixed 2026-10-15 in patch 0065 (splits J7): the corners redraw with the layout. |
| S-198 | Export Space could write outside its folder | Fixed 2026-10-15 in patch 0065 (import I20): the file name is made safe. |
| S-199 | A slept tab lost its place in a folder close | Fixed 2026-10-15 in patch 0065 (folders F19): the place goes with the replaced contents. |
| S-200 | Tests read a freed command bar | Fixed 2026-10-15 in patch 0065: those tests run where the bar cannot close under them. |
| S-137 | A folder closed in part came back at its end | Fixed 2026-10-14 in patch 0063 (folders F19, F20): each row returns to its slot. |
| S-135 | A restored folder came back in reverse order | Fixed 2026-10-14 in patch 0063 (folders F19, spaces B12). |
| S-136 | Splitting two tabs in a folder took them out | Fixed 2026-10-14 in patch 0063 (folders F34, splits J8): the split keeps the folder. |
| S-69 | The restore bar and the gutter stayed in full screen | The gutter in patch 0059; the bar in patch 0063, 2026-10-14 (toolbar T33). |
| S-70 | A Space chip showed its name twice | Fixed 2026-10-14 in patch 0063 (sidebar Y14): the open chip has no tooltip. |
| S-54 | Google’s push service at startup | Fixed 2026-10-12 in patch 0030 (privacy Q11): no token unless a policy can arrive. |
| S-67 | Google’s account list at startup | Fixed 2026-10-12 in patch 0030 (privacy Q12): no ListAccounts while sign-in is off. |
| S-105 | The macOS image of betas 13 and 14 | 0.2.0 beta 14’s Mac image, 2026-10-12 (sidebar Y19, Y20). 0.2.0 beta 13 has none. |
| S-109 | Site Search: Tab makes a site’s name a chip | Built in patch 0061, 0.2.0 beta 14 (commandbar K27). |
| S-114 | Collapse Pinned Tabs | Built in patch 0061, 0.2.0 beta 14 (pins H17): per Space, kept across a restart. |
| S-116 | New Documents | Built in patch 0061, 0.2.0 beta 14 (commandbar K28): eleven services, a fixed list. |
| S-130 | Auto-archive is Never by default | Set in patch 0060, 0.2.0 beta 14 (archive A6, settings T8). |
| S-131 | A welcome step for how Stedding behaves | Built in patch 0060, 0.2.0 beta 14 (welcome W12). |
| S-132 | The address hover cut the first letter | Fixed in patch 0060, 0.2.0 beta 14 (toolbar T34): the field stays whole when hovered, and the address paints no background of its own. |
| S-133 | Toasts covered the address row | Fixed in patch 0060, 0.2.0 beta 14 (toolbar T35): a toast sits under the row. |
| S-77 | Every search engine showed a globe in welcome | Fixed in patch 0060, 0.2.0 beta 14 (welcome W2): each prepopulated engine shows its own mark, and an engine without one shows its initial. |
| S-124 | The page flush against the window | Built in patch 0060, 0.2.0 beta 14, off by default (sidebar Y23, settings T15). |
| S-123 | The sidebar edge shows where to drag | Built in patch 0060, 0.2.0 beta 14 (sidebar Y22): a double click restores the width. |
| S-122 | Mute and picture in picture by key | Built in patch 0060, 0.2.0 beta 14 (tabs R29, commandbar K25, player Mp5). |
| S-120 | Folder verbs: expand, collapse, sort, new tab | Built in patch 0060, 0.2.0 beta 14 (folders F30–F33, menus M7). |
| S-121 | Edit a pin’s home; a middle click sends it home | Built in patch 0060, 0.2.0 beta 14 (pins H15, H16). |
| S-119 | Clear the site’s cookies and reload | Built in patch 0060, 0.2.0 beta 14 (commandbar K24, sessions S27). |
| S-108 | Inline completion in the command bar | Built in patch 0060, 0.2.0 beta 14 (commandbar K23): a history host completes the field. |
| S-97 | Undo after closing tabs | Built in patch 0060, 0.2.0 beta 14 (tabs R25–R28): a toast for 8 seconds. |
| S-84 | New pins landed on top and unpinned under the line | Fixed 2026-10-10 in patch 0059 (pins H14): a pin joins the end of the run. |
| S-85 | The sidebar resized only inside its edge | Fixed 2026-10-10 in patch 0059 (sidebar Y18): the handle reaches the card’s edge. |
| S-86 | A third sidebar form: hidden | Built 2026-10-11 in patch 0059 (sidebar Y19, Y20): hide completely, page to the edge. |
| S-87 | The toggle and the bar named Ctrl+Shift+L | Fixed 2026-10-10 in patch 0059 (windows N7): the chord is Ctrl+S. |
| S-73 | The default globe was nearly invisible in dark mode | Fixed 2026-10-11 in patch 0059 (sidebar Y21): a translucent row is read over the frame. |
| S-82 | The in-browser shortcut list was behind the product | Updated 2026-10-10 in patch 0059 (shortcuts Z1). Peek’s rows are listed (Z1, peek P7). |
| S-83 | The screenshot toast said “Show in Finder” on Windows | Fixed 2026-10-10 in patch 0059 (screenshot C5, windows N10): “Show in folder” off the Mac. |
| S-17 | Signing and notarisation on the Mac | 0.2.0 beta 10’s Mac image, 2026-10-01, was the first signed and notarized (HANDOFF trap 49). |
| S-80 | Incoming rows opened from collapsed during a switch | Fixed 2026-10-02 in patch 0058 (spaces B37): the switch snaps the rows into place. |
| S-78 | ⌘T from an empty New Tab page left that page | Fixed 2026-10-02 in patch 0058 (commandbar K21): an untouched New Tab takes what the bar opens. |
| S-76 | The welcome steps ran under the footer | Fixed 2026-10-02 in patch 0058 (welcome W11): a long step fades until it is scrolled to the end. |
| S-63 | The address row’s colour in full screen | Fixed in patch 0058 (toolbar T32, 2026-10-01): the row is the page’s colour, with one hairline. |
| S-68 | The command bar ran past a narrow window | Fixed 2026-09-30 in patch 0057 (commandbar K20): the bar stays inside the page card. |
| S-64 | Take 155.0.8059.12 | Pinned 2026-09-24 (ADR 0007), from 153.0.8010.53. |
| S-62 | Take 153.0.8010.53 | Pinned 2026-09-18, 49 patches (ADR 0007). Mac image v0.2.0-beta.8. |
| S-52 | Take 153.0.8010.48 | Pinned with 46 patches. Mac image v0.2.0-beta.7 (2026-09-16). |
| S-60 | Independent Space sessions | Built 2026-09-16 in patch 0046 (sessions S1–S12, ADR 0019). Own essentials are spaces B6. |
| S-45 | Google’s new tab page when Google is the engine | Fixed 2026-09-10 in patch 0044 (new-tab N1): every engine opens the local page. |
| S-53 | The rail’s tab pill | Second pass 2026-09-08 (patch 0039). The square now follows density (sidebar Y8). |
| S-46 | Round 7: the operator’s look at beta 3 | Closed 2026-09-05 in patches 0037 and 0038 (toolbar T15, sidebar Y6). Shipped in v0.2.0-beta.4. |
| S-42 | Space colour on the welcome flow | Built in patch 0018 (welcome W7): the swatches tint the first Space at once. |
| S-41 | Download progress on the sidebar button | Built (toolbar T14): the sidebar button shows the ring. The test is in patches 0071 and 0099. |
| S-44 | Round 6: Zen mods and beyond | Landed 2026-09-05 as patches 0016–0036. |
| S-43 | About page version label | Built in patch 0018 (settings T10): About names Stedding’s version and the Chromium pin. Verified 2026-09-05. |
| S-40 | Capture toast | Built in patch 0017 (screenshot C5), verified 2026-09-05. Off the Mac the button says “Show in folder” (S-83). |
| S-38 | Full-screen toolbar over the sidebar | Closed 2026-09-02 in patch 0002 (operator round 4): the toolbar is inset by the sidebar. |
| S-18 | Proprietary-codecs licensing decision | Decided 2026-08-31 (ADR 0008): ship H.264 and AAC. The licence is a 1.0 checklist item. |
| S-36 | Sidebar and Spaces settings rows | Built in patches 0010–0012 (settings T6–T9): hover, width, archive, and the Spaces list. |
| S-37 | Perf budgets on the first vanilla pair | Measured 2026-09-02, local list: cold +2.3%, warm −2.0%, memory +0.0% (docs/perf/README.md). No later measurement. |
| S-39 | Space tint on the sidebar, neutral new tab page | Built in patch 0007 (spaces B11): the active Space tints the sidebar ground only. |
| S-9 | Operator retest: full-screen URL width | Retested 2026-09-02. Since 0.2.0 beta 10 the field takes the row (toolbar T28–T30). |
| S-10 | Operator retest: pill site icon | Retested 2026-09-02: the pill’s site icon rendered clean at 2×. |
| S-31 | Vanilla official build, measured with the same harness | Compared 2026-09-02 (docs/perf/README.md, tooling/args/vanilla.gn). No later measurement. |
| S-35 | Promote a peek into a split | Built in patch 0009 (peek P9). On with Peek since 2026-10-25 (PLAN.md decision 2). |
| S-8 | Popup windows have no Spaces | Covered by PopupSpaceTest (spaces B14). |
| S-34 | Peek for a new tab from a pinned tab | Built in patch 0009 (peek P8). On with Peek since 2026-10-25 (PLAN.md decision 2). |
| S-15 | Settings surface | Built in patch 0010: chrome://settings/stedding (docs/features/settings.md). |
| S-33 | A setting to hide the new-tab shortcut row | Built (new-tab N5, settings T5): a switch hides the most-visited shortcut row. |
| S-14 | Peek | Built in patch 0009. Withdrawn 2026-09-26; on by default since 2026-10-25 (PLAN.md decision 2). |
| S-28 | A Stedding new tab page | Built in patch 0003 (docs/features/new-tab.md): a local page, no Web Store tile. |
| S-32 | Branding leftovers in chrome://settings | “About Stedding”, and the Stedding mark in the chip, app menu and WebUI. |
| S-4 | Folder variant in the tab-strip mojom | Built in patch 0008: a folder is id, title and collapsed, and was verified live. |
| S-29 | De-Google chrome://settings | Built in patch 0003: “You and Google” and “AI in Chrome” are hidden. |
| S-30 | Import entry in the app menu | Present (menus M3, import I14): Import Bookmarks and Settings stays in the app menu. |
| S-13 | Performance baselines from the official build | Recorded 2026-09-02: cold 0.63 s, warm 0.77 s, 5.7 GB, 107 processes (docs/perf/README.md). Not current. |
| S-20 | Folder drop highlight | The hovered header paints its highlight, and the drop lands inside (folders F7). |
| S-16 | Import from Chrome, Arc and Firefox | Closed 2026-09-01. On the Mac, Chromium’s importer brings in Safari and Firefox. Chrome, Brave and Edge stay undocumented until that importer exists (PLAN.md decision 8, S-101). Stedding’s own importer brings in Arc. |
| S-27 | Sidebar collapse button | Kept: it is the sidebar toggle. The tab-group and tab-search combo was removed (patch 0002). |
| S-7 | Command bar across Spaces | Covered by CommandBarViewTest (spaces B13). |
| S-26 | First-run search engine chooser | Chromium’s chooser shipped in patch 0003. Skipping the welcome step records DuckDuckGo (welcome W2, 2026-10-18). |
| S-12 | capture --assert | tooling/assert-capture and tooling/probes/window.json, 23 probes. |
| S-21 | De-Google the new tab page and omnibox | Built in patch 0003 (new-tab N1): DuckDuckGo is the default, and the new tab page is local. |
| S-22 | Essentials as a grid of cards | Built in patch 0002. Since 2026-10-22, up to four cards, then two rows (sidebar Y33). |
| S-23 | Sidebar top row | Built in patch 0002: the tab-group combo, its hairline and the profile avatar are gone. |
| S-24 | Default Space chip glyph | Built in patch 0004: a Space with no icon shows a default glyph, a dot in its colour (spaces B11, B42). The Space menu does not list a fixed set of icons. |
| S-5 | New Tab row | Built in patch 0002: above the unpinned tabs, under Clear. The row opens the command bar. |
| S-25 | The typed text as a command bar row | Built in patch 0005: the bar shows the typed text as an Open or Search row. |
| S-3 | Live restart check for Spaces and folders | tooling/drive quits and relaunches; the list stays (spaces B9). |
| S-6 | Session-compaction audit | The rebuild dropped Stedding’s extra data; a provider registry writes it back. |
| S-19 | Live drag, click and key harness | tooling/drive and tooling/drive-window.py. |
| S-11 | Squash the patch series into per-feature patches | Squashed 2026-09-01 from 45 patches to one per feature (patches/README.md). 111 patches on 2026-10-28. |
| S-2 | Drag a tab onto a folder header to move it in | Built in patch 0008 (folders F7–F9), verified with a synthetic drag. |
| S-1 | Spaces core semantics: membership on insert, active tab follows the switch, empty Space opens a tab, delete moves tabs | patch 0004, `space_model_window_unittest.cc` (spaces B1–B8) |
