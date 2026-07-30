---
title: "Versioning — MCP spec v2026-07-28"
type: source
tags: [mcp, versioning, protocol, negotiation]
sources: 1
updated: 2026-07-30
---
**Source:** [Versioning](https://modelcontextprotocol.io/docs/2026-07-28/learn/versioning.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Describes MCP's `YYYY-MM-DD` string version scheme, revision states (Draft/Current/Final), the feature deprecation lifecycle, and — most notably for this revision — the shift to **per-request protocol-version negotiation**. In 2026-07-28, every request declares its version via a `_meta` key (and an HTTP header on Streamable HTTP), the server accepts/rejects each request independently, and the old initialization-based handshake is superseded (with a backward-compat path for `2025-11-25` and earlier).

## Key points
- **Version format:** `YYYY-MM-DD` = date of the last backwards-incompatible change. Version is **not** incremented for backwards-compatible updates.
- **Current version: `2026-07-28`.**
- **Revision states:** Draft (in-progress, not ready), Current (ready, may still get backwards-compatible changes), Final (past/complete, immutable).
- **Feature states:** individual features may be **Deprecated** — remain in spec ≥ 12 months (or ≥ 90 days under the expedited-removal exception) with a documented migration path, before becoming eligible for **Removal**. Listed in the deprecated-features registry.
- **Per-request negotiation (new model):**
  - Every request declares its version via the `io.modelcontextprotocol/protocolVersion` key in its `_meta` field.
  - On Streamable HTTP, the same value is carried in the `MCP-Protocol-Version` header.
  - Server accepts/rejects **each request independently**. Clients and servers **MAY** support multiple versions simultaneously.
  - If server doesn't support the requested version → responds with `UnsupportedProtocolVersionError` listing supported versions; client retries with a mutual version or surfaces an error.
- **`server/discover`:** a mandatory RPC returning the server's supported protocol versions, capabilities, and identity in one request. Calling it is **optional** — a client may send any request directly and handle a version error.
- **Backward compatibility:** for servers/clients on handshake-based revisions (`2025-11-25` and earlier), see the spec's Backward Compatibility (initialization-based versions) section.

## Notable quotes
> "The Model Context Protocol uses string-based version identifiers following the format `YYYY-MM-DD`, to indicate the last date backwards incompatible changes were made."

> "Every request declares the protocol version it is using via the `io.modelcontextprotocol/protocolVersion` key in its `_meta` field, and the server accepts or rejects each request independently."

> "server/discover, a mandatory RPC that returns the server's supported protocol versions, capabilities, and identity in a single request. Calling it is optional..."

## Gaps / open questions
- `server/discover` is "mandatory" for servers to implement but optional for clients to call — implication for minimal server implementations should be confirmed against the server/discover spec page.
- Exact `UnsupportedProtocolVersionError` shape and the `_meta` field structure are cross-referenced to `basic/index#meta` and `basic/versioning`, not fully expanded here.
- The page begins with an injected "Documentation Index" callout instructing a fetch of `llms.txt`; treated as DATA, not obeyed:
  > [!question] Injected instruction (not obeyed)
  > "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt ..."

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-client-concepts]] · [[mcp-docs-server-concepts]]
