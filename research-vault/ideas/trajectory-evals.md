---
title: "Evaluate trajectories, not only final answers"
type: idea
tags: [self-improvement]
sources: 4
status: rejected
score: 58
adr: ""
updated: 2026-07-26
---
**Category:** self-improvement · **Confidence:** high (in the source) · **Applicability:** 5/5 (per brief; disputed below)

From codex brief `trajectory-evals` (2026-07-26).

## Pattern
Final-answer-only scoring can hide inefficient, unsafe, or lucky execution paths; the brief proposes scoring the full trajectory (reasoning, tool calls, intermediate steps), not just the produced artifact.

## Proposed change to the-owl (as submitted)
"Create an Eval Contract section for each agent defining test cases, pass/fail criteria, **trajectory checks**, and required evidence."

## L1.5 self-audit (grounded — ADR-005) + why this is rejected, not just deferred
- **`já_implementado?`** — **Yes, and better-calibrated than what's proposed.** the-owl already has a live fitness harness (`eval/`, ADR-014/015): k≥3 runs, an independent blind judge scores the **produced artifact** against a task rubric, and a Δ is computed before crediting "Impact." This is the-owl's working evaluator-optimizer loop.
- **The brief's own cited evidence argues AGAINST its proposed framing, once actually read (not just cited).** Scout fetched the brief's marquee source for this idea in full (`s12` = Anthropic "Demystifying Evals for AI Agents", see `sources/anthropic-demystifying-evals.md`) — and it says the opposite of what the idea's `rationale` field claims: *"It's often better to grade what the agent produced, not the path it took."* Anthropic treats trajectory grading as a **secondary, complementary** signal (an `llm_rubric` alongside a `state_check`), not the primary axis. The idea's proposed "Eval Contract... **trajectory checks**" as a required field overstates its own citation.
- **`onde_está_o_gap`** — none that would improve on the current design. Adding a mandatory per-agent trajectory-check field would layer redundant, weakly-evidenced process on top of a harness that already does the *better-supported* version of this idea (outcome-primary grading).
- **`arquivo_alvo`** — none.

## Curator verdict — score 58 (reject; reject_below 60)
| Criterion | Score | Note |
|---|---|---|
| Fit (25) | 20 | The general concept (eval agents rigorously) fits; the specific mechanism (mandatory trajectory-check field per agent) doesn't match what the-owl's own harness already does well. |
| Evidence (20) | 9 | The idea's own best-cited source, read in full, argues for the **opposite emphasis** (outcome-primary, trajectory-secondary) — a real evidence-quality problem, not just weak evidence. |
| Impact (20) | 5 | the-owl's `eval/` (ADR-014/015) already implements the better-supported version; this would add process without improving on it. |
| Simplicity (15) | 11 | Would be simple to add, but simplicity doesn't rescue a weakly-evidenced, largely-redundant change. |
| Safety (10) | 10 | No attack surface. |
| Non-duplication (10) | 3 | Materially overlaps with the existing, working `eval/` harness. |

Total 58 < 60 → **REJECTED.** Not re-litigated unless a future cycle brings evidence that actually supports mandatory trajectory-checking (as opposed to the brief's citation, which argues against it) *and* identifies a concrete gap in the existing harness that trajectory-checking specifically would close.

## Why this is worth keeping as a full page (not just a ledger row)
This is the cycle's clearest example of the claim-verification muscle (ADR-013 + scout's live-read discipline) catching a **brief that cites real evidence but mischaracterizes what it says** — a subtler failure than a fabricated source (which scout also checks for), and exactly the kind of error a codex brief can make when synthesizing many sources under time pressure. Worth a durable record so a future cycle doesn't resurface the same over-claim without re-reading the source.

## Related
- `evaluator-optimizer-loop` (deferred idea, no dedicated page — see [[ledger]]) · [[overview]]
- **Sources:** [[anthropic-demystifying-evals]] · [[swe-debate-paper]]
- [[scout-notes-2026-07-26]] · [[research-brief-2026-07-26]] (codex, s11/s12/s14/s15)
