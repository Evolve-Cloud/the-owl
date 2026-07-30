---
description: the-owl agent-library conventions — auto-loaded only when editing an agent, ADR, or convention file (paths-scoped, keeps other sessions context-minimal)
paths:
  - ".claude/commands/agents/*.md"
  - ".claude/commands/owl/*.md"
  - "docs/decisions/*.md"
  - "docs/conventions/*.md"
---

# the-owl conventions (paths-scoped auto-load)

These load **only** when you are editing an agent definition, an ADR, or a convention — so the conventions are in context exactly when they're load-bearing, without inflating unrelated sessions (respects the context-minimal / turn-economy principle: ADR-004, ADR-018).

**Source of truth stays in `docs/conventions/`** — this file only surfaces it; it does not fork it. Edit the convention there, not here.

- @../../docs/conventions/handoff-contract.md
- @../../docs/conventions/role-ownership.md
- @../../docs/conventions/consult-claude-architecture.md

> If any `@import` above fails to resolve, the imports are relative to THIS file (`.claude/rules/`) — `../../` reaches the repo root. The conventions remain independently readable at their `docs/conventions/` paths, which every agent already cites.
