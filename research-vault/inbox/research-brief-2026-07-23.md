---
schema_version: 1
date: 2026-07-23
generator: gpt-5-deep-research
source_count: 8
idea_count: 8
---

## Executive summary

The strongest consensus is to use small, specialized roles with explicit boundaries rather than large autonomous swarms.
Production systems increasingly combine deterministic workflows with limited agent autonomy at decision points.
Handoffs are becoming structured state transitions, not informal conversational messages.
Context minimization, durable artifacts, and traceable evaluation are treated as core reliability mechanisms.
Human approval remains important for consequential actions and uncertain outputs.
Markdown-native agent libraries are increasingly viable through skills, plugins, and shared source-of-truth conventions.
Popular frameworks demonstrate useful patterns, but their runtime abstractions are not automatically appropriate for a no-runtime library.
The field is moving away from unconstrained group chat, implicit memory, and framework-first complexity.

## Sources

| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | Anthropic — Building effective agents | blog | https://www.anthropic.com/engineering/building-effective-agents | n/a | primary |
| s2 | LangGraph | repo | https://github.com/langchain-ai/langgraph | 38.0k | primary |
| s3 | CrewAI | repo | https://github.com/crewAIInc/crewAI | 56.0k | primary |
| s4 | AG2 / AutoGen | repo | https://github.com/ag2ai/ag2 | n/a | primary |
| s5 | Microsoft AutoGen | repo | https://github.com/microsoft/autogen | 59.9k | primary |
| s6 | OpenAI Swarm | repo | https://github.com/openai/swarm | 21.9k | primary |
| s7 | wshobson/agents | repo | https://github.com/wshobson/agents | 38.2k | primary |
| s8 | Claude Platform CLI, SDKs, and libraries | doc | https://platform.claude.com/docs/en/cli-sdks-libraries/overview | n/a | primary |

## Ideas

### explicit-role-boundaries: Explicit role boundaries
```yaml
id: explicit-role-boundaries
title: Explicit role boundaries
category: roles
pattern: >
  Assign each agent one narrow responsibility, defined inputs, permitted tools, and an explicit
  completion condition. Separate implementation from review, planning from execution, and
  evaluation from generation. Adoption is visible across CrewAI role-based agents, AG2 coder/reviewer
  examples, and markdown-native agent marketplaces.
evidence: [s1, s3, s4, s7] + multiple high-adoption implementations
rationale: Narrow roles reduce duplicated work, conflicting edits, and ambiguous accountability while making outputs easier to evaluate.
applicability_to_owl: 5
applicability_note: >
  Encode a mandatory Role, Non-goals, Inputs, Outputs, Allowed tools, and Done criteria section
  in every agent markdown file.
proposed_change: >
  Add a standardized role-boundary template to all eight agents and require each agent to state
  at least three explicit non-goals.
risk: >
  Over-specialization can create excessive handoffs or leave tasks uncovered; boundaries must be
  reviewed when the library gains a new workflow.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/crewAIInc/crewAI
  - https://github.com/ag2ai/ag2
  - https://github.com/wshobson/agents
```

### deterministic-handoff-contracts: Deterministic handoff contracts
```yaml
id: deterministic-handoff-contracts
title: Deterministic handoff contracts
category: communication
pattern: >
  Treat delegation as a typed state transition with a compact contract: objective, evidence,
  decisions, unresolved questions, constraints, and expected response shape. The receiving agent
  should not need the entire conversation to act. Structured outputs and explicit message exchange
  are recurring patterns in AG2, LangGraph state transitions, and production workflow guidance.
evidence: [s1, s2, s4, s5] + recurring structured-state pattern
rationale: Contracts reduce context drift, make failures diagnosable, and let the hub validate whether a specialist actually completed its assignment.
applicability_to_owl: 5
applicability_note: >
  Add a Handoff Contract section to every agent and define one YAML-like return envelope for
  findings, decisions, risks, open questions, and recommended next delegation.
proposed_change: >
  Create a shared HANDOFF-CONTRACT.md convention and require every delegation prompt to name the
  receiving agent, input artifact, output fields, and escalation condition.
risk: >
  Rigid schemas can suppress useful nuance or force premature certainty; allow an explicit
  unknowns and evidence-quality field.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/langchain-ai/langgraph
  - https://github.com/ag2ai/ag2
  - https://github.com/microsoft/autogen
```

### workflow-first-orchestration: Workflow-first orchestration
```yaml
id: workflow-first-orchestration
title: Workflow-first orchestration
category: orchestration
pattern: >
  Use deterministic sequences, branches, and approval gates for known work, reserving agent
  autonomy for ambiguous decisions. Anthropic explicitly distinguishes predictable workflows from
  flexible agents, while LangGraph and CrewAI expose durable graph or flow structures alongside
  autonomous teams. The pattern is broadly adopted, but runtime implementations are outside the-owl's scope.
evidence: [s1, s2, s3, s5] + high-adoption framework convergence
rationale: Deterministic control improves predictability, cost, auditability, and recovery without eliminating specialist reasoning where it is valuable.
applicability_to_owl: 5
applicability_note: >
  Express each major task as a documented delegation sequence with allowed transitions, hard
  stops, and explicit approval points rather than adding a runtime graph.
proposed_change: >
  Add a WORKFLOW section to the top-level library documentation describing the canonical
  hub-to-specialist sequence and permitted return paths.
risk: >
  Excessive sequencing can increase latency and prevent useful parallel exploration; permit
  parallel specialist analysis only when outputs are independent and mergeable.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/langchain-ai/langgraph
  - https://github.com/crewAIInc/crewAI
```

### artifact-oriented-context: Artifact-oriented context
```yaml
id: artifact-oriented-context
title: Artifact-oriented context
category: context
pattern: >
  Pass compact, durable artifacts instead of full conversational history: plans, decisions,
  evidence summaries, test results, and unresolved questions. Persist only information that
  must survive the current task, while keeping transient reasoning local. LangGraph emphasizes
  short-term and long-term memory, and Anthropic emphasizes context management and modular design.
evidence: [s1, s2, s7] + convergent production-design guidance
rationale: Smaller context reduces token cost and distraction while durable artifacts preserve continuity and auditability.
applicability_to_owl: 5
applicability_note: >
  Strengthen the N-1 rule by defining a compact handoff artifact and a separate durable ADR or
  decision note; prohibit forwarding raw transcripts by default.
proposed_change: >
  Add Context Budget and Durable Artifact sections to the agent template, including a maximum
  input summary shape and rules for what belongs in an ADR.
risk: >
  Aggressive summarization can discard critical evidence or uncertainty; require citations,
  provenance, and an explicit omitted-context warning.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/langchain-ai/langgraph
  - https://github.com/wshobson/agents
```

### evaluator-optimizer-loop: Evaluator-optimizer loop
```yaml
id: evaluator-optimizer-loop
title: Evaluator-optimizer loop
category: self-improvement
pattern: >
  Separate generation from evaluation: one agent produces a plan or change, another checks it
  against explicit criteria, and the producer revises only when the evaluator identifies a
  concrete defect. Anthropic identifies evaluator-optimizer workflows as a reusable pattern;
  LangGraph emphasizes trajectory evaluation and observability, and CrewAI exposes review-oriented
  task patterns. Evidence supports the pattern more strongly than any universal score threshold.
evidence: [s1, s2, s3] + primary-source pattern convergence
rationale: Independent critique catches omissions and makes quality criteria visible without requiring every agent to be both creator and judge.
applicability_to_owl: 5
applicability_note: >
  Formalize guardian and challenger as evaluators with distinct rubrics, require evidence-backed
  findings, and route revisions back through the hub rather than allowing direct agent-to-agent calls.
proposed_change: >
  Add an Evaluation Contract defining rubric, severity, evidence requirement, pass criteria, and
  maximum revision rounds.
risk: >
  Evaluators can agree with plausible but incorrect output, and repeated critique can create
  cost or stagnation; retain human escalation for high-impact or disputed decisions.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/langchain-ai/langgraph
  - https://github.com/crewAIInc/crewAI
```

### markdown-source-of-truth: Markdown source of truth
```yaml
id: markdown-source-of-truth
title: Markdown source of truth
category: files
pattern: >
  Keep agent behavior in readable, version-controlled Markdown and derive harness-specific
  packaging or metadata from that source. The wshobson/agents repository demonstrates a large
  Markdown-native marketplace spanning multiple agent harnesses, with separate plugin registries,
  skills, commands, and agent files. Its adoption is strong, but its star count and ecosystem
  scale do not prove that every structure is optimal.
evidence: [s7, s8] + 38.2k-star repository adoption
rationale: Human-readable files simplify review, portability, diff-based governance, and prompt experimentation.
applicability_to_owl: 5
applicability_note: >
  Preserve Markdown as the canonical agent format, while adding predictable directories for
  agents, commands, conventions, ADRs, and shared schemas.
proposed_change: >
  Add a repository layout convention and a lightweight manifest describing each agent's role,
  inputs, outputs, tools, and owning ADRs without introducing a runtime.
risk: >
  Multiple generated or harness-specific copies can drift from the source; designate one canonical
  file and require generated artifacts to be clearly marked.
confidence: high
references:
  - https://github.com/wshobson/agents
  - https://platform.claude.com/docs/en/cli-sdks-libraries/overview
```

### least-privilege-tool-scopes: Least-privilege tool scopes
```yaml
id: least-privilege-tool-scopes
title: Least-privilege tool scopes
category: safety
pattern: >
  Give each role only the tools and permissions required for its task, and make sensitive actions
  require explicit human approval or a separate executor. Official agent frameworks expose tool
  registration and human-in-the-loop mechanisms, while current coding-agent practice increasingly
  separates planning, review, and mutation capabilities. The pattern is operationally strong,
  although framework documentation does not by itself establish security effectiveness.
evidence: [s1, s4, s5, s8] + primary framework support for tool scoping and HITL
rationale: Narrow tool access limits blast radius, reduces accidental mutation, and makes prompt-injection containment more tractable.
applicability_to_owl: 5
applicability_note: >
  Add Allowed tools, Forbidden tools, and Approval required sections to every agent; encode
  read-only defaults and require the hub to approve any mutating handoff.
proposed_change: >
  Update all agent prompts with explicit capability boundaries and add a mandatory human approval
  gate before implementation, repository mutation, or external side effects.
risk: >
  Overly narrow permissions can block legitimate work and encourage unsafe workarounds; provide
  a documented escalation path through the hub.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/ag2ai/ag2
  - https://github.com/microsoft/autogen
  - https://platform.claude.com/docs/en/cli-sdks-libraries/overview
```

### provenance-first-evaluation: Provenance-first evaluation
```yaml
id: provenance-first-evaluation
title: Provenance-first evaluation
category: self-improvement
pattern: >
  Evaluate agent work using reproducible tasks, explicit rubrics, observed trajectories, and
  artifact provenance rather than subjective final-output impressions alone. LangGraph promotes
  tracing and trajectory evaluation, while the broader agent ecosystem increasingly separates
  observability from execution. No source establishes a universal benchmark for markdown-only
  agent libraries, so local regression suites remain necessary.
evidence: [s1, s2, s7] + primary observability and evaluation guidance
rationale: Provenance makes regressions, hallucinations, and prompt changes measurable and supports safe iteration.
applicability_to_owl: 5
applicability_note: >
  Define replayable scenario prompts, expected delegation paths, ADR checks, and reviewer rubrics;
  store results as versioned Markdown or JSON fixtures rather than adding an evaluation service.
proposed_change: >
  Add an evals/ convention with representative tasks, expected handoffs, safety failures, and a
  changelog of score changes for every prompt revision.
risk: >
  Narrow evals can be gamed or overfit and may reward stylistic conformity instead of useful work;
  rotate scenarios and include adversarial cases.
confidence: medium
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/langchain-ai/langgraph
  - https://github.com/wshobson/agents
```

### centralized-governance-hub: Centralized governance hub
```yaml
id: centralized-governance-hub
title: Centralized governance hub
category: orchestration
pattern: >
  Prefer a coordinator that owns task decomposition, delegation, merge decisions, and escalation,
  while specialists return findings rather than directly invoking one another. Lightweight Swarm
  and multi-agent frameworks demonstrate handoffs, but more autonomous group-chat and swarm modes
  increase coordination freedom and ambiguity. The evidence supports handoffs as a useful primitive,
  not a claim that every task benefits from a free-form swarm.
evidence: [s1, s3, s4, s6] + popular-framework comparison
rationale: A hub preserves accountability, prevents cycles, and fits governance-heavy work where every decision must be reviewable.
applicability_to_owl: 5
applicability_note: >
  Make the orchestrator the sole delegation authority, require all specialists to return control,
  and reject direct specialist-to-specialist calls in the shared conventions.
proposed_change: >
  Add a non-negotiable Delegation Authority rule to AGENTS.md and each agent prompt, including
  explicit handling for incomplete, conflicting, or unsafe specialist outputs.
risk: >
  The hub can become a bottleneck, single point of failure, or source of biased decomposition;
  use bounded parallel branches and evaluator checks without creating a free mesh.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/openai/swarm
  - https://github.com/crewAIInc/crewAI
  - https://github.com/ag2ai/ag2
```

## Anti-patterns to avoid

- Unconstrained multi-agent group chat — increases token cost, coordination ambiguity, and duplicate work; structured workflows and explicit handoffs are replacing it.
- Framework-first architecture — adds abstraction and hidden behavior before the problem requires it; simple composable prompts and direct model APIs are often preferred.
- Full-transcript forwarding — wastes context and amplifies irrelevant or poisoned content; compact evidence artifacts and scoped memory are replacing it.
- Agents with overlapping authority — makes ownership and failure analysis unclear; narrow roles with explicit non-goals are replacing it.
- Autonomous mutation without approval — expands blast radius and weakens auditability; least-privilege tools and human-in-the-loop gates are replacing it.
- Evaluation by final prose quality alone — misses unsafe trajectories and provenance failures; replayable tasks, rubrics, and trace inspection are replacing it.

## Open questions

- Which handoff schema is expressive enough for complex work while remaining compact under the-owl's N-1 context rule?
- How should the library measure whether a new specialist reduces total effort rather than merely adding another review stage?
- Which Markdown-native eval fixtures best predict real Claude Code outcomes across repositories and task types?
- When should bounded parallel delegation be allowed without weakening the hub-and-spoke governance model?
- How can prompt-injection defenses distinguish hostile repository content from legitimate project instructions without excessive false positives?