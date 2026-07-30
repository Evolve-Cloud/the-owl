---
title: "Transports Overview — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, transports, binding, custom-transport]
sources: 1
updated: 2026-07-30
---
**Source:** [Transports Overview](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/index.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Defines what a transport must provide to carry MCP messages and the requirements for defining new ones. A transport is a *binding*: it defines message framing, delivery, request-metadata carriage, and cancellation/termination signaling — but not message meaning (patterns are core-protocol, identical on every transport). Two standard bindings: stdio and Streamable HTTP. Custom transports are permitted.

## Key points
- Protocol semantics identical on every transport; a transport is purely a binding.
- Standard transports: (1) **stdio** — newline-delimited messages over standard streams of a client-launched subprocess; (2) **Streamable HTTP** — each message is an HTTP POST to a single MCP endpoint; replies arrive as a JSON object or request-scoped SSE stream.
- JSON-RPC messages **MUST** be UTF-8 encoded.
- A binding **MUST** deliver client-sent *requests* and *notifications* to server, and server-sent *responses* and *notifications* to client. No other direction exists — servers do not initiate JSON-RPC requests and clients do not send JSON-RPC responses.
- **Request metadata** travels in the message body: every request carries protocol version + client capabilities in `_meta.io.modelcontextprotocol/*`. A binding **MAY** mirror selected body fields into envelope metadata (Streamable HTTP mirrors into HTTP headers). Body remains source of truth; mirroring bindings define how mismatches are rejected.
- **Cancellation**: each binding defines how client abandons an in-flight request — stdio sends `notifications/cancelled`; Streamable HTTP closes the request's response stream. Protocol-level rules are the same everywhere.
- **Custom transports**: clients/servers **MAY** implement additional mechanisms; protocol is transport-agnostic over any bidirectional channel. Implementers **MUST** preserve JSON-RPC message format, message patterns, and the per-request metadata model. Custom transports **SHOULD** document connection establishment, framing, cancellation. Those over reliable bidirectional byte streams (Unix sockets, TCP) **SHOULD** reuse stdio framing.
- **Backward compatibility**: earlier revisions used connection-scoped `initialize` session and allowed server-initiated requests; era detection + fallback per the Versioning page. Each binding page describes its detection mechanics.

## Notable quotes
> "A transport is a **binding**: it defines how messages are framed and delivered ... It does not define what the messages mean"
> "servers do not initiate JSON-RPC requests and clients do not send JSON-RPC responses."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Concrete framing details deferred to the stdio/Streamable-HTTP binding pages.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-transports-stdio]] · [[mcp-spec-transports-streamable-http]] · [[mcp-spec-patterns-index]] · [[mcp-spec-patterns-cancellation]]
