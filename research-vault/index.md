---
title: Research Vault — Index
type: index
tags: []
updated: 2026-07-26
---

# the-owl Research Vault — Master Index

External-research knowledge base for **agent-team engineering**. See [[SCHEMA]] for conventions and workflows. Separate from the internal `docs/wiki/`.

## Status
- **Cycles run:** 6 (2026-07-23 cycle 1; 2026-07-23b continuation → PR #2; 2026-07-24 cycle 3 → PR #3; 2026-07-24b human-directed rollout completion; 2026-07-26 cycle 4 scheduled → mid-cycle checkpoint / ADR-016 via PR #4; 2026-07-26 human-directed backlog score pass → ADR-017)
- **Decided:** 35 (8 accepted, 3 rejected, 24 deferred) — see [[ledger]]
- **Sources:** 51 pages (see below). Two 2026-07-26 tracks — the scheduled cycle 4 (fresh brief; +2 source notes) and the human-directed read-in-full backlog score pass. +1 human-directed 2026-07-29 (spec MCP v2026-07-28).
- **Synthesis:** see [[overview]]

> [!note]
> The 24 read-in-full sources imported 2026-07-26 were **scored on 2026-07-26** (Cycle 4, score-only): **0 new accepts** at score-time, **3 net-new deferred**, the rest deduped/corroborated. **Then (human-directed integrate)** `convention-staleness-review` was promoted **deferred → accepted (82)** and integrated as **[[convention-staleness-review]] / ADR-017** (working-tree, gate-then-owner-lands). Remaining deferred: `just-in-time-context-loading`, `eval-saturation-graduation`. Full map in [[ledger]]; synthesis in [[overview]].

## Sources

**51 source notes in `sources/`.** Tiers: **25 read-in-full** pages (full summary, key points, quotes, gaps), **24 brief-materialized** stubs (one line per codex-brief source, awaiting a full read), and **2 from the scheduled cycle 4** (2026-07-26).

### Read-in-full — human-directed 2026-07-29

- [[mcp-architecture-spec-2026-07-28]] — MCP Architecture spec v2026-07-28 (modelcontextprotocol.io): stateless `_meta`, `server/discover`, `title` em tools, sampling/logging **deprecated**, `subscriptions/listen` para notificações opt-in. Aplicado diretamente ao agente `mcp-builder`.

### Read-in-full (24) — imported 2026-07-26

**Agent design & orchestration**
- [[anthropic-building-effective-agents]] — Building Effective Agents
- [[multi-agent-research-system]] — How We Built Our Multi-Agent Research System
- [[scaling-managed-agents]] — Scaling Managed Agents (decoupling brain from hands)
- [[building-c-compiler]] — Building a C Compiler with a Team of Parallel Claudes
- [[anthropic-agent-skills]] — Equipping Agents for the Real World with Agent Skills

**Context engineering & retrieval**
- [[effective-context-engineering]] — Effective Context Engineering for AI Agents
- [[anthropic-contextual-retrieval]] — Introducing Contextual Retrieval

**Tools & MCP**
- [[writing-tools-for-agents]] — Writing Effective Tools for Agents — With Agents
- [[advanced-tool-use]] — Introducing Advanced Tool Use
- [[code-execution-mcp]] — Code Execution with MCP
- [[claude-think-tool]] — The 'Think' Tool
- [[desktop-extensions]] — Desktop Extensions

**Harnesses & long-running agents**
- [[effective-harnesses-long-running]] — Effective Harnesses for Long-Running Agents
- [[harness-design-long-running-apps]] — Harness Design for Long-Running Application Development
- [[claude-code-best-practices]] — Best Practices for Claude Code
- [[claude-code-auto-mode]] — Claude Code Auto Mode
- [[claude-code-sandboxing]] — Beyond Permission Prompts (sandboxing)

**Evaluation**
- [[anthropic-demystifying-evals]] — Demystifying Evals for AI Agents
- [[ai-resistant-technical-evals]] — Designing AI-Resistant Technical Evaluations
- [[eval-awareness-browsecomp]] — Eval Awareness in Claude Opus 4.6's BrowseComp Performance
- [[infrastructure-noise-evals]] — Quantifying Infrastructure Noise in Agentic Coding Evals
- [[swe-bench-sonnet]] — Raising the Bar on SWE-bench Verified

**Workflow & forecasting** _(the carinhAI `Engineering/AI/` library)_
- [[spdd-structured-prompt-driven-development]] — Structured Prompt-Driven Development (Fowler/Thoughtworks)
- [[ai-2027]] — AI 2027 superhuman-AI scenario forecast

### Brief-materialized (24) — from the codex briefs (2026-07-24)
Multi-agent framework & research landscape, one page per codex-brief source, awaiting a full read:
[[metagpt]] · [[langgraph]] · [[crewai]] · [[microsoft-autogen]] · [[openhands]] · [[swe-agent]] · [[ag2]] · [[openai-swarm]] · [[openai-agents-sdk-handoffs]] · [[openai-agents-sdk-orchestration]] · [[openai-agents-sdk-guardrails]] · [[langgraph-multi-agent-handoffs]] · [[langgraph-persistence]] · [[metagpt-paper]] · [[magentic-one-paper]] · [[react-paper]] · [[swe-agent-paper]] · [[wshobson-agents]] · [[claude-code-subagents]] · [[claude-code-agent-teams]] · [[claude-code-worktrees]] · [[claude-agent-sdk-subagents]] · [[claude-agent-sdk-typescript]] · [[claude-platform-cli-sdks]]

### Scheduled cycle 4 (2026-07-26)
Fresh-research sources from the scheduled `/owl:evolve` cycle: [[anthropic-trustworthy-agents]] · [[swe-debate-paper]] (+ enriched [[anthropic-demystifying-evals]]).

### Raw ingest (immutable, `inbox/`)
- [[research-brief-2026-07-23]] — codex brief (cycle 1): 8 sources, 9 ideas.
- [[scout-notes-2026-07-23]] — scout live research (cycle 1): w1–w4.
- [[research-brief-2026-07-24]] — codex brief (cycle 2): 22 sources, 16 ideas.
- [[scout-notes-2026-07-24]] — scout live research (cycle 2): x1–x5.
- [[research-brief-2026-07-26]] — codex brief (cycle 4): 15 sources, 12 ideas.
- [[scout-notes-2026-07-26]] — scout live research (cycle 4): x1–x3, all independently verified real.

## Patterns
- [[role-decomposition]] — roles / ownership boundaries (cycle 2).
- [[context-engineering]] — context rot, attention budget, just-in-time retrieval, progressive disclosure, long-horizon memory (added 2026-07-26; grounded in ~10 read-in-full primaries).
- _communication / handoff — captured in [[handoff-contract]] + `docs/conventions/handoff-contract.md` (dedicated pattern page: lint follow-up)._

## Ideas
- [[handoff-contract]] — **accepted (91)** → ADR-004.
- [[handoff-contract-rollout]] — **accepted (94)** → ADR-006/007/008 (architect/builder/chronicler). The queued ADR-004 follow-up, grounded via L1.5 (ADR-005).
- [[role-ownership]] — **accepted (87)** → ADR-009 (promotes previously-deferred `explicit-role-boundaries`).
- [[convention-staleness-review]] — **accepted (82)** → ADR-017 (curator re-examines old conventions as models improve; impact provisional). Same-day promotion from deferred.
- [[externalized-checkpoint-memory]] — **accepted, provisional (75)** → ADR-016 (mid-cycle checkpoint for `/owl:evolve`; scored 83 raw, self-haircut per ADR-015).
- [[handoff-contract-uncertainty-fields]] — **accepted, provisional (78)** → ADR-020 (adds assumptions / open-questions / evidence-confidence fields to the handoff contract; extends ADR-004, doesn't re-litigate it).
- [[isolated-workspaces-for-parallel-coding]] — **rejected (41)** — runtime-shaped, low fit.
- [[trajectory-evals]] — **rejected (58)** — its own best-cited source, read in full, argues the opposite framing; the-owl's fitness harness already does the better-supported version.
- Others deferred; see [[ledger]].

## Sections
- [[overview]] — evolving synthesis: how to build the best agent team
- [[ledger]] — the decision ledger (dedup source of truth)
- [[log]] — chronological cycle log
