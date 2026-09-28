# Feature: Sidebar file

Status: **Sf2 partial**; **Sf1, Sf3–Sf5 withdrawn** in patch 0055 (owner decision, 2026-09-26). Owner: import I18–I20.

Spaces can be exported as a file. No Stedding account, no Stedding host.

The **Export Space…** row writes the importer's format (import I20,
`sidebar_backup.cc`), and **Import sidebar…** reads it back. The
`stedding.sidebar` version 2 module and the sidebar folder are not in the product.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Sf1 | A portable `stedding.sidebar` version 2 catalog would round-trip a window. | none | withdrawn |
| Sf2 | **Import sidebar…** merges by durable id and never closes an open tab (import I18). | `SidebarBackupTest.RestoreClosesNothing` (closes nothing); merging by durable id is PLAN.md WEB-19 | partial |
| Sf3 | Settings **Sidebar folder**: a user-chosen directory. Stedding writes `sidebar.stedding.json` on the backup tick and on quit, atomically. A newer file on launch is merged. Stedding never talks to Syncthing or iCloud. | none | withdrawn |
| Sf4 | A `.sync-conflict-*` copy is not applied silently; a toast names it. | none | withdrawn |
| Sf5 | Unpinned tabs would not travel unless the user opted in. Passwords, history, extensions and partitions never travel. | none | withdrawn |
