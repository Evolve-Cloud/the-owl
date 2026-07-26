---
title: "Anthropic — Desktop Extensions: One-Click MCP Server Installation for Claude Desktop"
type: source
tags: [mcp, desktop-extensions, distribution, claude-desktop, packaging]
sources: 1
updated: 2026-07-26
---
**Source:** [Desktop Extensions: One-click MCP server installation for Claude Desktop](https://www.anthropic.com/engineering/desktop-extensions) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Anthropic  ·  **Published:** 2025-06-26  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Desktop Extensions solve the MCP installation barrier for non-technical users by bundling entire MCP servers with all dependencies into single `.mcpb` files. The format is a ZIP archive with a declarative `manifest.json`; Claude Desktop handles runtime complexity. The MCPB spec is open-sourced to enable other AI applications to support the same format.

## Key points
- Previous MCP installation required Node.js/Python, manual JSON editing, dependency resolution — too complex for non-developers.
- `.mcpb` files are ZIP archives: manifest.json + server files + bundled dependencies + optional icons.
- Node.js ships with Claude Desktop; sensitive data stores in OS keychains; automatic updates; enterprise Group Policy/MDM support.
- `@anthropic-ai/mcpb` package provides `init` and `pack` commands for creating extensions from existing MCP servers.
- Open ecosystem: MCPB specification v0.1 open-sourced for other AI applications.
- Enterprise: pre-install approved extensions, disable directories, deploy private repositories via group policies.

## Informs (ideas / patterns)
- [[mcp]] — extension packaging format; distribution model; enterprise governance; MCPB v0.1 specification.

## Notable quotes
> "Desktop Extensions solve these problems by bundling an entire MCP server—including all dependencies—into a single installable package."
> "Package once, run anywhere that supports MCPB."

## Gaps / open questions
- How does the extension model handle security auditing of bundled dependencies?
- What's the update and revocation mechanism for extensions that turn out to be malicious?

## Related
- [[mcp]] · [[agent-skills]] · [[code-execution-mcp]]
