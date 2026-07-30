---
title: "Prompts — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, prompts, prompts-get, prompts-list]
sources: 1
updated: 2026-07-30
---
**Source:** [Prompts](https://modelcontextprotocol.io/specification/2026-07-28/server/prompts.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Prompts are server-provided, user-controlled templates of structured messages/instructions for interacting with LLMs (e.g. exposed as slash commands). Clients discover via `prompts/list` (paginated + cacheable) and retrieve via `prompts/get`, passing arguments (auto-completable via completion API). The page defines the Prompt and PromptMessage data types, content types, and error/security rules.

## Key points
- Methods: **`prompts/list`** (pagination + caching), **`prompts/get`**. Notification: **`notifications/prompts/list_changed`**.
- Capability: servers supporting prompts **MUST** declare `prompts` in their `DiscoverResult`: `{"capabilities":{"prompts":{"listChanged":true}}}`.
- `prompts/list` set **MAY** be empty, **MAY** change, **MUST NOT** vary per-connection or as a side effect; **MAY** vary by authorization on the request.
- **Prompt** fields: `name`, `title` (optional), `description` (optional), `icons` (optional), `arguments` (optional list; each has `name`, `description`, `required`).
- **`prompts/get`** response: `resultType` (`"complete"`), `description`, `messages` (array of PromptMessage). **MAY** respond with `InputRequiredResult` (MRTR) needing `inputResponses`/`requestState` on retry.
- **PromptMessage**: `role` (`"user"` or `"assistant"`) + `content`. Content types: `text`; `image` (base64 `data` + valid `mimeType`, **MUST** be base64-encoded); `audio` (base64 `data` + `mimeType`, MUST be base64); `resource_link` (`uri`, `name`, `description`, `mimeType`); embedded `resource` (**MUST** include valid URI, appropriate MIME type, and either text or base64 blob). Content supports the same annotations as resources.
- **List Changed**: servers that declared `listChanged` **SHOULD** notify clients that opened a `subscriptions/listen` stream with `promptsListChanged: true`.
- **Error handling** (SHOULD, standard JSON-RPC): invalid prompt name `-32602`; missing required arguments `-32602`; internal errors `-32603`.
- **Implementation**: servers **SHOULD** validate prompt arguments before processing; clients **SHOULD** handle pagination; both **SHOULD** respect capability negotiation.
- **Security**: Implementations **MUST** carefully validate all prompt inputs and outputs to prevent injection attacks or unauthorized resource access.

## Notable quotes
> "Prompts are designed to be **user-controlled**... This refers to who decides when the prompt is used, not who authors its content. Prompt content is defined by the server."
> "Implementations **MUST** carefully validate all prompt inputs and outputs to prevent injection attacks or unauthorized access to resources."

> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Unlike tools/resources list results in the fetched examples, the `prompts/get` response example carries no `ttlMs`/`cacheScope` (get is not listed as cacheable; only `prompts/list` is).

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-utilities-completion]] · [[mcp-spec-server-resources]] · [[mcp-spec-server-utilities-pagination]]
