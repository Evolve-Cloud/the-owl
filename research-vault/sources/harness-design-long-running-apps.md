---
title: "Anthropic — Harness Design for Long-Running Application Development"
type: source
tags: [harness-design, multi-agent, evals, context-engineering, generator-evaluator, long-running-agents]
sources: 1
updated: 2026-07-26
---
**Source:** [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Prithvi Rajasekaran (Anthropic Labs)  ·  **Published:** 2026-03-24  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Complex, long-running coding tasks are dramatically improved by a GAN-inspired multi-agent harness that separates generation from evaluation. The article documents a harness where a generator agent builds applications and an evaluator agent tests them via Playwright — running 5-15 iterations per sprint with explicit "sprint contracts" defining testable success criteria. Model-specific scaffolding matters: Sonnet 4.5 required context resets and compaction; Opus 4.6 made those components unnecessary.

## Key points
- Self-evaluation fails: models reliably skew positive when grading their own work; a separate evaluator agent makes skepticism tractable.
- "Context anxiety" on Sonnet 4.5: models prematurely wrap up work as they approach context limits; complete context resets with structured handoffs outperformed in-place compaction.
- Sprint contracts: pre-implementation agreements between generator and evaluator defining deliverables and testable success criteria.
- Generator-evaluator loop: evaluator navigates live interfaces via Playwright, identifies failures, returns detailed critiques — 5-15 iterations per sprint.
- Model-specific scaffolding: Opus 4.6's improvements made several Sonnet 4.5 scaffolding components unnecessary.
- Cost-quality tradeoffs: 6-hour/$200 full-harness run vs. 20-minute/$9 solo run — full-harness produced actually functional core features.
- "Every component in a harness encodes an assumption about what the model can't do."

## Informs (ideas / patterns)
- [[agent-architectures]] — GAN-inspired generator-evaluator pattern; sprint contracts; model-specific scaffolding.
- [[context-engineering]] — context anxiety; context-reset vs. compaction tradeoffs per model.
- [[evals]] — design-criteria calibration; evaluator-as-quality-gate pattern.
- [[compaction]] — context resets vs. compaction; when compaction is suboptimal.

## Notable quotes
> "Agents reliably skew positive when grading their own work... the separation doesn't immediately eliminate that leniency on its own."
> "Every component in a harness encodes an assumption about what the model can't do... assumptions are worth stress testing."

## Gaps / open questions
- Does context anxiety appear in other model families, or is it specific to certain training regimes?
- At what capability level does the evaluator become redundant?

## Related
- [[agent-architectures]] · [[effective-harnesses-long-running]] · [[compaction]] · [[anthropic-demystifying-evals]] · [[multi-agent-research-system]]
