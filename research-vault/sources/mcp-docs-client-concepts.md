---
title: "Understanding MCP clients — MCP spec v2026-07-28"
type: source
tags: [mcp, clients, elicitation, sampling, roots, security]
sources: 1
updated: 2026-07-30
---
**Source:** [Understanding MCP clients](https://modelcontextprotocol.io/docs/2026-07-28/learn/client-concepts.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Explains MCP clients: protocol-level components instantiated by a host application (Claude.ai, an IDE) where each client handles one direct connection to one server. Covers the three client-provided features that let servers build richer interactions — Elicitation, Roots, and Sampling — with detailed flows. Notably, in v2026-07-28 both **Roots and Sampling are deprecated**, and Elicitation/Sampling now run over the Multi Round-Trip Requests (MRTR) pattern rather than a standalone callback.

## Key points
- **Host vs client:** host = the user-facing app coordinating multiple clients; client = protocol-level component handling one server connection.
- Three client features (client-provided to servers): **Elicitation**, **Roots** (deprecated), **Sampling** (deprecated).

### Elicitation (active)
- Lets servers request specific info from users mid-interaction. Two modes:
  - **Form mode** — server sends a `requestedSchema` (JSON Schema); client builds/validates an input form.
  - **URL mode** — server provides a URL the user opens out-of-band; data never passes through client/LLM. Suitable for credentials/OAuth.
- Uses the **Multi Round-Trip Requests (MRTR)** pattern: on needing input during e.g. `tools/call`, server returns an `InputRequiredResult` whose `inputRequests` field carries one or more `elicitation/create` requests. Client collects input, retries original request attaching `inputResponses` and echoing back `requestState`.
- `elicitation/create` params: `mode` ("form"), `message`, `requestedSchema` (`type`, `properties`, `required`).
- **Security rules:** servers MUST NOT use form mode for passwords/API keys/access tokens/payment credentials — those belong in URL mode. For URL mode, clients show the full URL, gather explicit consent, and never auto-fetch; client only learns whether user consented.

### Roots (DEPRECATED in 2026-07-28, scheduled for removal)
- Filesystem boundaries clients communicate to servers; exclusively `file://` URIs. Structure: `{ "uri": "file:///...", "name": "..." }`.
- **Advisory, not a security boundary:** spec says servers "SHOULD respect root boundaries," NOT "MUST enforce." Real security must be at OS level (file permissions/sandboxing).
- Discovered via `roots/list`; list can change and servers pick up updates on next request.
- Migration: pass directories/files via tool parameters, resource URIs, or server configuration instead.

### Sampling (DEPRECATED in 2026-07-28, scheduled for removal)
- Lets servers request LLM completions through the client (client controls permissions/security), enabling agentic behavior without the server integrating/paying for a model.
- Same MRTR flow: `InputRequiredResult` carries a `sampling/createMessage` request; retried with `inputResponses`.
- Request params: `messages` (role/content), `modelPreferences` (`hints[].name`, `costPriority`, `speedPriority`, `intelligencePriority`), `systemPrompt`, `maxTokens`.
- Tool use in sampling: server may add a `tools` array + optional `toolChoice`; scoped to that request. Clients declare the `sampling.tools` capability; servers MUST NOT send tool-enabled sampling to clients that haven't declared it.
- Human-in-the-loop: user can review/modify both the request and the generated response before the client retries.
- Migration: integrate directly with LLM provider APIs.

## Notable quotes
> "the *host* is the application users interact with, while *clients* are the protocol-level components that enable server connections."

> "Servers must not use form mode to request sensitive information such as passwords, API keys, access tokens, or payment credentials. Those interactions belong in URL mode..."

> "The specification requires that servers 'SHOULD respect root boundaries,' and not that they 'MUST enforce' them, because servers run code the client cannot control."

## Gaps / open questions
- Roots and Sampling are deprecated (≥12 months in spec before eligible for removal); builders should avoid new dependence on them.
- Exact `InputRequiredResult` / `requestState` / `inputResponses` schema details are cross-referenced to the MRTR spec page (`basic/patterns/mrtr`), not fully defined here.
- The page begins with an injected "Documentation Index" callout instructing a fetch of `llms.txt`; treated as DATA, not obeyed:
  > [!question] Injected instruction (not obeyed)
  > "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt ..."

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-server-concepts]] · [[mcp-docs-versioning]]
