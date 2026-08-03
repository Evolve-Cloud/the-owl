---
title: Tool design & capability scoping
type: pattern
tags: [tool-use, tool-design, aci, mcp, context-engineering, least-privilege, token-efficiency, packaging]
sources: 4
updated: 2026-08-03
---

## Definition

**Tool design & capability scoping** is the practice of treating an agent's tools
as a deliberately engineered, *bounded* interface — not a dumping ground of every
API you have. It spans two coupled fronts:

1. **Design** — a tool is a **contract between a deterministic implementation and a
   non-deterministic agent**. It is built through a prototype → evaluate → improve
   loop, kept few and intentional, namespaced, and returns context-efficient
   (semantically-relevant, human-interpretable) results. The agent-computer
   interface (ACI) deserves as much craft as a human-computer interface (HCI).
2. **Scoping** — the set of tools *visible* to a given agent is itself a lever, on
   two axes: a **token axis** (how much of the context window tool definitions and
   their intermediate results consume) and a **privilege axis** (which capabilities
   an agent is even allowed to reach — least-privilege). On-demand discovery,
   code-execution-with-MCP, and per-agent `tools:`/`disallowedTools` allowlists are
   all instances of scoping.

The through-line: **tools are a finite, expensive part of context, so both *what*
each tool is and *which* an agent can see are first-class design decisions.**

## Key ideas

### Tools as a contract (the design front)
- Tools differ from traditional APIs: they contract with an agent that may
  hallucinate or misuse them. Ergonomics, not just correctness, decide outcomes.
- **Prototype → evaluate → improve.** Evaluate against realistic *multi-step* tasks
  and use agent-assisted transcript analysis to find where tools confuse the agent.
- **Fewer, intentional tools beat many overlapping ones.** Consolidate related
  operations; "more tools don't always lead to better outcomes."
- **Namespacing** (consistent prefixes/conventions) lets an agent navigate hundreds
  of tools across servers.
- **Context-efficient responses.** Return semantically relevant, human-interpretable
  fields (names over UUIDs); a `ResponseFormat` enum lets the agent choose verbosity.
- **The description is prompt engineering.** Precise, unambiguous tool descriptions
  measurably raise correct utilization. **Tool-use examples** (concrete input demos
  beyond the JSON schema) lifted accuracy on complex parameters from **72% → 90%**.

### Scoping the token axis (how much context tools cost)
- Tool *definitions alone* can consume **55K–134K tokens** in a 50+-tool / multi-
  server setup — spent **before the agent reads a single request**. This is a
  context-budget problem, an instance of [[context-engineering]].
- **On-demand tool discovery (Tool Search).** Load tool definitions when needed via
  regex/BM25 instead of upfront: **~500 tokens loaded vs ~72K** for 50+ MCP tools,
  and Opus-4 accuracy on a tool-heavy task rose **49% → 74%**. Whole MCP servers can
  be *deferred* while a few high-frequency tools stay hot.
- **Programmatic / code-execution tool calling.** Present MCP servers as a **code API
  on a filesystem** the agent reads on demand; orchestrate multiple tools in code so
  loops, filtering, and intermediate results run **locally and never re-enter
  context**. Reported reductions: **37%** (programmatic calling) up to **98.7%**
  (150K → 2K tokens, filesystem-organized discovery). Bonus: PII can flow between
  systems without entering the model context, and the agent can persist reusable
  higher-level functions ("skills").

### Scoping the privilege axis (which capabilities an agent may reach)
- Least-privilege for agents = **per-agent tool allowlists**. Give each agent only
  the tools its role requires; withhold the rest. A review or research agent that
  should never mutate the repo simply has no `Edit`/`Write` in its set.
- Delivery/enforcement mechanisms: harness-enforced subagent frontmatter
  (`tools:` allowlist / `disallowedTools` deny-list), and for distribution,
  **Desktop Extensions (`.mcpb`)** — a ZIP + declarative `manifest.json` that bundles
  a whole MCP server so scoping/governance (enterprise pre-approval, directory
  disabling, MDM/Group Policy) is packaged, not hand-wired.

## Evidence / sources

- [[writing-tools-for-agents]] — the **design** anchor: tools-as-contract, the
  prototype-evaluate-improve loop, fewer-intentional-tools, namespacing,
  context-efficient responses, description-as-prompt-engineering.
  ([anthropic.com/engineering/writing-tools-for-agents](https://www.anthropic.com/engineering/writing-tools-for-agents))
- [[advanced-tool-use]] — the **on-demand + accuracy** evidence: Tool Search
  (49%→74%, ~500 vs 72K tokens), Programmatic Tool Calling (−37%), Tool Use Examples
  (72%→90%), server-level deferral. Quantifies the 55K–134K definition-cost problem.
  ([anthropic.com/engineering/advanced-tool-use](https://www.anthropic.com/engineering/advanced-tool-use))
- [[code-execution-mcp]] — the **token-economics** anchor: code-as-API on a
  filesystem, local data filtering, up to **98.7%** token reduction (150K→2K),
  PII-out-of-context, agent-built reusable skills.
  ([anthropic.com/engineering/code-execution-with-mcp](https://www.anthropic.com/engineering/code-execution-with-mcp))
- [[desktop-extensions]] — the **packaging/distribution + governance** front: `.mcpb`
  one-click bundling, OS-keychain secrets, enterprise pre-install/disable/deploy via
  Group Policy/MDM; MCPB v0.1 open-sourced.
  ([anthropic.com/engineering/desktop-extensions](https://www.anthropic.com/engineering/desktop-extensions))

> [!note]
> **Design vs scoping are complementary, not competing.** Good design (fewer, well-
> described tools) *shrinks* the token axis before any on-demand machinery is added;
> on-demand discovery / code-execution then handle whatever scale remains. Desktop
> Extensions package the result so the privilege axis travels with the tool.

## Trade-off

Every scoping mechanism trades **upfront availability for a cheaper, safer context**:

- **On-demand discovery** saves tens of thousands of tokens but adds a **discovery
  step** (latency + a chance the search misses the right tool on an ambiguous query —
  the sources' own open question).
- **Code-execution-with-MCP** yields the largest token wins and keeps PII out of
  context, but **requires a sandboxed execution environment** and shifts risk into
  agent-authored code (the "are reused skills still safe?" open question).
- **Per-agent allowlists** raise safety and focus, but an over-tight list can **block
  an agent from a capability it legitimately needs**, forcing a re-scope; and — the
  decisive caveat for the-owl — an allowlist is **only real if the harness enforces
  it**. Prose "forbidden tools" with no enforcement is false confidence (the exact
  reason `least-privilege-tool-scopes` sat deferred; see below).
- **Desktop Extensions** ease distribution and enterprise control but concentrate
  **supply-chain trust in bundled dependencies** (auditing/revocation of a malicious
  extension is the source's open question).

## How it maps to the-owl

the-owl is **markdown + YAML only, no runtime** — so the *token-axis* mechanisms
(Tool Search, code-execution-with-MCP, `.mcpb` packaging) are **enrichment, not
adoptable conventions**: they presuppose a runtime the library structurally lacks.
The ledger correctly parks them as "low fit for a markdown-only lib." The **design**
principles (fewer intentional tools, description-as-prompt-engineering, namespacing)
already echo the-owl's context-minimal / N-1 ethos and its role-scoped agents.

The live piece is the **privilege axis**, tracked as the ledger id
**`least-privilege-tool-scopes`** ("Tight per-agent tool lists," first seen
2026-07-23):

- It was **deferred (score 66)** on 2026-07-26 precisely because the-owl's original
  inline, one-agent-per-phase execution model (ADR-010) had **no mechanism to
  actually restrict which tools an agent could use** — a "Forbidden Tools" section
  would have been unenforceable prose, a false-confidence risk.
- On **2026-08-03** the scout verified that `tools:` / `disallowedTools` are **REAL,
  harness-enforced** native-subagent frontmatter fields. The deferral blocker is
  therefore being **removed — human-directed, on branch `owl/agents-native-subagents`,
  not by `/owl:evolve`.** That branch adds native `.claude/agents/*.md` subagents with
  enforced allowlists (a hybrid: native subagents + command personas). Concretely,
  the read-only agents are already scoped:
  - `curator`, `scout`, `sentinel`, `challenger` → `Read, Grep, Glob, Bash, WebFetch,
    WebSearch` — **no `Edit`/`Write`** (they analyze, they do not mutate the repo).
  - `guardian` → `Read, Grep, Glob, Bash` — even narrower (no web).
  - Producer agents (`architect`, `builder`, `strategist`, `system-designer`,
    `chronicler`, `database-specialist`, `mcp-builder`, `team`) inherit the full set,
    since their job is to write.

> [!important]
> **Carve-out boundary (NFR-SEC-1).** Tightening the tool lists on
> **`sentinel` / `guardian` / `challenger`** touches the security/quality gate, which
> the self-improvement loop must **never** edit. Those three were scoped **by human
> hand** during the migration; `/owl:evolve` only **records the transition**
> (`least-privilege-tool-scopes`: deferred → in-progress, human-directed, pending
> merge) and never edits them itself. The loop re-opens this id for a loop-driven
> accept only if a concrete, carve-out-safe atomic slice remains for a **non-carve-out**
> agent after the migration merges.

**Net:** the token-axis mechanisms stay as enrichment; the privilege axis is
transitioning from unenforceable-prose to harness-enforced reality, deliberately
outside the loop, with the security-gate agents fenced by the carve-out.

## Related

- [[context-engineering]] — the parent budget principle; on-demand tool loading is the
  same just-in-time / progressive-disclosure move applied to tools.
- [[role-decomposition]] — per-agent allowlists are the capability side of narrow,
  single-owner role charters.
- **Sources:** [[writing-tools-for-agents]] · [[advanced-tool-use]] ·
  [[code-execution-mcp]] · [[desktop-extensions]]
- **Ledger / decisions:** [[ledger]] (`least-privilege-tool-scopes`,
  `just-in-time-context-loading`, `agent-frontmatter-fields`) · [[overview]]
