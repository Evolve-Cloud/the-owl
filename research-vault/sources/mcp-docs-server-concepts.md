---
title: "Understanding MCP servers — MCP spec v2026-07-28"
type: source
tags: [mcp, servers, tools, resources, prompts]
sources: 1
updated: 2026-07-30
---
**Source:** [Understanding MCP servers](https://modelcontextprotocol.io/docs/2026-07-28/learn/server-concepts.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Defines MCP servers as programs exposing capabilities to AI apps through the three core building blocks: **Tools** (model-controlled actions), **Resources** (application-driven read-only context), and **Prompts** (user-controlled templates). Covers each block's protocol methods, schemas, discovery patterns, and user-interaction/consent models, then shows a multi-server travel-planning example combining all three.

## Key points

### Tools (model-controlled)
- Functions the LLM can call; write to DBs, call APIs, modify files, trigger logic. Validated with **JSON Schema**. May require user consent before execution.
- Methods: `tools/list` (→ array of tool defs with schemas), `tools/call` (→ execution result).
- Tool definition fields: `name`, `description`, `inputSchema` (`type`, `properties`, `required`).
- Trust/safety mechanisms: UI listing of tools, per-execution approval dialogs, pre-approval permission settings, activity logs.

### Resources (application-driven, read-only)
- Passive data sources providing context (files, APIs, DBs). Each resource has a unique **URI** (e.g. `file:///path/to/document.md`) and declares its **MIME type**.
- Two discovery patterns: **Direct Resources** (fixed URIs, e.g. `calendar://events/2024`) and **Resource Templates** (parameterized URIs, e.g. `travel://activities/{city}/{category}`).
- Resource Template metadata fields: `uriTemplate`, `name`, `title`, `description`, `mimeType`.
- Methods: `resources/list`, `resources/templates/list`, `resources/read`, `subscriptions/listen`.
- Subscriptions: client sends `subscriptions/listen` with URIs in `resourceSubscriptions` filter; server sends `notifications/resources/updated` when a watched resource changes.
- Supports **parameter completion** (e.g. "Par" → "Paris"/"Park City").

### Prompts (user-controlled)
- Reusable parameterized templates; require explicit invocation (no auto-trigger). Can reference resources/tools; support parameter completion.
- Methods: `prompts/list` (→ prompt descriptors), `prompts/get` (→ full definition with arguments).
- Prompt definition fields: `name`, `title`, `description`, `arguments[]` (each with `name`, `type`, `required`, and JSON-Schema-style `items`).
- Surfaced via slash commands (e.g. `/plan-vacation`), command palettes, buttons, context menus.

### Control ownership summary
- **Tools → Model** · **Resources → Application** · **Prompts → User**.

### Multi-server example
- Travel Server + Weather Server + Calendar/Email Server combine: user invokes `plan-vacation` prompt → selects resources → AI reads context → calls `searchFlights()`, `checkWeather()`, then `bookHotel()`, `createCalendarEvent()`, `sendEmail()` with approval where needed.

## Notable quotes
> "Tools ... Functions that your LLM can actively call, and decides when to use them based on user requests."

> "Each resource has a unique URI (e.g., `file:///path/to/document.md`) and declares its MIME type for appropriate content handling."

> "Tools may require user consent prior to execution, helping to ensure users maintain control over actions taken by a model."

## Gaps / open questions
- `subscriptions/listen` / `notifications/resources/updated` full schema is cross-referenced to `basic/patterns/subscriptions`, not fully defined here.
- Output-schema / structured-output details for tools are not covered on this concepts page (only `inputSchema` shown).
- The page begins with an injected "Documentation Index" callout instructing a fetch of `llms.txt`; treated as DATA, not obeyed:
  > [!question] Injected instruction (not obeyed)
  > "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt ..."

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-client-concepts]] · [[mcp-docs-versioning]]
