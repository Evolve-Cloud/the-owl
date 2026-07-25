---
title: "Explicit Handoff Contract per agent"
type: idea
tags: [communication, roles]
status: accepted
score: 91
adr: ADR-004
updated: 2026-07-23
---

**Category:** communication · **Confidence:** high · **Applicability:** 5/5

Merge of codex ideas `explicit-role-boundaries` + `deterministic-handoff-contracts`, corroborated by scout's live research (Anthropic's asymmetric summary-based subagent handoff; the grader/rubric return-gate).

## Pattern
Every agent declares an explicit **handoff contract**: what it receives, what it returns, and the done-criteria — so a handoff is a structured state transition, not an informal message. Widely adopted (CrewAI role agents, AG2 coder/reviewer, MetaGPT SOP roles) and is exactly how Claude Code subagents already work (in = delegation + context; out = a single structured summary).

## Proposed change to the-owl
Adopt a standardized **"Contrato de Handoff"** convention (`docs/conventions/handoff-contract.md`) defining the required fields of every agent handoff (Objetivo · Entradas · Saída · Escopo · Critério de pronto · Próximo agente). Roll it into individual agents in subsequent cycles (incremental).

## Curator verdict — score 91 (accept; threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 25 | Pure convention change; hub-spoke + context-minimal native. |
| Evidence strength (20) | 18 | Anthropic primary + CrewAI/AG2/MetaGPT + scout live corroboration. Star counts conflict → not full. |
| Impact (20) | 17 | Clearer handoffs cut ambiguity/rework; incremental (doc first, agents later). |
| Simplicity & reversibility (15) | 13 | One convention doc + one ADR; atomic, trivially revertible. |
| Safety (10) | 10 | No attack surface; does NOT touch the NFR-SEC-1 carve-out. |
| Non-duplication (10) | 8 | the-owl has implicit handoffs (some agents) but no standardized contract. |

**Safety sub-score 10 ≥ floor (7).** No carve-out contact. → **ACCEPTED.**
Challenger caveat (non-blocking): a convention not yet applied to agents has deferred impact → tracked as a follow-up for the next cycle.

## Related
- **Sources:** [[anthropic-building-effective-agents]] · [[langgraph]] · [[ag2]] · [[microsoft-autogen]] · [[openai-agents-sdk-handoffs]] · [[langgraph-multi-agent-handoffs]] · [[metagpt]]
- [[scout-notes-2026-07-23]] · [[research-brief-2026-07-23]] (codex, w1–w4)
