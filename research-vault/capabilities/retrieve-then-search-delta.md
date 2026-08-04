---
title: Retrieve-then-search-delta (skill-side dedup before research)
type: capability
tags: [retrieve-delta, dedup, ledger, progressive-disclosure, skill-index, reflection]
verified_on: 2026-08-03
verified_by: harness discipline observed in the-owl loop (curator checks ledger + L1.5 grounding before scoring); ledger dedup rows
status: verified
---

## What it is

A reflection-loop technique: **before doing new research, retrieve what is already decided, inject it as an exclusion list, and search ONLY the delta** — net-new ideas, recency updates, or contradictions of a settled decision. It is the owl port of the Hermes progressive-disclosure / skill-index mechanism (see [[hermes-agent-reference]]): a terse index is read *skill-side* first, so the expensive search never re-derives what's already known.

## How the-owl uses it

Concretely, the loop is **retrieve → diff → act**, not re-derive:

1. **Retrieve decided-ids skill-side.** The curator reads `ledger.md` first; a decided `id` (accepted/rejected/deferred) is **skipped, never re-argued**. The ledger is the dedup source of truth.
2. **Retrieve the terse indexes.** `patterns/index` and `capabilities/index` are one-line-description tables kept deliberately terse **precisely so the research skill can grep them** as the Level-0 disclosure — a decided pattern/capability is recognized before any web work.
3. **L1.5 grounding against real code** (`já_implementado?` / `onde_está_o_gap` / `arquivo_alvo`) **before scoring**, so the loop never proposes what already exists.
4. **Search only the delta.** Every cycle the brief's ideas are aliased against the ledger (e.g. `bounded-role-charters`→`role-ownership`); only genuinely net-new / recency / contradiction candidates get scored. Multiple cycles land **0 accepts** exactly because the delta was empty — the intended outcome.

## Verified facts

- **The ledger is an authoritative exclusion list.** Cycle blocks in `ledger.md` show brief ideas being mapped to already-decided ids and *not re-litigated* — e.g. cycle 2026-08-03: *"4 aliases of already-decided ids, not re-litigated."* This is the injected-exclusion-list step, real and enforced by curator discipline.
- **Terse index by design.** The pattern/capability index rows are one-liners specifically to be greppable Level-0 gates (progressive disclosure): read the index, only open the full page on a hit.
- **Guards two failure modes:** *re-litigation* (spending a cycle re-deciding a settled question) and *redundant proposals* (adding something already implemented). Grounding-against-your-own-state before proposing is the fix.

## Pitfalls

- **Skipping the ledger read** → re-litigation: burning a cycle re-scoring a settled id. The retrieve step is not optional.
- **Fat index rows** → the grep-gate stops working; keep index descriptions terse or the Level-0 disclosure collapses into "read everything."
- **Treating an alias as net-new** → false accept. Always alias-map a brief id to its ledger equivalent before scoring.
- **`prompt_redesign` is a ledger id, not an ADR.** The originating write-up lives in the pattern files ([[self-improvement-and-memory]]), *not* in `docs/decisions/` — do not cite a non-existent ADR number for it.

## Related

- [[self-improvement-and-memory]] — the parent pattern (retrieve-then-delta reflection loops; ported Hermes mechanisms)
- [[hermes-agent-reference]] — the source mechanisms (progressive disclosure / skill-index) this ports
- [[ADR-017-convention-staleness-review]] — the "re-examine old decisions" complement
- ledger id: `prompt_redesign` (pattern-file origin, no ADR)
