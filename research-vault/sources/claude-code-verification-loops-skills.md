---
title: "Building Verification Loops in Claude Code with Skills"
type: source
tags: [verification, skills, self-improvement, evaluation, claude-code, loops]
sources: 1
updated: 2026-08-07
---
**Source:** [Building Verification Loops in Claude Code with Skills](https://claude.com/blog/building-verification-loops-in-claude-code-with-skills) · **Type:** blog · **Stars/credibility:** first-party (Claude Code team) · primary
**Author / Org:** Delba de Oliveira (Claude Code team, Anthropic)
**Published:** 2026-07-22  ·  **Ingested:** 2026-08-07 (human-directed, via `claude.com/blog` — a domain the pipeline was not previously searching)

## Summary
Argues that the agentic coding cycle (gather context → act → verify → loop) has one stage that is still mostly manual: verification. Claude already consumes deterministic signals for free (type checker, linter, tests, runtime errors); every project-specific check beyond that depends on a human remembering to ask. The piece's thesis is that those checks should be **packaged as skills** so they run every session, and it lays out four escalating invocation patterns for doing so.

## Key points
- Defines the pattern as a repeating cycle in which the agent checks its own work — tests, linters, custom checks — and fixes failures before moving on.
- **Trigger for writing one:** notice the identical small correction you make after *every* feature Claude ships. That repeated manual follow-up IS the skill.
- **Checks need not be fuzzy.** The article's own example of a deterministic, project-specific rule no generic linter catches: reject any migration that drops a column without a backfill step.
- **How to author:** write the procedure in plain English, framed as onboarding instructions for a new teammate on day one. If you can't articulate it, ask Claude for the generic best practice and then edit — *the deviations from generic are the valuable part*.
- **Built-in surfaces before you build your own:** the `/verify` skill; the toolchain (list build/test commands in CLAUDE.md so Claude doesn't guess); Code Review (research preview, multi-agent PR review, `@claude` on a finding); GitHub Actions firing a verification skill on push/PR; spec-validation against a repo markdown spec; rubrics in Managed Agents (beta), where a separate grader agent scores outcomes and failures route back for rework automatically.
- **Four invocation patterns**, in escalating automation:
  1. **Standalone** — you invoke it deliberately after the artifact exists. Good for cross-cutting/occasional checks (pre-commit security scan, pre-PR a11y audit, license headers). Cost: each run is a turn you must remember. Running it after every change ⇒ promote it.
  2. **Embedded** — appended to the producing skill's own body, so it fires automatically (`After creating the component file, run eslint on it and address any errors before reporting completion.`). Only works on skills you can edit; built-in/plugin skills get overwritten on update ⇒ chain those instead. Skip embedding for checks spanning multiple workflows.
  3. **Chained** — one skill invokes the next at completion. Reported as the Claude Code team's daily practice: `/code-review` finds bugs → `/simplify` cleans the diff → `/verify` confirms end-to-end → a custom `/design` skill checks DESIGN.md when UI changed. Chaining also *wraps* skills you cannot modify. Framing: a habit becomes a contract. Trade-off stated explicitly — chaining trades flexibility for automation, and chains can increase token spend, so test first.
  4. **On every PR** — once the chain is stable, run it on all PRs so teammates clear the same gates regardless of diligence. Converts personal infrastructure into team infrastructure. Hold off while the chain is still changing, since every tweak becomes team-visible.
- **Frontmatter shape shown** for a verification skill: `name`, `description` (with an explicit *when to use* — "Use when the diff touches error handling or logging"), and `allowed-tools: [Read, Edit, Grep]` — i.e. the check is tool-scoped to what it needs.
- **Verification that the skill took:** run it on a fresh task and watch for the new step in the output. If the step is absent, the description or the earlier instructions aren't pulling it in.
- Closing argument: the more checks are encoded, the closer Claude lands to intent on the first attempt; the corrections you stop making by hand free attention for work no skill can capture.

## Informs (ideas / patterns)
- [[evaluation-and-fitness]] — the grader/rubric return-gate appears here as a shipped product surface (Managed Agents rubrics: separate grader agent, automatic route-back on failure), not just a paper pattern.
- [[self-improvement-and-memory]] — "encode the correction you keep making by hand" is a concrete, markdown-expressible mechanism for turning repeated human feedback into durable convention.
- [[single-agent-coding-loops]] — names verification as the weakest stage of the gather→act→verify cycle and gives four ways to harden it.
- [[guardrails-and-safety]] — `allowed-tools` on a verification skill = least-privilege applied to the checker itself.
- [[handoff-and-orchestration]] — the chained pattern is a fixed, deterministic sequence of skills, i.e. a pipeline expressed purely in markdown.

## Notable quotes
_Scope: **only** the fragments retrieved on the targeted ADR-013 confirmation fetch of 2026-08-07 are recorded as verbatim. The rest of this page remains summarizer-derived paraphrase — do not promote any other sentence to a quote without its own re-fetch._

> "Pick the manual follow-up you did most often this week."

Retrieved verbatim (curator, 2026-08-07) as the opening item of the article's process list. The companion drafting rule — write the procedure in plain English, the way you would hand it to a new teammate on day one — was confirmed in the same fetch. Together these are the verified basis of [[encode-the-repeated-correction]] (accepted 75).

## Gaps / open questions
- Full-read **still pending** for the rest of the page. The 2026-08-07 fetch was targeted at one claim (ADR-013), not a full read; every other sentence here remains paraphrase-grade.
- The article asserts chains "can increase token spend" but gives no measured figure — unknown what a 4-skill chain costs versus the same checks run standalone.
- `allowed-tools` is shown in a SKILL.md frontmatter; unclear whether it is *enforced* by the harness for skills the way `tools`/`disallowedTools` are for subagents (see [[claude-code-subagents]] — that distinction is exactly what pinned `least-privilege-tool-scopes` at 66 in the ledger). Not resolved by this source.
- No guidance on what happens when two chained skills disagree (e.g. `/simplify` undoes what a verification skill required).

## Related
- [[claude-code-loops-getting-started]] — the companion piece; this article is the deep dive on the *verification* stage that the loops article names as the turn-based loop's hand-off point.
- [[anthropic-agent-skills]] · [[claude-code-subagents]] · [[claude-code-best-practices]] · [[anthropic-demystifying-evals]] · [[claude-code-agent-teams]]
- [[scout-notes-2026-08-07]]
