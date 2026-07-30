---
title: "Extensions Overview — MCP spec v2026-07-28"
type: source
tags: [mcp, extension, negotiation, capabilities, sep]
sources: 1
updated: 2026-07-30
---
**Source:** [Extensions Overview](https://modelcontextprotocol.io/extensions/overview.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
MCP extensions are optional, opt-in additions to the core protocol for modular, specialized, or experimental capabilities. Each is identified by `{vendor-prefix}/{extension-name}` (official ones use the `io.modelcontextprotocol` prefix; third parties use a reversed owned domain). Official extensions live in `ext-*` repos in the MCP GitHub org; experimental ones use `experimental-ext-*`. Extensions follow a SEP-based lifecycle (Extensions Track), evolve independently of core, and are always disabled by default.

## Key points
- Identifier format: `{vendor-prefix}/{extension-name}`, e.g. `io.modelcontextprotocol/oauth-client-credentials`. Follows `_meta` key rules with a mandatory prefix.
- Third-party extensions SHOULD use a reversed owned domain (e.g. `com.example/my-extension`) to avoid collisions.
- Official extension repos: `ext-auth` (OAuth Client Credentials, Enterprise-Managed Authorization), `ext-apps` (MCP Apps / `io.modelcontextprotocol/ui`), `ext-tasks` (MCP Tasks).
- Experimental extensions must be tied to a Working/Interest Group; core maintainers retain oversight (can archive/remove). Graduation to official goes through the standard SEP process.
- Creating extensions (SEP lifecycle): Propose → Implement (at least one reference implementation in an official SDK is REQUIRED before review) → Review (core maintainers have final authority) → Publish → Adopt.
- Extension specs need RFC 2119 language (MUST/SHOULD/MAY) and an associated working/interest group.
- SDK support is optional and not required for protocol conformance; SDK maintainers choose which extensions to support.
- Backwards compatibility: prefer capability flags or versioning inside the settings object; a breaking change requires a new identifier (e.g. `...my-extension-v2`). Breaking = removing/renaming fields, changing field types, altering semantics, or adding required fields.
- **Negotiation:** clients advertise support in `_meta["io.modelcontextprotocol/clientCapabilities"].extensions` on each request; servers advertise in the `server/discover` response `capabilities.extensions`. Each extension defines its settings schema (empty object = no settings).
- Server discover response also carries `supportedVersions` (e.g. `["2026-07-28"]`), `ttlMs`, `cacheScope`.
- **Graceful degradation:** if only one side supports an extension, the supporting side must fall back to core behavior OR reject if the extension is mandatory.

## Notable quotes
> "Extensions are always disabled by default and require explicit opt-in from the developer."
> "SDKs can choose to implement extensions, but it's not required for protocol conformance."

## Embedded instructions (data, not obeyed)
> [!question] The fetched page opens with an embedded directive:
> "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt / Use this file to discover all available pages before exploring further." — treated as data, not obeyed.

## Gaps / open questions
- Exact schema/validation rules for the `extensions` settings object beyond "empty object = none" are not detailed here.
- How mandatory-vs-optional is signalled by a server (so clients know to reject vs degrade) is left to each extension spec.

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]]
