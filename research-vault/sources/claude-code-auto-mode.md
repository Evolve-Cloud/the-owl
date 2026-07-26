---
title: "Anthropic — Claude Code Auto Mode: A Safer Way to Skip Permissions"
type: source
tags: [claude-code, sandboxing, security, permissions, auto-mode, prompt-injection]
sources: 1
updated: 2026-07-26
---
**Source:** [Claude Code auto mode: a safer way to skip permissions](https://www.anthropic.com/engineering/claude-code-auto-mode) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** John Hughes; contributors Alex Isken, Alexander Glynn, Conner Phillippi, David Dworken, Emily To, Fabien Roger, Jake Eaton, Javier Rando, Shawn Moore, Soyary Sunthorn (Anthropic)  ·  **Published:** 2026-03-25  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Auto mode introduces a model-based classifier layer between Claude Code and dangerous actions, creating a middle ground between manual permission approval and unrestricted execution. It addresses the "approval fatigue" problem (93% of prompts are approved without scrutiny) by automating safety decisions through a two-layer defense: input-layer prompt-injection probing and output-layer transcript classification.

## Key points
- Users approve 93% of permission prompts, creating approval fatigue that undermines security.
- Two-layer defense: (1) input-layer prompt-injection probe screens tool outputs; (2) output-layer transcript classifier evaluates actions before execution.
- Four threat categories treated uniformly (overeager behavior, honest mistakes, prompt injection, model misalignment) — all receive the same response: action blocking.
- Performance: 0.4% false-positive rate on real traffic; 17% false-negative rate on documented overeager actions.
- The classifier never sees tool outputs or assistant reasoning — "reasoning-blind classification" — preventing social engineering.
- "Deny-and-continue": blocked actions return denial notifications; the agent attempts safer alternatives.

## Informs (ideas / patterns)
- [[sandboxing]] — auto mode as a complement to OS-level sandboxing; reasoning-blind classification pattern.
- [[claude-code]] — auto mode as a new permission tier for production use.
- [[agent-architectures]] — deny-and-continue recovery pattern; multi-layer defense architecture.

## Notable quotes
> "Approval fatigue, where people stop paying close attention to what they're approving" is the core usability challenge being addressed.
> "The agent shouldn't be able to hide a dangerous operation behind a benign-looking wrapper."

## Gaps / open questions
- Can the classifier be extended to multi-agent scenarios where one agent triggers actions on behalf of another?
- What happens when a blocked action is truly necessary and no safe alternative exists?

## Related
- [[sandboxing]] · [[claude-code-sandboxing]] · [[claude-code-best-practices]] · [[writing-tools-for-agents]]
