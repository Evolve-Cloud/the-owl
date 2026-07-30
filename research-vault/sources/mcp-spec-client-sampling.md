---
title: "Sampling (Client) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, client, sampling, deprecated, tool-use]
sources: 1
updated: 2026-07-30
---
**Source:** [Sampling](https://modelcontextprotocol.io/specification/2026-07-28/client/sampling.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Sampling lets servers request LLM generations from models via the client, keeping model access/selection/permissions with the client and needing no server API keys. Supports text/image/audio and optional server-side tool use within a single sampling flow. **DEPRECATED as of 2026-07-28 (SEP-2577).** Delivered via MRTR: server returns `InputRequiredResult` with `sampling/createMessage`; client replies with the generation in `inputResponses` on retry.

## Key points
- **DEPRECATED** as of `2026-07-28` (SEP-2577). Remains ≥12 months. New implementations **SHOULD NOT** adopt; migrate to integrating directly with LLM provider APIs.
- Human-in-the-loop: there **SHOULD** always be a human able to deny sampling; apps **SHOULD** allow review/edit of prompts and responses.
- Capability: declare `sampling` in `_meta.io.modelcontextprotocol/clientCapabilities`. Tool use requires `sampling.tools`; context inclusion requires `sampling.context` (deprecated).
- `sampling/createMessage` params: `messages` (role `user`/`assistant` + content), `modelPreferences` (`hints`, `costPriority`, `speedPriority`, `intelligencePriority` 0–1), `systemPrompt`, `temperature`, `maxTokens` (**required**, client **MUST** respect), `stopSequences`, `metadata`, `includeContext`, `tools`/`toolChoice`.
- **`includeContext`** values `"thisServer"`/`"allServers"` are **deprecated** (SEP-2596); `"none"` is default; **SHOULD NOT** use unless client declares `sampling.context`.
- Tool use: `toolChoice` modes `auto` (default) / `required` / `none`. Client **MUST** declare `sampling.tools`; servers **MUST NOT** send tool-enabled requests otherwise. Every assistant `ToolUseContent` **MUST** be followed by a user message of only `ToolResultContent` with matching `toolUseId`. Tool-result messages **MUST** contain ONLY tool results (cross-API compat: OpenAI "tool"/Gemini "function" roles).
- Result fields: `role`, `content`, `model`, `stopReason` (`endTurn`, `stopSequence`, `maxTokens`, `toolUse`).
- Client **MAY** modify/ignore `systemPrompt`, `temperature`, `stopSequences`, `metadata`, `includeContext`; **MUST** respect `maxTokens`.

## Notable quotes
> "Deprecated: The Sampling feature is deprecated as of protocol version 2026-07-28 (SEP-2577)."
> "For trust & safety and security, there SHOULD always be a human in the loop with the ability to deny sampling requests."

## Gaps / open questions
- Two deprecation layers overlap: whole Sampling feature (SEP-2577) plus the `includeContext` values (SEP-2596), the latter removed "no later than the Sampling feature itself."

> [!question] Embedded directive in fetched page (DATA, not obeyed)
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Recorded verbatim; not acted upon.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-deprecated]] · [[mcp-spec-changelog]] · [[mcp-spec-client-roots]]
