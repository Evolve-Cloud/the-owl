---
title: MCP authorization & security
type: pattern
tags: [mcp, security, authorization, oauth, oauth2.1, pkce, audience-binding, token-passthrough, confused-deputy, ssrf, cimd, enterprise-managed, client-credentials, sentinel, mcp-builder]
sources: 9
updated: 2026-08-03
---

## Definition

**MCP authorization & security** is the transport-level trust model that governs *who may call a remote MCP server, with what token, and how that token is proven to belong there.* It is **OAuth 2.1 with a hardened profile** — a subset of OAuth 2.1 plus a stack of RFCs (6750 Bearer, 8414 AS Metadata, 7591 DCR, 8707 Resource Indicators, 9728 Protected Resource Metadata, 9207 Issuer Identification) and the Client ID Metadata Documents draft — narrowed by MCP-specific MUST/SHOULD rules and an explicit threat model.

Authorization is **OPTIONAL** and **HTTP-transport-only**: HTTP transports **SHOULD** conform, STDIO transports **SHOULD NOT** (they take credentials from the environment instead). The roles are fixed: the **MCP server is the OAuth 2.1 resource server**, the **MCP client is the OAuth 2.1 client**, and an authorization server (co-hosted or separate) issues the tokens.

Rather than a checklist of ~50 normative clauses, the whole spec collapses to **five load-bearing pillars**. Everything else is a detail hanging off one of them.

## Key ideas

### 1. OAuth 2.1 + PKCE is the foundation
User authorization is always **authorization-code-with-PKCE**. Clients **MUST** implement PKCE, **MUST** verify PKCE support before proceeding, and **MUST** use `S256` when capable. PKCE support is discovered via AS metadata: if `code_challenge_methods_supported` is **absent**, the AS does not support PKCE and the client **MUST refuse to proceed** ([[mcp-spec-authorization-security-considerations]]). MCP is not tied to one identity system — any OAuth 2.1 AS works ([[mcp-docs-authorization]]). For local/STDIO servers, env-based or embedded credentials replace the browser flow entirely.

### 2. Audience binding / no token passthrough — the single most-repeated invariant
This clause appears in **every** source and is the spine of the whole model. The client **MUST** send the RFC 8707 `resource` parameter (the canonical URI of the target MCP server) in **both** the authorization and token requests, **regardless of whether the AS advertises support**. The server **MUST** validate that every access token was issued *specifically for it* as the intended audience, and **MUST reject** any token whose `aud` claim does not name it. Two forbidden anti-patterns follow directly:

- **Token passthrough is "explicitly forbidden"** — an MCP server **MUST NOT** accept a token not issued to it, and **MUST NOT** forward the client's token to an upstream API. If the server calls upstream APIs it acts as a *separate* OAuth client with its *own* token ([[mcp-spec-authorization-security-considerations]], [[mcp-docs-security-best-practices]]).
- Tokens **MUST** ride in the `Authorization: Bearer` header on **every** request and **MUST NOT** appear in a URI query string ([[mcp-spec-authorization-index]]).

The `aud` claim is "the primary defense against token passthrough"; production audience **must** derive from the client-supplied `resource` parameter, not a fixed value ([[mcp-docs-authorization]]).

### 3. Discovery & registration is a chain of trust, guarded at every link
The client walks a discovery chain, and **each hop is a place an attacker can substitute a malicious endpoint**, so each hop has a mandatory validation:

1. **401 handshake** → server returns `WWW-Authenticate: Bearer ... resource_metadata="..."`.
2. **Protected Resource Metadata (RFC 9728)** — servers **MUST** implement PRM; it **MUST** list `authorization_servers` (≥1). Clients **MUST** support both PRM discovery mechanisms (the `WWW-Authenticate` header *and* the well-known URI fallback) ([[mcp-spec-authorization-server-discovery]]).
3. **AS metadata (RFC 8414 or OIDC Discovery)** — clients **MUST** probe multiple well-known endpoints in a fixed priority order, then **MUST** validate that the document's `issuer` is *byte-identical* to the issuer identifier used to build the URL. A document from `attacker.example` claiming `"issuer": "https://honest.example"` **MUST** be rejected (metadata-substitution defense).
4. **Client registration** — three mechanisms, in priority order: pre-registration → **Client ID Metadata Documents (CIMD, preferred)** → **DCR (deprecated, backwards-compat only)** → prompt the user. CIMD uses a self-hosted HTTPS URL (with a path component) as the `client_id`; both the client and the AS **MUST** validate that the `client_id` inside the fetched metadata matches the URL exactly. CIMD client IDs are **portable across authorization servers**; pre-registered/DCR credentials **MUST** be bound to their issuing AS by `issuer` and **MUST NOT** be reused across AS ([[mcp-spec-authorization-client-registration]]).

The mix-up defense (RFC 9207) sits across the whole chain: the client **MUST** record the validated `issuer`, associate it with the per-request PKCE/state record, and validate the `iss` on the authorization response **before** sending the code to any token endpoint — using plain string comparison with **no normalization**. **PKCE alone does not prevent a mix-up attack**, because the client would transmit the `code_verifier` to the attacker's token endpoint ([[mcp-docs-security-best-practices]]).

### 4. A concrete threat model with per-threat mitigations
[[mcp-docs-security-best-practices]] is the canonical MCP threat catalog. The load-bearing threats and their required countermeasures:

- **Confused deputy** — an MCP proxy with a *static client ID* + dynamic client registration + a third-party consent cookie lets an attacker skip the consent screen and steal the auth code. Mitigation: proxies **MUST** obtain per-client user consent *before* forwarding to a third-party AS; the consent cookie **MUST NOT** be set until *after* the user approves; exact `redirect_uri` matching; single-use cryptographic `state`.
- **Token passthrough** — see pillar 2 (`MUST NOT` accept/forward foreign tokens).
- **SSRF on discovery** — every discovery URL (`resource_metadata`, `authorization_servers`, `token_endpoint`) is attacker-controllable and can point at cloud metadata (`169.254.169.254`) or internal services. Clients **MUST** consider SSRF; **SHOULD** require HTTPS, block private/reserved IP ranges, and not blindly follow redirects. SSRF also applies to the AS when it fetches CIMD documents.
- **State-handle hijacking** — MCP is stateless; servers **MUST NOT** treat possession of a handle (cart ID, workflow ID) as authentication, and **SHOULD** bind handles server-side to the token-derived user.
- **Local server compromise** — one-click local-server config **MUST** show the exact command and require explicit consent; treat `Mcp-Session-Id` as untrusted and never tie authorization to it ([[mcp-docs-authorization]]).
- **Open redirect / localhost impersonation** — AS **MUST** validate exact registered redirect URIs; all redirect URIs **MUST** be `localhost` or HTTPS; CIMD cannot prove *which* local process owns a `localhost` port, so the AS **MUST** display the redirect hostname and **MAY** require attestation.
- **Scope minimization** — no catch-all scopes (`*`, `admin:*`, `full-access`); use least-privilege step-up via `WWW-Authenticate: ... error="insufficient_scope", scope="..."` (403), and clients compute the **union** of prior + newly-challenged scopes.

### 5. Deployment-mode extensions supplement the interactive core
The two official `ext-auth` extensions are additive; the core spec (no extension) already covers standard interactive user authorization ([[mcp-ext-auth-overview]]):

- **OAuth Client Credentials** (`io.modelcontextprotocol/oauth-client-credentials`) — machine-to-machine, no user. Background daemons, CI/CD, server-to-server. A **JWT Bearer Assertion (RFC 7523) is recommended over a `client_id`/`client_secret`**, because assertions are short-lived and don't transmit the signing key. Client secrets are long-lived credentials that grant silent impersonation if leaked → store in a secrets manager, rotate, scope to minimum ([[mcp-ext-auth-oauth-client-credentials]]).
- **Enterprise-Managed Authorization** (`io.modelcontextprotocol/enterprise-managed-authorization`) — the enterprise IdP (Okta, Azure AD) becomes the policy decision-maker. The client obtains an **Identity Assertion JWT Authorization Grant (ID-JAG)** from the IdP and exchanges it for an MCP access token at the MCP AS — **with no user redirect to the MCP AS authorization endpoint**. Enables centralized policy, SSO, and immediate centralized revocation. The AS validates the ID-JAG signature/audience/issuer and uses `sub` as the stable identifier (email only as a fallback) ([[mcp-ext-auth-enterprise-managed]]).

Decision rule ([[mcp-ext-auth-overview]]): no human present → client credentials; centralized org policy via IdP → enterprise-managed; individual interactive consent → core.

## Evidence / sources

**Normative spec (primary — official MCP spec site):**
- [[mcp-spec-authorization-index]] — the core profile: OAuth 2.1 subset + RFC stack, roles, the full PKCE + `resource` + issuer-validation flow, token-usage rules, scope step-up. URL: https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/index.md
- [[mcp-spec-authorization-client-registration]] — CIMD-preferred / DCR-deprecated registration, selection priority, AS-binding-by-issuer rules. URL: https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/client-registration.md
- [[mcp-spec-authorization-server-discovery]] — RFC 9728 PRM + RFC 8414/OIDC AS discovery, well-known probing order, issuer-equals-URL metadata validation. URL: https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/authorization-server-discovery.md
- [[mcp-spec-authorization-security-considerations]] — the normative threat/mitigation page: audience binding, token theft, PKCE, mix-up, open redirect, CIMD/SSRF, confused deputy, no-passthrough. URL: https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/security-considerations.md

**Tutorials & threat model (primary — official docs):**
- [[mcp-docs-authorization]] — the implementation tutorial: six-step flow, Keycloak reference impl, audience-validation emphasis, the "Common Pitfalls" checklist. URL: https://modelcontextprotocol.io/docs/2026-07-28/tutorials/security/authorization.md
- [[mcp-docs-security-best-practices]] — the canonical concrete threat catalog (confused deputy, passthrough, SSRF, state-handle hijack, local compromise, mix-up, scope minimization) with per-threat MUST/SHOULD. URL: https://modelcontextprotocol.io/docs/2026-07-28/tutorials/security/security_best_practices.md

**Auth extensions (primary — official docs):**
- [[mcp-ext-auth-overview]] — routing/decision page mapping deployment scenario → approach. URL: https://modelcontextprotocol.io/extensions/auth/overview.md
- [[mcp-ext-auth-oauth-client-credentials]] — M2M client-credentials extension (JWT-assertion-recommended). URL: https://modelcontextprotocol.io/extensions/auth/oauth-client-credentials.md
- [[mcp-ext-auth-enterprise-managed]] — enterprise IdP-mediated ID-JAG exchange flow. URL: https://modelcontextprotocol.io/extensions/auth/enterprise-managed-authorization.md

> [!important]
> **The one invariant to remember if you remember nothing else: audience-bind and never pass through.** The client sends the RFC 8707 `resource` parameter; the server validates the token's `aud` names *it*; the server **MUST NOT** accept a token issued to another service, and **MUST NOT** forward the client's token upstream. This single rule is repeated in all nine sources and is the difference between an MCP server and a confused deputy.

> [!contradiction]
> **The tutorial lags the normative spec on client registration.** [[mcp-docs-authorization]] presents **Dynamic Client Registration (DCR, RFC 7591)** as a primary registration path and never mentions CIMD. The normative [[mcp-spec-authorization-client-registration]] states *"Dynamic Client Registration is deprecated. New implementations should use Client ID Metadata Documents instead."* When they disagree, the **spec wins** — prefer CIMD; treat DCR as backwards-compat only (and, if enabled, gate it behind trusted-host vetting, since unauthenticated DCR lets anyone register any client).

## The trade-off

- **Optional & HTTP-only.** Authorization is `OPTIONAL` and applies only to HTTP transports — a large surface (STDIO/local servers) is *deliberately outside* this model and instead leans on environment credentials + OS-level trust. That is a simplification, not a gap, but it means "MCP has an auth spec" does not imply *your* server is covered.
- **Security-vs-friction on the discovery chain.** Every hardening step (issuer validation with no normalization, SSRF blocklists, exact redirect-URI matching, per-client proxy consent) adds implementation weight and failure modes; skipping any one re-opens a named attack. The spec resolves this by making the *dangerous* steps `MUST` and leaving hardening depth (SSRF is `SHOULD`, localhost attestation is `MAY`) to the operator — leaving a genuine residual gap around SSRF and localhost impersonation.
- **Deprecated-but-present DCR.** DCR is kept for backwards compatibility, so implementations must *support the deprecated path while steering new clients to CIMD* — carrying two registration code paths and the contradiction above.
- **Extensions trade interactivity for automation.** Client-credentials removes the human (and with it, consent-based revocation) in exchange for M2M capability — the long-lived secret becomes the whole attack surface. Enterprise-managed re-centralizes control at the IdP but requires org-level IT support and an ID-JAG-capable client; the `email`-fallback account-linking path is a documented takeover risk if email is unverified.

## How it maps to the-owl

the-owl is **markdown + YAML only, no runtime** — it does **not execute an OAuth flow**. So this pattern is **reference knowledge that two specific agents consult during their build/review passes**, not an adoptable runtime convention. The task scoped it exactly there: `mcp-builder` (when it *builds* an MCP integration) and `sentinel` (when it *reviews* one in a diff).

**For `mcp-builder` — a build checklist when standing up a remote MCP integration:**
- Use **OAuth 2.1 + PKCE (`S256`)**; refuse to proceed if `code_challenge_methods_supported` is absent.
- **Audience-bind:** send the RFC 8707 `resource` parameter (canonical URI) in authorization *and* token requests; validate `aud` server-side against the configured resource.
- Prefer **CIMD** over deprecated DCR for client registration; bind pre-registered/DCR creds to their issuing `issuer`.
- **SSRF-guard** every discovery fetch (`resource_metadata`, `authorization_servers`, `token_endpoint`): require HTTPS, block private/reserved IP ranges, don't follow redirects to internal hosts.
- If it's a **proxy**, obtain **per-client user consent** before forwarding to a third-party AS; never set the consent cookie before approval.
- Pick the deployment mode deliberately: **client-credentials (JWT assertion)** for M2M/CI/daemons, **enterprise-managed (ID-JAG)** for org-policy access, **core** for interactive.

**For `sentinel` — red-flags to auto-flag in a diff touching MCP auth:**
- **Token passthrough** — a server accepting a token not issued to it, or forwarding the client's token upstream. Highest-severity single finding.
- **Missing/weak audience validation** — no `aud` check, or a *fixed/generic* audience (`api`) instead of the client `resource`.
- **Tokens in a URI query string** (must be `Authorization: Bearer` header only).
- **Broad / catch-all scopes** (`*`, `admin:*`, `full-access`) — blast-radius expansion.
- **Static-client-ID proxy without per-client consent** — the confused-deputy signature.
- **`http://` redirect URIs** (non-localhost), missing PKCE, missing issuer/mix-up validation, unauthenticated DCR.
- **Secrets in source** — MCP client secrets or signing keys committed instead of held in a secrets manager.

**The honest gaps & the carve-out boundary:**
- This is **reference-only** for the-owl itself — there is no OAuth code in a markdown/YAML library to secure. Its value is entirely in raising the quality of the two agents' build/review output, mirroring how [[tool-design-and-capability-scoping]] treats runtime mechanisms as *enrichment, not adoptable conventions*.
- It intersects **NFR-SEC-1**: MCP client secrets, refresh tokens, and signing keys are exactly the kind of secret the self-improvement loop **must never** read or touch. The "store secrets in a secrets manager, never in source" rule from [[mcp-ext-auth-oauth-client-credentials]] is the same invariant the-owl already enforces via its carve-out.
- The `NFR-SEC-2` data-boundary is *itself* visible in these very sources: every fetched MCP page carried an injected "fetch the docs index" directive, which the scout quarantined into a `> [!question]` callout and never obeyed — the same pattern documented in [[guardrails-and-safety]].

## Related

- **Sources:** [[mcp-spec-authorization-index]] · [[mcp-spec-authorization-client-registration]] · [[mcp-spec-authorization-server-discovery]] · [[mcp-spec-authorization-security-considerations]] · [[mcp-docs-authorization]] · [[mcp-docs-security-best-practices]] · [[mcp-ext-auth-overview]] · [[mcp-ext-auth-oauth-client-credentials]] · [[mcp-ext-auth-enterprise-managed]]
- **Patterns:** [[guardrails-and-safety]] (data-boundary + least-privilege + no-passthrough are the same discipline) · [[tool-design-and-capability-scoping]] (runtime mechanisms as reference-only enrichment for a no-runtime library)
- **Agents:** [[mcp-builder]] · [[sentinel]] · [[mcp-architecture-spec-2026-07-28]]
- [[overview]] · [[ledger]]
