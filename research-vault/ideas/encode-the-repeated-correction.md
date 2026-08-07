---
title: "A repeated human-directed correction is a convention waiting to be written"
type: idea
tags: [self-improvement, memory, process]
sources: 1
status: accepted
score: 75
adr: "ADR-027"
updated: 2026-08-07
---
**Category:** self-improvement / memory · **Confidence:** med · **Applicability:** 4/5

## Pattern
The authoring trigger for a durable check is **behavioural, not analytical**: notice the correction you make *again and again* after the agent ships, and package it so it runs every time instead of depending on memory. The source states the selection rule directly — pick the manual follow-up you repeated most this week — and the drafting rule: write it in plain English as if onboarding a teammate on day one, then edit the generic version, because the *deviations* from generic carry the value.

Translated to the-owl: candidate conventions today have exactly **one** intake path — external research (L0 codex brief + L1 scout web). The owner's own repeated corrections are not an intake path at all, so a correction given twice is never detected as a pattern.

## Proposed change to the-owl
**Accepted scope is the atomic slice, not the broad framing.** Add an additive step to the curator flow: when scoring, read the **human-directed** entries in `research-vault/log.md` since the previous cycle and give each one a `ledger.md` row (status `human-directed`, no score). A class of correction that appears **≥2×** across cycles is raised as a normal candidate on the next pass, scored by the standard rubric.

Deliberately **not** accepted: the broad "turn every owner correction into a convention" framing — unbounded, and it would let a one-off preference calcify into a rule.

## L1.5 self-audit (ADR-005)
- `já_implementado?` **No.** `grep -rniE "correção repetida|owner feedback|repeated correction"` over `docs/`, `.claude/commands/`, `research-vault/patterns/` returns **zero hits**. `/owl:evolve` L0→L2 sources candidates only from the codex brief and scout's web pass; no path exists from an owner correction to a scored candidate.
- `onde_está_o_gap` **Human-directed changes bypass `ledger.md` entirely** — and `ledger.md` is the declared dedup source of truth (SCHEMA.md). Since 2026-07-24 the log records ~6 human-directed interventions (rollout completion, backlog score pass, MCP spec ingest ×2, native-subagents branch, and today's scout source-surface widening). Only the ones that happened to become ADRs left a ledger trace. **Today's cycle is itself the demonstration:** the owner's correction — "the lane only searches `anthropic.com/engineering`, add `claude.com/blog`" — landed as a prompt edit in `scout.md` with **no ADR and no ledger row**. If the same class of correction recurs in three cycles, nothing in the system can notice.
- `arquivo_alvo` `.claude/commands/agents/curator.md` — one additive step (the ADR-017 shape, which added step 4.5 to this same file). Outside the NFR-SEC-1 carve-out.

## Curator verdict — score 75 (threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 22 | Markdown-only, one additive curator step + a row format. Curator already owns `ledger.md`. Hub-spoke and context-minimal untouched. Structurally identical to ADR-017 (accepted 82), which also edited `curator.md`. |
| Evidence strength (20) | 14 | ONE first-party primary ([[claude-code-verification-loops-skills]]), claim **verified verbatim this cycle** (below). Single-source, and the-owl-specific translation is my engineering, not the source's — so no ceiling credit. |
| Impact (20) | 13 | Gap is grounded and **demonstrated in this very cycle** (today's un-ledgered scout edit), not hypothetical. Bounded: weekly cadence, one owner. **Structural/process, not behavioural** ⇒ per the ADR-017 precedent the ADR-015 discount barely applies. |
| Simplicity & reversibility (15) | 12 | Additive, atomic, revertible; no new runtime; no new file. |
| Safety (10) | 9 | **≥ safety_floor 7.** No new surface; strictly *increases* auditability. Touches `curator.md` only — never the carve-out. |
| Non-duplication (10) | 7 | ADR-017 covers the **reverse** direction (do old conventions still pay?). Nothing covers "a change entered the system without a ledger row." Adjacent enough to deduct. |

**Raw 77 → 75 after a −2 ADR-015 haircut** (structural/process, so the measured ~+15 behavioural-optimism bias barely applies — same reasoning the ledger recorded for `convention-staleness-review`). **75 = threshold ⇒ accepted, and explicitly PROVISIONAL.** It sits exactly on the line; if two cycles pass with the new step producing no ≥2× signal, it is ceremony and should be reverted.

> [!question]
> **Conflict of interest — disclosed, not dismissed.** The central Impact evidence for this candidate (the un-ledgered `scout.md` edit) was **produced by the same session that scored it**, an hour earlier, at the owner's direction. I then scored the idea that would have caught it. Three facts compound: (a) self-generated evidence, (b) landing **exactly** on the threshold, (c) breaking a four-cycle 0-accept run. That is the textbook shape of a motivated accept, and the −2 haircut is smaller than the measured +15.4 optimism bias because I judged this structural rather than behavioural — a judgement I also made about my own candidate. The precedent I leaned on (`convention-staleness-review`, 82) was scored on **external** evidence; this one is not.
> I did not lower the score, because I still believe the grounding (a `grep` returning zero mechanisms) is objective and independent of who noticed it. But the **provisional flag is carrying more weight here than usual**, and the revert condition below is the load-bearing safeguard, not a formality: **if two cycles pass with the new step producing no ≥2× signal, revert — and treat that outcome as confirmation of this bias, not as bad luck.** An owner review of this accept before L3 is warranted for that reason alone.

> [!important]
> **Bounded on purpose.** The mechanism only *records and counts*; it never auto-promotes. A correction reaching ≥2× becomes a **candidate**, scored by the normal rubric with the normal carve-out veto. An owner instruction must never become a convention by mere repetition — that would be a path around the rigor gate.

## Claim verification
_(ADR-013 — targeted confirmation fetch performed before accepting, 2026-08-07.)_
- **Claim:** the trigger for authoring a durable check is a *repeated manual correction*, and the procedure is written in plain English as if onboarding a new teammate.
- **Source:** [Building Verification Loops in Claude Code with Skills](https://claude.com/blog/building-verification-loops-in-claude-code-with-skills) — the cited primary.
- **Verdict:** **confirmed.**
- **Evidence:** the article's process list opens with — > "Pick the manual follow-up you did most often this week." — and states the drafting rule as writing the procedure in plain English, the way you would hand it to a new teammate on day one. Both retrieved verbatim on a targeted re-fetch; this supersedes the scout's summarizer-only pass, which is why [[claude-code-verification-loops-skills]] now carries a verified-quote section.

## Related
- **Sources:** [[claude-code-verification-loops-skills]] · [[scout-notes-2026-08-07]]
- [[self-improvement-and-memory]] · [[convention-staleness-review]] (the reverse direction — this idea is its missing counterpart) · [[externalized-checkpoint-memory]]
