---
title: "Anthropic — Introducing Advanced Tool Use on the Claude Developer Platform"
type: source
tags: [tool-use, mcp, context-engineering, agents, token-efficiency]
sources: 1
updated: 2026-07-26
---
**Source:** [Introducing advanced tool use on the Claude Developer Platform](https://www.anthropic.com/engineering/advanced-tool-use) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Bin Wu; contributors Adam Jones, Artur Renault, Henry Tay, Jake Noble, Noah Picard, Sam Jiang (Anthropic)  ·  **Published:** 2025-11-24  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Three beta features address fundamental limitations in traditional tool use: Tool Search (on-demand discovery), Programmatic Tool Calling (code-based orchestration), and Tool Use Examples (parameter demonstrations). Together they tackle the context-waste problem — tool definitions alone can consume 55K-134K tokens in multi-server setups — and improve accuracy on complex parameter handling.

## Key points
- Tool definitions consume 55K-134K tokens in 50+ tool setups before an agent reads a single request.
- Tool Search Tool: on-demand discovery via regex/BM25; improved Opus 4 performance from 49% to 74%; only ~500 tokens loaded upfront vs. 72K for 50+ MCP tools.
- Programmatic Tool Calling: orchestrates multiple tools through code execution; reduces token consumption by 37%; eliminates intermediate results from context; enables parallel tool execution.
- Tool Use Examples: concrete input demonstrations beyond JSON schemas; improved accuracy from 72% to 90% on complex parameter handling.
- Integrates with MCP servers: entire servers can be deferred while high-frequency tools remain immediately available.

## Informs (ideas / patterns)
- [[tool-use]] — tool search as a discovery pattern; programmatic calling; tool use examples; defer loading.
- [[context-engineering]] — managing hundreds of tool definitions as a context-budget problem.
- [[mcp]] — advanced MCP integration; server-level deferral.

## Notable quotes
> "Agents should discover and load tools on-demand, keeping only what's relevant for the current task."
> "Tool Use Examples improved accuracy from 72% to 90% on complex parameter handling."

## Gaps / open questions
- How does tool search perform on ambiguous queries where multiple tools could apply?
- What's the latency cost of on-demand tool discovery at scale?

## Related
- [[tool-use]] · [[writing-tools-for-agents]] · [[code-execution-mcp]] · [[mcp]] · [[context-engineering]]
