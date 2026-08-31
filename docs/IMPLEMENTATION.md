# Implementation plan

How each Stedding feature gets built on Chromium 153, what upstream already provides,
and what it costs. Derived from ten parallel source investigations of the tree at the
pin, each required to cite `file:line` and to say what could be reused before proposing
anything new.

The headline: **almost nothing here needs new machinery.** Chromium has spent the last
few years building the pieces — a tab collection tree, an in-window overlay slot, an
autocomplete provider stack, a session `extra_data` channel, a settings plugin
architecture. The work is composition, not invention.

Rebase cost is the constraint (`decisions/0003-chromium-minimal-patch-fork.md`), so
every row names the files it would edit and their commits in the last year.

## Summary

| Feature | Cost | The reuse that makes it cheap |
|---|---|---|
| Command bar | **small** | `AutocompleteController` + the default omnibox providers, used as-is |
| Little Arc | **small** | `TYPE_POPUP` windows + `Navigate(NEW_POPUP)` + `omit_from_session_restore` |
| Air Traffic Control | **small** | `URLMatcher` for rules; the routing decision already lives in the chrome layer |
| Auto Archive | **small** | `TabRestoreService` *is* an archive; `CLOSE_CREATE_HISTORICAL_TAB` already writes the memento |
| Session persistence | **small** | Session `extra_data` maps — vertical tabs already persist through them |
| Peek | **medium** | `ContentsContainerView`'s overlay slot; `TabbedWebAppNavigationThrottle` as the interception precedent |
| Spaces | **medium** | `TabStripCollection` — the collection tree already holds pinned/group/split sets |
| Folders | **medium** | Same collection tree; nesting groups is "the missing allowance", not a new model |
| Settings section | **medium** | chrome://settings is a plugin architecture: one directory per sidenav entry |

Nothing on this list requires touching `content/`, `blink/`, `net/` or `v8/`.

## The load-bearing discoveries

**Spaces are not a new data structure.** `components/tabs/` holds a collection tree that
already models pinned, grouped and split tab sets. A Space is N `TabStripCollection`s
plus an active id, with `DetachTab*`/`InsertDetached*` moving tabs between them. The
investigation's warning is the important part: *do not reintroduce a flat vector*, and
do not pretend windows or tab groups are Spaces — that is what turns this from medium
into large.

**Peek has a substrate.** `ContentsContainerView` already hosts overlay children with a
scrim, used by existing features, and `WebContents::IgnoreInputEvents` handles the
dismissal semantics. For "this link would leave the pinned site",
`TabbedWebAppNavigationThrottle` is an exact working precedent — a throttle that decides
a navigation belongs elsewhere and redirects it. Peek becomes a new throttle plus a new
overlay controller, with a single call added to a file that sees 46 commits a year.

**The command bar should not fork the omnibox.** `AutocompleteController` and the default
providers can be driven directly from a new host, and `OpenTabProvider` already supplies
open-tab matching. Two traps are named explicitly: adding a new `AutocompleteProvider::Type`
edits hot shared headers, and expanding Tab Search's WebUI into a command bar is large.
Cloning the `WebUIBubbleManager` top-chrome pattern into our own directory is small.

**Auto Archive is mostly already written.** Closing a tab with `CLOSE_CREATE_HISTORICAL_TAB`
puts it in `TabRestoreService`, which is an archive with restore. The work is the idle
timer and the policy (pinned and foldered tabs never archive), not storage. The
investigation warns off the tempting wrong hook: the performance discarding/freezing
machinery is not Archive and using it would be both harder and incorrect.

**Session persistence has a supported channel.** Sessions carry `extra_data` maps per
window and per tab, and upstream's own vertical tabs already persist state through them.
Spaces, folders and archive timing ride the same channel rather than a parallel store —
which matters because Zen's largest bug cluster is exactly tab identity across restore
(`EVIDENCE.md`).

**Settings has a plugin architecture.** As of 2025, chrome://settings maps one sidenav
entry to one element directory. A Stedding section is a new directory plus small edits
to four files with 45, 24, 17 and 13 commits a year — low churn by Chromium standards,
and no generated search catalog to regenerate.

## Spaces: the seams, verified

ADR 0015 decides that Spaces filter one tab strip. These are the exact places
that implements against, each read in the pinned tree rather than assumed. All
line numbers are Chromium 153.0.8010.12.

**A space id on a tab, without patching the tab.**
`TabInterface::GetUnownedUserDataHost()` (`components/tabs/public/tab_interface.h`)
takes arbitrary per-tab data. `TabUIHelper` is the working precedent:

```
chrome/browser/ui/tab_ui_helper.cc:82
    scoped_unowned_user_data_(tab_interface.GetUnownedUserDataHost(), *this)
```

So a `SpaceTabData` attaches to each tab with no change to `tabs::TabModel` at
all. `TabModel` does carry `group_` and `split_` as plain fields, so a field is
possible, but it would be a patch to a file we would rather not own.

**"The user cannot see this tab" already exists.**
Collapsed tab groups are tabs that are in the model and not on screen, and the
machinery is centralised:

| Concern | Where | Note |
|---|---|---|
| The predicate | `tab_strip_model.cc:1515` `IsTabCollapsed` | small caller set |
| Ctrl+Tab | `tab_strip_model.cc:4139` `SelectRelativeTab`'s `is_tab_invalid` | already filters |
| Which tab to activate next | `tab_strip_model.cc:5653`, `5661`, `5671` | already filters |
| Moving activation off a tab about to be hidden | `tab_strip_model.cc:3458` `GetNextExpandedActiveTab` | takes a range, returns the nearest visible index |
| Hiding in the view | `tab_group_view.cc:281` `child->SetVisible(!collapsed)` | model untouched |

The order that function implies matters: activate the next visible tab *first*,
then hide the outgoing set. `SelectRelativeTab` `DCHECK`s that the active tab is
not hidden, so hiding first trips it.

**Persistence.** `SessionService::AddTabExtraData(window, tab, key, data)`
(`chrome/browser/sessions/session_service.h:132`) writes per-tab key/value into
the session; it comes back as `SessionTab::extra_data`
(`components/sessions/core/session_types.h:113`). `SessionWindow::extra_data`
(`:237`) is the matching place for the window's list of spaces. The precedent is
send-tab-to-self:

```
chrome/browser/ui/send_tab_to_self/send_tab_to_self_activation_tracker.cc:94
    AddTabExtraData(..., kSendTabToSelfEntryGUIDKey, ...)
```

Because every tab stays in the live strip, compaction rebuilds all of them and
no session-service patch is needed — which is the whole reason ADR 0015 chose
filtering over parking.

**Churn of what this touches:** `tab_strip_model.cc` 153/yr (a few small hunks),
`tab_group_view.cc` and the vertical strip views lower, and the new code lives
in `chrome/browser/ui/spaces/`, which is ours.

## Build order

Following `EVIDENCE.md`, which says folders were the gate for Arc switchers and that
session restore must be built with the tab model rather than after it:

1. **Spaces + Folders + session persistence, as one milestone.** They share the
   collection tree and the `extra_data` channel, and splitting them is how tabs get
   lost on restore.
2. **Peek.** Highest value per unit of effort; it is what makes pinned tabs behave like
   applications.
3. **Command bar.** Small, and it unlocks keyboard access to everything above.
4. **Little Arc**, then **Air Traffic Control** — the second depends on Spaces existing.
5. **Auto Archive** and the **settings section** alongside, since both are small and
   every feature above needs settings entries to satisfy `QUALITY.md`.

## Standing rules for this work

- New files in new directories wherever possible. Every edit to `browser_view.cc`
  (412 commits/year) or `vertical_tab_strip_region_view.cc` (181) is a design failure to
  be reviewed, not a routine step.
- Reuse before building. Each investigation above found upstream machinery that a naive
  implementation would have duplicated; a patch that reimplements something Chromium
  already does is a patch we will carry forever for nothing.
- Measure churn before editing a file, not after: `git log --oneline --since=1.year -- <file> | wc -l`
