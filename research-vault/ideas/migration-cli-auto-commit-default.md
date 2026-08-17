---
title: "Migration CLI auto-commit default (gcloud DMS conversion workspaces)"
type: idea
tags: [data-engineering, migrations, tooling]
sources: 1
status: deferred
score: 63
classe: capability
adr: ""
origin: research
updated: 2026-08-17
---
**Category:** tooling · **Confidence:** high · **Applicability claimed by brief:** 5/5 · **Applicability as scored:** 2/5

## Pattern
Google Cloud CLI 578.0.0 made **auto-commit the default** for Database Migration Service conversion-workspace `seed`, `convert` and `import-rules`. Workflows that relied on a staged/reviewable conversion workspace must now pass the explicit negative flag.

## Proposed change to the-owl
A data-engineering checklist item: for migration tooling, verify current commit/apply defaults from the release notes; do not infer dry-run behaviour from older command examples.

## L1.5 self-audit (ADR-005)
- **`já_implementado?` — NÃO.** Verificado por `grep -rli` em `.claude/`, `docs/conventions/`, `research-vault/capabilities/`, `eval/tasks/` para `tombstone` / `Iceberg` / `Delta Lake` / `lakehouse` / `Databricks` / `auto-commit`: **zero arquivos**, todos os termos.
- **`onde_está_o_gap`** — real mas **fora do território declarado do agente**. O `database-specialist` é deliberadamente **neutro de fornecedor** (PostgreSQL/MySQL/MongoDB + pgvector); nenhuma superfície da-owl menciona plataforma de lakehouse. O gap não é "o agente está errado", é "o agente não cobre um stack que não há evidência de que alguém aqui use".
- **`arquivo_alvo`** — seria o par `database-specialist` (+ `system-designer` em duas delas) ou uma `capabilities/` page nova.

## Curator verdict — score 63 (threshold 75 · reject 60)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 12 | O fato específico é sobre **uma versão de uma CLI de um produto de um fornecedor** — a coisa com a meia-vida mais curta que este ciclo viu. A *generalização* ("verifique o default mutante") cabe bem; o fato, não. |
| Evidence strength (20) | 14 | Release notes primárias ✓, mas apontam para uma página de notas **rolante** (`/sdk/docs/release-notes`), não para uma âncora imutável da 578.0.0 — a citação envelhece junto com a página. Não re-buscada por mim. |
| Impact (20) | 6 | O menor do ciclo. Um flag, num produto, que a-owl não tem evidência de usar. |
| Simplicity & reversibility (15) | 13 | Trivial de adicionar e remover. |
| Safety (10) | 8 | Sem superfície nova. Nota: a *direção* do fato é relevante para segurança (um comando que se acreditava em staging agora commita), o que sustenta a generalização, não o fato. |
| Non-duplication (10) | 10 | Ausente do repo. |

**Safety 8 ≥ floor 7. Total 63 ⇒ DEFERRED**, no piso da faixa.

## ➡️ Reopening condition
Não reabrir na forma específica — ela expira sozinha. A forma reabrível é a **generalização** partilhada com as outras três ideias do brief deste ciclo.

## Related
- **Sources:** [[research-brief-2026-08-17]] · [[managed-connector-schema-tombstones]] · [[ledger]]
