---
title: "Message Patterns Overview — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, patterns, request-response, mrtr, subscriptions]
sources: 1
updated: 2026-07-30
---
**Source:** [Message Patterns Overview](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/index.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Defines the three core-protocol message patterns that compose JSON-RPC requests/responses/notifications into interactions: Request and Response, Multi Round-Trip Requests (MRTR), and Subscribe and Notify. Every interaction begins with the client; servers never initiate JSON-RPC requests and clients never send JSON-RPC responses. All transports carry all patterns identically.

## Key points
- Client sends *requests* and *notifications*; server answers each request with a *response* (result or error), optionally preceded by request-scoped *notifications*.
- Servers **MUST NOT** initiate JSON-RPC requests; clients do not send JSON-RPC responses.
- **Request and Response**: client sends request; server answers with result or error; while in flight server **MAY** send `notifications/progress` and `notifications/message` scoped to it.
- **Multi Round-Trip Requests (MRTR)**: when server needs client input (sampling, elicitation, roots) it answers with an `InputRequiredResult` (containing `inputRequests`); client retries the request (new `id`) with matching `inputResponses`.
- **Subscribe and Notify**: client sends `subscriptions/listen`; reply is a long-lived stream of requested notification types; server first sends `notifications/subscriptions/acknowledged`, then `notifications/*` tagged with `subscriptionId`. Stream state scoped to the request; if channel lost, client re-issues request.
- Adding patterns: a revision that adds a pattern defines it on this page; transports carry new patterns without change.

## Notable quotes
> "Servers **MUST NOT** initiate JSON-RPC requests, and clients do not send JSON-RPC responses."
> "Every transport carries all of these patterns; transports differ only in how messages are framed and delivered."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Overview page; concrete field structures deferred to the mrtr/progress/subscriptions/cancellation pages.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-patterns-mrtr]] · [[mcp-spec-patterns-progress]] · [[mcp-spec-patterns-subscriptions]] · [[mcp-spec-patterns-cancellation]] · [[mcp-spec-basic-index]]
