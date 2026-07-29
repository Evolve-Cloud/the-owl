---
title: "Separate durable decisions from working memory (Memory Promotion)"
type: idea
tags: [memory]
sources: 3
status: deferred
score: 64
adr: ""
updated: 2026-07-29
---
**Category:** memory · **Confidence:** high · **Applicability:** 4/5

## Pattern
Persist only stable, reviewable knowledge (ADRs, accepted interfaces, eval outcomes); treat transcripts, notes, and unverified hypotheses as ephemeral unless promoted through an explicit decision step. Add a "Memory Promotion" section (status, rationale, scope, supersession link, source) to chronicler/architect.

## L1.5 self-audit (ADR-005)
- `já_implementado?` **Largely, de facto.** the-owl already uses **ADR-as-sole-promotion-path** — every change lands as an ADR; the vault `ledger.md` has an explicit `status` field (accepted/deferred/rejected/quarantined) that separates decided from pending; `SCHEMA.md` marks `inbox/` immutable and unverified ideas `(pending)`. This *is* durable-vs-working separation.
- `onde_está_o_gap` No explicit prose "Memory Promotion" section in chronicler/architect naming supersession-link + provenance as a required promotion step — but the mechanism exists.
- `arquivo_alvo` `chronicler.md` + `architect.md`.

## Curator verdict — score 64 (threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 19 | Markdown convention; fits, but the mechanism already exists. |
| Evidence strength (20) | 14 | Decent primaries (Anthropic memory/evals, LangGraph persistence). |
| Impact (20) | 8 | Behavioral (ADR-015); ADR-discipline + ledger status already deliver the outcome. Marginal. |
| Simplicity & reversibility (15) | 9 | Two-agent rollout. |
| Safety (10) | 9 | No new surface. |
| Non-duplication (10) | 5 | Substantially implemented (ADR-as-promotion + ledger status). |

**Total 64 — below threshold ⇒ deferred.** The-owl already separates durable decisions (ADRs + ledger) from working memory (inbox/transcripts). Revisit only if a concrete failure of silent-promotion is observed. Not a carve-out.

## Related
- **Sources:** [[langgraph-persistence]] · [[multi-agent-research-system]] · [[anthropic-demystifying-evals]] · [[research-brief-2026-07-29]]
- [[context-engineering]]
