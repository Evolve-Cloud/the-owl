---
title: "stdio Transport — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, transports, stdio, lifecycle, cancellation]
sources: 1
updated: 2026-07-30
---
**Source:** [stdio Transport](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/stdio.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Specifies the stdio binding: the client launches the server as a subprocess and both ends exchange newline-delimited JSON-RPC messages over stdin/stdout. Covers message framing, request metadata (inline in body), cancellation via `notifications/cancelled`, process shutdown/restart lifecycle, and backward-compatibility probing with `server/discover`. The wire format also works over Unix sockets/TCP; only process-lifecycle aspects are stdio-specific.

## Key points
- Server reads JSON-RPC from `stdin`, writes to `stdout`; each message is one request/notification/response. Messages **MUST NOT** contain embedded newlines (newline-delimited).
- Server **MAY** write UTF-8 to `stderr` for logging; client **MAY** capture/forward/ignore it and **SHOULD NOT** assume stderr means error.
- Server **MUST NOT** write non-MCP to `stdout`; client **MUST NOT** write non-MCP to server's `stdin`.
- Custom transports over reliable byte streams **SHOULD** reuse this framing + message rules.
- **Sending**: client writes *requests* and *notifications* to `stdin`, one per line; **MUST NOT** write JSON-RPC *responses*.
- **Receiving**: client reads from `stdout`, one per line; single shared channel (no per-request streams). Server writes: (1) responses correlated by `id`; (2) request-scoped notifications (`notifications/progress`, `notifications/message`); (3) subscription notifications. Clients **MUST** correlate subscription notifications via `io.modelcontextprotocol/subscriptionId` in `_meta`. Server **MUST NOT** write JSON-RPC *requests* to `stdout` — server-to-client interactions carried in `InputRequiredResult` replies (MRTR).
- **Request metadata**: carried inline in body (`_meta.io.modelcontextprotocol/*`); no header layer.
- **Cancellation**: to cancel, client **MUST** send `notifications/cancelled` referencing the request ID (no per-request stream to close). Servers **SHOULD** stop work ASAP and **MUST NOT** send further messages for it.
- **Shutdown**: client **SHOULD** (1) close input stream to child, (2) wait for exit, (3) forcibly terminate if not exited in reasonable time (POSIX SIGTERM→SIGKILL; Windows TerminateProcess/Job Objects). Servers **SHOULD** exit promptly on stdin close/EOF (primary + only portable graceful signal). Server **MAY** initiate shutdown by closing output and exiting.
- **Unexpected termination**: if server exits unexpectedly, client **SHOULD** restart it; stateless protocol means in-flight requests are lost and can be retried. Active `subscriptions/listen` streams must be re-established after restart.
- **Backward compatibility**: dual-support client **SHOULD** probe with `server/discover` (preferred modern version in `_meta`) before other requests. Outcomes: `DiscoverResult` → modern, pick from `supportedVersions`; recognized modern error (e.g. `UnsupportedProtocolVersionError`) → modern, do NOT fall back to `initialize`; any other error or timeout → legacy, fall back to `initialize`. Fallback **MUST NOT** be keyed to one error code (legacy commonly returns `-32601`/`-32602` or nothing). Modern-only clients need not probe but probing is **RECOMMENDED** (some legacy servers process era-ambiguous methods under legacy semantics).

## Notable quotes
> "Messages are delimited by newlines, and **MUST NOT** contain embedded newlines."
> "The server **MUST NOT** write JSON-RPC *requests* to `stdout`."
> "Because the protocol is stateless, any in-flight requests are simply lost and the client can retry them against the fresh process."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- "reasonable time"/"reasonable timeout" for shutdown and probe are unspecified (implementation-defined).

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-transports-index]] · [[mcp-spec-transports-streamable-http]] · [[mcp-spec-patterns-cancellation]] · [[mcp-spec-versioning]] · [[mcp-spec-patterns-subscriptions]]
