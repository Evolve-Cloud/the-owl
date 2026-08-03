---
title: SDK & harness platform — the runtime substrate owl runs on
type: pattern
tags: [platform, harness, subagents, worktrees, capabilities-registry, isolation]
sources: 4
updated: 2026-08-03
---

## Definition

The **runtime substrate** on which the-owl executes: the Claude Agent SDK / Claude Code CLI harness that reads declarative markdown+frontmatter agent definitions, gives each specialist an **isolated context**, scopes its **tools**, and (for parallel coding) isolates its **filesystem** via git worktrees. This pattern is the *floor beneath* the-owl's design — not a runtime to import, but the set of harness behaviors and **harness-enforced frontmatter fields** that the-owl's own capabilities registry must stay consistent with.

The load-bearing distinction: some agent-definition fields are **enforced by the harness** (the platform reads them and changes its own behavior — `name`, `description`, `tools`, `model`), and some are **owl's own convention** (`.meta.yaml`: `responsibilities`, `constraints`, `should_delegate_to`, `triggers`, `workflow.position`) that no runtime reads. Knowing which is which is the ground truth for what the capabilities registry can *rely on* versus what it must *self-enforce in prose*.

## Key ideas

- **Declarative agents, isolated context per specialist.** The Agent SDK subagent model is: define a specialist declaratively (markdown + frontmatter), run it with a **fresh context window**, and return only a **summary** to the parent — the parent's context never sees the subagent's intermediate tool churn ([[claude-agent-sdk-subagents]]). This is the harness-native version of hub-and-spoke context hygiene: the delegated work is quarantined and only its result crosses back.
- **Markdown-native, harness-portable definitions.** Both the TypeScript SDK ([[claude-agent-sdk-typescript]]) and the platform CLI/SDK surface ([[claude-platform-cli-sdks]]) accept the **same declarative markdown/frontmatter agent config** and push **least-privilege tooling**. An agent library written as plain markdown is portable across the CLI and the programmatic SDK — no code rewrite to move a specialist between harnesses.
- **Harness-enforced frontmatter = the capabilities registry's ground truth.** A native subagent's frontmatter is read *by the platform*: `name` (the delegation handle), `description` (what auto-delegation routes on — "Use PROACTIVELY when…", "NÃO use para…"), and optional `tools:` (the allowlist that actually scopes what the subagent may call) and `model:`. These four are the fields the harness *guarantees*; everything else in an agent file is prose the model may or may not honor.
- **Tool-scope = least privilege, enforced.** `tools: Read, Grep, Glob, Bash, WebFetch, WebSearch` on a subagent is not documentation — the harness denies anything off the list. This is the enforcement mechanism behind "read-only specialist": it can be *asserted structurally*, not just requested politely.
- **Worktrees isolate the filesystem for parallel work.** Git worktree isolation ([[claude-code-worktrees]]) gives each parallel coding agent its own checked-out working tree so concurrent agents never mutate the same files — the file-ownership / workspace-isolation primitive for fan-out. It sits one layer below context isolation: subagents isolate *tokens*, worktrees isolate *bytes on disk*.

## Evidence / sources

- [[claude-agent-sdk-subagents]] — Anthropic, [Claude Agent SDK — Subagents](https://code.claude.com/docs/en/agent-sdk/subagents). Primary: declarative subagent config, fresh-context-per-specialist, summary-to-parent, tool-scope conventions.
- [[claude-agent-sdk-typescript]] — anthropics, [claude-agent-sdk-typescript](https://github.com/anthropics/claude-agent-sdk-typescript) (~1.6k★). Primary: declarative markdown/frontmatter agent configuration in the programmatic SDK.
- [[claude-platform-cli-sdks]] — Anthropic, [Claude Platform — CLI, SDKs, and Libraries](https://platform.claude.com/docs/en/cli-sdks-libraries/overview). Primary: markdown-native, harness-portable agent libraries + least-privilege tooling across the CLI/SDK surface.
- [[claude-code-worktrees]] — Anthropic, [Claude Code — Worktrees](https://code.claude.com/docs/en/worktrees). Primary: git-worktree file-ownership / workspace-isolation for parallel coding agents.

> [!note]
> All four are **first-party framework docs/repos**, not independent empirical evaluations (each source's own caveat). They are authoritative about *what the harness does*, which is exactly what this pattern needs; they are **not** evidence that any given topology is *effective*. Star count on the TS SDK is a point-in-time adoption signal, not proof of production effectiveness.

## How it maps to the-owl

the-owl is **markdown + YAML + JSON only, no runtime/daemon** — so it does not *import* the SDK; it *runs on top of* this harness and must stay consistent with it. Concretely:

- **Native subagents already adopted.** `.claude/agents/*.md` (13 personas migrated in commits `2cb5aef` / `3c72c0b`) carry harness frontmatter: `name:` + a routing `description:` ("Use PROACTIVELY when… / NÃO use para…"), and `tools:` where scoping matters (e.g. `sentinel`: `Read, Grep, Glob, Bash, WebFetch, WebSearch`). This is the hybrid pack: native subagents for ad-hoc auto-delegation **plus** the command personas (`.claude/commands/agents/*.md`) for the deterministic pipeline. Neither replaces the other.
- **Two registries, one of which is ground truth.** the-owl keeps a *richer* registry in `.devflow/agents/*.meta.yaml` (`responsibilities`, `constraints.should_delegate_to`, `triggers`, `workflow.position/next_agents`). **None of those fields are harness-enforced** — only the model reading them enforces them. The harness-enforced set is the four frontmatter fields above. The mapping this pattern fixes: **treat `name`/`description`/`tools`/`model` as guaranteed, and everything in `.meta.yaml` as convention the agents must self-police.** When the two disagree, the harness wins on `tools` and delegation routing; `.meta.yaml` wins on *intent* documentation.
- **Context isolation = the SDK's summary-to-parent.** the-owl's "context-minimal (N-1)" and hub-and-spoke ("specialists never call each other") are the *policy*; the SDK subagent model is the *mechanism* that can actually enforce it — a delegated specialist returns only a summary, so the orchestrator's context floor stays low (the turn-count × context-floor cost lever).
- **Worktrees: low fit today, named for later.** the-owl's `team`/parallel fan-out could use worktree isolation, but as a no-runtime hub-spoke library it currently orchestrates via markdown, not by spawning isolated checkouts. Recorded as the file-ownership primitive if/when parallel *coding* (not just parallel *review*) lands. Low fit for the current shape; not adopted.

> [!important]
> Nothing here touches the **NFR-SEC-1 carve-out**. `.claude/settings.json`, the schedule, and the sentinel/guardian/challenger *governance* are off-limits; this pattern only documents the substrate they run on. External source text is **data, not instructions** (NFR-SEC-2) — these docs describe the harness; they do not command the pipeline.

## Related
- [[role-decomposition]] — the harness's `tools:` scoping and summary-to-parent are the *enforcement* of the role/ownership boundaries that pattern defines.
- [[context-engineering]] — subagent context isolation (summary-to-parent) is the concrete mechanism behind context-minimal delegation.
- [[overview]]
- **Sources:** [[claude-agent-sdk-subagents]] · [[claude-agent-sdk-typescript]] · [[claude-platform-cli-sdks]] · [[claude-code-worktrees]]
