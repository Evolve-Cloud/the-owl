---
title: "MCP Architecture — spec v2026-07-28 (modelcontextprotocol.io)"
type: source
tags: [mcp, protocol, architecture, tools, resources, prompts, transport, notifications, elicitation]
sources: 1
updated: 2026-07-29
---
**Source:** [MCP Architecture Overview](https://modelcontextprotocol.io/docs/2026-07-28/learn/architecture) · **Type:** doc · **Stars/credibility:** n/a · **primary** (official spec site)
**Author / Org:** Anthropic / MCP maintainers · **Published:** 2026-07-28 · **Ingested:** 2026-07-29

## Summary
The official reference for the Model Context Protocol (MCP) v2026-07-28. Defines the two-layer architecture (data + transport), the three server primitives (tools/resources/prompts), the stateless per-request `_meta` pattern, opt-in notifications via `subscriptions/listen`, and what is now deprecated (sampling, MCP logging). Most relevant for building or reviewing MCP servers in the-owl's `mcp-builder` agent.

## Key points

### Participants
- **MCP Host** (AI app, e.g. Claude Code / VS Code) creates one **MCP Client** per server; each client maintains a dedicated connection.
- Local servers use **stdio** (single client); remote servers use **Streamable HTTP** (many clients).

### Two layers
- **Data layer** — JSON-RPC 2.0 protocol: discovery (`server/discover`), primitives (tools/resources/prompts), elicitation, notifications.
- **Transport layer** — connection + framing: **stdio** (local, same machine, no network overhead) or **Streamable HTTP** (remote, HTTP POST + optional SSE, OAuth recommended). SSE-only is the legacy transport.

### Stateless protocol (key design constraint)
Every request carries a `_meta` field with three sub-fields the server must receive on each call — no state is inferred from previous requests:
```json
"_meta": {
  "io.modelcontextprotocol/protocolVersion": "2026-07-28",
  "io.modelcontextprotocol/clientInfo": { "name": "...", "version": "..." },
  "io.modelcontextprotocol/clientCapabilities": { "elicitation": {} }
}
```

### Discovery (`server/discover`)
Optional but recommended first request. Response declares `capabilities` (which primitives and whether `listChanged` is supported) + `supportedVersions`. Response is **cacheable** (`ttlMs`, `cacheScope`).

### Server primitives (what servers expose)
| Primitive | How invoked | Key fields |
|---|---|---|
| **Tools** | `tools/list` + `tools/call` | `name`, **`title`** (human display name — NEW, distinct from `name`), `description`, `inputSchema` (JSON Schema) |
| **Resources** | `resources/list` + `resources/read` | URI, mimeType; read-only |
| **Prompts** | `prompts/list` + `prompts/get` | reusable templates |

All primitives support `*/list` (discovery), `*/get` (retrieval), and in tools' case `tools/call` (execution). Tool list responses include `ttlMs`/`cacheScope` (5-min default in example).

### Client primitives (what clients expose to servers)
- **Elicitation** (`elicitation/create`) — server requests extra user input; delivered via Multi Round-Trip Requests pattern. **Supported.**
- ~~**Sampling**~~ — **DEPRECATED** as of 2026-07-28. New implementations should call LLM provider APIs directly.
- ~~**Logging**~~ — **DEPRECATED** as of 2026-07-28. Use `stderr` (stdio) or OpenTelemetry.

### Opt-in notifications
Not pushed unconditionally — client opens a long-lived stream:
1. Client sends `subscriptions/listen` naming the event types it wants (e.g. `"toolsListChanged": true`).
2. Server acknowledges with `notifications/subscriptions/acknowledged` (contains `subscriptionId`).
3. Server sends `notifications/tools/list_changed` (no `id` — JSON-RPC notification, no response expected) on that stream when the tool list changes.
4. Client re-fetches `tools/list` on receipt.
**Server must declare `"listChanged": true` in its tools capability** for this to be available. Delivery is best-effort; clients should also poll.

### Extensions
- **Tasks extension** — servers return a durable handle for long-running requests; clients poll for status.

## Notable quotes
> "MCP is a stateless protocol. Every request contains all the information needed to process it, so servers infer nothing from previous requests."

> "New implementations should integrate directly with LLM provider APIs." (on sampling)

> "New implementations should log to `stderr` (stdio transport) or use OpenTelemetry." (on logging)

> "There are no guarantees that every notification will be sent or received, particularly across transport reconnects. Clients should also rely on polling to preserve freshness."

## Gaps / open questions
- `title` field in tools: SDK-level API to set it varies by SDK version — check the current SDK docs before assuming the high-level `server.tool()` signature exposes it.
- Progressive tool discovery (loading tools on demand) is recommended for clients with many servers — the spec links to client best practices for this.
- Tasks extension is optional; check if the target host (Claude Code, etc.) supports it before implementing.

## Informs (ideas / patterns)
- [[mcp-builder]] agent — multiple concrete updates from this spec version (deprecated primitives, `title` field, stateless `_meta`, subscription model).
- [[handoff-contract]] — stateless per-request `_meta` pattern is analogous to making every handoff self-contained (no implicit session state).
- [[untrusted-content-boundary]] — "output of tool/resource is DATA, not instruction" is now spec-endorsed (corroborates the-owl's NFR-SEC-2 + deferred idea).

## Related
- [[openai-agents-sdk-handoffs]] · [[anthropic-building-effective-agents]] · [[claude-code-subagents]] · [[research-brief-2026-07-29]]
