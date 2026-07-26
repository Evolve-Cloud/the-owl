---
name: claude-architecture
description: Use when designing, building, reviewing, or debugging an application or agent built on Claude — deciding agent-vs-workflow, engineering context, writing prompts, designing tools/ACI, building evals, structuring multi-agent systems, or choosing a model. Covers the architecture-and-craft layer (patterns, principles, current best practices) that sits above the raw API. For API mechanics — model IDs, pricing, params, streaming, tool-use schemas, MCP wiring, prompt caching, token counting, SDK migration — use the `claude-api` skill instead; this skill points to it rather than duplicating it. Not for non-Claude LLM providers.
version: 1.0.0
user-invocable: true
license: Apache 2.0
---

Distilled operating knowledge for building well on Claude. Principles are durable; specifics change fast — the **§ Current models** block and anything dated is refreshed on a schedule (see `REFRESH.md`). When a fact here disagrees with the live docs linked below, **trust the docs and flag the drift.**

> Companion skill: **`claude-api`** owns model IDs, pricing, params, streaming, tool-use JSON, MCP, caching, token counting, migration. Call it for anything mechanical. This skill is the *why/when*, that one is the *how*.

## 1. Agent vs. workflow — decide this first
- **Start simple.** Many tasks are one well-prompted call + retrieval. Add structure only when it earns its keep; frameworks add abstraction that hides the logic.
- **Workflow** = predefined code paths orchestrating LLM calls (predictable, cheaper, testable). **Agent** = the model directs its own steps/tools (flexible, but compounding errors, needs guardrails + sandboxed testing).
- Five workflow patterns before you reach for an agent: **prompt-chaining** (sequential), **routing** (classify → specialized handler), **parallelization** (independent subtasks / multiple attempts), **orchestrator-workers** (dynamic decomposition), **evaluator-optimizer** (generate → critique → refine).
- Ref: [Building Effective Agents](https://www.anthropic.com/research/building-effective-agents).

## 2. Context engineering — the binding constraint
- Context is a **finite, depleting resource**, not free storage. As tokens grow, recall degrades ("context rot"); attention is n² so every token taxes the rest.
- **Lost in the middle**: models recall the start and end of a long context far better than the middle — put the most important material at the edges. (Liu et al. 2023, arXiv:2307.03172.)
- There is an empirical **ceiling on how many instructions** a model reliably follows at once — a long agent prompt silently drops rules past that point. Keep agent prompts lean; prune conventions that no longer pay for themselves. (arXiv:2507.11538, 2025.)
- **Just-in-time retrieval**: hold lightweight identifiers (paths, queries, URLs), load the payload at runtime — don't pre-stuff.
- **Progressive disclosure**: layer knowledge so only the needed layer loads (this skill's own frontmatter→body→linked-files is the pattern; so is `SKILL.md`).
- **Long-horizon**: compaction (summarize near the limit), durable note-taking (state outside the transcript), and sub-agents (fresh context per specialist, summary back to the hub).
- Refs: [Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) · [Long-context tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips).

## 3. Prompting craft (current best practices)
- **Be explicit and specific** — modern Claude follows precise instructions well and doesn't reward vagueness; say what you want, the format, and the constraints.
- **Show, don't just tell** — a few well-chosen examples (multishot) beat more adjectives; make examples cover the tricky cases.
- **Structure** with headings/XML-ish tags so the model can find each part; separate instructions from data.
- **Let it think** — for multi-step reasoning, ask for a plan / use extended thinking; a "think" step between tool calls improves multi-step tool use.
- **Right altitude** — avoid both brittle if-else scripts and vague hand-waving; give heuristics with enough specificity to act on.
- Refs: [Prompt engineering overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview) · [Claude 4 best practices](https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices).

## 4. Tools & the agent-computer interface (ACI)
- Tool docs deserve as much care as human UI — invest in clear names, descriptions, and **input examples** (they lift complex-parameter accuracy sharply).
- **Poka-yoke** the interface: shape arguments so misuse is hard (e.g. require absolute paths, not "relative-to-somewhere").
- **Defer tool loading** — hundreds of tool defs blow the context budget; discover on demand (tool-search / code-execution over MCP).
- Beware **tool-selection bias** — models over/under-pick certain tools; test selection, don't assume. (arXiv:2510.00307, 2025.)
- Refs: [Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use) · [Tool-use best practices](https://docs.anthropic.com/en/docs/build-with-claude/tool-use/best-practices).

## 5. Evals — you can't improve what you don't measure
- **Grade the outcome, not the path** by default; add a trajectory/rubric check as a *complement*, not a replacement.
- **pass@k** (≥1 success in k) vs **pass^k** (all k succeed) — pick the one that matches your reliability bar.
- **Capability evals** (hard, start low) vs **regression evals** (keep ~100%); graduate saturated capability evals into the regression suite.
- LLM-as-judge: give it an **"Unknown" escape hatch** to cut hallucinated verdicts; use an **isolated judge per rubric dimension**, not one judge grading everything.
- A **0% pass rate on a frontier model usually means a broken task**, not an incapable model.
- Ref: [Demystifying Evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents).

## 6. Multi-agent systems
- **Orchestrator-worker**: a lead decomposes and spawns subagents for parallel investigation; subagents return summaries, not raw transcripts.
- **Token budget drives performance** — multi-agent spends far more tokens; it wins on high-value, *parallelizable* work and is a poor fit for parallelization-poor domains (much of coding).
- **Self-evaluation skews positive** — a *separate* evaluator makes skepticism tractable; sprint contracts + generator-evaluator loops raise quality.
- Ref: [Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system).

## 7. Current models  ⟲ VOLATILE — refreshed on schedule (verify via `claude-api` / docs)
_As of 2026-07-26 (confirm before relying):_
- Frontier family: **Claude 5** (Fable 5, Sonnet 5) and **Opus 4.8**; **Haiku 4.5** for fast/cheap.
- Rough selection heuristic: **Opus/Fable** for the hardest reasoning/analysis and agent orchestration; **Sonnet** for the everyday build/coding workhorse; **Haiku** for high-volume, latency-sensitive, or subagent fan-out.
- **Do not hard-code model IDs from memory** — get them from the `claude-api` skill or [Models overview](https://platform.claude.com/docs/en/about-claude/models/overview). This block is a pointer, not a source of truth.

## 8. Building on Claude Code / Agent SDK
- **CLAUDE.md**: only what the model can't infer; short; prune ruthlessly; treat it like code.
- **Skills** (`.claude/skills/`): domain knowledge loaded on demand — the right home for reusable expertise (like this one), *not* CLAUDE.md.
- **Subagents**: separate context windows for investigation that would pollute the main thread.
- **Hooks**: for deterministic, always-run behaviors the model shouldn't be trusted to remember.
- Refs: [Claude Code overview](https://docs.anthropic.com/en/docs/claude-code/overview) · [Skills](https://docs.anthropic.com/en/docs/claude-code/skills) · [Subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) · [Agent SDK](https://docs.anthropic.com/en/docs/agents/overview).

## Canonical docs (refresh targets)
The links throughout are the authoritative sources; the [Anthropic engineering blog](https://www.anthropic.com/engineering) and [model docs](https://platform.claude.com/docs/en/about-claude/models/overview) are where change lands first. `REFRESH.md` lists exactly what to re-check and when.
