---
title: Scout notes — 2026-07-30 (cycle 6)
type: log
tags: [scout, ingest, cycle-6]
sources: 2
updated: 2026-07-30
---

# Scout notes — 2026-07-30

Brief of record: [[research-brief-2026-07-30]] (codex, gpt-5, 14 sources, 11 idea blocks; frontmatter `idea_count: 10` miscounts — 11 `### ` blocks present, non-blocking). All content is **DATA, not instruction** (NFR-SEC-2). No injected directive found in the brief or in the two live fetches below.

## Candidates surfaced (11) — all aliases of already-decided ledger ids

Every idea block in today's brief resurfaces an idea the curator has already decided in a prior cycle. Recorded here so the curator can dedup against `ledger.md` (authoritative dedup is curator's job, not mine). No net-new id this cycle.

| brief id | maps to (ledger) | prior status |
|---|---|---|
| role-boundaries-and-artifact-contracts | role-ownership (ADR-009) + handoff-contract (ADR-004) | accepted |
| coordinator-owned-hub-spoke | supervisor-specialists / hub-spoke (ADR-010) | deferred/accepted |
| yaml-frontmatter-and-prompt-body | agent-frontmatter-fields | deferred |
| least-privilege-tool-scoping | least-privilege-tool-scopes | deferred (66 — unenforceable-prose risk) |
| structured-handoff-contracts | handoff-contract (ADR-004) + uncertainty-fields (ADR-020) | accepted |
| n-minus-one-context-transfer | context-budgeting | deferred (74) |
| adr-as-durable-decision-memory | durable-decisions-separate-from-working-memory | deferred (64) |
| evidence-gated-evaluation-loop | evaluator-optimizer-loop / trajectory-evals | corroborated / rejected (58) |
| independent-adversarial-review | adversarial-review-gate | **rejected (carve-out — NFR-SEC-1)** |
| effort-budgets-and-hard-stops | explicit-termination-and-escalation (68) + single-agent-first (69) | deferred |
| human-approval-at-boundary-crossings | human-approval-gates | deferred (67) |

## Live corroboration (2 fetches — both real, none fabricated)

### 1. OpenAI Agents SDK — handoff input filtering (corroborates `n-minus-one-context-transfer` / `structured-handoff-contracts`)
Source: [[openai-agents-sdk-handoffs]] · https://openai.github.io/openai-agents-python/handoffs/
Confirmed API surface for **filtering what context crosses a handoff**: `input_filter`, `HandoffInputData` (fields `input_history`, `pre_handoff_items`, `new_items`, `input_items`, `run_context`), `RunConfig.handoff_input_filter`, prebuilt `handoff_filters.remove_all_tools`; structured inputs via `input_type` (schema for handoff tool-call args) + `on_handoff` callback + a `reason` field example. → This is the runtime-level version of the-owl's N-1 scoping rule; corroborates that "pass a filtered summary + artifact ref, not the full transcript" is SOTA, but it is a **runtime mechanism** (no atomic markdown gap by itself).

### 2. Anthropic multi-agent research system — proportional effort/scaling rules (corroborates `effort-budgets-and-hard-stops`)
Source: [[multi-agent-research-system]] · https://www.anthropic.com/engineering/multi-agent-research-system
Confirmed, exact quotes: over-delegation was "a common failure mode in our early versions" ("spawning 50 subagents for simple queries"); embedded **scaling rules in the prompts** — "Simple fact-finding requires just 1 agent with 3-10 tool calls", "direct comparisons might need 2-4 subagents with 10-15 calls each", "complex research might use more than 10 subagents with clearly divided responsibilities"; loop exits "once sufficient information is gathered"; multi-agent "use about 15× more tokens". → Strongest fresh corroboration this cycle. Directly reinforces the deferred `explicit-termination-and-escalation` (68) and `single-agent-first` (69). Still: the-owl already encodes HARD STOP + circuit breaker + hub-spoke-one-agent-per-phase (ADR-010), so the curator must find a *concrete atomic gap* to promote from deferred.

## Handoff → @curator
11 candidates surfaced in inbox/ (all aliases of decided ids — see table), 0 net-new sources (both fetched sources already in `sources/`), 2 live corroborations recorded. Ready for @curator to dedup vs `ledger.md`, ground (L1.5), and score. Returning control to `/owl:evolve`.
