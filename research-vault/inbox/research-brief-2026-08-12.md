---
schema_version: 1
date: 2026-08-12
generator: gpt-5-codex
source_count: 3
idea_count: 2
---

## Executive summary
This cycle found little usable topology delta for the-owl because most recent multi-agent coding material is runtime-shaped: parallel fleets, task daemons, shared SQL todo state, UI agent trees, or SDK event streams.
The strongest usable shift is narrower: modern agent platforms are separating the specialist roster from the routing policy that decides whether a specialist may be selected automatically.
GitHub's Copilot SDK exposes this as `infer: false`; GitHub's CLI docs describe a built-in research agent that can only be invoked explicitly, not auto-triggered by the main agent.
Anthropic's Managed Agents documentation adds another topology-relevant control: coordinator rosters are snapshotted and referenced agents are version-pinned until the coordinator is updated.
For the-owl, the usable delta is not adopting either runtime. It is adding markdown-visible routing eligibility and roster-version intent so the hub-and-spoke topology is explicit, auditable, and less dependent on prose-only descriptions.
No contradiction against a decided idea was found on the scoped axis.

## Sources
| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | Anthropic Managed Agents: Multiagent orchestration | doc | https://platform.claude.com/docs/en/managed-agents/multiagent-orchestration | n/a | primary |
| s2 | GitHub Docs: Custom agents and sub-agent orchestration | doc | https://docs.github.com/en/copilot/how-tos/copilot-sdk/features/custom-agents | n/a | primary |
| s3 | GitHub Docs: About custom agents | doc | https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-custom-agents | n/a | primary |

## Ideas

### routing-eligibility-mode: Explicit Routing Eligibility Per Specialist
```yaml
id: routing-eligibility-mode
title: Explicit routing eligibility per specialist
category: orchestration
delta_type: net-new
challenges_id:
pattern: >
  Separate "this specialist exists" from "the orchestrator may select this specialist automatically."
  GitHub's Copilot SDK exposes this distinction with an `infer` flag, while its CLI docs describe a research agent that is only invocable by an explicit slash command.
  In a markdown-only hub-and-spoke system, the same pattern can be encoded as a routing eligibility field on each agent: automatic, mandatory-when-condition-matches, or explicit-only.
evidence: [s2, s3]
rationale: >
  Automatic routing based only on role descriptions can make specialist invocation too broad, especially for agents that are expensive, disruptive, or meant for rare escalation.
  A visible routing mode lets the orchestrator keep a stable roster while narrowing which spokes are eligible for implicit delegation.
applicability_to_owl: 5
applicability_note: >
  This maps cleanly to the-owl as YAML/frontmatter plus prompt convention.
  It preserves hub-and-spoke control because only the orchestrator reads the field and delegates; specialists still never call each other.
proposed_change: >
  Add a `routing_mode` field to every agent definition with allowed values such as `auto`, `mandatory`, and `explicit-only`, plus a short `routing_trigger` sentence.
  Mark high-friction or exceptional roles as explicit-only unless an existing ADR requires mandatory delegation.
risk: >
  If overused, explicit-only routing can hide useful specialists and reduce delegation quality.
  If described as enforcement when the Claude Code harness does not enforce it directly, it risks becoming unenforceable prose; the convention should be framed as orchestrator-readable routing metadata, not a hard security boundary.
confidence: high
references:
  - https://docs.github.com/en/copilot/how-tos/copilot-sdk/features/custom-agents
  - https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-custom-agents
```

### pinned-roster-snapshots: Version-Pinned Specialist Rosters
```yaml
id: pinned-roster-snapshots
title: Version-pinned specialist rosters
category: orchestration
delta_type: recency
challenges_id:
pattern: >
  Treat the orchestrator's specialist roster as a snapshotted topology artifact, not a loose list of agent names.
  Anthropic's Managed Agents docs state that referenced agents remain pinned to resolved versions until the coordinator is updated.
  For the-owl, the portable idea is to record which agent definition revision a pipeline cycle intended to use when an ADR changes delegation topology.
evidence: [s1]
rationale: >
  Multi-agent behavior can change when a specialist prompt changes, even if the orchestrator prompt is untouched.
  Pinning or at least recording the intended specialist revision makes topology drift visible and gives ADRs a concrete surface for reviewing routing changes.
applicability_to_owl: 4
applicability_note: >
  the-owl cannot rely on a Managed Agents runtime snapshot, but it can express the same control as markdown metadata and ADR structure.
  A lightweight `roster_revision` or per-agent prompt digest in the orchestrator documentation would preserve the no-runtime constraint.
proposed_change: >
  Extend topology-changing ADRs with a `roster_snapshot` section listing each delegated specialist, its file path, and a human-readable revision marker such as commit SHA or prompt version.
  When an agent prompt changes materially, require the chronicler to note whether the orchestrator roster intent changed or only the specialist internals changed.
risk: >
  Manual revision recording can become stale if it is not updated with prompt changes.
  Adding too much bookkeeping may slow small edits, so the field should be limited to topology-affecting ADRs rather than every prompt edit.
confidence: medium
references:
  - https://platform.claude.com/docs/en/managed-agents/multiagent-orchestration
```

## Anti-patterns to avoid
- Implicit auto-routing for every named specialist — recent platform docs increasingly expose routing eligibility controls because role descriptions alone are too blunt.
- Treating specialist prompt edits as topology-neutral by default — a hub-and-spoke roster can drift behaviorally even when the orchestrator file is unchanged.
- Importing fleet, swarm, or task-graph runtimes as the lesson — those are mostly outside the-owl's markdown-only and sequential constraints.

## Open questions
- Should `routing_mode` be added to all agents now, or only to agents whose invocation has caused misrouting in prior cycles?
- What revision marker is cheapest and least brittle for `roster_snapshot`: commit SHA, ADR id, prompt version, or file hash?