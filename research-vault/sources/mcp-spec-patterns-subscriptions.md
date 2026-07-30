---
title: "Subscriptions — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, patterns, subscriptions, notifications, streaming]
sources: 1
updated: 2026-07-30
---
**Source:** [Subscriptions](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/subscriptions.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
`subscriptions/listen` opens a long-lived server→client notification stream, replacing the former `resources/subscribe` RPC and the HTTP GET endpoint. The client specifies a `notifications` filter of event types it wants; the server MUST NOT send unrequested types. The server acknowledges with `notifications/subscriptions/acknowledged` carrying the subscription id, and every message on the stream carries `io.modelcontextprotocol/subscriptionId` in `_meta` for demultiplexing. Covers filters, acknowledgment ordering, concurrent subscriptions, cancellation, and graceful closure.

## Key points
- `subscriptions/listen` request carries a `notifications` filter; server **MUST NOT** send notification types the client has not explicitly requested. It replaces `resources/subscribe` + the HTTP GET endpoint.
- **Notification filter fields** (all optional; omitting = not subscribing): `toolsListChanged` (bool → `notifications/tools/list_changed`), `promptsListChanged` (bool → `notifications/prompts/list_changed`), `resourcesListChanged` (bool → `notifications/resources/list_changed`), `resourceSubscriptions` (string[] of URIs → `notifications/resources/updated`).
- **Acknowledgment**: server **MUST** send `notifications/subscriptions/acknowledged` as the FIRST message, carrying the subscription id in `_meta` under `io.modelcontextprotocol/subscriptionId`, and **MUST NOT** send any notification on the subscription before it. On stdio, ordering is per subscription id (other subscriptions' messages **MAY** interleave before it). The ack's `notifications` field reflects the subset the server agreed to honor (unsupported types omitted). Client **SHOULD** check the acknowledged filter vs. what it requested and handle unsupported types gracefully.
- **subscriptionId**: all stream messages carry `io.modelcontextprotocol/subscriptionId` in `_meta`; value = the JSON-RPC `id` of the `subscriptions/listen` request. On stdio (single shared channel) clients **MUST** use it to correlate notifications.
- **Multiple concurrent subscriptions**: a client **MAY** have several active; each identified by its `subscriptions/listen` request id; every notification carries that id for demultiplexing.
- **Cancellation**: subscription ends when — client cancels (close SSE stream on HTTP, or send `notifications/cancelled` referencing the request id on stdio); server tears it down (**SHOULD** send the empty `subscriptions/listen` response for graceful end, then close); or the transport closes.
- **Graceful closure**: server ending on its own initiative **SHOULD** respond to the original `subscriptions/listen` request with an empty result (`resultType: "complete"`, with `subscriptionId` in `_meta`) before closing — signals clean end vs. abrupt drop (no response). A transport closing without it indicates unexpected disconnect, which the client **MAY** treat as reconnect trigger.
- On stdio, after reconnection the client **MUST** re-send `subscriptions/listen` to re-establish subscriptions — server holds no subscription state across reconnections.

## Notable quotes
> "The server **MUST NOT** send notification types the client has not explicitly requested."
> "The server **MUST** send `notifications/subscriptions/acknowledged` as the first message ... and **MUST NOT** send any notification on the subscription before it."
> "the server holds no subscription state across reconnections."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- `SubscriptionsListenRequest` full schema lives in the schema, not this page.
- Keep-alive on the listen stream is covered on the Streamable HTTP page, not here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-patterns-index]] · [[mcp-spec-patterns-cancellation]] · [[mcp-spec-transports-stdio]] · [[mcp-spec-transports-streamable-http]] · [[mcp-spec-basic-index]]
