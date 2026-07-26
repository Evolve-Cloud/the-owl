---
title: "Anthropic — Writing Effective Tools for Agents — With Agents"
type: source
tags: [tool-use, tool-design, mcp, agents, evals, aci]
sources: 1
updated: 2026-07-26
---
**Source:** [Writing effective tools for agents — with agents](https://www.anthropic.com/engineering/writing-tools-for-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Ken Aizawa; contributors Barry Zhang, Zachary Witten, Daniel Jiang, and a large Anthropic team  ·  **Published:** 2025-09-11  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Tools are a new kind of software — contracts between deterministic implementations and non-deterministic agents. The prototype-evaluate-improve cycle, using realistic multi-step evaluations and agent-assisted transcript analysis, is the systematic path to tools that actually work well. The most ergonomic tools for agents also tend to be surprisingly intuitive for humans.

## Key points
- Tools differ from traditional APIs: they establish contracts with non-deterministic agents that may hallucinate or misunderstand usage.
- Prototype-evaluate-improve cycle: quick prototype → comprehensive evaluations with realistic multi-step tasks → agent-assisted refinement.
- Fewer intentional tools outperform numerous overlapping implementations: tools should consolidate related operations.
- Namespacing for clarity: consistent naming conventions help agents navigate hundreds of tools across multiple servers.
- Context-efficient responses: prioritize semantic relevance over technical details; exclude UUIDs in favor of human-interpretable names.
- Description as steering mechanism: tool descriptions function as prompt engineering — precise, unambiguous language measurably improves utilization.
- ResponseFormat enum pattern: parameterized response verbosity for agent-controlled output compression.

## Informs (ideas / patterns)
- [[tool-use]] — ACI (agent-computer interface) design principles; prototype-evaluate-improve cycle; tool affordances; description-as-prompt-engineering.
- [[evals]] — evaluation-driven tool development; realistic multi-step task evals; transcript analysis.
- [[mcp]] — multi-server tool management; namespacing conventions.

## Notable quotes
> "Tools are a new kind of software which reflects a contract between deterministic systems and non-deterministic agents."
> "Think about how much effort goes into human-computer interfaces (HCI), and plan to invest just as much effort in creating good agent-computer interfaces (ACI)."
> "More tools don't always lead to better outcomes."

## Gaps / open questions
- How do you evaluate tool usability when the agent's behavior is inherently non-deterministic?
- What's the right level of abstraction for tools — atomic operations or higher-level workflows?

## Related
- [[tool-use]] · [[advanced-tool-use]] · [[anthropic-building-effective-agents]] · [[context-engineering]] · [[mcp]]
