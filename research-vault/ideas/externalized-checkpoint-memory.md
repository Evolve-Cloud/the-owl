---
title: "Explicit state and resumable checkpoints"
type: idea
tags: [memory, reliability]
sources: 4
status: accepted
score: 75
adr: ADR-016
updated: 2026-07-26
---
**Category:** memory · **Confidence:** high · **Applicability:** 4/5

From codex brief `externalized-checkpoint-memory` (2026-07-26), corroborated by scout's live confirmation of the LangGraph checkpointer mechanism.

## Pattern
Long-running agent systems persist task state, intermediate artifacts, and checkpoints **outside the prompt/transcript**, so an interrupted run can resume (or at least be diagnosed) from the last known-good point instead of silently losing state or re-doing already-completed work.

## Proposed change to the-owl
Add a **mid-cycle checkpoint** to `/owl:evolve`: after each phase (L0–L5) completes and passes its own verification step, write (or update) a `.owl/state/cycle-in-progress.json` recording `{cycle_date, phase_completed, ideas_processed_so_far, accepted_so_far}`. On a fresh invocation, if this file exists and is from **today**, the orchestrator reports it and asks whether to resume from the last completed phase or start a fresh cycle — it never silently overwrites or silently ignores it. The file is deleted (or renamed into the completed `last-run.json`) when L5 finishes normally. This is a **structured-artifact convention**, not a runtime/engine — no new dependency, additive to the existing `.owl/state/` directory.

## L1.5 self-audit (grounded against the real code — ADR-005)
- **`já_implementado?`** — **No.** `.owl/state/` currently holds only `last-run.json` (written once, at the **end** of a completed cycle) + daily launchd logs (`daily-2026-07-2{3,4}.log`). Verified directly: `ls .owl/state/` shows no mid-cycle state file of any kind. If `/owl:evolve` is interrupted after, say, L3 (integrate) but before L4 (gate), there is **no record** of which ideas were mid-flight, what was already ADR'd/edited, or where to safely resume — the next invocation has no way to distinguish "nothing happened yet today" from "a cycle died halfway through."
- **`onde_está_o_gap`** — `.claude/commands/owl/evolve.md`'s "Circuit breaker" section already specifies writing `.owl/state/last-run.json` **at the end**, but has no language about a **mid-cycle** checkpoint or resume-detection at the start of a run.
- **`arquivo_alvo`** — `.claude/commands/owl/evolve.md` (add the checkpoint-write step after each phase + a resume-check in "Setup"). No agent `.md` file needs to change — this is orchestrator-only, matching ADR-010's "the orchestrator does more per cycle" model.

## Curator verdict — score 75 (accept, provisional; threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 23 | Pure structured-artifact convention (a JSON file the orchestrator writes/reads); no runtime/engine; fits the existing `.owl/state/` directory exactly. |
| Evidence strength (20) | 15 | Solid secondary sources (LangGraph/OpenAI Agents SDK docs, evidence: s1/s7/s8/s11) + scout's live confirmation of LangGraph's actual checkpointer mechanism (see Claim verification) — not first-party/primary-authored-for-agents-specifically, but directly on-point and independently confirmed, not just cited. |
| Impact (20) | 14 | **Not capped at pure hypothesis-level (ADR-015 distinction):** this candidate's value is a **structural/testable fact** (does a mid-cycle checkpoint get written; can a run detect and report an interrupted prior cycle?), not a claim about whether an agent's *output quality* improves — ADR-015 explicitly separates "afirmação comportamental (o que um agente produz)" from "fato estrutural/documental." This is the latter, so it doesn't inherit role-ownership's measured-null profile the way a "be a better X" convention would. Still, the actual real-world frequency of the failure mode (a cycle actually dying mid-L3–L4) is unproven — scored well short of the ceiling. |
| Simplicity & reversibility (15) | 12 | One new JSON file + a short addition to `evolve.md`'s Setup and per-phase sections; trivially deletable/revertible; no schema migration. |
| Safety (10) | 10 | No attack surface; touches only `.owl/state/` (already the loop's own scratch space, not the carve-out — `.owl/loop-config.yml` itself is untouched). |
| Non-duplication (10) | 9 | Confirmed via direct grounding: no existing mid-cycle state mechanism. Genuinely new. |

**Raw total: 83.** Safety sub-score 10 ≥ floor (7). No carve-out contact.

**Self-haircut applied (ADR-015): −8, landing at 75 (exactly at threshold).** The 2026-07-25 calibration probe measured the curator scoring **+15.4 hot vs. independent peers** on every candidate checked, and instructs a self-discount on marginal (75–90) candidates. 83 sits in that band, so the accept is marked explicitly **provisional**, not a confident clear-accept — if a future session finds this checkpoint mechanism goes unused or the "resume vs. fresh" prompt is just noise nobody acts on, that's grounds to revert (ADR-015 keep/revert framing), same as any other marginal-band accept this cycle onward.

Challenger-style caveat (self-applied, non-blocking): the failure mode this prevents (a `/owl:evolve` run dying mid-cycle) hasn't actually happened yet in the-owl's short history (per `.owl/state/daily-*.log`, both prior automated runs completed or recovered) — this is a **preventive** accept for a risk that is plausible (per ADR-010's own account of the 2026-07-24 subagent no-op near-miss) but not yet observed. Worth noting explicitly rather than implying it fixes a demonstrated incident.

## Claim verification
_(ADR-013 — verified live 2026-07-26 via WebSearch/live doc confirmation, targeted at the central mechanism.)_
- **Claim:** externalizing checkpoints (writing state outside the prompt/transcript at each step) lets an interrupted multi-step run resume without re-doing already-completed work, rather than silently losing state.
- **Source:** LangGraph persistence/checkpointer docs (`langchain-ai.github.io/langgraph`) — primary (framework's own documented mechanism), cross-checked via live search since the direct URL redirected.
- **Verdict:** **confirmed.**
- **Evidence:**
  > "When a graph node fails mid-execution at a given superstep, LangGraph stores pending checkpoint writes from any other nodes that completed successfully at that superstep, so that whenever execution is resumed from that superstep the successful nodes aren't re-run."
- **Note:** this confirms the exact mechanism the-owl's proposed change mirrors at a much smaller scale (one JSON file, not a full checkpointer library) — the underlying principle (persist-outside-the-transcript → skip re-doing completed work on resume) transfers cleanly to a markdown-only, no-runtime setting.

## Related
- `sequential-artifact-pipeline` (deferred idea, no dedicated page — see [[ledger]]) · [[overview]]
- **Sources:** [[langgraph-persistence]] · [[langgraph]] · [[langgraph-multi-agent-handoffs]] · [[openai-agents-sdk-orchestration]]
- [[scout-notes-2026-07-26]] · [[research-brief-2026-07-26]] (codex, s1/s7/s8/s11)
