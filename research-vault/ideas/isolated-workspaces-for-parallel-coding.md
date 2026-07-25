---
title: "File ownership & workspace isolation for parallel coding"
type: idea
tags: [tooling, orchestration]
status: rejected
score: 41
adr: ""
updated: 2026-07-24
---

**Category:** tooling · **Confidence:** high (in the source) · **Applicability:** 2/5

From codex brief `isolated-workspaces-for-parallel-coding` (2026-07-24).

## Pattern
Parallel coding agents work in separate worktrees / isolated workspaces with explicit file ownership and a controlled merge boundary, so two agents never mutate the same file concurrently.

## L1.5 self-audit (grounded)
- **`já_implementado?`** — N/A. the-owl is a **single-threaded, no-runtime, hub-and-spoke library**; it has no parallel disk-writing agents and cannot provide workspace isolation. The only transposable sliver ("declare file ownership / no-overlap") is already covered by the accepted [[role-ownership]] + [[handoff-contract]] conventions.
- **`onde_está_o_gap`** — none that fits: worktree isolation is a *host/runtime* capability, not a prompt/convention.
- **`arquivo_alvo`** — none.

## Curator verdict — score 41 (reject; reject_below 60)
| Criterion | Score | Note |
|---|---|---|
| Fit (25) | 6 | Applicability 2/5; presupposes a runtime the-owl deliberately does not have. |
| Evidence (20) | 16 | Strong in general (Claude Code worktrees, OpenHands, SWE-agent) — but for *parallel* systems, not a single-threaded lib. |
| Impact (20) | 4 | Near-zero for the-owl's topology; scout live research WEAKENED its fit here. |
| Simplicity (15) | 8 | A static ownership rule is simple but cannot enforce isolation without host support (false guarantee). |
| Safety (10) | 5 | No carve-out contact, but a rule implying isolation the host doesn't enforce is a mild false-assurance risk. |
| Non-duplication (10) | 2 | The usable sliver already lives in role-ownership + handoff-contract. |

Total 41 < 60 → **REJECTED** (low architectural fit — a clean signal the loop discriminates against runtime-shaped ideas). Not re-litigated unless the-owl gains parallel execution.

## Related
- [[role-ownership]] · [[handoff-contract]]
- **Sources:** [[claude-code-worktrees]] · [[claude-code-agent-teams]] · [[openhands]] · [[swe-agent]] · [[swe-agent-paper]] · [[research-brief-2026-07-24]] (codex)
