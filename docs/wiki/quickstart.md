# the-owl — Quickstart (for agents)

Navigable index of the-owl, maintained by @chronicler. **Read this before searching the code.** Every claim here is grounded in a real file; follow the links for detail. (Rewritten 2026-08-13 — the previous version carried 4 expired structural claims; treat stale counts here as bugs and fix via `/agents:chronicler /wiki update`.)

## What this repository is
- A library of **13 specialized Claude Code agents** (DevFlow re-scaffold). Every persona exists as a **PAIR** (ADR-028): a native subagent in `.claude/agents/<x>.md` (auto-delegation; harness-enforced frontmatter like `tools:`) **and** a slash-command persona in `.claude/commands/agents/<x>.md` (deterministic pipeline). Edits to a persona hit BOTH copies identically (narrow exception: ADR-034).
- It **improves its own agents autonomously** via `/owl:evolve` (weekly schedule, Mondays 07:13): research the delta on the cycle's axis → score against the rubric AND against our own code (L1.5) → ADR-backed atomic edit → triple gate → shadow PR.
- **Since ADR-040 the loop's default target is CAPABILITY, not governance:** research axes rotate over domain knowledge (`platform-engineering` · `data-engineering` · `mcp-and-claude-harness` · `secure-sdlc`), every accept is classed `capability | governance`, and capability accepts must move `research-vault/capabilities/agent-capability-matrix.md`.
- **Structural truth lives in `docs/conventions/structural-properties.md`** — NOT in prose like "markdown-only" or "no runtime" (those claims expired; the repo has a spawner, a scheduler, git hooks and scripts). What disqualifies an idea is the BOUNDARY: the loop may not touch the runtime that exists (carve-out + sequential-by-design, ADR-010).
- **Topology is scoped (ADR-038):** inside `/owl:evolve` it is hub-and-spoke (P7a, orchestrator reads personas inline, specialists return control). In interactive DevFlow, 9 of 13 pairs deliberately instruct Skill-tool peer invocation (P7b — by design, not drift).
- **Safe self-modification (NFR-SEC-1, ADR-001):** the loop may improve any non-gate agent and conventions, but NEVER autonomously edits sentinel/guardian/challenger, the rubric safety floor, `.owl/loop-config.yml`, `.claude/settings.json`, the schedule, `~/.ssh`, or secrets.

## Start here
- [Architecture](architecture/overview.md) — the loop, the 13 agent pairs, the safety model.
- [Workflows](workflows/self-improvement-cycle.md) — one cycle end-to-end; how to run and arm it.
- [Operations](operations/config-and-schedule.md) — config, the weekly schedule, landing modes, follow-ups.
- [Architecture diagrams](../architecture/diagrams/self-improvement-loop.md) — Mermaid (pipeline, topology, carve-out, git flow).

## Key source files
- `.claude/commands/owl/evolve.md` — the L0→L5 loop orchestrator (inline execution + per-phase artifact verification, ADR-010/016).
- `.claude/commands/owl/research.md` — L0: retrieve-then-search-delta codex brief (ADR-022/030); axis default = capability axes (ADR-040).
- `.claude/agents/*.md` + `.claude/commands/agents/*.md` — the 13 persona pairs: strategist · architect · system-designer · builder · guardian · sentinel · challenger · chronicler · database-specialist · mcp-builder · team · scout · curator.
- `research-vault/` — external-research memory (`SCHEMA.md`, `ledger.md` = dedup truth, `capabilities/agent-capability-matrix.md` = the capability target, `inbox/ sources/ patterns/ ideas/`).
- `.owl/loop-config.yml` — the brake pedal (carve-out, human-only).
- `eval/` + `scripts/owl-fitness.py` — the fitness harness (ADR-014/015): measured Δ or it's a hypothesis.
- `scripts/owl-daily.sh` + `scripts/com.evolvelabs.owl.daily.plist` — the WEEKLY schedule (filename "daily" is legacy).

## Decision records (authoritative — `docs/decisions/`, ADR-001..040)
Load-bearing ones: ADR-001 (loop + carve-out) · 003 (rubric) · 004/020/029 (handoff contract, measured Δ +11.0) · 005 (L1.5 grounding) · 010 (inline exec + verification) · 013 (claim verification) · 014/015 (fitness; impact is a hypothesis until measured) · 017/033/039 (staleness · expired blockers · mechanism liveness) · 022/030 (retrieve-delta research) · 028/034 (the persona pair) · 038 (scoped properties) · **040 (capability over governance — current direction)**.

## Notes for agents
- **Two knowledge stores, separate on purpose:** `docs/wiki/` (internal, source-grounded) vs `research-vault/` (external research). Never mix them.
- **Every autonomous change is 1 idea → 1 ADR → 1 atomic commit**, landed as a shadow PR.
- Counts in this wiki (13 agents, 40 ADRs) go stale — when structure changes, update via `/agents:chronicler /wiki update`. A wiki claim that contradicts `structural-properties.md` loses.
