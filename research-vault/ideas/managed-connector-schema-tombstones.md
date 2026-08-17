---
title: "Managed ingestion schema tombstones (deleted source columns become inactive, not deleted)"
type: idea
tags: [data-engineering, cdc, schema-evolution]
sources: 1
status: deferred
score: 66
classe: capability
adr: ""
origin: research
updated: 2026-08-17
---
**Category:** other · **Confidence:** high · **Applicability claimed by brief:** 5/5 · **Applicability as scored:** 2/5

## Pattern
Databricks Lakeflow managed connectors document a stateful schema-evolution contract: new source columns are ingested automatically, but **deleted** source columns are not deleted downstream — they are marked *inactive*, and a later source column reusing that name can fail the pipeline unless the table is full-refreshed or the inactive column is manually dropped.

## Proposed change to the-owl
A capability-page note for data-engineering: for managed connectors, ask whether deletes become tombstones and document the full-refresh / manual-drop recovery path for renamed or reused columns.

## L1.5 self-audit (ADR-005)
- **`já_implementado?` — NÃO.** Verificado por `grep -rli` em `.claude/`, `docs/conventions/`, `research-vault/capabilities/`, `eval/tasks/` para `tombstone` / `Iceberg` / `Delta Lake` / `lakehouse` / `Databricks` / `auto-commit`: **zero arquivos**, todos os termos.
- **`onde_está_o_gap`** — real mas **fora do território declarado do agente**. O `database-specialist` é deliberadamente **neutro de fornecedor** (PostgreSQL/MySQL/MongoDB + pgvector); nenhuma superfície da-owl menciona plataforma de lakehouse. O gap não é "o agente está errado", é "o agente não cobre um stack que não há evidência de que alguém aqui use".
- **`arquivo_alvo`** — seria o par `database-specialist` (+ `system-designer` em duas delas) ou uma `capabilities/` page nova.

## Curator verdict — score 66 (threshold 75 · reject 60)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 14 | Expressável como prompt/capability page ✓. **−11: fato de UM fornecedor** enxertado num agente neutro de fornecedor, sem consumidor conhecido. O próprio `risk` do brief admite: *"Overfitting to Databricks could make agents assume every connector tombstones columns."* |
| Evidence strength (20) | 15 | Doc primária ✓. −5: fonte única, e **eu não a re-busquei** — é claim do brief, não fato verificado por mim (ADR-013 só obriga o fetch nas que eu fosse aceitar). |
| Impact (20) | 8 | Real para quem roda Lakeflow; **zero** para todo o resto. Nenhum fixture. |
| Simplicity & reversibility (15) | 11 | Uma nota; reversível. −4: exige criar/escolher a superfície de destino. |
| Safety (10) | 8 | Sem superfície nova, sem carve-out. |
| Non-duplication (10) | 10 | Ausente do repo. |

**Safety 8 ≥ floor 7. Total 66 ⇒ DEFERRED** (entre 60 e 75).

## ➡️ Reopening condition
Reabrir se um consumidor da-owl adotar um lakehouse gerenciado — ou, melhor, se a **generalização** (ver [[ledger]], bloco do ciclo 11) for levantada como candidato próprio: *"plataforma gerenciada muda comportamento da camada de dados sem migration versionada"* é a forma com meia-vida maior que um ciclo de release de fornecedor.

## Related
- **Sources:** [[research-brief-2026-08-17]] · [[scout-notes-2026-08-17]] · [[delta-table-auto-feature-upgrades]] · [[ledger]]
