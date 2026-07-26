# ADR-017 — Convention staleness review: the curator re-examines old conventions as models improve

**Status:** Accepted
**Date:** 2026-07-26
**Author:** @architect (integrate step; from curator idea `convention-staleness-review`, human-directed cycle)
**Tags:** [self-improvement, governance, curator, fitness, reversibility]
**Related:** ADR-001 (loop + NFR-SEC-1 carve-out), ADR-005 (L1.5 grounding), ADR-012 (rollout-coverage scorecard — the complement), ADR-013 (claim verification), ADR-014/ADR-015 (fitness gate for *new* conventions)

## Contexto
A self-improvement loop that only ever *adds* conventions accumulates cruft. A convention is adopted to compensate for a model weakness; when a stronger model no longer has that weakness, the convention becomes dead weight — extra prompt surface that costs attention budget and earns nothing. This is the standing failure mode of a loop that only ratchets forward.

Two Anthropic engineering pieces name the insight directly (ADR-013 claim verification, live-fetched 2026-07-26): *"harnesses encode assumptions about what Claude can't do on its own. However, those assumptions need to be frequently questioned because they can go stale as models improve"* (Scaling Managed Agents, 2026-04-08), corroborated by *"Every component in a harness encodes an assumption about what the model can't do... assumptions are worth stress testing"* (Harness Design for Long-Running Apps, 2026-03-24).

The-owl already has two of the three needed loops but not this one: ADR-014/015 **fitness-gate new conventions at accept-time**, and ADR-012's `scripts/owl-metrics.py` **measures rollout coverage** (is accepted work finished across the fleet?). Nothing re-examines whether an **already-rolled-out** convention *still* earns its keep. The curator flow (`curator.md` → "🔄 Meu fluxo", steps 0–6) only scores **incoming** candidates.

## Decisão
Add one **additive step** to the curator's per-cycle flow: each cycle, re-read the **1–2 oldest / least-recently-validated** accepted conventions and ask, as a **curator judgment**, whether the current model plausibly makes one redundant. If so, **flag it as a candidate for owner-reviewed re-fitness** (re-run `scripts/owl-fitness.py` on the convention's target dimension) and record the flag in `log.md`. The curator **never reverts autonomously** — keep/revert is a human decision, on the same principle as the NFR-SEC-1 carve-out.

**Actionable, not aspirational (the load-bearing design choice).** The step is a curator *judgment that triggers* re-fitness; it does **not** read a periodic re-fitness Δ of old conventions, because none is instrumented — fitness runs are per-change/on-demand (ADR-012/014) and the accept-time Δ is frozen. Writing the step to "read the decayed Δ" would depend on a prerequisite that does not exist; writing it to "flag for re-fitness" needs no new data and works today.

## Alternativas consideradas
- **A (escolhida): a curator-judgment flag that triggers owner-reviewed re-fitness.** Prós: concrete, carve-out-safe, needs no new instrumentation, complements ADR-012/015 without overlap. Contras: relies on curator judgment to spot a stale convention (mitigated by "oldest first, 1–2/cycle" bounding + human review of the flag).
- **B: read an automated re-fitness Δ of old conventions and auto-flag when it decays into noise.** Prós: fully mechanical. Contras: the re-fitness-of-old-conventions data is **not instrumented** — this depends on a non-existent prerequisite. Rejected (deferred as a possible future once that data exists).
- **C: let the curator autonomously revert stale conventions.** Contras: reverting a convention changes agent behavior autonomously — exactly what the carve-out reserves for humans. Rejected.
- **D: a separate `docs/conventions/` doc + fleet rollout.** Contras: this is a curator-*process* step, not a fleet-wide agent convention; a doc + rollout would be over-production. Rejected in favor of the atomic `curator.md` edit (ADR-012 precedent: process change = agent/tooling edit + ADR, no separate doc).

## Consequências
- **Mais fácil:** the standing convention set gets a backward pass, so cruft becomes visible and legible for the owner to prune — the reverse direction of ADR-012's forward rollout-coverage view. Together they answer "is accepted work finished?" *and* "does finished work still pay for itself?"
- **Trade-offs aceitos:** the flag is a **curator judgment**, not a measurement, so it can miss or over-flag — bounded to 1–2 oldest conventions/cycle and always human-reviewed before any revert. Impact is **provisional** (ADR-015): full credit only once the step actually flags a stale convention and a re-fitness confirms it.
- **Novos riscos:** none to safety — the step is read-only + triggers an existing read-only script, never auto-reverts, and edits `curator.md` (outside the carve-out), not `.owl/loop-config.yml`.

## Notas de implementação
- Edit: `.claude/commands/agents/curator.md`, "🔄 Meu fluxo" — new step **4.5** (after scoring/claim-verification, before persistence), additive; the `.devflow/agents/curator.meta.yaml` prose source-of-truth stays consistent (no ownership change).
- The step reuses existing machinery + `log.md`. **Precision (gate finding, challenger 2026-07-26):** `scripts/owl-fitness.py` **only compares two run-record sets (before/after) — it does not run the eval.** So "re-fitness an old convention" = re-run the eval fleet **with/without** the convention on the *current* model to produce fresh run-records, *then* `owl-fitness.py` reports the Δ. That is real owner-decided work; the step therefore **recommends** re-fitness to the owner rather than claiming to trigger it. No new runtime, no new file.
- **Anti-ceremony (gate finding):** the step must **record in `log.md` every cycle which convention it examined and the verdict** (including "still earns its keep"), so it leaves an audit trail and cannot be silently skipped. Impact credit stays provisional until it produces its first *revert/simplify* flag confirmed by a re-fitness.
- **Provenance:** curator idea `research-vault/ideas/convention-staleness-review.md` (score 82, claim-verified) → this ADR → the `curator.md` edit. Ledger row updated to `accepted / ADR-017`.
- **Landing:** working-tree edit for owner review; **not** committed to `main` by the loop (shadow default, `.owl/loop-config.yml` `landing: pr`). Gate: challenger (independent) + sentinel/guardian (inline) before any commit.
