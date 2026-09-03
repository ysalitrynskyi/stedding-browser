# 0008 — Proprietary codecs (H.264, AAC)

Status: Accepted
Supersedes the Proposed state of 2026-08-30, decided by the operator 2026-08-31.
Date: 2026-08-30

## Context

A vanilla Chromium build compiles without proprietary codecs: `proprietary_codecs`
is off and `ffmpeg_branding` is `"Chromium"`. Royalty-free formats work — VP8, VP9,
AV1, Opus, Vorbis — and H.264 and AAC do not.

This is now measured rather than assumed. `tooling/verify-build` against the M0 vanilla
build of `153.0.8010.12` decoded real frames from VP9/WebM and AV1/MP4, and failed on
H.264+AAC with:

```
MediaError 4: PipelineStatus::DEMUXER_ERROR_NO_SUPPORTED_STREAMS:
FFmpegDemuxer: no supported streams
```

`canPlayType` returns `no` for both `video/mp4; codecs="avc1.42E01E"` and
`audio/mp4; codecs="mp4a.40.2"`, while returning `probably` for VP8, VP9, AV1, Opus,
Vorbis and MP3. The same harness run against Chrome for Testing — which does ship the
codecs — passes all of them, so the difference is the build configuration and not the
test.

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

**Ship them.** `proprietary_codecs = true` and `ffmpeg_branding = "Chrome"` in every
build configuration, so H.264, AAC, MP3 and the MP4 container work as they do in every
mainstream browser.

The reasoning is the mandate in `../../AGENTS.md`: a technical user should prefer this
to Chrome within a day. A browser that silently fails on a large share of the web's
video does not clear that bar, and "we did not want the licensing conversation" is not
an answer a user cares about.

**What this obliges us to.** Distributing binaries that decode AVC/H.264 and AAC
carries patent-licensing obligations, administered by Via LA. Building for yourself is
not distribution; publishing a `.dmg` is. That obligation attaches at the first public
release, not now, and it is a cost of being a real browser rather than a reason not to
be one. It is written here so nobody discovers it at release time.

Two things this does not change. We build with Chromium branding and our own, never
Google Chrome branding, so no Google licence is implied or relied on. And the codecs
are compiled in rather than fetched, so there is no new network endpoint and nothing
for `../PRIVACY.md` to declare.

## Consequences

- `proprietary_codecs = true` and `ffmpeg_branding = "Chrome"` in every configuration
  under `tooling/args/`; `tooling/verify-build` treats H.264+AAC playback as a pass
  condition, not a note.
- The patent-licensing obligation (Via LA, AVC/H.264 and AAC) attaches at the first
  public release. Terms and cost are **TBD** and are recorded in a superseding ADR
  before the 1.0 release checklist in `../QUALITY.md` passes; unsigned pre-release
  betas to testers are made in the meantime with this obligation stated in their
  release notes.
- Chromium branding plus our own, never Google Chrome's, so no Google licence is
  implied; codecs are compiled in, so `../PRIVACY.md` has nothing new to declare.
