---
title: "Anthropic — Code Execution with MCP: Building More Efficient Agents"
type: source
tags: [mcp, code-execution, tool-use, context-engineering, token-efficiency, agents]
sources: 1
updated: 2026-07-26
---
**Source:** [Code Execution with MCP: Building More Efficient Agents](https://www.anthropic.com/engineering/code-execution-with-mcp) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Adam Jones, Conor Kelly; contributors Jeremy Fox, Jerome Swannack, Stuart Ritchie, Molly Vorwerck, Matt Samuels, Maggie Vo (Anthropic)  ·  **Published:** 2025-11-04  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Presenting MCP servers as code APIs rather than direct tool calls enables agents to load tools on-demand and process data locally — reducing token consumption by up to 98.7% in some cases. The article reframes agent tool design using established software-engineering patterns: composition, state management, and progressive disclosure applied to LLM-agent tool interaction.

## Key points
- Two root causes of context overload: upfront tool-definition loading and redundant data flow (intermediate results traverse context multiple times).
- Filesystem-based tool discovery: organizing MCP tools as a directory structure reduced token usage from 150,000 to 2,000 tokens (98.7%) in the illustrated example.
- Local data filtering: agents process/filter/transform large datasets within the execution environment, returning only summaries — large documents never enter context.
- Control-flow efficiency: loops and conditionals execute locally, reducing latency without alternating model-tool cycles.
- Privacy protection: PII flows between external systems without entering model context.
- State persistence: code execution with filesystem access allows saving progress and building reusable function libraries ("skills development").

## Informs (ideas / patterns)
- [[mcp]] — code-as-API pattern; filesystem-organized tool discovery; skills as reusable function libraries.
- [[tool-use]] — progressive disclosure for tools; local data-processing patterns.
- [[context-engineering]] — 98.7% token reduction via on-demand tool loading.
- [[sandboxing]] — execution-environment requirements for code-mode agents.

## Notable quotes
> "Models are great at navigating filesystems. Presenting tools as code on a filesystem allows models to read tool definitions on-demand, rather than reading them all up-front."
> "Over time, this allows your agent to build a toolbox of higher-level capabilities, evolving the scaffolding that it needs to work most effectively."

## Gaps / open questions
- How do you ensure skills developed by agents remain safe when reused across different contexts?
- What's the right granularity for organizing MCP tools in a filesystem hierarchy?

## Related
- [[mcp]] · [[tool-use]] · [[advanced-tool-use]] · [[sandboxing]] · [[agent-skills]]
