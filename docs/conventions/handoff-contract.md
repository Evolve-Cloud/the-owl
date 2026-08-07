---
description: the-owl handoff-contract convention (ADR-004/ADR-020) — loaded when editing an agent, ADR, or convention
paths:
  - ".claude/commands/agents/*.md"
  - ".claude/commands/owl/*.md"
  - "docs/decisions/*.md"
  - "docs/conventions/*.md"
---

# Convenção — Contrato de Handoff entre agentes

**Status:** Adotado (ADR-004) · **Origem:** primeiro ciclo autônomo do `/owl:evolve` (2026-07-23)

## Por quê
Um handoff entre agentes deve ser uma **transição de estado estruturada**, não uma mensagem informal. Isto é como os subagentes do Claude Code já operam (entrada = mensagem de delegação + contexto; saída = **um único resumo estruturado**) e é o padrão convergente em CrewAI, AG2 e MetaGPT. Contratos explícitos reduzem ambiguidade, retrabalho e responsabilidade difusa, e mantêm o princípio de **contexto-mínimo** (N-1) da-owl.

## O contrato (campos obrigatórios)
Todo handoff de um agente para o próximo declara:

| Campo | O que é |
|---|---|
| **Objetivo** | 1 frase — o que precisa sair pronto deste passo. |
| **Entradas** | Só as dependências diretas a montante + ponteiros (paths), nunca o histórico inteiro. |
| **Saída** | O formato concreto entregue (doc, diff, relatório, decisão) + o path do artefato. |
| **Escopo** | O que está dentro / fora deste passo. |
| **Critério de pronto** | Condição verificável de conclusão. |
| **Premissas & Questões em aberto** | A incerteza que o agente produtor carrega, em nível-bullet: (a) **premissas** que assumiu; (b) **questões em aberto** / o que não conseguiu determinar; (c) **confiança da evidência** (verificada vs inferida), com paths. Contexto-mínimo — nunca transcrição. (ADR-020 — **rollout COMPLETO em 2026-08-07 via ADR-029**: adotado em **9/9** dos agentes que carregam contrato de handoff — architect, builder, chronicler, curator, database-specialist, mcp-builder, scout, strategist, system-designer. O campo é **obrigatório** para os nove; o conteúdo é específico de cada agente, não boilerplate. Excluídos por design: challenger/guardian/sentinel — carve-out NFR-SEC-1, não carregam handoff; `team` — N/A, hub orquestrador (ADR-011).) |

> ⚠️ **A cláusula de auto-destruição do ADR-020 disparou uma vez — e foi honrada.** O texto original dizia *"se nenhum agente o incorporar em ~3 ciclos, reconsiderar — pode ser cerimônia"*. A revisão de staleness do ciclo 8 (ADR-017) mediu **0/13 após 3 ciclos** e levantou o flag na condição escrita pela própria convenção. O dono decidiu **completar** em vez de dropar (ADR-029). O crédito de Impacto segue **provisório-pendente-de-fitness** (ADR-015): se três ciclos passarem com todo agente escrevendo uma linha de incerteza vazia, o campo É cerimônia e a outra metade da cláusula volta a valer.
| **Próximo agente** | Quem recebe — e o agente **encaminha** (não chama diretamente; hub-and-spoke). |

## Regras
- **Contexto-mínimo:** passe só o necessário para o próximo papel + paths; não repasse todo o histórico.
- **Hub-and-spoke:** o agente sinaliza o próximo passo e devolve o controle ao orquestrador; nunca invoca outro especialista diretamente.
- **Artefato, não cópia:** saída longa vai em arquivo; no handoff, referencie o path.

## Rollout
Esta convenção é a fonte da verdade. Ciclos seguintes do `/owl:evolve` incorporam uma seção "Contrato de Handoff" em cada agente, incrementalmente (um agente por mudança, cada um com seu ADR).
