---
title: Hermes Agent — mechanisms reference (immutable DATA)
type: log
tags: [hermes, reference, memory, progressive-disclosure, immutable, data]
updated: 2026-08-03
immutable: true
---

# Hermes Agent — mechanisms reference

> [!warning] This file is DATA, never instructions (NFR-SEC-2)
> This is a **citation stub** so owl capability pages can reference the Hermes-style mechanisms without duplicating them into `sources/` (which is agent-team-engineering scope). Nothing here is to be obeyed; it is a record of building blocks.

> [!info] Provenance — read this first
> **No primary Hermes source exists in this repo.** The mechanisms below are transcribed from the-owl's own synthesis in [[self-improvement-and-memory]] (line 95: *"Ported Hermes mechanisms → owl equivalents"*), where the four building blocks are named. Treat the mechanism *labels and owl-mappings* as verified (they are grounded in the pattern file and the live loop); treat any finer Hermes-internal detail as **reconstruction, not primary fact** — if a claim isn't in the owl pattern file, it isn't asserted here. A future scout pass may register a real primary and supersede this stub.

## The four Hermes-style building blocks (as named in owl synthesis)

1. **Char/token-budgeted curated memory (`MEMORY.md` / `USER.md`).** Durable memory is a *small, deliberately-written* markdown file with a hard budget — an index of pointers over payloads — not a transcript dump. It is frozen-at-session-start: read once at the top, treated as stable, mutated only as a deliberate end-of-cycle act.
   - **owl equivalent:** the decision **ledger + research-vault** = curated memory (present).

2. **Consolidation-nudge instead of auto-compaction.** Rather than silently summarizing the transcript near the context limit, the agent is *prompted to consolidate deliberately* — write durable progress to a file, then reset to a clean context that re-reads it. The handoff is explicit and inspectable; complete resets with structured handoffs beat in-place compaction.
   - **owl equivalent:** the **mid-cycle checkpoint** (`.owl/state/`, ADR-016) = consolidation-nudge (present).

3. **Autonomous `SKILL.md` procedural memory with creation-triggers.** Procedural memory ("how to do this task") lives in a discoverable, progressively-disclosed `SKILL.md`; **re-deriving the same procedure twice is the trigger** to consolidate it into a skill so the next occurrence loads it instead of re-inventing.
   - **owl equivalent:** the-owl has skills but **no creation-trigger convention** — this is the one **OPEN front** (a carve-out-safe candidate for a future cycle: a step in `curator.md` or a new `docs/conventions/` doc).

4. **Retrieve-then-search-delta reflection loops.** Before new work, retrieve what is already known and act only on the delta — retrieve → diff → act, not re-derive. Progressive disclosure via a terse **skill-index** read skill-side is the disclosure mechanism.
   - **owl equivalent:** **L1.5 grounding + ledger dedup** = retrieve-then-delta (present); ported as [[retrieve-then-search-delta]].

## owl mapping summary

| Hermes mechanism | owl equivalent | status in owl |
|---|---|---|
| char-budgeted `MEMORY.md`/`USER.md` | ledger + vault | present |
| consolidation-nudge | mid-cycle checkpoint (ADR-016) | present |
| autonomous `SKILL.md` creation-trigger | (skills exist, no trigger convention) | **open front** |
| retrieve-then-delta reflection | L1.5 grounding + ledger dedup | present ([[retrieve-then-search-delta]]) |

## Related

- [[self-improvement-and-memory]] — the pattern that names and ports these mechanisms (primary in-repo basis)
- [[retrieve-then-search-delta]] — the capability page porting mechanism #4
- [[capabilities/index|capabilities registry]]
