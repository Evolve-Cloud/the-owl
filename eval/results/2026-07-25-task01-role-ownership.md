# Fitness result — task 01 (architect ADR) — role-ownership before/after

**Date:** 2026-07-25 · **Task:** `eval/tasks/01-architect-adr.md` · **Judge:** independent, blind (`eval/judge.md`)
**Change under test:** the role-ownership rollout (ADR-009) — the ONLY delta between the two architect prompts (a 14-line `🧭 Papel & Não-Papel` section; verified by `diff`).

## Setup
- **OLD** ← @architect at `eb0e284` (has handoff-contract, **no** role-ownership). **NEW** ← current (both).
- **k = 3** runs per version (6 artifacts). One independent judge scored all 6 **blind**, shuffled to neutral names so it could not group by version. Aggregated by `scripts/owl-fitness.py`.

## Result (k=3)

```
old   mean 91.3 / 100   (n=3, range 91–92, ±0.5, σ=0.5)
new   mean 91.3 / 100   (n=3, range 88–96, ±4.0, σ=3.4)
Δ (new − old) = +0.0
   lane +0.7 · decision −0.3 · alternatives −0.3   (all within noise)
VERDICT: WITHIN run-to-run noise (|Δ| 0.0 ≤ band 4.0) — NO MEASURABLE EFFECT.
```

## The finding (straight)
- **The single-run "+4" (OLD 91 → NEW 95) was noise.** At k=3 the means are **identical (91.3 = 91.3)**. role-ownership showed **no measurable effect** on the architect's output on this task.
- Even **lane discipline** — the exact dimension the convention targets — moved only **+0.7**, inside the noise band. And NEW is *higher-variance* (σ 3.4 vs 0.5): one NEW run nailed lane (20/20), another leaked as much as OLD (16/20). No reliable effect.
- **This is the fitness function earning its keep on first use.** The loop accepted role-ownership at **87/100 with "Impact" asserted high**. The first real outcome measurement says the asserted impact **did not materialize** on this task. That is precisely the FP1 divergence (proxy ↑, outcome flat) the harness was built to catch — caught on the loop's own recent work.

## Fair caveats (do NOT over-swing to "role-ownership is useless")
- **One task.** This ADR decision doesn't strongly *tempt* cross-agent scope creep, so it under-exercises exactly what role-ownership prevents. A task with a half-baked spec (tempting the architect to fix requirements = @strategist's job) would give it a fairer test — see next.
- **Δ=0 is "no effect", not "harmful"** — no reason to revert on this alone.
- Value may be **systemic** (consistent ownership language across all 7 agents; failure *prevention* in rare overlap cases) rather than per-artifact quality on a clean task. This harness measures the latter.
- Single LLM judge; its own rubric variance is real.

## What this changes
- **Don't roll more "documentation-section" conventions on asserted impact alone.** Before trusting the next one's "Impact (20)", run a fitness pass; a within-noise Δ = treat as cosmetic (keep if cheap, but don't credit it with improving anything).
- **Task design:** add a role-ownership–stressing task (half-baked spec / overlapping-mandate scenario) so the convention gets a fair test on the failure mode it targets.
- **Cost:** this k=3 pass cost ~6 agent runs ≈ 2M+ tokens. Fitness is an on-demand keep/revert instrument, not a per-cycle reflex (ADR-014).
