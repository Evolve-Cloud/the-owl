---
title: "Completion — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, utilities, completion, autocomplete]
sources: 1
updated: 2026-07-30
---
**Source:** [Completion](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/completion.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Completion gives servers a standardized way to offer autocompletion for the arguments of prompts and resource templates, supporting IDE-like interactive UX. Clients send `completion/complete` referencing a prompt (by name) or resource template (by URI), plus the argument being typed and optional already-resolved argument context. Servers return relevance-ranked suggestions (max 100), an optional total, and a `hasMore` flag.

## Key points
- Method: **`completion/complete`**.
- Capability: servers supporting completions **MUST** declare `completions`: `{"capabilities":{"completions":{}}}`.
- **CompleteRequest** params: `ref` (a `PromptReference` `{"type":"ref/prompt","name":...}` or `ResourceTemplateReference` `{"type":"ref/resource","uri":...}` where `uri` is a URI or URI template); `argument` (`{name, value}`); `context.arguments` (mapping of already-resolved argument names → values, to inform subsequent requests).
- Reference types: **`ref/prompt`** (prompt by name), **`ref/resource`** (resource URI or URI template).
- **CompleteResult**: `completion.values` (array of suggestions, **max 100**), `completion.total` (optional total matches), `completion.hasMore` (boolean; additional results exist). `resultType: "complete"`.
- **Error handling** (SHOULD, standard JSON-RPC): method not found `-32601` (capability not supported); invalid prompt name `-32602`; missing required arguments `-32602`; internal errors `-32603`.
- **Implementation**: servers **SHOULD** sort by relevance, do fuzzy matching, rate limit, validate inputs; clients **SHOULD** debounce, cache results where appropriate, handle missing/partial results.
- **Security**: implementations **MUST** validate all completion inputs, rate limit, control access to sensitive suggestions, and prevent completion-based information disclosure.

## Notable quotes
> "For prompts or URI templates with multiple arguments, clients should include previous completions in the `context.arguments` object to provide context for subsequent requests."
> "Maximum 100 items per response"

> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Completion applies to prompt arguments and resource-template arguments; tool inputSchema completion is not covered by this page.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-prompts]] · [[mcp-spec-server-resources]]
