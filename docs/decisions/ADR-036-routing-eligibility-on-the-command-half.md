# ADR-036 — Elegibilidade de roteamento: a metade `commands/` declara que não é auto-selecionável

**Status:** **REJECTED no gate L4 (2026-08-12)** — a mudança foi aplicada, reprovada pelo @guardian e **revertida**. Nada foi commitado. O ADR fica como registro da decisão de NÃO fazer, e da razão.
**Date:** 2026-08-12
**Author:** @architect (ciclo 9 do `/owl:evolve`)
**Tags:** [orchestration, routing, frontmatter, topology, adr-034]

## Contexto

Cada especialista da-owl existe como **par** (ADR-028): um subagent nativo em `.claude/agents/` e uma persona-comando em `.claude/commands/agents/`. A divisão de trabalho é deliberada — o subagent existe **para** auto-delegação por Claude; a persona-comando existe para o pipeline determinístico que o `/owl:evolve` executa inline (ADR-010).

**Essa divisão não está expressa em lugar nenhum que a harness leia.** Verificado contra a árvore em 2026-08-12:

```
.claude/commands/agents/*.md → 13 arquivos, 0 com qualquer frontmatter
disable-model-invocation     → 0 ocorrências em todo o repo
```

Resultado: as duas metades do par são auto-invocáveis por Claude. Uma superfície duplicada para uma função que só precisa de uma — e a metade duplicada é composta de prompts de ~1000–1700 linhas.

### Convergência de dois fornecedores, ambos verificados na fonte primária neste ciclo

| plataforma | campo | doc verbatim |
|---|---|---|
| GitHub Copilot SDK | `infer: false` | *"Whether the runtime can auto-select this agent (default: `true`)"* |
| Claude Code | `disable-model-invocation: true` | *"prevent Claude from **automatically loading** this skill"* |

E a doc do Claude Code nomeia o caso de uso exatamente:
> *"Use this for workflows **with side effects** or that you want to control timing […] **You don't want Claude deciding to deploy because your code looks ready.**"*

### O `proposed_change` do brief estava errado, e a correção é o que torna a ideia viável

O brief L0 propôs adicionar um campo **`routing_mode`** com valores `auto`/`mandatory`/`explicit-only`, e marcou o próprio risco: *"if described as enforcement when the harness does not enforce it directly, it risks becoming unenforceable prose."*

`routing_mode` é um campo **inventado**. Adicioná-lo produziria exatamente o defeito que este mesmo ciclo achou em `inert-command-frontmatter` (11/11 blocos de frontmatter compostos só de campos que a harness ignora). O brief previu o risco e propôs a forma que o realiza.

**O delta não é um campo novo — é usar o campo que já é imposto.**

## Decisão

As **10 personas-comando não-carve-out** recebem frontmatter mínimo declarando que a metade `commands/` é invocada pelo pipeline, não auto-selecionada por Claude:

```yaml
---
description: <a linha de papel que o próprio arquivo já declara no H1>
disable-model-invocation: true
---
```

A auto-delegação continua disponível — pela metade `agents/`, que é onde ela pertence. `/agents:builder` digitado pelo usuário continua funcionando: `disable-model-invocation` bloqueia a invocação **por Claude**, não pelo humano.

### Exclusões, cada uma com razão

- ⛔ `challenger`, `guardian`, `sentinel` — **carve-out NFR-SEC-1**. O loop nunca os edita.
- ⛔ `.claude/commands/owl/evolve.md` — **território do dono.** Também não tem `disable-model-invocation`, e é a instância de maior impacto (é o loop autônomo que escreve ADRs, edita agentes e commita; a doc nomeia literalmente esse caso). Mas **um loop que ajusta a própria superfície de disparo é a classe que o carve-out mantém em mão humana, mesmo quando a edição aperta em vez de afrouxar.** Levantado, registrado, não acionado.
- ⛔ `.claude/agents/<x>.md` — assimetria estrutural verificada (ver abaixo).

## Alternativas consideradas

- **Alternativa A (escolhida): usar `disable-model-invocation` nas 10 personas não-carve-out.** Prós: campo imposto pela harness (sai da classe *Unenforceable prose*); expressa uma divisão que a-owl já escolheu; remove ~10 prompts longos do contexto de Claude; é restrição, não capacidade. Contras: cria bloco de frontmatter onde não havia nenhum em 10 arquivos; o benefício de roteamento é hipótese, não medição.
- **Alternativa B: o `routing_mode` do brief.** Prós: mais expressivo (3 estados). Contras: **rejeitada** — campo inventado que a harness ignora. Seria frontmatter inerte, e este ciclo acabou de catalogar 11 instâncias exatamente disso.
- **Alternativa C: não fazer nada; a duplicação é inofensiva.** Prós: zero risco. Contras: rejeitada, mas é a alternativa mais forte — em 9 ciclos não se observou dano por auto-invocação de persona. O que decide contra ela é o custo de contexto, que é **verificável** (a doc: *"This removes the skill from Claude's context entirely"*), enquanto o dano de roteamento é especulativo.

## Consequências

**Fica mais fácil:** a divisão híbrida (subagent = auto-delegação, comando = pipeline) passa a ser lida pela harness, não só afirmada em prosa. O contexto de Claude deixa de carregar 10 descrições de persona que duplicam os subagents.

**Fica mais difícil / trade-off aceito:** se alguém *quisesse* que Claude auto-carregasse uma persona-comando, agora precisa remover a linha. É a intenção — mas é uma porta que fecha.

**Risco novo, dito sem maquiagem:** `disable-model-invocation: true` remove a skill do contexto de Claude **inteiramente**. Se algum fluxo depende de Claude descobrir `/agents:<x>` sozinho, ele quebra silenciosamente. Verificado que o `/owl:evolve` **não** depende disso — o ADR-010 manda o orquestrador **ler o arquivo** (`Read`), não invocar o comando. Nenhum outro consumidor conhecido.

⚠️ **Crédito de Impacto: PROVISÓRIO-PENDENTE-DE-FITNESS (ADR-015)** — afirmação comportamental. Δ nulo na dimensão-alvo ⇒ reverter ou reetiquetar documentação-apenas.

## Notas de implementação

**`arquivo_alvo` (ADR-028 + ADR-034):**

- ✅ **RECEBEM a edição** — `.claude/commands/agents/`: `architect`, `builder`, `chronicler`, `curator`, `database-specialist`, `mcp-builder`, `scout`, `strategist`, `system-designer`, `team` (10).
- ⛔ **EXCLUÍDA COM RAZÃO VERIFICADA** — `.claude/agents/<x>.md`. A lista completa de campos de frontmatter de subagent, verbatim da doc primária, é `description, prompt, tools, disallowedTools, model, permissionMode, mcpServers, hooks, maxTurns, skills, initialPrompt, memory, effort, background, isolation, color` (+`name`). **`disable-model-invocation` e `user-invocable` não estão nela** — a elegibilidade de auto-delegação de um subagent é governada só por `description`. Não há equivalente a excluir. Assimetria **verificada, não presumida** (ADR-013).

> 📌 **Primeiro exercício do ADR-034 no sentido espelhado.** A cláusula foi escrita com a metade `commands/` como a excluída. Aqui a excluída é a metade `agents/`. O texto do ADR-034 é neutro quanto à direção (*"cuja superfície-irmã não impõe equivalente"*) e **sobreviveu sem emenda** — evidência de que a cláusula foi bem formada, não ajustada ao caso que a motivou.

**`description`:** derivada do **H1 que cada arquivo já carrega** (ex.: `# Builder Agent - Implementação`), não inventada. Deriva > invenção, e mantém as duas metades coerentes sem duplicar a descrição longa do subagent.

**NÃO fazer:** não tocar as 3 personas de carve-out; não tocar `owl/evolve.md` nem `owl/research.md`; não adicionar `routing_mode` nem qualquer campo fora da tabela de referência da doc.

**Verificação:** (a) as 10 têm frontmatter válido e as 3 de carve-out **não** foram tocadas; (b) nenhuma chave usada está fora da tabela de campos da doc primária; (c) `git diff --stat` toca exatamente 10 arquivos sob `.claude/commands/agents/`.

---

# ⛔ GATE L4 — @guardian: **FAIL**. Mudança revertida, nada commitado.

As três verificações acima **passaram** (10 arquivos, chaves válidas, carve-out intocado). A mudança foi reprovada por uma coisa que nenhuma delas testava.

## O defeito

Este ADR afirma, na seção *Consequências*:

> "Se algum fluxo depende de Claude descobrir `/agents:<x>` sozinho, ele quebra silenciosamente. Verificado que o `/owl:evolve` **não** depende disso […] **Nenhum outro consumidor conhecido.**"

**A última frase é falsa, e era verificável por `grep` antes de escrever.** O `/owl:evolve` foi checado; **os próprios agentes não foram.**

`grep -rl 'skill="agents:\|Skill tool: /agents:' .claude/agents/` → **9 de 13**: `architect`, `builder`, `chronicler`, `database-specialist`, `guardian`, `mcp-builder`, `sentinel`, `strategist`, `system-designer`.

Eles não mencionam o irmão em prosa — eles **instruem a invocação**, em maiúsculas:

> `architect.md:83` — **"USE A SKILL TOOL** (não apenas mencione): `skill="agents:system-designer"` · `skill="agents:builder"` […] **IMPORTANTE**: não apenas mencione "@builder" no texto — USE a Skill tool."

E a doc primária é explícita sobre o que `disable-model-invocation` faz com isso:

> "The `user-invocable` field only controls menu visibility, **not Skill tool access**. Use **`disable-model-invocation: true` to block programmatic invocation.**"

⇒ A mudança teria **quebrado o mecanismo de delegação que 9 dos 13 agentes instruem**, e quebrado em silêncio: a invocação simplesmente não aconteceria.

## A causa-raiz do erro, nomeada para não se repetir

O ADR checou **um** consumidor (o orquestrador), achou-o limpo, e **generalizou para "nenhum"**. É a mesma forma de raciocínio que o ADR-015 registrou quando o Δ=0 do `role-ownership` foi generalizado de 5 agentes para 13 — e que o resultado de fitness de 2026-08-07 recusou explicitamente repetir (*"Os outros 8 agentes herdam por analogia — que é exatamente o raciocínio que falhou. Não generalizo."*).

**Verificar um caso e escrever "nenhum outro conhecido" não é verificação — é a ausência dela, com a redação de uma.** O `grep` que refutou custou uma linha.

## 🔑 O achado maior, que o gate produziu e o ciclo não tinha

**P7 é falsa.** `docs/conventions/structural-properties.md` afirma:

> | P7 | "topologia **hub-and-spoke**" | **VERDADEIRA** — especialistas devolvem o controle, nunca chamam uns aos outros | `.claude/commands/agents/*.md`, ADR-010 | 2026-08-07 |

**9 de 13 agentes instruem literalmente chamar uns aos outros.** A propriedade é afirmada como verdadeira, com caminho-prova, e o caminho-prova a contradiz.

E P7 está classificada como **"escolha, não capacidade"** — a classe que o registro diz que *"só muda por decisão do dono"*. Ou seja: ou os arquivos divergiram da escolha sem ninguém decidir, ou a escolha nunca foi implementada. **Qualquer uma das duas é do dono, não do loop** — e é por isso que este gate não "conserta" nada, só reporta.

⚖️ Isto **não** é levantado como licença para reabrir a mudança por outro caminho. É levantado porque uma propriedade estrutural falsa é exatamente o que o ciclo 9 já está corrigindo em outro arquivo (ADR-035), e esta foi achada pelo mecanismo funcionando.

## ➡️ Condição de reabertura (`routing-eligibility-mode-v2`)

Reabrir **só depois** que o dono resolver a contradição de P7, porque a resposta determina se a ideia faz sentido:

- **Se hub-and-spoke é a escolha real** e as instruções de peer-invocation são deriva a corrigir ⇒ `disable-model-invocation` deixa de quebrar algo e vira **reforço** dessa escolha. A ideia volta forte.
- **Se peer-invocation via Skill é o mecanismo real** ⇒ P7 está errada no registro, e esta ideia está morta na forma proposta.

⛔ **Não reabrir como "aplicar só nos 4 agentes que ninguém invoca"** — foi considerado e recusado **aqui**, sob pressão de gate: redesenhar uma mudança para caber pela brecha que o gate abriu é como mudança ruim entra. E deixaria metade do par com semântica diferente da outra metade, sem ninguém ter decidido isso.

## O que sobrevive deste ADR

A pesquisa e a verificação continuam válidas e não precisam ser refeitas: `infer: false` (GitHub) e `disable-model-invocation` (Claude Code) são reais, convergentes, citados verbatim, e a assimetria do ADR-034 no sentido espelhado foi verificada. **O que falhou não foi a evidência — foi a análise de impacto.**
