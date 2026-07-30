---
title: "Extensions Client Matrix — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, client-support, apps, auth]
sources: 1
updated: 2026-07-30
---
**Source:** [Extensions Client Matrix](https://modelcontextprotocol.io/extensions/client-matrix.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
A reference matrix listing which MCP clients support which extensions, plus a scenario→extension recommendation guide. Extensions covered: MCP Apps (`io.modelcontextprotocol/ui`), OAuth Client Credentials (`io.modelcontextprotocol/oauth-client-credentials`), and Enterprise-Managed Authorization (`io.modelcontextprotocol/enterprise-managed-authorization`). Support is opt-in and varies per client.

## Key points
- Extension identifiers catalogued: `io.modelcontextprotocol/ui` (interactive HTML inline in conversation), `io.modelcontextprotocol/oauth-client-credentials` (machine-to-machine auth without interactive login), `io.modelcontextprotocol/enterprise-managed-authorization` (centralized access control via enterprise IdP).
- Clients appearing in the matrix (MCP Apps support marked): Claude (web), Claude Desktop, VS Code GitHub Copilot, Microsoft 365 Copilot, Goose, Postman, MCPJam, ChatGPT, Cursor, Archestra.AI, PostHog Code.
- Scenario → recommended extension guidance:
  - Background service/daemon → OAuth Client Credentials
  - CI/CD pipeline calling MCP tools → OAuth Client Credentials
  - Server-to-server API integration → OAuth Client Credentials
  - Enterprise employees accessing MCP at work → Enterprise-Managed Authorization
  - Org-wide MCP access policy enforcement → Enterprise-Managed Authorization
  - Standard interactive user authorization → Core MCP spec (no extension needed)

## Notable quotes
> "Standard interactive user authorization — Core MCP spec (no extension needed)"

## Gaps / open questions
- The fetched render returned rows primarily for the MCP Apps column; per-client Tasks and per-auth-extension support cells were not fully captured in this snapshot.
- Exact date/version of the matrix and update cadence not stated.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]]
