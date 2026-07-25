# ADR-011 — Complete the handoff-contract + role-ownership rollout across the pipeline agents

**Status:** Accepted
**Date:** 2026-07-24
**Author:** @architect (human-directed rollout completion; gate-reviewed)
**Tags:** [self-improvement, roles, conventions, agents, rollout]
**Related:** ADR-004 (handoff-contract convention), ADR-006/007/008 (per-agent handoff rollout for architect/builder/chronicler), ADR-009 (role-ownership convention), ADR-005 (gap analysis L1.5), ADR-012 (efficiency measurement — the scorecard that surfaced this debt)

## Contexto
Two conventions were already **accepted** but only partially **rolled out** — the exact "convention debt" the prior cycle's challenger flagged as non-blocking, and that the new efficiency scorecard (ADR-012, `scripts/owl-metrics.py`) quantified:
- **handoff-contract** (ADR-004): present in only `architect`, `builder`, `chronicler` (ADR-006/007/008); missing from the other pipeline specialists.
- **role-ownership** (ADR-009): present in **zero** agents (convention doc only).

The binding constraint on the loop turned out to be **integration/rollout, not research** — the loop accepts conventions faster than it spreads them (see ADR-012). Finishing the rollout is the highest-value work available.

L1.5 grounding (ADR-005) against the real files corrected two stale assumptions in ADR-009:
- ADR-009 claimed `scout`/`curator` lack `.meta.yaml`. **They do have it** in the canonical registry `.devflow/agents/` (the location `docs/wiki/architecture/overview.md` and `chronicler.meta.yaml` name as the structured-metadata source). Only `team` lacks a `.devflow` meta — and `team` is out of scope (below).
- The `.claude/commands/agents/*.meta.yaml` **secondary mirrors** are drifted (curator/scout absent there; system-designer's mirror stale). Pre-existing; left untouched (see Consequências → follow-up).

## Decisão
Complete **both** rollouts in a single **human-directed, gate-reviewed** pass:
- Add the 6-field **"🤝 Contrato de Handoff"** section to the 4 specialists that lacked it: `curator`, `scout` (standardizing their partial "Contrato de saída"), `strategist`, `system-designer`.
- Add the 5-field **"🧭 Papel & Não-Papel"** section to all 7 pipeline specialists: `architect`, `builder`, `chronicler`, `curator`, `scout`, `strategist`, `system-designer`.
- Fill the one meta gap found: add `constraints.should_not_do` + `should_delegate_to` to `.devflow/agents/system-designer.meta.yaml`, consistent with its `.md`.
- **Exclude `team`** from both conventions as **N/A by design**: it is the DevFlow parallel **orchestrator (hub)**, not a pipeline specialist. handoff-contract's "Próximo agente" and role-ownership's "one boundary, one owner" do not bind a hub whose next agent is *every* agent; its boundary is already its `⛔ NUNCA FAÇA` + "QUANDO USAR". Encoded as `NA_FOR_CONVENTIONS` in the scorecard (printed on its own "N/A by design" line, not silently dropped), so 100% is honest and reachable.

This pass **supersedes the "one agent per ADR" incremental cadence** (ADR-004/009 rollout notes) *for a human-directed completion*: the conventions are already accepted (no novel decision per agent), the edits are mechanical/additive, and the change is gate-reviewed. The autonomous loop's incremental cadence + circuit-breaker cap still apply to *autonomous* cycles.

## Alternativas consideradas
- **Alternativa A (escolhida): finish both rollouts in one human-directed, gated pass.** Prós: closes the debt the scorecard flags; unblocks measuring durability (a convention replaced next cycle can't be measured); one coherent review. Contras: 11 sections at once is more blast radius than the cap-3 autonomous norm — mitigated by additive-only edits + the full guardian/sentinel/challenger gate + atomic commits.
- **Alternativa B: one agent per ADR over ~5 weekly cycles (the letter of ADR-004/009).** Prós: minimal per-cycle blast radius. Contras: ~5 weeks to close a debt that is mechanical application of *already-accepted* conventions; conflicts with the user's explicit "do it without me / finish it" directive; the cap exists for *novel* decisions, not rollout.
- **Alternativa C: roll out handoff-contract only, defer role-ownership.** Prós: smaller. Contras: leaves the scorecard's headline signal partial; role-ownership is the higher-value one (kills overlap). Rejected.

## Consequências
- **Mais fácil:** both conventions at **7/7 (100%)** across the target set; every specialist's file now carries a single-owner boundary table + a typed handoff contract instead of ownership scattered across four heading styles; the scorecard's headline ("is accepted work finished across the fleet?") flips from partial to complete.
- **Trade-offs aceitos:** a larger single change than the autonomous cap (contained by additive-only + gate + atomic commits); `strategist`'s "Não possui" is necessarily a broad "everything downstream" list (it owns the problem; all solution-space is delegated) — correct but the least agent-specific section (challenger noted, non-blocking).
- **Follow-up (tracked, non-blocking):** the duplicate meta directories are drifted — `.claude/commands/agents/*.meta.yaml` lacks curator/scout entirely and its system-designer copy is stale vs the canonical `.devflow/agents/`. This rollout referenced and updated the **canonical** `.devflow/` copies only. Reconciling or de-duplicating the two meta locations is a separate cleanup.
- **Novos riscos:** none to the security surface — additive documentation, **0 carve-out contact** (verified), no injection, no secrets.

## Notas de implementação
Executed:
- Sections added additively (176 insertions, **0 deletions**), inserted between existing blocks; existing prose + Skill-tool chaining preserved.
- "Fonte da verdade" of each role section points at `.devflow/agents/<id>.meta.yaml` (canonical) — verified by @guardian to match each `.md`.
- **Gate (blocking, 3 independent reviewers): PASS × 3.** @guardian (additive-only, all fields, agent-specific, meta consistent), @sentinel (0 carve-out contact, no injection/secrets, boundaries reinforced), @challenger (real improvement, `team` exclusion legitimate/honest, ownership integrity holds).
- **Landing: committed to `main`** — deliberate deviation from the shadow-PR default because this is a **human-directed, attended, gate-reviewed** change (not an unattended autonomous run). `landing: pr` in `.owl/loop-config.yml` still governs the autonomous loop; `gh` is not installed, so a shadow PR would require a human to open/merge, which the directive ("do it without me") rules out. Atomic commits keep it revertible.
- Did NOT touch: `sentinel.md`, `guardian.md`, `challenger.md`, their `.meta.yaml`, `.owl/loop-config.yml` rubric/circuit-breaker, `~/.ssh`, or any secret.
