# ADR-012 — Measure loop efficiency with a rollout-coverage scorecard; move the schedule to weekly

**Status:** Accepted
**Date:** 2026-07-24
**Author:** @architect (human-directed; operator config + tooling)
**Tags:** [self-improvement, metrics, efficiency, schedule, tooling]
**Related:** ADR-001 (loop + NFR-SEC-1 carve-out), ADR-005 (L1.5 grounding), ADR-010 (headless reliability), ADR-011 (the rollout this scorecard surfaced as the priority)

## Contexto
There was no way to measure whether the loop is *efficient* — only that it runs. The failure mode for a self-improvement loop is **motion mistaken for progress**: it can emit an ADR + PR every cycle and feel productive while the agents get no better. Counting ADRs / PRs / ideas is a **vanity metric** that rewards motion.

The data already told a story once aggregated: the loop **accepts conventions faster than it rolls them out**. Before ADR-011, `handoff-contract` was on 3 of 7 target agents and `role-ownership` on 0; the ledger held ~16 deferred ideas. The **same-day guard had already fired** (cycle 2b did no new codex research because the same-day brief was still fresh) — direct evidence that the daily research cadence was out-running what the loop could integrate. The binding constraint is **integration/absorption, not research supply**.

## Decisão
Two coupled decisions:

1. **Efficiency = durable value delivered ÷ cost to deliver.** The headline signal is **rollout coverage** — is accepted work actually *finished* across the fleet, or does it linger as "convention debt"? Ship a read-only scorecard, **`scripts/owl-metrics.py`**, that computes from what the loop already produces (`research-vault/ledger.md`, `.owl/state/last-run.json`, the agent files, git): rollout coverage per convention, accept rate (rigor discrimination), score separation, deferred backlog, gate result, carve-out contact (must be 0). It is outside the NFR-SEC-1 carve-out (pure read-only reporting) and safe to run anytime. Cost fields (codex $, tokens, human-review minutes) are **not yet instrumented** — a tracked follow-up; until then the loop cannot compute true cost-per-durable-change.

2. **Move the launchd schedule from daily → weekly (Mondays 07:13).** Because the binding constraint is absorption, not research, a slower research cadence lets each merged change be *used* for a week before the next cycle — a precondition for measuring durability. The change enters at the start of the week and is absorbed through it.

## Alternativas consideradas
- **Metrics — Alternativa A (escolhida): a rollout-coverage-first scorecard from existing artifacts.** Prós: cheap (≈70% of inputs already exist), read-only/safe, surfaces the real bottleneck. Contras: cost side not yet instrumented (deferred).
- **Metrics — Alternativa B: vanity counters (ADRs/PRs/ideas per cycle).** Prós: trivial. Contras: rewards motion over progress — exactly the failure mode. Rejected.
- **Cadence — keep daily.** Prós: more cycles, faster metric signal. Contras: research supply already exceeds integration (same-day guard fired); daily inflates the deferred backlog faster than it drains. Rejected.
- **Cadence — decouple research (weekly) from rollout (on-demand).** The *ideal* (the constraint is integration, not research), but `/owl:evolve` couples them in one command. Deferred; for now, weekly-everything + manual `/owl:evolve` runs (which honor the same-day guard and do only integration) approximate it.

## Consequências
- **Mais fácil:** a per-cycle scorecard makes "are we actually finishing accepted work?" visible and trend-able; the priority for the next cycle is legible (drain rollout debt before accepting new conventions — the loop's own standing challenger flag).
- **Trade-offs aceitos:** at weekly cadence the metric signal accumulates **~7× slower** (a meaningful trend takes ~2 months instead of ~1.5 weeks) — acceptable while the priority is draining backlog, not stacking cycles; cost-per-durable-change stays uncomputable until the cost fields are instrumented.
- **Novos riscos:** none — the scorecard is read-only; the schedule/config edits are human-directed operator changes.

## Notas de implementação
- `scripts/owl-metrics.py` — read-only; run `python3 scripts/owl-metrics.py`. `NA_FOR_CONVENTIONS = {"team"}` excludes the orchestrator hub from the coverage denominator (documented; printed on its own N/A line).
- Schedule: `.owl/loop-config.yml` `cadence: weekly` + `day: monday` + `time: "07:13"`; launchd plist `StartCalendarInterval` gains `Weekday=1` (both the repo template `scripts/com.evolvelabs.owl.daily.plist` and the live `~/Library/LaunchAgents/` copy; reloaded via `launchctl bootout`+`bootstrap`).
- The launchd **label/filename keep the legacy `daily` name** (referenced by ops docs' bootout/kickstart commands + historical CHANGELOG); a comment in each file kills the footgun ("legacy name, runs weekly"). Full rename deferred as a doc sweep.
- `.owl/loop-config.yml` is inside the NFR-SEC-1 carve-out (human-only). This edit is legitimate because it is **human-directed**, not an autonomous-loop self-modification — which is exactly what the carve-out reserves for humans.
- Follow-up: instrument `cost` + `human_review_minutes` in `.owl/state/last-run.json` (a small change to the loop's last-run writer) to enable cost-per-durable-change.
