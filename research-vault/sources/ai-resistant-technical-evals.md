---
title: "Anthropic — Designing AI-Resistant Technical Evaluations"
type: source
tags: [evals, hiring, ai-resistance, benchmarks, technical-interviews]
sources: 1
updated: 2026-07-26
---
**Source:** [Designing AI-resistant technical evaluations](https://www.anthropic.com/engineering/AI-resistant-technical-evaluations) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Tristan Hume (Anthropic performance optimization team)  ·  **Published:** 2026-01-21  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Anthropic's performance-engineering take-home interview required three major redesigns as successive Claude versions matched or exceeded human performance within allotted time windows. The article documents each redesign and the core tension: as AI capabilities improve, technical evaluations must shift away from realistic problem-solving toward novelty, constraint-heavy puzzles, or sufficiently extended time horizons where human expertise still holds an advantage.

## Key points
- Claude Opus 4 defeated the original take-home; Opus 4.5 matched elite human performance within 2 hours, forcing a redesign.
- Version 1→2→3 progression: shortened deadlines, removed solved components, then abandoned realism entirely for a Zachtronics-inspired constraint puzzle resistant to pattern-matching from training data.
- Human experts retain an advantage at sufficiently long time horizons (unlimited-time human submissions exceed Claude's best).
- Core tension: novel problems resist AI better but sacrifice fidelity to actual engineering work.
- Original version released on GitHub as an open challenge.

## Informs (ideas / patterns)
- [[evals]] — AI-resistant evaluation design; the realism-vs-resistance tradeoff; extended time horizon as a defense; Zachtronics-style constraint puzzles.

## Notable quotes
> "Each new Claude model has forced us to redesign the test."
> "Realism may be a luxury we no longer have."
> "Human experts retain an advantage over current models at sufficiently long time horizons."

## Gaps / open questions
- Is extended time horizon a sustainable defense, or will frontier models eventually saturate it?
- What does a valid evaluation look like when AI can solve any realistic task faster than humans?

## Related
- [[evals]] · [[eval-awareness-browsecomp]] · [[infrastructure-noise-evals]] · [[anthropic-demystifying-evals]]
