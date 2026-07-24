# ADR-009 — Adopt a Role Ownership & Non-Ownership convention

**Status:** Accepted
**Date:** 2026-07-24
**Author:** @architect (via `/owl:evolve` cycle 2026-07-24, from accepted idea `role-ownership`, score 87)
**Tags:** [self-improvement, roles, conventions, agents]
**Related:** ADR-004 (handoff-contract convention), ADR-005 (gap analysis L1.5), `research-vault/ideas/role-ownership.md`, `docs/conventions/handoff-contract.md`

## Contexto
the-owl's whole premise is narrow specialists that don't overlap. The field's convergent, primary-source-backed 2026 finding is that role *labels* are insufficient: "vague roles, overlapping responsibilities, and unclear goals create conflicts where agents duplicate work or pass tasks endlessly" (CrewAI 2026), and "a pile of overlapping agents is harder to manage than a few sharp ones" (Anthropic best-practices). See `research-vault/inbox/research-brief-2026-07-24.md` (idea `narrow-single-owner-roles`, sources s1/s2/s11/s19) and `research-vault/inbox/scout-notes-2026-07-24.md` (x1/x3/x4).

The L1.5 self-audit (ADR-005) grounded this against the real code and found ownership is **already encoded, but unevenly**:
- 8/11 agents carry `.meta.yaml` with `responsibilities.primary` (owns), `constraints.should_not_do` (non-ownership), `should_delegate_to` (routing), `outputs` (the artifact) — e.g. `.claude/commands/agents/architect.meta.yaml:32-84`.
- The `.md` bodies carry ad-hoc equivalents ("🎯 Minha Responsabilidade", "⛔ NUNCA FAÇA (HARD STOP)", "⚠️ Quando NÃO me usar") — e.g. `.claude/commands/agents/strategist.md:8-24`.
- **`scout`, `curator`, `sentinel` have no `.meta.yaml` at all** — the structured ownership is missing for exactly the loop's own newest agents.

There is no convention naming this pattern as the standard, and no uniform statement of *decision-rights on contested boundaries* or *forbidden-overlap → owner*. This is the same shape as the handoff problem solved by ADR-004: a real, partly-latent practice made explicit as a convention.

## Decisão
Adopt a standardized convention at **`docs/conventions/role-ownership.md`** ("Papel & Não-Papel") that defines the ownership fields every agent must declare: **Possui** (decision rights + the single artifact it returns) · **Não possui** (forbidden overlap → which agent owns it) · **Entradas exigidas** · **Critério de pronto** · **Fonte da verdade** (the `.md` prose and the `.meta.yaml` structured fields must agree). The convention is the source of truth; **rollout into individual agents is a tracked incremental follow-up (one agent per ADR)**, exactly like the handoff-contract rollout. The convention explicitly records that `sentinel` sits inside the NFR-SEC-1 carve-out and its ownership metadata must be completed by a **human**, never by the loop.

## Alternativas consideradas
- **Alternativa A (escolhida): a convention doc only, rollout deferred.** Prós: atomic, reversible (`git revert` one file), no carve-out contact, mirrors the proven ADR-004 pattern, and standardizes an existing-but-uneven practice. Contras: convention-first means part of the impact is deferred to the rollout (the challenger's standing caveat).
- **Alternativa B: skip the convention, directly add the missing `.meta.yaml` to scout/curator this cycle.** Prós: immediate concrete consistency fix. Contras: 2+ file edits (exceeds the atomic 1-idea→1-edit norm), and without a convention the *why/standard* isn't captured — the next new agent repeats the gap. Deferred to the rollout follow-up, where it belongs.
- **Alternativa C: do nothing — ownership is "already there" in `.meta.yaml`.** Prós: zero work. Contras: it's uneven (3 agents lack it) and unnamed, so overlap/ambiguity is only prevented by convention-by-accident. Rejected: the field evidence is that this exact gap causes duplicated work.

## Consequências
- **Mais fácil:** a single named standard for ownership/non-ownership; new agents have a checklist; the `.meta.yaml`↔`.md` inconsistency (scout/curator/sentinel) is surfaced as an explicit, trackable follow-up; less risk of two agents claiming the same boundary.
- **Trade-offs aceitos:** a convention not yet rolled into agents has deferred impact (tracked, non-blocking — same as ADR-004); one more convention file to maintain in sync with `.meta.yaml`.
- **Novos riscos:** none to the security surface — the convention is pure documentation and must never itself edit carve-out agents (it only *documents* that sentinel is human-maintained).

## Notas de implementação
For @builder — a single atomic edit:
- Create **`docs/conventions/role-ownership.md`** only. Do not edit any agent `.md`/`.meta.yaml` this cycle (that is the rollout follow-up).
- Match the shape/tone of `docs/conventions/handoff-contract.md` (Por quê → o contrato/campos → regras → rollout).
- The fields table must define: Possui · Não possui (→ owner) · Entradas exigidas · Critério de pronto · Fonte da verdade (`.md` ↔ `.meta.yaml`).
- State plainly that the rollout is incremental (1 agent / ADR), that scout/curator need `.meta.yaml` added, and that **sentinel is NFR-SEC-1 carve-out → human-only** (the loop must never edit it).
- Do NOT touch: `sentinel.md`, `guardian.md`, `challenger.md`, `.owl/loop-config.yml`, `.claude/settings.json`, the schedule, `~/.ssh`, or any secret.
- ADR numbering: `006–008` are reserved by the in-flight handoff-rollout shadow PR (`owl/evolve-2026-07-23-handoff-rollout`); this cycle uses `009` to avoid collision.
