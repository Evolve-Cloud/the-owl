---
title: "Anthropic — The 'Think' Tool: Enabling Claude to Stop and Think in Complex Tool Use Situations"
type: source
tags: [think-tool, extended-thinking, tool-use, reasoning, agents, benchmarks]
sources: 1
updated: 2026-07-26
---
**Source:** [The 'think' tool: Enabling Claude to stop and think in complex tool use situations](https://www.anthropic.com/engineering/claude-think-tool) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Anthropic Engineering  ·  **Published:** 2025-03-20  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
A dedicated "think" tool — a no-op tool that provides a scratchpad for mid-response reasoning — significantly improves Claude's performance on complex tool-use scenarios. Unlike extended thinking (which happens before response generation), the think tool activates after response generation begins, allowing Claude to pause and reassess while processing tool outputs. On τ-bench airline domain, the think tool with optimized prompting achieved a 54% relative improvement.

## Key points
- Distinct from extended thinking: operates after response generation begins, useful specifically when processing tool outputs between sequential calls.
- τ-bench airline domain: 54% relative improvement (0.570 vs. 0.370 baseline pass¹ scores) with optimized prompting.
- τ-bench retail domain: 0.812 pass¹ without additional prompting, outperforming extended thinking (0.770).
- SWE-bench: contributed to Claude 3.7 Sonnet's 0.623 SOTA score; 1.6% isolated improvement (statistically significant).
- Benefits persisted through pass^k measurements (k=5), indicating improved edge-case handling and consistency.
- Best practice: place detailed "think" guidance in system prompts, not tool descriptions.

## Informs (ideas / patterns)
- [[think-tool]] — foundational description; distinction from extended thinking; optimal use cases; implementation pattern.
- [[tool-use]] — reasoning integration during multi-step tool use; pass^k metric for consistency; τ-bench benchmark.
- [[evals]] — pass^k as a consistency metric; τ-bench as a tool-use evaluation framework.

## Notable quotes
> "It doesn't change external behavior unless Claude decides to use it, and doesn't interfere with your existing tools."

## Gaps / open questions
- How does the think tool interact with parallel tool execution (where sequential reasoning may not apply)?
- When does adding a think tool become counterproductive (too many reasoning steps)?

## Related
- [[think-tool]] · [[tool-use]] · [[advanced-tool-use]] · [[writing-tools-for-agents]] · [[anthropic-building-effective-agents]]
