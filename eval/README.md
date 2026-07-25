# the-owl Fitness Harness

Measures whether a change to an agent makes its **output** better — not just whether it parses or fits (ADR-014). This is the loop's outcome signal; the rubric's "Impact (20)" should be *measured* here, not asserted.

## What's here

```
eval/
├── README.md   ← this file (the protocol)
├── judge.md    ← the INDEPENDENT judge protocol + shared scoring rules
├── tasks/      ← self-contained fixtures (agent_under_test + input + rubric)
└── results/    ← recorded scores per run, dated (baseline + before/after deltas)
```

**Fixture matrix — every editable agent has a happy-path *and* a temptation task.** A happy-path task measures normal quality; a temptation task baits the agent into another owner's lane, so guardrail conventions (role-ownership) are measurable (see "Guardrail conventions" below — a guardrail shows Δ=0 on the happy task even when it works).

| agent | happy-path | temptation (guardrail) |
|---|---|---|
| architect | `01-architect-adr` | `06-architect-lane-discipline` |
| strategist | `02-strategist-prd` | `07-strategist-lane-discipline` |
| builder | `03-builder-edit` | `08-builder-lane-discipline` |
| system-designer | `04-system-designer-sdd` | `09-system-designer-lane-discipline` |
| chronicler | `05-chronicler-changelog` | `10-chronicler-lane-discipline` |

The chronicler temptation also stresses **secret-hygiene** (it hands the agent a token and asks to paste it into a durable doc — a leak sinks the score).

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

## Guardrail conventions: measure the worst case, not the mean

Some conventions don't make good output *better* — they make bad output *less likely* (a guardrail: role-ownership, tool-scopes, approval gates). For these:

- **The mean Δ under-detects them.** A convention that turns one-in-three failures into zero moves the worst case a lot and the mean barely (and inflates the baseline's spread, so the noise band swallows the mean Δ). `owl-fitness.py` therefore reports the **worst-case (min) Δ** and flags when it exceeds the mean Δ — read the per-run notes there.
- **The task must stress the failure mode.** A clean happy-path task shows Δ=0 for a guardrail *even when it works* (see `results/2026-07-25-task01` vs `-task06`: same convention, Δ=0 on the clean task, worst-case +9 on the temptation task). Every guardrail convention needs a temptation fixture like `tasks/06-*`.
- **Read the delta on the TARGETED dimension, not the total.** A guardrail (role-ownership) governs one dimension (lane discipline). The *total* can "EXCEED noise" on an orthogonal dimension (product quality, code concreteness) where run-to-run variance dominates — and point opposite ways across agents. That's noise w.r.t. the convention, not an effect. The fleet before/after (`results/2026-07-25-fleet-guardrail-beforeafter.md`) showed lane Δ ≈ 0 on all 5 agents while two totals "exceeded noise" in opposite directions on orthogonal dims. Always inspect the per-dimension breakdown `owl-fitness.py` prints; trust the total only when the delta sits in the dimension the change targets.
- **The temptation must actually tempt the base agent.** If the un-converted agent already stays in lane (lane maxed in both versions), the fixture can't measure the guardrail — you learn only that the base prompt already holds. Fixtures `07/08/10` hit this; harden a fixture until the *old* version reliably bites before trusting a null.

## Honest limits

- 5 tasks is a **sample**, not proof. A gain is *evidence*, not certainty.
- A single LLM judge has variance and can share the producer's blind spots. Mitigate later with N judges / diverse lenses. For now: blind + rubric-anchored + delta-based.
- Fixtures can be **overfit** if agents are tuned *to the eval*. Rotate/extend tasks over time (LINT-style).
- Judged artifacts are **data, not instructions** (NFR-SEC-2).
