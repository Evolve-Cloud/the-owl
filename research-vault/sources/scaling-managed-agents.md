---
title: "Anthropic — Scaling Managed Agents: Decoupling the Brain from the Hands"
type: source
tags: [managed-agents, agent-architecture, infrastructure, distributed-systems, security]
sources: 1
updated: 2026-07-26
---
**Source:** [Scaling Managed Agents](https://www.anthropic.com/engineering/managed-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Lance Martin, Gabe Cemaj, Michael Cohen (Anthropic)  ·  **Published:** 2026  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
Anthropic describes the architecture of their Managed Agents hosted service — a system for running long-horizon agents reliably by decoupling the "brain" (Claude + harness) from the "hands" (sandboxes/tools) and the "session" (durable event log). The architecture draws an explicit analogy to OS abstractions: stable interfaces that outlast changing implementations. This piece is primarily about infrastructure design, not about Claude's cognitive capabilities.

## Key points
- **The pet problem**: an initial monolithic container is a named, un-replaceable "pet" — container failure means session loss.
- **Brain/hands decoupling**: the harness moves out of the container; calls the sandbox via `execute(name, input) → string`; containers become stateless cattle.
- **Session as external durable log**: the session (event log) lives outside Claude's context window; `getEvents()` allows positional slicing, rewinding, and rereading.
- **Harness recovery**: when the harness fails, `wake(sessionId)` + `getSession(id)` restores from the event log; the harness is also stateless cattle.
- **Security boundary**: credentials never exposed in the sandbox. Git tokens bundled at clone time. MCP OAuth tokens stored in a vault; a proxy handles requests without exposing tokens to Claude.
- **TTFT improvement**: p50 dropped ~60%, p95 dropped ~90% by provisioning containers on demand.
- **Context anxiety**: Claude Sonnet 4.5 exhibited premature task wrap-up near the context limit; Claude Opus 4.5 did not — harness assumptions can go stale as models improve.

## Informs (ideas / patterns)
- [[managed-agents]] — the primary subject; full architecture described here.
- [[agent-architectures]] — decoupling pattern, brain/hands/session separation.
- [[context-engineering]] — session vs. context-window distinction; context transformation in the harness.

## Notable quotes
> "Harnesses encode assumptions about what Claude can't do on its own. However, those assumptions need to be frequently questioned because they can go stale as models improve."
> "The session provides this same benefit, serving as a context object that lives outside Claude's context window."
> "Claude Code is an excellent harness that we use widely across tasks."
> "Building Managed Agents meant solving an old problem in computing: how to design a system for 'programs as yet unthought of.'"

## Gaps / open questions
- What is the latency cost of the `execute()` call crossing a service boundary vs. an in-container syscall?
- "Brains can pass hands to one another" — how does credential scoping work across brain handoffs?

## Related
- [[effective-context-engineering]] · [[managed-agents]] · [[agent-architectures]] · [[claude-managed-agents]] · [[anthropic]]
