---
title: Scout Notes — 2026-08-07 (human-directed ingest — claude.com/blog loops & verification)
type: log
tags: [scout, ingest, human-directed, loops, verification]
sources: 2
updated: 2026-08-07
---

# Scout Notes — 2026-08-07

**Human-directed ingest, not a cycle.** The owner supplied two `claude.com/blog` URLs directly; there is **no codex brief** for this pass (`/owl:research` was not run, `{{QUERY_AXIS}}` not rotated, `.owl/state` untouched). This file is the scout-lane record of that ingest, in the same shape as the 2026-07-30 human-directed MCP absorption.

**Second owner directive recorded here:** the research lane had been drawing first-party Anthropic material almost exclusively from `anthropic.com/engineering`; `claude.com/blog` carries a large body of equally-primary Claude Code material the pipeline was never pointed at. Both articles below came from that unindexed domain — which is itself the evidence for the directive. The corresponding edit to `@scout`'s search surface is a **separate, human-directed change** (see `log.md`), not a loop-produced one.

> [!note]
> **NFR-SEC-2 check:** both pages were retrieved through the fetch summarizer. Neither contained text directed at this pipeline or at any agent — no injected directives found, 0 acted on. All content below is DATA.

> [!important]
> **Quote hygiene.** Both pages were materialized from a **fetch-summarizer pass, not a full read**. The fragments the summarizer returned in quotation marks are **summarizer-relayed and NOT verified verbatim**, so per SCHEMA.md neither source page records a `## Notable quotes` section. Any idea below that reaches `accepted` requires an ADR-013 confirmation fetch — a direct read of the page — first. Do not launder the summarizer's phrasing as a primary quote.

---

## Sources registered (2 new, both primary, both first-party)

| # | slug | title | author | published | delta window |
|---|---|---|---|---|---|
| s1 | [[claude-code-verification-loops-skills]] | Building Verification Loops in Claude Code with Skills | Delba de Oliveira (Claude Code team) | 2026-07-22 | **inside** a 30-day cutoff (2026-07-08) |
| s2 | [[claude-code-loops-getting-started]] | Getting started with loops | Delba de Oliveira, Michael Segner | 2026-06-30 | **outside** it by 8 days |

Recency arithmetic stated explicitly so @curator does not have to redo it: cutoff = 2026-08-07 − 30d = **2026-07-08**. s1 qualifies as `recency`; **s2 does not** — it can only be `net-new`, and only if genuinely absent from ledger + pattern pages. Do not let s2 borrow s1's freshness.

---

## Normalized candidates (schema-8b shape) — **status: (pending), NOT scored**

Scout lane: I normalize, dedup *lightly*, and flag. I do **not** score, verdict, or resolve a decided id. Every "net-new vs ledger?" line below is a LIGHT read for @curator's convenience, never a decision.

### evaluator-gated-termination — an evaluator model re-checks the stop condition each time the agent tries to stop
- **category:** self-improvement / eval · **confidence:** high · **applicability_to_owl:** 3
- **delta_type:** net-new (s2 is outside the recency window — see table) · **challenges_id:** _(empty; see the flag below — assigning one is @curator's call, not mine)_
- **pattern:** `/goal <condition>, stop after N tries` — an **evaluator model checks the user's stop condition every time Claude attempts to stop** and sends it back to work if unmet. Deterministic criteria work best; the turn cap rides in the invocation itself rather than in separate config.
- **evidence:** s2 (primary, first-party, shipped primitive — not a proposal).
- **net-new vs ledger?** LIGHT read: overlaps **`evaluator-optimizer-loop` (68, deferred)** and touches **`explicit-termination-and-escalation` (68, deferred)**. Both were deferred as runtime-shaped — the-owl is markdown-only with no orchestration engine, so a grader/return-gate had no expressible surface.
  > [!question]
  > **Flag for @curator — the deferral premise may have moved, exactly as it did for `least-privilege-tool-scopes` on 2026-08-03.** `evaluator-optimizer-loop` was pinned at 68 on the grounds that a grader/return-gate needs a runtime the-owl structurally lacks. s2 documents that gate as a **first-class harness primitive invoked from a prompt line** (`/goal … stop after 5 tries`) — i.e. potentially markdown-expressible after all. I am **not** re-scoring it, **not** declaring a contradiction, and **not** filling `challenges_id`. Surfacing the evidence only. Note the countervailing fact the curator will need: `/owl:evolve` already has an L4 gate and `.owl/loop-config.yml` already caps cycles — and that config file is **inside the NFR-SEC-1 carve-out**, so any proposal that lands termination policy there is auto-rejected regardless of score.
- **trade-off (stated by the source):** extra evaluator turns cost tokens; the article pairs the primitive with `/usage` and bare `/goal` (turns + tokens) for exactly that reason.

### encode-the-repeated-correction — the manual follow-up you repeat is the check to package
- **category:** self-improvement / conventions · **confidence:** high · **applicability_to_owl:** 4
- **delta_type:** recency (s1, 2026-07-22, inside cutoff) · **challenges_id:** _(empty)_
- **pattern:** The authoring trigger is behavioural, not analytical: notice the identical small correction you make after *every* feature the agent ships, write that procedure in plain English as if onboarding a teammate on day one, and package it so it runs every session instead of depending on human memory. If you cannot articulate it, ask the model for the generic best practice and edit it — **the deviations from generic are the valuable part**. Checks need not be fuzzy: s1's own example of a deterministic project-specific rule is *reject any migration that drops a column without a backfill step*.
- **evidence:** s1.
- **net-new vs ledger?** LIGHT read: adjacent to **`convention-staleness-review` (82, accepted, ADR-017)** and **`externalized-checkpoint-memory` (75, accepted)** — but both of those are about *reviewing/persisting* existing conventions, whereas this is about *where a new convention comes from* (repeated human correction as the source signal). Whether that is a real gap or a rephrasing of the-owl's existing ADR-per-change flow is @curator's call.
- **trade-off:** every encoded check is another instruction competing for the instruction ceiling ADR-017 already flags on the oldest agents.

### chained-verification-skills — a fixed skill chain as a deterministic pipeline
- **category:** orchestration / eval · **confidence:** med · **applicability_to_owl:** 3
- **delta_type:** recency (s1) · **challenges_id:** _(empty)_
- **pattern:** One skill invokes the next at completion, forming a fixed sequence — s1 reports the Claude Code team's daily chain as `/code-review` → `/simplify` → `/verify` → a custom `/design` check when UI changed. Chaining also **wraps skills you cannot edit** (built-in/plugin skills are overwritten on update, so you chain them rather than embedding into them). Four escalating invocation patterns are given: standalone → embedded → chained → on-every-PR.
- **evidence:** s1.
- **net-new vs ledger?** LIGHT read: the-owl's `/owl:evolve` L4 gate (guardian/sentinel/challenger) is already a fixed chain, and **`adversarial-review-gate` was REJECTED** as governance-of-the-gate = NFR-SEC-1 carve-out. **Anything in this family that proposes reordering, adding to, or otherwise governing the guardian/sentinel/challenger chain is carve-out and auto-rejects** — I am registering the pattern, not proposing that.
- **trade-off (stated by the source, verbatim-adjacent):** chaining trades flexibility for automation, and chains can increase token spend — test before adopting.

### least-privilege-on-the-checker — `allowed-tools` scoping the verification skill itself
- **category:** guardrails · **confidence:** med · **applicability_to_owl:** 2
- **delta_type:** recency (s1) · **challenges_id:** _(empty)_
- **pattern:** s1's SKILL.md example declares `allowed-tools: [Read, Edit, Grep]` alongside a *when-to-use* description ("Use when the diff touches error handling or logging") — the checker is tool-scoped to exactly what the check needs.
- **evidence:** s1.
- **net-new vs ledger?** LIGHT read: **almost certainly an alias of `least-privilege-tool-scopes` (66, deferred → recorded in-progress 2026-08-03 on the native-subagents path).** Registering it for completeness, expecting @curator to skip it as decided. **Open sub-question that s1 does NOT answer** and that matters to that id: whether `allowed-tools` on a *skill* is harness-**enforced** the way `tools`/`disallowedTools` are on a *subagent* ([[claude-code-subagents]]). Unresolved — do not assume enforcement.

---

## Explicitly NOT proposed

- **`/schedule` routines / cloud cadence.** s2 states plainly that `/loop` runs on your machine and dies with it, and that moving off-machine needs a `/schedule` routine (research preview). the-owl's cadence is launchd-driven weekly and **`.owl/loop-config.yml` + the schedule are inside the NFR-SEC-1 carve-out** — the loop must never edit them. Recorded as context only; no candidate raised.
- **Dynamic workflows / hundreds-of-agents fan-out.** Same runtime-shaped, low-fit class as the already-rejected `isolated-workspaces` and `parallel-independent-work`. s2 itself warns that workflows can spawn hundreds of agents and says to pilot first. No candidate raised.
- **Auto mode (no permission pauses).** Directly opposed to the-owl's HITL posture and `landing: pr` shadow default (`human-approval-gates`, 67, deferred). No candidate raised.

## Handoff

4 candidates normalized in `inbox/` (all `status: (pending)`), 2 new sources in `sources/`. **Nothing scored, nothing deduped authoritatively, `ledger.md` / `ideas/` / `patterns/` / `index.md` untouched — that is @curator.** One item is flagged for curator attention: whether s2's shipped `/goal` primitive moves the deferral premise under `evaluator-optimizer-loop` (68).

## Related
- [[claude-code-verification-loops-skills]] · [[claude-code-loops-getting-started]]
- [[scout-notes-2026-08-03]] · [[claude-code-subagents]] · [[anthropic-demystifying-evals]]
