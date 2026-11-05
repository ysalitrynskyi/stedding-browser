# Vision, name, brand and competitors

Stedding Browser is a fully open-source, Chromium-based desktop browser: a sidebar
of vertical tabs, Spaces, pinned tabs and folders, split view, and a command bar.
It is built for technical users who want privacy, control, and a productive UI,
without betting a daily workflow on a company's pivot, acquisition, or monetization.

This document says why the project exists, what it values, who it is for, and what
it will not be. It records the name and the brand, and the browsers Stedding is
measured against.

## Why this exists

Arc showed that a sidebar, workspaces, and a command bar are a better way to work
than a row of horizontal tabs. People who adopted that model rarely wanted to go
back. Arc was never open source. When its maker moved on, nobody outside the
company could pick it up.

The open browsers in that neighbourhood do not fill the same space. Zen is built
on Firefox, so it does not run Chrome extensions. Nook is built on WebKit, for the
Mac, under a copyleft licence. Brave is open Chromium with a conventional UI, and
it bundles crypto and rewards. The comparison is in "Competitors", below.

The short version: no permissively licensed Chromium browser carries that workflow
forward, UI included. That is the gap Stedding fills.

The core is BSD-3-Clause. If the maintainers lose interest, pivot, or sell, anyone
can fork the browser and keep going. The licence is the exit Arc never gave anyone.

## What we are building

A minimal patch-set fork of Chromium stable, the Brave/Helium model, not a hard
fork. UI work stays as high in the stack as it can, so tracking upstream stays
cheap. Full Chrome extension compatibility is a hard requirement.

macOS (Apple silicon) and Windows ship. Linux is next and is not shipped
([ADR 0006](decisions/0006-platform-order-macos-first.md)). The Windows build is
made on a Windows PC, the Mac build on a Mac.

Every milestone ends in something installable. A feature ships with its shortcuts,
settings, edge cases and polish, or it does not ship. The product, the architecture
and the quality bar are [PRODUCT.md](PRODUCT.md), [ARCHITECTURE.md](ARCHITECTURE.md)
and [ROADMAP.md](ROADMAP.md#the-quality-bar).

## Values

**User control.** The browser answers to the person using it. Defaults are
opinionated, and everything meaningful is configurable. Nothing has to ask a server
for permission. The profile, the data and the machine stay the user's.

**Privacy by default.** No telemetry by default, and none in the builds to turn on.
Privacy protections are product features, held to the same bar as the rest, not
checkbox settings buried three menus deep. The defaults are in
[PRIVACY.md](PRIVACY.md).

**Openness.** The browser is developed in public under BSD-3-Clause. A decision
that is hard to reverse is an ADR in [decisions/](decisions/), written before or
with the change. Closed or paid add-ons may exist someday. The core — everything
needed to build, run and fork the browser — stays permissively licensed.

**Craft.** Shipping polished beats shipping first. A feature that is 90% done is
0% done. Performance, keyboard support and detail work are part of every feature,
not a later pass.

## Who it is for

Technical users: developers, researchers, power users. People who live in a browser
all day, keep dozens of tabs across several projects, rely on extensions, and notice
when software wastes their time. People who read a privacy policy, or would rather
use software that makes reading one unnecessary.

It is for former Arc users who want that workflow on a foundation nobody can take
away.

It is not, at least at first, aimed at someone who wants a browser that manages
itself. Stedding is opinionated and rewards investment. The defaults should be
good. The payoff is in the Spaces, the command bar and the keyboard.

## Non-goals

These are commitments, not omissions. Absence from this list is not a promise.
Presence on it is.

- **No crypto or web3 features.** No wallet, no tokens, no rewards program, no
  blockchain integration of any kind. Anyone who wants these can install an
  extension.
- **No ads or sponsored placements, ever.** No sponsored tiles, no paid default
  shortcuts, no affiliate-injected results, no "partner" content. The new tab page
  belongs to the user.
- **No AI gimmicks bolted on.** Stedding ships no bundled model: no command-bar
  chat, no agent that holds a Space's cookies
  ([ADR 0020](decisions/0020-no-bundled-model.md)). Any later feature that sends
  page content or browsing data to a model needs an ADR of its own, and is opt-in,
  clearly labelled and off by default. Dia is for people who want an AI browser.
  Stedding is not that.
- **No mobile, for now.** Desktop — macOS, Windows, Linux — is the whole scope
  until 1.0 is shipped and stable. A mobile browser is a different product. Doing
  it badly would violate the quality bar.
- **Not a Chrome re-skin.** Stedding is an opinionated workflow browser. The point
  is the sidebar, Spaces, split view and the command bar. A change that merely
  recolors Chrome is not worth a patch.

## What success looks like

A technical user downloads an installer, opens it, imports a profile, and prefers
it to Chrome or Arc within a day. Every milestone on the way ends in something
installable ([ROADMAP.md](ROADMAP.md)).

Success is not a user count we would have to invent. The project succeeds when it
is someone's daily browser and they stop thinking about it — and when, if this
project ends, its users are not stranded.

## The name

The naming decision record.

Date: 2026-08-30.
Status: decided. The product is **Stedding Browser**. The canonical domain is
**stedding.dev**.
See also: [ADR 0001](decisions/0001-product-name-stedding.md),
[ADR 0004](decisions/0004-domain-stedding-dev.md), and "Brand and voice", below.

### Method

Candidate names came from invented and real English words and coinages, across
nautical, avian, wayfinding and shelter themes.

Every candidate was vetted with live web searches on the same day, against five
criteria:

| Criterion | What we checked |
|---|---|
| Existing browsers | Any shipping or announced browser with the same or a confusable name |
| Software collisions | Apps, CLIs, SaaS products, packages or dev tools using the name |
| Trademark exposure | Active companies or rights-holders in adjacent markets, especially ones selling to our audience |
| Pronunciation | One obvious reading for an English speaker; no competing readings |
| SEO headroom | Realistic odds of ranking first for the exact phrase "{Name} Browser" |

A name failed if it collided with any browser, with software our audience
(developers, DevOps, technical users) already knows, or with a rights-holder likely
to contest it. It also had to be usable without implying affiliation with anyone.

### Why the early working name was rejected

The early working name failed on two counts. A well-funded software company sells
to the same technical audience under that name. Two software products, one name,
overlapping buyers: a textbook trademark-confusion posture, and a company with the
resources to contest it. English speakers also pronounced it two ways. A name people
cannot say the same way is a name they cannot recommend out loud. Either problem
alone might have been survivable. Together they were disqualifying.

### Finalists

#### Stedding — winner

- **Meaning matches the product.** Stedding means a haven, a settled, kept place.
  The browser is a place to use the web where the surveillance economy cannot
  reach. The name is the pitch.
- **Clean field.** No products, no live trademarks, and no exact-phrase competition
  for "Stedding Browser" on the day of the search. The results page was effectively
  empty.
- **Plain English roots.** The name is shaped on "steading", a farmstead or
  homestead, from "stead", an old word for a place. We use only the word, as this
  browser's name, and claim no affiliation with anyone.

#### Vesper — runner-up

Highly brandable, pleasant to say, and an empty exact-phrase results page for
"Vesper Browser" on the day of the search. Some existing bare-name software (small
apps and projects) was survivable, and still not the clean field Stedding offered.

### Notable eliminations

| Candidate | Reason eliminated |
|---|---|
| Heron | **Herond Browser** — an active Chromium-based privacy browser, one letter away; direct confusion in our category |
| Vela | Three existing browsers already use the name |
| Rove | rovebrowser.com exists |
| Lumar | Lumar (formerly DeepCrawl), an SEO product sold to technical marketers; also a near-homophone of Lemur Browser |
| Skiff | A dead privacy brand (acquired by Notion, then shut down) |
| Scry | An existing "Scry browser app"; also rhymes with "spy" |
| Magpie | Saturated across apps and tools |
| Lodestar | Saturated; several software products |
| Prow | Dev-tool collisions |
| Cairn | Saturated across apps and dev tools |
| Tern | Dev-tool collision (Tern, the JavaScript analysis engine, among others) |
| Pharos | Saturated; several software products |

### Domain

**stedding.dev** is the canonical domain. DNS is on Cloudflare.

- **Short brand domain.** steddingbrowser.com was available. Exact-match-domain SEO
  is mostly obsolete. Ranking for "Stedding Browser" depends on content and links,
  not on the domain string.
- **.dev fits the audience**, and the whole .dev zone is HSTS-preloaded, so the site
  is HTTPS-only by construction.
- **stedding.top was rejected.** Cheap, and the TLD's spam association hurts trust
  on the download page.
- **stedding.com, stedding.app and stedding.co** were already registered by
  unrelated parties. Acceptable: people search for the browser by name. Revisit
  buying one only if the project grows enough to justify it.

The site is a website. Update checks do not go through it
([ADR 0014](decisions/0014-github-releases-as-update-channel.md)).

### Outcome

- Product name: **Stedding Browser**
- Domain: **stedding.dev**
- GitHub: `ysalitrynskyi/stedding-browser`
- How to use the name: "Brand and voice", below

## Brand and voice

How Stedding presents itself: the name, the voice, the look, and the rules that
keep all three safe. How the name was chosen is in "The name", above.

### Using the name

**Stedding Browser** on first mention, **Stedding** after that. The app is
`Stedding`. The macOS bundle id is `dev.stedding.Stedding`
([ADR 0009](decisions/0009-macos-bundle-identifier.md)).

#### Meaning and story

Stedding means a haven: a settled, kept place. The name is shaped on the English
word "steading", a farmstead or homestead. "Steading" comes from Middle English
"steding" ("place, farm"), and that from Old English "stede" ("locality, place,
site"). "Stead" is an old English word for a place.

That is what this browser is for: a place to use the web where surveillance and
vendor control cannot reach. Tracking, telemetry, ad-driven defaults, and a roadmap
set by someone else's business stop at the door.

Say it **STED-ding**. It rhymes with "wedding". Two syllables, stress on the first.

### Voice

Calm, precise, no hype. Write the way a good engineer explains something to a
colleague: plainly, accurately, without selling.

- **Say what the software does.** Not what it "revolutionizes", "supercharges" or
  "reimagines". If a sentence would survive on a competitor's site unchanged, it
  says nothing. Cut it.
- **Be concrete.** "No telemetry by default" beats "privacy-first". A number only
  when it was measured. Otherwise leave it out, or write TBD.
- **Be quiet.** No exclamation marks in product copy. No emoji in docs or release
  notes. No countdowns, no "last chance".
- **Respect the reader.** The audience is technical. Do not pad, do not
  over-explain, and do not hide a limitation. State a trade-off plainly.
- **Admit what is unfinished.** "Not implemented yet" is a complete sentence.

The same register everywhere: the website, release notes, error messages, settings
copy and social posts. If it would sound wrong in a commit message, it is wrong on
the website.

### Taglines

Chosen with the website (stedding.dev, 2026-09-16). **"Your haven on the web."**
leads. **"A quiet place to get things done."** is for where the workflow is the
subject. The first is the name's meaning in five words. The second is what daily
use feels like.

### Visual direction

The mark and the palette exist. The mark is generated from one geometry file,
[`tooling/brand/mark.py`](../tooling/brand/mark.py), into
[`branding/`](../branding/README.md): an arch over a hearth. Its colours are slate
`#2F4858`, cream `#F2E9DE`, amber `#E8B04B` and ink `#1C2B33`.

The browser's light chrome is Tailwind's slate-300 (`#CBD5E1`). The dark chrome is
a blue-to-plum gradient, `#21263A` to `#31243A`. A Space's colour tints the sidebar
and nothing else. Chromium's own surfaces keep its baseline palette (patch 0105,
[S-310](history/archive.md)). The mark's amber dot stays; it is the one amber left
(S-310). Neither the mark nor the palette has an ADR.

Rules for any new visual work:

- **Mood: quiet and settled.** A settled, kept place. Calm, grounded, unhurried.
  Not neon gradients, glassy chrome or startup confetti.
- **Motifs: shelter and ground.** A roof line, an arch, a threshold, a hearth,
  stone. Abstract geometry from these, not a literal illustration. Nothing from
  anyone else's work (trademark hygiene, below).
- **Both themes.** Light and dark. The chrome is where the brand lives daily.
- **Typography.** A clear sans-serif for the UI and the docs. Nothing decorative in
  the product. A display face is for the website only, and its licence must allow
  open-source redistribution.
- **Iconography.** Simple, geometric, legible at 16 px. The app icon must read at
  dock size beside Chrome, Arc and Firefox.

Test for a visual proposal: does it feel like a place you would go to concentrate?
If it feels like a place someone is trying to sell you something, it fails.

### Trademark hygiene

The name is shaped on ordinary English words. These rules keep it clear of anyone
else's brand or work.

- **Only the word.** Only "Stedding", as this browser's name. No artwork, logos,
  names, quotations or other material from any book, film, game or other brand, in
  the product, the website, the docs, marketing, or a community space we control.
  Every piece of artwork is our own.
- **No claimed affiliation.** We do not state or imply endorsement by, or
  association with, anyone.
- **Plain English roots.** "Steading", a farmstead or homestead, from "stead", an
  old word for a place. This is a hygiene policy, not legal advice. If anyone
  objects to the name, we engage in good faith.
- **BSD clause 3 protects the name from forks.** BSD-3-Clause forbids using the
  names of the copyright holder or contributors to endorse or promote a derived
  product without written permission. Anyone may fork the code. A fork may not
  market itself as endorsed by Stedding, or pass itself off as Stedding. Written
  guidance for naming a fork does not exist yet.
- **Registration: TBD.** No trademark registration is recorded in this repository.
  The last note is 2026-08-30: none had been filed. Whether and where to file is
  open. The decision gets an ADR when it is made.

When in doubt: the word, its meaning, our own artwork. Nothing else.

## Competitors

Where Stedding sits among browsers that matter to technical users who want an
Arc-style workflow, privacy and control.

Stedding's row is the release of 2026-10-28. Nook and Aura were read on 2026-10-11
([ADR 0021](decisions/0021-ideas-from-nook-and-aura.md)). The other rows were last
checked on 2026-08-30, except the Arc sunset notice below and the four browsers
named after the summary table (2026-10-22). Re-check a rival before quoting it.
Prefer the vendor's own site.

### The reference point: Arc

**Arc** (The Browser Company of New York) defined the model: a sidebar of vertical
tabs, spaces, split view, a command bar, and an opinionated macOS-first design. It
showed there is demand for a browser that treats tab management as a product
problem.

Arc is closed source, and its development has wound down. The Browser Company
announced in May 2025 that Arc would receive security and Chromium updates only,
with no new features, as the team moved to Dia. In September 2025 Atlassian
announced it was acquiring The Browser Company. Arc's users were left on a
maintenance-mode product owned by an enterprise software company. Stedding's core
is BSD-licensed and forkable, so an acquisition or a pivot cannot take the product
away.

On 2026-10-22 The Browser Company told Arc users that Arc will be sunset on December 22,
2026: Arc keeps basic updates until then; that day the app stops working on the Mac and on
Windows, accounts close, and personal data tied to an account is deleted within 30 days (its
notice to users, read again on 2026-10-23; stedding.dev/arc/ is the page for people moving).

### Nook and Aura

Their behaviours are rebuilt from the descriptions here, never from their files
(ADR 0021). Copyleft would stop the core being all BSD-3-Clause. Their AI features
are not taken ([ADR 0020](decisions/0020-no-bundled-model.md)). Boosts stay deferred
([ADR 0012](decisions/0012-defer-boosts-and-easels.md)). What has shipped, and what
is left, is [ROADMAP.md](ROADMAP.md) M10.

#### Nook

Open source, Arc-style, for macOS on Apple silicon, in Swift and SwiftUI on WebKit
(`WKWebView`), GPL-3.0, with its name and icon reserved. Chrome extensions run only
as far as WebKit supports them. No Windows build.

| What was read | In Stedding |
|---|---|
| An ad blocker, with a "blocked page, continue?" screen | Request blocking, off by default (blocker Bk1–Bk13). The blocked-page screen is not built (Bk20). |
| Tracking parameters stripped from every link opened | Built (clean links, S-89). |
| Child tabs under their opener, and Back returning to it | The nesting is built (tabs R56–R59). Back returning to the opener is not (R60). |
| A second press of a chord a web app also binds reaches the browser | Not built (S-90). |
| Shortcuts the user can change | Built (S-91). |
| A video left playing moves into the sidebar | Not built (S-95). A picture-in-picture key exists (player Mp5) and opens Chromium's own window until the player does. |
| Peek and a little window: one page that becomes a tab without reloading | Built (peek, S-93). |
| "This page is open in another window: show here / go to window" | Not built (S-94). |
| The sidebar on the right | Built (S-96). |
| Closed tabs reopened from a stack kept across launches | A closed tab can be reopened (S-97), and Recently Closed lists it. |
| History and Downloads in the sidebar | Built (S-98). |
| Import from Dia, and from Safari's export file | Dia's bookmarks, history and passwords, and Safari's export, are built (import I28–I32, I34–I42). Dia's sidebar is not (I33). Settings and command-bar rows for those imports are not built. |
| Folders in the pinned list | Built (folders F38). An Arc import brings a pinned folder in pinned (import I3). |
| A launch that loads only the selected tab | Built (tabs R45–R48). |
| Tabs that sleep on a timer | Built (tabs R39–R44). |
| One panel of site controls | Built into the page-info panel (site controls Si1–Si11). |
| A sidebar chat, a tab organizer, an agent-control server | Not taken (ADR 0020). |

#### Aura

Open source, Arc-style, iPad first (iPhone and visionOS too; the Mac through
Catalyst), in Swift and SwiftUI on WebKit. MPL-2.0 since 2025-06-06, and archived
since then. Its rewrite has no licence.

Worth having, and not to copy:

| What was read | In Stedding |
|---|---|
| A free colour or gradient per Space, and a searchable icon picker | Any emoji and any colour are built (S-99). A two-colour gradient is not. |
| Per-site CSS ("Boosts"), written in a side panel with a live preview | Deferred (ADR 0012). |
| Dark mode forced on web pages | Built (S-100). |
| The sidebar on the right | Built (S-96). |
| Every keystroke sent to Google's suggestions, whatever the engine; API keys logged; every third-party script blocked | Not copied. |

### Summary

| Browser | Engine | Arc-style workflow | Open source | Licence | Chrome extensions | Status |
|---|---|---|---|---|---|---|
| Arc | Chromium | Yes (defined it) | No | — | Yes | Sunset 22 December 2026; until then, security and Chromium updates only |
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
| **Stedding** | Chromium | Yes | Yes | BSD-3-Clause | Yes | 0.3.0 beta 22 (2026-10-28), Chromium 156.0.8078.48. macOS (Apple silicon) signed and notarized; Windows x64 unsigned ([S-56](../BACKLOG.md)). Both update themselves. No Linux. |

Also read on 2026-10-22, and not re-checked since: Ora and Refrax (WebKit, Mac,
GPL-3.0), Crest (WebKit and a second engine, Mac, iPhone and iPad, MPL-2.0), Nez
(Chromium, Windows, no source found).

### Chromium's own vertical tabs

Chromium has shipped vertical tabs since 153: collapse, pinning, drag-to-reorder,
persisted width and state, a settings toggle, in-product help and interactive tests.
The decision to build Stedding's sidebar on that view, rather than replace the tab
strip, is [ADR 0010](decisions/0010-ride-upstream-vertical-tabs.md).

Upstream registers `vertical_tabs.enabled` false, so a stock build hides the strip
until the user turns it on. Patch 0001 registers it true. Expand-on-hover is a
separate preference, `vertical_tabs.expand_on_hover`, which upstream already
registers true. Split view is also upstream: `tabs::kSplitViewHorizontal` is enabled
by default in that tree, and no Stedding patch changes it.

What is not upstream is the rest of the workflow: Spaces, pinned tabs and folders as
Stedding does them, and the command bar, together with the privacy defaults and who
controls the roadmap.

The owner answered the positioning question in
[ADR 0011](decisions/0011-full-arc-parity.md): full functional parity with Arc, plus
what Arc could not offer.

### The gap

Users can already have:

- An Arc-style UI, open source, on Gecko (Zen, Floorp): no Chrome extensions.
- An Arc-style UI, open source, on WebKit (Nook; Aura is archived): partial or no
  Chrome extension support, and no Windows build from Nook.
- Open-source Chromium with a partial workflow (Helium has vertical tabs and split
  view, and not Spaces or a command bar; Thorium keeps Chrome's UI), or with a
  crypto business attached (Brave).
- The workflow on Chromium, closed source (Arc, now being shut down; Vivaldi's UI
  layer).

Stedding occupies the remaining cell: Chromium, so Chrome extensions and mainstream
web compatibility; the UI open with the rest; BSD-3-Clause, so it can be audited,
forked and embedded without copyleft. No other project in the table offers all three.

### Why a person might not switch yet

- **It is a beta.** The current release is 0.3.0 beta 22 (2026-10-28), for macOS and
  Windows, built on Chromium 156.0.8078.48. The Mac image is signed and notarized and
  has updated itself since 0.2.0 beta 16. The Windows installer has updated itself
  since 0.2.0 beta 19 and is not code-signed, so SmartScreen asks once (S-56). The
  repository's main branch is rebased onto Chromium 157.0.8103.31 and is not what
  that release installs. Google's schedule puts M157 on stable on 2026-11-03. Linux
  is not shipped. There is no Intel Mac build.
- **The fork has to keep up.** Security updates mean rebasing onto Chromium stable,
  on a treadmill that has broken larger teams. The project started on 2026-08-30.
  Trusting it with daily browsing is still a bet on that work continuing.
- **No sync service of our own.** Google Sync is not available to a Chromium fork
  ([PRIVACY.md](PRIVACY.md)). The sidebar can sync through a folder the user picks,
  off by default
  ([ADR 0029](decisions/0029-sidebar-sync-through-a-folder.md)): Spaces, pins, pinned folders
  and essentials. Stedding makes no network request for it. Open tabs, history and
  passwords stay on each machine.
- **One maintainer.** Brave has a company. Zen has a large community. The BSD licence
  means anyone can pick the work up. A licence is not a maintainer.

The bet is that the cell above is worth occupying, and that shipping complete
milestones ([the quality bar](ROADMAP.md#the-quality-bar)) is how the trust is earned.
