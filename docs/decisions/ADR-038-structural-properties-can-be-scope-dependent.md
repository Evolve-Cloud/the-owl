# ADR-038 — Propriedade estrutural pode ser dependente de ESCOPO: o P7 é verdadeiro no loop e falso no DevFlow

**Status:** Accepted
**Date:** 2026-08-12
**Author:** @architect (direção do dono, após o achado do gate L4 do ciclo 9)
**Tags:** [structural-properties, topology, adr-033, adr-010]

## Contexto

O gate L4 do ciclo 9 reprovou o ADR-036 e, como subproduto, achou que o **P7 do registro de propriedades é contradito pelo próprio caminho-prova dele**:

> | P7 | "topologia **hub-and-spoke**" | **VERDADEIRA** — especialistas devolvem o controle, nunca chamam uns aos outros | `.claude/commands/agents/*.md`, ADR-010 | 2026-08-07 |

Contagem verificada em 2026-08-12, **nas duas metades do par**:

```
grep -rl 'skill="agents:\|Skill tool: /agents:\|USE A SKILL TOOL'
  .claude/agents/           → 9 de 13
  .claude/commands/agents/  → 9 de 13   ← o caminho-prova do P7
```

Os mesmos 9, nas duas metades — **o par está consistente, não há deriva ADR-028.** E eles não mencionam o irmão em prosa; instruem a chamada, em maiúsculas (`architect.md:83`: *"**USE A SKILL TOOL** […] não apenas mencione '@builder' no texto"*).

### O primeiro enquadramento estava errado e foi descartado

A pergunta levada ao dono foi binária: *"hub-and-spoke é a escolha real (e os 9 são deriva a corrigir), ou peer-invocation é o mecanismo real (e o P7 está errado)?"* **As duas opções estão erradas**, e a contagem dos 4 que **não** fazem peer-invocation mostra por quê:

| não instrui peer-invocation | o que é |
|---|---|
| `curator`, `scout` | agentes que existem **só para o loop** |
| `team` | o **hub** orquestrador (ADR-011, N/A por design) |
| `challenger` | gate que **devolve veredito**, não delega |

Não é distribuição aleatória. **É exatamente o conjunto que vive dentro do loop ou é gate.** Os 9 que instruem são o pipeline **DevFlow** — os mesmos que vão no pack portátil `owl-agents/`.

E `evolve.md:21` fecha o outro lado, explícito: *"o orquestrador **lê o arquivo** do agente (`.claude/commands/agents/<nome>.md`) e **segue as instruções dele inline**"*. **O loop nunca invoca persona via Skill.**

## Decisão

**Uma propriedade estrutural pode ser verdadeira num escopo e falsa noutro.** O registro passa a poder declarar isso, e o P7 é cindido em duas linhas com escopo explícito:

- **P7a — dentro do `/owl:evolve`: VERDADEIRA.** O orquestrador lê inline; os agentes loop-only não chamam ninguém.
- **P7b — no DevFlow interativo: FALSA, por design.** 9 dos 13 pares instruem invocação peer via Skill tool.

**Nenhum arquivo de agente muda.** Não há nada quebrado neles — o que estava errado era o registro descrever um escopo e citar o outro como prova.

## Alternativas consideradas

- **Alternativa A (escolhida): cindir com escopo declarado.** Prós: é o que os arquivos de fato dizem; custo = uma tabela no registro, zero edição de agente; e **responde** o `routing-eligibility-mode` em vez de deixá-lo pendurado. Contras: o registro ganha um segundo eixo (escopo, além de capacidade×escolha), então fica um pouco mais pesado de ler.
- **Alternativa B: virar o P7 para FALSA.** Prós: uma linha. Contras: **rejeitada — seria trocar uma afirmação imprecisa por outra.** Hub-and-spoke é verdadeiro e load-bearing dentro do loop (é a razão de confiabilidade do ADR-010); marcar FALSA convidaria alguém a propor mesh dentro do ciclo.
- **Alternativa C: remover as instruções de peer-invocation dos 9 agentes.** Prós: o P7 volta a ser globalmente verdadeiro. Contras: **rejeitada, e é a que mais custa.** Mudaria 18 arquivos para fazer a realidade caber num registro, quebrando um mecanismo DevFlow deliberado e documentado — **conserta o mapa destruindo o território.**

## Consequências

**Fica mais fácil:** uma propriedade citada para desqualificar uma família de ideias agora carrega **onde** ela vale. O passo 4.6 (ADR-033) passa a poder responder *"expirou nesse escopo?"* em vez de só *"expirou?"*.

**Fica mais difícil / trade-off aceito:** o registro ganha um eixo. Toda propriedade futura precisa da pergunta *"isto vale em todo lugar, ou num escopo?"*, o que é um passo a mais — e é o passo cuja ausência produziu este ADR.

**Consequência imediata e concreta:** **`routing-eligibility-mode` está encerrado, não adiado.** Sua condição de reabertura era *"depende do dono resolver o P7"*. Resolvida, e a resposta é negativa: peer-invocation é o mecanismo real do DevFlow, então `disable-model-invocation` nas personas do pipeline **quebra** exatamente o que o P7b descreve. O id morre na forma proposta.

⚖️ **Fatia principiada que existe e NÃO está sendo tomada:** com o P7a isolado, aplicar elegibilidade de roteamento **só aos agentes loop-only** seria coerente — ali hub-and-spoke é o invariante real. Registrado e **não acionado**: é pequena, e ressuscitar um id rejeitado pela porta que o próprio gate abriu é o movimento que o ADR-036 recusou sob pressão. Se valer, o ciclo 10 pontua **do zero**, com id novo.

**Sem crédito de fitness a reivindicar:** isto não afirma que a-owl vai produzir melhor. É correção de fato sobre a própria estrutura — a mesma classe do ADR-035, e como ele, **não** é afirmação comportamental.

## Notas de implementação

1. `docs/conventions/structural-properties.md` — cindir a linha P7 em **P7a/P7b** com coluna de escopo preenchida; atualizar a seção *"A distinção que faz o trabalho"* (que diz *"P1–P6 são capacidade. P7–P8 são escolha"*) para acomodar o novo eixo.
2. `research-vault/ideas/routing-eligibility-mode.md` + o §"Condição de reabertura" do **ADR-036** — marcar a condição como **cumprida com resposta negativa**; o id fecha. Deixá-lo "reabrível" seria o modo de falha que o ADR-033 inteiro existe para combater.

**NÃO fazer:** não tocar nenhum arquivo de agente; não remover instruções de peer-invocation; não aplicar elegibilidade de roteamento a nada.

**Verificação:** a contagem 9/13 nas duas metades continua reproduzível pelo grep acima, e `evolve.md:21` continua dizendo "inline" — se qualquer um dos dois mudar, P7a/P7b precisam ser relidos (é o gatilho (a) do ADR-033).
