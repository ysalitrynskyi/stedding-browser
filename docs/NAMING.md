# Naming decision record

Date: 2026-08-30
Status: Decided — the product is named **Stedding Browser**, canonical domain **stedding.dev**.
See also: `decisions/0001-product-name-stedding.md`, `decisions/0004-domain-stedding-dev.md`, `BRAND.md`.

## Method

We generated candidate names from invented and real English words and coinages
across nautical, avian, wayfinding, and shelter themes.

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
contest it. A candidate also had to be usable as a name without implying affiliation
with anyone.

## Why the early working name was rejected

The project's early working name failed vetting on two counts. A well-funded software
company sells to the same technical audience under that name: two software products
with one name aimed at overlapping buyers is a textbook trademark-confusion posture,
and that company has the resources to contest it. And English speakers pronounced it
two ways; a name people cannot say the same way is a name they cannot recommend out
loud. Either problem alone would have been survivable; together they were
disqualifying.

## Finalists

### Stedding — winner

- **Meaning matches the product thesis.** Stedding means a haven, a settled, kept
  place; the browser is a place to use the web where the surveillance economy cannot
  reach. The name *is* the pitch.
- **Clean field.** No products, no live trademarks, no exact-phrase competition for
  "Stedding Browser" — the SERP is effectively empty.
- **Plain English roots.** The name is shaped on the English word "steading", a
  farmstead or homestead, which comes from "stead", an old word for a place. We use
  only the word, as this browser's name, and claim no affiliation with anyone.

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
