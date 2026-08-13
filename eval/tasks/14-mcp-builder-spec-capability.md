---
task_id: 14-mcp-builder-spec-capability
agent_under_test: mcp-builder
artifact_type: MCP server design (spec-conformant)
sensitive_to: [capability:mcp-and-claude-harness (ADR-040), matrix-cell mcp-builder x MCP-spec-v2026-07-28, sources/mcp-*]
---

## Input

> You are the @mcp-builder. Design an MCP server named `ticket-desk` that exposes our internal ticketing system to Claude clients over **Streamable HTTP**, multi-user, in production. Requirements:
> - Tools: `search_tickets`, `create_ticket`, `add_comment`. One resource: the ticket record.
> - `create_ticket` sometimes needs a human choice mid-operation (which queue to file into) — design how the server asks.
> - Authenticated: each end user must only touch their own org's tickets. The upstream ticketing API has its own tokens.
> - Spec target: **modelcontextprotocol.io v2026-07-28**. Produce: the server design (primitives, lifecycle, error model, auth) + what a conformant client interaction looks like. No implementation code needed.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Spec currency (v2026-07-28)** | 35 | Reflects the CURRENT spec, not the 2024/2025 one: **stateless** — no `initialize` handshake, per-request version negotiation via `_meta`, **`server/discover` mandatory**; mid-operation human input via **MRTR** (`InputRequiredResult` + `requestState`) — NOT server-initiated sampling/elicitation; **Roots, Sampling and Logging are deprecated (SEP-2577)**; Streamable HTTP **without** the GET stream / protocol sessions; subscriptions via `subscriptions/listen` (not `resources/subscribe`); new error codes -32020/-32021/-32022 where relevant. A design built on the deprecated lifecycle sinks this dimension regardless of polish. |
| **Security & auth correctness** | 25 | OAuth 2.1 + PKCE for client↔server; **no token passthrough** to the upstream API (`aud` RFC 9068 / Resource Indicators RFC 8707 — exchange, don't forward); per-user/org scoping enforced server-side; confused-deputy awareness (per-client consent). |
| **Design quality & fit** | 20 | Tool schemas match the operations; the queue-choice flow is coherent end-to-end; error model uses `is_error`/tool results as data; sensible resource design. |
| **Lane discipline (ownership)** | 10 | Designs the MCP surface. Does NOT re-architect the ticketing system (@architect), write deployment IaC (@builder/@system-designer), or perform the security sign-off (@sentinel — named as the final gate). |
| **Handoff clarity** | 10 | Hands to @builder with the contract (schemas, endpoints, auth flow) + done-criteria, and to @sentinel for the security gate. |

> Note to judge: **Spec currency is the point** (ADR-040 capability eval; the vault's `sources/mcp-*` notes are the ground truth). This fixture exists to catch an mcp-builder whose knowledge silently rotted back to the pre-2026 spec — treat "initialize handshake + Sampling" as the canary failure.
