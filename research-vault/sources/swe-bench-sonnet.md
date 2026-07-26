---
title: "Anthropic — Raising the Bar on SWE-bench Verified with Claude 3.5 Sonnet"
type: source
tags: [swe-bench, agentic-coding, scaffolding, tool-design, benchmarks, evals]
sources: 1
updated: 2026-07-26
---
**Source:** [Raising the bar on SWE-bench Verified with Claude 3.5 Sonnet](https://www.anthropic.com/engineering/swe-bench-sonnet) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Erik Schluntz; contributors Simon Biggs, Dawn Drain, Eric Christiansen, Shauna Kravec, Felipe Rosso, Nova DasSarma, Ven Chandrasekaran (Anthropic)  ·  **Published:** 2025-01-06  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Claude 3.5 Sonnet achieves 49% on SWE-bench Verified (up from 45%) through carefully designed agentic scaffolding. The key insight: agent performance depends substantially on the scaffolding — prompts, output parsing, interaction loops — not just the model. Two minimal tools (Bash and Edit) with detailed descriptions give the model autonomy rather than constraining it to rigid workflows.

## Key points
- 49% on SWE-bench Verified, surpassing the previous SOTA of 45%.
- Performance depends substantially on scaffolding even with the same underlying model.
- Minimal, flexible design: just two tools (Bash and Edit) with detailed descriptions; model autonomy over predetermined step sequences.
- Considerable effort went into refining tool descriptions to preempt misunderstandings — treated as carefully as human-facing software interfaces.
- Error-proofing: requiring absolute file paths prevents a common mistake after directory changes.
- Successful resolution often requires hundreds of turns and 100,000+ tokens.

## Informs (ideas / patterns)
- [[evals]] — SWE-bench Verified as a human-reviewed benchmark; scaffolding impact on benchmark scores.
- [[tool-use]] — two-tool minimal design as reference implementation; tool-schema design; absolute-path enforcement.
- [[agent-architectures]] — scaffolding as a first-class variable; self-correction as agent behavior.

## Notable quotes
> "The performance of an agent on SWE-bench can vary significantly based on this scaffolding, even when using the same underlying AI model."

## Gaps / open questions
- What scaffolding changes would push past the 50% threshold?
- How should benchmarks account for scaffolding variation in reported scores?

## Related
- [[evals]] · [[tool-use]] · [[anthropic-building-effective-agents]] · [[writing-tools-for-agents]] · [[agent-architectures]]
