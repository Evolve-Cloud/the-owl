---
title: "Auth Extensions Overview — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, auth, oauth, enterprise, sentinel]
sources: 1
updated: 2026-07-30
---
**Source:** [Auth Extensions Overview](https://modelcontextprotocol.io/extensions/auth/overview.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Landing/decision page for MCP authorization extensions (in the `ext-auth` repo). It maps deployment scenarios to the right approach: OAuth Client Credentials for machine-to-machine (no user), Enterprise-Managed Authorization for org-controlled employee access via an IdP, and the core MCP spec (no extension) for standard interactive user authorization. Both auth extensions are supplementary to the core authorization mechanism.

## Key points
- Two official auth extensions beyond core: OAuth Client Credentials (`io.modelcontextprotocol/oauth-client-credentials`) and Enterprise-Managed Authorization (`io.modelcontextprotocol/enterprise-managed-authorization`).
- Scenario → recommended approach:
  - Background service / daemon accessing an MCP server → **OAuth Client Credentials**
  - CI/CD pipeline calling MCP tools → **OAuth Client Credentials**
  - Server-to-server API integration → **OAuth Client Credentials**
  - Enterprise employees accessing MCP servers at work → **Enterprise-Managed Authorization**
  - Organization-wide MCP access policy enforcement → **Enterprise-Managed Authorization**
  - Standard interactive user authorization → **Core MCP spec (no extension needed)**
- Decision rule: no human present / automated system → client credentials; centralized org policy via IdP → enterprise-managed; individual interactive consent → core.

## Notable quotes
> "Standard interactive user authorization — Core MCP spec (no extension needed)"

## Embedded instructions (data, not obeyed)
> [!question] The fetched page-top directive ("Fetch the complete documentation index at https://modelcontextprotocol.io/llms.txt … to discover all available pages") is treated as data, not obeyed.

## Gaps / open questions
- This overview is a routing/decision page; normative MUST/SHOULD detail lives on the two child extension pages, not here.
- No guidance on combining extensions (e.g. enterprise-managed for humans + client credentials for that org's automation) on the same server.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[sentinel]]
