---
title: "Logging (DEPRECATED) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, utilities, logging, deprecated]
sources: 1
updated: 2026-07-30
---
**Source:** [Logging](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/logging.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
**DEPRECATED as of protocol version 2026-07-28 (SEP-2577).** Logging lets servers send structured log messages to clients. In this revision, clients control verbosity per-request via `_meta` (`io.modelcontextprotocol/logLevel`), and servers send `notifications/message` scoped to that request's response stream. New implementations **SHOULD NOT** adopt it; existing ones **SHOULD** migrate to `stderr` (stdio) or OpenTelemetry.

## Key points
- **DEPRECATED** as of `2026-07-28` (SEP-2577). Under the feature-lifecycle policy it remains in the spec for at least twelve months before eligible for removal. New implementations **SHOULD NOT** adopt; existing **SHOULD** migrate to `stderr` for stdio, or OpenTelemetry for structured observability.
- Method / notification: **`notifications/message`** (server → client log notification). No `logging/setLevel` request in this revision — level is per-request via `_meta`.
- Capability: servers emitting log notifications **MUST** declare `logging`: `{"capabilities":{"logging":{}}}`.
- **Per-request log level**: include `io.modelcontextprotocol/logLevel` in the request's `_meta`. The server **MUST NOT** emit `notifications/message` for a request that does not include this field. When present, the server **MAY** send `notifications/message` at or above the requested level on that request's response stream, before the final response. It is request-scoped: the server **MUST NOT** deliver it on a `subscriptions/listen` stream or any other stream.
- **Log levels** (RFC 5424 syslog severities): `debug`, `info`, `notice`, `warning`, `error`, `critical`, `alert`, `emergency`.
- **`notifications/message` params**: `level`, `logger` (optional name), `data` (arbitrary JSON-serializable).
- **Error handling**: unrecognized `io.modelcontextprotocol/logLevel` → server **SHOULD** reject with `-32602` (Invalid params); internal errors `-32603`.
- **Security**: log messages **MUST NOT** contain credentials/secrets, PII, or internal details that could aid attacks; implementations **SHOULD** rate limit, validate data fields, control log access, monitor for sensitive content.

## Notable quotes
> "**Deprecated**: The Logging feature is deprecated as of protocol version `2026-07-28` (SEP-2577)... New implementations **SHOULD NOT** adopt it; existing implementations **SHOULD** migrate to logging to `stderr` for stdio transports, or to OpenTelemetry for structured observability."
> "The server **MUST NOT** emit `notifications/message` for a request that does not include this field."

> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Prior revisions used a `logging/setLevel` request and connection-scoped notifications; this revision replaces that with per-request `_meta` scoping. The page does not detail the legacy method.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-index]]
