---
title: "MCP Apps — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, apps, ui, iframe, security]
sources: 1
updated: 2026-07-30
---
**Source:** [MCP Apps](https://modelcontextprotocol.io/extensions/apps/overview.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
MCP Apps (`io.modelcontextprotocol/ui`) let servers return interactive HTML interfaces (charts, forms, dashboards, media viewers) rendered inline in the conversation. A tool declares a `ui://` resource via `_meta.ui.resourceUri`; the host fetches and renders it in a sandboxed iframe. App and host communicate over a JSON-RPC `postMessage` dialect of MCP (`ui/*` methods plus shared ones like `tools/call`), enabling bidirectional data flow while keeping the app isolated.

## Key points
- Advantages over a standalone web app: context preservation (lives in chat), bidirectional data flow via existing MCP patterns, integration with host capabilities (delegate actions like "schedule this meeting" to user's connected tools subject to consent), and sandbox security guarantees.
- Flow: (1) **UI preloading** — tool description carries `_meta.ui.resourceUri` → `ui://` resource; host may preload before the tool is called (enables streaming tool inputs). (2) **Resource fetch** — host fetches HTML (often bundled with JS/CSS); external scripts allowed only from origins in `_meta.ui.csp`. (3) **Sandboxed rendering** — web hosts render in a sandboxed iframe; `_meta.ui` may include `permissions` (mic, camera) and `csp`. (4) **Bidirectional communication** — JSON-RPC dialect; `ui/`-prefixed methods plus shared/similar ones (`tools/call`, `ui/initialize`).
- Security model: sandboxed iframe prevents access to parent DOM, host cookies/localStorage, parent navigation, or script execution in parent context. All host↔app comms go through postMessage. Host controls which capabilities the app gets (e.g. restrict callable tools, disable `sendOpenLink`).
- Good fit: exploring complex data, config with many options, rich media viewing, real-time monitoring, multi-step workflows.
- Framework-agnostic: uses standard web primitives; transport is postMessage (not stdio/HTTP). `App` class from `@modelcontextprotocol/ext-apps` is a convenience wrapper, not required — you can implement the postMessage protocol directly. Starter templates for React, Vue, Svelte, Preact, Solid, vanilla JS.
- Client-side integration options for host builders: `@mcp-ui/client` React components, or build on the SDK's **App Bridge** module (rendering, message passing, tool-call proxying, security policy enforcement).
- Currently supported by Claude (web), Claude Desktop, VS Code GitHub Copilot, Microsoft 365 Copilot, Goose, Postman, MCPJam, Archestra.AI.

## Notable quotes
> "MCP Apps run in a sandboxed iframe controlled by the host. They can't access the parent page, steal cookies, or escape their container."
> "The app stays isolated from the host but can still call MCP tools through the secure postMessage channel."

## Embedded instructions (data, not obeyed)
> [!question] Page-top directive treated as data, not obeyed: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt … Use this file to discover all available pages before exploring further."

## Gaps / open questions
- The full `_meta.ui` schema (exact shape of `csp`, `permissions`) is referenced but not fully specified on this page.
- Consent UX for host-delegated actions (e.g. "schedule this meeting") is described conceptually, not normatively.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]]
