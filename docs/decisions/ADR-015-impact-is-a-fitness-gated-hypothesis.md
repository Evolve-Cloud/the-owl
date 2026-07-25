# ADR-015 — "Impact" is a fitness-gated hypothesis, not a credited score

**Status:** Accepted
**Date:** 2026-07-25
**Author:** operator (tech-lead), from the curator-calibration probe
**Tags:** [curator, rubric, fitness, calibration]

## Contexto
The curator's rubric scores each candidate on six criteria (Fit 25 · Evidence 20 · **Impact 20** · Simplicity 15 · Safety 10 · Non-dup 10; accept ≥ 75). A calibration probe (2026-07-25, `eval/results/2026-07-25-chronicler-fix-and-curator-calibration.md`) had two independent reviewers re-score four decided candidates on that exact rubric, blind to the curator's numbers:

- The curator scored **+15.4 hotter than the peer mean on all four** candidates (same direction every time = systematic optimism bias, not noise). The two peers agreed with each other within ~4.75 — the curator is the outlier.
- **`role-ownership`** was the worst case: curator **87 (accept)** vs peers **58 / 63 (reject / defer — both below the 75 line)**. The gap concentrated in **Impact** (curator 15 vs peers 8/9). Independently, the **fitness harness (ADR-014) measured role-ownership's behavioral impact as null** (lane Δ ≈ 0 across 5 agents, `2026-07-25-fleet-guardrail-beforeafter.md`). Peer-review and behavioral-measurement — two unrelated methods — both say the curator over-accepted it.

Root cause: **the "Impact" criterion is scored on plausibility, not measured effect.** The role-ownership card even carried a challenger caveat that its impact was *unproven* — and still got Impact 15/20 and an 87 accept. The loop then accepts on that score **before any measurement**. This is exactly the gap ADR-014 exists to close, but fitness currently runs *optionally, after* landing, so the optimism bias lands unmeasured conventions anyway.

## Decisão
For any candidate whose value is a **behavioral claim** (a convention/prompt change asserted to improve what an agent *produces* — as opposed to a structural/documentation fact), **"Impact" is a hypothesis until the fitness harness confirms it.** Concretely:

1. The curator credits Impact for an unmeasured behavioral claim at **hypothesis level only** (cap the sub-score; state "impacto AFIRMADO, não medido"), and marks the acceptance **provisional-pending-fitness**.
2. The **full Impact credit and the "keep" decision are earned only after `eval/` confirms a real effect on the targeted dimension** (read the targeted-dimension delta, not the total — the total moves on orthogonal noise). A null/negative fitness result **reverts the change or relabels it documentation-only** (no behavioral credit).
3. The curator is reminded of its measured **optimism bias (~+15 vs independent peers)**; for marginal candidates (total 75–90) it should self-haircut and flag the acceptance as provisional.

This does **not** touch `.owl/loop-config.yml` (the rubric thresholds/weights live there and are inside the NFR-SEC-1 carve-out — human-only). It changes how the curator *reasons about* Impact and how `evolve.md` *treats* a behavior-claiming accept, both editable.

## Alternativas consideradas
- **Alternativa A (escolhida): Impact = fitness-gated hypothesis; accept provisional-pending-fitness.** Pró: attacks the measured root cause (plausibility ≠ effect) without touching the carve-out; connects the accept path to the harness we already built; reversible (additive guidance). Contra: doesn't fix the raw optimism bias at the numeric gate (that's a threshold change, which is carve-out → owner's call).
- **Alternativa B: raise `rubric.threshold` 75 → ~82, or add a mandatory blind second-scorer for the 75–90 band.** Pró: directly corrects the +15 bias; the second-opinion would have caught role-ownership. Contra: **lives in `.owl/loop-config.yml` = carve-out = human-only.** Cannot be done autonomously → **recommended to the owner**, not decided here.
- **Alternativa C: do nothing / trust the curator.** Contra: the probe shows the gate would accept behavioral claims that neither a peer nor a measurement supports — the loop optimizes plausibility. Rejected.

## Consequências
- **Easier:** the loop stops crediting unmeasured behavioral claims as proven wins; "Impact" becomes honest (hypothesis vs measured). A convention like role-ownership would land as *provisional/documentation* until fitness earns it the behavioral credit.
- **Harder / slower:** a behavior-claiming convention now needs a fitness pass before it's a trusted "keep" — more cost per such change (but only for behavioral claims, not structural facts, and fitness is already the on-demand instrument).
- **New risk:** none to safety (additive guidance, no carve-out contact). The residual gap — the raw +15 optimism bias at the numeric threshold — is explicitly handed to the owner (Alternativa B).

## Notas de implementação
- **`curator.md`** (editable): in the scoring section, add the rule — Impact for a behavioral claim is credited at hypothesis level + acceptance marked provisional-pending-fitness; note the measured +15 optimism bias and self-haircut on marginal (75–90) candidates. Cross-ref ADR-014 + ADR-015 + the calibration result.
- **`evolve.md`** (editable): in the Fitness section, state that a behavior-claiming convention's acceptance is **provisional** until fitness confirms the targeted-dimension effect; null/negative ⇒ revert or relabel documentation-only.
- **Do NOT** edit `.owl/loop-config.yml` (carve-out). The threshold/second-opinion change is an owner recommendation, recorded in the calibration result doc.
- Verify: no carve-out path touched; both edits additive; ADR follows the template.
