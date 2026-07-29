# ADR-020 — Campo de premissas & questões em aberto no contrato de handoff

**Status:** Accepted ✅ · **Decision Date:** 2026-07-29 · **Decided by:** Architect Agent (via `/owl:evolve` cycle 5)
**Date:** 2026-07-29
**Author:** @architect
**Tags:** [convention, communication, handoff, self-improvement]

## Contexto
O contrato de handoff (`docs/conventions/handoff-contract.md`, ADR-004; rollout ADR-006/007/008/011) define **6 campos obrigatórios**: Objetivo, Entradas, Saída, Escopo, Critério de pronto, Próximo agente (`docs/conventions/handoff-contract.md:11-18`). Nenhum deles permite ao agente produtor declarar **a incerteza que ele carrega** — as premissas que assumiu, o que não conseguiu determinar, e a confiança/proveniência da evidência.

O ciclo 5 do `/owl:evolve` (brief codex 2026-07-29) trouxe **dois candidatos independentes de alta confiança** convergindo nesse gap:
- `artifact-first-pipeline` — "Add a Handoff Contract section ... requiring input schema, output schema, **assumptions, unresolved questions, evidence links**, and an explicit return-to-orchestrator marker."
- `context-budgeted-handoffs` — "Add a Context Manifest ... with Included Artifacts, Excluded History, Non-Negotiable Constraints, **Evidence Confidence, and Open Questions** fields."

Grounding L1.5 (ADR-005) contra o código real confirmou o gap: a tabela do contrato não tem campo de incerteza. Claim verificada ao vivo (ADR-013) contra a fonte primária citada — OpenAI Agents SDK Handoffs documenta payloads estruturados de handoff (`input_type` com campos como `reason: str`, `EscalationData`), i.e. o agente que faz o handoff fornece **campos estruturados**, não uma transferência crua. Isso sustenta um campo de incerteza explícito.

Sem esse campo, um agente produtor herda premissas silenciosas para jusante — exatamente o "telephone game" que a Anthropic aponta em sistemas multi-agente ([[multi-agent-research-system]]).

## Decisão
Estender o contrato de handoff (`docs/conventions/handoff-contract.md`) com **um campo obrigatório adicional**: **"Premissas & Questões em aberto"** — o agente produtor declara, em nível-bullet (contexto-mínimo, nunca transcrição):
1. **Premissas** que assumiu para produzir a saída;
2. **Questões em aberto** / o que **não** conseguiu determinar;
3. **Confiança da evidência** (verificada vs inferida), com paths.

Este ciclo edita **apenas a convenção** (a fonte da verdade). O rollout campo-a-campo nos agentes individuais é **incremental em ciclos futuros** (um agente por ADR), conforme a regra de rollout que a própria convenção já estabelece (`docs/conventions/handoff-contract.md:25-26`) — o mesmo padrão de ADR-004→ADR-011.

## Alternativas consideradas
- **Alternativa A (escolhida):** Adicionar 1 campo à tabela da convenção agora; rollout incremental depois. — **Prós:** atômico (1 linha, 1 arquivo), reversível, respeita o padrão ADR-004→011, evidência convergente. **Contras:** o valor comportamental (agentes de fato produzirem melhores premissas) só se confirma com o rollout + fitness; por isso o Impacto é hipótese (ADR-015) e a aceitação é **provisória**.
- **Alternativa B:** Rollout imediato em todos os 8 agentes num único ciclo. — **Prós:** efeito completo já. **Contras:** não-atômico, contraria a regra de rollout incremental da convenção, e amplia o blast-radius de uma convenção ainda não medida por fitness. Rejeitada.
- **Alternativa C:** Um "Context Manifest" separado (proposta literal de `context-budgeted-handoffs`). — **Prós:** mais rico. **Contras:** duplica a estrutura do contrato existente, viola contexto-mínimo (mais cerimônia), maior. Deferida (é o `context-budgeting`, deferred 74).

## Consequências
**Benefícios:** o contrato passa a **representar incerteza** — premissas silenciosas viram explícitas, revisores a jusante recebem os caveats de que precisam, e a proveniência da evidência acompanha o handoff. Melhora esperada em completude de handoff e redução de retrabalho por premissa-errada-herdada.

**Trade-offs aceitos:** (1) mais um campo = risco de virar cerimônia/burocracia se preenchido com ruído — mitigado exigindo nível-bullet e contexto-mínimo; (2) o benefício comportamental é **hipótese até o fitness confirmar** (ADR-015) — a aceitação é provisória-pendente-de-fitness na dimensão-alvo (completude de handoff / retrabalho a jusante); Δ nulo/negativo ⇒ reverter ou reetiquetar como documentação-apenas; (3) o efeito real só aparece após o rollout incremental nos agentes.

**Novos riscos:** nenhum de segurança (não toca o carve-out; não abre superfície). Risco de baixo uso se os agentes tratarem o campo como opcional — mitigado por ser **obrigatório** na convenção fonte-da-verdade.

## Notas de implementação
- **Arquivo a tocar (único):** `docs/conventions/handoff-contract.md` — adicionar 1 linha na tabela "O contrato (campos obrigatórios)" e, se necessário, 1 bullet nas "Regras" reforçando contexto-mínimo do novo campo. **NÃO** editar nenhum agente `.md` neste ciclo (rollout é futuro).
- **NÃO tocar** o carve-out (sentinel/guardian/challenger, `.owl/loop-config.yml`, o schedule, `.claude/settings.json`, `~/.ssh`, segredos).
- **Verificação:** `git diff --stat` deve mostrar exatamente 1 arquivo alterado; a nova linha deve manter o formato da tabela existente (`| Campo | O que é |`).
- **Reversibilidade:** remover a linha reverte 100%.
- Gravar o `adr` de volta em `research-vault/ideas/handoff-contract-uncertainty-fields.md` e no `ledger.md` (já feito no L2).
