---
title: "Build an MCP server — MCP spec v2026-07-28"
type: source
tags: [mcp, server, tools, stdio, sdk]
sources: 1
updated: 2026-07-30
---
**Source:** [Build an MCP server](https://modelcontextprotocol.io/docs/2026-07-28/develop/build-server.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Step-by-step tutorial for building a weather MCP server exposing two tools (`get_alerts`, `get_forecast`) and connecting it to Claude for Desktop as the host. Covers server setup, tool registration, transport, and per-language logging pitfalls across Python, TypeScript, Java (Spring AI), Kotlin, C#, and Ruby. MCP servers can provide three capability types: Resources, Tools, and Prompts; the tutorial focuses on Tools.

## Key points
- **Three capability types**: Resources (file-like readable data), Tools (LLM-callable functions, with user approval), Prompts (reusable templates).
- **Python SDK**: requires **Python MCP SDK 2.0.0+** and Python 3.10+. Uses `from mcp.server import MCPServer`; instantiate `mcp = MCPServer("weather")`; decorate tools with `@mcp.tool()`; run with `mcp.run(transport="stdio")`. Type hints + docstrings auto-generate tool definitions. HTTP client dependency is `httpx2` (pulled in by `mcp`). Install via `uv add "mcp[cli]"`.
- **TypeScript SDK**: uses `@modelcontextprotocol/server`, `McpServer`, `StdioServerTransport`, `server.registerTool(name, {description, inputSchema}, handler)` with `zod` schemas. Node.js 20+. Tool returns `{ content: [{ type: "text", text }] }`.
- **STDIO logging rule (critical)**: Never write to stdout in STDIO servers — it corrupts JSON-RPC. Avoid `print()` (Python), `console.log()` (TS → use `console.error()`), `System.out.println()` (Java), `println()` (Kotlin), `Console.WriteLine()` (C#), `puts`/`print` (Ruby). Use stderr / a logging library. HTTP servers: stdout logging is fine.
- **Java (Spring AI)**: `@Tool`/`@ToolParam` annotations, `MethodToolCallbackProvider`, `spring-ai-starter-mcp-server`. Set `spring.ai.mcp.server.protocol=STREAMABLE` for Streamable HTTP.
- **Kotlin SDK**: `Server(Implementation(...), ServerOptions(capabilities = ServerCapabilities(tools = ...listChanged=true)))`, `server.addTool(name, description, inputSchema = ToolSchema(...))`, `StdioServerTransport`.
- **C#**: `AddMcpServer().WithStdioServerTransport().WithToolsFromAssembly()`; use `CreateEmptyApplicationBuilder` (not `CreateDefaultBuilder`) for STDIO to avoid console writes; `[McpServerToolType]`/`[McpServerTool]` attributes.
- **Host config**: Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) under the `mcpServers` key; each server specifies `command` + `args`. Absolute paths required. Restart Claude Desktop to load.
- Data source in examples is the National Weather Service API (`https://api.weather.gov`).

## Notable quotes
> "Writing to stdout will corrupt the JSON-RPC messages and break your server."
> "The MCPServer class uses Python type hints and docstrings to automatically generate tool definitions, making it easy to create and maintain MCP tools."
> "The MCP UI elements will only show up in Claude for Desktop if at least one server is properly configured."

## Gaps / open questions
- SDK APIs are version-dependent: Python requires MCP SDK **2.0.0+**; the import surface (`MCPServer`, `httpx2`) reflects that major version and differs from older SDKs. TypeScript package is `@modelcontextprotocol/server`, Kotlin SDK `0.9.0`.
- Claude for Desktop not available on Linux; Linux users must use the build-client path instead.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-build-client]] · [[mcp-docs-connect-local-servers]] · [[mcp-docs-build-with-agent-skills]]
