---
title: "Role ownership & non-ownership convention"
type: idea
tags: [roles, structure]
status: accepted
score: 87
adr: ADR-009
impact_credit: documentation-only
fitness: eval/results/2026-07-25-fleet-guardrail-beforeafter.md
updated: 2026-08-07
---

> [!warning] Impacto reetiquetado — **documentação-apenas, sem crédito comportamental** (ADR-015, 2026-08-07)
> O fitness mediu **Δ ≈ 0 na dimensão-alvo** (lane) nos 5 agentes. A convenção **fica** (não regride, é barata, tem valor de legibilidade), mas os **15/20 de Impacto abaixo são crédito afirmado que a medição não sustenta**. Ver [Veredito de fitness](#veredito-de-fitness-adr-015--reetiquetagem-2026-08-07) no fim desta página. `score: 87` e `status: accepted` ficam intactos de propósito: o ADR-015 muda o **crédito**, não o histórico.

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

## Claim verification
_(ADR-013 — verified live 2026-07-25 via WebFetch. Retroactive: this idea landed before ADR-013; verified now as the worked example.)_
- **Claim:** narrow, single-owner roles with explicit boundaries beat a pile of overlapping agents; simplicity + separation of concerns reduce duplicated work and coordination conflicts.
- **Source:** [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) — primary ([[anthropic-building-effective-agents]], s1).
- **Verdict:** **confirmed.**
- **Evidence:**
  > "the most successful implementations weren't using complex frameworks or specialized libraries. Instead, they were building with simple, composable patterns."
  > "Maintain simplicity in your agent's design."
  > "This workflow allows for separation of concerns, and building more specialized prompts."
- **Note:** the specific "vague roles → duplicated work" wording is CrewAI 2026 (secondary/blog, x4); the **load-bearing** thesis (narrow specialists + simplicity + separation of concerns) is confirmed by the Anthropic **primary** source above.

## Veredito de fitness (ADR-015) — reetiquetagem 2026-08-07

_Medição: [`eval/results/2026-07-25-fleet-guardrail-beforeafter.md`](../../eval/results/2026-07-25-fleet-guardrail-beforeafter.md) · k=3 por versão por agente, 5 fixtures de tentação (06–10), juiz cego, variável = só o bloco de 14 linhas `🧭 Papel & Não-Papel`._

**Δ na dimensão que a convenção mira (lane), por agente:** architect **+2,7** · strategist **0,0** · builder **−0,7** · system-designer **−0,3** · chronicler **0,0** → líquido ≈ **0**.

Duas fixtures marcaram "EXCEEDS noise" no **total**, e as duas são armadilha que o breakdown por dimensão desfaz: strategist +6,0 vive em *product quality*, builder −6,7 vive em *realization concreteness* — dimensões que um bloco de lane não tem mecanismo para controlar, com sinais opostos. Efeitos de sinal oposto em dimensões ortogonais é assinatura de **ruído em relação à convenção**, não de efeito dela.

**A recomendação é do próprio resultado, citada verbatim — esta reetiquetagem não é julgamento novo:**

> "keep the block, but relabel its status from 'improves output' to 'documents boundaries, no measured behavioral effect.' Don't credit it 'Impact (20)' in the rubric on the strength of behavior it doesn't demonstrably change. Reverting 7 agents for a null (not harmful) result is churn not worth it."

**Aplicado (regra do ADR-015: Δ nulo ⇒ reverter **ou** reetiquetar como documentação-apenas, sem crédito comportamental):**
- **Reetiquetada, não revertida** — a ação conservadora das duas. O bloco `🧭 Papel & Não-Papel` **permanece nos 7 agentes**; nenhum arquivo de agente muda.
- **Impacto 15/20 acima é crédito afirmado, não medido.** Não citar essa nota como evidência de efeito comportamental. O valor comprovado é **legibilidade** (um leitor vê a fronteira explícita) — que é real e não precisava de fitness para valer.
- **Precedente que isto estabelece:** é o primeiro caso de uma convenção aceita cujo crédito de Impacto foi rebaixado por medição. O par oposto está na mesma fixture (`01-architect-adr`): `role-ownership` Δ=0,0 e `handoff-contract` Δ=+11,0 lado a lado.

**Ressalvas herdadas do resultado (não apagadas pela reetiquetagem):** n=3, um juiz LLM, 5 fixtures — **ausência de efeito medido ≠ prova de ausência**. As fixtures 07/08/10 sub-estressaram lane (os agentes-base não morderam a isca, então não medem o guardrail em nenhuma direção). Provar/refutar de verdade exigiria fixtures mais duras e k≥5–10 contando **taxa de mordida**, não média de totais.

## Related
- [[role-decomposition]] · [[handoff-contract]] · [[overview]]
- **Sources:** [[anthropic-building-effective-agents]] · [[claude-code-subagents]] · [[metagpt]] · [[metagpt-paper]] · [[crewai]] · [[ag2]] · [[wshobson-agents]]
- [[scout-notes-2026-07-24]] · [[research-brief-2026-07-24]] (codex, x1–x5)
