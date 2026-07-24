---
schema_version: 1
date: 2026-07-24
generator: gpt-5-o3-deep-research
source_count: 22
idea_count: 14
---

## Executive summary
The field is converging on small, specialized agents coordinated by explicit workflows rather than unrestricted agent swarms.
Manager-style orchestration and directed handoffs are more controllable than all-to-all collaboration.
Structured outputs, typed handoffs, tool allowlists, and isolated context are becoming standard production primitives.
Coding systems increasingly separate planning, implementation, testing, review, and security ownership.
Persistent state is being separated from conversational transcripts through checkpoints, stores, and durable artifacts.
Evaluation is shifting from demos toward replayable task suites, trace inspection, regression tests, and cost-aware scoring.
Human approval remains important at side-effect boundaries, especially for code changes and privileged tools.
Repository popularity is a signal of adoption and ecosystem interest, not proof of production effectiveness; star counts are point-in-time snapshots.

## Sources
| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | Anthropic Building Effective AI Agents | blog | https://www.anthropic.com/engineering/building-effective-agents | n/a | primary |
| s2 | Claude Code Custom Subagents | doc | https://code.claude.com/docs/en/sub-agents | n/a | primary |
| s3 | Claude Code Agent Teams | doc | https://code.claude.com/docs/en/agent-teams | n/a | primary |
| s4 | Claude Code Worktrees | doc | https://code.claude.com/docs/en/worktrees | n/a | primary |
| s5 | Claude Agent SDK Subagents | doc | https://code.claude.com/docs/en/agent-sdk/subagents | n/a | primary |
| s6 | OpenAI Agents SDK Agents and Orchestration | doc | https://openai.github.io/openai-agents-python/agents/ | n/a | primary |
| s7 | OpenAI Agents SDK Handoffs | doc | https://openai.github.io/openai-agents-python/handoffs/ | n/a | primary |
| s8 | OpenAI Agents SDK Guardrails | doc | https://openai.github.io/openai-agents-python/guardrails/ | n/a | primary |
| s9 | LangGraph Multi-Agent Handoffs | doc | https://docs.langchain.com/oss/python/langchain/multi-agent/handoffs | n/a | primary |
| s10 | LangGraph Persistence | doc | https://langchain-ai.github.io/langgraph/concepts/time-travel/ | n/a | primary |
| s11 | FoundationAgents MetaGPT | repo | https://github.com/FoundationAgents/MetaGPT | 69.5k | primary |
| s12 | OpenHands | repo | https://github.com/OpenHands/OpenHands | 81.9k | primary |
| s13 | SWE-agent | repo | https://github.com/SWE-agent/SWE-agent | 19.5k | primary |
| s14 | Microsoft AutoGen | repo | https://github.com/microsoft/autogen | 59.9k | primary |
| s15 | CrewAI | repo | https://github.com/crewAIInc/crewAI | 53.6k | primary |
| s16 | LangGraph | repo | https://github.com/langchain-ai/langgraph | 37.4k | primary |
| s17 | OpenAI Swarm | repo | https://github.com/openai/swarm | 21.9k | primary |
| s18 | Claude Agent SDK TypeScript | repo | https://github.com/anthropics/claude-agent-sdk-typescript | 1.6k | primary |
| s19 | MetaGPT: Meta Programming for a Multi-Agent Collaborative Framework | paper | https://arxiv.org/abs/2308.00352 | n/a | primary |
| s20 | Magentic-One: A Generalist Multi-Agent System | paper | https://arxiv.org/abs/2411.04468 | n/a | primary |
| s21 | SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering | paper | https://arxiv.org/abs/2405.15793 | n/a | primary |
| s22 | ReAct: Synergizing Reasoning and Acting in Language Models | paper | https://arxiv.org/abs/2210.03629 | n/a | primary |

## Ideas

### narrow-single-owner-roles: Narrow roles with explicit ownership
```yaml
id: narrow-single-owner-roles
title: Narrow roles with explicit ownership
category: roles
pattern: >
  Effective teams assign each agent a narrow responsibility with a distinct output
  boundary, such as planning, architecture, implementation, testing, or security review.
  The role definition states what the agent owns and what it must not decide.
evidence: [s1, s2, s11, s19] # adoption: reflected across Claude Code, MetaGPT, CrewAI, and Anthropic's workflow patterns.
rationale: Narrow scopes reduce prompt competition, duplicated work, conflicting recommendations, and ambiguous accountability.
applicability_to_owl: 5
applicability_note: >
  The existing specialist roster maps cleanly to this pattern. Role files can make
  ownership, exclusions, entry criteria, and final deliverables explicit without adding runtime behavior.
proposed_change: >
  Add an Ownership and Non-Ownership section to every agent definition, including
  decision rights, forbidden overlap, required inputs, and the single artifact it returns.
risk: >
  Excessive specialization can create handoff overhead, brittle routing, and gaps between
  roles. A role taxonomy can also become stale as the library evolves.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://code.claude.com/docs/en/sub-agents
  - https://arxiv.org/abs/2308.00352
```

### manager-retains-control: Central manager with specialists as bounded capabilities
```yaml
id: manager-retains-control
title: Central manager with bounded specialists
category: orchestration
pattern: >
  A central manager retains responsibility for the user-facing task and invokes specialists
  as bounded capabilities, receiving results rather than surrendering the entire workflow.
  This is distinct from peer handoffs, where control moves permanently to another agent.
evidence: [s1, s6, s9, s20] # adoption: documented by OpenAI and LangChain and used by Magentic-One's orchestrator.
rationale: >
  Central control makes routing, sequencing, stopping conditions, and final synthesis visible.
  It reduces coordination complexity while preserving specialist depth.
applicability_to_owl: 5
applicability_note: >
  The hub-and-spoke topology already embodies this pattern. Prompt conventions can require
  the orchestrator to retain control, delegate only bounded work, and reject unsolicited peer calls.
proposed_change: >
  Add a Hub Control Contract stating that specialists return control to the orchestrator,
  cannot delegate laterally, and may propose follow-up work only as a typed recommendation.
risk: >
  The hub can become a bottleneck, a single point of failure, or an overloaded context holder.
  Central routing can also make genuinely interactive specialist conversations less natural.
confidence: high
references:
  - https://openai.github.io/openai-agents-python/agents/
  - https://docs.langchain.com/oss/python/langchain/multi-agent/handoffs
  - https://arxiv.org/abs/2411.04468
```

### sop-as-executable-contract: Standard operating procedures as workflow contracts
```yaml
id: sop-as-executable-contract
title: Standard operating procedures as workflow contracts
category: orchestration
pattern: >
  Complex work is decomposed into a visible sequence of stages with entry criteria,
  outputs, validation gates, and failure paths. MetaGPT calls this encoding human
  software-company procedures into prompts; Anthropic distinguishes predictable workflows
  from open-ended agents.
evidence: [s1, s11, s19, s20] # adoption: MetaGPT, Anthropic workflows, and Magentic-One all use explicit staged coordination.
rationale: >
  Explicit procedures reduce cascading hallucinations and make intermediate artifacts
  inspectable, replayable, and easier to debug than unconstrained conversation.
applicability_to_owl: 5
applicability_note: >
  Existing mandatory delegation and ADR governance can be formalized as stage contracts
  linking strategist, architect, designer, builder, guardian, sentinel, challenger, and chronicler.
proposed_change: >
  Define a canonical lifecycle template with stage purpose, prerequisite artifact,
  success condition, rejection condition, and required ADR outcome for every workflow.
risk: >
  Rigid procedures can fail on novel tasks, create unnecessary latency, and encourage agents
  to satisfy checklist fields without improving the underlying result.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://github.com/FoundationAgents/MetaGPT
  - https://arxiv.org/abs/2308.00352
```

### markdown-frontmatter-config: Declarative agent configuration
```yaml
id: markdown-frontmatter-config
title: Declarative agent configuration
category: tooling
pattern: >
  Agent definitions combine machine-readable frontmatter with human-readable instructions.
  Common fields include name, description, model, tools, permissions, turn limits, skills,
  memory scope, and isolation policy.
evidence: [s2, s5, s18] # adoption: Claude Code directly standardizes Markdown plus YAML frontmatter for project agents.
rationale: >
  Declarative metadata makes capabilities auditable, supports routing, and separates stable
  policy from task-specific prose without requiring a runtime framework.
applicability_to_owl: 5
applicability_note: >
  The markdown-only library can preserve YAML frontmatter while adding a stable schema for
  role, inputs, outputs, delegation rights, tool scope, stop conditions, and ADR requirements.
proposed_change: >
  Standardize frontmatter fields for every agent and validate that names, descriptions,
  tools, delegation permissions, and output contracts are present and unique.
risk: >
  Frontmatter can become configuration sprawl, and unsupported or ambiguously interpreted
  fields may create false guarantees about enforcement.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://code.claude.com/docs/en/agent-sdk/subagents
  - https://github.com/anthropics/claude-agent-sdk-typescript
```

### scope-based-agent-library: Scope-aware folder organization
```yaml
id: scope-based-agent-library
title: Scope-aware agent library organization
category: files
pattern: >
  Agent definitions are organized by scope: organization-wide defaults, user-level agents,
  project agents, plugins, and task-specific skills. Project-local definitions are versioned
  with the repository, while shared definitions live at broader scopes.
evidence: [s2, s3, s5, s12] # adoption: Claude Code documents explicit scopes; OpenHands exposes agents, skills, and tests as repository structure.
rationale: >
  Scope boundaries clarify precedence, ownership, portability, and review responsibility.
  They also prevent project-specific assumptions from silently becoming global behavior.
applicability_to_owl: 5
applicability_note: >
  The library can distinguish core agents, reusable conventions, project overlays, and
  task skills through directories and naming rules while remaining entirely static.
proposed_change: >
  Establish stable directories for agents, commands, shared contracts, ADR templates,
  examples, and validation fixtures, with precedence documented in a top-level manifest.
risk: >
  Multiple scopes create precedence bugs, duplicate names, and maintenance burden.
  A folder hierarchy can also imply isolation that the host platform does not enforce.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://code.claude.com/docs/en/agent-teams
  - https://github.com/OpenHands/OpenHands
```

### typed-minimal-handoffs: Minimal typed handoff artifacts
```yaml
id: typed-minimal-handoffs
title: Minimal typed handoff artifacts
category: communication
pattern: >
  Handoffs carry a compact structured payload rather than an unrestricted transcript.
  Useful fields include objective, assumptions, evidence, unresolved questions, decisions,
  rejected alternatives, constraints, artifact references, and acceptance criteria.
evidence: [s7, s9, s11, s19] # adoption: OpenAI supports typed handoff inputs and filters; MetaGPT uses standardized intermediate artifacts.
rationale: >
  Typed handoffs preserve the information needed for the next decision while reducing
  context pollution, accidental authority transfer, and repeated exploration.
applicability_to_owl: 5
applicability_note: >
  N-1 context can be represented as a required Handoff Contract section in each Markdown
  agent output, with a stable schema and explicit uncertainty fields.
proposed_change: >
  Define one reusable Handoff Contract containing objective, completed work, evidence,
  assumptions, open risks, requested decision, and next-agent acceptance criteria.
risk: >
  Overly small payloads can omit important nuance; overly large payloads recreate the
  transcript problem. Schema evolution can also break older handoffs.
confidence: high
references:
  - https://openai.github.io/openai-agents-python/handoffs/
  - https://docs.langchain.com/oss/python/langchain/multi-agent/handoffs
  - https://arxiv.org/abs/2308.00352
```

### context-isolation-and-summary: Fresh context per specialist
```yaml
id: context-isolation-and-summary
title: Fresh context per specialist
category: context
pattern: >
  A specialist receives only the task-specific brief and relevant artifacts, works in an
  isolated context, and returns a summary to the parent. The parent does not automatically
  forward every exploration trace, tool result, or intermediate transcript.
evidence: [s1, s2, s5, s7] # adoption: explicitly documented by Claude Code, Claude Agent SDK, OpenAI handoff filters, and Anthropic.
rationale: >
  Isolation limits token growth, reduces irrelevant anchoring, and lets each role reason
  from a clean problem representation.
applicability_to_owl: 5
applicability_note: >
  The existing N-1 rule can be strengthened with a context budget, mandatory summary format,
  and explicit artifact references for information that must survive beyond one handoff.
proposed_change: >
  Add a Context Budget and Transmission Policy section specifying allowed inputs,
  excluded transcript material, summary length, and artifact-reference rules.
risk: >
  Aggressive filtering can hide contradictory evidence or cause the next agent to trust
  an incomplete summary. Summary quality becomes a critical failure point.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://code.claude.com/docs/en/agent-sdk/subagents
  - https://openai.github.io/openai-agents-python/handoffs/
```

### durable-state-separated-from-transcript: Separate working state and long-term memory
```yaml
id: durable-state-separated-from-transcript
title: Separate working state from long-term memory
category: memory
pattern: >
  Short-term execution state is separated from durable cross-run knowledge. Checkpoints
  preserve resumable thread state, while a distinct store holds durable facts, preferences,
  decisions, or learned procedures.
evidence: [s10, s6, s12] # adoption: LangGraph formalizes checkpoint versus store; OpenAI exposes sessions and resumable state; OpenHands maintains durable project artifacts.
rationale: >
  Separation improves retention control, replayability, privacy, and pruning. It prevents
  every historical interaction from becoming permanent prompt context.
applicability_to_owl: 4
applicability_note: >
  Without runtime storage, the-owl can distinguish ephemeral handoff text from durable
  repository artifacts such as ADRs, decision logs, evaluation fixtures, and policy files.
proposed_change: >
  Define durable-memory classes in Markdown and JSON conventions: ADR, invariant,
  rejected alternative, learned heuristic, evaluation case, and project fact.
risk: >
  Persistent memory can preserve incorrect or sensitive information and may become stale.
  Static artifacts also require deliberate maintenance because no runtime policy can prune them.
confidence: high
references:
  - https://langchain-ai.github.io/langgraph/concepts/time-travel/
  - https://openai.github.io/openai-agents-python/running_agents/
  - https://github.com/OpenHands/OpenHands
```

### evidence-action-observation-loop: Evidence-grounded action loops
```yaml
id: evidence-action-observation-loop
title: Evidence-grounded action loops
category: context
pattern: >
  Agents alternate between explicit reasoning, an externally observable action or tool use,
  and an observation that updates the working hypothesis. The loop records evidence and
  distinguishes observations from assumptions.
evidence: [s1, s13, s21, s22] # adoption: ReAct established the pattern; SWE-agent applies interface-centered loops to software engineering.
rationale: >
  External observations constrain hallucination, support recovery from failed assumptions,
  and make the trajectory more interpretable than unsupported final answers.
applicability_to_owl: 5
applicability_note: >
  Each agent can use an Evidence Log section separating facts, interpretations, actions,
  results, and confidence without adding execution code.
proposed_change: >
  Add an Evidence Log convention requiring every material claim to identify its source,
  observation status, confidence, and the next falsifiable check.
risk: >
  Excessive logging increases token cost and can encourage performative reasoning.
  Tool outputs may themselves be malicious, incomplete, or misleading.
confidence: high
references:
  - https://arxiv.org/abs/2210.03629
  - https://arxiv.org/abs/2405.15793
  - https://github.com/SWE-agent/SWE-agent
```

### evaluator-optimizer-with-replay: Evaluator and replay loops
```yaml
id: evaluator-optimizer-with-replay
title: Evaluator and replay loops
category: self-improvement
pattern: >
  A producer generates an artifact and a separate evaluator scores it against explicit
  criteria. Failed cases are replayed, feedback is classified, and improvements are
  measured against a fixed regression set rather than accepted from anecdotal success.
evidence: [s1, s6, s10, s14, s20, s21] # adoption: Anthropic, OpenAI, LangGraph, AutoGenBench, Magentic-One, and SWE-agent emphasize evaluation or replay.
rationale: >
  Separation of generation and evaluation exposes regressions and turns qualitative
  feedback into measurable changes in accuracy, completeness, safety, latency, and cost.
applicability_to_owl: 5
applicability_note: >
  The library can encode evaluator roles, scorecards, replay fixtures, and ADR requirements
  for changes to prompts or delegation topology.
proposed_change: >
  Add an Evaluation Contract requiring baseline cases, rubric dimensions, failure labels,
  before-and-after results, and an ADR for any behavior-changing prompt edit.
risk: >
  Evaluators can share the producer's blind spots, optimize superficial rubric compliance,
  or create expensive feedback loops. Benchmarks may not represent real projects.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://openai.github.io/openai-agents-python/multi_agent/
  - https://arxiv.org/abs/2411.04468
```

### human-approval-at-side-effect-boundaries: Approval before consequential actions
```yaml
id: human-approval-at-side-effect-boundaries
title: Approval before consequential actions
category: safety
pattern: >
  Agents may investigate, plan, draft, and validate autonomously, but actions with
  irreversible, privileged, external, or production impact pause for human approval.
  Approval state and the exact proposed change are explicit parts of the run state.
evidence: [s1, s3, s6, s8, s20] # adoption: Anthropic, Claude Code, OpenAI guardrails, and Magentic-One emphasize controlled execution and side-effect containment.
rationale: >
  Human review limits blast radius when model confidence is poorly calibrated or tools
  expose capabilities broader than the task requires.
applicability_to_owl: 5
applicability_note: >
  Existing hard-stops can be made uniform by requiring every mutating proposal to end in
  a reviewable approval artifact and forbidding agents from treating approval as implicit.
proposed_change: >
  Standardize an Approval Gate section containing proposed action, affected scope,
  reversibility, evidence, residual risk, approver identity, and explicit disposition.
risk: >
  Approval gates reduce automation and can create rubber-stamping or operational bottlenecks.
  Humans may approve unsafe actions when summaries omit uncertainty.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://code.claude.com/docs/en/agent-teams
  - https://openai.github.io/openai-agents-python/guardrails/
```

### tool-allowlists-and-provenance: Least-privilege tools and untrusted-data boundaries
```yaml
id: tool-allowlists-and-provenance
title: Least-privilege tools and provenance boundaries
category: safety
pattern: >
  Each agent receives only the tools needed for its role, with explicit allowlists,
  denied capabilities, input validation, and provenance labels for untrusted content.
  Tool results are treated as data rather than instructions.
evidence: [s2, s5, s8, s14] # adoption: Claude Code frontmatter, OpenAI tool guardrails, and AutoGen security guidance support scoped capabilities.
rationale: >
  Capability reduction limits accidental side effects and narrows prompt-injection paths.
  Provenance helps agents distinguish project policy from repository text, web content, and tool output.
applicability_to_owl: 5
applicability_note: >
  Markdown definitions can declare allowed tools, forbidden tools, trusted inputs,
  untrusted inputs, secret-handling rules, and escalation conditions.
proposed_change: >
  Add Tool Scope and Input Provenance sections to every agent, with a default-deny
  convention and explicit rules for handling instructions found in external artifacts.
risk: >
  Strict allowlists can block legitimate work and encourage unsafe workarounds.
  Provenance labels are only effective if the host runtime preserves them accurately.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://openai.github.io/openai-agents-python/guardrails/
  - https://github.com/microsoft/autogen
```

### isolated-workspaces-for-parallel-coding: File ownership and workspace isolation
```yaml
id: isolated-workspaces-for-parallel-coding
title: File ownership and workspace isolation
category: tooling
pattern: >
  Parallel coding agents work in separate worktrees or otherwise isolated workspaces,
  with explicit file ownership and a controlled merge or review boundary. Shared task
  lists coordinate work, but agents do not concurrently mutate the same files.
evidence: [s3, s4, s12, s13] # adoption: Claude Code documents worktree isolation; OpenHands and SWE-agent are coding-focused systems with isolated execution environments.
rationale: >
  Isolation prevents conflicting edits, makes rollback easier, and preserves a clear
  mapping between an agent's work and its reviewable artifact.
applicability_to_owl: 2
applicability_note: >
  The markdown-only library cannot provide workspace isolation, but it can encode file
  ownership, no-overlap rules, merge responsibility, and a prohibition on concurrent edits.
proposed_change: >
  Add a File Ownership Contract to implementation workflows specifying owned paths,
  read-only paths, conflict handling, and the single integration authority.
risk: >
  Worktrees and merge boundaries add operational complexity and can fragment context.
  Static ownership rules cannot enforce isolation without host support.
confidence: high
references:
  - https://code.claude.com/docs/en/worktrees
  - https://code.claude.com/docs/en/agent-teams
  - https://github.com/OpenHands/OpenHands
```

### deterministic-workflow-before-autonomous-swarm: Prefer the simplest sufficient topology
```yaml
id: deterministic-workflow-before-autonomous-swarm
title: Prefer the simplest sufficient topology
category: orchestration
pattern: >
  Systems begin with a single agent or deterministic pipeline, add routing or parallel
  specialists only when the task requires distinct capabilities, and reserve autonomous
  loops or swarms for genuinely open-ended work.
evidence: [s1, s6, s9, s17] # adoption: Anthropic explicitly distinguishes workflows from agents; OpenAI and LangGraph document multiple topology choices; Swarm labels itself educational.
rationale: >
  Simpler topologies reduce latency, token cost, coordination failures, and debugging
  difficulty while preserving predictable control flow.
applicability_to_owl: 5
applicability_note: >
  The-owl can define topology selection as a planning decision recorded in an ADR,
  with hub-and-spoke as the default and parallel or recursive delegation requiring justification.
proposed_change: >
  Add a Topology Decision section requiring task characteristics, expected coordination
  cost, failure containment, and an ADR whenever the default hub-and-spoke shape changes.
risk: >
  Overly conservative topology selection can underuse parallelism and specialist diversity.
  A deterministic pipeline may be brittle when requirements are ambiguous or evolving.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://openai.github.io/openai-agents-python/agents/
  - https://github.com/openai/swarm
```

### directed-handoff-graph: Directed communication instead of free mesh
```yaml
id: directed-handoff-graph
title: Directed communication instead of free mesh
category: communication
pattern: >
  Communication paths are explicit and directional. A coordinator decides which specialist
  receives work, while peer-to-peer messaging is limited to cases where direct collaboration
  is necessary and its recipient, purpose, and return condition are known.
evidence: [s3, s7, s9, s14] # adoption: Claude Code teams, OpenAI handoffs, LangGraph handoffs, and AutoGen expose directed coordination primitives.
rationale: >
  Directed graphs reduce routing ambiguity, cyclic delegation, broadcast noise, and
  authority confusion compared with unconstrained peer meshes.
applicability_to_owl: 5
applicability_note: >
  The existing rule that specialists never call one another is a strong form of this
  pattern. It can be documented as a topology invariant with explicit exception handling.
proposed_change: >
  Add a Delegation Graph section naming permitted caller-to-agent edges, forbidden cycles,
  escalation paths, and the required return artifact for each edge.
risk: >
  Directed graphs can overconstrain collaboration and make the orchestrator a bottleneck.
  Incorrect edge definitions can silently prevent the right specialist from being reached.
confidence: high
references:
  - https://code.claude.com/docs/en/agent-teams
  - https://openai.github.io/openai-agents-python/handoffs/
  - https://docs.langchain.com/oss/python/langchain/multi-agent/handoffs
```

### adr-backed-prompt-evolution: Govern prompt changes as versioned engineering changes
```yaml
id: adr-backed-prompt-evolution
title: Govern prompt changes as versioned engineering changes
category: self-improvement
pattern: >
  Agent prompts, role boundaries, routing rules, and handoff schemas are treated as
  production behavior. Changes are reviewed, versioned, evaluated against regression cases,
  and accompanied by a rationale and rollback path.
evidence: [s1, s2, s10, s19, s20] # adoption: production guidance emphasizes evaluation; agent frameworks expose versioned configurations and replayable state.
rationale: >
  Prompt behavior is a software dependency even when the library has no executable runtime.
  Versioned decisions make regressions attributable and preserve institutional knowledge.
applicability_to_owl: 5
applicability_note: >
  The existing mandatory ADR rule directly supports this pattern and can include prompt
  diffs, changed delegation behavior, evaluation results, and compatibility notes.
proposed_change: >
  Extend the ADR template with prompt surface, affected agents, topology impact,
  handoff-schema impact, evaluation evidence, and rollback version.
risk: >
  Excessive process can slow useful iteration and encourage documentation without meaningful
  testing. Prompt-only changes may still behave differently across models or host versions.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://code.claude.com/docs/en/sub-agents
  - https://arxiv.org/abs/2411.04468
```

## Anti-patterns to avoid
- Unrestricted all-to-all agent meshes — coordination cost, cycles, and authority ambiguity grow rapidly; directed hub-and-spoke or explicit graphs are replacing them.
- Giant generalist prompts with every tool and responsibility — they increase context load and reduce accountability; narrow specialists with scoped tools are preferred.
- Passing complete transcripts between every agent — it increases cost and anchoring; compact typed handoffs and isolated contexts are replacing it.
- Treating role labels as sufficient decomposition — titles without ownership, exclusions, and acceptance criteria create overlapping work.
- Autonomous mutation without approval or sandboxing — production systems increasingly place human approval, tool guardrails, and isolation at side-effect boundaries.
- Unbounded self-improvement from unconstrained feedback — replay suites, fixed rubrics, regression cases, and versioned changes provide stronger evidence.
- Parallel agents sharing one mutable working tree — file ownership, worktrees, and controlled integration reduce edit collisions.
- Framework-first architecture — primary guidance increasingly favors choosing the simplest workflow that meets the task before introducing a multi-agent runtime.

## Open questions
- How much multi-agent improvement remains after controlling for total token budget, model calls, and evaluator compute?
- Which handoff schemas preserve the most decision-relevant information under strict context budgets?
- When does a specialist improve coding reliability enough to justify its coordination and latency cost?
- How should prompt-injection provenance be represented when repository files, tool results, and agent-generated artifacts are mixed?
- What evaluation methods best measure maintainability, security, and architectural coherence rather than only task completion?
- How can static Markdown conventions provide meaningful guarantees when enforcement depends on Claude Code or the Agent SDK host?
- What are reliable criteria for promoting a learned heuristic into durable project policy?
- How should teams handle disagreement between independent evaluators without adding an unbounded debate loop?