# ADR-003 — Rigor Rubric for Accepting Improvements

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect
**Tags:** [architecture, rigor, self-improvement, safety]
**Related:** ADR-001, `.owl/loop-config.yml`, PRD §9

## Contexto
The maintainer's bar: *"don't accept everything without questioning; approve only if it really makes sense; be more rigorous as the agents evolve."* The `curator` needs a consistent, tunable, ratcheting acceptance gate — not ad-hoc "is this good?" judgment.

## Decisão
A **weighted 0–100 rubric** applied by `curator`:

| Criterion | Weight |
|---|---|
| Fit to our architecture (markdown-only, no-runtime, hub-spoke, context-minimal) | 25 |
| Evidence strength (multiple high-star repos / primary sources, not hype) | 20 |
| Impact (materially better quality / coordination / token-efficiency) | 20 |
| Simplicity & reversibility (small, atomic, no new runtime) | 15 |
| Safety (no new attack surface; respects §7 governance) | 10 |
| Non-duplication | 10 |

- **Accept** ≥ `threshold` · **Defer** below it · **Reject** < `reject_below` (60).
- **Ratchet:** `threshold` starts **75**, rises **+5 per minor version**, cap **90**.
- **Hard safety veto:** Safety sub-score < `safety_floor` (7) ⇒ auto-reject regardless of total. Non-overridable.
- Values live in `.owl/loop-config.yml`. The `safety_floor` and the threshold config sit **inside the NFR-SEC-1 carve-out** — the loop cannot lower its own bar.

## Alternativas consideradas
- **A (chosen): weighted rubric + ratchet + veto.** Pros: consistent, tunable, gets stricter as the lib matures, hard safety floor. Cons: weights need occasional human recalibration.
- **B: free LLM judgment ("is this a good idea?").** Pros: zero config. Cons: inconsistent, no ratchet, no auditable score — rejected.
- **C: fixed threshold, no ratchet.** Pros: simplest. Cons: doesn't honor "more rigorous as agents evolve" — rejected.

## Consequências
- **Easier:** auditable accept/defer/reject with a written rationale per idea; a healthy accept-rate band is measurable (a KPI).
- **Trade-offs:** weight/threshold recalibration is a periodic human task; a great idea with weak public evidence may be *deferred* (revisit), not lost.

## Notas de implementação
`curator` applies this each cycle (dedup → score → veto → classify), records the breakdown in `ideas/<id>.md`, and updates `ledger.md`. Changing weights/threshold/floor is human-only (carve-out).
