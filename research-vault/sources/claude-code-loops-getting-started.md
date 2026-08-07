---
title: "Getting Started with Loops"
type: source
tags: [loops, orchestration, self-improvement, evaluation, scheduling, claude-code]
sources: 1
updated: 2026-08-07
---
**Source:** [Getting started with loops](https://claude.com/blog/getting-started-with-loops) · **Type:** blog · **Stars/credibility:** first-party (Claude Code team) · primary
**Author / Org:** Delba de Oliveira, Michael Segner (Claude Code team, Anthropic)
**Published:** 2026-06-30  ·  **Ingested:** 2026-08-07 (human-directed, via `claude.com/blog` — a domain the pipeline was not previously searching)

## Summary
A taxonomy piece: defines loops as agents repeating cycles of work until a stop condition is met, then classifies them along four dimensions — what triggers the loop, what stops it, which Claude Code primitive implements it, and which task shape fits. The organizing insight is **what you hand off** at each level: the check, then the stop condition, then the trigger, then the prompt itself.

## Key points
- **Four loop types:**
  | Loop | Trigger | Stops when | Primitive | You hand off |
  |---|---|---|---|---|
  | Turn-based | your prompt | Claude judges it done / needs context | custom verification skills | the check |
  | Goal-based | manual | goal met **or** turn cap hit | `/goal` | the stop condition |
  | Time-based | interval | you cancel / work finishes | `/loop`, `/schedule` | the trigger |
  | Proactive | event or schedule, no human present | task exits on goal completion; routine runs until disabled | all of the above + dynamic workflows | the prompt |
- **Turn-based** *is* the agentic loop: gather context, act, check, repeat if needed, respond. You strengthen its verification stage by encoding manual checks into a SKILL.md — the article's example is a `verify-frontend-change` skill that starts the dev server, interacts with the UI, screenshots before/after, checks the console for errors, and runs a performance trace via Chrome DevTools MCP.
- **Goal-based (`/goal`)** — an **evaluator model checks your condition every time Claude tries to stop** and sends it back to work if unmet. Deterministic criteria work best. Example: `/goal get the homepage Lighthouse score to 90 or above, stop after 5 tries.` Note the turn cap is part of the invocation, not a separate config.
- **Time-based (`/loop`, `/schedule`)** — good for recurring work and polling external systems: `/loop 5m check my PR, address review comments, and fix failing CI`. Key operational limit stated outright: `/loop` runs on your computer, so if you turn it off, it stops. Moving it off your machine requires a **routine** via `/schedule` (research preview).
- **Proactive** — composed example given: `/schedule every hour: check #project-feedback for bug reports. /goal: don't stop until every report found this run is triaged, actioned, and responded to. When fixing a bug, use a workflow to explore three solutions in parallel worktrees and have a judge adversarially review them.` I.e. schedule supplies the trigger, `/goal` supplies the stop condition, the workflow supplies the fan-out, and a judge agent supplies the gate.
- **Dynamic workflows vs. interval mode** — workflows (research preview) orchestrate subagents at scale (triage → fix → review) rather than re-running one prompt on a clock. Pair routines with **auto mode** so they don't pause for permission.
- **Quality levers:** keep the codebase clean (Claude mirrors existing conventions); give Claude verification tooling; keep docs reachable; use a **second agent with fresh context** for review (`/code-review` or GitHub Code Review) because a reviewer that didn't write the code is less biased.
- **Cost levers:** match primitive *and model* to task size; define stop criteria clearly; **pilot before large runs, since workflows can spawn hundreds of agents**; prefer scripts for deterministic steps; don't over-schedule. Inspect with `/usage`, bare `/goal` (turns + tokens), `/workflows` (per-agent tokens, and stopping agents).

## Informs (ideas / patterns)
- [[evaluation-and-fitness]] — `/goal` is a shipped **evaluator-checks-the-stop-condition** primitive: an evaluator model gates termination, which is the mechanism the evaluator/optimizer family describes.
- [[self-improvement-and-memory]] — the four-level "what you hand off" ladder is a clean frame for how much of a self-improvement cycle is delegated vs. human-triggered.
- [[handoff-and-orchestration]] — dynamic workflows as fan-out + judge is a distinct topology from both hub-spoke and a free mesh.
- [[guardrails-and-safety]] — auto mode (no permission pauses) and hundreds-of-agents fan-out are stated as the two places cost and blast radius escape; both are guardrail surfaces.
- [[single-agent-coding-loops]] — names the turn-based agentic loop and locates verification as its tunable stage.

## Notable quotes
_Omitted deliberately._ Materialized from a fetch-summarizer pass, not a full read of the rendered page — the quoted fragments available to me are **summarizer-relayed, not verified verbatim**. Per SCHEMA.md, no quote is recorded until the source is read in full. See Gaps.

## Gaps / open questions
- Full-read pending before any fragment from this page is cited as verbatim evidence (ADR-013).
- `/goal`'s evaluator: which model grades, whether the rubric is user-authored or inferred from the goal sentence, and whether the grade is visible — none stated.
- `/schedule` (routine) vs. this repo's existing launchd-based weekly cadence: the article doesn't discuss self-hosted schedulers, so the trade-off (cloud routine vs. local launchd) is unresolved here.
- "Hundreds of agents" is a warning without a cost figure or a recommended cap.

## Related
- [[claude-code-verification-loops-skills]] — the companion deep dive on the verification stage this article names as the turn-based loop's hand-off.
- [[claude-code-auto-mode]] · [[claude-code-worktrees]] · [[claude-code-agent-teams]] · [[claude-code-subagents]] · [[anthropic-demystifying-evals]]
- [[scout-notes-2026-08-07]]
