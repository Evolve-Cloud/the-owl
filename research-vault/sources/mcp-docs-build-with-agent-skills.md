---
title: "Build with Agent Skills — MCP spec v2026-07-28"
type: source
tags: [mcp, agent-skills, scaffolding, deployment, mcpb]
sources: 1
updated: 2026-07-30
---
**Source:** [Build with Agent Skills](https://modelcontextprotocol.io/docs/2026-07-28/develop/build-with-agent-skills.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Describes using Agent Skills — portable instruction sets that give AI coding assistants domain knowledge — to design and scaffold MCP servers. A reference `mcp-server-dev` plugin provides three composing skills that interrogate a use case, pick a deployment model and tool-design pattern, and generate a fitting server.

## Key points
- **Three composing skills** in the `mcp-server-dev` plugin:
  - `build-mcp-server` — entry point; interrogates the use case, picks deployment model + tool-design pattern, routes to specialized skills.
  - `build-mcp-app` — adds interactive UI widgets (forms, pickers, dashboards) rendered inline in chat.
  - `build-mcpb` — packages a local stdio server with its runtime so users install without Node or Python.
- Each skill ships a `SKILL.md` plus a `references/` folder (auth flows, tool-design patterns, widget templates, manifest schemas), read on demand; open format, works with any standard-compliant agent.
- **Install in Claude Code**: `/plugin marketplace add anthropics/claude-plugins-official` then `/plugin install mcp-server-dev`.
- **Discovery phase** (before writing code) asks about: what it connects to (cloud API / local process / filesystem / hardware); who uses it; action-surface size; user interaction needs (plain text, elicitation, or rich widgets); upstream auth (API keys, OAuth 2.0, none).
- **Four deployment paths**:
  - **Remote Streamable HTTP** — default for cloud-API wrappers; zero install, one deployment for all users, OAuth works (server handles redirects + token storage). Scaffolds for Cloudflare Workers and Express/FastMCP.
  - **MCP apps** — interactive widgets in chat; hands off to `build-mcp-app` when elicitation's flat-form constraints don't fit.
  - **MCP Bundles (MCPB)** — `.mcpb` archive bundling a local server + runtime; for servers that touch the user's machine (local files, desktop apps, localhost). Hands off to `build-mcpb`.
  - **Local stdio** — for prototyping, with a noted upgrade path to MCPB for distribution.
- Combined with progressive discovery: a skill file can declare which MCP servers it needs, and the host connects them only when the skill is invoked.

## Notable quotes
> "Agent skills are portable instruction sets that give AI coding assistants domain knowledge for a task."
> "Remote Streamable HTTP is the default for anything wrapping a cloud API. Zero install friction, one deployment serves all users, and OAuth flows work properly because the server can handle redirects and token storage."

## Gaps / open questions
- The skill set is a reference implementation (Anthropic `claude-plugins-official`); exact behavior depends on the agent's skill-invocation syntax and catalog. Non-Claude agents must clone `SKILL.md` + `references/` into their skills location.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[anthropic-agent-skills]] · [[mcp-docs-build-server]] · [[mcp-docs-client-best-practices]]
