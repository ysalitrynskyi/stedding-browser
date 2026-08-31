# Product specification

**Stedding targets full functional parity with Arc**, per
`decisions/0011-full-arc-parity.md`. This document is the inventory of what that means,
written from Arc's own documentation rather than from recollection, and using Arc's
terminology for Arc's concepts so it can be checked against the thing it copies.

Arc is a fixed target: its maker put it in maintenance mode in May 2025 and moved to
Dia (`COMPETITORS.md`). That is what makes parity finishable.

## How to read this

Every feature carries a tier:

| Tier | Meaning |
|---|---|
| **[1.0]** | Required for parity. Ships before 1.0. |
| **[post-1.0]** | Real Arc behaviour, deferred deliberately, with the reason stated. |
| **[needs decision]** | Parity here conflicts with a documented out-of-scope item in `ROADMAP.md`, or requires infrastructure we do not have. Listed, not silently dropped. |
| **[not applicable]** | Exists in Arc but is a property of Arc's business, not a browser capability. |
| **[deferred]** | Real Arc behaviour, kept in this document, but not in the first releases. Each says why and what would bring it back. |

Where Arc's behaviour is macOS-only, that is noted — convenient, since we are macOS
first (`decisions/0006-platform-order-macos-first.md`).

Shortcuts are Arc's documented macOS shortcuts. Ours may differ where they collide with
Chromium bindings; every deliberate divergence belongs in the in-product shortcut
reference (`QUALITY.md`).

---

## 1. Sidebar and tabs

The sidebar is the primary surface. It has, top to bottom: **Favorites**, the Space
title, **Pinned Tabs**, a horizontal divider, **Unpinned Tabs**, and at the bottom the
Space icons, the Library, and a `+` control.

- **Sidebar** **[1.0]** — vertical tab strip replacing the horizontal strip. Show/hide
  with `⌘S`. State persists.
- **Pinned Tabs** **[1.0]** — saved per Space, above the divider, never auto-archived.
  `⌘D` pins. Arc describes them as between an app and a bookmark: navigating *within*
  the site stays in the tab; **a link that would leave the site opens Peek instead of
  replacing the pinned page**. Clicking the favicon resets the tab to its pinned URL.
- **Favorites** **[1.0]** — pinned tabs visible in *every* Space, shown above Space
  titles, **capped at 12**. Distinct from Pinned Tabs; a spec that conflates the two
  gets the model wrong.
- **Unpinned Tabs** **[1.0]** — below the divider, auto-archived when idle.
  `⌘⇧K` clears them as a set.
- **Folders** **[1.0]** — group tabs; **tabs in folders do not auto-archive**. Created
  from `+`. Rename, move, delete from the folder title's context menu. Drag to add.
- **No bookmarks** **[1.0]** — Arc has none, by design. Pinned Tabs replace them.
  Imported bookmarks land as pinned tabs and folders.
- **Tab switching** **[1.0]** — `⌘⌥↑/↓` moves in sidebar order; `⌘1`…`⌘9` jumps to tab
  N; `⌃⇥` cycles the five most recently visited.
- **Favicons** **[1.0]** — per tab; a "navigated away" indicator appears when a pinned
  tab has left its URL, and the favicon is the reset control.
- **Audio indicator and mute** **[1.0]** — click to mute; right-click mutes a tab that
  is not currently playing; mutable from within a Split View.
- **Collapse Pinned Tabs** **[1.0]** — hide the pinned list without hiding the sidebar.
  Requires the Space to be named.
- **Previews on hover** **[post-1.0]** — hovering a pinned/favorited tab glances the
  site: recent mail, upcoming calendar events, open PRs. Deferred because each
  supported site is a bespoke integration; the hover affordance itself is [1.0].
- **Rename tab** **[1.0]** — double-click.
- **Drag tab out → Blank Window** **[1.0]** — a genuinely separate window, distinct
  from a Space-synced one.
- **Sidebar backups** **[1.0]** — restore prior sidebar states: 10 for today, 1/day for
  10 days, 1/week for a month, 1/month for a year. Distinct from the tab Archive.
- **Copy URL, and copy as Markdown** **[1.0]** — `⌘⇧C`.
- **Reopen closed tab** **[1.0]** — `⌘⇧T`.

## 2. Spaces

- **Spaces** **[1.0]** — distinct browsing areas, each with its own pinned section,
  unpinned section, theme and icon. `⌃1`…`⌃N` focuses a Space; two-finger swipe in the
  sidebar switches; icons live at the sidebar bottom.
- **Create, rename, reorder** **[1.0]** — `+` creates; rename from the menu bar;
  drag the Space icon to reorder.
- **Theme and icon** **[1.0]** — per-Space colour theme picker. The same picker also
  sets app-wide light/dark/automatic.
- **Per-Space Profiles** **[1.0]** — bind a Space to a profile. A profile scopes
  logins, cookies, history, archive timing, default-browser choice, favorites and
  extensions. New profiles start empty.
- **Move tabs between Spaces** **[1.0]** — command bar "Move to [Space]", right-click,
  or drag sideways.
- **Air Traffic Control** **[1.0]** — rules routing URLs to Spaces: *contains* or
  *is equal to* → destination Space, plus a default destination for links opened from
  other applications. This is one of Arc's most distinctive features and is easy to
  overlook.
- **Live Folders (GitHub)** **[post-1.0]** — a sidebar folder auto-populated with your
  open pull requests, filterable by author, draft state or repository. A bespoke
  integration; deferred, not dropped.
- **Live Calendars** **[post-1.0]** — a pinned calendar shows a countdown to the next
  event and a Join button. Same reasoning.
- **Share Space** **[needs decision]** — publishes a snapshot of a Space to a public
  URL. Requires hosting we do not have, and it is a publishing feature with privacy
  consequences (shared links cannot be deleted by the sharer). The local half —
  exporting a Space — is [1.0].
- **Share Quote** **[needs decision]** — same: a hosted link whose preview image
  contains the quoted text.

## 3. Command Bar

- **Command Bar** **[1.0]** — Arc's combined new-tab, URL bar, search, tab switcher and
  action palette. `⌘T` opens it; `⌘L` opens it targeting the current tab's URL. There is
  no always-visible URL bar.
- **Actions mode** **[1.0]** — `⇥` immediately after `⌘T` filters to actions. Every
  Stedding feature must be reachable here; that is already a `QUALITY.md` gate.
- **Site Search** **[1.0]** — one- or two-letter shortcuts that search a site directly
  from the command bar, configurable with a `%s` URL template.
- **Full URL in Toolbar** **[1.0]** — `⌘⇧D` reveals a toolbar with the full URL, for
  people who want one.
- **Instant Links** **[needs decision]** — `⇧↵` opens the top result instead of the
  results page. The non-AI half is a lucky-style navigation; the "Folder of …" variant
  is AI. See §8.
- **Ranking** **[1.0]** — Arc never documented its ranking function. Ours will be
  specified rather than inherited, since we cannot copy what was never published.

## 4. Split View

- **Split View** **[1.0]** — multiple tabs in one window, **horizontal or vertical**.
  Created by shortcut, by dragging a sidebar tab to the centre, or from the command bar.
- **A split is a tab** **[1.0]** — it appears in the sidebar as a single item and can be
  pinned, favorited and renamed as a unit. This is the part most clones miss.
- **Persistence** **[1.0]** — returning to that sidebar item restores the split.

Note: this supersedes the earlier "exactly two panes at 1.0" scope. Arc supports more,
and parity is the target.

## 5. Transient windows

- **Peek** **[1.0]** — a link from a pinned or favorited tab opens in a transient
  overlay rather than navigating the pinned tab away. Expand to a real tab with `⌘O`,
  promote into a split, or dismiss by clicking outside. **Peek is what makes pinned
  tabs behave like apps**; without it, pinning is just a bookmark.
- **Little Arc** **[1.0]** — a small window for links opened from *other applications*,
  to read and dismiss or triage into the sidebar. `⌘⌥N` opens one anywhere. Archives on
  its own schedule (6 hours by default, against 12 for normal tabs).
- **Folder peek** **[post-1.0]** — hover a closed folder, search or scroll its contents,
  open one tab without expanding the folder.
- **Blank Window** **[1.0]** — a fully separate window not sharing the Space's tabs.
- **Incognito Window** **[1.0]** — Chromium's, with extensions optionally allowed.

## 6. Boosts — [deferred]

Deferred past the first releases by `decisions/0012-defer-boosts-and-easels.md`.
Specified here so the eventual implementation has something to build against.

- **Boosts** — per-site restyling: colour wheel, invert lightness for a dark mode,
  contrast/brightness/saturation, font presets, size 90–150%, capitalization, and
  **full CSS and JavaScript editors**.
- **Zap** — click a page element to hide it, persisting across that site's pages;
  `\` restores.
- **Sharing Boosts** — Arc hosted a gallery. The local half (export/import a Boost as a
  file) is the part worth having; a gallery is infrastructure.

**Why deferred.** Extensions already answer this, and full extension support is a hard
requirement we are keeping: Stylus does per-site CSS, Violentmonkey does per-site
JavaScript, uBlock Origin's element picker does Zap. A user can have all three on day
one without us building or securing them.

**Before any implementation:** Boosts is a script host, and a script host is a security
surface. User JavaScript injected per site needs a threat model, a permission story, and
an answer for how a shared Boost cannot become an attack. That work comes first, not
alongside.

## 7. Easels and captures

- **Capture Full Page** **[1.0]** — full-page PNG to the downloads folder.
- **Capture region to Easel** **[1.0]** — grab a rectangle of a page.
- **Easels** **[deferred]** — freeform whiteboards that hold captures, drawings and
  text, living as pinned tabs and archived to the Library. Deferred by
  `decisions/0012-defer-boosts-and-easels.md`: it is a drawing application inside a
  browser, it is the single largest item in this document, and it has almost nothing to
  do with browsing. The page-capture features it feeds remain **[1.0]** — captures are
  useful with or without a canvas to put them on.
- **Arc Notes** **[not applicable]** — Arc shipped notes and then removed them in three
  phases during 2024, ending in export-only. Parity with a feature its author deleted
  is not parity; we skip it deliberately.
- **New Documents** **[1.0]** — a configurable "new note" action that opens the user's
  chosen service (Notion, Google Docs, Word, Confluence).

## 8. Arc Max (AI) — [needs decision]

Arc Max bundles: 5-second previews on hover, tidy tab titles, tidy downloads, tidy
tabs, Ask on Page, Instant Links, and ChatGPT in the command bar.

**Every one of these requires a model provider.** `ROADMAP.md` lists built-in AI
features as out of scope for 1.0, and `VISION.md` is hostile to bundled cloud services.
Full Arc parity and that out-of-scope list cannot both be true, and this document will
not paper over it: **this needs a decision**, recorded as its own ADR, covering whether
Stedding ships AI features at all, and if so whether they are local, bring-your-own-key,
or hosted.

Two are separable and are **[1.0]** because they need no model: *tidy downloads*
(grouping downloads sensibly) and the *hover preview* affordance itself.

## 9. Media and downloads

- **Mini Player / Picture-in-Picture** **[1.0]** — floating video player.
- **Audio Player** **[1.0]** — playback control for audio tabs; suppressed for muted
  tabs.
- **Downloads** **[1.0]** — panel and default location.
- **Library** **[1.0]** — the archive of easels, captures, downloads and archived tabs,
  reachable from the sidebar's bottom-left.

## 10. Profiles, windows, sync

- **Profiles** **[1.0]** — Chromium profiles, surfaced Arc's way and bound to Spaces.
- **Multi-window and multi-display** **[1.0]** — tabs in a Space appear in every window
  showing that Space; Blank Windows are independent.
- **Arc Sync** **[needs decision]** — cross-device sync of spaces, pinned tabs and
  order. `ROADMAP.md` puts sync services out of scope and `PRIVACY.md` is emphatic that
  we run no accounts. Parity here means either running a sync service or offering a
  self-hosted/file-based alternative. Not decided here.
- **Recovery Card** **[not applicable]** — recovery for an Arc account we do not have.
- **Arc account / sign-in** **[not applicable]** — we ship no account. This is a
  deliberate divergence and a selling point, not a gap.

## 11. Archive, history, search

- **Auto Archive** **[1.0]** — idle unpinned tabs archive on a schedule, **12 hours by
  default**, per profile, reset by viewing the tab. In Arc it **cannot be disabled**;
  we will make it configurable, including off, because a browser that closes your tabs
  against your wishes is not respecting the user.
- **View / restore / clear Archive** **[1.0]**.
- **History** **[1.0]** — `⌘Y`.
- **Find in page** **[1.0]** — `⌘F`.

## 12. macOS integration and the rest

- **Keyboard shortcut customisation** **[1.0]** — Arc has a full remapping settings
  page. Ours must too; `QUALITY.md` already requires the reference.
- **Site Control Center** **[1.0]** — per-site permissions and controls from the URL
  area, and the entry point to Boosts and Developer Mode.
- **Developer Mode** **[1.0]** — per-site mode with the full URL bar and developer
  affordances, automatic for localhost.
- **Extensions** **[1.0]** — full Chrome Web Store compatibility. Already a hard
  requirement (`AGENTS.md`); `⌘E` cycles them.
- **Import from another browser** **[1.0]** — already M6.
- **Multi-select tabs** **[1.0]** — `⌘`/`⇧` click, then act on the selection.
- **Progressive Web Apps** — Arc does *not* support installing PWAs and points users at
  Favorites instead. **We should ship PWA support anyway**: parity is the floor, not the
  ceiling, and this is a case where Arc is simply worse.
- **Arc Search (iOS/Android)** **[not applicable]** — mobile is out of scope in
  `ROADMAP.md` and nothing here changes that.

---

## What parity does not cover

Three things in this document need a human decision before the roadmap can be
restructured honestly, because each collides with a documented out-of-scope item:

1. **AI features (§8)** — the whole Arc Max bundle.
2. **Sync (§10)** — requires infrastructure and an account model we have rejected.
3. **Hosted sharing (§2, §6)** — Share Space, Share Quote, the Boost gallery.

Until those are settled, "full parity" means *full parity with the local, offline
capabilities of Arc*, which is the large majority of it, plus explicit gaps here.

Separately, **Boosts and Easels are deferred past the first releases**
(`decisions/0012-defer-boosts-and-easels.md`). So the honest description of the target
until that is revisited is **parity minus Boosts and Easels** — which removes the two
largest items in this document and is most of why parity looked out of reach.

## Where we deliberately differ

- **No account, ever.** Arc requires one; we do not.
- **Auto Archive can be turned off.** Arc does not permit that.
- **PWA support**, which Arc lacks.
- **No telemetry**, per `PRIVACY.md`.
- **Open source under BSD**, so the browser cannot be discontinued out from under its
  users — which is precisely what happened to Arc's.
