---
schema_version: 1
date: 2026-07-26
generator: gpt-5-o3-deep-research
source_count: 15
idea_count: 11
---

## Executive summary

The field is shifting from “more agents” toward explicit workflow design and context engineering.
Supervisor-and-specialist architectures remain the strongest general-purpose pattern for controlled teams.
Frameworks increasingly expose handoffs, structured state, checkpoints, tracing, and human approval as first-class concepts.
Single-agent baselines are now essential because multi-agent coordination adds latency, cost, and error propagation.
Evaluation is moving from final-answer scoring toward trajectory, tool-call, and task-success measurement.
Security practice increasingly treats prompts, tools, handoffs, and external content as separate trust boundaries.
OpenAI Swarm remains influential conceptually but is explicitly experimental; AutoGen is now in maintenance mode.

## Sources

| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | LangGraph | repo | https://github.com/langchain-ai/langgraph | 37.9k | primary |
| s2 | CrewAI | repo | https://github.com/crewAIInc/crewAI | 52.3k | primary |
| s3 | AutoGen | repo | https://github.com/microsoft/autogen | 60.0k | primary |
| s4 | OpenAI Swarm | repo | https://github.com/openai/swarm | 21.9k | primary |
| s5 | SWE-agent | repo | https://github.com/SWE-agent/SWE-agent | 19.9k | primary |
| s6 | Building Effective AI Agents | blog | https://www.anthropic.com/engineering/building-effective-agents | n/a | primary |
| s7 | LangGraph Multi-Agent Patterns | doc | https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/ | n/a | primary |
| s8 | OpenAI Agents SDK: Multi-Agent Orchestration | doc | https://openai.github.io/openai-agents-python/multi_agent/ | n/a | primary |
| s9 | OpenAI Agents SDK: Handoffs | doc | https://openai.github.io/openai-agents-python/handoffs/ | n/a | primary |
| s10 | AutoGen Selector Group Chat | doc | https://microsoft.github.io/autogen/dev/user-guide/agentchat-user-guide/selector-group-chat.html | n/a | primary |
| s11 | OpenAI Agents SDK Tracing | doc | https://openai.github.io/openai-agents-python/tracing/ | n/a | primary |
| s12 | Demystifying Evals for AI Agents | blog | https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents | n/a | primary |
| s13 | Trustworthy Agents in Practice | blog | https://www.anthropic.com/research/trustworthy-agents | n/a | primary |
| s14 | SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering | paper | https://papers.neurips.cc/paper_files/paper/2024/file/5a7c947568c1b1328ccc5230172e1e7c-Paper-Conference.pdf | n/a | primary |
| s15 | SWE-Debate: Competitive Multi-Agent Debate for Software Issue Resolution | paper | https://arxiv.org/abs/2507.23348 | n/a | primary |

## Ideas

### single-agent-first: Single-agent baseline before team expansion
```yaml
id: single-agent-first
title: Single-agent baseline before team expansion
category: structure
pattern: >
  Begin with one capable agent and add specialists only when the task has genuine
  decomposition, specialized context, independent work, or a measurable quality need.
  Multi-agent designs should be compared against a single-agent baseline on quality,
  cost, latency, and failure rate.
evidence: [s6, s7, s10]
rationale: Multi-agent coordination introduces handoff loss, duplicated reasoning, latency, and cost. Anthropic and LangGraph both distinguish cases where a single agent with well-scoped tools is sufficient.
applicability_to_owl: 5
applicability_note: >
  Add a mandatory “why multiple agents?” field to ADRs and require evidence that a
  new specialist removes a documented bottleneck or risk.
proposed_change: >
  Add a Team-Design ADR section comparing the proposed topology with the existing
  single-agent or smallest-team alternative.
risk: >
  Excessive conservatism can prevent useful specialization when tasks genuinely
  require independent contexts or parallel work.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/
```

### supervisor-specialists: Supervisor-owned specialist delegation
```yaml
id: supervisor-specialists
title: Supervisor-owned specialist delegation
category: orchestration
pattern: >
  A central supervisor retains responsibility for routing, synthesis, and final
  output while invoking narrow specialists as tools or delegated workers.
  Specialists return results to the supervisor rather than forming arbitrary peer-to-peer links.
evidence: [s1, s2, s7, s8]
rationale: Centralized routing improves observability, keeps authority and synthesis in one place, and limits communication paths. This is a recurring pattern in LangGraph, CrewAI, and OpenAI Agents SDK documentation.
applicability_to_owl: 5
applicability_note: >
  This maps directly to the-owl’s hub-and-spoke model: the orchestrating Claude Code
  session delegates to specialists, and each specialist returns control.
proposed_change: >
  Formalize the orchestrator as the sole delegation authority and prohibit specialist-to-specialist invocation in every agent contract.
risk: >
  The supervisor becomes a bottleneck and a single point of routing failure; poor routing can underuse or misuse specialists.
confidence: high
references:
  - https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/
  - https://openai.github.io/openai-agents-python/multi_agent/
  - https://github.com/crewAIInc/crewAI
```

### narrow-role-boundaries: Narrow roles with explicit non-goals
```yaml
id: narrow-role-boundaries
title: Narrow roles with explicit non-goals
category: roles
pattern: >
  Each agent has one primary responsibility, a bounded input domain, explicit
  non-goals, and a defined output artifact. Role descriptions should minimize overlap
  and make routing decisions distinguishable.
evidence: [s2, s3, s7, s10]
rationale: Role descriptions and agent metadata are used by supervisors and selector models to choose participants. Narrow boundaries reduce duplicated work and conflicting recommendations.
applicability_to_owl: 5
applicability_note: >
  Existing strategist, architect, builder, guardian, sentinel, challenger, and
  chronicler roles can gain explicit “owns,” “does not own,” and “when to invoke” sections.
proposed_change: >
  Add a Role Boundary section to every agent markdown file containing mission, inputs, outputs, non-goals, and escalation conditions.
risk: >
  Roles that are too narrow create routing overhead and may force artificial handoffs for tasks one agent could complete.
confidence: high
references:
  - https://github.com/crewAIInc/crewAI
  - https://microsoft.github.io/autogen/dev/user-guide/agentchat-user-guide/selector-group-chat.html
```

### structured-handoff-contracts: Typed handoff artifacts
```yaml
id: structured-handoff-contracts
title: Typed handoff artifacts
category: communication
pattern: >
  Handoffs carry a compact, structured contract rather than an unrestricted transcript.
  The contract identifies objective, assumptions, evidence, unresolved questions, artifacts,
  constraints, and the exact requested decision or next action.
evidence: [s8, s9, s1, s7]
rationale: Explicit handoff schemas reduce context loss and make downstream behavior auditable. OpenAI documents input filters and handoff history mapping; LangGraph models communication as state updates.
applicability_to_owl: 5
applicability_note: >
  The existing N-1 context rule can be strengthened by making every specialist output
  conform to a markdown/YAML handoff block.
proposed_change: >
  Add a mandatory Handoff Contract section to every agent prompt with fields for objective, findings, evidence, assumptions, risks, open questions, and requested next owner.
risk: >
  Rigid contracts can omit nuance or encourage agents to optimize for formatting rather than substantive reasoning.
confidence: high
references:
  - https://openai.github.io/openai-agents-python/handoffs/
  - https://langchain-ai.github.io/langgraph/concepts/multi_agent/
```

### sequential-artifact-pipeline: Sequential stages separated by durable artifacts
```yaml
id: sequential-artifact-pipeline
title: Sequential stages separated by durable artifacts
category: orchestration
pattern: >
  Complex work is divided into ordered stages where each stage consumes a defined
  artifact and produces the next artifact. Deterministic gates can be placed between
  stages, while model-driven reasoning is reserved for ambiguous decisions.
evidence: [s6, s7, s1, s14]
rationale: Sequential workflows provide predictable ordering, clear responsibility, and easier debugging than unconstrained conversations. SWE-agent also demonstrates the value of explicit agent-computer interaction loops.
applicability_to_owl: 5
applicability_note: >
  the-owl’s existing planning-to-architecture-to-build-to-review flow already fits this
  model and can be made more explicit through artifact names and acceptance criteria.
proposed_change: >
  Define canonical stage artifacts such as PRD, ADR, design, implementation plan, review findings, and release record, with each agent required to consume and produce only named artifacts.
risk: >
  Sequential stages increase latency and can block progress when an earlier artifact is incomplete or wrong.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/SWE-agent/SWE-agent
```

### context-budgeting: Deliberate context selection and summarization
```yaml
id: context-budgeting
title: Deliberate context selection and summarization
category: context
pattern: >
  Agents receive only the information required for their current responsibility.
  Systems may pass the last result, a filtered transcript, a structured summary, or
  selected state rather than the full conversation history.
evidence: [s7, s9, s1, s8]
rationale: Context engineering reduces distraction, token cost, and accidental authority leakage. LangGraph explicitly frames multi-agent design around selective context exposure, while OpenAI documents history filters and nested handoff summaries.
applicability_to_owl: 5
applicability_note: >
  This directly reinforces the-owl’s N-1 context rule while providing a standard for
  preserving evidence that must not be summarized away.
proposed_change: >
  Add a Context Budget section to every agent specifying allowed upstream sections,
  excluded sections, preservation-required evidence, and maximum handoff size.
risk: >
  Over-aggressive compression can remove critical evidence and cause downstream agents to repeat discovery work.
confidence: high
references:
  - https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/
  - https://openai.github.io/openai-agents-python/handoffs/
```

### externalized-checkpoint-memory: Explicit state and resumable checkpoints
```yaml
id: externalized-checkpoint-memory
title: Explicit state and resumable checkpoints
category: memory
pattern: >
  Long-running teams persist task state, intermediate artifacts, and checkpoints outside
  the prompt. Resumption must be designed for retries, idempotency, and changing execution
  conditions rather than relying on an ever-growing transcript.
evidence: [s1, s7, s8, s11]
rationale: State graphs and tracing systems make execution inspectable and resumable. Checkpoints reduce context pressure but require careful handling of repeated side effects and stale state.
applicability_to_owl: 3
applicability_note: >
  Because the-owl has no runtime, express this as a convention for ADRs, handoff
  artifacts, and repository documents rather than introducing a persistence engine.
proposed_change: >
  Add a “Durable State” convention defining which outputs must be written to repository artifacts and how an interrupted delegation resumes from the latest artifact.
risk: >
  Persisted state can become stale, leak sensitive information, or create false confidence that an artifact is authoritative.
confidence: high
references:
  - https://langchain-ai.github.io/langgraph/concepts/multi_agent/
  - https://openai.github.io/openai-agents-python/tracing/
```

### least-privilege-tools: Tool and permission scoping per agent
```yaml
id: least-privilege-tools
title: Tool and permission scoping per agent
category: safety
pattern: >
  Each agent receives only the tools and permissions required for its role.
  Sensitive or mutating operations require explicit approval, and tool inputs and outputs
  are validated independently of the language model’s instructions.
evidence: [s8, s9, s13, s3]
rationale: Tool boundaries reduce blast radius and make authorization legible. Anthropic emphasizes human control and security, while OpenAI exposes guardrails around tools, handoffs, and approvals.
applicability_to_owl: 5
applicability_note: >
  the-owl can encode tool allowlists, forbidden operations, approval gates, and
  escalation rules entirely in YAML frontmatter and prompt sections.
proposed_change: >
  Add per-agent Allowed Tools, Forbidden Tools, Mutation Policy, and Approval Required sections to every agent definition.
risk: >
  Overly restrictive permissions can make agents ineffective or encourage unsafe workarounds through indirect tools.
confidence: high
references:
  - https://www.anthropic.com/research/trustworthy-agents
  - https://openai.github.io/openai-agents-python/handoffs/
```

### trajectory-evals: Evaluate trajectories, not only final answers
```yaml
id: trajectory-evals
title: Evaluate trajectories, not only final answers
category: self-improvement
pattern: >
  Agent teams are evaluated on task success, intermediate decisions, tool calls,
  handoff quality, policy violations, cost, latency, and recovery behavior.
  Evaluation sets should include representative cases, adversarial cases, and regression cases.
evidence: [s11, s12, s14, s15]
rationale: Final-answer scoring hides inefficient, unsafe, or lucky trajectories. Tracing and coding benchmarks provide the observable execution history needed for meaningful evaluation.
applicability_to_owl: 5
applicability_note: >
  Add replayable markdown fixtures and score each agent’s artifact against acceptance
  criteria, delegation compliance, security constraints, and regression expectations.
proposed_change: >
  Create an Eval Contract section for each agent defining test cases, pass/fail criteria, trajectory checks, and required evidence.
risk: >
  Automated graders can reward stylistic conformity, overfit to benchmark cases, or miss real-world maintainability.
confidence: high
references:
  - https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
  - https://openai.github.io/openai-agents-python/tracing/
  - https://github.com/SWE-agent/SWE-agent
```

### evaluator-optimizer-loop: Separate generation from verification
```yaml
id: evaluator-optimizer-loop
title: Separate generation from verification
category: self-improvement
pattern: >
  One agent produces a plan or implementation and a separate evaluator checks it against
  explicit criteria, tests, or reference evidence. Feedback is fed back through a bounded
  revision loop rather than unrestricted self-critique.
evidence: [s6, s12, s15]
rationale: Independent evaluation can expose omissions and incorrect assumptions that the generator does not notice. Debate research suggests gains are possible when perspectives and stopping criteria are structured, but results are task-dependent.
applicability_to_owl: 5
applicability_note: >
  guardian, sentinel, and challenger already provide natural evaluator roles without
  changing the hub-and-spoke topology.
proposed_change: >
  Define a bounded review loop: builder output, guardian verification, sentinel security review, challenger adversarial review, then one orchestrator-controlled revision cycle.
risk: >
  Review loops multiply cost and can produce correlated errors when evaluator and generator share the same assumptions or model.
confidence: medium
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://arxiv.org/abs/2507.23348
```

### human-approval-gates: Human approval at consequential boundaries
```yaml
id: human-approval-gates
title: Human approval at consequential boundaries
category: safety
pattern: >
  Agents may investigate, plan, and propose, but consequential mutations pause for
  explicit human approval. Approval should identify the proposed action, scope, expected
  effect, risks, and rollback or recovery information.
evidence: [s13, s8, s9, s3]
rationale: Human control is the most direct defense against misunderstood intent, prompt injection, and unsafe tool use. Frameworks increasingly expose interruptions, approvals, and guardrails as runtime primitives.
applicability_to_owl: 5
applicability_note: >
  This matches the-owl’s hard-stop governance and can be encoded as mandatory prompt
  gates before implementation, deployment, or irreversible repository changes.
proposed_change: >
  Add a standard Approval Gate block to all agents that can propose or authorize mutations, requiring explicit approval evidence before delegation continues.
risk: >
  Excessive approvals create operator fatigue and may cause humans to approve changes without adequate review.
confidence: high
references:
  - https://www.anthropic.com/research/trustworthy-agents
  - https://openai.github.io/openai-agents-python/
```

### parallel-independent-work: Parallelize only independent subtasks
```yaml
id: parallel-independent-work
title: Parallelize only independent subtasks
category: orchestration
pattern: >
  Parallel workers are appropriate when subtasks have independent inputs and can be
  merged through a defined reducer or synthesis step. Sequential execution remains
  preferable when later reasoning depends heavily on earlier reasoning.
evidence: [s7, s8, s10, s15]
rationale: Parallelism can reduce latency and increase diversity, but shared mutable context and correlated assumptions create merge and error-propagation costs.
applicability_to_owl: 3
applicability_note: >
  the-owl can permit parallel specialist review only when the orchestrator defines
  independent scopes and a synthesis artifact; specialists still do not call each other.
proposed_change: >
  Add a Parallelization Eligibility field to ADRs requiring independent inputs, non-overlapping ownership, and a named synthesis owner.
risk: >
  Parallel agents may duplicate work, disagree without resolution criteria, or produce conflicting repository edits.
confidence: high
references:
  - https://langchain-ai.github.io/langgraph/concepts/multi_agent/
  - https://openai.github.io/openai-agents-python/multi_agent/
```

## Anti-patterns to avoid

- Unbounded peer-to-peer agent mesh — increases routing ambiguity, context leakage, and debugging cost; replaced by supervisors, explicit workflows, or constrained handoffs.

- Adding agents because a task sounds complex — often increases cost and lowers reliability; replaced by a single-agent baseline and decomposition evidence.

- Passing the entire transcript to every agent — causes context dilution and authority leakage; replaced by filtered handoff contracts and bounded context.

- Treating role labels as sufficient governance — names such as “researcher” or “reviewer” do not define ownership; replaced by explicit inputs, outputs, non-goals, permissions, and acceptance criteria.

- Relying on self-critique without independent evaluation — correlated errors survive repeated model reflection; replaced by test oracles, structured evaluators, and trajectory-level evals.

- Using unrestricted autonomous tools — creates excessive blast radius and prompt-injection exposure; replaced by least-privilege tools, input/output validation, and human approval gates.

- Assuming popularity proves production readiness — high GitHub stars measure attention, not reliability; OpenAI Swarm is explicitly educational and experimental, and AutoGen is now in maintenance mode.

- Persisting conversational memory without state discipline — stale or sensitive context accumulates; replaced by explicit durable artifacts, checkpoint semantics, retention rules, and idempotent resumption.

## Open questions

- Which multi-agent coding patterns improve real repository outcomes after controlling for model, token budget, and compute?
- How should handoff contracts preserve raw evidence without defeating context minimization?
- What evaluation metrics best predict maintainability, security, and reviewer acceptance rather than benchmark patch success?
- When does debate outperform independent sampling or a stronger single-agent verifier?
- How can markdown-only agent libraries validate tool permissions and approval gates without adding a runtime?
- What repository conventions best prevent parallel coding agents from producing conflicting or stale ADRs?
