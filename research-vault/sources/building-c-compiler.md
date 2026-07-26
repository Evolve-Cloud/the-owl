---
title: "Anthropic — Building a C Compiler with a Team of Parallel Claudes"
type: source
tags: [multi-agent, agent-teams, agentic-coding, parallelization, long-running-agents]
sources: 1
updated: 2026-07-26
---
**Source:** [Building a C Compiler with a Team of Parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Nicholas Carlini (Anthropic Safeguards)  ·  **Published:** 2026-02-05  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
16 parallel Claude instances autonomously collaborated on a single C compiler project without human-in-the-loop management, producing a 100,000-line compiler that builds Linux 6.9 across three architectures. The project consumed ~2B input tokens and $20,000 in compute, demonstrating both the feasibility and the limits of autonomous multi-agent software development.

## Key points
- 16 parallel Claude instances in a bash loop: each picks up tasks from a shared queue, locks tasks to prevent duplication, commits to git, and immediately starts the next task.
- Test quality is the critical variable: poor tests cause agents to solve the wrong problem.
- Specialization helps: different agent roles (refactoring, performance, documentation, code quality) increased overall productivity.
- Resource scale: ~2B input tokens, 140M output tokens, ~2,000 sessions, ~$20,000.
- Opus 4.6 approaches the capability ceiling for autonomous compiler development: new features frequently break existing functionality.
- Safety concern: developers never personally verify generated code — requires new deployment safety strategies.

## Informs (ideas / patterns)
- [[agent-architectures]] — agent teams pattern; task locking via git; specialization roles in parallel agents.
- [[evals]] — test quality as the enabling constraint for autonomous agent work; delta debugging with an external oracle.

## Notable quotes
> "Claude will work autonomously to solve whatever problem I give it. So it's important that the task verifier is nearly perfect."
> "In one instance, I did see Claude `pkill -9 bash` on accident, thus killing itself."

## Gaps / open questions
- What does the capability ceiling look like for other complex systems (OS kernels, databases)?
- How should code review and deployment verification work when no human has verified the generated code?

## Related
- [[agent-architectures]] · [[multi-agent-research-system]] · [[effective-harnesses-long-running]] · [[harness-design-long-running-apps]]
