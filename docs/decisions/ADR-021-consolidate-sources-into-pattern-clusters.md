# ADR-021 — Consolidate research-vault sources into thematic pattern clusters

**Status:** Accepted
**Date:** 2026-08-03
**Author:** @curator (proposed), @architect (recorded)
**Tags:** [research-vault, patterns, memory, retrieval, mcp]

## Contexto
O `research-vault/` acumulou **106 páginas em `sources/`** (`research-vault/sources/*.md`) — **56 sobre a especificação MCP** e **50 sobre engenharia de times de agentes**. Um corpus plano desse tamanho tem dois problemas:

1. **As 56 páginas do spec MCP afogam as 50 de agent-team.** Um grep/leitura ingênua da memória dá peso desproporcional ao MCP, que é referência de protocolo, não o eixo primário de auto-melhoria da-owl.
2. **A memória durável não é retrievável em L0.** O redesenho retrieve-then-search-delta (ADR-022) precisa injetar no prompt do codex um **índice conciso do que já é conhecido** — descrições de uma linha, não 106 corpos de página. Sem um nível de síntese acima de `sources/`, não há o que injetar barato.

`sources/` guarda um resumo por fonte ingerida (imutável — [[SCHEMA]]); `patterns/` guarda as **páginas-conceito sintetizadas**. Hoje existem 11 páginas em `research-vault/patterns/` (9 agent-team + 2 MCP já iniciadas: `mcp-protocol-architecture`, `mcp-extensions-apps-tasks`). A consolidação precisa de uma **estrutura-alvo declarada** para o rollout convergir.

## Decisão
Consolidar as 106 fontes em **13 páginas-conceito temáticas** em `research-vault/patterns/`, o **nível-de-síntese retrievável** que o delta-prompt (ADR-022) grepa:

**9 páginas agent-team** (estende as existentes + adiciona as que faltam):
- `role-decomposition` (existe) · `context-engineering` (existe)
- `handoff-and-orchestration` · `self-improvement-and-memory` · `guardrails-and-safety` · `evaluation-and-fitness` · `tool-design-and-capability-scoping` · `sdk-and-harness-platform` · `single-agent-coding-loops`

**4 páginas de referência MCP** (para as 56 páginas de spec não afogarem as 51 de agent-team):
- `mcp-protocol-architecture` · `mcp-authorization-security` · `mcp-server-and-client-building` · `mcp-extensions-apps-tasks`

**Cada fonte mantém seu stub em `sources/`** (imutável, é o registro da ingestão); a página-conceito é sua **casa sintetizada**. As 13 páginas são a **memória durável retrievável** que o `## Definition` de cada uma alimenta o índice injetado skill-side (ADR-022 §PATTERN INDEX).

## Alternativas consideradas
- **Alternativa A (escolhida): 13 clusters temáticos, sources/ preservado como stub.** Prós: memória retrievável em L0 (descrições de uma linha), MCP separado sem afogar agent-team, ingestão imutável intacta, casa a estrutura que o grep de ADR-022 já espera. Contras: rollout incremental (nem todas as 13 landam de uma vez); risco de uma fonte mapear a >1 cluster (aceito — a página-conceito referencia, não move o stub).
- **Alternativa B: manter `sources/` plano, sem camada de síntese.** Prós: zero trabalho. Contras: ADR-022 não tem o que injetar barato (teria que grepar 106 corpos); MCP continua afogando agent-team. Rejeitada — bloqueia o L0-fix.
- **Alternativa C: apagar/arquivar as fontes MCP.** Prós: enxuga o corpus. Contras: perde ingestão imutável (viola [[SCHEMA]] "imutável once ingested") e o conhecimento MCP é referência legítima para @mcp-builder. Rejeitada.

## Consequências
- **Fica mais fácil:** injetar o índice de padrões no prompt do codex (ADR-022); @scout/@curator navegam por 13 conceitos em vez de 106 fontes; MCP e agent-team ficam em trilhas separadas.
- **Fica mais difícil / trade-off:** consolidação é trabalho incremental do @curator; enquanto as 13 não estão completas, o índice injetado é parcial (aceitável — descrições, não corpos). Uma fonte pode informar >1 cluster (referência cruzada, não duplicação).
- **Novo risco:** uma página-conceito pode divergir do stub da fonte se atualizada isoladamente. Mitigação: o stub é imutável (data de ingestão), a página-conceito cita `[[fonte]]` e carrega `updated:`.
- **Estado atual (2026-08-03):** 11/13 páginas existem (9 agent-team completas ou em síntese + 2 MCP). Faltam **`mcp-authorization-security`** e **`mcp-server-and-client-building`**. As páginas com `## Definition` ainda vazio (stubs) são preenchidas no rollout incremental do @curator.

## Notas de implementação
- **Dono:** @curator (possui `patterns/` — [[SCHEMA]] §Ownership). Rollout incremental, uma página por vez, como as convenções (ADR-011 shape). **Não** é uma edição atômica única do loop.
- **Não fabricar:** cada `## Evidence / sources` cita apenas `[[fonte]]` reais já em `sources/`; sem quotes salvo fonte lida em full ([[SCHEMA]] §Source page).
- **A primeira linha após `## Definition`** de cada página é o que o ADR-022 grepa para o índice injetado — mantê-la **uma frase densa e autossuficiente** (é o Level-0 progressive-disclosure que o codex vê).
- **Não tocar** o carve-out. Consolidar `sources/`→`patterns/` é trabalho de vault (memória), nunca edita agentes/`.owl`/settings.
- **Ordem sugerida:** completar as 2 páginas MCP faltantes → preencher os `## Definition` stubs agent-team → linkar cada `sources/` MCP à sua das 4 páginas MCP.
