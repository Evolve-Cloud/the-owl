---
title: Role decomposition & ownership boundaries
type: pattern
tags: [roles, structure]
sources: 11
updated: 2026-08-03
---

## Definition
How a multi-agent team divides work into **narrow, single-owner roles** so responsibilities do not overlap. Each agent owns a distinct slice (decision rights + a single output artifact), explicitly declares what it does **not** own (and who does), and has verifiable entry/done criteria. The ownership boundary is expressed as **machine-readable fields**, not prose alone. This is the vault's **#1 recurring axis** — the `bounded-role-charters` idea has been re-surfaced and re-confirmed as still-SOTA across cycles 5, 6, and 7, never displaced by a newer pattern.

## Key ideas
- **Single responsibility per agent.** One clear job beats a pile of overlapping agents ([[anthropic-building-effective-agents]] — "Maintain simplicity"; separation of concerns → more specialized prompts).
- **Explicit non-ownership.** The failure mode of vague roles is duplicated work / endless task-passing / conflicting recommendations ([[crewai]]: "vague roles, overlapping responsibilities, and unclear goals create conflicts where agents duplicate work or pass tasks endlessly"). Naming the *forbidden overlap → owner* is what prevents it.
- **Manager retains control.** A central orchestrator owns planning + integration; specialists are bounded capabilities that **return control** (hub-and-spoke). Distinct from peer handoff where control moves permanently. Backed by the orchestrator-led design of [[magentic-one-paper]] and by [[claude-code-agent-teams]]' lead-coordinates-teammates model.
- **Ownership is structured, not just prose.** Best expressed as machine-readable fields (responsibilities / constraints / outputs / delegation) alongside the human-readable role text. [[claude-code-subagents]] encodes exactly this: one clear job per subagent in markdown + YAML frontmatter.
- **Ownership now extends to tool scope (cycle 7).** The same machine-readable-ownership principle reaches *capability* ownership: native Claude Code subagent frontmatter (`tools:` / `disallowedTools:` / `permissionMode:`) is **harness-enforced**, not advisory prose — so "which tools this role may touch" becomes a declared, enforced boundary rather than a hope. This closes the long-standing `least-privilege-tool-scopes` gap (see mapping below).
- **Typed intermediate artifacts between roles.** [[metagpt]] / [[metagpt-paper]] encode human software-company SOPs (PM/Architect/Engineer/QA) as prompts with standardized outputs between roles; [[ag2]] (coder↔reviewer) and [[microsoft-autogen]] (structured message exchange) show the same coder-vs-reviewer boundary. [[langgraph]] makes the transitions explicit and durable as graph state. Role decomposition and the [[handoff-contract]] are two halves of the same discipline: a narrow role is only useful if what crosses its boundary is typed.

## Evidence / sources
Convergent across independent lineages — framework docs, high-star OSS, and peer-reviewed papers all land on the same pattern:

- [[anthropic-building-effective-agents]] — primary vendor guidance: simplicity + separation of concerns; narrow specialists over monoliths. **The load-bearing thesis.**
- [[claude-code-subagents]] — markdown+YAML, one clear job per subagent; the machine-readable-ownership template.
- [[claude-code-agent-teams]] — lead coordinates teammates over a shared task list (manager-retains-control in practice).
- [[metagpt]] · [[metagpt-paper]] — SOPs-as-prompts with typed intermediate artifacts reduce cascading errors (repo 69.5k + the paper behind it).
- [[magentic-one-paper]] — orchestrator plans/delegates/synthesizes (manager-retains-control, primary source).
- [[crewai]] — the sharpest statement of the *failure mode* of non-ownership (repo 53.6k).
- [[langgraph]] — explicit, durable state transitions between roles (repo 37.4k).
- [[microsoft-autogen]] · [[ag2]] — structured message exchange, explicit coder/reviewer boundaries, least-privilege tool scoping (repos 59.9k / community fork).
- [[wshobson-agents]] — a 38.2k-star markdown-native agent marketplace: separate plugin/skill/command/agent files = scope-aware library organization at scale.
- Original live corroboration: [[scout-notes-2026-07-24]] (x1 PubNub, x3 Anthropic, x4 CrewAI/MetaGPT) and codex [[research-brief-2026-07-24]] (ideas `narrow-single-owner-roles`, `manager-retains-control`, `directed-handoff-graph`, `sop-as-executable-contract`).

> [!note]
> **Adoption ≠ proof.** Star counts (MetaGPT 69.5k, AutoGen 59.9k, CrewAI 53.6k, wshobson 38.2k, LangGraph 37.4k) are point-in-time popularity signals, not production-effectiveness benchmarks — the brief's standing caveat. The load-bearing evidence is the **convergence across independent source types** (vendor primary + papers + high-star OSS) plus the documented failure mode, not any single count.

> [!important]
> **Re-confirmed still-SOTA, cycles 5/6/7.** This axis has been re-surfaced under fresh idea slugs three cycles running — `explicit-role-charters` (2026-07-29), `role-boundaries-and-artifact-contracts` (2026-07-30), `bounded-role-charters` (2026-08-03) — each time the curator's staleness review (ADR-017 step 4.5) found `role-ownership` (ADR-009) **still pays**: Anthropic multi-agent + LangGraph + Claude Code subagents independently re-converge on non-overlapping, artifact-owning role charters, and the current model has **not** made the convention native/obsolete. All three were correctly deduped to the accepted ADR-009 id, never re-litigated ([[ledger]]).

## How it maps to the-owl
the-owl already embodies the core pattern: hub-and-spoke, "specialists never call each other", per-agent `🎯 Minha Responsabilidade` / `⛔ NUNCA FAÇA (HARD STOP)` / `⚠️ Quando NÃO me usar`, and `.meta.yaml` `responsibilities` / `constraints` / `outputs` / `should_delegate_to`.

**Adopted:** `docs/conventions/role-ownership.md` (**ADR-009**, accepted score 87) — standardizes the ownership fields (**Possui** / **Não possui → owner** / **Entradas exigidas** / **Critério de pronto** / **Fonte da verdade** `.md ↔ .meta.yaml`), driven by the [[role-ownership]] idea. Original L1.5 gaps: (1) no convention named this as the standard; (2) `scout`, `curator`, `sentinel` lacked `.meta.yaml` (8/11 had it). Per-agent rollout tracked as incremental follow-up (**ADR-011**), one agent per ADR, mirroring the [[handoff-contract]] rollout. `sentinel`'s completion is human-only (NFR-SEC-1 carve-out — the convention *documents* this, never edits sentinel).

**Tool-scope ownership — gap now closing (cycle 7, human-directed, outside the loop).** For six cycles `least-privilege-tool-scopes` sat **deferred** (score 66): in the-owl's inline, non-subagent execution model (ADR-010) a "Forbidden Tools" section would have been *unenforceable prose* with a false-confidence risk — the same failure class as the rejected `isolated-workspaces`. In cycle 7 the scout verified that `tools:` / `disallowedTools:` are **real, harness-enforced** subagent frontmatter fields, and the branch `owl/agents-native-subagents` adds native `.claude/agents/*.md` subagents **with** enforced `tools:` scoping (hybrid: native subagents + command personas). The deferral blocker (no way to enforce per-agent tool scope) is therefore being removed — but by **owner direction, not by `/owl:evolve`**. The tight-tool-list slice on `sentinel` / `guardian` / `challenger` is **NFR-SEC-1 carve-out**: the loop never edits those three; the migration scoped them by human hand.

**Trade-off.** Narrowing roles is not free. (1) **Over-decomposition tax** — too many sharp roles multiplies handoffs and coordination overhead; [[anthropic-building-effective-agents]]' "maintain simplicity" is the counter-pressure (a few sharp agents beat both many overlapping *and* too-many-thin ones). (2) **Convention-first has deferred impact** — a role convention not yet rolled into every agent only pays once the rollout lands (the standing challenger caveat on both ADR-009 and ADR-004). (3) **Enforceability gap between prose and harness** — an ownership boundary written only in the `.md` body is advisory; the value multiplies when it is a machine-checked field (`.meta.yaml`, or now harness-enforced `tools:`). Prose-only scoping that *reads* like a guarantee but isn't enforced carries a false-confidence risk — the explicit reason tool-scoping stayed deferred until the harness could enforce it.

## Related
- [[role-ownership]] · [[handoff-contract]] · [[context-engineering]] · [[overview]] · [[ledger]]
