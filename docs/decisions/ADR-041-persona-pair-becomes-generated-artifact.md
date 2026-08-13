# ADR-041 — O par de personas vira artefato verificável por script (sync-persona-pair)

**Status:** Accepted
**Date:** 2026-08-13
**Author:** dono (owner-directed, Passo 3 do plano ADR-040)
**Tags:** [adr-028, tooling, pair-sync]

## Contexto
O ADR-028 exige que toda edição de persona toque as duas cópias (`.claude/agents/` + `.claude/commands/agents/`) identicamente. A imposição era **disciplinar**: hash manual no gate (ciclo 10 verificou "byte-identical by hash"), e o quase-acidente do ADR-027 mostrou o custo de errar. Disciplina manual em 13 pares × toda edição é exatamente a classe de mecanismo que degrada em silêncio (ADR-039). Prova: o `--check` inaugural achou **drift pré-existente real** no par `curator` (`scout` vs `scout.md`, 1 linha) que nenhum hash manual tinha pego.

## Decisão
`scripts/sync-persona-pair.sh`: a cópia-comando passa a ser **derivada** da cópia-subagent (canônica). `--check` compara os 13 pares após normalização (strip do frontmatter — assimetria ADR-034 — e ajuste de profundidade dos links relativos `../../`→`../../../`) e sai 1 em drift; `--sync [agent]` regenera. O gate L4 do @guardian usa `--check` no lugar do hash manual.

## Alternativas consideradas
- **A (escolhida): derivação por script, canônico = subagent.** Prós: ADR-028 vira mecânico; drift detectável em CI/gate; frontmatter (campos impostos pela harness) vive só na metade que impõe. Contras: um transform de links por sed é heurístico — links relativos fora do padrão `](../../` escapariam (aceito: o `--check` pega qualquer divergência resultante).
- **B: manter a disciplina manual + hash no gate.** Prós: zero código novo. Contras: já falhou (drift do curator existia sob ela); custo por edição permanece.
- **C: eliminar uma das cópias.** Prós: resolve na raiz. Contras: as duas superfícies têm consumidores distintos e reais (auto-delegação vs pipeline determinístico + pack) — P7b/ADR-038; fora de alcance sem redesenho.

## Consequências
Editar persona = editar SÓ `.claude/agents/<x>.md` e rodar `--sync`; o par deixa de ser 2 edições. O gate ganha um check objetivo. Risco aceito: se alguém editar a cópia-comando direto, o próximo `--sync` sobrescreve — por isso o `--check` no gate vem ANTES de qualquer `--sync`, e o script imprime qual lado é canônico.

## Notas de implementação
`scripts/sync-persona-pair.sh` (executável). Verificação de aceitação executada: `--check` 13/13 em sincronia após `--sync curator` (drift de 1 linha corrigido a partir da canônica). Consumidores a atualizar em ciclo futuro: instruções de verificação no `evolve.md` L3/L4 podem citar o script (hoje citam "diff idêntico nas duas cópias" — compatível, não bloqueante).
