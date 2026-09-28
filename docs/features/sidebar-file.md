# Feature: Sidebar file

Status: **Sf1, Sf5 withdrawn**; **Sf2–Sf4 planned**. Owner: PRODUCT §10, import I17–I20. Patch: 0055.

Spaces can be exported as a file. No Stedding account, no Stedding host.

The **Export Space…** row writes the importer's backup format (import I20,
`sidebar_backup.cc`). The `stedding.sidebar` version 2 module is not in the
product.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Sf1 | A portable `stedding.sidebar` version 2 catalog would round-trip a window. | `SpaceWindowTest.BlankWindowIsolationIsOnDisk` | planned · withdrawn, the v2 module is not in the product |
| Sf2 | **Import sidebar…** merges by durable id and never closes an open tab (import I19). | `SidebarFileTest.ImportMergesById` | planned |
| Sf3 | Settings **Sidebar folder**: a user-chosen directory. Stedding writes `sidebar.stedding.json` on the backup tick and on quit, atomically. A newer file on launch is merged. Stedding never talks to Syncthing or iCloud. | `SidebarFileTest.FolderWriteIsAtomic` | planned |
| Sf4 | A `.sync-conflict-*` copy is not applied silently; a toast names it. | `SidebarFileTest.ConflictCopyIsNotApplied` | planned |
| Sf5 | Unpinned tabs would not travel unless the user opted in. Passwords, history, extensions and partitions never travel. | `SpaceWindowTest.BlankWindowIsolationIsOnDisk` | planned · withdrawn with Sf1 |
