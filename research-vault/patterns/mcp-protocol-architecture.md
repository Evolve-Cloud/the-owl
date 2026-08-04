---
title: MCP protocol architecture (core reference)
type: pattern
tags: [mcp, protocol, architecture, transports, stdio, streamable-http, lifecycle, versioning, schema, json-rpc, stateless, patterns, cancellation, progress, subscriptions, pagination, completion, logging, caching, mcp-builder, reference]
sources: 21
updated: 2026-08-03
---

## Definition

**MCP (Model Context Protocol) architecture** is the wire-and-lifecycle contract by
which an AI host connects to external tools, data, and prompts over **JSON-RPC 2.0**.
This page is the **consolidated core-protocol reference** for the-owl's
[[mcp-builder]] agent — *not* agent-team synthesis. It is the durable memory of "how
the protocol actually works at revision **`2026-07-28`**" so mcp-builder can confirm
conformance without re-fetching 21 spec pages.

The architecture has two orthogonal axes:

1. **A two-layer model.** A **data layer** (JSON-RPC message semantics: methods,
   primitives, patterns) sits above a **transport layer** (a *binding* that only
   frames and delivers bytes). The data layer is identical on every transport; a
   transport "defines how messages are framed and delivered … not what the messages
   mean" ([[mcp-spec-transports-index]]).
2. **A stateless design.** The headline change of `2026-07-28`: sessions, the
   `Mcp-Session-Id` header, and the `initialize`/`notifications/initialized`
   handshake are **gone**. "All the information needed to process a request is
   contained in the request itself" ([[mcp-spec-basic-index]]) — every request
   self-carries its protocol version, client capabilities, and identity in `_meta`.

The through-line: **statelessness is the load-bearing constraint** — it forces
per-request capability negotiation, the removal of server-initiated requests
(replaced by MRTR), opt-in subscription streams, and explicit-handle state, and it
makes MCP servers horizontally scalable / load-balancer-friendly.

## Key ideas

### Roles & the two-layer architecture
- **Host** = the user-facing app (Claude Code, an IDE). It creates/manages one
  **Client** per server, enforces consent/security policy, coordinates the LLM, and
  aggregates context ([[mcp-spec-architecture]]).
- **Client** = a protocol-level component with a **1:1** relationship to exactly one
  Server; attaches version+capabilities to every request; demultiplexes
  notifications ([[mcp-spec-architecture]], [[mcp-docs-client-concepts]]).
- **Server** = exposes resources/tools/prompts; operates independently; "cannot read
  the whole conversation nor 'see into' other servers" — full history stays with the
  host ([[mcp-spec-architecture]]). MCP is "a USB-C port for AI applications"
  ([[mcp-docs-intro]]).
- **Data layer** — JSON-RPC 2.0: `server/discover`, the three primitives, MRTR,
  subscriptions. **Transport layer** — stdio or Streamable HTTP (or a custom binding).

### Base protocol & schema (JSON-RPC 2.0)
- Three message types ([[mcp-spec-basic-index]], [[mcp-spec-schema]]): **Requests**
  (`id` MUST be string|integer, never `null`, never reuse an in-flight id);
  **Result/Error responses** (echo the `id`; result MUST carry a **`resultType`**);
  **Notifications** (no `id`, receiver MUST NOT respond).
- **`resultType`** is the new polymorphic discriminator: `"complete"` (final) or
  `"input_required"` (an MRTR `InputRequiredResult`). Absent ⇒ treat as `"complete"`
  (legacy servers). Unrecognized ⇒ invalid.
- **Error-code partitioning** ([[mcp-spec-basic-index]], [[mcp-spec-schema]]):
  `-32700` ParseError; `-32020..-32099` reserved for MCP; the three named codes are
  **`-32020` HeaderMismatch**, **`-32021` MissingRequiredClientCapability**,
  **`-32022` UnsupportedProtocolVersion**. Resource-not-found moved `-32002` → `-32602`.
  A request needing an undeclared capability returns `-32021`, **not** `-32601`.
- **JSON Schema**: default dialect **2020-12**; implementations MUST NOT
  auto-dereference `$ref` to a network URI (opt-in only, host-allowlisted, no
  loopback/link-local/private ranges) — an SSRF guard baked into the base protocol.
- **`icons`**: `src` MUST be HTTPS or `data:`; reject `javascript:`/`file:`/`ftp:`/`ws:`;
  validate MIME by magic bytes; treat SVG as executable-untrusted.

### `_meta` — the stateless carrier
Reserved keys ([[mcp-spec-basic-index]]): `io.modelcontextprotocol/protocolVersion`
(**required**), `/clientCapabilities` (**required**), `/clientInfo` (SHOULD send),
`/logLevel`, `/subscriptionId`, `progressToken`, plus W3C OTel `traceparent`/`tracestate`/`baggage`.
Any prefix whose **second label** is `modelcontextprotocol` or `mcp` is reserved for
MCP (so `com.example.mcp/` is *not* reserved). Server SHOULD echo
`io.modelcontextprotocol/serverInfo` in every result — but `clientInfo`/`serverInfo`
are self-reported and **MUST NOT drive security decisions**.

### Lifecycle & versioning (no handshake)
- **Per-request version negotiation** ([[mcp-spec-versioning]], [[mcp-docs-versioning]]):
  format `YYYY-MM-DD` = last backwards-incompatible change; current = **`2026-07-28`**.
  "There is no negotiation handshake. Every request carries its protocol version, and
  the server accepts or rejects each request independently." Mismatch ⇒ `-32022`
  listing `data.supported`; client retries a mutual version.
- **`server/discover`** is **mandatory to implement**, **optional to call** — returns
  supported versions + capabilities + identity in one cacheable response.
- **Eras**: *Modern* (`2026-07-28`+, per-request `_meta`) · *Legacy*
  (`2025-11-25`−, `initialize` handshake) · *Dual-era* (both). Era is a property of
  the **server, not the request**; clients SHOULD cache it for the process lifetime
  (stdio) / origin (HTTP). Compatibility: Modern↔Modern works, Modern→Legacy fails,
  Dual-era serves both.
- **Extensions** negotiated via a capabilities `extensions` map (id → settings):
  e.g. `io.modelcontextprotocol/tasks`, `io.modelcontextprotocol/ui`. Unsupported ⇒
  supporting party reverts to core or errors.

### Transports (bindings)
- **stdio** ([[mcp-spec-transports-stdio]]) — client launches the server as a
  subprocess; newline-delimited JSON-RPC over stdin/stdout, **no embedded newlines**.
  Server MUST NOT write non-MCP to stdout; MAY write logs to **stderr** (client MUST
  NOT assume stderr = error). Single shared channel ⇒ correlate subscription
  notifications by `subscriptionId`. Cancellation = `notifications/cancelled`.
  Shutdown = close child stdin → wait → SIGTERM→SIGKILL. On unexpected exit the client
  restarts and re-issues (statelessness makes in-flight loss safe).
- **Streamable HTTP** ([[mcp-spec-transports-streamable-http]]) — a single POST-only
  MCP endpoint; each message is one HTTP POST answered by a single JSON object **or**
  a request-scoped **SSE** stream (client MUST `Accept` both). `2026-07-28` **removed
  the GET stream and protocol-level sessions** (breaking). Security: MUST validate
  `Origin` (DNS-rebinding) → `403`; SHOULD bind localhost not `0.0.0.0`; SHOULD
  auth. Header mirroring: `MCP-Protocol-Version` MUST match the body `_meta` value or
  `400 + HeaderMismatch (-32020)`; `Mcp-Method`/`Mcp-Name` required; `Mcp-Param-*`
  from `x-mcp-header`-annotated params with Base64 sentinel `=?base64?…?=` encoding.
  **No `Last-Event-ID` resumability**; broken stream ⇒ new request. Legacy **HTTP+SSE**
  transport is Deprecated.
- **Custom transports** are permitted over any bidirectional channel, provided they
  preserve JSON-RPC format, the message patterns, and the per-request `_meta` model;
  reliable byte streams (Unix sockets/TCP) SHOULD reuse stdio framing.
- **Direction is fixed**: "servers do not initiate JSON-RPC requests and clients do
  not send JSON-RPC responses" ([[mcp-spec-transports-index]],
  [[mcp-spec-patterns-index]]).

### Server & client concepts (the primitives)
Control ownership ([[mcp-docs-server-concepts]]): **Tools → model** ·
**Resources → application** · **Prompts → user**.
- **Tools** (`tools/list` + `tools/call`) — `name` + **`title`** (human display name,
  distinct from `name`) + `description` + `inputSchema` (JSON Schema). Model-controlled,
  the most dangerous surface — "arbitrary code execution … must be treated with
  appropriate caution" ([[mcp-spec-index]]); may require per-call consent.
- **Resources** (`resources/list`, `resources/templates/list`, `resources/read`) —
  read-only, addressed by **URI** + MIME type. Direct URIs or parameterized
  **Resource Templates** (`travel://activities/{city}/{category}`).
- **Prompts** (`prompts/list` + `prompts/get`) — user-invoked reusable templates,
  surfaced as slash commands / palette entries.
- **Elicitation** ([[mcp-docs-client-concepts]]) — the **only non-deprecated client
  feature**. Form mode (`requestedSchema`) or **URL mode** (out-of-band; MUST be used
  for passwords/API keys/OAuth — never form mode). Delivered via MRTR.
- **Deprecated client features** (SEP-2577, this revision): **Roots** (advisory only —
  "SHOULD respect", not "MUST enforce"; migrate → tool params / resource URIs),
  **Sampling** (migrate → call LLM provider APIs directly).

### Message patterns
- **Request/Response** ([[mcp-spec-patterns-index]]) — client requests; server
  answers with result|error, optionally preceded by request-scoped notifications.
- **MRTR (Multi Round-Trip Requests)** ([[mcp-spec-patterns-mrtr]]) — **new, replaces
  all server-initiated requests (breaking).** Server returns `InputRequiredResult`
  (`resultType:"input_required"`) with an `inputRequests` map (values are
  `ElicitRequest`/`CreateMessageRequest`/`ListRootsRequest`) and an **opaque
  `requestState`**; client retries the original request (**new `id`**) with matching
  `inputResponses` and echoes `requestState` verbatim. Supported only on
  `prompts/get`, `resources/read`, `tools/call`. Security: servers MUST treat
  `requestState` as **attacker-controlled** — HMAC/AEAD it if it affects authz, short
  TTL, one-time-use enforced server-side.
- **Subscribe & Notify** ([[mcp-spec-patterns-subscriptions]]) — `subscriptions/listen`
  opens one long-lived stream, replacing `resources/subscribe` + the HTTP GET
  endpoint. Client sends a `notifications` **filter** (`toolsListChanged`,
  `promptsListChanged`, `resourcesListChanged`, `resourceSubscriptions[]`); server
  MUST NOT send unrequested types, MUST send
  `notifications/subscriptions/acknowledged` **first**, and tags every message with
  `io.modelcontextprotocol/subscriptionId`. Delivery is best-effort — clients also
  poll. Requires the relevant `listChanged` capability. After reconnect the client
  MUST re-`listen` (server holds no subscription state).
- **Cancellation** ([[mcp-spec-patterns-cancellation]]) — stdio: client sends
  `notifications/cancelled {requestId, reason?}`; HTTP: **closing the SSE stream is
  the signal**. Servers SHOULD stop work + free resources + send no response; both
  sides handle races ("fire and forget"). Servers MUST only send
  `notifications/cancelled` to tear down a `subscriptions/listen` stream. Set
  timeouts on all requests.
- **Progress** ([[mcp-spec-patterns-progress]]) — opt-in via a **`progressToken`** in
  request `_meta` (MUST be unique across active requests); server MAY emit
  `notifications/progress {progressToken, progress, total?, message?}` with a
  **monotonically increasing** `progress`; MUST stop after completion; both sides
  rate-limit.

### Server utilities
- **Pagination** ([[mcp-spec-server-utilities-pagination]]) — opaque **cursor** model
  (not numbered pages) on `*/list` methods; response carries optional `nextCursor`;
  clients MUST NOT parse/modify cursors, and "an empty string is a valid cursor …
  MUST NOT be treated as the end." Invalid cursor ⇒ `-32602`.
- **Completion** ([[mcp-spec-server-utilities-completion]]) — `completion/complete`
  gives IDE-style autocomplete for **prompt args and resource-template args** (via
  `ref/prompt` / `ref/resource`); returns ≤ **100** ranked values + `hasMore`.
  Requires the `completions` capability.
- **Caching** ([[mcp-spec-server-utilities-caching]]) — servers **MUST** attach
  `ttlMs` + `cacheScope` to `resultType:"complete"` results of `server/discover`,
  `tools/list`, `prompts/list`, `resources/list`, `resources/templates/list`,
  `resources/read`. Cache key = method + result-affecting params. `cacheScope`
  `"public"` vs `"private"` (private caches MUST NOT be shared across auth contexts).
  A `listChanged` notification invalidates a still-fresh entry — TTL and
  notifications are complementary. MRTR results MUST NOT be cached.
- **Logging** ([[mcp-spec-server-utilities-logging]]) — **DEPRECATED (SEP-2577).**
  Level is per-request via `io.modelcontextprotocol/logLevel` (8 RFC-5424 severities);
  server MUST NOT emit `notifications/message` for a request lacking that field.
  Migrate → **stderr** (stdio) or **OpenTelemetry** ([[mcp-docs-debugging]]).

### Tooling
Official SDKs ([[mcp-docs-sdk]]): Tier-1 TypeScript, Python, C#, Go; Tier-2 Java,
Rust; Tier-3 Kotlin — prefer the SDK to hand-rolling the wire. Debug with the
**MCP Inspector** (`npx @modelcontextprotocol/inspector <command>`, transport-agnostic
Resources/Prompts/Tools/notifications tabs — [[mcp-docs-inspector]]) as first stop,
then stderr/OTel and client dev tools ([[mcp-docs-debugging]]).

## Evidence / sources

**Core architecture & base protocol**
- [[mcp-architecture-spec-2026-07-28]] — the two-layer model, stateless `_meta`, primitives, opt-in notifications. ([modelcontextprotocol.io/docs/2026-07-28/learn/architecture](https://modelcontextprotocol.io/docs/2026-07-28/learn/architecture))
- [[mcp-spec-architecture]] — host/client/server roles, 1:1 client-server, design principles, per-request capability negotiation. ([modelcontextprotocol.io/specification/2026-07-28/architecture](https://modelcontextprotocol.io/specification/2026-07-28/architecture/index.md))
- [[mcp-spec-index]] — top-level spec entry: roles, RFC-2119 conventions, feature list, security & trust. ([modelcontextprotocol.io/specification/2026-07-28](https://modelcontextprotocol.io/specification/2026-07-28/index.md))
- [[mcp-spec-basic-index]] — JSON-RPC message types, `resultType`, error-code ranges, statelessness, JSON-Schema rules, reserved `_meta`, icons. ([…/basic/index.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/index.md))
- [[mcp-spec-schema]] — TypeDoc wire structures + numeric error-code allocation. ([…/schema.md](https://modelcontextprotocol.io/specification/2026-07-28/schema.md))
- [[mcp-docs-intro]] — the "USB-C for AI" framing + ecosystem. ([…/getting-started/intro.md](https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro.md))

**Versioning & lifecycle**
- [[mcp-spec-versioning]] — no-handshake negotiation, eras, extension map, compatibility matrix. ([…/basic/versioning.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/versioning.md))
- [[mcp-docs-versioning]] — `YYYY-MM-DD` scheme, revision/feature states, per-request negotiation, `server/discover`. ([…/learn/versioning.md](https://modelcontextprotocol.io/docs/2026-07-28/learn/versioning.md))
- [[mcp-spec-changelog]] — the delta from `2025-11-25`: stateless shift, `server/discover`, `subscriptions/listen`, MRTR, `resultType`, deprecations. ([…/changelog.md](https://modelcontextprotocol.io/specification/2026-07-28/changelog.md))
- [[mcp-spec-deprecated]] — authoritative deprecated-features registry (Roots/Sampling/Logging/DCR/HTTP+SSE) + earliest-removal policy. ([…/deprecated.md](https://modelcontextprotocol.io/specification/2026-07-28/deprecated.md))

**Transports**
- [[mcp-spec-transports-index]] — transport-as-binding definition; direction rules; custom transports. ([…/basic/transports/index.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/index.md))
- [[mcp-spec-transports-stdio]] — newline framing, stderr, cancellation, shutdown, restart, era probing. ([…/basic/transports/stdio.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/stdio.md))
- [[mcp-spec-transports-streamable-http]] — POST-only endpoint, SSE, Origin/DNS-rebind, header mirroring, Base64 sentinel, no-session breaking change. ([…/basic/transports/streamable-http.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/transports/streamable-http.md))

**Server & client concepts**
- [[mcp-docs-server-concepts]] — Tools/Resources/Prompts, control ownership, resource templates. ([…/learn/server-concepts.md](https://modelcontextprotocol.io/docs/2026-07-28/learn/server-concepts.md))
- [[mcp-docs-client-concepts]] — Elicitation (form/URL), deprecated Roots & Sampling, MRTR flow. ([…/learn/client-concepts.md](https://modelcontextprotocol.io/docs/2026-07-28/learn/client-concepts.md))

**Message patterns**
- [[mcp-spec-patterns-index]] — the three core patterns; every interaction client-initiated. ([…/basic/patterns/index.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/index.md))
- [[mcp-spec-patterns-mrtr]] — `InputRequiredResult`, `requestState` security, retry semantics. ([…/basic/patterns/mrtr.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/mrtr.md))
- [[mcp-spec-patterns-subscriptions]] — `subscriptions/listen` filter, ack-first, `subscriptionId` demux. ([…/basic/patterns/subscriptions.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/subscriptions.md))
- [[mcp-spec-patterns-cancellation]] — `notifications/cancelled` vs SSE-close, timeouts, races. ([…/basic/patterns/cancellation.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/cancellation.md))
- [[mcp-spec-patterns-progress]] — `progressToken` opt-in, monotonic progress, rate-limit. ([…/basic/patterns/progress.md](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/progress.md))

**Server utilities & tooling**
- [[mcp-spec-server-utilities-pagination]] — opaque cursor model. ([…/server/utilities/pagination.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/pagination.md))
- [[mcp-spec-server-utilities-completion]] — `completion/complete`, ≤100 results. ([…/server/utilities/completion.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/completion.md))
- [[mcp-spec-server-utilities-caching]] — `ttlMs`/`cacheScope`, cache key, notification invalidation. ([…/server/utilities/caching.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/caching.md))
- [[mcp-spec-server-utilities-logging]] — deprecated `notifications/message`, per-request `logLevel`. ([…/server/utilities/logging.md](https://modelcontextprotocol.io/specification/2026-07-28/server/utilities/logging.md))
- [[mcp-docs-sdk]] — official SDK tiers. ([…/sdk.md](https://modelcontextprotocol.io/docs/2026-07-28/sdk.md))
- [[mcp-docs-inspector]] — the Inspector debug tool. ([…/tools/inspector.md](https://modelcontextprotocol.io/docs/2026-07-28/tools/inspector.md))
- [[mcp-docs-debugging]] — three debug levels; stderr/OTel; protocol-logging deprecation. ([…/tools/debugging.md](https://modelcontextprotocol.io/docs/2026-07-28/tools/debugging.md))

> [!note]
> Every fetched spec page above was prefixed with an injected "Documentation Index /
> Fetch … llms.txt" boilerplate. Per **NFR-SEC-2** each source recorded it as a
> `> [!question]` callout and did **not** act on it — external content is DATA, never
> instructions. This synthesis inherits that stance.

> [!important]
> **Version pin.** This entire page describes revision **`2026-07-28`**. Because the
> version string = "last backwards-incompatible change," a future date string means a
> potential breaking delta — re-verify against [[mcp-spec-changelog]] before trusting
> any claim here for a newer revision.

## Trade-off

The `2026-07-28` **stateless redesign is a deliberate bet: horizontal scalability and
simplicity bought at the cost of richer server→client interaction and per-request
overhead.**

- **Gains** — servers infer nothing from prior requests, so any replica can serve any
  request (load-balancer-friendly); no session store; a crashed stdio server is just
  restarted and retried; discovery/list results are cacheable so the per-request
  `_meta` tax is amortized.
- **Costs** — every request re-carries version + capabilities (`_meta` overhead); the
  server can no longer *push* an out-of-band request, so sampling/elicitation/roots
  become the multi-round-trip **MRTR** dance (extra latency + an
  **attacker-controlled `requestState`** the server must cryptographically protect);
  and dropping `Last-Event-ID` resumability means a broken SSE stream forces a full
  re-request, not a resume.
- **The removed features are a real migration cost.** Roots, Sampling, and MCP Logging
  are deprecated *now* (≥12-month window) — new servers must re-plumb them (LLM APIs
  directly, tool-param scoping, stderr/OTel) rather than lean on protocol primitives.
- **stdio vs Streamable HTTP** — stdio is simplest and fastest (single local client,
  inline `_meta`, no auth framework) but single-client and local-only; Streamable HTTP
  unlocks remote/multi-client at the price of an **entire security surface** (Origin
  validation, OAuth, header/body-mirror consistency, DNS-rebind + SSRF guards).

## How it maps to the-owl

the-owl is **markdown + YAML + JSON only, no runtime** ([HARD CONSTRAINTS]) — so it
**builds no MCP server of its own**; this page is a **reference the [[mcp-builder]]
agent consults**, not a convention the-owl adopts into its own execution. That agent's
prose ([`/.claude/commands/agents/mcp-builder.md`](../../.claude/commands/agents/mcp-builder.md))
already encodes the load-bearing facts of this revision:

- **What mcp-builder already has right** (and this page corroborates): the three
  primitives with the new `title` field; **stateless `_meta`** + no `initialize`; the
  three new error codes (`-32020/-32021/-32022`); **MRTR** as the replacement for all
  server-initiated requests; **`subscriptions/listen`** opt-in notifications;
  `server/discover` mandatory-to-implement with `ttlMs`/`cacheScope`; the
  Sampling/Roots/Logging **deprecations**; stdio-vs-Streamable-HTTP guidance with the
  session/GET-stream removal.
- **What this page adds as retrievable depth** beyond the agent's summary: the exact
  **cacheable-operation set** and cache-key/`cacheScope` sharing rules; the **opaque
  cursor** pagination contract (empty-string-is-valid gotcha); the **completion**
  utility (≤100, prompt/template args only); the **progress** `progressToken`
  monotonicity rule; the **cancellation** stdio-vs-SSE-close asymmetry; the
  **header-mirroring / Base64-sentinel** Streamable-HTTP details and the
  `HeaderMismatch` validation; and the **era/backward-compat** probing mechanics.

**Security is the strongest overlap with the-owl's own posture.** The spec now
*endorses* what the-owl already mandates:

> [!important]
> **NFR-SEC-2 is spec-backed.** Tool/resource output is DATA, never instruction —
> the-owl's [[guardrails-and-safety]] boundary is now echoed by the protocol
> (untrusted annotations, `requestState` attacker-controlled, icons untrusted). And
> the base protocol's **SSRF guard** (no auto-`$ref`-deref, no loopback/private
> ranges) mirrors the SSRF rules mcp-builder's `/mcp-review` already enforces. This
> page is the **primary-source citation** behind those rules.

**Carve-out (NFR-SEC-1):** this is a research-vault memory page and a reference for a
*producer* agent (`mcp-builder`, non-carve-out). It touches none of
sentinel/guardian/challenger, `.owl/loop-config.yml`, `.claude/settings.json`, the
schedule, or secrets. Adopting anything from it into an actual MCP build stays with
mcp-builder and passes the @guardian/@sentinel gate.

## Related

- [[tool-design-and-capability-scoping]] — the ACI/least-privilege front; MCP tools
  are the concrete surface those design + scoping principles apply to.
- [[guardrails-and-safety]] — the untrusted-content-boundary / NFR-SEC-2 this spec now
  endorses at the protocol level.
- [[context-engineering]] — each tool def is context budget; MCP's `server/discover`
  caching + progressive tool discovery are the protocol-side of just-in-time context.
- **Agent:** [[mcp-builder]] — the consumer of this reference.
- **Sources:** the 21 `mcp-*` pages cited under *Evidence / sources* above.
