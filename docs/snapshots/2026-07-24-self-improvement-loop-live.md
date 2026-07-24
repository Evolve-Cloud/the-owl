# Snapshot — Self-Improvement Loop LIVE (milestone)

**Date:** 2026-07-24 · **main:** `13a934b` · **Version:** 1.6.0
**Status:** loop live + armed (daily 07:13) · **3 autonomous cycles merged** · **0 carve-out violations** · **0 open PR branches**

## What the-owl is now
A markdown-only, no-runtime, hub-and-spoke DevFlow agent library that **improves its own agents autonomously**, daily, with a human merge gate. The loop researches the field, scores ideas against a ratcheting rubric *and* against our own code, turns accepted ideas into ADR-backed edits, gates them with its own quality agents, and lands them as shadow PRs.

## Agents (10 + team)
Existing DevFlow 8: `strategist` · `architect` · `system-designer` · `builder` · `guardian` · `sentinel` · `challenger` · `chronicler`.
New for the loop: **`scout`** (field research → normalized candidates) · **`curator`** (rigor scoring + owns the research vault).

## The loop (L0→L5) — `/owl:evolve`
- **L0** `/owl:research` — codex CLI (`codex exec -o …`) writes the daily brief to `research-vault/inbox/`.
- **L1** scout — brief + live WebSearch → candidates (schema 8b).
- **L1.5** gap-analysis (ADR-005) — audits the real agent files: *already implemented? where's the gap? which file?*
- **L2** curator — dedup vs `ledger.md` → rubric score (accept ≥ threshold, ratchets 75→90) → **safety veto** (sub-score < 7 = auto-reject) → classify.
- **L3** integrate — architect writes the ADR, builder edits the target file (1 idea → 1 ADR → 1 atomic commit).
- **L4** gate (blocking) — guardian + sentinel + challenger, all must PASS.
- **L5** land — shadow PR by default (`.owl/loop-config.yml` `landing: pr`); chronicler updates docs.

## Safety model (NFR-SEC-1, ADR-001) — why autonomous is acceptable
The loop may improve any agent **except its own guardrails**: sentinel veto, guardian gate, challenger, the rubric safety floor, the scope allow-list, `.owl/loop-config.yml`, `.claude/settings.json`, the schedule, `~/.ssh`, secrets — all **human-only**. Enforced at L4 by sentinel + a carve-out pre-check at L3. Contained further by: shadow-mode default, circuit breaker (≤3 accepted/cycle), one-ADR-per-commit reversibility, and untrusted-content handling (web/codex = data, never instructions).

## 3 cycles run + merged
| # | Date | Accepted | ADR(s) | PR |
|---|------|----------|--------|-----|
| 1 | 2026-07-23 | handoff-contract convention (91) | ADR-004 | #1 ✅ |
| 2 | 2026-07-23b | handoff rollout → architect/builder/chronicler (94) | ADR-006/007/008 | #2 ✅ |
| 3 | 2026-07-24 | role-ownership convention (87); **rejected** isolated-workspaces (41) | ADR-009 | #3 ✅ |

## Decision records (authoritative — docs/decisions/)
ADR-001 loop + NFR-SEC-1 · ADR-002 vault schema · ADR-003 rigor rubric · ADR-004 handoff-contract convention · ADR-005 gap-analysis vs own code · ADR-006/007/008 handoff rollout · ADR-009 role-ownership · ADR-010 inline execution + output verification.

## Key files
- `.claude/commands/owl/{research,evolve}.md` — the loop.
- `.claude/commands/agents/{scout,curator}.md` (+ `.devflow/agents/*.meta.yaml`) — new agents.
- `research-vault/` — external-research RAG (SCHEMA, index, log, overview, `ledger.md` = dedup truth, inbox/sources/patterns/ideas).
- `.owl/loop-config.yml` — brake pedal (landing, circuit breaker, rubric, safety floor).
- `scripts/owl-daily.sh` + `scripts/com.evolvelabs.owl.daily.plist` — daily schedule.
- `docs/architecture/diagrams/` — Mermaid architecture diagrams.

## Proven this milestone
Headless daily run fired unattended (07:13) · dual research (codex + scout) · rigorous scoring that says *no* (rejected an idea at 41) · gap-analysis grounded in real code · reliable execution after the ADR-010 fix (silent no-op → detected + verified).

## Known follow-ups (non-blocking)
Convention rollout > new conventions (the loop's own flag) · codex deep-research model unavailable → `gpt-5.6-luna` fallback · tokenless launchd can't auto-open PRs (human opens) · `docs/wiki/` not yet initialized · `.devflow/knowledge-graph.json` referenced but absent (regenerate).
