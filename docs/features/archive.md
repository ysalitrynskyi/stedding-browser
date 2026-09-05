# Feature: Auto-archive

Status: **A1–A6 built and tested**; **A7–A11 planned** (round 6, `docs/ROUND6-PLAN.md`
R6-24).
Owner docs: `docs/PRODUCT.md` ("Unpinned Tabs — auto-archived when idle"). Patch: `0011`
(`patches/README.md`); A7–A11: TBD.

Unpinned tabs that nobody has looked at for a while leave the sidebar on their own, the way
Arc's do. "Archived" means closed into Chromium's recently-closed list, so ⇧⌘T and the
History menu bring one back with its navigation intact. Nothing pinned, nothing in a folder
and nothing the user is looking at is ever archived.

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
| A7 | An "Archived" row at the foot of the tab list, above the switcher row, opens `chrome://stedding-archive`, a WebUI page built like the welcome flow's; ⌘T offers "Show Archived Tabs" (⌘Y stays History). | live capture (`w3_archive_row`, `w3_archive_page`) | planned |
| A8 | One archive mark, set by `TabArchiver::Sweep` and by `SpaceModel::ClearUnpinnedTabs` before the close, is written into the closed tab's `extra_data` as `stedding.archive.reason` (`auto` \| `clear`) beside the Space name (`stedding.spacename`), the Space id and the folder path Chromium's list already carries, so ⇧⌘T keeps working and the archive is the same list. A plain ⌘W carries no reason and shows as "closed". | TabArchiverTest.SweepRecordsSpaceAndReason, SpaceWindowTest.ClearRecordsReason, ArchiveExtraDataTest.MarkThenPopulate | planned |
| A9 | The page groups by day, filters by Space, searches title and address, and "Restore" puts a tab back in its Space — re-creating the Space by name when it is gone — and switches to it; "Clear archive" empties the list. | ArchivePageTest.RestoreRecreatesAMissingSpace; live | planned |
| A10 | The command bar lists archived tabs that match the typed text after the open tabs, labelled "Archived"; choosing one restores it to its Space. | CommandBarViewTest.ArchivedRowRestoresToItsSpace | planned |
| A11 | "Keep archived tabs for 7 / 30 / 90 days" (`stedding.archive.keep_days`, default 30) bounds what the page and the bar show; Chromium's recently-closed list keeps 500 entries instead of 25 so the archive is worth its name. | ArchivePageTest.RetentionFiltersOldEntries | planned |
