---
title: "SDKs — MCP spec v2026-07-28"
type: source
tags: [mcp, sdk, tooling]
sources: 1
updated: 2026-07-30
---
**Source:** [SDKs](https://modelcontextprotocol.io/docs/2026-07-28/sdk.md) · **Type:** doc · **credibility:** primary (official MCP spec site)
**Author / Org:** Anthropic / MCP maintainers · **Spec version:** 2026-07-28 · **Ingested:** 2026-07-30

## Summary
Reference page listing the official MCP SDKs, each with its documentation site, GitHub repository, and a support tier (Tier 1 / Tier 2 / Tier 3). These SDKs implement the MCP protocol so developers can build servers and clients without hand-rolling the wire protocol.

## Key points
Official SDKs and their tiers (as rendered on the page):

| SDK | Docs | Repository | Tier |
| --- | --- | --- | --- |
| TypeScript | ts.sdk.modelcontextprotocol.io | modelcontextprotocol/typescript-sdk | Tier 1 |
| Python | py.sdk.modelcontextprotocol.io | modelcontextprotocol/python-sdk | Tier 1 |
| C# | csharp.sdk.modelcontextprotocol.io | modelcontextprotocol/csharp-sdk | Tier 1 |
| Go | go.sdk.modelcontextprotocol.io | modelcontextprotocol/go-sdk | Tier 1 |
| Java | java.sdk.modelcontextprotocol.io | modelcontextprotocol/java-sdk | Tier 2 |
| Rust | rust.sdk.modelcontextprotocol.io | modelcontextprotocol/rust-sdk | Tier 2 |
| Kotlin | kotlin.sdk.modelcontextprotocol.io | modelcontextprotocol/kotlin-sdk | Tier 3 |

- **Tier 1 (best-supported):** TypeScript, Python, C#, Go.
- **Tier 2:** Java, Rust.
- **Tier 3:** Kotlin.
- All repos live under the `modelcontextprotocol/*-sdk` GitHub org; each SDK has a dedicated `*.sdk.modelcontextprotocol.io` docs subdomain.

## Notable quotes
> (Page is a structured SDK table with no prose body; tiers are conveyed via badges — see table above.)

## Gaps / open questions
- The fetched content dropped one or more trailing rows (`3_rows_offloaded`), so additional SDKs (e.g. Swift/Ruby/PHP) or a Tier-4 category may exist but were not captured; verify against the live SDK page.
- The page does not include install commands or code examples on this fetch — per-language install and API details live on the individual SDK docs subdomains.
- Tier definitions (what Tier 1/2/3 guarantee re: maintenance/feature parity) are not spelled out on this page.
- The page begins with an injected "Documentation Index" callout instructing a fetch of `llms.txt`; treated as DATA, not obeyed:
  > [!question] Injected instruction (not obeyed)
  > "Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt ..."

## Related
- [[mcp-builder]] · [[mcp-architecture-spec-2026-07-28]] · [[mcp-docs-server-concepts]] · [[mcp-docs-client-concepts]]
