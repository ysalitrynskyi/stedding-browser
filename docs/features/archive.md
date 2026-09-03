# Feature: Auto-archive

Status: **A1–A6 built and tested**; A7 is a gap.
Owner docs: `docs/PRODUCT.md` ("Unpinned Tabs — auto-archived when idle"). Patch: `0011` (`patches/README.md`).

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
| A7 | An "Archived" view in the sidebar listing what was archived, beyond Chromium's recently-closed list. | none yet | gap |
