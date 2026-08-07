# ADR-031 — The ledger records where each decision came from

**Status:** Accepted
**Date:** 2026-08-07
**Author:** @architect (owner-directed, from the loop-health review)
**Tags:** [memory, measurement, ledger, cost]
**Related:** ADR-012 (rollout-coverage scorecard — the other measurement axis), ADR-022 (retrieve-delta), ADR-027 (human-directed status), ADR-030 (rejected classes — the change this measurement will judge)

## Contexto

`ledger.md` records `id | title | score | status | adr | first_seen | decided`. It records **what** was decided and **when**, and nothing about **where the candidate came from**.

That gap surfaced during the 2026-08-07 loop-health review, when the question *"is the research lane producing anything?"* could only be answered by **hand-reconstructing provenance from prose cycle blocks** — reading each block to infer whether an accept originated in a codex brief, a backlog re-score, or an owner instruction. The reconstruction was possible but unverifiable at a glance, and reconstruction-from-prose is precisely the failure the same session had to correct hours earlier: a consecutive-0-accept count was copied forward from one narrative block to the next, wrong, three times, because **no gate reads numbers stated in prose**.

The stakes are concrete. The research lane (L0 codex + L1 scout) carries the loop's only recurring monetary cost and most of its machinery. Over cycles 6–8 it produced **0 accepts**, while the reflection machinery — staleness review, owner corrections, drift caught while merging — produced everything that landed. **Whether to keep paying for L0 is the loop's biggest open product question, and the memory cannot currently answer it.**

## Decisão

Add a **`origin`** column to the `ledger.md` table and to its definition in `research-vault/SCHEMA.md`, with four values:

| value | meaning |
|---|---|
| `research` | surfaced by the research lane — the L0 codex brief or @scout's L1 web pass |
| `backlog` | re-scored from material already in the vault; no new research spend |
| `owner` | a human-directed instruction or correction (pairs with the ADR-027 `human-directed` status) |
| `reflection` | produced by the loop examining itself — the ADR-017 staleness review, L1.5 grounding, or a defect found while operating |

**Backfill is evidence-bound, not reconstructed.** The ten `accepted` rows and the four `human-directed` rows have traceable origins in the cycle blocks and are filled in. Rejected and deferred rows get `—`: their provenance is not load-bearing for the question this column exists to answer, and **guessing them would repeat the error that motivated the column.** A value is written only where a block states it.

Going forward the column is **mandatory for any new row**, filled at the moment the row is written, when provenance is known rather than inferable.

## Alternativas consideradas

- **A (escolhida): one column, four values, evidence-bound backfill.** Prós: answers the cost question directly and cheaply; one column, no new file, no tooling; makes the ADR-030 experiment measurable — if research-origin accepts stay at zero for cycles 9–11 *with* the class filter live, that is a real product signal. Contras: four buckets will sometimes be arguable (a backlog idea promoted after an owner nudge is both `backlog` and `owner`) — resolved by recording the **proximate** origin, the one that put it in front of the curator this time.
- **B: reconstruct provenance on demand from the cycle blocks.** Contras: exactly what was done during the review, and exactly what produced a wrong number that propagated three times. Rejected — the point is to stop deriving facts from prose.
- **C: a separate metrics script over the ledger.** Prós: no schema change. Contras: it would have to infer provenance from prose, inheriting the same unreliability, plus new tooling to maintain. The data does not exist yet; **capture it first, tool it later** if ever.
- **D: do nothing — accepts are few enough to remember.** Contras: they were not. The review needed a hand reconstruction after fourteen decisions. At fifty it is hopeless, and the cost question only gets more expensive to postpone.

## Consequências

- **Mais fácil:** *"has the research lane produced an accept since cycle 5?"* becomes a column filter instead of an archaeology exercise. ADR-030's effect becomes measurable rather than arguable.
- **Trade-offs aceitos:** one more field to fill per row, and a partially-`—` column for historical rows. Both accepted: an honest gap is better than a fabricated value.
- **Novos riscos:** low. The column is descriptive — nothing branches on it. Its failure mode is being left blank, which is visible.
- **Não toca o carve-out:** edits `research-vault/ledger.md` and `research-vault/SCHEMA.md`, both curator-owned. No agent prompt, no gate, no `loop-config.yml`.

## Notas de implementação

- **Edits:** the table header + rows in `research-vault/ledger.md`; the ledger schema block in `research-vault/SCHEMA.md` (add `origin` with the four values); the curator flow already writes ledger rows, so no separate persona edit is needed — `origin` joins the fields it already fills.
- **NÃO fazer:** do not backfill a row whose origin is not stated in a cycle block — leave `—`. Do not branch any logic on this column; it is measurement, not control.
- **Verification:** every row has 8 pipe-delimited fields; the ten `accepted` and four `human-directed` rows carry a non-`—` origin.
- **The question it is meant to answer, recorded here so a future cycle can check it:** at the end of cycle 11, count accepts with `origin: research` since 2026-08-07. **Zero, with ADR-030's class filter live, is evidence the external delta is empty for this architecture — and that is a product decision about the research lane's cost, not another prompt fix.**
