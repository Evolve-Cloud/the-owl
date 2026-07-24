# ADR-010 — Loop execution model: inline phases + mandatory output verification

**Status:** Accepted
**Date:** 2026-07-24
**Author:** @architect (human-driven fix to loop machinery)
**Tags:** [self-improvement, reliability, harness, loop-machinery]
**Related:** ADR-001, ADR-005, `.claude/commands/owl/evolve.md`

## Contexto
The first fully-autonomous scheduled cycle (2026-07-24) exposed a real reliability bug. `/owl:evolve` said *"Invocar @scout"*, but the-owl's agents are **slash-commands** (`.claude/commands/agents/*.md`), not Agent-tool subagents — there is no `.claude/agents/`. In a headless `claude -p` run there is no interactive `@scout` resolution, so the orchestrator spawned a bare `general-purpose` subagent with no concrete instructions. It **returned 0 tool-uses and wrote nothing** ("subagent no-op'd, redone inline" in the log). The cycle recovered by chance, but the failure was **silently absorbed** — a no-op that produced no research could just as easily have slipped through and corrupted a cycle.

## Decisão
Make the loop's execution model explicit and verified:
1. **Inline by default.** Each phase is executed by the orchestrator **reading the agent's `.md` and following it inline** — the most reliable path in a single headless session. No subagent round-trip that can return empty.
2. **Delegation is optional and must be complete.** If a subagent *is* spawned, it must receive the **full contents** of the agent file as its prompt (never just `@name`).
3. **Mandatory output verification (harness discipline).** Every phase declares an expected artifact; after the phase, the orchestrator **confirms the artifact exists**. A no-op (no artifact) is a **failure → redo inline once → else abort + alert**. Never proceed over a phase that produced nothing.
4. **PR-open resilience.** Landing tries `gh`, then the GitHub API with a keychain/`GH_TOKEN` token; if no token is in the environment (e.g. launchd), it leaves the branch pushed and records the compare URL for the human — the cycle never fails for lack of a PR.

## Alternativas consideradas
- **A (chosen): inline-by-default + per-phase output verification.** Pros: eliminates the no-op class of bug; verification catches any future silent failure; no dependency on a subagent registry the-owl doesn't have. Cons: the orchestrator context does more per cycle (acceptable — phases are sequential and bounded).
- **B: create real Agent-tool subagents (`.claude/agents/scout.md` …).** Pros: true isolation per phase. Cons: duplicates the agent definitions into a second location, risks drift, and still needs output verification anyway — rejected for now (revisit if cycles grow too large for one context).
- **C: leave it (rely on the lucky inline recovery).** Cons: the exact silent-failure we must not have in an autonomous loop — rejected.

## Consequências
- **Easier / safer:** cycles are deterministic about *how* each phase runs; a no-op can no longer pass unnoticed; scheduled (tokenless) runs still complete and hand off a reviewable branch.
- **Trade-offs:** more work in the orchestrator's context per cycle; if a future cycle is huge, option B (real subagents) is the escape hatch.

## Notas de implementação
Edited `.claude/commands/owl/evolve.md`: added an "Execution model" section; converted L1–L5 from "Invocar @agent" to "executar inline `<agent>.md`"; added a ✅ **Verificar** checkpoint to L0–L3; added the PR-open fallback to L5. No carve-out contact. Human-driven → committed to `main`.
