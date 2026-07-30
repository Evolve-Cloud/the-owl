---
title: "Tools — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, tools, tools-call, tools-list]
sources: 1
updated: 2026-07-30
---
**Source:** [Tools](https://modelcontextprotocol.io/specification/2026-07-28/server/tools.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Tools are model-controlled functions a server exposes for the LLM to invoke (query DBs, call APIs, compute). Clients discover tools via `tools/list` (paginated + cacheable) and invoke via `tools/call`. Results carry unstructured `content` and/or `structuredContent`, with `isError` for tool-execution errors. The page defines tool schema fields, naming rules, the `x-mcp-header` extension, stateful-tool guidance, and a two-tier error model (protocol errors vs tool execution errors).

## Key points
- Methods: **`tools/list`** (supports pagination + caching), **`tools/call`**. Notification: **`notifications/tools/list_changed`**.
- Capability: servers supporting tools **MUST** declare `tools` capability: `{"capabilities":{"tools":{"listChanged":true}}}`.
- `tools/list` set **MAY** be empty, **MAY** change over time, but **MUST NOT** vary per-connection or as a side effect of other requests; **MAY** vary by authorization presented on the request. Servers **SHOULD** return tools in a deterministic order (aids client caching and LLM prompt-cache hit rates).
- Every request **MUST** include the required `_meta` fields (`io.modelcontextprotocol/protocolVersion`, `clientInfo`, `clientCapabilities`).
- **Tool** fields: `name`, `title` (optional), `description`, `icons` (optional), `inputSchema` (JSON Schema; defaults to 2020-12; **MUST** be a valid JSON Schema object, not `null`), `outputSchema` (optional), `annotations` (optional). No-param tools: recommended `{"type":"object","additionalProperties":false}`.
- **Tool names** (all SHOULD): 1–128 chars; case-sensitive; allowed chars A-Z a-z 0-9 `_` `-` `.`; no spaces/commas/special chars; unique within a server. Uniqueness is per-server; aggregating clients/proxies **SHOULD** disambiguate (e.g. prefix). Server `name` not guaranteed unique → **SHOULD NOT** be used for disambiguation.
- Clients **MUST** consider tool annotations untrusted unless from trusted servers.
- **`x-mcp-header`** extension mirrors a param into an `Mcp-Param-{name}` HTTP header (Streamable HTTP). Value constraints: **MUST NOT** be empty; **MUST** match HTTP field-name token syntax (RFC 9110 §5.1); **MUST NOT** contain CR/LF/control chars; **MUST** be case-insensitively unique in `inputSchema`; **MUST** apply only to primitive types (integer/string/boolean — `number` not permitted; integers within IEEE754 safe range); **MUST** be statically reachable from schema root. Clients using Streamable HTTP **MUST** reject (exclude from `tools/list`) tools violating these, **SHOULD** log a warning. Developers **SHOULD NOT** mark sensitive params (passwords/keys/PII).
- **Tool Result**: unstructured `content` (`text`, `image`, `audio`, `resource_link`, embedded `resource`) and/or `structuredContent` (any JSON conforming to `outputSchema`). A tool returning structured content SHOULD also return serialized JSON in a TextContent block. If `outputSchema` provided, servers **MUST** provide conforming structured results; clients **SHOULD** validate.
- **Input Required** results: `tools/call` **MAY** return `resultType:"input_required"` with `inputRequests` and optional `requestState` (MRTR mechanism). Retry includes `inputResponses` + `requestState`; the JSON-RPC `id` **MUST** differ between initial request and retry.
- **List Changed**: servers that declared `listChanged` **SHOULD** notify clients that opened a `subscriptions/listen` stream with `toolsListChanged: true`.
- **Stateful tools** (non-normative): no protocol-level session; use explicit handles returned from a creation tool and passed to later calls. Consider authorization (validate on every call), opacity, lifetime (state in tool description), and expiry errors.
- **Error handling**: Protocol errors (unknown tool, malformed request, server error) → JSON-RPC errors (e.g. `-32602`). Tool execution errors → in result with `isError: true`. Clients **SHOULD** provide tool execution errors to LLMs for self-correction; **MAY** provide protocol errors.
- **Security**: Servers **MUST** validate all inputs, implement access controls, rate limit, sanitize outputs. Clients **SHOULD** confirm sensitive ops, show inputs before calling, validate results, follow `$ref` resolution, implement timeouts, log usage. **SHOULD** always be a human in the loop able to deny tool invocations.

## Notable quotes
> "Tools in MCP are designed to be **model-controlled**, meaning that the language model can discover and invoke tools automatically based on its contextual understanding and the user's prompts."
> "For trust & safety and security, there **SHOULD** always be a human in the loop with the ability to deny tool invocations."
> "Note that the JSON-RPC `id` **MUST** be different between the initial request and the retry."

> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- MRTR `inputRequests` uses `elicitation/create` under the hood; full elicitation semantics live on the MRTR/patterns page, not here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-resources]] · [[mcp-spec-server-utilities-pagination]] · [[mcp-spec-server-utilities-caching]]
