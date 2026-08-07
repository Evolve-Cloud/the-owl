---
title: "Per-agent tool scopes, re-opened: the harness now enforces them"
type: idea
tags: [security, tooling, subagents, least-privilege]
supersedes_context: least-privilege-tool-scopes
awaiting_scoring: cycle-9
reopened: 2026-08-07
reopened_by: human-directed (ADR-033 finding)
updated: 2026-08-07
---

> [!important] **Este candidato NÃO está pontuado — e de propósito.**
> Reabrir não é aceitar. Isto é um candidato na fila para o @curator pontuar no ciclo 9, pela rubrica normal, com o veto de segurança normal, o haircut do ADR-015 normal e o gate normal. Não há tabela de rubrica, total nem nota de Impacto nesta página porque nenhuma foi atribuída.
>
> **Não existe linha no `ledger.md` para o id `least-privilege-tool-scopes-v2` — isso é intencional, não um esquecimento.** O ledger é o ledger de **decisões**; um candidato não pontuado não tem decisão. Se uma linha for adicionada aqui, o passo 1 do curator (`curator.md:80` — *"id decidido → pular"*) vai tratar o id como decidido e **pular**, e a reabertura vira no-op que parece feita. O @curator escreve a linha quando pontuar. O **ato** de reabrir tem a sua própria linha (`hd-reopen-least-privilege-tool-scopes`), com id distinto.

## Por que este id existe (regra do id sufixado)

`least-privilege-tool-scopes` (66) foi **deferido** em 2026-07-23 com um bloqueio explícito: *"unenforceable prose in the-owl's inline-exec model (ADR-010)"* — a-owl não tinha como **impor** escopo de ferramenta por agente, então a convenção seria prosa que finge impor. Bloqueio correto na época.

Esse bloqueio **caiu**. O SCHEMA manda que evidência materialmente nova para um id decidido vire **linha nova com sufixo, nunca sobrescrita silenciosa** — daí o `-v2`.

**A condição de reabertura foi escrita pelo próprio ciclo 7, em `ledger.md`, e é citada verbatim:**

> "The deferral blocker (inability to enforce per-agent tool scope) is therefore being removed […] **Re-open for a loop accept only if a concrete carve-out-safe atomic slice for a NON-carve-out agent still remains after the migration merges.**"

O merge aconteceu (PR #17, `dcb5e6b`; frontmatter em `2cb5aef`). A condição está **cumprida**. Ninguém reabriu — o ADR-033 identificou exatamente essa lacuna (nada no fluxo relê uma condição de reabertura registrada) e a reabertura foi autorizada pelo dono em 2026-08-07.

## O fato estrutural mudado (re-verificado contra a árvore hoje, não herdado da prosa)

`tools:` no frontmatter de `.claude/agents/*.md` é campo **imposto pela harness** (confirmado ao vivo pelo scout no ciclo 7 na doc de subagents do Claude Code, junto com `disallowedTools`/`permissionMode`/`maxTurns`).

| | agentes | n |
|---|---|---|
| **têm `tools:`** | challenger, curator, guardian, scout, sentinel | 5 de 13 |
| ├─ destes, **carve-out NFR-SEC-1** | challenger, guardian, sentinel | 3 |
| └─ destes, **não-carve-out** | curator, scout | 2 |
| **não-carve-out, SEM `tools:`** | architect, builder, chronicler, database-specialist, mcp-builder, strategist, system-designer, team | **8** |

⚖️ **Fronteira do carve-out, intocada.** challenger/guardian/sentinel já foram escopados **por mão humana** na migração. O loop **nunca** os edita — a fatia deles não faz parte deste candidato e não pode fazer. O que resta são os 8 acima.

## Questões em aberto que o @curator precisa resolver ANTES de pontuar

Estas não são detalhes; cada uma pode mover o score ou matar a fatia. São o motivo de o candidato viajar com elas.

1. **~~Assimetria do par de personas (ADR-028)~~ → RESOLVIDA pelo ADR-034, condicional a uma verificação.** O ADR-028 manda que `arquivo_alvo` nomeie o **par** (`.claude/agents/<x>.md` + `.claude/commands/agents/<x>.md`) e que tocar só uma cópia seja **fase FALHOU**, não sucesso parcial. Mas **0 de 13** personas-comando têm frontmatter YAML (verificado hoje: nenhuma começa com `---`), e `allowed-tools` não aparece em lugar nenhum de `.claude/commands/`. Ou seja: **a metade `commands/` estruturalmente não recebe `tools:`**. O **ADR-034** (2026-08-07) resolveu isso: campo imposto pela harness cuja superfície-irmã **não impõe equivalente** pode landar só na que impõe, desde que `arquivo_alvo` liste as duas e marque a excluída com a razão. ⚠️ **Mas a condição não está satisfeita ainda:** o ADR-034 exige que *"não impõe equivalente"* seja **verificado contra a doc primária (ADR-013)**, e o teste é **imposição**, não ausência — personas-comando **podem** ter frontmatter (`owl/research.md` tem), só não têm. **Isso torna a Q2 abaixo pré-requisito de caminho crítico, não curiosidade.** Se a verificação mostrar que `allowed-tools` num comando **é** imposto, não há assimetria: a edição vai nas duas metades na forma de cada uma, e a alternativa B do ADR-034 passa a valer.
2. **A sub-questão que o ciclo 7 registrou e deixou sem resposta, aqui verbatim:** *"whether `allowed-tools` on a **skill** is harness-enforced the way `tools`/`disallowedTools` are on a **subagent**"* — **não resolvida**, e explicitamente registrada *"for whoever re-opens that id"*. Se a resposta for "não é imposto", a classe *Unenforceable prose* volta a morder a metade `commands/`, e a fatia encolhe para só a metade `agents/`.
3. **`team` conta como alvo?** É o hub orquestrador e foi **excluído por design** do rollout do contrato de handoff (ADR-011, N/A). Se a mesma exclusão vale aqui, a superfície real é **7**, não 8. Não decidido.
4. **Qual é a fatia atômica?** "Adicionar `tools:` a 8 agentes" não é uma edição lógica — a-owl mantém 1 ideia → 1 ADR → 1 edição. Um agente por ciclo (a forma dos rollouts ADR-006/007/008) ou um conjunto justificado? Escolha do curator/architect, não deste registro.
5. **O que este candidato NÃO é.** Não é uma convenção nova de prosa dizendo "agentes devem ter escopo mínimo" — essa é a forma que foi deferida em 2026-07-23 e que a classe *Unenforceable prose* ainda rejeita. O delta é **o campo imposto**, não o texto.

## Ligação com o bloco de classes do ADR-030

O ADR-030 citava este id como exemplo vivo de *Unenforceable prose*. O exemplo foi **removido** em 2026-08-07 (`hd-unstale-rejected-class-example`) porque tinha expirado antes do bloco entrar em operação. A classe segue válida como **propriedade estrutural** — o que caducou foi a instância. Este candidato é o outro lado da mesma correção: o exemplo saiu do filtro, o id volta para a fila.

## Related
- [[ledger]] (condição de reabertura, ciclo 7 · sub-questão não resolvida, passagem 2026-08-07)
- ADR-033 (achado que destravou isto) · ADR-030 + `## Correção` (exemplo expirado) · ADR-028 (regra do par) + **ADR-034** (cláusula de assimetria — resolve a Q1, condicional à Q2) · ADR-011 (`team` N/A) · ADR-010 (modelo inline-exec, o bloqueio original)
- Fonte do fato estrutural: `.claude/agents/*.md` frontmatter, merge `dcb5e6b` / `2cb5aef` (PR #17)
