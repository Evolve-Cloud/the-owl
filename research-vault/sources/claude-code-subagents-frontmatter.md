---
title: "Claude Code — Create custom subagents (frontmatter reference)"
type: source
tags: [claude-code, subagents, frontmatter, tools, enforcement]
sources: 1
updated: 2026-08-12
---
**Source:** [Create custom subagents](https://code.claude.com/docs/en/sub-agents) · **Type:** doc · **Credibility:** primary (vendor docs)
**Author / Org:** Anthropic · **Published:** continuously updated · **Ingested:** 2026-08-12 (cycle 9, targeted verification fetch — ADR-013)

## Summary

Doc de referência dos subagents do Claude Code. Buscada para responder **uma** pergunta que bloqueava dois candidatos reabertos: quais campos de frontmatter de subagent são reais e impostos pela harness. Respondeu essa e derrubou de vez o bloqueio de `agent-frontmatter-fields`.

## Key points

- **Lista completa de campos**, verbatim: *"…`description`, `prompt`, `tools`, `disallowedTools`, `model`, `permissionMode`, `mcpServers`, `hooks`, `maxTurns`, `skills`, `initialPrompt`, `memory`, `effort`, `background`, `isolation`, and `color`."* (+ `name`)
- `tools` é **allowlist durável**: *"Tools the subagent can use. **Inherits every tool available to subagents if omitted**."* ⇒ agente sem `tools:` herda tudo.
- `disallowedTools` é denylist; se ambos setados, *"`disallowedTools` is applied first, then `tools` is resolved against the remaining pool."*
- `maxTurns`: *"Maximum number of agentic turns before the subagent stops."* — **real**.
- `memory` (**minúsculo**, não `Memory`) e `isolation` (só aceita `worktree`) — **reais**, os dois.
- Modo de falha nomeado: *"If no entry in the list resolves to a tool, the subagent usually **fails to launch**"* — ruidoso, e só quando **nenhuma** entrada resolve.
- **`disable-model-invocation` e `user-invocable` NÃO estão nesta lista** — a elegibilidade de auto-delegação de um subagent é governada só por `description`. Foi este negativo que sustentou a assimetria do ADR-034 no sentido espelhado.

## Informs (ideas / patterns)

- [[least-privilege-tool-scopes-v2]] — a citação de `tools:` é a base do ADR-037.
- [[agent-frontmatter-fields-v2]] — derrubou o bloqueio dos 3 campos; o candidato foi deferido depois **por mérito**, não por bloqueio.
- [[routing-eligibility-mode]] — o **negativo** (sem `disable-model-invocation` aqui) é o que verifica a assimetria.
- [[tool-design-and-capability-scoping]]

## Notable quotes

> "Tools the subagent can use. Inherits every tool available to subagents if omitted."

> "`maxTurns` | No | Maximum number of agentic turns before the subagent stops"

## Gaps / open questions

- Não diz quais ferramentas o **modo Agent Teams** (peer) exige — a lacuna que fez o ADR-037 declarar aquele modo fora de escopo.
- Não quantifica custo/benefício de nenhum campo; é doc de capacidade, não de efeito.

## Related
- [[claude-code-skills-commands-frontmatter]] (a superfície-irmã — o contraste é o achado) · [[structural-properties]] · [[scout-notes-2026-08-12]]
