---
title: "Nada verifica se os mecanismos da-owl que afirmam rodar de fato rodam"
type: idea
tags: [reflection, liveness, silent-failure, adr-033]
sources: 0
scored: cycle-10 (2026-08-12b)
status: accepted
score: 88
adr: ADR-039
origin: reflection
raised: 2026-08-12
raised_by: human-directed (dono, após o ciclo 9 produzir 2 instâncias frescas)
updated: 2026-08-12
---

> [!note] **Levantado no ciclo 9 sem linha no ledger (de propósito); pontuado no ciclo 10, que é quando a linha foi escrita.** O mecanismo funcionou como projetado: o passo 1 do curator achou este arquivo como o **único** em `ideas/` sem linha, que é exatamente o ramo que o ciclo 8 registrou como "documentado e nunca exercitado".

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

---

# PONTUAÇÃO — ciclo 10 (2026-08-12b, backlog pass)

## L1.5 self-audit (ADR-005) — e o grounding deu um achado mais afiado que a página tinha

- **`já_implementado?`** **PARCIALMENTE — e o jeito como é parcial É o defeito.** Verificado contra a árvore:
  - `evolve.md` tem **6** verificações de saída por fase (*"artefato ausente = fase FALHOU"*) — isso **é** liveness, no nível de **fase**;
  - `curator.md` tem o **4.5** (staleness de convenções, relógio) e o **4.6** (bloqueio expirado, evento);
  - `owl-metrics.py` lê `last-cycle-metrics.json`, mas para **reportar custo**, não para julgar se o ciclo rodou.
- **🔑 O achado:** **toda a verificação de liveness da-owl vive DENTRO do loop.** Logo ela é estruturalmente incapaz de detectar **o loop não rodando**. As 6 checagens de fase só rodam quando um ciclo roda; se nenhum ciclo roda, ninguém repara. É por isso que 3 semanas de schedule morto passaram: o verificador está dentro da coisa verificada.
  Isso **responde a Q3** (*"quem verifica o verificador?"*): hoje, ninguém — e não por esquecimento, por topologia.
- **E responde Q2 (relógio × evento) de um jeito que eu não tinha visto.** Mecanismo morto **não emite evento** — a ausência é o sinal, então o modelo do 4.6 (evento) não serve. Mas também **não precisa de daemon novo**: quando um ciclo eventualmente roda (todos os ciclos 6–9 rodaram, por disparo humano), ele pode olhar **para trás** e responder *"quantos slots agendados passaram sem produzir run?"*. **Detecção por relógio, avaliada em-ciclo, retroativamente.** Sem processo novo — e um processo novo seria só mais uma coisa que pode morrer em silêncio.
- **O dado já existe e ninguém lê:** `.owl/state/daily-*.log` — um arquivo por run real. Os únicos são **23 e 24/jul**. **A ausência deles era a evidência**, disponível o tempo todo.
- **`onde_está_o_gap`** `.claude/commands/agents/curator.md` — tem 4.5 (relógio/convenções) e 4.6 (evento/propriedades), e **não tem** o terceiro: relógio/**mecanismos**.
- **`arquivo_alvo`** (ADR-028 — o **par**, prosa, sem exceção do ADR-034): `.claude/agents/curator.md` **+** `.claude/commands/agents/curator.md`. É prosa comportamental, então as **duas** metades recebem a mesma edição. Nenhuma exclusão.
  - **Carve-out:** o passo **lê e reporta**; nunca conserta o schedule (Q5 satisfeita). `curator` não é carve-out.

## Curator verdict — score 88 (threshold 75)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 23 | Terceiro passo na série que o `curator.md` já tem (4.5 relógio/convenções · 4.6 evento/propriedades · **4.7 relógio/mecanismos**). Reusa forma existente em vez de inventar. Lê dado que já existe (`daily-*.log`). −2: é o terceiro passo periódico no mesmo agente, e passo periódico que ninguém lê vira cerimônia — o risco que o 4.5 já carrega. |
| Evidence strength (20) | 19 | **Ground truth interno, não afirmação externa.** As 2 instâncias são deste repo, deste dia, com prova: o schedule morto (consertado em `134fa56`, com `launchctl list` dizendo "carregado, exit 0" enquanto o programa não existia) e `cost` TODO há 2+ ciclos. E o achado do L1.5 — verificador dentro do verificado — é verificável lendo `evolve.md` + `curator.md`. |
| Impact (20) | 17 | Uma das 2 instâncias **já custou uma decisão**: sem dado de turnos, `agent-frontmatter-fields-v2` foi deferido (73). A outra custou **3 semanas de cadência**. Não é impacto hipotético — é impacto já pago, duas vezes. −3: o passo **detecta**, não conserta; e alerta que ninguém lê é o mesmo defeito de roupa nova. |
| Simplicity & reversibility (15) | 13 | Um passo em prosa nas duas metades do par; a checagem é comparar a data do `daily-*.log` mais novo com a cadência declarada. Revert = apagar o passo. −2: exige nomear **quais** mecanismos entram na lista, e lista incompleta é o defeito que o ADR-035 acabou de pagar. |
| Safety (10) | 10 | **Lê e reporta, nunca repara.** O schedule, `loop-config.yml` e `settings.json` seguem carve-out intocado — o passo pode dizer "o schedule não roda há 3 semanas" e **não pode** consertá-lo. Zero capacidade nova. |
| Non-duplication (10) | 6 | −4, e é a nota mais honesta da tabela: sobrepõe **de verdade** a verificação por fase do `evolve.md`. A diferença é escopo (fase × mecanismo) e ponto de observação (dentro do ciclo × olhando para o ciclo). Real, mas é diferença **sutil**, e o ADR tem que dizê-la explicitamente ou alguém deleta um dos dois achando que é o mesmo. |

**Safety 10 ≥ floor 7.** ✅ · **ACEITO — 88.**

⚠️ **Sem haircut do ADR-015:** isto **não** é afirmação comportamental sobre a qualidade do output de um agente. É um passo que responde uma pergunta factual (*"a data do último `daily-*.log` está dentro da cadência?"*) cuja resposta é verificável sem juiz. Crédito de Impacto é cheio.

## Claim verification

- **Claim:** a-owl não tem verificação de liveness fora do loop, e por isso não pôde detectar o próprio schedule morto por ~3 semanas.
- **Source:** o próprio repo — `.claude/commands/owl/evolve.md` (6 verificações, todas em-fase), `.claude/commands/agents/curator.md` (4.5 e 4.6, nenhum sobre mecanismo), `.owl/state/daily-*.log` (só 2026-07-23 e 07-24), commit `134fa56`.
- **Verdict:** **confirmed.**
- **Evidence:**
  > `evolve.md`: *"**VERIFICAÇÃO DE SAÍDA (obrigatória, harness).** Toda fase declara um artefato esperado. Depois da fase, **confirmar que o artefato existe**"* — em-fase, portanto só roda quando um ciclo roda.

  E a ausência, que é o dado: `ls .owl/state/daily-*.log` → `daily-2026-07-23.log`, `daily-2026-07-24.log`. Nada entre 24/jul e 12/ago, com `cadence: weekly` declarado em `.owl/loop-config.yml`.

## Related
- [[structural-properties]] · ADR-033 (o vizinho: propriedade **expirada**; isto é mecanismo **morto**) · ADR-027 (a barra ≥2× que eleva a classe) · ADR-012 (custo como sinal — a instância 2) · ADR-010 (verificação de saída por fase — a duplicação parcial, Q4, resolvida acima)
- Instância 1 consertada em `134fa56`; contexto completo em `research-vault/log.md` → `[2026-08-12]`
- Irmão na fila: [[inert-command-frontmatter]] (atrás deste, por evidência mais fresca aqui)
