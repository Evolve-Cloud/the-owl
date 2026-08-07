# ADR-027 — Human-directed corrections enter the ledger: repetition becomes a candidate

**Status:** Accepted
**Date:** 2026-08-07
**Author:** @architect (integrate step; from curator idea `encode-the-repeated-correction`, human-directed pass)
**Tags:** [self-improvement, memory, curator, ledger, governance]
**Related:** ADR-001 (loop + NFR-SEC-1 carve-out), ADR-005 (L1.5 grounding), ADR-013 (claim verification), ADR-015 (behavioural discount / measured curator optimism), ADR-017 (the reverse direction — do old conventions still pay?), ADR-022 (retrieve-then-search-delta)

## Contexto

A candidate convention can reach the-owl through exactly **one** intake path: external research. `/owl:evolve` L0 runs the codex brief, L1 runs @scout's web pass, and L2 scores whatever those two produced (`.claude/commands/owl/evolve.md:28-36`). Nothing else can create a candidate.

The owner's own corrections are therefore invisible to the system. A `grep -rniE "correção repetida|owner feedback|repeated correction"` across `docs/`, `.claude/commands/`, and `research-vault/patterns/` returns **zero hits**: no mechanism maps an instruction the owner gives into a scored candidate.

The cost is concrete. Since 2026-07-24 the vault log records ~6 human-directed interventions (rollout completion, backlog score pass, MCP spec ingest ×2, the native-subagents branch, the `claude.com/blog` source-surface widening). Only those that happened to become ADRs left a row in `ledger.md` — and `ledger.md` is the **declared dedup source of truth** (`research-vault/SCHEMA.md`). Everything else entered the system without a trace, which means **the same correction can be given three times and nothing in the loop can notice**.

This ADR's own provenance is the demonstration. On 2026-08-07 the owner corrected the research lane — *"we were only pulling references from anthropic engineering, but the blog has a lot too"* — and that landed as a prompt edit in `.claude/commands/agents/scout.md` with no ADR and no ledger row. The gap documented itself while being documented.

The external evidence is a first-party Claude Code piece whose central claim was verified verbatim under ADR-013 (2026-08-07): the article's process list opens with *"Pick the manual follow-up you did most often this week."* — i.e. the authoring trigger for a durable check is a **repeated manual correction**, not an analysis. The-owl already had the same insight recorded and unfilled: `research-vault/patterns/self-improvement-and-memory.md` named "repetition ⇒ durable artifact" as the vault's one **open front**, on the agent side.

## Decisão

Add one **additive step 0.5** to the curator's per-cycle flow (`.claude/commands/agents/curator.md` → "🔄 Meu fluxo"), before dedup and scoring:

1. Read the **human-directed** entries in `research-vault/log.md` since the previous cycle.
2. Give each one a `ledger.md` row with status **`human-directed`** and **no score** — it is a record, not a decision.
3. When the **same class** of correction has appeared **≥2×** across cycles, raise it as a **normal candidate** for this pass, scored by the standard rubric with the standard safety veto.

**The mechanism only records and counts. It never promotes.** Reaching ≥2× produces a *candidate*, not a convention. An owner instruction must never become a rule by mere repetition — that would be a path around the rigor gate, which is the one thing the gate exists to prevent.

**Bounded scope, deliberately.** The broad framing — "turn every owner correction into a convention" — is explicitly **not** adopted: it is unbounded and would let a one-off preference calcify into a standing rule.

## Alternativas consideradas

- **A (escolhida): record human-directed changes in the ledger; ≥2× raises a normal candidate.** Prós: atomic (one step + one row format); uses machinery that already exists; carve-out-safe (`curator.md` only); makes repetition *detectable at all*, which is the precondition for every richer version. Contras: relies on the curator recognizing that two corrections belong to the same "class" — a judgment call, mitigated by the fact that a misjudgment produces at most a candidate that the rubric then rejects.
- **B: every owner correction is auto-promoted to a convention.** Contras: routes around the rigor gate entirely and lets a one-off preference become permanent. Rejected — this is the failure mode, not the feature.
- **C: a new `docs/conventions/` doc plus a fleet rollout.** Contras: this is a curator-*process* change, not a fleet-wide agent convention; a doc + 7-agent rollout is over-production for a one-step change. Rejected on the ADR-017/ADR-012 precedent (process change = agent edit + ADR, no separate doc).
- **D: do nothing; rely on the owner to raise a repeated correction as a candidate themselves.** Contras: this is the status quo, and the status quo is what let ~6 interventions pass unrecorded — including the one that motivated this ADR. Rejected.

## Consequências

- **Mais fácil:** the ledger becomes a complete record of *why the system is the way it is*, not just of what external research proposed. A correction given twice becomes visible as a pattern instead of dissolving into chat history. This closes the owner-side half of the "repetition ⇒ durable artifact" open front named in `patterns/self-improvement-and-memory.md`.
- **Trade-offs aceitos:** more ledger rows, most of which will never become candidates — accepted, since a row is cheap and the dedup source of truth being *incomplete* is the actual defect. Class-matching is curator judgment (see Alternative A contras).
- **Novos riscos:** the honest one is **laundering** — an owner preference acquiring the authority of a researched convention by being repeated. Mitigated structurally: the step **records and counts only**; promotion runs the full rubric, the safety veto, and the carve-out check like any other candidate.
- **Impacto provisional (ADR-015):** full credit only once the step produces its first genuine ≥2× flag. **Revert condition, load-bearing:** if two cycles pass with no ≥2× signal, this is ceremony ⇒ revert.

> **Conflict of interest, disclosed.** The Impact evidence for this decision (the un-ledgered `scout.md` edit) was produced by the **same session that scored the idea**, an hour before scoring it; the accept landed **exactly** on the threshold (75) and broke a four-cycle 0-accept run. That is the shape of a motivated accept. The score was not lowered — the grounding is a `grep` returning zero, which is objective regardless of who ran it — but the provisional flag carries more weight here than usual, and the revert condition above should be treated as a real test, not a formality. Recorded in `research-vault/ideas/encode-the-repeated-correction.md` and in `ledger.md`.

## Notas de implementação

- **Edit (exactly one, atomic):** `.claude/commands/agents/curator.md` → "🔄 Meu fluxo", new **step 0.5**, inserted after step 0 (L1.5 grounding) and before step 1 (dedup). Additive; no existing step is reworded, no ownership changes, so `.devflow/agents/curator.meta.yaml` stays consistent.
- **Placement rationale:** the step must run *before* scoring, because a ≥2× class becomes a candidate for the current pass and then flows through steps 1→4 like any other. Putting it after scoring would delay every promotion by a full cycle.
- **Ledger row format:** `| <id> | <what the owner corrected> | — | human-directed | | <first_seen> | <date> |`. Score column stays `—` **by design**: an unscored record, not a decision. `human-directed` joins `accepted`/`rejected`/`deferred`/`quarantined` as a status value in `research-vault/SCHEMA.md`.
- **NÃO fazer:** do not auto-promote; do not edit `.owl/loop-config.yml`, the schedule, or the sentinel/guardian/challenger agents (NFR-SEC-1 carve-out); do not backfill the ~6 historical interventions in this change — the step is forward-looking, and a retroactive sweep is separate, owner-decided work.
- **Precisões exigidas pelo gate L4 (aplicadas antes do commit — o gate não foi carimbado):**
  - **@guardian — fronteira de papel.** `scout.md:96` declara `**Possui**: Os candidatos estruturados`. Deixar o curator "levantar um candidato" cria dois donos para uma fronteira, que ADR-009 proíbe. **Resolução:** a fronteira é a **origem**, não o ato. @scout permanece dono único dos candidatos de **pesquisa externa** (schema 8b em `inbox/`); o passo 0.5 não pesquisa e não escreve em `inbox/` — lê `log.md`, artefato **interno que o curator já possui**, e conta repetição. Explicitado no próprio passo. `scout.md` **não** foi editado (nenhuma mudança de ownership é necessária do lado dele).
  - **@challenger — "mesma classe" era indefinido**, portanto infalsificável: sem critério o passo nunca dispara e vira cerimônia. **Resolução:** classe = **mesmo alvo** — duas correções são da mesma classe quando incidiriam sobre o mesmo arquivo de agente ou a mesma convenção. Verificável.
  - **@sentinel — PASS.** 0 contatos com o carve-out; `.owl/loop-config.yml` byte-idêntico (`landing: pr` segue o default para ciclos autônomos); 0 secrets. Observação registrada: o passo cria um caminho de instrução-do-dono → candidato; mitigado estruturalmente porque ele **só registra e conta**, e a promoção roda rubrica + veto + check de carve-out.
- **Consistência de enum (parte da mesma mudança):** `human-directed` foi adicionado à enumeração de status em `research-vault/SCHEMA.md` e no cabeçalho de `research-vault/ledger.md`. Sem isso o `curator.md` gravaria um status que o schema não conhece — drift do tipo que o @guardian existe para pegar.
- **Provenance:** [[claude-code-verification-loops-skills]] (claim verified verbatim, ADR-013) → curator idea `research-vault/ideas/encode-the-repeated-correction.md` (score 75, provisional) → this ADR → the `curator.md` edit. Ledger row updated to `accepted / ADR-027`.
- **Landing:** committed to **`main`** — a deliberate, human-directed deviation from the `landing: pr` shadow default, attended and gate-reviewed, on the ADR-011 precedent (2026-07-24). `.owl/loop-config.yml` is **not** edited; it remains `landing: pr` for autonomous cycles. The deviation is the owner exercising the brake pedal they own, not the loop relaxing it.
