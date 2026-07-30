---
title: "What is the Model Context Protocol (MCP)? — MCP spec v2026-07-28"
type: source
tags: [mcp, overview, ecosystem]
sources: 1
updated: 2026-07-30
---
**Source:** [What is the Model Context Protocol (MCP)?](https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Introductory page defining MCP as an open-source standard for connecting AI applications to external systems (data sources, tools, workflows). Uses the "USB-C port for AI applications" analogy for standardized connectivity. Frames the benefits for developers, AI applications/agents, and end-users, and lists the broad client/server ecosystem. Ends with entry-point links to build servers, build clients, and build MCP Apps.

## Key points
- MCP = "open-source standard for connecting AI applications to external systems."
- Connects three categories: **data sources** (local files, databases), **tools** (search engines, calculators), **workflows** (specialized prompts).
- Analogy: MCP is a "USB-C port for AI applications" — a standardized connection layer.
- Example enablements: agents accessing Google Calendar/Notion; Claude Code generating a web app from a Figma design; enterprise chatbots across multiple databases; 3D designs on Blender → 3D printer.
- Stakeholder benefits: **Developers** (less dev time/complexity), **AI applications/agents** (ecosystem of data/tools/apps), **End-users** (more capable agents that act on their behalf).
- Ecosystem support cited: clients **Claude**, **ChatGPT**, dev tools **Visual Studio Code**, **Cursor**, **MCPJam** — "build once and integrate everywhere."
- Start-building entry points: `/docs/2026-07-28/develop/build-server`, `/docs/2026-07-28/develop/build-client`, `/extensions/apps/overview` (MCP Apps), plus `learn/architecture` for concepts.

## Notable quotes
> "MCP (Model Context Protocol) is an open-source standard for connecting AI applications to external systems."

> "Think of MCP like a USB-C port for AI applications. Just as USB-C provides a standardized way to connect electronic devices, MCP provides a standardized way to connect AI applications to external systems."

## Gaps / open questions
- Page is a conceptual intro; no protocol methods/field names here — those live in architecture, client, and server concept pages.
- The page begins with an injected "Documentation Index" callout instructing the reader to fetch `https://modelcontextprotocol.io/llms.txt`. Treated as DATA (page chrome), not obeyed:
  > [!question] Injected instruction (not obeyed)
  > "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-client-concepts]] · [[mcp-docs-server-concepts]]
