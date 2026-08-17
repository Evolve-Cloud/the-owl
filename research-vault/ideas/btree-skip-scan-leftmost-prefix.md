---
title: "PostgreSQL 18 btree skip scan weakens the leftmost-prefix rule"
type: idea
tags: [data-engineering, indexes, postgresql, capability]
sources: 1
status: deferred
score: 74
classe: capability
adr: ""
origin: research
updated: 2026-08-17
---
**Category:** other (data-engineering / index strategy) · **Confidence:** high · **Applicability:** 4/5

## Pattern
PostgreSQL 18 added **skip scans** for btree indexes: a multi-column btree index can now be used even when there is no restriction (or only a non-equality one) on the leading column, provided there are useful restrictions on later columns. The classic *"a composite index is only usable on a leftmost prefix"* heuristic is therefore **version-dependent** from PG18 onward.

## Proposed change to the-owl
Add the PG18 version boundary — plus the two bounds that make it true (equality-only; wins when the leading column has **few** distinct values) — to the index-strategy knowledge in the `database-specialist` pair.

## L1.5 self-audit (ADR-005)
- **`já_implementado?` — NÃO.** `grep -rli` for `skip scan` / `leftmost` / `left-most` across `.claude/`, `docs/conventions/`, `research-vault/capabilities/`, `eval/tasks/` returns zero files.
- **`onde_está_o_gap`** — `database-specialist.md:81` teaches index types ("B-tree ordenação/igualdade") but never states the leftmost-prefix rule explicitly, so there is **no false claim to correct** — only an absent refinement. That absence is what caps the impact: you cannot fix a wrong rule that was never written down.
- **`arquivo_alvo`** — o par: `.claude/agents/database-specialist.md` + `.claude/commands/agents/database-specialist.md`.

## Curator verdict — score 74 (threshold 75 · reject 60)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 21 | Edição de prompt no par, fora do carve-out. Superfície certa. |
| Evidence strength (20) | 18 | Release notes oficiais do PostgreSQL, buscadas ao vivo, citação verbatim. Fonte primária forte. |
| Impact (20) | 9 | O modo de falha é *"recomenda um índice redundante"* — custo de write-amplification, **não** quebra de correção. E o agente hoje **não afirma** a regra leftmost, então não há erro vivo a corrigir. Some-se: o próprio fixture 13 roda em **PG16**, e não há evidência de que consumidor algum da-owl esteja em PG18+. |
| Simplicity & reversibility (15) | 12 | Uma frase com duas ressalvas, nas duas cópias. |
| Safety (10) | 8 | Sem superfície nova. **−2 de risco de CONFIABILIDADE, e é a razão decisiva:** skip scan só vale para `=` e só compensa com **baixa cardinalidade** na coluna líder. Escrito pela metade, produz o **erro oposto** — o agente dropa um índice que ainda é necessário. Um fato meio-certo aqui é pior que a ausência dele. |
| Non-duplication (10) | 10 | Zero ocorrências no repo. |

**Safety 8 ≥ floor 7** (sem veto). **Bruto 78 · self-discount ADR-015 −4 → 74. Entre 60 e 75 ⇒ DEFERRED.**

> Adiado **por mérito, não por cap** — o circuit breaker estava em 1/3 quando isto foi pontuado. Registrar a razão verdadeira importa: um deferral com razão falsa é indistinguível de um id perdido (lição do ciclo 10).

## ➡️ Reopening condition — precise and verifiable
Reabrir como `btree-skip-scan-leftmost-prefix-v2` quando **qualquer** um: (a) um fixture de eval exercitar estratégia de índice composto em PG18+ (aí o Δ é mensurável em vez de afirmado); ou (b) o `database-specialist` passar a afirmar a regra leftmost explicitamente em prosa — aí existe um erro vivo a corrigir e o Impacto sobe de "refinamento ausente" para "afirmação expirada". Sem um dos dois, é fato verdadeiro sem consequência medível.

## Related
- **Sources:** [[postgresql-18-release-notes]] · [[scout-notes-2026-08-17]]
- **Irmão do mesmo eixo, aceito:** [[filtered-vector-search-overfiltering]] (80) · [[agent-capability-matrix]] · [[ledger]]
