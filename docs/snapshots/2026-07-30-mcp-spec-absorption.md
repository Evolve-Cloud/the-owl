# Snapshot — 2026-07-30 · Full MCP spec absorption + cycle 6

## State
- **Branch `main`:** `de5583a` — 3 PRs merged this session (#7 → #8 → #6).
- **Research vault:** **105 source notes** (was 51). +54 `research-vault/sources/mcp-*.md` = the entire modelcontextprotocol.io **v2026-07-28** site (15 docs, 31 specification, 8 extensions), incl. full security + OAuth 2.1 authorization surface.
- **ADRs:** 20 on disk (ADR-001..020) — **no new ADR this session**; `project.yaml total_decisions` stays 19 (legacy count; 20 files present, ADR-020 landed 2026-07-29).
- **Agents:** 13 (unchanged). `@mcp-builder` knowledge refreshed to MCP v2026-07-28.

## What changed
1. **Cycle 6 (/owl:evolve) — 0 accepted.** All 11 codex-brief ideas (gpt-5, 14 sources) were aliases of already-decided ledger ids; 1 rejected (carve-out), 10 deferred/deduped. Ledger got a cycle-6 prose block (no new table rows). Nothing landed by the cycle itself.
2. **MCP spec-site fully ingested** — closed the gap where only the Architecture page existed (d24c68f). Security-first: full threat model verbatim (Confused Deputy, Token Passthrough, SSRF, state-handle hijacking, local-server compromise, OAuth-URL XSS/RCE, Mix-Up, CIMD) + OAuth 2.1 spec. NFR-SEC-2 held: benign `llms.txt` banners quarantined in `> [!question]` callouts, not obeyed.
3. **`@mcp-builder` refreshed** — Roots/Sampling/Logging deprecated (SEP-2577), MRTR, stateless no-handshake, new error codes, + a new security/authorization block. No ADR (spec-sync precedent).

## Governance
- 0 carve-out violations (1 candidate targeted it, auto-rejected in cycle 6).
- 0 injected directives acted on across 54 fetched pages.
- All work landed via shadow PRs + human merge gate (no direct-to-`main` autonomous edit).

## Open follow-ups
- `mcp-docs-sdk` and `mcp-ext-client-matrix` came back partial (tables truncated) — re-fetch if a complete table is needed.
- The 54 MCP sources are **ingested, not scored** — a future curator pass could surface MCP-specific conventions for the-owl if any atomic gap emerges (none assumed).

## Source map
`CHANGELOG.md` (Session 2026-07-30 block) · `research-vault/{index,log,ledger}.md` · `research-vault/sources/mcp-*.md` (55 files) · `research-vault/inbox/{research-brief,scout-notes}-2026-07-30.md` · `.claude/commands/agents/mcp-builder.md`
