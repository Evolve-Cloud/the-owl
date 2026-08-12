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
3. **~~Assimetria do par (ADR-028)~~ → RESOLVIDA pelo ADR-034, condicional à mesma verificação.** **0 de 13** personas-comando têm frontmatter YAML. O ADR-028 exige que a edição toque **as duas** cópias e chama tocar só uma de **fase FALHOU**. O **ADR-034** (2026-08-07) foi escrito exatamente por isto — o conflito travava **dois** candidatos. A cláusula: campo imposto pela harness cuja superfície-irmã **não impõe equivalente** pode landar só na que impõe, com as duas metades listadas e a excluída marcada com a razão. ⚠️ **Condição ainda não satisfeita:** *"não impõe equivalente"* tem que ser **verificado** (ADR-013), e o teste é **imposição**, não ausência. **A mesma verificação que a Q1 exige para `Memory`/`isolation` cobre isto** — faça as duas no mesmo fetch. Se um comando impuser equivalente, não há assimetria e a edição vai nas duas metades.
4. **Duplicação com o bloco de prosa.** Se `maxTurns` entrar, a prosa de economia de turnos fica, sai, ou muda? Elas não fazem a mesma coisa (pedido × imposição) — mas manter as duas sem dizer a relação é o tipo de sobreposição que o ADR-009 existe para impedir.
5. **Carve-out.** `challenger`/`guardian`/`sentinel` estão fora — foram escopados por mão humana e o loop nunca os edita. Sobram no máximo 10.

## O que este candidato NÃO é

Não é "adotar todos os campos de frontmatter de 2026". Essa é a forma vaga de 2026-07-23, e ela continua sem fatia atômica. O delta é **um campo imposto, verificado, com número justificado, num conjunto nomeado de agentes**.

---

# PONTUAÇÃO — ciclo 9 (2026-08-12) — **DEFERRED (73)**

## Q1 — RESOLVIDA, e a resposta é boa: os TRÊS campos são reais

Verificação alvo na doc primária ([sub-agents](https://code.claude.com/docs/en/sub-agents), buscada 2026-08-12). Lista completa de campos de frontmatter de subagent, verbatim:

> "…`description`, `prompt`, `tools`, `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`, `maxTurns`, `skills`, `initialPrompt`, `memory`, `effort`, `background`, `isolation`, and `color`."

| campo | veredito | correção ao candidato |
|---|---|---|
| `maxTurns` | **REAL** — *"Maximum number of agentic turns before the subagent stops"* | — |
| `memory` | **REAL** | o candidato escreve `Memory`; **o campo é minúsculo** |
| `isolation` | **REAL** — *"Set to `worktree` to run the subagent in a temporary git worktree"* | só aceita `worktree`; é concern de **VCS/runtime**, não de prompt |

**O bloqueio P4/P5 caiu por inteiro.** A reabertura estava certa. E ainda assim o candidato **não passa** — por mérito, não por bloqueio, que é o desfecho que o passo 4.6 sempre disse ser possível (*"reabrir ≠ aceitar"*). Primeira vez que essa distinção é exercida na prática.

## Q2 — o trade-off que o próprio candidato nomeou é o que o afunda

> "Cap não é economia, é corte. Agente que bate o teto entrega trabalho truncado, e o `/owl:evolve` trata artefato ausente como **fase FALHOU**. Teto errado troca custo por falha de ciclo."

Está correto, e **não existe dado para escolher o número**: a-owl nunca instrumentou contagem de turnos por agente. `.owl/state/last-cycle-metrics.json` captura wall-clock, não turnos. Escolher `maxTurns` hoje é chutar um teto cujo erro converte custo em ciclo quebrado — e o custo que ele atacaria (`cost` no `last-run.json`) está registrado como *"not instrumented this run"* há dois ciclos.

**Fixar o teto antes de medir a distribuição é a ordem errada das operações.**

## Q4 — duplicação com a prosa, não resolvida

O bloco *"O custo do agente = piso de contexto × nº de turnos"* está em 4 dos 13 subagents. Se `maxTurns` entra, a relação prosa↔campo precisa ser declarada (pedido × imposição) ou vira a sobreposição que o ADR-009 existe para impedir. O candidato levanta e não resolve — corretamente, é decisão de integrate — mas somado ao Q2 não sobra fatia pronta.

## Curator verdict — score 73 (threshold 75 · reject 60)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 19 | Campo imposto pela harness, superfície certa. −6: `isolation` é worktree/VCS (fora do que a-owl faz) e `memory` sobrepõe o sistema de memória que a-owl já tem — só `maxTurns` sobrevive à triagem, e a ideia como escrita agrega três coisas distintas. |
| Evidence strength (20) | 18 | Os três campos verificados na doc primária hoje, com citação. Evidência **da existência** é forte. −2: nenhuma evidência sobre o **valor** de aplicá-los aqui. |
| Impact (20) | 10 | Direção do efeito **desconhecida**. O ganho (menos tokens) não está quantificado — o próprio `last-run.json` diz `cost: not instrumented`. A perda (truncar um agente ⇒ fase FALHOU) é concreta e nomeada. Impacto esperado plausivelmente **negativo** sem dado de calibração. |
| Simplicity & reversibility (15) | 10 | Uma linha por agente, revert trivial. −5: escolher o **número** não é simples e não é derivável de nada que a-owl tenha hoje. |
| Safety (10) | 8 | Não é risco de segurança. −2: é risco de **confiabilidade** — teto errado quebra ciclo, e o loop já trata artefato ausente como falha dura. |
| Non-duplication (10) | 8 | −2: sobrepõe o bloco de prosa de economia de turnos em 4 agentes, sem a relação declarada (Q4 aberta). |

**Safety 8 ≥ floor 7** (sem veto). **Total 73 → entre 60 e 75 ⇒ DEFERRED.**

## ➡️ Condição de reabertura — precisa, verificável, com prazo de premissa

Reabrir como `agent-frontmatter-fields-v3` **quando, e só quando**, existir distribuição medida de turnos por agente — ou seja, quando `.owl/state/last-run.json` carregar `cost`/turnos reais por pelo menos 3 ciclos. Aí `maxTurns` deixa de ser chute e vira p95+margem.

⚠️ **Escopo do v3, já delimitado para não reabrir a agregação inteira:** só `maxTurns`. `memory` e `isolation` são reais mas **fora de alcance por mérito** (memória já resolvida; worktree é concern de VCS que a-owl não usa) — isso é decisão, não bloqueio pendente, e não deve voltar como "bloqueio caiu".

## Related
- [[structural-properties]] (P4, P5 — as propriedades cujo estado destravou isto) · [[ledger]] (deferral do ciclo 1; achado de capacidade do ciclo 7)
- [[scout-notes-2026-08-12]] (a verificação que resolveu Q1) · [[least-privilege-tool-scopes-v2]] (irmão de reabertura — este passou, aquele não)
- ADR-033 (forma B — o passo 4.6, cujo **primeiro alvo vivo** é este) · ADR-028 (regra do par) + **ADR-034** (a cláusula de assimetria que resolveu a Q3, condicional à verificação) · ADR-013 (verificação de claim — obrigatória para Q1) · ADR-010 (o modelo inline, origem do bloqueio P4)
- Irmão de reabertura: `least-privilege-tool-scopes-v2` — mesmo evento (PR #17), mesmo conflito ADR-028, mesma verificação pendente
