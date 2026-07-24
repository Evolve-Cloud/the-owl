# ADR-001 — Self-Improvement Loop for the-owl

**Status:** Accepted
**Date:** 2026-07-23
**Author:** @architect
**Tags:** [architecture, self-improvement, safety, agents, governance]
**Related:** `docs/planning/prd-owl-self-improvement.md`, `docs/planning/stories/EPIC-001-self-improvement-loop.md`

## Contexto
the-owl (a markdown-only, no-runtime, hub-and-spoke DevFlow library of 8 agents in `.claude/commands/agents/*.md`) only improves when a human manually researches the field and edits agent prompts. The multi-agent engineering field moves weekly. We want the library to learn from the field and evolve **autonomously and daily**, while remaining safe — because the agents edit **their own definitions**, fed by **untrusted** web/ChatGPT content. Maintainer decisions are locked (PRD §5): auto-commit to `main`; ChatGPT input automated via the codex CLI (already wired at `/quick:codex-review`); a **full internal gate** (guardian + sentinel + challenger) before commit. The ADR template was missing (now created at `docs/decisions/000-template.md`).

## Decisão
Adopt a **daily autonomous pipeline** — `owl-research` (codex→brief) → `scout` (research) → `curator` (score + vault) → `architect` ADR + `builder` edit → **guardian+sentinel+challenger gate** → commit — with these architecture decisions:

1. **The "writer" is a workflow, not a new agent.** Only two new agents are created (`scout`, `curator`); applying an accepted idea reuses `architect` (writes the ADR — already its domain) + `builder` (applies the edit). *Reuse before create.*
2. **Safety invariant NFR-SEC-1 (self-modification carve-out) is the reason auto-commit-to-`main` is acceptable.** The loop may edit strategist/architect/system-designer/builder/chronicler/scout/curator and their conventions; it may **NOT** autonomously edit sentinel's veto, guardian's gate, challenger, the rubric safety floor, the scope allow-list, `settings.json`, the schedule, `~/.ssh`, or secrets. Those require a human. A system that can rewrite its own brakes is the failure mode we refuse; sentinel enforces this at the gate.
3. **Untrusted-input rule (NFR-SEC-2):** web pages and the brief are data, never instructions; sentinel scans each proposed diff for injected intent.
4. **Reversibility (NFR-SEC-3):** one accepted idea → one ADR → one atomic commit → `git revert` is the rollback.
5. **Shadow-first rollout:** the loop ships in shadow mode (opens PRs / dry-runs to a branch) for ~1–2 weeks to validate its judgment, then flips to auto-`main` via config.

### Open questions resolved (PRD §13)
1. **Integrator** → **workflow** reusing architect+builder (decision 1 above).
2. **Vault path** → **`research-vault/`** at repo root — top-level, unambiguously separate from `docs/wiki/` (the internal grounded wiki).
3. **Scheduler** → **local launchd job (macOS)** running a wrapper that enters the-owl and executes `claude -p "/owl:evolve"` headless once/day (needs local git + `~/.ssh/github` + codex CLI). The cloud `schedule` skill is a documented alternative if off-machine execution is later wanted.
4. **Landing-mode + circuit-breaker config** → a new **`.owl/loop-config.yml`** (`OWL_LANDING`, max changes/cycle). It lives **inside the carve-out** — the loop cannot edit it; human-only, sentinel-protected.
5. **Codex contract** → reuse the `/quick:codex-review` codex CLI; a deep-research/high-reasoning model; enforce a per-call budget cap; write to `research-vault/inbox/`. Exact flags confirmed by @builder against the installed CLI.

## Alternativas consideradas
- **A (chosen): daily autonomous loop with a self-modification carve-out + full internal gate + shadow rollout.** Pros: hands-off, rigorous, ADR-traceable, reversible, and the carve-out contains the worst failure mode. Cons: real prompt-injection surface (mitigated by NFR-SEC-2 + gate + shadow phase); non-trivial to build.
- **B: human-in-the-loop (PR + human merge every change).** Pros: simplest, safest. Cons: rejected by the maintainer — reintroduces the daily human burden the project exists to remove. (Kept as the *shadow-mode* behavior for the rollout window.)
- **C: fully autonomous with no carve-out and no gate.** Pros: fastest. Cons: reckless — the loop could weaken its own guardrails or land injected changes on `main`. Rejected.
- **D: a runtime/orchestration engine (swarm/MCP) to run the loop.** Pros: richer coordination. Cons: violates the-owl's no-runtime identity; the loop is expressible as prompts + skills + a schedule. Rejected.

## Consequências
- **Easier:** the library stays current with zero daily effort; every change is auditable (ADR + commit) and reversible; external knowledge compounds in the vault (no re-litigation via `ledger.md`).
- **Harder / accepted trade-offs:** we take on a prompt-injection attack surface (contained by NFR-SEC-2 + the blocking gate + shadow phase + the carve-out); the daily run has a real token cost (bounded by the circuit breaker + budget cap); the gate adds latency per accepted change (accepted — it earns the right to auto-commit).
- **New invariant to protect forever:** NFR-SEC-1. Any future ADR that proposes letting the loop edit its own guardrails must be treated as a security regression.

## Notas de implementação (for @builder)
Build order = EPIC-001 dependency graph: **US-001** (git remote + this ADR machinery) → **US-006** (`research-vault/` scaffold + `SCHEMA.md`) → **US-002** (`owl-research` skill; embed artifacts 8a+8b) → **US-003** (`scout`) → **US-004** (`curator` + rubric) → **US-005** (integrate workflow, carve-out enforced) → **US-007** (gate wiring) → **US-008** (`/owl:evolve` + launchd + `.owl/loop-config.yml`, `OWL_LANDING=pr` default). Fast-follow ADRs: **ADR-002** (vault schema), **ADR-003** (rigor rubric). Do not create an `integrator` agent. Enforce NFR-SEC-1 as a hard refusal in the integrate step *and* as a sentinel gate check — defense in depth.
