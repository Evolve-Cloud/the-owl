# ADR-006 — Architect carries a standardized Handoff Contract section

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect (via `/owl:evolve` cycle 2, continuation)
**Tags:** [self-improvement, communication, conventions, agent-prompt]

## Contexto
ADR-004 adopted the **Contrato de Handoff** convention (`docs/conventions/handoff-contract.md`) and explicitly deferred its rollout: *"Ciclos seguintes … incorporam uma seção 'Contrato de Handoff' em cada agente, incrementalmente (um agente por mudança, cada um com seu ADR)."* The L1.5 self-audit (ADR-005) against the real file `.claude/commands/agents/architect.md` confirms the gap: the architect only declares its handoffs as informal prose under "🤝 Como Trabalho com Outros Agentes" — there is no first-class, 6-field contract. A reader must infer the architect's exact inputs/outputs/done-criteria instead of seeing them at a glance.

## Decisão
Add one concise **"🤝 Contrato de Handoff"** section to `.claude/commands/agents/architect.md`, filling the six convention fields with the architect's real I/O: **Objetivo** (design + ADR that lets implementation proceed without re-deciding), **Entradas** (PRD/spec from @strategist + scale constraints from @system-designer, by path — not full history), **Saída** (ADR(s) in `docs/decisions/` + design docs, by path), **Escopo** (technical decisions/stack/contracts; out: implementation, requirements, tests), **Critério de pronto** (ADR with decision + alternatives + consequences; blueprint unambiguous for @builder), **Próximo agente** (@builder — hub-and-spoke: forward and return control to the orchestrator).

## Alternativas consideradas
- **Alternativa A (escolhida): add the concrete, agent-specific contract section.** Prós: closes the exact gap; the reader sees the architect's handshake immediately; grounded in what the agent already does; purely additive. Contras: mild duplication with the existing prose (accepted — the contract is the canonical at-a-glance form; the prose stays as narrative).
- **Alternativa B: leave the informal prose as-is and only rely on the convention doc.** Prós: zero edit. Contras: the convention says roll it into each agent; leaving it undone keeps the "deferred impact" that challenger flagged on ADR-004 — the standard never becomes real.
- **Alternativa C: rewrite the whole "Como Trabalho com Outros Agentes" section into the contract.** Contras: larger, riskier diff; loses useful per-peer narrative; not atomic. Rejected.

## Consequências
- **Easier:** anyone (human or agent) reading the architect knows its precise handshake; the `/owl:evolve` loop dogfoods its own convention on the agent that writes its ADRs.
- **Trade-offs:** a small amount of intentional redundancy (contract + prose). No behavior change — Skill-tool chaining and role boundaries are untouched.
- **Risks:** none to safety — editable agent, no carve-out contact (guardian/sentinel/challenger unchanged).

## Notas de implementação
@builder adds the "🤝 Contrato de Handoff" section to `.claude/commands/agents/architect.md` immediately after the existing "🤝 Como Trabalho com Outros Agentes" section. Keep it to the 6 labeled fields, agent-specific, ≤ ~15 lines, referencing `docs/conventions/handoff-contract.md`. Do **not** remove or rewrite existing sections; do **not** touch the carve-out agents. One atomic commit for this ADR + edit.
