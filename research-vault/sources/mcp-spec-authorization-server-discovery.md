---
title: "Authorization Server Discovery — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, security, authorization, oauth]
sources: 1
updated: 2026-07-30
---
**Source:** [Authorization Server Discovery](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/authorization-server-discovery.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
This page defines how MCP servers advertise their authorization servers (via RFC 9728 Protected Resource Metadata) and how clients discover AS endpoints (via RFC 8414 AS Metadata or OIDC Discovery 1.0). It mandates the `authorization_servers` field, two PRM discovery mechanisms (WWW-Authenticate header and well-known URI), the exact well-known probing order for AS metadata (with and without path components), and a mandatory issuer-equals-URL validation to reject metadata substitution.

## Key points
- **AS location:** MCP servers **MUST** implement RFC 9728 PRM to indicate AS locations. The PRM document **MUST** include `authorization_servers` with at least one AS.
- **Multiple AS:** PRM may list multiple AS; client selects (RFC 9728 §7.6). Each listed AS is independent; client IDs are unique per AS (RFC 6749 §2.2). Clients **MUST** maintain separate registration state (credentials, tokens) per AS and **MUST NOT** assume credentials for one AS work at another.
- **PRM discovery mechanisms (server MUST implement one):**
  1. **WWW-Authenticate Header:** include resource metadata URL under `resource_metadata` in the `WWW-Authenticate` header on 401 responses (RFC 9728 §5.1).
  2. **Well-Known URI:** serve metadata at a well-known URI (RFC 9728) — either at the MCP endpoint path (`https://example.com/public/mcp` → `https://example.com/.well-known/oauth-protected-resource/public/mcp`) or at root (`https://example.com/.well-known/oauth-protected-resource`).
- Clients **MUST** support both mechanisms: use the URL from parsed `WWW-Authenticate` when present, else **MUST** fall back to constructing/requesting the well-known URIs in listed order. Clients **MUST** be able to parse `WWW-Authenticate` and respond to 401.
- Servers can include a `scope` param in the `WWW-Authenticate` challenge (semantics per Scope Selection Strategy).
- **AS Metadata discovery:** uses default `oauth-authorization-server` well-known suffix (RFC 8414 §3.1). No MCP-specific suffix. Clients **MUST** attempt multiple well-known endpoints to interoperate with OAuth 2.0 AS Metadata and OIDC Discovery 1.0.
  - **Issuer URLs WITH path** (e.g. `https://auth.example.com/tenant1`) — try in order:
    1. `https://auth.example.com/.well-known/oauth-authorization-server/tenant1`
    2. `https://auth.example.com/.well-known/openid-configuration/tenant1`
    3. `https://auth.example.com/tenant1/.well-known/openid-configuration`
  - **Issuer URLs WITHOUT path** (e.g. `https://auth.example.com`) — try:
    1. `https://auth.example.com/.well-known/oauth-authorization-server`
    2. `https://auth.example.com/.well-known/openid-configuration`
- **Metadata validation:** after retrieving AS metadata, clients **MUST** validate per RFC 8414 §3.3 / OIDC Discovery §4.3: the `issuer` in the document **MUST** be identical to the issuer identifier used to build the well-known URL. If they differ the client **MUST NOT** use the metadata (e.g. doc from `https://attacker.example/...` with `"issuer": "https://honest.example"` **MUST** be rejected).
- **Sequence:** unauth request → 401 (may include WWW-Authenticate); if header has `resource_metadata` → GET it; else fall back to well-known probing (sub-path then root); if none → abort or use pre-configured values → validate RS metadata → build AS metadata URL → GET AS metadata (OAuth then OIDC priority) → OAuth 2.1 flow → token request → token → MCP requests.

## Security requirements
- Servers **MUST** implement RFC 9728 PRM; PRM **MUST** include `authorization_servers` (≥1). (Threat: undiscoverable/ambiguous AS.)
- Clients **MUST** maintain separate registration state per AS; **MUST NOT** assume cross-AS credential validity. (Threat: credential leakage/misbinding across AS.)
- Servers **MUST** implement one of the two PRM discovery mechanisms; clients **MUST** support both and **MUST** parse `WWW-Authenticate` / respond to 401.
- Clients **MUST** attempt the multiple well-known endpoints in the specified priority order.
- Clients **MUST** validate `issuer` == issuer identifier used to construct the URL; **MUST NOT** use mismatched metadata. (Threat: metadata substitution / malicious AS impersonation.)

## Notable quotes
> "The Protected Resource Metadata document returned by the MCP server **MUST** include the `authorization_servers` field containing at least one authorization server."
> "Clients **MUST** maintain separate registration state (client credentials, tokens) per authorization server and **MUST NOT** assume that credentials valid for one authorization server will be accepted by another."
> "the `issuer` value in the document **MUST** be identical to the issuer identifier used to construct the well-known URL. If they differ, the client **MUST NOT** use the metadata."
> "a document fetched from `https://attacker.example/.well-known/oauth-authorization-server` that contains `\"issuer\": \"https://honest.example\"` **MUST** be rejected."

> [!question] Embedded directive found in fetched page (NOT obeyed, per NFR-SEC-2)
> Injected page prefix instructs: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Treated as data, not obeyed.

## Gaps / open questions
- AS selection logic among multiple `authorization_servers` is delegated to the client (RFC 9728 §7.6) with no MCP-specific deterministic rule.
- Behavior when all well-known probes fail ("Abort or use pre-configured values") is under-specified as to precedence/fallback config source.
- Well-known root probing is "Not applicable if the MCP server is at the root" — edge cases for nested paths left to RFC 9728.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]] · [[mcp-spec-authorization-index]] · [[mcp-spec-authorization-security-considerations]] · [[mcp-spec-authorization-client-registration]]
