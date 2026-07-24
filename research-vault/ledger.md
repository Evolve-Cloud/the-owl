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
| explicit-role-boundaries | Standardized role/non-goals section | 84 | deferred | | 2026-07-23 | 2026-07-23 |
| least-privilege-tool-scopes | Tight per-agent tool lists | 78 | deferred | | 2026-07-23 | 2026-07-23 |
| evaluator-optimizer-loop | Grader/rubric return-gate | — | deferred | | 2026-07-23 | 2026-07-23 |
| provenance-first-evaluation | Cite a real source per claim | — | deferred | | 2026-07-23 | 2026-07-23 |
| artifact-oriented-context | Durable artifacts over chat history | — | deferred | | 2026-07-23 | 2026-07-23 |
| markdown-source-of-truth | Single markdown source of truth | — | deferred | | 2026-07-23 | 2026-07-23 |
| workflow-first-orchestration | Deterministic workflow + agent at decision points | — | deferred | | 2026-07-23 | 2026-07-23 |
| centralized-governance-hub | Central governance/hub doc | — | deferred | | 2026-07-23 | 2026-07-23 |
| agent-frontmatter-fields | maxTurns/Memory/isolation frontmatter | — | deferred | | 2026-07-23 | 2026-07-23 |

> Cycle 2026-07-23: circuit breaker cap = 3 accepted/cycle; cycle 1 kept conservative → **1 accepted**, rest **deferred** (revisit next cycles, evidence already captured; not re-litigated).
> Cycle 2026-07-23b (continuation, no new codex spend): applied the new L1.5 grounding (ADR-005) to the queued **handoff-contract rollout** — 3 accepted edits (architect/builder/chronicler) = the ADR-004 follow-up, at the cap. scout/curator (partial) + strategist/system-designer queued next. Deferred backlog ideas untouched (not re-litigated).
