---
title: "O bloco CONTEXT do prompt L0 afirma 5 propriedades falsas — e contradiz o próprio prompt"
type: idea
tags: [reflection, l0, prompt, structural-properties, adr-033]
sources: 2
status: accepted
score: 91
adr: ADR-035
origin: reflection
updated: 2026-08-12
---

**Categoria:** self-improvement / grounding · **Confiança:** high · **Aplicabilidade:** 5/5

## Pattern

Uma premissa estrutural expirada, embutida num prompt que é injetado **todo ciclo**, continua decidindo o que a pesquisa pode propor muito depois de a premissa ter caído. É a mesma classe que o ADR-033 ratificou um mecanismo para pegar — só que o alvo aqui não é linha de ledger nem ADR: é o **artefato de prompt**.

## O achado (verificado contra a árvore hoje)

`docs/planning/artifacts/chatgpt-research-brief-prompt.md:30-41` — o bloco `## CONTEXT`, injetado no prompt do codex a cada L0:

> "the-owl is a markdown-only, **NO-RUNTIME** library of **~8** specialized Claude Code agents (strategist, architect, system-designer, builder, guardian, sentinel, challenger, chronicler). […] Pure markdown + YAML + JSON prompts. **No orchestration engine, no swarm runtime, no daemon.**"

Contra `docs/conventions/structural-properties.md` (o registro que o ADR-033 forma B criou exatamente para isto):

| afirmação do bloco CONTEXT | propriedade | estado verificado |
|---|---|---|
| "NO-RUNTIME" / "no orchestration engine" | P1 | **FALSA** — Agent tool + 13 subagents nativos + agente `team` |
| "no daemon" | P2 | **FALSA** — launchd (`scripts/*.plist`) |
| (implícito: sem trigger surface) | P3 | **FALSA** — `.git/hooks/post-commit` + `post-checkout` ativos |
| "markdown-only" | P6 | **FALSA (parcial)** — Python e shell em `scripts/` |
| "**~8** agents", listados nominalmente | — | **FALSA** — são **13** |

### O agravante: o prompt montado hoje se contradiz internamente

A correção de 2026-08-07 (`hd-unstale-structural-property-claims`) consertou o bloco `## REJECTED CLASSES` do `research.md` — que é injetado **no mesmo prompt**. O resultado é que o prompt L0 deste ciclo, montado e enviado, diz nas duas pontas:

- linha ~33 (CONTEXT): *"No orchestration engine, no swarm runtime, no daemon."*
- linha ~117 (REJECTED CLASSES): *"Existem spawner (Agent tool + 13 subagents nativos), scheduler (launchd) e hooks de git ativos."*

Um documento único, enviado a um modelo, afirmando A e ¬A com 84 linhas de distância.

### A causa-raiz, e é ela que precisa do conserto durável

`structural-properties.md` → seção *"O que depende deste registro (manter em sincronia — os dois sentidos)"* lista `research.md`, `evolve.md`, `ledger.md`, ADR-010/001/030. **Não lista o artefato 8a.**

O mecanismo do ADR-033 funcionou como projetado — o gatilho (a) disparou neste ciclo e a re-verificação aconteceu. O que falhou foi a **lista de alvos**: ela tem um buraco exatamente do tamanho do arquivo que carrega a afirmação para dentro do prompt. Consertar só o texto deixa a próxima propriedade expirar do mesmo jeito.

## Proposed change to the-owl

Duas edições que são **uma** mudança lógica (corrigir a afirmação + fechar o caminho que a deixou passar):

1. Reescrever `## CONTEXT` do artefato 8a para afirmar a **fronteira real** em vez da capacidade falsa — mesma forma da correção de 2026-08-07 no bloco de classes: dizer que o runtime **existe** e que o loop **não pode mexer nele** (carve-out + escolha sequencial do ADR-010). E `13`, não `~8`.
2. Adicionar o artefato 8a à lista de dependentes de `structural-properties.md`, com a nota de que ele é injetado no prompt do L0 a cada ciclo.

⛔ **Explicitamente FORA desta mudança:** qualquer edição em `.claude/commands/owl/evolve.md` para além do que já foi corrigido em 2026-08-07, e qualquer edição de git hook.

## L1.5 self-audit (ADR-005)

- **`já_implementado?`** **NÃO.** O bloco CONTEXT está intacto desde a criação do artefato; a correção de 2026-08-07 tocou `research.md`, não o 8a. Verificado lendo os dois arquivos hoje.
- **`onde_está_o_gap`** `docs/planning/artifacts/chatgpt-research-brief-prompt.md:30-41` (a afirmação) **+** `docs/conventions/structural-properties.md` §"O que depende deste registro" (a razão de ninguém ter pego).
- **`arquivo_alvo`** `docs/planning/artifacts/chatgpt-research-brief-prompt.md` · `docs/conventions/structural-properties.md`
  - **ADR-028 N/A:** nenhum dos dois é persona; não existe par `agents/` ↔ `commands/agents/`. A regra do par não se aplica e a cláusula do ADR-034 não é invocada.
  - **Carve-out:** nenhum dos dois caminhos está na allow-list de bloqueio do NFR-SEC-1. Confirmado item a item.

## Curator verdict — score 91 (threshold 75)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 23 | Correção de fato num artefato de prompt que a-owl possui. Exatamente a forma que a-owl trata (prompt/convenção). −2: é maquinaria do loop, e mexer nela merece o gate inteiro — mas `docs/planning/artifacts/` não é carve-out, e há precedente direto (a correção de 07-08 no bloco irmão). |
| Evidence strength (20) | 19 | Não é evidência externa — é **ground truth interno**, que aqui é mais forte. Cada uma das 5 propriedades tem estado verificado + caminho-prova + data em `structural-properties.md`, e a contradição é demonstrável lendo o prompt montado neste ciclo. −1: o registro foi verificado em 07-08, não re-verificado caminho a caminho hoje. |
| Impact (20) | 15 | Degrada o L0 **a cada ciclo**. O sumário executivo deste brief abre com *"most recent multi-agent coding material is runtime-shaped"* — o modelo gastou o orçamento do eixo filtrando contra uma premissa parcialmente falsa. ⚠️ **PROVISÓRIO-PENDENTE-DE-FITNESS (ADR-015)**: é afirmação comportamental (muda o que o codex produz). Crédito cheio só depois de medir. |
| Simplicity & reversibility (15) | 15 | Um bloco de prosa num arquivo + uma linha numa tabela. `git revert` de um commit. |
| Safety (10) | 10 | Corrige uma afirmação falsa; **não adiciona capacidade nenhuma**. Reduz estritamente o risco de o loop raciocinar a partir de premissa falsa. Zero contato com carve-out. |
| Non-duplication (10) | 9 | Adjacente à correção de 2026-08-07 — mas **arquivo diferente**, e este foi omitido justamente porque o registro de acoplamento não o lista. Fechar o registro é a parte não-duplicada. −1 pela adjacência. |

**Safety sub-score 10 ≥ floor 7.** ✅

## Claim verification

- **Claim:** as 5 propriedades afirmadas no bloco CONTEXT são falsas hoje, e o registro de acoplamento omite o artefato 8a.
- **Source:** `docs/conventions/structural-properties.md` (registro ratificado, ADR-033 forma B, com caminhos-prova datados) + a árvore do repo.
- **Verdict:** **confirmed.**
- **Evidence:**
  > P1 "não há spawner" — **FALSA** — existem Agent tool, 13 subagents nativos e o agente `team` (fan-out paralelo) · prova: `.claude/agents/*.md` · verificado 2026-08-07

  E a lista de dependentes do mesmo arquivo, verbatim — o 8a não aparece:
  > `.claude/commands/owl/research.md` → o bloco `## REJECTED CLASSES` […] · `.claude/commands/owl/evolve.md` → o "Modelo de execução" […] · `research-vault/ledger.md` → razões de deferral […] · ADR-010 · ADR-001 · ADR-030

  Contagem de agentes, contra a árvore: `ls .claude/agents/*.md | wc -l` → **13** (o bloco diz "~8" e nomeia 8).

## Related
- **Sources:** [[scout-notes-2026-08-12]] · [[structural-properties]]
- ADR-033 (o mecanismo — funcionou; o que falhou foi a lista de alvos) · ADR-030 (o bloco irmão, já corrigido) · ADR-022 (retrieve-then-search-delta) · ADR-010 (a escolha sequencial que é a razão REAL da desqualificação)
- Irmão do mesmo ciclo: [[inert-command-frontmatter]]
