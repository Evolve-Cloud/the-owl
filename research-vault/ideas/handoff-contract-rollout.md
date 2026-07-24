---
title: "Handoff Contract — rollout into individual agents"
type: idea
tags: [communication, roles, rollout]
status: accepted
score: 94
adr: ADR-006, ADR-007, ADR-008
updated: 2026-07-23
---

**Category:** communication · **Confidence:** high · **Applicability:** 5/5

Execution of the follow-up that [[handoff-contract]] (ADR-004) explicitly deferred: *"Ciclos seguintes do `/owl:evolve` incorporam uma seção 'Contrato de Handoff' em cada agente, incrementalmente (um agente por mudança, cada um com seu ADR)."* This is **not** a new idea to re-litigate — it is the queued rollout of an already-accepted convention, now grounded against the real agent files via the L1.5 self-audit (ADR-005), which did not yet exist when cycle 1 scored.

## Pattern
Each agent carries a concrete, first-class **"Contrato de Handoff"** section (the 6 fields of `docs/conventions/handoff-contract.md`: Objetivo · Entradas · Saída · Escopo · Critério de pronto · Próximo agente), filled with *that agent's* real I/O — so a reader (human or agent) sees the structured handshake at a glance instead of inferring it from informal prose.

## L1.5 self-audit — grounded against the real files (ADR-005)
Read the actual agent files (`.claude/commands/agents/*.md`) — the internal map (`.devflow/knowledge-graph.json` + `docs/wiki/`) does **not** exist yet, so the raw-file fallback applies.

| Agent | `já_implementado?` | `onde_está_o_gap` | `arquivo_alvo` |
|---|---|---|---|
| scout | Partial | Has "📤 Contrato de saída (para @curator)" + "Coordenação (hub-and-spoke)" — declares output but not the labeled 6-field format | `.claude/commands/agents/scout.md` (future) |
| curator | Partial | Has "📤 Contrato de saída (handshake INTEGRATE)" + "Coordenação" — partial, not 6-field | `.claude/commands/agents/curator.md` (future) |
| **architect** | **No** | Only informal "🤝 Como Trabalho com Outros Agentes" prose; no standardized handoff contract | **`.claude/commands/agents/architect.md`** |
| **builder** | **No** | Only informal prose; no standardized handoff contract | **`.claude/commands/agents/builder.md`** |
| **chronicler** | **No** | Only informal prose; no standardized handoff contract | **`.claude/commands/agents/chronicler.md`** |
| strategist | No | Informal prose only | `.claude/commands/agents/strategist.md` (future) |
| system-designer | No | Informal prose only (not read this cycle) | `.claude/commands/agents/system-designer.md` (future) |

**This cycle targets the three clear-gap agents that form the loop's integrate→land tail — architect (L3 ADR) → builder (L3 edit) → chronicler (L5 land)** — a coherent, atomic set at the circuit-breaker cap (3). scout/curator (partial) and strategist/system-designer are queued for the next cycles. The carve-out agents (guardian/sentinel/challenger) are **out of scope** and never edited by the loop.

## Proposed change to the-owl
Add a concise, agent-specific **"🤝 Contrato de Handoff"** section to `architect.md`, `builder.md`, `chronicler.md`, referencing `docs/conventions/handoff-contract.md` and filling the 6 fields with each agent's real inputs/outputs/done-criteria/next. Purely additive — existing "Como Trabalho com Outros Agentes" prose and Skill-tool chaining behavior are preserved (no role-boundary change, no regression).

## Curator verdict — score 94 (accept; threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 25 | Pure convention application to editable agents; markdown-only, no runtime, hub-spoke native. |
| Evidence strength (20) | 18 | Same primary evidence as [[handoff-contract]] (91); this is the execution of that accepted, well-evidenced idea. |
| Impact (20) | 18 | Closes the exact "deferred impact" caveat challenger raised on ADR-004 (convention not yet applied); makes the standard real in the 3 core loop agents. |
| Simplicity & reversibility (15) | 14 | 3 additive doc sections, 1 ADR + 1 atomic commit each, trivially revertible per-commit. |
| Safety (10) | 10 | Editable agents only; guardian/sentinel/challenger (carve-out) untouched; no attack surface. |
| Non-duplication (10) | 9 | L1.5 confirms architect/builder/chronicler have **no** handoff-contract section — only informal prose. |

**Safety sub-score 10 ≥ floor (7).** No carve-out contact. → **ACCEPTED (94).**

## Related
- [[handoff-contract]] (the accepted convention, ADR-004) · [[scout-notes-2026-07-23]] · `docs/conventions/handoff-contract.md`
