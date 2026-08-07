# ADR-032 — Two defects in the fitness harness: silent comparison loss, and producer contamination

**Status:** Accepted
**Date:** 2026-08-07
**Author:** @architect (owner-directed, from defects found while running the handoff-contract pass)
**Tags:** [eval, fitness, harness, correctness]
**Related:** ADR-014 (the fitness harness), ADR-015 (provisional impact / measured optimism bias), ADR-013 (claim verification)

## Contexto

The 2026-08-07 fitness pass on the handoff-contract stack produced a real result (Δ +11.0, exceeds noise). Running it surfaced **two defects in the instrument itself**, both of which were recorded in that result file as "known limitation, not fixed." An instrument with a silent failure mode is worse than no instrument, because it produces confident output that is wrong; this ADR fixes both.

### Defect 1 — a second comparison on the same fixture silently disables the delta

`scripts/owl-fitness.py` grouped run records by `task` alone and computed a delta only under `if len(versions) == 2`. Measuring a **second** convention on an already-used fixture therefore put three or more version labels under one key, the branch never ran, and **nothing was printed to say so** — no warning, no error, exit 0. The output looked like a task where no comparison had been intended.

This is not hypothetical. It has bitten **twice**, and both times was worked around the same way — by inventing a fake task label:

| real fixture | fake label invented | what it measured |
|---|---|---|
| `10-chronicler-lane` | `10-chronicler-secretfix` | the chronicler secret-hygiene fix (2026-07-25) |
| `01-architect-adr` | `01-architect-adr-handoff` | the handoff-contract stack (2026-08-07) |

The workaround costs the `task` field its meaning: the label stops naming a file in `eval/tasks/` and starts naming a *measurement occasion*. Two prior workarounds is evidence of a recurring defect, not of an edge case.

### Defect 2 — stripping a convention from the prompt does not remove it from the repository

`eval/README.md` step 1 constrains the producer's **context** ("nothing else in context — no hints, no rubric") and says nothing about its **filesystem access**. In the handoff-contract pass, **1 of 3 "old" producers recovered the stripped convention** by reading `docs/conventions/handoff-contract.md`, cited ADR-004, and reproduced the removed uncertainty field. It scored highest of the three olds.

The bias is directional and predictable: a leaked "old" run inflates the baseline, so the measured delta is **too small**. Here the effect survived (+11.0 measured, +13.7 excluding the leaked run), but a convention with a genuine +4 effect would have been reported as noise. **Every convention worth measuring is also written down somewhere the producer can read** — that is what makes it a convention — so this affects every before/after pass, not this one.

## Decisão

**Defect 1 — group comparisons on `(task, change_under_test)`, and fail loudly when a group is not exactly two versions.**

- Run records gain a `change_under_test` field. `task` goes back to naming the **fixture**; `change_under_test` names **what is being compared**. `""` means a baseline pass with no comparison.
- A group with >2 versions prints `⛔ NO COMPARISON`, explains that the runs were pooled and no Δ computed, states the fix, and the script **exits 1**.
- The 60 existing run records are migrated, and the two fake labels are retired — `01-architect-adr` and `10-chronicler-lane` each now legitimately hold two comparisons. **Every migrated attribution was confirmed against its own result file**, never inferred: the fleet-guardrail result names fixtures 06–10 and role-ownership explicitly; the chronicler-fix result names the secret-hygiene change. All ten deltas are byte-identical before and after migration.

**Defect 2 — make contamination a checked step, not an assumption.** `eval/README.md` gains an explicit warning that prompt isolation is insufficient, with two required practices: run the producer against a scratch copy of the prompt, and **verify contamination per artifact after the fact** — grep each "old" artifact for the convention's ADR number and distinctive field names, report the count in the result file, and report the delta **with and without** any leaked run. A measured delta is a **floor** whenever an "old" run leaked.

**Not decided here: filesystem sandboxing.** The real fix is a producer that cannot read the repository at all. That needs a mechanism this harness does not have, and inventing one is a larger change than this defect fix. The detect-and-disclose rule works today and is honest about what it is: mitigation, not prevention.

## Alternativas consideradas

- **A (escolhida): `change_under_test` + loud failure; contamination checked and disclosed.** Prós: fixes both defects at their cause; restores the `task` field's meaning; retires two workarounds; the loud failure converts a silent wrong answer into a stopped run. Contras: a one-off migration of 60 records; the contamination rule is manual and can be skipped by a careless operator — mitigated only by it being written into the protocol next to the step it guards.
- **B: keep inventing task labels per measurement.** Prós: zero code change. Contras: it is the status quo that already failed twice; the fixture label becomes meaningless, and the next operator has no way to know that `01-architect-adr-handoff` is not a file in `eval/tasks/`. Rejected.
- **C: compare only the two most recent versions when a group has more.** Prós: never fails. Contras: **silently guesses the operator's intent** — the exact class of behaviour that caused the defect. A wrong comparison presented confidently is worse than a refusal. Rejected.
- **D: sandbox the producer's filesystem now.** Prós: actually prevents contamination rather than detecting it. Contras: a substantially larger change to how producers are run, and it would have blocked this fix behind it. **Deferred, not rejected** — recorded as the real answer whenever the harness gets a sandbox mechanism.
- **E: leave both, they are documented in the result file.** Contras: documentation in one result file does not stop the next pass from hitting the same silent failure. A defect known and left in a measurement tool will eventually produce a confident wrong number, which is worse than the tool being absent. Rejected.

## Consequências

- **Mais fácil:** a fixture can measure several conventions over its life, which is the normal case — `01-architect-adr` now legitimately holds `role-ownership` (Δ 0.0) and `handoff-contract` (Δ +11.0) side by side, and that juxtaposition is itself the most instructive output the harness has produced.
- **Trade-offs aceitos:** one more required field per run record; a stricter script that can now fail a previously-passing invocation — which is the point.
- **Novos riscos:** the contamination check is manual, so it can be forgotten. Mitigated by placement (in the protocol, at the step it guards) and by requiring the count to appear in the result file, where its absence is visible.
- **Não toca o carve-out:** edits `scripts/owl-fitness.py`, `eval/README.md`, and the run records. No agent prompt, no gate, no `.owl/loop-config.yml`.

## Notas de implementação

- **Verification performed, not assumed:** all ten pre-existing deltas reproduce identically after migration; a synthetic third version was injected to confirm the `⛔` path prints and exits 1, then removed, and exit 0 confirmed restored.
- **NÃO fazer:** do not let the script guess which two versions to compare (Alternative C); do not treat a leaked "old" run as automatically discardable — name it, and report the delta both ways.
- **Provenance:** both defects were found by running `eval/results/2026-08-07-task01-handoff-contract.md`, where they are recorded in *Caveats* and *Harness finding*. That result file's numbers are unaffected by this fix — it is the same data, re-grouped.
