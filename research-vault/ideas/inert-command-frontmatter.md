---
title: "11 de 11 blocos de frontmatter de comando são inertes"
type: idea
tags: [reflection, frontmatter, unenforceable-prose]
sources: 2
status: deferred
score: 79
adr: ""
origin: reflection
updated: 2026-08-12
---

**Categoria:** self-improvement / enforcement · **Confiança:** high · **Aplicabilidade:** 4/5

## Pattern

*Unenforceable prose* na sua forma mais pura — não em prosa, mas em **frontmatter**, que é o lugar onde a inimponibilidade é mais enganosa, porque YAML *parece* configuração por construção.

## O achado (verificado contra a doc primária + a árvore, 2026-08-12)

| chave usada | ocorrências | está na tabela de campos do Claude Code? |
|---|---|---|
| `trigger:` | 11 | ❌ não |
| `category:` | 11 | ❌ não |
| `priority:` | 11 | ❌ não |

**11 de 11** blocos de frontmatter de comando da-owl (`.claude/commands/owl/*.md` + `quick/*.md`) são compostos **inteiramente** de campos que a harness ignora. E `description:` — o campo que de fato governa quando Claude carrega o comando — está **ausente dos 11**; sem ele a harness cai para *"the first paragraph of markdown content"*.

Ou seja: cada um desses arquivos declara um `trigger:` que não dispara nada, e deixa vazio o campo que dispararia.

## L1.5 self-audit (ADR-005)

- **`já_implementado?`** **NÃO.**
- **`onde_está_o_gap`** `.claude/commands/quick/*.md` (9 arquivos) + `.claude/commands/owl/*.md` (2).
- **`arquivo_alvo`** `.claude/commands/quick/*.md` — **9 arquivos**. ADR-028 **N/A**: não são personas, não existe par em `.claude/agents/`.
  - ⛔ `.claude/commands/owl/evolve.md` e `research.md` **fora**: são a maquinaria do loop, e `evolve.md` em particular é a superfície de disparo do próprio loop (mesma fronteira desenhada em [[routing-eligibility-mode]]).

## Curator verdict — score 79 (threshold 75) → **DEFERRED por cap + adjacência**

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 21 | Correção de frontmatter em arquivos que a-owl possui. −4: 2 dos 11 são maquinaria do loop e saem da fatia. |
| Evidence strength (20) | 19 | Tabela completa de campos da doc primária + inventário da árvore. Diretamente verificável, sem inferência. |
| Impact (20) | 12 | ⚠️ **provisório (ADR-015)**. O fallback da harness (primeiro parágrafo) provavelmente já funciona razoavelmente, então o ganho funcional é modesto — o ganho real é **honestidade**: parar de exibir configuração que não configura. |
| Simplicity & reversibility (15) | 13 | Mecânico: trocar 3 chaves inertes por reais em 9 arquivos. |
| Safety (10) | 9 | Nenhuma capacidade nova. |
| Non-duplication (10) | 5 | −5: **mesma mecânica** de [[routing-eligibility-mode]], que landa neste ciclo. Conjuntos de arquivos disjuntos (personas × quick), então não é o mesmo diff — mas é o mesmo aprendizado. |

**Safety 9 ≥ floor 7.** Total **79 ≥ 75** — passaria. **Deferido pelo circuit breaker:** cap = 3, e os três aceitos pontuam 91 / 84 / 80. Este é o excedente.

> ⚖️ **Deferido por CAP e ADJACÊNCIA, não por mérito** — dito explicitamente porque foi assim que `agent-frontmatter-fields` se perdeu por 3 semanas no ciclo 1. A adjacência é razão adicional e boa: `routing-eligibility-mode` aplica a mesma mecânica num conjunto disjunto de arquivos **neste ciclo**; observar um ciclo antes de repetir é mais barato que dois ADRs sobrepostos.

## ➡️ Condição de reabertura — sem gatilho externo, é fila

**Reabrir no ciclo 10 como primeiro item da fila**, sem esperar evidência nova: o bloqueio é o cap, e o cap zera todo ciclo. Se o ciclo 10 passar sem pontuá-lo, o modo de falha do ciclo 1 se repetiu e isso é um defeito do roteamento, não do mérito.

## Related
- **Sources:** [[scout-notes-2026-08-12]]
- [[routing-eligibility-mode]] (irmão que landa este ciclo — mesma mecânica, arquivos disjuntos) · [[stale-context-block-in-l0-prompt]]
- ADR-030 (a classe *Unenforceable prose*, da qual isto é a instância mais literal já achada)
