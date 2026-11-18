# 0034 — Spaces that share a named session

Status: Accepted (the owner's yes to build it, 2026-11-05, and to take it into the next release once every check passed, 2026-11-10; S-272). Amends ADR 0019 ("Binding two Spaces to one jar ... needs a later ADR"), ADR 0028 (whose essentials a session has) and ADR 0029 (what sync carries of a session). "The words" below were amended on 2026-11-13 (`BACKLOG.md` S-477, GitHub issue 99).
Date: 2026-11-05

## Context

Arc gives each Space a profile, and several Spaces can share one. Stedding had Spaces that share the profile's jar, and an opt-in Independent session per Space: a `StoragePartition` named by that Space's `profile_id` (ADR 0019). Two users asked for several Spaces on one session (GitHub issue 8, and three Work Spaces on one account beside two Personal Spaces on another).

What the code held on 2026-11-05:

- `RegistryEntry::profile_id` is the partition name and `isolated` says whether the Space uses it now; off keeps the token (sessions S7). Two entries may already hold one token: `SpacePartitionNames` drops repeats, so the collection (S25) and Delete browsing data (S24) are safe.
- Four places assumed a jar has one Space, and each would have lost data or sign-ins: `RemoveSpace` wiped the deleted Space's jar; `SpaceModel::SpaceNamingJar` stopped at the first entry; `WipeIsolatedSession` reloaded one Space's tabs; the question before a deletion said the jar is erased.
- A waiting wipe (S17) was checked when resumed after a restart, not when it ran.
- There is no Undo on turning a session on or off; the question, and S21's rule for a page with unsaved changes, is all there is.

## Decision

### The model

A session has an id and a name. **The id is the jar's token**, so nothing on disk moves. A Space's `profile_id` is which session it is in, and several Spaces may hold one id; its `isolated` flag says whether it uses that session now (off is "Shared", and it still keeps the token).

Names are kept in one new list, `stedding.spaces.sessions` (`{id, name}`), only for a session that has one: made with "New session…", joined by a second Space, or left by its last Space. **A token with no row is a session named after the Space that holds it.** That is every Independent session on disk before this, so there is no migration, and an older build reads every Space as it was. A row's name is chosen once and has no rename. A name is trimmed, kept to 64 characters and made unique ("Work 2"), since two sessions of one name could not be told apart in a choice whose wrong answer signs a Space out. A session id from outside (a sidebar or sync file) is taken only if it is a token.

### The words

As first decided: "Shared" is the profile's jar, a session is otherwise named by its name, and the Space menu, the command bar and the mark keep "Independent session". Settings' switch on each Space becomes a choice, since one switch cannot say which session.

Amended 2026-11-13 (the owner approved the words that day): "Independent session" is no longer shown. A Space alone on its session is marked "Own session", and a Space on a session other Spaces share with the session's name, as "Session: Clients". The Space menu's check item became a Session submenu (Shared, each session, New Session…), Clear Independent Session became Clear Session Data…, and the command bar's row became Choose This Space's Session…, which opens Edit Space on the session (`docs/features/sessions.md` S10, S13, S16, S48).

### What changes a Space's session

Edit Space and Settings' Space row choose Shared, an existing session, or "New session…". Choosing moves the Space's tabs to the new jar by the same road as turning a session on or off: the registry changes, each window sees the Space's jar move, and its tabs are rebound off screen asleep (S21). A page with unsaved changes keeps its jar until it is left. The same question comes first, and asks nothing when nothing would reload and no app is named. There is no Undo. A Space holding tabs from different sessions was declined.

### The jar is wiped only when no Space names it

A Space *names* a jar when it holds the token, its session on or off.

| The user does | Another Space names the jar | No other Space does |
|---|---|---|
| Deletes the Space | Nothing is wiped; the question says who keeps the session | The jar is wiped (S17), and the question says so |
| Turns its session off, or chooses Shared | Nothing is wiped | Nothing is wiped: the Space still names it (S7) |
| Moves it to another session | Nothing is wiped | Nothing is wiped; the session stays, with its name |
| Clear Session Data… (was Clear Independent Session) | Cleared for every Space in it, and the question names them | Cleared |
| Delete Session… (Settings, a session no Space uses) | Not offered | The jar is wiped, after a question naming the session |

Moving away from a session never erases it, because the user changed where a Space points and did not ask for sign-ins to go; it also means sync on another computer erases nothing. A session no Space uses stays reachable: in the choices, in Settings with Delete Session…, in Delete browsing data and in the collection, since `SpacePartitionNames` reads the sessions list too. Every wipe is checked when it runs, and a jar a Space or a session row names is never wiped from `stedding.spaces.pending_jar_wipes`.

### Essentials

Spaces in one session share their own essentials (ADR 0028). An essential is filed under the Space it was pinned in and shows in every Space on the same jar; such a Space shows no shared essential, as in Arc. When its Space leaves the session or is deleted, it is filed under another Space of this window in that session; when none is, ADR 0028 holds.

### The mark, and which Space a jar belongs to

Spaces of one session wear the same mark; the tooltip of a session with more than one Space names it and the others, and site controls name the session. A page or a worker in a jar several Spaces name goes to the Space on screen when that Space uses the jar, else the first that uses it, else the first that names it.

### Export and import

Export writes `session: {id, name}` beside `isolated` only for a session with a name, so a Space's lone session stays `isolated: true` and a file means what it always meant. Import is by id, never by name: an imported Space takes the session with that id here, or a new empty one with that id and name, so the Spaces of one session stay one session, signed out. With no `session` it gets an empty jar of its own (Sf6). The id is a random token, not a secret.

### Sync

Sync's `session` field carries `id` and `name` as one value, written only for a named session (Sf24). A Space made by sync takes that session by id, new and empty if needed. An existing Space never moves on its own: a different session is Sf24's row, **Join here** or **Not on this computer**. Sessions are never matched by name, and a session's name is not merged. An empty field on the other side changes nothing.

### Windows and pages without sessions

A Blank Window and a private window offer no session (S18, S32). A peek and a little window follow the jar of the tab they come from. An app keeps the jar it was made in while any Space uses it, and falls back to the shared one when the last Space leaves (ADR 0025). An archived tab reopens in the jar its Space has now; nothing new is stored.

### Arc import

Spaces that shared one custom Arc profile in one import share one new session named after that profile, on an empty jar (import I8). A Space on Arc's default profile stays Shared. Nothing joins a session already here: a second import makes "Personal 2" rather than guess. Nothing Arc was signed in to comes across.

## Consequences

- `chrome/common/stedding/space_partitions.cc` reads two preferences, so the collection (S25) and Delete browsing data (S24) reach the sessions no Space uses.
- `stedding.spaces.sessions` is new and old builds ignore it. After a downgrade a session's Spaces stay on one jar, and a session no Space names is collected.
- `SpaceModel` asks `SpacesShareSession` where it asked whether two Space ids were equal for an essential.
- A jar stays on disk while no Space uses it, which is what the row in Settings is for; `docs/PRIVACY.md` says so.
- Both platforms were checked before it joined the series: the suites on every build, and acceptance SS1–SS6 with real input on each (`docs/features/acceptance.md`, 2026-11-10 and 2026-11-11).
