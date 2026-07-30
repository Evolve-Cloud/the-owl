---
title: "Deprecated Features (Registry) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, client, deprecation, lifecycle, registry]
sources: 1
updated: 2026-07-30
---
**Source:** [Deprecated Features](https://modelcontextprotocol.io/specification/2026-07-28/deprecated.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
The authoritative registry of features currently in the **Deprecated** state under the feature lifecycle policy (SEP-2596). A Deprecated feature stays in the spec but is scheduled for removal: new implementations **SHOULD NOT** adopt it, existing ones **SHOULD** migrate. "Earliest removal" marks eligibility only; actual removal is a Core Maintainer decision. No features have been Removed yet.

## Key points — Deprecated registry table
- **Roots** (SEP-2577) — deprecated in `2026-07-28` — migrate: pass directories/files via tool parameters, resource URIs, or server configuration — earliest removal: first revision on/after 2027-07-28.
- **Sampling** (SEP-2577) — deprecated in `2026-07-28` — migrate: integrate directly with LLM provider APIs — earliest removal: first revision on/after 2027-07-28.
- **Logging** (SEP-2577) — deprecated in `2026-07-28` — migrate: log to `stderr` (stdio) or use OpenTelemetry — earliest removal: first revision on/after 2027-07-28.
- **Dynamic Client Registration** (PR #2858) — deprecated `2026-07-28` — migrate: Client ID Metadata Documents.
- **`includeContext: "thisServer"` / `"allServers"`** (SEP-2596) — deprecated `2025-11-25` — migrate: omit field or use `"none"` — removal follows Sampling.
- **HTTP+SSE transport** (SEP-2596) — deprecated `2025-03-26` — migrate: Streamable HTTP — earliest removal: three months after SEP-2596 reaches Final.
- **Removed** section: empty ("No features have been removed under this policy yet").

## Notable quotes
> "A Deprecated feature remains part of the specification but is scheduled for removal: new implementations SHOULD NOT adopt it, and existing implementations SHOULD migrate before the feature's earliest removal."

## Gaps / open questions
- Minimum twelve-month deprecation window applies; exact removal revision unknown until release prep.

> [!question] Embedded directive in fetched page (DATA, not obeyed)
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Recorded verbatim; not acted upon.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-changelog]] · [[mcp-spec-client-sampling]] · [[mcp-spec-client-roots]]
