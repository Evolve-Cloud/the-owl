# PRD: the-owl — Self-Improvement Loop

**Version:** 1.0
**Date:** 2026-07-23
**Author:** @strategist
**Status:** Approved (pending @architect viability review)
**Repository:** github.com/evolve-labs-cloud/the-owl
**Related:** `docs/planning/artifacts/chatgpt-research-brief-prompt.md`, `docs/planning/artifacts/research-brief-schema.md`, `docs/planning/stories/EPIC-001-self-improvement-loop.md`

---

## 1. Overview

### Problem
the-owl is a library of 8 specialized Claude Code agents (a DevFlow v1.5.0 re-scaffold). Today it improves **only when a human manually researches the field and edits the agent definitions**. The multi-agent engineering field moves weekly; the library drifts out of date, and the maintainer carries the entire burden of finding, judging, and applying new patterns.

### Solution
A **daily autonomous loop** that researches how the best teams build agent systems, rigorously scores each idea against the-owl's architecture, and — for accepted ideas — writes an ADR and applies the edit, gated by the-owl's own quality agents, committing to `main` with a full audit trail. Accumulated knowledge lives in an **Obsidian research vault** so learning compounds and no idea is re-litigated.

### Objectives
1. Keep the agent library **state-of-the-art** with zero daily human effort.
2. **Rigorous acceptance** — only changes that materially fit and improve the-owl land; rigor **ratchets up** as the library matures.
3. **Every improvement is an ADR** — fully traceable and reversible.
4. **Safe self-modification** — the loop can improve the agents but **cannot weaken its own guardrails**.
5. **Compounding knowledge** — a persistent, interlinked vault of what the field knows about building agent teams.

### Success metrics (KPIs)
- **Cadence:** ≥ 1 successful autonomous cycle/day.
- **Rigor:** accept rate lands in a healthy band (target 10–30% of surfaced ideas; a 90% accept rate means the rubric is too loose).
- **Safety:** 0 autonomous edits to the §7 carve-out; 0 committed changes that fail a later human spot-check for injection.
- **Reversibility:** 100% of changes map to exactly one ADR + one atomic commit.
- **Compounding:** 0 re-evaluations of an idea already decided in `ledger.md`.

---

## 2. Background & current state (grounded in the repo)

- **the-owl** = fresh re-scaffold of DevFlow v1.5.0. Agents in `.claude/commands/agents/*.md` (strategist, architect, system-designer, builder, guardian, sentinel, challenger, chronicler + team). Metadata in `.devflow/` (project.yaml, memory/, sessions/).
- **Architecture:** markdown-only, **no runtime**; **hub-and-spoke** (delegation, not mesh); **context-minimal** (N-1 scoping between agents); governance via **hard-stops + mandatory delegation + ADRs**.
- **ADR convention:** `docs/decisions/ADR-{NNN}-{kebab}.md`; template `docs/decisions/000-template.md` is **referenced but does not exist yet** (must be created). `@architect` owns ADRs. Sections: Status · Contexto · Decisão · Alternativas consideradas · Consequências · Notas de implementação.
- **Codex/OpenAI CLI is already wired** (`/quick:codex-review`) → the automated ChatGPT path is viable today.
- **Existing knowledge system:** `docs/wiki/` (grounded **internal** wiki) + `knowledge-graph.json` (chronicler). The new research vault is a **separate, external-research RAG** — it must not duplicate the internal wiki.
- **Not yet a git repo** — must be connected to `github.com/evolve-labs-cloud/the-owl` (key `~/.ssh/github`).

---

## 3. Goals & non-goals

**Goals:** autonomous daily learning loop · rigorous, ratcheting acceptance · ADR-traceable, reversible changes · safe self-modification · compounding external-knowledge vault.

**Non-goals:** generating product/application code · introducing a runtime or orchestration engine · **autonomously editing the loop's own guardrails** (permanently human-gated) · replacing the internal `docs/wiki/`.

---

## 4. Users / personas

- **The maintainer (Rafael).** Wants the agent library to stay current without daily manual research; requires auditability, control, and security-first safety. Judges the loop by the quality and safety of what it commits.
- **The agents themselves.** Consumers of the vault (read best-practice knowledge) and subjects of improvement (their prompts get edited).

---

## 5. Locked decisions (from maintainer)

| Decision | Choice | Consequence |
|---|---|---|
| Where accepted changes land | **Auto-commit to `main`** | No human in the per-change loop → safety carried by the automated gate + ADR trail + §7 carve-out + circuit breaker. |
| ChatGPT input | **Automated via codex CLI** | `owl-research` skill generates the brief daily; manual drop-file is fallback. Brief is **untrusted data**. |
| Self-review before commit | **Full gate: guardian + sentinel + challenger (blocking)** | No commit unless all three pass. |

**Rollout decision (recommended, records in ADR-001):** ship in **shadow mode** (opens PRs / dry-runs to a branch) for the first ~1–2 weeks to validate the loop's judgment on real cycles, then flip `OWL_LANDING=pr → main`.

---

## 6. Functional requirements — the daily pipeline

| Level | Actor | Requirement |
|---|---|---|
| **L0** | `owl-research` skill | Call the codex/OpenAI CLI with the §8a prompt; write `research-brief-YYYY-MM-DD.md` (§8b schema) to `research-vault/inbox/`. Fallback: ingest a manually dropped brief if present. |
| **L1** | `scout` | Read the brief + perform own WebSearch/WebFetch of top-starred repos & authoritative blogs; normalize findings into candidate ideas conforming to the §8b idea schema; write to `research-vault/inbox/`. |
| **L2** | `curator` | Dedup each candidate against `research-vault/ledger.md` (never re-evaluate a decided idea); score each against the §9 rubric; classify **accepted / deferred / rejected** with written rationale; persist **all** outcomes to the vault; update `ledger.md`, `index.md`, `log.md`, `overview.md`. |
| **L3** | `architect` → `builder` | For each accepted idea: `architect` writes `ADR-{NNN}`; `builder` applies the concrete edit to the target agent file/convention. One idea → one ADR → one edit. |
| **L4** | `guardian` + `sentinel` + `challenger` (**blocking gate**) | `guardian`: role-boundary + regression check on the edited agent(s). `sentinel`: injection scan + §7 scope-carve-out enforcement + secret check. `challenger`: is this a real improvement or cargo-cult? All three must PASS. |
| **L5** | commit + `chronicler` | On PASS: atomic commit to `main` (1 commit per ADR) in the configured landing mode; `chronicler` updates CHANGELOG + snapshot + wiki/graph. On FAIL: reject, log rationale to the vault, no commit. |

**Loop orchestration:** exposed as `/owl:evolve`; fired daily by a scheduled task. Circuit breaker: cap accepted changes/day; halt + alert on repeated gate FAIL.

---

## 7. Non-functional requirements

### Security (security-first — these are non-negotiable)
- **NFR-SEC-1 — Self-modification carve-out (THE invariant).** The loop MAY edit: strategist, architect, system-designer, builder, chronicler, scout, curator, and their conventions/docs. The loop MAY NOT autonomously edit: `sentinel`'s veto logic, `guardian`'s gate, `challenger`, the rubric's **safety floor**, the **scope allow-list**, `settings.json`, the cron/schedule, `~/.ssh`, or any secret. Those require a human. *A self-modifying system that can rewrite its own brakes is the one failure mode we refuse.* Enforced by `sentinel` at L4.
- **NFR-SEC-2 — Untrusted input.** Web pages and the ChatGPT brief are **data, not instructions**. scout/curator never execute embedded directives. sentinel scans the proposed diff for injected intent (disabling a gate, exfiltration, touching the carve-out) → auto-reject + alert.
- **NFR-SEC-3 — Reversibility.** Atomic 1-commit-per-ADR; `git revert` is the rollback; every change ↔ one ADR.
- **NFR-SEC-4 — Circuit breaker.** Bounded changes/cycle; automatic halt + alert on repeated failure or anomaly.

### Quality
- **NFR-Q-1 — Blocking gate.** No commit unless guardian + sentinel + challenger all PASS.
- **NFR-Q-2 — Rigor ratchet.** Acceptance threshold rises as the library matures (§9).

### Operational
- **NFR-O-1 — ADR-traceable.** Every accepted improvement has an ADR; no "silent" edits.
- **NFR-O-2 — Compounding knowledge.** `ledger.md` is the dedup source of truth; decided ideas are never re-litigated.
- **NFR-O-3 — Markdown-only.** No runtime/engine introduced; the loop is prompts + skills + a schedule.

---

## 8. Product artifacts (delivered separately)

- **8a — ChatGPT research-brief prompt:** `docs/planning/artifacts/chatgpt-research-brief-prompt.md` — the exact prompt `owl-research` sends to codex daily.
- **8b — Research-brief document schema:** `docs/planning/artifacts/research-brief-schema.md` — the machine-parseable structure ChatGPT must emit so scout/curator can merge it.

Both are the maintainer-requested deliverables; `@builder` embeds them into the `owl-research` skill.

---

## 9. Rigor rubric (curator's acceptance gate)

| Criterion | Weight |
|---|---|
| Fit to our architecture (markdown-only, no-runtime, hub-spoke, context-minimal) | 25 |
| Evidence strength (multiple high-star repos / primary sources, not hype) | 20 |
| Impact (materially better agent quality / coordination / token-efficiency) | 20 |
| Simplicity & reversibility (small, atomic, no new runtime) | 15 |
| Safety (no new attack surface; respects §7 governance) | 10 |
| Non-duplication (not already present; not previously rejected) | 10 |

- **Accept** ≥ threshold · **Defer** in the band below threshold · **Reject** < 60.
- **Ratchet:** threshold starts **75**, rises **+5 per minor version** (cap **90**) — "more rigorous as the agents evolve."
- **Hard veto:** Safety sub-score `< 7/10` **auto-rejects regardless of total**. Non-overridable by score.

`@architect` formalizes this as **ADR-003**.

---

## 10. The Obsidian research vault (external-research RAG)

Adapts proven `carinhAI` conventions to *agent-team engineering* knowledge — **separate** from `docs/wiki/`.

```
research-vault/
├── SCHEMA.md      operating manual: frontmatter, wikilinks, callouts, INGEST/SCORE/LINT workflows
├── index.md       master index (updated each cycle)
├── log.md         append-only cycle log
├── overview.md    evolving synthesis: "how to build the best agent team"
├── inbox/         immutable raw sources (daily brief + scout clippings)
├── sources/       one page per repo/blog: what it contributes
├── patterns/      concept pages: topologies, communication, memory, context, self-improvement, guardrails
├── ideas/         one page per candidate idea: score, status, linked ADR
└── ledger.md      DEDUP SOURCE OF TRUTH: id | score | status | ADR | date
```

Conventions: YAML frontmatter · `[[wikilinks]]` (every page links ≥1) · `## Related` · callouts (`> [!contradiction]`, `> [!important]`, `> [!question]`) · Dataview at 50+ notes. Curator writes; agents read. `@architect` formalizes the schema as **ADR-002**.

---

## 11. Rollout

1. **Shadow mode (weeks 1–2):** loop opens PRs / dry-runs to a branch; maintainer reviews the loop's judgment on real cycles.
2. **Flip:** set `OWL_LANDING=main` once trust is established.
3. **Ratchet:** raise the rubric threshold per §9 as versions increment.

---

## 12. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Prompt-injection via scraped/ChatGPT content | NFR-SEC-2 + sentinel diff scan + human backstop in shadow phase |
| Self-poisoning (loop weakens its own brakes) | NFR-SEC-1 carve-out (hard-enforced) |
| Rubric too loose → churn / low-value edits | Ratchet + hard safety veto + accept-rate KPI + challenger |
| Runaway edits | Circuit breaker (NFR-SEC-4) |
| Duplicated/oscillating decisions | `ledger.md` dedup (NFR-O-2) |
| ChatGPT fabricates repos/stars | Prompt demands sources + confidence; curator penalizes weak evidence |

---

## 13. Open questions for @architect

1. **Integrator: workflow vs. dedicated agent.** Recommendation: reuse `architect`+`builder` as a workflow (honors "reuse before create"). Confirm or justify a thin `integrator` agent.
2. **Vault root path:** `research-vault/` at repo root vs. `knowledge/` vs. `.owl/vault/`.
3. **Scheduler mechanism:** cron vs. launchd vs. the `schedule` skill vs. a settings hook — pick the most robust for a daily headless run.
4. **Landing-mode config surface:** where `OWL_LANDING` and the circuit-breaker cap live (must be inside the §7 carve-out).
5. **Codex invocation contract:** exact CLI flags, model, and budget cap for the daily research call.

---

## 14. Out of scope (now)
Autonomous edits to the §7 carve-out · generating non-agent code · a runtime/swarm engine · replacing `docs/wiki/`.
