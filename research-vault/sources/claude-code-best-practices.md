---
title: "Anthropic — Best Practices for Claude Code"
type: source
tags: [claude-code, context-engineering, best-practices, subagents, skills, permissions]
sources: 1
updated: 2026-07-26
---
**Source:** [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) · **Type:** doc · **Stars/credibility:** n/a · primary
**Author / Org:** Anthropic  ·  **Published:** 2026 (undated doc page)  ·  **Ingested:** 2026-07-26 (imported from carinhAI, a separate personal vault; original ingestion/verification there predates this import)

## Summary
The official Claude Code best-practices guide synthesizes patterns from Anthropic's internal teams and engineering users. The dominant constraint is context-window management — performance degrades as context fills. Every major practice (verification, explore-plan-code workflow, subagents, `/clear` usage, CLAUDE.md design) is grounded in managing this constraint.

## Key points
- "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
- Give Claude a way to verify its work (tests, screenshots, expected outputs) — highest-leverage intervention.
- Four-phase workflow: Explore (Plan Mode, read-only) → Plan → Implement → Commit.
- CLAUDE.md design: only include things Claude can't infer from code; keep it short; prune ruthlessly; treat it like code. Hierarchy: `~/.claude/` → project root → project-local → child directories.
- Permission tiers: auto mode (classifier), allowlists (specific commands), sandboxing (OS-level).
- Skills (`SKILL.md` in `.claude/skills/`): domain knowledge loaded on demand, not in every session.
- Subagents: run in separate context windows; ideal for investigation that would pollute main context. Parallel sessions: Writer/Reviewer pattern; agent teams; fan-out with `claude -p`.
- Common failure patterns: kitchen-sink session, over-correction loop, over-specified CLAUDE.md, trust-then-verify gap, infinite exploration.
- `/clear`, `/compact`, `/rewind`, `/btw` as context-management primitives.

## Informs (ideas / patterns)
- [[context-engineering]] — session-management primitives; CLAUDE.md design principles; subagents as context isolation.
- [[agent-architectures]] — subagents for investigation; parallel sessions; Writer/Reviewer pattern; agent teams.
- [[agent-skills]] — SKILL.md in `.claude/skills/`; on-demand vs. always-loaded context.
- [[sandboxing]] — three permission tiers; auto mode; OS-level sandboxing.
- [[claude-code]] — definitive best practices; hooks; CLAUDE.md hierarchy; non-interactive mode; fan-out pattern.

## Notable quotes
> "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
> "If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run /clear and start fresh."

## Gaps / open questions
- What's the right granularity for subagent delegation vs. keeping work in the main context?
- How should teams coordinate shared CLAUDE.md files across contributors with different workflows?

## Related
- [[claude-code]] · [[context-engineering]] · [[agent-skills]] · [[claude-code-auto-mode]] · [[claude-code-sandboxing]] · [[agent-architectures]]
