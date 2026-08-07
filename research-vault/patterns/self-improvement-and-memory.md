---
title: Self-improvement & memory
type: pattern
tags: [memory, self-improvement, consolidation, skills, adr, staleness, context, long-horizon]
sources: 5
updated: 2026-08-03
---

## Definition

**Self-improvement & memory** is the discipline by which a long-running agent (or agent *team*) carries knowledge, decisions, and procedures **across context windows and across cycles** — so that each new session does not start from zero, and a settled decision is never re-litigated. It is the load-bearing pattern for **this** project: the-owl is a weekly self-improvement loop whose entire value depends on knowledge *compounding* rather than evaporating with each context reset.

The pattern has two faces that reinforce each other:

- **Memory** — durable, *curated* state that lives **outside** the transcript (files, git, an ADR trail, a decision ledger, a `SKILL.md`), re-read at session start instead of held in a fragile chat history.
- **Self-improvement** — the loop that *reads that memory first*, computes only the **delta** against it, lands a durable decision, and periodically re-examines whether old decisions still earn their keep.

The unifying principle: **treat memory as a small, high-signal, deliberately-written artifact — not a transcript dump — and make improvement a retrieve-then-act loop over it, not a from-scratch re-derivation.**

## Key ideas

### 1. Curated markdown memory (MEMORY.md / USER.md), frozen at session start

Durable memory is a **small curated markdown file** (`MEMORY.md`, `USER.md`), not the raw conversation. Three properties make it work:

- **Character/token budget.** Memory competes for the same finite attention budget as everything else (see [[context-engineering]] — context is a *depleting* resource). An unbounded memory file is context rot waiting to happen. A hard char budget forces the writer to keep only load-bearing rules and evict the rest.
- **Curation over accumulation.** What lands in memory is a *decision* — an index of pointers ("see `HISTORY.md` on demand") over payloads. This is just-in-time retrieval applied to memory itself: the always-loaded file stays tiny; the detail is one hop away.
- **Frozen-at-session-start injection.** Memory is read **once**, at the top of the session, and treated as stable for that session. It is not re-mutated mid-turn on every thought — that would make behavior non-reproducible and let a single bad turn poison the durable store. Writes to memory are a deliberate, end-of-cycle act.

### 2. Consolidation-nudge instead of auto-compaction

Two ways to handle a filling context window:

- **Auto-compaction** — silently summarize the transcript near the limit and continue. Cheap, but lossy and *invisible*: the agent can't tell what was dropped, and "context anxiety" makes models prematurely wrap up as they sense the limit approaching ([[harness-design-long-running-apps]]).
- **Consolidation-nudge** — instead of auto-summarizing, *prompt the agent to consolidate deliberately*: write the durable progress out to a file, then reset to a clean context that re-reads that file. The handoff is explicit and inspectable. [[effective-harnesses-long-running]] found **complete context resets with structured handoffs outperformed in-place compaction** on Sonnet 4.5 — the reset forces a legible progress artifact, whereas compaction quietly degrades.

The nudge is the memory-write trigger: consolidation is *when* curated memory gets updated, and the clean restart is *when* it gets injected. Compaction and reset are complementary, not exclusive — but the reset path is what produces durable memory as a side effect.

### 3. Autonomous SKILL.md procedural memory, with creation triggers

Declarative memory ("what is true") is not enough; agents also need **procedural** memory ("how to do this task"). A `SKILL.md` folder is exactly that: a discoverable, progressively-disclosed unit of *procedure* — YAML frontmatter as a cheap relevance gate, the body and linked files loading only on demand ([[anthropic-agent-skills]]; *"like putting together an onboarding guide for a new hire"*).

The self-improvement move is to make skill **creation a triggered reflex**: when the agent (or loop) notices it has re-derived the same multi-step procedure more than once, that repetition is the *trigger* to consolidate it into a `SKILL.md` so the next occurrence loads the procedure instead of re-inventing it. Procedural memory thus grows the same way a codebase's SPDD canvas coverage grows ([[spdd-structured-prompt-driven-development]]): organically, one gap at a time, rather than all-up-front.

### 4. Retrieve-then-search-delta reflection loops

The core efficiency move of a compounding loop: **before doing new work, retrieve what is already known, and act only on the delta.** the-owl's loop is built this way — the curator **checks the ledger first** (a decided `id` is skipped, never re-argued), then does **L1.5 grounding** against the real code (`já_implementado?` / `onde_está_o_gap` / `arquivo_alvo`) *before* scoring, so it never proposes what already exists. This is retrieve → diff → act, not re-derive.

Two failure modes this guards against:
- **Re-litigation** — spending a cycle re-deciding a settled question. The ledger is the dedup source of truth precisely to prevent this.
- **Redundant proposals** — "adding" something already implemented. Grounding-against-your-own-state before proposing is the fix.

### 5. ADR-as-durable-decision-memory

A decision is only durable if it is **written down as a first-class, reviewable artifact** — not left implicit in a diff or a chat log. This is the shared shape across SPDD and the-owl:

- SPDD treats the **prompt-as-spec** as a version-controlled asset that must stay *synced* with the code ([[spdd-structured-prompt-driven-development]]): logic change → update the spec first; refactor → change code first, then sync the spec back. The spec is the durable memory of *intent*; drift between spec and code is the enemy.
- the-owl treats every accepted change as an **ADR in `docs/decisions/`** plus a **ledger row** — the durable memory of *why*. The chat that produced the change is disposable; the ADR is the memory.

Both make the same bet: the artifact of a decision (spec, ADR) outlives and outranks the conversation that produced it.

### 6. Staleness / re-fitness review

A loop that only *adds* memory accumulates cruft. A convention is adopted to compensate for a model weakness; when a stronger model no longer has that weakness, the convention becomes dead weight — extra prompt surface that costs attention budget and earns nothing.

> [!important]
> *"Every component in a harness encodes an assumption about what the model can't do... assumptions are worth stress testing."* — [[harness-design-long-running-apps]]. As models improve, memory and scaffolding must be **re-examined**, not just extended.

The counter-measure is a **backward pass**: each cycle, re-read the oldest / least-recently-validated memory and ask whether the current model still needs it. In the-owl this is a *curator judgment that recommends re-fitness* to a human — never an autonomous revert (that stays a human decision, per the NFR-SEC-1 carve-out). Memory has a maintenance loop, not just a growth loop.

## Evidence / sources

- [[harness-design-long-running-apps]] — self-evaluation skews positive (a separate evaluator makes skepticism tractable); "context anxiety" near the limit; **context resets + structured handoffs > in-place compaction**; "every harness component encodes an assumption… worth stress testing" (the staleness principle).
- [[effective-harnesses-long-running]] — the canonical statement of the memory problem: *"each new session begins with no memory of what came before."* Durable **progress files** + git-as-state + a **session-startup protocol** (read progress → review git log → run tests → select next feature) as the memory-injection mechanism.
- [[anthropic-agent-skills]] — `SKILL.md` as **procedural memory**: progressive disclosure (frontmatter gate → body → linked files → code), *"amount of context that can be bundled is effectively unbounded"* because it loads on demand.
- [[spdd-structured-prompt-driven-development]] — **spec/ADR-as-durable-decision-memory**: prompt-as-versioned-asset, two-way sync to prevent spec/code drift, coverage that grows organically one gap at a time. Also the honest limit: structure *narrows* but does not *eliminate* judgment variance ("pushes the variance problem up a layer").
- [[anthropic-trustworthy-agents]] — the safety envelope for autonomous memory-writing: **least-privilege scopes**, **tiered approval** (routine vs. consequential), *"no single line of defense is enough."* Grounds why memory *reads* can be autonomous but memory *reverts* stay human-gated.

> [!contradiction]
> [[harness-design-long-running-apps]] observed context-reset scaffolding that later became **unnecessary** as the model improved (Sonnet 4.5 → Opus 4.6). So "consolidation-nudge over auto-compaction" (idea 2) is itself a **staleness-prone assumption** (idea 6): the right amount of memory scaffolding is model-dependent and must be periodically re-tested, not fixed. The pattern contains its own expiry check.

## How it maps to the-owl

the-owl is **the** instance of this pattern — the research vault *is* the memory and the evolve loop *is* the self-improvement.

| Mechanism | the-owl's implementation | Status |
|---|---|---|
| Curated memory, frozen at start | Research vault (`sources/`, `patterns/`, `ideas/`) + `ledger.md`; read whole at cycle start (SCHEMA). CLAUDE.md kept to load-bearing rules, dated detail split to `HISTORY.md` on demand. | **Adopted** |
| Consolidation over auto-compaction | Curator *writes* synthesis (this page, `overview.md`) rather than letting the transcript compact away; ADR-016 mid-cycle checkpoint is a consolidation nudge. | **Adopted** |
| SKILL.md procedural memory | `.claude/skills/` + slash-command agents; second-brain / update-owl-agents skills package procedure. Autonomous *creation-triggers* are latent, not yet a named convention. | **Partial / gap** |
| Retrieve-then-search-delta | Curator checks **ledger first** (dedup), then **L1.5 grounding** against real code before scoring (ADR-005). | **Adopted** |
| ADR-as-decision-memory | Every change → an **ADR in `docs/decisions/`** + a ledger row; claim-verification against primary sources before landing (ADR-013). | **Adopted** |
| Staleness / re-fitness | **ADR-017** — curator re-reads the 1–2 oldest conventions each cycle and *recommends* re-fitness; never auto-reverts. Complements ADR-012 (forward rollout coverage) with a backward pass. | **Adopted** |
| Repetition ⇒ durable artifact (**owner side**) | **[[encode-the-repeated-correction]]** (accepted 75, provisional, 2026-08-07, ADR pending) — human-directed changes get a `ledger.md` row; a class recurring **≥2×** is raised as a normal candidate. Closes the *intake* hole: until now the only path to a candidate was external research (L0 codex + L1 scout), so an owner correction given twice was invisible to the dedup source of truth. | **Accepted, not yet integrated** |

**Ported Hermes mechanisms → owl equivalents.** The Hermes-style building blocks — char-budgeted `MEMORY.md`/`USER.md`, consolidation-nudge, autonomous `SKILL.md` creation, retrieve-then-delta reflection — land here as *this synthesis*. Their owl analogues already exist for four of five (ledger + vault = curated memory; checkpoint = consolidation-nudge; L1.5 + ledger = retrieve-then-delta; ADR-017 = staleness). The one **open front** was **autonomous SKILL.md creation-triggers**: the-owl has skills but no convention that says *"re-deriving the same procedure twice ⇒ consolidate it into a SKILL.md."* That is the atomic, carve-out-safe candidate a future cycle can concretize (a step in `curator.md` or a new `docs/conventions/` doc), scored through the normal rubric.

> [!important]
> **Half of that open front closed on 2026-08-07 — from the other side.** [[encode-the-repeated-correction]] (accepted 75, provisional) is the same principle — *repetition ⇒ durable artifact* — applied to the **owner's** repeated corrections rather than the **agent's** repeated derivations. It was concretized exactly as this paragraph predicted: an additive step in `curator.md`, carve-out-safe, scored through the normal rubric. Note the provenance, because it is the argument for the idea: the candidate did **not** arrive through the external-research lane. It came from an owner correction made mid-ingest (*"the lane only searches `anthropic.com/engineering`, add `claude.com/blog`"*) which landed as a prompt edit with **no ADR and no ledger row** — the very blindness it fixes.
> The **agent-side** half — *re-deriving the same procedure twice ⇒ consolidate into a SKILL.md* — remains open and is now the sharper of the two, since the owner-side mechanism gives it a template to copy.

**Safety envelope (non-negotiable).** Every memory *write* the loop performs is bounded by the **NFR-SEC-1 carve-out**: the loop may read and synthesize freely, but reverting a convention, editing `.owl/loop-config.yml`, the schedule, or the sentinel/guardian/challenger agents stays **human-only**. This is exactly the tiered-approval model of [[anthropic-trustworthy-agents]] — routine (read/synthesize) auto-allowed, consequential (revert/rewire) gated. Memory that can rewrite the rules of its own loop is the one thing autonomy must not have.

## Related

- [[context-engineering]] — the sister pattern: memory is *what* you keep durably, context engineering is *how much* of it you load and when. Just-in-time retrieval and progressive disclosure are the loading mechanics for memory.
- [[role-decomposition]] — who *owns* the memory: curator owns `sources/`/`patterns/`/`ideas/`/`ledger.md`; the write is single-owner.
- [[overview]] · [[ledger]]
