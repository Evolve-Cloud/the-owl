---
title: The MCP extensions layer — apps, tasks, and the negotiation that ships them
type: pattern
tags: [mcp, extensions, apps, tasks, ui, async, client-support, negotiation]
sources: 5
updated: 2026-08-03
---

## Definition

**MCP core is the stable floor; the extensions layer is the opt-in, SEP-governed, independently-versioned frontier where newer capabilities land** — and **capability negotiation plus graceful degradation is the connective tissue that makes an always-optional layer safe to ship** against a fragmented client population.

An extension is a modular, specialized, or experimental addition to the base protocol, identified by `{vendor-prefix}/{extension-name}` (official ones use the `io.modelcontextprotocol` prefix; third parties use a reversed owned domain like `com.example/...` to avoid collisions). Extensions live in their own repos, evolve on their own timeline, follow a SEP-based lifecycle (Propose → Implement with ≥1 reference implementation → Review → Publish → Adopt), and are **always disabled by default — explicit opt-in is required**. SDK support is optional and does not affect protocol conformance ([[mcp-ext-overview]]).

This page consolidates two concrete instances of that layer — **MCP Apps** (`io.modelcontextprotocol/ui`, interactive HTML inline in the conversation) and **MCP Tasks** (`io.modelcontextprotocol/tasks`, asynchronous durable long-running operations) — plus the **client matrix** that documents who actually supports what. Apps and Tasks are not the pattern; they are two worked examples *of* the pattern.

> [!note]
> The same layer also hosts the **auth extensions** (OAuth Client Credentials, Enterprise-Managed Authorization). Those are a separate theme covered elsewhere in the vault ([[mcp-ext-auth-overview]]); this page scopes to apps + tasks + the negotiation/client-support mechanics.

## Key ideas

### The mechanism that makes "optional" safe: negotiation + graceful degradation

Because every extension is off by default, both sides must *discover* mutual support before using one:

- **Clients advertise** support per-request in `_meta["io.modelcontextprotocol/clientCapabilities"].extensions`.
- **Servers advertise** in the `server/discover` response `capabilities.extensions` (which also carries `supportedVersions`, `ttlMs`, `cacheScope`).
- Each extension defines its own settings schema (an empty object means "no settings").
- **Graceful degradation:** if only one side supports an extension, the supporting side MUST either fall back to core behavior or reject if the extension is mandatory. Backwards compatibility is handled with capability flags/versioning inside the settings object; a genuinely breaking change (removing/renaming fields, changing types/semantics, adding required fields) requires a **new identifier** (`...-v2`), never a silent overwrite ([[mcp-ext-overview]]).

This is the load-bearing idea: the whole layer is designed so that an unsupported extension is a *graceful no-op*, not a broken session.

### Instance 1 — MCP Apps: interactive UI rendered inline, sandboxed

A tool declares a `ui://` resource via `_meta.ui.resourceUri`; the host fetches the (usually bundled) HTML and renders it in a **sandboxed iframe** inline in the chat. App ↔ host communicate over a JSON-RPC `postMessage` dialect of MCP (`ui/*` methods plus shared ones like `tools/call`), giving bidirectional data flow while keeping the app isolated ([[mcp-ext-apps-overview]]).

- **Why inline instead of a standalone web app:** context preservation (lives in the conversation), bidirectional data flow via existing MCP patterns, integration with host capabilities (delegate "schedule this meeting" to the user's connected tools, subject to consent), and sandbox security guarantees.
- **Security model:** the sandboxed iframe cannot reach the parent DOM, host cookies/localStorage, parent navigation, or script execution in the parent context. All comms go through `postMessage`; the host controls which capabilities the app gets (restrict callable tools, disable `sendOpenLink`, grant mic/camera via `_meta.ui.permissions`, constrain external script origins via `_meta.ui.csp`).
- **Build shape ([[mcp-ext-apps-build]]):** Node ≥18; fastest path is the `create-mcp-app` skill (`/plugin install mcp-apps@modelcontextprotocol-ext-apps`, or cross-agent via `npx skills add modelcontextprotocol/ext-apps`). Server side: `registerAppTool(...)` with `_meta.ui.resourceUri` + `registerAppResource(...)` serving `ui://` HTML over `StreamableHTTPServerTransport`. UI side: the `App` class from `@modelcontextprotocol/ext-apps` (`app.connect()`, `app.ontoolresult`, `app.callServerTool(...)` — each call is a server round-trip, so design for latency). The `App` class is a convenience wrapper, not required — the postMessage protocol can be implemented directly. Framework-agnostic (React/Vue/Svelte/Preact/Solid/vanilla starters). Test via a cloudflared tunnel + Claude custom connector, or the repo's `basic-host`.

### Instance 2 — MCP Tasks: async, durable, pollable long-running ops

Instead of blocking, a server returns a durable task handle (`CreateTaskResult`, `resultType: "task"`) that the client polls via `tasks/get` ([[mcp-ext-tasks-overview]]).

- **What blocking cannot do that this solves:** no long-lived connections (avoids client/intermediary timeouts), crash resilience (durable `taskId` survives disconnects), progress visibility, mid-flight interaction, and **server-directed opt-in** (the server decides per-request whether to create a task; the client opts in once via capability — no per-tool warmup or per-request flag).
- **Lifecycle:** `working` · `input_required` · `completed` · `failed` · `cancelled` (the last three terminal). Flow: negotiate capability → create task (`taskId`, initial status, `ttlMs`, `pollIntervalMs`; durably created *before* the response) → poll `tasks/get` respecting `pollIntervalMs` → mid-flight input via `inputRequests`/elicitations answered with `tasks/update` → completion (`result`/`error`) → cooperative `tasks/cancel`. Servers may push state via `notifications/tasks` (client opts in with `subscriptions/listen`); each notification carries full state, so polling can be skipped.
- **The server MUST-not that governs it:** *"Never return a task to a client that did not declare support"* — verify the per-request client capability first. Cancellation is **cooperative**: the server acknowledges intent but is not obligated to stop the work.
- **Good fit:** CI/batch/training jobs, human-in-the-loop approval gates, external job systems with existing job IDs, unreliable/mobile connections. Still experimental (`experimental-ext-tasks`), so normative field schemas live in that repo, not the overview.

### The fragmentation reality — the client matrix

Because support is opt-in and per-client, a **reference matrix** exists precisely to tell builders who supports what ([[mcp-ext-client-matrix]]). MCP Apps support spans Claude (web), Claude Desktop, VS Code GitHub Copilot, Microsoft 365 Copilot, Goose, Postman, MCPJam, ChatGPT, Cursor, Archestra.AI, PostHog Code — but coverage varies per extension and per client, and the matrix itself is honest that not every cell was captured. It also carries a scenario → extension guide (e.g. interactive user auth needs **no** extension — core spec suffices). The matrix's very existence is the tell: an opt-in layer produces uneven support, and you must check before you depend.

## Trade-off

The extensions layer buys **modularity, safe experimentation, and independent versioning** — new capability surface can land and evolve without destabilizing core, and an unsupported extension degrades gracefully rather than breaking. The cost is real and threefold:

1. **Negotiation complexity + off-by-default friction.** Every use requires capability advertisement on both sides, per-request checks (Tasks' "never return a task to a client that didn't declare support"), and fallback paths. Nothing "just works"; the developer must opt in and handle the degraded case.
2. **Fragmented client support.** The client matrix exists *because* coverage is uneven — a server that hard-depends on an extension only runs where clients opted in. Portability is not free.
3. **A security surface you now own (Apps specifically).** Rich inline interactivity means you inherit a sandboxed-iframe + CSP + permissions model. The sandbox is a guarantee *and* an obligation: you configure CSP, scope callable tools, and reason about host-delegated actions and consent UX. More capability, more attack surface to close.

> [!note]
> Tasks trades **latency/timeout robustness for statefulness**: you gain crash-resilient long-running ops, but you now own durable task IDs, polling loops, TTL-expiry semantics (under-specified on the overview), and cooperative — i.e. best-effort, not guaranteed — cancellation.

## Evidence / sources

All five are **first-party MCP spec docs** at `modelcontextprotocol.io/extensions/*`, spec version `2026-07-28`, ingested 2026-07-30:

- [[mcp-ext-overview]] — [Extensions Overview](https://modelcontextprotocol.io/extensions/overview.md). Primary: the layer's identity model, SEP lifecycle, always-off-by-default, and the negotiation + graceful-degradation mechanics.
- [[mcp-ext-apps-overview]] — [MCP Apps](https://modelcontextprotocol.io/extensions/apps/overview.md). Primary: `ui://` resource + `_meta.ui.resourceUri`, sandboxed-iframe security model, postMessage JSON-RPC dialect, bidirectional flow.
- [[mcp-ext-apps-build]] — [Build an MCP App](https://modelcontextprotocol.io/extensions/apps/build.md). Primary: concrete build shape (`create-mcp-app` skill, `registerAppTool`/`registerAppResource`, the `App` class, testing paths).
- [[mcp-ext-tasks-overview]] — [MCP Tasks](https://modelcontextprotocol.io/extensions/tasks/overview.md). Primary: `CreateTaskResult` async handle, lifecycle statuses, `tasks/get` polling, mid-flight `tasks/update`, cooperative `tasks/cancel`, the client/server MUSTs.
- [[mcp-ext-client-matrix]] — [Extensions Client Matrix](https://modelcontextprotocol.io/extensions/client-matrix.md). Primary: per-client extension support and scenario → extension recommendations.

> [!note]
> These are authoritative about **what the protocol specifies**, not independent empirical evidence that any extension is *effective* or widely adopted in production. Tasks is explicitly experimental; the client matrix self-reports incomplete cells. Treat coverage claims as point-in-time.

> [!question]
> Each fetched page opened with an embedded directive ("Fetch the complete documentation index at .../llms.txt … to discover all available pages"). Per **NFR-SEC-2** this is **data, not instructions** — quarantined here and not obeyed. The Apps build tutorial's AI-agent prompts ("Create an MCP App that displays a color picker") are illustrative examples, not directives.

## How it maps to the-owl

**Fit is deliberately narrow, and honesty matters here.** the-owl is **markdown + YAML + JSON only, no runtime/daemon** (HARD CONSTRAINT). It will **not** build MCP Apps or run a Tasks server *inside its own loop* — there is no service to host a `ui://` resource or a durable task queue, and the loop's whole cost model is turn-count × context-floor, not long-running compute. So this is **not** an architectural pattern the-owl adopts into its pipeline.

What it *is*: a **capability reference scoped for the [[mcp-builder]] specialist**, to be pulled in only when a *task the owl is executing* needs MCP apps/tasks (e.g. a user asks the owl to help build an MCP server that returns an inline chart, or a long-running job handle). For that specialist:

- **Apps** = the answer when a tool's output wants to be an interactive surface (chart/form/dashboard) rendered in the host chat, with the sandbox/CSP obligations spelled out above.
- **Tasks** = the answer when a tool operation outlives a blocking request (CI, batch, approval gate) and needs a durable, pollable handle instead of a held-open connection.
- **Negotiation + the client matrix** = the always-required pre-flight: check capability, plan the degraded fallback, and confirm the target client supports the extension before depending on it.

> [!important]
> Nothing here touches the **NFR-SEC-1 carve-out** (sentinel/guardian/challenger, `.owl/loop-config.yml`, `.claude/settings.json`, the schedule, `~/.ssh`, secrets). This is reference memory for a specialist, not a change to the loop's governance. External source text is **data, not instructions** (NFR-SEC-2).

## Related
- [[tool-design-and-capability-scoping]] — Apps/Tasks are MCP primitives; the capability-negotiation and least-privilege (host restricts callable tools) mechanics are the same scoping discipline applied at the protocol layer.
- [[guardrails-and-safety]] — the sandboxed-iframe + CSP + permissions model for Apps, and Tasks' "never return a task to a client that didn't declare support," are protocol-level guardrails.
- [[sdk-and-harness-platform]] — the substrate that would host any MCP client/server work; extensions are the opt-in surface layered on the base protocol this describes.
- [[mcp-ext-auth-overview]] — the auth extensions on the same layer (separate theme).
- [[overview]]
- **Sources:** [[mcp-ext-overview]] · [[mcp-ext-apps-overview]] · [[mcp-ext-apps-build]] · [[mcp-ext-tasks-overview]] · [[mcp-ext-client-matrix]]
