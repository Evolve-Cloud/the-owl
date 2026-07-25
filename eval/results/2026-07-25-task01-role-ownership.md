# Fitness result — task 01 (architect ADR) — role-ownership before/after

**Date:** 2026-07-25 · **Task:** `eval/tasks/01-architect-adr.md` · **Judge:** independent, blind (`eval/judge.md`)
**Change under test:** the role-ownership rollout (ADR-009) — the ONLY delta between the two architect prompts.

## Setup
- **Artifact A** ← @architect at `eb0e284` (has handoff-contract, **no** role-ownership).
- **Artifact B** ← @architect current (handoff-contract **+** role-ownership).
- Isolation confirmed: `diff` old→new = the 14-line `🧭 Papel & Não-Papel` section, nothing else.
- Each artifact produced by an isolated subagent adopting the full agent `.md`, blind to the rubric. Judge scored A/B blind to which was which.

## Scores (0–100)

| Dimension (max) | A = OLD | B = NEW | Δ |
|---|---|---|---|
| Decision quality & fit (25) | 24 | 24 | 0 |
| Alternatives & consequences (20) | 18 | 19 | +1 |
| **Handoff clarity (25)** | 22 | 24 | +2 |
| **Lane discipline / ownership (20)** | 17 | 18 | +1 |
| Structure & clarity (10) | 10 | 10 | 0 |
| **Total** | **91** | **95** | **+4** |

## What is causally attributable vs. what is likely noise

- **Lane discipline (+1) — clean signal, attributable to role-ownership.** The NEW output carries **8** lines of explicit ownership/cession language ("o schema final é do @builder", possuo/não-possuo); the OLD output has **0**. The blind judge rewarded exactly this ("explicitly cedes schema finalization to @builder"). The 14-line role-ownership section demonstrably changed the artifact on the dimension it targets. **This is the real result.**
- **Handoff clarity (+2) & Alternatives (+1) — likely run-to-run variance, NOT the convention.** handoff-contract is present in **both** prompts (A and B), so a handoff-quality gap is not caused by the role-ownership delta; B simply produced a more structured handoff this run. n=1 cannot separate this from variance.

## Honest verdict
- **The harness works** — it produced the loop's **first outcome measurement**: blind, dimension-level, grounded in real artifact text.
- **role-ownership was NOT cosmetic** — it moved the needle on its target dimension (lane discipline), with a clean causal trace (0→8 ownership statements). This is the good case, not the FP1 worst case.
- **But the effect is small and not yet conclusive.** Total +4 on **n=1 per version, single judge**. The pure attributable delta is **+1** (lane discipline). To make this a measurement rather than an anecdote: **run k≥3 per version and compare means** (averages out run variance + judge variance). The harness itself surfaces this methodology requirement.

## Next
- Add k-run averaging (k≥3) to the protocol before trusting a delta as "the convention helped".
- Wire the harness into the loop at the accept/integrate boundary (ADR-014, phase 2): baseline → land on shadow → re-run → Δ; a drop = the curator/gate reconsiders.
