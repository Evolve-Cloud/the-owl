# ADR-039 — Liveness de mecanismo se verifica olhando para trás, não de dentro

**Status:** Accepted
**Date:** 2026-08-12
**Author:** @architect (ciclo 10 do `/owl:evolve`, backlog pass)
**Tags:** [liveness, silent-failure, operations, adr-033, adr-017]

## Contexto

A-owl tem **ADR-033** para propriedade estrutural que **expira**. Não tem nada para o caso vizinho: **um mecanismo que afirma rodar e não roda.** A diferença importa — propriedade expirada produz decisões erradas (ruidoso); mecanismo morto produz **silêncio**, indistinguível de "nada a fazer".

Duas instâncias, ambas de 2026-08-12, ambas verificadas:

1. **A cadência semanal esteve morta ~3 semanas.** `launchctl list` mostrava o job **carregado, exit status 0** — a checagem óbvia dizia "saudável" — enquanto o programa não existia, e o `StandardErrorPath` do plist apontava para dentro da mesma casca, então o log que denunciaria isso tinha **0 bytes** num lugar que ninguém olha. Consertado em `134fa56`. Ciclos 6, 7, 8 e 9 foram **todos** disparados por humano.
2. **`cost` "TODO" há 2+ ciclos.** `last-cycle-metrics.json` carrega `cost_usd: null`; o `last-run.json` do ciclo 8 diz `"not instrumented this run"`. **Essa falta de dado deferiu `agent-frontmatter-fields-v2` (73) no ciclo 9** — sem distribuição de turnos, `maxTurns` é chute. Mecanismo morto custou uma decisão.

### O achado que o grounding produziu, e é ele que define a forma

**Toda a verificação de liveness da-owl vive DENTRO do loop.** Verificado:
- `evolve.md` tem **6** verificações de saída por fase (*"artefato ausente = fase FALHOU"*) — liveness real, no nível de **fase**;
- `curator.md` tem **4.5** (staleness de convenções, relógio) e **4.6** (bloqueio expirado, evento) — nenhum sobre mecanismo;
- `owl-metrics.py` lê `last-cycle-metrics.json` para **reportar custo**, não para julgar se o ciclo rodou.

⇒ **O verificador está dentro da coisa verificada.** As 6 checagens só rodam quando um ciclo roda. Se nenhum roda, ninguém repara. Não é esquecimento — é **topologia**, e é a resposta para *"quem verifica o verificador?"*: hoje, ninguém.

### E isso resolve relógio × evento de um jeito não-óbvio

Mecanismo morto **não emite evento** — a **ausência** é o sinal — então o modelo do 4.6 (evento) não serve. Mas também **não pede daemon novo**: quando um ciclo eventualmente roda (todos os 6–9 rodaram, por disparo humano), ele pode olhar **para trás**. Um processo novo para vigiar seria só mais uma coisa capaz de morrer em silêncio — o problema, não a solução.

**E o dado já existe e ninguém lê:** `.owl/state/daily-*.log`, um arquivo por run real. Os únicos são **23 e 24/jul**. A ausência deles era a evidência, disponível o tempo todo.

## Decisão

**Passo 4.7 no `curator.md`** (o par, ADR-028), completando a série que o agente já tem:

| passo | relê o quê | cadência | ADR |
|---|---|---|---|
| 4.5 | convenções **aceitas** | relógio | ADR-017 |
| 4.6 | bloqueios que são **propriedade estrutural** | **evento** | ADR-033 |
| **4.7** | **mecanismos que afirmam rodar** | **relógio, retroativo** | **este** |

O 4.7 responde uma pergunta factual, verificável sem juiz: **para cada mecanismo da lista, quando ele produziu evidência de execução pela última vez, e isso está dentro da cadência declarada?**

Lista inicial, cada um com o artefato que **prova** execução:

| mecanismo | prova de execução | cadência declarada |
|---|---|---|
| schedule semanal | `.owl/state/daily-*.log` mais recente | `loop-config.yml` → `cadence: weekly` |
| instrumentação de custo | `cost_usd` não-nulo em `last-cycle-metrics.json` | todo ciclo |
| passo 4.6 (ADR-033) | entrada no `log.md` quando o gatilho dispara | por evento — **ausência é esperada**, não é falha |

⛔ **Lê e reporta. Nunca conserta.** O schedule, `.owl/loop-config.yml` e `.claude/settings.json` são carve-out NFR-SEC-1: o passo pode dizer *"o schedule não produz run há 3 semanas"* e **não pode** consertá-lo. Reparo é do dono.

## Alternativas consideradas

- **Alternativa A (escolhida): passo em-ciclo, olhando para trás.** Prós: sem processo novo; reusa a forma 4.5/4.6 que o agente já tem; lê dado que já existe; não pode morrer separadamente do loop. Contras: **só detecta quando um ciclo roda.** Se ninguém rodar nada por 3 meses, o 4.7 fica em silêncio junto — dito sem maquiagem abaixo.
- **Alternativa B: um segundo job agendado que vigia o primeiro.** Prós: detecta mesmo com o loop parado. Contras: **rejeitada** — é mais uma coisa que pode morrer em silêncio, e morreria pelo mesmo motivo (caminho errado, log num lugar que ninguém lê). Vigiar um mecanismo frágil com outro do mesmo tipo não reduz o risco, duplica.
- **Alternativa C: fazer o `owl-daily.sh` alertar em falha.** Prós: mais perto da fonte. Contras: rejeitada — **é o script que não roda**. Um alerta dentro do que está morto é a mesma armadilha topológica de novo, e o `exit 4` de `134fa56` já cobre o pedaço que dá para cobrir de dentro.

## Consequências

**Fica mais fácil:** "o schedule está rodando?" passa a ter resposta escrita e datada, em vez de depender de alguém estranhar uma ausência. E as duas instâncias que já custaram — 3 semanas de cadência e um deferral — viram detectáveis.

**Fica mais difícil / trade-off aceito:** é o **terceiro** passo periódico no `curator`. Passo periódico que ninguém lê vira cerimônia — risco que o 4.5 já carrega e que este herda. Mitigação: o 4.7 grava no `log.md` **sempre**, inclusive "tudo dentro da cadência", pelo mesmo motivo que o 4.5 grava — deixar rastro auditável em vez de virar no-op invisível.

**⚠️ O limite honesto, que a alternativa B teria coberto e esta não:** o 4.7 **só roda quando um ciclo roda**. Ele teria pego o schedule morto na primeira vez que alguém disparasse um ciclo à mão — que aconteceu 4 vezes (ciclos 6–9) — mas **não** detecta um repo completamente parado. Isso é aceito conscientemente: repo parado tem sinal humano (ninguém está usando), enquanto repo em uso com automação morta é justamente o caso invisível.

**Duplicação parcial, declarada para ninguém deletar o errado:** o `evolve.md` já verifica saída **por fase**. O 4.7 **não** o substitui e não é substituído por ele — a diferença é **escopo** (fase × mecanismo) e **ponto de observação** (dentro da execução × olhando para execuções passadas). Se alguém achar que são a mesma coisa e remover um, o que se perde é a detecção de "não houve execução nenhuma".

## Notas de implementação

**`arquivo_alvo` (ADR-028 — o par, prosa, SEM exceção do ADR-034):**
- ✅ `.claude/agents/curator.md` **e** `.claude/commands/agents/curator.md` — **as duas metades recebem a MESMA edição.** É prosa comportamental; a exceção do ADR-034 vale só para campo imposto pela harness, e não é o caso. Tocar só uma é **fase FALHOU**.

Inserir o **4.7** logo após o 4.6, seguindo a forma dos dois vizinhos (o que relê, com que cadência, o que registrar, o que **não** pode fazer).

**NÃO fazer:** não tocar `.owl/loop-config.yml`, o plist, `settings.json` ou git hooks; não criar job agendado novo; não fazer o passo consertar nada.

**Verificação:** (a) as **duas** cópias do par contêm o 4.7 e o diff toca exatamente 2 arquivos; (b) o texto diz explicitamente *lê e reporta, nunca conserta*; (c) a lista de mecanismos nomeia, para cada um, o **artefato que prova execução** — sem isso o passo é uma pergunta sem fonte.

---

## 🔬 Primeira execução do 4.7 — e ela achou um defeito NO PRÓPRIO 4.7

O passo foi rodado de verdade antes de landar, sobre os 3 mecanismos da tabela. Resultado:

```
daily-*.log mais recente : daily-2026-08-12.log   ← de HOJE
started_at (metrics)     : None
cost_usd (metrics)       : None
```

**O `daily-2026-08-12.log` é do meu dry-run de verificação do wrapper, não de uma run agendada.** O passo, como escrito originalmente, teria lido "log de hoje ⇒ schedule saudável" e **passado** — no dia seguinte ao schedule ter estado morto por 3 semanas.

**A causa é precisa:** o artefato *"existe um `daily-*.log`"* prova que **o wrapper rodou**, não que **o schedule disparou**. Wrapper roda também por invocação manual e por dry-run. Era o artefato errado.

**Correção aplicada antes de landar:** a prova do schedule passa a exigir **dois artefatos concordando** — o `daily-*.log` recente **E** `started_at` não-nulo em `last-cycle-metrics.json`. Foi exatamente o `started_at: null` que discordou e denunciou o dry-run.

> ⚖️ **Por que isto vale registrar em vez de só corrigir em silêncio:** o defeito é o **mesmo padrão** que o passo existe para pegar — um sinal que *parece* prova de execução e não é. O 4.7 achou isso em si mesmo na primeira execução, o que é o melhor argumento disponível a favor dele e simultaneamente a prova de que a escolha do artefato é a parte frágil do desenho. Qualquer mecanismo adicionado à tabela no futuro tem que responder: **este artefato prova que ESTE mecanismo rodou, ou só que algo rodou?**
