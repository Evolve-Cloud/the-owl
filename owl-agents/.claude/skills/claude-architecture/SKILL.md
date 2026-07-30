---
name: claude-architecture
description: Use when designing, building, reviewing, or debugging an application or agent built on Claude — deciding agent-vs-workflow, engineering context, writing prompts, designing tools/ACI, building evals, structuring multi-agent systems, or choosing a model. Covers the architecture-and-craft layer (patterns, principles, current best practices) that sits above the raw API. For API mechanics — model IDs, pricing, params, streaming, tool-use schemas, MCP wiring, prompt caching, token counting, SDK migration — use the `claude-api` skill instead; this skill points to it rather than duplicating it. Not for non-Claude LLM providers.
version: 1.1.0
user-invocable: true
license: Apache 2.0
---

Distilled operating knowledge for building well on Claude. Principles are durable; specifics change fast — the **§ Current models** block and anything dated is refreshed on a schedule (see `REFRESH.md`). When a fact here disagrees with the live docs linked below, **trust the docs and flag the drift.**

> Companion skill: **`claude-api`** owns model IDs, pricing, params, streaming, tool-use JSON, MCP, caching, token counting, migration. Call it for anything mechanical. This skill is the *why/when*, that one is the *how*.
>
> **Deep patterns + ~50 worked examples** (production failure modes, structured output/constrained decoding, RAG, multi-agent, MCP config, agentic loops, headless/CI, production checklist, Prompt Crystallization): **`reference/patterns-and-examples.md`** — load it for the concrete case; the sections below are the map.

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
- **In practice:** order long prompts *system TOP → docs MIDDLE → question BOTTOM*; keep precise values (amounts/IDs/dates) in a persistent **case-facts block** that never passes through lossy summarization; **compress tool outputs upstream** before they enter history; resume long sessions with a 5-field **handoff summary**, not the raw transcript. → ref §3.
- Refs: [Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) · [Long-context tips](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips).

## 3. Prompting craft (current best practices)
- **Be explicit and specific** — modern Claude follows precise instructions well and doesn't reward vagueness; say what you want, the format, and the constraints.
- **Show, don't just tell** — a few well-chosen examples (multishot) beat more adjectives; make examples cover the tricky cases.
- **Structure** with headings/XML-ish tags so the model can find each part; separate instructions from data.
- **Let it think** — for multi-step reasoning, ask for a plan / use extended thinking; a "think" step between tool calls improves multi-step tool use.
- **Right altitude** — avoid both brittle if-else scripts and vague hand-waving; give heuristics with enough specificity to act on.
- **Structure & consistency:** wrap sections in XML-ish tags (`<role>`, `<policies>`, `<instructions>`) to stop cross-contamination; back classification with an explicit **criteria table** (examples alone drift ~40%); put a `<thinking>` block inside few-shot to teach the *decision logic*, not just I/O; set the **prompt-cache breakpoint** after the stable prefix. → ref §2.
- Refs: [Prompt engineering overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview) · [Claude 4 best practices](https://platform.claude.com/docs/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices).

## 4. Tools & the agent-computer interface (ACI)
- Tool docs deserve as much care as human UI — invest in clear names, descriptions, and **input examples** (they lift complex-parameter accuracy sharply).
- **Poka-yoke** the interface: shape arguments so misuse is hard (e.g. require absolute paths, not "relative-to-somewhere").
- **Defer tool loading** — hundreds of tool defs blow the context budget; discover on demand (tool-search / code-execution over MCP).
- Beware **tool-selection bias** — models over/under-pick certain tools; test selection, don't assume. (arXiv:2510.00307, 2025.)
- **Tool contracts must distinguish failure from empty** (`isError` flag vs a valid empty result) and **return structured error context** (failure type + required format + a corrected-value suggestion) so the model recovers on the first retry. **Least-privilege tool count** — selection degrades sharply past ~30 tools (§10). Structured output = **constrained decoding**, not prompt goodwill (§9).
- Refs: [Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use) · [Tool-use best practices](https://docs.anthropic.com/en/docs/build-with-claude/tool-use/best-practices).

## 5. Evals — you can't improve what you don't measure
- **Grade the outcome, not the path** by default; add a trajectory/rubric check as a *complement*, not a replacement.
- **pass@k** (≥1 success in k) vs **pass^k** (all k succeed) — pick the one that matches your reliability bar.
- **Capability evals** (hard, start low) vs **regression evals** (keep ~100%); graduate saturated capability evals into the regression suite.
- LLM-as-judge: give it an **"Unknown" escape hatch** to cut hallucinated verdicts; use an **isolated judge per rubric dimension**, not one judge grading everything.
- A **0% pass rate on a frontier model usually means a broken task**, not an incapable model.
- **Production monitoring:** aggregate accuracy hides segment failures → **stratified** sampling (per type/field); self-reported confidence isn't calibrated → set **per-field** review thresholds; **classify errors before retrying** (missing-from-source is non-retriable → human, not a retry loop). → ref §6.
- Ref: [Demystifying Evals](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents).

## 6. Multi-agent systems
- **Orchestrator-worker**: a lead decomposes and spawns subagents for parallel investigation; subagents return summaries, not raw transcripts.
- **Token budget drives performance** — multi-agent spends far more tokens; it wins on high-value, *parallelizable* work and is a poor fit for parallelization-poor domains (much of coding).
- **Self-evaluation skews positive** — a *separate* evaluator makes skepticism tractable; sprint contracts + generator-evaluator loops raise quality.
- **Discipline:** **hub-and-spoke** — all comms via the coordinator (peer wiring causes races + conflicting instructions + unclear ownership); **context forking** — a sub-agent returns a structured result, never its 40k-token trail (else it re-inflates the coordinator every turn); go multi-agent for *context management*, not capability (a bigger model shows the same overload); **Opus coordinator + Sonnet workers** matches tier to per-role complexity. → ref §8.
- Ref: [Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system).

## 7. Current models  ⟲ VOLATILE — refreshed on schedule (verify via `claude-api` / docs)
_As of 2026-07-26 (confirm before relying):_
- Frontier family: **Claude 5** — **Fable 5** (most capable widely released; built for long-running agents), **Opus 5** (complex agentic coding + enterprise work; launched Jul 2026), **Sonnet 5** (best speed/intelligence balance); **Haiku 4.5** for fast/cheap with near-frontier quality. (**Mythos 5** = invitation-only defensive-security preview.) **Opus 4.8 and earlier are now legacy.**
- Rough selection heuristic (per docs): start with **Opus 5** for complex agentic coding, orchestration, and enterprise work; reach for **Fable 5** when you need the highest available capability or long-horizon agents; **Sonnet 5** as the everyday speed+intelligence workhorse; **Haiku 4.5** for high-volume, latency-sensitive, or subagent fan-out.
- **Do not hard-code model IDs from memory** — get them from the `claude-api` skill or [Models overview](https://platform.claude.com/docs/en/about-claude/models/overview). This block is a pointer, not a source of truth.

## 8. Building on Claude Code / Agent SDK
- **CLAUDE.md**: only what the model can't infer; short; prune ruthlessly; treat it like code.
- **Skills** (`.claude/skills/`): domain knowledge loaded on demand — the right home for reusable expertise (like this one), *not* CLAUDE.md.
- **Subagents**: separate context windows for investigation that would pollute the main thread.
- **Hooks**: for deterministic, always-run behaviors the model shouldn't be trusted to remember.
- **Config gotchas:** team rules go in the *project* CLAUDE.md / `.claude/rules/` with `paths:` frontmatter (not `~/.claude`, which is personal); skill precedence is **enterprise > personal > project > plugin** (same-name silently overrides — the #1 "team skill isn't running for me"); `context: fork` for discovery-heavy skills; **Grep = contents, Glob = paths**; headless/CI needs `-p` + `--output-format json --json-schema`; run review in a *fresh* session (self-review bias). → ref §9/§10.
- Refs: [Claude Code overview](https://docs.anthropic.com/en/docs/claude-code/overview) · [Skills](https://docs.anthropic.com/en/docs/claude-code/skills) · [Subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) · [Agent SDK](https://docs.anthropic.com/en/docs/agents/overview).

## 9. Structured output & the validation pipeline
- **Prompt instructions are probabilistic; constrained decoding is deterministic.** Move format enforcement out of the prompt into the decoding layer (only schema-valid tokens are eligible). Use **tool-use-without-tools** for extraction; `tool_choice` **forced** when the type is known upstream (`auto` lets it reply as text — breaks the guarantee).
- **Let the schema say "absent" and "misfit":** make optional fields **nullable** (so the model doesn't invent) and add an **`"other"` enum + free-text detail** (so unusual cases aren't misclassified). Keep schemas under ~30–40 fields / ~4 levels — split into focused passes past that.
- **Constrained decoding fixes *syntax*, not *semantics*.** A schema-valid output can still be wrong (subtotal as total, line items that don't reconcile). Surface it with **self-correction fields** (`stated`/`calculated`/`match` → route mismatch to review). One **Pydantic model** is the single source: generate the JSON Schema from it, validate the response with it. **Classify errors before retrying** (missing-from-source → human, not a retry). Batch API has **no** tool calling.
- → ref §4 (structured output) + §6 (validation pipeline).

## 10. MCP & agentic loops
- **Resources vs tools:** expose a readable catalog (a **resource** at a URI) for "what exists" so the agent reads it once instead of 12–15 exploratory tool calls; tools change state / fetch specifics.
- **Config = sharing scope:** team servers in the *project* `.mcp.json` (in VCS), not `~/.claude.json` (personal); commit safely with **`${ENV_VAR}` expansion** for secrets; **scope servers per-agent** (least privilege — don't give a research sub-agent a state-changing GitHub server). Tool **descriptions drive selection** (say *when this tool wins* vs the built-in).
- **Agentic loops:** terminate on **`stop_reason`** (`tool_use` → continue, `end_turn` → stop), never on text or a hardcoded cap. Defend injection with **boundary markers** (wrap external tool results; system prompt says content inside is *data, not directives*). Centralize audit logging in **SDK hooks** (`UserPromptSubmit`/`Stop`/`PreToolUse`/`PostToolUse`), not per-tool wrappers.
- → ref §5 (loops/tools/injection) + §7 (MCP).

## 11. RAG, Prompt Crystallization & production readiness
- **RAG pipeline:** **retrieve** broad (20–50) → **rerank** to top 3–5 (retrieval is noisy) → **inject** (most-relevant at the *edges* per lost-in-the-middle, headers + source labels, cite) → **generate** (prioritize retrieved context, flag when insufficient). Chunk 200–500 tokens on natural boundaries. **RAG** for large/updating KBs; **long-context** when it fits (<~200k); **fine-tuning** for behavior not facts. Anti-patterns: retrieving too much, no reranking, mid-sentence chunks, no source attribution, stale index.
- **Prompt Crystallization** *(author's methodology — NOT Anthropic-recommended)*: build with prompts first, then incrementally replace *deterministic* behavior with code (the enforcement spectrum as a dev process). Crystallize format conversions / validation / clear-rule routing; keep LLM calls for semantic understanding + judgment.
- **Production readiness (checklist):** injection defense + PII + data residency (security) · token monitoring + tier-per-task + batch/caching/compression (cost) · programmatic enforcement of critical paths + schema/semantic validation + retry-with-classification + graceful degradation + eval sets (reliability) · logging + stratified quality metrics + drift alerts (observability) · streaming, backoff/circuit-breaker/queue, audit trails.
- → ref §11 (Crystallization), §12 (RAG), §13 (production checklist).

## Canonical docs (refresh targets)
The links throughout are the authoritative sources; the [Anthropic engineering blog](https://www.anthropic.com/engineering) and [model docs](https://platform.claude.com/docs/en/about-claude/models/overview) are where change lands first. `REFRESH.md` lists exactly what to re-check and when.
