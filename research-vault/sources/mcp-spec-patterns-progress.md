---
title: "Progress — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, patterns, progress, notifications, progressToken]
sources: 1
updated: 2026-07-30
---
**Source:** [Progress](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/progress.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Specifies optional progress tracking for long-running operations. A client opts in by including a `progressToken` in the request's `_meta`; the server MAY then emit `notifications/progress` referencing that token with a monotonically increasing `progress` value plus optional `total` and `message`. Progress is best-effort — servers may send none, at any frequency, and must stop after completion.

## Key points
- Client opts in by including `progressToken` in `_meta` of the request.
- `progressToken` **MUST** be a string or integer; can be chosen by any means but **MUST** be unique across all active requests.
- **`notifications/progress` params**: `progressToken` (the original token), `progress` (current value), `total` (optional), `message` (optional).
- `progress` **MUST** increase with each notification, even if total unknown. `progress` and `total` **MAY** be floating point. `message` **SHOULD** provide relevant human-readable info.
- **Behavior**: (1) progress notifications **MUST** only reference tokens that were provided in an active request and are associated with an in-progress operation; (2) servers receiving a token **MAY** choose not to send any, send at any frequency, or omit total if unknown.
- Clients and servers **SHOULD** track active progress tokens; both **SHOULD** implement rate limiting to prevent flooding; progress notifications **MUST** stop after completion.

## Notable quotes
> "The `progress` value **MUST** increase with each notification, even if the total is unknown."
> "Progress tokens ... **MUST** be unique across all active requests."
> "Progress notifications **MUST** stop after completion."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Rate-limiting thresholds and notification frequency are left to implementations.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-patterns-index]] · [[mcp-spec-patterns-cancellation]] · [[mcp-spec-basic-index]] · [[mcp-spec-transports-streamable-http]]
