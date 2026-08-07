---
title: "Campos de frontmatter de subagent, reaberto: o bloqueio era 'não temos subagents'"
type: idea
tags: [frontmatter, subagents, cost, enforcement]
supersedes_context: agent-frontmatter-fields
awaiting_scoring: cycle-9
reopened: 2026-08-07
reopened_by: human-directed (primeiro alvo vivo do passo 4.6, ADR-033 forma B)
updated: 2026-08-07
---

> [!important] **NÃO pontuado, de propósito. E sem linha no `ledger.md`, também de propósito.**
> Reabrir não é aceitar. Sem tabela de rubrica, sem total, sem nota de Impacto — nenhuma foi atribuída. **Não existe linha no ledger para `agent-frontmatter-fields-v2`:** o passo 1 do curator pula id que já está no ledger, então uma linha aqui mataria a reabertura em silêncio e ela *pareceria* feita. O @curator escreve a linha quando pontuar. O **ato** de reabrir tem linha própria (`hd-reopen-agent-frontmatter-fields`), com id distinto.

## Por que este id existe

`agent-frontmatter-fields` (`deferred`, sem score, 2026-07-23 — título *"maxTurns/Memory/isolation frontmatter"*; agrega os aliases `markdown-frontmatter-config`, `yaml-frontmatter-and-prompt-body`, `frontmatter-capability-scoping`) **nunca teve página de ideia** — só a linha do ledger e uma frase em `overview.md`.

**Dois bloqueios registrados, os dois caídos:**

1. **O bloqueio de cadência (ciclo 1):** *"circuit breaker cap = 3 accepted/cycle; cycle 1 kept conservative → 1 accepted, rest deferred."* Nunca foi julgamento de mérito — foi fila.
2. **O bloqueio substantivo, em `overview.md:38`:** *"Concrete 2026 frontmatter fields (`maxTurns`, `Memory`, `isolation`) — **applicability to slash-command agents needs care**."* Ou seja: são campos de **subagent**, e a-owl só tinha agentes slash-command. **Isso é a propriedade P4** (`docs/conventions/structural-properties.md`), e P4 é **falsa desde o PR #17**: existem 13 subagents nativos.

O ciclo 7 registrou o resto: `tools`/`disallowedTools`/`permissionMode`/`maxTurns` são campos **reais, impostos pela harness** — verificado ao vivo pelo scout na doc de subagents do Claude Code.

**Este é o primeiro alvo do passo 4.6** (ADR-033 forma B), identificado pela varredura de propriedades de 2026-08-07 e reaberto por direção do dono.

## ⚠️ O bloqueio caiu para 1 dos 3 campos do título — e isso é a parte que decide o escopo

| campo | verificado como real/imposto? | evidência |
|---|---|---|
| `maxTurns` | **SIM** | ciclo 7, doc de subagents do Claude Code, verificado ao vivo pelo scout |
| `Memory` | **NÃO** — nenhuma verificação em lugar nenhum do vault | só a menção original de 2026-07-23 em `overview.md:38`, com a ressalva *"needs care"* nunca resolvida |
| `isolation` | **NÃO** — idem | idem |

**E na árvore hoje:** os 13 subagents nativos usam **só** `name`, `description`, `tools`. **Zero** usam `maxTurns`.

⛔ **Consequência direta:** propor `Memory`/`isolation` sem verificá-los primeiro é **exatamente a armadilha de prosa inimponível** que deferiu o `least-privilege-tool-scopes` na origem — escrever um campo que a harness ignora, com risco de falsa confiança. **Verificar antes de pontuar é pré-requisito, não detalhe.** Se não forem reais, o candidato encolhe para `maxTurns` sozinho.

## A fatia concreta: `maxTurns` é a versão imposta de uma prosa que a-owl JÁ escreve

Este não é um campo em busca de um problema. A-owl já carrega, em **prosa**, a instrução que `maxTurns` imporia:

> ⚡ ECONOMIA DE TURNOS (cada round-trip re-lê TODO o contexto)
> `O custo do agente = piso de contexto × nº de turnos. Menos turnos = menos token.`

Estado verificado: esse bloco está em **4 dos 13** subagents nativos (architect, builder, chronicler, system-designer). `maxTurns` está em **0 de 13**.

Então a forma da fatia é a mesma que destravou o `least-privilege`: **um pedido comportamental em prosa, para o qual a harness agora tem imposição real.** É a instância mais forte que este candidato tem, e é a que o @curator deveria olhar primeiro.

## Questões em aberto que o @curator precisa resolver ANTES de pontuar

1. **`Memory` e `isolation` são campos reais?** Ver tabela acima. **Verificação obrigatória** (fetch alvo na doc primária, ADR-013). Se não forem, o candidato é só `maxTurns`.
2. **Cap não é economia — cap é corte.** A prosa *pede* frugalidade; `maxTurns` **interrompe**. Um agente que bate o teto no meio de uma tarefa legítima entrega trabalho truncado, e o `/owl:evolve` trata artefato ausente como **fase FALHOU**. Qual é o número, e para quais agentes? Um teto errado troca custo por falha de ciclo. Isto é trade-off real, não detalhe de implementação.
3. **Assimetria do par (ADR-028) — a mesma que trava o `least-privilege-tool-scopes-v2`.** **0 de 13** personas-comando têm frontmatter YAML. O ADR-028 exige que a edição toque **as duas** cópias e chama tocar só uma de **fase FALHOU**. Metade do par estruturalmente não recebe `maxTurns`. Este conflito agora bloqueia **dois** candidatos — pode ser o sinal de que o próprio ADR-028 precisa de uma cláusula para campos que só existem numa das metades. **Essa é a decisão maior escondida aqui.**
4. **Duplicação com o bloco de prosa.** Se `maxTurns` entrar, a prosa de economia de turnos fica, sai, ou muda? Elas não fazem a mesma coisa (pedido × imposição) — mas manter as duas sem dizer a relação é o tipo de sobreposição que o ADR-009 existe para impedir.
5. **Carve-out.** `challenger`/`guardian`/`sentinel` estão fora — foram escopados por mão humana e o loop nunca os edita. Sobram no máximo 10.

## O que este candidato NÃO é

Não é "adotar todos os campos de frontmatter de 2026". Essa é a forma vaga de 2026-07-23, e ela continua sem fatia atômica. O delta é **um campo imposto, verificado, com número justificado, num conjunto nomeado de agentes**.

## Related
- [[structural-properties]] (P4, P5 — as propriedades cujo estado destravou isto) · [[ledger]] (deferral do ciclo 1; achado de capacidade do ciclo 7)
- ADR-033 (forma B — o passo 4.6, cujo **primeiro alvo vivo** é este) · ADR-028 (regra do par — em conflito, ver Q3) · ADR-013 (verificação de claim — obrigatória para Q1) · ADR-010 (o modelo inline, origem do bloqueio P4)
- Irmão de reabertura: `least-privilege-tool-scopes-v2` — mesmo evento (PR #17), mesmo conflito ADR-028
