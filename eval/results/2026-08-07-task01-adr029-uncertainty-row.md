# Fitness result — task 01 — ADR-029's uncertainty row, isolated

**Date:** 2026-08-07 · **Task:** `eval/tasks/01-architect-adr.md` · **Judge:** independent, blind (`eval/judge.md`)
**Change under test:** `adr029-uncertainty-row` — **one table row** in `@architect`'s handoff contract (`| **Premissas & Questões em aberto** | … |`). Verified by `diff`: the variable is **exactly 1 line**; the handoff section and its other 6 fields are present in both variants.

This is the follow-up the 2026-08-07 handoff-contract result named as the next thing worth buying: ADR-029 spent instruction surface across **18 files** on a purely asserted impact, and it was the largest un-measured cost of that day.

## Setup
- **no-row** ← current `@architect` minus that single row (the state before ADR-029). **with-row** ← current, unmodified.
- **k = 3** per version, judged blind together, shuffled to `item_A…F` in a separate directory.
- **A sub-judgement was requested separately from the rubric:** *does the artifact declare the producing agent's own uncertainty — assumptions, what it could not determine, verified vs inferred evidence?* (`yes`/`partial`/`no`). The judge was instructed that this **must not change any of the five scores**. That separation is what makes it usable as an independent check on the mechanism.

## Result (k=3)

```
no-row     mean 92.0 / 100   (n=3, range 91–93, ±1.0, σ=0.8)
with-row   mean 95.3 / 100   (n=3, range 94–97, ±1.5, σ=1.2)
Δ (with-row − no-row) = +3.3
   handoff +1.3 · lane +1.3 · decision +0.7 · alternatives +0.3 · structure −0.3
worst-case min: no-row 91 · with-row 94   →  Δmin +3
VERDICT: EXCEEDS noise (|Δ| 3.3 > band 1.5) — real directional effect.
```

| version | run | total | handoff /25 | **declares own uncertainty** |
|---|---|---|---|---|
| no-row | 1 | 92 | 24 | partial |
| no-row | 2 | 93 | 23 | partial |
| no-row | 3 | 91 | 23 | partial |
| with-row | 1 | 97 | 25 | **yes** |
| with-row | 2 | 95 | 24 | **yes** |
| with-row | 3 | 94 | 25 | **yes** |

## The finding (straight)

- **The categorical result is cleaner than the numeric one: 3/3 `yes` vs 3/3 `partial`, perfect separation, zero overlap.** The row does precisely what it claims — it makes the agent state what it assumed and what it could not verify. Every `with-row` artifact carries an explicit grounding statement; the judge quoted, e.g., *"this Context is built from the stated facts only. No line of `checkout-api` or `inventory-svc` was read."* The `no-row` artifacts all named *some* open question (an `Assumption` block, `Open Items`), but none characterized their **evidence confidence** — which is the third of the field's three parts and the one that consistently went missing without it.
- **The numeric delta is small but clears its band by 2.2×.** +3.3 on a 100-point scale is modest in absolute terms, and the band is tight (1.5) because both groups were consistent. Read this as *a real, small, reliable effect*, not a large one.
- **It shows up where it should.** `handoff` +1.3 and `lane` +1.3 are the two largest per-dimension moves, and handoff is the dimension the field belongs to. `structure` moved −0.3 — the row costs a little concision, which is the honest price.
- **The behaviour is not free without the field.** All three `no-row` runs volunteered uncertainty in *some* shape. The row's contribution is not "makes the agent think about assumptions" — it is **standardizing where they go and completing the third part (evidence confidence)** that otherwise gets dropped.

## Contamination check (required by `eval/README.md`, ADR-032)

| artifact | cites ADR-004 | reproduced the exact row |
|---|---|---|
| no-row 1 | 1 | **0** |
| no-row 2 | 2 | **0** |
| no-row 3 | 1 | **0** |
| with-row 1 | 0 | 0 |
| with-row 2 | 1 | 1 |
| with-row 3 | 2 | 1 |

**5 of 6 producers read the repository** and cited ADR-004 — the leak found on the previous pass recurs, as predicted. **But the treatment was not restored: 0 of 3 `no-row` artifacts reproduced the field row.** Reading the convention did not put the removed row back, so this comparison is clean on its variable in a way the previous one was not.

**One anomaly worth recording:** `with-row 1` did **not** emit the literal table row (0) yet was scored `yes` on declaring uncertainty and took the highest total (97). So the treatment operates at the level of *the instruction being present in the prompt*, not of the field being copied verbatim into the artifact. That is the right reading of the mechanism, and it means the effect would have been invisible to a check that only grepped artifacts for the field.

## Caveats

- **n=3, one task, one LLM judge.** Evidence, not proof. The tight band makes "exceeds noise" easier to reach than on a noisy fixture — a 1.5-point band is a low bar, and it should be read alongside the effect's small absolute size.
- **The sub-judgement is one judge's categorical call**, not an independent instrument. Its value is that it was declared out-of-scope for scoring *before* scoring, so it could not have been reverse-engineered from the totals.
- Measures the row **in `@architect` only**. ADR-029 rolled it to 9 agents × 2 copies; the other 8 are untested and inherit this evidence by analogy — which is exactly the reasoning that failed when role-ownership's Δ=0 was generalized from.

## What this changes

- **ADR-029's provisional flag is discharged for `@architect`.** The row has a measured effect on the dimension it targets and a clean categorical effect on the behaviour it names. The 18-file rollout is no longer riding on assertion — for one of the nine agents.
- **The revert condition in `docs/conventions/handoff-contract.md` should be read against this.** It says: if three cycles pass with every agent writing an empty uncertainty row, the field is ceremony. That test still stands and is *not* answered here — this measures whether the field changes what the agent produces, not whether agents keep filling it in over time.
- **The `declares_uncertainty` sub-judgement is a reusable pattern.** Asking the judge a categorical question that is explicitly excluded from scoring gave a cleaner signal than the rubric did. Worth reaching for whenever a convention targets a behaviour the rubric only measures indirectly.
- **Cost:** 3 producers + 1 judge ≈ **1.8M subagent tokens** (half the previous pass, by reusing the three `with-row` artifacts already produced and re-judging all six together).
