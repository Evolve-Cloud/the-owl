---
title: Role decomposition & ownership boundaries
type: pattern
tags: [roles, structure]
updated: 2026-07-24
---

## Definition
How a multi-agent team divides work into **narrow, single-owner roles** so responsibilities do not overlap. Each agent owns a distinct slice (decision rights + a single output artifact), explicitly declares what it does **not** own (and who does), and has verifiable entry/done criteria.

## Key ideas
- **Single responsibility per agent.** One clear job beats a pile of overlapping agents (Anthropic best-practices, PubNub).
- **Explicit non-ownership.** The failure mode of vague roles is duplicated work / endless task-passing / conflicting recommendations (CrewAI 2026). Naming the *forbidden overlap → owner* is what prevents it.
- **Manager retains control.** A central orchestrator owns planning + integration; specialists are bounded capabilities that return control (hub-and-spoke). Distinct from peer handoff where control moves permanently.
- **Ownership is structured, not just prose.** Best expressed as machine-readable fields (responsibilities / constraints / outputs / delegation) alongside the human-readable role text.

## Evidence / sources
- [[scout-notes-2026-07-24]] — live corroboration (x1 PubNub, x3 Anthropic, x4 CrewAI/MetaGPT).
- codex [[research-brief-2026-07-24]] — ideas `narrow-single-owner-roles`, `manager-retains-control`, `directed-handoff-graph`, `sop-as-executable-contract`.
- **Sources:** [[anthropic-building-effective-agents]] · [[claude-code-subagents]] · [[metagpt]] · [[metagpt-paper]] · [[openai-agents-sdk-orchestration]] · [[magentic-one-paper]] · [[crewai]] · [[langgraph]].

## How it maps to the-owl
the-owl already embodies much of this: hub-and-spoke, "specialists never call each other", per-agent `🎯 Minha Responsabilidade` / `⛔ NUNCA FAÇA` / `⚠️ Quando NÃO me usar`, and `.meta.yaml` `responsibilities`/`constraints`/`outputs`/`should_delegate_to`. **Gaps found (L1.5):** (1) no convention names this as the standard; (2) `scout`, `curator`, `sentinel` lack `.meta.yaml` (8/11 have it). → Adopted `docs/conventions/role-ownership.md` (ADR-009). sentinel's completion is human-only (NFR-SEC-1 carve-out).

## Related
- [[role-ownership]] · [[handoff-contract]] · [[overview]]
