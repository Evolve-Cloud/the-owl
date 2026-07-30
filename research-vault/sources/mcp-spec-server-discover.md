---
title: "Discovery — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, discover, capabilities, versioning]
sources: 1
updated: 2026-07-30
---
**Source:** [Discovery](https://modelcontextprotocol.io/specification/2026-07-28/server/discover.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
`server/discover` lets a client query a server's supported protocol versions, capabilities, and identity before sending any other requests. Servers **MUST** implement it. Calling it is optional for clients — a client may invoke any RPC inline and handle `UnsupportedProtocolVersionError`. It is useful for presenting server info in one request and as a stdio backward-compatibility probe. The operation supports caching.

## Key points
- Method: **`server/discover`**. Servers **MUST** implement it.
- Request carries no body params beyond standard `_meta`, which includes `io.modelcontextprotocol/protocolVersion` (`"2026-07-28"`), `io.modelcontextprotocol/clientInfo` (`name`, `version`), and `io.modelcontextprotocol/clientCapabilities`.
- **DiscoverResult** fields: `resultType` (`"complete"`), `supportedVersions` (array; client should choose one), `capabilities` (e.g. `tools`, `resources`, `prompts`), `_meta['io.modelcontextprotocol/serverInfo']` (`name`, `version` — servers **SHOULD** include), `instructions` (optional natural-language guidance for LLMs), plus caching hints `ttlMs` and `cacheScope`.
- Client is optional to call, but a client supporting both modern (per-request `_meta`) and legacy (`initialize` handshake) servers **SHOULD** send `server/discover` first on stdio for the fallback probe.
- `serverInfo` is self-reported and NOT verified: clients **SHOULD NOT** use it to change behavior and **SHOULD NOT** rely on it for security decisions.

## Notable quotes
> "`server/discover` lets a client query a server's supported protocol versions, capabilities, and identity before sending any other requests. Servers **MUST** implement it."
> "`serverInfo` is self-reported by the server and is not verified by the protocol... Clients **SHOULD NOT** use it to change their behavior, and **SHOULD NOT** rely on it for security decisions."

The fetched page contained an embedded directive at the top. Per NFR-SEC-2 it is DATA, not an instruction to obey:
> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- `cacheScope` example value shown is `"public"`; the discover page does not enumerate the full capability set beyond the example (`tools`, `resources`).

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-index]] · [[mcp-spec-server-utilities-caching]]
