# ADR-018 — Custo de agente = piso de contexto × nº de turnos; o lever de economia de turnos

**Status:** Accepted
**Date:** 2026-07-28
**Author:** @chronicler (documentando uma sessão de medição human-directed)
**Tags:** [token-economy, agents, measurement, context-engineering, attention-budget]
**Related:** ADR-017 (staleness — convenção custa attention budget), ADR-009 (role ownership — superfície de prompt do agente), ADR-023 (parallel subagents, referenciado pelos agentes)

## Contexto
Observação do owner: os agentes "antigos" (arquivos grandes, self-contained) pareciam gastar **menos** token que os atuais (afinados por progressive disclosure). Em vez de teorizar, medimos com runs A/B reais de subagente na mesma tarefa, com a **verdade-terreno = o transcript jsonl**. O auto-report do agente ("quais arquivos li") mostrou-se **inconfiável** — dizia não ter lido o reference quando o transcript provava que leu; toda conclusão daqui em diante usa o transcript, não o auto-report.

**Achado (medido):** `custo do agente = piso de contexto × nº de turnos`. O piso (~84–92k tokens) é fixo do harness (system prompt + schemas de tools + listagem de skills + instruções MCP) e é re-lido a cada round-trip (cache_read). Descartados por medição, cada um <8% do custo:
- tamanho do arquivo do agente (~1% — carga única, cacheada);
- a skill `claude-architecture` (~1,3% marginal; não lê o reference de 7k por reflexo se o ponteiro for firme);
- superfície MCP/tools (~8%, e quase tudo é core fixo — podar um MCP raspa poucos k);
- **`CLAUDE.md` não é carregado em subagentes** (grep no transcript = 0 marcadores) — só no loop principal.

O único lever config-controlável é o **nº de turnos** (cada turno re-lê o piso).

## Decisão
Adicionar um bloco **`⚡ ECONOMIA DE TURNOS`** no topo das REGRAS CRÍTICAS dos 4 agentes afinados (`architect`, `builder`, `chronicler`, `system-designer`) — *aja, não narre; leia o contexto num batch inicial; agrupe entregas; só leia o reference se travar; fale uma vez no fim* — e **apertar o ponteiro do reference** de cada um ("NÃO leia por reflexo — só abra se travar num exemplo concreto").

## Resultado (medido, antes→depois, mesma tarefa)
| agente | turnos | cache_read | custo billado |
|---|---|---|---|
| builder | 22→6 | −80% | **−57%** |
| architect | 10→3 | −84% | **−49%** |
| system-designer | 9→3 | −85% | **−37%** |
| chronicler | 3→3 | ±0% | neutro (já mínimo — sem dano) |

O lean+lever ganha até do agente grande self-contained. Qualidade preservada em todos.

## Alternativas consideradas
- **A (escolhida): regra de turnos + ponteiro firme.** Único lever que move o ponteiro; ganho onde há desperdício de turno, inofensivo onde não há.
- **B: reverter aos agentes grandes self-contained.** Rejeitada — re-dilui as regras load-bearing (o instruction-ceiling do claude-architecture §2 / ADR-017) e o tamanho do arquivo é ~1% do custo.
- **C: podar MCP/tools.** Medido ~8%, quase tudo core fixo. Higiene opcional, não o lever.

## Consequências
- **Mais barato:** ~−50%/run nos agentes com desperdício de turno; a frota paga o piso menos vezes.
- **Regra durável:** todo agente novo/afinado leva o bloco de economia de turnos; **medir sempre pelo transcript, nunca pelo auto-report** (que mentiu de forma reprodutível).
- **Conecta com ADR-017:** o "attention budget" que as convenções custam — antes citado — agora está **medido** em token; o lever é o backward-pass concreto sobre esse custo.
- **Provenance (fora do repo):** o `~/.claude/CLAUDE.md` (44,5k, carregado a cada turno do loop principal) foi separado em regras + `~/.claude/HISTORY.md` → corte de ~43k/turno no interativo.
