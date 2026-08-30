# Brand

How Stedding presents itself: the name, the voice, the look, and the rules
that keep all three safe to use. The naming decision record — 38 candidates and
the criteria they were vetted against — is in `docs/NAMING.md`.

## The name

**Stedding Browser.** "Stedding Browser" on first mention; "Stedding" after
that. The binary, bundle, and package identifiers use `stedding`.

### Meaning and story

In Robert Jordan's *Wheel of Time*, a stedding is a haven — a place where the
One Power cannot touch you. Inside a stedding you cannot be reached by the
force that shapes everything outside it.

That is the metaphor, and it maps precisely onto what this browser is for: a
place to use the web where surveillance and vendor control cannot reach. The
power that shapes the rest of the web — tracking, telemetry, ad-driven
defaults, roadmaps set by someone else's business model — stops at the door.

The word itself is an English coinage rooted in "stead" and the archaic
"steading" (a homestead — a settled, kept place). Even without the fantasy
reference, it reads as what it is: a quiet, held ground.

### Pronunciation

**STED-ding.** Rhymes with "wedding." Two syllables, stress on the first.

## Voice

Calm, precise, no hype. Stedding writes the way a good engineer explains
something to a colleague: plainly, accurately, without selling.

- **Say what the software does.** Not what it "revolutionizes," "supercharges,"
  or "reimagines." If a sentence would survive on a competitor's site
  unchanged, it says nothing; cut it.
- **Be concrete.** "No telemetry by default" beats "privacy-first." Numbers
  only when they are real and measured; write TBD rather than invent one.
- **Be quiet.** No exclamation marks in product copy. No emoji in docs or
  release notes. No countdowns, no FOMO, no "last chance."
- **Respect the reader.** The audience is technical. Do not pad, do not
  over-explain, do not hide limitations. State trade-offs plainly.
- **Admit what is unfinished.** "Not implemented yet" is a complete sentence
  and better brand-building than a vague promise.

The same register applies everywhere: website, release notes, error messages,
settings copy, and social posts. If it would sound wrong in a commit message,
it is wrong on the website.

## Taglines

Candidates. None is final; the choice belongs with the first website release.

1. **"Your haven on the web."** — The name's meaning in five words. Warm,
   direct, works even for readers who have never heard of a stedding.
2. **"The web, on your terms."** — Leads with control rather than shelter.
   Broader, but less distinctive; many privacy products could say it.
3. **"Where the web can't track you back."** — Concrete and slightly pointed;
   states the privacy promise as a fact about the place.
4. **"A quiet place to get things done."** — Leads with the workflow product
   (calm UI, workspaces, focus) rather than privacy. Honest about what daily
   use actually feels like.
5. **"Out of reach. In control."** — The haven metaphor and the control value
   in four words. Strongest as a short mark next to the logo; too clipped to
   stand entirely alone.

Working recommendation: lead with **"Your haven on the web"** and use
**"A quiet place to get things done"** where the workflow features are the
subject. Revisit before launch.

## Visual direction

Suggestions, not decisions — this space is open for exploration. The logo and
palette do not exist yet; when they do, they get recorded here and in an ADR
if the choice is hard to reverse.

- **Mood: quiet and natural.** A stedding is old-growth forest and standing
  stone. Calm, grounded, unhurried. The opposite of neon gradients, glassy
  chrome, and startup confetti.
- **Motifs: grove and stone.** Trees, a clearing, a ring of stones, a
  threshold. Abstract geometry derived from these beats literal illustration —
  and literal fantasy artwork is ruled out entirely (see trademark hygiene).
- **Palette.** Deep greens, stone grays, warm off-whites; sparing accent
  color. Must hold up in both light and dark UI themes, since the browser
  chrome is where the brand lives daily.
- **Typography.** A clear, unremarkable-in-the-best-way sans-serif for UI and
  docs. Nothing decorative in the product; any display face is for the website
  only. Specific faces: TBD, but license terms must permit open-source
  redistribution.
- **Iconography.** Simple, geometric, legible at 16 px. The app icon must read
  at dock size next to Chrome, Arc, and Firefox without shouting.

Test for any visual proposal: does it feel like a place you would go to
concentrate? If it feels like a place someone is trying to sell you something,
it fails.

## Trademark hygiene

The name borrows a metaphor, not a property. These rules keep it that way.

- **We use only the word.** "Stedding" appears as a name for this browser and
  nothing more. No Wheel of Time trademarks, logos, cover art, illustrations,
  maps, character or place names, quotations, or excerpts — not in the product,
  the website, the docs, marketing, or community spaces we control.
- **No claimed affiliation.** We do not state or imply endorsement by, or
  association with, Robert Jordan's estate, Bandersnatch Group, Sony Pictures
  Television, Amazon, or any other Wheel of Time rights holder. The origin
  story above is told as attribution, not association.
- **Different goods, ordinary word.** The browser is desktop software; the
  Wheel of Time marks cover fiction and entertainment properties. We stay
  clearly on our side of that line and additionally lean on the word's plain
  English roots ("stead," "steading"). This is a hygiene policy, not legal
  advice; if a rights holder ever objects, we engage in good faith.
- **BSD clause 3 protects the name from forks.** BSD-3-Clause forbids using
  the names of the copyright holder or contributors to endorse or promote
  derived products without written permission. Anyone may fork the code — that
  is the point of the license — but a fork may not market itself as endorsed
  by, or pass itself off as, Stedding. Guidance for fork naming will live in
  `CONTRIBUTING.md`.
- **Registration status: TBD.** No trademark registration has been filed as of
  2026-08-30. Whether and where to file is an open question; the decision gets
  an ADR when it is made.

When in doubt: the word, the metaphor, our own artwork — nothing else.
