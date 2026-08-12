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

## ➡️ Condição de reabertura — **revista em 2026-08-12: NÃO é mais cabeça de fila**

> A versão anterior desta seção dizia *"reabrir no ciclo 10 como primeiro item da fila"*. Revista por direção do dono depois do FAIL do ADR-036, que mudou o que se sabe sobre esta superfície. A revisão está escrita, não silenciosa.

**Segue reabrível no ciclo 10 — mas não primeiro, e não sem pré-condição.**

### Por que saiu da cabeça da fila

1. **Isto NÃO é limpeza cosmética — muda roteamento.** Hoje, sem `description`, a harness cai em *"the first paragraph of markdown content"*. Pôr um `description` explícito **muda quando Claude carrega aqueles 9 comandos**. É a mesma classe de mudança que acabou de reprovar no gate (ADR-036), com raio menor mas não zero. A página original tratava isso como troca de chaves inertes; é mais que isso.
2. **O valor é honestidade, não função.** Impacto pontuado 12/20, e o fallback da harness provavelmente já funciona. Parar de exibir configuração que não configura é real — mas não é urgente.
3. **Seria a terceira mudança de frontmatter seguida**, num ciclo que acabou de provar que a semântica de frontmatter em comando não é óbvia (`allowed-tools` alarga em vez de restringir; `disable-model-invocation` bloqueia invocação programática).

### ⛔ Pré-condição de caminho crítico — escrita, não conferência opcional

Antes de qualquer ADR sobre isto, **rodar e registrar o grep de consumidores** dos 9 comandos:

```bash
grep -rn 'quick/\|/quick:' .claude/ docs/ scripts/    # quem invoca ou referencia estes comandos?
```

**É literalmente o passo que faltou no ADR-036.** Aquele ADR escreveu *"nenhum outro consumidor conhecido"* depois de verificar um; o grep que refutou custou uma linha. Esta pré-condição existe para que o mesmo erro não seja cometido duas vezes na mesma superfície, e o resultado dele vai no ADR — inclusive se for "nenhum consumidor", que aí é um negativo **verificado**, não afirmado.

### Ordem recomendada para o ciclo 10

Depois do ADR-038 (P7 cindido, já feito) e **atrás** de `mechanism-liveness-verification`, que carrega evidência mais fresca e mais cara. Se o ciclo 10 pontuar este e ele passar, ótimo; se o cap comer de novo, **registrar isso outra vez** — dois ciclos seguidos deferido por cap vira sinal de roteamento, não de mérito.

## Related
- **Sources:** [[scout-notes-2026-08-12]]
- [[routing-eligibility-mode]] (irmão que landa este ciclo — mesma mecânica, arquivos disjuntos) · [[stale-context-block-in-l0-prompt]]
- ADR-030 (a classe *Unenforceable prose*, da qual isto é a instância mais literal já achada)
