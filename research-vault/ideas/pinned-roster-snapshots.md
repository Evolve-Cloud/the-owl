---
title: "Rosters de especialistas versionados em ADRs que mudam topologia"
type: idea
tags: [orchestration, topology, adr]
sources: 1
status: deferred
score: 62
adr: ""
origin: research
updated: 2026-08-12
---

**Categoria:** orchestration · **Confiança:** medium · **Aplicabilidade:** 4/5

## Pattern

Tratar o roster de especialistas do orquestrador como **artefato de topologia versionado**, não como lista solta de nomes. A doc de Managed Agents (segundo o brief) afirma que agentes referenciados ficam presos a versões resolvidas até o coordenador ser atualizado. A versão portátil para a-owl: registrar, num ADR que muda topologia, qual revisão de cada definição de agente aquele ciclo pretendia usar.

## Proposed change to the-owl

Estender ADRs que mudam topologia com uma seção `roster_snapshot`: cada especialista delegado, seu path e um marcador de revisão legível (SHA de commit ou versão de prompt).

## L1.5 self-audit (ADR-005)

- **`já_implementado?`** **PARCIALMENTE.** Todo ADR já nomeia os arquivos que toca, o `chronicler` já produz snapshot + knowledge-graph por ciclo, e o `last-run.json` registra o que foi landado. O que **não** existe é o vínculo explícito "esta decisão de topologia assumiu esta revisão dos especialistas".
- **`onde_está_o_gap`** `docs/decisions/000-template.md` (não tem a seção) + o passo do chronicler no L5.
- **`arquivo_alvo`** `docs/decisions/000-template.md` · `.claude/agents/chronicler.md` + `.claude/commands/agents/chronicler.md` (par, ADR-028) — **não avaliado em detalhe**, porque a ideia não passa da verificação de evidência.

## Curator verdict — score 62 (threshold 75 · reject 60) → **DEFERRED**

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 16 | Expressável como markdown + estrutura de ADR, sem runtime. −9: a-owl é um repo git de um autor; a deriva de roster que o pinning previne é um problema de **plataforma multi-tenant**, e o `git log` já responde "que revisão era" sem bookkeeping novo. |
| Evidence strength (20) | 9 | ⛔ **Fonte única, NÃO buscada nesta passagem.** O `evidence: [s1]` do brief não foi confirmado contra a doc primária. Pelo ADR-013 isso sozinho barra a aceitação. |
| Impact (20) | 10 | O risco que ataca (prompt de especialista muda, comportamento do orquestrador deriva) é real e nomeado pelo próprio brief — mas a-owl já ancora cada mudança num ADR + commit. |
| Simplicity & reversibility (15) | 11 | Uma seção no template. −4: o risco de obsolescência é do próprio brief (*"manual revision recording can become stale"*) — bookkeeping manual que ninguém relê é o defeito que este ciclo passou o dia corrigindo. |
| Safety (10) | 9 | Só documentação. |
| Non-duplication (10) | 7 | −3: sobrepõe substancialmente o que ADR + `git log` + snapshot do chronicler já dão. |

**Safety 9 ≥ floor 7.** Total **62** → entre 60 e 75 ⇒ **DEFERRED**.

## ➡️ Condição de reabertura

Buscar a doc de Managed Agents e confirmar o mecanismo de pinning **na fonte primária** (o passo que faltou aqui). Se confirmado E surgir uma instância real de deriva de roster na-owl — um ADR de topologia cuja conclusão virou falsa porque um prompt de especialista mudou depois — reabrir como `pinned-roster-snapshots-v2`. Sem a instância, o `git log` basta.

## Related
- **Sources:** [[research-brief-2026-08-12]] (s1, não verificada) · [[scout-notes-2026-08-12]] (registra a não-verificação)
- [[handoff-and-orchestration]] · ADR-013 (a regra que barra) · ADR-031 (`origin` — este é do braço de pesquisa)
