# ADR-007 — Builder carries a standardized Handoff Contract section

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect (via `/owl:evolve` cycle 2, continuation)
**Tags:** [self-improvement, communication, conventions, agent-prompt]

## Contexto
Part of the ADR-004 rollout (see ADR-006). The L1.5 self-audit (ADR-005) against `.claude/commands/agents/builder.md` confirms the builder declares its handoffs only as informal prose under "🤝 Como Trabalho com Outros Agentes" — no first-class 6-field contract. The builder is the loop's mutation step (it applies the edit), so making its handshake explicit — especially the input `arquivo_alvo` it receives from @curator's L1.5 audit and the atomic-diff done-criteria — has direct value for both the general DevFlow pipeline and the `/owl:evolve` loop.

## Decisão
Add one concise **"🤝 Contrato de Handoff"** section to `.claude/commands/agents/builder.md`, filling the six convention fields with the builder's real I/O: **Objetivo** (deliver the edit/code that realizes the design, atomically), **Entradas** (ADR + design from @architect + story from @strategist, by path; in the loop, the exact `arquivo_alvo` from @curator — not full history), **Saída** (applied diff on the named files + updated story/checkbox, by path), **Escopo** (implementation, refactor, fix, code review; out: ADR/stack = @architect, requirements = @strategist, test strategy = @guardian), **Critério de pronto** (edit matches the design; one atomic, revertible unit; self-review done), **Próximo agente** (the gate @guardian/@sentinel/@challenger — hub-and-spoke: forward and return control to the orchestrator).

## Alternativas consideradas
- **Alternativa A (escolhida): add the concrete, agent-specific contract section.** Prós: closes the gap; makes the builder's atomic-diff + `arquivo_alvo` handshake explicit; additive. Contras: mild redundancy with the existing prose (accepted).
- **Alternativa B: leave prose as-is.** Contras: rollout stays undone; the loop's own mutation agent never carries the standard it enforces on itself.
- **Alternativa C: fold the "MEU ESCOPO EXATO" block into the contract.** Contras: that block is a distinct, useful hard-boundary list; merging risks a larger diff and loss of clarity. Rejected — keep both, contract references scope.

## Consequências
- **Easier:** the builder's precise inputs (incl. `arquivo_alvo`), atomic-output rule, and next-hop (the gate) are visible at a glance; reinforces "one idea → one edit → one commit."
- **Trade-offs:** small intentional redundancy. No behavior change; existing hard-stops and Skill-tool chaining preserved.
- **Risks:** none to safety — editable agent, no carve-out contact.

## Notas de implementação
@builder adds the "🤝 Contrato de Handoff" section to `.claude/commands/agents/builder.md` immediately after the existing "🤝 Como Trabalho com Outros Agentes" section, ≤ ~15 lines, 6 labeled fields, referencing `docs/conventions/handoff-contract.md`. Preserve all existing sections and hard-stops. One atomic commit for this ADR + edit.
