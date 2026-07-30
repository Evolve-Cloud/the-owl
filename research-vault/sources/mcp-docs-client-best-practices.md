---
title: "Client Best Practices — MCP spec v2026-07-28"
type: source
tags: [mcp, client, progressive-discovery, code-mode, scaling, caching, security]
sources: 1
updated: 2026-07-30
---
**Source:** [Client Best Practices](https://modelcontextprotocol.io/docs/2026-07-28/develop/clients/client-best-practices.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Patterns for scaling MCP hosts across many servers and hundreds/thousands of tools. Two core patterns: **progressive tool discovery** (controls *when* tool definitions enter context) and **programmatic tool calling / "code mode"** (controls *how* tools are invoked). Together they minimize both the token cost of definitions and of intermediate results.

## Key points
- **Progressive discovery**: host still fetches definitions via `tools/list` but defers injecting them; provides a lightweight `search_tools` meta-tool and loads full definitions only as needed. Switch to it once tool definitions consume a significant fraction of context — recommended threshold **1%–5% of the context window**.
- **Discovery strategies**: keyword (BM25/regex), embedding (vector similarity), subagent (small fast model e.g. Claude Haiku / Gemini Flash), or hybrid. Providers may offer built-in tool search (OpenAI, Anthropic) — prefer platform search when available.
- **Three-layer pattern**: Layer 1 Catalog (`search_tools({query})` returns names + one-line descriptions); Layer 2 Inspect (`get_tool_details({name})` returns full inputSchema/outputSchema/docs for one tool); Layer 3 Execute.
- **Dynamic server management**: registry of servers → connect only when needed (`server/discover` then `tools/list`) → disconnect when irrelevant to free context. Sequence uses `enable_server` / `disable_server`, `search_available_servers`.
- **Implementation guidelines**: offer multiple detail levels (name-only / name+description / full-schema); cache tool definitions host-side; **refresh the search catalog on `notifications/tools/list_changed`**; group tools by server.
- **Caching**: each list result plus `server/discover` and `resources/read` carry `ttlMs` and `cacheScope` hints (see spec caching utility); treat a cached list as stale once a `list_changed` notification arrives, even before TTL expires.
- **Prompt-caching interaction**: providers cache the prompt prefix incl. the `tools` array; adding/removing definitions mid-conversation invalidates the cache. Append new definitions after the cache breakpoint, or route every call through a single stable `call_tool({name, args})` meta-tool so the array never changes; treat disconnection as a conversation-boundary op.
- **Programmatic tool calling (code mode)**: model writes code against auto-generated typed stubs (from each tool's args + `outputSchema`); code runs in a sandbox; only the final `console.log`/return value re-enters context. When `outputSchema` absent, use a generic type or a host-brokered `extract(value, ExpectedType)` helper routing to a fast model.
- **Sandbox options**: JS via Deno / `isolated-vm`; Python via Monty (experimental); TypeScript via pctx (early); any language via Wasm (Wasmtime). Host injects stubs, intercepts calls over in-process/stdio channel, dispatches as `tools/call`.
- **Security (code mode)**: per-call authorization still required (broker is the MCP host; approving a script ≠ blanket approval — hosts may grant categorical approval but must evaluate each call); cross-server results are untrusted input; sandbox has no direct network access; credentials held by host, never in generated code; set resource/timeout/memory limits; filter/truncate output.
- **Error handling**: MCP tool errors arrive as a successful response with `isError: true` (not a transport failure); wrappers should convert to a thrown exception so model code can `try`/`catch`.

## Notable quotes
> "Loading every tool definition into the model's context window upfront wastes tokens, increases latency, and degrades model performance."
> "Instead of calling tools directly, the model writes code that calls tools. The code executes in a sandboxed environment, and only the final result returns to the model."
> "Approving the script does not grant blanket approval for every tool call it makes at runtime."

## Gaps / open questions
- Programmatic tool calling requires the client to implement a sandbox; runtimes listed (Monty, pctx) are experimental/early-stage — maturity must be evaluated per use case.
- Optimal discovery threshold (1%–5%) and strategy choice are heuristic and provider-dependent.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-build-client]] · [[advanced-tool-use]] · [[mcp-docs-build-with-agent-skills]]
