# ADR-024 — Add the L6 meta-reflection phase and reflector agent

**Status:** Accepted (decisão) — **trabalho ainda NÃO shipado** (forward work)
**Date:** 2026-08-03
**Author:** @architect
**Tags:** [self-improvement, reflection, L6, meta, delta, carve-out-aware]

> ℹ️ **Accepted ≠ já shipado.** Este ADR registra uma **decisão aceita**, não uma entrega concluída. O agente `reflector` (`.claude/commands/agents/reflector.md`) e a fase L6 no `evolve.md` descritos aqui são **trabalho futuro ainda não construído**. O deliverable shipado neste ciclo (retrieve-then-search-delta, ADR-022) **não depende** desta fase: o `research.md` degrada graciosamente porque `{{QUERY_AXIS}}` faz default para round-robin (`dia-do-ano mod 8`), sem dependência do reflector nem do `run-history.jsonl`. Ver as "Notas de implementação" abaixo como a especificação a construir num ciclo seguinte.

## Contexto
O loop `/owl:evolve` roda L0→L5 e para. Ele **age dentro de um ciclo** mas não **olha a série de ciclos** para ajustar o próprio comportamento de pesquisa. O sintoma: 4 ciclos consecutivos com 0 accepts e `net_new_candidates=0` (`.owl/state/last-run.json`; `research-vault/log.md`) — nenhuma fase existente é responsável por notar "a novidade secou, mude o eixo / aumente a recência". O @curator faz staleness de *convenções* (ADR-017 step 4.5), mas isso é sobre ideias decididas envelhecerem, não sobre a **saúde do pipeline de pesquisa** (novelty/accept-rate/diversity ao longo do tempo).

O ADR-022 introduz `{{QUERY_AXIS}}` e `{{RECENCY_CUTOFF}}` como alavancas de delta-search — mas nada as *move* de ciclo para ciclo. Falta uma fase que leia a série e recomende a próxima alavancagem, mantendo-se estritamente do lado seguro do carve-out.

## Decisão
Adicionar uma **fase L6 de meta-reflexão** ao `/owl:evolve` e um **agente `reflector` separado** (`.claude/commands/agents/reflector.md`, distinto do `curator`):

- **`reflector` lê a série de ciclos:** `research-vault/log.md` + os blocos de ciclo do `ledger.md` + `.owl/state/run-history.jsonl` (ADR-025). Pontua três sinais ao longo do tempo: **novelty** (net_new_candidates por ciclo), **accept-rate**, **diversity** (cobertura de eixos / concentração de aliases).
- **Saída L6 = uma ação loop-acionável concreta OU no-change+porquê**, logada **todo ciclo**:
  - Ação dentro do que o loop pode mexer sem carve-out: **rotacionar `{{QUERY_AXIS}}`** ou **aumentar `{{RECENCY_CUTOFF}}`**, via o caminho **gated de edição-de-prompt** (as variáveis vivem no prompt/skill, ADR-022 — fora do carve-out). Nunca auto-edita `.owl/loop-config.yml`.
  - OU **no-change + razão** (ex.: "novelty baixa é esperada nesta maturidade; cap é teto, não meta") — também logado, para a série ter continuidade.
- **Recomendações de config/cadência** (knobs de `.owl/loop-config.yml` — circuit breaker, budget, schedule): **recommend-to-human ONLY**, nunca auto-editadas (carve-out NFR-SEC-1).

`reflector` é separado de `curator`: o curator **decide ideias** (dentro de um ciclo); o reflector **avalia a série** (entre ciclos). Fronteiras distintas → agentes distintos (role-ownership, ADR-009).

## Alternativas consideradas
- **Alternativa A (escolhida): agente `reflector` + fase L6 separados.** Prós: separação de papéis limpa (curator=ideias, reflector=série); a meta-reflexão vira responsável nomeado por notar "novelty secou"; a ação (rotacionar eixo/subir recência) é carve-out-safe porque mexe no prompt, não no loop-config. Contras: mais um agente e uma fase (custo de turnos por ciclo — mitigado: L6 é leve, lê series + emite uma linha).
- **Alternativa B: enfiar a meta-reflexão no `curator` (estender step 4.5).** Prós: sem agente novo. Contras: mistura decisão-de-ideia com avaliação-de-série (fronteiras diferentes, cadências diferentes); incha o curator (já é dos maiores). Rejeitada por role-ownership.
- **Alternativa C: deixar a rotação de eixo automática no `research.md` (round-robin cego) sem reflexão.** Prós: zero agente. Contras: round-robin é o *default* (ADR-022), mas cego — não reage a "eixo X está seco, pule para Y"; sem série, sem aprendizado. A reflexão é o que torna a alavanca *informada*. Rejeitada (o default fica; a reflexão o sobrepõe quando tem sinal).

## Consequências
- **Fica mais fácil:** o loop **nota** quando a pesquisa estagna e **age** (dentro dos limites seguros) em vez de repetir 0-accept em silêncio; a rotação de eixo passa a ser informada pela série, não cega.
- **Fica mais difícil / trade-off:** +1 agente, +1 fase por ciclo (custo de turnos — ADR-018: turnos são a alavanca de custo; L6 tem que ser enxuto). A ação de edição-de-prompt precisa passar pelo **gate** (guardian/sentinel/challenger no L4) como qualquer edição — não é auto-aplicada crua.
- **Novo risco:** o reflector recomendar mexer numa alavanca que na verdade é carve-out. Mitigação dura: recomendações de `loop-config.yml`/cadência/schedule são **recommend-to-human only**; só `{{QUERY_AXIS}}`/`{{RECENCY_CUTOFF}}` (que vivem no prompt) são loop-acionáveis, e via o path gated.
- **Todo ciclo loga uma linha de reflexão** — a série fica auditável mesmo quando a decisão é no-change.

## Notas de implementação
- **@builder cria** `.claude/commands/agents/reflector.md` (papel: avaliar a série; NÃO decide ideias — delega isso ao curator; hub-and-spoke, retorna controle ao orquestrador). Declara Possui/Não-possui (role-ownership ADR-009) e Contrato de Handoff (ADR-004).
- **@builder adiciona a fase L6** ao `.claude/commands/owl/evolve.md`, após L5, lendo `log.md` + blocos de ledger + `run-history.jsonl` (ADR-025).
- **Carve-out (crítico):** L6 pode recomendar rotacionar eixo / subir recência **via edição de prompt gated**; **NUNCA** auto-edita `.owl/loop-config.yml`, o schedule, o safety_floor, ou sentinel/guardian/challenger. Recomendações a esses = **recommend-to-human**, logadas, não aplicadas.
- **Verificação:** `reflector.md` existe e segue as convenções de agente; a fase L6 no `evolve.md` referencia `run-history.jsonl`; cada ciclo emite a linha de reflexão no log.
- **Dependência:** ADR-025 (a série JSONL que a L6 lê). Se `run-history.jsonl` não existir ainda, a L6 cai para re-parsear o `log.md`/`ledger.md` (degradado, mas funcional).
