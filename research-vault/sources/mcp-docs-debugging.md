---
title: "Debugging — MCP spec v2026-07-28"
type: source
tags: [mcp, tooling, debugging, logging, observability, otel]
sources: 1
updated: 2026-07-30
---
**Source:** [Debugging](https://modelcontextprotocol.io/docs/2026-07-28/tools/debugging.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Guide to debugging MCP integrations across three levels: the MCP Inspector (first stop), server-side logging (stderr for stdio, OpenTelemetry for all transports), and client developer tools. Covers common issues (working directory, env vars, startup, connection/protocol-negotiation errors), Claude Desktop specifics (log locations, Chrome DevTools), a development-cycle workflow, and best practices including a short security-considerations section on log hygiene.

## Key points
- **Three debugging levels**: (1) MCP Inspector — interactive transport-agnostic UI, first stop; (2) Server logging — structured logs to stderr (stdio) or via OpenTelemetry (all transports); (3) Client developer tools.
- **Protocol logging deprecation**: over-the-protocol logging via `notifications/message` is **deprecated as of protocol version 2026-07-28** (still available during the deprecation window).
- **stdio stderr**: all messages to stderr are captured by the host; **servers must NOT log to stdout** (interferes with protocol operation). For Streamable HTTP, stderr is NOT captured by the client — use OTel/log aggregation + curl/DevTools Network panel.
- **Log levels**: eight RFC 5424 severity levels (`debug` through `emergency`). Clients opt in per request via `io.modelcontextprotocol/logLevel` in the request `_meta`; servers must not send `notifications/message` for requests that omit this field.
- **Important events to log**: startup steps, resource access, tool execution, error conditions, performance metrics.
- **Working directory**: may be undefined (`/` on macOS) for client-launched stdio servers — always use absolute paths in config and `.env`.
- **Env vars**: stdio servers inherit only a limited platform-dependent subset; override via `env` key in `claude_desktop_config.json`.
- **Connection/protocol debugging**: call `server/discover` to see supported protocol versions; `UnsupportedProtocolVersionError` (`-32022`) lists supported versions in `data`. Every request must carry `io.modelcontextprotocol/protocolVersion` and `io.modelcontextprotocol/clientCapabilities` (and should include `clientInfo`); missing required field → `-32602` (Invalid params); missing declared capability (e.g. elicitation) → `MissingRequiredClientCapabilityError` (`-32021`).
- **Claude Desktop**: logs at `~/Library/Logs/Claude` (macOS) / `%APPDATA%\Claude\logs` (Windows); `tail -F .../mcp*.log`. Chrome DevTools via `developer_settings.json` `{"allowDevTools": true}`, then Cmd-Opt-I / Ctrl-Alt-I.
- **Testing changes**: config change → restart client; server code change → fully quit & reopen client (closing window insufficient for Claude Desktop); quick iteration → Inspector.

## Security requirements (security pages only)
Not a primary security page — no MUST/SHOULD. It includes a **Security considerations** subsection under best practices:
- **Sensitive Data**: sanitize logs, protect credentials, mask personal information.
- **Access Control**: verify permissions, check authentication, monitor access patterns.
- Directs readers to [[mcp-docs-security-best-practices]] for the full treatment of attack vectors and mitigations.

## Notable quotes
> "Local MCP servers should not log messages to stdout (standard out), as this will interfere with protocol operation."

> "The `notifications/message` mechanism ... is deprecated as of protocol version `2026-07-28`. It remains available during the deprecation window."

> [!question] Untrusted content directed at the pipeline (NOT obeyed)
> The fetched page was prefixed with injected boilerplate instructing the agent to "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt ... to discover all available pages before exploring further." Per NFR-SEC-2, treated as data, NOT acted upon.

## Gaps / open questions
- OpenTelemetry is named as the recommended cross-transport logging mechanism but the page gives no wiring/config detail (deferred to OTel docs).
- The deprecation window for `notifications/message` has no stated end date.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-inspector]] · [[mcp-docs-security-best-practices]] · [[observability]]
