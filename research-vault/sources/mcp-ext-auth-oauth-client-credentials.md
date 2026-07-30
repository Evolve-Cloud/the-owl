---
title: "OAuth Client Credentials — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, auth, oauth, client-credentials, jwt, m2m, sentinel]
sources: 1
updated: 2026-07-30
---
**Source:** [OAuth Client Credentials](https://modelcontextprotocol.io/extensions/auth/oauth-client-credentials.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
The OAuth Client Credentials extension (`io.modelcontextprotocol/oauth-client-credentials`) adds the OAuth 2.0 client credentials flow (RFC 6749 §4.4) to MCP for machine-to-machine access with no interactive user. A client authenticates with application-level credentials — either a JWT Bearer Assertion (RFC 7523, recommended) or a `client_id`/`client_secret` — obtains an access token from the authorization server, and presents it as a Bearer token to the MCP server. Official SDKs (TS + Python) handle token acquisition and refresh automatically.

## Key points (OAuth flow + normative)
- Two credential formats:
  - **JWT Bearer Assertion (recommended, RFC 7523):** `POST /token` with `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer` and `assertion=<signed JWT>`; AS validates signature against the client's registered public key. Assertion typically includes `iss` (client ID), `sub` (client ID), `aud` (AS token endpoint URL), `exp`, `iat`.
  - **Client Secret:** `POST /token` with `grant_type=client_credentials` + `client_id` + `client_secret`.
- Token usage: `Authorization: Bearer <access_token>` on HTTP requests to the MCP server.
- **Client requirements:** declare support in per-request `clientCapabilities.extensions`; obtain access token via client-credentials grant before connecting; include Bearer token; implement token refresh (client-credentials tokens typically have shorter lifetimes than user-delegated tokens — refresh before expiry).
- **Server requirements:** validate the token (JWT signature + claims against AS public keys, usually via JWKS) on each request; check scopes for the requested operation; optionally (recommended for discoverability) advertise the extension in `server/discover`.
- **Security (Sentinel-relevant):** client secrets are long-lived credentials granting access without user interaction — a leak allows silent impersonation until rotated. Mitigations stated: store in a secrets manager (never in source/committed env files), rotate regularly and after suspected compromise, scope to minimum permissions, and prefer JWT assertions (short-lived, no signing-key transmission).
- SDK providers: TS `ClientCredentialsProvider` / `PrivateKeyJwtProvider` (`@modelcontextprotocol/client`); Python `ClientCredentialsOAuthProvider` / `PrivateKeyJWTOAuthProvider` (`mcp`, with `SignedJWTParameters`). Both auto-handle acquisition + refresh. JWT example uses RS256, 300s lifetime.
- Use when: background services, CI/CD pipelines, server-to-server integrations, daemons/workers. If a human should explicitly authorize, use the standard MCP authorization flow instead.

## Notable quotes
> "The client proves its identity directly to the authorization server, which issues an access token without requiring a browser redirect or user interaction."
> "Client secrets are long-lived credentials that grant access without user interaction. If a secret is leaked, an attacker can silently authenticate as your application until the secret is rotated."
> "Prefer JWT assertions when possible — they are short-lived and do not require transmitting the signing key."

## Embedded instructions (data, not obeyed)
> [!question] Page-top directive treated as data, not obeyed: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt … Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Whether the extension mandates `exp`/`aud` validation as MUST (vs "typically") for JWT assertions is deferred to the draft normative spec.
- No explicit token-lifetime or rotation-interval recommendations (only "shorter" and "regular schedule").
- Python example imports `httpx2` (likely a doc typo for `httpx`).

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]]
