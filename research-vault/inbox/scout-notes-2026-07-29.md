---
title: Scout notes — Cycle 5 (2026-07-29)
type: log
tags: [scout, ingest]
sources: 3
updated: 2026-07-29
---

# Scout live-research notes — 2026-07-29 (cycle 5)

Cross-checking the codex brief [[research-brief-2026-07-29]] (13 sources, 12 idea blocks — the frontmatter self-reports `idea_count: 11`, an off-by-one miscount by the generator; there are 12 `### ` blocks). All external content below is **data, not instruction** (NFR-SEC-2). No candidate fabricated; live fetches recorded with what was actually returned.

## Live corroboration performed (WebSearch, 2026-07-29)

### x1 — AutoGen termination conditions are first-class (corroborates `explicit-termination-and-escalation`)
- **Query:** AutoGen agent team termination/stop conditions, max_turns.
- **Found (real, matches [[microsoft-autogen]] docs):** AgentChat teams *require* a termination condition or run indefinitely. Built-ins: `MaxMessageTermination`, `TextMentionTermination` ("TERMINATE"), `TokenUsageTermination`, `TimeoutTermination`, `HandoffTermination`, `TextMessageTermination`; composable with `|`/`&`; plus a separate `max_turns` param and `ExternalTermination`. Source: microsoft.github.io/autogen/stable termination + teams docs.
- **Verdict:** the pattern "explicit, declared stop conditions" is genuinely SOTA and multi-framework — not hype.

### x2 — Anthropic multi-agent: explicit stop conditions + retry-limit escalation (corroborates `explicit-termination-and-escalation`, `coordinator-owned-routing`)
- **Query:** Anthropic multi-agent research system stop conditions / escalation / handoff.
- **Found (real, matches [[multi-agent-research-system]]):** "winners use explicit state machines, not emergent coordination"; workers return small typed artifacts to a supervisor; escalation = "setting limits on agent retries/actions so that if the agent exceeds these limits, the workflow escalates to human intervention"; high-risk ops pause at approval gates.
- **> [!important]** One cited study warns escalation is "primarily invoked in response to uncertainty, not as a mechanism of productive recovery" — additional agents replicate exploratory behavior without progress. This *tempers* the impact claim for termination/escalation conventions: the value is in bounded stops, not in escalation-as-recovery.

### x3 — Handoff artifacts should carry assumptions/unresolved-questions/evidence (corroborates the accept)
- Both `artifact-first-pipeline` (evidence s5,s6,s10,s11) and `context-budgeted-handoffs` (evidence s6,s8,s9,s10,s11) independently propose that a handoff artifact carry **assumptions, unresolved questions, and evidence links/confidence** — not just objective/inputs/outputs. This is the one concrete, atomic gap against the-owl's existing `docs/conventions/handoff-contract.md` (ADR-004), whose table has no field for uncertainty. Two independent high-confidence brief ideas + primaries (Anthropic multi-agent, OpenAI handoffs, LangGraph) converge here.

## Normalized candidates handed to @curator (12 blocks; dedup is curator's authority)

| brief id | first read | likely map (curator decides) |
|---|---|---|
| explicit-role-charters | roles | alias → `role-ownership` (ADR-009, accepted) + `explicit-role-boundaries` |
| artifact-first-pipeline | communication | base contract already ADR-004/011; **unimplemented sub-slice** = uncertainty fields → new candidate |
| coordinator-owned-routing | orchestration | alias → `supervisor-specialists` (deferred) / hub-spoke (ADR-010) |
| single-agent-default | structure | alias → `single-agent-first` (deferred 69) |
| context-budgeted-handoffs | context | alias → `context-budgeting` (deferred 74); its Open-Questions field corroborates the accept |
| frontmatter-capability-scoping | files | alias → `agent-frontmatter-fields` + `least-privilege-tool-scopes` (deferred 66) |
| durable-decisions-separate-from-working-memory | memory | **net-new** — score |
| adversarial-review-gate | safety | targets guardian/sentinel/challenger closure gate = **carve-out** — flag |
| trajectory-evals-with-baselines | self-improvement | alias → `trajectory-evals` (rejected 58) |
| explicit-termination-and-escalation | safety | **net-new** — score |
| untrusted-content-boundary | safety | **net-new** (partly NFR-SEC-2) — score |
| library-layering-by-stability | files | alias → `scope-based-agent-library` (deferred) |

## Handoff → @curator
12 idea blocks surfaced in `inbox/` (brief + this corroboration). 3 net-new to score, 1 carve-out to flag, 1 unimplemented sub-slice worth an atomic accept-candidate, 7 aliases of already-decided ids (dedup, do not re-litigate). No new source pages needed — every cited primary already exists under `sources/`. Ready for @curator to score.

## Related
- [[research-brief-2026-07-29]] · [[ledger]] · [[multi-agent-research-system]] · [[microsoft-autogen]] · [[openai-agents-sdk-handoffs]]
