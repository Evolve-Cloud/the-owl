---
title: Research Vault — Index
type: index
tags: []
updated: 2026-07-24
---

# the-owl Research Vault — Master Index

External-research knowledge base for **agent-team engineering**. See [[SCHEMA]] for conventions and workflows. Separate from the internal `docs/wiki/`.

## Status
- **Cycles run:** 4 (2026-07-23 cycle 1; 2026-07-23b continuation → PR #2; 2026-07-24 → PR #3; 2026-07-24b human-directed rollout completion)
- **Decided:** 24 (6 accepted, 1 rejected, 17 deferred) — see [[ledger]]
- **Synthesis:** see [[overview]]

## Sources
**25 source notes in `sources/`** — one page per ingested codex-brief source (name/URL/stars + what it contributes + links to the ideas it informs). Materialized 2026-07-24. Key: [[anthropic-building-effective-agents]] · [[metagpt]] · [[langgraph]] · [[crewai]] · [[microsoft-autogen]] · [[openhands]] · [[swe-agent]] · [[openai-agents-sdk-handoffs]] · [[wshobson-agents]].
- [[research-brief-2026-07-23]] — codex brief (cycle 1): 8 sources, 9 ideas.
- [[scout-notes-2026-07-23]] — scout live research (cycle 1): w1–w4.
- [[research-brief-2026-07-24]] — codex brief (cycle 2): 22 sources, 16 ideas.
- [[scout-notes-2026-07-24]] — scout live research (cycle 2): x1–x5.

## Patterns
- [[role-decomposition]] — roles / ownership boundaries (cycle 2).
- _communication / handoff — captured in [[handoff-contract]] + `docs/conventions/handoff-contract.md` (dedicated pattern page: lint follow-up)._

## Ideas
- [[handoff-contract]] — **accepted (91)** → ADR-004.
- [[handoff-contract-rollout]] — **accepted (94)** → ADR-006/007/008 (architect/builder/chronicler). The queued ADR-004 follow-up, grounded via L1.5 (ADR-005).
- [[role-ownership]] — **accepted (87)** → ADR-009 (promotes previously-deferred `explicit-role-boundaries`).
- [[isolated-workspaces-for-parallel-coding]] — **rejected (41)** — runtime-shaped, low fit.
- Others deferred; see [[ledger]].

## Sections
- [[overview]] — evolving synthesis: how to build the best agent team
- [[ledger]] — the decision ledger (dedup source of truth)
- [[log]] — chronological cycle log
