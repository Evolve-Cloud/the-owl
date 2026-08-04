---
title: "SWE-bench: Can Language Models Resolve Real-World GitHub Issues?"
type: source
tags: [swe-bench, evals, agentic-coding, benchmarks, repository-level]
sources: 1
updated: 2026-08-03
---
**Source:** [SWE-bench: Can Language Models Resolve Real-World GitHub Issues?](https://arxiv.org/abs/2310.06770) · **Type:** paper · **Stars/credibility:** n/a · primary
**Author / Org:** Carlos E. Jimenez, John Yang, Alexander Wettig, Shunyu Yao, Kexin Pei, Ofir Press, Karthik Narasimhan (Princeton NLP / University of Chicago)
**Published:** 2023-10-10 (arXiv v1; last revised 2024-11-11) · ICLR 2024  ·  **Ingested:** 2026-08-03

## Summary
Introduces SWE-bench, an evaluation framework built from ~2,294 real GitHub issue + pull-request pairs across 12 popular Python repositories. A model is given an issue description and the repository, and must produce a patch that resolves the issue, verified by the repository's own tests. The paper's central finding is that real-world software engineering is a hard testbed — at publication the best model (Claude 2) resolved only 1.96% of issues — establishing an executable, repository-level, regression-tested benchmark rather than a synthetic one.

## Key points
- Task = resolve a real GitHub issue by editing a real codebase; success is judged by the repo's actual test suite (FAIL→PASS + PASS→PASS), not by string match.
- Repository-level, cross-file reasoning: issues require understanding code far beyond the edited lines and long-range historical/project context.
- Executable evaluation: patches are applied and tests run — resistant to answer-memorization in a way multiple-choice benchmarks are not.
- At publication, top models scored in the low single digits (Claude 2 ~1.96%), quantifying the gap between LLM capability and real SWE work.
- Became the canonical harness/benchmark that later agentic-scaffolding work (e.g. the Anthropic SWE-bench-Sonnet 49% result) is measured against.

## Informs (ideas / patterns)
- [[eval-backed-library-evolution]] — executable, replayable issue-resolution suite is the archetype the-owl's fitness harness (ADR-014/015) generalizes.
- [[append-only-decision-memory]] — grounds the claim that repository work needs durable cross-file/historical understanding (directional support, not a mechanism).
- [[evals]] — original benchmark paper distinct from the Anthropic scaffolding blog.

## Notable quotes
_(Not a full-text read — from the arXiv abstract only, via WebFetch summarizer 2026-08-03; recorded as a paraphrase, not a verbatim quote.)_
- Abstract (paraphrase): the best-performing model, Claude 2, resolved only ~1.96% of the issues.

## Gaps / open questions
- Static benchmark → contamination/overfitting risk over time (later addressed by SWE-bench Verified and refreshed variants).
- Says nothing about markdown-only / no-runtime agent libraries — evidence is directional for the-owl, not a concrete convention gap.

## Related
- [[swe-bench-sonnet]] — the Anthropic *blog* (49% scaffolding result) that benchmarks against THIS paper; the two are distinct sources.
- [[anthropic-demystifying-evals]] · [[eval-backed-library-evolution]] · [[research-brief-2026-08-03]]
