# Competitive landscape

Where Stedding sits among the browsers that matter to our audience: technical users
who want an Arc-style workflow UI, privacy, and control. Facts below were checked
against public sources on 2026-08-30; statuses change, so verify before quoting.

## The reference point: Arc

**Arc** (The Browser Company of New York) defined the feature model we admire:
sidebar with vertical tabs, spaces (workspaces), split view, a command bar, and an
opinionated, polished macOS-first design. It proved there is real demand for a
browser that treats tab management as a first-class product problem.

Arc is closed source and its development has wound down. The Browser Company
announced in May 2025 that Arc would receive security and Chromium updates only,
with no new features, as the team pivoted to Dia. In September 2025 Atlassian
announced it was acquiring The Browser Company (reported at ~$610 million). Arc
still runs, but its users are effectively on a maintenance-mode product owned by an
enterprise software company — which is precisely the situation Stedding exists to
make impossible: our core is BSD-licensed and forkable, so no acquisition or pivot
can take the product away.

## Direct and adjacent competitors

### Dia (The Browser Company / Atlassian)

AI-centric browser and the successor product to Arc. Closed source; as of this
writing available only on macOS 14+ with Apple Silicon. Dia's core interaction is
chatting with an AI about your tabs, not Arc's workflow model — most of Arc's
signature features are absent or simplified. Under Atlassian, its roadmap points at
work/enterprise use. Different lane: Dia bets on AI as the interface; we bet on the
workflow UI Arc abandoned.

### Zen Browser

Open-source (MPL-2.0), Firefox/Gecko-based browser with an Arc-like UI: vertical
sidebar, workspaces, compact mode, split view, "Glance" previews, community mods.
Actively developed with a large community (tens of thousands of GitHub stars) and
regular releases tracking Firefox. Zen is our closest spiritual peer — same thesis
(the Arc model deserves to live, in the open), different engine lane. The decisive
difference: Zen inherits Firefox's extension ecosystem and web compatibility
profile. Users who need Chrome extensions or Chromium-only site behavior cannot
switch to Zen. That is the lane we occupy, and why we did not simply join Zen
(see AGENTS.md: Firefox base considered and rejected).

### Helium

Open-source (GPL-3.0) Chromium-based browser by imput, with Google service
dependencies removed, built-in ad/tracker blocking, and a deliberately minimal
interface. In beta on macOS, Windows, and Linux; no native sync. Helium validates
our technical approach — a small, maintained patch set on Chromium with the Google
services stripped — and we study it for that reason. But Helium's product thesis is
minimalism: it intentionally does not build the sidebar/workspaces/command-bar
workflow layer that is Stedding's whole point. Also copyleft (GPL) where we are
permissive (BSD).

### Thorium

Chromium fork by a solo developer (Alex313031) focused on compiler-level
performance optimizations (AVX2/SSE4 builds and similar), with Chrome-like
features restored. Open source, BSD-3-Clause, active releases across platforms.
Thorium competes on raw speed claims, not workflow or privacy defaults, and ships
a stock Chrome-style UI. No overlap with our product surface; some overlap in
audience (users willing to run a niche Chromium fork).

### Brave

The largest privacy-positioned Chromium browser. Open source (MPL-2.0), full
Chrome extension support, ad/tracker blocking on by default, solid engineering,
long track record of tracking Chromium stable. Brave's business model is the
friction point for our audience: opt-in Brave Rewards paying users in BAT
cryptocurrency, sponsored new-tab background images shown by default, crypto
wallet and widgets built in, and a history of trust incidents (notably the 2020
affiliate-link autocomplete episode). Ships a conventional horizontal-tab UI
(vertical tabs exist as an option, not as the organizing model). Users who want
Brave's privacy without the crypto/ads surface area are a core Stedding audience.

### Vivaldi

Power-user Chromium browser: tab stacks, tiling/split view, workspaces, notes,
built-in mail and calendar, deep customization. Full extension support, no ad-based
business model. The blocker for us and our users: Vivaldi's UI layer is proprietary
and closed source (Vivaldi has publicly explained why it won't open it), and the
browser sends a documented user-counting ping with an installation identifier. A
feature-rich browser you cannot audit or fork is not in our lane.

### Floorp

Open-source (MPL-2.0) Firefox-based browser from the Japanese Ablaze community:
vertical tabs, workspaces, web panels, heavy customization. Same engine-lane
limitation as Zen (Firefox extensions only), with a smaller community and a less
Arc-shaped design. Adjacent, not competing.

### SigmaOS

Closed-source, Mac-only, WebKit-based browser aimed at task-based work browsing
(pages as todo items, spaces, AI features), on a freemium model. WebKit means no
Chrome extension support, and macOS-only by design. Interesting interaction ideas;
different engine, different openness, different audience breadth.

### Horse Browser

Closed-source, paid (subscription) browser by a solo developer. Replaces tabs
entirely with "Trails" — a persistent tree of pages that preserves how you got
somewhere — and markets to users with ADHD. Chromium-based; added extension support
in August 2026. A genuinely novel navigation model, but a niche, closed, paid
product. Evidence that small teams can ship real browser UX innovation — and of how
much distribution a solo closed product can't get.

## Summary table

| Browser | Engine | Arc-style workflow UI | Open source | License | Chrome extensions | Status (2026-08) |
|---|---|---|---|---|---|---|
| Arc | Chromium | Yes (defined it) | No | — | Yes | Maintenance mode |
| Dia | Chromium | No (AI-first) | No | — | Partial | Active (Atlassian) |
| Zen | Gecko | Yes | Yes | MPL-2.0 | No (Firefox add-ons) | Active |
| Helium | Chromium | No (minimal) | Yes | GPL-3.0 | Yes | Beta, active |
| Thorium | Chromium | No (stock UI) | Yes | BSD-3-Clause | Yes | Active |
| Brave | Chromium | No | Yes | MPL-2.0 | Yes | Active |
| Vivaldi | Chromium | Partial (power UI) | UI closed | Proprietary UI | Yes | Active |
| Floorp | Gecko | Partial | Yes | MPL-2.0 | No (Firefox add-ons) | Active |
| SigmaOS | WebKit | Partial (tasks) | No | — | No | Active |
| Horse | Chromium | No (Trails) | No | — | Yes (recent) | Active, paid |
| **Stedding** | Chromium | Yes (goal) | Yes | BSD-3-Clause | Yes (hard req.) | M0, no installer |

## The gap we occupy

Every cell combination above is taken except one. Users today can have:

- Arc's workflow UI, open source — **only on Gecko** (Zen, Floorp): lose Chrome
  extensions and Chromium web compatibility.
- Open-source, de-Googled Chromium — **only without the workflow UI** (Helium,
  Thorium), or **with a crypto/ads business model attached** (Brave).
- The workflow UI on Chromium — **only closed source** (Arc, now unmaintained;
  Vivaldi's closed UI layer).

Stedding targets the empty cell: an Arc-style workflow browser that is
simultaneously **Chromium-based** (full Chrome extension compatibility, mainstream
web compatibility), **fully open source including the UI layer**, and
**permissively licensed** (BSD-3-Clause — auditable, forkable, embeddable, no
copyleft conditions). No other project on this list offers all three.

## Why users would not pick us today

Honesty section. As of 2026-08-30:

- **We don't exist as a product yet.** There is build tooling and no installable
  browser (see ROADMAP.md — M0). Every browser
  above ships today; Zen and Brave ship polished products today.
- **No track record.** Keeping a Chromium fork current with security updates is a
  treadmill that has broken larger teams. Until we demonstrate months of on-time
  stable rebases, trusting us with your daily browsing is a leap.
- **No sync.** Google Sync is unavailable to Chromium forks (see PRIVACY.md), and
  our own sync does not exist yet. Multi-device users lose real functionality.
- **Small team, bus factor.** Brave has a company behind it; Zen has a large
  community. We have neither yet. The BSD license is the mitigation — anyone can
  pick up the work — but a license is not a maintainer.
- **macOS only at first.** Windows and Linux users have nothing to try until later
  milestones.

The bet is that the empty cell above is worth occupying anyway, and that shipping
complete, polished milestones (see QUALITY.md) closes the trust gap over time.
