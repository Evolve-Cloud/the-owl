---
schema_version: 1
date: 2026-07-29
generator: gpt-5
source_count: 13
idea_count: 11
---

## Executive summary

The durable pattern is not an autonomous “swarm,” but a small number of sharply bounded specialists coordinated by one owner.  
Context engineering has become the central design concern: specialists should receive an intentionally scoped artifact, not a growing transcript.  
Structured handoffs, explicit stopping conditions, and evaluation fixtures are increasingly treated as first-class system design rather than prompt embellishments.  
Framework popularity supports these patterns, but star counts do not establish effectiveness; most public multi-agent claims remain application-specific.  
For coding systems, hierarchical manager-and-worker topologies are more controllable than peer meshes and map especially well to reviewable software artifacts.  
The strongest safety direction is capability minimization, explicit approval boundaries, and treating untrusted retrieved text as data rather than instructions.  
For a markdown-only library, these findings primarily translate into agent-file conventions, handoff schemas, decision gates, and ADR-backed evaluation records.

## Sources

| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | OpenHands/OpenHands | repo | https://github.com/OpenHands/OpenHands | 82.3k | primary |
| s2 | crewAIInc/crewAI | repo | https://github.com/crewAIInc/crewAI | 52.3k | primary |
| s3 | langchain-ai/langgraph | repo | https://github.com/langchain-ai/langgraph | 37.4k | primary |
| s4 | microsoft/autogen | repo | https://github.com/microsoft/autogen | 58.4k | secondary |
| s5 | Building Effective Agents | blog | https://www.anthropic.com/engineering/building-effective-agents | n/a | primary |
| s6 | How we built our multi-agent research system | blog | https://www.anthropic.com/engineering/multi-agent-research-system | n/a | primary |
| s7 | When to use multi-agent systems and when not to | blog | https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them | n/a | primary |
| s8 | Claude Code custom subagents | doc | https://code.claude.com/docs/en/sub-agents | n/a | primary |
| s9 | Claude Agent SDK subagents | doc | https://code.claude.com/docs/en/agent-sdk/subagents | n/a | primary |
| s10 | LangGraph multi-agent concepts | doc | https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/ | n/a | primary |
| s11 | OpenAI Agents SDK handoffs | doc | https://openai.github.io/openai-agents-python/handoffs/ | n/a | primary |
| s12 | AutoGen teams and termination | doc | https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/teams.html | n/a | primary |
| s13 | Demystifying evals for AI agents | blog | https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents | n/a | primary |

## Ideas

### explicit-role-charters: Explicit role charters with non-overlapping deliverables

```yaml
id: explicit-role-charters
title: Explicit role charters with non-overlapping deliverables
category: roles
pattern: >
  Define each specialist by a distinct decision or artifact it owns, its admissible inputs,
  exclusions, and completion criteria. Use a small team whose roles correspond to meaningful
  expertise boundaries, rather than multiple generic agents differentiated only by persona.
evidence: [s2, s3, s5, s8] # High-adoption frameworks expose specialist agents; Anthropic and Claude Code describe focused workers.
rationale: >
  Clear ownership reduces duplicated reasoning, contradictory edits, and router ambiguity.
  Specialization is most useful when knowledge, tools, or quality criteria genuinely differ.
applicability_to_owl: 5
applicability_note: >
  Express each charter in the agent Markdown body with Required Inputs, Owned Output,
  Out of Scope, Mandatory Delegation, and Definition of Done sections.
proposed_change: >
  Add a Role Boundary section to every agent file and a role-boundary matrix documenting
  the sole owner of strategy, architecture, implementation, verification, security review,
  challenge, and changelog artifacts.
risk: >
  Over-specialization creates unnecessary handoffs and latency; role labels without exclusive
  deliverables become cosmetic personas rather than useful boundaries.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://code.claude.com/docs/en/sub-agents
  - https://github.com/crewAIInc/crewAI
```

### artifact-first-pipeline: Artifact-first sequential handoffs

```yaml
id: artifact-first-pipeline
title: Artifact-first sequential handoffs
category: communication
pattern: >
  Pass a named, structured output from one stage to the next instead of relying on an
  implicitly shared conversation. Each stage validates its input artifact, produces its own
  bounded artifact, and returns control to one coordinator.
evidence: [s5, s6, s10, s11] # Primary sources describe orchestrated workers, routing, and typed handoff inputs.
rationale: >
  A bounded artifact preserves provenance, prevents context accumulation, and makes failures
  attributable to a stage. It also makes a workflow inspectable without reproducing a runtime trace.
applicability_to_owl: 5
applicability_note: >
  Define Markdown or YAML handoff blocks such as Strategy Brief, Architecture Decision,
  Implementation Plan, Verification Report, and Security Review; the next agent receives
  only the immediately preceding artifact plus stable project rules.
proposed_change: >
  Add a Handoff Contract section to every agent file requiring input schema, output schema,
  assumptions, unresolved questions, evidence links, and an explicit return-to-orchestrator marker.
risk: >
  Schemas can become bureaucratic and omit useful nuance; overly lossy summaries may hide
  evidence needed by later reviewers.
confidence: high
references:
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://openai.github.io/openai-agents-python/handoffs/
  - https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/
```

### coordinator-owned-routing: Coordinator-owned hub-and-spoke routing

```yaml
id: coordinator-owned-routing
title: Coordinator-owned hub-and-spoke routing
category: orchestration
pattern: >
  Keep routing, sequencing, escalation, and final synthesis with one coordinator while
  specialists act as bounded workers and return results. Allow peer-to-peer handoffs only
  when conversational transfer is itself the product requirement.
evidence: [s7, s10, s11] # LangGraph documents coordinator-as-subagents and handoff alternatives; Anthropic cautions against unnecessary multi-agent complexity.
rationale: >
  A central owner makes task state, authority, and quality gates legible. It avoids emergent
  cycles and makes the path from request to ADR auditable.
applicability_to_owl: 5
applicability_note: >
  Preserve the current orchestrator-only delegation rule and encode each specialist's allowed
  predecessor and successor as a static routing table in the library documentation.
proposed_change: >
  Add a canonical workflow map stating that specialists must return a handoff artifact to
  the orchestrator and may not invoke, select, or message another specialist directly.
risk: >
  The coordinator becomes a throughput and judgment bottleneck; inappropriate centralization
  can slow genuinely independent research or review tasks.
confidence: high
references:
  - https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them
  - https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/
  - https://openai.github.io/openai-agents-python/handoffs/
```

### single-agent-default: Single-agent baseline before team expansion

```yaml
id: single-agent-default
title: Single-agent baseline before team expansion
category: structure
pattern: >
  Treat a multi-agent path as justified only when a single well-prompted, correctly tooled
  agent demonstrably lacks context capacity, domain specialization, parallelism, or a required
  independent review boundary. Maintain a simpler baseline workflow for comparison.
evidence: [s5, s7, s10, s12] # Anthropic, LangGraph, and AutoGen all explicitly advise starting simpler.
rationale: >
  Multiple agents add routing error, cost, latency, coordination overhead, and more failure
  surfaces. A baseline exposes whether specialization creates measurable improvement rather
  than merely more verbose work.
applicability_to_owl: 5
applicability_note: >
  Make delegation conditional on explicit triggers in the orchestrator prompt, such as a
  cross-cutting security decision, independent verification need, or artifact requiring a
  role-specific authority.
proposed_change: >
  Add a Delegation Justification field to orchestrator handoffs with one of four values:
  specialization, independent review, context isolation, or parallelizable research.
risk: >
  Excessive conservatism can leave a generalist handling work that genuinely needs independent
  challenge or deep domain review.
confidence: high
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them
  - https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/teams.html
```

### context-budgeted-handoffs: Context-budgeted handoffs and progressive disclosure

```yaml
id: context-budgeted-handoffs
title: Context-budgeted handoffs and progressive disclosure
category: context
pattern: >
  Give a specialist only the task, relevant constraints, required source artifacts, and the
  immediate predecessor's structured result. Keep stable conventions separate from volatile
  task evidence, and summarize rather than forward long transcripts.
evidence: [s6, s8, s9, s10, s11] # Claude subagents isolate context; framework docs identify context engineering as the main multi-agent design problem.
rationale: >
  Selective context reduces distraction, stale assumptions, token cost, and prompt-injection
  exposure while preserving the information needed for a specialized decision.
applicability_to_owl: 5
applicability_note: >
  Retain N-1 scoping and require every handoff to label content as stable policy, verified
  evidence, inference, or unresolved issue; agents may not assume access to omitted history.
proposed_change: >
  Add a Context Manifest template to handoffs with Included Artifacts, Excluded History,
  Non-Negotiable Constraints, Evidence Confidence, and Open Questions fields.
risk: >
  Aggressive compression can remove a dependency or rationale and cause a later agent to
  repeat investigation or make an inconsistent decision.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://code.claude.com/docs/en/agent-sdk/subagents
  - https://langchain-ai.github.io/langgraph/tutorials/multi_agent/multi-agent-collaboration/
  - https://openai.github.io/openai-agents-python/handoffs/
```

### frontmatter-capability-scoping: Declarative agent metadata and capability scoping

```yaml
id: frontmatter-capability-scoping
title: Declarative agent metadata and capability scoping
category: files
pattern: >
  Store reusable agent definitions as Markdown with machine-readable YAML frontmatter for
  name, invocation description, tool permissions, model selection, and operational limits,
  followed by the role prompt. Restrict tools and permissions per role rather than relying
  on prose-only prohibitions.
evidence: [s2, s8, s9] # CrewAI uses agent/task YAML; Claude Code supports Markdown subagents with frontmatter and scoped tools.
rationale: >
  Declarative metadata separates routing and capability policy from behavioral guidance,
  improving reviewability and preventing accidental authority expansion.
applicability_to_owl: 5
applicability_note: >
  the-owl already uses Markdown and YAML, so a common frontmatter contract can declare
  role identity, read-only versus change-producing intent, allowed artifact outputs, and
  mandatory ADR behavior without introducing a runtime.
proposed_change: >
  Standardize frontmatter keys across all agent files: name, description, inputs,
  outputs, allowed-tools, disallowed-tools, handoff-return, authority-boundary, and
  adr-required.
risk: >
  Unsupported frontmatter keys may be ignored by Claude Code; repository conventions must
  distinguish runtime-enforced fields from documentation-only fields.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://code.claude.com/docs/en/agent-sdk/subagents
  - https://github.com/crewAIInc/crewAI
```

### durable-decisions-separate-from-working-memory: Separate durable decisions from working memory

```yaml
id: durable-decisions-separate-from-working-memory
title: Separate durable decisions from working memory
category: memory
pattern: >
  Persist only stable, reviewable project knowledge such as ADRs, accepted interfaces,
  invariant policies, and evaluation outcomes. Treat task transcripts, exploratory notes,
  and unverified hypotheses as ephemeral unless promoted through an explicit decision step.
evidence: [s3, s6, s10, s13] # Stateful frameworks support persistence, while Anthropic emphasizes context management and evaluation-driven iteration.
rationale: >
  Durable memory compounds useful organizational knowledge only when it has provenance and
  an owner. Separating it from working context prevents incorrect or superseded speculation
  from silently becoming policy.
applicability_to_owl: 5
applicability_note: >
  Use the existing ADR requirement as the sole promotion path: an agent may cite prior ADRs
  as durable memory but must mark all other inherited material as provisional.
proposed_change: >
  Add a Memory Promotion section to chronicler and architect prompts requiring status,
  rationale, scope, supersession link, and source handoff before a finding is recorded as
  durable project knowledge.
risk: >
  ADR-heavy persistence can become stale or difficult to search; forcing every operational
  detail into an ADR creates needless governance overhead.
confidence: high
references:
  - https://github.com/langchain-ai/langgraph
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
```

### adversarial-review-gate: Independent adversarial review before change closure

```yaml
id: adversarial-review-gate
title: Independent adversarial review before change closure
category: safety
pattern: >
  Insert a specialist whose deliverable is to challenge assumptions, scope, security, and
  evidence quality before a consequential change is declared complete. The reviewer has a
  different success criterion from the builder and returns findings to the coordinator.
evidence: [s5, s7, s13] # Primary guidance favors simple controlled workflows, evaluation, and verification over unconstrained autonomy.
rationale: >
  Builder self-review is vulnerable to confirmation bias. A bounded independent check creates
  a deliberate disagreement mechanism without requiring a peer mesh.
applicability_to_owl: 5
applicability_note: >
  Preserve guardian, sentinel, and challenger as independent return-only stages with explicit
  authority to block closure, request evidence, or require an ADR amendment.
proposed_change: >
  Add a Change Closure Gate requiring a guardian verification report, sentinel security
  assessment when attack surface changes, and challenger review for material architectural decisions.
risk: >
  Mandatory review on trivial changes increases latency and encourages superficial rubber-stamping
  unless materiality thresholds are explicit.
confidence: medium
references:
  - https://www.anthropic.com/engineering/building-effective-agents
  - https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them
  - https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
```

### trajectory-evals-with-baselines: Scenario-based trajectory evaluation with baselines

```yaml
id: trajectory-evals-with-baselines
title: Scenario-based trajectory evaluation with baselines
category: self-improvement
pattern: >
  Evaluate complete agent trajectories and produced artifacts against representative,
  versioned scenarios, not only final prose. Compare the specialist workflow against a
  simpler baseline and record task success, quality defects, cost, time, and unsafe behavior.
evidence: [s3, s6, s7, s13] # LangGraph emphasizes tracing and state; Anthropic advocates rigorous agent evals and warns that teams are not universally superior.
rationale: >
  Agent changes often shift behavior indirectly through routing and context. Scenario replay
  makes regressions visible and tests whether team complexity earns its cost.
applicability_to_owl: 5
applicability_note: >
  Define Markdown evaluation fixtures containing an input brief, expected required artifacts,
  forbidden outcomes, scoring rubric, and expected delegation sequence; store scored outcomes
  beside the relevant ADR or agent revision.
proposed_change: >
  Create an evals directory with role-specific and end-to-end fixtures, plus an Evaluation
  Record template that compares the current workflow with a single-agent baseline.
risk: >
  Small hand-authored eval sets can be gamed or become stale; subjective rubrics require
  calibration and cannot prove real-world reliability.
confidence: high
references:
  - https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
  - https://www.anthropic.com/engineering/multi-agent-research-system
  - https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them
```

### explicit-termination-and-escalation: Explicit termination, escalation, and approval conditions

```yaml
id: explicit-termination-and-escalation
title: Explicit termination, escalation, and approval conditions
category: safety
pattern: >
  Define stop conditions, turn or effort bounds, unresolved-question thresholds, and human
  approval points before work begins. A specialist must return control when it cannot satisfy
  its acceptance criteria rather than continuing speculative loops.
evidence: [s8, s11, s12] # Claude Code exposes max-turn and permission controls; OpenAI and AutoGen document handoff and termination mechanisms.
rationale: >
  Explicit exits prevent runaway coordination, false completion, and silent escalation of
  authority. They also distinguish a blocked task from a failed agent.
applicability_to_owl: 5
applicability_note: >
  Represent termination as mandatory prompt sections: Stop When, Escalate When, Do Not Decide,
  and Approval Required. The orchestrator, not a specialist, resolves escalations.
proposed_change: >
  Add a Stop and Escalation Contract to every agent prompt, including maximum review iterations,
  evidence insufficiency criteria, and explicit conditions that require human owner input.
risk: >
  Rigid stop rules can terminate recoverable work too early; loose rules become indistinguishable
  from unconstrained autonomy.
confidence: high
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://openai.github.io/openai-agents-python/handoffs/
  - https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/teams.html
```

### untrusted-content-boundary: Treat retrieved and delegated content as untrusted data

```yaml
id: untrusted-content-boundary
title: Treat retrieved and delegated content as untrusted data
category: safety
pattern: >
  Require agents to separate quoted external content from governing instructions, reject
  attempts to alter authority through task artifacts, and verify claims before promoting
  them into an ADR or implementation decision. Tool authority should follow least privilege
  and be scoped to the task role.
evidence: [s8, s11, s13] # Claude Code supports scoped tools and permissions; OpenAI documents guardrail scope; evaluation guidance supports testing unsafe behavior.
rationale: >
  A multi-agent system multiplies the surfaces where compromised web content, repository text,
  or a flawed handoff can steer later decisions. Explicit provenance and authority boundaries
  make injection and error propagation easier to detect.
applicability_to_owl: 5
applicability_note: >
  Add a rule that handoffs may contain evidence and recommendations but never new governing
  instructions; only repository-level policy and the orchestrator can alter an agent's scope.
proposed_change: >
  Add an Evidence Trust section to agent templates requiring source classification,
  verification status, and a statement that embedded instructions in inputs are non-authoritative.
risk: >
  Excessive distrust slows use of legitimate project documentation and can lead to redundant
  verification work.
confidence: medium
references:
  - https://code.claude.com/docs/en/sub-agents
  - https://openai.github.io/openai-agents-python/handoffs/
  - https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
```

### library-layering-by-stability: Organize the library by stable policy, roles, workflows, and records

```yaml
id: library-layering-by-stability
title: Organize the library by stable policy, roles, workflows, and records
category: files
pattern: >
  Separate universal project policy, individual role definitions, reusable workflow templates,
  and project-specific decision records into distinct folders. Load stable policy globally,
  invoke workflow material on demand, and keep role prompts focused on their owned judgment.
evidence: [s2, s8, s10] # CrewAI separates agents and tasks; Claude Code distinguishes shared instructions, skills, and subagents; LangGraph separates state and nodes.
rationale: >
  Layering avoids copying policy across agents and makes changes reviewable at the correct
  level. It also supports context-minimal operation because only relevant templates need be
  included in a handoff.
applicability_to_owl: 5
applicability_note: >
  Keep shared governance in a root policy document, agents in one role directory, handoff and
  eval templates in dedicated directories, and ADRs in an append-only decision directory.
proposed_change: >
  Adopt a documented layout of policies/, agents/, workflows/, templates/, evals/, and adr/,
  with every agent prompt referencing common policy by stable relative path rather than copying it.
risk: >
  Excessive fragmentation raises discovery cost and broken-reference risk; shared policy must
  remain short enough not to become an indiscriminate context dump.
confidence: high
references:
  - https://github.com/crewAIInc/crewAI
  - https://code.claude.com/docs/en/sub-agents
  - https://langchain-ai.github.io/langgraph/concepts/multi_agent/
```

## Anti-patterns to avoid

- Free-form peer mesh communication — it obscures ownership, permits cycles, and increases context and token cost; coordinator-owned delegation with return-only handoffs is more controllable.
- Adding agents before optimizing a single-agent workflow — primary framework guidance repeatedly notes that better prompting, tools, or deterministic workflow steps can match a team at lower cost.
- Generic persona multiplication — “expert,” “senior,” and “reviewer” labels without exclusive artifacts or authority boundaries create duplicated work rather than specialization.
- Full-transcript forwarding — it bloats context, spreads stale assumptions and injection payloads, and weakens provenance; use bounded handoff artifacts and manifests.
- Prose-only safety rules with broad tool access — permissions and capability scope should be declarative where the host supports them, with hard-stop language as an additional layer.
- Self-improvement based only on agent self-critique — it is vulnerable to confirmation bias; use versioned scenarios, explicit rubrics, baselines, and independent review.
- Treating star counts as proof of reliability — repository popularity measures visibility and ecosystem activity, not task success, security, or suitability for a markdown-only library.
- Persistent memory without promotion criteria — unverified observations become durable policy; retain only ADR-backed decisions and clearly scoped evaluation records.

## Open questions

- Which fixed, representative coding-planning scenarios most reliably distinguish the-owl’s specialist pipeline from a single well-prompted Claude Code agent?
- What materiality threshold should require sentinel and challenger review without turning low-risk documentation changes into a slow approval process?
- How should a markdown-only library represent a machine-checkable handoff schema while remaining usable directly inside Claude Code and the Claude Agent SDK?
- Which handoff fields create the best quality-versus-context trade-off: evidence excerpts, source links, confidence labels, decision alternatives, or all four?