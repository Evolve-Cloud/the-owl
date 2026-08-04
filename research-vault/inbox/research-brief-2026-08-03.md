---
schema_version: 1
date: 2026-08-03
generator: gpt-5
source_count: 13
idea_count: 10
---

## Executive summary

The strongest shift is away from open-ended “agent swarms” toward explicit, bounded workflows with specialized agents and observable handoffs.  
Central-manager/subagent designs remain the most compatible pattern for reliability, context isolation, and governance; free mesh collaboration remains useful mainly for exploratory work.  
Context engineering—not agent count—is the main determinant of multi-agent quality: specialists should receive task-relevant artifacts rather than a growing shared transcript.  
Role specialization is increasingly expressed through narrowly scoped instructions, tools, permissions, output schemas, and termination conditions.  
Structured handoffs and intermediate artifacts are more credible than natural-language-only delegation because they make review, replay, and evaluation possible.  
Evaluation is moving from single showcase runs toward executable task suites, trace review, and regression gates; benchmark scores alone remain weak evidence of operational quality.  
Human approval, tool-level constraints, and explicit stop conditions are becoming baseline controls for systems that can modify code or act externally.  
For the-owl, the highest-value changes are conventions and prompt structures that formalize existing hub-and-spoke governance without adding runtime machinery.

## Sources

| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | Anthropic: Building effective agents | blog | https://www.anthropic.com/engineering/building-effective-agents | n/a | primary |
| s2 | Claude Code: Create custom subagents | doc | https://code.claude.com/docs/en/sub-agents | n/a | primary |
| s3 | LangGraph: Multi-agent concepts | doc | https://docs.langchain.com/oss/python/langchain/multi-agent | n/a | primary |
| s4 | langchain-ai/langgraph | repo | https://github.com/langchain-ai/langgraph | 38,779 | primary |
| s5 | crewAIInc/crewAI | repo | https://github.com/crewAIInc/crewAI | 53.6k | primary |
| s6 | microsoft/autogen | repo | https://github.com/microsoft/autogen | 60,191 | primary |
| s7 | openai/openai-agents-python | repo | https://github.com/openai/openai-agents-python | 28,360 | primary |
| s8 | FoundationAgents/MetaGPT | repo | https://github.com/FoundationAgents/MetaGPT | 69.7k | primary |
| s9 | OpenAI Agents SDK: agents and orchestration | doc | https://openai.github.io/openai-agents-python/agents/ | n/a | primary |
| s10 | OpenAI Agents SDK: guardrails | doc | https://openai.github.io/openai-agents-python/guardrails/ | n/a | primary |
| s11 | AutoGen: teams and termination | doc | https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/teams.html | n/a | primary |
| s12 | MetaGPT: Meta Programming for a Multi-Agent Collaborative Framework | paper | https://arxiv.org/abs/2308.00352 | n/a | primary |
| s13 | SWE-bench: Can Language Models Resolve Real-World GitHub Issues? | paper | https://arxiv.org/abs/2310.06770 | n/a | primary |

## Ideas

### bounded-role-charters: Narrow, non-overlapping specialist charters

```yaml
id: bounded-role-charters
title: Narrow, non-overlapping specialist charters
category: roles
pattern: >
  Define each specialist by a distinct decision boundary, inputs, permitted work, required
  outputs, and explicit exclusions. The coordinator owns routing and integration; specialists
  produce an artifact for one bounded concern rather than independently solving the whole task.
evidence: [s1, s3, s6, s8] # Multiple major frameworks and MetaGPT use specialized roles; LangGraph recommends multi-agent primarily for distinct tools or large specialist context.
rationale: >
  Specialization reduces tool-choice ambiguity and prompt overload while making responsibility
  for omissions reviewable. It is more reliable than role names alone because the boundary is
  defined in terms of deliverables and prohibitions.
applicability_to_owl: 5
applicability_note: >
  This maps directly to markdown agent contracts: preserve the current specialist roster, state
  each agent's exclusive decision domain, and state what it must hand back instead of performing.
proposed_change: >
  Add a Role Boundary section to every agent file with Owns, Must Not Do, Required Inputs,
  Required Outputs, and Escalation Conditions fields.
risk: >
  Excessive decomposition increases handoffs, latency, and loss of global understanding; roles
  should be split only where the artifact or tool scope is materially different.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://github.com/FoundationAgents/MetaGPT
```

### repository-agent-manifest: Declarative agent manifests with scoped capabilities

```yaml
id: repository-agent-manifest
title: Declarative agent manifests with scoped capabilities
category: files
pattern: >
  Store one agent definition per markdown file with machine-readable frontmatter and a
  human-readable prompt body. Frontmatter declares description, model or effort preference,
  allowed tools, denied tools, permissions, and optional lifecycle constraints; the body defines
  the operating procedure and output contract.
evidence: [s2, s7, s9] # Claude Code subagents and the OpenAI Agents SDK expose instructions, tools, handoffs, guardrails, and structured outputs as first-class configuration.
rationale: >
  Separating stable configuration from operating instructions makes capability boundaries visible,
  reviewable, and portable. Tool scope is a stronger control than an instruction merely asking an
  agent not to act.
applicability_to_owl: 5
applicability_note: >
  The library already uses markdown, YAML, and JSON prompts, so this requires only a normalized
  frontmatter schema and consistent section ordering.
proposed_change: >
  Standardize agent YAML frontmatter with name, description, tools, disallowedTools,
  permissionMode, inputs, outputs, escalation, and version fields; retain role instructions below it.
risk: >
  Configuration schemas can become decorative if Claude Code does not enforce a field, and overly
  restrictive tool declarations can prevent valid investigation or verification work.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://openai.github.io/openai-agents-python/agents/
  - https://github.com/openai/openai-agents-python
```

### structured-handoff-contracts: Typed artifact handoffs instead of conversational delegation

```yaml
id: structured-handoff-contracts
title: Typed artifact handoffs instead of conversational delegation
category: communication
pattern: >
  Require every delegation to end in a compact handoff artifact with task status, decisions,
  evidence, assumptions, unresolved risks, and the exact next-owner question. The receiving
  specialist consumes the artifact rather than an unbounded conversation transcript.
evidence: [s3, s7, s9, s12] # Agent handoffs are a core SDK primitive; MetaGPT operationalizes intermediate SOP artifacts rather than relying solely on chat.
rationale: >
  A stable contract reduces information loss, enables targeted review, and makes a workflow
  replayable. It also prevents downstream agents from treating prior prose as unrestricted
  authority or silently re-litigating settled decisions.
applicability_to_owl: 5
applicability_note: >
  This reinforces the existing N-1 context rule: the previous output becomes a normalized
  markdown or YAML handoff rather than arbitrary accumulated context.
proposed_change: >
  Add a Handoff Contract section to every agent file requiring summary, artifact links,
  decisions, evidence, assumptions, risks, ADR impact, and next-agent prompt.
risk: >
  Rigid schemas can cause agents to optimize for form completion and omit nuance; allow an
  evidence appendix and a clear insufficient-information status.
confidence: high
references:
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://openai.github.io/openai-agents-python/agents/
  - https://arxiv.org/abs/2308.00352
```

### hub-spoke-return-control: Central coordinator with mandatory return control

```yaml
id: hub-spoke-return-control
title: Central coordinator with mandatory return control
category: orchestration
pattern: >
  Use a manager or orchestrator as the only routing authority. Specialists are invoked as bounded
  subagents, return their artifact to the manager, and do not delegate directly to peers; any
  additional work is requested by the manager through a new scoped handoff.
evidence: [s1, s3, s4, s7, s9] # LangGraph explicitly documents subagents as a main-agent-controlled pattern and notes that its extra call buys centralized control.
rationale: >
  Centralized routing preserves governance, creates a single audit point, and keeps specialist
  context isolated. It is especially suitable where task order, approval gates, and ADR creation
  are mandatory.
applicability_to_owl: 5
applicability_note: >
  This is directly aligned with the-owl's existing topology and can be made explicit in the
  orchestrator prompt and each specialist's hard-stop section.
proposed_change: >
  Add a mandatory Return Control rule to all specialist prompts: no peer delegation, no
  self-selected next agent, and a required proposed-next-step field for the orchestrator.
risk: >
  The coordinator can become a bottleneck and may misroute nuanced work; this trades some
  parallelism and adaptability for predictability and control.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://langchain-ai.github.io/langgraphjs/reference/modules/langgraph-supervisor.html
```

### stage-gated-sop-pipeline: Deterministic stage gates for known engineering workflows

```yaml
id: stage-gated-sop-pipeline
title: Deterministic stage gates for known engineering workflows
category: orchestration
pattern: >
  Express recurring delivery work as an explicit sequence of stages with entry criteria,
  required artifacts, review questions, and exit criteria. Reserve adaptive agentic loops for
  bounded investigation or evaluation inside a stage, rather than using free-form routing for the
  entire lifecycle.
evidence: [s1, s11, s12] # Anthropic distinguishes predictable workflows from autonomous agents; MetaGPT encodes SOPs as prompt sequences; AutoGen stresses termination and scaffolding needs.
rationale: >
  Engineering work has recurring dependencies—requirements before architecture, architecture
  before implementation, and verification before release. Gates make these dependencies visible
  and create clear places for governance and ADR review.
applicability_to_owl: 5
applicability_note: >
  Existing strategist-to-chronicler sequencing can be represented as a pipeline index document,
  with each agent's markdown defining its entry and exit artifact.
proposed_change: >
  Create a workflow.md containing stage order, mandatory agents, required handoff artifact types,
  hard-stop conditions, and the ADR checkpoint for every change.
risk: >
  A fixed pipeline can be slow or inappropriate for small edits and exploratory incidents; permit
  explicitly documented short paths rather than silently bypassing stages.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/teams.html
  - https://arxiv.org/abs/2308.00352
```

### scoped-context-artifacts: Minimal, task-shaped context rather than shared history

```yaml
id: scoped-context-artifacts
title: Minimal, task-shaped context rather than shared history
category: context
pattern: >
  Pass each specialist only the task brief, its role contract, the immediate predecessor artifact,
  and explicitly selected evidence or repository references. Avoid broadcasting full histories
  and avoid making every agent a persistent participant in a shared conversation.
evidence: [s1, s3, s6] # LangGraph identifies context engineering as the center of multi-agent design and contrasts isolated subagents with shared-context patterns; AutoGen documents bounded contexts.
rationale: >
  Context isolation reduces irrelevant-token cost, distraction, leakage between concerns, and
  propagation of speculative reasoning. It also makes the evidence an agent used inspectable.
applicability_to_owl: 5
applicability_note: >
  This preserves the-owl's N-1 scoping and turns it into an enforceable prompt convention:
  downstream agents receive an artifact plus explicitly listed references, not prior chat history.
proposed_change: >
  Add a Context Budget section to each agent prompt with Allowed Context, Forbidden Context,
  Required Evidence, and Compression Rules for the returned artifact.
risk: >
  Over-pruning can hide a critical earlier constraint or decision; the handoff must carry
  sufficient provenance and a mechanism to request a specific missing artifact through the hub.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/agents.html
```

### append-only-decision-memory: ADR-backed long-term memory

```yaml
id: append-only-decision-memory
title: ADR-backed long-term memory
category: memory
pattern: >
  Persist durable decisions, invariants, accepted risks, and evaluation outcomes as concise,
  versioned records rather than treating chat history as memory. Retrieve only records relevant to
  the current task, and require new changes to supersede or reference the applicable prior record.
evidence: [s3, s4, s7, s13] # Production frameworks distinguish working context from persistent state; SWE-bench demonstrates that repository-level work requires cross-file and historical understanding.
rationale: >
  Durable records survive context truncation and make prior judgment inspectable. They prevent
  repeated debate and give agents a safer basis for explaining why a constraint exists.
applicability_to_owl: 5
applicability_note: >
  The existing ADR requirement is already the correct markdown-only memory primitive; the missing
  element is a consistent retrieval and supersession convention.
proposed_change: >
  Add an ADR Index with status and supersedes fields, plus an agent prompt rule requiring relevant
  ADRs to be cited in design, implementation, review, and changelog handoffs.
risk: >
  An ever-growing ADR corpus can become stale and costly to consult; indexing, status labels, and
  explicit supersession are necessary to avoid fossilized guidance.
confidence: high
references:
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://github.com/langchain-ai/langgraph
  - https://arxiv.org/abs/2310.06770
```

### eval-backed-library-evolution: Change agent prompts through replayable evaluations

```yaml
id: eval-backed-library-evolution
title: Change agent prompts through replayable evaluations
category: self-improvement
pattern: >
  Treat agent-library changes as hypotheses tested against a fixed corpus of representative tasks,
  with scored artifacts and qualitative trace review. Record failures by stage and role, compare
  the baseline and candidate prompt set, and promote only changes that improve defined criteria.
evidence: [s1, s7, s13] # Anthropic recommends simple, measurable patterns before complexity; the OpenAI Agents SDK includes tracing and evaluation support; SWE-bench establishes executable issue-resolution evaluation.
rationale: >
  Prompt and workflow changes can easily improve a demo while harming reliability elsewhere.
  Regression evaluation turns “agent improvement” from anecdote into an evidence-backed decision.
applicability_to_owl: 4
applicability_note: >
  A markdown-only library can store eval cases, expected artifacts, rubrics, and scorecards even
  though execution occurs inside Claude Code or its SDK rather than a new runtime.
proposed_change: >
  Add an evals/ directory containing scenario briefs, expected handoff properties, scoring rubrics,
  baseline results, and a mandatory evaluation summary in the ADR for agent-library changes.
risk: >
  Small static suites encourage overfitting and benchmark contamination; include varied,
  periodically refreshed real tasks and retain human review of high-impact failures.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://openai.github.io/openai-agents-python/
  - https://arxiv.org/abs/2310.06770
```

### layered-guardrails-and-approval: Per-stage safety boundaries and human approval gates

```yaml
id: layered-guardrails-and-approval
title: Per-stage safety boundaries and human approval gates
category: safety
pattern: >
  Apply safety constraints at the task input, specialist instruction, tool permission, handoff,
  and final output layers. Sensitive actions or irreversible changes require an explicit human
  approval artifact; untrusted content is treated as data, never as authority to override role or
  governance instructions.
evidence: [s2, s7, s9, s10, s11] # Claude Code supports allowed and disallowed tools and permissions; OpenAI distinguishes input, output, and tool guardrails and supports run-wide human approval.
rationale: >
  Prompt-only safety controls are vulnerable to accidental scope drift and instruction injection.
  Layered checks limit blast radius and make approval state explicit rather than inferred from prose.
applicability_to_owl: 5
applicability_note: >
  This can be represented through frontmatter tool scopes, prompt hard-stops, standardized approval
  handoffs, and sentinel review criteria without introducing a runtime.
proposed_change: >
  Add a Safety Contract section to every agent with trusted inputs, untrusted-input handling,
  forbidden actions, required approval conditions, and escalation to sentinel or the orchestrator.
risk: >
  Multiple controls can create duplicated review and false confidence; markdown conventions cannot
  enforce tool restrictions unless paired with Claude Code's actual permission configuration.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://openai.github.io/openai-agents-python/guardrails/
  - https://openai.github.io/openai-agents-python/human_in_the_loop/
```

### deterministic-termination-budgets: Explicit completion, escalation, and budget conditions

```yaml
id: deterministic-termination-budgets
title: Explicit completion, escalation, and budget conditions
category: safety
pattern: >
  Define when a specialist is complete, when it must return insufficient-information status, and
  when a workflow must stop for review. Use bounded turns, bounded scope, and explicit acceptance
  criteria rather than relying on an agent to decide when continued discussion is useful.
evidence: [s2, s6, s11] # Claude Code supports maxTurns; AutoGen documents message, token, timeout, handoff, and external termination conditions.
rationale: >
  Multi-agent systems otherwise amplify loops, repeated critique, and escalating context costs.
  Termination conditions also make failures observable and distinguish blocked work from unfinished work.
applicability_to_owl: 5
applicability_note: >
  Markdown prompts can require a final status selected from complete, blocked, needs-approval, or
  needs-research, with a clear stop-and-return rule for every specialist.
proposed_change: >
  Add Completion Contract and Stop Conditions sections to every agent file, including acceptance
  criteria, maximum scope, blocked-state output, and mandatory return to the orchestrator.
risk: >
  Hard bounds can terminate difficult work prematurely; escalation paths must preserve the option
  for the orchestrator to authorize a new, separately scoped investigation.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/termination.html
  - https://github.com/microsoft/autogen
```

## Anti-patterns to avoid

- Free-form peer-to-peer swarms for governed coding work — shared conversation and unconstrained routing make scope, provenance, and termination difficult to control; manager-led subagents or explicit pipelines replace them.
- Role labels without exclusive deliverables — “architect,” “reviewer,” and “engineer” overlap unless each has inputs, outputs, exclusions, and escalation rules.
- Broadcasting the complete transcript to every agent — it increases token cost, distraction, and leakage of speculative reasoning; scoped artifacts and selected evidence replace it.
- Treating a long system prompt as the only safety control — prompts alone do not constrain tools or approvals; capability scope, hard stops, and human gates are stronger.
- Letting specialists choose and invoke peer specialists — this bypasses the hub's governance and obscures accountability; specialists return a proposed next step to the orchestrator.
- Using benchmark wins or one successful demo as proof of improvement — static benchmarks can be contaminated or unrepresentative; replay suites, task-specific rubrics, and trace review replace anecdotal evaluation.
- Permanent memory as accumulated chat logs — it is noisy, hard to retrieve, and difficult to audit; concise ADRs, indexed decisions, and supersession records replace it.

## Open questions

- Which existing the-owl workflows show enough repeated failure or context pressure to justify a new specialist rather than a stronger artifact contract?
- What minimal rubric can score strategist, architect, builder, guardian, and sentinel handoffs consistently without rewarding verbosity?
- Which Claude Code frontmatter fields are enforced in the intended deployment surface, and which remain documentation-only conventions?
- How should ADR retrieval be scoped so durable decisions are found without violating the library's N-1 context-minimal principle?