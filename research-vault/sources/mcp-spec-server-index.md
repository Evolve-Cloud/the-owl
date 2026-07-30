---
title: "Server — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, overview, primitives]
sources: 1
updated: 2026-07-30
---
**Source:** [Server](https://modelcontextprotocol.io/specification/2026-07-28/server/index.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
The server-index page introduces the three server-exposed primitives in MCP and classifies each by who controls it. It is the entry point for the server-side spec, framing Prompts (user-controlled), Resources (application-controlled), and Tools (model-controlled). The individual method-level detail lives on the per-primitive sub-pages (discover, tools, resources, prompts) plus the utilities (caching, completion, logging, pagination).

## Key points
The three primitives and their control model (verbatim from the page table):

| Primitive | Control | Description | Example |
| --- | --- | --- | --- |
| **Prompts** | User-controlled | Interactive templates invoked by user choice | Slash commands, menu options |
| **Resources** | Application-controlled | Contextual data attached and managed by the client | File contents, git history |
| **Tools** | Model-controlled | Functions exposed to the LLM to take actions | API POST requests, file writing |

- Related methods across sub-pages: `server/discover`, `tools/list`, `tools/call`, `resources/list`, `resources/read`, `resources/templates/list`, `prompts/list`, `prompts/get`, `completion/complete`.

## Notable quotes
> "Interactive templates invoked by user choice" (Prompts)
> "Functions exposed to the LLM to take actions" (Tools)

## Gaps / open questions
- The fetched index rendered only the primitive table; surrounding narrative (if any) was not captured. Method-level MUST/SHOULD rules live on the sub-pages, not here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-discover]] · [[mcp-spec-server-tools]] · [[mcp-spec-server-resources]] · [[mcp-spec-server-prompts]]
