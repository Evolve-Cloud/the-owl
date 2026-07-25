# ADR-014 — A fitness harness: measure whether a change improves agent output, not just whether it parses

**Status:** Accepted
**Date:** 2026-07-25
**Author:** human-directed (tech-lead review — the FP1 fix)
**Tags:** [self-improvement, evaluation, fitness, outcome-measurement]
**Related:** ADR-003 (rigor rubric — "Impact (20)"), ADR-012 (efficiency = value/cost), ADR-013 (claim verification), `research-vault/ledger.md` (`evaluator-optimizer-loop`, `provenance-first-evaluation` — both deferred), the deferred remedy this ADR finally builds.

## Contexto
The loop had **no fitness function** — the deepest failure point. Proof:
- `find` for `eval|replay|fitness|benchmark` in the-owl → **nothing**.
- `last-run.json` records process (ids, accepted, gate result), never outcome.
- The rubric's **Impact (20)** criterion is **asserted by the curator**, never measured.
- The loop optimizes a proxy ("fits + evidenced + safe + tidy") with no ground truth → textbook Goodhart. It can accept well-evidenced, safe, plausible conventions forever and never make an agent measurably better at real work. The rollout scorecard I built measures **rollout coverage** — a *process* metric, not an *outcome*.
- The loop's own research surfaced the exact remedy (`evaluator-optimizer-loop`, `provenance-first-evaluation`) and **deferred both** — it is structurally blind to its own blindness.

The-owl improves the **DevFlow agent definitions** (architect/builder/chronicler/strategist/system-designer/scout/curator). "Improve" has meant "adopt a convention that fits." The real target must be: **does the change make the agent produce a better artifact on a real task?**

## Decisão
Build a **fitness harness** (`eval/`) that measures agent-output quality, before and after a change.

**Structure:**
```
eval/
  README.md   ← the protocol (how to run a fitness pass)
  judge.md    ← the INDEPENDENT judge protocol + shared scoring rules
  tasks/      ← 5 self-contained fixtures: agent_under_test + input + rubric
  results/    ← recorded before/after scores per run (dated)
```

**A fitness pass:**
1. For each task, **run the agent-under-test** (its current `.md` prompt) on the task input, in an isolated subagent → produces an artifact.
2. An **independent judge** (a separate subagent, blind to which prompt version produced the artifact) scores the artifact against the task's rubric (0–100).
3. To measure a **change**, run the task with the agent prompt **before** and **after** the change; the **delta** is the measured impact.

**Rules that make it real:**
- **Independent judge** — never self-score; the producer and the judge are different subagents (this is the `evaluator-optimizer` pattern the loop deferred).
- **Blind** — the judge does not know which artifact is "before" vs "after"; label them A/B.
- **Sensitive tasks** — each task's rubric must score the dimension the change targets, or the delta is noise. (Task 01 scores handoff clarity + lane-discipline precisely because the recent conventions — handoff-contract, role-ownership — target those.)
- **Grounded** — fixtures are realistic mini-scenarios of what the agents actually do (ADR, PRD, SDD, edit, CHANGELOG), so a score gain reflects better *real* output.

**Integration (phased):**
- **Now (this ADR):** the harness + fixtures + the judge protocol exist and are demonstrated once, for real.
- **Next:** the loop runs the harness at the accept/integrate boundary for an accepted convention (baseline → land on shadow → re-run → delta); a **fitness drop is a signal the change hurt** and the curator/gate reconsiders. This turns rubric "Impact (20)" from asserted into measured.

## Alternativas consideradas
- **Alternativa A (escolhida): a small (5-task) LLM-judged before/after harness, in-repo, run via subagents.** Prós: gives the missing ground truth cheaply (~10 LLM calls/pass); grounded in real agent work; the independent+blind judge is the deferred `evaluator-optimizer` pattern. Contras: 5 tasks is a narrow sample; a single LLM judge has variance and can share blind spots (mitigations below).
- **Alternativa B: a large benchmark suite + human scoring.** Prós: rigorous. Contras: heavy to build/maintain; human scoring doesn't scale to a weekly loop. Over-engineered for now.
- **Alternativa C: keep asserting Impact (status quo).** Rejected — this IS FP1.

## Consequências
- **Mais fácil:** for the first time, a change to an agent can be **measured** ("did the score go up?") instead of argued. "Did our self-improvement improve anything?" becomes answerable. Directly attacks FP1 and FP3 (fitness is grounded in real work).
- **Trade-offs aceitos:** ~10 LLM calls per fitness pass (bounded); 5 tasks is a sample, not proof — a gain is *evidence*, not certainty. Single-judge variance: mitigate later with N judges / diverse lenses; for now the judge is blind + rubric-anchored, and the delta (same judge, same task, two artifacts) cancels much of the judge's absolute bias.
- **Novos riscos:** the fixtures can be gamed/overfit if agents are tuned *to the eval*; rotate/extend tasks over time (the LINT-style discipline). The judge ingests agent output = data, not instructions (NFR-SEC-2). 0 carve-out contact — `eval/` is new, editable, touches no guardrail.

## Notas de implementação
- `eval/` created with README + judge.md + 5 fixtures + results/.
- **Demonstrated for real** (not a rule on paper): task 01 run with `@architect` **before vs after** the role-ownership rollout (git `eb0e284` vs current), scored blind by an independent judge → a recorded before/after delta in `eval/results/`. This is the loop's **first outcome measurement** — and it is designed to tell the truth even if the answer is "the convention didn't help."
- Human-directed; landed to `main`; gate-lens self-reviewed (additive, 0 carve-out).
