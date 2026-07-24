# Changelog

All notable changes to the-owl are recorded here. Format loosely follows Keep a Changelog; the-owl versions its own evolution and, once the loop is live, each autonomous change lands as its own ADR + commit.

## [Unreleased]

### Added — Self-Improvement Loop (planning + architecture)
- **PRD** `docs/planning/prd-owl-self-improvement.md` — the daily autonomous loop that lets the-owl improve its own agents from field research, with rigorous scoring and a safe self-modification model.
- **EPIC-001** `docs/planning/stories/EPIC-001-self-improvement-loop.md` — US-001…US-009, MoSCoW, dependency graph.
- **Artifacts** `docs/planning/artifacts/` — the ChatGPT research-brief prompt (8a) and its output schema (8b).
- **ADR-001** `docs/decisions/ADR-001-self-improvement-loop.md` — Accepted. The loop, the 3 locked decisions (auto-commit to `main` · codex-automated input · full guardian+sentinel+challenger gate), and the load-bearing safety invariant **NFR-SEC-1** (the loop cannot autonomously edit its own guardrails), shadow-first rollout.
- **ADR template** `docs/decisions/000-template.md` — was referenced but missing; created.

### Pending (next: @builder)
- US-001 (git remote → `github.com/evolve-labs-cloud/the-owl`) · US-006 (`research-vault/`) · US-002 (`owl-research` skill) · US-003 (`scout`) · US-004 (`curator` + rubric) · US-005 (integrate) · US-007 (gate) · US-008 (`/owl:evolve` + schedule).
- Fast-follow: ADR-002 (vault schema), ADR-003 (rigor rubric).
