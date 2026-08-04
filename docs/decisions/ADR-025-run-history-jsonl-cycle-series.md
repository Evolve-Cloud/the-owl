# ADR-025 — Add append-only .owl/state/run-history.jsonl cycle series

**Status:** Accepted (decisão) — **trabalho ainda NÃO shipado** (forward work)
**Date:** 2026-08-03
**Author:** @architect
**Tags:** [state, telemetry, jsonl, meta, self-improvement]

> ℹ️ **Accepted ≠ já shipado.** Este ADR registra uma **decisão aceita**, não uma entrega concluída. O `.owl/state/run-history.jsonl` e o append no L5 do `evolve.md` descritos aqui são **trabalho futuro ainda não construído** (par do ADR-024). O deliverable shipado neste ciclo (retrieve-then-search-delta, ADR-022) **não depende** deste arquivo. Ver as "Notas de implementação" abaixo como a especificação a construir num ciclo seguinte.

## Contexto
A meta-reflexão L6 (ADR-024) precisa de uma **série temporal por ciclo** — novelty, accept-rate, diversity ao longo dos ciclos — para decidir se a pesquisa estagnou. Hoje esses números existem só como **prosa** dispersa: nos blocos narrativos do `research-vault/log.md`, nos blocos de ciclo do `ledger.md`, e num `.owl/state/last-run.json` que guarda **apenas o último ciclo** (é um snapshot, não uma série). Re-parsear prosa a cada L6 é frágil e não-determinístico.

`.owl/state/last-run.json` (verificado 2026-08-03) tem os campos certos para *um* ciclo (`net_new_candidates`, `accepted`, `rejected`, `deferred`, `candidates_surfaced`) mas é sobrescrito todo ciclo — a história se perde.

## Decisão
Adicionar `.owl/state/run-history.jsonl` — um arquivo **append-only, uma linha JSON por ciclo**, escrito pelo `/owl:evolve` no **L5**:

```
{"date":"2026-08-03","net_new_candidates":0,"accepted":0,"deferred":5,"rejected":0,"corpus_source_count":106}
```

Campos mínimos por linha: `date`, `net_new_candidates`, `accepted`, `deferred`, `rejected`, `corpus_source_count`. A L6 (ADR-024) lê essa série como **fonte determinística e machine-readable** em vez de re-parsear prosa.

`.owl/state/last-run.json` **permanece** como o snapshot-do-último-ciclo (não é substituído — os dois coexistem: `last-run.json` = último estado rico; `run-history.jsonl` = série enxuta append-only).

## Alternativas consideradas
- **Alternativa A (escolhida): JSONL append-only separado, escrito no L5.** Prós: série determinística sem re-parsear prosa; append-only = imutável por ciclo (histórico não se corrompe); JSONL satisfaz a constraint JSON-only da-owl (é linhas JSON, não um runtime); coexiste com `last-run.json` sem conflito. Contras: +1 arquivo de estado a manter em sincronia com a narrativa do log (aceito — a narrativa continua no log.md; o JSONL é o extrato numérico).
- **Alternativa B: L6 re-parseia `log.md` + `ledger.md` (prosa).** Prós: zero arquivo novo. Contras: frágil (a prosa varia de ciclo a ciclo — ex.: `idea_count` já se contradiz no frontmatter de vários briefs), não-determinístico, custo de tokens alto por L6. Rejeitada.
- **Alternativa C: expandir `last-run.json` para um array de todos os ciclos.** Prós: um só arquivo. Contras: reescrever-o-array-inteiro-todo-ciclo é read-modify-write (não append), propenso a corromper a série num crash de meio-de-ciclo; perde a propriedade append-only. Rejeitada.

## Consequências
- **Fica mais fácil:** a L6 lê uma série numérica limpa (novelty/accept-rate/diversity computáveis direto); auditar a saúde do loop ao longo do tempo vira um `cat *.jsonl`.
- **Fica mais difícil / trade-off:** +1 arquivo a escrever no L5; o `corpus_source_count` precisa ser contado no momento (barato: `ls research-vault/sources/*.md | wc -l`). A narrativa rica continua no `log.md` — o JSONL é extrato, não substituto.
- **`.owl/state/` NÃO é carve-out:** o carve-out (NFR-SEC-1) cobre `.owl/loop-config.yml`, o schedule, settings, sentinel/guardian/challenger — **não** os arquivos de estado de telemetria em `.owl/state/` (onde `last-run.json` e os logs diários já vivem e são escritos pelo loop). Escrever `run-history.jsonl` é a mesma classe de operação que já escrever `last-run.json`.
- **JSONL satisfaz a constraint JSON-only** (markdown+YAML+JSON, sem runtime): cada linha é JSON válido; sem daemon, sem serviço.
- **Novo risco:** append duplicado se um ciclo re-rodar no mesmo dia. Mitigação: o L5 checa se já existe linha com `date` de hoje antes de appendar (ou sobrescreve a linha do dia — idempotência por data), espelhando a checagem de `last-run.json` do Setup do `/owl:evolve`.

## Notas de implementação
- **@builder adiciona ao `.claude/commands/owl/evolve.md` L5** o append de uma linha ao `run-history.jsonl` — junto de onde já grava `last-run.json`. Campos: `date`, `net_new_candidates`, `accepted`, `deferred`, `rejected`, `corpus_source_count`.
- **Idempotência:** antes de appendar, se a última linha já é de hoje, substituir em vez de duplicar (mesma disciplina do "não repetir um ciclo já feito hoje" do Setup).
- **NÃO fabricar** números (ADR-012): os counts vêm do desfecho real do ciclo; `corpus_source_count` de `ls research-vault/sources/*.md | wc -l` no momento.
- **`last-run.json` permanece** — não removê-lo; os dois são complementares.
- **Não tocar** o carve-out. `.owl/state/run-history.jsonl` é telemetria de estado, mesma classe de `last-run.json`.
- **Verificação:** após um L5, `run-history.jsonl` tem exatamente uma linha nova (ou uma substituída) com JSON válido parseável; `last-run.json` continua sendo o snapshot rico.
