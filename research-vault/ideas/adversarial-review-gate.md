---
title: "Independent adversarial review gate with materiality thresholds"
type: idea
tags: [safety]
sources: 3
status: rejected
score: 0
adr: ""
updated: 2026-07-29
---
**Category:** safety · **Confidence:** medium · **Applicability:** n/a (carve-out)

## Pattern
Insert an independent challenge/verify stage before a change is declared complete, with explicit materiality thresholds governing when guardian verification / sentinel security assessment / challenger review are required.

## Proposed change to the-owl
"Add a Change Closure Gate requiring a guardian verification report, sentinel security assessment when attack surface changes, and challenger review for material architectural decisions."

## L1.5 self-audit (ADR-005)
- `já_implementado?` **Yes.** the-owl already runs exactly this: `/owl:evolve` **L4** is a blocking three-review gate (guardian + sentinel + challenger, independent). The pattern is core architecture.
- `onde_está_o_gap` The only net-new element is *materiality thresholds* (when each review must fire) — which is **tuning the closure gate itself**.
- `arquivo_alvo` guardian/sentinel/challenger and/or the L4 gate logic in the orchestrator.

## Curator verdict — REJECTED (carve-out auto-reject, NFR-SEC-1)
> **HARD STOP (curator ⛔):** a `proposed_change` whose target is the guardian/sentinel/challenger closure gate — or the governance that decides when that gate fires — is inside the **NFR-SEC-1 carve-out**. The autonomous loop must never edit the gate agents or its own governance. **Auto-reject + human alert**, regardless of rubric score. Defense-in-depth: even though the curator flags this, the sentinel would also veto any such diff at L4.

Doubly disqualified: (1) already implemented (the three-review gate is the-owl's core), and (2) the only novel slice (materiality thresholds) is governance-of-the-gate = carve-out. The underlying "when should the gate fire on trivial vs material changes?" is a **legitimate open question for the human owner** (it also appears in the brief's Open Questions), not an autonomous edit. Related deferred concept: `human-approval-gates` (deferred 67, 2026-07-26) — that one targets per-agent approval blocks, not the closure gate; this id is distinct and rejected on carve-out grounds.

## Related
- **Sources:** [[anthropic-building-effective-agents]] · [[anthropic-demystifying-evals]] · [[research-brief-2026-07-29]]
- [[role-decomposition]]
