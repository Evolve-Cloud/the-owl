---
title: "Anthropic — Demystifying Evals for AI Agents"
type: source
tags: [evals, agents, testing, regression, grading, benchmarks]
sources: 1
updated: 2026-07-26
---
**Source:** [Anthropic — Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Mikaela Grace, Jeremy Hadfield, Rodrigo Olivares, Jiri De Jonghe (Anthropic); contributors David Hershey, Gian Segato, Mike Merrill, Alex Shaw  ·  **Published:** 2026-01-09  ·  **Ingested:** 2026-07-26 (cited in `/owl:evolve` cycle 4, PR #4; enriched here from a personal-vault import, same source re-read in full)

## Summary
Rigorous automated evaluations are essential infrastructure for shipping AI agents confidently. Anthropic's practical guidance on building agent eval harnesses: grade the transcript (path/reasoning/tool calls) AND the outcome, but weight outcome higher — rigid trajectory-checking is brittle since agents find valid paths eval designers didn't anticipate. Covers grader types, agent-specific approaches, statistical metrics for non-determinism, LLM-as-judge pitfalls, and organizational patterns for building sustainable eval programs.

## Key points
- **Nuance worth flagging for the-owl's own fitness harness (ADR-014):** "It's often better to grade what the agent produced, not the path it took." Trajectory grading is recommended as a *complement* (e.g. an `llm_rubric` alongside a `state_check`), not a replacement for outcome grading — the-owl's judge (`eval/judge.md`) already grades outcome, consistent with this recommendation.
- Agent autonomy and flexibility make evals harder than single-turn systems — mistakes propagate across multiple turns.
- Three grader types: code-based (fast, objective, brittle), model-based (flexible, nuanced, non-deterministic), human (gold standard, expensive).
- Two eval categories: capability evals (start at low pass rates, target hard tasks) vs. regression evals (maintain ~100% pass rate to catch backsliding).
- Two non-determinism metrics: pass@k (probability of ≥1 success in k attempts) vs. pass^k (probability all k succeed) — different reliability implications.
- LLM-as-judge pitfalls: non-deterministic + costly; give the judge an "Unknown" escape hatch to reduce hallucinated verdicts; use an isolated judge per rubric dimension rather than one judge grading everything — matches the-owl's own per-dimension judge breakdown.
- Practical roadmap: start with 20-50 tasks from real failures, convert manual checks to automated tests, write unambiguous specs with reference solutions, build clean isolated environments per trial.
- Eval saturation risk: as models improve, evals approaching 100% stop providing improvement signal — should "graduate" into regression suites.
- "With frontier models, a 0% pass rate is most often a signal of a broken task, not an incapable agent."

## Informs (ideas / patterns)
- [[evals]] — comprehensive framework for agent evals; pass@k and pass^k metrics; capability vs. regression distinction; eval saturation; transcript/trace/outcome definitions.
- `trajectory-evals` (the-owl idea, rejected 58/100, cycle 4) — this source is the one the rejected idea over-cited: read in full, it argues the opposite of "evaluate trajectories, not only final answers."
- `evaluator-optimizer-loop` (the-owl idea, deferred 68/100) — the isolated-judge-per-dimension point matches `eval/judge.md`.

## Notable quotes
> "Good evaluations help teams ship AI agents more confidently."
> "It's often better to grade what the agent produced, not the path it took."
> "No single evaluation layer catches every issue... with multiple methods combined, failures that slip through one layer are caught by another."
> "Reading transcripts is how you verify that your eval is measuring what actually matters."

## Gaps / open questions
- How do you build evals for tasks with no verifiable ground truth (creative writing, strategic reasoning)?
- What's the right ratio of capability to regression evals for a production agent?
- How do evals transfer across model versions when model behavior changes substantially?

## Related
- [[evals]] · `infrastructure-noise-evals` · `eval-awareness-browsecomp` · `ai-resistant-technical-evals` · `harness-design-long-running-apps`
