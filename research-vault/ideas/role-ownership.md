---
title: "Role ownership & non-ownership convention"
type: idea
tags: [roles, structure]
status: accepted
score: 87
adr: ADR-009
updated: 2026-07-24
---

**Category:** roles · **Confidence:** high · **Applicability:** 5/5

Canonical accept for the field's **narrow-single-owner-roles** pattern. Merges the codex brief `narrow-single-owner-roles` (2026-07-24) with the previously **deferred** ledger id `explicit-role-boundaries` (cycle 2026-07-23, score 84 — deferred only by the circuit-breaker cap). Today's brief + scout live research provide the "more evidence" that promotes it from deferred → accepted.

## Pattern
Every agent declares a narrow responsibility with an explicit **ownership boundary**: what it *owns* (decision rights + the single artifact it returns), what it explicitly does *not* own (forbidden overlap → which agent owns that instead), its required inputs, and its done-criteria. The field's convergent finding: *titles without ownership/exclusions/acceptance-criteria create overlapping work* — "vague roles, overlapping responsibilities, and unclear goals create conflicts where agents duplicate work or pass tasks endlessly" (CrewAI 2026, x4); "a pile of overlapping agents is harder to manage than a few sharp ones" (Anthropic/PubNub, x1/x3).

## Proposed change to the-owl
Adopt a standardized **"Convenção — Papel & Não-Papel"** at `docs/conventions/role-ownership.md` (parallels `docs/conventions/handoff-contract.md`) defining the required ownership fields of every agent: **Possui** (decision rights + single artifact) · **Não possui** (forbidden overlap → owner) · **Entradas exigidas** · **Critério de pronto** · **Fonte da verdade** (`.md` prose ↔ `.meta.yaml` structured fields). Rollout into individual agents = tracked incremental follow-up (one agent per ADR), exactly like the handoff-contract rollout.

## L1.5 self-audit (grounded against the real code — ADR-005)
- **`já_implementado?`** — **Partially.** Ownership is already encoded, but **unevenly**: (a) `.meta.yaml` files carry `responsibilities.primary` (owns), `constraints.should_not_do` (non-ownership), `should_delegate_to` (routing), `outputs` (artifact); (b) the `.md` bodies carry "🎯 Minha Responsabilidade", "⛔ NUNCA FAÇA (HARD STOP)", "⚠️ Quando NÃO me usar". There is **no convention** naming this as the standard, and no uniform statement of *decision-rights on contested boundaries* or *forbidden-overlap → owner*.
- **`onde_está_o_gap`** — Two concrete gaps: (1) no `docs/conventions/role-ownership.md` unifying the pattern; (2) **scout, curator, and sentinel lack `.meta.yaml` entirely** (8 of 11 agents have it) — the structured ownership metadata is missing for exactly the loop's own newest agents. *(sentinel is inside the NFR-SEC-1 carve-out → its completion is HUMAN-only; the convention documents this, never edits sentinel.)*
- **`arquivo_alvo`** — NEW `docs/conventions/role-ownership.md` (the atomic, no-runtime, reversible edit for this cycle). Follow-up (future cycles): add ownership metadata to `scout`/`curator`; flag `sentinel` for the human.

## Curator verdict — score 87 (accept; threshold 75)
| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 24 | Pure convention; markdown-only, hub-spoke native; builds on the existing `.meta.yaml` pattern. |
| Evidence strength (20) | 18 | Anthropic primary (x3) + CrewAI/MetaGPT (x4) + brief s1/s2/s11/s19 + scout live corroboration; the failure mode is documented, not hype. |
| Impact (20) | 15 | Real (cuts overlap/ambiguity, standardizes, surfaces a concrete inconsistency); convention-first ⇒ part of the impact is deferred to the rollout (challenger caveat, tracked). |
| Simplicity & reversibility (15) | 14 | One convention doc + one ADR; atomic, trivially `git revert`. |
| Safety (10) | 10 | No attack surface; does **NOT** touch the NFR-SEC-1 carve-out (it *documents* that sentinel is human-only — it never edits it). |
| Non-duplication (10) | 6 | Ownership fields already exist in `.meta.yaml`; the convention's delta is standardization + decision-rights/forbidden-overlap + the consistency fix. Partial duplication → 6. |

**Safety sub-score 10 ≥ floor (7).** No carve-out contact. Total 87 ≥ 75 → **ACCEPTED.**
Challenger caveat (non-blocking, same as handoff-contract): a convention not yet rolled into agents has deferred impact → the rollout is the tracked next-cycle follow-up; the L1.5-surfaced meta.yaml inconsistency is the concrete near-term target.

## Related
- [[role-decomposition]] · [[handoff-contract]] · [[overview]] · sources: codex `research-brief-2026-07-24`, [[scout-notes-2026-07-24]] (x1–x5)
