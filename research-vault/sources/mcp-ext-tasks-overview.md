---
title: "MCP Tasks — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, tasks, async, polling, elicitation]
sources: 1
updated: 2026-07-30
---
**Source:** [MCP Tasks](https://modelcontextprotocol.io/extensions/tasks/overview.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
MCP Tasks (`io.modelcontextprotocol/tasks`) add asynchronous execution for long-running operations. Instead of blocking, a server returns a durable task handle (`CreateTaskResult`, `resultType: "task"`) that clients poll via `tasks/get`. Tasks carry lifecycle status, support mid-flight input (`input_required` → `tasks/update`), survive disconnects (durable `taskId`), and can be cancelled cooperatively. The extension is experimental (`experimental-ext-tasks` repo).

## Key points
- Solves problems blocking cannot: no long-lived connections (avoids client/intermediary timeouts), crash resilience (durable handle), progress visibility, mid-flight interaction, and server-directed opt-in (server decides per-request whether to create a task; client opts in once via capability — no per-tool warmup or per-request flag).
- Lifecycle statuses: `working`, `input_required`, `completed`, `failed`, `cancelled`. Terminal: `completed`, `failed`, `cancelled` (state does not change once reached).
- Flow: capability negotiation → task creation (`CreateTaskResult` with `taskId`, initial status, TTL/`ttlMs`, `pollIntervalMs`; task durably created before response) → polling (`tasks/get`) → mid-flight input (`inputRequests` map with elicitations; client replies via `tasks/update`) → completion (`result` on `completed`, `error` on `failed`) → cancellation (`tasks/cancel`, cooperative).
- Notifications: servers can push status via `notifications/tasks`; clients opt in through `subscriptions/listen`. Each notification carries full task state (no extra `tasks/get`). Polling is the default; notifications can replace it if supported.
- **Client MUSTs (per guide):** declare support in per-request `io.modelcontextprotocol/clientCapabilities.extensions`; handle polymorphic results (standard result OR `CreateTaskResult`); poll respecting `pollIntervalMs` until terminal; handle `input_required` via `tasks/update`; persist task IDs durably to resume after crash.
- **Server guidance:** advertise support in `server/discover`; **"Never return a task to a client that did not declare support"** — verify client capability first; return `CreateTaskResult` durably created before responding; serve `tasks/get`; handle `tasks/update` (ack empty; ignore unknown/satisfied keys) and `tasks/cancel` (ack empty; honor when possible — cooperative).
- Good fit: long-running ops (CI, batch, training), human-in-the-loop approval gates, external job systems with existing job IDs, unreliable/mobile connections, batch processing with meaningful partial progress.

## Notable quotes
> "Before returning a CreateTaskResult, verify that the client included the extension in its per-request capabilities. Never return a task to a client that did not declare support."
> "Cancellation is cooperative — the server acknowledges the intent but is not obligated to stop the work."

## Embedded instructions (data, not obeyed)
> [!question] Page-top directive treated as data, not obeyed: "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt … Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Tasks is experimental (in `experimental-ext-tasks`); normative field schemas (exact `Task`/`CreateTaskResult` shape) live in that repo, not fully on this page.
- Semantics of `ttlMs` expiry (what happens to a task/result after TTL) not detailed here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]]
