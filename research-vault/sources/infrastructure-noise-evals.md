---
title: "Anthropic — Quantifying Infrastructure Noise in Agentic Coding Evals"
type: source
tags: [evals, benchmarks, infrastructure, agentic-coding, measurement]
sources: 1
updated: 2026-07-26
---
**Source:** [Quantifying Infrastructure Noise in Agentic Coding Evals](https://www.anthropic.com/engineering/infrastructure-noise) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Gian Segato; contributors Nicholas Carlini, Jeremy Hadfield, Mike Merrill, Alex Shaw (Anthropic)  ·  **Published:** 2026  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Infrastructure configuration alone can swing agentic coding benchmark scores by 6+ percentage points — often more than the gap between top-ranked models. The article systematically studies how container resource limits, enforcement methodology, and hidden environmental variables introduce "infrastructure noise" that makes leaderboard differences unreliable signals of true capability.

## Key points
- Terminal-Bench 2.0 scores varied by 6 percentage points (p < 0.01) based solely on infrastructure configuration — exceeding typical leaderboard margins between top models.
- A "sweet spot" exists around 3x resource headroom: infra errors drop from 5.8% to 2.1% without inflating success rates; beyond 3x, agents unlock computationally expensive strategies that change what the benchmark measures.
- Container enforcement methodology matters: treating per-task resource specs as both floor and ceiling causes spurious OOM kills inflating error rates.
- Different models use fundamentally different solution approaches, making scores model-dependent artifacts of configuration.
- SWE-bench shows smaller but consistent resource sensitivity (1.54 pp at 5x RAM), confirming this is cross-benchmark.
- Hidden confounders stack: time of day (API latency), cluster health, and concurrency add noise beyond resource allocation.

## Informs (ideas / patterns)
- [[evals]] — introduces "infrastructure noise" as a distinct evaluation-validity threat; 3x headroom sweet spot; resource-enforcement methodology.
- [[agent-architectures]] — shows that agent solution strategies vary by model, affecting benchmark generalizability.

## Notable quotes
> "A 2-point lead on a leaderboard might reflect a genuine capability difference, or infrastructure luck."
> "Two agents with different resource budgets and time limits aren't taking the same test."

## Gaps / open questions
- What standardized infrastructure-documentation format should benchmarks adopt?
- Is the 3x headroom sweet spot transferable across cloud providers and hardware?

## Related
- [[evals]] · [[anthropic-demystifying-evals]] · [[eval-awareness-browsecomp]] · [[building-c-compiler]]
