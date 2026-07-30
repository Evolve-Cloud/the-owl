---
title: "Streamable HTTP Transport — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, transports, streamable-http, sse, headers, security]
sources: 1
updated: 2026-07-30
---
**Source:** [Streamable HTTP Transport](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Specifies the Streamable HTTP binding: a single POST-only MCP endpoint where each JSON-RPC message is its own HTTP POST, answered with either a single JSON object or a request-scoped SSE stream. Revision 2026-07-28 removed the GET stream endpoint and protocol-level sessions (breaking change). Covers DNS-rebinding security, request-metadata mirroring into HTTP headers (`MCP-Protocol-Version`, `Mcp-Method`, `Mcp-Name`, `Mcp-Param-*`), Base64 sentinel value encoding, header/body validation (`HeaderMismatch` `-32020`), and backward compatibility with legacy sessions and the deprecated HTTP+SSE transport.

## Key points
- Server **MUST** provide a single HTTP endpoint (the MCP endpoint) supporting POST (e.g. `https://example.com/mcp`).
- **Security**: server **MUST** validate `Origin` header on all connections (DNS-rebinding); invalid present Origin → **MUST** respond `403 Forbidden` (body **MAY** be JSON-RPC error with no `id`). Local servers **SHOULD** bind to localhost (127.0.0.1) not 0.0.0.0. Servers **SHOULD** implement proper auth.
- **Sending**: every message **MUST** be a new HTTP POST. Client **MUST** use POST; **MUST** include `Accept` listing both `application/json` and `text/event-stream`; **MUST** include request-metadata headers; body **MUST** be a single JSON-RPC *request* or *notification*; **MUST NOT** send responses.
- Notification body: accepted → server **MUST** return `202 Accepted` no body; cannot accept → **MUST** return HTTP error (e.g. `400`). Note: core protocol defines NO client→server notifications over Streamable HTTP (`notifications/cancelled` is stdio-only; on HTTP closing the SSE stream is the cancel signal).
- Request body: server **MUST** return either `Content-Type: application/json` (single object) or `text/event-stream` (SSE stream); client **MUST** support both.
- **SSE stream**: server **MAY** send request-related `notifications/progress`/`notifications/message` before final response (**MUST** relate to originating request); **MUST NOT** send independent JSON-RPC requests (server-to-client via `InputRequiredResult`/MRTR — change from 2025-03-26…2025-11-25). Final response **SHOULD** terminate the stream. Server **SHOULD** send `X-Accel-Buffering: no`. Long-lived streams encouraged to emit SSE comment lines (`:\r\n`) as keep-alive; clients must ignore comment lines. Resumable SSE via `Last-Event-ID` NOT supported.
- Long-lived change notifications delivered on the response stream of a `subscriptions/listen` request (`notifications/tools/list_changed`, `notifications/resources/updated`); request-scoped notifications flow only on their originating request's stream.
- **Cancellation**: closing the SSE response stream **MUST** be treated as cancellation; server **SHOULD** stop work ASAP and **MUST NOT** send further messages.
- **Protocol Version Header**: every POST **MUST** include `MCP-Protocol-Version` (e.g. `2026-07-28`); **MUST** match body `_meta.io.modelcontextprotocol/protocolVersion` or server **MUST** reject `400` + `HeaderMismatch`. Unsupported version → `400` + `UnsupportedProtocolVersionError`. Unknown RPC method → `404 Not Found` + JSON-RPC `-32601`. Server supporting pre-`2025-06-18` clients **MAY** treat missing header as `2025-03-26`; else **MUST** reject.
- **Standard headers** (REQUIRED for compliance): `Mcp-Method` (from `method`, all requests); `Mcp-Name` (from `params.name` or `params.uri`, for `tools/call`/`resources/read`/`prompts/get`).
- **Custom headers from tool params**: `x-mcp-header` extension property in a param's `inputSchema` → header `Mcp-Param-{name}`. Optional for servers but clients **MUST** support it (mirror annotated values). `x-mcp-header` constraints: MUST NOT be empty; MUST match HTTP token syntax; no CR/LF; case-insensitively unique; only primitive types (integer/string/boolean, NOT `number`); integers in JS safe range; only statically reachable via `properties` chain (not through `items`/composition/conditional/`$ref`). Clients **MUST** reject tool defs violating constraints by excluding the invalid tool from `tools/list` (**SHOULD** log warning). Other-transport clients **MAY** ignore `x-mcp-header`.
- **Value encoding**: clients **MUST** encode header values (string as-is; integer decimal; boolean lowercase). Non-ASCII/control/whitespace values **MUST** use Base64: `=?base64?{Base64}?=` (case-sensitive markers). Same rule for `Mcp-Name`. Plain-ASCII values matching the sentinel **MUST** also be Base64-encoded. Servers **MUST** decode encoded values before comparing to body.
- **Server validation**: servers processing the body **MUST** reject header/body mismatches with `400` + JSON-RPC `-32020` `HeaderMismatch`. Failure conditions: missing required standard header; value mismatch; invalid characters. Integer values **SHOULD** be compared numerically. Header names case-insensitive; header values case-sensitive. Intermediaries enforcing policy on mirrored headers **SHOULD** verify `MCP-Protocol-Version` requires header–body validation, else reject.
- **Backward compatibility**: dual-support client **MAY** try modern request first; on `400` **SHOULD** inspect body — recognized modern error → retry/correct; empty/non-modern → fall back to `initialize`. Earlier Streamable HTTP (`2025-03-26`…`2025-11-25`) used `Mcp-Session-Id`, GET SSE stream, server-initiated requests, `Last-Event-ID` — none in this revision. Modern-only server **SHOULD**: GET/DELETE → `405 Method Not Allowed`; ignore `Mcp-Session-Id`; ignore `Last-Event-ID`. HTTP+SSE transport (2024-11-05) is **Deprecated**; new implementations **SHOULD NOT** adopt it.

## Notable quotes
> "Removal of the GET stream endpoint. Removal of protocol-level sessions."
> "Servers **MUST** validate the `Origin` header on all incoming connections to prevent DNS rebinding attacks."
> "Closing the SSE response stream **MUST** be treated by the server as cancellation of that request."
> "The header value **MUST** match the `io.modelcontextprotocol/protocolVersion` field carried in the request body's `_meta`."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Header requirements for notification POSTs are explicitly "not defined by this revision."
- SSE keep-alive interval unspecified ("periodically").

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-transports-index]] · [[mcp-spec-transports-stdio]] · [[mcp-spec-basic-index]] · [[mcp-spec-versioning]] · [[mcp-spec-patterns-subscriptions]] · [[mcp-spec-patterns-cancellation]]
