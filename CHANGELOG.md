# Changelog

All notable changes to the-owl are recorded here. Format loosely follows Keep a Changelog; the-owl versions its own evolution and, once the loop is live, each autonomous change lands as its own ADR + commit.

## [Unreleased]

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
