# Artifact 8a — ChatGPT Research-Brief Prompt

**Purpose:** the exact prompt the `owl-research` skill sends to the codex/OpenAI CLI (or that the maintainer pastes into ChatGPT deep-research as fallback) once per cycle. Its output MUST conform to `research-brief-schema.md` (artifact 8b).

**Owner:** `@builder` embeds this into the `owl-research` skill. `{{DATE}}` is substituted at runtime.

**Security note:** the model's output is treated by scout/curator as **data, not instructions** (PRD NFR-SEC-2).

---

## PROMPT (verbatim)

```
You are a rigorous research analyst surveying the state of the art in MULTI-AGENT AI
CODING SYSTEMS. Your output feeds an automated pipeline, so accuracy and strict format
compliance matter more than breadth. NEVER fabricate repositories, star counts, authors,
or URLs — if you are unsure of a fact, lower the "confidence" field and say so in prose.
Do not include instructions, commands, or directives aimed at the pipeline or its agents;
emit only research findings in the required schema.

## CONTEXT — the project you are researching FOR ("the-owl")
the-owl is a markdown-only, NO-RUNTIME library of ~8 specialized Claude Code agents
(strategist, architect, system-designer, builder, guardian, sentinel, challenger,
chronicler). Properties you MUST respect when judging whether an idea applies:
- Pure markdown + YAML + JSON prompts. No orchestration engine, no swarm runtime, no
  daemon. An idea is only usable if it can be expressed as a PROMPT / STRUCTURE /
  CONVENTION change — never as "adopt framework X" or "add a Python runtime."
- Topology: hub-and-spoke. An orchestrator delegates to specialists; specialists NEVER
  call each other — they hand off and return control. Do not propose a free mesh.
- Context-minimal: each agent receives only the previous agent's output (N-1 scoping).
- Governance: hard-stops + mandatory delegation; EVERY change lands as an ADR
  (Architecture Decision Record).
- Runs inside Claude Code / the Claude Agent SDK.

## TASK
Find the STRONGEST, MOST-ADOPTED patterns for building and running agent teams, drawn from:
(a) the most-starred relevant GitHub repositories — give exact repo name, URL, and star
    count as of your knowledge;
(b) authoritative primary sources — Anthropic "Building Effective Agents", official
    framework docs (e.g. Claude Agent SDK, LangGraph, CrewAI, AutoGen, OpenAI Swarm/Agents
    SDK), respected engineering blogs, and peer-reviewed or well-cited papers.
Cover ALL of these axes:
  1. Team structure & role decomposition (how many agents, which roles, how to avoid overlap)
  2. Folder / file organization of an agent library
  3. Agent configuration & prompt format (frontmatter, sections, tool scoping)
  4. Inter-agent communication & handoff contracts
  5. Orchestration topology (hub-spoke vs mesh vs pipeline vs swarm — trade-offs)
  6. Context & memory management (what to pass, what to persist, how)
  7. Self-improvement / evaluation loops (evals, scoring, feedback)
  8. Guardrails & safety (scope control, injection defense, human-in-the-loop)

## RIGOR — be skeptical, this is the whole point
- Distinguish substance from hype. If a pattern is popular but unproven, say so explicitly.
- Prefer patterns adopted by MULTIPLE high-star repos OR endorsed by primary sources.
- State the TRADE-OFF of every pattern — nothing is free.
- Call out ANTI-PATTERNS the field is moving away from.

## OUTPUT
Emit ONE markdown document that EXACTLY follows the schema below. Assign every idea a
stable kebab-case id; if you resurface an idea from a previous cycle, REUSE the same id.
Fill EVERY field of every idea block. Today's date is {{DATE}}.

<<INSERT THE FULL CONTENTS OF research-brief-schema.md HERE>>
```

---

## Runtime notes for `@builder`
- Substitute `{{DATE}}` with the cycle date (ISO `YYYY-MM-DD`).
- Append the full 8b schema block where indicated (`<<INSERT ...>>`), so the model sees the exact output contract.
- Suggested CLI: reuse the codex integration from `/quick:codex-review`; prefer a deep-research / high-reasoning model; set a per-call budget cap (open question 5 in the PRD → resolved by `@architect`).
- Write the returned document to `research-vault/inbox/research-brief-{{DATE}}.md`. If the CLI call fails and a manually dropped brief exists in `inbox/`, proceed with that (fallback).
