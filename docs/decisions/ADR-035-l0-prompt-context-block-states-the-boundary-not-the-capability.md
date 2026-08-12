# ADR-035 — O bloco CONTEXT do prompt L0 afirma a fronteira, não a capacidade

**Status:** Accepted
**Date:** 2026-08-12
**Author:** @architect (ciclo 9 do `/owl:evolve`)
**Tags:** [grounding, l0, prompt, structural-properties, adr-033]

## Contexto

`docs/planning/artifacts/chatgpt-research-brief-prompt.md:30-41` é o bloco `## CONTEXT` do prompt que o L0 injeta no codex **a cada ciclo**. Ele afirma:

> "the-owl is a markdown-only, **NO-RUNTIME** library of **~8** specialized Claude Code agents […] Pure markdown + YAML + JSON prompts. **No orchestration engine, no swarm runtime, no daemon.**"

Contra `docs/conventions/structural-properties.md` — o registro que o ADR-033 (forma B) criou exatamente para ser a lista que se re-verifica — **cinco** dessas afirmações são falsas:

| afirmação | propriedade | estado verificado | prova |
|---|---|---|---|
| "NO-RUNTIME" / "no orchestration engine" | P1 | FALSA | `.claude/agents/*.md` (13), Agent tool, agente `team` |
| "no daemon" | P2 | FALSA | `scripts/com.evolvelabs.owl.daily.plist` (launchd) |
| (implícito: sem trigger surface) | P3 | FALSA | `.git/hooks/post-commit`, `post-checkout` ativos |
| "markdown-only" | P6 | FALSA (parcial) | Python e shell em `scripts/` |
| "**~8** agents", nomeados | — | FALSA | são **13** |

### O agravante: o prompt montado se contradiz internamente

A correção de 2026-08-07 (`hd-unstale-structural-property-claims`) consertou o bloco `## REJECTED CLASSES` do `research.md`, que é injetado **no mesmo prompt**. O prompt montado neste ciclo, portanto, afirma A e ¬A com 84 linhas de distância:

- CONTEXT (~linha 33): *"No orchestration engine, no swarm runtime, no daemon."*
- REJECTED CLASSES (~linha 117): *"Existem spawner (Agent tool + 13 subagents nativos), scheduler (launchd) e hooks de git ativos."*

### A causa-raiz — e é ela que precisa do conserto durável

O mecanismo do ADR-033 **funcionou**: o gatilho (a) disparou neste ciclo (caminhos-prova tocados), a re-verificação rodou, o defeito apareceu. O que falhou foi a **lista de alvos**. A seção *"O que depende deste registro (manter em sincronia — os dois sentidos)"* de `structural-properties.md` lista `research.md`, `evolve.md`, `ledger.md`, ADR-010/001/030 — e **não lista o artefato 8a**, que é o arquivo que carrega a afirmação para dentro do prompt.

Consertar só o texto deixa a próxima propriedade expirar exatamente do mesmo jeito.

## Decisão

O bloco `## CONTEXT` do artefato 8a passa a afirmar **a fronteira que de fato desqualifica** (o loop não pode mexer no runtime que existe: carve-out NFR-SEC-1 + a escolha sequencial do ADR-010), em vez da **capacidade falsa** ("não existe runtime") — a mesma forma da correção de 2026-08-07 no bloco irmão. A contagem de agentes passa a **13**.

E `docs/conventions/structural-properties.md` passa a **listar o artefato 8a** entre seus dependentes, marcado como injetado no prompt do L0 a cada ciclo.

## Alternativas consideradas

- **Alternativa A (escolhida): corrigir a afirmação E fechar o registro de acoplamento.** Prós: ataca a causa-raiz, não só a instância; o custo da segunda metade é uma linha; alinha o 8a ao bloco irmão já corrigido, eliminando a contradição interna. Contras: toca dois arquivos num commit — mitigado porque é **uma** mudança lógica (a afirmação e o caminho que a deixou passar são a mesma falha).
- **Alternativa B: só corrigir o texto do 8a.** Prós: diff mínimo. Contras: **rejeitada** — deixa o registro de acoplamento com o mesmo buraco, o que é literalmente a repetição do defeito de 2026-08-07, que também foi achado tarde por não haver lista. Consertar a instância e deixar o caminho aberto é o padrão que este ciclo inteiro existe para quebrar.
- **Alternativa C: apagar o bloco CONTEXT inteiro.** Prós: nada falso pode sobrar. Contras: rejeitada — o bloco faz trabalho real (ensina ao codex a forma do que é utilizável). Apagar o "ZERO" sem dizer a fronteira convida exatamente as propostas runtime-shaped que o filtro existe para barrar; foi o raciocínio já registrado em 2026-08-07 e continua valendo.

## Consequências

**Fica mais fácil:** o codex recebe um prompt internamente consistente e uma fronteira precisa, então gasta o orçamento do eixo filtrando pelo critério certo (o loop não pode mexer no runtime) em vez de um falso (o runtime não existe). O registro de acoplamento passa a cobrir o arquivo que estava fora dele.

**Fica mais difícil / trade-off aceito:** o bloco CONTEXT fica um pouco mais longo e menos slogan-like. É o preço honesto — a versão curta era curta porque era falsa.

**Risco novo:** a lista de dependentes de `structural-properties.md` cresce, e uma lista que cresce é uma lista que pode ficar incompleta de novo. Este ADR **não** resolve isso; ele fecha um buraco conhecido. A forma geral (como saber que a lista está completa) segue aberta e é candidata futura.

⚠️ **Crédito de Impacto: PROVISÓRIO-PENDENTE-DE-FITNESS (ADR-015).** A afirmação é comportamental — que isto muda o que o codex produz. Crédito cheio de Impacto só depois que o harness medir Δ na dimensão-alvo. Δ nulo ⇒ reetiquetar como documentação-apenas.

## Notas de implementação

Arquivos, nesta ordem:

1. `docs/planning/artifacts/chatgpt-research-brief-prompt.md` — substituir as linhas 30-41 (bloco `## CONTEXT`). Manter as propriedades que continuam **verdadeiras** e são as que fazem o trabalho de filtro: hub-and-spoke (P7), contexto-mínimo N-1, ADR-por-mudança, roda dentro do Claude Code. Trocar as negações de capacidade pela fronteira.
2. `docs/conventions/structural-properties.md` — adicionar o 8a na seção *"O que depende deste registro"*, com a nota de que é injetado no prompt do L0 todo ciclo.

3. `docs/planning/artifacts/research-brief-schema.md:44` — **terceiro arquivo, achado PELA verificação, não pelo plano.** O comentário do campo `applicability_to_owl` dizia *"5 = maps cleanly to a **markdown-only** hub-spoke lib"*: mesma propriedade falsa (P6), mesmo prompt montado, terceiro arquivo. Reescrito para o critério que de fato importa — *"expressible as a prompt/structure/convention change"*.

**NÃO fazer:** não tocar `.claude/commands/owl/evolve.md` (já corrigido em 2026-08-07); não tocar git hooks (superfície de segurança, decisão do dono); não editar `.owl/loop-config.yml`.

**Verificação:** remontar o prompt L0 e confirmar que (a) nenhuma das 5 afirmações falsas sobrevive, (b) CONTEXT e REJECTED CLASSES não se contradizem, (c) o número de agentes bate com `ls .claude/agents/*.md | wc -l`.

> ✅ **Executada, e ela achou algo — que é o ponto de ter critério de verificação escrito antes.** A primeira passagem voltou `markdown-only -> 1`: o plano listava dois arquivos, e havia **três**. O terceiro (8b, item 3 acima) não teria sido encontrado por revisão do diff, só por remontar o artefato final. Registrado aqui em vez de silenciosamente incorporado, porque "o plano estava incompleto e a verificação pegou" é informação sobre o método, não ruído.
>
> **Ainda aberto, de propósito:** a lista de dependentes agora cobre 8a; **8b entrou por achado, não por regra.** A pergunta geral — *como saber que a lista está completa?* — segue sem resposta e sem mecanismo. Nomeada aqui para não ser redescoberta como nova.
