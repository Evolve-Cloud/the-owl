---
title: "Build an MCP client — MCP spec v2026-07-28"
type: source
tags: [mcp, client, tools, stdio, sdk]
sources: 1
updated: 2026-07-30
---
**Source:** [Build an MCP client](https://modelcontextprotocol.io/docs/2026-07-28/develop/build-client.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Tutorial for building an LLM-powered chatbot client that connects to MCP servers over stdio and bridges tool calls to the Anthropic Messages API. Walks through client init, server-subprocess launch, tool listing, query processing with tool-use loops, and cleanup, across Python, TypeScript, Java (Spring AI), Kotlin, C#, and Ruby.

## Key points
- **Python SDK**: requires **Python MCP SDK 2.0.0+**. Core object is `Client` (`from mcp import Client, StdioServerParameters`; `from mcp.client.stdio import stdio_client`). Connection lifecycle is a single `async with Client(stdio_client(server_params(...))) as client:` — entering launches the server and negotiates protocol version; leaving disconnects and shuts down the subprocess. No manual connect/close.
- **Client methods**: `await client.list_tools()` → `.tools` (each has `.name`, `.description`, `.input_schema`); `await client.call_tool(tool_name, tool_args)` → `CallToolResult` whose `.content` is a list of blocks (narrow to `TextContent` before reading `.text`) and carries `.is_error`.
- **Error semantics**: a failing tool does NOT raise in `call_tool`; it returns with `is_error` set. Clients should check `result.is_error` and pass the flag to Claude so it can self-correct. Raise `read_timeout_seconds` on the `Client` for timeouts.
- **Tool-call loop**: list tools → send query + tool descriptions to Claude → for each `tool_use` content block, call the tool, append `tool_result` (with `tool_use_id`) → send back to Claude for a natural-language response.
- **TypeScript**: `@modelcontextprotocol/client`, `Client`, `StdioClientTransport`, `this.mcp.connect(transport)`, `this.mcp.listTools()`, `this.mcp.callTool({name, arguments})`, `this.mcp.close()`. Node.js 20+.
- **C#**: `McpClient.CreateAsync(clientTransport)`, `StdioClientTransport`, `mcpClient.ListToolsAsync()`; uses `Microsoft.Extensions.AI` `IChatClient` with automatic function invocation.
- **Model** used across examples: `claude-opus-5`.
- **Tool-name validation**: names follow the format in the spec (`/specification/2026-07-28/server/tools#tool-names`); a conforming name should not fail client-side validation.
- **Security best practices**: store API keys in `.env` (gitignored), validate server responses, be cautious with tool permissions.

## Notable quotes
> "That `async with` is the entire connection lifecycle. Entering it launches the server and agrees a protocol version with it; leaving it disconnects and shuts the subprocess down. There is nothing to close by hand."
> "A tool that raises does not raise here: it answers with `is_error` set, and passing that flag on lets Claude read the message and try something else."

## Gaps / open questions
- Version-dependent: Python MCP SDK **2.0.0+** required; import surface (`from mcp import Client`) is that major version. TS package `@modelcontextprotocol/client`. These differ from pre-2.0 client APIs.
- First response may take up to ~30s (server init + Claude + tool execution) — normal, not a bug.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-build-server]] · [[mcp-docs-client-best-practices]] · [[mcp-docs-connect-remote-servers]]
