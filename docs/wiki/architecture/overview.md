# Architecture — the loop, the agents, the safety model

How the-owl is put together. Visual companion: [`docs/architecture/diagrams/self-improvement-loop.md`](../../architecture/diagrams/self-improvement-loop.md).

## What exists
- **The loop** — `.claude/commands/owl/evolve.md` (orchestrator, L0→L5) + `.claude/commands/owl/research.md` (L0 codex brief).
- **13 agent PAIRS (ADR-028)** — every persona exists twice by design: `.claude/agents/*.md` (native subagents, harness-enforced frontmatter) + `.claude/commands/agents/*.md` (command personas):
  - Loop-specific: `scout.md` (field research), `curator.md` (rigor scoring + owns the vault).
  - DevFlow specialists: `strategist`, `architect`, `system-designer`, `builder`, `guardian`, `sentinel`, `challenger`, `chronicler`, `database-specialist`, `mcp-builder` (+ `team.md` orchestration).
  - Structured metadata mirrors in `.devflow/agents/*.meta.yaml`.
- **Research vault** — `research-vault/` (`SCHEMA.md`, `index.md`, `overview.md`, `log.md`, `ledger.md`, `capabilities/agent-capability-matrix.md`, `inbox/ sources/ patterns/ ideas/`).
- **Config / brake pedal** — `.owl/loop-config.yml`.
- **Decision records** — `docs/decisions/ADR-001..040`.

## How it works
- **Topology is SCOPED (ADR-038, `docs/conventions/structural-properties.md` P7a/P7b).** Inside `/owl:evolve`: hub-and-spoke — only the orchestrator invokes an agent; specialists return control (P7a TRUE). In interactive DevFlow: 9 of 13 pairs deliberately instruct Skill-tool peer invocation (P7b — by design). Handoffs follow `docs/conventions/handoff-contract.md`.
- **Context-minimal.** Each phase gets only what it needs (the prior output + pointers), not the whole history.
- **Execution model (ADR-010).** Native subagents EXIST (13, since PR #17), but the loop runs each phase **inline by reliability decision** (reads the agent `.md`, follows it) and **verifies each phase's expected artifact exists** — a no-op is detected, never silently absorbed.
- **The vault is the memory; the agents/ADRs are the change.** `research-vault/ledger.md` is the dedup source of truth — a decided idea is never re-litigated.

## Why it is this way
- **The boundary, not a missing runtime (structural-properties.md, ADR-035/038)** — a spawner, a scheduler and git hooks all EXIST; what disqualifies an idea is that the loop may not touch them (carve-out) and is sequential by design (ADR-010). Usable ideas are prompt/structure/convention changes — never "adopt framework X". Enforced by the rubric (`docs/decisions/ADR-003-rigor-rubric.md`) + the REJECTED CLASSES block.
- **Hub-and-spoke inside the loop** — avoids uncontrolled fan-out and keeps a single stop-gate (scope: P7a).
- **Safety model — NFR-SEC-1 carve-out** (`docs/decisions/ADR-001-self-improvement-loop.md`): the loop may improve strategist/architect/system-designer/builder/chronicler/scout/curator and conventions, but **may not autonomously edit** sentinel's veto, guardian's gate, challenger, the rubric safety floor, the scope allow-list, `.owl/loop-config.yml`, `.claude/settings.json`, the schedule, `~/.ssh`, or secrets. This is what makes autonomous landing acceptable; enforced at L3 (pre-check) and L4 (sentinel).
- **Grounding against our own code (ADR-005)** — before scoring, the curator audits the real agent files so ideas are judged against reality, not in the abstract.

## Extension points
- **New agent:** add `.claude/commands/agents/<name>.md` + `.devflow/agents/<name>.meta.yaml`, register in `.devflow/project.yaml`.
- **New loop phase:** edit `.claude/commands/owl/evolve.md` and give the phase an explicit expected-artifact check (ADR-010).
- **Tune rigor:** `.owl/loop-config.yml` (`rubric.threshold`, `safety_floor`) — but this file is inside the carve-out (human-only).

## What to watch
- **Never** author an edit that weakens the carve-out — that is a security regression by definition (ADR-001).
- Keep `docs/wiki/` (internal) separate from `research-vault/` (external research).
- A phase that produces no artifact = failure; do not proceed past it.

## Source map
`.claude/commands/owl/{evolve,research}.md` · `.claude/commands/agents/*.md` · `.devflow/agents/*.meta.yaml` · `research-vault/SCHEMA.md` · `.owl/loop-config.yml` · `docs/decisions/ADR-001,002,003,005,010` · `docs/architecture/diagrams/self-improvement-loop.md`.
