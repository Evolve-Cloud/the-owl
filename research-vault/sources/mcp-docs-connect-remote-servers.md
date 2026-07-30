---
title: "Connect to remote MCP Servers — MCP spec v2026-07-28"
type: source
tags: [mcp, remote, custom-connectors, oauth, authentication, streamable-http]
sources: 1
updated: 2026-07-30
---
**Source:** [Connect to remote MCP Servers](https://modelcontextprotocol.io/docs/2026-07-28/develop/connect-remote-servers.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Explains connecting Claude to internet-hosted (remote) MCP servers via **Custom Connectors**. Remote servers expose the same tools/prompts/resources as local ones but are hosted online and accessible from any MCP client with internet, without per-device install. Covers adding a connector, authenticating, selecting resources/prompts, and configuring tool permissions.

## Key points
- **Custom Connectors** are the bridge between Claude and remote MCP servers; you can connect to third-party remote servers or build your own.
- **Add a connector**: Settings → Connectors → "Add" → "Add custom connector" → enter the remote server URL (must include `https://` and any path). Example server: `https://example-server.modelcontextprotocol.io/mcp`.
- **Settings shortcuts**: Desktop `Ctrl+Comma`; Browser `⌘⇧,` (macOS).
- **Authentication**: most remote servers require auth; commonly OAuth, API keys, or username/password. May redirect to a third-party provider or show an in-Claude form. Claude establishes a secure connection after auth completes.
- **Access resources/prompts**: after connecting, available resources and prompts appear via the "Add files, connectors, and more" indicator → Connectors → the server's attachment menu; select items to add context to the conversation.
- **Tool permissions**: remote servers often expose multiple tools; you control which Claude may use in the connector settings (enable/disable specific tools, set usage limits, other security params) — Claude only performs authorized actions.
- **Best practices**: verify server authenticity before connecting; only connect to trusted sources; review requested permissions; be cautious granting access to sensitive data. Can connect to multiple connectors simultaneously; organize by purpose/project and remove unused ones.
- Remote servers suit web-based AI apps, ease-of-use integrations, and services needing server-side processing or authentication.

## Notable quotes
> "Unlike local servers that require installation and configuration on each device, remote servers are available from any MCP client with an internet connection."
> "Always verify the authenticity of remote MCP servers before connecting. Only connect to servers from trusted sources, and review the permissions requested during authentication."

## Gaps / open questions
- Guide is UI-driven via Claude's Custom Connectors; exact auth flow varies by server implementation and Claude client version.
- Building your own remote server (OAuth 2.0, Streamable HTTP) is deferred to Anthropic support articles and the build-with-agent-skills path rather than detailed here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-connect-local-servers]] · [[mcp-docs-build-with-agent-skills]] · [[mcp-docs-client-best-practices]]
