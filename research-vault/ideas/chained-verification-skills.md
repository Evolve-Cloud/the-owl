---
title: "Chained verification skills — one skill invokes the next at completion"
type: idea
tags: [orchestration, eval, pipeline]
sources: 1
status: rejected
score: 50
adr: ""
updated: 2026-08-07
---
**Category:** orchestration / eval · **Confidence:** med · **Applicability:** 2/5

## Pattern
One skill invokes the next on completion, forming a fixed sequence — the source reports the Claude Code team's daily chain as `/code-review` → `/simplify` → `/verify` → a `/design` check when UI changed. Chaining also **wraps skills you cannot edit** (built-in/plugin skills are overwritten on update, so you chain rather than embed). Four escalating invocation patterns: standalone → embedded → chained → on-every-PR. Stated trade-off: chaining trades flexibility for automation and can raise token spend.

## Proposed change to the-owl
None survives grounding — already embodied twice, and the remaining delta is gate governance.

## L1.5 self-audit (ADR-005)
- `já_implementado?` **Yes, twice.**
  1. `/owl:evolve` **L4** is exactly a fixed blocking chain: guardian → sentinel → challenger, independent, any FAIL ⇒ no commit. That is the "chained" pattern with a stronger contract than the source's (blocking, not advisory).
  2. The `/quick:*` commands are stage chains, and `/owl:evolve` L0→L5 is a deterministic staged pipeline with per-phase artifact verification.
  The ledger already records this: `sequential-artifact-pipeline` (68, deferred) — *"embodied in /quick:\* + /owl:evolve stage gates"*.
- `onde_está_o_gap` Only the **on-every-PR** escalation is not present. But running the gate on every PR = changing *when guardian/sentinel/challenger fire* = **governance of the gate**.
- `arquivo_alvo` `/owl:evolve` L4 — carve-out territory. `adversarial-review-gate` was **rejected on 2026-07-29 for precisely this** (materiality thresholds on the closure gate = NFR-SEC-1) and the rejection was re-confirmed on 2026-07-30 when it resurfaced as `independent-adversarial-review`. This is its third appearance.

## Curator verdict — score 50 (threshold 75, reject_below 60)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 12 | Chain-as-markdown fits the-owl well in principle — which is why the-owl already has it. The remaining delta is gate governance, which does not fit at all. |
| Evidence strength (20) | 15 | Single first-party primary, reporting real internal team practice. Credible; not multi-source. |
| Impact (20) | 5 | Already embodied twice, in a stricter (blocking) form than the source describes. |
| Simplicity & reversibility (15) | 8 | The non-carve-out reading has no concrete edit left to make; the carve-out reading is inadmissible. |
| Safety (10) | 7 | **Exactly at safety_floor.** Scored on the non-carve-out reading (registering the pattern). The on-every-PR slice is separately auto-rejected as gate governance. |
| Non-duplication (10) | 3 | Alias of `sequential-artifact-pipeline` (68, deferred) and, in its net-new slice, of `adversarial-review-gate` (**rejected**). |

**Total 50 < `reject_below` 60 ⇒ rejected — for duplication, not for being wrong.** The pattern is sound and the-owl independently arrived at a stronger version of it. Third appearance of the gate-governance slice; not re-opened.

## Related
- **Sources:** [[claude-code-verification-loops-skills]] · [[scout-notes-2026-08-07]]
- [[handoff-and-orchestration]] · [[adversarial-review-gate]] · [[single-agent-coding-loops]]
