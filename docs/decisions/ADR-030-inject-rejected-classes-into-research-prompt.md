# ADR-030 — Inject rejected *classes* into the research prompt, not just decided *ids*

**Status:** Accepted
**Date:** 2026-08-07
**Author:** @architect (owner-directed, from the loop-health review)
**Tags:** [research, retrieve-delta, targeting, cost]
**Related:** ADR-022 (**this extends it**), ADR-001 (carve-out), ADR-005 (L1.5 grounding), ADR-013 (claim verification)

## Contexto

ADR-022 fixed a real problem: codex was re-surveying settled SOTA every cycle, so the skill now retrieves the **decided-id table** from `ledger.md` and injects it as an exclusion list. It worked — cycle 8's brief returned 1 idea with **0 collisions** against 44 injected ids, and no padding.

But it fixed duplication by **id**, and the loop's dominant rejection pattern is by **class**. Grounded count in `ledger.md`: **8 mentions** of the same disqualifier — *runtime-shaped / presupposes a runtime the-owl lacks*. The individual verdicts:

| id | score | outcome |
|---|---|---|
| `isolated-workspaces-for-parallel-coding` | 41 | rejected |
| `evaluator-gated-termination` | 45 | rejected (also safety veto) |
| `chained-verification-skills` | 50 | rejected |
| `parallel-independent-work` | 52 | rejected |
| `explicit-termination-and-escalation` | 68 | deferred **twice** |

Every one is a *different id*, so the ADR-022 exclusion list correctly lets them through. Codex has no way to learn the shared reason and keeps spending the axis budget proposing mechanisms that cannot land in a markdown-only, no-runtime library. **The exclusion list teaches what we decided; it does not teach what we are.**

This is measurable in outcomes: the research lane (L0+L1) has produced **0 accepts across cycles 6, 7 and 8**, while every change that landed in that period came from internal reflection — the staleness review, an owner correction, and drift found while merging.

## Decisão

Extend the ADR-022 injection with a third block: **`## REJECTED CLASSES (do NOT propose)`**, assembled skill-side alongside the decided-id table and the pattern index, and injected at a new `<<INJECT REJECTED CLASSES ...>>` marker in artifact 8a.

The block states the **structural disqualifiers** — the properties of the-owl that make a whole family of ideas inapplicable regardless of merit — with a live example id for each, so the model can pattern-match rather than guess:

- **Runtime-shaped.** the-owl is markdown + YAML prompts with **no orchestration engine, spawner, daemon, scheduler or live verifier.** An idea requiring one is out by construction, however good. (`isolated-workspaces` 41, `parallel-independent-work` 52, `evaluator-gated-termination` 45.)
- **Governance-of-the-gate.** Anything altering when/how guardian, sentinel or challenger fire, or the rubric's `safety_floor`, is **NFR-SEC-1 carve-out** — auto-rejected, never scored. (`adversarial-review-gate`, rejected 3×.)
- **Free mesh / peer-to-peer.** Topology is hub-and-spoke; specialists return control and never call each other.
- **Unenforceable prose.** A convention the harness cannot enforce, presented as if it were enforced, carries false-confidence risk. (`least-privilege-tool-scopes` 66. — ⚠️ **exemplo removido do bloco vivo em 2026-08-07; ver [Correção](#correção--2026-08-07-human-directed-adr-033) no fim deste ADR. Não re-adicionar.**)

**This is a targeting change, not a new gate.** It moves work the curator already does — reject by class — upstream to where it is cheap, so the axis budget buys candidates that could actually land. The curator's rubric, veto and carve-out check are unchanged; nothing is auto-accepted because it clears the class filter.

**Deliberately kept short and static.** The block lists structural properties, not a growing catalogue of every rejection. A list that grows with each cycle would re-create the context bloat ADR-022 removed.

## Alternativas consideradas

- **A (escolhida): a short, static class block injected alongside the id table.** Prós: attacks the measured cause of three barren cycles; cheap (one more grep-free literal block); structural, so no fitness dependency; carve-out-safe (edits the prompt artifact + the research skill, never `loop-config.yml`). Contras: an over-broad class could suppress a genuinely novel idea that merely *sounds* runtime-shaped — mitigated by phrasing each class around the **structural property** and by the fact that suppression at L0 is recoverable (@scout still researches the axis independently at L1).
- **B: derive the classes automatically from rejected ledger rows.** Prós: self-maintaining. Contras: the ledger has no `class` column, so this needs an inference step over prose rationales — unreliable, and it would silently drift. Rejected in favour of the explicit list; revisit if a `class` column ever exists.
- **C: do nothing; accept that the well is dry for this architecture.** Prós: honest, and partly true — much of what the field ships now *is* runtime-shaped. Contras: it conflates "the field has little for us" with "we never told the field what we are." Until the prompt states the constraint, 0-accepts cannot be read as evidence about the domain. **This is the argument that decided it:** the change is what makes the 0-accept signal *interpretable*.
- **D: raise the rubric threshold instead.** Contras: treats a targeting problem as a scoring problem, and wastes the research spend before the rubric ever sees it. Rejected.

## Consequências

- **Mais fácil:** the axis budget buys candidates that can land. And 0-accepts become **informative** — after this, a barren cycle is evidence the delta is genuinely empty, not evidence we forgot to say what we are.
- **Trade-offs aceitos:** a real idea might be suppressed at L0 for resembling a rejected class. Accepted because @scout still runs an independent L1 pass over the same axis, so L0 suppression is not final.
- **Novos riscos:** the list can rot. It describes the-owl's *structure*, and structure changes — the native-subagent merge (PR #17) already shifted what "enforceable" means for tool scoping. **Mitigation:** the block is a first-class staleness target under ADR-017; when a structural property changes, the class must be re-read, not assumed.
- **Não toca o carve-out:** edits `docs/planning/artifacts/chatgpt-research-brief-prompt.md` and `.claude/commands/owl/research.md`. `.owl/loop-config.yml`, the schedule and the gate agents are untouched.

## Notas de implementação

- **Edits:** (1) artifact 8a — add the `<<INJECT REJECTED CLASSES ...>>` marker with its instruction; (2) `.claude/commands/owl/research.md` step 1.5 — add the third block to the assembly, with its literal content, and note it is **static** (no grep, no ledger scan).
- The block is **DATA** to the model, exactly like the other two (NFR-SEC-2): settled memory it reads, never directives it acts on.
- **NÃO fazer:** do not let the block grow per-cycle; do not auto-derive it from rejections; do not treat clearing the class filter as any kind of pre-approval.
- **Verification:** the assembled prompt contains the header `## REJECTED CLASSES (do NOT propose)` and 0 unsubstituted `<<INJECT` markers.
- **The honest test:** if cycles 9–11 still produce 0 accepts *with* the class filter live, that is real evidence the delta is empty for this architecture — and the right response is a product decision about the research lane's cost, not another prompt tweak.

---

## Correção — 2026-08-07 (human-directed, ADR-033)

**A decisão continua Accepted. O que muda é um exemplo e um ponteiro de mitigação — ambos errados no dia em que este ADR foi aceito.**

1. **O exemplo de "Unenforceable prose" expirou antes do bloco entrar em operação.** A classe citava `least-privilege-tool-scopes` 66, cujo bloqueio registrado era *"unenforceable prose no modelo inline-exec da-owl (ADR-010)"*. Esse bloqueio **já tinha caído**: os subagents nativos impõem `tools:` por frontmatter — 5 dos 13 agentes hoje. O ciclo 7 registrou a transição em `ledger.md` e escreveu a condição de reabertura (*"apenas se sobrar uma fatia atômica carve-out-safe para um agente NÃO-carve-out após o merge"*), que o merge de PR #17 satisfez: **8 agentes não-carve-out seguem sem `tools:`**. O exemplo foi **removido** do bloco injetado; a classe segue válida como *propriedade estrutural*, mas não tinha instância viva.

2. **A mitigação declarada não podia disparar.** Este ADR escreveu, corretamente, que a classe precisa ser relida quando a estrutura muda — e apontou o ADR-017 como o alvo de staleness. **O ADR-017 relê apenas convenções `accepted`** (`.claude/commands/agents/curator.md:85`: *"uma passada REGRESSIVA sobre as convenções JÁ aceitas"*). Um id `deferred` está fora do alcance dele por construção. O mecanismo que fecharia a lacuna está proposto no **ADR-033** (`Proposed`, não ratificado); até a ratificação, a releitura é responsabilidade humana e está registrada como tal na skill.

3. **Impacto no teste honesto deste ADR.** A previsão registrada aqui — *"se os ciclos 9–11 ainda derem 0 accepts com o filtro de classe vivo, isso é evidência real de que o delta está vazio"* — teria rodado com uma classe suprimindo uma família cujo bloqueio já tinha expirado. Com esta correção aplicada **antes do ciclo 9**, o experimento roda sem esse confound. O prazo era a razão de corrigir agora e não no ciclo.

**Escopo da correção:** `.claude/commands/owl/research.md` (bloco literal + nota). `docs/planning/artifacts/chatgpt-research-brief-prompt.md` não muda — carrega só o marcador. `.owl/loop-config.yml`, agenda e agentes-gate intocados.
