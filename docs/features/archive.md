# Feature: Auto-archive

Status: **A1–A7, A10, A11 built**; **A8, A9 partial and A12 planned**: rewritten
for PLAN.md WEB-6 and WEB-7, written, not yet run (A7–A11: round 6,
`docs/ROUND6-PLAN.md` R6-24).
Owner docs: `docs/PRODUCT.md` ("Unpinned Tabs — auto-archived when idle"). Patch: `0011`
(`patches/README.md`); A7–A11: `0028`.

Unpinned tabs that nobody has looked at for a while leave the sidebar on their own, the way
Arc's do. "Archived" means closed into Chromium's recently-closed list, so ⇧⌘T and the
History menu bring one back with its navigation intact. Nothing pinned, nothing in a folder
and nothing the user is looking at or using is ever archived (A12).

The sweep is a per-window `TabArchiver` (`chrome/browser/ui/archive/`), a timer that runs a
few times an hour and closes every tab whose last activation is older than the threshold.
The threshold is the profile preference `stedding.archive.idle_hours` (12 by default, 0 turns
the feature off), exposed as a dropdown in chrome://settings/stedding.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| A1 | An unpinned tab idle for longer than the threshold is closed by the sweep, and lands in the recently-closed list. | `TabArchiverTest.ArchivesIdleUnpinnedTabs`, `TabArchiverTest.KeepsTabsUnderTheThreshold`, `TabArchiverTest.TimerSweeps` | built |
| A2 | The active tab is never archived, however long it has been open. | `TabArchiverTest.NeverArchivesTheActiveTab` | built |
| A3 | Chromium-pinned tabs (essentials) and Space-pinned tabs are never archived. | `TabArchiverTest.KeepsPinnedTabs` | built |
| A4 | Tabs inside a folder are never archived (PRODUCT: folders are deliberate). | `TabArchiverTest.KeepsFolderTabs` | built |
| A5 | A threshold of 0 hours turns the sweep off; changing the preference takes effect at the next sweep. | `TabArchiverTest.ZeroHoursDisables` (the timer stops with the preference at 0 and restarts when it changes) | built |
| A6 | The setting is a dropdown in chrome://settings/stedding: Never, 6 hours, 12 hours (default), 1 day, 3 days. | capture | built |
| A7 | An "Archived" row at the foot of the tab list, above the switcher row, opens `chrome://stedding-archive`, a WebUI page built like the welcome flow's; ⌘T offers "Show Archived Tabs" (⌘Y stays History). | live: `w3_archive_row` (the row above the switcher), `w3_archive_page` (the page with a swept tab and a cleared one) | built |
| A8 | One archive mark, set by `TabArchiver::Sweep` and by `SpaceModel::ClearUnpinnedTabs` before the close, is written into the closed tab's `extra_data` as `stedding.archive.reason` (`auto` \| `clear`). The mark is for that one close: the record takes it, and it clears itself when the page's "Leave site?" is answered Stay, so a later ⌘W on the same tab is a plain close (PLAN.md WEB-6). Beside it go what a restore needs (PLAN.md WEB-7): the tab's Space id, pin and home exactly as the session writes them (`SessionExtraDataForTab`), the user's name for the tab, its folders (`stedding.archive.folderpath`), the Space's name as the sidebar showed it (`stedding.spacename`) and its own name (`stedding.spacename.own`, none for an unnamed Space). So ⇧⌘T brings a tab back in its Space, in that Space's jar and with its pin, and the archive is the same list. A plain ⌘W carries no reason and shows as "closed". | TabArchiverTest.SweepRecordsSpaceAndReason, SpaceWindowTest.ClearRecordsReason, ArchivePageWindowTest.MarkThenPopulate, ArchivePageWindowTest.ClearedMarkRecordsAPlainClose, ArchivePageWindowTest.PopulateCarriesWhatARestoreNeeds, ArchivePageWindowTest.PopulateNamesNoSpaceForAnEssential; browser, through a real `TabRestoreService`: `ArchiveSweepTest.TheSweepLeavesEveryTabInUseAlone` (a tab the sweep skipped, closed later, is a plain close) | partial · the unit and browser tests pass; the Stay case (a page that asks, told to stay) has no test |
| A9 | The page groups by day, filters by Space, searches title and address, and shows each tab's folders by title. "Restore" finds the tab's Space by its id, never by position, and makes nothing before the tab is back: a Space deleted since comes back by its own name, an unnamed one does not (the tab stays in the active Space). The tab is in that Space's jar, and back in its folder when the folder is still there, before it is shown; then the tab and its Space are shown, once (PLAN.md WEB-7). "Clear archive" empties the list. | ArchivePageWindowTest.SpaceForRestoreFindsWithoutMaking, ArchivePageTest.RowNamesTheFolders; browser: `RestoreTest.AnArchivedTabComesBackToItsSpaceFolderAndJar` (an unnamed Space with its own session, reordered, the folder, the jar); live: `w3_archive_page`, `w3_archive_restored` (earlier build) | built |
| A10 | The command bar lists archived tabs that match the typed text after the open tabs, labelled "Archived"; Enter on that highlighted row restores it to its Space. | `CommandBarViewTest.ArchivedRowRestoresToItsSpace`, `CommandBarViewTest.EnterRunsTheHighlightedArchivedRow` | built |
| A11 | "Keep archived tabs for 7 / 30 / 90 days" (`stedding.archive.keep_days`, default 30) bounds what the page and the bar show; Chromium's recently-closed list keeps 500 entries instead of 25 so the archive is worth its name. | ArchivePageTest.RetentionFiltersOldEntries; the dropdown: `w3_archive_settings` | built |
| A12 | The sweep leaves every tab in use, however long it idled: on screen (the active tab or a pane of the active split), playing sound or a moment ago, in a call or a share, captured, holding a USB, HID, serial or Bluetooth device, in picture-in-picture or a fullscreen video, able to ask "Leave site?", or holding form input (`TabIsInUse`, the rule sleep uses), with DevTools attached, or one Chromium would refuse to close. So a sweep never shows a dialog, raises the window, activates a tab or changes Space (PLAN.md WEB-6). A page with only unload handlers closes a moment after the sweep, once they ran, and keeps its mark until then. | TabArchiverTest.SweepLeavesTabsInUse, TabArchiverTest.ALeftTabCarriesNoMark; browser: `ArchiveSweepTest.TheSweepLeavesEveryTabInUseAlone` (a half-typed form with "Leave site?" in another Space, a split's other pane, a tab playing sound: all kept, no question, no Space switch, nothing activated) | built |

## Notes on the archived view (A7–A11)

- The archive is Chromium's recently-closed list, read through one function
  (`ListArchivedTabs`) that keeps TAB entries within the retention, newest first.
  A tab closed with ⌘W is in it too, shown as "closed"; the sweep's and Clear's
  tabs say "archived" and "cleared" from the mark they carried. Windows and
  groups closed whole are not listed (their tabs come back with ⇧⌘T as before).
- The mark is a `WebContentsUserData` set a moment before the close;
  `BrowserLiveTabContext::GetExtraDataForTab` takes it while Chromium records the
  tab, beside the Space's data. Nothing clears it when the close call returns with
  the tab still in the strip: that is a close waiting on the page's unload
  handlers, which is recorded when they have run.
- The folders go under the archive's own key, not the session's
  `stedding.folderpath`: under that key a ⇧⌘T would park the path on the tab and
  the next session restore would build a second folder with the same id. So ⇧⌘T
  brings a tab back without its folder; the archive's Restore puts it back in the
  folder when that folder is still there.
- The page is plain DOM (no Lit), like the welcome flow: the keyboard and VoiceOver
  come from real inputs and buttons. It refreshes on the service's own change
  notification, so a restore or a sweep in another window shows at once.
- The list's cap moves from 25 to 500 entries in the same patch; the retention
  setting bounds what is shown, not what is kept.
