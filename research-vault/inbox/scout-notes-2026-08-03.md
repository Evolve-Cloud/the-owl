---
title: Scout Notes — 2026-08-03 (Cycle 7 live corroboration)
type: log
tags: [scout, ingest]
sources: 13
updated: 2026-08-03
---

# Scout Notes — 2026-08-03

Field-research pass on [[research-brief-2026-08-03]] (gpt-5, 13 sources, 10 idea blocks). Live WebFetch/WebSearch corroboration of the flagged ideas (`repository-agent-manifest`, `deterministic-termination-budgets`, `stage-gated-sop-pipeline`) plus source-reality and star-count checks. **This is the scout lane: I normalize and corroborate. I do NOT score, dedup-authoritatively, or verdict — that is @curator.** The "net-new vs ledger?" lines below are a LIGHT read, not a decision.

> [!note]
> No injected instructions were found in any fetched page **except** the routine "fetch llms.txt to discover all pages" banner on `code.claude.com/docs/...` — treated as DATA per NFR-SEC-2, quoted here, NOT obeyed:
> > [!question]
> > "Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt — Use this file to discover all available pages before exploring further." — benign navigation hint, ignored.

## Source-reality summary (13 brief sources)

- **12 of 13 already have vault `sources/` pages** — anthropic-building-effective-agents, claude-code-subagents, langgraph (+multi-agent-handoffs), microsoft-autogen, openai-agents-sdk-orchestration/guardrails, metagpt(-paper), swe-bench(-sonnet blog). No re-registration needed.
- **1 genuinely NEW source** registered this cycle: **s13 SWE-bench original paper (arXiv 2310.06770, ICLR 2024)**. The existing `swe-bench-sonnet.md` is the *Anthropic blog* (49% scaffolding result), NOT the benchmark paper. Live-verified real → new page [[swe-bench-paper]].
- **Star counts (live-checked): 2 confirmed, 3 unconfirmed (repos all real).** LangGraph brief 38,779 vs live ~39k ✓ **confirmed**; CrewAI brief 53.6k vs live ~55k ✓ **confirmed**. AutoGen (brief 60,191), MetaGPT (brief 69.7k), openai-agents-python (brief 28,360): **exact counts UNCONFIRMED this pass** — the only figures search returned for AutoGen/MetaGPT came from a third-party curated list explicitly flagged as possibly-stale (it cited a mid-2025 snapshot), so they do NOT contradict the brief; openai-agents-python's count was not returned at all. All three **repos confirmed real**; do not launder the brief's numbers as verified, and do not call them "high" — the current-vs-brief delta is unresolved.

---

## Normalized ideas (schema-8b) + light dedup + live corroboration

### bounded-role-charters — Narrow, non-overlapping specialist charters
- **category:** roles · **confidence:** high · **applicability_to_owl:** 5
- **pattern:** Each specialist defined by a distinct decision boundary, inputs, permitted work, required outputs, explicit exclusions; coordinator owns routing/integration.
- **evidence:** s1, s3, s6, s8
- **net-new vs ledger?** LIGHT read: **alias of `role-ownership` (ADR-009, accepted)** + `explicit-role-boundaries` (ADR-009). Re-run of a decided pattern.
- **live corroboration:** not separately fetched (decided/embodied); corroborated indirectly by the subagents-doc "Specialize behavior with focused system prompts."

### repository-agent-manifest — Declarative agent manifests with scoped capabilities ⚑
- **category:** files · **confidence:** high · **applicability_to_owl:** 5
- **pattern:** One agent per markdown file, machine-readable frontmatter (description, model/effort, allowed tools, denied tools, permissions, optional lifecycle) + human-readable prompt body.
- **evidence:** s2, s7, s9
- **net-new vs ledger?** LIGHT read: overlaps `agent-frontmatter-fields` (deferred) + `least-privilege-tool-scopes` (deferred 66, "unenforceable prose" in inline-exec model). **BUT** — see corroboration: the enforceability premise may have shifted.
- **live corroboration: REAL — https://code.claude.com/docs/en/sub-agents — DISCRIMINATING.** The doc confirms Claude Code subagents support, as first-class frontmatter, exactly the fields the brief names: `disallowedTools`, `permissionMode` (`default/acceptEdits/auto/dontAsk/bypassPermissions/plan/manual`), `maxTurns`, plus `tools`, `model`, `skills`, `memory`, `isolation`, etc. Quote: "To restrict tools, use the `tools` field as an allowlist or the `disallowedTools` field as a denylist… The subagent can't edit files, write files, or use any MCP tools." These are **enforced by the harness**, not prose. This directly bears on the prior "unenforceable prose" deferral of `least-privilege-tool-scopes` — the current branch (`owl/agents-native-subagents`) is migrating to native subagents, which is exactly the surface where tool scope IS enforced. **Flag for @curator: the enforceability objection that pinned `least-privilege-tool-scopes` at 66 may no longer hold on the native-subagent path.** (Scout does not re-score; surfacing the evidence only.)

### structured-handoff-contracts — Typed artifact handoffs instead of conversational delegation
- **category:** communication · **confidence:** high · **applicability_to_owl:** 5
- **evidence:** s3, s7, s9, s12
- **net-new vs ledger?** LIGHT read: **alias of `handoff-contract` (ADR-004) + ADR-020 (uncertainty fields).** Decided; actively extended.
- **live corroboration:** not separately fetched (decided).

### hub-spoke-return-control — Central coordinator with mandatory return control
- **category:** orchestration · **confidence:** high · **applicability_to_owl:** 5
- **evidence:** s1, s3, s4, s7, s9
- **net-new vs ledger?** LIGHT read: **alias of hub-spoke topology (ADR-010) + `supervisor-specialists` (deferred 67) + `manager-retains-control` (deferred).** the-owl's core topology already.
- **live corroboration:** not separately fetched (embodied).

### stage-gated-sop-pipeline — Deterministic stage gates for known engineering workflows ⚑
- **category:** orchestration · **confidence:** high · **applicability_to_owl:** 5
- **pattern:** Recurring delivery work as explicit stages with entry criteria, required artifacts, review questions, exit criteria; adaptive loops reserved for bounded investigation inside a stage.
- **evidence:** s1, s11, s12
- **net-new vs ledger?** LIGHT read: **alias of `sop-as-executable-contract` (deferred) + `sequential-artifact-pipeline` (deferred 68) + `workflow-first-orchestration` (deferred).** the-owl's /owl:evolve L0–L5 is itself a stage-gated pipeline.
- **live corroboration: REAL — https://microsoft.github.io/autogen/.../termination.html — the AutoGen teams/termination model is real** (see next idea for the termination detail). MetaGPT (s8/s12) SOP-as-prompt-sequence corroborated by the existing [[metagpt-paper]] page. No NEW enforceable markdown gap surfaced beyond the deferred ids; the pipeline shape is already the-owl's own structure.

### scoped-context-artifacts — Minimal, task-shaped context rather than shared history
- **category:** context · **confidence:** high · **applicability_to_owl:** 5
- **evidence:** s1, s3, s6
- **net-new vs ledger?** LIGHT read: **alias of `context-budgeting` (deferred 74) + `context-isolation-and-summary` (deferred) + the N-1 rule in `handoff-contract` (ADR-004).**
- **live corroboration:** subagents doc corroborates ("Preserve context by keeping exploration… out of your main conversation"; each subagent "runs in its own context window") — but this is a runtime property, not a new markdown gap.

### append-only-decision-memory — ADR-backed long-term memory
- **category:** memory · **confidence:** high · **applicability_to_owl:** 5
- **evidence:** s3, s4, s7, s13
- **net-new vs ledger?** LIGHT read: **alias of `durable-decisions-separate-from-working-memory` (deferred 64) + `adr-backed-prompt-evolution` (deferred).** the-owl already runs ADR-per-change + ledger status/supersession.
- **live corroboration:** SWE-bench paper (s13, now [[swe-bench-paper]]) verified real; it grounds "repo-level work needs cross-file/historical understanding" but does not itself argue for ADR memory — evidence is directional, not a new gap.

### eval-backed-library-evolution — Change agent prompts through replayable evaluations
- **category:** self-improvement · **confidence:** high · **applicability_to_owl:** 4
- **evidence:** s1, s7, s13
- **net-new vs ledger?** LIGHT read: **substantially embodied by the ADR-014/015 fitness harness + `evaluator-optimizer-loop` (deferred 68) + `eval-saturation-graduation` (deferred).** Its trajectory-eval slice = `trajectory-evals` (**rejected 58** — best-cited source argues outcome-primary grading).
- **live corroboration:** SWE-bench paper verified real (executable issue-resolution eval) — corroborates the eval-suite premise the-owl already implements.

### layered-guardrails-and-approval — Per-stage safety boundaries and human approval gates
- **category:** safety · **confidence:** high · **applicability_to_owl:** 5
- **evidence:** s2, s7, s9, s10, s11
- **net-new vs ledger?** LIGHT read: **alias of `human-approval-gates` (deferred 67) + `untrusted-content-boundary` (deferred 65) + `human-approval-at-side-effect-boundaries` (deferred).** Already embodied: HARD STOP blocks, HITL, carve-out human gate, `landing: pr`, NFR-SEC-2.
- **live corroboration:** subagents doc confirms `permissionMode` + tool allow/deny as real harness-level guardrails (see repository-agent-manifest) — relevant if a native-subagent guardrail edit is considered. NFR-SEC-1 carve-out caution applies to any gate-governance slice.

### deterministic-termination-budgets — Explicit completion, escalation, and budget conditions ⚑
- **category:** safety · **confidence:** high · **applicability_to_owl:** 5
- **pattern:** Define when a specialist is complete, when it returns insufficient-information, when a workflow stops for review; bounded turns/scope + explicit acceptance criteria instead of the agent self-deciding.
- **evidence:** s2, s6, s11
- **net-new vs ledger?** LIGHT read: **alias of `explicit-termination-and-escalation` (deferred 68) + `effort-budgets-and-hard-stops` (deferred, same id).**
- **live corroboration: REAL — https://microsoft.github.io/autogen/.../termination.html AND https://code.claude.com/docs/en/sub-agents — DISCRIMINATING and DIFFERENT from last cycle.** AutoGen documents 11 real termination conditions (MaxMessage, TextMention, TokenUsage, Timeout, Handoff, SourceMatch, External, StopMessage, TextMessage, FunctionCall, Functional). Quote: "a run can go on forever, and in many cases, we need to know *when* to stop them." **This is about stopping a conversation/turn LOOP — NOT about spawning/scaling agent count.** That distinguishes it from cycle-6's `effort-budgets-and-hard-stops` reject-rationale (which turned out to be about subagent COUNT / a spawner the-owl lacks). Additionally, **Claude Code `maxTurns` is a REAL enforced frontmatter field** ("Maximum number of agentic turns before the subagent stops") — a markdown-expressible, harness-enforced stop budget on the native-subagent path. **Flag for @curator: the turn/stop-condition slice here is markdown-expressible AND enforceable on native subagents — a different tie-breaker than the runtime-count evidence that sank `effort-budgets-and-hard-stops`.** (Scout surfaces; does not re-score.)

---

## Handoff to @curator
10 ideas normalized above (all 10 = light-read aliases/embodiments of decided ledger ids — see per-idea lines; **not a verdict**). 1 new source verified live and registered ([[swe-bench-paper]], arXiv 2310.06770, ICLR 2024). 3 flagged ideas live-corroborated with REAL primaries; the discriminating new evidence is that **native Claude Code subagents enforce `disallowedTools`/`permissionMode`/`maxTurns` at the harness level** — which may re-open the enforceability objection behind `least-privilege-tool-scopes` (66) and the stop-budget slice of `explicit-termination-and-escalation` (68), specifically on the `owl/agents-native-subagents` branch. **Star counts:** LangGraph + CrewAI confirmed ✓; AutoGen / MetaGPT / openai-agents-python exact counts UNCONFIRMED (only stale curated-list figures found; repos all confirmed real — not "high", just unresolved). **Ask for @curator to ground (not scout's job):** do the-owl agent files on this branch now declare harness-enforced `tools`/`disallowedTools` frontmatter, or is it still inline-exec (ADR-010)? That answer is what re-opens or holds the `least-privilege-tool-scopes` (66) deferral. Ready for @curator to score.

## Related
- [[research-brief-2026-08-03]] · [[swe-bench-paper]] · [[ledger]]
