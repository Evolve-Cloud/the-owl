---
title: "Versioning and Compatibility — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, versioning, capabilities, extensions, backward-compat]
sources: 1
updated: 2026-07-30
---
**Source:** [Versioning and Compatibility](https://modelcontextprotocol.io/specification/2026-07-28/basic/versioning.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Defines how client and server agree on protocol version, extensions, and interoperability with older handshake-based revisions. There is NO negotiation handshake in modern MCP: every request carries its protocol version and the server accepts/rejects each request independently. Extensions are negotiated via a capabilities `extensions` map. A compatibility matrix covers modern/legacy/dual-era combinations.

## Key points
- Terminology: **Modern** = per-request-metadata versions (`2026-07-28`+); **Legacy** = `initialize`-handshake versions (`2025-11-25` and earlier); **Dual-era** = supports both.
- Every request declares its version in `_meta`; on HTTP also in the `MCP-Protocol-Version` header.
- Server that doesn't implement requested version **MUST** respond with `UnsupportedProtocolVersionError` (code `-32022`) listing supported versions in `data.supported` (plus `data.requested`). Client **SHOULD** select a mutually supported version and retry, or surface an error.
- Servers **MUST** implement `server/discover`. Clients **MAY** call it up front but aren't required to — may invoke any RPC inline and handle `UnsupportedProtocolVersionError`.
- **Extension negotiation**: extensions advertised in the `extensions` field of capabilities (map of extension id → per-extension settings object). Extension identifiers **MUST** follow `_meta` key naming rules with a mandatory prefix. Examples: `io.modelcontextprotocol/ui` (MCP Apps), `io.modelcontextprotocol/tasks` (Tasks). Empty settings object = support with no settings. If one party supports an extension and the other doesn't, supporting party **MUST** revert to core behavior or reject with error; extensions **SHOULD** document fallback.
- **Backward compat**: dual-era server **MAY** implement both behaviors. Client detects server era via transport-specific mechanics: stdio → probe with `server/discover`, fall back on any non-modern error; Streamable HTTP → attempt modern request, inspect body of `400 Bad Request` before falling back. A recognized modern JSON-RPC error identifies a modern server.
- Era is a property of the server, not the request. Clients **SHOULD** cache era for the server-process lifetime (stdio) / origin (HTTP), **MAY** persist across restarts, re-probing on failure.
- Modern-only server **SHOULD** name supported versions in any error it returns to an `initialize` request (legacy clients have no fall-forward).
- Compatibility matrix outcomes: Modern↔Modern works; Modern→Legacy fails; Dual-era→Modern/Legacy works; Legacy→Modern fails; Legacy→Dual-era works; Legacy↔Legacy per legacy revision.
- Dual-era server selects behavior from how the client opens: modern `_meta` → stateless per this revision; `initialize` → legacy semantics. **MAY** serve both eras concurrently on same endpoint/process.

## Notable quotes
> "There is no negotiation handshake. Every request carries its protocol version, and the server accepts or rejects each request independently"
> "The era determination is a property of the server, not of an individual request."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- The exact code a legacy server returns to a modern/unknown request is implementation-defined (commonly `-32601`/`-32602`).
- `server/discover` `DiscoverResult` / `supportedVersions` shape defined in schema, not here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-basic-index]] · [[mcp-spec-transports-stdio]] · [[mcp-spec-transports-streamable-http]]
