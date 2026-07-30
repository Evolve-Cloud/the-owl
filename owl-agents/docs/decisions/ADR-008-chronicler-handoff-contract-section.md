# ADR-008 — Chronicler carries a standardized Handoff Contract section

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect (via `/owl:evolve` cycle 2, continuation)
**Tags:** [self-improvement, communication, conventions, agent-prompt]

## Contexto
Final agent in this cycle's ADR-004 rollout (see ADR-006, ADR-007). The L1.5 self-audit (ADR-005) against `.claude/commands/agents/chronicler.md` confirms the chronicler declares its handoffs only as informal prose under "🤝 Como Trabalho com Outros Agentes" — no first-class 6-field contract. The chronicler is the loop's land/memory step (L5): it consumes upstream artifacts (ADRs, diffs, stories) and writes durable memory (CHANGELOG, snapshot, wiki/graph). Its handshake is worth making explicit — and it carries a security-relevant done-criterion (never persist secrets) that belongs in the contract.

## Decisão
Add one concise **"🤝 Contrato de Handoff"** section to `.claude/commands/agents/chronicler.md`, filling the six convention fields with the chronicler's real I/O: **Objetivo** (record the change in project memory without drift), **Entradas** (the upstream artifacts — ADRs, diffs, stories — by path + version/date; not full history), **Saída** (updated CHANGELOG / snapshot / wiki / knowledge-graph, by path; **never a secret value** — reference by name), **Escopo** (documentation, memory, status/badges, wiki/graph; out: code = @builder, design = @architect, requirements = @strategist), **Critério de pronto** (CHANGELOG reflects what changed; ADRs linked; snapshot at milestones; every claim grounded in real files — nothing invented), **Próximo agente** (usually end-of-flow — return control to the orchestrator/human).

## Alternativas consideradas
- **Alternativa A (escolhida): add the concrete, agent-specific contract section.** Prós: closes the gap; surfaces the "no secrets / grounded" done-criteria as a contract term; additive. Contras: mild redundancy with existing prose (accepted).
- **Alternativa B: leave prose as-is.** Contras: rollout incomplete; the memory agent lacks the standard the loop just adopted.
- **Alternativa C: also roll into scout/curator/strategist/system-designer this cycle.** Contras: exceeds the circuit-breaker cap (3) and mixes partial-gap with clear-gap agents. Rejected — those are queued for the next cycles.

## Consequências
- **Easier:** the chronicler's inputs, durable outputs, and its security/grounding done-criteria are explicit; completes the loop's integrate→land pipeline (architect→builder→chronicler) under one convention.
- **Trade-offs:** small intentional redundancy. No behavior change; the extensive existing chronicler sections (Repo Wiki, Knowledge Graph, checklists) are untouched.
- **Risks:** none to safety — editable agent, no carve-out contact. After this cycle, scout/curator (partial) + strategist/system-designer remain as the next rollout increment.

## Notas de implementação
@builder adds the "🤝 Contrato de Handoff" section to `.claude/commands/agents/chronicler.md` immediately after the existing "🤝 Como Trabalho com Outros Agentes" section, ≤ ~15 lines, 6 labeled fields, referencing `docs/conventions/handoff-contract.md`. Preserve all existing sections. One atomic commit for this ADR + edit.
