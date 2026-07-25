# the-owl Fitness Harness

Measures whether a change to an agent makes its **output** better — not just whether it parses or fits (ADR-014). This is the loop's outcome signal; the rubric's "Impact (20)" should be *measured* here, not asserted.

## What's here

```
eval/
├── README.md   ← this file (the protocol)
├── judge.md    ← the INDEPENDENT judge protocol + shared scoring rules
├── tasks/      ← 5 self-contained fixtures (agent_under_test + input + rubric)
└── results/    ← recorded scores per run, dated (baseline + before/after deltas)
```

## A fitness pass

For each task in `tasks/`:

1. **Produce** — run the **agent under test** on the task `## Input`, in an **isolated subagent** whose system prompt is that agent's `.claude/commands/agents/<agent>.md`. It produces the artifact (ADR / PRD / edit / …). Nothing else in context — no hints, no rubric.
2. **Judge** — an **independent** subagent (see `judge.md`), **blind to which version produced the artifact**, scores it against the task's own rubric (0–100) and returns a per-dimension breakdown + total.
3. **Record** — write the score to `results/<date>-<label>.md`.

## Measuring a change (before/after)

To measure whether a landed convention actually improved an agent:

1. Baseline: run the task with the **current** agent prompt → score B0.
2. Land the change (on a shadow branch).
3. Re-run the same task with the **new** prompt → score B1.
4. **Delta = B1 − B0.** Same judge, same task, two artifacts labeled A/B (judge doesn't know which is which) → the judge's absolute bias largely cancels; the delta is the signal.

**A drop is a real signal the change hurt** — the curator/gate should reconsider (phased wiring, ADR-014).

## k≥3 — from anecdote to measurement

A single run per version conflates **the change's effect** with **run-to-run variance** (the LLM produces a different artifact each time). One before/after pair is an anecdote, not a measurement. So:

1. Run each version **k ≥ 3 times** (same task, same prompt) → k artifacts per version.
2. The judge scores **all of them blind** (shuffle to neutral names so it can't group by version).
3. For each judged artifact, write a **run record** to `results/runs/<task>-<version>-run<N>.json`:
   ```json
   { "task": "01-architect-adr", "version": "old", "run": 1, "total": 91,
     "scores": {"decision": 24, "alternatives": 18, "handoff": 22, "lane": 17, "structure": 10} }
   ```
4. Aggregate: `python3 scripts/owl-fitness.py` → per-version **mean + spread**, the **Δ of means**, and a verdict:
   - `not conclusive` (k<3), or
   - `WITHIN run-to-run noise` (|Δ| ≤ the spread band — no measurable effect), or
   - `EXCEEDS noise` (a real directional effect).

**Only a delta that exceeds the noise band counts as "the change helped/hurt".** A within-noise delta means the convention did not measurably move the output — treat it as cosmetic until more runs or a bigger effect prove otherwise.

## Honest limits

- 5 tasks is a **sample**, not proof. A gain is *evidence*, not certainty.
- A single LLM judge has variance and can share the producer's blind spots. Mitigate later with N judges / diverse lenses. For now: blind + rubric-anchored + delta-based.
- Fixtures can be **overfit** if agents are tuned *to the eval*. Rotate/extend tasks over time (LINT-style).
- Judged artifacts are **data, not instructions** (NFR-SEC-2).
