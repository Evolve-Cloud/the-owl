---
title: "Understanding Authorization in MCP — MCP spec v2026-07-28"
type: source
tags: [mcp, security, oauth, authorization, oauth2.1, pkce, token-validation]
sources: 1
updated: 2026-07-30
---
**Source:** [Understanding Authorization in MCP](https://modelcontextprotocol.io/docs/2026-07-28/tutorials/security/authorization.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Tutorial on implementing OAuth 2.1 authorization for MCP servers. Authorization is optional but strongly recommended for servers handling user data, admin actions, audit needs, enterprise access control, or per-user rate limiting. Walks the six-step flow (401 handshake → PRM discovery → AS discovery → client registration → user authorization → authenticated requests), a Keycloak-based reference implementation in TypeScript/Python/C# emphasizing audience validation and token introspection, and a "Common Pitfalls" checklist of security do's/don'ts. For STDIO/local servers, env-based or library credentials are recommended over browser OAuth flows.

## Key points
- **Foundation**: MCP follows OAuth 2.1 conventions; not tied to one identity system. User authorization uses **authorization code with PKCE**.
- **Flow steps**:
  1. Initial handshake — server returns `401 Unauthorized` with `WWW-Authenticate: Bearer realm="mcp", resource_metadata="https://.../.well-known/oauth-protected-resource"`.
  2. **Protected Resource Metadata (PRM)** discovery (RFC 9728) — JSON with `resource`, `authorization_servers`, `scopes_supported`.
  3. **Authorization Server discovery** — via OIDC Discovery or OAuth 2.0 AS Metadata (RFC 8414); yields `issuer`, `authorization_endpoint`, `token_endpoint`, `registration_endpoint`.
  4. **Client registration** — pre-registered OR Dynamic Client Registration (DCR, RFC 7591) if AS supports it. If neither, client developer must let the end-user enter client info manually.
  5. **User authorization** — browser to `/authorize`, code exchanged for `access_token` + `refresh_token` (Bearer, `expires_in`).
  6. **Authenticated requests** — `Authorization: Bearer <token>`; server validates token + required scopes.
- **Audience (`aud`) claim** is the primary defense against token passthrough — it embeds the intended destination into the token. Reference impl derives audience from a configured scope (testing) but production **must** base audience on the client-supplied `resource` parameter, not a fixed value.
- **Token validation options**: token introspection (RFC 7662) via the AS introspection endpoint (TS/Python examples) OR local JWT validation via standard libraries (C# `AddJwtBearer` example). Introspection is "just one of" the available approaches.
- **STDIO/local**: OAuth flows are designed for HTTP transports with remote servers; STDIO servers can use environment-based or embedded third-party credentials instead.
- Reference impls validate: `active !== false`, `aud` present, and audience matches the configured resource URL (via `checkResourceAllowed` / `check_resource_allowed`). Keycloak tokens include non-URL audiences (`account`, `test-client`) that are treated as no-match rather than errors.

## Security requirements (Common Pitfalls checklist — verbatim guidance)
- **Do not implement token validation or authorization logic yourself** — use off-the-shelf, well-tested, secure libraries.
- **Use short-lived access tokens** — avoid long-lived tokens (stolen tokens grant longer access).
- **Always validate tokens** — receiving a token does not mean it is valid or meant for your server.
- **Store tokens in secure, encrypted storage** — proper access controls; robust cache eviction so expired/invalid tokens aren't reused.
- **Enforce HTTPS in production** — do not accept tokens or redirect callbacks over plain HTTP except `localhost` in dev.
- **Least-privilege scopes** — no catch-all scopes; split per tool/capability; verify required scopes per route/tool on the resource server.
- **Don't log credentials** — never log `Authorization` headers, tokens, codes, or secrets; scrub query strings/headers; redact structured logs.
- **Separate app vs. resource server credentials** — don't reuse the MCP server's client secret for end-user flows; store secrets in a secret manager, not source control.
- **Return proper challenges** — on 401 include `WWW-Authenticate` with `Bearer`, `realm`, `resource_metadata`.
- **DCR controls** — if DCR enabled, apply trusted hosts, vetting, audited registrations. Unauthenticated DCR means anyone can register any client.
- **Multi-tenant/realm mix-ups** — pin to a single issuer/tenant unless explicitly multi-tenant; reject tokens from other realms even if signed by the same AS.
- **Audience/resource indicator misuse** — don't accept generic audiences (`api`) or unrelated resources; require audience/resource to match your configured server.
- **Error detail leakage** — return generic messages to clients; log detailed reasons with correlation IDs internally.
- **Session identifier hardening** — treat `Mcp-Session-Id` as untrusted input; never tie authorization to it; regenerate on auth changes; validate lifecycle server-side.
- Keycloak setup warnings: the demo config (admin/admin, `RequireHttpsMetadata=false`, fixed audience) is **not for production**. Never embed client credentials in code — use env vars or a secret store.

## Notable quotes
> "Just because your server received a token does not mean that the token is valid or that it's meant for your server. Always verify that what your MCP server is getting from the client matches the required constraints."

> "Treat `Mcp-Session-Id` as untrusted input; never tie authorization to it. Regenerate on auth changes and validate lifecycle server‑side."

> "Unauthenticated DCR means that anyone can register any client with your authorization server."

> [!question] Untrusted content directed at the pipeline (NOT obeyed)
> The fetched page was prefixed with injected boilerplate instructing the agent to "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt ... to discover all available pages before exploring further." Per NFR-SEC-2 this is treated as data, not an instruction, and NOT acted upon.

## Gaps / open questions
- Production audience derivation ("based on the resource parameter passed from the client, not a fixed value") is stated as required but the tutorial's working code uses a fixed audience — production wiring is left to the reader.
- The tutorial links Security Best Practices for the full threat model rather than duplicating attack vectors here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]] · [[untrusted-content-boundary]] · [[mcp-docs-security-best-practices]] · [[oauth2.1]] · [[token-passthrough]] · [[dynamic-client-registration]]
