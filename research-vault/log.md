---
title: Cycle Log
type: log
tags: []
updated: 2026-07-23
---

# Cycle Log (append-only)

One block per cycle event: `ingest` (scout), `score` (curator), `integrate` (handshake), `lint`.

## [2026-07-23] scaffold | Vault created
- Created: SCHEMA.md, index.md, overview.md, ledger.md, log.md, inbox/, sources/, patterns/, ideas/

## [2026-07-23] ingest | Cycle 1 — dual research (codex + scout)
- L0 codex brief: `inbox/research-brief-2026-07-23.md` (8 sources, 9 ideas; generator gpt-5-deep-research).
- L1 scout live research: `inbox/scout-notes-2026-07-23.md` (w1–w4). Corroborated 5 codex ideas; added frontmatter-fields + AutoGen-maintenance-mode fact; flagged star-count contradiction.

## [2026-07-23] score | Cycle 1 — curator
- Deduped vs ledger (empty). Scored merged candidate set.
- Accepted: **handoff-contract** (91). Deferred: 9 others (circuit-breaker cap = 3; cycle 1 conservative → 1 accepted).
- Safety veto applied; none touched the carve-out.

## [2026-07-23] integrate | Cycle 1 — ADR-004 + convention
- @architect wrote ADR-004; created `docs/conventions/handoff-contract.md`.
- Gate (guardian/sentinel/challenger): PASS (no role break, no injection/carve-out/secret, real improvement; challenger deferred-impact caveat noted).
- Landing: **shadow (pr)** → branch `owl/evolve-2026-07-23-handoff-contract`; main untouched.

## [2026-07-23] score | Cycle 2 (continuation) — curator
- **No new codex spend** (same-day guard): brief from cycle 1 still fresh; processed the queued backlog instead of re-running L0.
- L1.5 self-audit (ADR-005, first cycle to have it) on the real agent files: architect/builder/chronicler have **no** handoff-contract section (only informal prose); scout/curator partial.
- Accepted: **handoff-contract-rollout** (94) — the ADR-004 follow-up, 3 edits (architect/builder/chronicler) at the circuit-breaker cap. Deferred backlog not re-litigated.

## [2026-07-23] integrate | Cycle 2 — ADR-006/007/008 + agent edits
- @architect wrote ADR-006 (architect), ADR-007 (builder), ADR-008 (chronicler).
- @builder added a "🤝 Contrato de Handoff" section (the 6 convention fields, agent-specific) to each of the 3 agent files. Additive; existing prose + Skill-tool chaining preserved.
- Gate (guardian/sentinel/challenger): **PASS** — additive-only/role-preserved (guardian), 0 carve-out contact + no injection/secrets (sentinel), real improvement not cargo-cult (challenger). 0 consecutive failures.
- Landing: **shadow (pr)** → branch `owl/evolve-2026-07-23-handoff-rollout`; merged via PR #2.

## [2026-07-24] ingest | Cycle 3 — dual research (codex + scout)
- L0 codex brief: `inbox/research-brief-2026-07-24.md` (22 sources, 16 ideas; default model gpt-5.6-luna via ~/.codex — deep-research model unavailable on the ChatGPT account, fell back per skill).
- L1 scout live research: `inbox/scout-notes-2026-07-24.md` (x1–x5). Strengthened narrow-single-owner-roles / manager-retains-control / sop / typed-handoffs; weakened isolated-workspaces (no parallel writers); flagged already-implemented dedup signals.

## [2026-07-24] score | Cycle 3 — curator (L1.5 grounded)
- L1.5 self-audit vs real code: ownership already in `.meta.yaml` for 8/11 agents; **scout/curator/sentinel lack it** (sentinel = carve-out, human-only).
- Deduped vs ledger (6 brief-ids aliased to existing decided ids, not re-litigated).
- Accepted: **role-ownership (87)** → `docs/conventions/role-ownership.md` (promotes previously-deferred `explicit-role-boundaries`). Rejected: **isolated-workspaces (41)** (runtime-shaped, fit 2/5). Deferred: rest (evidence captured; several already implemented).
- Safety veto applied; the accepted change does NOT touch the NFR-SEC-1 carve-out. Circuit breaker: 1 accepted ≤ cap 3.

## [2026-07-24] integrate | Cycle 3b (human-directed) — complete the convention rollout + efficiency tooling
- **Trigger:** the new efficiency scorecard (`scripts/owl-metrics.py`, ADR-012) quantified the standing "convention debt": handoff-contract on 3/7 target agents, role-ownership on 0/7. Bottleneck = integration, not research.
- **L1.5 grounding (ADR-005):** corrected ADR-009's stale claim — `scout`/`curator` DO have `.meta.yaml` in the canonical `.devflow/agents/`; only `team` lacks one (N/A, orchestrator hub). Found the `.claude/commands/agents/*.meta.yaml` mirrors drifted (follow-up).
- **Change (ADR-011):** "🤝 Contrato de Handoff" added to curator/scout/strategist/system-designer; "🧭 Papel & Não-Papel" added to all 7 pipeline specialists; `system-designer.meta.yaml` gained `constraints`. **176 insertions, 0 deletions.** `team` excluded as N/A by design. Both conventions now **7/7 (100%)**.
- **Also (ADR-012):** shipped `scripts/owl-metrics.py` (read-only scorecard) + moved the schedule daily → **weekly (Mondays 07:13)**.
- **Gate (guardian/sentinel/challenger): PASS × 3** — additive-only/agent-specific (guardian), 0 carve-out contact + no injection/secrets (sentinel), real improvement + `team` exclusion honest, not goalpost-moving (challenger). 0 consecutive failures.
- **Landing: committed to `main`** — deliberate deviation from shadow-PR: human-directed, attended, gate-reviewed (see ADR-011 → Notas).

## [2026-07-24] lint | Sources layer materialized + first vault health pass
- **Materialized `sources/`** (was empty — the SCHEMA INGEST step never ran; the scout no-op'd): **25 source notes**, one per ingested codex-brief source across both cycles (deduped). name/URL/stars copied **verbatim** from `research-brief-2026-07-{23,24}.md` — no fabrication (`n/a` stays `n/a`; dual-cycle star counts noted). Scout sources (w1–w4, x1–x5) were already captured in the `type: source` scout-notes.
- **Wired provenance:** idea/pattern `## Related` now link the `sources/` notes (opaque `s#`/`x#`/`w#` IDs replaced by real wikilinks); the two briefs are **de-orphaned** (every source note links its origin `research-brief-*`); `overview.md` gains a `## Sources` hub linking all 25.
- **Health:** wikilinks **47 → 177**. **0 real broken links** (the 5 flagged are SCHEMA.md's own doc placeholders). **0 orphan notes** (was 2 briefs + 7 deferred-only sources — all now anchored).
- **Findings / next-cycle:** (1) 7 sources are cited only by *deferred* ideas → they gain idea-side inbound links when those ideas materialize; (2) `.meta.yaml` still carry stale paths (`docs/CHANGELOG.md`, `knowledge-graph.json`) → separate meta-accuracy pass; (3) no dedicated `patterns/` page for communication/handoff yet (only `role-decomposition`).

## [2026-07-26] score | Human-directed backlog pass (parallel to scheduled cycle 4) — read-in-full library
- **Scope:** the 24 **read-in-full** sources imported 2026-07-26 (the Jul-26 library + the carinhAI `Engineering/AI/` docs) were **ingested but never scored** (INGEST ≠ SCORE). This cycle mines + decides them. Deduped vs `ledger.md` + **L1.5 grounded** against the real agents/conventions.
- **Accepted: 0. Deferred (net-new): 3** (`just-in-time-context-loading`, `convention-staleness-review`, `eval-saturation-graduation`). Rest **deduped/corroborated** decided/deferred ids. Accept-0 is the expected outcome under the **ADR-015 self-discount** (~+15 curator optimism) on an all-behavioral-claim candidate set (Impact = hypothesis-level, not ceiling); the cap of 3 is a ceiling, not a target.
- **Why the strongest candidate didn't clear:** `just-in-time-context-loading`'s core (pass pointers, load on demand) is **already** the-owl's practice via `handoff-contract` (ADR-004, context-minimal) → dedup, not a new accept. `convention-staleness-review` is genuinely novel but hypothesis-level + **loop-adjacent** → deferred for a carve-out-safe cycle (edit curator flow, never `.owl/loop-config.yml`).
- **Safety veto:** n/a (nothing accepted); the 3 deferrals are flagged for carve-out care at any future integrate. **Curator boundary held:** scored + persisted to the vault only — no agent/ADR edited, nothing committed.
- **Synthesis:** [[overview]] refreshed (primary-source corroboration of context-minimal/hub-spoke/evaluator-gate + a multi-agent-economics caution + new deferred fronts); new `patterns/context-engineering.md` (partially closes the cycle-3 lint finding on missing pattern pages); [[index]] `[!todo]` (unscored library) resolved. Full dedup/corroboration map in `ledger.md`.

## [2026-07-26] integrate | Human-directed (parallel to scheduled cycle 4) — ADR-017 (convention staleness review)
- **Trigger:** owner directed integrating the strongest deferred candidate from the same-day score pass. Promoted `convention-staleness-review` **deferred → accepted (82)** — rubric-justified (not by the direction): concretized to an actionable, carve-out-safe, data-independent atomic edit; claim verified live (ADR-013: "harnesses encode assumptions... that go stale as models improve", Anthropic Managed Agents, fetched 2026-07-26); structural/process convention (ADR-012 shape), so the ADR-015 behavioral discount barely applies.
- **Change (ADR-017):** additive **step 4.5** in `.claude/commands/agents/curator.md` "🔄 Meu fluxo" — each cycle the curator re-reads the 1–2 oldest accepted conventions and flags any the current model made redundant for **owner-reviewed re-fitness** (triggers `scripts/owl-fitness.py`); **never auto-reverts**. The inverse of ADR-012's rollout-coverage view. **Actionable framing** chosen; the aspirational "read a decayed re-fitness Δ" form rejected (that data isn't instrumented).
- **Carve-out:** edit is to `curator.md` (outside NFR-SEC-1), **not** `.owl/loop-config.yml`. Impact **provisional-pending-first-flag** (ADR-015).
- **Gate: PASS (with 2 fixes applied in-gate).** Sentinel PASS (0 carve-out contact, grep-verified). Guardian PASS (additive, ownership unchanged, no prose↔meta drift). **Challenger (independent, `docs/security/challenger-2026-07-26.md`): Partially Agree / 84** — flagged the accept as **marginal** (discounted for ADR-015's ~+15 curator optimism it would defer; survives only via the ADR-012 structural-convention exemption — kept labeled provisional) and found **2 real gaps, both fixed here:** (a) step 4.5 risked being ceremonial → now **requires a per-cycle `log.md` audit trail** (which convention examined + verdict); (b) "trigger `owl-fitness.py`" leaned on a capability the script lacks (it only *compares* run-records, doesn't run the eval) → reworded to **recommend an owner re-fitness** (re-run eval with/without → then compare). No blocking gaps.
- **Landing:** **working-tree only** — not committed to `main` by the loop (shadow default). Owner picks shadow-branch/PR after reviewing the diff.
- **Watch:** if step 4.5 never produces a flag within a few cycles, it is itself the first stale convention (self-application).

## [2026-07-26] ingest | Cycle 4 — dual research (codex + scout)
- L0 codex brief: `inbox/research-brief-2026-07-26.md` (15 sources, 12 ideas; model gpt-5.6-luna via ~/.codex — deep-research still unavailable on this account, same documented fallback. Note: the brief's own `generator:` frontmatter inaccurately self-reports `gpt-5-o3-deep-research`; the real model is recorded here).
- L1 scout live research: `inbox/scout-notes-2026-07-26.md` (x1–x3, all verified real — none fabricated, incl. the arXiv id). Strengthened `least-privilege-tools` (= the deferred `least-privilege-tool-scopes`, score 78) and `human-approval-gates` with a primary Anthropic source each. Nuanced `trajectory-evals`: its own best source actually recommends outcome-primary grading (the-owl's ADR-014 harness already does this). Flagged 2 **aliases of already-decided ideas** (`narrow-role-boundaries`→`role-ownership` ADR-009, `structured-handoff-contracts`→`handoff-contract` ADR-004 — do not re-litigate) and 1 **resurfacing** (`evaluator-optimizer-loop`, deferred 2026-07-23 — the-owl's state changed materially since: ADR-014/015 now largely implement it). Surfaced one narrow open gap: `.owl/state/last-run.json` has no mid-cycle resumable checkpoint.

## [2026-07-26] score | Cycle 4 — curator (L1.5 grounded + ADR-015 self-haircut)
- L1.5 self-audit vs real code: confirmed `.owl/state/` has no mid-cycle checkpoint (real gap); confirmed 7/7 pipeline agents already state "contexto-mínimo"; confirmed "orchestrator is sole delegator" already stated verbatim in scout.md/curator.md coordination sections; confirmed ADR-010 documents the loop as sequential/one-agent-per-phase (no fan-out) — grounds several defers/rejects directly, not by assumption.
- Deduped vs ledger: 2 brief-ids aliased to already-decided ids, not re-litigated (`narrow-role-boundaries`→`role-ownership`, `structured-handoff-contracts`→`handoff-contract`). 2 re-scored with materially-changed basis: `evaluator-optimizer-loop` (now substantially covered by ADR-014/015 → 68, no fresh gap) and `least-privilege-tool-scopes` (78→**66, revised DOWN** despite stronger evidence — grounding found no tool-gating enforcement path exists in the-owl's inline execution model, ADR-010; same "presupposes a runtime we don't have" shape as a prior reject).
- Accepted: **externalized-checkpoint-memory (83 raw → 75 after ADR-015 self-haircut, provisional)** — the only candidate whose value is a structural/testable fact (does a checkpoint get written) rather than a behavioral claim, so not capped at hypothesis-level the way the others were. Rejected: **trajectory-evals (58)** — its own cited primary source argues the opposite framing once read in full; **parallel-independent-work (52)** — no-runtime-for-this, same shape as a prior reject. Deferred: `context-budgeting` (74), `single-agent-first` (69), `supervisor-specialists` (67), `sequential-artifact-pipeline` (68), `human-approval-gates` (67) — each grounded as substantially already-embodied or landing just under the self-haircut-adjusted bar; none forced to fill the circuit-breaker cap.
- Safety veto: N/A this cycle (no candidate scored below the floor while otherwise clearing threshold). Carve-out check: 0 candidates touch sentinel/guardian/challenger/`.owl/loop-config.yml`. Circuit breaker: 1 accepted ≤ cap 3 — no defer-for-cap needed since only 1 candidate cleared the (haircut-adjusted) bar.

## [2026-07-26] integrate+gate | Cycle 4 — ADR-016 (mid-cycle checkpoint)
- **@architect:** `ADR-016-mid-cycle-checkpoint.md` — a JSON checkpoint (`.owl/state/cycle-in-progress.json`) written after each phase's existing verification passes; read at Setup with an explicit resume-or-fresh choice; deleted on normal L5 completion; left in place on an aborted cycle (by design, for human inspection).
- **@builder:** exactly one file touched, `.claude/commands/owl/evolve.md` (4 insertions across Setup / the shared per-phase verification note / L5 / circuit breaker — additive only, nothing removed). Diff confirmed via `git diff --stat`: 1 file, 4 insertions, 1 deletion (a line extended, not removed).
- **Gate (guardian/sentinel/challenger): PASS × 3.** Guardian: no agent `.md` touched, no downstream consumer of `evolve.md` to regress, additions don't contradict the existing verification model. Sentinel: 0 carve-out contact (confirmed, 1 file outside the carve-out list), no external-brief content copied verbatim, no secrets in the new JSON schema (only phase names + kebab-slug idea ids). Challenger: pressed on "the failure mode this prevents hasn't been directly observed yet" — agreed with the ADR's own self-haircut/provisional framing rather than treating it as new; added a concrete, falsifiable revisit trigger (non-blocking): if `cycle-in-progress.json` is never found non-stale at Setup across ~5 cycles, that's a legitimate signal to remove the mechanism, sharper than an open-ended "revisit if unused."
- 0 consecutive gate failures. Circuit breaker: 1 accepted ≤ cap 3.

## [2026-07-29] ingest | Cycle 5 — dual research (codex + scout)
- L0 codex brief: `inbox/research-brief-2026-07-29.md` (13 sources, 12 idea blocks; model **gpt-5** via ~/.codex — deep-research still unavailable on the account, documented fallback). Note: frontmatter self-reports `idea_count: 11` — an off-by-one miscount; there are 12 `### ` blocks (recorded here, corrected).
- L1 scout live corroboration: `inbox/scout-notes-2026-07-29.md` — x1 (AutoGen termination conditions first-class), x2 (Anthropic multi-agent explicit stop conditions + retry-limit escalation; incl. the study caveat that escalation is "not a mechanism of productive recovery"), x3 (handoff artifacts should carry assumptions/unresolved-questions/evidence). All real, none fabricated. No new source pages needed — every cited primary already exists under `sources/`.

## [2026-07-29] score | Cycle 5 — curator (L1.5 grounded + ADR-015 self-haircut)
- L1.5 self-audit vs real code: `docs/conventions/handoff-contract.md` has 6 contract fields, **none** for uncertainty (assumptions/open-questions/evidence) — confirmed atomic gap; only `sentinel.md` matched grep for an explicit escalate/stop contract; only `scout.md` carries the NFR-SEC-2 banner verbatim; ADR-as-promotion + ledger `status` already deliver durable-vs-working memory separation.
- **Accepted (1, provisional): `handoff-contract-uncertainty-fields` (78)** — the atomic, non-carve-out gap in an existing accepted convention; claim verified live (ADR-013: OpenAI handoffs `input_type`/`reason`, `confirmed`). New suffixed id (extends ADR-004, not a re-litigation). **Rejected (1): `adversarial-review-gate`** — materiality thresholds on the closure gate = governance-of-the-gate (NFR-SEC-1 carve-out) + already implemented (L4). **Deferred (3, net-new): `explicit-termination-and-escalation` (68), `untrusted-content-boundary` (65), `durable-decisions-separate-from-working-memory` (64)** — below the haircut-adjusted bar, substantially embodied already. **Aliased to already-decided (7), not re-litigated** (see ledger).
- Safety veto: N/A (no candidate below floor while clearing threshold). Carve-out: 1 candidate (`adversarial-review-gate`) touched it → auto-rejected + noted for human. The accepted change does NOT touch the carve-out. Circuit breaker: 1 accepted ≤ cap 3.
- **Staleness review (ADR-017 step 4.5):** examined `handoff-contract` (ADR-004) — actively extended this cycle, not stale; `role-ownership` (ADR-009) — **still pays** (this cycle's #1 high-confidence idea `explicit-role-charters` re-confirms role charters remain SOTA; model has not made it native). No re-fitness flagged.

## [2026-07-30] ingest | Cycle 6 — dual research (codex + scout)
- L0 codex brief: inbox/research-brief-2026-07-30.md (gpt-5, 14 sources, 11 idea blocks; frontmatter idea_count:10 miscount, non-blocking).
- L1 scout live: inbox/scout-notes-2026-07-30.md — 0 net-new sources; 2 live corroborations (OpenAI handoff input_filter/HandoffInputData; Anthropic proportional effort-scaling tiers). All 11 brief ideas are aliases of already-decided ledger ids — 0 net-new candidate this cycle.

## [2026-07-30] score | Cycle 6 — 0 accepted, 1 rejected (carve-out), 10 deferred/deduped
- **All 11 brief ideas are aliases of already-decided ledger ids** (see scout-notes-2026-07-30 table). Per SCHEMA dedup rule, a decided id is skipped — no new ledger rows, no re-litigation. **0 net-new candidate.**
- **0 accepted.** Precedented + expected (cf. 2026-07-26 cycle, also 0-accepted): every candidate is a behavioral-claim re-run of a pattern the-owl already embodies. The cap (3) is a ceiling, not a target; the weekly-cadence rationale (absorption, not research supply, is the binding constraint) points the same way — yesterday's ADR-020 has not yet had its week of use. No accept was manufactured to justify the run.
- **L1.5 grounding per candidate (já_implementado / verdict):**
  - `role-boundaries-and-artifact-contracts` → role-ownership (ADR-009) + handoff-contract (ADR-004). Implemented. **dedup/decided.**
  - `coordinator-owned-hub-spoke` → hub-spoke enforced everywhere (ADR-010). Implemented. **dedup/decided.**
  - `yaml-frontmatter-and-prompt-body` → `.devflow/agents/*.meta.yaml` + md body already this shape. **deferred** (agent-frontmatter-fields; no atomic gap).
  - `least-privilege-tool-scoping` → **deferred (66, unchanged):** inline execution model (ADR-010) still has no mechanism to enforce per-agent tool scope; a "Tool Scope" section would be unenforceable prose with false-confidence risk (same class as rejected `isolated-workspaces`). Fit unchanged by today's evidence.
  - `structured-handoff-contracts` → handoff-contract (ADR-004 + ADR-020). Implemented. **dedup/decided.**
  - `n-minus-one-context-transfer` → handoff-contract "contexto-mínimo (N-1)" rule. Implemented. **deferred** (context-budgeting 74; no new atomic gap). Corroborated by live fetch of OpenAI `input_filter`/`HandoffInputData` — but that is a **runtime mechanism**, no markdown gap.
  - `adr-as-durable-decision-memory` → ADR-per-change + ledger status/supersession. Implemented. **deferred** (durable-decisions-separate-from-working-memory 64).
  - `evidence-gated-evaluation-loop` → ADR-014/015 fitness harness (outcome-graded, evidence-gated). Implemented. **dedup;** its trajectory-eval slice remains **rejected (58)** — its own best-cited source argues outcome-primary grading, the opposite of mandatory trajectory-checks.
  - `independent-adversarial-review` → **REJECTED (confirmed):** = `adversarial-review-gate`, rejected 2026-07-29 as governance-of-the-gate on guardian/sentinel/challenger = **NFR-SEC-1 carve-out**; also already implemented as `/owl:evolve` L4. Not re-opened.
  - `effort-budgets-and-hard-stops` → **deferred (68, stays):** = `explicit-termination-and-escalation`. Live-verified Anthropic evidence (real quotes: "1 agent with 3-10 tool calls" / "2-4 subagents" / ">10 subagents", 15× token cost) is about **scaling subagent COUNT** — a runtime spawner the-owl structurally lacks (hub-spoke, one-agent-per-phase). Same runtime-shaped/low-fit class as rejected `isolated-workspaces`/`parallel-independent-work`. Evidence does NOT match the recorded revisit condition ("a single 'Stop When' line distilled into the handoff convention"); re-scoring one day after deferral would be re-litigation. HARD STOP + circuit breaker already cover the markdown-expressible part.
  - `human-approval-at-boundary-crossings` → **deferred (67):** = `human-approval-gates`. Already embodied: per-agent HARD STOP blocks, HITL, the carve-out human gate, and `landing: pr` (shadow) default. No atomic gap.
- **Staleness review (ADR-017 step 4.5):** examined the 2 oldest conventions. `handoff-contract` (ADR-004) — extended just yesterday (ADR-020), not stale; its incremental per-agent rollout of the uncertainty field is the live follow-up. `role-ownership` (ADR-009) — **still pays:** today's #1 high-confidence brief idea (`role-boundaries-and-artifact-contracts`) independently re-confirms non-overlapping artifact-owning role charters remain SOTA (Anthropic multi-agent + LangChain + Claude Code subagents all converge). Current model has NOT made it native. No re-fitness flagged.
- **Circuit breaker:** 0 accepted ≤ cap 3; 0 gate failures. Carve-out contacts: 1 candidate (`independent-adversarial-review`) targeted it, auto-rejected by curator. 0 violations.
- **Cycle product:** research + live corroboration folded into the vault; ledger unchanged (no re-litigation). No ADR, no edit, nothing landed. L2.5/L3/L4/L5 not reached (nothing accepted).

## [2026-07-30] ingest | Human-directed — full MCP spec-site v2026-07-28 absorption
- **+54 source notes** (`sources/mcp-*.md`) covering the ENTIRE modelcontextprotocol.io v2026-07-28 site: 15 docs (getting-started/learn/develop/tools/tutorials-security), 31 specification pages (basic/patterns/transports/authorization/server/client/utilities/schema/changelog/deprecated), 8 extensions (apps/tasks/auth). Complements the pre-existing `mcp-architecture-spec-2026-07-28.md` → 55 `mcp-*` notes total. Vault sources 51 → 105.
- **Security-first coverage (was the gap):** full threat model in `mcp-docs-security-best-practices` (Confused Deputy, Token Passthrough, SSRF, State-Handle Hijacking, local-server compromise, OAuth-URL XSS/RCE, Mix-Up, CIMD) with every MUST/SHOULD/MUST NOT verbatim; complete OAuth 2.1 authorization spec (`mcp-spec-authorization-*`, `mcp-docs-authorization`); enterprise-managed auth + OAuth client-credentials extensions.
- **Key v2026-07-28 deltas surfaced (candidates for a mcp-builder refresh):** Roots + Sampling + Logging all DEPRECATED (SEP-2577); stateless protocol — no `initialize` handshake, per-request `_meta` version negotiation + mandatory `server/discover`; MRTR (Multi Round-Trip Requests, `InputRequiredResult`) replaces all server-initiated requests; Streamable HTTP drops the GET stream + protocol sessions; new error codes -32020/-32021/-32022; `resources/subscribe` → `subscriptions/listen`.
- **NFR-SEC-2:** every page carried a benign "fetch llms.txt to discover all pages" banner — treated as DATA, quoted in a `> [!question]` callout in each note, NOT obeyed. 0 injected directives acted on.
- **Partial fetches flagged (in their own Gaps sections):** `mcp-docs-sdk` (trailing SDK rows dropped) and `mcp-ext-client-matrix` (support matrix partial) — re-fetch if a complete table is needed.
- Curator has NOT scored these — this is an ingest (scout lane). No agent/ADR/convention edited by this ingest; `mcp-builder` refresh from the deltas above is a separate follow-up decision.

## [2026-08-03] ingest | Cycle 7 — dual research (codex + scout)
- L0 codex brief: `inbox/research-brief-2026-08-03.md` (gpt-5, 13 sources, 10 idea blocks: bounded-role-charters, repository-agent-manifest, structured-handoff-contracts, hub-spoke-return-control, stage-gated-sop-pipeline, scoped-context-artifacts, append-only-decision-memory, eval-backed-library-evolution, layered-guardrails-and-approval, deterministic-termination-budgets).
- L1 scout live: `inbox/scout-notes-2026-08-03.md`. **+1 source** ([[swe-bench-paper]], arXiv 2310.06770, ICLR 2024 — the benchmark *paper*, distinct from the existing `swe-bench-sonnet` *blog*; live-verified real). 12/13 brief sources already had vault pages.
- **Live corroboration (3 flagged ideas, all URLs REAL, no fabrication):** AutoGen termination doc (11 real stop conditions; about halting a conversation LOOP, NOT scaling agent count — differs from cycle-6 `effort-budgets-and-hard-stops` which was subagent-COUNT); Claude Code subagents doc (`disallowedTools`/`permissionMode`/`maxTurns` confirmed as REAL, harness-ENFORCED frontmatter — bears on the "unenforceable prose" deferral of `least-privilege-tool-scopes` 66 on the `owl/agents-native-subagents` branch); SWE-bench paper. **Surfaced for @curator, NOT scored.**
- **Star checks (2 confirmed, 3 unconfirmed; all repos real):** LangGraph ~39k ✓, CrewAI ~55k ✓; AutoGen / MetaGPT / openai-agents-python exact counts UNCONFIRMED (only stale curated-list figures found — not "high", just unresolved).
- **NFR-SEC-2:** only the routine `code.claude.com` "fetch llms.txt" banner seen — quoted as DATA in a `> [!question]` callout, NOT obeyed. 0 injected directives acted on.
- Scout lane: `inbox/` + one `sources/` page only. Nothing scored/deduped-authoritatively/edited in `ideas/`, `ledger.md`, `patterns/` — that is @curator.
- **Cycle 7 (2026-08-03) score:** 10 candidates → 0 accepted · 4 aliases-of-decided (skipped) · 5 deferred (embodied/below-bar) · 1 state-change recorded (`least-privilege-tool-scopes` deferred→in-progress via human-directed native-subagents branch, partly carve-out). Staleness (ADR-017): handoff-contract (ADR-004) not stale (ADR-020 rollout live); role-ownership (ADR-009) still pays. No re-fitness flagged.
- **Cycle 7 landing (2026-08-03):** shadow branch `owl/evolve-2026-08-03-cycle7` committed locally (4747d77) with the vault research memory. `git push` failed (no SSH key in this env) — branch is local, needs a manual push + PR from a machine with remote access. main untouched. Not a cycle failure (documented L5 fallback).

## [2026-08-07] ingest | Human-directed — claude.com/blog (loops & verification) + fonte-de-pesquisa alargada
- **Não é um ciclo.** Sem brief do codex (`/owl:research` não rodou, `{{QUERY_AXIS}}` não rodou round-robin, `.owl/state` intocado). Duas URLs entregues pelo dono; mesma forma do ingest human-directed de 2026-07-30 (MCP spec-site).
- **+2 source notes** (primárias, first-party, Claude Code team): [[claude-code-verification-loops-skills]] (Delba de Oliveira, 2026-07-22) e [[claude-code-loops-getting-started]] (Delba de Oliveira + Michael Segner, 2026-06-30). Vault sources **106 → 108** (contagem real por `ls sources/*.md`; o `index.md` vinha registrando 105 — drift anterior a este ingest, sinalizado, não corrigido em silêncio).
- **Substância:** s1 = os quatro padrões de invocação de uma skill de verificação (standalone → embedded → chained → on-every-PR), com o gatilho de autoria "a correção que você repete depois de toda feature É o check"; s2 = a taxonomia de loops (turn-based / goal-based `/goal` / time-based `/loop`+`/schedule` / proactive) e o que se delega em cada nível (o check → a condição de parada → o gatilho → o prompt).
- **4 candidatos normalizados** em `inbox/scout-notes-2026-08-07.md`, todos `status: (pending)`: `evaluator-gated-termination`, `encode-the-repeated-correction`, `chained-verification-skills`, `least-privilege-on-the-checker`.
- **⚑ Flag para @curator (evidência, não veredito):** s2 documenta `/goal` como **primitiva de harness invocável por uma linha de prompt** — um modelo avaliador re-checa a condição de parada a cada tentativa de parar. Isso toca a premissa que fixou **`evaluator-optimizer-loop` em 68 (deferred)**: "grader/return-gate precisa de runtime que a-owl não tem". Scout **não** re-pontuou, **não** declarou contradição e **não** preencheu `challenges_id`. Mesma classe do flag de 2026-08-03 sobre `least-privilege-tool-scopes`. Contraponto que o curator vai precisar: política de terminação em `.owl/loop-config.yml` é **carve-out NFR-SEC-1** — auto-rejeita.
- **Janela de recência explicitada:** cutoff 2026-08-07 − 30d = **2026-07-08**. s1 (07-22) está dentro → `recency`; **s2 (06-30) está 8 dias fora** → só pode ser `net-new`. s2 não herda o frescor de s1.
- **Higiene de citação:** ambas as páginas vieram do sumarizador de fetch, **não de leitura integral** → nenhum `## Notable quotes` gravado nas duas notas (SCHEMA.md). Qualquer ideia daqui que chegue a `accepted` exige antes o fetch de confirmação do ADR-013 (leitura direta).
- **NFR-SEC-2:** nenhuma instrução injetada nas duas páginas; 0 obedecidas.
- **Não proposto de propósito** (registrado como contexto, sem candidato): rotinas `/schedule` (cadência = carve-out), dynamic workflows / fan-out de centenas de agentes (classe runtime-shaped já rejeitada em `isolated-workspaces`/`parallel-independent-work`), auto mode (contraria HITL + `landing: pr`).
- Pista scout: só `inbox/` + `sources/`. **`ledger.md`, `ideas/`, `patterns/`, `index.md`, `overview.md` intocados** — isso é @curator.

## [2026-08-07] change | Human-directed — @scout passa a cobrir todas as superfícies first-party Anthropic/Claude
- **Motivo (dono):** o lane de pesquisa vinha puxando material first-party quase só de `anthropic.com/engineering`; `claude.com/blog` carrega um corpus grande de posts do time do Claude Code (loops, skills, verificação, workflows) que o pipeline nunca apontou. As duas fontes ingeridas hoje vieram justamente desse domínio não-indexado — a evidência da lacuna é o próprio ingest acima.
- **Edit:** `.claude/commands/agents/scout.md` passo 2 ("Pesquisar") — a lista de fontes vira duas linhas: **first-party = `anthropic.com/engineering` + `claude.com/blog` + docs (`code.claude.com/docs`, Agent SDK)**, e **terceiros = LangGraph/CrewAI/AutoGen/OpenAI/papers/top-starred**. Redação deliberadamente ampla ("todas as superfícies"), não uma URL única, para não precisar reeditar quando o formato de link mudar.
- **Dirigido por humano, não produzido pelo loop.** Sem ADR (mudança de superfície de busca do scout, não de convenção/gate). Fora do carve-out NFR-SEC-1 (scout não é guardian/sentinel/challenger). `owl-agents/` não sincroniza — o pack portátil não inclui scout/curator.
