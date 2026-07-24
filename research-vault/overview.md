---
title: Overview — How to Build the Best Agent Team
type: overview
tags: []
sources: 12
updated: 2026-07-24
---

# How to Build the Best Agent Team — living synthesis

`curator` revises this page whenever a new cycle materially changes the picture.

## Current thesis (corroborated by cycles 2026-07-23 → 2026-07-24)
Independent research passes (codex + scout, twice) converge on the-owl's baseline and sharpen it:
- **Small, specialized roles with explicit ownership boundaries** beat large autonomous swarms. The named failure mode of vague roles is *duplicated work / endless task-passing* (CrewAI 2026) → **adopted 2026-07-24 as `docs/conventions/role-ownership.md` (ADR-009)**, which standardizes the ownership fields already latent in the `.meta.yaml`/`.md` files.
- **Hub-and-spoke over mesh** — an orchestrator retains control and delegates; specialists hand off, never call each other. (Already the-owl's core invariant — 2026-07-24 brief re-corroborated; not re-adopted.)
- **Handoffs are structured state transitions, not chat** — asymmetric, summary-based. → *adopted as `docs/conventions/handoff-contract.md` (ADR-004); rollout into agents in-flight.*
- **Context-minimal handoffs** (N-1 + pointers), durable artifacts over chat history.
- **Grader/rubric return-gates** — a separate grader sends work back until it meets a rubric. The-owl's curator+gate IS this pattern (so `evaluator-optimizer` stays deferred, not re-invented).
- **Markdown-native, no runtime** is viable; runtime-shaped ideas (worktree isolation for parallel writers) are **rejected** for this lib (2026-07-24: `isolated-workspaces`, applicability 2/5).
- Field is moving **away from** unconstrained group chat, implicit memory, framework-first complexity, and role labels without ownership/exclusions.

## Grounding insight (L1.5, ADR-005)
Scoring against the real code revealed ownership is *already* encoded but **unevenly**: 8/11 agents have `.meta.yaml` (`responsibilities`/`constraints`/`outputs`/`should_delegate_to`); **scout, curator, sentinel lack it**. The convention standardizes the pattern and surfaces this inconsistency (sentinel's fix is human-only — NFR-SEC-1 carve-out).

## Open fronts (deferred ideas to pressure-test next cycles)
- **Rollout:** roll the handoff contract *and* the role-ownership convention into each agent (incremental, 1/ADR); add missing `.meta.yaml` to scout/curator (sentinel = human).
- Least-privilege tool scopes per agent (near-threshold 78; deserves a careful, security-adjacent cycle).
- Evidence-log / provenance convention (ReAct-style) · durable-artifact classes · extend the ADR template for prompt-surface changes.
- Concrete 2026 frontmatter fields (`maxTurns`, `Memory`, `isolation`) — applicability to slash-command agents needs care.

## Related
- [[SCHEMA]] · [[ledger]] · [[index]] · [[handoff-contract]] · [[role-ownership]] · [[role-decomposition]]
