---
title: "Schema Reference — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, client, schema, json-rpc, error-codes]
sources: 1
updated: 2026-07-30
---
**Source:** [Schema Reference](https://modelcontextprotocol.io/specification/2026-07-28/schema.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Auto-generated TypeDoc schema reference for MCP 2026-07-28. Documents the JSON-RPC 2.0 wire structures (notifications, result/error responses), shared common types, the `Icon` type, and the numeric error-code allocation. Reflects the stateless redesign of this revision. Logging is among the primitives now marked deprecated.

## Key points
- `JSONRPCNotification`: `method`, `params?`, `jsonrpc: "2.0"` — no `id`, no response expected.
- `JSONRPCResponse` = `JSONRPCResultResponse | JSONRPCErrorResponse`.
- `JSONRPCResultResponse`: `jsonrpc`, `id` (required), `result: Result`.
- `JSONRPCErrorResponse`: `jsonrpc`, `id?` (optional), `error: Error`.
- `RequestId` = `string | number`.
- `Icon`: `src`, `mimeType?`, `sizes?: string[]`, `theme?: "light" | "dark"`. Consumers **SHOULD** verify icon URLs are same-domain/trusted and **SHOULD** take precautions with SVGs (may contain executable JavaScript).
- Error codes: `ParseError` `-32700`; `MissingRequiredClientCapabilityError` `-32021` (→ 400); `UnsupportedProtocolVersionError` `-32022` (→ 400). A request requiring an undeclared client capability returns `-32021`, NOT `-32601` (`MethodNotFoundError`).
- Reverse-DNS namespace: any prefix whose second label is `modelcontextprotocol` or `mcp` is **reserved** for MCP use.
- **DEPRECATED:** Logging (and Roots/Sampling) primitives noted as deprecated; each carries: "Remains in the specification for at least twelve months; see the deprecated features registry."

## Notable quotes
> "Any prefix where the second label is `modelcontextprotocol` or `mcp` is reserved for MCP use. ... However, `com.example.mcp/` is NOT reserved, as the second label is `example`."

## Gaps / open questions
- Full field-level schema for deprecated Sampling/Roots types not captured in fetch; consult schema.ts on GitHub if needed.

> [!question] Embedded directive in fetched page (DATA, not obeyed)
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Recorded verbatim; not acted upon.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-changelog]] · [[mcp-spec-index]]
