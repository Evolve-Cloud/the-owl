# ADR-016 — Mid-cycle checkpoint for `/owl:evolve`

**Status:** Accepted
**Date:** 2026-07-26
**Author:** @architect (inline, cycle 2026-07-26)
**Tags:** [reliability, orchestrator, state]

## Contexto
`.owl/state/` currently holds only `last-run.json`, written **once, at the end** of a completed `/owl:evolve` cycle (`evolve.md` → "Circuit breaker" section). There is no record of a cycle **in progress**. ADR-010 already documents a related near-miss: the 2026-07-24 cycle's orchestrator spawned a bare subagent that returned 0 tool-uses and wrote nothing — the failure was "silently absorbed" and the cycle happened to recover by luck, not by design. If a future cycle is interrupted mid-flight (say, after L3 integrate has written an ADR + edit but before L4's gate has run), the next invocation of `/owl:evolve` has no way to tell "nothing ran today" from "a cycle died halfway through with a half-landed change" — it would either silently re-run L0 from scratch (wasting the codex research spend) or, worse, not notice an ADR/edit pair that never passed the L4 gate.

This gap was surfaced by research idea `externalized-checkpoint-memory` (`research-vault/ideas/externalized-checkpoint-memory.md`, accepted 75/100 provisional, cycle 2026-07-26), grounded directly against the real `.owl/state/` directory (confirmed empty of any mid-cycle state) and confirmed via a live claim-verification fetch of LangGraph's checkpointer semantics (persist-outside-the-transcript → skip re-doing completed work on resume).

## Decisão
Add a **mid-cycle checkpoint file**, `.owl/state/cycle-in-progress.json`, written/updated by the `/owl:evolve` orchestrator after each phase (L0–L5) **passes its own existing verification step**. It records:
```json
{ "cycle_date": "YYYY-MM-DD", "last_phase_completed": "L0|L1|L1.5|L2|L2.5|L3|L4|L5", "ideas_in_flight": ["id", ...], "accepted_so_far": ["id", ...] }
```
At the **start** of a cycle (the existing "Setup" step in `evolve.md`), the orchestrator checks for this file. If it exists and is dated **today**, the orchestrator reports it to the human/log and **asks whether to resume from `last_phase_completed` or start a fresh cycle** — it never silently overwrites and never silently ignores it. On a normal L5 completion, the file is deleted (its content is already folded into the final `last-run.json`).

This is a **pure structured-artifact convention** — a JSON file the orchestrator itself reads/writes as part of following `evolve.md`'s own instructions. It introduces no runtime, no new dependency, and no agent `.md` file changes (this is orchestrator-only, consistent with ADR-010's model of "the orchestrator does more per cycle").

## Alternativas consideradas
- **Alternativa A (escolhida): a single JSON checkpoint file, updated after each phase's existing verification step.** Pró: minimal — reuses the exact per-phase verification `evolve.md` already has (L0–L5 each already declare "✅ Verificar: ..."); the checkpoint write piggybacks on a check that already runs, so it costs nothing new to *compute*, only to *persist*. Con: doesn't capture sub-phase state (e.g. which of several accepted ideas in L3 finished vs. not) at finer granularity than "the phase as a whole completed" — accepted as sufficient, since the circuit breaker cap (3/cycle) keeps L3's per-idea loop small.
- **Alternativa B: a full event log (append-only, one line per sub-step).** Pró: finer-grained resumability, an audit trail "for free." Con: more moving parts, another file to reconcile at cycle-end into `last-run.json`, and no concrete evidence yet that finer granularity is needed (the observed near-miss in ADR-010 was a whole-phase no-op, not a partial-phase failure). Rejected as over-engineering for a risk that hasn't been observed at that granularity.
- **Alternativa C: do nothing, rely on `last-run.json`'s absence as the "cycle didn't finish" signal.** Con: `last-run.json` is silent about *whether* a cycle is currently running vs. never started — it can't distinguish "no cycle ran today yet" from "one is half-done right now," which is exactly the ambiguity ADR-010's near-miss showed can be dangerous. Rejected — this is the status quo the idea was accepted specifically to fix.

## Consequências
- **Easier:** a future interrupted cycle is detectable and resumable (or at minimum, diagnosable) instead of silently ambiguous; a human re-running `/owl:evolve` after a crash gets an explicit resume-or-fresh choice instead of the orchestrator guessing.
- **Harder / slower:** the orchestrator now does one more file read (Setup) and one more file write (after each phase) per cycle — negligible cost, no added latency of consequence.
- **New risk:** none to safety (the file lives in `.owl/state/`, already the loop's own scratch space; it doesn't touch `.owl/loop-config.yml` or any carve-out path). The one operational risk is the file itself going stale (e.g. a developer manually kills a cycle without cleanup) — mitigated by the "dated today" check: a checkpoint from a prior day is treated as stale and ignored (logged, not silently deleted, so a human can inspect it if curious).

## Notas de implementação
- **`@builder` touches exactly one file:** `.claude/commands/owl/evolve.md`.
  - In **"Setup (ler antes de começar)"**: add a step — check for `.owl/state/cycle-in-progress.json`; if present and dated today, surface it (log + ask resume-vs-fresh) before proceeding.
  - After **each** of L0/L1/L1.5/L2/L2.5/L3/L4/L5's existing "✅ Verificar" step passes: write/update `.owl/state/cycle-in-progress.json` with the phase name + in-flight idea ids.
  - In **"L5 — Land + registrar"**: on normal completion (after `last-run.json` is written), delete `.owl/state/cycle-in-progress.json`.
  - In **"Circuit breaker (HARD STOP)"**: note that an abort (consecutive gate failures, or a phase that fails twice) leaves the checkpoint file in place **on purpose** — it's the record of where the cycle stopped, for the human to inspect.
- **Verify:** no carve-out path touched (`.claude/commands/owl/evolve.md` is editable); the diff is additive (no existing instruction removed); `docs/decisions/000-template.md` format followed.
- **This is this cycle's only accepted change** (circuit breaker: 1 accepted ≤ cap 3) — the ADR-015 self-haircut applied to this idea's score (83 raw → 75) means the L4 gate should weigh the "provisional" framing seriously: if this checkpoint mechanism goes unused or the resume-prompt proves to be noise nobody acts on, ADR-014/015's keep/revert framing applies here too.
