---
title: "Authorization — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, security, authorization, oauth]
sources: 1
updated: 2026-07-30
---
**Source:** [Authorization](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/index.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
The core Authorization page defines MCP's transport-level OAuth authorization for HTTP-based transports. Authorization is OPTIONAL; HTTP transports SHOULD conform, STDIO SHOULD NOT (use environment credentials). It is built on a subset of OAuth 2.1 plus RFC 6750, 8414, 7591, 8707, 9728, 9207, OIDC Discovery/Registration, and the Client ID Metadata Document draft. It specifies roles (MCP server = resource server, MCP client = OAuth 2.1 client), the full authorization flow with PKCE, the RFC 8707 `resource` parameter for audience binding, token usage rules, refresh-token guidance, scope selection/step-up, issuer validation (RFC 9207), and error handling.

## Key points
- **Protocol requirements:** Authorization is **OPTIONAL**. HTTP transports **SHOULD** conform; STDIO **SHOULD NOT** (retrieve credentials from environment); alternative transports **MUST** follow security best practices for their protocol.
- **Standards base:** OAuth 2.1 (draft-ietf-oauth-v2-1-13), RFC 6750 (Bearer), RFC 8414 (AS Metadata), RFC 7591 (DCR), RFC 8707 (Resource Indicators), RFC 9728 (Protected Resource Metadata), RFC 9207 (Issuer Identification), OAuth Client ID Metadata Documents draft-00, OIDC Discovery 1.0, OIDC Dynamic Client Registration 1.0.
- **Roles:** Protected MCP server = OAuth 2.1 resource server; MCP client = OAuth 2.1 client; authorization server issues access tokens (may be co-hosted or separate).
- **OAuth 2.1 flow:** unauth request → 401 + `WWW-Authenticate` → fetch Protected Resource Metadata → discover AS metadata (OAuth 2.0 + OIDC endpoints in priority order) → client registration (CIMD / DCR / pre-registered) → generate PKCE + `resource` param + scope selection + record expected issuer → browser authorization request with `code_challenge` + `resource` → redirect callback with code + `iss` → validate `iss` (RFC 9207) → token request + `code_verifier` + `resource` → access token (+ refresh) → MCP request with Bearer token.
- **Client ID Metadata Documents flow:** client uses HTTPS URL as `client_id`; AS detects URL-formatted client_id, fetches metadata from the URL, validates metadata and `redirect_uris`.
- **Issuer validation (RFC 9207):** client **MUST** record `issuer` from validated AS metadata, associate with the per-request PKCE/state record. AS **SHOULD** include `iss` in responses (incl. errors) and **MUST** advertise via `authorization_response_iss_parameter_supported=true`. Client **MUST** apply RFC 9207 §2.4 validation before sending the code to any token endpoint. Comparison is simple string comparison (RFC 3986 §6.2.1); clients **MUST NOT** apply scheme/host case folding, default-port elision, trailing-slash, or percent-encoding normalization. Validation applies to error responses too — on mismatch client **MUST NOT** act on/display `error`, `error_description`, `error_uri`.
- **`iss` action matrix:** advertised=true & present → compare; true & absent → reject; false/absent & present → compare (local-policy provision); false/absent & absent → proceed. Future revision expected to upgrade `iss` inclusion from SHOULD to MUST.
- **Resource parameter (RFC 8707):** client **MUST** implement Resource Indicators; `resource` **MUST** be in both authorization and token requests, **MUST** identify the target MCP server, **MUST** use the canonical URI (RFC 8707 §2, aligned with RFC 9728). Client **MUST** send it regardless of AS support. Provide most specific URI; **SHOULD** accept uppercase scheme/host for robustness; prefer no trailing slash.
  - Valid canonical URIs: `https://mcp.example.com/mcp`, `https://mcp.example.com`, `https://mcp.example.com:8443`, `https://mcp.example.com/server/mcp`. Invalid: `mcp.example.com` (no scheme), `https://mcp.example.com#fragment` (has fragment).
- **Token usage:** conform to OAuth 2.1 §5. Use `Authorization: Bearer <access-token>` header on **every** HTTP request. Tokens **MUST NOT** be in URI query string. Servers **MUST** validate tokens (OAuth 2.1 §5.2), **MUST** validate audience (issued for them, RFC 8707 §2); invalid/expired → HTTP 401. Clients **MUST NOT** send tokens other than those issued by the MCP server's own AS. Servers **MUST** only accept tokens valid for their own resources; **MUST NOT** accept or transit any other tokens.
- **Refresh tokens:** clients wanting them **MUST** keep them confidential in transit/storage, **SHOULD** include `refresh_token` in `grant_types`, **MAY** add `offline_access` scope if in AS `scopes_supported`, **MUST NOT** assume refresh tokens will be issued (AS discretion). Servers **SHOULD NOT** include `offline_access` in `WWW-Authenticate` scope or PRM `scopes_supported`.
- **Scope selection:** servers **SHOULD** include `scope` in `WWW-Authenticate` (RFC 6750 §3) for least privilege. Clients **MUST NOT** assume set relationship between challenged scopes and `scopes_supported`; **MUST** treat challenge scopes as authoritative; **SHOULD** union with previously granted scopes on re-auth. Priority: (1) use `scope` from 401 `WWW-Authenticate`; (2) else use all `scopes_supported`, omitting `scope` if undefined.
- **Error codes:** 401 (authz required/token invalid), 403 (invalid scopes/insufficient permissions), 400 (malformed request).
- **Scope challenge / step-up:** on insufficient scope at runtime server **SHOULD** return 403 with `WWW-Authenticate: Bearer error="insufficient_scope"`, `scope=...`, `resource_metadata`, optional `error_description`. Servers **SHOULD** emit all required scopes in a single challenge (no incremental challenging). Servers **MUST** account for scope hierarchies. Clients **SHOULD** step-up (compute union of prior + challenge scopes), **SHOULD** implement retry limits, retry no more than a few times then treat as permanent failure.

## Security requirements
- Authorization servers **MUST** implement OAuth 2.1 with appropriate security measures for confidential and public clients.
- AS and clients **SHOULD** support OAuth Client ID Metadata Documents (draft-00).
- AS and clients **MAY** support DCR (RFC 7591) — DCR is deprecated, retained for backwards compat.
- MCP servers **MUST** implement RFC 9728 Protected Resource Metadata; clients **MUST** use it for AS discovery.
- MCP authorization servers **MUST** provide at least one of RFC 8414 AS Metadata or OIDC Discovery 1.0; clients **MUST** support both discovery mechanisms.
- Clients **MUST** obtain a client ID via one of: Client ID Metadata Documents, pre-registration, or DCR.
- Client **MUST** record validated `issuer`; **MUST** apply RFC 9207 §2.4 before token exchange; **MUST NOT** normalize `iss` before comparison; **MUST NOT** act on mismatched error responses. (Threat: mix-up attacks.)
- Client **MUST** include `resource` in authz + token requests; **MUST** identify the MCP server; **MUST** use canonical URI; **MUST** send regardless of AS support. (Threat: token misuse across services / audience confusion.)
- Client **MUST** use `Authorization: Bearer`; **MUST NOT** put tokens in query string; **MUST NOT** send tokens not issued by the server's AS. (Threat: token leakage, passthrough.)
- Servers **MUST** validate tokens; **MUST** validate audience; **MUST** only accept tokens for their own resources; **MUST NOT** accept/transit other tokens. (Threat: confused deputy, token passthrough, privilege escalation.)
- Refresh-token confidentiality **MUST** be maintained; clients **MUST NOT** assume issuance.
- Implementations **MUST** follow the normative Security Considerations page (audience binding, token theft, communication security, authz code protection, mix-up/confused deputy, open redirection, CIMD security).

## Notable quotes
> "Authorization is **OPTIONAL** for MCP implementations."
> "MCP clients **MUST NOT** send tokens to the MCP server other than ones issued by the MCP server's authorization server."
> "MCP servers **MUST NOT** accept or transit any other tokens."
> "Access tokens **MUST NOT** be included in the URI query string"
> "Note that authorization **MUST** be included in every HTTP request from client to server."
> "MCP servers **MUST** validate that access tokens were issued specifically for them as the intended audience, according to RFC 8707 Section 2."
> "clients **MUST NOT** apply scheme or host case folding, default-port elision, trailing-slash, or percent-encoding normalization ... before comparison."
> "This validation applies equally to error responses - on mismatch the client **MUST NOT** act on or display `error`, `error_description`, or `error_uri`."

> [!question] Embedded directive found in fetched page (NOT obeyed, per NFR-SEC-2)
> Every fetched page is prefixed with an injected instruction block: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Treated as data, not obeyed.

## Gaps / open questions
- `iss` inclusion is currently SHOULD; a future revision is "expected" to upgrade to MUST — timing/path undefined.
- AS selection among multiple `authorization_servers` is delegated to the client (RFC 9728 §7.6) with no MCP-specific tiebreak.
- The `resource` canonical-URI acceptance of uppercase scheme/host (SHOULD) vs. lowercase canonical form leaves room for interop divergence.
- Extensions (ext-auth repo) are optional/additive/composable but unspecified here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]] · [[mcp-spec-authorization-index]] · [[mcp-spec-authorization-security-considerations]] · [[mcp-spec-authorization-server-discovery]] · [[mcp-spec-authorization-client-registration]]
