---
title: "Anthropic — Beyond Permission Prompts: Making Claude Code More Secure and Autonomous"
type: source
tags: [sandboxing, security, claude-code, prompt-injection, permissions, autonomy]
sources: 1
updated: 2026-07-26
---
**Source:** [Beyond permission prompts: making Claude Code more secure and autonomous](https://www.anthropic.com/engineering/claude-code-sandboxing) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** David Dworken, Oliver Weller-Davies; contributors Meaghan Choi, Catherine Wu, Molly Vorwerck, Alex Isken, Kier Bradwell, Kevin Garcia (Anthropic)  ·  **Published:** 2025-10-20  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
OS-level sandboxing reduces Claude Code permission prompts by 84% while simultaneously strengthening security against prompt injection. Two complementary isolation layers — filesystem isolation and network isolation — are implemented via Linux bubblewrap and macOS seatbelt, enforced at the OS level for all spawned processes. Neither layer alone is sufficient.

## Key points
- Permission fatigue problem: constant approval requests reduce vigilance; users stop meaningfully reviewing.
- Dual-boundary sandboxing: filesystem isolation (designated directories only) + network isolation (approved servers only).
- OS-level enforcement via Linux bubblewrap and macOS seatbelt — covers all spawned child processes, not just Claude's direct actions.
- 84% reduction in permission prompts; "even a successful prompt injection is fully isolated."
- Credential handling: Claude Code on the web uses a custom proxy service; git credentials validated before attachment at clone time.
- Both layers are essential: either alone leaves a different attack vector open.

## Informs (ideas / patterns)
- [[sandboxing]] — OS-level dual-boundary isolation; filesystem + network as complementary layers; bubblewrap/seatbelt implementation; credential proxy pattern.
- [[agent-architectures]] — security patterns for production agents; credential structural isolation.
- [[claude-code]] — sandboxed bash tool; Claude Code on the web.

## Notable quotes
> "Sandboxing safely reduces permission prompts by 84%."
> "Even a successful prompt injection is fully isolated, and cannot impact overall user security."

## Gaps / open questions
- How does sandboxing interact with MCP servers that need broad network access?
- What's the performance overhead of OS-level sandboxing on long-running agentic tasks?

## Related
- [[sandboxing]] · [[claude-code-auto-mode]] · [[agent-architectures]] · [[writing-tools-for-agents]]
