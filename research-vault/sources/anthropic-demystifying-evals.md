---
title: "Anthropic — Demystifying Evals for AI Agents"
type: source
tags: []
sources: 1
updated: 2026-07-26
---
**Source:** [Anthropic — Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Anthropic  ·  **Published:** unknown  ·  **Ingested:** 2026-07-26

## Summary
Anthropic's practical guidance on building agent eval harnesses: grade the transcript (path/reasoning/tool calls) AND the outcome, but weight outcome higher — rigid trajectory-checking is brittle since agents find valid paths eval designers didn't anticipate. Covers LLM-as-judge pitfalls and harness hygiene (isolated trials, deterministic graders where feasible, partial credit, reading transcripts).

## Key points
- **Nuance vs. a pure "evaluate trajectories" framing:** "It's often better to grade what the agent produced, not the path it took." Trajectory grading is recommended as a *complement* (e.g. an `llm_rubric` alongside a `state_check`), not a replacement for outcome grading.
- LLM-as-judge pitfalls: non-deterministic + costly; give the judge an "Unknown" escape hatch to reduce hallucinated verdicts; use an isolated judge per rubric dimension rather than one judge grading everything.
- Grading bugs can masquerade as agent failure (a correct-but-differently-formatted answer scored as wrong) — read transcripts to catch this, don't trust the grader blindly.
- Isolate trials (clean environment per run); build partial credit into multi-step tasks; watch for saturation (100% pass rate stops signaling improvement — graduate to a regression suite).

## Informs (ideas / patterns)
- [[trajectory-evals]] — tempers the brief's framing: this source treats trajectory grading as a secondary/complementary signal, not the primary one. the-owl's own fitness harness (`eval/`, ADR-014) already grades OUTCOME (a judge scoring the produced artifact) — consistent with this source's actual recommendation, not the brief's "evaluate trajectories" framing.
- `evaluator-optimizer-loop` (deferred, no dedicated page — see [[ledger]]) — the "isolated judge per rubric dimension" point matches the-owl's own judge protocol (`eval/judge.md`, per-dimension breakdown).

## Notable quotes
> "It's often better to grade what the agent produced, not the path it took."
> "Reading transcripts is how you verify that your eval is measuring what actually matters."

## Gaps / open questions
- Vendor guidance from Anthropic's own agent-building experience, not an independent benchmark study.

## Related
[[research-brief-2026-07-26]] · [[anthropic-building-effective-agents]]
