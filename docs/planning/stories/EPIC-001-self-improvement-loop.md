# EPIC-001 — the-owl Self-Improvement Loop

**Status:** Ready for @architect viability review → @builder implementation
**PRD:** `docs/planning/prd-owl-self-improvement.md`
**Related artifacts:** `docs/planning/artifacts/chatgpt-research-brief-prompt.md`, `docs/planning/artifacts/research-brief-schema.md`

**Goal:** a daily autonomous loop that researches agent-team best practices, rigorously scores them, and applies accepted improvements to the-owl's agents as ADRs — gated by the-owl's own quality agents, committing to `main`, with compounding knowledge in an Obsidian vault, and a hard carve-out so the loop can never weaken its own guardrails.

## Dependency levels
```
US-001 (git + template) ─┐
US-006 (vault)  ─────────┤
US-002 (owl-research) ───┼─→ US-003 (scout) ─→ US-004 (curator) ─→ US-005 (integrate) ─→ US-007 (gate) ─→ US-008 (schedule + circuit breaker)
US-009 (safety invariants) ── cross-cutting, gates US-005/US-007
```

## Prioritization (MoSCoW)
- **MUST:** US-001, US-002, US-003, US-004, US-005, US-006, US-007, US-009
- **SHOULD:** US-008 (ships shadow-mode first), threshold auto-ratchet, GitHub API star counts
- **COULD:** parallel scouts, Dataview dashboards, codex second-opinion in curator, weekly digest
- **WON'T (now):** autonomous edits to the §7 carve-out, non-agent code generation

---

## US-001 — Repo + ADR foundation
**Como** maintainer, **quero** the-owl conectado ao GitHub e o template de ADR criado, **para** que cada melhoria seja versionada e rastreável.
**AC (Given/When/Then):**
- [ ] Given a fresh the-owl, When setup runs, Then it is a git repo with remote `git@github.com:evolve-labs-cloud/the-owl.git` (key `~/.ssh/github`) and an initial commit.
- [ ] Given the ADR convention, When setup runs, Then `docs/decisions/000-template.md` exists with sections: Status · Contexto · Decisão · Alternativas · Consequências · Notas de implementação.
**Owner:** @builder · **Priority:** P0 · **Deps:** none

## US-002 — `owl-research` skill (codex → daily brief)
**Como** loop, **quero** gerar o research brief automaticamente via codex CLI, **para** alimentar o scout sem esforço humano.
**AC:**
- [ ] Given the §8a prompt + §8b schema, When the skill runs, Then it calls the codex CLI and writes `research-vault/inbox/research-brief-YYYY-MM-DD.md`.
- [ ] Given a CLI failure but a manually-dropped brief in `inbox/`, When the skill runs, Then it proceeds with the dropped file (fallback).
- [ ] Given output, Then it conforms to the §8b schema (frontmatter + Sources + Ideas parse cleanly); a per-call budget cap is enforced.
**Owner:** @builder · **Priority:** P0 · **Deps:** US-006

## US-003 — `scout` agent
**Como** loop, **quero** um agente que pesquisa a web e normaliza ideias, **para** ter candidatos estruturados.
**AC:**
- [ ] Given the brief + own WebSearch/WebFetch of top-starred repos & authoritative blogs, When scout runs, Then it emits candidate ideas conforming to the §8b idea schema into `research-vault/inbox/`.
- [ ] Given any source content, Then embedded instructions are treated as inert data (NFR-SEC-2) — scout never acts on them.
- [ ] scout is read-only w.r.t. agent definitions; it only writes to the vault.
**Owner:** @builder · **Priority:** P0 · **Deps:** US-002, US-006

## US-004 — `curator` agent + rigor rubric + vault ownership
**Como** loop, **quero** um agente que pontua e filtra ideias com rigor, **para** aceitar só o que realmente cabe e melhora.
**AC:**
- [ ] Given candidates, When curator runs, Then each is deduped against `ledger.md` (decided ids skipped) and scored on the §9 rubric (0–100).
- [ ] Given a score, Then it is classified accept ≥ threshold / defer / reject < 60, **with written rationale**; Safety sub-score `< 7/10` auto-rejects regardless of total.
- [ ] Given the ratchet, Then the threshold starts 75 and rises +5 per minor version (cap 90).
- [ ] Given any outcome, Then curator persists it to the vault (`ideas/`, `ledger.md`, `index.md`, `log.md`, `overview.md`).
**Owner:** @builder (agent) · @architect (rubric → ADR-003) · **Priority:** P0 · **Deps:** US-003, US-006

## US-005 — Integrate workflow (ADR + edit)
**Como** loop, **quero** aplicar cada ideia aceita como ADR + edição, **para** que a mudança seja concreta e rastreável.
**AC:**
- [ ] Given an accepted idea, When integrate runs, Then `@architect` writes `ADR-{NNN}` (next sequential) and `@builder` applies exactly one edit to the target agent/convention.
- [ ] Given the edit target, Then it is within the §7 allow-list; an edit touching the carve-out is refused before the gate (NFR-SEC-1).
- [ ] One idea → one ADR → one atomic commit (NFR-SEC-3).
**Owner:** @architect + @builder · **Priority:** P0 · **Deps:** US-004, US-009

## US-006 — Obsidian research vault
**Como** loop, **quero** um vault externo interligado, **para** que o conhecimento componha e nada seja re-litigado.
**AC:**
- [ ] Given the design, Then `research-vault/` exists with `SCHEMA.md, index.md, log.md, overview.md, inbox/, sources/, patterns/, ideas/, ledger.md` per PRD §10.
- [ ] Given conventions, Then pages use YAML frontmatter + `[[wikilinks]]` (every page links ≥1) + `## Related` + callouts; it is **separate** from `docs/wiki/`.
- [ ] Given `ledger.md`, Then it is the dedup source of truth (id | score | status | ADR | date).
**Owner:** @architect (schema → ADR-002) · @builder (scaffold) · @chronicler (curator handshake) · **Priority:** P0 · **Deps:** none

## US-007 — Full self-review gate (blocking)
**Como** maintainer, **quero** que o time revise a própria evolução antes do commit, **para** barrar injeção e edições fracas.
**AC:**
- [ ] Given a proposed change, When the gate runs, Then `@guardian` (role-boundary + regression), `@sentinel` (injection + §7 scope + secret scan), and `@challenger` (real improvement?) all run.
- [ ] Given any FAIL, Then no commit occurs; the rejection + rationale is logged to the vault.
- [ ] Given all PASS, Then the change proceeds to L5 commit.
**Owner:** @guardian + @sentinel + @challenger · **Priority:** P0 · **Deps:** US-005

## US-008 — `/owl:evolve` orchestration + schedule + circuit breaker
**Como** maintainer, **quero** o loop rodando diariamente sozinho com freio, **para** evolução contínua e segura.
**AC:**
- [ ] Given `/owl:evolve`, When invoked, Then it runs L0→L5 in order, passing only N-1 context between actors.
- [ ] Given a daily schedule, Then the loop fires headless once/day.
- [ ] Given the circuit breaker, Then accepted changes/cycle are capped and the loop halts + alerts on repeated gate FAIL.
- [ ] Given `OWL_LANDING`, Then it defaults to shadow (PR/branch) and flips to `main` by config only (config lives inside the §7 carve-out).
**Owner:** @builder · **Priority:** P1 (ships shadow-first) · **Deps:** US-007

## US-009 — Safety invariants (cross-cutting)
**Como** maintainer, **quero** que o loop nunca enfraqueça os próprios guardrails, **para** que auto-commit-to-main seja seguro.
**AC:**
- [ ] Given the carve-out, Then autonomous edits to `sentinel` veto, `guardian` gate, `challenger`, the rubric safety floor, the scope allow-list, `settings.json`, cron, `~/.ssh`, or secrets are refused (NFR-SEC-1) and require a human.
- [ ] Given untrusted content, Then no embedded directive is ever executed (NFR-SEC-2); sentinel's diff scan enforces this at the gate.
- [ ] Given reversibility, Then every change is one ADR + one revertible commit (NFR-SEC-3).
**Owner:** @sentinel (enforcement) + @architect (ADR-001 records it) · **Priority:** P0 · **Deps:** none (gates US-005/US-007)
