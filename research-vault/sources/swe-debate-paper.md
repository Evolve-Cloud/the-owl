---
title: "SWE-Debate: Competitive Multi-Agent Debate for Software Issue Resolution"
type: source
tags: []
sources: 1
updated: 2026-07-26
---
**Source:** [SWE-Debate (arXiv:2507.23348)](https://arxiv.org/abs/2507.23348) · **Type:** paper · **Stars/credibility:** n/a · primary
**Author / Org:** Li, Shi, Lin, Gu, Lian, Wang, Jia, Huang, Wang  ·  **Published:** 2025-07-31  ·  **Ingested:** 2026-07-26

## Summary
Proposes a competitive multi-agent debate framework for software issue localization: builds a static code dependency graph (calls/inheritance/imports/refs), generates multiple candidate fault-propagation traces from it, then runs a 3-round debate among agents each arguing a different trace before consolidating on one issue localization. Verified real via WebSearch (not fabricated) — cross-listed cs.SE/cs.CL/cs.LG, code at github.com/YerbaPage/SWE-Debate, already cited by follow-up papers (Free-MAD, SWE-Exp).

## Key points
- Independent single-agent exploration gets stuck in local solutions and misses cross-file issue patterns — the motivating problem.
- Debate is structured (graph-guided traces + fixed rounds), not free-form multi-turn chat — each agent's position is grounded in a specific dependency-graph path.
- This is a localization/verification technique for a narrow coding task, not a general team-topology pattern.

## Informs (ideas / patterns)
- [[trajectory-evals]] — weak evidence for this idea specifically; the paper is about debate-based localization accuracy, not eval methodology. Cited by the brief but the connection is indirect (multiple reasoning traces ≈ multiple trajectories to grade).
- `evaluator-optimizer-loop` (deferred, no dedicated page — see [[ledger]]) — debate-as-verification is a variant, but the-owl is single-pass hub-spoke (ADR-001), not a debate topology; applicability is conceptual (structured disagreement surfaces errors) not literal (the-owl won't run N agents debating).

## Gaps / open questions
- No public benchmark numbers were surfaced in this check (would need the PDF for SWE-bench scores); treat "competitive debate improves localization" as the paper's claim, not independently verified here.
- Applicability to the-owl is low (2-3/5): the-owl has no runtime for parallel debating agents (hub-spoke, single specialist per phase, ADR-001) — the transposable sliver is narrow.

## Related
[[research-brief-2026-07-26]] · [[swe-agent-paper]]
