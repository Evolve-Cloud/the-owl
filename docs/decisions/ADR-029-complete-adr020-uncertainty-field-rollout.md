# ADR-029 — Complete the ADR-020 rollout: the uncertainty field lands in all 9 handoff-carrying agents

**Status:** Accepted
**Date:** 2026-08-07
**Author:** @architect (owner-directed, answering the cycle-8 staleness flag)
**Tags:** [handoff, rollout, conventions, uncertainty]
**Related:** ADR-004 (the handoff contract), ADR-020 (**this completes its rollout**), ADR-011 (precedent: a rollout completion gets its own ADR), ADR-017 (the staleness review that raised the flag), ADR-028 (persona pair — governs how many files this touches)

## Contexto

ADR-020 (2026-07-29) added a sixth field to the handoff contract — **Premissas & Questões em aberto**: the uncertainty the producing agent carries, as (a) assumptions made, (b) open questions / what it could not determine, (c) evidence confidence (verified vs inferred), with paths.

It shipped with a deliberate self-destruct clause written into `docs/conventions/handoff-contract.md`:

> "ADR-020 — **em rollout incremental**: obrigatório à medida que cada agente incorpora o campo, um agente por ADR, como ADR-004→011. **Se nenhum agente o incorporar em ~3 ciclos, reconsiderar — pode ser cerimônia.**"

Cycle 8 (2026-08-07) ran the ADR-017 staleness review and found the clause had fired: **0 of 13 agents** carried the field after **3 cycles** (07-30, 08-03, 08-07). The flag was raised on the convention's own written condition, not on curator judgment, and the curator recommended without reverting (ADR-017: keep/revert is the owner's).

**The owner's decision is to complete the rollout, not to drop the field.** This ADR executes that decision. The clause was a real test and the honest outcome of a failed test was either completion or removal — leaving it half-adopted for a fourth cycle was the one option not available.

**Scope resolves cleanly and does not touch the carve-out.** Nine agents carry a `🤝 Contrato de Handoff` section: architect, builder, chronicler, curator, database-specialist, mcp-builder, scout, strategist, system-designer. The three gate agents (challenger, guardian, sentinel) **have no such section at all** — they are NFR-SEC-1 carve-out and are not touched here. `team` was excluded as N/A by ADR-011 (orchestrator hub, receives no handoff). So "complete the rollout" is exactly those nine.

## Decisão

Add the **Premissas & Questões em aberto** row to the handoff table of all nine handoff-carrying agents, positioned per the convention's field order (after *Critério de pronto*, before *Próximo agente*).

**The content is per-agent, not boilerplate.** Each row names the uncertainty *that agent actually carries* — @scout's is "which source facts were verified live vs copied from the brief", @curator's is "which rubric criteria rested on inference and whether the claim check reached the body or stopped at the abstract", @builder's is "what the code assumes about interfaces it did not itself verify". A uniform sentence pasted nine times would be precisely the ceremony the staleness clause was written to catch.

**Per ADR-028 this is one logical edit across 18 files** — each persona exists twice (`.claude/agents/<x>.md` + `.claude/commands/agents/<x>.md`). This is the first rollout to run under that rule; before it, this change would have landed in nine files and silently drifted in the other nine.

**The self-destruct clause is removed from the convention** and replaced with the completion record. Leaving "if no agent adopts it in ~3 cycles, reconsider" in place after full adoption would misinform the next staleness review.

## Alternativas consideradas

- **A (escolhida): complete the rollout across all nine, with per-agent content.** Prós: honours the field's original intent; the convention stops lying about its own state; uncertainty becomes a first-class part of every handoff. Contras: nine more table rows of instruction surface — the ADR-017 concern — mitigated by keeping each row to one line of genuinely agent-specific prose.
- **B: drop the field, per the clause's other branch.** Prós: smallest instruction surface; honest response to zero adoption. Contras: the field addresses a real gap (a handoff that looks complete while resting on unstated assumptions), and the evidence for it was verified at accept-time. Zero adoption looked like *nobody executed the rollout*, not like *agents tried it and it was useless*. Rejected by the owner.
- **C: roll out one agent per cycle, as ADR-020 originally specified.** Prós: matches the ADR-004→011 precedent exactly. Contras: at one per cycle this finishes in nine weeks, and the clause already fired once; a mechanism that takes nine weeks to adopt a table row is the ceremony, not the cure. ADR-011 set the counter-precedent by completing a stalled rollout in a single owner-directed change.
- **D: leave it and re-flag next cycle.** Contras: the flag has already fired; ignoring it makes the staleness review decorative. Rejected.

## Consequências

- **Mais fácil:** the receiving agent sees what the producer was unsure about instead of inferring it. This is the field's whole point and it has been unavailable for 3 cycles.
- **Trade-offs aceitos:** +1 row × 18 files of instruction surface. ADR-017's instruction-ceiling concern is real, and this spends against it deliberately.
- **Novos riscos:** the field can degrade into a ritual "no assumptions" line. **Mitigation is measurement, not prose:** this is a behavioural claim (ADR-015) ⇒ **Impact is provisional-pending-fitness**, and the honest check is whether downstream agents' output changes. If three cycles pass with every agent writing an empty uncertainty row, the field IS ceremony and branch B becomes correct after all.
- **Não toca o carve-out:** challenger/guardian/sentinel have no handoff section and are untouched; `.owl/loop-config.yml`, schedule and settings unchanged.

## Notas de implementação

- **Edits:** one row inserted into each agent's handoff table, in both copies (ADR-028): `.claude/agents/<x>.md` and `.claude/commands/agents/<x>.md`, for x ∈ {architect, builder, chronicler, curator, database-specialist, mcp-builder, scout, strategist, system-designer} = **18 files**.
- **Also:** `docs/conventions/handoff-contract.md` — replace the "em rollout incremental / reconsiderar em ~3 ciclos" clause with the completion record (adopted 9/9, ADR-029), so the next ADR-017 pass reads the true state.
- **Pack:** `owl-agents/` is regenerated from the canonical sources by the packer, never hand-curated — run it after these edits rather than editing the pack directly. The pack ships 11 personas without scout/curator, so it receives the subset that applies.
- **NÃO fazer:** do not add the section to challenger/guardian/sentinel (carve-out, and they carry no handoff), and do not add it to `team` (N/A by ADR-011). Do not paste identical text across agents.
- **Verification:** `grep -c` for the field must return 1 in each of the 18 files, and 0 in the four excluded agents' files.
