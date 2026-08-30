# Naming decision record

Date: 2026-08-30
Status: Decided — the product is named **Stedding Browser**, canonical domain **stedding.dev**.
See also: `decisions/0001-product-name-stedding.md`, `decisions/0004-domain-stedding-dev.md`, `BRAND.md`.

## Method

We generated 38 candidate names across three pools:

1. **Invented-setting deep cuts** — short words from fiction that work as
   standalone English-adjacent words (the project's working name came from here).
2. **Terms from a second invented setting** — same idea, different universe.
3. **Invented and real English words** — nautical, avian, wayfinding, and
   shelter-themed vocabulary, plus coinages.

Every candidate was vetted with live web searches on the same day against five criteria:

| Criterion | What we checked |
|---|---|
| Existing browsers | Any shipping or announced browser with the same or a confusable name |
| Software collisions | Apps, CLIs, SaaS products, packages, or dev tools using the name |
| Trademark exposure | Active companies or rights-holders in adjacent markets, especially ones selling to our audience |
| Pronunciation | One obvious reading for an English speaker; no competing readings |
| SEO headroom | Realistic odds of ranking #1 for the exact phrase "{Name} Browser" |

A name failed if it collided with any browser, with software our target users
(developers, DevOps, technical users) already know, or with a rights-holder likely to
contest it. Fictional-universe names carried an extra test: the word had to be usable
as a plain word without implying affiliation with the rights-holder.

## Why the early working name was rejected

The project started under an early working name. Vetting killed it:

- **A funded company already sells under it.** A well-funded autonomous
  cloud-optimization company with granted patents sells to the same technical/DevOps
  audience under that name. Two software products with one name aimed at overlapping
  buyers is a textbook trademark-confusion posture, and they have the resources to
  contest it.
- **Pronunciation split**: English speakers read it two different ways in
  roughly equal numbers. A name people cannot say the same way is a name they cannot
  recommend out loud.

Either problem alone would have been survivable; together they were disqualifying.

## Finalists

### Stedding — winner

- **Meaning matches the product thesis.** A stedding is a haven nothing outside can
  touch; the browser is a place the surveillance economy cannot touch. The name *is*
  the pitch.
- **Clean field.** No products, no live trademarks, no exact-phrase competition for
  "Stedding Browser" — the SERP is effectively empty.
- **Legal position strengthened by the word's roots.** "Stedding" is shaped on
  "steading" (a small farm; a homestead), from "stead", an old word for a place. We
  can credibly claim to be using an English-rooted word, not anyone else's asset. We
  still use only the word — no other party's trademarks, artwork, or claimed
  affiliation, ever.

### A one-word English compound — runner-up

- Friction-free English compound: everyone can spell it, say it, and remember it.
- Its exact-phrase SERP as a browser name was empty.
- Lost to Stedding on meaning: it evokes speed, not shelter, and speed is not our
  differentiator. It is also a prominent character name in a fantasy series, which is
  a weaker "it's just an English word" defense than Stedding has.

### Vesper — runner-up

- Highly brandable, pleasant to say, empty exact-phrase SERP for "Vesper Browser".
- Some existing bare-name software use (assorted small apps and projects), which is
  survivable but not the clean field Stedding offers.

## Notable eliminations

| Candidate | Reason eliminated |
|---|---|
| Heron | **Herond Browser** — an active Chromium-based privacy browser one letter away; direct confusion in our exact category |
| Vela | Three existing browsers already use the name |
| Rove | rovebrowser.com exists |
| Lumar | Lumar (formerly DeepCrawl), an SEO SaaS sold to technical marketers; also a near-homophone of Lemur Browser |
| Skiff | Dead privacy brand (acquired by Notion, shut down); inheriting its ghost and its grave |
| Scry | An existing "Scry browser app"; also rhymes with "spy", the exact opposite of the pitch |
| Magpie | Name saturated across apps and tools |
| Lodestar | Saturated; multiple software products |
| Prow | Dev-tool collisions |
| Cairn | Saturated across apps and dev tools |
| Tern | Dev-tool collision (Tern, the JS analysis engine, among others) |
| Pharos | Saturated; multiple software products |
| A pool of invented-setting words | Their rights-holder actively trademarks and merchandises that property; entire pool eliminated |

That elimination is worth stating as policy: we do not take names from an invented
universe whose rights-holder demonstrably polices commercial use, regardless of how
good the word is.

## Domain

**stedding.dev** is the canonical domain.

- **Short brand domain over exact-match.** steddingbrowser.com was available, but
  exact-match-domain SEO is mostly obsolete; ranking for "Stedding Browser" depends on
  content and links, not the domain string.
- **.dev fits the audience** — technical users — and the entire .dev zone is
  HSTS-preloaded, so the site is HTTPS-only by construction. Right signal for a
  privacy product.
- **stedding.top rejected**: cheap, but the TLD's spam association hurts trust in the
  one place we cannot afford it — the download page.
- **stedding.com, stedding.app, stedding.co** are already registered by unrelated
  parties. Acceptable: we are a browser people search for by name, not a domain-hack
  business. Revisit acquisition only if the project grows enough to justify it.

## Outcome

- Product name: **Stedding Browser**
- Domain: **stedding.dev** (DNS on Cloudflare)
- GitHub: `ysalitrynskyi/stedding-browser`
- Usage rules for the name (voice, trademark hygiene, what we never do): `BRAND.md`
