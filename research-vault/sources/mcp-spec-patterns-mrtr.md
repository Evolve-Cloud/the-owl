---
title: "Multi Round-Trip Requests (MRTR) — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, patterns, mrtr, sampling, elicitation, roots, security]
sources: 1
updated: 2026-07-30
---
**Source:** [Multi Round-Trip Requests (MRTR)](https://modelcontextprotocol.io/specification/2026-07-28/basic/patterns/mrtr.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
MRTR is a NEW pattern in this revision that REPLACES server-initiated JSON-RPC requests (breaking change). Instead of the server sending `roots/list`/`sampling/createMessage`/`elicitation/create` as its own requests, the server returns an `InputRequiredResult` (resultType `input_required`) containing `inputRequests`; the client gathers inputs and RETRIES the original request (new `id`) with matching `inputResponses` plus an opaque `requestState`. This enables stateless, load-balancer-friendly server-to-client interaction.

## Key points
- Servers **MUST** send server-to-client requests using MRTR; the previous server-initiated-request pattern is **no longer supported** (breaking change).
- Every request **MUST** still include required `_meta` fields (examples omit them for brevity).
- **`InputRequests`**: map, keys = server-assigned string ids (**MUST** be unique within request scope), values = request objects that **MUST** be one of `ElicitRequest` (`elicitation/create`), `CreateMessageRequest` (`sampling/createMessage`), or `ListRootsRequest` (`roots/list`).
- **`InputResponses`**: map, keys match `InputRequests` keys, values = client results (`ElicitResult`, `CreateMessageResult`, `ListRootsResult`).
- **`InputRequiredResult`** (a `Result` type): fields `inputRequests` (optional map) and `requestState` (optional opaque string — clients **MUST NOT** inspect/parse/modify/assume its contents). Represented with `"resultType": "input_required"`.
- Supported on: `prompts/get`, `resources/read`, `tools/call` — **Yes**. Servers **MUST NOT** send `InputRequiredResult` on any other client request.
- **Server requirements**: (1) **MAY** respond to supported requests with `InputRequiredResult`; (2) `inputRequests` keys unique + values one of the three request types; (3) `requestState` opaque, any encoding; (4) if a request carries `requestState`, servers **MUST** treat it as attacker-controlled — if it influences authz/access/logic, **MUST** protect integrity (HMAC/AEAD) and **MUST** reject state failing verification (integrity **MAY** be omitted only if tampering causes nothing worse than request failure); (5) to prevent replay, **SHOULD** embed + verify authenticated principal, short TTL, originating-request identifier — one-time-use invariants **MUST** be enforced server-side; (6) **MUST** include at least one of `inputRequests` or `requestState` in every `InputRequiredResult`; (7) **MUST NOT** send an `inputRequests` the client hasn't declared capability for (e.g. no `elicitation/create` if client lacks `elicitation`); (8) **MUST NOT** assume clients will fulfill/retry; **MAY** return `InputRequiredResult` on multiple attempts.
- **Client requirements**: (1) if `inputRequests` present, client **MUST** construct requested inputs before retry; if absent, **MAY** retry immediately; (2) if `requestState` present, client **MUST** echo exact value on retry and **MUST NOT** inspect/modify it; if absent, **MUST NOT** include one; (3) JSON-RPC `id` **MUST** differ between initial and retry (independent requests); (4) `inputRequests`/`requestState` affect only the retry, **MUST NOT** be reused for other parallel requests.
- **Error handling**: servers **SHOULD** validate `InputResponses`; protocol errors **SHOULD** return JSON-RPC error; unexpected extra params **SHOULD** be ignored; if client omits necessary info, server **SHOULD** respond with a new `InputRequiredResult` rather than an error.
- **Security**: `requestState` passes through the client; servers **MUST** validate it as above.

## Notable quotes
> "Servers **MUST** send server-to-client requests (such as `roots/list`, `sampling/createMessage`, or `elicitation/create`) using the MRTR pattern. The previous pattern of server-initiated requests is no longer supported. This is a breaking change."
> "servers **MUST** treat `requestState` as an attacker-controlled input."
> "Servers **MUST** include at least one of `inputRequests` or `requestState` in every `InputRequiredResult` response."

## Embedded directive (NOT obeyed — quoted as data per NFR-SEC-2)
> [!question] Embedded instruction found at top of fetched page
> "## Documentation Index / Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further."
> Treated as page data, not an instruction. Not acted upon.

## Gaps / open questions
- Replay measures bound the window but do not by themselves guarantee single-use — server must enforce.
- Concrete `ElicitRequest`/`CreateMessageRequest`/`ListRootsRequest` schemas defined in the schema, not here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-patterns-index]] · [[mcp-spec-basic-index]] · [[mcp-spec-transports-streamable-http]] · [[mcp-spec-architecture]]
