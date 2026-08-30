# Product Specification

This is the feature specification for Stedding Browser 1.0 and beyond. Every feature
is marked **[1.0]** or **[post-1.0]**. A feature marked [1.0] ships complete — behavior,
keyboard shortcuts, settings entry, edge cases — or 1.0 does not ship. See
`docs/QUALITY.md` for the bar and `docs/ROADMAP.md` for sequencing.

**Keyboard-first is a core principle.** Every feature below includes its shortcut
story. All shortcuts listed are defaults and are remappable in Settings → Shortcuts.
Shortcuts are given in macOS notation; Windows/Linux substitute Ctrl for Cmd unless
noted otherwise.

## Sidebar [1.0]

The sidebar replaces the horizontal tab strip entirely. It contains, top to bottom:
the current space's pinned tabs, its regular ("today") tabs, and the space switcher.

- **Vertical tabs.** Tabs are rows: favicon, title, close affordance on hover, audio
  indicator when playing. Active tab is visually distinct. Tab order is manual.
- **Pinned tabs.** Pinning moves a tab to the pinned section. Pinned tabs persist
  across restarts, never auto-archive, and keep their assigned URL: navigating away
  within a pinned tab is allowed, but activating it again after it has been closed
  reloads its pinned URL. Closing a pinned tab unloads it without removing it.
- **Today tabs with auto-archive.** Regular tabs are ephemeral by design. A tab
  untouched for a configurable period (default: 12 hours; options include 24 hours,
  7 days, never) is archived automatically — removed from the sidebar, recorded in
  the archive timeline (see Tab management). Nothing is deleted; archive is always
  recoverable.
- **Drag organization.** Tabs reorder by drag, move between pinned and today sections
  by drag, and move to another space by dragging onto that space's name in the
  switcher. Dragging a tab into the page area creates a split (see Split view).
- **Folders.** Pinned tabs can be grouped into named, collapsible folders. [1.0]
- **Collapse.** The sidebar collapses to hide all chrome, leaving only the page.
  A hover zone at the window edge reveals it temporarily. Collapsed state persists
  per window.

Keyboard: `Cmd+S` toggle sidebar; `Cmd+W` archive current tab; `Cmd+Shift+W` close
window; `Ctrl+Tab` / `Ctrl+Shift+Tab` next/previous tab in most-recently-used order
(hold to see a switcher overlay); `Cmd+1`–`Cmd+8` jump to Nth tab, `Cmd+9` last tab;
`Cmd+D` pin/unpin current tab (bookmark-add is folded into pinning); arrow keys move
through the sidebar when it has focus, `Enter` activates, `Space` previews.

## Workspaces (Spaces) [1.0]

A space is a named set of pinned and today tabs with its own visual identity.
Typical use: Work / Personal / Project X.

- **Separate tab sets.** Each space has independent pinned tabs, today tabs, and
  folders. Switching spaces swaps the sidebar content; loaded pages stay loaded.
- **Profile association.** By default all spaces share one Chromium profile (cookies,
  storage, extensions). A space can instead be bound to a separate profile at
  creation, giving it isolated cookies, logins, and extension set — true
  work/personal separation. Binding is per-space and explicit; the UI states plainly
  which spaces share state. Moving a tab between spaces with different profiles
  reloads it in the target profile.
- **Per-space accent color.** Each space has an accent color used in the sidebar
  background tint, active-tab highlight, and window accents, so the active space is
  identifiable at a glance (see Appearance).
- **Per-space defaults.** New-tab search engine and download directory are settable
  per space. [post-1.0]
- **Default containers.** A space bound to a separate profile acts as a container:
  links opened from within it stay in it. Rules that route specific domains to a
  specific space ("always open github.com in Work") are [post-1.0].
- **Fast switching.** Switching is instant — no profile relaunch, even for
  profile-bound spaces; all profiles are live within one browser process tree.

Keyboard: `Ctrl+1`–`Ctrl+9` jump to space by position; `Cmd+Option+Left/Right`
previous/next space; space switching is also first-class in the command bar
(type the space name). `Cmd+Shift+N` creates a new space. On Windows/Linux,
space switching is `Alt+1`–`Alt+9` instead: the Cmd→Ctrl substitution gives
`Ctrl+1`–`Ctrl+8` to the Nth-tab jump, so spaces move to `Alt`.

## Command bar [1.0]

One entry point for everything, in the spirit of a code editor's command palette.
Opens as a centered overlay. There is no separate, always-visible URL bar; the
current URL is shown compactly at the top of the sidebar and expands on focus.

A single input, fuzzy-matched across ranked providers:

1. **Open tabs** — switch to a matching tab in any space (labeled with its space).
2. **URL / search** — anything URL-like navigates; anything else searches with the
   default engine. Explicit prefixes force a provider (`?` search, `#` tabs,
   `>` commands, `@` history, `*` bookmarks/pinned).
3. **History and bookmarks/pinned** — fuzzy over title and URL.
4. **Browser commands** — every menu action and every feature in this document is
   invocable by name ("Split right", "Archive tab", "New space", "Toggle dark
   mode"). Each result shows its shortcut, which is how users discover shortcuts.
5. **Extension actions** — installed extensions' actions and their registered
   commands appear as results.

Behavior: results update per keystroke; `Enter` acts on the top result; `Cmd+Enter`
opens a URL/search result in a new tab; ranking blends match quality with recency
and frequency of use. Matching is local; nothing typed is sent anywhere except the
chosen search engine on an explicit search, and search suggestions are off by
default (`docs/PRIVACY.md`).

Keyboard: `Cmd+T` opens the command bar (new-tab intent); `Cmd+L` opens it with the
current URL selected (edit intent); `Esc` closes; `Up/Down` move selection; `Tab`
cycles provider filters.

## Split view [1.0]

- **Creation.** Drag a tab from the sidebar to the left or right half of the page
  area, or use the command bar ("Split right with…"), or `Cmd+Shift+D` to split the
  current tab with the next tab.
- **Panes.** Two panes side by side at 1.0. Three or more panes and 2×2 grids are
  [post-1.0]. Each pane is a full tab: its own navigation, its own history, its own
  audio. The focused pane has a visible highlight and receives all keyboard input,
  including shortcuts like `Cmd+L` and `Cmd+W` (which closes only that pane,
  collapsing the split when one pane remains).
- **Resizing.** Panes resize by dragging the divider; double-click the divider to
  reset to 50/50.
- **Persistence.** A split is a sidebar item: it appears as one grouped row, is
  restored across restarts, and archives as a unit.

Keyboard: `Cmd+Shift+D` split with next tab; `Cmd+Option+Up/Down` cycle pane focus
(`Cmd+Option+Left/Right` is taken by space switching); "Swap panes", "Close pane",
and "Break split into tabs" are command-bar commands with assignable shortcuts.

## Tab management: archive and restore [1.0]

- **Archive timeline.** Every archived tab (auto-archived, or closed with `Cmd+W`)
  is recorded with title, URL, favicon, space, and archive time. The archive view
  is a reverse-chronological, searchable timeline grouped by day, filterable by
  space. Retention is configurable (default: 30 days, options up to forever);
  history proper is separate and unaffected.
- **Restore.** `Enter` on an archive entry reopens the tab in its original space.
  `Cmd+Shift+T` restores the most recently archived/closed tab, repeatedly, exactly
  like Chrome's reopen-closed-tab, and also restores closed windows.
- **Session safety.** Quitting and relaunching restores all spaces, pinned tabs,
  today tabs, and splits. Crash recovery restores the same.

Keyboard: `Cmd+Shift+E` opens the archive view; within it, type to search, arrows
to move, `Enter` restore, `Cmd+Enter` restore without switching to it.

## Settings [1.0]

- Opens in a tab. A single search field filters all settings live, including
  Chromium-inherited ones; every result deep-links to the exact control.
- **Sane defaults.** Privacy-respecting defaults per `docs/PRIVACY.md` (no
  telemetry, no search suggestions, tracker blocking on). Auto-archive at 12 hours.
  Defaults are chosen so a new user never needs Settings on day one.
- **Everything keyboardable.** Every control is reachable by Tab/arrows and operable
  by keyboard. Settings → Shortcuts lists every command, shows conflicts, and
  allows remapping; a "restore defaults" action exists per shortcut and globally.

Keyboard: `Cmd+,` opens Settings with the search field focused.

## Import [1.0]

First-run offers import from **Chrome, Arc, and Brave** (macOS profile locations at
1.0; Windows/Linux follow their platform releases). Import is re-runnable later
from Settings.

- **Bookmarks, history, open tabs.** Imported directly. Arc import maps spaces to
  spaces and pinned tabs to pinned tabs; Chrome/Brave bookmark folders can be
  converted to pinned-tab folders or kept as bookmarks.
- **Passwords — honest constraints.** Chromium-family browsers encrypt stored
  passwords with an OS-keychain-protected key. Import therefore triggers OS
  authentication prompts (macOS will ask for the login keychain / user password,
  attributed to the source browser), and can only work while the source profile is
  on the same machine and user account. If access is denied, we say exactly what
  failed and fall back to guiding a CSV export/import from the source browser,
  with a one-click secure delete of the CSV afterwards. We never claim a seamless
  password migration that the OS does not permit.
- **Extensions — re-install flow.** Extension binaries and their local data are not
  copied. Import reads the source profile's extension list and presents it with
  checkboxes; confirming installs each selected extension fresh from the Chrome
  Web Store. Extensions absent from the store (sideloaded/enterprise) are listed
  as not importable, with their IDs shown.
- **Cookies/sessions** are not imported at 1.0; users re-log-in. [post-1.0: opt-in
  session import where the OS permits.]

Keyboard: the import wizard is fully operable by keyboard: arrows/`Space` toggle
items, `Enter` advances, `Esc` cancels.

## Extensions [1.0]

Full Chrome Web Store compatibility is a hard requirement (`AGENTS.md`). Users
install from the Web Store directly; extension APIs, keyboard commands
(`chrome.commands`), context menus, and DevTools integrations behave as in Chrome.
Extension toolbar actions live at the bottom of the sidebar and can be hidden
per-extension; hidden or not, every action remains invocable from the command bar.
No custom extension store, no allowlist, no "verified" tier at 1.0.

## Media: picture-in-picture [1.0]

Any page video can pop into a floating always-on-top PiP window (site permission
not required; this is a user action). The PiP window offers play/pause, seek,
volume, and return-to-tab, and survives tab archiving while playing. Auto-PiP when
switching away from a playing tab is off by default, available in Settings.

Keyboard: `Cmd+Option+P` toggles PiP for the active tab's playing video; inside the
PiP window `Space` play/pause and arrow keys seek.

## Appearance [1.0]

- **Light/dark** follows the OS by default; forceable either way in Settings.
- **Per-space accents** as described under Workspaces: each space picks an accent
  from a curated palette or a custom color; the accent tints sidebar and highlights
  in both light and dark modes with contrast maintained.
- **Themes.** 1.0 ships light, dark, and per-space accents only. Full theming
  (user-defined palettes, community themes) is [post-1.0]. Chrome Web Store themes
  are not supported; they target a horizontal-tab layout that does not exist here,
  and partial support would look broken.
- **Density.** Compact/comfortable sidebar density toggle. [1.0]

Keyboard: "Toggle dark mode" and "Edit space color" are command-bar commands;
`Cmd+Shift+L` toggles light/dark override.

## Developer niceties

- **Flags page [1.0].** `stedding://flags` (Chromium's flags mechanism, inherited)
  plus a small, documented set of Stedding-specific flags. Experimental features
  ship behind flags before they ship by default.
- **Custom CSS/JS per site [post-1.0].** User stylesheets and scripts scoped by
  domain, managed in Settings, stored locally, with an obvious kill switch. Until
  then, existing Web Store extensions (e.g. user-style managers) cover this.
- **stedding:// pages [1.0].** Internal pages (settings, flags, archive, version)
  use the `stedding://` scheme; `chrome://` equivalents redirect.

## Scope summary

| Area | 1.0 | Post-1.0 |
|---|---|---|
| Sidebar | Vertical/pinned/today tabs, auto-archive, folders, drag, collapse | — |
| Spaces | Tab sets, optional profile binding, accents, fast switch | Domain→space rules, per-space search/downloads |
| Command bar | All five providers, fuzzy matching, prefixes | Custom user commands |
| Split view | Two panes, drag-to-split, resize, persistence | 3+ panes, grids |
| Tab management | Archive timeline, search, restore, session restore | — |
| Settings | Searchable, keyboardable, remappable shortcuts | Settings sync |
| Import | Chrome/Arc/Brave; bookmarks, history, tabs, passwords (keychain-honest), extension re-install | Opt-in session import |
| Extensions | Full Chrome Web Store compatibility | — |
| Media | Picture-in-picture | Auto-PiP refinements |
| Appearance | Light/dark, per-space accents, density | Full theming |
| Developer | Flags page, stedding:// pages | Per-site CSS/JS |
