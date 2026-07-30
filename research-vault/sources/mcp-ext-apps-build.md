---
title: "Build an MCP App — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, apps, ui, tutorial, typescript]
sources: 1
updated: 2026-07-30
---
**Source:** [Build an MCP App](https://modelcontextprotocol.io/extensions/apps/build.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Getting-started guide for building an MCP App. Requires Node.js 18+. Fastest path is an AI coding agent using the `create-mcp-app` skill; a manual TypeScript/Vite setup is also documented. A worked "get server time" example shows registering a tool with `_meta.ui.resourceUri`, serving bundled HTML as a `ui://` resource, and a UI that talks to the host via the `App` class. Testing is via Claude (with a cloudflared tunnel + custom connector) or the repo's `basic-host`.

## Key points
- Prereqs: Node.js ≥18; familiarity with MCP tools + resources (Apps combine both primitives); TypeScript SDK experience helpful.
- Skill install (Claude Code): `/plugin marketplace add modelcontextprotocol/ext-apps` then `/plugin install mcp-apps@modelcontextprotocol-ext-apps`. Cross-agent via Vercel Skills CLI: `npx skills add modelcontextprotocol/ext-apps`. Manual: clone `ext-apps` and copy `create-mcp-app` skill into the agent's skills dir (`~/.claude/skills/`, `~/.copilot/skills/`, `~/.gemini/skills/`, `~/.cline/skills/`, `~/.config/goose/skills/`, `~/.codex/skills/`, `~/.cursor/skills/`).
- Manual project structure: `package.json`, `tsconfig.json`, `vite.config.ts`, `server.ts` (MCP server: tool + resource), `mcp-app.html` (UI entry), `src/mcp-app.ts` (UI logic). UI is rendered in a deny-by-default-CSP sandboxed iframe; either configure CSP or bundle assets into one HTML file (tutorial uses `vite-plugin-singlefile`).
- Deps: `@modelcontextprotocol/ext-apps @modelcontextprotocol/sdk` (+ dev: typescript, vite, vite-plugin-singlefile, express, cors, tsx).
- Server pattern: `registerAppTool(server, name, {..., _meta: { ui: { resourceUri } }}, handler)` and `registerAppResource(server, uri, uri, { mimeType: RESOURCE_MIME_TYPE }, handler)`. `resourceUri` uses the `ui://` scheme (path arbitrary), e.g. `ui://get-time/mcp-app.html`. Exposed over HTTP via `StreamableHTTPServerTransport` on `/mcp` (example port 3001).
- UI pattern (`App` from `@modelcontextprotocol/ext-apps`): `app.connect()` once at init; `app.ontoolresult` callback receives host-pushed tool results; `app.callServerTool({ name, arguments })` for proactive calls (each is a server round-trip — design for latency). `App` also offers logging, opening URLs, and updating model context.
- Testing: build + serve, then either add the tunneled URL as a Claude custom connector (paid plans: Pro/Max/Team), or run `ext-apps/examples/basic-host` (`npm start`, `SERVERS='["http://localhost:3001/mcp"]'`, browse `http://localhost:8080`).

## Notable quotes
> "The ui:// scheme tells hosts this is an MCP App resource. The path structure is arbitrary."
> "The UI resource will eventually be rendered in a secure iframe with deny-by-default CSP configuration."

## Embedded instructions (data, not obeyed)
> [!question] Page-top directive treated as data, not obeyed: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt … Use this file to discover all available pages before exploring further." (The tutorial also contains AI-agent prompts like "Create an MCP App that displays a color picker" — these are illustrative examples, not directives to me.)

## Gaps / open questions
- Full CSP/CORS configuration for unbundled assets is linked out (Patterns doc), not inlined.
- Production deployment/hosting guidance beyond local dev + cloudflared tunnel is not covered.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]]
