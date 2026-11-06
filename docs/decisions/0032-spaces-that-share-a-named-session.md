# 0032 — Spaces that share a named session

Status: Proposed (the owner's yes to build it, 2026-11-05; `BACKLOG.md` S-272). Amends ADR 0019 ("Binding two Spaces to one jar ... needs a later ADR"), ADR 0028 (whose essentials a session has) and ADR 0029 (what sync carries of a session).
Date: 2026-11-05

## Context

Arc gives each Space a profile, and several Spaces can share one. Stedding has Spaces that all share the profile's jar, and an opt-in Independent session per Space: a `StoragePartition` named by that Space's `profile_id` (ADR 0019). Two users have asked for several Spaces on one session: GitHub issue 8, and a comment on r/Stedding, three Work Spaces signed in as one account and two Personal Spaces as another.

What the code held on 2026-11-05, read before this was written:

- `RegistryEntry::profile_id` is the partition name and `isolated` says whether the Space uses it now. Off keeps the token (sessions S7).
- Nothing stops two entries holding one token: `SpacePartitionNames` already drops repeats, so Chromium's collection (S25) and Delete browsing data (S24) are safe with it.
- Four places assume a jar has one Space, and each would have lost data or sign-ins: `RemoveSpace` wipes the jar of the Space deleted; `SpaceModel::SpaceNamingJar` stops at the first entry, so a Space with its session off could hide one with it on; `WipeIsolatedSession` reloads one Space's tabs; the question before a deletion says the jar is erased.
- A waiting wipe (S17) is checked against the registry when it is resumed after a restart and not when it runs. A Space brought back by a window's session (S2) could name a jar a wipe was waiting on.
- There is no Undo on turning a session on or off. The question, and S21's rule for a page with unsaved changes, is all there is.

## Decision

### The model

A session has an id and a name. **The id is the jar's token**, the partition name, so a session needs no second key and nothing on disk moves. A Space's `profile_id` is which session it is in, and several Spaces may hold one id. Its `isolated` flag says whether it uses that session now: off is "Shared", and it still keeps the token (S7).

The name is kept in one new list, `stedding.spaces.sessions`, `{id, name}`, and only for a session that has one:

- made with "New session…", when the user names it;
- joined by a second Space, when the name it has then is written down;
- left by its last Space, which would otherwise take the name with it.

**A token with no row in that list is a session named after the Space that holds it.** That is every Independent session on disk today, and it is why there is no migration: nothing is rewritten, nothing can fail halfway, and a build from before this reads every Space as it was. Such a session follows its Space's name, as it is that Space's. A row's name is chosen once and has no rename, because a name that moves under a Space in another window explains nothing.

A name is trimmed, kept to 64 characters, and made unique among the sessions by a number ("Work 2"). Two sessions of one name would be two lines nobody can tell apart in a choice whose wrong answer signs a Space out.

A session id that arrives from outside (a sidebar file, a sync file) is taken only if it is a token, as a window's session already is (S2).

### The words

"Shared" is the profile's jar. A Space's session is otherwise named by its name. "Independent session" stays what it is on the Space menu, the command bar and the mark: this Space's session is on. "New session…" makes one. Clear Independent Session keeps its name.

Settings' switch on each Space becomes the choice, because one switch cannot say which session. The Space menu's check item and the command bar's row stay: they turn the session the Space has on or off, or give it a new one named after it, as they always have.

### What changes a Space's session

Edit Space and Settings' Space row choose: Shared, a session already there, or "New session…". Choosing moves the Space's tabs to the new jar by the same road as turning a session on or off: the registry changes, each window's `SyncWithRegistry` sees the Space's jar move, and `RebindTabsInSpace` puts its tabs off screen asleep (S21). A page with unsaved changes keeps its jar until it is left; a form it sends goes in the jar it was filled in. The same question comes first, with the same count of pages and the same line for apps. It asks nothing when nothing would reload and no app is named. There is no Undo, as there is none today.

Do not build a Space holding tabs from different sessions. That was declined.

### The jar is wiped only when no Space names it

A Space *names* a jar when it holds the token, its session on or off. A session stays until the user ends it:

| The user does | Another Space names the jar | No other Space does |
|---|---|---|
| Deletes the Space | Nothing is wiped. The question says the session stays and who keeps it | The jar is wiped (S17), and the question says so |
| Turns its session off, or chooses Shared | Nothing is wiped | Nothing is wiped: the Space still names it (S7) |
| Moves it to another session | Nothing is wiped | Nothing is wiped. The session stays, with its name, in every choice and in Settings |
| Clear Independent Session | Cleared for every Space in it, and the question names them | Cleared |
| Delete Session… (Settings, a session no Space uses) | Not offered | The jar is wiped, after a question that names the session |

Moving away from a session never erases it, for the reason turning one off never does: the user changed where a Space points, and did not ask for sign-ins to go. It also means sync's "yes" on another computer erases nothing. The price is a session no Space uses, which must be reachable: it stays in the choices, Settings lists it with Delete Session…, Delete browsing data reaches it, and the collection keeps it, because `SpacePartitionNames` reads the sessions list as well as the Space list.

Every wipe is checked at the moment it runs, not only when it is asked for. A jar a Space or a session row names is never wiped from `stedding.spaces.pending_jar_wipes`.

### Essentials

Spaces in one session share their own essentials (ADR 0028). An essential is still filed under one Space, the one it was pinned in, and shows in every Space whose session is on the same jar. Arc's rule stays: such a Space shows no shared essential.

An essential belongs to its session. When the Space it is filed under leaves the session or is deleted, and another Space of this window is still in that session, it is filed there and stays in the jar it is signed in to. When none is, ADR 0028 holds: it goes with its Space, and becomes a pin in a Space with no session of its own.

### The session mark

Spaces of one session wear the same mark. The tooltip of a session with more than one Space names the session and the others, as "Independent session" no longer says what it is. Site controls name the session, not the first Space that holds it.

### Which Space a jar belongs to

A page or a worker in a jar several Spaces name goes to the Space on screen when that Space uses the jar, else to the first Space that uses it, else to the first that names it. It was the first that named it, and a Space with its session off could shadow one with it on.

### Export and import

Export writes a Space's session only when it has a name in the list: `session: {id, name}` beside `isolated`. A Space's lone session stays what it was, `isolated: true`, so a file means what it always meant. Import is by id and never by name:

- A Space an import makes takes the session with that id here, or a new empty one with that id and name. So the Spaces of one session stay one session in another install, on one new jar, signed out.
- With no `session` it gets a jar of its own, empty, as today (Sf6).
- A file from before this reads as it did.

What was signed in does not travel. The id is a random token, not a secret: a partition's path on disk is a hash of it, and it opens nothing on another computer.

### Sync

Sync's `session` field carries `id` and `name` as one value, so they merge as one. It is written for a Space on a session with a name, and empty otherwise, so a Space's lone session syncs as it did (Sf24).

- **A Space made here by sync** takes that session by id, new and empty when this computer has none. It has no tabs to move and nobody loses anything.
- **An existing Space** never moves on its own. A different session is the row Sf24 already gives, naming the session and the pages: **Join here**, or **Not on this computer**, which holds until a newer change.
- **Never by name.** Two computers that each made a session called Work have two sessions, and a Space joins a jar only under the id it was given. A session's name is not merged: the first row for an id keeps its name.
- A field that is empty on the other side, with the Space on a session here, changes nothing and asks nothing: empty does not say which jar.

### Windows and pages without sessions

A Blank Window has no registry, a private window has no Spaces, and neither offers a session (S18, S32). A peek keeps the pinned tab's jar and a little window its source's. Both follow what the tab's jar is, so neither knows sessions exist. An app keeps the jar it was made in while any Space uses it (ADR 0025): it falls back to the shared one when the last Space leaves.

### The archive

An archived tab names its Space. Reopened, it goes in the jar that Space has now. If the Space has moved to another session, that is the session the tab comes back to. Nothing new is stored.

### Arc import

Arc's sidebar file names a profile for each Space, and the importer already reads it (import I8). Spaces that shared one custom profile in one import now share one new session named after that profile, on an empty jar. A Space on Arc's default profile stays Shared. Nothing joins a session already here, by that name or any other: a second import makes "Personal 2" rather than guess. The first Space, which takes the lone unnamed default Space, joins when no page there would reload, for the reason S32's note gives. Nothing Arc was signed in to comes across.

## Consequences

- `chrome/common/stedding/space_partitions.cc` reads two preferences, and every caller gets the sessions no Space uses for nothing: the collection (S25) and Delete browsing data (S24).
- `stedding.spaces.sessions` is new, and old builds ignore it. A downgrade reads each Space's token as before; a session's Spaces stay on one jar, and a session no Space names is collected at the next collection, as the old build sees it as nothing.
- `SpaceModel` asks one question, `SpacesShareSession`, where it asked whether two Space ids were equal for an essential.
- A jar stays on disk while no Space uses it, which is what the row in Settings is for. `docs/PRIVACY.md` says so.
- Windows has none of this checked until a Windows build runs it (`docs/features/sessions.md`).
