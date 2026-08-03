---
title: Inter-agent handoff & orchestration
type: pattern
tags: [communication, handoff, orchestration, topology]
sources: 6
updated: 2026-08-03
---

## Definition

How agents in a multi-agent team **hand control and information to one another**, and who owns the routing. Two things travel in every handoff and they are separable:

1. **The payload** — *what* the next agent receives. Best practice is a **typed/structured contract** (objective, inputs-as-pointers, output format, done-criteria), filtered down to the direct dependency — **not** the whole transcript.
2. **The control** — *whether* the receiving agent takes over, and if so, does control ever come back. This is the axis that decides the team **topology**: control that **returns to a central hub** (hub-and-spoke) vs. control that **moves agent-to-agent** (mesh/peer handoff).

The-owl adopts the first (typed payload) and deliberately constrains the second (control always returns to the orchestrator — **coordinator-owned routing**, never a free mesh).

## Key ideas

### Typed / structured handoff, not an informal message
A handoff is a **state transition with a schema**, not a chat message. The OpenAI Agents SDK models this as a first-class `handoff` with a **typed input** and **input filters** (control what the receiving agent sees) and a `reason`; LangGraph exposes handoffs as explicit, directional control-transfer primitives inside a graph. The convergent payoff: less ambiguity, less rework, no diffuse accountability, and a natural fit for **context-minimal (N-1)** transfer — you pass the direct upstream dependency plus pointers (paths), never the accumulated history.

### Directed handoff graph — no free mesh
Handoffs travel along **declared, directional edges**, not an open "any agent may call any agent" mesh. A directed graph keeps the reachable state space small and auditable; a free mesh lets any pair of agents talk, which multiplies coordination failure modes (duplicate work, endless task-passing, contradictory recommendations — the same failure class [[role-decomposition]] guards against on the ownership side).

### Coordinator-owned routing (hub-and-spoke)
In the strongest production accounts the **coordinator owns routing**. OpenAI's agents-as-tools orchestration has a manager invoke specialists as **bounded capabilities** and keep control; Anthropic's multi-agent research system uses an **orchestrator-worker** shape where a lead agent decomposes the task, spawns subagents, and integrates their results. The specialist returns a result to the hub; it does **not** re-dispatch to a peer.

### The topology spectrum & where control lives
| Topology | Control flow | When it fits | Cost / risk |
|---|---|---|---|
| **Hub-and-spoke** | Specialist returns control to a central orchestrator after each step. | Pipelines needing a single accountable integrator; auditability; context-minimal transfer. | Orchestrator is the bottleneck / single decision point. |
| **Pipeline** | Fixed A→B→C stage sequence; each stage a typed handoff. | Deterministic staged work with clear stage-artifacts. | Rigid; poor at dynamic re-routing. |
| **Mesh / peer handoff** | Control moves permanently to the receiving agent (Swarm, LangGraph handoff). | Highly dynamic conversational routing (e.g. triage → specialist). | No central integrator; harder to reason about, test, and bound. |
| **Swarm** | Many peers, lightweight handoffs as the only primitive. | Exploratory / educational; simple triage demos. | **Explicitly experimental** — adoption ≠ production-proven. |

The distinguishing question is always: **after a handoff, does control return to a hub, or move agent-to-agent?**

## Evidence / sources

- [[openai-agents-sdk-handoffs]] — typed handoffs with **input filters** and a structured payload (not the whole transcript); primary evidence for typed-minimal, directed transfer. (https://openai.github.io/openai-agents-python/handoffs/)
- [[langgraph-multi-agent-handoffs]] — handoff primitives as **explicit, directional** control transfer in a graph; evidence for directed-handoff-graph over free mesh. (https://docs.langchain.com/oss/python/langchain/multi-agent/handoffs)
- [[openai-agents-sdk-orchestration]] — **agents-as-tools**: a manager invokes specialists as bounded capabilities and **retains control**; evidence for coordinator-owned routing and simplest-sufficient topology. (https://openai.github.io/openai-agents-python/agents/)
- [[openai-swarm]] — handoffs as a **primitive** between peers; **self-labeled experimental/educational** — a design demonstration, not proof of production effectiveness. (https://github.com/openai/swarm)
- [[multi-agent-research-system]] — production **orchestrator-worker**: lead agent decomposes, spawns parallel subagents, integrates. Also the **cost side**: multi-agent uses **~15× more tokens** and is "unsuitable for parallelization-poor domains like most coding." (https://www.anthropic.com/engineering/multi-agent-research-system)
- [[scaling-managed-agents]] — **brain/hands/session** decoupling and the **durable event log outside the context window**: the infrastructure that makes structured, resumable handoffs reliable at long horizons. (https://www.anthropic.com/engineering/managed-agents)

> [!contradiction]
> Swarm and LangGraph treat a handoff as **permanent peer control-transfer** (the receiving agent takes over → this is what enables mesh). OpenAI's agents-as-tools orchestration and Anthropic's orchestrator-worker keep the coordinator in control (the specialist **returns** a result). The-owl resolves this in favor of the latter: a handoff's "next agent" is a **signal to the orchestrator**, never a direct peer invocation.

## Trade-off

Structured, directed, coordinator-owned handoffs buy **auditability, bounded state, single-integrator accountability, and context-minimal transfer** — at the cost of routing flexibility (the hub is the single decision point) and, for the full multi-agent orchestrator-worker version, **steep token cost (~15×)** that only pays off on high-value, parallelizable work. Free mesh / swarm buys dynamic routing and simplicity of the primitive, but sacrifices the central integrator and is harder to test and bound — and its most-cited exemplar (Swarm) is **explicitly not production-grade**. The honest read: prefer the **simplest sufficient topology**; escalate from single-agent → hub-spoke pipeline → mesh only when the task genuinely demands it.

## How it maps to the-owl

the-owl already embodies the adopted side of this pattern:
- **Typed handoff contract** — `docs/conventions/handoff-contract.md` (ADR-004, extended by ADR-020) mandates every handoff declare *Objetivo · Entradas (só dependências + paths) · Saída (+ path) · Escopo · Critério de pronto · Premissas & Questões em aberto · Próximo agente*. This is the typed/minimal payload, straight from the OpenAI/LangGraph primitive.
- **Coordinator-owned routing / no free mesh** — hub-and-spoke is a hard constraint: "o agente **sinaliza** o próximo passo e **devolve o controle ao orquestrador**; nunca invoca outro especialista diretamente." The `Próximo agente` field is a routing *signal to the hub*, not a peer call. This is exactly agents-as-tools / orchestrator-worker, not Swarm/mesh.
- **Directed handoff graph** — the `directed-handoff-graph` idea is on the ledger as "already largely implemented" (deferred, low re-accept priority) precisely because the sequential one-agent-per-phase `/owl:evolve` loop *is* a directed edge set with no mesh.
- **Artifact, not copy** — long output goes to a file; the handoff references the path. This mirrors the durable-log-outside-the-context-window discipline from [[scaling-managed-agents]].

**Gap this page closes:** the SCHEMA index flagged (lint) that handoff/orchestration lived **only** as an operational convention (`docs/conventions/handoff-contract.md`) with **no dedicated pattern page** — no accumulated *external-research memory* explaining what the pattern is, its evidence, and its trade-off. This page is that durable, retrievable memory. It changes no agent, no ADR, no convention — it consolidates the sources that back the already-adopted decisions.

## Related
- [[handoff-contract]] · [[role-decomposition]] · [[role-ownership]] · [[overview]]
