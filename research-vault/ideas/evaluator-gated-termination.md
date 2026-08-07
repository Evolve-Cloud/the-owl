---
title: "Evaluator-gated termination (/goal): a grader re-checks the stop condition on every attempt to stop"
type: idea
tags: [eval, termination, runtime-shaped]
sources: 1
status: rejected
score: 45
adr: ""
updated: 2026-08-07
---
**Category:** self-improvement / eval · **Confidence:** high (on the fact) · **Applicability:** 1/5

## Pattern
`/goal <condition>, stop after N tries` — an evaluator model checks the user's stop condition **every time the agent tries to stop** and sends it back to work if unmet. Deterministic criteria work best; the turn cap rides in the invocation itself. Shipped Claude Code primitive, not a proposal.

## Proposed change to the-owl
None survives grounding — see below. Any concrete form lands inside the carve-out.

## L1.5 self-audit (ADR-005)
- `já_implementado?` **Substantially, three times over.**
  1. **Grader/rubric return-gate** — the ADR-014/015 fitness harness (blind judge, `scripts/owl-fitness.py`, k≥3). This is precisely why the ledger deferred `evaluator-optimizer-loop` at 68 on 2026-07-26, in its own words: the harness *"now substantially implements this; no further action needed, not a fresh gap."*
  2. **Blocking return-gate per cycle** — `/owl:evolve` **L4**: guardian + sentinel + challenger, independent, any FAIL ⇒ no commit.
  3. **Attempt caps** — `circuit_breaker.max_accepted_changes_per_cycle: 3` and `halt_on_consecutive_gate_failures: 3`.
- `onde_está_o_gap` The one genuinely novel bit is *re-checking the stop condition at each attempt to stop*. But the-owl's phases terminate on **artifact verification** (`/owl:evolve`: "toda fase declara um artefato esperado… se não existir, a fase FALHOU"), which is a stricter, deterministic test than an evaluator's judgement. The gap is real but the existing mechanism is arguably better for this system.
- `arquivo_alvo` **None that is carve-out-safe.** Termination policy lives in `.owl/loop-config.yml`; invocation lives in `scripts/owl-daily.sh` + the launchd schedule. **All three are NFR-SEC-1 carve-out** (ADR-001) — the loop must never edit them. An idea whose only landing site is the brake pedal has no admissible target.

## Curator verdict — score 45 (threshold 75, reject_below 60)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 8 | `/goal` is a **harness primitive**, not a markdown convention. Adopting it = "adopt runtime feature X" — the exact class already rejected as `isolated-workspaces` (41) and `parallel-independent-work` (52). the-owl is markdown-only, no-runtime. |
| Evidence strength (20) | 16 | Single first-party primary, but it documents a **shipped** primitive rather than a proposal. Strong for what it is; not multi-source. |
| Impact (20) | 6 | The function is already covered three ways (above); artifact-verification termination is stricter than evaluator judgement. |
| Simplicity & reversibility (15) | 6 | No atomic markdown edit exists. The change is to *how the loop is invoked*, which is not a prompt edit. |
| **Safety (10)** | **6** | **BELOW safety_floor 7 ⇒ HARD VETO.** Every concrete form targets the carve-out (`loop-config.yml` / `owl-daily.sh` / schedule). Delegating *when the loop is allowed to stop* to a model is the single change most corrosive to the brake pedal the carve-out exists to protect. |
| Non-duplication (10) | 3 | Alias of `evaluator-optimizer-loop` (68, deferred) + `explicit-termination-and-escalation` (68, deferred). Both decided. |

**Total 45 — rejected on two independent grounds:** the **Safety hard-veto** (6 < 7, non-overridable regardless of total) and 45 < `reject_below` 60. Per the curator HARD STOP, an idea whose `proposed_change` touches the carve-out is an automatic rejection plus a human alert — recorded here.

> [!note]
> **Correcting the scout's LIGHT read.** [[scout-notes-2026-08-07]] flagged that this may contradict the premise which pinned `evaluator-optimizer-loop` at 68 — stated there as "needs a runtime the-owl lacks". Grounding shows that was **not** the recorded reason: the ledger deferred it because the ADR-014/015 harness *already substantially implements it*. The "no runtime" reasoning belongs to `explicit-termination-and-escalation` (68), a different id. `/goal` being a shipped primitive therefore does **not** move the premise it was said to move. The flag was correctly raised (scout's job) and is correctly resolved here (curator's job) — **no contradiction, no re-litigation, `evaluator-optimizer-loop` stays deferred at 68 untouched.**

## Related
- **Sources:** [[claude-code-loops-getting-started]] · [[scout-notes-2026-08-07]]
- [[evaluation-and-fitness]] · [[explicit-termination-and-escalation]] · [[guardrails-and-safety]]
