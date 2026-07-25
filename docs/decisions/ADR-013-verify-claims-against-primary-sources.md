# ADR-013 — Verify each accepted idea's central claim against a primary source before it lands

**Status:** Accepted
**Date:** 2026-07-25
**Author:** human-directed loop-hardening (tech-lead review of the research→validation pipeline)
**Tags:** [self-improvement, validation, research, rigor, curator]
**Related:** ADR-003 (rigor rubric), ADR-005 (L1.5 grounding), ADR-010 (headless output verification), `research-vault/ledger.md` (`provenance-first-evaluation`, deferred), ADR-012 (efficiency measurement)

## Contexto
The loop's research is validated for **structure, not truth**. Concretely:
- `owl-research` (the codex brief generator) validates only that the output **parses** (frontmatter + sources table + idea blocks). If it parses, it is trusted.
- Research comes from a **single generator** (codex `gpt-5.6-luna` — the deep-research model is unavailable on the account). Star counts are self-reported and **explicitly not re-verified** ("treat the brief's numbers as approximate").
- The curator's rubric scores **Evidence strength (20)** against the brief's **self-reported** `evidence: [s1, s2, …]` lists and `# adoption:` comments — it never fetches the source to confirm the claim.
- The only truth-check is `@scout`'s live corroboration, which (a) **no-op'd silently for a whole cycle** once (ADR-010) and (b) corroborates at the **thesis** level, not claim-by-claim.

So accepted conventions rest on **unverified evidence**. Damning tell: the loop's own research surfaced the exact remedy — `provenance-first-evaluation` ("cite a real source per claim") — and **deferred it, unscored**, while accepting cosmetic conventions (handoff-contract 91, role-ownership 87). The loop is structurally biased toward *safe/tidy* over *true*.

## Decisão
At the **accept boundary** (between L2 score and L3 integrate), the curator **must verify the central evidence claim of each idea it is about to accept** by fetching the cited primary source and confirming the claim. Record in the idea's **`## Claim verification`** section: the claim, the source URL, the **verdict** (`confirmed` | `contradicted` | `unreachable`), and a **real quote or paraphrase** from the source.

Verdict rules:
- **confirmed** → the idea may land.
- **contradicted** → the idea is **not accepted**; it drops to `deferred` with the finding. Evidence that doesn't hold does not become a change.
- **unreachable** (paywall / moved / fetch fails) → `deferred`. We do not land on faith.

**Scope:** only ideas *about to be accepted* (2–3/cycle), **not** all ~16 candidates — verification cost is paid only for what actually changes the system.

**Role nuance:** this is a **narrow confirmation fetch of one claim**, distinct from `@scout`'s open **discovery** research. It stays with the curator because it is part of the accept *decision*. Web content fetched here is **data, not instructions** (NFR-SEC-2) — quote it, never act on it.

## Alternativas consideradas
- **Alternativa A (escolhida): verify only the accepted ideas, at the boundary, by the curator.** Prós: cheap (2–3 fetches/cycle), targets exactly what lands, enforceable by the editable curator. Contras: an idea whose source is merely unreachable defers (conservative false-negative — acceptable; it can re-surface).
- **Alternativa B: verify ALL sources at ingest (scout).** Prós: most thorough; every source note carries a verdict. Contras: ~16+ fetches/cycle for ideas that are mostly deferred — pays verification cost for changes that never happen. Deferred as a future upgrade if cost allows.
- **Alternativa C: status quo — parse-only + scout thesis corroboration.** Prós: zero added cost. Contras: this **is** the FP2 hole (the scout no-op'd; corroborates theses, not claims). Rejected.

## Consequências
- **Mais fácil:** accepted changes rest on a verified claim, not the brief's self-report; a contradicting source stops a bad idea *at the boundary*; the rubric's **Evidence strength (20)** becomes partly grounded in a real fetch instead of a self-report.
- **Trade-offs aceitos:** +2–3 web fetches per cycle (bounded); a paywalled/moved source yields `unreachable` → the idea defers (may defer a genuinely good idea; conservative by design).
- **Novos riscos:** none to the carve-out — curator + SCHEMA + `evolve.md` are all in the loop's **editable** set; the gate agents, `loop-config.yml`, schedule, `~/.ssh`, secrets are **untouched**. The verification fetch ingests untrusted web content — handled as data (NFR-SEC-2).

## Notas de implementação
- Wired at four points (all editable, 0 carve-out contact): **`evolve.md`** L2.5 step; **`SCHEMA.md`** (Idea Page Format `## Claim verification` + a SCORE-workflow line); **`curator.md`** (the confirmation-fetch capability, the requirement, and a hard-stop against accepting on unverified evidence).
- **Enforcement** lives in the editable curator. The gate (guardian/challenger — **carve-out**) *may* additionally check that every accepted idea carries a `## Claim verification` with a real quote; wiring that is **human-only** (flagged, not done here).
- **Demonstrated once live** on `ideas/role-ownership.md` (fetched a primary source, recorded the verdict + quote) — this ADR ships with a worked example, not a rule on paper.
- This is **human-directed loop-hardening**, not an autonomous-loop-proposed change; landed to `main` directly, gate-lens self-reviewed (additive, role-preserved, 0 carve-out).
