---
title: "Key Changes (Changelog) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, client, changelog, stateless, mrtr, deprecation]
sources: 1
updated: 2026-07-30
---
**Source:** [Key Changes](https://modelcontextprotocol.io/specification/2026-07-28/changelog.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Lists changes since 2025-11-25. The headline shift is making MCP **stateless**: protocol-level sessions, the `Mcp-Session-Id` header, and the `initialize`/`notifications/initialized` handshake are removed; every request now carries its protocol version and client capabilities in `_meta`. Introduces `server/discover`, `subscriptions/listen`, the Multi Round-Trip Requests (MRTR) pattern, and a required `resultType` field. Deprecates Roots, Sampling, and Logging (SEP-2577).

## Key points
- **Stateless:** remove sessions + `Mcp-Session-Id`; remove `initialize`/`notifications/initialized`. Per-request `_meta` keys: `io.modelcontextprotocol/protocolVersion`, `io.modelcontextprotocol/clientCapabilities`, `io.modelcontextprotocol/clientInfo`, server `io.modelcontextprotocol/serverInfo`. Version mismatch → `UnsupportedProtocolVersionError`.
- **`server/discover`:** servers **MUST** implement it to advertise supported versions, capabilities, identity.
- **`subscriptions/listen`** replaces HTTP GET + `resources/subscribe`/`unsubscribe`; single long-lived POST stream; opt-in types (`toolsListChanged`, `promptsListChanged`, `resourcesListChanged`, `resourceSubscriptions`); notifications tagged with `io.modelcontextprotocol/subscriptionId`.
- **Remove `ping`, `logging/setLevel`, `notifications/roots/list_changed`.** Log level now per-request via `io.modelcontextprotocol/logLevel` in `_meta`; servers **MUST NOT** emit `notifications/message` for requests without that field.
- **MRTR (SEP-2322):** replaces server-initiated `roots/list`, `sampling/createMessage`, `elicitation/create`. Servers return `InputRequiredResult` (`resultType: "input_required"`) with `inputRequests`; clients reply with `inputResponses` on a retry.
- **`resultType` required** on all results: `"complete"` or `"input_required"`. Clients **MUST** treat omitted (older-server) as `"complete"`.
- Remove SSE resumability/redelivery (`Last-Event-ID`); broken stream → client **MUST** re-issue as a new request.
- Tasks moved to official extension `io.modelcontextprotocol/tasks` (polling `tasks/get`, `tasks/update`; removes `tasks/result`, `tasks/list`).
- Minor: `CacheableResult` adds `ttlMs` + `cacheScope` (`"public"`/`"private"`); `Mcp-Method`/`Mcp-Name` headers required; resource-not-found error `-32002`→`-32602`; error-code partition `-32020..-32099` reserved for MCP.
- Removed `notifications/elicitation/complete` and URL-mode `elicitationId` (2025-11-25 additions).

## DEPRECATIONS (this revision)
- **Roots, Sampling, and Logging** deprecated (SEP-2577). Migrations: Roots → tool params / resource URIs / server config; Sampling → integrate directly with LLM provider APIs; Logging → `stderr` (stdio) or OpenTelemetry.
- HTTP+SSE transport reclassified Deprecated (SEP-2596).
- `includeContext` values `"thisServer"` / `"allServers"` reclassified Deprecated (removed no later than Sampling).
- OAuth 2.0 Dynamic Client Registration (RFC7591) deprecated in favor of Client ID Metadata Documents.

## Notable quotes
> "Deprecate the Roots, Sampling, and Logging features (SEP-2577). These features remain fully functional during the deprecation window but new implementations should not add support for them."

## Gaps / open questions
- Twelve-month window sets earliest-removal at "first revision released on or after 2027-07-28"; actual removal is a maintainer decision.

> [!question] Embedded directive in fetched page (DATA, not obeyed)
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Recorded verbatim; not acted upon.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-deprecated]] · [[mcp-spec-client-sampling]] · [[mcp-spec-client-roots]]
