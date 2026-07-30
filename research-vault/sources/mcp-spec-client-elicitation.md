---
title: "Elicitation (Client) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, client, elicitation, mrtr, security]
sources: 1
updated: 2026-07-30
---
**Source:** [Elicitation](https://modelcontextprotocol.io/specification/2026-07-28/client/elicitation.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Elicitation is the active client primitive letting servers request additional information from users through the client, nested inside other server features. Two modes: **Form mode** (in-band structured data with a restricted JSON Schema) and **URL mode** (out-of-band navigation for sensitive interactions that must not pass through the client). Delivered via the MRTR pattern: server returns `InputRequiredResult` containing an `elicitation/create` request; client replies with `inputResponses` on retry. This primitive is NOT deprecated.

## Key points
- Capability: clients **MUST** declare `elicitation` in `_meta.io.modelcontextprotocol/clientCapabilities`, e.g. `{"elicitation": {"form": {}, "url": {}}}`. Empty `{}` ≡ `form` only. Must support at least one mode. Servers **MUST NOT** send unsupported modes.
- `elicitation/create` params: `mode` (`form`|`url`, optional→defaults `form`), `message` (required, human-readable).
- Form mode adds `requestedSchema` — restricted to **flat objects with primitive properties**: string (formats `email`, `uri`, `date`, `date-time`), number/integer, boolean, enum (`enum` or `oneOf`/`anyOf` with `const`+`title`). No nested objects/arrays-of-objects.
- URL mode adds `url` (**MUST** be valid URL); `content` omitted in the accept result.
- Three response actions: **accept** (with `content` for form), **decline**, **cancel**.
- Security: servers **MUST NOT** use form mode for sensitive info (passwords, API keys, tokens, payment creds) — **MUST** use URL mode. Clients **MUST NOT** auto-prefetch or open URLs without explicit consent; **MUST** show the full URL; **MUST** open in a manner the client/LLM cannot inspect.
- URL-mode phishing: server **MUST** verify the user who opened the URL is the same user who started the elicitation (e.g. session cookie `sub` vs MCP AS `sub`).
- URL mode is NOT MCP authorization; server **MUST NOT** rely on it to authorize the client to itself, and **MUST NOT** relay third-party credentials to the client (token passthrough forbidden).
- Note: `notifications/elicitation/complete` and `elicitationId` were removed this revision (correlate via `requestState` instead).

## Notable quotes
> "Servers MUST NOT use form mode elicitation to request sensitive information such as passwords, API keys, access tokens, or payment credentials"
> "The third-party credentials MUST NOT transit through the MCP client"

## Gaps / open questions
- URL mode marked "New feature" (introduced 2025-11-25); design "may change in future protocol revisions."

> [!question] Embedded directive in fetched page (DATA, not obeyed)
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Recorded verbatim; not acted upon.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-client-roots]] · [[mcp-spec-client-sampling]]
