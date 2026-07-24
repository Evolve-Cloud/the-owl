# Changelog

All notable changes to the-owl are recorded here. Format loosely follows Keep a Changelog; the-owl versions its own evolution and, once the loop is live, each autonomous change lands as its own ADR + commit.

## [Unreleased]

### Cycle 2026-07-24 — autonomous /owl:evolve (shadow mode, proposed on a branch)
- **Fresh dual research:** codex brief `research-vault/inbox/research-brief-2026-07-24.md` (22 sources, 16 ideas — default model `gpt-5.6-luna` via `~/.codex`; the deep-research model is not available on this ChatGPT account, so the skill's documented fallback was used) + scout live pass (`scout-notes-2026-07-24.md`, x1–x5).
- **L1.5 grounding (ADR-005) mattered:** scoring against the real code found ownership is already in `.meta.yaml` for **8/11** agents, but `scout`, `curator`, `sentinel` lack it — a concrete inconsistency (sentinel = carve-out, human-only).
- **1 accepted / 1 rejected / rest deferred** — accepted `role-ownership` (87/100, promotes the previously-deferred `explicit-role-boundaries` with today's stronger evidence); rejected `isolated-workspaces` (41 — runtime-shaped, applicability 2/5).
- **Change proposed (not on main):** **ADR-009** + `docs/conventions/role-ownership.md` (the "Papel & Não-Papel" ownership convention). Gate (guardian/sentinel/challenger) PASS; **0 carve-out contact**. Challenger flag (non-blocking): two conventions (handoff-contract, role-ownership) now await rollout — prioritize rollout over new conventions next cycle. On branch `owl/evolve-2026-07-24-role-ownership`.

### Cycle 2026-07-23b — /owl:evolve continuation (merged via PR #2)
- **Same-day guard honored:** no new codex research spend — the cycle-1 brief was still fresh, so the loop processed the **queued backlog** instead of re-running L0.
- **First cycle to use L1.5 grounding (ADR-005):** audited the real agent files — architect/builder/chronicler had **no** handoff-contract section (only informal prose); scout/curator partial. This grounded the acceptance in the real gap.
- **1 accepted (94/100):** `handoff-contract-rollout` — the follow-up ADR-004 explicitly deferred. Rolled the "🤝 Contrato de Handoff" convention (6 fields) into the three integrate→land agents, **at the circuit-breaker cap (3)**.
- **Change:** ADR-006 (architect) + ADR-007 (builder) + ADR-008 (chronicler), each = 1 additive, agent-specific handoff-contract section. Gate (guardian/sentinel/challenger) **PASS** — additive-only, role boundaries preserved, no injection/secrets, 0 carve-out contact, real (not cargo-cult) improvement.
- **Queued next:** roll the same convention into scout/curator (partial) + strategist/system-designer; the deferred backlog ideas remain untouched (not re-litigated).

### Cycle 2026-07-23 — first autonomous /owl:evolve (shadow mode, proposed on a branch)
- **Dual research proven:** codex brief (ChatGPT-side) + scout live web research (Claude-side), merged/deduped by curator.
- **1 accepted / 9 deferred** — curator scored the merged set; accepted `handoff-contract` (91/100), rest deferred (evidence captured, not re-litigated).
- **Change proposed (not on main):** ADR-004 + `docs/conventions/handoff-contract.md` (standardized agent handoff contract). Gate (guardian/sentinel/challenger) PASS; 0 carve-out contact. On branch `owl/evolve-2026-07-23-handoff-contract`.

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

### Remaining
- (Optional) wire the L4 gate role explicitly into `sentinel`/`guardian` prompts — `/owl:evolve` already instructs them per-run.
- First real `/owl:evolve` run to validate the codex output-capture flag + the pipeline end-to-end (shadow mode).
- Human step to arm the daily schedule: `launchctl load ~/Library/LaunchAgents/com.evolvelabs.owl.daily.plist`.
