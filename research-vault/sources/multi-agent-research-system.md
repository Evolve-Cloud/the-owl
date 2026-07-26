---
title: "Anthropic — How We Built Our Multi-Agent Research System"
type: source
tags: [multi-agent, research, orchestrator-worker, extended-thinking, production, evals]
sources: 1
updated: 2026-07-26
---
**Source:** [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Jeremy Hadfield, Barry Zhang, Kenneth Lien, Florian Scholz, Jeremy Fox, Daniel Ford (Anthropic)  ·  **Published:** 2025-06-13  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Anthropic's multi-agent research system achieves a 90.2% performance improvement over single-agent Claude Opus 4 by using an orchestrator-worker pattern where a lead agent decomposes queries and spawns specialized subagents for parallel investigation. Token usage explains 80% of performance variance. Production reliability required stateful error handling, full tracing, and rainbow deployments.

## Key points
- 90.2% performance improvement over single-agent on internal research evaluation.
- Token usage explains 80% of performance variance; multi-agent uses ~15x more tokens than standard chat.
- Orchestrator-worker pattern: lead agent (Opus 4) decomposes queries, spawns Sonnet 4 subagents for parallel investigation.
- Parallel tool execution cut research time by up to 90%.
- LLM-as-judge evaluation: judges assess outputs against rubrics (accuracy, citations, completeness) — more scalable than programmatic evaluation for free-form research text.
- Stateful error handling: resume from where agents failed, not restart; combines adaptive AI + deterministic retry + checkpoints.
- Rainbow deployments for stateful agent-system updates (avoids disrupting in-flight sessions).
- Economic constraint: multi-agent demands high-value tasks; unsuitable for parallelization-poor domains like most coding.

## Informs (ideas / patterns)
- [[agent-architectures]] — orchestrator-worker pattern; subagent filesystem output; stateful error handling; rainbow deployments; token-as-performance-driver.
- [[evals]] — LLM-as-judge at scale; end-state evaluation for multi-turn state-mutating workflows.
- [[context-engineering]] — token budget as performance variable; parallel tool execution for latency reduction.

## Notable quotes
> "Token usage by itself explains 80% of the variance" in browsing agent performance.
> "The gap between prototype and production is often wider than anticipated."

## Gaps / open questions
- How do you balance token consumption with cost for tasks that are valuable but not high-margin?
- What failure modes emerge when subagents contradict each other's findings?

## Related
- [[agent-architectures]] · [[anthropic-building-effective-agents]] · [[harness-design-long-running-apps]] · [[effective-harnesses-long-running]] · [[claude-think-tool]]
