---
title: "Anthropic — Building Effective Agents"
type: source
tags: [agents, agent-architectures, workflows, tool-use, simplicity, mcp]
sources: 1
updated: 2026-07-26
---
**Source:** [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Erik Schluntz and Barry Zhang (Anthropic)  ·  **Published:** 2024-12-19  ·  **Ingested:** 2026-07-24 (enriched 2026-07-26 from a personal-vault import, same source re-read in full)

## Summary
Anthropic's primary guidance on building agents: prefer the simplest sufficient pattern, distinguish predictable workflows from open-ended agents, and compose narrow specialists over monolithic ones. Establishes the taxonomy of agentic systems (workflows vs. agents), five core workflow patterns, and the principle that complexity should only be added when it demonstrably improves outcomes. Tool documentation deserves the same investment as human-computer interface design.

## Key points
- Anchors narrow-single-owner-roles, typed handoffs, hub control, evaluator-optimizer, and human-approval-at-side-effects — cited by nearly every idea in both briefs.
- Workflows: predefined code paths for orchestration; Agents: dynamically direct their own processes and tool usage.
- Start simple: many applications succeed with optimized single LLM calls + retrieval; frameworks add abstraction that obscures logic.
- Five core workflow patterns: (1) prompt chaining (sequential), (2) routing (classify → specialized handlers), (3) parallelization (independent subtasks or multiple attempts), (4) orchestrator-workers (dynamic breakdown), (5) evaluator-optimizer (iterative refinement).
- Agents: autonomous with potential for compounding errors; require extensive sandboxed testing and guardrails.
- Tool documentation deserves investment equal to HCI: "agent-computer interface (ACI)"; SWE-bench implementation required more tool optimization than overall prompt work. Poka-yoke for tools: restructure arguments to make misuse more difficult.
- Three core principles: maintain simplicity, prioritize transparency in planning steps, carefully craft ACI.

## Informs (ideas / patterns)
- [[role-ownership]]
- [[handoff-contract]]
- [[role-decomposition]]
- [[agent-architectures]] — definitive taxonomy (workflows vs. agents); five workflow patterns; augmented LLM as foundation; compounding errors in agents.
- [[tool-use]] — ACI (agent-computer interface); poka-yoke pattern; tool documentation investment.
- [[mcp]] — introduced as a framework for integrating third-party tools.

## Notable quotes
> "The most successful implementations weren't using complex frameworks or specialized libraries."
> "Think about how much effort goes into human-computer interfaces (HCI), and plan to invest just as much effort in creating good agent-computer interfaces (ACI)."
> "Success in the LLM space isn't about building the most sophisticated system. It's about building the right system for your needs."

## Gaps / open questions
- Vendor guidance/opinion, not an independent benchmark.
- When exactly should you move from a workflow to a true agent?
- How do you detect compounding errors early in agentic chains before they cascade?

## Related
[[research-brief-2026-07-24]] · [[research-brief-2026-07-23]] · [[tool-use]] · [[mcp]] · [[agent-architectures]] · [[writing-tools-for-agents]] · [[swe-bench-sonnet]] · [[multi-agent-research-system]]
