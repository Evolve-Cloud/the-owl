---
title: "Client Registration — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, security, authorization, oauth]
sources: 1
updated: 2026-07-30
---
**Source:** [Client Registration](https://modelcontextprotocol.io/specification/2026-07-28/basic/authorization/client-registration.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
This page defines the three MCP client-registration mechanisms — Client ID Metadata Documents (CIMD, preferred for no-prior-relationship), Pre-registration (existing relationship), and Dynamic Client Registration (RFC 7591, deprecated/backwards-compat) — plus a client selection priority order. It specifies CIMD requirements for clients and authorization servers, DCR `application_type` constraints under OIDC, and authorization-server-binding rules that keep credentials scoped to their issuing AS.

## Key points
- **Three mechanisms:** CIMD (no prior relationship, most common); Pre-registration (existing relationship); DCR (backwards compat / specific requirements).
- **Client selection priority (clients supporting all options SHOULD use):**
  1. Use pre-registered client info if available.
  2. Use CIMD if AS advertises support (`client_id_metadata_document_supported` in AS metadata).
  3. Use DCR as fallback if AS supports it (`registration_endpoint` in AS metadata).
  4. Prompt user to enter client info if nothing else available.
- **CIMD:** clients and AS **SHOULD** support OAuth Client ID Metadata Documents (draft-00). Clients use an HTTPS URL as `client_id` pointing to a JSON metadata document — addresses the no-pre-existing-relationship scenario.
  - **For clients:** **MUST** host metadata at an HTTPS URL per RFC; `client_id` URL **MUST** use "https" scheme and contain a path component (e.g. `https://example.com/client.json`); metadata **MUST** include at least `client_id`, `client_name`, `redirect_uris`; **MUST** ensure `client_id` in metadata matches the document URL exactly; **MAY** use `private_key_jwt` for client auth with JWKS.
  - **For authorization servers:** **SHOULD** fetch metadata on URL-formatted client_ids; **MUST** validate fetched `client_id` matches the URL exactly; **SHOULD** cache respecting HTTP cache headers; **MUST** validate redirect URIs in the authz request against the metadata document; **MUST** validate document is valid JSON with required fields; **SHOULD** follow CIMD §6 + spec security considerations.
  - Example metadata: `token_endpoint_auth_method: "none"`, `grant_types: ["authorization_code"]`, `response_types: ["code"]`, localhost/127.0.0.1 redirect URIs.
  - **Advertising:** AS sets `client_id_metadata_document_supported: true`. Clients **SHOULD** check and **MAY** fall back to DCR or pre-registration if unavailable.
- **Pre-registration:** clients **SHOULD** support static client credentials (hardcoded client ID/credentials for that AS, or a UI to enter details after self-registering an OAuth client).
- **Dynamic Client Registration (DEPRECATED):** new implementations should use CIMD. Clients and AS **MAY** support RFC 7591 to obtain client IDs without user interaction; retained for backwards compat.
  - **`application_type`:** clients **MUST** specify an appropriate `application_type` during DCR. Omitting defaults to `"web"` under OIDC (can conflict with native redirect URIs); non-OIDC servers ignore it. Native apps (desktop, mobile, CLI, localhost-hosted) **SHOULD** use `"native"`; web apps (remote browser-based) **SHOULD** use `"web"`.
  - Clients **MUST** be prepared to handle registration failures due to redirect URI constraints under OIDC; **SHOULD** surface a meaningful error; **MAY** retry with adjusted `application_type` or conforming redirect URIs.
- **Authorization Server Binding:** clients using pre-registered creds or persisting DCR creds **MUST** associate them with the specific issuing AS keyed by `issuer`. When the AS changes (via updated PRM) clients **MUST NOT** reuse creds from a different AS and **MUST** re-register with the new AS. If the PRM-indicated AS no longer matches the registered one, clients **SHOULD** surface an error rather than silently use mismatched creds. CIMD-based client IDs are portable across AS (self-hosted HTTPS URLs); no re-registration needed on AS change.

## Security requirements
- CIMD `client_id` **MUST** use https + path; metadata **MUST** contain `client_id`/`client_name`/`redirect_uris`; client **MUST** ensure `client_id` matches URL exactly. (Threat: client impersonation / metadata spoofing.)
- AS **MUST** validate fetched `client_id` matches URL exactly; **MUST** validate redirect URIs against the metadata doc; **MUST** validate valid JSON + required fields. (Threat: open redirect, malformed/forged client metadata.)
- Clients **MUST** specify appropriate `application_type` in DCR. (Threat: native/web redirect-URI confusion.)
- Clients **MUST** associate credentials with the issuing AS by `issuer`; **MUST NOT** reuse creds across AS; **MUST** re-register on AS change; **SHOULD** error on mismatch. (Threat: cross-AS credential misuse / silent trust of wrong AS.)
- CIMD security implications per CIMD §6 and the spec's CIMD security section (SSRF, localhost impersonation, trust policies).

## Notable quotes
> "Dynamic Client Registration is deprecated. New implementations should use Client ID Metadata Documents instead."
> "The `client_id` URL **MUST** use the \"https\" scheme and contain a path component, e.g. `https://example.com/client.json`"
> "Clients **MUST** ensure the `client_id` value in the metadata matches the document URL exactly"
> "[AS] **MUST** validate that the fetched document's `client_id` matches the URL exactly"
> "clients **MUST NOT** reuse client credentials from a different authorization server and **MUST** re-register with the new authorization server."
> "Client IDs based on Client ID Metadata Documents are portable across authorization servers, since they are self-hosted HTTPS URLs resolved by the authorization server on demand."

> [!question] Embedded directive found in fetched page (NOT obeyed, per NFR-SEC-2)
> Injected page prefix instructs: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Treated as data, not obeyed.

## Gaps / open questions
- CIMD `redirect_uris` example uses `http://localhost`/`127.0.0.1` — allowed by communication-security rules but carries the localhost-impersonation risk noted in the security-considerations page.
- Behavior when a client supports none of the four selection-priority options beyond "prompt user" is minimally specified.
- `private_key_jwt` client auth is MAY only; no mandated authentication method for CIMD clients (example shows `token_endpoint_auth_method: "none"`).

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]] · [[mcp-spec-authorization-index]] · [[mcp-spec-authorization-security-considerations]] · [[mcp-spec-authorization-server-discovery]]
