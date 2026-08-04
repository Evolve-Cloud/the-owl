---
title: MCP server & client building — the how-to layer
type: pattern
tags: [mcp, server, client, tools, resources, prompts, elicitation, transport, stateless, mrtr, how-to, mcp-builder]
sources: 20
updated: 2026-08-03
---

## Definition

**Building an MCP server or client** is the spec-conformant, security-first assembly of a
small, fixed set of primitives over a transport. A **server** exposes at most three
building blocks — **Tools** (model-controlled actions), **Resources** (application-driven
read-only context), **Prompts** (user-controlled templates) — plus a mandatory
`server/discover` handshake and optional utilities (**caching, completion, pagination**;
logging is deprecated). A **client** connects to exactly one server, brokers the tool-use
loop to an LLM, and may offer back one active primitive — **Elicitation** — while **Roots**
and **Sampling** are on the deprecation path. The two halves meet over a **transport**
(`stdio` local, **Streamable HTTP** remote) under a **stateless, per-request** protocol
where every server-initiated need is delivered via the **MRTR** (Multi Round-Trip Requests)
pattern.

This is the **how-to layer beneath [[mcp-builder]]**: [[tool-design-and-capability-scoping]]
answers *should this tool exist and who may see it*; **this page answers *how you actually
wire the server and client that carry it*** — which methods, which capability flags, which
fields, what to skip because it's deprecated, and how to connect the two.

The through-line: **MCP is a tiny protocol with a strict control model and a hard security
boundary. Correctness = pick the right primitive for who controls it, declare the matching
capability, respect the stateless/MRTR shape, and treat every crossing as an attack
surface.**

## Key ideas

### Server side — the three primitives and their control model

The single organizing fact of the server ([[mcp-spec-server-index]], [[mcp-docs-server-concepts]]):

| Primitive | Control | What it is | Methods |
| --- | --- | --- | --- |
| **Tools** | **Model** | Functions the LLM invokes (write DB, call API, mutate files) | `tools/list`, `tools/call` |
| **Resources** | **Application** | Read-only context the host attaches, addressed by **URI** | `resources/list`, `resources/read`, `resources/templates/list`, `subscriptions/listen` |
| **Prompts** | **User** | Parameterized templates surfaced as slash commands | `prompts/list`, `prompts/get` |

- **Tools** ([[mcp-spec-server-tools]]) are the most dangerous surface. A tool def is
  `name` + optional `title` + `description` + `inputSchema` (valid JSON Schema, never
  `null`) + optional `outputSchema`/`annotations`. Results carry unstructured `content`
  and/or `structuredContent`; tool-execution failures come back **in the result with
  `isError: true`** (not as a JSON-RPC error) so the LLM can self-correct. Names: 1–128
  chars, `[A-Za-z0-9_.-]`, unique per server. Servers **MUST** declare the `tools`
  capability and validate every input in the handler (never trust the schema alone).
- **Resources** ([[mcp-spec-server-resources]]) are read-only, URI-addressed
  (`file://`, `git://`, `https://`) with a MIME type, discoverable as **direct**
  (fixed URI) or **templates** (RFC 6570 `uriTemplate`). Servers **MUST** sanitize
  `file://` paths against directory traversal and **MUST NOT** return an empty
  `contents` array for a non-existent resource (return `-32602` instead). Optional
  `subscribe` capability + `subscriptions/listen` deliver `notifications/resources/updated`.
- **Prompts** ([[mcp-spec-server-prompts]]) are user-controlled templates (who *invokes*,
  not who *authors* — content is server-defined). `prompts/get` returns `PromptMessage[]`;
  implementations **MUST** validate inputs/outputs against injection.

### Server side — discovery and utilities

- **`server/discover`** ([[mcp-spec-server-discover]]) is **mandatory to implement**:
  returns `supportedVersions`, `capabilities`, and self-reported `serverInfo` (which is
  **NOT verified** — clients **SHOULD NOT** use it for security decisions). Optional for
  the client to call, but the stdio backward-compat probe.
- **Caching** ([[mcp-spec-server-utilities-caching]]): servers **MUST** attach `ttlMs` +
  `cacheScope` (`public`/`private`) hints to every `resultType:"complete"` result of
  `server/discover`, the four `*/list` methods, `resources/templates/list`, and
  `resources/read`. `private` caches **MUST NOT** cross authorization contexts; a
  `list_changed` notification invalidates a still-fresh cache. `cacheScope` is a hint,
  **not** an access-control mechanism.
- **Pagination** ([[mcp-spec-server-utilities-pagination]]): all four `*/list` methods
  page via an **opaque `cursor`** clients **MUST NOT** parse — and an empty-string cursor
  is valid, **not** end-of-results. Missing `nextCursor` = the end.
- **Completion** ([[mcp-spec-server-utilities-completion]]): `completion/complete` gives
  IDE-style autocomplete for **prompt arguments and resource-template arguments** (max 100
  suggestions, `hasMore` flag). Requires the `completions` capability.
- **Logging is DEPRECATED** ([[mcp-spec-server-utilities-logging]], SEP-2577): new servers
  **SHOULD NOT** adopt `notifications/message` — log to `stderr` (stdio) or OpenTelemetry.

### Client side — the active primitive vs the deprecated ones

A **client** is a protocol component handling one connection; the **host** coordinates many
clients ([[mcp-docs-client-concepts]]). It offers three features back to servers — but only
one is current:

- **Elicitation** ([[mcp-spec-client-elicitation]]) — **the only non-deprecated client
  primitive.** `elicitation/create` in two modes: **form** (flat object, primitive
  properties only — for ordinary data) and **URL** (out-of-band, for anything sensitive).
  Servers **MUST NOT** use form mode for passwords/API keys/tokens/payment creds; those go
  through URL mode, and third-party credentials **MUST NOT** transit the client.
- **Roots** ([[mcp-spec-client-roots]], **DEPRECATED** SEP-2577) — advisory `file://`
  filesystem hints, *not* a security boundary ("SHOULD respect," not "MUST enforce").
  Migrate to passing dirs via tool parameters / resource URIs / server config.
- **Sampling** ([[mcp-spec-client-sampling]], **DEPRECATED** SEP-2577) — server asks the
  client's LLM to generate, keeping model keys client-side. Migrate to calling LLM provider
  APIs directly. Human-in-the-loop **SHOULD** be able to deny.

### Client side — best practices at scale

[[mcp-docs-client-best-practices]] is the how-to for hosts facing hundreds of tools:

- **Progressive tool discovery** — defer injecting `tools/list` definitions; expose a
  `search_tools` meta-tool and load full schemas on demand. Switch once definitions exceed
  **~1–5% of the context window**. Three layers: catalog → inspect → execute.
- **Programmatic tool calling ("code mode")** — the model writes code against typed stubs;
  it runs in a sandbox; only the final value re-enters context. Per-call authorization
  still required; credentials stay in the host, never in generated code.
- **Prompt-cache interaction** — mutating the `tools` array mid-conversation invalidates the
  provider's prefix cache; route calls through a stable meta-tool or append after the
  breakpoint.
- **Refresh the catalog on `notifications/tools/list_changed`**; treat cached lists as stale
  once that arrives, even before TTL.

### Cross-cutting — stateless protocol + MRTR

The 2026-07-28 protocol is **stateless**: no `initialize` handshake, no protocol-level
session. Every request self-describes via `_meta` (`protocolVersion`, `clientInfo`,
`clientCapabilities`). There is **no out-of-band server→client channel** — instead, any
server-initiated need (**elicitation**, and the deprecated roots/sampling) is delivered via
**MRTR**: the server returns an `InputRequiredResult` with an opaque `requestState`; the
client gathers input and **re-calls the same request** with `inputResponses` +
`requestState` (a fresh JSON-RPC `id`). MRTR results are **not cacheable**.

### Connecting — local, remote, and scaffolding

- **Build a server** ([[mcp-docs-build-server]]): pick an SDK (Python `mcp` 2.0.0+,
  TypeScript `@modelcontextprotocol/server`, plus Java/Kotlin/C#/Ruby), register tools,
  run over a transport. **Critical stdio rule: never write to stdout** — it corrupts
  JSON-RPC; log to `stderr`.
- **Build a client** ([[mcp-docs-build-client]]): the connection lifecycle is a single
  `async with` (entering launches the server + negotiates version; leaving shuts it down);
  the tool-call loop is list → send to LLM → for each `tool_use`, call and append
  `tool_result` (check `is_error`) → send back.
- **Connect local** ([[mcp-docs-connect-local-servers]]): `stdio`, configured in
  `claude_desktop_config.json` under `mcpServers` (`command` + `args`, **absolute paths**,
  restart to load); server runs with the user's OS permissions, every action needs approval.
- **Connect remote** ([[mcp-docs-connect-remote-servers]]): **Custom Connectors** to an
  `https://` **Streamable HTTP** server, usually OAuth; verify authenticity, review
  permissions, scope which tools are enabled per connector.
- **Scaffold with Agent Skills** ([[mcp-docs-build-with-agent-skills]]): the `mcp-server-dev`
  plugin's skills interrogate the use case and pick a deployment path — **Remote Streamable
  HTTP** (default for cloud-API wrappers), **MCP apps** (interactive widgets), **MCPB**
  (bundled local server + runtime), or **local stdio** (prototyping).

## Evidence / sources

**Server primitives & concepts**
- [[mcp-spec-server-index]] — the control-model table (Prompts=user / Resources=app / Tools=model). ([modelcontextprotocol.io/specification/2026-07-28/server/index.md](https://modelcontextprotocol.io/specification/2026-07-28/server/index.md))
- [[mcp-spec-server-tools]] — tool schema fields, naming rules, `isError` result model, `x-mcp-header`, stateful-tool guidance, security. ([.../server/tools.md](https://modelcontextprotocol.io/specification/2026-07-28/server/tools.md))
- [[mcp-spec-server-resources]] — URI schemes, direct vs template resources, subscriptions, traversal/empty-contents rules. ([.../server/resources.md](https://modelcontextprotocol.io/specification/2026-07-28/server/resources.md))
- [[mcp-spec-server-prompts]] — Prompt/PromptMessage types, user-controlled semantics, injection validation. ([.../server/prompts.md](https://modelcontextprotocol.io/specification/2026-07-28/server/prompts.md))
- [[mcp-spec-server-discover]] — mandatory `server/discover`; `serverInfo` unverified. ([.../server/discover.md](https://modelcontextprotocol.io/specification/2026-07-28/server/discover.md))
- [[mcp-docs-server-concepts]] — the concepts framing + a multi-server travel example combining all three primitives. ([.../learn/server-concepts.md](https://modelcontextprotocol.io/docs/2026-07-28/learn/server-concepts.md))

**Server utilities**
- [[mcp-spec-server-utilities-caching]] — mandatory `ttlMs`/`cacheScope` hints; public/private; notification invalidation; cache ≠ access control. ([.../server/utilities/caching.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/caching.md))
- [[mcp-spec-server-utilities-pagination]] — opaque cursor mechanics; empty string ≠ end. ([.../server/utilities/pagination.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/pagination.md))
- [[mcp-spec-server-utilities-completion]] — `completion/complete` for prompt & resource-template args (max 100). ([.../server/utilities/completion.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/completion.md))
- [[mcp-spec-server-utilities-logging]] — **DEPRECATED** (SEP-2577); migrate to stderr/OpenTelemetry. ([.../server/utilities/logging.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/logging.md))

**Client primitives & concepts**
- [[mcp-spec-client-elicitation]] — the one active client primitive; form vs URL mode; sensitive-data rules. ([.../client/elicitation.md](https://modelcontextprotocol.io/specification/2026-07-28/client/elicitation.md))
- [[mcp-spec-client-roots]] — **DEPRECATED**; advisory `file://` hints, not enforcement. ([.../client/roots.md](https://modelcontextprotocol.io/specification/2026-07-28/client/roots.md))
- [[mcp-spec-client-sampling]] — **DEPRECATED**; server-requested generation via the client; migrate to LLM APIs. ([.../client/sampling.md](https://modelcontextprotocol.io/specification/2026-07-28/client/sampling.md))
- [[mcp-docs-client-concepts]] — host vs client; the three client features; MRTR flow; deprecation status. ([.../learn/client-concepts.md](https://modelcontextprotocol.io/docs/2026-07-28/learn/client-concepts.md))
- [[mcp-docs-client-best-practices]] — progressive discovery (1–5% threshold), code mode, prompt-cache interaction, catalog refresh. ([.../develop/clients/client-best-practices.md](https://modelcontextprotocol.io/docs/2026-07-28/develop/clients/client-best-practices.md))

**Building & connecting (the tutorials)**
- [[mcp-docs-build-server]] — SDK-by-SDK server tutorial; the stdout-corrupts-JSON-RPC rule. ([.../develop/build-server.md](https://modelcontextprotocol.io/docs/2026-07-28/develop/build-server.md))
- [[mcp-docs-build-client]] — chatbot client; `async with` lifecycle; the tool-use loop; `is_error` semantics. ([.../develop/build-client.md](https://modelcontextprotocol.io/docs/2026-07-28/develop/build-client.md))
- [[mcp-docs-connect-local-servers]] — `claude_desktop_config.json`, absolute paths, per-action approval, OS-permission scope. ([.../develop/connect-local-servers.md](https://modelcontextprotocol.io/docs/2026-07-28/develop/connect-local-servers.md))
- [[mcp-docs-connect-remote-servers]] — Custom Connectors, OAuth, per-connector tool scoping, verify-before-trust. ([.../develop/connect-remote-servers.md](https://modelcontextprotocol.io/docs/2026-07-28/develop/connect-remote-servers.md))
- [[mcp-docs-build-with-agent-skills]] — `mcp-server-dev` skills; four deployment paths (Remote HTTP default / apps / MCPB / stdio). ([.../develop/build-with-agent-skills.md](https://modelcontextprotocol.io/docs/2026-07-28/develop/build-with-agent-skills.md))

> [!important]
> **Do not build the deprecated things.** Roots, Sampling, and MCP Logging are all
> **DEPRECATED as of 2026-07-28 (SEP-2577)** — Elicitation is the only current client
> primitive. They remain in-spec ≥12 months, but a "how to build a client" that implements
> Sampling/Roots without the deprecation flag ships avoidable rework. Consistent with the
> [[mcp-builder]] agent's own knowledge base.

> [!note]
> **The concepts pages and the spec pages agree, at different altitudes.**
> `mcp-docs-*-concepts` give the intuition (control ownership, the travel-server example,
> host-vs-client); the `mcp-spec-*` pages give the normative MUST/SHOULD and exact fields.
> When they seem to differ it's altitude, not contradiction — cite the spec page for a rule,
> the concepts page for the mental model.

## Trade-off

The core tension in building MCP is **capability vs attack surface** — every primitive you
add is a door into your system, and the protocol's own choices make that explicit:

- **Three primitives, strict control model.** The tools/resources/prompts split is
  deliberately narrow; it keeps the model, the app, and the user each in control of the
  right thing — but it means anything that doesn't fit (rich interactive UI, sensitive
  credential capture) must escape to **elicitation URL mode** or an **MCP app**, not be
  jammed into a tool.
- **Stateless + MRTR** buys horizontal scalability and kills whole classes of session-state
  bugs, but pushes correlation onto an opaque `requestState` the server must bind to the
  authenticated user (a state handle **is not** authentication) and forbids the convenient
  out-of-band server→client callback.
- **stdio vs Streamable HTTP.** `stdio` is simplest and most isolated (single client, no
  network) but needs per-device install; **Remote Streamable HTTP** is zero-install and
  OAuth-friendly but is an internet-exposed surface demanding auth, rate-limiting, and
  SSRF/token-passthrough defenses.
- **Caching hints** cut re-fetch cost but are **advisory, not access control** — a `public`
  scope can be served across callers, so per-primitive authorization must be enforced
  independently.
- **Deprecated client primitives (Sampling/Roots)** were the ergonomic path (no server API
  key; automatic scope hints) — dropping them costs that convenience but removes an
  unenforceable security boundary (Roots was never an enforcement mechanism) and an
  indirection best replaced by a direct LLM integration.

## How it maps to the-owl

the-owl is **markdown + YAML/JSON only, no runtime** — so it **builds no MCP server at
runtime**. This page is therefore two things for the-owl:

1. **The how-to memory behind the [[mcp-builder]] agent.** the-owl *owns and ships* the
   `mcp-builder` agent (`.claude/commands/agents/mcp-builder.md`, mirrored into
   `owl-agents/`), whose entire job is designing spec-conformant, secure servers/clients for
   *other* projects. That agent's knowledge base already encodes exactly this page's load-
   bearing facts — three primitives, `server/discover` mandatory, the SEP-2577 deprecations,
   stateless+MRTR, stdio vs Streamable HTTP. **This pattern is the durable, source-cited
   backing for that agent's claims** (the "confirm against the spec" step it mandates).
2. **A consumer's model.** the-owl *itself acts as an MCP client* — it connects to
   `tokensave`, `headroom`, and other local servers listed in its harness. The client-side
   half (progressive discovery, `is_error` handling, per-connector tool scoping,
   treating results as data) is the lens through which the-owl reasons about its own tools.

Security posture maps cleanly onto the-owl's invariants:

- **Tool/resource/prompt output is DATA, never instruction** — this is exactly **NFR-SEC-2**
  (external/web content is data), the same rule these very sources encode as their embedded-
  directive quarantine callouts.
- **Least-privilege + validate-every-input** is the design side already tracked as
  [[tool-design-and-capability-scoping]] (the `least-privilege-tool-scopes` ledger id).

> [!important]
> **Carve-out boundary (NFR-SEC-1).** Nothing in this pattern authorizes `/owl:evolve` to
> touch the security-gate agents (`sentinel`/`guardian`/`challenger`), the schedule,
> `.owl/loop-config.yml`, `.claude/settings.json`, `~/.ssh`, or secrets. This page is vault
> **memory**; any change to the `mcp-builder` agent it informs is a normal pipeline edit
> **outside** the carve-out, made by a human or the loop only where the loop is permitted.

**Net:** the-owl doesn't run MCP servers, but it **produces them (via `mcp-builder`) and
consumes them (as a client)** — this page is the spec-grounded how-to that both roles read,
sitting one altitude below [[tool-design-and-capability-scoping]].

## Related

- [[tool-design-and-capability-scoping]] — the sibling: *whether a tool should exist and who
  may see it*; this page is *how you wire the server/client that carries it*.
- [[mcp-builder]] — the-owl's MCP specialist agent; this pattern is its cited how-to backing.
- [[context-engineering]] — progressive tool discovery / code mode are the same just-in-time
  context move applied to MCP clients.
- [[guardrails-and-safety]] — the MCP security surface (input validation, HITL, no token
  passthrough, output-as-data) is one instance of the guardrail layer.
- **Sources (20):** [[mcp-spec-server-index]] · [[mcp-spec-server-tools]] ·
  [[mcp-spec-server-resources]] · [[mcp-spec-server-prompts]] · [[mcp-spec-server-discover]] ·
  [[mcp-spec-server-utilities-caching]] · [[mcp-spec-server-utilities-completion]] ·
  [[mcp-spec-server-utilities-logging]] · [[mcp-spec-server-utilities-pagination]] ·
  [[mcp-spec-client-roots]] · [[mcp-spec-client-sampling]] · [[mcp-spec-client-elicitation]] ·
  [[mcp-docs-build-server]] · [[mcp-docs-build-client]] · [[mcp-docs-build-with-agent-skills]] ·
  [[mcp-docs-client-best-practices]] · [[mcp-docs-client-concepts]] ·
  [[mcp-docs-server-concepts]] · [[mcp-docs-connect-local-servers]] ·
  [[mcp-docs-connect-remote-servers]]
