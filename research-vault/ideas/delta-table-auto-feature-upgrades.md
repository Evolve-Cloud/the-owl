---
title: "Delta table feature auto-upgrades (Unity Catalog managed tables)"
type: idea
tags: [data-engineering, lakehouse, safety]
sources: 1
status: deferred
score: 60
classe: capability
adr: ""
origin: research
updated: 2026-08-17
---
**Category:** safety · **Confidence:** medium (per brief) · **Applicability claimed by brief:** 5/5 · **Applicability as scored:** 2/5

## Pattern
Databricks is expanding automatic upgrades for Unity Catalog managed tables — row tracking and Checkpoint V2 rolling out July 2026, catalog commits and deletion vectors *planned* for August 2026 — guarded by a workload-compatibility observation window. Table protocol capabilities can therefore change **without a hand-authored migration**.

## Proposed change to the-owl
A prompt convention: for Delta/lakehouse tables, document table-feature state, automatic-upgrade policy and oldest supported client before proposing migrations, rollback or incident remediation.

## L1.5 self-audit (ADR-005)
- **`já_implementado?` — NÃO.** Verificado por `grep -rli` em `.claude/`, `docs/conventions/`, `research-vault/capabilities/`, `eval/tasks/` para `tombstone` / `Iceberg` / `Delta Lake` / `lakehouse` / `Databricks` / `auto-commit`: **zero arquivos**, todos os termos.
- **`onde_está_o_gap`** — real mas **fora do território declarado do agente**. O `database-specialist` é deliberadamente **neutro de fornecedor** (PostgreSQL/MySQL/MongoDB + pgvector); nenhuma superfície da-owl menciona plataforma de lakehouse. O gap não é "o agente está errado", é "o agente não cobre um stack que não há evidência de que alguém aqui use".
- **`arquivo_alvo`** — seria o par `database-specialist` (+ `system-designer` em duas delas) ou uma `capabilities/` page nova.

## Curator verdict — score 60 (threshold 75 · reject 60)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 13 | Fornecedor único, agente neutro de fornecedor, consumidor desconhecido. |
| Evidence strength (20) | 11 | **A mais fraca do ciclo, e por um motivo de tipo, não de grau.** A fonte é uma página *"What's coming"* e metade da claim é **prospectiva** (*"planned for August 2026"*). Uma claim sobre o futuro não é verificável contra fonte primária no sentido do ADR-013 — no melhor caso confirma-se que *o fornecedor anunciou um plano*, não que o comportamento existe. O próprio brief marcou `confidence: medium`, o único assim das quatro. |
| Impact (20) | 8 | O *princípio* subjacente ("o estado da tabela pode mudar sem DDL versionada") é bom e é exatamente a generalização; o fato específico não. |
| Simplicity & reversibility (15) | 11 | Uma convenção curta; reversível. |
| Safety (10) | 7 | **No piso, mas acima dele — sem veto.** Categoria `safety` no brief e o conteúdo é sobre compatibilidade de cliente/rollback, então uma versão meio-certa aqui aconselha mal num caminho de incidente. Isso é risco de confiabilidade, não superfície de ataque. |
| Non-duplication (10) | 10 | Ausente do repo. |

**Safety 7 = floor 7 ⇒ NÃO dispara o veto** (o veto é `< 7`, não `≤ 7`). **Total 60 ⇒ DEFERRED**, exatamente no limite de rejeição; `confidence: medium` enviesa para adiar em vez de rejeitar, conforme o contrato de campo do schema 8b.

## ➡️ Reopening condition
Reabrir só quando os recursos *planejados* tiverem **enviado** e a doc descrever comportamento presente em vez de roadmap — aí a claim vira verificável. Ou, como as irmãs, via a generalização.

## Related
- **Sources:** [[research-brief-2026-08-17]] · [[managed-connector-schema-tombstones]] · [[iceberg-catalog-side-scan-planning]] · [[ledger]]
