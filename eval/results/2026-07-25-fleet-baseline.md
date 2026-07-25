# Fitness result — fleet baseline (strategist / builder / system-designer / chronicler)

**Date:** 2026-07-25 · **Judge:** independent, blind (`eval/judge.md`), a **separate judge instance per task** · **k = 3** per task, all three artifacts scored blind against that task's own rubric.
**What this is:** a **reference point** — each of the four agents run on its representative task with its **current** prompt. No before/after here; these are the anchors a *future* change to that agent compares against (`owl-fitness.py` Δ = new − baseline).

## Baselines (k=3)

```
TASK 02  strategist       mean 90.3 / 100   (n=3, range 88–94, σ=2.6)
TASK 03  builder          mean 91.0 / 100   (n=3, range 88–93, σ=2.2)
TASK 04  system-designer  mean 89.0 / 100   (n=3, range 82–94, σ=5.1)
TASK 05  chronicler       mean 88.0 / 100   (n=3, range 83–95, σ=5.1)
```
(Run-records: `eval/results/runs/task0{2..5}-baseline-run{1..3}.json`. Aggregate: `python3 scripts/owl-fitness.py`.)

## What the numbers say — read the SPREAD, not just the mean

The means are close (88–91), but the **spread is the story**, and it splits the fleet in two:

- **Tight (σ≈2.2–2.6): strategist, builder.** Every run landed 88–94. These agents produce consistently on their task — a future change has a **narrow noise band (~±2.5–3)**, so even a small real improvement will be detectable.
- **Wide (σ≈5.1): system-designer, chronicler.** One strong run each (94 / 95) and one weak run (82 / 83). The weak runs are where the failure modes live:
  - **system-designer min 82** — dropped the dedicated golden-signals/monitoring section (scored monitoring 10 vs 14) and a `DLBQ` typo; the other two runs kept it.
  - **chronicler min 83** — broken/stray markdown fences (structure 2 vs 8); content was faithful and leaked no secret, but the shape fell apart.
  These wide bands mean a future change to those two agents needs a **larger effect (or more runs)** to rise above the noise — and the obvious improvement target is **reducing the worst run**, not lifting the mean.

## Honest caveats (do not over-read these)

- **Not a cross-agent leaderboard.** Each task was scored by a **different judge instance against a different rubric**. builder's 91 is *not* "better than" strategist's 90.3 — they're not on the same scale. Each baseline is an anchor **for its own task's future before/after only**.
- **n=3.** A σ of 5 off three runs is itself uncertain; the wide bands could tighten (or widen) with more runs. Treat the split as directional.
- **Single LLM judge per task**, artifacts as data (NFR-SEC-2). No convention was measured here — these are current-state anchors, nothing landed or reverted.

## Cost (FP5 datum)

Full k=3 fleet baseline of 4 agents ≈ **5.9M tokens** (12 producers ≈ 4.44M + 4 judges ≈ 1.44M), ~90 s wall-clock at this concurrency. Confirms the harness is an **on-demand keep/revert instrument**, not a per-cycle reflex.

## Harness fix shipped alongside (owl-fitness.py)

Writing these baselines surfaced a **backwards message** in the worst-case flag: on task 01 it printed *"likely a RELIABILITY effect (prevents worst-case failures)"* for a Δmin of **−3** — i.e. it spun the new version's *lower* worst run as a win. Fixed: the flag is now **signed** — a positive Δmin ≫ mean reads as a reliability WIN (lifts the worst run, the task-06 case); a negative Δmin ≫ mean reads as *"worst run is lower — could be a regression OR just higher variance; n=3 can't tell — add runs."* The tool no longer launders variance into a win in either direction.
