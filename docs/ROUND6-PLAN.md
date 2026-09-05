# Round 6 — Zen mods and beyond: the plan

Date: 2026-09-04. Status: hand-off; nothing here is implemented. Backlog row: `S-44`.

This is the plan for round 6 of Stedding: the round that mines the 77 community mods
of Zen Browser (https://zen-browser.app/mods/, fetched 2026-09-04) for the needs they
reveal, adds what Arc parity still lacks, and turns the result into numbered behaviours
with test ids, the way every feature spec in `docs/features/` is written. A behaviour
here is a plan until its test is green on the pinned tree (`docs/AGENT-LOOP.md`).

How it was produced, in one line: a workflow ran eight evaluators over the 77 mods
(each mod: the need behind it, what Stedding has, evidence from the tree, a proposal that
is better than the mod), three idea lenses that each wrote ten ideas beyond the catalogue,
three judges that scored the 84 candidates the synthesis listed (score, verdict, reason),
one synthesis that folded 107 candidates into 24 plan items and 60 skips, one
completeness critic that read the synthesis against PRODUCT.md, QUALITY.md, PRIVACY.md
and the tree, and then the orchestrator's decisions (D1–D11 below), which override the
synthesis where they differ.
Every number in this file comes from that material or from the repo; where the material
is silent the cell says TBD.

## How to continue

For the next agent picking this up cold:

1. **Read order.** `AGENTS.md` → `docs/HANDOFF.md` (the traps) → `docs/AGENT-LOOP.md`
   (the loop) → this file's Decisions and the wave you are in → the item's feature spec
   in `docs/features/` (a new spec is created from the rows here) → `BACKLOG.md`.
2. **One item at a time, the loop as written.** research the seam → copy the item's rows
   into `docs/features/<feature>.md` with State `planned` → write the failing test named
   in the row → implement → `tooling/dev build` → `tooling/dev test <feature>` → capture
   (`tooling/dev capture --assert tooling/probes/window.json`; interactive rows through
   `tooling/drive <profile> <steps>`) → `tooling/dev patch` → commit this repo with the
   regenerated patches, the spec state and the backlog row in one commit.
3. **Patches.** The first round-6 patch is `0016`; each wave-1/2 item family gets one new
   patch, numbered in landing order, and the number is written into the item's Patch line
   and the spec header when it lands (do not pre-assign). Fixups go **only** into round-6
   patches (D11); never into the patches that exist today (`tooling/dev status` lists
   them). Wave-3/4 items follow the same rule.
4. **The status column.** The wave tables below carry `planned`. Move an item to `built`
   (with its patch number) when every row's test is green; a row shipped without a test
   is a `gap` and gets an `S-` id in `BACKLOG.md`. Rows marked `draft` were written by the
   orchestrator from the critic's text and need a side-by-side check against Arc before
   their failing test.
5. **Commands.** `tooling/dev build`, `tooling/dev test <feature>`, `tooling/dev test all`,
   `tooling/dev capture`, `tooling/drive`, `tooling/dev patch`, `tooling/dev check`,
   `tooling/dev status` (every count in a doc comes from it).
6. **Budgets.** Nothing runs unattended past 15 minutes; `tooling/dev build` and `test`
   print progress every minute and stop themselves; a longer job is asked for and passed
   `--budget <minutes>`. Never edit the checkout while a build runs. After a failed fold,
   `git stash list` (HANDOFF trap 8).
7. **Every new surface** is captured in dark and light with a probe (QUALITY; critic #30)
   and names a VoiceOver role and a keyboard-only path in its spec before it is `built`
   (QUALITY accessibility gate; critic #31).
8. **ADRs** are numbered in writing order (`docs/decisions/README.md`); the synthesis's
   "0016"/"0017" are placeholders. Wave 4 starts with the registry ADR (R6-31 G0); the
   privacy ADR is part of R6-26 (Q0).
9. **Paths** below are relative to the Chromium checkout (`docs/HANDOFF.md` says where it
   is) or to this repo; `file:line` numbers were read on the pinned tree on 2026-09-04.

## Decisions

The orchestrator's decisions. Each overrides the synthesis JSON where they differ; the
reason follows the decision.

**D1 — Waves, not one list.** The synthesis delivered 24 items in one order with a dense conflict graph (every item names the files it shares with others). Round 6 ships in four waves. **Wave 1** (small, high value, no ADR): the shortcut reference block in chrome://settings/stedding (critic #6) first, because items cite it; then plan items 2, 9 (with the audio-badge bug folded in, critic #8), 5, 19, 20, 21, 24, S-43 (About version label) and S-42 (a five-swatch Space colour on the welcome appearance step). **Wave 2**: items 1, 3, 4, 6 (with critic #1 Space-scoped Close Others / Clear Below, #14 the tab-group chords removed in the same hunk, #15 four menus), 7, 8, 10, 14 (with critic #10 Space reorder by dragging a chip plus a menu Move left/right), a new `splits.md` spec (critic #5), a selection rule (critic #4), S-41. **Wave 3**: items 11 (with critic #19's mapping rules), 12, 13, 18, 22, 23, plus two new items: imported bookmarks become pinned tabs and folders (critic #3) and sidebar backups/export/restore sharing item 11's file format (critic #7). **Wave 4** (needs an ADR first): 15, 16 (the ADR must say a registry Space can carry a profile id, critic #9), 17. Reason: wave 1 settles the hunks the M-sized items pile onto (IsChildVisible, the colour mixer, the accelerator tables) and gives every later item one place to record a divergence; wave 2 is the model work the other specs cite (selection, splits, the command bar's action variant); wave 3 needs rows from waves 1–2 (the importer records home URLs through H1, the archive needs Clear inside SpaceModel through B20, the hidden address row needs actions mode); wave 4 changes ownership (a profile-level registry, popups as little windows, OTR gating in browser_window_features.cc) and starts with an ADR. The three backlog rows S-41, S-42, S-43 had no owner in the synthesis (critic #11); they have one now.

**D2 — ⌘L opens the command bar (K12).** ⌘L opens the bar prefilled with the page URL selected; Escape returns to the page; the address row stays as the page's top (the operator's round-5 design, ARC-ROUND2 round 5 #5) and a click on its URL text also opens the bar. Item 18's T9 (a floating omnibox pill summoned by hover or ⌘L) is dropped; T8, T10 and T11 stay. Reason: critic #2. PRODUCT §3 says the bar "opens targeting the current tab's URL" on ⌘L and that there is no always-visible URL bar at 1.0; items 1 and 18 were both built around ⌘L staying on the omnibox, so T9 was work 1.0 would delete. The skipped "Cleaned URL bar" and "Add new tab urlbar icon" also hinged on this route.

**D3 — Multi-select is one cross-cutting rule.** When more than one row is selected (⌘-click, ⇧-click), every verb acts on the selection (close, pin, move to Space, sleep, mute, move to folder, archive) and menus show plurals ("Close 3 Tabs"); rename is the exception. The rule is written once (R6-20) and each item's spec cites it instead of restating it. Reason: critic #4. PRODUCT §12 lists multi-select as [1.0]; item 6's menu showed no plurals and items 1, 2 (⌘D), 5, 7 and 12 all said "the active tab"; TabMenuModel already reads selection_model() (tab_menu_model.cc:111), so the cost is in the specs, not the model.

**D4 — ⌘D on an essential is a no-op; Space chords are off where there are no Spaces.** ⌘D on an essentials (Chromium-pinned) tab does nothing and the menu row is disabled; ⌃1–9, ⇧⌘K and the Space commands are disabled in private and popup windows. Reason: critic #13. B21 said nothing about the essentials tier while F8 already refuses folders for pins; a no-op with a disabled row is the answer that loses nothing. Popup windows have no Spaces (B14) and private windows will have none (V2), so the controller must say so or the chords act on a model that is not there.

**D5 — ⌃1–⌃9 and Mission Control: no remap.** ⌃1–⌃9 collide with macOS Mission Control "Switch to Desktop N" once a second desktop exists. The Spaces menu rows (B23) make the chords discoverable and reachable when macOS eats them, and the shortcut reference notes the collision (Z3); nothing is remapped now. Reason: critic #12. Arc ships the same chords and its users hit the same collision; remapping is PRODUCT §12 [1.0] and out of round 6 (Z5).

**D6 — Item 1 details.** ⇥ with text typed filters that text to actions (Arc), ⇧⇥ goes back; Escape in actions mode returns to tabs mode and a second Escape closes; private and popup windows list Chromium's actions only; a row whose target is absent (Move to Space for an essential, a peek open) is hidden; dropdown preferences appear as cycling rows ("Archive after: 12 hours ▸"). Reason: critic #16. K8–K11 covered the empty-bar entry only; "one on/off row per stedding.* preference" could not express the archive hours, sleep minutes or density dropdowns.

**D7 — Row numbers (item 4).** Essentials cards show the number in a corner badge, the collapsed rail beside the icon; a split row counts as one; sleeping rows are numbered like the rest. Reason: critic #17. R11 placed the badge in the close-button slot, which essentials cards (a grid) and the collapsed rail do not have; the split and sleeping cases were unsaid.

**D8 — Pinned lifecycle (item 8).** A click on a drifted essential activates it and the reset appears on hover (Arc); ⌘W on the last visible tab of a Space that holds only pins sleeps it and the Space shows its new-tab row (B4): intended. Reason: critic #18. An essentials card is icon-only, so H5's "favicon column" is the whole card and a click would have reset instead of activated. The critic's unsure line asks for a side-by-side check in Arc before H5/H10 are written; H10 records that check as the first step.

**D9 — Arc import (item 11).** Split-view items become split rows, archived items go to the archive (item 13), the per-Space profile binding is dropped and named in the import summary; the importer reads a copy of the file and warns if Arc is running; windowTheme maps to the nearest Stedding swatch; favorites are capped at 12; a second import is idempotent, keyed by Arc's item id. Reason: critic #19. Arc's sidebar JSON holds those three item kinds beyond tabs, lists and containers; Arc rewrites the file while running; nothing in the tree caps essentials.

**D10 — Extension actions, the media button and page info when the row is hidden (item 18).** They live in the command bar's actions mode; ⌘E cycles extension actions as PRODUCT §12 says; page info opens from the URL text in the bar. Reason: critic #20. T8 removes the row those controls sit in; Arc parks extensions in its sidebar; with D2 the bar is where the URL text is, so page info follows it.

**D11 — Not implementing now.** This document is the hand-off. Implementation follows `docs/AGENT-LOOP.md` per item (spec row → failing test → build → capture → patch), one new patch per wave-1/2 item family with numbering continuing from 0016, and fixups only into the round-6 patches. Reason: `docs/HANDOFF.md` trap 8 (the 2026-09-04 fold: an autosquash into an old patch conflicted, the abort left the branding stash unpopped and every later build made `Chromium.app`) and the round-5 fold itself (commit `d307cc6`, `git log --grep='round 5'`): fixups into the old patches conflicted with later patches touching the same lines, so that round became one new patch; a round-6 patch has no such history.

## Waves

Ids are `R6-NN` in wave order. Plan-item numbers (1–24) are the synthesis's; the map:

| Plan item | Id | | Plan item | Id | | Plan item | Id |
|---|---|---|---|---|---|---|---|
| 1 | R6-11 | | 2 | R6-02 | | 3 | R6-12 |
| 4 | R6-13 | | 5 | R6-04 | | 6 | R6-14 |
| 7 | R6-15 | | 8 | R6-16 | | 9 | R6-03 |
| 10 | R6-17 | | 11 | R6-22 | | 12 | R6-23 |
| 13 | R6-24 | | 14 | R6-18 | | 15 | R6-30 |
| 16 | R6-31 | | 17 | R6-32 | | 18 | R6-25 |
| 19 | R6-05 | | 20 | R6-06 | | 21 | R6-07 |
| 22 | R6-26 | | 23 | R6-27 | | 24 | R6-08 |

Effort is the synthesis's (S/M/L). "Source" names the mod or idea and the judges' average
over three scores (Appendix C). Status is `planned` for every row until its test is green.

### Wave 1 — small, high value, no ADR

| Id | Name | Source | Effort | Setting | Shortcut | Status |
|---|---|---|---|---|---|---|
| R6-01 | Shortcut reference block in chrome://settings/stedding | critic #6 (QUALITY.md "UX completeness" 1, ROADMAP.md M6 scope) | S | a "Shortcuts" block (no preference) | none (it lists them) | planned |
| R6-02 | Arc's keyboard for Spaces | idea "Arc's keyboard for Spaces" (judges 8.67, build×3) | S (M with the Spaces menu) | none | ⌃1–9; ⌥⌘←/→; ⌥⌘↑/↓; ⇧⌘K; ⌘D; ⌥⇧⌘←/→ | planned |
| R6-03 | Close glyph only on hover or focus (Arc's active row) | mod "Only Close On Hover" (judges 7.33, build×3); Improved Collapsed Tabs' rail rule (R3); the audio-badge bug from Bigger Mute Button, Audio Indicator Enhanced and Audio TabIcon Plus (critic #8) | S | none | none | planned |
| R6-04 | ⇧⌘C copies a clean link, ⌥⇧⌘C a Markdown link with a rich-text twin | idea "⇧⌘C copies the URL, ⌥⇧⌘C copies a Markdown link with a rich-text twin, and the bar says Copied" (judges 6.67, build×2, maybe×1) + idea "Copy clean link on Shift-Cmd-C, Markdown on Option-Shift-Cmd-C" (judges 6.67, skip×1, build×2), merged; Zen Context Menu's tracking strip | S | stedding.copy.strip_tracking | ⇧⌘C; ⌥⇧⌘C | planned |
| R6-05 | No ring around split panes | mod "NoHighlightSplit" (judges 6.33, build×3) | S | none | none | planned |
| R6-06 | Card-native link status pill and find bar colours | mod "Floating Status Bar" (judges 5.67, skip×1, build×2); mod "Better Find Bar" (judges 5, skip×1, maybe×1, build×1): the mixer mapping and edge alignment; idea "Card-native find bar and link status" (judges 5.67, build×1, maybe×2): the pill; the find-bar reposition and the three-way setting dropped; Custom Statusbar (critic #33) | S | none | ⌘F | planned |
| R6-07 | Capture toast on Chromium's toast framework (S-40) | mod "smaller zen toast popup" (judges 6, build×3); backlog S-40 | S | none | none | planned |
| R6-08 | Motion follows the system | idea "Motion follows the system" (judges 5.67, build×2, maybe×1) | S | stedding.ui.animate | none | planned |
| R6-09 | About page version label (S-43) | backlog S-43 (round 5 audit, 2026-09-04) | S | none | none | planned |
| R6-10 | Space colour on the welcome flow (S-42) | backlog S-42; mod "Zen Colored Picker" (judges 5.33, build×1, maybe×1, skip×1): the five-swatch part | S | welcome step 3 swatches | none | planned |

#### Wave 1 — landing notes (2026-09-04)

Decisions taken while implementing, where the rows above left room or the tree
said otherwise. Each is also in the item's spec.

- **R6-01.** The model (`stedding::ShortcutReference()`) lives beside its handler in
  `chrome/browser/ui/webui/settings/stedding_shortcuts_handler.cc`, Mac-only, and reads
  chords through `GetDefaultMacAcceleratorForCommandId` (both Mac tables, one call). The
  peek's ⌘O / ⇧⌘O are view accelerators, not commands, so they moved into
  `chrome/browser/ui/views/peek/peek_accelerators.h` and the model reads them from there.
  One divergence row carries a literal chord: ⇧⌘D, which Stedding binds to nothing (B21).
  The "Show keyboard shortcuts" ⌘T action waits for R6-11 as planned.
- **R6-02.** Chromium's Mac build bound pane focus to ⌥⌘↑/↓ only; those keys now traverse
  tabs, so F6 / ⇧F6 were added for pane focus, as on the other platforms (B19 says so).
  `SpaceModel::SetSpacePinned` moves a newly pinned tab under the Clear line itself, so
  the context menu and ⌘D share one path. The Spaces menu's pin row reads "Pin Tab in
  This Space", shows a check while pinned and is disabled on an essential
  (`BrowserNativeWidgetMac::ValidateUserInterfaceItem`, B28). `spaces::SpaceCommandState`
  keeps Space N enabled only while N Spaces exist (B23) through a callback into the
  command updater. Strings for the menu bar needed real ids: `chrome/app/stedding_strings.grdp`
  is the one part for every Stedding string (HANDOFF trap 9).
- **R6-03.** The rules are pure functions (`stedding_tab_row_rules.cc`), tested as
  `TabRowRulesTest.*`; the layout asks them. The close slot is reserved on every expanded
  row, not only the active one, so no row's title ever re-elides on hover. The badge is the
  alert indicator at the card's bottom-right corner, 2 DIP in; click-to-mute keeps
  upstream's width rule.
- **R6-04.** `chrome::CopyURL` now routes through `stedding::CopyLink`, so the app menu,
  the tab menu and ⇧⌘C all strip and toast. The Markdown twin writes the text plus an
  anchor through `ScopedClipboardWriter::WriteHyperlink`. Title: the page title, else the
  host. Inside a peek both chords copy the peek's page (the peek view owns them).
- **R6-07.** Placement (critic #21): Chromium's anchor stays, top-centre of the page card,
  straddling the bar/card seam; Arc's bottom placement would need a second anchor view and
  is not worth a hunk in `ContentsContainerView` now. A toast's colours come from the
  dialog surface; the "Show in Finder" action reveals the last saved capture.
- **R6-08.** `stedding::ShouldAnimate(prefs)` gates `BrowserAnimationController` (every
  sidebar motion), the toast's entry and exit, and the tab hover card; the hover card's
  gate is static in upstream, so it honours the system and the capture parameter but not
  the preference. The welcome page's two CSS transitions follow `prefers-reduced-motion`.
- **R6-09.** `tooling/build-chromium` writes `stedding_version = "<VERSION>"` into
  `args.gn`; a buildflag header carries it; the About line keeps the "(arm64)" suffix.
- **Live checks, 2026-09-05.** ⌃2, ⌥⌘→/←, ⌘D and ⇧⌘K verified through `tooling/drive`
  (Space 2 activated, the pin moved under the Clear line, Clear kept the pin). ⇧⌘C could not
  be verified by keystroke on the operator's Mac: the clipboard manager Maccy owns ⇧⌘C as a
  global hotkey there, so the chord never reaches any browser (Arc's ⇧⌘C loses the same way).
  Copy Link was verified through the File menu instead (the link came back stripped). The
  chord stays ⇧⌘C for Arc parity; the copy-link spec records the collision.
- **The card gutter (operator, 2026-09-05 01:10).** "Make sure the distance from the top to
  the address bar is the same as the right and bottom borders, and a little smaller": one
  parameter, `card_gutter` (6 DIP, was 8 at the right and bottom and 0 at the top), insets the
  card on three sides and moves the address row down by it; the find bar follows.
- **T7 (toolbar).** Landed with wave 1: `PageBarColorSupplier` on the window's colour key.
  Verified live in light mode: a page with a dark `theme-color` turns the row dark with light
  icons and URL text; example.com keeps a light row with dark icons.
- **R6-10.** The welcome page is not a tab, so `stedding::WelcomeHost` (WebContents user
  data set by the dialog) is how its handler reaches the window's `SpaceModel`; the five
  colours moved to `chrome/browser/ui/spaces/space_colors.h` so the switcher and the flow
  share them. Step 5 gained ⌃1–9, ⌘D/⇧⌘K and ⇧⌘C rows and the link to the reference.

- **Gutter follow-up (2026-09-05, morning).** The first build put the address row 12 DIP
  down with its bottom 6 DIP clipped: `CalculateTopContainerLayout` lays the toolbar out
  in the top container's own coordinates, so insetting `visual_client_area` at the top
  moved both the container and the toolbar inside it (the same double offset the strip
  inset already corrected for x). The container now starts at the window's top edge and
  grows by the gutter. The 1 DIP line between the row and the page
  (`MultiContentsView`'s top separator, `kColorToolbarContentAreaSeparator`) is off under
  the Stedding card: it ran across the gutters as a light hairline on the mat. Measured
  on `tooling/probes/window.json` (23 probes): row from y=6, page from y=38, mat 6 DIP on
  the left, right and bottom, no line.
- **The plus glyphs (operator, 2026-09-05 01:15).** "Replace the + sign too, looks too
  small and weird now." The New Tab row and the switcher's new-Space button drew a text
  "+"; both are `vector_icons::kAdd2Icon` now (the wider Material plus; `kAddIcon` from
  `chrome/app/vector_icons` has shorter arms), the row's at the favicon size in the
  favicon column, the switcher's at the chip glyph size plus 2, both in the row/label
  secondary colour.
- **Seen on the way.** With Google chosen on the welcome flow's first step the new tab
  page becomes Chromium's first-party page (Google logo, Gmail/Images, "Customize
  Stedding"), not the local third-party page S-21 promised for every provider. Logged as
  S-45; not part of round 6.

- **Live checks, 2026-09-05 (second pass, every wave-1 surface).** Through
  `tooling/drive` with the operator away: the link status pill inside the card (U1), the
  hovered row's close glyph and the active row without one (R1), a playing essentials
  card's corner badge in dark and light (R18), ⌥⇧⌘→ moving the tab and following it
  (B22), the Spaces menu with Space 7–9 disabled past the count (B23), the shortcut
  reference in dark and light with the divergence rows and the Mission Control note
  (Z1–Z3), settings search finding it and the welcome link opening it (Z4), the About
  line in both modes (T10), the ⌘F bubble in dialog colours at the card's right edge in
  both modes (U3–U4), a split with no Material ring (U6, U8), the capture toast (C5) and
  the "Link copied, tracking removed" toast (L5), github.com in light mode with a dark
  row and light icons (T4/T7), the welcome swatches (W7's UI). Three things the pass
  found: the reference named ⇧⌘] against "Focus the next pane" because `ChordFor`
  returns the menu's binding first (fixed: divergence and tab rows read the table's
  ⌥⌘↓/↑ through `TableChordFor`, with a test); choosing a swatch on a fresh profile
  tinted nothing, because the ground only took a Space colour once a second Space
  existed (spaces B31: a chosen colour tints a lone Space too, `Space::color_chosen`,
  persisted); and ⌥⌘N from the harness never reached the window, which was not key on
  the two-URL runs (grey traffic lights) — the Tab menu path opened the split, so the
  harness, not the chord, is suspect (HANDOFF trap 10).
- **Motion O2 stays partial.** Two shots 80 ms apart after ⌘S or ⇧⌘2 were identical in
  every mode: neither the strip collapse nor the toast shows an intermediate frame at
  the harness's sampling, so the capture cannot tell the gate. The gate is unit-tested
  (`MotionTest`) and the call sites are reviewed; a frame-level proof needs a faster
  capture path.

#### Wave 2 — landing notes (2026-09-05, in progress)

- **Order of landing.** Parts A–E of the wave went into the checkout together on
  2026-09-05 after wave 1's commit: R6-13 R10 (⌘1–9 skip hidden rows), R6-14 M5–M6
  (Close Others / Clear Below stay inside the Space; the tab-group chords are gone),
  R6-15 R4–R6, R8 (the slept look, Sleep Tab / Sleep Others, a Space sleeps 15 minutes
  after the user leaves it, the dropdown), R6-21 T14 (download progress on the sidebar
  button), R6-20 R20–R22 (verbs act on the selection, plural labels), R6-16 H1–H9 (the
  home URL, ⌘W sleeps a pin, the drifted dot, favicon reset, the menu rows, peek reads
  the stored site), R6-17 R14–R17 (rename in place: `stedding::TabName` on the
  WebContents, preferred by `TabUIHelper::GetTitle()`, written as session extra data
  and re-emitted on rebuild), R6-14 M1, M4 (the short menu is a separate
  `TabMenuModel::BuildStedding`, so a rebase cannot leak a hidden row into it).
- **Parts F and G, same night.** R6-13 R11–R13, R19: a `ui::EventMonitor` on the
  window watches the ⌘ key (modifier-only presses never reach a view); 250 ms later
  every visible row shows its number in the close slot (cards and the rail: a corner
  badge, the pure rule `NumberBadgePlacementFor`), the Space chips show ⌃N in place of
  their glyph, an 80 ms fade under the motion gate, any chord or the key-up hides
  them; `stedding::NumberedTabs` is the one list ⌘N and the badges share. R6-18: at
  overflow (`SwitcherOverflows`, the same metrics the row uses) the inactive chips are
  6 DIP dots in their Space colour until the pointer rests on the row; Move Left /
  Move Right on the Space menu reorder through `SpaceModel::MoveSpace`, persisted
  with the Spaces; the chip drag (B27's pointer path) is a later pass.
- **Live checks, 2026-09-05 (05:15–05:35).** The short menu with every disabled row
  greyed for the row it opened on (M1); rename in place with the field over the title
  (R14); ⌘-click selection with plural labels (R20–R21); the row numbers, the card's
  corner number and ⌃N on the chips while ⌘ is held, gone on release (R11, R19); a
  slept row at 55 % (R4); the drifted pin's dot and the favicon reset (H4–H5); twelve
  Spaces as dots that grow back under the pointer (B24–B25); the four new settings
  rows (R8, R12, M4, H9). Four things the pass taught: a right-click activates the row
  it opens on, so Sleep Tab now takes the active row after activating the nearest
  visible neighbour (R5 reworded); the switcher only hears hover on its children
  with `SetNotifyEnterExitOnChild`; an off-site link on a pin peeks (P1) rather than
  drifting it, so the drift check uses a same-site link; and the machine's input
  source reached the harness's typing (HANDOFF trap 13). The sidebar's own
  background menu (Chromium's: Bookmark All Tabs…, Unpin Tab Search, Turn off Auto
  Expanding Tabs) is untouched — a row for R6-14 M3's pass.
- **Part H, R6-11 (actions mode), the same morning.** The bar gains a second mode:
  ⇥ in the bar, a leading ">", or ⇧⌘P (`IDC_STEDDING_COMMAND_PALETTE`, in the
  not-in-main-menu table and the shortcut reference). The list is Stedding's verbs
  first — Move Tab to <Space> (one row per other Space, none for an essentials tab),
  Pin/Unpin to This Space, Move Tab to New Folder, Sleep Tab, Clear This Space,
  Next/Previous Space, New Space, the three captures, Copy Link (plain and Markdown),
  Collapse or Expand the Sidebar, Show Keyboard Shortcuts, one on/off row per boolean
  preference and one cycling row per dropdown (K17) — then every visible, enabled
  item of `BrowserActions`' registry with its label and chord. Chords for Stedding's
  rows come from the window's accelerator provider (the BrowserView; tests inject
  one). ⌘L opens the bar with the page URL selected (K12); Escape leaves actions
  mode, a second Escape closes (K14); private and popup windows list Chromium's
  actions only (K15). Not yet: "Archive idle tabs now" (the archiver has no window
  accessor), "Rename tab" from the bar (the row's view is the strip's), the
  address-row click of K12, and extension actions (K11 covers later commands).
  The live check found two things the unit tests could not: the field must claim
  ⇥/⇧⇥ from the Mac focus manager (HANDOFF trap 15) and the panel must resize on
  every rebuild path; both fixed, ⌘T-then-⇥ shows seven rows with a scroll
  indicator, ⌘L shows the URL selected. Patch 0022; 18 bar and shortcut tests.
- **Part I, R6-12 (⌃⇥), the same morning.** `SpaceModel` keeps an activation
  history per Space (X1); ⌃⇥ / ⌃⇧⇥ walk the five most recent tabs of the active
  Space through `spaces::CycleRecentTab` ahead of Chromium's `kCtrlTabMru` (off),
  a tap is one step (X2), a ⌃ held past 150 ms shows the strip — a layered child
  of the BrowserView with favicon, title and the Space's colour per cell, the
  position highlighted; ⌃ up commits, Escape cancels, a mouse press or a key
  without ⌃ commits (X3). ⌥⇧⌘↑/↓ move the row within its container: a row inside
  a folder stays inside, a folder beside a row is jumped as one row, and moves
  that touch no folder keep Chromium's group rules, so its tests stay green (X4).
  The setting `stedding.tabs.ctrl_tab_mru` (on) returns ⌃⇥ to strip order when
  off (X5); the shortcut reference lists the four chords and the divergence; the
  bar carries "Go to the Most Recent Tab". The recent list counts a split once
  (splits J2, the ⌃⇥ half). Patch 0023.
- **Not in this pass.** R6-14 M2, M3, M7 (page and app menus; the five row-kind
  menus), R6-15 R7 (folder dim), R6-16 H10–H11, R6-19's other J rows, B27's
  drag, T14's download capture. Each keeps its row.

#### R6-01 · Shortcut reference block in chrome://settings/stedding

- Source: critic #6 (QUALITY.md "UX completeness" 1, ROADMAP.md M6 scope).
- Effort: S.
- Setting: a "Shortcuts" block (no preference).
- Shortcut: none (it lists them).
- Spec: docs/features/shortcuts.md (new; Z series).

| Id | Behaviour | Test | State |
|---|---|---|---|
| Z1 | chrome://settings/stedding carries a "Shortcuts" block listing every Stedding chord and every Chromium chord Stedding remaps, built from the accelerator tables (accelerators_cocoa.mm, global_keyboard_shortcuts_mac.mm, accelerator_table.cc) at startup, never hand-typed; it is the "in-product shortcut reference" QUALITY.md and ROADMAP.md cite and nothing implements today (critic #6: only the two citations exist). | a unit test that every IDC_STEDDING_* command with an accelerator appears in the block's model; capture, dark and light | planned · draft |
| Z2 | Every remapped Chromium chord has a divergence row: the chord, what Chromium binds it to, what Stedding binds it to (⌘S/⇧⌘S from round 5; ⌘D, ⇧⌘C, ⌥⌘↑/↓, ⇧⌘K, ⇧⌘D and later chords from the items below). Items record divergences here, not in QUALITY.md. | the model test asserts the divergence set; each item that remaps a chord adds its row in its own patch | planned · draft |
| Z3 | A note row records that ⌃1–⌃9 collide with macOS Mission Control "Switch to Desktop N" once a second desktop exists (D5). | model test; capture | planned · draft |
| Z4 | The block is found by settings search ("shortcuts") and, once R6-11 lands, by the ⌘T action "Show keyboard shortcuts"; welcome step 5 (W6) links to it. | live: settings search; ⌘T | planned · draft |
| Z5 | Remapping (PRODUCT §12 "Keyboard shortcut customisation" [1.0]) is out of scope for round 6; the block is read-only. | spec row | planned · draft |

Rows drafted by the orchestrator from the critic's text; confirm each against Arc before its failing test.

Files: chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/ui/webui/settings/ (a handler that walks the accelerator provider); chrome/browser/ui/cocoa/accelerators_cocoa.mm and chrome/browser/global_keyboard_shortcuts_mac.mm (read only); docs/features/shortcuts.md (new); docs/QUALITY.md and docs/ROADMAP.md keep their citations.

Patch: new (D11); the first round-6 patch since every later item cites it.

Conflicts: R6-02, R6-04, R6-25 add divergence rows; R6-11 adds the ⌘T action.

From the critic: #6 (this item), #12 (Z3), #29 (whether the mac-only tables are deliberate is TBD and belongs in Z2's wording).

#### R6-02 · Arc's keyboard for Spaces — plan item 2

- Source: idea "Arc's keyboard for Spaces" (judges 8.67, build×3).
- Effort: S (M with the Spaces menu).
- Setting: none (the judges dropped the 'Use Arc's shortcuts' fallback toggle: the accelerator tables are static singletons; the divergences go in the shortcut reference instead).
- Shortcut: ⌃1–⌃9 Space N; ⌥⌘←/→ previous/next Space; ⌥⌘↑/↓ previous/next tab (was IDC_FOCUS_PREVIOUS/NEXT_PANE at global_keyboard_shortcuts_mac.mm:158-159); ⇧⌘K Clear; ⌘D Pin to This Space (was IDC_BOOKMARK_THIS_TAB, accelerators_cocoa.mm:56); ⌥⇧⌘←/→ move tab one Space over.
- Spec: docs/features/spaces.md (B18–B23, B28–B30).
- Selection: the multi-select rule R6-20 (D3) applies to every verb here; the spec cites it and does not restate it. ⌘D and ⌥⇧⌘←/→ act on the selection.

| Id | Behaviour | Test | State |
|---|---|---|---|
| B18 | ⌃1…⌃9 activate Space N in switcher order (SpaceModel::SetActiveSpace(spaces()[n-1]->id())); N past size() is a no-op. | SpaceModelTest.SetActiveSpaceByIndexIgnoresOutOfRange, a command-controller test that IDC_STEDDING_SPACE_9 is disabled with three Spaces. | planned |
| B19 | ⌥⌘← / ⌥⌘→ activate the previous / next Space through SwitchToNeighbour (no wrap, same path as the swipe B15); tab traversal moves to ⌥⌘↑ / ⌥⌘↓ (⇧⌘] / ⇧⌘[ kept), F6 keeps pane focus. | SpaceModelTest.SwitchToNeighbour* (exists); live: tooling/drive key ⌥⌘→ then read the switcher. | planned |
| B20 | ⇧⌘K runs Clear on the active Space through SpaceModel::ClearUnpinnedTabs, the collector moved out of VerticalTabStripRegionView::ClearCurrentSpaceTabs so the line and the key share one path; Space-pinned tabs survive. | SpaceModelTest.ClearUnpinnedTabsKeepsPins. | planned |
| B21 | ⌘D toggles Pin to This Space (CommandSpacePin/Unpin); Bookmark This Tab and Bookmark All Tabs keep their menu rows and lose their chords (recorded in the QUALITY.md shortcut reference as a deliberate divergence: pinned tabs replace bookmarks, PRODUCT §1). | SpaceWindowTest.CmdDTogglesSpacePin. | planned |
| B22 | ⌥⇧⌘← / ⌥⇧⌘→ move the active tab one Space over and follow it (SetSpaceForTab then SetActiveSpace). | SpaceWindowTest.MoveTabToNeighbourSpaceFollowsIt. | planned |
| B23 | A "Spaces" menu in the menu bar lists Next Space, Previous Space, Clear This Space and Space 1…Space 9 with their chords (static items in main_menu_builder.mm; the controller enables Space N only when N ≤ size()). | capture of the menu; welcome step 5 and the settings hint list ⌃1–9 and ⇧⌘K. | planned |
| B28 | ⌘D on an essentials (Chromium-pinned) tab is a no-op and the menu row is disabled (D4; F8 refuses folders for pins the same way). | SpaceWindowTest.CmdDOnAnEssentialIsANoOp; TabMenuModelTest row state | planned · D4 |
| B29 | ⌃1–⌃9, ⇧⌘K, ⌥⌘←/→, ⌥⇧⌘←/→ and the Spaces menu rows are disabled in private and popup windows (no Spaces there: B14, V2). | a command-controller test on a TYPE_POPUP browser (the PopupSpaceTest fixture) and on an off-the-record browser | planned · D4 |
| B30 | ⌃1–⌃9 collide with macOS Mission Control "Switch to Desktop N" once a second desktop exists; the Spaces menu (B23) keeps the commands reachable and the shortcut reference notes it (Z3); no remap in round 6 (D5). | spec row; Z3 | planned · D5 |

Rows B18, B19, B20, B21, B22, B23 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: chrome/app/chrome_command_ids.h (IDC_STEDDING_SPACE_1..9, _SPACE_NEXT, _SPACE_PREVIOUS, _CLEAR_SPACE, _TOGGLE_SPACE_PIN, _MOVE_TAB_TO_NEXT/PREVIOUS_SPACE after 55102; mirror in chrome/browser/ui/actions/chrome_action_id.h per the LINT.ThenChange); chrome/browser/global_keyboard_shortcuts_mac.mm (lines 129-130, 158-159); chrome/browser/ui/cocoa/accelerators_cocoa.mm (line 56, 104); chrome/browser/ui/browser_command_controller.cc; chrome/browser/ui/spaces/space_model.h/.cc (new ClearUnpinnedTabs); chrome/browser/ui/views/frame/vertical_tab_strip_region_view.cc (ClearCurrentSpaceTabs ~1422 becomes a call); chrome/browser/ui/cocoa/main_menu_builder.mm; chrome/browser/ui/spaces/space_model_unittest.cc, space_model_window_unittest.cc; chrome/browser/resources/stedding_welcome/app.ts (step 'keys'); docs/features/spaces.md; docs/QUALITY.md (shortcut reference).

Patch: new (D11); the synthesis pointed at: Patch 0004 (model) and 0013 (keys). Fixups go into round-6 patches only.

Conflicts: 1 (command ids, controller, mac shortcut table), 3 and 4 (same two accelerator files and browser_command_controller.cc), 5 (chrome_command_ids.h, accelerators_cocoa.mm), 8 (space_model.h/.cc, CommandSpacePin), 18 (accelerators_cocoa.mm ⇧⌘D).

From the critic: #12 (D5, B30), #13 (D4, B28–B29), #29 (mac tables only: TBD, see R6-01), #6 (B21's divergence row goes to Z2, not QUALITY.md).

#### R6-03 · Close glyph only on hover or focus (Arc's active row) — plan item 9

- Source: mod "Only Close On Hover" (judges 7.33, build×3); Improved Collapsed Tabs' rail rule (R3); the audio-badge bug from Bigger Mute Button, Audio Indicator Enhanced and Audio TabIcon Plus (critic #8).
- Effort: S.
- Setting: none (Arc's default).
- Shortcut: none.
- Spec: docs/features/tabs.md (new; R1–R3, R18).

| Id | Behaviour | Test | State |
|---|---|---|---|
| R1 | Under stedding::kArcStyleWindow the close button is laid out only while the row is hovered or its close button has keyboard focus; the active row carries no permanent glyph (today IsChildVisible returns active_ \|\| hovered_or_focused at tab_view_vertical_layout.cc:192). Confirmed against the Arc reference by side-by-side capture before the change. | TabViewVerticalLayoutTest.ActiveUnhoveredHidesClose, HoveredShowsClose, FocusedShowsClose. | planned |
| R2 | The close slot stays reserved on the active row so the title does not re-elide when the glyph appears. | TabViewVerticalLayoutTest.TitleWidthUnchangedByHover. | planned |
| R3 | Essentials cards and the collapsed rail never show the close glyph (⌘W and the menu close). | TabViewVerticalLayoutTest.PinnedAndCollapsedNeverShowClose. | planned |
| R18 | A playing or muted essentials card keeps its favicon and shows the alert as a corner badge (today TabViewVerticalLayout::IsChildVisible hides icon_ while the alert shows, so a playing essential loses its site icon); a click on the badge mutes; a right-click on a silent tab's row offers Mute Site (CommandToggleSiteMuted); the badge works on a split row (PRODUCT §1 "Audio indicator and mute" [1.0]). | TabViewVerticalLayoutTest.PlayingEssentialKeepsItsFavicon; live: tooling/drive on a page with audio, capture in dark and light | planned · critic #8 |

Rows R1, R2, R3 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: chrome/browser/ui/views/tabs/common/tab_view_vertical_layout.cc (IsChildVisible 173-192); chrome/browser/ui/views/tabs/common/tab_view.cc (UpdateHovered already invalidates layout); a unit test beside chrome/browser/ui/views/tabs/common/tab_view_browsertest.cc; docs/features/tabs.md.

Patch: new (D11); the synthesis pointed at: Patch 0013. Fixups go into round-6 patches only.

Conflicts: 7 (same IsChildVisible hunk for the slept row), 4 (the ⌘-held badge takes this slot), 23 (row metrics).

From the critic: #8 (R18, folded here by D1 instead of a later fixup), #30 (capture both modes with a probe).

#### R6-04 · ⇧⌘C copies a clean link, ⌥⇧⌘C a Markdown link with a rich-text twin — plan item 5

- Source: idea "⇧⌘C copies the URL, ⌥⇧⌘C copies a Markdown link with a rich-text twin, and the bar says Copied" (judges 6.67, build×2, maybe×1) + idea "Copy clean link on Shift-Cmd-C, Markdown on Option-Shift-Cmd-C" (judges 6.67, skip×1, build×2), merged; Zen Context Menu's tracking strip.
- Effort: S.
- Setting: chrome://settings/stedding toggle 'Copy links without tracking parameters' (stedding.copy.strip_tracking, on).
- Shortcut: ⇧⌘C copy URL (from IDC_DEV_TOOLS_INSPECT; ⌥⌘C keeps Inspect); ⌥⇧⌘C copy as Markdown (unbound in Chromium).
- Spec: docs/features/copy-link.md (new; L1–L6).
- Selection: the multi-select rule R6-20 (D3) applies to every verb here; the spec cites it and does not restate it. The plural form of a copy (one line per selected tab, or the active tab only) is TBD.

| Id | Behaviour | Test | State |
|---|---|---|---|
| L1 | ⇧⌘C copies the page URL; ⌥⌘C keeps Inspect Element (both chords map to IDC_DEV_TOOLS_INSPECT today, global_keyboard_shortcuts_mac.mm:156-157), recorded in the shortcut reference. | an accelerator-table test that ⇧⌘C resolves to IDC_COPY_URL. | planned |
| L2 | Tracking parameters are removed before the copy when the setting is on: utm_*, fbclid, gclid, dclid, msclkid, mc_eid, mc_cid, igshid, _hsenc, _hsmi, mkt_tok, yclid, twclid, ref_src, and si on youtube.com; the table lives in one file. Never applied to navigation. | CleanLinkTest.StripsEachFamily, CleanLinkTest.KeepsUnknownParameters. | planned |
| L3 | ⌥⇧⌘C (IDC_STEDDING_COPY_MARKDOWN_LINK) writes `[title](clean url)` as text and an anchor as HTML on the same pasteboard, so Slack, Notion and Docs paste a live link. | CopyUrlTest.PlainMarkdownAndHtmlFlavours reads the clipboard. | planned |
| L4 | Both appear in the tab context menu (CommandCopyURL exists; a Markdown sibling joins it), the app menu and the command bar. | TabMenuModelTest row set (item 6). | planned |
| L5 | Chromium's ToastId::kLinkCopied confirms; it reads 'Link copied, tracking removed' when something was stripped. | live capture through tooling/drive. | planned |
| L6 | Setting off copies the URL verbatim. | CopyUrlTest.SettingOffCopiesVerbatim. | planned |

Files: chrome/app/chrome_command_ids.h (IDC_COPY_URL 34071; new IDC_STEDDING_COPY_MARKDOWN_LINK; mirror in chrome_action_id.h); chrome/browser/global_keyboard_shortcuts_mac.mm (156-157); chrome/browser/ui/cocoa/accelerators_cocoa.mm; chrome/browser/ui/browser_command_controller.cc (IDC_COPY_URL case 1485); chrome/browser/ui/browser_commands.cc (CopyURL); new chrome/browser/ui/stedding/clean_link.h/.cc + unittest; chrome/browser/ui/tabs/tab_menu_model.cc; chrome/browser/ui/toasts/api/toast_id.h (kLinkCopied, existing); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; new docs/features/copy-link.md.

Patch: new (D11); the synthesis pointed at: Patch 0013 plus a new privacy patch shared with item 22. Fixups go into round-6 patches only.

Conflicts: 2 (chrome_command_ids.h, accelerators_cocoa.mm, global_keyboard_shortcuts_mac.mm, browser_command_controller.cc), 6 (tab_menu_model.cc), 21 (toast style), 1 (action rows).

From the critic: #24 (⇧⌘C inside a peek, the Markdown title's source, L5's anchor in a peek: TBD, decide in the spec before the failing test), #6 (L1's divergence row goes to Z2).

#### R6-05 · No ring around split panes — plan item 19

- Source: mod "NoHighlightSplit" (judges 6.33, build×3).
- Effort: S.
- Setting: none.
- Shortcut: none.
- Spec: docs/features/page.md (new; U6–U8).

| Id | Behaviour | Test | State |
|---|---|---|---|
| U6 | kColorMultiContentsViewActiveContentOutline and kColorMultiContentsViewInactiveContentOutline map in stedding_color_mixer.cc to the row-text tint at 0x18 (the selected-row value) so light, dark and Space tint follow; Arc draws no ring, and the page-coloured bar (T3) says which pane is active. | a probe on a split capture (tooling/probes/window.json, a split case) at the pane edge: no Material outline luma. | planned |
| U7 | The 3 px highlight (ContentsContainerOutline::UpdateState(is_active, is_highlighted)) stays for the drag-and-drop target only. | existing split browsertests unchanged. | planned |
| U8 | The inactive pane's mini toolbar is captured against Arc in the same pass and left alone unless it clashes (a separate row if it changes). | capture. | planned |

Files: chrome/browser/ui/color/stedding_color_mixer.cc; chrome/browser/ui/views/frame/contents_container_outline.h/.cc (UpdateState 41); chrome/browser/ui/views/frame/contents_container_view.cc (UpdateBorderAndOverlay 199); chrome/browser/ui/views/frame/multi_contents_view.cc (SetHighlightActiveContentsView, patched in 0002); tooling/probes/window.json; new docs/features/page.md.

Patch: new (D11); the synthesis pointed at: Patch 0007. Fixups go into round-6 patches only.

Conflicts: 17, 20, 21 (stedding_color_mixer.cc).

From the critic: #30 (a split capture, dark and light, with the probe U6 names).

#### R6-06 · Card-native link status pill and find bar colours — plan item 20

- Source: mod "Floating Status Bar" (judges 5.67, skip×1, build×2); mod "Better Find Bar" (judges 5, skip×1, maybe×1, build×1): the mixer mapping and edge alignment; idea "Card-native find bar and link status" (judges 5.67, build×1, maybe×2): the pill; the find-bar reposition and the three-way setting dropped; Custom Statusbar (critic #33).
- Effort: S.
- Setting: none.
- Shortcut: ⌘F (existing).
- Spec: docs/features/page.md (U1–U5).

| Id | Behaviour | Test | State |
|---|---|---|---|
| U1 | In Stedding mode the link status bubble is a pill inside the card: inset 8 DIP from the card's left and bottom edges, radius = height/2 on all four corners (StatusView::OnPaint drops the per-corner special-casing and kBubbleCornerRadius 4), background and text from kColorStatusBubble* mapped in stedding_color_mixer.cc to the card surface and secondary text, a hairline in the toolbar-separator tint. Chromium's slide-away-from-the-mouse (kMousePadding) and expand-on-hover stay. | a hovered-link probe in tooling/probes/window.json (tooling/drive hovers a link, shot): pill luma at the inset, card corner still rounded beneath. | planned |
| U2 | The pill never touches the card edge at any window size, including immersive fullscreen. | capture at 1400×880 and in ⌃⌘F. | planned |
| U3 | kColorFindBarBackground / Foreground / MatchCount / ButtonIcon* map to the dialog colours the command bar uses (K6), so the ⌘F bubble follows light, dark and the Space tint instead of GM3 grey. | a colour probe on a ⌘F capture, dark and light. | planned |
| U4 | The find bubble's right edge aligns with the content card's right edge (BrowserView::GetFindBarBoundingBox inset by the 8 DIP gutter, T2). | probe. | planned |
| U5 | No position, width, checkbox or hide settings: Arc has one placement for each and shows the hovered link. | spec row. | planned |

Files: chrome/browser/ui/views/status_bubble_views.cc (StatusView::OnPaint 485, Reposition 802, GetPreferredHeight 824, kBubbleCornerRadius 67, kMousePadding 71); chrome/browser/ui/color/stedding_color_mixer.cc (kColorStatusBubble* and kColorFindBar* ids from chrome/browser/ui/color/chrome_color_id.h 204-209, 927-931); chrome/browser/ui/views/find_bar_view.cc; chrome/browser/ui/views/find_bar_host.cc (GetDialogPosition); chrome/browser/ui/views/frame/browser_view.cc (GetFindBarBoundingBox 1200); chrome/browser/ui/stedding_ui_metrics.h/.cc (a status-bubble inset param); tooling/probes/window.json; docs/features/page.md.

Patch: new (D11); the synthesis pointed at: Patches 0002 and 0007. Fixups go into round-6 patches only.

Conflicts: 17, 19, 21 (stedding_color_mixer.cc), 18 (the find bar anchors under a row that can now be hidden: U4 must handle the zero-height container).

From the critic: #33 (Custom Statusbar closes here: the knobs are dropped, U1 is the one look), #30 (hovered-link and ⌘F captures in both modes), #20 (R6-25 hides the row; the synthesis's conflict note, not the critic, says U4 must handle the zero-height container).

#### R6-07 · Capture toast on Chromium's toast framework (S-40) — plan item 21

- Source: mod "smaller zen toast popup" (judges 6, build×3); backlog S-40.
- Effort: S.
- Setting: none.
- Shortcut: none.
- Spec: docs/features/screenshot.md (C5–C7).

| Id | Behaviour | Test | State |
|---|---|---|---|
| C5 | closed as: after ⇧⌘2 / ⌥⇧⌘2 / ⇧⌘1 a toast reads 'Copied · Saved to Downloads' with an action 'Show in Finder', raised from the shared ending in screenshot_capture.cc (clipboard, then Downloads) through a new ToastId registered in toast_service.cc (ToastSpecification::Builder(icon, body) + AddActionButton + AddCloseButton); a thumbnail rides in the icon slot if the specification's image model allows it, else the capture icon. | live: tooling/drive ⇧⌘2, shot within 2 s shows the toast; none after 6 s. | planned |
| C6 | ToastView's colours are overridden in stedding_color_mixer.cc so the toast matches the window (dialog colours, text-tinted, readable in light and dark); hover pauses the dismiss (Chromium's behaviour). This is the one style for every later Stedding toast (D4's undo, L5's confirmation). | colour probe on the capture. | planned |
| C7 | No toast for a ⌘-clicked link: the sidebar row is the feedback, as in Arc. | spec row. | planned |

Files: chrome/browser/ui/toasts/api/toast_id.h; chrome/browser/ui/toasts/api/toast_specification.h (Builder 22, AddActionButton 36, AddCloseButton 31); chrome/browser/ui/toasts/toast_service.cc (the registration list at 86-134); chrome/browser/ui/toasts/toast_controller.h (MaybeShowToast 105, GetAnchorView 158); chrome/browser/ui/toasts/toast_view.cc; chrome/browser/ui/stedding/screenshot/screenshot_capture.cc (the shared ending at 78); chrome/browser/ui/color/stedding_color_mixer.cc; docs/features/screenshot.md (C5–C7); BACKLOG.md (S-40 to Done).

Patch: new (D11); the synthesis pointed at: Patch 0014 and 0007. Fixups go into round-6 patches only.

Conflicts: 12 (D4's undo toast wants this style), 5 (L5 reuses kLinkCopied and this style), 17, 19, 20 (stedding_color_mixer.cc).

From the critic: #21 (placement: Chromium anchors top-centre under the toolbar, Arc bottom-centre of the content; TBD, decide once before C6 declares the style for every later toast, and R6-25 removes the anchor view), #34 (thumbnail and "Show in Finder" are in C5; Arc's bottom placement is the #21 question).

#### R6-08 · Motion follows the system — plan item 24

- Source: idea "Motion follows the system" (judges 5.67, build×2, maybe×1).
- Effort: S.
- Setting: chrome://settings/stedding toggle 'Animate the sidebar and overlays (follows macOS Reduce Motion)' (stedding.ui.animate, on).
- Shortcut: none.
- Spec: docs/features/motion.md (new; O1–O3).

| Id | Behaviour | Test | State |
|---|---|---|---|
| O1 | One helper, stedding::ShouldAnimate(): false when gfx::Animation::PrefersReducedMotion() or the preference is off; every Stedding animation (the ⌃⇥ strip fade X3, the ⌘-badge fade R11, the toast, a future peek slide or command bar fade) is gated by it and its spec row says so. | a unit test on the helper under both inputs. | planned |
| O2 | Upstream's expand-on-hover animation (AnimateExpandOnHover), hover-card fade and strip collapse take the same gate in the Stedding window. | a capture parameter SteddingArcStyleWindow:reduce_motion/true proves the still path (two shots 80 ms apart identical). | planned |
| O3 | Setting off stills the browser regardless of macOS; on follows macOS Reduce Motion. | SteddingPrefsTest default; live toggle. | planned |

Note (synthesis): Lands with the first Stedding animation (item 3 or 4), not as a standalone patch.

Files: new chrome/browser/ui/stedding/motion.h/.cc + unittest; ui/gfx/animation/animation.h (ShouldRenderRichAnimation 81, PrefersReducedMotion 102, read only); chrome/browser/ui/views/frame/vertical_tab_strip_region_view.h (AnimateExpandOnHover 247); chrome/browser/ui/views/peek/peek_view.cc; chrome/browser/ui/views/commandbar/command_bar_view.cc; chrome/browser/ui/views/spaces/space_switcher_view.cc; chrome/browser/ui/stedding_ui_metrics.h/.cc (reduce_motion param); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; new docs/features/motion.md; docs/QUALITY.md.

Patch: new (D11); the synthesis pointed at: Patch 0013 plus 0010. Fixups go into round-6 patches only.

Conflicts: 3, 4, 21 (their fades call the helper), 14 (space_switcher_view.cc), 22 and 23 (settings page, prefs).

From the critic: none directly; the "cut-off-only hover card" rule from the skipped "One motion setting" idea is noted for a later pass.

#### R6-09 · About page version label (S-43)

- Source: backlog S-43 (round 5 audit, 2026-09-04).
- Effort: S.
- Setting: none.
- Shortcut: none.
- Spec: docs/features/settings.md (T10; settings.md and toolbar.md each have a T series already, so R6-25's T10 is toolbar's and this one is settings'; an existing collision, not this plan's to fix).

| Id | Behaviour | Test | State |
|---|---|---|---|
| T10 | chrome://settings/help reads "Stedding <VERSION> · Chromium <pin>" with no "(Developer Build)" modifier; `VERSION` and `tooling/chromium-version` are the sources (today the modifier comes from Chromium's channel string for non-official builds). | a unit test on the version-string formatter; capture of the About page, dark and light | planned · draft |

Rows drafted by the orchestrator from the backlog row (critic #11 named it ownerless); confirm against Arc before the failing test.

Files: chrome/browser/ui/webui/settings/ (the About page's version string; find the seam that reads the channel string) and the branding strings; docs/features/settings.md; BACKLOG.md (S-43 to Done).

Patch: new (D11).

Conflicts: none.

From the critic: #11 (no owner in the plan; this row is the owner).

#### R6-10 · Space colour on the welcome flow (S-42)

- Source: backlog S-42; mod "Zen Colored Picker" (judges 5.33, build×1, maybe×1, skip×1): the five-swatch part.
- Effort: S.
- Setting: welcome step 3 swatches.
- Shortcut: none.
- Spec: docs/features/welcome.md (W7 closed).

| Id | Behaviour | Test | State |
|---|---|---|---|
| W7 | closed as: step 3 (appearance) shows the five Space swatches the switcher menu offers (kNewSpaceColors) and choosing one tints the first Space at once through SpaceModel::SetSpaceColor; Skip leaves the default. No colour pad (HANDOFF trap 6 rules out the BubbleDialogDelegateView subclass the mod would need). | live: tooling/drive <fresh> --stedding-welcome, choose the third swatch, read the sidebar-ground probe (B11's tint); SteddingWelcomeHandler unit test for the message | planned · D1 |

Rows drafted by the orchestrator from the backlog row (critic #11 named it ownerless); confirm against Arc before the failing test.

Files: chrome/browser/resources/stedding_welcome/app.ts (step "appearance"); chrome/browser/ui/webui/stedding_welcome/stedding_welcome_handler.cc; chrome/browser/ui/views/spaces/space_switcher_view.cc (kNewSpaceColors, read only); docs/features/welcome.md; BACKLOG.md (S-42 to Done).

Patch: new (D11); the synthesis pointed at 0015.

Conflicts: R6-02 and R6-13 also edit welcome step 5 (a different step).

From the critic: #11 (owner; the Zen Colored Picker skip says five swatches is the ask).

### Wave 2 — the model work the specs cite

| Id | Name | Source | Effort | Setting | Shortcut | Status |
|---|---|---|---|---|---|---|
| R6-11 | Command bar actions mode (⇥ after ⌘T, or ⇧⌘P) | idea "Command bar actions mode" (judges 9, build×3) | M | none | ⇥ in an empty ⌘T bar; ⇧⌘P; ⌘L (D2) | planned |
| R6-12 | ⌃⇥ most-recent switcher with a hold-to-see strip | idea "⌃⇥ most-recent switcher with a hold-to-see strip, and Arc's ⌥⌘↑/↓ travel keys" (judges 7.33, build×3); mod "Better CtrlTab Panel" (judges 5.33, skip×1, maybe×2), merged | M | stedding.tabs.ctrl_tab_mru | ⌃⇥ / ⌃⇧⇥; ⌥⌘↑/↓; ⌥⇧⌘↑/↓ | planned |
| R6-13 | ⌘1–9 count what you can see; hold ⌘ to see row numbers | idea "Hold ⌘ to see row numbers, and ⌘1–9 that count what you can see" (judges 7, build×3); mod "Tab Numbers" (judges 5.33, skip×1, maybe×2), merged | M (the fix alone is S and ships first) | stedding.sidebar.hold_cmd_numbers | ⌘1–9; ⌘ held | planned |
| R6-14 | Context menus with Stedding's verbs first and Google's gone | idea "Context menus with Stedding's verbs first and Google's gone" (judges 6.67, build×3); mods Zen Context Menu and Cleaner Bookmark Menu, merged | M | stedding.menus.short | none new | planned |
| R6-15 | Sleeping tabs: one unloaded look, 'Sleep' as a verb, per tab and per Space | idea "Sleeping tabs" (judges 7, build×3); mods Better Tab Indicators, Tab title fixes, Ghost Tabs, Better Unloaded Tabs, merged | M | stedding.spaces.sleep_minutes | none; ⌘T "Sleep tab" | planned |
| R6-16 | Arc's pinned-tab lifecycle: a home URL, ⌘W sleeps, the favicon resets | idea "Arc's pinned-tab lifecycle" (judges 8.33, build×3); idea "Pinned tabs have a home" (judges 6.33, maybe×2, build×1): "Set pinned URL to this page" and the hover-card line merged, the thumbnail dropped; mods Hidden Reset Button, No pinned tab reset btn, Only Reset On Hover, Remove Tab X part (a), merged | M | stedding.pins.close_sleeps | ⌘W on a pinned row | planned |
| R6-17 | Inline tab rename that survives restore | idea "Inline tab rename that survives restore" (judges 7.33, build×3); idea "Rename a tab in place" (judges 6, skip×1, build×1, maybe×1), merged: the TabUIHelper placement chosen over a SpaceModel map | M | none | double-click; ⌘T "Rename tab" | planned |
| R6-18 | Space switcher overflow: inactive chips shrink to dots | mod "Hide Inactive Workspaces" (judges 6.33, build×2, maybe×1) | M | none | none | planned |
| R6-19 | Splits as a unit (splits.md) | critic #5 (PRODUCT §4 "Split View"); ARC-ROUND2 round 5 #8 and peek P9 for what exists | S (spec and tests; the model is Chromium 153's split view) | none | none new | planned |
| R6-20 | Multi-select rule | D3; critic #4 (PRODUCT §12 "Multi-select tabs" [1.0]); TabMenuModel already reads selection_model() (tab_menu_model.cc:111) | S | none | ⌘-click, ⇧-click | planned |
| R6-21 | Download progress on the sidebar button (S-41) | backlog S-41 (toolbar; round 5 item 12) | S | none | none | planned |

#### R6-11 · Command bar actions mode (⇥ after ⌘T, or ⇧⌘P) — plan item 1

- Source: idea "Command bar actions mode" (judges 9, build×3).
- Effort: M.
- Setting: none.
- Shortcut: ⇥ in an empty ⌘T bar; ⇧⌘P (unbound in Chromium on mac; the tab-group chords ⌃⌘C/P/W/X/Z, global_keyboard_shortcuts_mac.mm:166-174, are untouched; the synthesis and critic #14 wrote ⌥⌘ for them, but the entries set command_key and cntrl_key in global_keyboard_shortcuts_mac.h).
- Spec: docs/features/commandbar.md (K8–K17).
- Selection: the multi-select rule R6-20 (D3) applies to every verb here; the spec cites it and does not restate it. Move to Space, Pin/Unpin, Sleep and Move to Folder rows act on the selection.

| Id | Behaviour | Test | State |
|---|---|---|---|
| K8 | In an empty bar, ⇥ (or a leading ">") switches to actions mode: rows are commands, not tabs; ⇧⌘P opens the bar already in actions mode. | CommandBarViewTest.TabFiltersToActions, CommandBarViewTest.ShiftCmdPOpensInActionsMode. | planned |
| K9 | The action list is Chromium's own registry (every ActionItem under BrowserActions::root_action_item() with text, icon, accelerator) plus Stedding's rows: Move tab to <Space> (one row per SpaceModel::spaces()), Pin/Unpin to This Space, Move to New Folder, Clear this Space, Archive idle tabs now (TabArchiver::Sweep), Capture page/region/full document, Toggle sidebar, New Space, Rename tab, and one on/off row per stedding.* preference. | CommandBarViewTest.ActionRowsListSpacesAndCaptures. | planned |
| K10 | Rows fuzzy-match on label; the accelerator is drawn at the right of the row from the window's AcceleratorProvider; Enter runs chrome::ExecuteCommand or ActionItem::InvokeAction. | CommandBarViewTest.MoveToSpaceRowMovesTheTab (asserts through SpaceModel::SpaceForTab), CommandBarViewTest.ActionRowsCarryAccelerators. | planned |
| K11 | Every later feature that adds a command adds its row here; the empty actions state reads "No matching command" (never a blank panel). | capture, dark and light. | planned |
| K12 | ⌘L opens the bar prefilled with the page URL, selected; Escape returns to the page unchanged; a click on the address row's URL text opens the bar the same way. The address row stays the page's top (the operator's round-5 design, ARC-ROUND2 round 5 #5); the K7 row says that Enter navigates this tab (the cue the skipped "Add new tab urlbar icon" asked for). | CommandBarViewTest.CmdLPrefillsTheUrlSelected; live: ⌘L, Escape, URL unchanged | planned · D2 |
| K13 | ⇥ with text already typed filters that text against actions (Arc); ⇧⇥ returns to tabs mode with the text kept. | CommandBarViewTest.TabWithTextFiltersActions | planned · D6 |
| K14 | Escape in actions mode returns to tabs mode; a second Escape closes the bar. | CommandBarViewTest.EscapeLeavesActionsModeThenCloses | planned · D6 |
| K15 | In private and popup windows the actions list holds Chromium's actions only: no Space, pin, folder or archive rows (B14, V2). | a CommandBarViewTest on a TYPE_POPUP browser | planned · D6 |
| K16 | A row whose target is absent is hidden: Move to Space for an essentials tab, tab-scoped rows while a peek is open. | CommandBarViewTest.RowsWithoutATargetAreHidden | planned · D6 |
| K17 | A dropdown preference appears as one cycling row ("Archive after: 12 hours ▸"): Enter advances to the next value and the row re-reads. | CommandBarViewTest.DropdownPrefRowCycles | planned · D6 |

Rows K8, K9, K10, K11 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: chrome/browser/ui/views/commandbar/command_bar_view.h (Result gains an action variant); chrome/browser/ui/views/commandbar/command_bar_view.cc (UpdateResults, RebuildRows, GoTo); chrome/browser/ui/views/commandbar/command_bar_view_unittest.cc; chrome/browser/ui/browser_actions.h (root_action_item); chrome/browser/ui/actions/chrome_action_id.h; chrome/browser/ui/browser_command_controller.cc; chrome/browser/ui/spaces/space_model.h; chrome/browser/ui/archive/tab_archiver.h (Sweep); chrome/browser/global_keyboard_shortcuts_mac.mm (⇧⌘P); docs/features/commandbar.md.

Patch: new (D11); the synthesis pointed at: Patch 0005. Fixups go into round-6 patches only.

Conflicts: Every item below that adds a command-bar action (2, 3, 4, 5, 7, 8, 10, 11, 12, 13, 24) lands its row through this Result variant; items 2 and 5 also edit global_keyboard_shortcuts_mac.mm and browser_command_controller.cc.

From the critic: #2 (D2, K12), #16 (D6, K13–K17), #20 (D10: extension actions, the media button and page info live here when the row is hidden, R6-25 T13), #32 ("New Documents" as a ⌘T action: not taken into round 6, no decision), #31 (VoiceOver role and keyboard path for the actions list: name them in the spec before "built").

#### R6-12 · ⌃⇥ most-recent switcher with a hold-to-see strip — plan item 3

- Source: idea "⌃⇥ most-recent switcher with a hold-to-see strip, and Arc's ⌥⌘↑/↓ travel keys" (judges 7.33, build×3); mod "Better CtrlTab Panel" (judges 5.33, skip×1, maybe×2), merged.
- Effort: M.
- Setting: chrome://settings/stedding toggle '⌃⇥ cycles the most recently used tabs' (stedding.tabs.ctrl_tab_mru, on).
- Shortcut: ⌃⇥ / ⌃⇧⇥ (accelerator_table.cc:91-93, IDC_CYCLE_TO_NEXT/PREVIOUS_TAB); ⌥⌘↑/↓ and ⌥⇧⌘↑/↓ (bound with item 2).
- Spec: docs/features/switcher.md (new; X1–X5).
- Selection: not affected (⌃⇥ activates one tab).

| Id | Behaviour | Test | State |
|---|---|---|---|
| X1 | SpaceModel keeps an activation history per Space (a closed tab leaves it; a Space switch scopes it); ⌃⇥ / ⌃⇧⇥ walk the five most recent tabs of the active Space, essentials included; Chromium's kCtrlTabMru stays off (it is global across windows and would activate Space-hidden tabs, breaking B7). | SpaceModelTest.ActivationHistoryIsPerSpace, SpaceWindowTest.CtrlTabWalksRecentTabsOfTheActiveSpace (beside NextTabSkipsOtherSpaces). | planned |
| X2 | A tap switches to the previous tab silently. | SpaceWindowTest.CtrlTabTapGoesToPreviousTab. | planned |
| X3 | Holding ⌃ past 150 ms shows a strip of up to five favicon+title cells (Space colour dot) over the content, a layered child of BrowserView like the command bar, in the theme's dialog colours; ⇥/⇧⇥ move the highlight, releasing ⌃ commits, Escape cancels. The ⌃-release detection (flagsChanged arriving as a modifier key event) is prototyped first. | RecentTabsSwitcherViewTest.ReleaseCommitsEscapeCancels; live: tooling/drive holds the key, shot, releases. | planned |
| X4 | ⌥⌘↑ / ⌥⌘↓ select the previous / next visible row (SelectRelativeTab already skips hidden tabs); ⌥⇧⌘↑ / ⌥⇧⌘↓ move the active row within its container, folder-aware (MoveTabRelative). | TabStripModelTest.MoveTabRelativeStaysInsideItsFolder. | planned |
| X5 | Setting off returns ⌃⇥ to sidebar order (IDC_CYCLE_TO_NEXT_TAB as today). | SpaceWindowTest.CtrlTabSettingOffUsesStripOrder. | planned |

Files: chrome/browser/ui/spaces/space_model.h/.cc (history beside last_active_); chrome/browser/ui/browser_commands.cc (CycleToMruTab 1525, GetGlobalMruTab 495 left alone; a Stedding path); chrome/browser/ui/browser_command_controller.cc (IDC_CYCLE_TO_NEXT_TAB); chrome/browser/ui/tabs/tab_strip_model.cc (SelectRelativeTab 4155, MoveTabRelative 4196); new chrome/browser/ui/views/switcher/recent_tabs_switcher_view.h/.cc modelled on chrome/browser/ui/views/commandbar/command_bar_view.cc; chrome/browser/global_keyboard_shortcuts_mac.mm; chrome/browser/ui/accelerator_table.cc; chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/ui/spaces/space_model_unittest.cc, space_model_window_unittest.cc; new docs/features/switcher.md.

Patch: new (D11); the synthesis pointed at: Patch 0004 (history) plus a new switcher patch. Fixups go into round-6 patches only.

Conflicts: 2 (accelerator files, browser_command_controller.cc, space_model), 4 (browser_commands.cc, space_model_window_unittest.cc), 24 (the strip's fade goes through the motion gate), 1 (a 'Switch to recent tab' action row).

From the critic: #23 (a split is one cell: R6-19 J2; tabs inside collapsed folders, ⌃⇥ while a peek or the bar is open, and a tap-only fallback if flagsChanged never reaches Views: TBD in the spec before X3's prototype), #30 (strip capture, dark and light, with a probe), #31 (VoiceOver role for the strip: TBD).

#### R6-13 · ⌘1–9 count what you can see; hold ⌘ to see row numbers — plan item 4

- Source: idea "Hold ⌘ to see row numbers, and ⌘1–9 that count what you can see" (judges 7, build×3); mod "Tab Numbers" (judges 5.33, skip×1, maybe×2), merged.
- Effort: M (the fix alone is S and ships first).
- Setting: chrome://settings/stedding toggle 'Show row numbers while ⌘ is held' (stedding.sidebar.hold_cmd_numbers, on).
- Shortcut: ⌘1–⌘9 (existing, IDC_SELECT_TAB_0.. and IDC_SELECT_LAST_TAB); ⌘ held alone shows the badges; ⌃1–9 badges reuse item 2's chords.
- Spec: docs/features/tabs.md (R10–R13, R19).
- Selection: not affected (⌘N activates one row).

| Id | Behaviour | Test | State |
|---|---|---|---|
| R10 | chrome::SelectNumberedTab and SelectLastTab skip TabStripModel::IsTabHidden tabs (Space predicate, collapsed folders) and count in sidebar order: essentials, the Space-pinned run, then the rest; ⌘9 is the last visible tab. Today IsTabSelectable (browser_commands.cc:549) never asks IsTabHidden, so ⌘2 in Space B can activate a tab of Space A. | SpaceWindowTest.NumberedTabSkipsOtherSpaces, SpaceWindowTest.LastTabIsLastVisible (hidden tabs first in the strip). | planned |
| R11 | Holding ⌘ for 250 ms shows a 1–9 badge in the close-button slot of the first nine visible rows and a ⌃N badge on each Space chip; the badges fade in over 80 ms (motion gate, item 24) and vanish on key-up; favicons never move. Modifier-only presses reach the strip through a ui::EventMonitor on the browser widget. | TabViewVerticalLayoutTest.NumberBadgeTakesTheCloseSlotWhileCmdIsHeld; live: tooling/drive holds ⌘, shot, releases. | planned |
| R12 | Setting off leaves the fix (R10) and removes the badges. | SteddingPrefsTest default; live toggle. | planned |
| R13 | Welcome step 5 and the settings hint list ⌘1–9. | capture. | planned |
| R19 | Essentials cards show the number in a corner badge and the collapsed rail beside the icon; a split row counts as one number (R6-19 J2); sleeping rows are numbered like the rest (D7). | TabViewVerticalLayoutTest.NumberBadgeOnCardsAndRail; capture of the grid, the rail and a split, dark and light | planned · D7 |

Rows R10, R11, R12, R13 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: chrome/browser/ui/browser_commands.cc (SelectNumberedTab 1548, SelectLastTab 1569, IsTabSelectable 549); chrome/browser/ui/tabs/tab_strip_model.h (IsTabHidden 520); chrome/browser/ui/spaces/space_model_window_unittest.cc; chrome/browser/ui/views/tabs/common/tab_view_vertical_layout.cc (close slot); chrome/browser/ui/views/tabs/common/tab_view.cc; chrome/browser/ui/views/spaces/space_switcher_view.cc; chrome/browser/ui/views/frame/vertical_tab_strip_region_view.cc (event monitor); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/resources/stedding_welcome/app.ts; new docs/features/tabs.md.

Patch: new (D11); the synthesis pointed at: Patch 0004 (fix) and 0013 (badges). Fixups go into round-6 patches only.

Conflicts: 3 (browser_commands.cc, space_model_window_unittest.cc), 7 and 9 (tab_view_vertical_layout.cc close slot), 14 (space_switcher_view.cc), 24 (fade), 2 (welcome step 5).

From the critic: #17 (D7, R19), #1 (the Close Others fix is M5 in R6-14, not here), #30 (badge captures), #31 (badges are visual only; the chord is the keyboard path).

#### R6-14 · Context menus with Stedding's verbs first and Google's gone — plan item 6

- Source: idea "Context menus with Stedding's verbs first and Google's gone" (judges 6.67, build×3); mods Zen Context Menu and Cleaner Bookmark Menu, merged.
- Effort: M.
- Setting: chrome://settings/stedding toggle 'Short context menus (hide Chromium's sync, Google and AI items)' (stedding.menus.short, on).
- Shortcut: none new; the menu shows item 2's, 5's and 7's chords.
- Spec: docs/features/menus.md (new; M1–M7).
- Selection: the multi-select rule R6-20 (D3) applies to every verb here; the spec cites it and does not restate it. M7 carries the plural labels.

| Id | Behaviour | Test | State |
|---|---|---|---|
| M1 | Tab menu order: Pin to This Space / Add to Essentials / Rename… / Move to Space ▸ / Move to Folder ▸ (existing folders, then New Folder) / Add to Split / Sleep Tab / Mute Site — Copy Link / Copy as Markdown — Close / Close Others / Clear Below; every item shows its chord. Send to your devices, Glic, reading list, tab groups and move-to-window are gone unless the setting says otherwise. | TabMenuModelTest.SteddingOrder asserts the exact command list for both states of the toggle, so a rebase cannot reintroduce CommandSendTabToSelf, CommandAddToReadLater or CommandGlic*. | planned |
| M2 | Page menu loses Lens, Search Google for image/video frame, Generate QR code, Reading mode and Glic; 'Search <default engine> for …' stays. | RenderViewContextMenuTest row set (a later pass if the file's size argues for it; judges accepted keeping the page menu for a second round). | planned |
| M3 | App menu loses Manage Google account, Open Glic, Send tab to self, Customize Chrome and Payment methods; gains Import…, Screenshot ▸ (the three captures) and Spaces ▸. The Bookmarks and lists submenu keeps Import Bookmarks and Settings and the manager, loses the bookmarks-bar submenu and the side-panel entry. | AppMenuModelTest.SteddingRows. | planned |
| M4 | The Chromium set returns with the toggle (on = Stedding's short menu; the row is worded so 'on' is the default per settings T2). | TabMenuModelTest.SteddingOrder (off branch). | planned |
| M5 | Close Others and Clear Below act inside the active Space and skip tabs inside collapsed folders: TabStripModel::GetIndicesClosedByCommand never asks IsTabHidden today, so both would close tabs in other Spaces (critic #1; same family as R10). | TabStripModelTest.CloseOthersStaysInsideTheSpace, TabStripModelTest.ClearBelowSkipsHiddenTabs | planned · critic #1 |
| M6 | The tab-group chords (⌃⌘C/P/W/X/Z, global_keyboard_shortcuts_mac.mm:166-174; the synthesis and critic #14 wrote ⌥⌘, but the entries set command_key and cntrl_key in global_keyboard_shortcuts_mac.h) are removed in the same hunk that hides the group rows, so a rebase cannot re-expose a hidden feature by keyboard (critic #14; item 1 called them "untouched"). | an accelerator-table test that none of the five resolves to a group command; Z2 records the removal | planned · critic #14 |
| M7 | Beyond the plain row (M1), four more menus: the essentials card (Remove from Essentials; no Move to Space, no folder), the folder header, the split row (R6-19), the Space-pinned row (Unpin, Reset to Pinned Page, Make This the Pinned Page). With a multi-selection every label takes the plural ("Close 3 Tabs", "Move 3 Tabs to ▸", R6-20). | TabMenuModelTest.SteddingOrder asserts all five command lists and the plural labels | planned · critic #15, D3 |

Rows M1, M2, M3, M4 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: chrome/browser/ui/tabs/tab_menu_model.cc (Build, ~424-500); chrome/browser/ui/tabs/tab_strip_model.h (ContextMenuCommand 794-830: new CommandMoveToSpace, CommandMoveToFolder, CommandCopyMarkdownLink, CommandSleepTab, CommandClearBelow); chrome/browser/ui/tabs/tab_strip_model.cc (ExecuteContextMenuCommand); chrome/browser/ui/views/tabs/common/tab_strip_collection_controller.cc; chrome/browser/ui/toolbar/app_menu_model.cc; chrome/browser/ui/toolbar/bookmark_sub_menu_model.cc; chrome/browser/renderer_context_menu/render_view_context_menu.cc (M2, later pass); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; new docs/features/menus.md.

Patch: new (D11); the synthesis pointed at: Patches 0001/0004/0008 fixups. Fixups go into round-6 patches only.

Conflicts: 5 (tab_menu_model.cc Copy rows), 7 (Sleep Tab row), 8 (pin rows, Reset to pinned page), 10 (Rename… row), 12 (Always open <site> in ▸ row), 2 (⌘D hint on the pin row). Land this after 5, 7, 8, 10, 12 have added their rows, or land the order first and let each add into it.

From the critic: #1 (M5), #14 (M6), #15 (M7), #4 (D3, R6-20), #34 (chords drawn in the menu plus plural verbs: M1 and M7).

#### R6-15 · Sleeping tabs: one unloaded look, 'Sleep' as a verb, per tab and per Space — plan item 7

- Source: idea "Sleeping tabs" (judges 7, build×3); mods Better Tab Indicators, Tab title fixes, Ghost Tabs, Better Unloaded Tabs, merged.
- Effort: M.
- Setting: chrome://settings/stedding dropdown 'Put a Space to sleep after leaving it: Never / 5 min / 15 min / 1 hour' (stedding.spaces.sleep_minutes, default 15; an int pref like stedding.archive.idle_hours).
- Shortcut: none; 'Sleep tab' is a ⌘T action and a context-menu row.
- Spec: docs/features/tabs.md (R4–R8).
- Selection: the multi-select rule R6-20 (D3) applies to every verb here; the spec cites it and does not restate it. Sleep Tab acts on the selection.

| Id | Behaviour | Test | State |
|---|---|---|---|
| R4 | A discarded row (TabData::is_tab_discarded) draws its favicon greyscale at 45% and its title at 55% alpha of the row's text colour (so Space tints and light mode follow) and hides the close glyph until hover; Chromium's discard ring is not drawn in the Stedding window. It returns to full strength on activation without extra plumbing (SetData → UpdateColors). | TabViewTest.DiscardedRowDimsTitleAndIcon asserts the title colour alpha on a discarded WebContents; capture of a restored session before and after loading. | planned |
| R5 | Tab context menu 'Sleep Tab' and 'Sleep Other Tabs in This Space' (new ContextMenuCommand entries beside CommandSpacePin) and matching ⌘T actions call resource_coordinator::TabLifecycleUnitExternal::DiscardTab with the external reason; the active tab is never slept. | TabStripModelTest.SleepOthersInSpaceSkipsActiveAndOtherSpaces with a fake lifecycle unit. | planned |
| R6 | 'Put a Space to sleep after leaving it' (Never / 5 min / 15 min / 1 h): a timer started from SpaceModel::Observer::OnActiveSpaceChanged, cancelled on return; essentials are exempt (SetAutoDiscardable(false)); Space-pinned tabs sleep too. | SpaceSleepTest.TimerSleepsLeftSpaceExceptEssentials. | planned |
| R7 | A folder whose every tab sleeps dims its header the same way. | capture. | planned |
| R8 | Setting: the dropdown above; the look itself has no switch (it is one visual state of the row). | SteddingPrefsTest default. | planned |

Files: chrome/browser/ui/views/tabs/tab/tab_icon.cc (SetDiscarded 167, PaintDiscardRingAndIcon 371); chrome/browser/ui/views/tabs/common/tab_view.cc (UpdateColors, SetData); chrome/browser/ui/views/tabs/common/tab_view_vertical_layout.cc (IsChildVisible 149-192 for the close glyph); chrome/browser/ui/views/tabs/vertical_tab_style_views.cc (CalculateTargetColors); chrome/browser/ui/views/tabs/common/folder_view.cc; chrome/browser/ui/tabs/tab_data.h (is_tab_discarded 62); chrome/browser/ui/tabs/tab_menu_model.cc; chrome/browser/ui/tabs/tab_strip_model.h/.cc; chrome/browser/resource_coordinator/tab_lifecycle_unit_external.h (DiscardTab 41, SetAutoDiscardable 38); chrome/browser/ui/spaces/space_model.h/.cc; chrome/browser/ui/views/commandbar/command_bar_view.cc; chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; docs/features/tabs.md.

Patch: new (D11); the synthesis pointed at: Patch 0013 plus 0004. Fixups go into round-6 patches only.

Conflicts: 8 (needs this look for a slept pinned tab: build R4 before item 8's H3), 9 and 4 (tab_view_vertical_layout.cc IsChildVisible), 6 (tab_menu_model.cc, tab_strip_model.h), 11 (the importer inserts unpinned tabs discarded, so they wear this look), 23 (tab_icon.cc, tab_view.cc).

From the critic: #27 (sleeping a tab that is in a split: R6-19 J4; the essentials card's slept look and the rail's dimmed icon: TBD rows before R4 is built; R6's timer per window vs per registry: decided with R6-31), #30 (captures both modes).

#### R6-16 · Arc's pinned-tab lifecycle: a home URL, ⌘W sleeps, the favicon resets — plan item 8

- Source: idea "Arc's pinned-tab lifecycle" (judges 8.33, build×3); idea "Pinned tabs have a home" (judges 6.33, maybe×2, build×1): "Set pinned URL to this page" and the hover-card line merged, the thumbnail dropped; mods Hidden Reset Button, No pinned tab reset btn, Only Reset On Hover, Remove Tab X part (a), merged.
- Effort: M.
- Setting: chrome://settings/stedding toggle '⌘W on a pinned tab puts it to sleep instead of closing it' (stedding.pins.close_sleeps, on).
- Shortcut: ⌘W (existing IDC_CLOSE_TAB, new semantics on pinned rows); ⌘D pins (item 2).
- Spec: docs/features/pins.md (new; H1–H11).
- Selection: the multi-select rule R6-20 (D3) applies to every verb here; the spec cites it and does not restate it. Reset to Pinned Page and Make This the Pinned Page act on the selection; ⌘W sleeps every selected pinned row.

| Id | Behaviour | Test | State |
|---|---|---|---|
| H1 | Both pin tiers record a home URL at pin time: SpaceModel::SetSpacePinned(tab, true) stores handle → GURL (space_pinned_ becomes a map), and Chromium's pinned bit flipping on (OnTabStripModelChanged) records it for essentials. | SpaceModelTest.PinRecordsHomeUrl. | planned |
| H2 | The home URL is written to per-tab session extra data beside stedding.spacepin through SessionExtraDataForTab and re-emitted by AppendRebuildCommands, so it survives a rebuilt session log (HANDOFF trap 4). | SessionRebuildTest.PinnedUrlSurvivesRebuild; live: tooling/drive quit and relaunch three times. | planned |
| H3 | ⌘W (IDC_CLOSE_TAB) on a Space-pinned or essentials tab sleeps it instead of closing (item 7's look; activation moves to the next visible row in the Space); a sleeping pinned tab is left alone; removal is Unpin. | SpaceWindowTest.CloseOnPinnedTabSleepsIt, SpaceWindowTest.CloseOnSleepingPinnedTabIsANoOp. | planned |
| H4 | When the tab's committed URL differs from home (origin or path), TabIcon paints a 5 DIP 'navigated away' dot at the favicon's corner (the attention-indicator geometry); it clears when the tab is home again. | TabIconTest.NavigatedAwayDot; capture. | planned |
| H5 | A click on the favicon column of a pinned tab (not the row) loads home; ⌥-click also reloads. | live: tooling/drive click on the favicon of a drifted pin, URL read back. | planned |
| H6 | Tab context menu 'Reset to Pinned Page' and 'Make This the Pinned Page'; both are ⌘T actions. | TabMenuModelTest row set (item 6). | planned |
| H7 | Peek reads the stored home URL's eTLD+1 as the pinned site (P2), so a drifted pin stops peeking the wrong site. | ShouldPeekTest.UsesTheStoredPinnedSite. | planned |
| H8 | The hover card of a pinned tab gains a line 'Pinned in <Space> · home <host>' (no thumbnail). | capture. | planned |
| H9 | Setting off returns ⌘W to closing (Unpin implied). | SpaceWindowTest.CloseSleepsSettingOffCloses. | planned |
| H10 | A click on a drifted essentials card activates it; the reset control appears on hover of the card (Arc), and a click on it loads home (D8). The critic's unsure line asks for a side-by-side check in Arc before H5 and H10 are written; do it first. | live: tooling/drive click on a drifted card (activates), hover, click the reset (URL read back) | planned · D8 |
| H11 | ⌘W on the last visible tab of a Space that holds only pins sleeps it and the Space shows its new-tab row (B4): intended (D8). | SpaceWindowTest.CloseOnLastPinnedTabSleepsItAndShowsTheNewTabRow | planned · D8 |

Rows H1, H2, H3, H4, H5, H6, H7, H8, H9 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: chrome/browser/ui/spaces/space_model.h (space_pinned_ 202, kSessionTabSpacePinKey 43) and .cc (SetSpacePinned 517, SessionExtraDataForTab 470, AppendRebuildCommands, OnTabStripModelChanged); chrome/browser/sessions/stedding_session_rebuild.h; chrome/browser/ui/spaces/tab_space_restore_data.h/.cc; chrome/browser/ui/browser_commands.cc (CloseTab 1415); chrome/browser/ui/browser_command_controller.cc (IDC_CLOSE_TAB 785); chrome/browser/ui/views/tabs/tab/tab_icon.cc (PaintAttentionIndicatorAndIcon 337); chrome/browser/ui/views/tabs/common/tab_view.cc; chrome/browser/ui/views/tabs/common/tab_view_vertical_layout.cc (favicon column hit test); chrome/browser/ui/tabs/tab_menu_model.cc; chrome/browser/ui/views/peek/peek_navigation_throttle.cc; chrome/browser/ui/views/tabs/hovercard/tab_hover_card_bubble_view.cc; chrome/browser/ui/spaces/space_model_unittest.cc, space_model_window_unittest.cc, session_rebuild_unittest.cc; chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; new docs/features/pins.md; docs/features/peek.md (P2 note).

Patch: new (D11); the synthesis pointed at: Patch 0004 and 0009. Fixups go into round-6 patches only.

Conflicts: 7 (the slept look, tab_icon.cc, tab_view.cc; land 7's R4 first), 2 (space_model, ⌘D), 3 (space_model.h), 6 (menu rows), 11 (the importer records savedURL as home through SetSpacePinned), 16 (space_model split into a registry later).

From the critic: #18 (D8, H10–H11), #32 ("Collapse Pinned Tabs" as a row here or in R6-02: not taken into round 6, no decision), #5 (a pinned split: R6-19 J1, J3).

#### R6-17 · Inline tab rename that survives restore — plan item 10

- Source: idea "Inline tab rename that survives restore" (judges 7.33, build×3); idea "Rename a tab in place" (judges 6, skip×1, build×1, maybe×1), merged: the TabUIHelper placement chosen over a SpaceModel map.
- Effort: M.
- Setting: none.
- Shortcut: none (double-click); 'Rename tab' in ⌘T.
- Spec: docs/features/tabs.md (R14–R17).
- Selection: rename is the exception to R6-20; it acts on the clicked row only (D3).

| Id | Behaviour | Test | State |
|---|---|---|---|
| R14 | Double-click a row's title (the favicon is the reset control, H5), the context menu 'Rename…' or the ⌘T action swaps the title for a views::Textfield in the same slot, prefilled and selected, the way FolderView::BeginRename/EndRename does; Enter commits, Escape cancels, an empty string restores the page title. | TabRenameTest.EnterCommitsEscapeCancelsEmptyRestores; live: tooling/drive double-click. | planned |
| R15 | The custom title lives in TabUIHelper (GetTitle prefers it), so the row, the hover card, the command bar and the ⌃⇥ strip read it; ⌘T matches the custom name first and the page title second. | CommandBarViewTest.MatchesCustomTitle. | planned |
| R16 | The title is written as per-tab session extra data under stedding.title and re-emitted by a rebuild provider (AddSessionRebuildProvider), so it survives a rebuilt session log. | SessionRebuildTest.TitleSurvivesRebuild. | planned |
| R17 | Names persist for every tab, whatever the tier, and survive pin/unpin; essentials keep theirs for the hover card. | TabRenameTest.NameSurvivesPinToggle. | planned |

Files: chrome/browser/ui/views/tabs/common/folder_view.cc (BeginRename 157, EndRename 166, the pattern); chrome/browser/ui/views/tabs/common/tab_view.cc (UpdateTitle ~1080-1089); chrome/browser/ui/views/tabs/tab/tab_title.cc; chrome/browser/ui/tab_ui_helper.h (GetTitle 55); chrome/browser/ui/tabs/tab_menu_model.cc; chrome/browser/ui/tabs/tab_strip_model.h (ContextMenuCommand); chrome/browser/sessions/stedding_session_rebuild.h; chrome/browser/ui/spaces/tab_space_restore_data.h (per-tab extra-data pattern); chrome/browser/ui/views/commandbar/command_bar_view.cc; docs/features/tabs.md.

Patch: new (D11); the synthesis pointed at: Patch 0013 plus the session-rebuild registry (0004). Fixups go into round-6 patches only.

Conflicts: 6 (tab_menu_model.cc, tab_strip_model.h), 8 (extra data and rebuild provider, tab_view.cc), 1 and 3 (command bar and switcher read the title), 23 (tab_title.cc).

From the critic: #25 (a split renames as a unit: R6-19 J1; rename from ⌘T while the sidebar is collapsed, and telling the user that an essentials rename only reaches the hover card: TBD rows before R14 is built), #30 (textfield capture, dark and light), #31 (keyboard path: the ⌘T action; VoiceOver role of the textfield: TBD).

#### R6-18 · Space switcher overflow: inactive chips shrink to dots — plan item 14

- Source: mod "Hide Inactive Workspaces" (judges 6.33, build×2, maybe×1).
- Effort: M.
- Setting: none (always on).
- Shortcut: none.
- Spec: docs/features/spaces.md (B24–B27).
- Selection: not affected.

| Id | Behaviour | Test | State |
|---|---|---|---|
| B24 | When the chips (24 DIP, kChipGap 12) would exceed the row, inactive chips shrink to 6 DIP dots in their Space colour while the active chip keeps its glyph; the '+' and downloads button never move. Confirm against the Arc reference first (unsure whether Arc collapses to dots at overflow; fix the dot size after the capture). | SpaceSwitcherViewTest.OverflowShrinksInactiveChips on measured widths at 352 and 126 with 12 Spaces. | planned |
| B25 | Hovering the row grows them back while the pointer is there, with no layout shift outside the row; the name pill and the swipe (B15) keep working. | SpaceSwitcherViewTest.HoverRestoresChipsWithinTheRow; live capture at 12 Spaces. | planned |
| B26 | Below the overflow threshold nothing changes (B11 holds). | existing B11 capture unchanged. | planned |
| B27 | A Space chip dragged along the row reorders the switcher; the Space menu offers Move Left / Move Right as the keyboard path (SpaceModel gains MoveSpace); the order persists (B9) and ⌃N follows it (B18). PRODUCT §2 [1.0]; critic #10. | SpaceModelTest.MoveSpaceReordersAndPersists; live: tooling/drive drags a chip past its neighbour, reads the switcher | planned · critic #10 |

Rows B24, B25, B26 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: chrome/browser/ui/views/spaces/space_switcher_view.cc (Rebuild 168, kChipGap 47) and .h; chrome/browser/ui/views/tabs/vertical/vertical_tab_strip_bottom_container.cc (row host); new chrome/browser/ui/views/spaces/space_switcher_view_unittest.cc beside space_drag_target_unittest.cc; docs/features/spaces.md.

Patch: new (D11); the synthesis pointed at: Patches 0004 and 0013. Fixups go into round-6 patches only.

Conflicts: 4 (⌃N badges on the chips), 12 (the Space menu in space_switcher_view.cc), 11 (a 16-Space import hits this at once: land before or with 11), 17 (no chips in private windows).

From the critic: #10 (B27), #34 (the name pill on a dot hover, not only on chips: part of B25), #30 (12-Space capture, dark and light).

#### R6-19 · Splits as a unit (splits.md)

- Source: critic #5 (PRODUCT §4 "Split View"); ARC-ROUND2 round 5 #8 and peek P9 for what exists.
- Effort: S (spec and tests; the model is Chromium 153's split view).
- Setting: none.
- Shortcut: none new.
- Spec: docs/features/splits.md (new; J series).

| Id | Behaviour | Test | State |
|---|---|---|---|
| J1 | A split is one row in the sidebar and one unit for the sidebar's verbs: it pins, Space-pins, renames (R6-17) and restores as one row, both pages coming back paired. | SplitRowTest.PinRenameAndRestoreKeepThePair (name TBD) | planned · draft |
| J2 | ⌘1–9 (R6-13 R19) and the ⌃⇥ strip (R6-12 X3) count a split as one; activating it activates the pane that was last active. | SpaceWindowTest.NumberedTabCountsASplitOnce; RecentTabsSwitcherViewTest.SplitIsOneCell | planned · draft |
| J3 | ⌘W on a split: TBD. Check first what Chromium 153 does to the other pane, then decide whether a pinned split's pane sleeps instead (R6-16 H3) and record it here before H3 is built. | TBD | planned · draft |
| J4 | Move to Space, Sleep and ⌘D act on both panes together (the split is one selection under R6-20). | SpaceWindowTest.MoveToSpaceMovesBothPanes; TabStripModelTest.SleepAppliesToBothPanes | planned · draft |
| J5 | A Space-pinned tab that joins a split leaves the pinned run for the split's row (noted, not changed, in the round-5 audit): keep or fix is TBD; the answer is a row here. | TBD | planned · draft |
| J6 | No ring around the panes (R6-05 U6–U7); Chromium's split browsertests stay green. | existing split browsertests; the U6 probe | planned · draft |

Rows drafted by the orchestrator from the critic's text; confirm each against Arc before its failing test.

Files: docs/features/splits.md (new); chrome/browser/ui/views/tabs/common/split_tab_view.cc (read first: CalculateVerticalLayout); chrome/browser/ui/tabs/tab_strip_model.h; the tests named by R6-12, R6-13, R6-16 and R6-20; docs/features/peek.md (P9 cites J1).

Patch: no patch of its own: each J row lands in the item that implements it (R6-12, R6-13, R6-16, R6-17, R6-20).

Conflicts: R6-12, R6-13, R6-15, R6-16, R6-17, R6-20, R6-23 all cite a J row.

From the critic: #5 (this spec; J1, J3), #23 (J2), #25 (J1), #27 (J4).

#### R6-20 · Multi-select rule

- Source: D3; critic #4 (PRODUCT §12 "Multi-select tabs" [1.0]); TabMenuModel already reads selection_model() (tab_menu_model.cc:111).
- Effort: S.
- Setting: none.
- Shortcut: ⌘-click, ⇧-click.
- Spec: docs/features/tabs.md (R20–R22).

| Id | Behaviour | Test | State |
|---|---|---|---|
| R20 | ⌘-click adds a row to the selection and ⇧-click extends it (Chromium's selection model); a selected row keeps the round-5 selected tint; a selection never spans Spaces because hidden rows cannot be selected. | existing Chromium selection tests; capture | planned · D3 |
| R21 | With more than one row selected, every verb acts on the selection: close, pin and unpin (both tiers), Move to Space, Move to Folder, Sleep, Mute, archive, Copy Link (form TBD, R6-04). Rename is the exception and acts on the clicked row. Menu labels take the plural ("Close 3 Tabs", "Move 3 Tabs to ▸"). | TabMenuModelTest.PluralLabelsForASelection; TabStripModelTest.SpacePinAppliesToTheSelection | planned · D3 |
| R22 | Chords act on the selection the same way (⌘W, ⌘D, ⌥⇧⌘←/→); a ⌘T action from the bar acts on the selection when the bar was opened with one. | SpaceWindowTest.CmdDPinsTheSelection; CommandBarViewTest.ActionAppliesToTheSelection | planned · D3 |

Rows drafted by the orchestrator from the critic's text; confirm each against Arc before its failing test.

Files: chrome/browser/ui/tabs/tab_menu_model.cc (selection_model() at 111); chrome/browser/ui/tabs/tab_strip_model.h/.cc (ExecuteContextMenuCommand over the selection); chrome/browser/ui/browser_commands.cc; chrome/browser/ui/spaces/space_model.cc (SetSpaceForTab, SetSpacePinned over a set); docs/features/tabs.md.

Patch: lands with R6-14 (the labels) and R6-02 (the chords) in their patches; no patch of its own.

Conflicts: R6-02, R6-04, R6-11, R6-14, R6-15, R6-16, R6-23 cite it.

From the critic: #4 (this rule), #34 (plural verbs).

#### R6-21 · Download progress on the sidebar button (S-41)

- Source: backlog S-41 (toolbar; round 5 item 12).
- Effort: S.
- Setting: none.
- Shortcut: none.
- Spec: docs/features/toolbar.md (T14).

| Id | Behaviour | Test | State |
|---|---|---|---|
| T14 | The bottom-left downloads button shows Chromium's progress ring and the download-started animation; today both target the toolbar button, which appears at the top right during a download. | live: tooling/drive starts a download, a capture within 1 s shows the ring on the sidebar button and no toolbar button; capture dark and light | planned · draft |

Rows drafted by the orchestrator from the backlog row (critic #11 named it ownerless); confirm against Arc before the failing test.

Files: chrome/browser/ui/views/tabs/vertical/vertical_tab_strip_bottom_container.cc (the button, round 5 item 12); chrome/browser/ui/views/download/ (the toolbar button's ring and animation, to be pointed at the sidebar button); docs/features/toolbar.md; BACKLOG.md (S-41 to Done).

Patch: new (D11); the synthesis pointed at 0013.

Conflicts: R6-18 (the bottom row), R6-32 (no chips in private windows).

From the critic: #11 (owner).

### Wave 3 — data-bearing features on top of waves 1 and 2

| Id | Name | Source | Effort | Setting | Shortcut | Status |
|---|---|---|---|---|---|---|
| R6-22 | Import from Arc (StorableSidebar.json): Spaces, pins, folders, favorites | idea "Import from Arc" (judges 8.33, build×3) | M | button "Import from Arc…"; welcome row | none; ⌘T "Import from Arc" | planned |
| R6-23 | Air Traffic Control: route sites to Spaces | idea "Air Traffic Control" (judges 7.33, build×3) | M | per-Space Routes list; stedding.spaces.external_default | none | planned |
| R6-24 | Archived view: what auto-archive and Clear closed, restorable to its Space | idea "Archived view" (judges 7.33, build×3); Floating History's Library panel deferred to grow around this data layer | M | stedding.archive.keep_days | none; ⌘T "Show archived tabs" | planned |
| R6-25 | The address row hides with the sidebar; ⇧⌘D shows it on its own | idea "The bar goes with the sidebar" (judges 7, build×2, maybe×1); mod "Hide Toolbar" (judges 6, maybe×2, build×1), merged: ⇧⌘D, the localhost exception | M (T8 first; T10 and T13 are the second half) | stedding.toolbar.hide_with_sidebar | ⌘S; ⇧⌘D | planned |
| R6-26 | Tracker-free defaults as one Privacy block | idea "Tracker-free defaults as one settings block" (judges 7.67, build×3); mod "No Top Sites" (judges 5.67, build×1, maybe×2): the kSearchSuggestEnabled default flip merged as Q7 | M (Q4 is the M-sized piece; the rest is default flips) | Privacy block (Chromium prefs + stedding.privacy.gpc) | none | planned |
| R6-27 | Sidebar density presets with one text-size step | idea "Sidebar density presets with one text-size step" (judges 6, maybe×3); mods Customize Font Size, Tab Text Size, Lean's compact rows, merged | M | stedding.sidebar.density; stedding.sidebar.text_size | none | planned |
| R6-28 | Imported bookmarks become pinned tabs and folders | critic #3 (PRODUCT §1 "No bookmarks" [1.0]); the Bookmark Toolbar Tweaks, Lean and Cleaner Bookmark Menu leftovers | M | import step wording (TBD) | none | planned |
| R6-29 | Sidebar backups, export and restore | critic #7 (PRODUCT §1 "Sidebar backups" [1.0]; EVIDENCE.md #2 "restore that never loses a tab", #5 sync 475 upvotes) | M | "Restore sidebar…" and "Export Space…" in chrome://settings/stedding | none; ⌘T actions | planned |

#### R6-22 · Import from Arc (StorableSidebar.json): Spaces, pins, folders, favorites — plan item 11

- Source: idea "Import from Arc" (judges 8.33, build×3).
- Effort: M.
- Setting: none (a button 'Import from Arc…' in the Stedding section; the welcome row).
- Shortcut: none; ⌘T action 'Import from Arc'.
- Spec: docs/features/import.md (new; I1–I12).
- Selection: not affected.

| Id | Behaviour | Test | State |
|---|---|---|---|
| I1 | spaces::ArcSidebarImporter parses ~/Library/Application Support/Arc/StorableSidebar.json (sidebar.containers[].spaces: id, title, customInfo.iconType.emoji_v2, windowTheme; containerIDs resolve pinned/unpinned containers; items: itemContainer, list (childrenIds → nested folders), tab (savedURL, savedTitle); topAppsContainerIDs → essentials) into a read-only plan. | ArcSidebarImporterTest.ParsesFixture with a fixture of two Spaces, a nested folder and two favorites. | planned |
| I2 | The plan is summarised ('16 Spaces, 210 pinned tabs, 44 folders') before anything is applied; Skip applies nothing. | live on the welcome flow. | planned |
| I3 | Apply: SpaceModel::AddSpace/SetSpaceIcon/SetSpaceColor; TabStripModel::SetTabPinned for essentials; SpaceModel::SetSpacePinned for the pinned run (which records the home URL, H1); TabStripModel::AddToNewFolder recursively for lists (F2 nesting); unpinned tabs inserted and discarded at once (TabLifecycleUnitExternal::DiscardTab) so 400 tabs cost no memory. | ArcSidebarImporterTest.AppliesFixtureToTheModel asserts the Space list, pins, folder tree and discard state. | planned |
| I4 | Entry points: an 'Arc' row on welcome step 2 when the file exists (WelcomeHandler detects it; checkboxes for Spaces and pinned tabs / unpinned tabs), 'Import from Arc…' in chrome://settings/stedding, and a ⌘T action. | live: tooling/drive <fresh> --stedding-welcome. | planned |
| I5 | Memory and warm-start after a 400-tab import stay inside the QUALITY budgets (a strip holding 400 hidden TabViews is the risk). | tooling/measure/harness.py warm and memory legs on the imported profile. | planned |
| I6 | Phase two, a TYPE_CHROMIUM-shaped importer for Arc's User Data/Default History and Login Data, is a separate row and patch. | none yet (gap). | planned |
| I7 | Arc split-view items become split rows (R6-19 J1); archived items go to the archive (R6-24 A8) with their Space and folder path and a reason of "import". | ArcSidebarImporterTest.SplitsBecomeSplitRowsAndArchivedItemsGoToTheArchive | planned · D9 |
| I8 | The per-Space profile binding is dropped and named in the import summary (I2). | ArcSidebarImporterTest.SummaryNamesDroppedProfileBindings | planned · D9 |
| I9 | The importer reads a copy of StorableSidebar.json (Arc rewrites the file while running) and warns when Arc is running. | ArcSidebarImporterTest.ReadsACopy; live with Arc open | planned · D9 |
| I10 | windowTheme maps to the nearest of the five Stedding swatches (kNewSpaceColors). | ArcSidebarImporterTest.ThemeMapsToTheNearestSwatch | planned · D9 |
| I11 | Favorites are capped at 12 essentials (nothing in the tree caps essentials); where the rest go is TBD and the summary counts them. | ArcSidebarImporterTest.FavoritesCapAtTwelve | planned · D9 |
| I12 | A second import is idempotent: Arc's item id is stored with the tab and nothing already present is created again. | ArcSidebarImporterTest.SecondImportAddsNothing | planned · D9 |

Rows I1, I2, I3, I4, I5, I6 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Files: new chrome/browser/ui/spaces/arc_sidebar_importer.h/.cc + arc_sidebar_importer_unittest.cc with a fixture JSON; chrome/browser/ui/spaces/space_model.h (AddSpace 110, SetSpaceIcon 130, SetSpaceColor 129, SetSpacePinned 164); chrome/browser/ui/tabs/tab_strip_model.h (AddToNewFolder 696, SetTabPinned 506); chrome/browser/resource_coordinator/tab_lifecycle_unit_external.h (DiscardTab); chrome/browser/ui/webui/stedding_welcome/stedding_welcome_handler.cc (RegisterMessages 33); chrome/browser/resources/stedding_welcome/app.ts (step 'import', 27-37); chrome/browser/ui/webui/settings/stedding_spaces_handler.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/ui/views/commandbar/command_bar_view.cc; chrome/browser/importer/importer_list.cc and components/user_data_importer/common/importer_type.h (I6 only); new docs/features/import.md; docs/features/welcome.md (W3/W8).

Patch: new (D11); the synthesis pointed at: Patch 0015 (welcome) plus a new import patch. Fixups go into round-6 patches only.

Conflicts: 8 (SetSpacePinned records the home URL; land after 8 or record it here too), 7 (inserted tabs wear the slept look), 12 and 16 (space_model.h, stedding_spaces_handler.cc), 14 (16 imported Spaces overflow the switcher: land 14 before or with this).

From the critic: #19 (D9, I7–I12), #7 (the plan format is R6-29's file format), #34 (the round-trip export makes the import strictly better than Arc's own).

#### R6-23 · Air Traffic Control: route sites to Spaces — plan item 12

- Source: idea "Air Traffic Control" (judges 7.33, build×3).
- Effort: M.
- Setting: chrome://settings/stedding: per-Space Routes sub-list in the Spaces list; dropdown 'Open links from other apps in' (stedding.spaces.external_default, default: the active Space).
- Shortcut: none.
- Spec: docs/features/routing.md (new; D1–D6).
- Selection: the multi-select rule R6-20 (D3) applies to every verb here; the spec cites it and does not restate it. "Always open <site> in ▸" from a multi-selection writes one rule per site (TBD).

| Id | Behaviour | Test | State |
|---|---|---|---|
| D1 | A pure-function SpaceRouter over the profile pref stedding.spaces.routes (entries {match: site\|contains\|equals, pattern, space}) plus stedding.spaces.external_default (the Space for links from other apps); a matching route wins over the default, as in Arc. | SpaceRouterTest.MatchTable. | planned |
| D2 | On insert of a tab that has a URL, and on the first navigation of a fresh tab (the seam in chrome::Navigate() beside MaybePeekInsteadOfNewTab), a match moves the tab with SetSpaceForTab and switches Space when the open was foreground. Session-restored tabs are never routed (B2). | SpaceWindowTest.InsertedTabFollowsRoute, SpaceWindowTest.RestoredTabIsNotRouted. | planned |
| D3 | Links from other apps (application:openURLs: → openStartupTabsReplacingNTP:) are tagged so external_default applies. | live: `open -a Stedding https://…` lands in the chosen Space. | planned |
| D4 | A 4-second toast 'Opened in Work · Undo' (item 21's style) returns the tab. | live capture; SpaceWindowTest.UndoMovesTheTabBack. | planned |
| D5 | Rules are made in place: tab context menu 'Always open <site> in ▸ <Spaces>' writes a site rule (eTLD+1, no regex); the Space menu offers 'Route sites here…'; the Spaces list in chrome://settings/stedding gains a Routes sub-list per Space with add/remove and 'Sort open tabs by these rules now' (second pass). | SpaceRouterTest.RuleFromTabIsSiteScoped; live. | planned |
| D6 | Pinned tabs keep peeking; routing applies to new tabs only, and peek precedes routing. | ShouldPeekTest.PeekPrecedesRoutes. | planned |

Files: new chrome/browser/ui/spaces/space_router.h/.cc + space_router_unittest.cc; chrome/browser/ui/spaces/space_model.cc (OnTabStripModelChanged, SetSpaceForTab 480); chrome/browser/ui/navigator/browser_navigator.cc (the peek check at 1112); chrome/browser/app_controller_mac.mm (openStartupTabsReplacingNTP: 560/1256, application:openURLs:); chrome/browser/ui/tabs/tab_menu_model.cc; chrome/browser/ui/views/spaces/space_switcher_view.cc (Space menu, ExecuteCommand 314); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/ui/webui/settings/stedding_spaces_handler.cc; chrome/browser/ui/spaces/space_model_window_unittest.cc; new docs/features/routing.md.

Patch: new (D11); the synthesis pointed at: Patch 0004 plus a new routing patch. Fixups go into round-6 patches only.

Conflicts: 21 (the undo toast; ship with Chromium's default ToastView if 21 is not in yet), 15 (external links: the little window opens unless a route matches, so 12 lands first), 6 (tab_menu_model.cc), 11 and 16 (space_model, stedding_spaces_handler.cc), 14 (space_switcher_view.cc menu), 8 (peek precedence).

From the critic: #26 (multi-window: which window external_default names, and a route whose site is Space-pinned in the target Space (duplicate or activate the pin): TBD until R6-31; the critic's unsure line asks whether Arc routes such a match into the pin, check side by side first), #21 (D4's undo toast takes R6-07's style).

#### R6-24 · Archived view: what auto-archive and Clear closed, restorable to its Space — plan item 13

- Source: idea "Archived view" (judges 7.33, build×3); Floating History's Library panel deferred to grow around this data layer.
- Effort: M.
- Setting: chrome://settings/stedding dropdown 'Keep archived tabs for: 7 days / 30 days / 90 days' (stedding.archive.keep_days, default 30).
- Shortcut: none; ⌘T action 'Show archived tabs' (⌘Y stays History).
- Spec: docs/features/archive.md (A7 closed, A8–A11).
- Selection: restore from the page acts on the page's own selection (TBD).

| Id | Behaviour | Test | State |
|---|---|---|---|
| A7 | closed as: an 'Archived' row at the foot of the tab list, above the switcher row, opens chrome://stedding-archive (a WebUI built like stedding_welcome_ui.cc). | live capture. | planned |
| A8 | One ArchiveTab() helper, called by TabArchiver::Sweep and by SpaceModel::ClearUnpinnedTabs (item 2), records Space name, folder path and reason (auto \| clear) in the tab's TabRestoreService extra_data (sessions::tab_restore::Tab::extra_data) rather than a second store; Chromium's list keeps ⇧⌘T working. | TabArchiverTest.SweepRecordsSpaceAndReason, SpaceModelTest.ClearRecordsReason. | planned |
| A9 | The page groups by day, filters by Space, searches, and 'Restore to <Space>' re-creates the Space if it is gone (AddSpace, then SetSpaceForTab); 'Clear archive' empties it. | ArchivePageTest.RestoreRecreatesAMissingSpace; live. | planned |
| A10 | CommandBarView::UpdateResults merges a third source labelled 'Archived', so ⌘T finds a tab whether open or archived; choosing one restores to its Space. | CommandBarViewTest.ArchivedRowRestoresToItsSpace. | planned |
| A11 | Retention: 'Keep archived tabs for 7 / 30 / 90 days' bounds what the page shows. | ArchivePageTest.RetentionFiltersOldEntries. | planned |

Files: chrome/browser/ui/archive/tab_archiver.h/.cc (Sweep 44); new chrome/browser/ui/archive/archive_tab.h/.cc (the helper); components/sessions/core/tab_restore_types.h (extra_data 77, read only); chrome/browser/ui/views/frame/vertical_tab_strip_region_view.cc (the Archived row); new chrome/browser/ui/webui/stedding_archive/ on the pattern of chrome/browser/ui/webui/stedding_welcome/stedding_welcome_ui.cc; chrome/browser/ui/webui/chrome_web_ui_configs.cc; chrome/browser/ui/views/commandbar/command_bar_view.cc (UpdateResults 247); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/ui/archive/tab_archiver_unittest.cc; docs/features/archive.md (A7 closed, A8–A11 added).

Patch: new (D11); the synthesis pointed at: Patch 0011. Fixups go into round-6 patches only.

Conflicts: 2 (Clear moves into SpaceModel::ClearUnpinnedTabs; the reason hook goes there), 1 (command bar source), 15 (little windows archive through the same helper), 17 (the archiver skips OTR windows).

From the critic: #28 (⇧⌘T already restores to the tab's Space through RestoreSpaceFromExtraData, browser_tabrestore.cc:90: A8 rides that path and adds the folder path; the "Archived" row in the collapsed rail is an icon, captured dark and light), #30, #31 (the archive page is WebUI: keyboard and VoiceOver come from the DOM; say so in the spec).

#### R6-25 · The address row hides with the sidebar; ⇧⌘D shows it on its own — plan item 18

- Source: idea "The bar goes with the sidebar" (judges 7, build×2, maybe×1); mod "Hide Toolbar" (judges 6, maybe×2, build×1), merged: ⇧⌘D, the localhost exception.
- Effort: M (T8 first; T10 and T13 are the second half).
- Setting: chrome://settings/stedding toggle 'Hide the address row with the sidebar' (stedding.toolbar.hide_with_sidebar, on), under the sidebar rows.
- Shortcut: ⌘S (existing collapse); ⇧⌘D toggle the row (from IDC_BOOKMARK_ALL_TABS, accelerators_cocoa.mm:104); ⌘L opens the command bar (D2, K12), it no longer reveals the row.
- Spec: docs/features/toolbar.md (T8–T13).
- Selection: not affected.

| Id | Behaviour | Test | State |
|---|---|---|---|
| T8 | When the strip collapses (⌘S, IDC_TOGGLE_VERTICAL_TABS_COLLAPSE) and the setting is on, SteddingBrowserViewLayout::CalculateTopContainerLayout returns a zero-height container: the content card takes the full height with its radius and 8 DIP gutters, and SteddingWindowBackground::PaintPageBar paints nothing. Immersive fullscreen is unchanged (T6; the overlay owns the row) and IsToolbarVisible()==false is the path already exercised there, so every anchor (bubbles, permission prompts, find bar, extension popups) is re-verified against it. | tooling/probes/window.json 'content top == window top when collapsed'; a layout unit test for the zero-height container. | planned |
| T9 | Resting the pointer in the top 6 DIP for 250 ms floats the row as a pill over the card's top edge (T3/T4 colour rules); ⌘L summons it focused with the full URL; Escape or focus loss retracts it. | live: tooling/drive hover at y=2, shot; ⌘L, type, Escape. | dropped (D2): ⌘L opens the command bar (K12); no floating pill |
| T10 | ⇧⌘D (Arc's 'Full URL in Toolbar') toggles the row for the window independently of the sidebar: with the sidebar expanded and the row hidden, or the sidebar collapsed and the row shown; IDC_BOOKMARK_ALL_TABS loses its chord (recorded). | layout unit test; live. | planned |
| T11 | localhost pages always show the row (Arc's Developer Mode). | live on http://localhost. | planned |
| T12 | Setting off keeps the row on regardless of the sidebar (today's behaviour); ⇧⌘D still works. | SteddingPrefsTest default; live. | planned |
| T13 | When the row is hidden, extension actions, the global media button and page info live in the command bar's actions mode (R6-11); ⌘E cycles extension actions (PRODUCT §12); page info opens from the URL text in the bar (D10). Permission chips: TBD. | CommandBarViewTest.ExtensionActionsListedWhenTheRowIsHidden; live: ⌘E with two extensions; page info from the bar | planned · D10 |

Rows T8, T9, T10, T11, T12 are verbatim from the synthesis (T9's behaviour and test as written; its State is D2's); the rest were added by the decisions named in their State.

Files: chrome/browser/ui/views/frame/layout/stedding_browser_view_layout.h/.cc (CalculateTopContainerLayout 55-102, ConfigureTopContainerBackground 104); chrome/browser/ui/views/frame/layout/browser_view_tabbed_layout_impl.cc; chrome/browser/ui/views/frame/browser_view.cc (IsToolbarVisible 3042); chrome/browser/ui/views/frame/top_container_view.cc (the immersive reveal path); chrome/browser/ui/views/frame/stedding_window_background.cc (PaintPageBar 106); chrome/browser/ui/views/frame/vertical_tab_strip_region_view.h (SetCollapsedStateUpdatedCallback 152); chrome/browser/ui/stedding/theme/page_theme_color_controller.cc; chrome/app/chrome_command_ids.h (IDC_STEDDING_TOGGLE_ADDRESS_ROW), chrome/browser/ui/cocoa/accelerators_cocoa.mm (71, 104), chrome/browser/ui/browser_command_controller.cc; chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; tooling/probes/window.json; docs/features/toolbar.md (T8–T13).

Patch: new (D11); the synthesis pointed at: Patches 0002 and 0013. Fixups go into round-6 patches only.

Conflicts: 2 and 5 (accelerators_cocoa.mm, chrome_command_ids.h, browser_command_controller.cc), 17 (stedding_window_background.cc), 20 (find bar and status bubble positions come from the same layout), 1 (a 'Toggle address row' action).

From the critic: #2 (D2: T9 dropped), #20 (D10: T13; the split mini-toolbars with no row above them: TBD), #30 (T8 captured dark and light with the probe named), #6 (T10's divergence row goes to Z2).

#### R6-26 · Tracker-free defaults as one Privacy block — plan item 22

- Source: idea "Tracker-free defaults as one settings block" (judges 7.67, build×3); mod "No Top Sites" (judges 5.67, build×1, maybe×2): the kSearchSuggestEnabled default flip merged as Q7.
- Effort: M (Q4 is the M-sized piece; the rest is default flips).
- Setting: chrome://settings/stedding 'Privacy' block: one toggle per row above (Chromium prefs for Q1–Q3, Q5–Q7; stedding.privacy.gpc for Q4). The Chromium-pref rows are exempt from settings T2's default-on rule because they are not stedding.* prefs; the block's wording makes each default the protective one.
- Shortcut: none.
- Spec: docs/features/privacy.md (new; Q0–Q8).
- Selection: not affected.

| Id | Behaviour | Test | State |
|---|---|---|---|
| Q0 | ADR 0017 records the default flips PRIVACY.md already promises (third-party cookies above all, with the site-breakage answer: Chromium's eye icon and per-site allow stay). | the ADR exists. | planned |
| Q1 | Third-party cookies blocked in normal windows: kCookieControlsMode defaults to kBlockThirdParty (cookie_settings.cc registers kIncognitoOnly today). | a network probe through tooling/drive on a page embedding a cross-site frame: no third-party Set-Cookie honoured; a default-pref test. | planned |
| Q2 | HTTPS-First balanced mode on (browser_ui_prefs.cc:231 registers false). | default-pref test; live: http://example.com upgrades. | planned |
| Q3 | 'Ask a web service about navigation errors' off (profile_network_context_service.cc:651 registers kAlternateErrorPagesEnabled true). | default-pref test; a failed navigation makes no request (network probe). | planned |
| Q4 | Global Privacy Control sent (Sec-GPC: 1 and navigator.globalPrivacyControl): a new pref stedding.privacy.gpc (on) read where the request header is assembled and by the Blink runtime feature GlobalPrivacyControl (runtime_enabled_features.json5:3395). | live: a page that echoes request headers shows Sec-GPC: 1; off removes it. | planned |
| Q5 | Quiet permission prompts on for notifications and geolocation (quiet_notification_permission_ui_state.cc). | default-pref test. | planned |
| Q6 | Topics, Protected Audience and Attribution pinned off (privacy_sandbox_prefs.cc) and the Privacy Sandbox settings page hidden in page_visibility.ts. | default-pref test; settings capture. | planned |
| Q7 | Search suggestions off by default (kSearchSuggestEnabled at profile.cc:340), the PRIVACY.md line 209 to-do; the Stedding row reads 'Send what you type to the search engine for suggestions' (off), and the ⌘T bar's empty query already shows no suggestions. | SteddingPrefsTest for the default; live: ⌘L, type, no suggest request (network probe). | planned |
| Q8 | Each of Q1–Q7 is one row in the Privacy block, each bound to exactly one preference, and each default is a docs/features/privacy.md row with its probe. | tooling/probes/settings.json. | planned |

Files: components/content_settings/core/browser/cookie_settings.cc (59/80); chrome/browser/ui/browser_ui_prefs.cc (231); chrome/browser/net/profile_network_context_service.cc (651); chrome/browser/permissions/quiet_notification_permission_ui_state.cc; components/privacy_sandbox/privacy_sandbox_prefs.cc; services/network/public/cpp/header_util.cc (Sec-GPC allowlist 150) and the request-header producer behind the Blink flag; third_party/blink/renderer/platform/runtime_enabled_features.json5 (3395); chrome/common/chrome_features.cc (kHttpsFirstBalancedModeAutoEnable); chrome/browser/profiles/profile.cc (340); chrome/browser/ui/stedding/stedding_prefs.h/.cc (a RegisterPrivacyDefaults run after Chromium's registration, SetDefaultPrefValue to keep upstream hunks near zero); chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/resources/settings/page_visibility.ts; chrome/browser/extensions/api/settings_private/prefs_util.cc; new docs/features/privacy.md; new docs/decisions/0017-tracker-free-defaults.md; docs/PRIVACY.md.

Patch: new (D11); the synthesis pointed at: New privacy patch (shared with item 5's clean-link table) plus 0010. Fixups go into round-6 patches only.

Conflicts: 5 (the same privacy patch and settings section), 23 and 24 (stedding_page.html.ts, stedding_prefs), 17 (PRIVACY.md).

From the critic: #22 (PRIVACY.md's own to-do table is only half covered: translate, preloading (net.network_prediction_options), network time, the component-updater endpoint, dummy API keys: each gets a Q row or a one-line reason in privacy.md, TBD; Q1's site-breakage answer is a visible row in the block, not only in the ADR).

#### R6-27 · Sidebar density presets with one text-size step — plan item 23

- Source: idea "Sidebar density presets with one text-size step" (judges 6, maybe×3); mods Customize Font Size, Tab Text Size, Lean's compact rows, merged.
- Effort: M.
- Setting: chrome://settings/stedding dropdown 'Sidebar density: Comfortable (default) / Compact / Dense' (stedding.sidebar.density, local state) and dropdown 'Sidebar text size: 12 / 13 / 14 / 15' (stedding.sidebar.text_size, default 12).
- Shortcut: none.
- Spec: docs/features/sidebar.md (new; Y1–Y5).
- Selection: not affected.

| Id | Behaviour | Test | State |
|---|---|---|---|
| Y1 | 'Sidebar density: Comfortable / Compact / Dense' sets rows 44/36/30 DIP, favicon slot 18/16/16, essentials card 50/40/34; the Stedding layout constants (kVerticalTabHeight, kVerticalTabPinnedHeight, kTabFaviconSize, kVerticalTabCornerRadius) read a local-state pref through a process-wide cache the way they read the feature params now, and the strip re-lays out live like the width slider (T7). Comfortable is today's measured Arc match, untouched. | a layout unit test for the three metric sets; tooling/probes/window.json gains a density case so the numbers are measured. | planned |
| Y2 | 'Sidebar text size' 12–15 pt applies to tab titles, the Space title row, folder headers, the '+ New Tab' row and the Clear line; the row height is max(preset, line height + insets) so nothing clips. | TabViewTest.TitleFontFollowsThePref; capture at 12 and 15. | planned |
| Y3 | Folder headers, the Space title row, the New Tab row and the Clear line take the same row height so Dense looks even. | capture at Dense. | planned |
| Y4 | ⌘T actions 'Sidebar density: …' for each preset. | CommandBarViewTest row set. | planned |
| Y5 | The essentials grid, toolbar and command bar do not move. | probes unchanged for those regions. | planned |

Files: chrome/browser/ui/layout_constants.cc (kVerticalTabHeight ~156, kVerticalTabPinnedHeight ~158); chrome/browser/ui/stedding_ui_metrics.h/.cc (kVerticalTabHeight 31, kVerticalTabPinnedHeight 37, kTabFaviconSize 69); chrome/browser/ui/views/tabs/common/tab_view_vertical_layout.cc; chrome/browser/ui/views/tabs/tab/tab_title.cc; chrome/browser/ui/views/tabs/common/tab_view.cc; chrome/browser/ui/views/tabs/common/folder_view.cc; chrome/browser/ui/views/tabs/common/tab_strip_view.cc (kSpaceTitleRowHeight 49); chrome/browser/ui/views/tabs/common/clear_tabs_separator.cc; chrome/browser/ui/views/frame/vertical_tab_strip_region_view.cc (UpdateSpaceTitle 1346); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; tooling/probes/window.json; new docs/features/sidebar.md.

Patch: new (D11); the synthesis pointed at: Patches 0002 and 0013. Fixups go into round-6 patches only.

Conflicts: 7, 9, 10 (tab_view.cc, tab_view_vertical_layout.cc, tab_title.cc), 17 (tab_strip_view.cc), 22 and 24 (settings page, prefs). Not parity; judges: after the parity rows above.

From the critic: none directly; #30 (a density case in the probe file is already Y1).

#### R6-28 · Imported bookmarks become pinned tabs and folders

- Source: critic #3 (PRODUCT §1 "No bookmarks" [1.0]); the Bookmark Toolbar Tweaks, Lean and Cleaner Bookmark Menu leftovers.
- Effort: M.
- Setting: import step wording (TBD).
- Shortcut: none.
- Spec: docs/features/import.md (I13–I16).

| Id | Behaviour | Test | State |
|---|---|---|---|
| I13 | Bookmarks imported on welcome W3 or from chrome://settings/importData become Space-pinned tabs in the active Space: each bookmark folder a folder (F1/F2 nesting), each bookmark a Space-pinned tab inserted discarded (I3), the bookmark-bar root first. | BookmarksToPinsTest.FolderTreeBecomesPinnedFolders | planned · draft |
| I14 | After the conversion the bookmark bar (⇧⌘B, the new tab page's bar), the star in the location bar and the Bookmarks submenu are hidden; Import Bookmarks and Settings stays reachable from the app menu (S-30, M3). | capture of the new tab page and the app menu; AppMenuModelTest.SteddingRows | planned · draft |
| I15 | The import step says what happens ("Bookmarks become pinned tabs and folders", with a count); Skip leaves the bookmark model as Chromium filled it, and whether the bar stays hidden then is TBD. | live on the welcome flow | planned · draft |
| I16 | A profile that already holds bookmarks when it upgrades: TBD (a one-time offer on the next start, or a ⌘T action "Turn bookmarks into pinned tabs"). | TBD | planned · draft |

Rows drafted by the orchestrator from the critic's text; confirm each against Arc before its failing test.

Files: chrome/browser/ui/webui/settings/import_data_handler.cc (the seam after the import completes); components/bookmarks (read only); chrome/browser/ui/spaces/space_model.h (SetSpacePinned, H1 records the home URL); chrome/browser/ui/tabs/tab_strip_model.h (AddToNewFolder); chrome/browser/ui/toolbar/bookmark_sub_menu_model.cc; chrome/browser/ui/views/location_bar/ (the star); chrome/browser/ui/bookmarks/bookmark_bar_controller.cc (IsShowingNTP shows the bar on the new tab page); chrome/browser/resources/stedding_welcome/app.ts; docs/features/import.md; docs/features/welcome.md (W3).

Patch: new (D11), after R6-22 (shares the importer's apply path) and R6-16 (H1).

Conflicts: R6-22 (apply path), R6-16 (home URL), R6-14 (M3 trims the Bookmarks submenu), R6-15 (inserted tabs wear the slept look).

From the critic: #3 (this item), #33 (Bookmark Toolbar Tweaks closes here).

#### R6-29 · Sidebar backups, export and restore

- Source: critic #7 (PRODUCT §1 "Sidebar backups" [1.0]; EVIDENCE.md #2 "restore that never loses a tab", #5 sync 475 upvotes).
- Effort: M.
- Setting: "Restore sidebar…" and "Export Space…" in chrome://settings/stedding.
- Shortcut: none; ⌘T actions.
- Spec: docs/features/import.md (I17–I20).

| Id | Behaviour | Test | State |
|---|---|---|---|
| I17 | Stedding writes a JSON snapshot of the sidebar (Spaces with name, icon, colour, order; essentials; the per-Space pinned runs with home URLs (H1); folders with nesting; custom titles (R15)) into the profile directory on the schedule PRODUCT §1 gives; local only, deleted with the profile. | SidebarBackupTest.SnapshotCarriesEveryField; a schedule test with a mock clock | planned · draft |
| I18 | The file is R6-22's plan format, so an export is an import in reverse and a restore applies through ArcSidebarImporter's apply path (I3, I12 idempotence). | SidebarBackupTest.RoundTripIsIdentity | planned · draft |
| I19 | "Restore sidebar…" lists snapshots by time; a restore never closes an open tab; whether it merges into or replaces the current sidebar is TBD and the row says which. | SidebarBackupTest.RestoreClosesNothing; live | planned · draft |
| I20 | "Export Space…" writes one Space in the same format and "Import sidebar…" reads a file back: the file-based answer to sync, with no account (PRIVACY.md). | SidebarBackupTest.ExportOneSpaceImportsBack | planned · draft |

Rows drafted by the orchestrator from the critic's text; confirm each against Arc before its failing test.

Files: chrome/browser/ui/spaces/arc_sidebar_importer.h/.cc (the plan type and apply path from R6-22); new chrome/browser/ui/spaces/sidebar_backup.h/.cc + unittest; chrome/browser/ui/webui/settings/stedding_spaces_handler.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; chrome/browser/ui/views/commandbar/command_bar_view.cc (actions); docs/features/import.md; docs/PRODUCT.md (§1).

Patch: new (D11), after R6-22.

Conflicts: R6-22 (plan format), R6-16 (home URLs), R6-17 (titles), R6-31 (the registry becomes the source once it exists).

From the critic: #7 (this item), #34 (the round trip).

### Wave 4 — needs an ADR first

| Id | Name | Source | Effort | Setting | Shortcut | Status |
|---|---|---|---|---|---|---|
| R6-30 | Little window: links from other apps open small | idea "Little window" (judges 6.33, build×1, maybe×2); judges: effort closer to L, needs 12 and 21 first | L | stedding.little.enabled; shares stedding.spaces.external_default | ⌘O / ⇧⌘O / Esc / ⌃1–9 inside | planned |
| R6-31 | One sidebar for every window (SpaceRegistry) — needs an ADR first | idea "One sidebar for every window" (judges 6.33, maybe×2, build×1); judges: L, needs its ADR and a design pass before an estimate | L | none | ⌘N; ⌥⇧⌘N | planned |
| R6-32 | Private windows wear a different coat | idea "Private windows wear a different coat" (judges 8, build×3); mod "Private Mode Highlighting" (judges 6, skip×1, build×1, maybe×1), merged: the avatar badge back for OTR | M | none | ⇧⌘N | planned |

#### R6-30 · Little window: links from other apps open small — plan item 15

- Source: idea "Little window" (judges 6.33, build×1, maybe×2); judges: effort closer to L, needs 12 and 21 first.
- Effort: L.
- Setting: chrome://settings/stedding toggle 'Open links from other apps in a small window' (stedding.little.enabled, on); shares stedding.spaces.external_default with item 12.
- Shortcut: ⌘O / ⇧⌘O / Escape inside the window (as peek); ⌃1–9 inside it; no chord to open one (see E5).
- Spec: docs/features/little.md (new; E1–E5).
- Selection: not affected (one page per little window).

| Id | Behaviour | Test | State |
|---|---|---|---|
| E1 | A link from another application opens a stedding::LittleWindow, a TYPE_POPUP browser (no Spaces, B14) with a thin bar: back/forward/reload, centred host, 'Open in ▸ <Space>' from the last-active normal window's SpaceModel, and Pin; unless an Air Traffic Control route matches (route wins, D3). | LittleWindowTest.ExternalUrlOpensLittleWindow, LittleWindowTest.MatchingRouteSkipsIt. | planned |
| E2 | ⌘O moves the WebContents into the last-active window's active Space (InsertWebContentsAt then SetSpaceForTab, no reload); ⇧⌘O into a split with its active tab; Escape closes; ⌃1–9 inside it send the page to Space N. The verbs mirror PeekView::PromoteToTab/PromoteToSplit. | LittleWindowTest.PromoteMovesContentsIntoSpace, LittleWindowTest.CtrlDigitSendsToSpaceN. | planned |
| E3 | TabArchiver gets a per-window threshold: little windows archive at 6 hours (stedding.little.idle_hours) against 12 for tabs. | TabArchiverTest.LittleWindowUsesItsOwnThreshold. | planned |
| E4 | Setting off opens external links as ordinary tabs in external_default (D3). | LittleWindowTest.SettingOffOpensATab. | planned |
| E5 | Chord: none in this cut. ⌥⌘N stays split (welcome W6 advertises it); the divergence from Arc's ⌥⌘N is recorded in the shortcut reference with a decision to make later. | shortcut reference row. | planned |

Note (synthesis): Effort is honest at L: popup chrome is Chromium's, and a custom thin bar with an Open-in-Space menu is more than the peek verbs. Spec and capture the bar against Little Arc before building.

Files: new chrome/browser/ui/views/little/little_window.h/.cc + unittest; chrome/browser/app_controller_mac.mm (openStartupTabsReplacingNTP: 560/1256); chrome/browser/ui/startup/startup_browser_creator_impl.cc; chrome/browser/ui/views/peek/peek_view.h (PromoteToTab 77, PromoteToSplit 81, the pattern); chrome/browser/ui/browser_window/internal/browser_window_features.cc (TYPE_NORMAL gates 276-279); chrome/browser/ui/archive/tab_archiver.h/.cc (IdleThreshold 63); chrome/browser/ui/stedding/stedding_prefs.h/.cc; chrome/browser/resources/settings/stedding_page/stedding_page.html.ts; new docs/features/little.md; docs/PRODUCT.md (§5).

Patch: new (D11); the synthesis pointed at: New patch. Fixups go into round-6 patches only.

Conflicts: 12 (routing decides before the little window; app_controller_mac.mm), 13 (tab_archiver), 17 (browser_window_features.cc), 21 (toast on promote), 2 (⌃1–9 handling inside a popup).

From the critic: #29 (chords inside the popup: mac tables), #30 (the bar captured dark and light with a probe), #31 (VoiceOver role of the thin bar: TBD), #26 (which window "last-active" means: R6-31).

#### R6-31 · One sidebar for every window (SpaceRegistry) — needs an ADR first — plan item 16

- Source: idea "One sidebar for every window" (judges 6.33, maybe×2, build×1); judges: L, needs its ADR and a design pass before an estimate.
- Effort: L.
- Setting: none.
- Shortcut: ⌘N (existing); ⌥⇧⌘N New Blank Window (unbound in Chromium on mac).
- Spec: docs/features/windows.md (new; G0–G5); docs/decisions/ (the registry ADR).
- Selection: not affected.

| Id | Behaviour | Test | State |
|---|---|---|---|
| G0 | ADR 0016 beside 0015: the Space list, order, metadata, essentials and per-Space pinned entries move to a profile-level SpaceRegistry (KeyedService); SpaceModel stays per window with only the active Space and tab membership, observing the registry. Written and accepted before code. | the ADR exists. | planned |
| G1 | ⌘N (and a tab dragged out through tab_drag_controller.cc) opens a window showing the same Spaces, essentials and pinned rows. | SpaceWindowTest.SecondWindowSeesTheSameSpaces. | planned |
| G2 | A pinned tab is a real tab in one window at a time; other windows show its row as a ghost (muted favicon, 'in another window' on hover); click moves the WebContents here (DetachTabAtForInsertion then InsertDetachedTabAt, no reload), ⌥-click focuses the window that has it. | SpaceWindowTest.PinnedTabMovesBetweenWindowsOnClick. | planned |
| G3 | The registry serialises to profile prefs (stedding.spaces.registry); per-window extra data keeps active Space and memberships so the B9 rebuild path is unchanged; settings T9 reads the registry. | SessionRebuildTest with two windows; SpaceRegistryTest.RoundTrip. | planned |
| G4 | 'New Blank Window' (⌥⇧⌘N, app menu) opens a window that opts out of the registry: Arc's Blank Window. | SpaceWindowTest.BlankWindowHasItsOwnSpaces. | planned |
| G5 | The registry ADR states that a registry Space can carry a profile id (PRODUCT §2 "Per-Space Profiles" [1.0]; the Container Halo and Colored container tab mods are the demand signal), so the model does not preclude it; nothing in this item binds a profile (critic #9, D1). | the ADR text; SpaceRegistryTest.RoundTrip carries an empty profile id | planned · critic #9 |

Rows G0, G1, G2, G3, G4 are verbatim from the synthesis; the rest were added by the decisions named in their State.

Note (synthesis): Effort is L and the estimate is not credible until G0 is done; schedule after the S/M items above.

Files: new chrome/browser/ui/spaces/space_registry.h/.cc + unittest; chrome/browser/ui/spaces/space_model.h/.cc; chrome/browser/ui/browser_window/internal/browser_window_features.cc (276-279); chrome/browser/ui/views/spaces/space_tab_visibility_controller.h/.cc; chrome/browser/ui/views/tabs/dragging/tab_drag_controller.cc; chrome/browser/sessions/stedding_session_rebuild.h; chrome/browser/ui/webui/settings/stedding_spaces_handler.cc; chrome/app/chrome_command_ids.h, chrome/browser/ui/cocoa/accelerators_cocoa.mm (⌥⇧⌘N); new docs/decisions/0016-space-registry.md; new docs/features/windows.md; docs/PRODUCT.md (§10).

Patch: new (D11); the synthesis pointed at: Patch 0004 becomes two. Fixups go into round-6 patches only.

Conflicts: Every item that edits space_model.h/.cc (2, 3, 8, 11, 12) and stedding_spaces_handler.cc (11, 12); 8's home URL and 11's importer target the registry once it exists, so land those first against SpaceModel and migrate in this item.

From the critic: #9 (G5), #26 (multi-window routing questions from R6-23 are answered here), #27 (R6's timer per window vs per registry), #29.

#### R6-32 · Private windows wear a different coat — plan item 17

- Source: idea "Private windows wear a different coat" (judges 8, build×3); mod "Private Mode Highlighting" (judges 6, skip×1, build×1, maybe×1), merged: the avatar badge back for OTR.
- Effort: M.
- Setting: none (nothing to turn off; Chromium's per-extension 'Allow in Incognito' stays).
- Shortcut: ⇧⌘N (existing).
- Spec: docs/features/private.md (new; V1–V6).
- Selection: not affected.

| Id | Behaviour | Test | State |
|---|---|---|---|
| V1 | An off-the-record window (BrowserWidget::IsIncognitoBrowser; ThemeService::GetColorProviderKey already forces dark + grayscale at theme_service.cc:712-716, which AddSteddingColorMixer today paints as the same navy) paints a flat graphite ground in both schemes: no gradient, no Space tint; the mat, the page bar and the command bar follow through the mixer. | tooling/probes/window.json run with --incognito, dark and light (a probe at the sidebar ground and at the mat). | planned |
| V2 | The Space title row (TabStripView::SetSpaceTitle) reads 'Private' with the incognito glyph and opens no menu; the switcher row shows no chips and no '+'; the window title carries ' - Private'. | capture; PopupSpaceTest-style unit test that a private window has one Space and no switcher. | planned |
| V3 | SpaceModel and TabArchiver are not created for OTR windows (browser_window_features.cc:276-279 gates on TYPE_NORMAL only today), so the archiver never closes a private tab and nothing private reaches the sidebar model or session extra data. | TabArchiverTest.SkipsOffTheRecordWindows, SpaceWindowTest.PrivateWindowHasNoSpaceModel. | planned |
| V4 | Chromium's avatar badge ('Incognito' pill) is shown again for OTR profiles only (patch 0002's toolbar hunk hides avatar_ for every window). | capture. | planned |
| V5 | The local new tab page adds one line under the hint: 'Private window: history, cookies and site data are forgotten when the last private window closes'. | tooling/probes/ntp.json --incognito. | planned |
| V6 | Peek and its promotion into a split stay inside the private window. | PeekViewTest.PromotionStaysInThePrivateWindow. | planned |

Files: chrome/browser/ui/views/frame/stedding_window_background.cc; chrome/browser/ui/color/stedding_color_mixer.cc (AddSteddingColorMixer 37-44); chrome/browser/ui/views/frame/browser_widget.cc (IsIncognitoBrowser 591, colour key 356/530); chrome/browser/themes/theme_service.cc (GetColorProviderKey 705, read only); chrome/browser/ui/views/tabs/common/tab_strip_view.cc (SetSpaceTitle 271); chrome/browser/ui/views/spaces/space_switcher_view.cc; chrome/browser/ui/browser_window/internal/browser_window_features.cc (276-279); chrome/browser/ui/archive/tab_archiver.cc; chrome/browser/ui/views/toolbar/toolbar_view.cc (the avatar_ hunk from patch 0002); chrome/browser/resources/new_tab_page_third_party/new_tab_page_third_party.html; tooling/probes/window.json; new docs/features/private.md; docs/PRIVACY.md.

Patch: new (D11); the synthesis pointed at: Patches 0002, 0007, 0004, 0011. Fixups go into round-6 patches only.

Conflicts: 18, 19, 20, 21 (stedding_color_mixer.cc, stedding_window_background.cc), 14 (space_switcher_view.cc), 13 and 15 (tab_archiver, browser_window_features.cc), 16 (window features).

From the critic: #30 (V1 is already a probe run in both modes), #31 (the "Private" title row: a VoiceOver label, TBD), #13 (B29 disables the Space chords here).

## Not now

The 60 candidates the synthesis skipped, with its reason verbatim, grouped by why. A
candidate under "merged" has a part of it inside a plan item; the rest is not built. Where
a decision moved a skip, the note says so.

### Merged into a plan item (30)

| Candidate | Synthesiser's reason | Now |
|---|---|---|
| Pinned tabs have a home (idea) | Merged into plan item 8: 'Set pinned URL to this page' and the hover-card home line taken; the kTabHoverCardImages thumbnail dropped (capture on every tab hide is a memory-budget question). | R6-16 |
| Hidden Reset Button | Merged into plan item 8 (H7: peek reads the stored pinned URL's site); the hover flip is extra motion the dot plus favicon click already covers. | R6-16 |
| No pinned tab reset btn | Merged into plan item 8; nothing distinct once the favicon is the only control. | R6-16 |
| Only Reset On Hover | Merged into plan item 8 ('Make This the Pinned Page' wording kept as H6). | R6-16 |
| Remove Tab X | Part (a) is plan item 8's pinned semantics; the 'Never' dropdown is a knob Arc lacks and plan item 9 already quiets the row. | R6-16, R6-03 |
| Rename a tab in place (idea) | Duplicate of plan item 10; the TabUIHelper placement was chosen over a SpaceModel map. | R6-17 |
| Private Mode Highlighting | Merged into plan item 17 (V4, the avatar badge back for OTR); the nine colour options and three toggles are not a product decision. | R6-32 |
| Hide Toolbar | Merged into plan item 18 (T10 ⇧⌘D, T11 localhost exception) rather than a second toggle. | R6-25 |
| Copy clean link on Shift-Cmd-C (idea) | Merged into plan item 5 (its tracking-parameter table, the YouTube 'si' rule, ⌥⌘C keeping Inspect, the kLinkCopied toast). | R6-04 |
| Better CtrlTab Panel | Merged into plan item 3; same design, and kCtrlTabMru is global and Space-blind so cannot be reused. | R6-12 |
| Tab Numbers | Merged into plan item 4; the favicon-slot badge loses site identity, so the close-slot form is used. | R6-13 |
| Zen Context Menu | Merged: curation into plan item 6, the tracking strip into plan item 5; thirty hide-switches are the clutter to avoid. | R6-14, R6-04 |
| Cleaner Bookmark Menu | Merged into plan item 6 (M3 trims the Bookmarks submenu) and plan item 2 (⌘D moves to Pin); the rest waits for import-to-pinned. | R6-14, R6-28 |
| Better Tab Indicators | The active look was decided in round 5; the dim half is plan item 7's R4. | R6-15 |
| Tab title fixes | The dim is plan item 7, the 13 px title is a step of plan item 23; nothing separate. | R6-15, R6-27 |
| Ghost Tabs | Merged into plan item 7 (R4, R7 folder dimming); Memory Saver is off in this tree so a dim without the Sleep verb would seldom show. | R6-15 |
| Better Unloaded Tabs | Merged into plan item 7 (Unload/Sleep verb and dim); its own toggle would duplicate Memory Saver's switch. | R6-15 |
| Customize Font Size | Merged into plan item 23 (one validated size, rows follow) instead of four free-form CSS strings. | R6-27 |
| Tab Text Size | Duplicate of Customize Font Size; merged into plan item 23. | R6-27 |
| Lean | Compact rows fold into plan item 23; the bookmark bar removal waits for import-to-pinned (Chromium shows the bar on the NTP regardless of kShowBookmarkBar); the bottom row stays as the drop and swipe surface. | R6-27, R6-28 |
| Better Find Bar | avg 5.0, build×1: the mixer mapping and edge alignment are taken into plan item 20 (U3, U4); the position, width and checkbox prefs are dropped. | R6-06 |
| Card-native find bar and link status (idea) | avg 5.67, build×1: the status pill is plan item 20; the find-bar reposition and the three-way link-status setting are dropped until a capture against Arc asks for them. | R6-06 |
| No Top Sites | avg 5.67, build×1: the kSearchSuggestEnabled default flip is plan item 22's Q7; masking providers in components/omnibox is upstream surface for a behaviour the field-trial defaults already give. | R6-26 |
| Bigger Mute Button | avg 5.67, build×1 (below both thresholds). The one verified bug — a playing essentials card loses its favicon because IsChildVisible hides icon_ while the alert shows — is worth a fixup into plan item 9's IsChildVisible hunk later (favicon plus a corner badge); the 'Mute Tab' menu row exists as CommandToggleSiteMuted. | R6-03 (D1: the favicon bug is R18, not a later fixup) |
| Audio Indicator Enhanced | avg 5.0, build×0: same badge-over-favicon fix as Bigger Mute Button; below threshold. | R6-03 (R18 is the same fix) |
| Audio TabIcon Plus | avg 5.0, build×1: same layout fix; below threshold, see Bigger Mute Button. | R6-03 (R18 is the same fix) |
| Improved Collapsed Tabs | avg 5.33, build×1: the rail's never-lay-out-close rule is taken as plan item 9's R3; the alert badge waits with the audio cluster; the rail itself is a Chromium state Arc lacks. | R6-03 |
| Add new tab urlbar icon | avg 4.33: the ambiguity it cues does not exist until ⌘L routes into the command bar; add the edit/new-tab mode in the K7 row as part of that change. | R6-11 (D2 lands ⌘L in the bar; the mode cue is in K12) |
| Zen Colored Picker | avg 5.33, build×1: as written it subclasses BubbleDialogDelegateView, which HANDOFF trap 6 says cannot be done outside Views in this tree; S-42 only needs the five swatches on the welcome step; a Skia colour pad is a later luxury. | R6-10 (D1: the five swatches on the welcome step) |
| Super Sleek UI | avg 4.67, maybe×3: only the scrim behind the command bar is Arc (one layer call, PeekView has one to reuse) and can ride plan item 1; the most-visited tiles contradict Arc's empty bar; edge-to-edge is rightly refused. | R6-11 (the scrim only, if it rides) |

### Below threshold (score or effort; nothing taken now) (14)

| Candidate | Synthesiser's reason | Now |
|---|---|---|
| Floating History | avg 5.67, maybe×3: Arc's Library at the bottom-left is [1.0] but L effort; plan item 13 builds the archive data layer it needs first, and the Library grows around it later. | grows around R6-24 later |
| Quietify | avg 4.0, maybe×1: an animated equaliser adds motion where a static badge does the job. | — |
| Media in the sidebar (idea) | avg 5.67, maybe×3: an L bundle whose favicon-replacement rule contradicts the badge design, and 'video follows you' leans on browser-initiated auto-PiP that upstream still ships as a dry run; split and spec first. | — |
| Pimp your PiP | avg 4.67: the auto pop-out is the Arc behaviour and belongs with the media idea; the overlay restyle touches an actively churned upstream window. | — |
| Smaller Compact Mode | avg 5.33, maybe×3: the third 'hidden' sidebar state is Arc's ⌘S but lives in Chromium's VerticalTabStripStateController and expand-on-hover overlay, both under active upstream development; decide after plan item 18 has landed and been retested. | decide after R6-25 |
| Cleaned URL bar | avg 5.33, build×1: PRODUCT routes ⌘L into the command bar at 1.0, which makes the omnibox popup transient; the mixer hunk only if ⌘L stays on the omnibox, and no blur setting. | D2 makes the omnibox popup transient |
| Tab Preview Enhanced | avg 5.33, build×1: the hover-card colour mapping and radius are a cheap mixer hunk to ride along a later theme pass; enabling kTabHoverCardImages means thumbnail capture on every tab hide and must be measured against the memory budget first. | — |
| SuperPins | avg 5.33, build×1: only the width-derived column count survives (a one-line change in the pinned_tab_container_view.cc hunk, probe at two widths); fold into Big Essentials when that is measured. | — |
| Big Essentials | avg 5.0, maybe×3: measure the icon against the Arc reference first; a crisp larger icon needs a large-favicon fetch threaded into TabData through upstream's favicon pipeline (M with rebase surface); try drawing the 32 px favicons Chromium already fetches before the LargeIconService route. | — |
| HidePlugins | avg 5.0, maybe×3: the puzzle container also hosts the site-access request chip and anchors popups, extensions are a hard requirement, and a default-off pref breaks settings T2; needs a design answer, and the toolbar may hide anyway under plan item 18. | R6-25 may hide the toolbar anyway |
| Animations Plus | avg 4.0: easing polish that must wait for plan item 24's gate; the one real gap, a folder-header hover tint, is a two-line fix worth doing on its own. | after R6-08 |
| One motion setting, and hover cards that speak only when the title was cut off | avg 4.67: overlaps plan item 24; the three-way scale reaches many upstream files for what macOS Reduce Motion already provides; the cut-off-only hover-card rule is the good part, noted for a later pass. | overlaps R6-08 |
| Clickable Scrollbar | avg 4.33: Arc's sidebar scrollbar is also an overlay, the change lands in the shared upstream RoundedScrollBar, and the macOS 'Show scroll bars' preference already covers the 'always' case; marginal gain. | — |
| Vertical Split Tab Groups | avg 3.33: Chromium already stacks the pair at narrow widths and round 5 #8 accepted the one-row form; an accent bar for a rare width is cosmetic. | — |

### Not Arc (parity says no, or only after parity) (14)

| Candidate | Synthesiser's reason |
|---|---|
| Disable Status Bar | avg 3.33, skip×3: Arc shows the hovered link; a remove-toggle for a useful indicator. The restyle is plan item 20. |
| A search engine per Space | avg 4.33: not parity, and the omnibox keyword-mode route is a hack over upstream autocomplete; the command-bar half is the only coherent part, after parity. |
| Reader: Chromium's immersive reading mode | avg 5.33, maybe×3: the engine is there (kImmersiveReadAnything on) but de-Googling its WebUI, removing HaTS and suggest-mode, and proving Read Aloud fetches nothing is a privacy audit plus WebUI CSS work on an actively developed feature; not parity. |
| Quiet titles | avg 5.0, maybe×3: stripping '(3)' counts is calm but rewrites every title and can hide information; needs the formatter table checked against real titles before a verdict, and only as a toggle after parity. |
| Quiet: one switch for sound, notifications and counts | avg 3.67: invented scope beyond parity; holding web notifications inside PlatformNotificationServiceImpl is invasive and ⌥⌘Q sits one key from ⌘Q. |
| Load Bar | avg 4.0: Arc's loading cue is the sidebar spinner; a per-tick repaint of the top container needs measuring and it adds a toggle and a moving element to the calm bar; the mute-orange hijack is exactly the noise to avoid. |
| Glass sidebar, riding upstream | avg 3.67: kGlassFrame is off, experimental and macOS-26-only with hit-testing caveats in upstream's own comments; Arc never blurred; must clear the memory and latency budgets; wait for upstream. |
| Transparent Zen | avg 3.0, skip×3: duplicate of Glass sidebar; the images, logo and animation bundle is not Arc and not Stedding. |
| sleek border | avg 3.33: Arc's card is borderless and the mixer removes the hairline on purpose; the contrast-gated corner case is tiny and adds page-colour plumbing into MultiContentsView for little value; revisit with toolbar T7. |
| Zen Back Forward | avg 3.0, skip×3: Arc shows both arrows with forward dimmed; an off-by-default toggle for a non-Arc behaviour breaks the settings convention. |
| Back Fwd Always Hidden | avg 2.67, skip×3: same need with a three-way dropdown and a history submenu to compensate; toolbar T1–T5 are settled. |
| Compact tabs title | avg 3.0, skip×3: monogram badges decorate a Chromium-only rail Arc lacks, plus a setting; the hover card already disambiguates. |
| Custom uiFont | avg 1.33, skip×3: Arc uses the system font, the candidate itself says do not ship, and a blanket typeface override is the re-skin VISION rules out. |
| Disable Rounded Corners | avg 1.0, skip×3: the card is the product's identity, Arc has no such option, and the radius is already a dev parameter for captures. |

### Not applicable here (nothing to build, or cannot be done in this tree) (2)

| Candidate | Synthesiser's reason |
|---|---|
| Tidy Popup | avg 3.33: macOS context menus are native NSMenu and round 4 signed off the views bubbles; a menu-colour mixer pass can ride a later theme pass but earns no patch. |
| Trackpad Animation | avg 1.0, skip×3: Chromium's history-swipe overlay already exists and Arc uses the same one; nothing to build. |

## Appendix A — every Zen mod

All 77 mods from the catalogue, alphabetical. "Has" is the evaluator's verdict on what
Stedding already has (yes / partial / no / n/a). "Disposition" is an `R6-NN` id, `built`
(already in the tree), or "not now" with the reason in a few words; the 23 mods the
synthesis listed nowhere are closed the way the critic's #33 says. "Key evidence" is a
one-line condensation of the evaluator's evidence field (paraphrased, not quoted).

| Mod | Need | Has | Disposition | Key evidence |
|---|---|---|---|---|
| Add new tab urlbar icon | When one text field serves both 'edit this tab's URL' and 'open a new tab', the user needs a visible mode cue so Enter does not replace the wrong page. | partial | R6-11 (K12 cue, D2) | The two modes sit on different surfaces today (⌘T bar, ⌘L omnibox); the ambiguity arrives with ⌘L in the bar. |
| Animations Plus | Hover and selection colour changes should ease instead of snapping, so the chrome feels alive and less flickery. | partial | not now: waits on the R6-08 gate | Rows and toolbar buttons already ease through GlowHoverController and ink drops; the command bar's chosen row and the folder header hover do not. |
| Audio Indicator Enhanced | See at a glance which sidebar tab is playing and mute it in one click, without the favicon disappearing under the speaker icon on essentials or icon-only tabs; a more polished indicator (hover-to-mute in place, muted state coloured). | partial | R6-03 (R18) | IsChildVisible hides a pinned tab's favicon while the alert shows, so a playing essential loses its icon; no spec row covers the indicator. |
| Audio TabIcon Plus | See at a glance which tab is playing or muted in every tab state (unfocused, discarded) and choose which side the indicator sits on. | partial | R6-03 (R18) | Same layout gap: in the 56 DIP rail the alert takes the single slot; Chromium's AlertIndicatorButton already mutes on click. |
| Back Fwd Always Hidden | Reclaim toolbar space and noise for users who navigate with mouse side buttons, trackpad swipe or ⌘[ / ⌘] and never click the arrows. | partial | not now: Arc shows both arrows | Only a forward-button pref exists (browser.show_forward_button) and it is not a settings toggle here; side buttons already navigate at content level. |
| Better Active Tab | The active tab must be unmistakable at a glance, even when the selected/hover tints or a theme wash the active background out. | yes | built (round 5 #4) | The active row is Arc's filled pill (text colour at 0x24 in dark, white card in light), captured in both modes; an accent bar would be drift. |
| Better CtrlTab Panel | A visible, well-styled Ctrl+Tab switcher over the recently used tabs (Firefox's MRU ctrlTab panel with previews), not a blind jump in strip order. | no | R6-12 | PRODUCT §1 [1.0] and unbuilt: ⌃⇥ is IDC_CYCLE_TO_NEXT_TAB in strip order; kCtrlTabMru is global across windows, Space-blind and draws nothing. |
| Better Find Bar | A ⌘F find bar that reads as part of the window: floating, in the browser's own colours, placeable, with the extra option checkboxes hideable. | partial | R6-06 (U3, U4) | Chromium's find bar is already a floating bubble, but kColorFindBar* are GM3 grey and stedding_color_mixer.cc does not map them. |
| Better Letterboxing | Firefox's resistFingerprinting letterboxing (viewport rounded to fixed sizes with grey margins) looks ugly in Zen; the mod rounds the letterboxed viewport and tints the margins with the accent gradient. | n/a | not now: Firefox-only | Chromium has no letterboxing and no resistFingerprinting; the rounded card on a mat already exists (patch 0002). |
| Better Tab Indicators | See at a glance which row is active (a coloured border) and which tabs are unloaded (dimmed title). | partial | R6-15 (R4) | The active look was settled in round 5; only the discard ring marks an unloaded tab and the title is never dimmed (TabView::UpdateColors). |
| Better UniExtBtn | The extensions toolbar button should not look foreign next to the extension icons; swap it for the browser's own mark or a custom image. | n/a | not now: cosmetic | The button already draws through kColorToolbarButtonIcon like its neighbours; Arc uses a puzzle piece too. |
| Better Unloaded Tabs | Tell at a glance which sidebar rows are not loaded (they will be slow on click and cost no memory), so unloaded tabs read differently from live ones. | partial | R6-15 | TabData::is_tab_discarded reaches the row only as the favicon ring; UpdateColors never looks at the discard state. |
| Big Essentials | Essentials are icon-only cards, so the icon must be big enough to recognise without a label: a 32 px icon with 16 px padding and a grid that fits more cards per row on a wide sidebar. | partial | not now: measure against Arc first | Cards are 50 DIP with an 18 DIP favicon fetched at 16 DIP×scale, so scaling blurs; Arc's icons are roughly 20–22 px in ~44 px cards. |
| Bigger Mute Button | See which sidebar tab is playing sound and mute it in one click, even when the sidebar is collapsed to icons or the tab is an essentials card. | partial | R6-03 (R18) | Upstream does most of it; the verified bug is the essentials card losing its favicon while the alert shows. |
| Bleeding Corners Fix | No light fringe at the rounded corners of the page: Zen rounds the page with CSS border-radius on a container, and the page's html background bleeds through the anti-aliased edge; the mod adds a clip-path at some GPU cost. | yes | built; add a corner probe (critic #33) | Corners are compositor clips (SetIsFastRoundedCorner), not CSS; the page cannot draw outside the mask; window.json probes the corners. |
| Bookmark Toolbar Tweaks | A bookmarks bar that stays out of the way: centred, icon-only, transparent, auto-hidden until hover or omnibox focus. | n/a | R6-28 | PRODUCT §1 "No bookmarks" is unbuilt: BookmarkBarView, ⇧⌘B and the new-tab-page bar are untouched by the series. |
| Cleaned URL bar | The address-bar dropdown should look like a floating frosted panel that matches the rest of the sidebar-style chrome, with a chosen-row colour that is not a saturated accent block. | partial | not now: omnibox popup transient (D2) | The ⌘T bar already is the frosted panel (K6); the ⌘L omnibox popup is untouched Chromium. |
| Cleaner Bookmark Menu | The bookmarks menu should be a list of bookmarks, not a management panel (sidebar, search, show-all, toolbar toggles). | partial | R6-14 (M3), R6-28 | The equivalent is the app menu's "Bookmarks and lists" submenu, untouched and relied on for import (S-30). |
| Clickable Scrollbar | The sidebar's tab list scrollbar is a thin overlay that is hard to see and grab; the user wants a real, clickable, draggable scrollbar when the sidebar is expanded (the mod switches scrollbar-width from thin to auto; its second rule, disabling window dragging on the toolbox, is a Firefox quirk). | partial | not now: overlay is Arc's too | Both sidebar lists use tabs::RoundedScrollBar, a 5 DIP overlay thumb with no track click; no spec row covers sidebar scrolling. |
| Colored container tab | See which container (isolated cookie jar / identity) the active tab belongs to. | no | not now: profiles ADR (R6-31 G5) | Chromium has no containers; the parity item is PRODUCT §2 "Per-Space Profiles" [1.0], and SpaceModel holds name, colour and icon only. |
| Compact tabs title | In the icon-only (collapsed) sidebar, tabs with the same favicon (five GitHub PRs, three Docs) are indistinguishable; show the first 1-3 title characters so they can be told apart without hovering. | partial | not now: rail is not Arc | The collapsed rail hides titles; the only disambiguation is the hover card; Arc has no icon-only mode. |
| Container Halo | See a tab's container identity on every row, active or not, as a full outline rather than Firefox's hairline. | no | not now: profiles ADR (R6-31 G5) | Same: no containers; identity in Stedding is the Space, shown on the ground (B11), not on a row border. |
| Custom MenuButton | Replace the app-menu (hamburger) button's glyph with the browser's own icon or a user-supplied image so the control reads as 'the browser' rather than a generic menu. | n/a | not now: cosmetic | BrowserAppMenuButton keeps kMoreVertIcon; Arc has no in-toolbar menu button at all. |
| Custom Statusbar | Tune the link-URL readout's radius, margin, border thickness and text/border/background colours (including gradients). | no | R6-06 (U1; knobs dropped) | status_bubble_views.cc is vanilla; the knobs conflict with QUALITY and settings T2's one-switch rule. |
| Custom uiFont | Use a personal typeface (serif or any installed family, with an optional text shadow) across the browser chrome. | no | not now: system font is Arc's | Every views label takes the platform font through ChromeTypographyProvider; no pref; parity does not ask for it. |
| CustomCursor | Personalise the pointer over the browser with a preset or a cursor image pulled from a URL or base64 string. | n/a | not now: Firefox-only | userChrome.css cursor rule; Chromium takes the system pointer; the mod fetches its cursor image over the network. |
| Customize Font Size | Readable sidebar text for the individual user: the workspace title, tab titles, the find bar and the footer icons each get a free-form font-size string. | no | R6-27 (Y2) | Tab titles are a Label at the default 12 pt; the Clear label is a hard-coded 11 pt; row height is a feature param, not a pref. |
| Disable Rounded Corners | Square content corners for people who find the rounded web-view card fussy; the readme also claims a GPU saving from dropping Zen's clip-path. | partial | not now: the card is the identity | The 12 DIP radius is already a dev parameter (contents_corner_radius); Chromium rounds through a layer clip, so the GPU claim does not carry. |
| Disable Status Bar | Remove the URL bubble that pops up at the bottom-left of the page on link hover: it flickers on pointer sweeps and covers page content in the corner. | no | not now: Arc shows the hovered link | status_bubble_views.cc untouched; one bubble per contents view; no pref anywhere. |
| DoubleClickless | No accidental new tabs from double- or middle-clicking empty space in the tab sidebar. | n/a | not now: cannot occur here | The vertical strip opens no tab on blank double- or middle-clicks; only tab_view.cc (middle-click close) and folder_view.cc (rename) handle those. |
| Extensions List | Find an extension by name in the extensions popup instead of guessing from an icon grid. | yes | built | ExtensionsMenuMainPageView is already a vertical list of icon, name, pin and site-access rows. |
| Floating History | History as a quick, themed panel over the window, toggled in place with a search field, instead of a full chrome://history tab. | no | not now: Library grows on R6-24 | ⌘Y opens chrome://history as a tab; the History side panel is off (kByDateHistoryInSidePanel) and Chrome-styled; archive A7 is the gap. |
| Floating Status Bar | The hovered-link URL readout should look like part of a rounded floating page card, not a square bar welded into the window corner. | no | R6-06 | StatusView rounds one corner with radius 4 and sits flush at the card's bottom-left, drawing over the rounded corner; no round-4/5 capture hovered a link. |
| Ghost Tabs | Tell unloaded (discarded) tabs and folders from live ones at a glance, so the user knows which rows will reload on click. | partial | R6-15 (R4, R7) | Memory Saver is off in this tree; the discard ring never dims titles or folders; Stedding's answer to stale tabs is the archive. |
| Hidden Reset Button | A pinned tab that has drifted from its pinned page should be one click from returning to it, without a permanent extra button on the row: hide the reset control behind the favicon and reveal it on hover. This is Arc's 'navigated away' indicator plus favicon-click reset. | no | R6-16 (H7) | Neither pin tier stores a URL; peek decides by the tab's current site, not a stored pinned site. |
| Hide Extension Name | On an extension's own page Firefox's identity box prints the extension's name as a label in the URL bar, taking width from the URL; the user wants only the icon. | n/a | not now: Chromium shows no label | On chrome-extension:// pages the chip is only the puzzle icon; the real gap is the inverse (the id shown as the host). |
| Hide Inactive Workspaces | A Space switcher row that stays tidy with many Spaces: show the active one, reveal the rest on hover. | partial | R6-18 | SpaceSwitcherView::Rebuild lays every chip at 24 DIP with a 12 DIP gap and no overflow rule; chips clip at about eight Spaces. |
| Hide Toolbar | Reclaim the address row: hide the toolbar/navbar entirely, reveal it on hover at the top edge with an animation, and choose this in settings (three preferences: enable, animate, top separation). | no | R6-25 (T10, T11) | T1–T6 keep a 33 DIP row always on; PRODUCT §3 records Arc's model as no always-visible URL bar with ⌘⇧D to reveal one. |
| HidePlugins | Hide the extensions puzzle-piece toolbar button; extensions are reached from the menu and the toolbar stays bare. | no | not now: needs a design answer | ExtensionsToolbarDesktop hides the container only with no extensions installed; it also hosts the site-access chip and anchors popups. |
| Improved Collapsed Tabs | With the sidebar collapsed to a rail, still see which tab is active and which plays audio, not close tabs by accident, and get a hint of the title. | partial | R6-03 (R3) | In the rail the layout shows exactly one child in the order close, alert, icon, so hovering the active tab swaps its icon for the close glyph. |
| Lean | Reclaim sidebar rows and toolbar width: show secondary chrome (bottom buttons, translate and page-action icons, the bookmarks bar, the workspace indicator) only on hover, drop the zoom icon, move pinned extensions into the sidebar. | partial | R6-27, R6-28 | Most of the density is baseline already; the bottom row stays as the drag and swipe surface; the bookmark bar still exists. |
| Left close button | Not closing a tab by accident when an expand-on-hover sidebar unfolds under the pointer (Zen with the sidebar on the right: the close button lands under the cursor). | n/a | not now: sidebar is left-only | Expand-on-hover unfolds rightwards, so the pointer lands on the favicon column, not the close glyph. |
| Left Side Glance Buttons | Zen's Glance (its peek) floats its action buttons in a container at one edge of the window; the mod moves them to the other edge for left-sidebar or left-handed layouts. | n/a | not now: Zen-specific layout | Peek keeps its three actions in a 44 DIP header inside the card, each with a key (P7, P9). |
| Load Bar | See page-load progress at the content edge (a sidebar favicon throbber is tiny) and see at once that the current tab is muted. | partial | not now: Arc's cue is the spinner | Loading shows only as the TabIcon throbber and the reload/stop button; nothing paints load progress in top chrome. |
| NavBar Margin | Breathing room above and below the address row; Zen's compact nav bar feels cramped. | yes | built (33 DIP row, T1–T5) | The row is 25 + 3 + 3 DIP measured against Arc and sits on the card since round 5. |
| No pinned tab reset btn | A pinned tab has a home URL and a way back to it, but the affordance should not be a hover button cluttering every pinned row (Zen's .tab-reset-button); the user wants the reset without the noise. | no | R6-16 | No pinned URL exists in SpaceModel; PRODUCT §1 lists the favicon reset and the navigated-away indicator as [1.0]. |
| No Sidebar Scrollbar | A tab list without a permanent scrollbar taking width and attention, but still scrollable. | yes | built | TabStripView::SetScrollViewProperties gives both lists an overlay RoundedScrollBar that takes no width at rest. |
| No Top Sites | Focusing the empty address bar should not push a list of top sites or suggestions at you: a calm bar, and no surprise history on a shared screen. | partial | R6-26 (Q7) | The ⌘T bar stops autocomplete on an empty query; the ⌘L omnibox's most-visited and zero-suggest providers are off by feature default or need Google. |
| NoHighlightSplit | In split view, no coloured outline around the active pane; the two panes should read as equal cards. | no | R6-05 | ContentsContainerOutline paints a 1 px kColorSysOutline ring on the active pane; stedding_color_mixer.cc does not touch the ids. |
| Old navigation buttons | Undo Zen's restyled back/forward/reload glyphs and get Firefox's stock buttons back. | n/a | not now: Firefox-only | Stedding keeps Chromium's back, forward and reload; the Arc reference shows the same three glyphs. |
| Only Close On Hover | Quiet rows: no permanent close glyph on the active tab; the close control appears only under the pointer. | no | R6-03 | IsChildVisible shows the close button when active_ \|\| hovered_or_focused, so the active row always carries the glyph; Arc shows it on hover only. |
| Only Reset On Hover | A pinned tab that has drifted from its pinned page should offer a way back without a permanently visible button cluttering the active row. | no | R6-16 (H6) | No pinned URL exists; same-site drift (a GitHub pin on a PR page) has no way back. |
| Pimp your PiP | A picture-in-picture window that looks like Arc's mini player: no button discs, close and back-to-tab in the corners, a full dim on hover, a thin progress bar that thickens on hover. | partial | not now: with the media idea, later | VideoOverlayWindowViews already has the controls; the auto pop-out is browser-initiated auto-PiP, still a dry run upstream. |
| Private Mode Highlighting | Make a private (incognito) window unmistakable at a glance: a coloured toolbar, a border around the page and an icon, so nobody types into the wrong window. | no | R6-32 (V4) | Stedding removes both incognito cues: the mixer paints the same navy for every dark key and patch 0002 hides the avatar for every window. |
| Quietify | An obvious, pleasant 'this tab is playing sound' signal: an animated equaliser in place of the favicon while audio plays, a flat-bars glyph when muted, click to mute; in the collapsed sidebar the favicon comes back on hover with the indicator shrinking to a corner badge. | partial | not now: a static badge suffices | AlertIndicatorButton shows a static speaker with a 200 ms fade; the throb exists for recording only. |
| Remove Tab X | Stop accidental closes: no close glyph on tab rows (all, or only pinned ones); close by middle-click or ⌘W instead. | partial | R6-16 (H3), R6-03 | Space-pinned rows still show × on hover and pressing it closes the tab outright; Arc unloads and keeps the entry. |
| Secret Theme | A joke: enable it and wait for something silly to happen. | n/a | not now: a joke | The readme says it is a joke; VISION's craft bar rules out gags. |
| Sidebar Expand on Hover | Keep the sidebar as a favicon rail and expand it when the pointer rests on it, with control over widths, expand and collapse delays, animation speed, essentials shown vertically in the rail, faded sleeping tabs and a hidden workspace header. | yes | built (settings T6, T7) | Settings T6 binds vertical_tabs.expand_on_hover_enabled; T7 sets the width; the rail shows one essential per row. |
| sleek border | A faint 1 px semi-transparent hairline around the URL field and the page container so edges read as edges without a heavy frame, a stronger border on hover, and a darker focused omnibox popup. | partial | not now: the card is borderless | The mixer removes the toolbar/content hairline on purpose; the omnibox hover tint (T5) is the affordance the mod wants. |
| Smaller Compact Mode | When the sidebar is hidden and slides in on hover, make the floating panel shorter (vertically centred, 70vh) and let it be narrower than the default minimum. | partial | not now: decide after R6-25 | ⌘S collapses to Chromium's 56 DIP rail, never to nothing; Arc's ⌘S hides the sidebar completely. |
| smaller zen toast popup | Transient notices that do not shout: small, translucent, out of the way, readable on hover. | no | R6-07 | Stedding shows no toasts; Chromium 153's toast framework is unused; the background-tab toast has no counterpart (the sidebar row is the feedback). |
| Super Sleek UI | A denser window: most-visited grid when the address field is empty, a pop-out focused address field that dims the page, a shorter toolbar, no gutters or rounded corners around the page, no border on the unfocused address field. | partial | not now: the scrim may ride R6-11 | The 33 DIP toolbar and no omnibox pill are done; nothing dims the page behind the ⌘T bar; edge-to-edge is refused. |
| SuperPins | Control the density and look of the essentials grid and pinned rows: card width, gap, column count, essentials-as-icons vs rows, position, borders and backgrounds, lazy restore of pinned tabs, dimming of unloaded tabs, favicon and workspace icon sizes, when the separator shows. | partial | not now: column count with Big Essentials | Only the width-derived column count survives (clamp(children, 1, 2) in pinned_tab_container_view.cc). |
| Tab Numbers | See which number Cmd-1..Cmd-9 will hit so keyboard jumps are reliable; numbers must count only essentials plus the active workspace's tabs. | no | R6-13 | No numbers anywhere, and SelectNumberedTab never asks IsTabHidden, so ⌘3 in Space B can activate an unseen tab of Space A. |
| Tab Preview Enhanced | The tab hover card should look native to the browser: the same (Space-tinted) ground, rounded like the rest of the window, a padded thumbnail, no hard border. | partial | not now: measure memory first | Hover cards are Chromium's GoogleGrey900/white and images are off on macOS (kTabHoverCardImages); enabling them captures a thumbnail on every tab hide. |
| Tab Text Size | Readability and density: change the sidebar's text size for tab titles, the workspace (Space) header and folder labels without editing a theme. | no | R6-27 (Y2) | Title, Space title and folder labels read no preference; row height is a feature param. |
| Tab title fixes | Tab titles at 13 px instead of Zen's 11, and tabs that are not loaded (restored but pending, or unloaded) visibly dimmer (icon and title at about 55%) so live tabs stand out at a glance. | partial | R6-15, R6-27 | Default 12 pt with no setting; session-restored tabs are created discarded and the state reaches the view but never dims the title. |
| Tidy Popup | Popup menus and panels that look current: rounded panel, separators rendered as whitespace instead of lines, compact rounded item rows with a strong hover colour, and an optional custom hover colour. | partial | not now: native NSMenu on macOS | Every Stedding context menu is a native NSMenu (MenuRunner routes CONTEXT_MENU to Cocoa); views bubbles were signed off in round 4. |
| TitleBarButton UI Tweaks | On custom-frame platforms the minimize/maximize/close buttons should be smaller, rounded and hover-tinted to match a rounded, tinted UI, with a red close hover. | n/a | not now: native traffic lights | macOS uses native caption buttons; Chromium draws its own only on Windows and Linux, and there is no Windows build yet. |
| Trackpad Animation | Physical feedback for two-finger history swipes: the page nudges and scales with the gesture, with tunable easing and shadows. | partial | built | ChromeRenderWidgetHostViewMacHistorySwiper drives HistoryOverlayController natively; Arc uses the same overlay. |
| Transparent Zen | A window the desktop blurs through (macOS vibrancy), plus a bundle: custom ground colour, background image, empty-tab logo, push-or-mask compact sidebar, tab-switch, URL-bar and trackpad animations with a smoothness preset. | no | not now: Arc never blurred | The ground is painted opaque by SteddingWindowBackground, matching Arc; upstream's kGlassFrame is off and macOS-26-only. |
| Vertical Split Tab Groups | A split's sidebar row is cramped with two tabs side by side at sidebar width; the user wants the pair stacked, with a marker showing they are one item. | partial | not now: one row accepted (round 5 #8) | SplitTabView already stacks the pair at narrow widths; only the together-marker is missing. |
| Winter Spirit | Seasonal decoration: animated snowflakes drifting over the window background, with size and speed knobs. | n/a | not now: seasonal cosmetic | A tiled-PNG overlay; nothing in PRODUCT, UI-SPEC or the Arc reference. |
| Zen Back Forward | Fewer dead controls: hide the back and forward buttons while they cannot do anything. | no | not now: Arc shows both arrows | ToolbarView only toggles enabled state; SetForwardButtonVisibility exists and nothing calls it; toolbar T1–T5 follow Arc. |
| Zen Colored Picker | When choosing a workspace or theme colour, see the real spectrum (a rainbow pad with a grid/frame) instead of a washed-out gradient, so you know what you are picking. | partial | R6-10 (five swatches) | Colours come from five named swatches in the chip menu; the model accepts any SkColor; no reusable colour chooser on Mac. |
| Zen Context Menu | Shorter page and tab context menus: hide items the user never uses, drop icons and separators, tint menus with the workspace colour, reorder the tab menu, prefer copying a tracking-free link. | partial | R6-14, R6-04 (L2) | The tab menu is Chromium's full list plus Stedding's three rows; the page menu is untouched by any patch. |
| Zen Minimal Exit Menu | On Windows/Linux, replace the boxy native minimise/maximise/close buttons with macOS-style coloured circles that suit a sidebar browser. | n/a | not now: macOS first, native | The traffic lights are native; the Windows/Linux frame files are untouched; the mod disables itself on macOS. |

## Appendix B — ideas beyond the catalogue

The 30 ideas from the three lenses (ten each), with the judges' average and the
disposition. Effort and value are the lens's own.

| Lens | Idea | Need | Effort / value | Judges | Disposition |
|---|---|---|---|---|---|
| 1 | Sidebar density presets with one text-size step | No compact mode or text-size control; every row kind has its own hard number. | M / 4 | 6 (maybe×3) | R6-27 |
| 1 | Sleeping tabs: a readable unloaded look plus 'Sleep' as a verb, per tab and per Space | A discarded tab shows only a thin favicon ring; no way to put a tab or a left Space to sleep. | M / 5 | 7 (build×3) | R6-15 |
| 1 | Arc's pinned-tab lifecycle: ⌘W sleeps a pinned tab, the favicon resets it | ⌘W deletes a Space pin; no pinned URL is stored, so no favicon reset and no navigated-away dot. | M / 5 | 8.33 (build×3) | R6-16 |
| 1 | Hold ⌘ to see row numbers, and ⌘1–9 that count what you can see | SelectNumberedTab never asks IsTabHidden, so ⌘N can hit a hidden Space; nobody can learn which row is 3. | M / 4 | 7 (build×3) | R6-13 |
| 1 | ⌃⇥ most-recent switcher with a hold-to-see strip, and Arc's ⌥⌘↑/↓ travel keys | ⌃⇥ walks strip order; ⌥⌘↑/↓ change pane focus invisibly; moving a tab is fn+⌃⇧↑ on a laptop. | M / 5 | 7.33 (build×3) | R6-12 |
| 1 | Inline tab rename that survives restore | PRODUCT §1 "Rename tab" [1.0]; Chromium has no custom title; folders already have the textfield pattern. | M / 4 | 7.33 (build×3) | R6-17 |
| 1 | Card-native find bar and link status | ⌘F drops Chrome's find box under the toolbar and the link status bubble sits square in the card's rounded corner. | M / 3 | 5.67 (build×1, maybe×2) | R6-06 (the pill; the find reposition and the three-way setting dropped) |
| 1 | Media in the sidebar: mute on the row, a now-playing strip, and video that follows you | The speaker competes with the close glyph; the media button lives top-right; Arc pops video out when you leave the tab. | L / 4 | 5.67 (maybe×3) | not now: an L bundle; split and spec first (the badge is R6-03 R18) |
| 1 | Context menus with Stedding's verbs first and Google's gone | The tab, page and app menus still carry Google, Glic, sync and group items that do nothing here. | M / 4 | 6.67 (build×3) | R6-14 |
| 1 | One motion setting, and hover cards that speak only when the title was cut off | Every strip insert, hover glow and hover card animates and obeys only macOS Reduce Motion. | S / 3 | 4.67 (maybe×2, skip×1) | not now: overlaps R6-08; the cut-off-only hover-card rule noted for a later pass |
| 2 | Import from Arc: Spaces, pinned tabs, folders and favorites from StorableSidebar.json | An Arc switcher's whole working life is one local JSON file; rebuilding Spaces by hand is the reason to close the DMG. | M / 5 | 8.33 (build×3) | R6-22 |
| 2 | Arc's keyboard for Spaces: ⌃1–⌃9 to a Space, ⌥⌘←/→ previous/next Space, ⌥⌘↑/↓ tabs, ⇧⌘K Clear, ⌘D pin | Every Space gesture exists except the keyboard; ⌃2 does nothing and ⌥⌘→ selects the next tab. | S / 5 | 8.67 (build×3) | R6-02 |
| 2 | Command bar actions mode: ⇥ after ⌘T (or ⇧⌘P) lists every Stedding and Chromium command with its key | QUALITY gates every feature on the bar, yet the bar lists tabs and omnibox suggestions only. | M / 5 | 9 (build×3) | R6-11 |
| 2 | Air Traffic Control: route sites to Spaces, with the rule made from the tab you are holding | PRODUCT §2 [1.0]; a GitHub link from Slack lands in whichever Space is active. | M / 4 | 7.33 (build×3) | R6-23 |
| 2 | Little window: links from other apps open small, with Move to Space, ⌘O and ⇧⌘O | A link from Mail becomes a full tab in the last window's active Space; Little Arc is not Peek (EVIDENCE.md). | M / 4 | 6.33 (build×1, maybe×2) | R6-30 |
| 2 | Pinned tabs have a home: navigated-away dot, favicon click resets, 'Set pinned URL to this page', hover card with a thumbnail | Neither pin tier remembers a URL; same-site drift leaves a pinned tab elsewhere for good. | M / 4 | 6.33 (maybe×2, build×1) | R6-16 (merged; the thumbnail dropped) |
| 2 | Archived view: what auto-archive and Clear closed, per Space, with the reason, restorable to its Space and searchable from ⌘T | The sweep and Clear drop tabs into the recently-closed list, which forgets Space, folder and reason. | M / 4 | 7.33 (build×3) | R6-24 |
| 2 | Rename a tab in place: double-click the title, persisted across restarts, shown in the sidebar and matched by ⌘T | PRODUCT §1 [1.0]; nothing in the tree renames a tab. | M / 4 | 6 (skip×1, build×1, maybe×1) | R6-17 (merged) |
| 2 | ⇧⌘C copies the URL, ⌥⇧⌘C copies a Markdown link with a rich-text twin, and the bar says Copied | IDC_COPY_URL has no mac chord and ⇧⌘C opens DevTools; no Markdown copy; no feedback. | S / 4 | 6.67 (build×2, maybe×1) | R6-04 |
| 2 | One sidebar for every window: ⌘N opens a window on the same Spaces, essentials and pinned tabs | SpaceModel is per window, so ⌘N yields a lone "Space 1" with no essentials; reads as data loss. | L / 4 | 6.33 (maybe×2, build×1) | R6-31 |
| 3 | The bar goes with the sidebar | ⌘S collapses the strip but the 33 DIP page bar stays, so the hidden state is still chrome. | M / 5 | 7 (build×2, maybe×1) | R6-25 (T9 dropped by D2) |
| 3 | Private windows wear a different coat | A private window has the same ground and chips; Spaces, tint and the archiver all run in it. | M / 4 | 8 (build×3) | R6-32 |
| 3 | Reader: Chromium's immersive reading mode, made Stedding's | Reading mode ships behind ⌥⌘R with Google fonts, a HaTS survey and voice downloads; no entry point. | M / 4 | 5.33 (maybe×3) | not now: not parity; a privacy audit plus WebUI work on an active feature |
| 3 | Tracker-free defaults as one settings block | PRIVACY.md promises defaults the tree does not have (third-party cookies, HTTPS-First, error-page lookups, GPC). | M / 5 | 7.67 (build×3) | R6-26 |
| 3 | Copy clean link on Shift-Cmd-C, Markdown on Option-Shift-Cmd-C | PRODUCT §1 lists copy URL and Markdown [1.0]; CopyURL writes the URL verbatim, tracking parameters included. | S / 4 | 6.67 (skip×1, build×2) | R6-04 (merged) |
| 3 | A search engine per Space | A Work Space on Kagi and a Personal Space on DuckDuckGo; neither Arc nor Zen offers it. | M / 3 | 4.33 (maybe×2, skip×1) | not now: not parity; the omnibox keyword route is a hack over upstream autocomplete |
| 3 | Quiet titles | Rows read "(3) Slack \| Acme"; every count is a pull at the start of every row. | S / 3 | 5 (maybe×3) | not now: after parity, as a toggle; check the formatter against real titles first |
| 3 | Quiet: one switch for sound, notifications and counts | Focus means no tab plays and no site notifies; today that is a mute click per tab. | M / 3 | 3.67 (maybe×1, skip×2) | not now: invented scope; holding notifications is invasive and ⌥⌘Q sits beside ⌘Q |
| 3 | Glass sidebar, riding upstream | Transparent Zen is the most-installed mod; Chromium 153 carries kGlassFrame off by default. | M / 3 | 3.67 (maybe×1, skip×2) | not now: kGlassFrame is off, experimental, macOS-26-only; Arc never blurred |
| 3 | Motion follows the system | QUALITY requires respecting reduce motion; nothing in the series checks it. | S / 2 | 5.67 (build×2, maybe×1) | R6-08 |

## Appendix C — judges

The three judges' scores merged by candidate, highest average first. Verdicts are
build / maybe / skip in judge order; a dash means that judge did not score it. The 23
mods the synthesis listed nowhere were not judged (Appendix A closes them).

| Candidate | Average | Judge 1 | Judge 2 | Judge 3 | Scores |
|---|---|---|---|---|---|
| Command bar actions mode: ⇥ after ⌘T (or ⇧⌘P) lists every Stedding and Chromium command with its key | 9 | build | build | build | 9, 9, 9 |
| Arc's keyboard for Spaces: ⌃1–⌃9 to a Space, ⌥⌘←/→ previous/next Space, ⌥⌘↑/↓ tabs, ⇧⌘K Clear, ⌘D pin | 8.67 | build | build | build | 9, 9, 8 |
| Arc's pinned-tab lifecycle: ⌘W sleeps a pinned tab, the favicon resets it | 8.33 | build | build | build | 9, 8, 8 |
| Import from Arc: Spaces, pinned tabs, folders and favorites from StorableSidebar.json | 8.33 | build | build | build | 9, 8, 8 |
| Private windows wear a different coat | 8 | build | build | build | 8, 8, 8 |
| Tracker-free defaults as one settings block | 7.67 | build | build | build | 8, 7, 8 |
| Air Traffic Control: route sites to Spaces, with the rule made from the tab you are holding | 7.33 | build | build | build | 8, 7, 7 |
| Archived view: what auto-archive and Clear closed, per Space, with the reason, restorable to its Space and searchable from ⌘T | 7.33 | build | build | build | 8, 7, 7 |
| Inline tab rename that survives restore | 7.33 | build | build | build | 8, 7, 7 |
| Only Close On Hover | 7.33 | build | build | build | 7, 7, 8 |
| ⌃⇥ most-recent switcher with a hold-to-see strip, and Arc's ⌥⌘↑/↓ travel keys | 7.33 | build | build | build | 8, 7, 7 |
| Hold ⌘ to see row numbers, and ⌘1–9 that count what you can see | 7 | build | build | build | 7, 7, 7 |
| Sleeping tabs: a readable unloaded look plus 'Sleep' as a verb, per tab and per Space | 7 | build | build | build | 7, 7, 7 |
| The bar goes with the sidebar | 7 | build | maybe | build | 8, 6, 7 |
| Context menus with Stedding's verbs first and Google's gone | 6.67 | build | build | build | 7, 7, 6 |
| Copy clean link on Shift-Cmd-C, Markdown on Option-Shift-Cmd-C | 6.67 | skip | build | build | 5, 7, 8 |
| ⇧⌘C copies the URL, ⌥⇧⌘C copies a Markdown link with a rich-text twin, and the bar says Copied | 6.67 | build | build | maybe | 8, 6, 6 |
| Hide Inactive Workspaces | 6.33 | build | build | maybe | 7, 7, 5 |
| Little window: links from other apps open small, with Move to Space, ⌘O and ⇧⌘O | 6.33 | build | maybe | maybe | 7, 6, 6 |
| NoHighlightSplit | 6.33 | build | build | build | 6, 6, 7 |
| One sidebar for every window: ⌘N opens a window on the same Spaces, essentials and pinned tabs | 6.33 | maybe | build | maybe | 7, 7, 5 |
| Pinned tabs have a home: navigated-away dot, favicon click resets, 'Set pinned URL to this page', hover card with a thumbnail | 6.33 | maybe | build | maybe | 6, 7, 6 |
| Hide Toolbar | 6 | maybe | build | maybe | 6, 7, 5 |
| Private Mode Highlighting | 6 | skip | build | maybe | 5, 7, 6 |
| Rename a tab in place: double-click the title, persisted across restarts, shown in the sidebar and matched by ⌘T | 6 | skip | build | maybe | 5, 7, 6 |
| Sidebar density presets with one text-size step | 6 | maybe | maybe | maybe | 6, 6, 6 |
| smaller zen toast popup | 6 | build | build | build | 6, 6, 6 |
| Bigger Mute Button | 5.67 | build | maybe | maybe | 6, 6, 5 |
| Card-native find bar and link status | 5.67 | build | maybe | maybe | 6, 6, 5 |
| Floating History | 5.67 | maybe | maybe | maybe | 6, 6, 5 |
| Floating Status Bar | 5.67 | skip | build | build | 5, 6, 6 |
| Hidden Reset Button | 5.67 | skip | build | maybe | 5, 7, 5 |
| Media in the sidebar: mute on the row, a now-playing strip, and video that follows you | 5.67 | maybe | maybe | maybe | 6, 6, 5 |
| Motion follows the system | 5.67 | build | build | maybe | 6, 6, 5 |
| No Top Sites | 5.67 | build | maybe | maybe | 6, 6, 5 |
| Better CtrlTab Panel | 5.33 | skip | maybe | maybe | 5, 6, 5 |
| Cleaned URL bar | 5.33 | maybe | maybe | build | 5, 5, 6 |
| Improved Collapsed Tabs | 5.33 | maybe | maybe | build | 5, 5, 6 |
| Reader: Chromium's immersive reading mode, made Stedding's | 5.33 | maybe | maybe | maybe | 6, 5, 5 |
| Smaller Compact Mode | 5.33 | maybe | maybe | maybe | 6, 5, 5 |
| SuperPins | 5.33 | maybe | maybe | build | 5, 5, 6 |
| Tab Numbers | 5.33 | skip | maybe | maybe | 5, 6, 5 |
| Tab Preview Enhanced | 5.33 | maybe | build | maybe | 5, 6, 5 |
| Zen Colored Picker | 5.33 | build | maybe | skip | 6, 6, 4 |
| Audio Indicator Enhanced | 5 | skip | maybe | maybe | 4, 6, 5 |
| Audio TabIcon Plus | 5 | skip | maybe | build | 4, 5, 6 |
| Better Find Bar | 5 | skip | maybe | build | 4, 5, 6 |
| Better Tab Indicators | 5 | skip | maybe | maybe | 4, 6, 5 |
| Big Essentials | 5 | maybe | maybe | maybe | 5, 5, 5 |
| HidePlugins | 5 | maybe | maybe | maybe | 5, 5, 5 |
| Quiet titles | 5 | maybe | maybe | maybe | 4, 5, 6 |
| Zen Context Menu | 5 | skip | maybe | skip | 5, 6, 4 |
| Better Unloaded Tabs | 4.67 | skip | maybe | skip | 5, 5, 4 |
| Lean | 4.67 | maybe | maybe | skip | 5, 5, 4 |
| No pinned tab reset btn | 4.67 | skip | maybe | skip | 4, 6, 4 |
| One motion setting, and hover cards that speak only when the title was cut off | 4.67 | maybe | maybe | skip | 5, 5, 4 |
| Only Reset On Hover | 4.67 | skip | maybe | skip | 4, 6, 4 |
| Pimp your PiP | 4.67 | maybe | maybe | skip | 5, 5, 4 |
| Super Sleek UI | 4.67 | maybe | maybe | maybe | 5, 4, 5 |
| A search engine per Space | 4.33 | maybe | maybe | skip | 5, 4, 4 |
| Add new tab urlbar icon | 4.33 | maybe | maybe | skip | 5, 5, 3 |
| Clickable Scrollbar | 4.33 | maybe | maybe | skip | 5, 5, 3 |
| Customize Font Size | 4.33 | skip | maybe | skip | 4, 5, 4 |
| Remove Tab X | 4.33 | skip | maybe | skip | 4, 5, 4 |
| Tab Text Size | 4.33 | skip | maybe | skip | 4, 5, 4 |
| Tab title fixes | 4.33 | skip | maybe | skip | 4, 5, 4 |
| Animations Plus | 4 | maybe | maybe | skip | 4, 4, 4 |
| Cleaner Bookmark Menu | 4 | skip | maybe | skip | 4, 5, 3 |
| Load Bar | 4 | skip | maybe | maybe | 3, 4, 5 |
| Quietify | 4 | — | maybe | — | 4 |
| Ghost Tabs | 3.67 | skip | maybe | skip | 3, 4, 4 |
| Glass sidebar, riding upstream | 3.67 | maybe | skip | skip | 4, 3, 4 |
| Quiet: one switch for sound, notifications and counts | 3.67 | maybe | skip | skip | 4, 3, 4 |
| Disable Status Bar | 3.33 | skip | skip | skip | 3, 3, 4 |
| sleek border | 3.33 | skip | maybe | skip | 3, 4, 3 |
| Tidy Popup | 3.33 | skip | maybe | skip | 3, 4, 3 |
| Vertical Split Tab Groups | 3.33 | skip | maybe | skip | 3, 4, 3 |
| Compact tabs title | 3 | skip | skip | skip | 3, 3, 3 |
| Transparent Zen | 3 | skip | skip | skip | 3, 3, 3 |
| Zen Back Forward | 3 | skip | skip | skip | 3, 3, 3 |
| Back Fwd Always Hidden | 2.67 | skip | skip | skip | 3, 2, 3 |
| Custom uiFont | 1.33 | skip | skip | skip | 1, 1, 2 |
| Disable Rounded Corners | 1 | skip | skip | skip | 1, 1, 1 |
| Trackpad Animation | 1 | skip | skip | skip | 1, 1, 1 |

## Appendix D — the critic, verbatim

The completeness critic's output, unchanged, with one disposition line after each
numbered point (adopted as a decision, folded into an item, or declined with the reason).

> RESULT:
>
> 1. [correction, bug] "Close Other Tabs" / "Close Tabs to the Right" are not Space-scoped: `TabStripModel::GetIndicesClosedByCommand` (`/Users/Shared/chromium/src/chrome/browser/ui/tabs/tab_strip_model.cc:3605`) never asks `IsTabHidden`, so item 6's kept "Close Others" and new "Clear Below" close tabs in other Spaces and inside collapsed folders. Same family as R10; add `TabStripModelTest.CloseOthersStaysInsideTheSpace` to item 4 or 6.
>
> → Disposition: folded into R6-14 (M5); test named there.
>
> 2. [missing, [1.0]] ⌘L into the command bar (PRODUCT §3): items 1 and 18 both build around the omnibox keeping ⌘L (T9 floats a pill for it) while PRODUCT removes the URL bar at 1.0. Decide now as K12 (⌘L opens the bar prefilled with the URL selected; Escape returns) or record the divergence; otherwise item 18 T9 is work that 1.0 deletes.
>
> → Disposition: adopted as D2 (R6-11 K12; R6-25 T9 dropped).
>
> 3. [missing, [1.0]] Imported bookmarks → pinned tabs and folders (PRODUCT §1). Welcome W3 imports bookmarks into a model nothing shows except Chromium's bar on the new tab page and the star in the location bar; item 11 covers Arc only. Add: each bookmark folder becomes a Space-pinned folder tree, then hide the bar, the star and the Bookmarks submenu (closes the "Lean"/"Cleaner Bookmark Menu" leftovers).
>
> → Disposition: adopted: new item R6-28.
>
> 4. [missing, [1.0]] Multi-select (PRODUCT §12): ⌘/⇧-click then act. Item 6's menu shows no plurals ("Close 3 Tabs", "Move 3 Tabs to ▸"), and items 1, 2 (⌘D), 5, 7, 12 all say "the active tab". `TabMenuModel` already reads `selection_model()` (tab_menu_model.cc:111); specify selection semantics once and cite it from each item.
>
> → Disposition: adopted as D3: new item R6-20; each item cites it.
>
> 5. [missing, [1.0]] Split view as a unit (PRODUCT §4): no item pins, Space-pins, renames or restores a split as one row, and no item names a split rule for ⌘W (8), ⌘D (2), rename (10), ⌘N counting (4), ⌃⇥ cells (3), Sleep (7), Move to Space (1/12). One "splits.md" spec, referenced by each.
>
> → Disposition: adopted: new spec R6-19 (splits.md), cited by R6-12, R6-13, R6-15, R6-16, R6-17, R6-20.
>
> 6. [missing] The in-product shortcut reference (QUALITY.md:102, ROADMAP.md:201) does not exist (grep: only the two citations), yet items 2, 5, 15, 18 "record divergences in the shortcut reference". Ship it first: a Shortcuts block in chrome://settings/stedding generated from the accelerator tables, with divergence rows; remapping (PRODUCT §12 [1.0]) later.
>
> → Disposition: adopted: new item R6-01, first in wave 1.
>
> 7. [missing, [1.0]] Sidebar backups (PRODUCT §1; EVIDENCE #2 "restore that never loses a tab"): periodic JSON snapshots of Spaces/pins/folders on Arc's schedule, "Restore sidebar…" in settings. Make the file item 11's plan format so import/export round-trip; it is also Export Space ([1.0]) and the honest file-based answer to sync (475 upvotes).
>
> → Disposition: adopted: new item R6-29, sharing R6-22's file format.
>
> 8. [correction] Bigger Mute Button's verified bug (a playing essentials card loses its favicon: `IsChildVisible` hides `icon_`) is a shipped defect against PRODUCT "Audio indicator and mute [1.0]", not a "later fixup". Fold into item 9's `IsChildVisible` hunk: favicon plus corner badge, click mutes, right-click mutes a silent tab, works in a split.
>
> → Disposition: adopted (D1): folded into R6-03 as R18.
>
> 9. [missing, [1.0]] Per-Space Profiles (PRODUCT §2): absent. The two undispositioned container mods (Container Halo, Colored container tab) are the demand signal. At minimum item 16's ADR 0016 must say a registry Space can carry a profile id so the model does not preclude it.
>
> → Disposition: adopted (D1): R6-31 G5; the ADR must say a registry Space can carry a profile id.
>
> 10. [missing] Space reorder by dragging a chip (PRODUCT §2 [1.0]): not built (`SpaceModel` has no MoveSpace, space_model.h) and not planned. Add B27 to item 14, with the Space menu "Move left/right" as the keyboard path.
>
> → Disposition: adopted (D1): R6-18 B27.
>
> 11. [missing] Backlog rows S-41 (download progress on the sidebar button), S-42 (Space colour on welcome; the "Zen Colored Picker" skip says five swatches is the ask), S-43 (About version) have no owner in the plan; 21 closes S-40 only.
>
> → Disposition: adopted (D1): R6-09 (S-43), R6-10 (S-42), R6-21 (S-41).
>
> 12. [under-spec, 2] ⌃1–⌃9 collide with macOS Mission Control "Switch to Desktop N", on by default once a second desktop exists; Arc users hit this. Record in the reference and welcome step 5, and give the Spaces menu rows so the chords are discoverable when eaten.
>
> → Disposition: adopted as D5 (R6-02 B30, R6-01 Z3).
>
> 13. [under-spec, 2] ⌘D on an essential (Chromium-pinned) tab: refuse, unpin to Space-pin, or no-op (F8 refuses folders for pins; B21 says nothing). ⇧⌘K and ⌃1–9 in a private window (V2: no Spaces) must be disabled in the controller.
>
> → Disposition: adopted as D4 (R6-02 B28, B29).
>
> 14. [under-spec, 6] Item 6 hides tab groups from the menu but leaves the group chords live (⌥⌘P/C/W/X/Z, global_keyboard_shortcuts_mac.mm:169-178, called "untouched" in item 1). Remove them in the same hunk or a rebase re-exposes a hidden feature by keyboard.
>
> → Disposition: adopted (D1): R6-14 M6.
>
> 15. [under-spec, 6] Four menus, not one: essentials card (Remove from Essentials, no Move to Space, no folder), folder header, split row, Space-pinned row (Unpin, Reset to Pinned Page, Make This the Pinned Page). M1 lists only the plain row.
>
> → Disposition: adopted (D1): R6-14 M7.
>
> 16. [under-spec, 1] ⇥ with text already typed (Arc filters to actions from any state; ⇧⇥ back), Escape in actions mode (back to tabs or close), the row set in private and popup windows, actions with no target (essentials in "Move to Space", a peek open), and dropdown prefs (archive hours, sleep minutes, density) that "one on/off row per stedding.* preference" cannot express.
>
> → Disposition: adopted as D6 (R6-11 K13–K17).
>
> 17. [under-spec, 4] R11's badge slot on essentials cards (grid, no close slot) and in the collapsed rail; whether a split row counts as one ⌘N or two; sleeping rows numbered the same.
>
> → Disposition: adopted as D7 (R6-13 R19).
>
> 18. [under-spec, 8] An essentials card is icon-only, so H5's "favicon column" is the whole card: a click on a drifted essential would reset instead of activate. Arc activates and shows the reset on hover; say which. H3 with a Space holding only pins: ⌘W sleeps the last visible tab and B4 opens a new tab — intended?
>
> → Disposition: adopted as D8 (R6-16 H10, H11); the side-by-side check in Arc comes first.
>
> 19. [under-spec, 11] Arc's sidebar JSON also holds split-view items, archived items and the per-Space profile binding: say each is mapped or dropped. Arc rewrites the file while running: read a copy and warn if Arc is open. Map `windowTheme` to the nearest Stedding swatch; cap favorites at 12 (nothing in the tree caps essentials); make a second import idempotent (Arc item id as the key).
>
> → Disposition: adopted as D9 (R6-22 I7–I12).
>
> 20. [under-spec, 18] Where extension actions (⌘E cycles them, PRODUCT §12 [1.0]), the global-media button, page-info and permission chips live when the row is hidden; Arc parks extensions in the sidebar. T9 in immersive fullscreen (the overlay owns the row) and the split mini-toolbars with no row above them.
>
> → Disposition: adopted as D10 (R6-25 T13); the split mini-toolbars stay TBD.
>
> 21. [under-spec, 21] Toast placement: Chromium anchors top-centre under the toolbar, Arc bottom-centre of the content; decide once, since C6 declares this the style for every later toast, and item 18 removes the anchor view.
>
> → Disposition: open: TBD in R6-07 (decide the placement once, before C6).
>
> 22. [under-spec, 22] PRIVACY.md's own to-do table is only half covered: translate off, preloading (`net.network_prediction_options`) off, network time off, component-updater endpoint, dummy API keys. Say each is in the Q block or why not; Q1 (third-party cookies) needs the site-breakage row visible in the block, not only the ADR.
>
> → Disposition: open: TBD in R6-26 (a Q row or a one-line reason per PRIVACY.md to-do).
>
> 23. [under-spec, 3] What a split is in the strip (one cell or two), tabs inside collapsed folders (hidden: skipped or listed), ⌃⇥ while a peek or the command bar is open, and the strip's ⌃-release prototype needs a fallback if `flagsChanged` never reaches Views (a tap-only mode).
>
> → Disposition: partly: the split is R6-19 J2; the rest TBD in R6-12 before X3's prototype.
>
> 24. [under-spec, 5] ⇧⌘C inside a peek copies the peek's URL (Arc does; the peek has no address row); the Markdown title uses item 10's custom name or the page title — say which; L5's toast in a peek anchors where.
>
> → Disposition: open: TBD in R6-04.
>
> 25. [under-spec, 10] Rename a split row as a unit; rename from ⌘T while the sidebar is collapsed (no slot for the textfield: expand first or edit in a bubble); essentials rename only reaches the hover card, say so in the UI.
>
> → Disposition: partly: the split is R6-19 J1; the collapsed-sidebar and essentials cases TBD in R6-17.
>
> 26. [under-spec, 12] Multi-window (16): routes are per profile but external_default names a Space in which window; a route whose site is Space-pinned in the target Space: open a duplicate or activate the pin.
>
> → Disposition: open: TBD, answered with R6-31 (multi-window) and checked in Arc first (the critic's unsure line).
>
> 27. [under-spec, 7] Sleeping a tab that is in a split (Chromium may refuse to discard); the essentials card's slept look (card alpha) and the collapsed rail's dimmed icon are unnamed; R6's timer per window vs. per registry after 16.
>
> → Disposition: partly: the split is R6-19 J4; the slept looks TBD in R6-15; the timer scope decided with R6-31.
>
> 28. [under-spec, 13] ⇧⌘T already restores to the tab's Space (`browser_tabrestore.cc:90`, `RestoreSpaceFromExtraData`); A8 should ride that path and add the folder path, which it does not restore today. The "Archived" row in the collapsed rail (icon), dark and light.
>
> → Disposition: folded into R6-24 as implementation guidance (A8 rides RestoreSpaceFromExtraData).
>
> 29. [cross-cutting] Every new chord lands only in the mac tables (accelerators_cocoa.mm, global_keyboard_shortcuts_mac.mm); M8 Windows redoes all of it. Bind cross-platform ids in accelerator_table.cc with platform modifiers where possible, or state that the mac tables are deliberate.
>
> → Disposition: open: TBD; R6-01 Z2 states whether the mac tables are deliberate before the first keyboard patch.
>
> 30. [cross-cutting] Light/dark and fullscreen captures are named for 7, 9, 14, 20, 21 but not for the new surfaces in 3 (strip), 4 (badges), 10 (textfield), 13 (archive WebUI), 15 (little-window bar), 18 (pill); QUALITY requires both plus a probe for each.
>
> → Disposition: adopted as a rule (How to continue, 7): every new surface captured dark and light with a probe.
>
> 31. [cross-cutting] No item names a VoiceOver role or a keyboard-only path (QUALITY accessibility gate): the ⌃⇥ strip, ⌘-held badges, inline rename, the archive page, the little-window bar, the Space chips as dots.
>
> → Disposition: adopted as a rule (How to continue, 7): a VoiceOver role and keyboard path per new surface before "built".
>
> 32. [missing, cheap] "New Documents" (PRODUCT §7 [1.0]): one URL pref and a ⌘T action "New document" in item 1; "Collapse Pinned Tabs" (§1 [1.0]): a collapsible pinned run, one row in item 8 or 2.
>
> → Disposition: declined for round 6: neither "New Documents" nor "Collapse Pinned Tabs" is in the decisions; both stay PRODUCT §7/§1 [1.0] items for a later round.
>
> 33. [completeness] 23 catalogue mods are in neither list; close them: Container Halo, Colored container tab → per-Space profiles (9); Bookmark Toolbar Tweaks → no bookmark bar (3); Bleeding Corners Fix → add a probe for the anti-aliased ring at the card corners over a white page in dark mode (window.json has none); Sidebar Expand on Hover → already settings T6; Custom Statusbar → item 20; Better Active Tab → settled in round 5 #4; Firefox-only or cosmetic, skip with one line each: Left close button, Left Side Glance Buttons, DoubleClickless, Hide Extension Name, Extensions List, Better Letterboxing, No Sidebar Scrollbar, NavBar Margin, Old navigation buttons, TitleBarButton UI Tweaks, Zen Minimal Exit Menu, Custom MenuButton, Better UniExtBtn, CustomCursor, Secret Theme, Winter Spirit.
>
> → Disposition: adopted: Appendix A closes all 23 the way this point says.
>
> 34. [better than the mod] Item 21: give the capture toast a thumbnail and "Show in Finder" plus Arc's bottom placement; item 14: the name pill on a dot hover, not only on chips; item 6: chords drawn in the menu (already planned) plus plural verbs (4); item 11: the round-trip export (7) makes Stedding's Arc import strictly better than Arc's own, which imports nothing from Arc.
>
> → Disposition: partly: thumbnail and Show in Finder are in C5 (placement is #21); the name pill on dots joins B25; chords plus plurals are M1/M7 with R6-20; the round trip is R6-29.
>
> unsure: Arc's exact behaviour for a click on a drifted Favorite (activate vs. reset) and whether Arc routes an ATC match into an existing pinned tab — confirm by side-by-side in Arc before writing H5 and D2.

Disposition of the unsure line: the two checks are the first step of R6-16 (H10) and R6-23 (D2); neither test is written before Arc is looked at side by side.

