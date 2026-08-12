---
title: "Nada verifica se os mecanismos da-owl que afirmam rodar de fato rodam"
type: idea
tags: [reflection, liveness, silent-failure, adr-033]
sources: 0
awaiting_scoring: cycle-10
raised: 2026-08-12
raised_by: human-directed (dono, após o ciclo 9 produzir 2 instâncias frescas)
updated: 2026-08-12
---

> [!important] **NÃO pontuado, e sem linha no `ledger.md` — os dois de propósito.**
> Levantar não é aceitar. O passo 1 do `curator.md` pula id que já está no ledger, então uma linha prematura mataria isto em silêncio e faria *parecer* feito. O @curator escreve a linha quando pontuar, no ciclo 10. O **ato** de levantar tem linha própria (`hd-raise-mechanism-liveness`), com id distinto.

**Categoria:** self-improvement / operations · **Confiança:** high (a evidência é do próprio repo) · **Aplicabilidade:** 5/5

## A lacuna

A-owl tem **ADR-033** para propriedade estrutural que **expira** (afirmação que era verdadeira e deixou de ser). Não tem nada para o caso vizinho e mais barato de detectar:

> **um mecanismo afirma que roda — ele roda?**

Não é sobre propriedade ficar obsoleta. É sobre automação que **está instalada, parece saudável e não faz nada**. O modo de falha é pior que o do ADR-033: uma propriedade expirada ainda produz decisões (erradas); um mecanismo morto produz **silêncio**, que é indistinguível de "nada a fazer".

## Instância 1 — a cadência semanal esteve morta ~3 semanas (verificado, consertado 2026-08-12)

O plist e o `owl-daily.sh` apontavam para `~/Evolve Labs/the-owl` — faltando um nível `Evolve Labs`.

**Por que sobreviveu 3 semanas é a parte que importa:**
- o caminho errado **existe** (casca com só `.owl/` + `venv/`, sem git), então o `cd "$REPO"` **sucedia** e a falha vinha depois, no `grep` do loop-config, sob `set -e` — saída silenciosa;
- `StandardErrorPath`/`StandardOutPath` do plist apontavam para dentro da **mesma casca** ⇒ o log que denunciaria isso era escrito onde ninguém olha, e ficou com **0 bytes**;
- `launchctl list` mostrava o job **carregado, exit status 0** — a checagem óbvia dizia "saudável";
- os únicos `daily-*.log` no repo são de **23 e 24/jul**. Essa ausência era a única evidência disponível, e ninguém a leu como evidência.

**Consequência:** ciclos 6, 7, 8 e 9 foram **todos** disparados por humano. O `.owl/loop-config.yml` declara `cadence: weekly, day: monday` e o `last-run.json` de cada ciclo registrava a data — **e nenhum registrou que a data não era segunda.** O ciclo 9 rodou numa quarta e o único lugar onde isso aparece é uma nota em prosa que eu escrevi à mão.

## Instância 2 — `cost` "instrumentado" há 2+ ciclos, nunca capturado

`owl-daily.sh` escreve `last-cycle-metrics.json` com `cost_usd: null` + `"note": "TODO (populate from codex/claude session usage)"`, e o `last-run.json` do ciclo 8 diz `"cost": "not instrumented this run"`. O ADR-012 declara custo como sinal do loop; o `owl-metrics.py` lê esse arquivo para a seção COST.

Ninguém afirmou que funcionava — mas ninguém verificou **por quanto tempo** não funciona, e o arquivo carregava dados de julho de uma run que nunca aconteceu de verdade. **Foi exatamente essa falta de dado que deferiu `agent-frontmatter-fields-v2` (73) neste ciclo**: sem distribuição de turnos, `maxTurns` é chute. Um mecanismo morto custou uma decisão.

## Por que isto é candidato agora (a barra do ADR-027)

**n=2 instâncias frescas, ambas do mesmo dia**, é a barra ≥2× que o ADR-027 usa para elevar classe a candidato normal. E as duas foram achadas **por acaso** — a primeira porque o dono mandou consertar o que estivesse quebrado, a segunda como subproduto. Nenhum mecanismo da-owl as procurou.

> ⚖️ **O que NÃO é instância, para não inflar o n:** o FAIL do ADR-036 também foi falha silenciosa, mas de **classe diferente** — foi disciplina de verificação (afirmar um negativo sem rodar o grep), não mecanismo morto. Essa lição já está registrada no próprio ADR-036. Contá-la aqui seria fabricar evidência.

## Questões em aberto que o @curator precisa resolver ANTES de pontuar

1. **Qual é a unidade?** O ADR-033 aprendeu que **propriedade** era a unidade certa e **linha do ledger** era a errada. Aqui a unidade candidata é **mecanismo** (schedule, hooks, passo 4.6, harness de fitness, instrumentação de custo). Isso precisa ser verificado, não presumido — foi o erro da forma A do ADR-033.
2. **Relógio ou evento?** O ADR-033 escolheu **evento** porque propriedade estrutural muda raro e de repente. Liveness é o caso oposto: um mecanismo morre em silêncio e **não emite evento nenhum** — a ausência é o sinal. Isso empurra para **relógio**, e é a primeira coisa neste repo que genuinamente pede o oposto do 4.6. Confirmar antes de copiar o formato do 4.6.
3. **Quem verifica o verificador?** Um registro de liveness pode morrer do mesmo jeito. Uma checagem que roda **dentro** do ciclo (que é disparado por humano quando o schedule falha) é auto-sustentável de um jeito que um segundo job agendado não é. Provavelmente decisivo para a forma.
4. **Já implementado em parte?** O `/owl:evolve` **já** tem verificação de saída por fase (*"artefato ausente = fase FALHOU"*) — que é liveness no nível de **fase**. A pergunta é se isto é a mesma ideia um nível acima, ou coisa diferente. Se for a mesma, a fatia é estendê-la, não criar mecanismo novo.
5. **Carve-out.** O schedule, `loop-config.yml` e `settings.json` são NFR-SEC-1. Um mecanismo de liveness pode **observar e reportar** que o schedule está morto; **não pode consertá-lo**. A fatia tem que ser leitura + alerta, nunca reparo automático — e isso limita o valor de forma honesta: alerta que ninguém lê é o mesmo defeito noutra roupa.

## O que este candidato NÃO é

Não é *"adicionar monitoramento"*. Essa é a forma vaga que não tem fatia atômica e que a classe *Runtime-shaped* barraria. O delta é **uma pergunta escrita, verificável, sobre um conjunto nomeado de mecanismos, respondida onde alguém já está olhando**.

Também não é o guard que já landou: o `exit 4` do `owl-daily.sh` (commit `134fa56`) conserta **uma** instância — path errado nunca mais falha em silêncio. Ele **não** responde *"o schedule rodou semana passada?"*, que é a pergunta desta classe.

## Related
- [[structural-properties]] · ADR-033 (o vizinho: propriedade **expirada**; isto é mecanismo **morto**) · ADR-027 (a barra ≥2× que eleva a classe) · ADR-012 (custo como sinal — a instância 2) · ADR-010 (verificação de saída por fase — possível duplicação, Q4)
- Instância 1 consertada em `134fa56`; contexto completo em `research-vault/log.md` → `[2026-08-12]`
- Irmão na fila: [[inert-command-frontmatter]] (atrás deste, por evidência mais fresca aqui)
