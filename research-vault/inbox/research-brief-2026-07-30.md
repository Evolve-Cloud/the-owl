---
schema_version: 1
date: 2026-07-30
generator: gpt-5
source_count: 14
idea_count: 10
---

## Executive summary

The strongest convergent pattern remains a central coordinator with narrowly scoped specialists, rather than a free-form agent mesh.  
Recent primary guidance is more explicit that multi-agent systems are useful chiefly for separable work, context isolation, or parallelism; most coding tasks do not automatically qualify.  
Typed or structured handoffs, bounded context transfer, and explicit stop conditions are becoming standard reliability mechanisms.  
Markdown/YAML agent definitions with role prompts, tool allowlists, and controlled delegation map directly to Claude Code’s supported model.  
The field is shifting from “more agents” toward measurable task decomposition, artifact-backed continuity, and evaluations of full trajectories.  
Autonomous self-improvement remains promising but is not yet strong evidence for unsupervised prompt mutation in production.  
Human approval, independent review, and least-privilege tool scope remain necessary because agent-level input/output checks alone do not cover delegated actions.

## Sources

| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | OpenHands/OpenHands | repo | https://github.com/OpenHands/OpenHands | 68.9k | primary |
| s2 | anthropics/claude-code | repo | https://github.com/anthropics/claude-code | 132k | primary |
| s3 | microsoft/autogen | repo | https://github.com/microsoft/autogen | 57.2k | primary |
| s4 | crewAIInc/crewAI | repo | https://github.com/crewAIInc/crewAI | 56.4k | primary |
| s5 | langchain-ai/langgraph | repo | https://github.com/langchain-ai/langgraph | 38.5k | primary |
| s6 | SWE-agent/SWE-agent | repo | https://github.com/SWE-agent/SWE-agent | 20.0k | primary |
| s7 | How we built our multi-agent research system | blog | https://www.anthropic.com/engineering/multi-agent-research-system | n/a | primary |
| s8 | Building Effective AI Agents | blog | https://resources.anthropic.com/building-effective-ai-agents | n/a | primary |
| s9 | Claude Code subagents documentation | doc | https://code.claude.com/docs/en/sub-agents | n/a | primary |
| s10 | OpenAI Agents SDK | doc | https://openai.github.io/openai-agents-python/ | n/a | primary |
| s11 | LangChain multi-agent documentation | doc | https://docs.langchain.com/oss/python/langchain/multi-agent | n/a | primary |
| s12 | OpenAI Agents SDK handoffs | doc | https://openai.github.io/openai-agents-python/handoffs/ | n/a | primary |
| s13 | AutoGen message and communication documentation | doc | https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/framework/message-and-communication.html | n/a | primary |
| s14 | SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering | paper | https://arxiv.org/abs/2405.15793 | n/a | primary |

## Ideas

### role-boundaries-and-artifact-contracts: Distinct roles with explicit deliverables

```yaml
id: role-boundaries-and-artifact-contracts
title: Distinct roles with explicit deliverables
category: roles
pattern: >
  Define specialists by non-overlapping decision authority and required output artifact,
  not merely by persona labels. Each role owns a bounded question, produces a named
  structured deliverable, and returns unresolved issues rather than absorbing another
  role's responsibility.
evidence: "[s7, s9, s11]; Anthropic reports vague delegation caused duplicated and missing work, while Claude Code and LangChain formalize specialized subagents."
rationale: >
  Concrete task boundaries reduce duplicated investigation and make the coordinator able
  to assess completeness from an artifact rather than conversational confidence.
applicability_to_owl: 5
applicability_note: >
  The existing specialist library can encode ownership, inputs, outputs, non-goals, and
  escalation conditions as mandatory Markdown sections for every agent.
proposed_change: >
  Add a Role Contract section to every agent definition containing authority, required
  artifact, non-goals, acceptance criteria, and return-to-orchestrator condition.
risk: >
  Excessively narrow roles can create needless handoffs and hide cross-cutting design
  judgment; role boundaries need periodic review against real failed tasks.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://code.claude.com/docs/en/sub-agents
  - https://docs.langchain.com/oss/python/langchain/multi-agent
```

### coordinator-owned-hub-spoke: Coordinator-owned delegation

```yaml
id: coordinator-owned-hub-spoke
title: Coordinator-owned delegation
category: orchestration
pattern: >
  Keep routing, task decomposition, synthesis, and final accountability with one
  orchestrator; specialists act as callable workers and return results to it. Use
  direct handoffs only when the next specialist must own a continuing user interaction
  or stateful stage.
evidence: "[s7, s11, s12]; Anthropic uses an orchestrator-worker architecture, LangChain documents subagents as centralized control, and OpenAI distinguishes manager-style delegation from handoffs."
rationale: >
  Central ownership makes scope, conflict resolution, and stop decisions inspectable and
  avoids the rapidly increasing coordination complexity of peer-to-peer conversations.
applicability_to_owl: 5
applicability_note: >
  This exactly preserves the-owl's hub-and-spoke constraint: every specialist returns a
  handoff artifact to the orchestrator and never invokes another specialist.
proposed_change: >
  Add an orchestration policy stating that only the orchestrator selects the next agent,
  reconciles conflicting outputs, and may declare a workflow complete.
risk: >
  The orchestrator can become a bottleneck or misroute nuanced work; parallel
  delegation should remain available only for independent, explicitly partitioned tasks.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://openai.github.io/openai-agents-python/handoffs/
```

### yaml-frontmatter-and-prompt-body: Declarative agent definitions

```yaml
id: yaml-frontmatter-and-prompt-body
title: Declarative agent definitions
category: files
pattern: >
  Store each agent as a small Markdown prompt with YAML frontmatter for stable metadata
  and capability configuration. Keep role instructions in Markdown and machine-routable
  fields such as name, description, tool permissions, model choice, and limits in
  frontmatter.
evidence: "[s2, s9, s6]; Claude Code natively defines subagents as YAML frontmatter plus Markdown, and SWE-agent uses a single YAML configuration surface."
rationale: >
  Separating declarative metadata from behavioral instructions makes agents discoverable,
  reviewable, and safer to modify without embedding hidden runtime assumptions.
applicability_to_owl: 5
applicability_note: >
  The-owl already uses Markdown, YAML, and JSON prompts, so this standardizes rather
  than expands its implementation model.
proposed_change: >
  Standardize agent frontmatter with name, description, allowed_tools, denied_tools,
  inputs, outputs, escalation, and adr_required fields; retain the operational prompt
  as the Markdown body.
risk: >
  Frontmatter can become an undocumented pseudo-runtime if fields are invented without
  Claude Code or SDK semantics; unsupported fields should remain descriptive conventions.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://github.com/anthropics/claude-code
  - https://github.com/SWE-agent/SWE-agent
```

### least-privilege-tool-scoping: Role-specific tool allowlists

```yaml
id: least-privilege-tool-scoping
title: Role-specific tool allowlists
category: safety
pattern: >
  Give each role the minimum tools needed for its artifact, using explicit allowlists
  where possible and prohibiting mutation-capable tools for research, review, and
  safety roles. Scope any external integration to the specialist that needs it rather
  than exposing all tools to every agent.
evidence: "[s9, s10, s13]; Claude Code supports per-subagent tool allowlists and denylists, while OpenAI and AutoGen model agents as instructions plus scoped tools."
rationale: >
  Tool scope is both a safety boundary and a context-quality control: irrelevant tool
  descriptions increase wrong-tool selection and prompt-injection exposure.
applicability_to_owl: 5
applicability_note: >
  Agent Markdown can declare a tool policy even where the surrounding Claude Code
  session enforces the actual permissions.
proposed_change: >
  Add a mandatory Tool Scope section to every agent prompt with allowed capabilities,
  prohibited capabilities, required confirmation boundaries, and expected evidence of
  tool use.
risk: >
  Overly restrictive scopes can cause agents to improvise around missing evidence or
  return shallow work; exceptions need an explicit orchestrator-mediated escalation.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://openai.github.io/openai-agents-python/
  - https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/framework/message-and-communication.html
```

### structured-handoff-contracts: Bounded structured handoffs

```yaml
id: structured-handoff-contracts
title: Bounded structured handoffs
category: communication
pattern: >
  Require each handoff to carry a compact structured contract: objective, completed
  work, evidence or artifact links, decisions, assumptions, unresolved questions,
  risks, and requested next role. Pass a summary and references instead of an entire
  transcript.
evidence: "[s7, s11, s12, s13]; Anthropic requires objectives, output format, tool guidance, and boundaries, while OpenAI and AutoGen support typed or serializable handoff messages."
rationale: >
  Explicit handoff payloads reduce telephone-game loss, prevent downstream agents from
  redoing work, and make missing prerequisites visible at the delegation boundary.
applicability_to_owl: 5
applicability_note: >
  This can be a Markdown or JSON template embedded in every agent prompt and consumed
  by the orchestrator without a new runtime.
proposed_change: >
  Add a Handoff Contract template to all agent definitions with fields for task,
  artifact, evidence, decisions, assumptions, open questions, risk, and recommended
  next specialist.
risk: >
  Rigid templates can add ceremony to trivial work and summaries can omit a crucial
  detail; agents should attach canonical artifact paths when fidelity matters.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://openai.github.io/openai-agents-python/handoffs/
  - https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/framework/message-and-communication.html
```

### n-minus-one-context-transfer: Minimal downstream context

```yaml
id: n-minus-one-context-transfer
title: Minimal downstream context
category: context
pattern: >
  Treat context as a role-specific dependency: a specialist receives the user objective,
  its own contract, and only the immediately preceding validated artifact or summary.
  Raw conversational history is excluded unless it is necessary evidence for the role.
evidence: "[s7, s11, s12]; Anthropic and LangChain identify context engineering as central, and OpenAI supports handoff input filtering rather than forwarding all history."
rationale: >
  Fresh context windows reduce distraction, leakage of irrelevant instructions, token
  cost, and propagation of earlier reasoning mistakes.
applicability_to_owl: 5
applicability_note: >
  This formalizes the-owl's existing N-1 scoping rule as an explicit input contract and
  prevents accidental full-transcript forwarding.
proposed_change: >
  Add an Input Boundary section declaring the sole prior artifact accepted by each
  specialist, the evidence that may be retrieved from it, and prohibited context such
  as hidden chain-of-thought or unrelated transcripts.
risk: >
  A too-small handoff can remove assumptions needed to detect an upstream error; the
  contract needs an explicit request-for-context return state.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://docs.langchain.com/oss/python/langchain/multi-agent
  - https://openai.github.io/openai-agents-python/handoffs/
```

### adr-as-durable-decision-memory: ADR-backed durable memory

```yaml
id: adr-as-durable-decision-memory
title: ADR-backed durable decision memory
category: memory
pattern: >
  Persist only durable, reviewable decisions and verified reusable findings, while
  keeping ephemeral scratch work out of long-term memory. Link the current task to the
  relevant ADRs and require material changes to create a new ADR or supersede one.
evidence: "[s7, s8, s14]; Anthropic persists plans and summarizes completed phases for long-horizon work, while SWE-agent emphasizes configurable, reproducible agent behavior."
rationale: >
  Durable artifacts preserve rationale across context resets without turning every
  conversation into an unbounded memory store.
applicability_to_owl: 5
applicability_note: >
  The-owl already mandates ADRs, so an ADR index and explicit citation convention are
  sufficient; no memory service or runtime is required.
proposed_change: >
  Add an ADR Memory Protocol defining which decisions must be recorded, a compact ADR
  reference block in handoffs, and a rule that superseded decisions are cited rather
  than silently overwritten.
risk: >
  ADR accumulation can create retrieval burden and stale guidance; concise status and
  supersession metadata are necessary to prevent obsolete decisions from steering work.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://resources.anthropic.com/building-effective-ai-agents
  - https://arxiv.org/abs/2405.15793
```

### evidence-gated-evaluation-loop: Evidence-gated evaluation loop

```yaml
id: evidence-gated-evaluation-loop
title: Evidence-gated evaluation loop
category: self-improvement
pattern: >
  Evaluate complete agent trajectories against task-specific acceptance criteria, then
  record failures, scores, and prompt changes as separate reviewable artifacts. Use
  evaluator-optimizer loops only where quality can be checked against concrete evidence
  rather than subjective stylistic preference.
evidence: "[s7, s8, s10, s14]; Anthropic reports prompt iteration driven by simulations and test cases, its guidance includes evaluator-optimizer patterns, and OpenAI provides tracing and evaluation support."
rationale: >
  Outcome-level evaluation identifies decomposition, tool-choice, and handoff failures
  that a final-answer-only review misses.
applicability_to_owl: 4
applicability_note: >
  A markdown evaluation rubric, failure ledger, and ADR-reviewed prompt revision can
  implement the loop without automated orchestration.
proposed_change: >
  Add an Evals section with scenario fixtures, observable acceptance criteria, a
  handoff-quality scorecard, and a feedback ledger that links each prompt change to
  measured failures.
risk: >
  Weak or self-authored evaluators can reward plausible but incorrect behavior and
  optimize the library toward benchmark artifacts rather than real engineering outcomes.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://resources.anthropic.com/building-effective-ai-agents
  - https://openai.github.io/openai-agents-python/
  - https://arxiv.org/abs/2405.15793
```

### independent-adversarial-review: Independent safety and quality review

```yaml
id: independent-adversarial-review
title: Independent safety and quality review
category: safety
pattern: >
  Separate proposal generation from verification by assigning independent reviewer and
  adversarial-review roles that receive the proposed artifact plus criteria, not the
  author's full internal rationale. The reviewer returns findings, evidence, and a
  pass, revise, or escalate decision to the coordinator.
evidence: "[s7, s8, s10]; Anthropic uses a dedicated citation agent and explicit guardrails, its guidance includes evaluator-optimizer patterns, and OpenAI provides guardrails plus traceable handoffs."
rationale: >
  Independent review reduces correlated errors and forces claims, tests, security
  assumptions, and completion statements to be checked against observable evidence.
applicability_to_owl: 5
applicability_note: >
  The existing guardian, sentinel, and challenger roles can be given distinct review
  contracts and invoked only by the orchestrator after an artifact is produced.
proposed_change: >
  Add a Review Boundary section requiring guardian, sentinel, or challenger output to
  contain independent checks, severity, evidence, and an explicit disposition rather
  than rewritten implementation text.
risk: >
  Repeated review layers increase latency and can produce superficial agreement if
  criteria are vague; use them for material changes and security-sensitive scope.
confidence: medium
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://resources.anthropic.com/building-effective-ai-agents
  - https://openai.github.io/openai-agents-python/
```

### effort-budgets-and-hard-stops: Effort budgets and hard stops

```yaml
id: effort-budgets-and-hard-stops
title: Effort budgets and hard stops
category: structure
pattern: >
  Define proportional effort rules, evidence thresholds, and termination conditions for
  each task class. The coordinator should scale the number of specialists and depth of
  review with task complexity, and stop or escalate when evidence remains insufficient.
evidence: "[s7, s8, s11]; Anthropic documents explicit scaling rules after over-delegation failures, recommends matching architecture complexity to value, and LangChain cautions that many tasks do not need multi-agent systems."
rationale: >
  Budgets counter runaway delegation, endless research, and costly agent loops while
  making uncertainty an explicit result rather than an invitation to fabricate.
applicability_to_owl: 5
applicability_note: >
  Prompt-level complexity tiers and hard-stop conditions fit the-owl governance model
  without requiring a scheduler, token meter, or daemon.
proposed_change: >
  Add a Delegation Budget matrix defining simple, standard, and high-risk task tiers,
  maximum specialist count, required evidence threshold, stop condition, and escalation
  wording for each tier.
risk: >
  Fixed budgets can prematurely terminate legitimate complex work or encourage agents
  to optimize for apparent completion; exceptions require documented coordinator judgment.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://resources.anthropic.com/building-effective-ai-agents
  - https://docs.langchain.com/oss/python/langchain/multi-agent
```

### human-approval-at-boundary-crossings: Human approval at consequential boundaries

```yaml
id: human-approval-at-boundary-crossings
title: Human approval at consequential boundaries
category: safety
pattern: >
  Require an explicit human decision when work crosses predefined consequential
  boundaries, including destructive changes, privilege expansion, security exceptions,
  production-impacting deployment, or unresolved high-severity findings. Represent the
  approval request as a concise decision record with alternatives and evidence.
evidence: "[s4, s9, s10]; CrewAI documents human-in-the-loop workflows, Claude Code exposes permission modes and prompts, and OpenAI Agents SDK supports human-in-the-loop interruptions."
rationale: >
  Model judgment is insufficient for authority transfer; a visible approval boundary
  preserves accountability and limits damage from prompt injection or faulty inference.
applicability_to_owl: 5
applicability_note: >
  The library can express approval gates as mandatory prompt hard-stops and ADR
  requirements, leaving actual permission enforcement to Claude Code or the Agent SDK.
proposed_change: >
  Add a Human Approval Gate template with trigger condition, proposed action, affected
  scope, evidence, alternatives, rollback considerations, and required approver decision.
risk: >
  Broad approval requirements can turn routine work into slow manual queues, while vague
  triggers invite bypass; gates need a small, unambiguous list of consequential actions.
confidence: high
references:
  - https://github.com/crewAIInc/crewAI
  - https://code.claude.com/docs/en/sub-agents
  - https://openai.github.io/openai-agents-python/
```

## Anti-patterns to avoid

- Free-form peer mesh communication — coordination cost, duplicated work, and unclear accountability grow rapidly; coordinator-owned delegation with bounded contracts is replacing it for most engineering workflows.
- Spawning many agents by default — Anthropic reports early systems creating excessive subagents for simple queries; proportional effort budgets and single-agent-first selection are stronger defaults.
- Passing full transcripts to every downstream agent — it increases cost, distracts specialists, and propagates irrelevant or adversarial instructions; summary-plus-artifact-reference handoffs replace it.
- Persona-only role design — labels such as “expert” do not prevent overlap; authority, non-goals, acceptance criteria, and named artifacts are more reliable.
- Unbounded autonomous prompt self-modification — it can optimize against weak self-evaluations and erase governance; measured changes recorded through reviewed ADRs are safer.
- Relying only on final input/output guardrails — delegated tool calls and handoffs can bypass those boundaries; tool-level constraints, permission gates, and independent review are needed.
- Treating multi-agent architecture as intrinsically superior to a well-prompted single agent — primary sources explicitly caution that many tasks, especially dependency-heavy coding work, are not good multi-agent fits.

## Open questions

- Which the-owl task classes demonstrate a measurable quality or latency gain from specialist delegation over a single-agent workflow?
- What minimum handoff schema preserves sufficient engineering context while retaining the current N-1 isolation guarantee?
- Which review findings should automatically require an ADR, versus being recorded only in a task-level feedback ledger?
