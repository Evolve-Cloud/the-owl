---
title: "Connect to local MCP servers — MCP spec v2026-07-28"
type: source
tags: [mcp, local, stdio, claude-desktop, filesystem, configuration]
sources: 1
updated: 2026-07-30
---
**Source:** [Connect to local MCP servers](https://modelcontextprotocol.io/docs/2026-07-28/develop/connect-local-servers.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Walks through connecting Claude Desktop to a local MCP server, using the Filesystem Server as the example, to give Claude controlled access to local files (read, create, move/rename, search) with per-action user approval. Configuration is via a JSON file that tells Claude Desktop which servers to auto-launch and how.

## Key points
- **Prerequisites**: Claude Desktop (macOS/Windows; not Linux), Node.js (LTS) for the Filesystem Server and many npx-based servers.
- **Config file location**: macOS `~/Library/Application Support/Claude/claude_desktop_config.json`; Windows `%APPDATA%\Claude\claude_desktop_config.json`. Opened via Settings → Developer tab → "Edit Config".
- **Config shape**: `mcpServers` object; each entry has a friendly name, `command` (e.g. `npx`), and `args`. Filesystem example: `"command": "npx"`, args `["-y", "@modelcontextprotocol/server-filesystem", "/Users/username/Desktop", "/Users/username/Downloads"]`. Trailing args are the directories the server may access. `-y` auto-confirms package install.
- **Restart required**: fully quit and reopen Claude Desktop after saving. Connected server tools appear via the "Add files, connectors, and more" indicator → Connectors → Manage connectors.
- **Security**: server runs with the user's account permissions and can do any file op the user can; only grant directories you're comfortable with. Every action requires explicit user approval before execution.
- **Logs**: macOS `~/Library/Logs/Claude`, Windows `%APPDATA%\Claude\logs`. `mcp.log` = general MCP connection logging; `mcp-server-SERVERNAME.log` = that server's stderr (stdio servers may log all output to stderr). Tail example: `tail -n 20 -f ~/Library/Logs/Claude/mcp*.log`.
- **Troubleshooting**: server-not-showing → restart, check JSON syntax, ensure paths are absolute (not relative), inspect logs, run the server manually. Windows `${APPDATA}` ENOENT error → add expanded `APPDATA` to the server's `env` key; npm must be installed globally (`%APPDATA%\npm` present) for `npx` to work.

## Notable quotes
> "All actions require your explicit approval before execution, ensuring you maintain full control over what Claude can access and modify."
> "The server runs with your user account permissions, so it can perform any file operations you can perform manually."

## Gaps / open questions
- Claude Desktop is not available on Linux — local-server connection via Desktop is macOS/Windows only.
- Guide is UI-driven (Claude Desktop menus/screenshots); exact labels may drift between Desktop versions.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-build-server]] · [[mcp-docs-connect-remote-servers]] · [[claude-code-sandboxing]]
