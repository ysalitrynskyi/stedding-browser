# Feature: Sidebar file

Status: **Sf1, Sf5 built**; **Sf2–Sf4 planned**. Owner: PRODUCT §10, import I17–I20. Patch: 0048.

Spaces travel as a file. No Stedding account, no Stedding host. Isolation
travels as a boolean; cookie jars do not.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Sf1 | **Export sidebar…** writes `kind: stedding.sidebar` version 2: Space ids, names, icons, colours, routes, isolation as a boolean. Pins and folders join when the catalog lifts off the window (Sf2). | `SidebarFileTest.ExportRoundTripsCatalog` | built |
| Sf2 | **Import sidebar…** merges by durable id and never closes an open tab (import I19). | `SidebarFileTest.ImportMergesById` | planned |
| Sf3 | Settings **Sidebar folder**: a user-chosen directory. Stedding writes `sidebar.stedding.json` on the backup tick and on quit, atomically. A newer file on launch is merged. Stedding never talks to Syncthing or iCloud. | `SidebarFileTest.FolderWriteIsAtomic` | planned |
| Sf4 | A `.sync-conflict-*` copy is not applied silently; a toast names it. | `SidebarFileTest.ConflictCopyIsNotApplied` | planned |
| Sf5 | Unpinned tabs do not travel unless the user opts in. Passwords, history, extensions and partitions never travel. | `SidebarFileTest.JarsAreNotInTheFile` | built |
