# ADR-043 — Custo instrumentado: o wrapper captura $/tokens reais da sessão

**Status:** Accepted
**Date:** 2026-08-13
**Author:** dono (owner-directed — o wrapper `owl-daily.sh` é carve-out NFR-SEC-1, edição humana explícita)
**Tags:** [cost, instrumentation, adr-012, schedule]

## Contexto
`cost_usd`/`tokens` estavam `null` com nota "TODO" em `.owl/state/last-cycle-metrics.json` desde o ADR-012, e o mecanismo constava como **morto** na tabela do passo 4.7 (ADR-039). O dado ausente já custou uma decisão: `agent-frontmatter-fields-v2` (73) foi adiado por não existir distribuição de turn-count para escolher um cap. A regra vigente era correta ("não fabricar"), mas ninguém tinha ligado a captura.

## Decisão
`owl-daily.sh` passa a invocar `claude -p --output-format json`, salvando o result-JSON da sessão em `.owl/state/last-run-output.json` e parseando `total_cost_usd` + `usage.*_tokens` para `last-cycle-metrics.json`. Parse falhou ⇒ nulls + nota do erro — **nunca fabricar** (ADR-012). O texto final da sessão continua indo ao `daily-*.log` (extraído do campo `result`).

## Alternativas consideradas
- **A (escolhida): parse do result-JSON no wrapper.** Prós: números reais, zero mudança no loop em si, falha degrada para o estado anterior (nulls). Contras: acopla ao formato do `--output-format json` do Claude Code — se o schema mudar, o parse falha ruidosamente (nota no metrics) em vez de mentir.
- **B: o loop escrever o próprio custo em `last-run.json`.** Prós: mais perto da fonte. Contras: o loop estimando o próprio custo de dentro é a topologia que o ADR-039 acabou de rejeitar; e exigiria editar `evolve.md` para uma função de observabilidade.
- **C: continuar TODO.** Contras: mecanismo morto conhecido, custo de decisão já pago uma vez.

## Consequências
O passo 4.7 do curator passa a poder ler `cost_usd` não-nulo como prova de execução (linha "instrumentação de custo" da tabela dele sai de morta). Ressalva honesta registrada no código: em auth de assinatura o `total_cost_usd` pode reportar 0.0 — **tokens são o sinal durável**; o cap de `maxTurns` do `agent-frontmatter-fields-v2` volta a ser decidível quando houver série.

## Notas de implementação
Edição única em `scripts/owl-daily.sh` (carve-out — owner-directed, registrada). Verificação: próximo run agendado/manual deve produzir `last-cycle-metrics.json` com `cost_usd`/`tokens` não-nulos OU nota de parse-fail explícita; `owl-metrics.py` já lê o arquivo.
