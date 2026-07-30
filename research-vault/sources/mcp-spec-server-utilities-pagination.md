---
title: "Pagination — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, utilities, pagination, cursor]
sources: 1
updated: 2026-07-30
---
**Source:** [Pagination](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/pagination.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
MCP paginates list operations that may return large result sets using an opaque, cursor-based model (not numbered pages). Servers determine page size and return an optional `nextCursor`; clients continue by passing that cursor. Cursors are opaque tokens clients **MUST NOT** parse or modify. The page lists which operations support pagination and the client/server guidelines.

## Key points
- Model: opaque **`cursor`** string token representing a position; page size is server-determined and clients **MUST NOT** assume a fixed page size.
- Response includes current page + optional **`nextCursor`** (present only if more results exist). Request continues by passing `params.cursor`.
- Operations supporting pagination: **`resources/list`**, **`resources/templates/list`**, **`prompts/list`**, **`tools/list`**.
- Guidelines — servers **SHOULD**: provide stable cursors; handle invalid cursors gracefully. Clients **SHOULD**: treat missing `nextCursor` as end of results; support both paginated and non-paginated flows.
- Clients **MUST** treat cursors as opaque: no assumptions about format, no parsing/modifying, and no determination based on cursor value other than whether a non-null value was provided — an empty string is a valid cursor and **MUST NOT** be treated as end of results.
- **Error handling**: invalid cursors **SHOULD** result in error code `-32602` (Invalid params).

## Notable quotes
> "The **cursor** is an opaque string token, representing a position in the result set"
> "an empty string is a valid cursor and thus **MUST NOT** be treated as the end of results"

> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Cross-page consistency is not guaranteed (covered on the caching page's pagination interaction); this page focuses on cursor mechanics only.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-utilities-caching]] · [[mcp-spec-server-tools]] · [[mcp-spec-server-resources]] · [[mcp-spec-server-prompts]]
