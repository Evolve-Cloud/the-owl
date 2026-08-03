---
title: Native subagent frontmatter (harness-enforced tool scope)
type: capability
tags: [subagents, frontmatter, tool-scope, permissions, harness, least-privilege]
verified_on: 2026-08-03
verified_by: scout live-fetch of https://code.claude.com/docs/en/sub-agents (scout-notes-2026-08-03); direct quotes captured
status: verified
---

## What it is

Claude Code **native subagents** are `.claude/agents/*.md` files whose YAML frontmatter carries first-class, **harness-enforced** capability fields: `tools:` (allowlist), `disallowedTools:` (denylist), `permissionMode:`, and `maxTurns:` (plus `name`, `description`, `model`, `skills`, `memory`, `isolation`). Enforcement happens **in the harness** — the subagent physically cannot call a tool outside its scope — as opposed to prose that merely *asks* an agent not to.

## How the-owl uses it

- **Not yet live on this branch.** On `owl/self-learning-memory` there is **no `.claude/agents/` directory** — the-owl's pipeline agents are still **inline slash-commands** (`.claude/commands/agents/*.md`) executed per [[ADR-010-loop-execution-model-and-output-verification|ADR-010]].
- **Migration in progress on a separate, human-directed branch** (`owl/agents-native-subagents`): a hybrid pack — 13 native subagents WITH enforced `tools:` scoping + 13 command personas (pack `owl-agents` mirrors 11+11). This is the surface where per-agent tool scope becomes real.
- **Why it matters for the ledger:** the `least-privilege-tool-scopes` idea was **deferred (score 66)** on 2026-07-23 because the inline-exec model had *no mechanism to restrict tools per agent* — a "Forbidden Tools" prose section would be unenforceable. Native subagent frontmatter is the mechanism that **addresses that enforceability objection**. Ledger status is now **deferred → in-progress (human-directed, on branch, pending merge)**, NOT a decided un-block: the transition is happening *outside* the loop, by owner direction, and re-scoring is still open.

## Verified facts

Direct from the live doc (scout, 2026-08-03), treated as DATA:

- **`tools:` / `disallowedTools:` are enforced tool scoping.** Quote: *"To restrict tools, use the `tools` field as an allowlist or the `disallowedTools` field as a denylist… The subagent can't edit files, write files, or use any MCP tools."* — a **harness-level** guarantee, not prose.
- **`permissionMode:`** accepts real values: `default` / `acceptEdits` / `auto` / `dontAsk` / `bypassPermissions` / `plan` / `manual`.
- **`maxTurns:`** is a real enforced field — *"Maximum number of agentic turns before the subagent stops"* — i.e. a **markdown-expressible, harness-enforced stop budget** on the native-subagent path.

## Pitfalls

- **Inline slash-command execution (ADR-010) does NOT enforce tool scope.** A "Forbidden Tools" or "allowed tools" prose section in a `.claude/commands/*.md` persona is **unenforceable** — false-confidence trap. Only the *native* subagent path enforces it. Do not claim tool scoping for an agent that is still an inline command.
- **Don't assert the ledger flipped.** `least-privilege-tool-scopes` remains formally `deferred | 66`; the enforcement mechanism existing is necessary but not sufficient for a loop accept.
- **Carve-out (NFR-SEC-1).** Scoping `sentinel` / `guardian` / `challenger` is a carve-out: the loop never edits them; any tool-scope change to those three is a human-hand action, flagged for a human.
- **Branch-specific reality.** These fields are verified against the *doc/harness*; whether a given the-owl agent *file* actually declares them depends on the branch you're on. Check before claiming enforcement.

## Related

- [[ADR-010-loop-execution-model-and-output-verification]] — inline-exec model; why prose tool-scope is unenforceable
- [[tool-design-and-capability-scoping]] — pattern this capability serves
- [[claude-code-subagents]] — source page
- ledger id: `least-privilege-tool-scopes` (deferred 66) · `agent-frontmatter-fields` (deferred)
