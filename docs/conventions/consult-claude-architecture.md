# Convention: Consult `claude-architecture` before building on Claude

**Status:** Adopted 2026-07-26 (owner-directed) · **Scope:** any agent-author (human or agent) in this repo and the shared fleet

## Rule
Before **creating or sharpening** anything built on top of Claude — a new agent, a skill, an MCP server, or an AI feature — **invoke the `claude-architecture` skill first** and let its guidance shape the work. Cite what it changed.

## Why
Dogfood, 2026-07-26: `mcp-builder` was first drafted from memory and missed real things the skill supplied — the reliability/evals angle (§5), *least-privilege as context hygiene* (§2/§4), and a current model-selection pointer (§7). The skill is **curated + monthly-refreshed**, so it beats training-time knowledge (which was already stale on models — thought Opus 4.8 was frontier; the skill had Opus 5 / Fable 5). Building on Claude *without* consulting it ships avoidable gaps.

## How to apply
1. At the **start** of a Claude-native build task, invoke `claude-architecture` (Skill tool).
2. Cross-check the draft against its §1–§8 (agent-vs-workflow · context engineering · prompting · tool/ACI · evals · multi-agent · current models · Claude Code/SDK).
3. It's the **why/when**; `claude-api` is the **how** (model IDs, params, tool JSON). Don't hard-code model IDs from memory.
4. Note in your handoff what the skill changed (as `mcp-builder` does).

## Boundaries
- General (non-Claude) software work does **not** trigger this — the skill's domain is *building on Claude*.
- This convention constrains the **author's process**, not an agent's runtime; it does not touch the NFR-SEC-1 carve-out.

## Related
- Skill: `.claude/skills/claude-architecture/` (source; shared to other projects via symlink).
- ADR-017 (convention staleness) — the same §2 "instruction ceiling" that sharpens new agents also flags that the **oldest agents are over it** (builder ~1700 lines, architect/system-designer ~1400) → a lean-up candidate.
- Can be formalized as an ADR on request (would be the next free number).
