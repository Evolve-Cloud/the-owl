---
title: "Architecture — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, architecture, capabilities, host-client-server]
sources: 1
updated: 2026-07-30
---
**Source:** [Architecture](https://modelcontextprotocol.io/specification/2026-07-28/architecture/index.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Describes MCP's client-host-server architecture: a host process runs multiple clients, each client has a 1:1 relationship with exactly one server. MCP is stateless — every request self-carries version and capabilities. Lists design principles (servers easy to build, composable, isolated from full conversation, progressively extensible) and the per-request capability-negotiation system (no session handshake), with `server/discover` as optional up-front discovery.

## Key points
- **Host**: container/coordinator — creates/manages clients, controls permissions/lifecycle, enforces security policies + consent, handles user authorization, coordinates AI/LLM sampling, aggregates context.
- **Client**: communicates with exactly one server (1:1); attaches protocol version + capabilities to every request; routes messages bidirectionally; manages subscriptions/notifications; maintains security boundaries.
- **Server**: exposes resources/tools/prompts; operates independently; requests client input (sampling, elicitation, roots) via `InputRequiredResult` within a reply (not via server-initiated requests); must respect security constraints; local or remote.
- Design principles: (1) servers extremely easy to build; (2) highly composable; (3) servers **cannot read whole conversation nor "see into" other servers** — full history stays with host, host enforces boundaries; (4) features added progressively, backwards compatibility maintained.
- **Capability negotiation** is per-request. Clients include capabilities in `_meta.io.modelcontextprotocol/clientCapabilities` on every request. Servers advertise capabilities in response to `server/discover`, which clients **MAY** call before any other request.
- Both parties must respect declared capabilities; server features **must** be advertised in the server's capabilities. Additional capabilities negotiated via extensions.
- Receiving resource-update notifications requires opening a `subscriptions/listen` stream with desired resource URIs. Tool invocation requires server to declare tool capabilities.
- Sequence diagram shows optional `server/discover`, per-request flow with `InputRequiredResult` (e.g. `sampling/createMessage`), and `subscriptions/listen` → `notifications/subscriptions/acknowledged` → `notifications/*` tagged with `subscriptionId`.

## Notable quotes
> "each host can run multiple client instances ... each client having a 1:1 relationship with a particular server."
> "Servers should not be able to read the whole conversation, nor 'see into' other servers"
> "Request client input (sampling, elicitation, roots) via `InputRequiredResult` within a reply"

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Page is largely non-normative (few MUST/SHOULD); the concrete capability struct shapes are in the schema / server-feature pages.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-basic-index]] · [[mcp-spec-versioning]] · [[mcp-spec-patterns-mrtr]] · [[mcp-spec-patterns-subscriptions]]
