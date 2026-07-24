# ADR-005 — Gap Analysis: score ideas against the-owl's own code

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect (human-driven improvement to the loop)
**Tags:** [self-improvement, grounding, curation, loop-machinery]
**Related:** ADR-001, ADR-003, `.claude/commands/agents/curator.md`, `.claude/commands/owl/evolve.md`

## Contexto
Cycle 1 proved the loop ingests good ideas from the field and scores them. But the "analyze against our code" part was **implicit**: the curator's rubric weighs *Fit to our architecture* and *Non-duplication*, yet nothing told it to actually **read the-owl's current agents** first. Ideas were judged somewhat in the abstract — it could accept an idea already implemented, or miss the exact place an agent falls short. The maintainer asked for the loop to explicitly analyze new ideas against our actual code. the-owl already has an internal code map — `knowledge-graph.json` + `docs/wiki/` — that `@guardian` uses for Diff-Impact; reuse it rather than build a new index.

## Decisão
Add an explicit **self-audit / gap-analysis step (L1.5)** to every cycle, owned by `@curator`, run **before** scoring:
- Read the-owl's real current state — prefer the internal map (`knowledge-graph.json` + `docs/wiki/`); fall back to the raw files (`.claude/commands/agents/*.md`, `docs/conventions/`).
- For each candidate, produce three concrete answers: **`já_implementado?`** · **`onde_está_o_gap`** · **`arquivo_alvo`**.
- Feed them into the rubric (grounds *Fit* and *Non-duplication* in reality) and pass `arquivo_alvo` to `@builder` so the edit targets the exact gap, not a generic location.

## Alternativas consideradas
- **A (chosen): explicit audit step reusing the existing internal map.** Pros: grounds acceptance in reality, targeted edits, zero new tooling (reuse the knowledge-graph/wiki). Cons: slightly more work per cycle; depends on the map being reasonably current (chronicler maintains it; raw-file fallback covers staleness).
- **B: build a dedicated code-analysis index/tool for the loop.** Pros: purpose-built. Cons: reinvents the knowledge-graph the-owl already has — rejected (over-engineering, violates reuse-before-create).
- **C: keep it implicit in the rubric.** Pros: no change. Cons: exactly the abstract, ungrounded scoring we are fixing — rejected.

## Consequências
- **Easier:** every accepted idea is grounded in the real gap; the builder edits the right file; duplicates are caught before scoring.
- **Trade-offs:** one extra read per cycle; relies on the internal map (with a raw-file fallback). If the map is stale, the audit still works from files.

## Notas de implementação
Edited `.claude/commands/agents/curator.md` (flow step 0 + audit fields in the verdict + handoff carries `arquivo_alvo`) and `.claude/commands/owl/evolve.md` (explicit **L1.5** before L2; L3 builder targets `arquivo_alvo`). Human-driven change → committed to `main` (not an autonomous proposal). The audit reads code but the loop's edits remain gated by the L4 gate + carve-out.
