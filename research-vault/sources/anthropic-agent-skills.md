---
title: "Anthropic — Equipping Agents for the Real World with Agent Skills"
type: source
tags: [agent-skills, context-engineering, mcp, tool-use, specialization]
sources: 1
updated: 2026-07-26
---
**Source:** [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Barry Zhang, Keith Lazuka, Mahesh Murag (Anthropic)  ·  **Published:** 2025-10-16  ·  **Ingested:** 2026-07-26 (imported from carinhAI; note — renamed from carinhAI's `agent-skills.md` to avoid a filename collision with the [[agent-skills]] pattern page in this vault)

## Summary
Agent Skills are organized folders containing a `SKILL.md` file plus supporting resources that package domain expertise, procedural knowledge, and executable code into discoverable, composable units. The design principle is progressive disclosure: YAML metadata loads at startup to determine relevance, then full content loads only when needed — optimizing token usage while making skills effectively unbounded in total capacity.

## Key points
- Agent Skills = organized folders with `SKILL.md` + supporting resources; enables dynamic loading of specialized expertise.
- Progressive disclosure: YAML frontmatter (name + description) loads at startup → full SKILL.md → linked files → code — each layer only as needed.
- Skills can bundle executable code scripts for deterministic, computationally efficient operations separate from token-heavy language generation.
- "The amount of context that can be bundled into a skill is effectively unbounded."
- Supported across Claude.ai, Claude Code, Claude Agent SDK, Claude Developer Platform.
- Security: only install from trusted sources; audit all code dependencies and external network instructions.

## Informs (ideas / patterns)
- [[agent-skills]] — foundational description of the Skills pattern; SKILL.md format; progressive disclosure implementation.
- [[context-engineering]] — progressive disclosure as context optimization; YAML metadata as lightweight relevance gate.
- [[tool-use]] — skills as a higher abstraction over raw tool calls; executable code bundles.

## Notable quotes
> "Skills extend Claude's capabilities by packaging your expertise into composable resources for Claude."
> "Building a skill for an agent is like putting together an onboarding guide for a new hire."

## Gaps / open questions
- How do skills compose with each other when multiple skills are relevant to the same task?
- What's the governance model for skill versioning and deprecation in team settings?

## Related
- [[agent-skills]] · [[tool-use]] · [[context-engineering]] · [[claude-code-best-practices]] · [[mcp]]
