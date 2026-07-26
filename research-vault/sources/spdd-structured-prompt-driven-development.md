---
title: "Martin Fowler / Thoughtworks — Structured Prompt-Driven Development (SPDD)"
type: source
tags: [spdd, prompt-engineering, spec-driven-development, governance, workflow, reasons-canvas]
sources: 1
updated: 2026-07-26
---
**Source:** [Structured-Prompt-Driven Development (SPDD)](https://martinfowler.com/articles/structured-prompt-driven/) · **Type:** blog (martinfowler.com) · **Stars/credibility:** n/a · primary
**Author / Org:** Wei Zhang and Jessie Jie Xia (Thoughtworks Global IT Services), with Martin Fowler  ·  **Published:** 2026-04-27  ·  **Ingested:** 2026-07-26 (found in carinhAI's raw `Engineering/AI/` clippings, not yet ingested into any wiki — this is its first vault page anywhere)

## Summary
SPDD is an engineering method that treats prompts as first-class, version-controlled delivery artifacts rather than throwaway chat. Its core is the **REASONS Canvas** — a seven-part structure (Requirements, Entities, Approach, Structure, Operations, Norms, Safeguards) that moves a prompt from intent → design → execution → governance before any code generates. A companion workflow (analysis → canvas → generate → review → sync) keeps the canvas and the code in lockstep across iterations, so business intent is captured durably instead of scattered across chat logs and diffs.

## Key points
- Two-way sync is the mechanism that prevents spec/code drift: `/spdd-prompt-update` flows requirements → prompt → code when business rules change; `/spdd-sync` flows code → prompt when the code is refactored. Neither side silently diverges.
- Explicit sequencing rule: **logic corrections** (behavior changes) → update the prompt first, then the code. **Refactoring** (no behavior change) → change the code first, then sync the prompt back. This distinction (Fowler's own refactoring definition) decides which direction the loop runs.
- Deliberately NOT TDD-ordered: API/functional tests run *before* code review (cheap to generate, validates the "what" fast), code review focuses on what only humans judge (architecture, tradeoffs), unit tests come *last* as a regression safety net once intent + implementation are both stable.
- Six-step workflow (story → clarify analysis → generate canvas → generate code → code review/adjustment → generate unit tests) is deliberately fine-grained: compressing intent confirmation into one big review after plan generation overloads human attention and reintroduces the drift SPDD is meant to prevent.
- Explicit fitness table: 5★ for scaled/standardized delivery and high-compliance domains; 2★ for hotfixes and exploratory spikes; 1★ for "context black holes" (undefined domains) and purely aesthetic/creative work. SPDD's authors are explicit that it is **not** a universal practice.
- Honest self-critique (from the article's own Q&A section): the Canvas "pushes the variance problem up a layer" — two developers can still produce different canvases for the same requirement; there is no formal, automated definition of "good" yet. Governance still leans on human judgment; the stated next step is automated verification *at the asset layer* (analysis/canvas/prompt), not just at the code layer.
- Model-agnostic by design (used across Claude/GPT/Gemini generations); the artifact is treated as "prompt-as-spec," the model as the interchangeable executor of that spec — but raw capability still matters for the harder analysis/canvas-generation steps (their own experience ranks Claude Opus ahead of GPT Codex and Gemini 3.x Pro there).
- Hotfixes don't bypass governance permanently — they defer it one step: if the bug is in an area with an existing canvas, update prompt-then-code even during the fix; for legacy code with no canvas, fix first, then a deliberate post-mortem step writes the missing canvas — this is described as how SPDD coverage organically grows over a codebase.

## Informs (ideas / patterns)
- This is a governance/workflow pattern most directly comparable to the-owl's own ADR-per-change discipline (`docs/decisions/`) and its ledger-as-decision-record model — SPDD's "prompt as version-controlled asset that must stay synced with code" is structurally the same shape as the-owl treating its own agent `.md` files + ADRs as the durable, reviewable artifact of a change, rather than the chat that produced it.
- The **logic-correction vs. refactoring** directional rule (spec-first vs. code-first depending on whether observable behavior changes) is a sharper, more general version of a distinction the-owl's own harness discipline gestures at but hasn't named explicitly — worth a `patterns/` page of its own if a future cycle wants to formalize it as a candidate idea.
- The self-admitted "pushes variance up a layer" gap is a direct parallel to the-owl's own ADR-015 finding (curator's own scoring optimism, ~+15 vs. independent peers) — both are cases of a structured process narrowing but not eliminating human/model judgment variance, and both conclude the fix is an independent verification layer, not more structure at the same layer.

## Notable quotes
> "When reality diverges, fix the prompt first — then update the code."
> "In science, if you know what you are doing, you shouldn't be doing it. In engineering, if you don't know what you are doing, you shouldn't be doing it." — Richard W. Hamming (quoted in the article's closing)
> "The Canvas narrows the band of variance compared with free-form prompting, but it does not eliminate it... human judgement is still load-bearing."

## Gaps / open questions
- No externally-run empirical comparison (vs. plain spec-driven development or ad hoc prompting) is cited — the evidence is a single worked example (a billing-engine enhancement) plus practitioner testimony, not a controlled study.
- The "automated verification at the asset layer" the authors call out as the necessary next step does not yet exist (as of publication) — unclear whether it is more tractable than automated code verification.
- Applicability to non-Thoughtworks, non-`openspdd`-tooled teams is unverified; the workflow is described as requiring senior-engineer judgment "up front," which may not transfer to less experienced teams the article's own "raises the floor" claim implies it should help.

## Related
- [[anthropic-building-effective-agents]] · [[agent-architectures]] · [[context-engineering]]
