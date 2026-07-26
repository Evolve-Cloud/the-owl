---
title: Overview — How to Build the Best Agent Team
type: overview
tags: []
sources: 48
updated: 2026-07-26
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

## Cycle 2026-07-26 — read-in-full library corroborates the baseline (0 new accepts)
Scoring the 24 **read-in-full** primary sources (Anthropic engineering blogs + the carinhAI docs) against the real code produced **no new accepted change** — and that is the signal, not a gap. These deep sources overwhelmingly **corroborate** decisions the-owl already made from the thinner cycle-1/2 briefs, now on far stronger evidence:
- **Context-minimal is right, and central.** [[effective-context-engineering]] names the mechanism (context rot, the n² attention budget, just-in-time retrieval, progressive disclosure). the-owl's `handoff-contract` (ADR-004, "paths not history") already *is* this at the handoff boundary → the `just-in-time-context-loading` candidate **dedups**. New pattern page: [[context-engineering]].
- **Hub-and-spoke + evaluator-gate confirmed.** [[anthropic-building-effective-agents]] ("start simple; frameworks obscure logic"; evaluator-optimizer) and [[multi-agent-research-system]] re-anchor the-owl's core invariants — not re-adopted.
- **New caution — multi-agent economics.** [[multi-agent-research-system]]: multi-agent is expensive and "unsuitable for parallelization-poor domains like most coding." A live check on the-owl's own hub-spoke ambitions: reserve fan-out for genuinely parallelizable, high-value work.
- **Impact-as-hypothesis reinforced.** [[harness-design-long-running-apps]] + [[scaling-managed-agents]]: "every harness component encodes an assumption about what the model can't do," and those assumptions **go stale as models improve** — the empirical backbone of ADR-015 and the new deferred `convention-staleness-review`.
- **Low fit for a markdown-only lib (noted, not adopted):** sandboxing, auto-mode, MCP packaging, advanced tool use, code execution, think-tool, eval-infra noise / eval-awareness — real depth, but runtime/tooling/eval-infra shaped; they enrich the picture, not the conventions.

## Grounding insight (L1.5, ADR-005)
Scoring against the real code revealed ownership is *already* encoded but **unevenly**: 8/11 agents have `.meta.yaml` (`responsibilities`/`constraints`/`outputs`/`should_delegate_to`); **scout, curator, sentinel lack it**. The convention standardizes the pattern and surfaces this inconsistency (sentinel's fix is human-only — NFR-SEC-1 carve-out).

## Open fronts (deferred ideas to pressure-test next cycles)
- **Rollout:** roll the handoff contract *and* the role-ownership convention into each agent (incremental, 1/ADR); add missing `.meta.yaml` to scout/curator (sentinel = human).
- Least-privilege tool scopes per agent (near-threshold 78; deserves a careful, security-adjacent cycle).
- Evidence-log / provenance convention (ReAct-style) · durable-artifact classes · extend the ADR template for prompt-surface changes.
- Concrete 2026 frontmatter fields (`maxTurns`, `Memory`, `isolation`) — applicability to slash-command agents needs care.
- **Accepted 2026-07-26 → ADR-016:** [[convention-staleness-review]] — the curator now re-examines the oldest accepted conventions each cycle and flags any that a stronger model made redundant for owner-reviewed re-fitness (the inverse of ADR-012's rollout-coverage view; never auto-reverts). Impact provisional until it flags its first stale convention.
- **Still deferred (2026-07-26):** `just-in-time-context-loading` (core dedups to `handoff-contract`; revisit if a concrete gap appears); `eval-saturation-graduation` — graduate saturated capability evals into the regression suite (`eval/`, ADR-014).

## Sources
This synthesis is grounded in **48** source notes (`sources/`) — 24 read-in-full (imported 2026-07-26; see [[index]] for the themed list) + the 25 brief-materialized notes below. By type:
- **Primary guidance:** [[anthropic-building-effective-agents]]
- **Claude / Agent SDK:** [[claude-code-subagents]] · [[claude-code-agent-teams]] · [[claude-code-worktrees]] · [[claude-agent-sdk-subagents]] · [[claude-agent-sdk-typescript]] · [[claude-platform-cli-sdks]]
- **OpenAI / LangGraph docs:** [[openai-agents-sdk-orchestration]] · [[openai-agents-sdk-handoffs]] · [[openai-agents-sdk-guardrails]] · [[langgraph-multi-agent-handoffs]] · [[langgraph-persistence]]
- **Frameworks (repos):** [[metagpt]] · [[openhands]] · [[swe-agent]] · [[microsoft-autogen]] · [[crewai]] · [[langgraph]] · [[openai-swarm]] · [[ag2]] · [[wshobson-agents]]
- **Papers:** [[metagpt-paper]] · [[magentic-one-paper]] · [[swe-agent-paper]] · [[react-paper]]

## Related
- [[SCHEMA]] · [[ledger]] · [[index]] · [[handoff-contract]] · [[role-ownership]] · [[role-decomposition]] · [[context-engineering]]
