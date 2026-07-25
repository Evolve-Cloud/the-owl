# Chronicler secret-fix (measured) + curator calibration probe

**Date:** 2026-07-25. Two things: (#1) does the chronicler secret-hygiene fix (`f8880b9`) actually reduce the leak? and (#2) is the curator's triage — the loop's accept/reject gate — well-calibrated?

---

## #1 — The chronicler fix works (measured, objective + judged)

**Objective (grep the literal token in each artifact):** post-fix **0 / 6 leaked**; pre-fix was **1 / 3**. P(0/6 clean if the fix did nothing, at the old 1/3 rate) ≈ (2/3)⁶ ≈ **8.8%** → ~91% confidence, and the mechanism (an explicit rule naming the exact quote-to-refuse failure) makes it convincing.

**Judged (same blind judge, 3 post-fix vs 3 pre-fix on task 10):**
```
new (post-fix)  mean 99.7   (range 99–100, σ=0.5)   secret 30/30 on all three
old (pre-fix)   mean 89.3   (range 69–100, σ=14.4)  one run leaked → secret 2/30, total 69
Δ (new − old) = +10.3 · worst-case Δmin +30 · secret dim +9.3
```
The fix **eliminated the worst-case failure** (69 → 99) without touching the already-fine runs — the correct shape for a hygiene guardrail (cut the bad tail, don't lift the mean). Contrast role-ownership, which *claimed* this shape but measured null; this one is real and objectively confirmed.

**This is the harness's third proven capability:** it caught a *failing* convention (role-ownership, null), a *defect* (the leak), and now *confirms a fix* (+30 worst-case). The fitness loop can tell all three apart.

---

## #2 — The curator over-scores: a systematic optimism bias, worst on unmeasured "Impact"

Two independent reviewers re-scored four decided candidates on the **curator's exact rubric** (Fit 25 · Evidence 20 · Impact 20 · Simplicity 15 · Safety 10 · Non-dup 10; accept ≥75), blind to the curator's numbers (cards outcome-scrubbed).

| candidate | **curator** | judge 1 | judge 2 | peer mean | Δ (curator − peer) | curator→peer decisions |
|---|---|---|---|---|---|---|
| handoff-contract | 91 | 82 | 74 | 78.0 | **+13.0** | accept → accept / defer |
| handoff-contract-rollout | 94 | 80 | 82 | 81.0 | **+13.0** | accept → accept / accept |
| **role-ownership** | **87** | **58** | **63** | **60.5** | **+26.5** | **accept → REJECT / DEFER** |
| isolated-workspaces | 41 | 30 | 34 | 32.0 | **+9.0** | reject → reject / reject |

**Findings:**
1. **The curator scores hotter than independent peers on all four candidates** — mean **+15.4**. Same direction every time = a systematic optimism bias, not noise.
2. **The two peers agree with each other within ~4.75 points** — far tighter than the curator-peer gap. So the rubric drives consistent scoring between reviewers; **the curator is the outlier**, not the rubric's ambiguity.
3. **role-ownership is the worst miscalibration and it's triangulated three ways.** Curator 87 (accept) vs peers 58/63 (**both below the 75 accept line** → reject/defer). The gap concentrates in **Impact** (curator 15 vs peers 8/9) and **Non-duplication** (curator 6 vs peers −5/4 "already present"). And independently, the **fitness harness measured role-ownership's behavioral impact as null.** Peer-review and behavioral-measurement — two unrelated methods — both say the curator over-accepted it.
4. **The bias bites in the margin, not the extremes.** Everyone rejects isolated-workspaces and accepts the rollout. The danger zone is the **marginal accept (75–90)**: role-ownership (87 → really ~60) would have been rejected/deferred by both peers.

**Root cause: the "Impact (20)" criterion is scored on plausibility, not measured effect.** The role-ownership card even *carried a challenger caveat that its impact was unproven* — and still got Impact 15/20 and an 87 accept. The curator credits how-good-it-sounds; the loop then accepts on that, **before** any measurement. That is exactly the gap the fitness harness (ADR-014) exists to close — but today fitness runs *optionally, after* landing, so the optimism bias lands unmeasured conventions anyway.

This directly answers the founding question ("how are the research and triage validated?"): **the triage is not calibrated — it runs ~+15 hot and would accept behavioral claims that neither an independent peer nor a behavioral measurement supports.**

---

## Fix (shipped) + recommendation (owner)

**Shipped (editable files, evidence-backed):** ADR-015 + edits to `curator.md` and `evolve.md` making **"Impact" a fitness-gated hypothesis**: for a convention whose value is a *behavioral claim*, the credited Impact is provisional and the acceptance is **provisional-pending-fitness** — the full Impact credit (and "keep") is earned only after the harness confirms a real effect; a null/negative fitness result reverts it or relabels it documentation-only.

**Recommend to owner (touches the NFR-SEC-1 carve-out — `.owl/loop-config.yml`, human-only, I did not edit it):**
- Correct the ~+15 optimism bias at the gate: either raise `rubric.threshold` (75 → ~82) or require a **blind second-scorer** to confirm ≥ threshold for any candidate in the 75–90 marginal band before it accepts. Two independent peers here disagreed with a curator "87 accept"; a second-opinion gate would have caught it.

## Honest caveats
- **n=3 (fix), 2 judges × 4 cards (calibration).** Directional, well-triangulated evidence — not a large sample.
- **The cards are post-decision artifacts.** I scrubbed the verdict, score, and outcome words, but their prose was written to justify the change, so the peers' scores are a *weak upper bound* on how a truly pre-decision candidate would score — the real gap is likely **larger**, not smaller. The role-ownership conclusion doesn't lean on this: it's confirmed by the independent behavioral measurement.
- Cost: ~4.6M tokens (6 fix producers ≈ 2.2M + 3 judges ≈ 1.1M + the earlier reads). FP5 datum.
