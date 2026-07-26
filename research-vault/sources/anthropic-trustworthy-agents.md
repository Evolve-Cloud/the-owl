---
title: "Anthropic — Trustworthy Agents in Practice"
type: source
tags: []
sources: 1
updated: 2026-07-26
---
**Source:** [Anthropic — Trustworthy Agents in Practice](https://www.anthropic.com/research/trustworthy-agents) · **Type:** blog · **Stars/credibility:** n/a · primary
**Author / Org:** Anthropic  ·  **Published:** unknown  ·  **Ingested:** 2026-07-26

## Summary
Anthropic's guidance on safe agent deployment: scope tool/data access per agent, tier approval requirements by consequence (routine actions auto-allowed, consequential ones need sign-off), and layer defenses for prompt-injection/irreversible-action risk since no single safeguard is sufficient alone.

## Key points
- Least-privilege framing: users/operators should "think carefully about which tools and data they provide to an agent, which permissions they grant, and which environments they let the agents operate in" (paraphrase — source exceeds quotable length).
- Tiered approval: "always allow, needs approval, block" per action type — routine (read a calendar) vs. consequential (send an invitation) get different defaults.
- Claude Code's Plan Mode is cited as a pattern for approving an overall *strategy* up front rather than every step — reduces approval friction while preserving the ability to intervene mid-execution.
- Layered defense for prompt injection specifically: "no single line of defense is enough to guarantee protection" — model training + production monitoring + red-teaming together.
- Trained judgment as a complement to hard gates: favors the model "raising concerns, seeking clarification, or declining to proceed" over acting on unverified assumptions.

## Informs (ideas / patterns)
- `least-privilege-tool-scopes` (deferred, no dedicated page — see [[ledger]]; brief's id `least-privilege-tools` aliased to this) — direct primary-source support; matches the-owl's own carve-out model (NFR-SEC-1: sentinel/guardian/challenger/config are un-editable by the loop) as an instance of scoped permissions.
- `human-approval-gates` (deferred, no dedicated page — see [[ledger]]) — the "approve the plan, not every step" framing matches how `/owl:evolve` already gates on the L4 review (guardian/sentinel/challenger) rather than per-edit approval, and how `landing: pr` (shadow) is itself a plan-level approval gate before `main`.

## Notable quotes
> "no single line of defense is enough to guarantee protection"

## Gaps / open questions
- Vendor guidance, not an independent red-team study; doesn't give a concrete rubric for classifying "consequential" vs "routine" beyond examples.

## Related
[[research-brief-2026-07-26]] · [[anthropic-building-effective-agents]] · [[anthropic-demystifying-evals]]
