---
title: "Overview (Base Protocol) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, base-protocol, json-rpc, meta, error-codes]
sources: 1
updated: 2026-07-30
---
**Source:** [Overview (Base Protocol)](https://modelcontextprotocol.io/specification/2026-07-28/basic/index.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Defines the MCP base protocol: the JSON-RPC 2.0 message types (requests, result/error responses, notifications), the new polymorphic `resultType` field, MCP-partitioned error-code ranges, the statelessness model, JSON Schema usage rules, and the reserved `_meta` fields (per-request protocol version/capabilities/identity). All implementations MUST support base protocol, versioning, and message patterns; other components MAY be implemented as needed. This revision moves version/capabilities/identity into per-request `_meta` rather than a session handshake.

## Key points
- All messages **MUST** follow JSON-RPC 2.0 and **MUST** be UTF-8.
- **Requests** (`jsonrpc`, `id`, `method`, `params?`): ID **MUST** be string or integer, **MUST NOT** be `null`, **MUST NOT** reuse an in-flight ID.
- **Result responses** (`jsonrpc`, `id`, `result`): **MUST** echo request ID; **MUST** include `result`; `result` **MUST** include a `resultType` field.
- `resultType` values: `"complete"` (final content), `"input_required"` (contains `InputRequiredResult`); extensions **MAY** add values (built from core set + advertised extension caps). Unrecognized value **MUST** be treated as invalid. Absent `resultType` (legacy servers) **MUST** be treated as `"complete"`.
- **Error responses** (`jsonrpc`, `id?`, `error{code,message,data?}`): **MUST** echo ID (except malformed-request cases); `code` **MUST** be integer; `data` **MAY** be present.
- Error code ranges: `-32000`–`-32019` legacy (new codes **MUST NOT** be allocated here; receivers **MUST NOT** assume meaning except `-32002`); `-32020`–`-32099` reserved for MCP spec. Defined codes: `-32020` `HeaderMismatch`, `-32021` `MissingRequiredClientCapability`, `-32022` `UnsupportedProtocolVersion`. Reserved/retired: `-32002` (resource not found, replaced by `-32602`), `-32042` (URL elicitation, 2025-11-25 only) — **MUST NOT** emit. New non-spec codes **SHOULD** be allocated outside `-32768`–`-32000`.
- **Notifications** (`jsonrpc`, `method`, `params?`): **MUST NOT** include an ID; receiver **MUST NOT** respond.
- Three message patterns: Request/Response, Multi Round-Trip Requests (MRTR), Subscribe and Notify.
- **Statelessness**: MCP is stateless; every request self-contained. Servers **MUST NOT** rely on prior requests over same connection for context; state spanning requests **MUST** be referenced by explicit identifier passed each request. STDIO process is NOT a session/conversation.
- **Auth**: HTTP transports **SHOULD** conform to the Authorization framework; STDIO **SHOULD NOT** (use env credentials instead). Custom auth **MAY** be negotiated.
- **JSON Schema**: default dialect 2020-12 when no `$schema`; **MUST** support 2020-12; **MUST** validate per declared/default dialect and handle unsupported dialects gracefully with an error. `$ref` to network URI: implementations **MUST NOT** auto-dereference; opt-in fetching **MUST** be disabled by default, **SHOULD** enforce host allowlist / reject loopback+link-local+private addrs, apply timeouts/size limits. Composition keywords **SHOULD** be bounded (depth/subschema cap/time budget) to prevent DoS.
- **`_meta`**: reserved keys carry protocol metadata. Key format: optional dotted prefix (reverse-DNS **SHOULD**) + name; prefixes whose second label is `modelcontextprotocol` or `mcp` are reserved for MCP.
- Reserved `_meta` keys: `progressToken`, `io.modelcontextprotocol/protocolVersion`, `io.modelcontextprotocol/clientInfo`, `io.modelcontextprotocol/clientCapabilities`, `io.modelcontextprotocol/logLevel`, `io.modelcontextprotocol/subscriptionId`, plus `traceparent`/`tracestate`/`baggage` (OTel, W3C formats).
- Per-request protocol fields: `protocolVersion` (string, **required**), `clientCapabilities` (**required**), `clientInfo` (optional, **SHOULD** send), `logLevel` (optional). Missing required field → server **MUST** reject `-32602`; HTTP status **MUST** be `400`. Undeclared capability required → `-32021` `MissingRequiredClientCapabilityError` with `data.requiredCapabilities`; HTTP `400`.
- Per-response: server **SHOULD** include `io.modelcontextprotocol/serverInfo` in every result `_meta`. `clientInfo`/`serverInfo` are self-reported, unverified — **SHOULD NOT** drive behavior or security decisions.
- Subscription notifications **MUST** carry `io.modelcontextprotocol/subscriptionId` in `_meta`.
- **`icons`**: array of `Icon` {`src` (HTTPS or `data:` URI required), `mimeType?`, `sizes?`, `theme?`}. Clients rendering icons **MUST** support `image/png` and `image/jpeg`; **SHOULD** support `image/svg+xml` and `image/webp`. **MUST** reject unsafe schemes (`javascript:`, `file:`, `ftp:`, `ws:`), fetch without credentials, validate MIME via magic bytes, treat as untrusted.

## Notable quotes
> "The Model Context Protocol (MCP) is a **stateless protocol**: all the information needed to process a request is contained in the request itself."
> "an open connection, such as a STDIO process, is not a conversation or session"
> "Implementations **MUST NOT** automatically dereference `$ref` values that resolve to a network URI."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Local/SDK-internal error conditions (e.g. request timeout) are not yet assigned standard codes.
- Exact `ClientCapabilities`/`Implementation` structures live in the TypeScript schema (source of truth), not this page.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-versioning]] · [[mcp-spec-transports-index]] · [[mcp-spec-patterns-index]] · [[mcp-spec-patterns-mrtr]]
