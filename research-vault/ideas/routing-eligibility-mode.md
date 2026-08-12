---
title: "Eligibilidade de roteamento por especialista — e a harness impõe"
type: idea
tags: [orchestration, routing, frontmatter, topology]
sources: 3
status: rejected
score: 84
adr: ADR-036 (rejeitado no gate L4)
origin: research
updated: 2026-08-12
---

**Categoria:** orchestration · **Confiança:** high · **Aplicabilidade:** 5/5

## Pattern

Separar **"este especialista existe"** de **"o orquestrador pode selecioná-lo automaticamente"**. Descrição de papel sozinha é sinal grosso demais para decidir delegação: agentes caros, disruptivos ou de escalada rara acabam elegíveis para invocação implícita só por existirem.

Dois fornecedores independentes convergiram no mesmo controle, os dois verificados na fonte primária neste ciclo:

| plataforma | campo | doc verbatim |
|---|---|---|
| GitHub Copilot SDK | `infer: false` | "Whether the runtime can auto-select this agent (default: `true`)" |
| Claude Code | `disable-model-invocation: true` | "prevent Claude from **automatically loading** this skill" |

## ⚠️ Correção ao `proposed_change` do brief — e é ela que torna a ideia viável

O brief propôs *"adicionar um campo `routing_mode` com valores `auto`/`mandatory`/`explicit-only`"* e marcou o próprio risco: *"if described as enforcement when the harness does not enforce it directly, it risks becoming unenforceable prose."*

**`routing_mode` é um campo inventado.** Adicioná-lo produziria exatamente o defeito que o ciclo achou em `inert-command-frontmatter`: frontmatter que parece configuração e não configura nada. O brief previu o risco e mesmo assim propôs a forma que o realiza.

**O delta real não é um campo novo — é usar o campo que já é imposto.** `disable-model-invocation` é lido pela harness. Isso tira a ideia da classe *Unenforceable prose* do ADR-030, que é o que a mataria.

## O gap na-owl (verificado contra a árvore hoje)

As personas-comando **são skills** — doc verbatim: *"Custom commands have been merged into skills. A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way."*

```
.claude/commands/agents/*.md → 13 arquivos, 0 com qualquer frontmatter
disable-model-invocation     → 0 ocorrências em todo o repo
```

**Consequência:** cada persona-comando é auto-carregável por Claude. E a-owl mantém **duas** superfícies para o mesmo papel (ADR-028): o subagent nativo, que existe **para** auto-delegação, e a persona-comando, que existe para o pipeline determinístico. Hoje as duas são auto-invocáveis — superfície duplicada para uma função que só precisa de uma.

O custo é concreto e nomeado pela própria doc: *"Hide individual skills by adding `disable-model-invocation: true`. **This removes the skill from Claude's context entirely.**"* As personas são prompts de ~1000–1700 linhas.

## Proposed change to the-owl

Adicionar frontmatter mínimo às **10 personas-comando não-carve-out**, declarando que a metade `commands/` é invocada pelo pipeline, não auto-selecionada:

```yaml
---
description: <a linha de papel que a persona já declara>
disable-model-invocation: true
---
```

A auto-delegação continua disponível — pela metade `agents/`, que é onde ela pertence. `/agents:builder` digitado pelo usuário continua funcionando (`disable-model-invocation` bloqueia só a invocação **por Claude**).

⛔ **Fora:** `challenger`, `guardian`, `sentinel` (carve-out NFR-SEC-1 — o loop nunca os edita). ⛔ **Fora:** `.claude/commands/owl/evolve.md` — ver a nota de fronteira abaixo.

> ⚖️ **A instância de maior impacto é do DONO, não do loop.** `/owl:evolve` também não tem `disable-model-invocation`, e a doc nomeia esse caso: *"Use this for workflows **with side effects** […] You don't want Claude deciding to deploy because your code looks ready."* Um loop que ajusta a própria superfície de disparo é a classe que o carve-out mantém em mão humana — **mesmo quando a edição aperta em vez de afrouxar**. Levantado, marcado, **não acionado**.

## L1.5 self-audit (ADR-005)

- **`já_implementado?`** **NÃO.** 0/13 personas-comando têm frontmatter; `disable-model-invocation` tem 0 ocorrências no repo. As 3 skills que usam `user-invocable: true` estão setando o **default**, o que é no-op.
- **`onde_está_o_gap`** `.claude/commands/agents/*.md` — 13 arquivos sem frontmatter, todos auto-carregáveis por Claude, duplicando a superfície de auto-delegação dos subagents nativos.
- **`arquivo_alvo`** (ADR-028 — o par; ADR-034 — assimetria verificada, **na direção espelhada**)
  - ✅ **RECEBE a edição:** `.claude/commands/agents/{architect,builder,chronicler,curator,database-specialist,mcp-builder,scout,strategist,system-designer,team}.md`
  - ⛔ **EXCLUÍDA COM RAZÃO VERIFICADA:** `.claude/agents/<x>.md` — a lista completa de campos de frontmatter de subagent, verbatim da doc primária, é `description, prompt, tools, disallowedTools, model, permissionMode, mcpServers, hooks, maxTurns, skills, initialPrompt, memory, effort, background, isolation, color` (+`name`). **`disable-model-invocation` e `user-invocable` não estão nela.** A elegibilidade de auto-delegação de um subagent é governada só por `description`. Não há equivalente a excluir — a assimetria é **estrutural e verificada**, não presumida.
  - ⛔ **EXCLUÍDOS por carve-out:** `challenger`, `guardian`, `sentinel`.
  - 📌 **Nota sobre o ADR-034:** a cláusula foi escrita para a metade `commands/` ser a excluída. Aqui a excluída é a metade `agents/`. A cláusula é **neutra quanto à direção** como está redigida (*"cuja superfície-irmã não impõe equivalente"*) — este é o primeiro exercício dela no sentido espelhado, e ela sobreviveu sem emenda.

## Curator verdict — score 84 (threshold 75)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 21 | Campo de frontmatter + convenção; hub-and-spoke preservado (só o orquestrador roteia; especialistas seguem sem chamar uns aos outros). Reforça a divisão híbrida que a-owl já escolheu. −4: exige criar bloco de frontmatter onde não havia nenhum em 10 arquivos, e a fatia depende de um julgamento (quais personas) que não é derivável de regra. |
| Evidence strength (20) | 19 | **Duas fontes primárias de fornecedores independentes, ambas buscadas e citadas verbatim neste ciclo** — GitHub `infer` e Claude Code `disable-model-invocation` — mais a doc nomeando o caso de uso de side-effect. −1: nenhuma das duas mede *resultado*; são docs de capacidade, não estudos de efeito. |
| Impact (20) | 13 | ⚠️ **PROVISÓRIO-PENDENTE-DE-FITNESS (ADR-015)** — afirmação comportamental. Ganho real mas modesto: em 9 ciclos não se observou dano por auto-invocação de persona. O ganho de contexto (remover ~10 prompts longos do contexto de Claude) é concreto e verificável; o ganho de roteamento é hipótese. A instância de alto impacto (`/owl:evolve`) é do dono, então a fatia do loop é a metade de menor impacto — dito sem maquiagem. |
| Simplicity & reversibility (15) | 13 | 3 linhas de YAML por arquivo, mecânicas; revert = apagar o bloco. −2: são 10 arquivos, e criar frontmatter onde não existia é maior que editar um campo existente. |
| Safety (10) | 9 | É **restrição**, não capacidade — reduz o que pode disparar sozinho. −1: mexe em superfície de invocação, que é adjacente ao espírito do carve-out; mitigado excluindo `evolve.md` e os 3 agentes-gate. |
| Non-duplication (10) | 9 | Nenhum id do ledger cobre elegibilidade de roteamento. −1: adjacente a `least-privilege-tool-scopes-v2` (os dois são "campo imposto no frontmatter"), mas o campo, a superfície e o efeito são distintos. |

**Safety sub-score 9 ≥ floor 7.** ✅

## Claim verification

- **Claim (a):** existe um controle de elegibilidade de auto-seleção, convergente entre fornecedores.
- **Source:** [GitHub Docs — Custom agents](https://docs.github.com/en/copilot/how-tos/copilot-sdk/features/custom-agents) · buscada 2026-08-12
- **Verdict:** **confirmed.**
- **Evidence:**
  > `infer` | `boolean` | "Whether the runtime can auto-select this agent (default: `true`)"
  >
  > …e na sequência de delegação: a seleção ocorre *"If a match is found and `infer` is not `false`"*.

- **Claim (b):** a harness do Claude Code **impõe** o equivalente — logo isto não é prosa inimponível.
- **Source:** [Claude Code — Extend Claude with skills](https://code.claude.com/docs/en/slash-commands) · buscada 2026-08-12
- **Verdict:** **confirmed.**
- **Evidence:**
  > "`disable-model-invocation` | Set to `true` to **prevent Claude from automatically loading this skill**. Use for workflows you want to trigger manually with `/name`."
  >
  > "By default, Claude can invoke any skill that doesn't have `disable-model-invocation: true` set."

---

# ⛔ DESFECHO — REJEITADA no gate L4 (2026-08-12). Aplicada, reprovada, revertida.

**Score 84 permanece.** O score registra **mérito**; o status registra **desfecho**. A pontuação não estava errada — a análise de impacto do integrate estava. (Mesma separação que o ADR-015 usa: `role-ownership` manteve `score: 87` quando o crédito foi rebaixado.)

**O defeito:** o ADR-036 afirmou *"nenhum outro consumidor conhecido"* depois de verificar **um** consumidor (o `/owl:evolve`). Um `grep` de uma linha refutou:

```
grep -rl 'skill="agents:\|Skill tool: /agents:' .claude/agents/   →  9 de 13
```

`architect`, `builder`, `chronicler`, `database-specialist`, `guardian`, `mcp-builder`, `sentinel`, `strategist`, `system-designer` **instruem** a invocação peer (`architect.md:83`: *"**USE A SKILL TOOL** […] não apenas mencione '@builder' no texto"*). E a doc primária: *"Use `disable-model-invocation: true` to **block programmatic invocation**"* — a mudança teria quebrado esse mecanismo nos 9, **em silêncio**.

**Achado que o gate produziu:** **P7 é falsa.** O registro afirma *"hub-and-spoke — especialistas nunca chamam uns aos outros — **VERDADEIRA**"*, com `.claude/commands/agents/*.md` como caminho-prova. O caminho-prova a contradiz em 9 arquivos. P7 é classificada como **escolha**, e escolha *"só muda por decisão do dono"* — então isto é reportado, não consertado.

**Reabertura: NENHUMA. Id ENCERRADO em 2026-08-12 (ADR-038).**

A condição registrada era *"depende do dono resolver P7"*. Foi resolvida no mesmo dia — e a resposta **não foi nenhuma das duas do binário**: o P7 não era verdadeiro nem falso, era **verdadeiro do loop arquivado como afirmação global**. Cindido em P7a (dentro do `/owl:evolve`: VERDADEIRA) e **P7b (DevFlow interativo: FALSA por design — 9 de 13 pares instruem invocação peer)**.

⇒ Peer-invocation é o mecanismo **real e deliberado** da superfície que esta ideia mirava. `disable-model-invocation` ali **quebra** exatamente o que o P7b descreve. Não existe versão desta mudança que sobreviva nessa superfície. **Condição cumprida, resposta negativa, id fechado** — nenhum arquivo de agente mudou em consequência, porque não havia nada quebrado neles.

📌 Existe uma fatia coerente **só nos agentes loop-only** (onde o P7a é o invariante real). Registrada no ADR-038 e **não acionada**: se valer, o ciclo 10 pontua **do zero, com id novo**. Este id não volta.

## Related
- **Sources:** [[research-brief-2026-08-12]] · [[scout-notes-2026-08-12]]
- [[handoff-and-orchestration]] · [[role-decomposition]] · [[tool-design-and-capability-scoping]]
- ADR-028 (regra do par) + ADR-034 (assimetria — **primeiro exercício no sentido espelhado**) · ADR-030 (a classe *Unenforceable prose*, evitada por usar o campo imposto) · ADR-011 (`team` como hub)
- Irmãos do ciclo: [[least-privilege-tool-scopes-v2]] · [[inert-command-frontmatter]]
