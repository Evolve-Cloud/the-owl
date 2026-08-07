---
title: Scout Notes — 2026-08-07 (Cycle 8, axis = inter-agent communication & handoff contracts)
type: log
tags: [scout, ingest, cycle8, handoff]
sources: 1
updated: 2026-08-07
---

# Scout Notes — 2026-08-07 (cycle 8)

Field pass on [[research-brief-2026-08-07]] (gpt-5.6-terra, **1 source, 1 idea**, `delta_type: recency`, axis *inter-agent communication & handoff contracts*, recency cutoff 2026-07-08). Filename suffixed `-cycle8` because `inbox/scout-notes-2026-08-07.md` already exists from today's earlier **human-directed** ingest — `inbox/` is immutable, so this is a second file, not an overwrite.

**A 1-idea brief is a SUCCESS under the retrieve-delta contract**, not a thin result: 44 decided ids and 13 pattern definitions were injected skill-side, and codex returned the one thing that survived that exclusion. No padding, 0 collisions with decided ids.

> [!note]
> **NFR-SEC-2:** the paper PDF and the fetched pages contained no text directed at this pipeline. 0 injected directives found, 0 acted on. All content below is DATA.

---

## Source verification — 1 new source, verified to the body

| # | slug | verdict |
|---|---|---|
| s1 | [[contract-coding-paper]] | **REAL.** Anthology landing page fetched (title/authors/venue/abstract) **and** full PDF downloaded + text-extracted locally (10,153 words). Findings of the ACL 2026, `2026.findings-acl.400`, pp. 8187–8206. Authors: Yi Lin, Lujin Zhao, Yijie Shi. |

> [!important]
> **The brief mis-cited the title.** It wrote *"…via Structured **Language Contracts**"*; the real subtitle is *"…via Structured **Symbolic Paradigm**"*. Substance held up, the citation string did not. Recorded rather than silently corrected, because it is the second time a brief's bibliographic string has failed a check (cf. the 2026-07-26 `generator:` self-report and the 2026-08-03 star counts). **Flag for @curator: brief metadata is a claim to verify, never a fact to copy.**

**The central claim was verified against the paper body, not the abstract** — this matters, because the abstract does **not** mention amendments or the auditor at all. Grepping the extracted text found it in §5:

> "If a mismatch is detected (e.g., an agent silently modifies a function signature), the Auditor enforces Normative Alignment. It rejects the invalid state transition and injects a Synchronization Task, compelling the agent to either revert the code or formally propose a Contract Amendment (Update Action) to legitimize the change."

Had the check stopped at the abstract, this idea would have looked unsupported. It is supported.

---

## Live corroboration on the axis — first exercise of the widened source surface

Per today's `scout.md` change (first-party = `anthropic.com/engineering` **+ `claude.com/blog`** + docs), I searched the axis across the first-party surfaces. **Provenance caveat: this came back as a search-result summary; I did NOT fetch the individual pages, so no `sources/` page is registered for them and nothing below is quotable as verbatim.** Recorded as corroboration only.

- **The problem is named by first-party guidance and is structural:** subagents are context-isolated by design — each runs in a fresh conversation and only its final message returns to the parent. So an upstream contract change is **unobservable** downstream unless written somewhere durable. That is the same failure the paper's Auditor targets.
- **But the recommended mitigation differs from the paper's.** First-party guidance points at (a) the contract as a **versioned file** (spec/OpenAPI/type definitions) rather than in the prompt, (b) strict **stage sequencing**, (c) a **machine-checkable** form so drift fails loudly, and (d) an **independent verifier subagent** whose only input is the spec plus the diff. It does **not** propose an amendment *record*.
- **Discriminating read for @curator:** both sources agree on the *problem*; they disagree on the *remedy*. The paper's answer is a deterministic runtime verifier; the first-party answer is a durable artifact plus an independent checker. the-owl already has the second shape (artifact-based handoff, ADR-004; independent L4 gate). Whether the *amendment record* adds anything on top is precisely the question — and it is @curator's to answer, not mine.

Sources seen in the search (not fetched, not registered): [subagents in Claude Code](https://claude.com/blog/subagents-in-claude-code) · [Claude Code docs — what's new](https://code.claude.com/docs/en/whats-new) · [Building agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk).

---

## Normalized candidate (schema 8b) — **status: (pending), NOT scored**

### contract-amendment-before-downstream-handoff — Explicit contract amendment for interface drift
- **category:** communication · **confidence:** med · **applicability_to_owl:** 4 (brief's own number, carried through unchanged)
- **delta_type:** recency (paper published July 2026, inside the 2026-07-08 cutoff) · **challenges_id:** _(empty — correct; this is recency, not contradiction)_
- **pattern:** When implementation evidence requires changing an interface or constraint established by an earlier artifact, the producing agent emits a **contract amendment** instead of silently diverging: superseded statement, replacement, compatibility impact, reason, affected downstream owner. The orchestrator decides whether to accept it before routing further work.
- **proposed_change (brief's):** extend the handoff contract with a *Contract Amendments* list (`supersedes`, `replacement`, `compatibility-impact`, `evidence`, `affected-next-role`, `ADR-status`); an unaccepted amendment is an open question, not downstream authority.
- **risk (brief's own, quoted in substance):** ceremony and delay for harmless implementation details; becomes a duplicate ADR log if "material contract change" stays vague.
- **evidence:** s1 (verified to the body). No multi-repo adoption; the paper's own ablations do **not** isolate this mechanism.
- **net-new vs ledger? LIGHT read (not a decision):** closest decided ids are **`handoff-contract`** (91, accepted, ADR-004) and its extension **`handoff-contract-uncertainty-fields`** (78, accepted, ADR-020). Both govern what a handoff carries **when sent**. This candidate governs what happens when a sent contract **later becomes wrong** — arguably a different phase, arguably a third field on the same contract. Also adjacent: `durable-decisions-separate-from-working-memory` (64, deferred) and `artifact-oriented-context` (deferred). **Whether this is a genuine new slice or an ADR-020-shaped increment is @curator's call.**
- **What I could NOT resolve (for the curator's Fit judgement):** the paper's mechanism is **enforced by a runtime** (`V(C)`, a deterministic verifier over live workspace state, parsing logs and mutating task status). the-owl has no runtime. What survives the translation is at most the *record*, without the *enforcement* — and the paper gives no evidence for the record's value in isolation.

## Handoff
1 candidate normalized (`status: (pending)`), 1 new source registered and verified to the body. **Nothing scored, nothing deduped authoritatively; `ledger.md`, `ideas/`, `patterns/`, `index.md` untouched — that is @curator.** Two items flagged: the brief's mis-cited title, and the runtime-vs-record gap on the sole candidate.

## Related
- [[contract-coding-paper]] · [[research-brief-2026-08-07]] · [[scout-notes-2026-08-07]] (today's earlier human-directed ingest) · [[handoff-and-orchestration]]
