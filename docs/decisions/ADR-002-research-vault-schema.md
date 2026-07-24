# ADR-002 — Obsidian Research Vault Schema

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect
**Tags:** [architecture, knowledge, vault, self-improvement]
**Related:** ADR-001, `research-vault/SCHEMA.md`, PRD §10

## Contexto
The self-improvement loop (ADR-001) accumulates external knowledge about agent-team engineering across cycles. It must not re-litigate a decided idea (compounding), must stay human-navigable, and must not be confused with the-owl's existing **internal** wiki (`docs/wiki/`, source-grounded). We need a persistent store the `curator` owns.

## Decisão
Use an **Obsidian-native research vault** at `research-vault/`, adapting the proven `carinhAI` conventions:
- `SCHEMA.md` (operating manual), `index.md`, `log.md`, `overview.md`, `ledger.md`, and dirs `inbox/`, `sources/`, `patterns/`, `ideas/`.
- Conventions: YAML frontmatter · `[[wikilinks]]` (every page links ≥1) · `## Related` · callouts (`> [!contradiction]`, `> [!question]`, …).
- **`ledger.md` is the dedup source of truth** (`id | title | score | status | adr | first_seen | decided`); a decided `id` is skipped forever (new evidence → new suffixed id).
- `scout` writes `inbox/` + `sources/`; `curator` owns everything else.

## Alternativas consideradas
- **A (chosen): dedicated Obsidian vault.** Pros: human-navigable graph, compounding, dedup via ledger, markdown-only (fits the-owl). Cons: curator must maintain links (mitigated by the LINT workflow).
- **B: reuse `docs/wiki/`.** Pros: one store. Cons: mixes internal (source-grounded) with external (research) knowledge — rejected (different provenance, different trust).
- **C: a JSON/SQLite knowledge store.** Pros: queryable. Cons: not human-navigable, not Obsidian, over-engineered for a no-runtime markdown lib — rejected.

## Consequências
- **Easier:** knowledge compounds; no re-litigation; a maintainer can browse the graph in Obsidian.
- **Trade-offs:** curator carries link-hygiene (LINT); at 200+ ideas we revisit search tooling (SCHEMA scale guidance).

## Notas de implementação
Already scaffolded at `research-vault/` (US-006). `curator` is the sole writer of `sources/patterns/ideas/ledger/index/overview/log`; `scout` writes `inbox/`. Never merge into `docs/wiki/`.
