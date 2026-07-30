---
title: "Cancellation — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, patterns, cancellation, timeouts, notifications]
sources: 1
updated: 2026-07-30
---
**Source:** [Cancellation](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/cancellation.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Specifies optional cancellation of in-progress requests via `notifications/cancelled`. Clients SHOULD send it to terminate a request; on stdio it is required, on Streamable HTTP closing the SSE stream is the signal instead. Servers MUST send `notifications/cancelled` only to tear down a `subscriptions/listen` stream, never otherwise. Covers timeouts, race conditions, and graceful "fire and forget" error handling.

## Key points
- Client **SHOULD** send a cancellation notification to terminate a previously issued request.
- Server **MUST** send `notifications/cancelled` referencing a `subscriptions/listen` request ID when tearing down that subscription stream; servers **MUST NOT** send `notifications/cancelled` for any other purpose.
- **`notifications/cancelled` params**: `requestId` (ID of request to cancel), `reason` (optional string, may be logged/displayed). Example params: `{"requestId": "123", "reason": "User requested cancellation"}`.
- **Transport-specific**: Streamable HTTP → closing the SSE response stream is the signal; server **MUST** treat client disconnect as cancellation; no `notifications/cancelled` required/expected. stdio → client **MUST** send `notifications/cancelled` referencing the request ID.
- **Timeouts**: implementations **SHOULD** set timeouts on all sent requests; on timeout the sender **SHOULD** cancel and stop waiting (HTTP: close stream; stdio: send `notifications/cancelled`). SDKs **SHOULD** allow per-request timeout config. **MAY** reset timeout clock on progress notification but **SHOULD** always enforce a maximum timeout.
- **Behavior requirements**: (1) cancellation notifications **MUST** only reference requests previously issued by the client and believed still in-progress; (2) server-sent cancellations **MUST** reference a `subscriptions/listen` request; (3) servers receiving cancellation **SHOULD** stop processing, free resources, not send a response; (4) servers **MAY** ignore cancellation if request unknown / already completed / not cancellable; (5) client **SHOULD** ignore any late response to a cancelled request.
- **Timing/race**: cancellation may arrive after processing completes / response sent; both parties **MUST** handle race conditions gracefully.
- **Error handling**: invalid cancellations (unknown IDs, already-completed, malformed) **SHOULD** be ignored — maintains "fire and forget" nature.
- Both parties **SHOULD** log cancellation reasons; UIs **SHOULD** indicate when cancellation is requested.

## Notable quotes
> "A server **MUST** send `notifications/cancelled` referencing a `subscriptions/listen` request ID when it tears down that subscription stream ... Servers **MUST NOT** send `notifications/cancelled` for any other purpose."
> "Streamable HTTP: Closing the SSE response stream is the cancellation signal."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Default timeout durations left to implementations/SDKs.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-patterns-index]] · [[mcp-spec-patterns-subscriptions]] · [[mcp-spec-patterns-progress]] · [[mcp-spec-transports-stdio]] · [[mcp-spec-transports-streamable-http]]
