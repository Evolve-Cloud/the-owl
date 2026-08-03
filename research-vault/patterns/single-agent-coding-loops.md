---
title: Single-agent coding loops
type: pattern
tags: [agentic-coding, react, agent-computer-interface, parallelization, single-agent]
sources: 5
updated: 2026-08-03
---

## Definition
The **single-agent-first** baseline for coding work: one agent runs a tight **reason → act → observe** loop, grounded at every step in real evidence from its environment (test output, compiler errors, file contents), through a well-designed **agent-computer interface (ACI)** and an isolated execution workspace. Multiple agents are added only when the target is *genuinely* parallelizable — which most coding is **not**. Parallel coding, when it works, is not a different pattern: it is *N* of these same single-agent loops running independently, coordinated by coarse-grained locking, over a target that happens to decompose into near-independent pieces.

## Key ideas

- **The loop is the primitive: evidence → action → observation (ReAct).** Interleaving reasoning traces with actions that produce fresh observations keeps the agent's plan grounded in the real world instead of drifting on its own priors. This is the evidence-action-observation grounding that every coding agent is built on ([[react-paper]]).

- **The ACI is what makes the loop effective.** A capable model on a poorly-shaped interface performs badly; the same model on a purpose-built agent-computer interface (scoped commands, structured feedback, guardrails against malformed actions) performs reliably. The *interface design*, not just the model, is the lever ([[swe-agent]], [[swe-agent-paper]]).

- **Isolation makes the loop safe to run.** The agent needs a real, isolated execution environment where it can run commands, observe results, and iterate without contaminating (or being contaminated by) other work. Durable artifacts — agents, skills, tests — persist in the repo structure ([[openhands]]).

- **Test/verifier quality is the enabling constraint.** When the loop's observations come from a weak oracle, the agent optimizes the wrong thing: it "solves" a problem the tests don't actually check. The verifier must be near-perfect for autonomous work to converge ([[building-c-compiler]]).

- **Parallelism is loop-count scaling, not a new mechanism.** The compiler case study ran 16 independent single-agent loops in a bash loop, each pulling from a shared queue, **locking tasks via git** to avoid duplication, committing, and moving on. It worked because a C compiler is *unusually* parallelizable — many near-independent passes/features — and because coordination stayed coarse (git-level locks), never fine-grained shared-file editing ([[building-c-compiler]]).

- **Most coding is parallelization-poor.** The reason the compiler is the exception that proves the rule: multi-agent fan-out is expensive and pays off only on high-value, genuinely decomposable work. Anthropic's own multi-agent research system flags coding as the canonical *bad* fit — "unsuitable for parallelization-poor domains like most coding" ([[multi-agent-research-system]]). So the default is one grounded loop; fan-out is the justified exception.

## Evidence / sources
- [[react-paper]] — [ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629). Primary-source origin of the reason→act→observe loop; the evidence-action-observation grounding all coding agents inherit.
- [[swe-agent]] — [SWE-agent](https://github.com/SWE-agent/SWE-agent) (repo, 19.5k★). The agent-computer interface as the effectiveness lever; isolated execution + evidence/action/observation loops.
- [[swe-agent-paper]] — [SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering](https://arxiv.org/abs/2405.15793). Primary-source backing that a well-designed ACI (not model alone) drives reliable software engineering.
- [[openhands]] — [OpenHands](https://github.com/OpenHands/OpenHands) (repo, 81.9k★). Isolated execution environments + durable project artifacts (agents/skills/tests as repo structure).
- [[building-c-compiler]] — [Building a C Compiler with a Team of Parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler) (Nicholas Carlini, Anthropic, 2026-02-05). 16 parallel single-agent loops, git task-locking, role specialization; ~2B input tokens / ~$20k; test quality as the critical variable.

> [!important]
> The load-bearing claim from the compiler case, in the author's words: *"Claude will work autonomously to solve whatever problem I give it. So it's important that the task verifier is nearly perfect."* Loop quality is bounded by observation quality.

> [!note]
> The "unsuitable for parallelization-poor domains like most coding" line is Anthropic's [[multi-agent-research-system]] caution, **not** the compiler blog. The compiler is the rare parallelizable coding target; the general rule cuts the other way.

## How it maps to the-owl
the-owl **already embodies single-agent-first by construction**, not by convention: it is a single-threaded, no-runtime, hub-and-spoke markdown library where the loop runs **one agent per phase** (ADR-010), the orchestrator delegates and specialists never call each other. There is no runtime that could spawn parallel disk-writing agents.

Consequently, the ledger's history is the mapping:
- **`single-agent-first`** (the "why multiple agents?" field on team-design ADRs) is **deferred (69)** — the *principle* is already lived architecturally, so an explicit convention has repeatedly landed just under the promotion bar rather than filling an atomic gap.
- **`isolated-workspaces-for-parallel-coding`** is **rejected (41)** and **`parallel-independent-work`** is **rejected (52)** — both are *runtime-shaped*: worktree isolation and parallel independent writers presuppose a host capability the-owl deliberately does not have. A markdown rule implying isolation the host cannot enforce is a false guarantee.

So the compiler's 16-way fan-out is **not** a signal for the-owl to adopt parallelism — it *corroborates the rejection*. the-owl's transposable sliver ("declare file ownership / no overlap") already lives in [[role-decomposition]] ([[role-ownership]] + handoff-contract). The durable lesson the-owl keeps: default to one grounded evidence-action-observation loop; treat fan-out as a runtime-shaped exception to be justified, not a baseline — and the loop discriminates correctly against runtime-shaped ideas.

## Related
- [[role-decomposition]] · [[isolated-workspaces-for-parallel-coding]] · [[multi-agent-research-system]]
