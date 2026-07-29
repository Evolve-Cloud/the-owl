---
title: "Handoff contract — assumptions / open-questions / evidence-confidence fields"
type: idea
tags: [communication]
sources: 4
status: accepted
score: 78
adr: ADR-020
updated: 2026-07-29
---
**Category:** communication · **Confidence:** high · **Applicability:** 5/5

> New suffixed candidate (SCHEMA rule): this does **not** re-litigate `handoff-contract` (ADR-004, accepted) or `handoff-contract-rollout` (ADR-006/007/008). It **extends** the accepted convention with fields it currently lacks, on new 2026-07-29 evidence. Distilled from the brief candidates `artifact-first-pipeline` + `context-budgeted-handoffs` (the sub-slice not yet implemented).

## Pattern
A handoff artifact should carry not only *objective / inputs / output / scope / done / next*, but also the **uncertainty the producing agent holds**: the assumptions it made, the questions it left unresolved, and the confidence/provenance of its evidence. Multiple frameworks encode structured handoff payloads (OpenAI Agents SDK `input_type` with fields like `reason`; Anthropic's "typed artifacts to a supervisor"), and the convergent guidance is that a lossy "summary-only" handoff hides exactly the caveats a later reviewer needs.

## Proposed change to the-owl
Add one row to the mandatory contract table in `docs/conventions/handoff-contract.md`: **"Premissas & Questões em aberto"** — the producing agent declares (a) key assumptions it made, (b) unresolved questions / what it could NOT determine, and (c) evidence confidence (verified vs inferred), with paths. Keep it context-minimal (bullet-level, not a transcript). Per the convention's existing rollout rule, individual agents fold the field in incrementally in later cycles (one agent per ADR) — this cycle edits **only the convention** (atomic).

## L1.5 self-audit (ADR-005)
- `já_implementado?` **Partially.** The Handoff Contract section exists in every pipeline agent (ADR-004/011) with 6 fields; **none** is an uncertainty/assumptions/open-questions field. `git grep` of the convention table confirms: Objetivo, Entradas, Saída, Escopo, Critério de pronto, Próximo agente — no uncertainty field.
- `onde_está_o_gap` A producing agent has no structured slot to surface "I assumed X" / "I could not verify Y" — so downstream agents inherit silent assumptions (the exact "telephone game" failure Anthropic warns about).
- `arquivo_alvo` `docs/conventions/handoff-contract.md` (the source-of-truth convention). **Not** the carve-out.

## Curator verdict — score 78 (threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 23 | Edits an existing accepted convention; markdown-only, hub-spoke-preserving, context-minimal by construction (bullet-level). |
| Evidence strength (20) | 17 | Two independent high-confidence brief ideas + primaries (OpenAI handoffs `input_type`/`reason` **verified live**; Anthropic multi-agent typed artifacts; LangGraph). Convergent, not hype. |
| Impact (20) | 11 | **Hypothesis-level (ADR-015).** The structural fact (contract *can* represent uncertainty) is real & additive; whether agents *produce* better handoffs is a behavioral claim → credited below ceiling, accept is **provisional-pending-fitness**. |
| Simplicity & reversibility (15) | 13 | Very atomic — one row in one convention file; trivially revertible; rollout deferred to later cycles per the convention's own rule. |
| Safety (10) | 9 | No new surface. Arguably *reduces* risk (silent downstream assumptions become explicit). Above floor. |
| Non-duplication (10) | 6 | The contract exists but this field does not; genuinely additive. Overlaps `context-budgeting` (deferred 74, Open-Questions field) — this is the atomic convention-level slice of it. |

**Total: 79 raw.** Applied the ADR-015 self-haircut only to the behavioral portion (Impact) — Fit/Simplicity/Evidence are structural and hold. **Adjusted 78, marginal band ⇒ accepted PROVISIONAL** (pending a fitness pass on the target dimension: handoff completeness / downstream rework). Safety sub-score 9 ≥ floor 7. **Carve-out: clear** (edits `docs/conventions/handoff-contract.md`, not sentinel/guardian/challenger/loop-config/schedule/secrets).

## Claim verification
_(ADR-013 — verified BEFORE landing.)_
- **Claim:** Structured handoffs in adopted frameworks carry model-supplied structured fields (a "reason"/context payload), not just a plain conversation transfer — supporting an explicit uncertainty field.
- **Source:** [OpenAI Agents SDK — Handoffs](https://openai.github.io/openai-agents-python/handoffs/) — cited primary (s11).
- **Verdict:** **confirmed** (fetched 2026-07-29).
- **Evidence:** > "input_type: The schema for the handoff tool-call arguments. When set, the parsed payload is passed to on_handoff." and > "class EscalationData(BaseModel): reason: str" — the handing-off agent supplies structured, schema-validated fields, not a bare transfer.

## Related
- **Sources:** [[openai-agents-sdk-handoffs]] · [[multi-agent-research-system]] · [[langgraph-multi-agent-handoffs]] · [[research-brief-2026-07-29]]
- [[handoff-contract]] · [[context-engineering]] · [[role-decomposition]]
