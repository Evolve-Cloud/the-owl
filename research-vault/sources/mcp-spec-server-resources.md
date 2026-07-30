---
title: "Resources — MCP spec v2026-07-28"
type: source
tags: [mcp, spec, server, resources, resources-read, subscriptions]
sources: 1
updated: 2026-07-30
---
**Source:** [Resources](https://modelcontextprotocol.io/specification/2026-07-28/server/resources.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Resources let servers expose data (files, schemas, app info) as context for LLMs, each identified by a URI. Resources are application-driven: the host decides how to incorporate them. Clients discover via `resources/list` and `resources/templates/list` (paginated + cacheable), read via `resources/read` (cacheable), and can subscribe to per-resource updates via `subscriptions/listen`. The page defines resource/content data types, annotations, standard URI schemes, and error/security rules.

## Key points
- Methods: **`resources/list`**, **`resources/read`**, **`resources/templates/list`**. Notifications: **`notifications/resources/list_changed`**, **`notifications/resources/updated`**. Subscriptions via **`subscriptions/listen`** with `resourceSubscriptions` filter.
- Capability: servers supporting resources **MUST** declare `resources`; two optional features `listChanged` and `subscribe` (advertise either/both/neither): `{"capabilities":{"resources":{"listChanged":true,"subscribe":true}}}`.
- `resources/list` set **MAY** be empty, **MAY** change, **MUST NOT** vary per-connection or as a side effect; **MAY** vary by authorization on the request.
- **Resource** fields: `uri`, `name`, `title` (optional), `description` (optional), `icons` (optional), `mimeType` (optional), `size` (optional bytes).
- **Resource Contents**: text (`text`) or binary (`blob`, base64). `resources/read` **MAY** return multiple `contents`. **MAY** respond with `InputRequiredResult` (MRTR) needing `inputResponses`/`requestState` on retry.
- **Resource Templates**: `uriTemplate` (RFC 6570); args auto-completable via completion API; paginated + cacheable.
- **Annotations** (resources, templates, content blocks): `audience` (array of `"user"`/`"assistant"`), `priority` (0.0–1.0), `lastModified` (ISO 8601).
- **Subscriptions**: client sends `subscriptions/listen` with URIs in `notifications.resourceSubscriptions`; server delivers `notifications/resources/updated` (carries `_meta['io.modelcontextprotocol/subscriptionId']` and `uri`) on that stream when a watched resource changes.
- **URI schemes**: `https://` (only when client can fetch directly itself), `file://` (filesystem-like; **MAY** use XDG MIME types like `inode/directory`), `git://`. Custom schemes **MUST** conform to RFC 3986.
- **Error handling**: non-existent resource → JSON-RPC error `-32602` (Invalid Params); internal errors **SHOULD** be `-32603`; clients **SHOULD** also accept `-32002` (legacy) as not-found. Servers **MUST NOT** return an empty `contents` array for a non-existent resource (ambiguous).
- **Security**: Servers **MUST** validate all resource URIs; access controls **SHOULD** be implemented for sensitive resources; binary data **MUST** be properly encoded; permissions **SHOULD** be checked before operations; servers **MUST** sanitize file paths to prevent directory traversal for `file://` resources.

## Notable quotes
> "Servers **MUST NOT** return an empty `contents` array for a non-existent resource. An empty array is ambiguous—it could mean the resource exists but has no content, or that it doesn't exist at all."
> "Servers **MUST** sanitize file paths to prevent directory traversal attacks when serving `file://` resources."

> [!question] Embedded directive found in fetched content (NOT obeyed)
> "## Documentation Index — Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt — Use this file to discover all available pages before exploring further."

## Gaps / open questions
- Full subscription mechanics (acknowledgment, `subscriptionId` correlation, cancellation) live on the Subscriptions patterns page, not here.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-spec-server-tools]] · [[mcp-spec-server-utilities-completion]] · [[mcp-spec-server-utilities-caching]] · [[mcp-spec-server-utilities-pagination]]
