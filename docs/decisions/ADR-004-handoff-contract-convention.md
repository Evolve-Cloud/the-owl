# ADR-004 — Convenção de Contrato de Handoff entre agentes

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect (via ciclo autônomo `/owl:evolve`)
**Tags:** [communication, agents, self-improvement, convention]
**Related:** ADR-001, `docs/conventions/handoff-contract.md`, `research-vault/ideas/handoff-contract.md`

## Contexto
Primeiro ciclo autônomo do loop de auto-melhoria (2026-07-23). Duas fontes de pesquisa independentes — o brief do codex (ChatGPT-side) e a pesquisa live do @scout (Claude-side) — convergiram fortemente na ideia `explicit handoff contracts / role boundaries`. Evidência: docs primárias da Anthropic (o handoff de subagente é assimétrico e baseado em resumo), além de CrewAI/AG2/MetaGPT. O @curator pontuou **91/100** (threshold 75), sem contato com o carve-out NFR-SEC-1, safety sub-score 10/10. A-owl tem handoffs implícitos em alguns agentes, mas nenhuma convenção padronizada.

## Decisão
Adotar uma convenção padronizada de **Contrato de Handoff** (`docs/conventions/handoff-contract.md`): todo handoff declara Objetivo · Entradas · Saída · Escopo · Critério de pronto · Próximo agente, respeitando contexto-mínimo (N-1) e hub-and-spoke. O rollout para dentro de cada agente é **incremental**, um agente por ciclo/ADR futuro.

## Alternativas consideradas
- **A (escolhida): convenção documentada agora + rollout incremental.** Prós: atômico, reversível, baixo risco, estabelece a fonte da verdade. Contras: impacto adiado até os agentes a adotarem (aceito — modela a incrementalidade do loop).
- **B: editar os 8 agentes de uma vez.** Prós: impacto imediato. Contras: não-atômico, difícil de revisar/reverter num único passo — rejeitado para o primeiro ciclo.
- **C: não fazer nada (handoffs implícitos).** Prós: zero mudança. Contras: mantém a ambiguidade que ambas as fontes apontam — rejeitado.

## Consequências
- **Mais fácil:** handoffs viram contratos verificáveis; base para o rollout por-agente.
- **Trade-off:** o valor só se realiza conforme os agentes adotam a seção (próximos ciclos).

## Notas de implementação
Arquivo criado: `docs/conventions/handoff-contract.md`. Próximo ciclo: adicionar a seção "Contrato de Handoff" a um agente-piloto (sugestão: `architect`), 1 agente por ADR. Nada aqui toca o carve-out.
