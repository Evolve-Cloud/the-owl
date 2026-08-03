---
title: Context engineering
type: pattern
tags: [context, memory, retrieval, long-horizon]
sources: 12
updated: 2026-08-03
---

## Definition
Context engineering is the practice of **curating the smallest high-signal token set** an agent needs at each step of inference — system prompt, tools, retrieved data, and message history — instead of pre-loading everything. It treats the context window as a **finite, depleting resource** rather than free storage.

## Key ideas
- **Context rot / attention budget.** As token count grows, recall degrades; the transformer's n² pairwise attention means every token spent lowers the budget for the rest. More context is not monotonically better — there are diminishing (then negative) returns.
- **Just-in-time retrieval.** Agents hold **lightweight identifiers** (file paths, queries, URLs) and load the underlying data **at runtime**, rather than stuffing it in up front. Pointers over payloads.
- **Progressive disclosure.** Structure knowledge in layers so only the needed layer loads: a cheap relevance gate (name + description / frontmatter) → the full body → linked files → executable code. This is how Agent Skills (`SKILL.md`) and on-demand tool discovery keep the upfront cost near-zero.
- **Long-horizon techniques (complementary, not exclusive):** *compaction* (summarize near the window limit and reinitiate), *structured note-taking* (durable progress files outside the transcript), and *sub-agent architectures* (fresh context per specialist, summary returned to the hub).
- **Durable state separated from the transcript.** The session/event log lives outside the model's context; the agent re-derives state from durable artifacts (files, git, progress lists) instead of relying on chat history it may lose. This is a *two-tier* split — LangGraph makes it explicit: **resumable checkpoint state** (a snapshot you can replay / "time-travel" to) is a distinct tier from the **durable long-term store** (memory that outlives any single run). The transcript is neither; it is the volatile working surface.
- **In-transcript reasoning is a separate, bounded tool.** A "think" scratchpad lets the agent pause mid-loop to reassess a tool result before the next call — it *complements* structured note-taking but lives **inside** the transcript, not as durable external state. Keeping the two distinct is the point: the scratchpad is cheap, ephemeral reasoning; the note file is durable state. On τ-bench airline the think tool gave a **54% relative improvement** with tuned prompting, so the in-context tier earns its (bounded) token cost.
- **Retrieval quality.** When retrieval is used, contextualizing chunks before embedding (Contextual Retrieval) cuts retrieval-failure rates sharply; for small corpora (<~200K tokens), just put the whole corpus in a cached prompt.
- **Assumptions go stale.** "Every component in a harness encodes an assumption about what the model can't do." As models improve (e.g. reduced context-anxiety from Sonnet 4.5 → Opus 4.5), context-management scaffolding can become unnecessary — worth periodically re-testing (see the deferred `convention-staleness-review` in [[ledger]]).

## Evidence / sources
- [[effective-context-engineering]] — the anchor: context rot, attention budget, altitude, just-in-time retrieval, compaction/note-taking/sub-agents.
- [[anthropic-agent-skills]] — progressive disclosure as the loading mechanism; "context that can be bundled is effectively unbounded" *because* it loads on demand.
- [[advanced-tool-use]] · [[code-execution-mcp]] — the same principle for **tools**: defer tool definitions, discover on demand (72K → ~500 tokens; 150K → 2K in the cited examples).
- [[anthropic-contextual-retrieval]] — retrieval-side context quality (49–67% fewer retrieval failures).
- [[effective-harnesses-long-running]] · [[harness-design-long-running-apps]] — durable progress files, git-as-state, session-startup protocols, compaction-vs-reset tradeoffs per model.
- [[scaling-managed-agents]] — session as an external durable event log (brain/hands decoupling); context-anxiety as a stale assumption.
- [[claude-code-best-practices]] — "context fills fast, performance degrades as it fills"; `/clear` `/compact`, subagent isolation, short CLAUDE.md.
- [[multi-agent-research-system]] — token budget as the dominant performance variable; subagent filesystem output.
- [[langgraph-persistence]] — the durable-state tier made concrete: resumable checkpoint state vs. a durable long-term store. **Design documentation, not an empirical result** (it describes a framework's own architecture) — cite it for the *shape* of the split, not a measured effect.
- [[claude-think-tool]] — the in-transcript reasoning tier: a no-op scratchpad for mid-loop reassessment (54% relative gain on τ-bench airline). Sharpens the boundary — bounded reasoning *inside* the window is a different lever from durable state *outside* it.

## How it maps to the-owl
the-owl is **markdown-only, no-runtime, context-minimal** — context engineering is a core value, not a new import. The pattern is **already partly adopted**:
- **This page anchors the N-1 constraint.** N-1 (each agent receives its parent's context *minus one hop* — "só o necessário + paths, nunca o histórico inteiro") is not a stylistic rule; it is the-owl's enforcement mechanism for **just-in-time-by-pointer**. The orchestrator passes identifiers (file paths, the ADR slug, the target file), and the specialist loads the payload at runtime. Pointers over payloads *is* what N-1 operationalizes at every handoff boundary.
- **`handoff-contract` (accepted, ADR-004)** mandates those context-minimal handoffs — so the `just-in-time-context-loading` candidate **dedups** to it.
- **Durable state lives outside the transcript by construction.** the-owl's memory is the research-vault + git + ADRs, not chat history — the same two-tier split [[langgraph-persistence]] formalizes (checkpoint vs. long-term store). A fresh sub-agent re-derives state from these artifacts, never from a transcript it cannot see. This is *why* the hub-and-spoke topology is context-safe.
- Progressive disclosure is **already latent** in `.claude/skills` / slash-command agents (bodies load when invoked).

**Open fronts (deferred — pressure-test in a focused cycle):** `artifact-oriented-context` · `context-isolation-and-summary` · `durable-state-separated-from-transcript` · `agent-frontmatter-fields` · `just-in-time-context-loading` · `convention-staleness-review` (all in [[ledger]]). None cleared the rubric this cycle (behavioral-claim ideas, hypothesis-level impact per ADR-015), but the 2026-07-26 read-in-full primaries give them **much stronger evidence** than the cycle-1/2 brief stubs did — a future cycle can revisit whichever concretizes into an atomic, carve-out-safe markdown edit.

## Related
- [[role-decomposition]] — the other pattern page; sub-agent context isolation sits at the intersection.
- [[overview]] · [[ledger]] · [[handoff-contract]]
