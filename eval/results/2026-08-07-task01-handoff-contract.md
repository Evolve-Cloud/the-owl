# Fitness result — task 01 (architect ADR) — handoff-contract before/after

**Date:** 2026-08-07 · **Task:** `eval/tasks/01-architect-adr.md` · **Judge:** independent, blind (`eval/judge.md`)
**Change under test:** the `🤝 Contrato de Handoff` section in `@architect` — the ONLY delta between the two prompts (16 lines; verified by `diff`, 0 other changes).

## What this actually measures (read before quoting the number)

**Not ADR-004 alone.** The section as it exists today is the accumulation of **ADR-004** (the convention) → **ADR-006** (rolled into architect) → **ADR-020** (uncertainty fields) → **ADR-029** (that field's rollout, landed hours before this run). The measurement is of the **stack**, and it cannot attribute the delta to any single ADR. A per-ADR attribution would need three more variants and three more k=3 passes.

**Control held:** `🧭 Papel & Não-Papel` (role-ownership, ADR-009) is present in **both** variants — it is not the variable here, and it was measured separately on 2026-07-25.

## Setup
- **OLD** ← current `@architect` with the handoff section stripped (191 lines). **NEW** ← current, unmodified (207 lines).
- **k = 3** per version (6 artifacts). Producers ran as isolated subagents, given the task Input only — no rubric, no hints.
- One independent judge scored all 6 **blind**, shuffled to neutral names (`candidate_A…F`) in a separate directory so neither filename nor path revealed the version. Key held back until after scoring.
- Aggregated by `scripts/owl-fitness.py` under task label `01-architect-adr-handoff` (see *Harness finding* below for why the label is new).

## Result (k=3)

```
old   mean 85.7 / 100   (n=3, range 79–91, ±6.0, σ=5.0)
new   mean 96.7 / 100   (n=3, range 94–99, ±2.5, σ=2.1)
Δ (new − old) = +11.0
   handoff +5.3 · decision +3.3 · lane +1.3 · alternatives +0.7 · structure +0.3
worst-case min: old 79 · new 94   →  Δmin +15
VERDICT: EXCEEDS noise (|Δ| 11.0 > band 6.0) — real directional effect.
```

Per-run, unblinded:

| version | run | total | **handoff** /25 |
|---|---|---|---|
| old | 1 | 79 | 17 |
| old | 2 | 87 | 20 |
| old | 3 | **91** | 22 ← *leaked, see caveats* |
| new | 1 | 99 | **25** |
| new | 2 | 97 | **25** |
| new | 3 | 94 | **25** |

## The finding (straight)

- **The delta lands in the targeted dimension.** `handoff` moved **+5.3**, the largest per-dimension move, and the README's own rule is to trust the total only when the delta sits where the change aims. It does. The three orthogonal dimensions moved +1.3, +0.7, +0.3 — noise.
- **NEW saturates the dimension: 25/25 on all three runs.** OLD never reached it (17, 20, 22). The convention does not nudge handoff quality — it pins it at the rubric ceiling, every time.
- **It also tightens variance.** σ 5.0 → 2.1, and the worst case moves +15 (79 → 94). The reliability gain is larger than the mean gain — the convention's biggest effect is on the *bad* run, not the good one.
- **This is the first convention the harness has measured as working.** The comparison that matters is with its sibling: `role-ownership` (ADR-009), accepted at 87/100 with asserted impact, measured **Δ = 0.0** on this same task on 2026-07-25. Two conventions from the same era, same shape, same fixture — one is cosmetic on this task, the other is worth +11. **Asserted impact was wrong about one and right about the other, and only measurement could tell them apart.** That is the whole argument for ADR-014/015, now with a positive case and not just a negative one.
- **Prediction failed, in the useful direction.** Going in, the expectation — stated in the loop-health review — was Δ≈0, reasoning by analogy from role-ownership. The analogy was wrong. Recording it because a harness that only ever confirms the operator's guess is not measuring anything.

## Caveats (do NOT over-swing to "the whole convention stack is proven")

- **One OLD run leaked the convention.** `old_3` (the highest OLD score, 91, handoff 22/25) cited **ADR-004** and reproduced the uncertainty field — it read `docs/conventions/handoff-contract.md` from the repository, which the producers had read access to. **This biases Δ downward:** excluding it, OLD mean = 83.0 and **Δ = +13.7**. So **+11.0 is a floor, not a point estimate.** Two of three OLD runs were clean (0 mentions of ADR-004, 0 uncertainty field).
- **Protocol gap this exposes:** `eval/README.md` step 1 says the producer gets "nothing else in context — no hints, no rubric," but says nothing about **repository access**. A producer that can read `docs/conventions/` can recover a stripped convention. Any future before/after on a convention that is *also written down elsewhere* has the same hole. Fixing it means sandboxing the producer's filesystem, not just its prompt.
- **The dimension is saturated, so the effect size is censored.** NEW scored the maximum on all three runs; the instrument cannot say how much more the convention could deliver, only that it reaches the ceiling reliably. A harder handoff rubric would be needed to measure further.
- **Stack, not ADR.** See the top section — do not cite this as "ADR-004 is worth +11."
- **n=3, one task, one LLM judge.** Evidence, not proof. The judge's own per-dimension reasoning was consistent and cited text, which is reassuring but not independent.

## Harness finding — a task can only ever measure ONE convention

`scripts/owl-fitness.py` computes a delta only when a task label has **exactly two versions** (`if len(versions) == 2`). Task `01-architect-adr` already held `old`/`new` from the role-ownership pass, so adding a second pair under the same label would have silently switched the comparison **off** — four versions, no Δ, no error. Worked around by recording under a distinct label, `01-architect-adr-handoff`.

That is a workaround, not a fix. The clean version is a `change_under_test` field in the run record, with grouping on `(task, change)` — leaving the label to mean the fixture. Recorded here as a known limitation; not changed in this pass.

## What this changes

- **Impact credit for the handoff-contract stack is no longer provisional on this dimension.** ADR-004/006/020/029 have a measured outcome effect on the architect's ADR-writing. The ADR-015 "provisional-pending-fitness" flag on ADR-029 is **partially discharged** — partially, because ADR-029's own increment (the uncertainty row) is inside the stack and not separately isolated.
- **The asymmetry with role-ownership is the lesson.** Δ=0 and Δ=+11 from the same era and the same rubric means "documentation-section conventions don't move the needle" is **not** a general rule. Each one has to be measured; neither optimism nor pessimism generalizes.
- **Next measurement, if one is bought:** isolate ADR-029's uncertainty row alone (strip one table row rather than the whole section). That is the change with the largest instruction-surface cost landed today — 18 files — and it is the one still riding entirely on assertion.
- **Cost of this pass:** 6 producer runs + 1 judge ≈ **3.2M subagent tokens**, ~30 min wall-clock. Confirms the README's framing: fitness is an on-demand keep/revert instrument, not a per-cycle reflex.
