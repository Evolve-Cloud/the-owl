# Changelog

All notable changes to the-owl are recorded here. Format loosely follows Keep a Changelog; the-owl versions its own evolution and, once the loop is live, each autonomous change lands as its own ADR + commit.

## [Unreleased]

### Cycle 2026-07-26 — autonomous /owl:evolve (shadow PR)
- **Fresh dual research:** codex brief `research-vault/inbox/research-brief-2026-07-26.md` (15 sources, 12 ideas — model `gpt-5.6-luna` again, same documented fallback; the brief's own `generator:` frontmatter inaccurately self-reports a different model, corrected in the vault) + scout live corroboration (`scout-notes-2026-07-26.md`, x1–x3, all independently verified real — none fabricated, including a specific arXiv id).
- **L1.5 grounding did real work again:** confirmed `.owl/state/` has no mid-cycle checkpoint (the accepted gap), confirmed `least-privilege-tool-scopes` has no enforcement path in the-owl's inline execution model (ADR-010) so its score moved **down** despite stronger evidence, and confirmed `evaluator-optimizer-loop` is now substantially covered by the fitness harness shipped 2026-07-25 (ADR-014/015).
- **1 accepted (provisional), 2 rejected, 2 aliases of already-decided ideas, 5 deferred.** Accepted: **`externalized-checkpoint-memory` (83 raw → 75 after the ADR-015 self-haircut)** — see ADR-016. Rejected: `trajectory-evals` (58 — its own best-cited source, read in full, argues the opposite of what it proposes) and `parallel-independent-work` (52 — no execution path in the current sequential loop, same shape as the earlier `isolated-workspaces` reject). Aliases (not re-litigated): `narrow-role-boundaries`→`role-ownership`, `structured-handoff-contracts`→`handoff-contract`.
- **Change (ADR-016):** a mid-cycle checkpoint for `/owl:evolve` (`.owl/state/cycle-in-progress.json`, written after each phase's existing verification, read at Setup with an explicit resume-or-fresh choice) — closes the ambiguity ADR-010 first flagged (a crashed cycle looks identical to "nothing ran yet"). **1 file touched** (`.claude/commands/owl/evolve.md`, additive only).
- **Gate (guardian/sentinel/challenger): PASS × 3** — 0 carve-out contact, no injection/secrets, additive-only. Challenger added a concrete revisit trigger: if the checkpoint is never found non-stale across ~5 cycles, that's grounds to remove it.
- **Landing:** shadow PR (`landing: pr`, default) — branch `owl/evolve-2026-07-26-externalized-checkpoint-memory`, not merged to `main`.

### 🦉 Milestone — Self-Improvement Loop LIVE (2026-07-24)
the-owl now improves its own agents autonomously, on a daily schedule, with a human merge gate.
- **Live & armed:** `/owl:evolve` runs headless **weekly, Mondays 07:13** (was daily until 2026-07-24 — the binding constraint is integration, not research; ADR-012) via launchd (`scripts/owl-daily.sh` + `com.evolvelabs.owl.daily.plist`), shadow-only by default (opens a PR; never auto-touches `main`).
- **3 autonomous cycles proposed, reviewed, and MERGED to `main`:** handoff-contract convention (ADR-004) → rolled into architect/builder/chronicler (ADR-006/007/008) → role-ownership convention (ADR-009). All PR branches cleaned up.
- **12 ADRs** (001–012) record every decision. Load-bearing invariant **NFR-SEC-1** (ADR-001): the loop may improve any agent **except its own guardrails** (sentinel veto, guardian gate, challenger, rubric safety floor, scope allow-list, `.owl/loop-config.yml`, schedule, `~/.ssh`, secrets) — those stay human-only. 0 carve-out contact across all cycles.
- **Proven behaviors:** dual research (codex + scout), rigorous scoring (it *rejected* `isolated-workspaces` at 41/100), gap-analysis against our own code (ADR-005), and reliable headless execution with per-phase output verification (ADR-010).

### Cycle 2026-07-24b — human-directed: finish the convention rollout + measure efficiency (committed to `main`)
- **Why now:** a new efficiency scorecard (`scripts/owl-metrics.py`, ADR-012) quantified the standing "convention debt" — `handoff-contract` on only 3/7 target agents, `role-ownership` on 0/7. The bottleneck is **integration, not research** (the same-day guard had already fired on daily cadence).
- **Rollout completed (ADR-011):** added the 6-field **"🤝 Contrato de Handoff"** to `curator`/`scout`/`strategist`/`system-designer` and the 5-field **"🧭 Papel & Não-Papel"** to all 7 pipeline specialists (`architect`/`builder`/`chronicler`/`curator`/`scout`/`strategist`/`system-designer`); `system-designer.meta.yaml` gained a `constraints` block. **176 insertions, 0 deletions.** Both conventions now **7/7 (100%)**.
- **`team` excluded as N/A by design:** it is the DevFlow parallel **orchestrator (hub)**, not a pipeline specialist — encoded as `NA_FOR_CONVENTIONS`, printed on its own line, not silently dropped. @challenger verdict: legitimate, "the honest denominator."
- **L1.5 grounding (ADR-005) corrected ADR-009:** `scout`/`curator` DO have `.meta.yaml` in the canonical `.devflow/agents/`; only `team` lacks one. The `.claude/commands/agents/*.meta.yaml` mirrors are drifted → tracked follow-up.
- **Efficiency (ADR-012):** shipped the read-only rollout-coverage scorecard + moved the schedule **daily → weekly (Mondays 07:13)**. Headline metric = *is accepted work finished across the fleet?* (not ADR/PR counts). Cost instrumentation = follow-up.
- **Gate (guardian/sentinel/challenger): PASS × 3** — additive-only + agent-specific, 0 carve-out contact, no injection/secrets, real improvement. **Landing: committed to `main`** (human-directed, attended, gate-reviewed — deliberate deviation from shadow-PR, since `gh` is absent and the directive was to finish it without a human merge step).

### Cycle 2026-07-24 — autonomous /owl:evolve (merged via PR #3)
- **Fresh dual research:** codex brief `research-vault/inbox/research-brief-2026-07-24.md` (22 sources, 16 ideas — default model `gpt-5.6-luna` via `~/.codex`; the deep-research model is not available on this ChatGPT account, so the skill's documented fallback was used) + scout live pass (`scout-notes-2026-07-24.md`, x1–x5).
- **L1.5 grounding (ADR-005) mattered:** scoring against the real code found ownership is already in `.meta.yaml` for **8/11** agents, but `scout`, `curator`, `sentinel` lack it — a concrete inconsistency (sentinel = carve-out, human-only).
- **1 accepted / 1 rejected / rest deferred** — accepted `role-ownership` (87/100, promotes the previously-deferred `explicit-role-boundaries` with today's stronger evidence); rejected `isolated-workspaces` (41 — runtime-shaped, applicability 2/5).
- **Change (merged):** **ADR-009** + `docs/conventions/role-ownership.md` (the "Papel & Não-Papel" ownership convention). Gate (guardian/sentinel/challenger) PASS; **0 carve-out contact**. Challenger flag (non-blocking): two conventions (handoff-contract, role-ownership) now await rollout — prioritize rollout over new conventions next cycle.

### Cycle 2026-07-23b — /owl:evolve continuation (merged via PR #2)
- **Same-day guard honored:** no new codex research spend — the cycle-1 brief was still fresh, so the loop processed the **queued backlog** instead of re-running L0.
- **First cycle to use L1.5 grounding (ADR-005):** audited the real agent files — architect/builder/chronicler had **no** handoff-contract section (only informal prose); scout/curator partial. This grounded the acceptance in the real gap.
- **1 accepted (94/100):** `handoff-contract-rollout` — the follow-up ADR-004 explicitly deferred. Rolled the "🤝 Contrato de Handoff" convention (6 fields) into the three integrate→land agents, **at the circuit-breaker cap (3)**.
- **Change:** ADR-006 (architect) + ADR-007 (builder) + ADR-008 (chronicler), each = 1 additive, agent-specific handoff-contract section. Gate (guardian/sentinel/challenger) **PASS** — additive-only, role boundaries preserved, no injection/secrets, 0 carve-out contact, real (not cargo-cult) improvement.
- **Queued next:** roll the same convention into scout/curator (partial) + strategist/system-designer; the deferred backlog ideas remain untouched (not re-litigated).

### Cycle 2026-07-23 — first autonomous /owl:evolve (merged via PR #1)
- **Dual research proven:** codex brief (ChatGPT-side) + scout live web research (Claude-side), merged/deduped by curator.
- **1 accepted / 9 deferred** — curator scored the merged set; accepted `handoff-contract` (91/100), rest deferred (evidence captured, not re-litigated).
- **Change (merged):** ADR-004 + `docs/conventions/handoff-contract.md` (standardized agent handoff contract). Gate (guardian/sentinel/challenger) PASS; 0 carve-out contact.

### Added — Self-Improvement Loop (planning + architecture)
- **PRD** `docs/planning/prd-owl-self-improvement.md` — the daily autonomous loop that lets the-owl improve its own agents from field research, with rigorous scoring and a safe self-modification model.
- **EPIC-001** `docs/planning/stories/EPIC-001-self-improvement-loop.md` — US-001…US-009, MoSCoW, dependency graph.
- **Artifacts** `docs/planning/artifacts/` — the ChatGPT research-brief prompt (8a) and its output schema (8b).
- **ADR-001** `docs/decisions/ADR-001-self-improvement-loop.md` — Accepted. The loop, the 3 locked decisions (auto-commit to `main` · codex-automated input · full guardian+sentinel+challenger gate), and the load-bearing safety invariant **NFR-SEC-1** (the loop cannot autonomously edit its own guardrails), shadow-first rollout.
- **ADR template** `docs/decisions/000-template.md` — was referenced but missing; created.

### Added — Implementation (@builder)
- **Git** — the-owl connected to `github.com/evolve-labs-cloud/the-owl` (branch `main`).
- **Vault** `research-vault/` — Obsidian external-research RAG (SCHEMA + index/log/overview/ledger + inbox/sources/patterns/ideas). See **ADR-002**.
- **scout** + **curator** agents — `.claude/commands/agents/{scout,curator}.md` + `.devflow/agents/*.meta.yaml`, registered in `project.yaml` (10 agents). scout researches; curator scores rigorously and owns the vault. Rubric in **ADR-003**.
- **Commands** — `/owl:research` (codex → daily brief) and `/owl:evolve` (the L0→L5 loop orchestrator; carve-out + circuit breaker enforced).
- **Schedule** — `scripts/owl-daily.sh` + launchd template `scripts/com.evolvelabs.owl.daily.plist` (human loads it once; not auto-installed).
- **Config** `.owl/loop-config.yml` — landing mode (default `pr`/shadow), circuit breaker, rubric threshold + safety floor.

### Done since
- ✅ First `/owl:evolve` run validated the codex output-capture flag + the full pipeline (verified `codex exec -o/--output-last-message`, committed in `bfcdbf7`).
- ✅ Daily schedule armed (`launchctl bootstrap`, `com.evolvelabs.owl.daily` loaded; first scheduled run fired 2026-07-24 07:13).
- ✅ Headless reliability hardened — inline phase execution + per-phase output verification (ADR-010), after the first scheduled run exposed a silent scout no-op.

### Known follow-ups (non-blocking)
- **Convention rollout > new conventions** (the loop's own challenger flag): roll handoff-contract + role-ownership into the remaining agents (scout/curator/strategist/system-designer; sentinel/guardian/challenger = human-only, carve-out).
- **codex deep-research model** unavailable on the account → falls back to `gpt-5.6-luna`. Point `research.model` at an available model if the deep-research tier is wanted.
- **Tokenless launchd PR-open:** scheduled runs push the branch but can't open the PR (no `gh`/token in that env) — a human opens it. ADR-010 records the branch + compare URL fallback.
- **Docs:** `docs/wiki/` not yet initialized; `.devflow/knowledge-graph.json` referenced in `project.yaml` but not present (regenerate via `/graph regenerate`).
- **Diagrams:** architecture diagrams added in `docs/architecture/diagrams/` (Mermaid).
