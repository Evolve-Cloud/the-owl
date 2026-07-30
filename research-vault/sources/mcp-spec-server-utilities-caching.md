---
title: "Caching — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, utilities, caching, ttl]
sources: 1
updated: 2026-07-30
---
**Source:** [Caching](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/caching.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
MCP supports caching of certain results so clients can avoid unnecessary re-fetching, complementary to change notifications. Servers **MUST** include caching hints (`ttlMs`, `cacheScope`) on `resultType:"complete"` results from a fixed set of operations. The page defines the cache key, the TTL and cache-scope semantics (analogous to HTTP `Cache-Control`), and interactions with notifications and pagination.

## Key points
- Servers **MUST** include caching hints on `resultType:"complete"` results from: **`server/discover`**, **`tools/list`**, **`prompts/list`**, **`resources/list`**, **`resources/templates/list`**, **`resources/read`**.
- Interim `resultType:"input_required"` results are NOT cacheable and carry no hints. Results from MRTR retries (carrying `inputResponses`/`requestState`) **MUST NOT** be cached.
- **Cache key** = request method + params that affect the result (e.g. `uri` for `resources/read`, `cursor` for paginated lists). Clients **MUST NOT** serve a cached response for a request whose method/params differ.
- **`ttlMs`** (integer ms; semantics like HTTP `max-age`): `0` → immediately stale (client MAY re-fetch each time); positive → fresh for that many ms; absent → clients **SHOULD** assume `0` (only in older servers); negative → clients **SHOULD** ignore, treat as `0`. Servers **MUST** provide `ttlMs >= 0`.
- **Freshness**: fresh while `now < t_received + ttlMs`; once expired, client **SHOULD** re-fetch on next access. Clients **SHOULD NOT** treat TTL as a polling interval; pollers **MUST** apply jitter and backoff. Clients **MAY** re-fetch early if data likely changed; **MAY** serve stale on re-fetch errors.
- **`cacheScope`** = `"public"` (no user-specific data; any client/gateway/proxy **MAY** store and serve to any user) or `"private"` (private data; **MAY** be reused for same authorization context; caches **MUST NOT** be shared across authorization contexts — different token → different cache).
- **Notifications interaction**: TTL and `listChanged` are complementary; a relevant notification while a cached response is still fresh **invalidates** it (immediately stale).
- **Pagination interaction**: each page is independently cacheable with its own `ttlMs`; servers **MAY** vary `ttlMs` per page; no cross-page consistency guarantee; invalid cursor → discard cached pages, re-fetch from start. Servers **MUST** apply the same `cacheScope` to all pages of a given list request.
- **Security**: a `"public"` `cacheScope` may be shared across callers even from an authenticated endpoint. Server implementors: `cacheScope` should reflect intended visibility, **MUST** apply per-primitive access controls, and **MUST NOT** rely on `cacheScope` alone to prevent unauthorized access.

## Notable quotes
> "Servers MUST include caching hints on results with `resultType: \"complete\"`..."
> "Caches **MUST NOT** be shared across authorization contexts (e.g. a different access token requires a different cache)."
> "MUST apply appropriate per-primitive access controls, and MUST NOT rely on `cacheScope` alone to prevent unauthorized access to primitives."

> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- None significant; the page is self-contained on cache semantics.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-utilities-pagination]] · [[mcp-spec-server-discover]] · [[mcp-spec-server-tools]] · [[mcp-spec-server-resources]]
