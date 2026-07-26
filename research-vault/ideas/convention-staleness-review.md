---
title: "Convention staleness review"
type: idea
tags: [self-improvement, governance, curator, fitness, reversibility]
sources: 2
status: accepted
score: 82
adr: ADR-016
updated: 2026-07-26
---
**Category:** self-improvement / loop governance · **Confidence:** med · **Applicability:** 4/5

## Pattern
A self-improvement loop that only ever *adds* conventions accumulates cruft: a convention adopted to compensate for a model weakness can become dead weight once a stronger model no longer has that weakness. The-owl already fitness-gates **new** conventions at accept-time (ADR-014/015) and measures **rollout coverage** of accepted ones (ADR-012), but nothing re-examines whether an **already-rolled-out** convention still earns its keep as models improve. Convention staleness review closes that gap.

## Proposed change to the-owl
Add one **additive step** to the curator's per-cycle flow (`.claude/commands/agents/curator.md` → "🔄 Meu fluxo"): each cycle, re-read the **1–2 oldest / least-recently-validated** accepted conventions and ask, as a **curator judgment**, whether the current model plausibly makes one redundant (a weakness the convention compensates for is now native). If so, **recommend an owner-reviewed re-fitness** — re-run the eval **with/without** the convention on the *current* model, then compare the target-dimension Δ with `scripts/owl-fitness.py` (a **comparator** of run-records; it does not run the eval — gate finding). **Never revert autonomously** — revert/keep is a human decision, like the NFR-SEC-1 carve-out. **Record every cycle in `log.md` which convention was examined and the verdict** (including "still earns its keep") so the step leaves an audit trail and cannot become ceremony. It does not read a pre-existing re-fitness Δ (none is instrumented for old conventions — see the L1.5 audit).

## L1.5 self-audit (ADR-005)
- `já_implementado?` **No.** ADR-012's `scripts/owl-metrics.py` measures *rollout coverage* (is accepted work finished across the fleet?); ADR-014/015 fitness-gate *new* conventions *at accept-time*. Neither re-examines *old* conventions as models improve. Genuine gap.
- `onde_está_o_gap` The curator flow (steps 0–6) only scores **incoming** candidates; there is no backward pass over the standing convention set.
- `arquivo_alvo` `.claude/commands/agents/curator.md` (the "🔄 Meu fluxo" section). Outside the carve-out. **Data check:** the step must be the *actionable* form (curator judgment → flag → trigger re-fitness), because no periodic re-fitness Δ of old conventions is produced today; the accept-time Δ is frozen. The aspirational form (read a decayed Δ) would depend on a non-existent prerequisite and was rejected.

## Curator verdict — score 82 (threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 22 | Markdown-only, no new runtime (triggers the existing `owl-fitness.py`), hub-spoke (flags to human), context-minimal. |
| Evidence strength (20) | 15 | Two primary Anthropic sources state the insight verbatim; live-fetch confirmed (below). Strong on the *insight*, though not "multiple sources on this exact convention." |
| Impact (20) | 13 | Structural: closes a real gap (convention cruft) complementing ADR-012/015. **Provisional** — full credit only once it actually flags a stale convention (ADR-015). |
| Simplicity & reversibility (15) | 14 | One additive flow step; trivially reversible. |
| Safety (10) | 9 | Carve-out-safe: edits `curator.md`, **not** `.owl/loop-config.yml`; never auto-reverts; read-only + triggers an existing read-only script. No new attack surface. (≥ safety_floor 7.) |
| Non-duplication (10) | 9 | Distinct from ADR-012 (rollout coverage) and ADR-015 (new-convention gating). |

**Promotion note (deferred → accepted, same day):** deferred earlier 2026-07-26 pending concreteness. Promoted because it now (1) reduces to a **concrete, carve-out-safe, data-independent** atomic edit (the actionable framing), (2) has a **verified** central claim, and (3) is a **structural/process** convention (ADR-012 shape), so the ADR-015 *behavioral* discount barely applies. Structurally identical to the `explicit-role-boundaries`→`role-ownership` promotion. The user's direction authorized the integrate *action*; the rubric — not the direction — clears the bar. Acceptance marked **provisional-pending-first-flag**.

## Claim verification
_(ADR-013 — verified BEFORE landing.)_
- **Claim:** harness/convention assumptions encode what the model can't do and **go stale as models improve**, so they must be periodically re-questioned.
- **Source:** [Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents) (Anthropic, pub. 2026-04-08) + [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) (Anthropic, 2026-03-24).
- **Verdict:** **confirmed** (live fetch 2026-07-26).
- **Evidence:** > "harnesses encode assumptions about what Claude can't do on its own. However, those assumptions need to be frequently questioned because they can go stale as models improve." — fetched verbatim from the Managed Agents article; corroborated by Harness Design: "Every component in a harness encodes an assumption about what the model can't do... assumptions are worth stress testing."

## Related
- **Sources:** [[scaling-managed-agents]] · [[harness-design-long-running-apps]]
- **Patterns:** [[context-engineering]]
- **Complements:** ADR-012 (rollout coverage) · ADR-014/015 (fitness gate for new conventions)
