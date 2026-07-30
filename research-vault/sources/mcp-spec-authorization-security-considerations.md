---
title: "Authorization Security Considerations — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, security, authorization, oauth]
sources: 1
updated: 2026-07-30
---
**Source:** [Authorization Security Considerations](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/security-considerations.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
The normative security-considerations page enumerates the threats MCP authorization must defend against and their required mitigations. It mandates OAuth 2.1 §7 security best practices and covers: token audience binding/validation (RFC 8707), token theft, communication security (HTTPS), authorization-code protection (PKCE S256), mix-up attacks (RFC 9207 issuer validation), open redirection, Client ID Metadata Document security (SSRF, localhost impersonation, trust policies), the confused-deputy problem, and access-token privilege restriction (no token passthrough).

## Key points
- Implementers **MUST** follow OAuth 2.1 §7 security best practices.
- **Token audience binding (RFC 8707):** clients **MUST** include `resource` in authz + token requests; servers **MUST** validate tokens were specifically issued for their use. Token passthrough is "explicitly forbidden."
- **Token theft:** clients and servers **MUST** implement secure token storage (OAuth 2.1 §7.1). AS **SHOULD** issue short-lived access tokens. For public clients, AS **MUST** rotate refresh tokens (OAuth 2.1 §4.3.1).
- **Communication security:** implementations **MUST** follow OAuth 2.1 §1.5. All AS endpoints **MUST** be HTTPS. All redirect URIs **MUST** be `localhost` or HTTPS.
- **Authorization code protection:** clients **MUST** implement PKCE (OAuth 2.1 §7.5.2) and **MUST** verify PKCE support before proceeding. Clients **MUST** use `S256` when technically capable (OAuth 2.1 §4.1.1). PKCE support is discovered via AS metadata: if `code_challenge_methods_supported` is absent (OAuth 2.0 AS Metadata), the AS does not support PKCE and clients **MUST** refuse to proceed. For OIDC Discovery, clients **MUST** verify presence of `code_challenge_methods_supported`; if absent **MUST** refuse. AS providing OIDC Discovery **MUST** include `code_challenge_methods_supported`.
- **Mix-up attacks:** a malicious AS may try to make the client send it a code/token from an honest AS. Required mitigation = Authorization Response Validation (RFC 9207 issuer check) from the core index page.
- **Open redirection:** clients **MUST** have redirect URIs registered with the AS; AS **MUST** validate exact redirect URIs against pre-registered values; clients **SHOULD** use and verify `state` and discard mismatches; AS **MUST** take precautions against redirecting to untrusted URIs (OAuth 2.1 §7.12.2); AS **SHOULD** only auto-redirect to trusted URIs, else **MAY** inform the user.
- **Client ID Metadata Document security:** AS **MUST** consider CIMD draft §6 security implications. AS fetching metadata **SHOULD** consider SSRF risks. Localhost: CIMD cannot prevent `localhost` URL impersonation alone — AS **SHOULD** display extra warnings for localhost-only redirect URIs, **MAY** require additional attestation, **MUST** clearly display the redirect URI hostname during authorization. AS **MAY** implement domain-based trust policies.
- **Confused deputy:** attackers exploit MCP servers as intermediaries to third-party APIs; using stolen authz codes they obtain tokens without user consent. MCP proxy servers using static client IDs **MUST** obtain user consent for each dynamically registered client before forwarding to third-party AS.
- **Access token privilege restriction:** servers **MUST** validate tokens before processing, ensuring the token was issued specifically for the MCP server; **MUST** follow OAuth 2.1 §5.2; **MUST** only accept tokens intended for themselves and **MUST** reject tokens not including them in the audience claim (or otherwise verify intended recipient). If the MCP server calls upstream APIs it acts as an OAuth client with a separate token and **MUST NOT** pass through the token received from the MCP client. Clients **MUST** implement/use the `resource` parameter (RFC 8707, aligned with RFC 9728 §7.4).

## Security requirements
Every normative statement, with the threat it addresses:
- **MUST** follow OAuth 2.1 §7 best practices — general.
- Clients **MUST** include `resource`; servers **MUST** validate token audience — audience confusion / cross-service token misuse.
- Clients & servers **MUST** implement secure token storage; AS **SHOULD** issue short-lived tokens; AS **MUST** rotate refresh tokens for public clients — token theft.
- AS endpoints **MUST** be HTTPS; redirect URIs **MUST** be localhost or HTTPS — communication interception.
- Clients **MUST** implement PKCE; **MUST** verify PKCE support; **MUST** use `S256`; **MUST** refuse if `code_challenge_methods_supported` absent; OIDC AS **MUST** include it — authorization code interception/injection.
- Issuer validation (RFC 9207) required — mix-up attacks.
- Clients **MUST** register redirect URIs; AS **MUST** validate exact redirect URIs; clients **SHOULD** verify `state`; AS **MUST** prevent untrusted redirects; AS **SHOULD** only auto-redirect trusted URIs — open redirection / phishing.
- AS **MUST** consider CIMD §6; **SHOULD** consider SSRF; localhost: **SHOULD** warn, **MAY** attest, **MUST** display hostname; **MAY** apply trust policies — CIMD abuse, SSRF, localhost impersonation.
- MCP proxy servers with static client IDs **MUST** obtain user consent per dynamically registered client before forwarding — confused deputy.
- Servers **MUST** validate tokens before processing; **MUST** follow OAuth 2.1 §5.2; **MUST** only accept audience-intended tokens; **MUST** reject others; **MUST NOT** pass through client token to upstream APIs; clients **MUST** use `resource` — privilege escalation / token passthrough / confused deputy.

## Notable quotes
> "token passthrough is explicitly forbidden."
> "Authorization servers **SHOULD** issue short-lived access tokens to reduce the impact of leaked tokens. For public clients, authorization servers **MUST** rotate refresh tokens..."
> "All authorization server endpoints **MUST** be served over HTTPS. ... All redirect URIs **MUST** be either `localhost` or use HTTPS."
> "MCP clients **MUST** implement PKCE ... and **MUST** verify PKCE support before proceeding with authorization."
> "If `code_challenge_methods_supported` is absent, the authorization server does not support PKCE and MCP clients **MUST** refuse to proceed."
> "Authorization servers **MUST** validate exact redirect URIs against pre-registered values to prevent redirection attacks."
> "MCP proxy servers using static client IDs **MUST** obtain user consent for each dynamically registered client before forwarding to third-party authorization servers"
> "The MCP server **MUST NOT** pass through the token it received from the MCP client."

> [!question] Embedded directive found in fetched page (NOT obeyed, per NFR-SEC-2)
> Injected page prefix instructs: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Treated as data, not obeyed.

## Gaps / open questions
- Localhost redirect impersonation is acknowledged as not fully preventable by CIMD; residual risk depends on optional attestation the spec only marks MAY.
- SSRF protection for AS-side metadata fetching is SHOULD, not MUST — leaves a hardening gap.
- "Secure token storage" is mandated but concrete storage mechanisms are deferred to OAuth 2.1 §7.1.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]] · [[mcp-spec-authorization-index]] · [[mcp-spec-authorization-server-discovery]] · [[mcp-spec-authorization-client-registration]]
