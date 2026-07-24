---
title: Overview — How to Build the Best Agent Team
type: overview
tags: []
sources: 6
updated: 2026-07-23
---

# How to Build the Best Agent Team — living synthesis

`curator` revises this page whenever a new cycle materially changes the picture.

## Current thesis (corroborated by cycle 2026-07-23)
Two independent research passes (codex + scout) converged on the-owl's baseline and sharpened it:
- **Small, specialized roles with explicit boundaries** beat large autonomous swarms.
- **Hub-and-spoke over mesh** — an orchestrator delegates; specialists hand off, never call each other.
- **Handoffs are structured state transitions, not chat** — asymmetric, summary-based (as Claude Code subagents already work). → *adopted this cycle as `docs/conventions/handoff-contract.md` (ADR-004).*
- **Context-minimal handoffs** (N-1 + pointers), durable artifacts over chat history.
- **Grader/rubric return-gates** ("Performance Outcomes") — a separate grader sends work back until it meets a rubric. The-owl's curator+gate is exactly this pattern.
- **Markdown-native, no runtime** is viable; framework runtime abstractions are *not* automatically appropriate for a no-runtime lib.
- Field is moving **away from** unconstrained group chat, implicit memory, framework-first complexity.

## Open fronts (deferred ideas to pressure-test next cycles)
- Roll the handoff contract into each agent (incremental, 1/ADR).
- Least-privilege tool scopes per agent · standardized role/non-goals section.
- Concrete 2026 frontmatter fields (`maxTurns`, `Memory`, `isolation`) — applicability to slash-command agents needs care.

## Related
- [[SCHEMA]] · [[ledger]] · [[index]] · [[handoff-contract]]
