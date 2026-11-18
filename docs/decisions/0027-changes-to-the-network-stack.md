# 0027 — Three changes to the network stack, and the rule for the next one

Status: Accepted
Date: 2026-10-21

## Context

`docs/ARCHITECTURE.md` says the series avoids patching `content/`, Blink, `net/` and V8, and that an engine patch needs an ADR. Three changes were already in the series without one.

## Decision

The three stay, each in the patch that carries it. The patch header names the reason and the tests that fail without the change. Each is small and leaves the stack’s own logic as Chromium wrote it.

1. **Chromium’s version, where a server or the root store expects it** (patch 0073, `S-72`). On Windows, `chrome/VERSION` carries Stedding’s product number so the installer can update. The root store’s version rules compare `version_info::GetChromiumVersion()`, in `net/cert/cert_verify_proc_builtin.cc` and `services/cert_verifier/cert_verifier_service_factory.cc`. The user agent, client hints, the Web Store, Safe Browsing, GCM, sync, OAuth, image search and DIAL send Chromium’s version too.
2. **Chrome’s launched defaults** (patch 0074, `S-236`, `S-237`). Features Chrome turns on for its users through field trials, Google’s key pins, and Certificate Transparency. Chrome’s certificate reports stay off.
3. **The certificate verifier’s change notices** (patch 0077, `S-251`). `CertVerifierServiceImpl::OnCertVerifierChanged` tells the network context only after the service has verified a certificate (`verified_any_`). Until then a change is dropped. Those notices drop every idle socket and every connect in progress, including plain http. Two of them arrive in the first second of a launch, before anything has been verified, and were dropping the connections opened ahead for tabs given on the command line. Amended 2026-11-18: patch 0148 (2026-11-05) extends this to https and to a profile that has verified a certificate, in `services/cert_verifier/`: the same certificates again no longer reach the verifier, and a network time within the factory's accepted uncertainty of the clock rebuilds the verifier without telling the client. A real change still does.

The next change goes into `net/` or `services/network/` only for a fault a user can see, or for a privacy promise (`docs/PRIVACY.md`). It needs an upstream bug, or a reason it is Stedding’s alone, a test that fails without it, and a line in the list above. A behaviour Chromium would plausibly take upstream is reported there as well.

## Consequences

- Each pin move re-applies these hunks. A conflict is resolved by reading the upstream change first.
- Until a certificate has been verified, no verifier-setup change reaches the network context. Nothing verified exists then that a change could make stale. After that, only a real change (other certificates, a CRLSet, a root store, a time further off) flushes (patch 0148, `S-251`).
- `docs/ARCHITECTURE.md` points here from its paragraph on the network stack.
