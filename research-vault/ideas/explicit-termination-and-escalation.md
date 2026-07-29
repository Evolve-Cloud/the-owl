---
title: "Explicit termination, escalation, and approval conditions per agent"
type: idea
tags: [safety]
sources: 3
status: deferred
score: 68
adr: ""
updated: 2026-07-29
---
**Category:** safety · **Confidence:** high · **Applicability:** 4/5

## Pattern
Give every agent explicit prompt sections — *Stop When / Escalate When / Do Not Decide / Approval Required* — with bounded iterations and evidence-insufficiency criteria, so a specialist returns control instead of looping speculatively. Escalations resolve at the orchestrator, not peer-to-peer.

## Proposed change to the-owl
Add a "Stop & Escalation Contract" section to every agent prompt (max review iterations, evidence-insufficiency triggers, conditions requiring human-owner input).

## L1.5 self-audit (ADR-005)
- `já_implementado?` **Partially.** Every agent has a "⛔ NUNCA FAÇA (HARD STOP)" role-boundary block; the **loop** has the strongest form at governance level (`circuit_breaker.halt_on_consecutive_gate_failures`, `max_accepted_changes_per_cycle`); escalation-to-human already exists via the carve-out ("rejeição automática + alerta ao humano"). Only `sentinel.md` matched a `grep` for escalate/stop/approval as an explicit contract.
- `onde_está_o_gap` No standardized *per-agent* "Stop When / Escalate When" section with max-iterations / evidence-insufficiency — those exit criteria are currently implicit in HARD STOP + role-ownership.
- `arquivo_alvo` all 8 agent `.md` files (a rollout, not one atomic edit).

## Curator verdict — score 68 (threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 19 | Expressible as prompt sections; but escalation-resolution is the orchestrator's job (already present) and it overlaps HARD STOP. |
| Evidence strength (20) | 17 | Strong & multi-framework — AutoGen termination conditions first-class (verified x1); Anthropic explicit stop conditions + retry-limit escalation (x2); OpenAI/Claude Code max-turns. |
| Impact (20) | 9 | Behavioral-claim (ADR-015). The strongest form already exists at the loop level; per-agent slice is marginal. x2 also warns escalation is "not a mechanism of productive recovery." |
| Simplicity & reversibility (15) | 9 | A cross-8-agent rollout (ADR-011 shape), not atomic. |
| Safety (10) | 9 | Improves; no new surface. |
| Non-duplication (10) | 5 | HARD STOP + circuit breaker + carve-out escalation already cover most of it. |

**Total 68 — below threshold ⇒ deferred.** Genuine, well-evidenced, but marginal and overlapping. Revisit if a concrete atomic slice emerges (e.g. a single "Stop When" line distilled into the handoff convention rather than a full per-agent rollout). Not a carve-out.

## Related
- **Sources:** [[microsoft-autogen]] · [[multi-agent-research-system]] · [[claude-code-subagents]] · [[research-brief-2026-07-29]]
- [[role-decomposition]] · [[handoff-contract]]
