---
title: "Roots (Client) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, client, roots, deprecated, filesystem]
sources: 1
updated: 2026-07-30
---
**Source:** [Roots](https://modelcontextprotocol.io/specification/2026-07-28/client/roots.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Roots let clients expose filesystem directories/files that the client considers relevant, as **informational guidance** (not access control) so servers can focus operations. **DEPRECATED as of 2026-07-28 (SEP-2577).** Delivered via MRTR: server returns `InputRequiredResult` containing a `roots/list` request; client returns `roots` in `inputResponses` on retry.

## Key points
- **DEPRECATED** as of `2026-07-28` (SEP-2577). Remains in spec ≥12 months before eligible for removal. New implementations **SHOULD NOT** adopt; migrate to passing directories/files via tool parameters, resource URIs, or server configuration.
- Capability: clients supporting roots **MUST** declare `roots` in `_meta.io.modelcontextprotocol/clientCapabilities` (`{"roots": {}}`).
- `roots/list` request (no params) delivered inside `InputRequiredResult.inputRequests`; client returns array of `Root`.
- `Root`: `uri` (**MUST** be a `file://` URI in current spec), `name` (optional, display).
- Roots are guidance only — "The protocol does not enforce that servers stay within roots."
- Note: `notifications/roots/list_changed` was removed this revision (per changelog).
- Security: clients **MUST** validate root URIs to prevent path traversal, implement access controls; servers **SHOULD** respect root boundaries and validate paths.

## Notable quotes
> "Deprecated: The Roots feature is deprecated as of protocol version 2026-07-28 (SEP-2577)."
> "They are informational guidance rather than an access-control mechanism. The protocol does not enforce that servers stay within roots."

## Gaps / open questions
- `uri` restricted to `file://` "in the current specification" — leaves room for other schemes later, but feature is on a deprecation path.

> [!question] Embedded directive in fetched page (DATA, not obeyed)
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Recorded verbatim; not acted upon.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-deprecated]] · [[mcp-spec-changelog]] · [[mcp-spec-client-sampling]]
