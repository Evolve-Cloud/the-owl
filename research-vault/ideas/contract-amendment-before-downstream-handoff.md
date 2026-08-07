---
title: "Explicit contract amendment for interface drift"
type: idea
tags: [communication, handoff, contracts]
sources: 1
status: rejected
score: 58
adr: ""
updated: 2026-08-07
---
**Category:** communication · **Confidence:** med · **Applicability:** 4/5 (brief's number; my grounding disagrees — see Fit)

## Pattern
When implementation evidence requires changing an interface or constraint established by an earlier artifact, the producing agent emits a **contract amendment** rather than silently diverging: superseded statement, replacement, compatibility impact, reason, affected downstream owner. The orchestrator accepts it before routing further work, so a changed assumption is reviewable as a state transition instead of being inferred later from code.

## Proposed change to the-owl
(Brief's) Extend the handoff contract with a *Contract Amendments* list — `supersedes`, `replacement`, `compatibility-impact`, `evidence`, `affected-next-role`, `ADR-status`; an unaccepted amendment is an open question, not downstream authority.

## L1.5 self-audit (ADR-005)
- `já_implementado?` **Yes — substantially, through three mechanisms, and it ran twice today.**
  1. **ADR supersession is first-class:** `docs/decisions/000-template.md:5` — `**Status:** Proposed | Accepted | Deprecated | **Superseded by ADR-XXX**`. The ADR *is* the-owl's contract of record and already has a formal amendment state.
  2. **Ledger suffixed-id rule** (`ledger.md:10`): *"Materially new evidence for a decided idea gets a **new suffixed id**, never a silent overwrite."* That is an amendment path with provenance and dedup built in.
  3. **ADR-020** added *Premissas & Questões em aberto* to the handoff contract — assumptions, open questions, evidence confidence.
  **Demonstration, same day:** ADR-028 amended ADR-005's contract and did precisely what this candidate proposes — named the superseded statement (`arquivo_alvo` is one file), the replacement (it names the pair), the compatibility impact (non-persona targets unaffected), the reason (the hybrid model merged), and the affected downstream owner (@builder) — then went through the decision path *before* further routing. ADR-027 did the same to the intake contract. The mechanism is not missing; it is in daily use, one level up.
- `onde_está_o_gap` Genuinely thin: the amendment path lives at the **ADR** level and is not named as a **field of the handoff contract**. A downstream agent discovering that an upstream artifact is wrong has a slot for *its own* uncertainty (ADR-020) but not for *"this earlier statement is now void"*.
- `arquivo_alvo` `docs/conventions/handoff-contract.md` — a convention, not a persona, so a single path (ADR-028's rule explicitly exempts non-persona targets).

## Curator verdict — score 58 (threshold 75, reject_below 60)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 15 | Markdown-expressible, yes. But the paper's mechanism is **runtime-enforced** — `V(C)` is a deterministic verifier over live workspace state, parsing logs and mutating task status. What survives translation is the *record without the enforcement*: the same "unenforceable prose" shape that pinned `least-privilege-tool-scopes` at 66. And the failure it targets is **structurally weaker here**: the-owl is sequential, one-agent-per-phase, hub-and-spoke, with the orchestrator between every step — not the parallel context-isolated fan-out the paper and the first-party guidance both describe. |
| Evidence strength (20) | 12 | ONE source, peer-reviewed (ACL Findings 2026), **verified to the body** with a real quote — strong verification. But single-source; the paper's own ablations isolate HEG and the symbolic layer, **not** this mechanism; the benchmark is the authors' own. And the evidence **does not converge**: first-party guidance on the same problem recommends a *different* remedy (contract as versioned file + independent verifier), not an amendment record. |
| Impact (20) | 7 | Behavioural claim, hypothesis-level (ADR-015). the-owl performed this exact operation twice today at the ADR level; the increment is a field name in one convention. |
| Simplicity & reversibility (15) | 12 | One additive field group, one file, atomic and revertible. Genuinely simple — the candidate's best criterion. |
| Safety (10) | 9 | **≥ safety_floor 7.** No new surface; carve-out untouched. |
| Non-duplication (10) | 3 | ADR supersession + ledger suffixed-id + the ADR-020 field already cover most of it, demonstrated in production today. |

**Total 58 < `reject_below` 60 ⇒ rejected.**

> [!important]
> **The decisive argument is adoption, not theory.** ADR-020 added the *last* field to this very convention on 2026-07-29. Grounding today: **0 of 13 agents** have incorporated it, across **3 cycles** (07-30, 08-03, 08-07). Adding a *second, larger* field group to a convention whose previous addition has zero adoption is textbook over-production — it grows the instruction surface (ADR-017's own concern) while the existing surface goes unused. The correct response to this candidate is not to add the field; it is to ask why the last one was never picked up. That is now a staleness flag against ADR-020 (see `log.md`), raised on the convention's **own written clause**: *"Se nenhum agente o incorporar em ~3 ciclos, reconsiderar — pode ser cerimônia."*

> [!note]
> **Rejected ≠ wrong.** The pattern is sound and the source is solid. If ADR-020's rollout is ever completed and the uncertainty field proves to be used, the amendment slice becomes a reasonable increment on a *living* convention — reopen as a suffixed id then, with adoption evidence. Not before.

## Related
- **Sources:** [[contract-coding-paper]] · [[research-brief-2026-08-07]] · [[scout-notes-2026-08-07-cycle8]]
- [[handoff-and-orchestration]] · [[handoff-contract-uncertainty-fields]] (the unadopted predecessor — the reason this is rejected) · [[convention-staleness-review]]
