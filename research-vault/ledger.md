---
title: Decision Ledger
type: index
tags: []
updated: 2026-07-23
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
| least-privilege-tool-scopes | Tight per-agent tool lists | 78 | deferred | | 2026-07-23 | 2026-07-23 |
| evaluator-optimizer-loop | Grader/rubric return-gate | — | deferred | | 2026-07-23 | 2026-07-23 |
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

> Cycle 2026-07-23: circuit breaker cap = 3 accepted/cycle; cycle 1 kept conservative → **1 accepted**, rest **deferred** (revisit next cycles, evidence already captured; not re-litigated).
>
> Cycle 2026-07-23b (continuation, no new codex spend): applied the new L1.5 grounding (ADR-005) to the queued **handoff-contract rollout** — 3 accepted edits (architect/builder/chronicler) = the ADR-004 follow-up, at the cap. scout/curator (partial) + strategist/system-designer queued next. Deferred backlog ideas untouched (not re-litigated). Merged via PR #2.
>
> Cycle 2026-07-24: fresh codex brief (22 sources / 16 ideas) + scout live pass. Deduped vs ledger + **L1.5 grounded against the real code**. **1 accepted** (`role-ownership` / ADR-009 — promotes the previously-deferred `explicit-role-boundaries` with today's stronger evidence, now accepted under ADR-009), **1 rejected** (`isolated-workspaces` — runtime-shaped, applicability 2/5), rest **deferred**. Brief-id aliases (same idea, not re-litigated): `narrow-single-owner-roles`→`role-ownership`; `typed-minimal-handoffs`→`handoff-contract`; `tool-allowlists-and-provenance`→`least-privilege-tool-scopes`; `evaluator-optimizer-with-replay`→`evaluator-optimizer-loop`; `deterministic-workflow-before-autonomous-swarm`→`workflow-first-orchestration`; `markdown-frontmatter-config`→`agent-frontmatter-fields`. Several deferred ids (`manager-retains-control`, `directed-handoff-graph`, `human-approval-at-side-effect-boundaries`, `adr-backed-prompt-evolution`) are **already largely implemented** in the-owl (hub-spoke, HITL, ADR-per-change) → deferred with that noted, low re-accept priority.
