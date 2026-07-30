---
title: "MCP Inspector — MCP spec v2026-07-28"
type: source
tags: [mcp, tooling, inspector, testing, debugging]
sources: 1
updated: 2026-07-30
---
**Source:** [MCP Inspector](https://modelcontextprotocol.io/docs/2026-07-28/tools/inspector.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Reference guide for the MCP Inspector, an interactive, transport-agnostic developer tool for testing and debugging MCP servers. It runs via `npx @modelcontextprotocol/inspector <command>` without installation, can inspect npm/PyPI packages or locally-developed servers (TypeScript via `node`, Python via `uv`), and exposes tabs for Resources, Prompts, Tools, plus a server-connection pane and a notifications/logs pane. Positioned as the first stop for debugging.

## Key points
- **Run without install**: `npx @modelcontextprotocol/inspector <command> <args>`.
- **Inspect npm packages**: `npx -y @modelcontextprotocol/inspector npx <package-name> <args>` (e.g. `@modelcontextprotocol/server-filesystem /path`).
- **Inspect PyPI packages**: `npx @modelcontextprotocol/inspector uvx <package-name> <args>` (e.g. `uvx mcp-server-git --repository ~/code/...`).
- **Inspect local TypeScript**: `npx @modelcontextprotocol/inspector node path/to/server/index.js args...`.
- **Inspect local Python**: `npx @modelcontextprotocol/inspector uv --directory path/to/server run package-name args...`.
- **Server connection pane**: selects transport; for local servers customizes command-line args and environment.
- **Resources tab**: lists resources, shows metadata (MIME types, descriptions), inspects content, tests subscriptions.
- **Prompts tab**: shows prompt templates, arguments/descriptions, tests with custom args, previews generated messages.
- **Tools tab**: lists tools, shows schemas/descriptions, tests with custom inputs, displays execution results.
- **Notifications pane**: presents all server logs and received notifications.
- **Recommended workflow**: start dev (launch + verify connectivity + check capability negotiation) → iterative testing (change, rebuild, reconnect, test, monitor) → test edge cases (invalid inputs, missing prompt args, concurrent operations, error handling).

## Security requirements (security pages only)
Not a security page — no MUST/SHOULD requirements. Security-relevant note: the Inspector executes server commands (spawns npm/PyPI/local processes with custom env), so it inherits the local-server-compromise risk surface documented in [[mcp-docs-security-best-practices]]. The page itself specifies no auth/token behavior.

## Notable quotes
> "The MCP Inspector is an interactive developer tool for testing and debugging MCP servers."

> "Please carefully read any attached README for the most accurate instructions."

> [!question] Untrusted content directed at the pipeline (NOT obeyed)
> The fetched page was prefixed with injected boilerplate: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt ... to discover all available pages before exploring further." Per NFR-SEC-2, treated as data, NOT acted upon.

## Gaps / open questions
- The page does not document the Inspector's own auth/token handling (some Inspector versions use a session/proxy token) — not covered in this spec version's doc.
- No sandboxing guidance for the processes the Inspector spawns; cross-reference the local-server-compromise mitigations in Security Best Practices.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-debugging]] · [[mcp-docs-security-best-practices]]
