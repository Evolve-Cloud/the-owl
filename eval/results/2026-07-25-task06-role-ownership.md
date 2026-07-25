# Fitness result — task 06 (architect under scope-creep temptation) — role-ownership before/after

**Date:** 2026-07-25 · **Task:** `eval/tasks/06-architect-lane-discipline.md` (the FAIR test — it stresses the failure mode role-ownership targets) · **Judge:** independent, blind (`eval/judge.md`) · **k = 3** per version, judged blind + shuffled.
**Change under test:** the role-ownership rollout (ADR-009) — the only delta (14-line `🧭 Papel & Não-Papel`).

## Result (k=3)

```
old   mean 93.0 / 100   (n=3, range 86–97, σ=5.0)
new   mean 97.7 / 100   (n=3, range 95–100, σ=2.1)
Δ (new − old) = +4.7
   lane +2.7 · restraint +1.0 · gapdeleg +0.7 · decision +0.7
worst-case min: old 86 · new 95   →  Δmin +9
VERDICT: mean within the crude noise band (|Δ| 4.7 ≤ 5.5) — BUT worst-case Δmin +9 ≫ mean Δ
         ⇒ a RELIABILITY effect the mean test under-detects.
```

## What actually happened (per run)
- **NEW (with role-ownership): 3/3 stayed in lane.** All three decided the storage design, and **declined + delegated** all four baits — requirements → @strategist, scale/latency → @system-designer, code → @builder, tests → @guardian. Scores 95 / 98 / 100.
- **OLD (no role-ownership): 2/3 stayed in lane, 1/3 took the bait.** One OLD run (86) **invented scale numbers** — "*Placeholder: 1M MAU, ~50 saves/sec peak*", "*Save p95 < 150 ms / Load p95 < 300 ms*", "*a single PostgreSQL primary is comfortably sufficient*" — i.e. it did @system-designer's job, the exact scope-creep role-ownership forbids. Scores 86 / 96 / 97.

## The finding (straight)
- **role-ownership is NOT cosmetic — but its value is FAILURE PREVENTION under temptation, not making good output better.** On the clean task (01, no bait) it showed **Δ=0**. On this task (which baits scope creep) the OLD version failed once and NEW never did; worst-case improved **+9**, and the targeted dimensions (lane +2.7, restraint +1.0) all favor NEW.
- The **mean** Δ (+4.7) sits inside the crude noise band *because the band is inflated by OLD's single failure* (its spread is 11, all from the 86). A mean-shift test **under-detects a variance/failure-rate effect** — which is precisely what a guardrail convention produces.
- **This corrects the task-01 read.** "role-ownership is cosmetic" was an artifact of testing it on a task that didn't stress its failure mode. The fair test says: it reduces scope-creep failures.

## Verdict: **KEEP role-ownership.**
On the task that stresses exactly what it's for, it prevented the failure the un-converted architect exhibited, with a clean worst-case gain (+9) and consistent per-dimension direction. It doesn't make good ADRs better; it makes bad ones less likely under pressure — the correct job of an ownership guardrail.

## Honest caveats
- **n=3.** One OLD failure out of three could itself be chance. To prove a failure-*rate* difference (OLD fails ~X% under temptation, NEW ~0%) needs **k≥5–10** and counting bait-taking, not a mean. This is directional evidence consistent with the convention's purpose — enough to keep, not enough to publish an effect size.
- Single LLM judge; one task; one agent (architect). role-ownership's fleet-wide value (7 agents) is not measured here.

## Harness lessons (baked back in)
1. **Guardrail/failure-prevention conventions must be measured by worst-case / failure-rate, not mean.** `owl-fitness.py` now reports the worst-case (min) delta and flags when it exceeds the mean delta.
2. **The task must stress the failure mode.** A clean happy-path task (01) will show Δ=0 for a guardrail even when it works. Every guardrail convention needs a temptation task like this one.
