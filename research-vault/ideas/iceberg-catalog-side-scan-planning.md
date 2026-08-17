---
title: "Catalog-side scan planning boundary (Iceberg REST Catalog 1.11)"
type: idea
tags: [data-engineering, lakehouse, architecture]
sources: 1
status: deferred
score: 68
classe: capability
adr: ""
origin: research
updated: 2026-08-17
---
**Category:** other · **Confidence:** high · **Applicability claimed by brief:** 4/5 · **Applicability as scored:** 3/5

## Pattern
Apache Iceberg 1.11 expands the REST Catalog from a metadata lookup into an **execution-planning boundary**: catalog servers can plan table scans and return only the relevant file-scan tasks, advertise a scan-planning mode, attach storage credentials to planning responses, and standardize idempotency keys for mutating catalog operations. Lakehouse correctness and performance shift from "client reads manifests and retries commits" toward a negotiated protocol.

## Proposed change to the-owl
An Iceberg / open-table-format subsection for architect + system-designer knowledge: catalogs may be active planning and authorization participants, not passive metadata stores — verify protocol capabilities before diagnosing driver memory, retry or scan-performance issues.

## L1.5 self-audit (ADR-005)
- **`já_implementado?` — NÃO.** Verificado por `grep -rli` em `.claude/`, `docs/conventions/`, `research-vault/capabilities/`, `eval/tasks/` para `tombstone` / `Iceberg` / `Delta Lake` / `lakehouse` / `Databricks` / `auto-commit`: **zero arquivos**, todos os termos.
- **`onde_está_o_gap`** — real mas **fora do território declarado do agente**. O `database-specialist` é deliberadamente **neutro de fornecedor** (PostgreSQL/MySQL/MongoDB + pgvector); nenhuma superfície da-owl menciona plataforma de lakehouse. O gap não é "o agente está errado", é "o agente não cobre um stack que não há evidência de que alguém aqui use".
- **`arquivo_alvo`** — seria o par `database-specialist` (+ `system-designer` em duas delas) ou uma `capabilities/` page nova.

## Curator verdict — score 68 (threshold 75 · reject 60)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 15 | A **melhor** das quatro do brief: é um deslocamento de fronteira arquitetural (onde vive o planejamento/autorização), não um flag. Isso é durável e é linguagem de `architect`/`system-designer`. −10: ainda assim é um formato de tabela que nenhuma superfície da-owl menciona. |
| Evidence strength (20) | 16 | Release primária do Iceberg 1.11 ✓, `net-new` genuíno. Não re-buscada por mim. |
| Impact (20) | 9 | Alto **se** houver um lakehouse; nenhum sinal de que haja. Sem fixture. |
| Simplicity & reversibility (15) | 10 | −5: é a maior das quatro — uma subseção, não uma linha, e tocaria **dois** pares (`architect` + `system-designer`) = 4 arquivos. Deixa de ser edição atômica. |
| Safety (10) | 8 | Sem superfície nova. Nota: *credential vending* pelo catálogo é conteúdo com peso de segurança — mais uma razão para não entrar pela metade. |
| Non-duplication (10) | 10 | Ausente do repo. |

**Safety 8 ≥ floor 7. Total 68 ⇒ DEFERRED.** O mais forte dos quatro do brief e ainda 7 abaixo do corte.

## ➡️ Reopening condition
Reabrir se o dono escopar `lakehouse` como eixo de capacidade na matriz (hoje CX2 é `data-engineering` genérico e a-owl é orientada a OLTP), **ou** se um projeto consumidor adotar Iceberg. Aí o Fit sobe de 15 para a faixa dos 20 e o Impacto deixa de ser condicional.

## Related
- **Sources:** [[research-brief-2026-08-17]] · [[delta-table-auto-feature-upgrades]] · [[ledger]]
