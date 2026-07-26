---
title: "Anthropic — Effective Context Engineering for AI Agents"
type: source
tags: [context-engineering, agents, prompt-engineering, long-horizon]
sources: 1
updated: 2026-07-26
---
**Source:** [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Prithvi Rajasekaran, Ethan Dixon, Carly Ryan, Jeremy Hadfield (Anthropic Applied AI)  ·  **Published:** 2026 (Sonnet 4.5 era)  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Anthropic's Applied AI team defines context engineering as the natural evolution beyond prompt engineering — the art of curating the optimal set of tokens at each inference step. As agents operate in loops over long horizons, managing the entire context state (not just system prompts) becomes the central engineering challenge. The piece covers foundational theory, system-prompt design, tool design, just-in-time retrieval, and three techniques for long-horizon tasks.

## Key points
- **Context engineering** = strategies for curating and maintaining the optimal token set during LLM inference, including system prompts, tools, MCP, external data, and message history.
- **Context rot**: as token count grows, recall accuracy degrades — context is a finite resource with diminishing marginal returns.
- **Attention budget**: transformer architecture creates n² pairwise relationships; every token depletes the attention budget.
- **System prompt altitude**: the "right altitude" avoids both brittle hardcoded if-else logic and vague high-level guidance.
- **Just-in-time retrieval**: agents maintain lightweight identifiers (file paths, queries, URLs) and load data at runtime rather than pre-loading everything.
- **Long-horizon techniques**: three complementary approaches — compaction, structured note-taking, sub-agent architectures.
- **Compaction**: summarize context near the window limit, reinitiate with the summary; preserve architectural decisions and implementation details, discard redundant tool outputs.

## Informs (ideas / patterns)
- [[context-engineering]] — foundational definition, contrast with prompt engineering, context rot, attention budget.
- [[agent-architectures]] — just-in-time retrieval, progressive disclosure, sub-agent pattern.
- [[compaction]] — primary technique introduced here in detail.
- [[managed-agents]] — cross-reference: compaction and note-taking are implemented in Managed Agents.

## Notable quotes
> "Find the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."
> "Context, therefore, must be treated as a finite resource with diminishing marginal returns."
> "If a human engineer can't definitively say which tool should be used in a given situation, an AI agent can't be expected to do better."

## Gaps / open questions
- How do you tune the compaction prompt for a specific domain? What evaluation methodology?
- At what token count does context rot become empirically significant?

## Related
- [[scaling-managed-agents]] · [[context-engineering]] · [[compaction]] · [[agent-architectures]] · [[anthropic]]
