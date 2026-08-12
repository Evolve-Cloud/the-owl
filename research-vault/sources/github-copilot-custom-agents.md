---
title: "GitHub Docs — Custom agents and sub-agent orchestration (Copilot SDK)"
type: source
tags: [github-copilot, orchestration, routing, custom-agents, prior-art]
sources: 1
updated: 2026-08-12
---
**Source:** [Custom agents and sub-agent orchestration](https://docs.github.com/en/copilot/how-tos/copilot-sdk/features/custom-agents) · **Type:** doc · **Credibility:** primary (vendor docs)
**Author / Org:** GitHub · **Published:** unknown (doc contínua) · **Ingested:** 2026-08-12 (cycle 9 — @scout verificou a claim do brief L0 na fonte)

## Summary

Doc de custom agents do Copilot SDK. Trazida pelo brief L0 como evidência de que plataformas modernas separam **o roster de especialistas** da **política de roteamento** que decide se um especialista pode ser auto-selecionado. O @scout buscou para confirmar em vez de aceitar a paráfrase — e a claim se sustentou verbatim.

## Key points

- **`infer`** na tabela de config, verbatim: *"Whether the runtime can auto-select this agent (default: `true`)"*.
- *"By default, all custom agents are available for automatic selection (`infer: true`)"*; `false` é *"useful for agents you only want invoked through explicit user requests"*.
- Na sequência de delegação, a seleção acontece *"If a match is found and `infer` is not `false`"* — é gate de roteamento, não sugestão.
- Exemplo da própria doc, e a escolha do exemplo é reveladora: o agente marcado `infer: false` chama-se **`dangerous-cleanup`** (*"Deletes unused files and dead code"*) — a doc ancora o campo em **ação com efeito colateral**, a mesma âncora que a doc do Claude Code usa (`/deploy`, `/commit`).
- `description` continua sendo o sinal primário de matching; a doc avisa que redação vaga produz delegação ruim.
- Outros controles de roteamento: `agent` (pré-seleciona na criação da sessão), `defaultAgent.excludedTools` (esconde ferramentas do agente principal, empurrando delegação).

## Informs (ideas / patterns)

- [[routing-eligibility-mode]] — é a evidência externa central. Convergência com o `disable-model-invocation` do Claude Code: **dois fornecedores independentes, mesmo controle, mesma âncora de side-effect.**
- [[handoff-and-orchestration]] · [[role-decomposition]]

## Notable quotes

> "Whether the runtime can auto-select this agent (default: `true`)"

> "infer: false, // Only invoked when user explicitly asks for this agent"

## Gaps / open questions

- É doc de **capacidade**: não mede se roteamento explícito melhora resultado, só que o controle existe. A ideia que ela sustentou foi aceita a 84 e **reprovada no gate** por razão interna à-owl, não por fraqueza desta fonte.
- Não diz como o runtime resolve empate entre vários agentes elegíveis.

## Related
- [[claude-code-skills-commands-frontmatter]] (o equivalente imposto na nossa harness) · [[research-brief-2026-08-12]] · [[scout-notes-2026-08-12]]
