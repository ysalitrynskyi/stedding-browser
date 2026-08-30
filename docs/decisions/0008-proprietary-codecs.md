# 0008 — Proprietary codecs (H.264, AAC)

Status: Proposed — needs a human decision before M1
Date: 2026-08-30

## Context

A vanilla Chromium build compiles without proprietary codecs: `proprietary_codecs`
is off and `ffmpeg_branding` is `"Chromium"`. Royalty-free formats work — VP8, VP9,
AV1, Opus, Vorbis — and H.264 and AAC do not. This was confirmed empirically at M0
rather than assumed; `tooling/verify-build` reports the codec matrix of any build.

Google Chrome ships these codecs under licences Google holds. A fork does not inherit
them. The distinction is legal, not technical: the code paths exist in the tree and
are switched on by a build flag.

What the gap costs a user is not marginal. H.264 remains the default for a large part
of the web's video — many embeds, much of what news sites serve, a great deal of
WebRTC — and AAC is its usual audio partner. A browser that silently fails on those
is not one a person keeps using, which collides directly with the mandate in
`../../AGENTS.md`: a technical user should prefer this to Chrome within a day.

The options, as they actually stand:

1. **Ship without them.** Honest, free, and what Chromium and ungoogled-chromium do.
   Costs the user working video on a meaningful share of the web.
2. **Enable them and license.** `proprietary_codecs = true` with
   `ffmpeg_branding = "Chrome"`. H.264/AVC and AAC patent pools are administered by
   Via LA. Terms, thresholds and cost for a distribution of this size: **TBD** — not
   guessed here.
3. **Use the platform decoder.** macOS decodes H.264 in hardware through
   VideoToolbox, and Chromium can be built to prefer platform decoders. Whether this
   changes the licensing position is a legal question, not an engineering one, and
   it does not remove the need to demux the container.

## Decision

**Not made.** This ADR exists to hold the question open in the right place rather
than to let a build flag decide it by default.

It is out of scope for M0, whose build is deliberately vanilla. It must be settled
before M1 ships anything installable, because a release is a distribution and that is
what the licensing attaches to.

The decision needs a human: it commits money, or it commits the project to a known
product gap. An agent should not pick either on the project's behalf.

## Consequences

- Until this is resolved, every Stedding build behaves like vanilla Chromium on
  H.264 and AAC, and `tooling/verify-build` reports that as an expected note rather
  than a failure.
- If option 1 is chosen, it is a documented product limitation with user-visible
  consequences, and `../PRODUCT.md` and the release notes must say so plainly rather
  than let users discover it on a broken page.
- If option 2 is chosen, licensing terms and cost belong in this ADR before the flag
  is flipped, and the flag change is its own commit referencing them.
- Whichever is chosen, this ADR is superseded by one that records the outcome; per
  `README.md` in this directory, a superseded ADR is not edited.
