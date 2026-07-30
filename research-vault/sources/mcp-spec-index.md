---
title: "Specification (Index) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, client, overview, architecture]
sources: 1
updated: 2026-07-30
---
**Source:** [Specification](https://modelcontextprotocol.io/specification/2026-07-28/index.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Top-level entry page for the MCP 2026-07-28 specification. Defines MCP as an open protocol connecting LLM apps to external data sources and tools over JSON-RPC 2.0, with Hosts, Clients, and Servers. It states RFC 2119/BCP 14 keyword conventions, lists server features (Resources, Prompts, Tools) and the single client feature (Elicitation), notes optional Extensions (Tasks, Skills over MCP, MCP Apps), and lays out Security & Trust/Safety principles.

## Key points
- Roles: **Hosts** (initiate connections), **Clients** (connectors in host), **Servers** (provide context/capabilities).
- Server features: **Resources**, **Prompts**, **Tools**. Client features: **Elicitation** ("Server-initiated requests for additional information from users").
- Notably, Sampling, Roots, and Logging are NOT listed as active client features here — consistent with their deprecation this revision.
- Base protocol: JSON-RPC message format, "Stateless, self-contained requests", "Per-request capability negotiation".
- Extensions are opt-in, negotiated during initialization: `Tasks`, `Skills over MCP`, `MCP Apps`.
- Security principles: User Consent and Control; Data Privacy; Tool Safety. Implementors **SHOULD** build consent/authorization flows; tool annotations "should be considered untrusted, unless obtained from a trusted server."

## Notable quotes
> "Clients may offer the following features to servers: Elicitation: Server-initiated requests for additional information from users"
> "Tools represent arbitrary code execution and must be treated with appropriate caution."

## Gaps / open questions
- Index lists only Elicitation as a client feature; deprecated Roots/Sampling still exist under `/client/` but are omitted here.

> [!question] Embedded directive in fetched page (DATA, not obeyed)
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further." Recorded verbatim; not acted upon.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-changelog]] · [[mcp-spec-deprecated]]
