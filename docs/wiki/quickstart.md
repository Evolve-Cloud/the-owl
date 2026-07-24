# the-owl — Quickstart (for agents)

Navigable index of the-owl, maintained by @chronicler. **Read this before searching the code.** Every claim here is grounded in a real file; follow the links for detail.

## What this repository is
- A **markdown-only, no-runtime** library of specialized Claude Code agents (a DevFlow re-scaffold). Agents live in `.claude/commands/agents/*.md`.
- It **improves its own agents autonomously**, daily, via the self-improvement loop `/owl:evolve` — research the field → score against a rubric and against our own code → ADR-backed edit → gated → shadow PR.
- **Hub-and-spoke**: the orchestrator delegates; specialists hand off and return control, never call each other.
- **Safe self-modification**: the loop can improve any agent *except its own guardrails* (NFR-SEC-1, `docs/decisions/ADR-001-self-improvement-loop.md`).

## Start here
- [Architecture](architecture/overview.md) — the loop, the 10 agents, the safety model.
- [Workflows](workflows/self-improvement-cycle.md) — one cycle end-to-end; how to run and arm it.
- [Operations](operations/config-and-schedule.md) — config, the daily schedule, landing modes, follow-ups.
- [Architecture diagrams](../architecture/diagrams/self-improvement-loop.md) — 4 Mermaid diagrams (pipeline, topology, carve-out, git flow).

## Key source files
- `.claude/commands/owl/evolve.md` — the L0→L5 loop orchestrator.
- `.claude/commands/owl/research.md` — L0: codex CLI → daily research brief.
- `.claude/commands/agents/scout.md` — field research → normalized candidates.
- `.claude/commands/agents/curator.md` — rigor scoring + owns the research vault.
- `.claude/commands/agents/{architect,builder,guardian,sentinel,challenger,chronicler,strategist,system-designer}.md` — the DevFlow specialists.
- `.owl/loop-config.yml` — the brake pedal (landing mode, circuit breaker, rubric, safety floor).
- `research-vault/` — external-research RAG (`SCHEMA.md`, `ledger.md` = dedup truth, `inbox/ sources/ patterns/ ideas/`).
- `scripts/owl-daily.sh` + `scripts/com.evolvelabs.owl.daily.plist` — the daily schedule.

## Decision records (authoritative — `docs/decisions/`)
ADR-001 loop + NFR-SEC-1 carve-out · ADR-002 vault schema · ADR-003 rigor rubric · ADR-004 handoff-contract convention · ADR-005 gap-analysis vs own code (L1.5) · ADR-006/007/008 handoff rollout · ADR-009 role-ownership · ADR-010 inline execution + output verification.

## Conventions (`docs/conventions/`)
- `handoff-contract.md` — the 6-field agent handoff (ADR-004).
- `role-ownership.md` — "Papel & Não-Papel" ownership boundaries (ADR-009).

## Notes for agents
- **Two knowledge stores, separate on purpose:** `docs/wiki/` (this — internal, source-grounded) vs `research-vault/` (external field research). Never mix them.
- **The carve-out is load-bearing:** never let the loop autonomously edit sentinel/guardian/challenger, the rubric safety floor, `.owl/loop-config.yml`, `.claude/settings.json`, the schedule, `~/.ssh`, or secrets.
- **Every autonomous change is 1 idea → 1 ADR → 1 atomic commit**, landed as a shadow PR (`.owl/loop-config.yml` `landing: pr`).
- Update this wiki via `/agents:chronicler /wiki update` after structural changes.
