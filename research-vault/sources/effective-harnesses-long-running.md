---
title: "Anthropic — Effective Harnesses for Long-Running Agents"
type: source
tags: [harness-design, long-running-agents, context-engineering, agent-architectures, memory]
sources: 1
updated: 2026-07-26
---
**Source:** [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Justin Young; contributors David Hershey, Prithvi Rajasakeran, Jeremy Hadfield, Naia Bouscal, Michael Tingley, Jesse Mu, and others (Anthropic)  ·  **Published:** 2025-11-26  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Long-running agents working across multiple context windows face a fundamental challenge: each new session starts with no memory of prior work. A two-part harness solution — an initializer agent that scaffolds the environment and a coding agent that makes incremental progress — plus git-based state persistence and browser-automation tools dramatically improves multi-session agent continuity.

## Key points
- Core problem: each new context window begins with no memory of prior work — like engineers working shifts with no handoff documentation.
- Two-part solution: initializer agent (first session, sets up environment and feature list) + coding agent (subsequent sessions, incremental progress, clean state).
- Feature-list file: JSON with 200+ feature descriptions initially marked "failing" — prevents agents from declaring premature victory.
- Git practices: committing progress with descriptive messages enables agents to track changes, revert mistakes, and provide clear handoffs.
- Session startup protocol: read progress files → review git log → run basic tests → select next feature.
- End-to-end testing: providing Puppeteer MCP dramatically improved feature verification vs. code review alone.

## Informs (ideas / patterns)
- [[agent-architectures]] — initializer-agent pattern; multi-context-window workflows; git as agent-state persistence.
- [[context-engineering]] — multi-session context recovery; progress files as structured memory.
- [[compaction]] — complementary technique; article notes context resets vs. progressive handoffs.

## Notable quotes
> "Each new session begins with no memory of what came before."
> "Inspiration for these practices came from knowing what effective software engineers do every day."

## Gaps / open questions
- Does a single general-purpose agent outperform multi-agent with specialized roles (testing, QA, cleanup)?
- What's the optimal session length before a context reset is beneficial?

## Related
- [[agent-architectures]] · [[harness-design-long-running-apps]] · [[context-engineering]] · [[compaction]] · [[building-c-compiler]]
