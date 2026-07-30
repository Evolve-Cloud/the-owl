---
description: the-owl agent-library conventions — a paths-scoped reminder that loads only when editing an agent, ADR, or convention file
paths:
  - ".claude/commands/agents/*.md"
  - ".claude/commands/owl/*.md"
  - "docs/decisions/*.md"
  - "docs/conventions/*.md"
---

# the-owl conventions (paths-scoped)

You are editing an agent definition, an ADR, or a convention. The binding conventions for the-owl's agent library — **read the full text at the path before you edit** (they are the source of truth; this rule only surfaces them, scoped to when they matter):

- **Handoff contract** (ADR-004, extended by ADR-020) → `docs/conventions/handoff-contract.md` — every handoff is a structured state transition with context-minimal (N-1) fields, incl. assumptions / open questions / evidence-confidence.
- **Role ownership** (ADR-009) → `docs/conventions/role-ownership.md` — one boundary, one owner; each agent declares what it owns and what it explicitly does NOT (with the named owner). Must agree with its `.meta.yaml`.
- **Consult claude-architecture** → `docs/conventions/consult-claude-architecture.md` — invoke the `claude-architecture` skill before any Claude-native build.

> **Mechanism note:** this file uses the native path-scoped `.claude/rules/` feature (auto-loads only when an edited file matches `paths:`). It deliberately does NOT `@import` the conventions — `@import` is documented for `CLAUDE.md`, not for rules files (code.claude.com/docs/en/memory.md). To instead auto-load the full convention *text* here, the documented path is a **symlink** (`ln -s ../../docs/conventions/handoff-contract.md .claude/rules/handoff-contract.md`) — note a symlinked file loads with the target's own frontmatter, so it would load unconditionally unless the target itself carries `paths:`.
