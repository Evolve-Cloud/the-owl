# ADR-023 — Introduce research-vault/capabilities/ registry

**Status:** Accepted
**Date:** 2026-08-03
**Author:** @architect
**Tags:** [research-vault, capabilities, tooling, staleness, memory]

## Contexto
O `research-vault/` tem `patterns/` (conceitos de engenharia de times de agentes — SOTA externa) e `sources/` (ingestão imutável). Falta um lugar para **how-tos operacionais do próprio tooling da-owl**: como se invoca o graphify, como é o frontmatter de um subagent nativo, quais flags do codex CLI, como funciona o próprio retrieve-then-search-delta. Isso não é um *pattern* (não é SOTA de campo a decidir) nem uma *source* (não é uma fonte externa ingerida) nem uma *idea* (não é candidato a decidir) — é **conhecimento operacional verificado** sobre ferramentas que a-owl usa.

Hoje esse conhecimento vive espalhado em prosa de agentes, comentários `# VERIFIED` (ex.: `owl/research.md` passo 4 sobre codex-cli 0.144.4) e memória do maintainer. Fatos de tooling **decaem** (uma flag de CLI muda, um campo de frontmatter é renomeado) — exatamente o problema que o ADR-017 resolveu para *convenções* com o `verified_on`/staleness. Tooling merece o mesmo tratamento.

## Decisão
Criar `research-vault/capabilities/` — um registro de **how-tos operacionais do tooling da-owl**, distinto de `patterns/`:

- **`capabilities/index.md`** — índice das capabilities registradas.
- **Uma página por capability**, com schema próprio: `title`, `type: capability`, `tool`/`surface`, `verified_on: YYYY-MM-DD`, `status: current | stale`, corpo com o how-to conciso + a fonte da verificação.
- **Staleness:** quando `verified_on` fica velho (o mesmo gatilho de ADR-017, aplicado a fatos de tooling em vez de convenções), o `status` vira `stale` e a página é candidata a re-verificação. Um fato de tooling stale **nunca** é tratado como current silenciosamente.

**Seeds iniciais:** `graphify-usage` (backend claude-cli, engine-only, $0), `native-subagent-frontmatter` (`tools`/`disallowedTools`/`permissionMode`/`maxTurns` harness-enforced), `codex-cli-flags` (`-s read-only --ephemeral`, `-o/--output-last-message`), `retrieve-then-search-delta` (o fluxo do ADR-022).

**Dono:** @curator (já possui `sources/`/`patterns/`/`ideas/` — [[SCHEMA]] §Ownership; capabilities/ é a mesma classe de memória curada).

## Alternativas consideradas
- **Alternativa A (escolhida): diretório `capabilities/` separado com staleness.** Prós: separa how-to-de-tooling (operacional, muda com versões) de pattern-de-campo (SOTA, muda com pesquisa); dá aos fatos de tooling o mesmo antídoto anti-decaimento do ADR-017; o retrieve-delta (ADR-022) pode um dia grepar capabilities/ como faz com patterns/. Contras: mais um tipo de página no vault (curva de manutenção).
- **Alternativa B: enfiar how-tos de tooling em `patterns/`.** Prós: zero diretório novo. Contras: mistura SOTA-de-campo (a decidir) com how-to-operacional (a manter atualizado) — semânticas e cadências de decaimento diferentes; poluiria o PATTERN INDEX injetado no codex (ADR-022) com ruído de tooling. Rejeitada.
- **Alternativa C: deixar em comentários `# VERIFIED` espalhados nos agentes.** Prós: já é o status quo. Contras: não-retrievável, sem staleness sistemática, duplicado, some quando o agente é reescrito. Rejeitada.

## Consequências
- **Fica mais fácil:** achar "como se usa X ferramenta na-owl" num só lugar verificado; detectar quando um how-to de tooling ficou velho (staleness); o retrieve-delta pode injetar capabilities como memória conhecida.
- **Fica mais difícil / trade-off:** o @curator ganha mais uma superfície para manter `verified_on` em dia; se ninguém re-verifica, as páginas viram `stale` (por design — melhor stale-marcado que current-mentiroso).
- **Novo risco:** capabilities/ divergir da realidade do tooling entre verificações. Mitigação: `status: stale` explícito + a re-verificação é um fetch/comando alvo (barato), não pesquisa aberta.
- **Espelha ADR-017** (staleness de convenção) para fatos de tooling — mesma filosofia, superfície diferente.

## Notas de implementação
- **@curator cria** `research-vault/capabilities/index.md` + o schema de página + as 4 seeds. Uma seed por vez (incremental), cada uma com `verified_on` real (a data em que o fato foi confirmado, não fabricada).
- **`native-subagent-frontmatter`** deve registrar que `tools`/`disallowedTools` são harness-enforced (confirmado pelo scout, cycle 7) — e que a fatia sentinel/guardian/challenger é **carve-out** (a capability descreve o fato; não autoriza o loop a editá-los).
- **`graphify-usage`** deve registrar backend `claude-cli` obrigatório (Pro Max, $0), engine-only, sem dump de stub obsidian.
- **Não tocar** o carve-out. capabilities/ é memória de vault; registrar um fato *sobre* uma ferramenta carve-out ≠ editar o carve-out.
- **Verificação:** `capabilities/index.md` existe e lista as seeds; cada seed tem `verified_on` + `status: current`.
