# Vision, name, brand and competitors

Stedding Browser is an open-source, Chromium-based desktop browser: a sidebar of vertical
tabs, Spaces, pinned tabs and folders, split view, and a command bar. It is for technical
users who want privacy, control and a productive UI, without betting a daily workflow on a
company's pivot, acquisition or monetization.

This page says why the project exists, what it values, who it is for and what it will not
be. It records the name and the brand, and the browsers Stedding is measured against.

## Why this exists

Arc showed that a sidebar, workspaces and a command bar are a better way to work than a row
of horizontal tabs. People who adopted that model rarely wanted to go back. Arc was never
open source, and when its maker moved on, nobody outside the company could pick it up.

The open browsers nearby do not fill the same space. Zen is built on Firefox, so it does not
run Chrome extensions. Nook is built on WebKit, for the Mac, under a copyleft licence. Brave
is open Chromium with a conventional UI, and it bundles crypto and rewards ("Competitors",
below). No permissively licensed Chromium browser carries that workflow forward, UI
included. That is the gap Stedding fills.

The core is BSD-3-Clause. If the maintainers lose interest, pivot or sell, anyone can fork
the browser and keep going. The licence is the exit Arc never gave anyone.

## What we are building

A minimal patch series on Chromium stable, the Brave/Helium model, not a hard fork. UI work
stays as high in the stack as it can, so tracking upstream stays cheap. Full Chrome
extension compatibility is a hard requirement.

macOS (Apple silicon) and Windows ship. Linux is next and is not shipped
([ADR 0006](decisions/0006-platform-order-macos-first.md)). Every milestone ends in
something installable. A feature ships with its shortcuts, settings, edge cases and polish,
or it does not ship. The product, the engineering and the quality bar are
[PRODUCT.md](PRODUCT.md), [ARCHITECTURE.md](ARCHITECTURE.md) and
[ROADMAP.md](ROADMAP.md#the-quality-bar).

## Values

**User control.** The browser answers to the person using it. Defaults are opinionated, and
everything meaningful is configurable. Nothing has to ask a server for permission. The
profile, the data and the machine stay the user's.

**Privacy by default.** No telemetry by default, and none in the builds to turn on. Privacy
protections are product features, held to the same bar as the rest, not checkbox settings
buried three menus deep. The defaults are in [PRIVACY.md](PRIVACY.md).

**Openness.** The browser is developed in public under BSD-3-Clause. A decision that is hard
to reverse is an ADR in [decisions/](decisions/), written before or with the change. Closed
or paid add-ons may exist someday. The core — everything needed to build, run and fork the
browser — stays permissively licensed.

**Craft.** Shipping polished beats shipping first. A feature that is 90% done is 0% done.
Performance, keyboard support and detail work are part of every feature, not a later pass.

## Who it is for

Technical users: developers, researchers, power users. People who live in a browser all day,
keep dozens of tabs across several projects, rely on extensions, and notice when software
wastes their time. People who read a privacy policy, or would rather use software that makes
reading one unnecessary. Former Arc users who want that workflow on a foundation nobody can
take away.

It is not, at least at first, aimed at someone who wants a browser that manages itself.
Stedding is opinionated and rewards investment. The defaults should be good. The payoff is
in the Spaces, the command bar and the keyboard.

## Non-goals

These are commitments, not omissions. Absence from this list is not a promise. Presence on
it is.

- **No crypto or web3 features.** No wallet, no tokens, no rewards program, no blockchain
  integration of any kind. Anyone who wants these can install an extension.
- **No ads or sponsored placements, ever.** No sponsored tiles, no paid default shortcuts,
  no affiliate-injected results, no "partner" content. The new tab page belongs to the user.
- **No AI gimmicks bolted on.** Stedding ships no bundled model: no command-bar chat, no
  agent that holds a Space's cookies ([ADR 0020](decisions/0020-no-bundled-model.md)). Any
  later feature that sends page content or browsing data to a model needs an ADR of its
  own, and is opt-in, clearly labelled and off by default. Dia is for people who want an AI
  browser. Stedding is not that.
- **No mobile, for now.** Desktop — macOS, Windows, Linux — is the whole scope until 1.0 is
  shipped and stable. A mobile browser is a different product. Doing it badly would violate
  the quality bar.
- **Not a Chrome re-skin.** Stedding is an opinionated workflow browser. The point is the
  sidebar, Spaces, split view and the command bar. A change that merely recolors Chrome is
  not worth a patch.

## What success looks like

A technical user downloads an installer, opens it, imports a profile, and prefers it to
Chrome or Arc within a day.

Success is not a user count we would have to invent. The project succeeds when it is
someone's daily browser and they stop thinking about it — and when, if this project ends,
its users are not stranded.

## The name

Decided 2026-08-30: the product is **Stedding Browser**, and the canonical domain is
**stedding.dev** ([ADR 0001](decisions/0001-product-name-stedding.md),
[ADR 0004](decisions/0004-domain-stedding-dev.md)). How to write the name, and what it
means, is "Brand and voice", below.

### How it was chosen

Candidates came from invented and real English words, across nautical, avian, wayfinding
and shelter themes. Each was vetted with live web searches on the same day:

| Criterion | What we checked |
|---|---|
| Existing browsers | Any shipping or announced browser with the same or a confusable name |
| Software collisions | Apps, CLIs, SaaS products, packages or dev tools using the name |
| Trademark exposure | Active companies or rights-holders in adjacent markets, especially ones selling to our audience |
| Pronunciation | One obvious reading for an English speaker |
| SEO headroom | Realistic odds of ranking first for the exact phrase "{Name} Browser" |

A name failed if it collided with any browser, with software our audience already knows, or
with a rights-holder likely to contest it. It also had to be usable without implying
affiliation with anyone.

The early working name failed twice over. A well-funded software company sells to the same
technical audience under that name, a textbook trademark-confusion posture. And English
speakers pronounced it two ways: a name people cannot say the same way is a name they
cannot recommend out loud.

**Stedding won.** Its meaning matches the product: a haven, a settled, kept place. The field
was clean: no products, no live trademarks, and an effectively empty results page for
"Stedding Browser" on the day of the search. **Vesper** was the runner-up: brandable, and an
empty exact-phrase page for "Vesper Browser", but with some small bare-name software, so not
the clean field Stedding offered.

| Eliminated | Why |
|---|---|
| Heron | **Herond Browser**, an active Chromium-based privacy browser, one letter away |
| Vela | Three existing browsers already use the name |
| Rove | rovebrowser.com exists |
| Lumar | Lumar (formerly DeepCrawl), an SEO product sold to technical marketers; also a near-homophone of Lemur Browser |
| Skiff | A dead privacy brand (acquired by Notion, then shut down) |
| Scry | An existing "Scry browser app"; also rhymes with "spy" |
| Magpie, Lodestar, Cairn, Pharos | Saturated across apps and software products |
| Prow, Tern | Dev-tool collisions (Tern, the JavaScript analysis engine, among others) |

### Domain

- **stedding.dev**, a short brand domain. steddingbrowser.com was available, but
  exact-match-domain SEO is mostly obsolete: ranking depends on content and links.
- **.dev fits the audience**, and the whole zone is HSTS-preloaded, so the site is
  HTTPS-only by construction. DNS is on Cloudflare.
- **stedding.top was rejected**: the TLD's spam association hurts trust on a download page.
- **stedding.com, .app and .co** were registered by unrelated parties. People search for the
  browser by name. Buying one is revisited only if the project grows enough to justify it.

The site is a website. Update checks do not go through it
([ADR 0014](decisions/0014-github-releases-as-update-channel.md)).

## Brand and voice

How Stedding presents itself: the name, the voice, the look, and the rules that keep all
three safe.

### Using the name

**Stedding Browser** on first mention, **Stedding** after that. The app is `Stedding`. The
macOS bundle id is `dev.stedding.Stedding`
([ADR 0009](decisions/0009-macos-bundle-identifier.md)).

Stedding means a haven: a settled, kept place. It is shaped on the English word "steading",
a farmstead or homestead, from Middle English "steding" ("place, farm") and Old English
"stede" ("locality, place, site"). That is what this browser is for: a place to use the web
where surveillance and vendor control cannot reach. Tracking, telemetry, ad-driven defaults,
and a roadmap set by someone else's business stop at the door.

Say it **STED-ding**. It rhymes with "wedding": two syllables, stress on the first.

### Voice

Calm, precise, no hype. Write the way a good engineer explains something to a colleague:
plainly, accurately, without selling.

- **Say what the software does.** Not what it "revolutionizes", "supercharges" or
  "reimagines". If a sentence would survive on a competitor's site unchanged, it says
  nothing. Cut it.
- **Be concrete.** "No telemetry by default" beats "privacy-first". A number only when it
  was measured. Otherwise leave it out, or write TBD.
- **Be quiet.** No exclamation marks in product copy. No emoji in docs or release notes. No
  countdowns, no "last chance".
- **Respect the reader.** The audience is technical. Do not pad, do not over-explain, and do
  not hide a limitation. State a trade-off plainly.
- **Admit what is unfinished.** "Not implemented yet" is a complete sentence.

The same register everywhere: the website, release notes, error messages, settings copy and
social posts. If it would sound wrong in a commit message, it is wrong on the website.

### Taglines

Chosen with the website (2026-09-16). **"Your haven on the web."** leads: the name's meaning
in five words. **"A quiet place to get things done."** is for where the workflow is the
subject: what daily use feels like.

### Visual direction

The mark is generated from one geometry file,
[`tooling/brand/mark.py`](../tooling/brand/mark.py), into
[`branding/`](../branding/README.md): an arch over a hearth. Its colours are slate
`#2F4858`, cream `#F2E9DE`, amber `#E8B04B` and ink `#1C2B33`.

The browser's light chrome is Tailwind's slate-300 (`#CBD5E1`). The dark chrome is a
blue-to-plum gradient, `#21263A` to `#31243A`. A Space's colour tints the sidebar and
nothing else. Chromium's own surfaces keep its baseline palette (patch 0105,
[S-310](history/archive.md)). The mark's amber dot is the one amber left. Neither the mark
nor the palette has an ADR.

Rules for any new visual work:

- **Mood: quiet and settled.** Calm, grounded, unhurried. Not neon gradients, glassy chrome
  or startup confetti.
- **Motifs: shelter and ground.** A roof line, an arch, a threshold, a hearth, stone.
  Abstract geometry from these, not a literal illustration, and nothing from anyone else's
  work.
- **Both themes.** Light and dark. The chrome is where the brand lives daily.
- **Typography.** A clear sans-serif for the UI and the docs. Nothing decorative in the
  product. A display face is for the website only, and its licence must allow open-source
  redistribution.
- **Iconography.** Simple, geometric, legible at 16 px. The app icon must read at dock size
  beside Chrome, Arc and Firefox.

Test for a visual proposal: does it feel like a place you would go to concentrate? If it
feels like a place someone is trying to sell you something, it fails.

### Trademark hygiene

- **Only the word.** Only "Stedding", as this browser's name. No artwork, logos, names,
  quotations or other material from any book, film, game or other brand, in the product,
  the website, the docs, marketing, or a community space we control. Every piece of artwork
  is our own.
- **No claimed affiliation.** We do not state or imply endorsement by, or association with,
  anyone. This is a hygiene policy, not legal advice. If anyone objects to the name, we
  engage in good faith.
- **BSD clause 3 protects the name from forks.** It forbids using the names of the copyright
  holder or contributors to endorse or promote a derived product without written
  permission. Anyone may fork the code. A fork may not market itself as endorsed by
  Stedding, or pass itself off as Stedding. Written guidance for naming a fork does not
  exist yet.
- **Registration: TBD.** No trademark registration is recorded in this repository. Whether
  and where to file is open, and the decision gets an ADR when it is made.

When in doubt: the word, its meaning, our own artwork. Nothing else.

## Competitors

Where Stedding sits among browsers that matter to technical users who want an Arc-style
workflow, privacy and control.

Nook and Aura were read on 2026-10-11
([ADR 0021](decisions/0021-ideas-from-nook-and-aura.md)). Arc's sunset notice and the four
browsers named after the summary table were read on 2026-10-22. The other rows were last
checked on 2026-08-30. Re-check a rival before quoting it, preferably on the vendor's own
site.

### The reference point: Arc

**Arc** (The Browser Company of New York) defined the model: a sidebar of vertical tabs,
spaces, split view, a command bar, and an opinionated macOS-first design. It showed there is
demand for a browser that treats tab management as a product problem.

Arc is closed source, and its development has wound down. In May 2025 The Browser Company
announced security and Chromium updates only, with no new features, as the team moved to
Dia. In September 2025 Atlassian announced it was acquiring the company. On 2026-10-22 The
Browser Company told Arc users that Arc will be sunset on December 22, 2026: basic updates
until then; that day the app stops working on the Mac and on Windows, accounts close, and
personal data tied to an account is deleted within 30 days (its notice to users, read again
on 2026-10-23). stedding.dev/arc/ is the page for people moving. Stedding's core is
BSD-licensed and forkable, so an acquisition or a pivot cannot take the product away.

### Nook and Aura

Their behaviours are rebuilt from the descriptions here, never from their files
(ADR 0021): copyleft would stop the core being all BSD-3-Clause. Their AI features are not
taken ([ADR 0020](decisions/0020-no-bundled-model.md)). Boosts stay deferred
([ADR 0012](decisions/0012-defer-boosts-and-easels.md)). What is still open is
[ROADMAP.md](ROADMAP.md) M10.

#### Nook

Open source, Arc-style, for macOS on Apple silicon, in Swift and SwiftUI on WebKit
(`WKWebView`), GPL-3.0, with its name and icon reserved. Chrome extensions run only as far
as WebKit supports them. No Windows build.

| What was read | In Stedding |
|---|---|
| An ad blocker, with a "blocked page, continue?" screen | Blocking built, off by default (blocker Bk1–Bk13). The blocked-page screen is not (Bk20). |
| Tracking parameters stripped from every link opened | Built, off by default (clean links). |
| Child tabs under their opener, and Back returning to it | Built (tabs R56–R60). |
| A second press of a chord a web app also binds reaches the browser | Not built (S-90). |
| Shortcuts the user can change | Built (shortcuts Z10–Z22). |
| A video left playing moves into the sidebar | A card for what plays in the background, and a video that pops out to picture in picture (player Mp2–Mp10). The player inside the sidebar is not built (Mp1, S-95). |
| Peek and a little window: one page that becomes a tab without reloading | Built (peek). |
| "This page is open in another window: show here / go to window" | Built (windows G12). Pins and essentials are in every window (G2, ADR 0035). |
| The sidebar on the right | Built (sidebar Y34–Y43). |
| Closed tabs reopened from a stack kept across launches | A closed tab can be reopened (⇧⌘T), and Recently Closed lists it. Undo after closing is a setting (tabs R25–R30). |
| History and Downloads in the sidebar | Built (sidebar panels). |
| Import from Dia, and from Safari's export file | Built (import I28–I42), except Dia's sidebar (I33). |
| Folders in the pinned list | Built (folders F38). |
| A launch that loads only the selected tab | Built (tabs R45–R48). |
| Tabs that sleep on a timer | Built (tabs R39–R44). |
| One panel of site controls | Built into the page-info panel (site controls Si1–Si11). |
| A sidebar chat, a tab organizer, an agent-control server | Not taken (ADR 0020). |

#### Aura

Open source, Arc-style, iPad first (iPhone and visionOS too; the Mac through Catalyst), in
Swift and SwiftUI on WebKit. MPL-2.0 since 2025-06-06, and archived since then. Its rewrite
has no licence.

| What was read | In Stedding |
|---|---|
| A free colour or gradient per Space, and a searchable icon picker | Any emoji and any colour (spaces B41–B44). A two-colour gradient is not built. |
| Per-site CSS ("Boosts"), written in a side panel with a live preview | Deferred (ADR 0012). |
| Dark mode forced on web pages | Built (dark pages). |
| The sidebar on the right | Built (sidebar Y34–Y43). |
| Every keystroke sent to Google's suggestions, whatever the engine; API keys logged; every third-party script blocked | Not copied. |

### Summary

| Browser | Engine | Arc-style workflow | Open source | Licence | Chrome extensions | Status |
|---|---|---|---|---|---|---|
| Arc | Chromium | Yes (defined it) | No | — | Yes | Sunset 22 December 2026; basic updates until then |
| Dia | Chromium | No (AI-first) | No | — | Partial | Active (Atlassian) |
| Zen | Gecko | Yes | Yes | MPL-2.0 | No (Firefox add-ons) | Active |
| Helium | Chromium | Partial (tabs, split) | Yes | GPL-3.0 | Yes | Beta, active |
| Thorium | Chromium | No (stock UI) | Yes | BSD-3-Clause | Yes | Active |
| Brave | Chromium | No | Yes | MPL-2.0 | Yes | Active |
| Vivaldi | Chromium | Partial (power UI) | UI closed | Proprietary UI | Yes | Active |
| Floorp | Gecko | Partial | Yes | MPL-2.0 | No (Firefox add-ons) | Active |
| SigmaOS | WebKit | Partial (tasks) | No | — | Yes (vendor claim) | Active |
| Horse | Chromium | No (Trails) | No | — | Yes (recent) | Active, paid |
| Nook | WebKit | Yes | Yes | GPL-3.0 | Partial (WebKit's support) | Active (2026-10), macOS on Apple silicon |
| Aura | WebKit | Yes (iPad first) | Yes | MPL-2.0 | No | Archived (2025) |
| **Stedding** | Chromium | Yes | Yes | BSD-3-Clause | Yes | Before 1.0 ([releases](https://github.com/ysalitrynskyi/stedding-browser/releases)). macOS (Apple silicon) signed and notarized; Windows x64 unsigned ([S-56](../BACKLOG.md)). Both update themselves. No Linux. |

Also read on 2026-10-22, and not re-checked since: Ora and Refrax (WebKit, Mac, GPL-3.0),
Crest (WebKit and a second engine, Mac, iPhone and iPad, MPL-2.0), Nez (Chromium, Windows,
no source found).

### Chromium's own vertical tabs

Chromium has shipped vertical tabs since 153, and split view. A stock build hides the
vertical strip until the user turns it on. Stedding's sidebar is built on that view rather
than on a replaced tab strip ([ADR 0010](decisions/0010-ride-upstream-vertical-tabs.md)).
What is not upstream is the rest of the workflow — Spaces, pinned tabs and folders as
Stedding does them, the command bar — together with the privacy defaults and who controls
the roadmap. The positioning is [ADR 0011](decisions/0011-full-arc-parity.md): full
functional parity with Arc, plus what Arc could not offer.

### The gap

Users can already have:

- An Arc-style UI, open source, on Gecko (Zen, Floorp): no Chrome extensions.
- An Arc-style UI, open source, on WebKit (Nook; Aura is archived): partial or no Chrome
  extension support, and no Windows build from Nook.
- Open-source Chromium with a partial workflow (Helium has vertical tabs and split view, and
  not Spaces or a command bar; Thorium keeps Chrome's UI), or with a crypto business
  attached (Brave).
- The workflow on Chromium, closed source (Arc, now being shut down; Vivaldi's UI layer).

Stedding occupies the remaining cell: Chromium, so Chrome extensions and mainstream web
compatibility; the UI open with the rest; BSD-3-Clause, so it can be audited, forked and
embedded without copyleft. No other project in the table offers all three.

### Why a person might not switch yet

- **It is before 1.0.** Releases are on
  [GitHub](https://github.com/ysalitrynskyi/stedding-browser/releases), for macOS on Apple
  silicon (no Intel build) and Windows x64. The Mac image is signed and notarized. The
  Windows installer is not code-signed, so SmartScreen asks once (S-56). Linux is not
  shipped. Netflix, Disney+, Prime Video and Spotify's web player do not play: Widevine is
  not built (S-270).
- **The fork has to keep up.** Security updates mean rebasing onto Chromium stable, on a
  treadmill that has broken larger teams. The project started on 2026-08-30. Trusting it
  with daily browsing is still a bet on that work continuing.
- **No sync service of our own.** Google Sync is not available to a Chromium fork
  ([PRIVACY.md](PRIVACY.md)). The sidebar can sync through a folder the user picks
  ([ADR 0029](decisions/0029-sidebar-sync-through-a-folder.md)), for which Stedding makes no
  network request, or through WebDAV or S3 storage the user sets up
  ([ADR 0032](decisions/0032-sidebar-sync-through-webdav-or-s3.md)), for which it talks only
  to the address they typed. Both are off by default. They carry Spaces, pins, pinned
  folders and essentials, and, each with its own box, Stedding's settings and the list of
  extensions ([ADR 0037](decisions/0037-settings-and-extensions-in-sync.md)). Open tabs,
  history and passwords stay on each machine.
- **One maintainer.** Brave has a company. Zen has a large community. The BSD licence means
  anyone can pick the work up. A licence is not a maintainer.

The bet is that the cell above is worth occupying, and that shipping complete milestones
([the quality bar](ROADMAP.md#the-quality-bar)) is how the trust is earned.
