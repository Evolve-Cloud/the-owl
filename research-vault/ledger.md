---
title: Decision Ledger
type: index
tags: []
updated: 2026-07-26
---

# Decision Ledger — dedup source of truth

Before scoring any candidate, `curator` checks this table. A decided `id` is **skipped** — the-owl never re-litigates a settled idea (see [[SCHEMA]] → The ledger). Materially new evidence for a decided idea gets a **new suffixed id**, never a silent overwrite.

`status`: `accepted` · `rejected` · `deferred` · `quarantined`

| id | title | score | status | adr | first_seen | decided |
|----|-------|-------|--------|-----|------------|---------|
| handoff-contract | Explicit handoff contract per agent | 91 | accepted | ADR-004 | 2026-07-23 | 2026-07-23 |
| handoff-contract-rollout | Roll the handoff contract into individual agents (architect/builder/chronicler) | 94 | accepted | ADR-006, ADR-007, ADR-008 | 2026-07-23 | 2026-07-23 |
| role-ownership | Role ownership & non-ownership convention | 87 | accepted | ADR-009 | 2026-07-23 | 2026-07-24 |
| explicit-role-boundaries | Standardized role/non-goals section | 84 | accepted | ADR-009 | 2026-07-23 | 2026-07-24 |
| isolated-workspaces-for-parallel-coding | File ownership / worktree isolation | 41 | rejected | | 2026-07-24 | 2026-07-24 |
| least-privilege-tool-scopes | Tight per-agent tool lists | 66 | deferred | | 2026-07-23 | 2026-07-26 |
| evaluator-optimizer-loop | Grader/rubric return-gate | 68 | deferred | | 2026-07-23 | 2026-07-26 |
| provenance-first-evaluation | Cite a real source per claim | — | deferred | | 2026-07-23 | 2026-07-23 |
| artifact-oriented-context | Durable artifacts over chat history | — | deferred | | 2026-07-23 | 2026-07-23 |
| markdown-source-of-truth | Single markdown source of truth | — | deferred | | 2026-07-23 | 2026-07-23 |
| workflow-first-orchestration | Deterministic workflow + agent at decision points | — | deferred | | 2026-07-23 | 2026-07-23 |
| centralized-governance-hub | Central governance/hub doc | — | deferred | | 2026-07-23 | 2026-07-23 |
| agent-frontmatter-fields | maxTurns/Memory/isolation frontmatter | — | deferred | | 2026-07-23 | 2026-07-23 |
| manager-retains-control | Central manager, bounded specialists | — | deferred | | 2026-07-24 | 2026-07-24 |
| sop-as-executable-contract | SOP as staged workflow contract | — | deferred | | 2026-07-24 | 2026-07-24 |
| scope-based-agent-library | Scope-aware folder organization | — | deferred | | 2026-07-24 | 2026-07-24 |
| context-isolation-and-summary | Fresh context + summary per specialist | — | deferred | | 2026-07-24 | 2026-07-24 |
| durable-state-separated-from-transcript | Durable artifact classes vs transcript | — | deferred | | 2026-07-24 | 2026-07-24 |
| evidence-action-observation-loop | Evidence log / ReAct-style grounding | — | deferred | | 2026-07-24 | 2026-07-24 |
| human-approval-at-side-effect-boundaries | Approval gate at side-effects | — | deferred | | 2026-07-24 | 2026-07-24 |
| directed-handoff-graph | Directed edges, no free mesh | — | deferred | | 2026-07-24 | 2026-07-24 |
| adr-backed-prompt-evolution | Extend ADR template for prompt changes | — | deferred | | 2026-07-24 | 2026-07-24 |
| handoff-role-rollout-completion | Finish handoff-contract + role-ownership across all pipeline agents | — | accepted | ADR-011 | 2026-07-24 | 2026-07-24 |
| efficiency-scorecard | Rollout-coverage scorecard + weekly cadence | — | accepted | ADR-012 | 2026-07-24 | 2026-07-24 |
| externalized-checkpoint-memory | Explicit state and resumable checkpoints (mid-cycle) | 75 | accepted | ADR-016 | 2026-07-26 | 2026-07-26 |
| context-budgeting | Structured Context Budget section per agent | 74 | deferred | | 2026-07-26 | 2026-07-26 |
| single-agent-first | "Why multiple agents?" field on team-design ADRs | 69 | deferred | | 2026-07-26 | 2026-07-26 |
| supervisor-specialists | Formalize orchestrator-as-sole-delegator in every agent | 67 | deferred | | 2026-07-26 | 2026-07-26 |
| sequential-artifact-pipeline | Canonical enumerated stage-artifact list | 68 | deferred | | 2026-07-26 | 2026-07-26 |
| human-approval-gates | Per-agent Approval Gate block | 67 | deferred | | 2026-07-26 | 2026-07-26 |
| trajectory-evals | Mandatory per-agent trajectory-check eval contract | 58 | rejected | | 2026-07-26 | 2026-07-26 |
| parallel-independent-work | Parallelization-eligibility field on ADRs | 52 | rejected | | 2026-07-26 | 2026-07-26 |

> Cycle 2026-07-23: circuit breaker cap = 3 accepted/cycle; cycle 1 kept conservative → **1 accepted**, rest **deferred** (revisit next cycles, evidence already captured; not re-litigated).
>
> Cycle 2026-07-23b (continuation, no new codex spend): applied the new L1.5 grounding (ADR-005) to the queued **handoff-contract rollout** — 3 accepted edits (architect/builder/chronicler) = the ADR-004 follow-up, at the cap. scout/curator (partial) + strategist/system-designer queued next. Deferred backlog ideas untouched (not re-litigated). Merged via PR #2.
>
> Cycle 2026-07-24: fresh codex brief (22 sources / 16 ideas) + scout live pass. Deduped vs ledger + **L1.5 grounded against the real code**. **1 accepted** (`role-ownership` / ADR-009 — promotes the previously-deferred `explicit-role-boundaries` with today's stronger evidence, now accepted under ADR-009), **1 rejected** (`isolated-workspaces` — runtime-shaped, applicability 2/5), rest **deferred**. Brief-id aliases (same idea, not re-litigated): `narrow-single-owner-roles`→`role-ownership`; `typed-minimal-handoffs`→`handoff-contract`; `tool-allowlists-and-provenance`→`least-privilege-tool-scopes`; `evaluator-optimizer-with-replay`→`evaluator-optimizer-loop`; `deterministic-workflow-before-autonomous-swarm`→`workflow-first-orchestration`; `markdown-frontmatter-config`→`agent-frontmatter-fields`. Several deferred ids (`manager-retains-control`, `directed-handoff-graph`, `human-approval-at-side-effect-boundaries`, `adr-backed-prompt-evolution`) are **already largely implemented** in the-owl (hub-spoke, HITL, ADR-per-change) → deferred with that noted, low re-accept priority.
>
> Cycle 2026-07-26: fresh codex brief (15 sources / 12 ideas, model gpt-5.6-luna — same fallback as before; the brief's own `generator:` frontmatter inaccurately self-reports a different model, corrected in `log.md`) + scout live corroboration (3 fetches, all real, none fabricated). **1 accepted, provisional** (`externalized-checkpoint-memory`, score 83 raw → **75 after the ADR-015 self-haircut** — the calibration probe's measured +15.4 curator optimism bias applies here; a genuinely-verified gap — `.owl/state/` confirmed to have no mid-cycle checkpoint — but still marginal-band, so the accept is explicitly provisional, revisit if unused). **2 rejected**: `trajectory-evals` (58 — its own best-cited source, read in full, argues the *opposite* of what the idea proposes: outcome-primary grading, not mandatory trajectory-checks; the-owl's ADR-014/015 harness already does the better-supported version) and `parallel-independent-work` (52 — ADR-010 explicitly documents the loop as sequential/one-agent-per-phase, same "presupposes a runtime the-owl doesn't have" shape as 2026-07-24's `isolated-workspaces` reject). **2 aliases of already-decided ideas, not re-scored** (brief generated fresh ids for existing decisions): `narrow-role-boundaries` → `role-ownership` (ADR-009, accepted); `structured-handoff-contracts` → `handoff-contract` (ADR-004, accepted). **2 re-scored deferred ideas with a materially-changed basis:** `evaluator-optimizer-loop` (unscored → 68 — the-owl's own ADR-014/015 fitness harness now substantially implements this; no further action needed, not a fresh gap) and `least-privilege-tool-scopes` (78 → **66, revised down** despite stronger evidence this cycle — grounding found the-owl's inline, non-subagent execution model (ADR-010) has **no mechanism to actually restrict which tools are available per-agent**, so a "Forbidden Tools" section would be unenforceable prose with a false-confidence risk, same failure class as the rejected `isolated-workspaces`; Fit dropped more than Evidence rose). **5 new deferred** (`context-budgeting` 74, `single-agent-first` 69, `supervisor-specialists` 67, `sequential-artifact-pipeline` 68, `human-approval-gates` 67) — each already substantially embodied in the-owl's existing conventions/architecture (verified directly per-candidate, not assumed), or landing just under the self-haircut-adjusted bar.
