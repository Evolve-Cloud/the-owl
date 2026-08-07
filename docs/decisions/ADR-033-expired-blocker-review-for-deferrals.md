# ADR-033 — Deferrals and rejections need their own staleness review: ADR-017 only reads *accepted* conventions

**Status:** **Proposed** — awaiting owner ratification. Authored in a human-directed loop-health review, outside `/owl:evolve`. Per the precedent of ADR-017 and ADR-026, a proposal about the loop's own machinery does not self-approve.
**Date:** 2026-08-07
**Author:** main loop (owner-directed: "atacar o streak de 0-accepts")
**Tags:** [loop-health, staleness, ledger, targeting, research-lane]
**Related:** ADR-017 (**this is its mirror**), ADR-030 (**this finds a defect in it**), ADR-022, ADR-015, ADR-031, ADR-005

---

## Contexto

### Premise correction, first

`.owl/state/last-run.json` records cycle 8 as the **"5th consecutive 0-accept."** That number is wrong, and it is the number that framed this review.

The count includes passes that could not have accepted anything. The 2026-07-30 human-directed MCP absorption is recorded in `log.md` with the explicit line *"Curator has NOT scored these — this is an ingest (scout lane)"* — an unscored ingest cannot produce an accept, so counting it as a 0-accept cycle is a category error. The 2026-07-26 human-directed backlog pass did score (0 accepted), but the **same-day** human-directed integrate accepted `convention-staleness-review` (82 → ADR-017), so reading that date as barren is at best misleading.

**The defensible number is 3** — scored research-lane cycles 6, 7 and 8 — which is exactly what ADR-030 already states: *"the research lane (L0+L1) has produced 0 accepts across cycles 6, 7 and 8."* ADR-030 got it right; the state file inflated it.

This matters beyond bookkeeping: a 5-cycle streak reads as a systemic failure, a 3-cycle streak reads as a hypothesis under test. ADR-030 is that test, and it is already scheduled (cycles 9–11).

### What this review actually found

ADR-030 attributes the barren cycles to **targeting** — research keeps proposing runtime-shaped mechanisms that cannot land in a markdown-only library — and injects a `## REJECTED CLASSES (do NOT propose)` block to fix it. That hypothesis is live and is not re-litigated here.

The finding below is **independent of it**, and it is not a targeting problem.

**Cycle 7 (2026-08-03) recorded, in writing, that a deferral's blocker was disappearing — and named the exact condition for re-opening it.** From `ledger.md`:

> `least-privilege-tool-scopes` (66, deferred 2026-07-23 as *"unenforceable prose in the-owl's inline-exec model, ADR-010"*) — the scout confirmed `tools`/`disallowedTools` are REAL harness-enforced subagent frontmatter fields […] **The deferral blocker (inability to enforce per-agent tool scope) is therefore being removed** […] **Re-open for a loop accept only if a concrete carve-out-safe atomic slice for a NON-carve-out agent still remains after the migration merges.**

**The migration merged** (PR #17, `dcb5e6b`; frontmatter added in `2cb5aef`). Verified against the tree today:

| | agents |
|---|---|
| carry harness-enforced `tools:` | challenger, curator, guardian, scout, sentinel (**5 of 13**) |
| of those, NFR-SEC-1 carve-out | challenger, guardian, sentinel (**3**) |
| **non-carve-out, no `tools:` line** | **architect, builder, chronicler, database-specialist, mcp-builder, strategist, system-designer, team (8)** |

The recorded re-open condition — *a carve-out-safe atomic slice for a non-carve-out agent* — is **met**, by eight agents. Nobody re-opened it.

**Not because anyone was careless.** The system *did* notice the capability change; a human recorded it precisely. What is missing is the step that reads a recorded re-open condition back and asks whether it has come true. ADR-017 step 4.5 re-reads the 1–2 oldest **accepted conventions** and asks *"did the model make this redundant?"* Nothing asks the mirror question of the 27 deferred and 7 rejected rows: **"did this blocker expire?"**

### The sharp part: ADR-030 froze the expired reason into the research prompt

ADR-030's class block ships this literal entry:

> **Unenforceable prose.** A convention the harness cannot enforce, presented as if it were enforced, carries false-confidence risk. (`least-privilege-tool-scopes` 66.)

It cites, as the standing example of a permanently-disqualified class, **the very id whose disqualifier the loop's own cycle-7 record says was being removed.** ADR-030 saw the risk and wrote it down — *"the native-subagent merge (PR #17) already shifted what 'enforceable' means for tool scoping"* — and assigned the mitigation to ADR-017: *"the block is a first-class staleness target under ADR-017."*

**That mitigation cannot fire.** ADR-017 reads accepted conventions. `least-privilege-tool-scopes` is a deferred idea. There is no path by which ADR-017 reaches it.

So the class block shipped **stale on the day it was accepted**, with a mitigation that structurally cannot reach the staleness, and it now instructs the research lane never to propose that family again.

**Consequence for the ADR-030 experiment:** cycles 9–11 will be measured with a filter that suppresses a family whose blocker expired. A 0-accept result over those cycles is **confounded on precisely this axis** and cannot be read as ADR-030's own "honest test" intended (*"real evidence the delta is empty for this architecture"*).

### Weaker supporting observation (context, not a claim)

`ledger.md` holds **27 deferred** against **10 accepted** and 7 rejected. Of the 10 accepts, the `origin` column (ADR-031, evidence-bound backfill) reads **4 research · 3 owner · 3 backlog** — six of ten did not come from the research lane.

**No claim is made that the backlog outperforms research.** Promoted backlog items are selected *because* someone already judged them strong, the samples are single-digit, and this repo has a formal noise band for exactly this kind of comparison. The only point taken from it: a stock of already-researched, already-scored candidates roughly **2.7× the size of everything ever accepted** sits with no scheduled re-examination, while the loop buys new research every week.

---

## Decisão (proposed)

Add an **expired-blocker review** — the mirror of ADR-017 step 4.5, in the curator flow.

Each cycle, the curator re-reads **1–2** `deferred`/`rejected` ledger rows whose recorded reason names a **structural property of the-owl** (no runtime, inline execution, hub-spoke topology, unenforceable prose, carve-out), and asks one question: **is that property still true?**

- If it still holds → note it and move on (same audit-trail discipline ADR-017 requires: which id examined, verdict, in `log.md`).
- If it has changed → the id is **re-opened as a normal candidate**: new suffixed id, normal scoring, normal ADR-015 haircut, normal gate. **Never auto-accepted, never auto-reverted** — the same boundary ADR-017 draws.

Bounded to 1–2 per cycle, oldest-first, so it cannot become a re-litigation engine. **It costs no research budget** — these candidates are already paid for.

Second, narrower change: any id cited as a **live example** inside ADR-030's class block inherits this review automatically, since ADR-030's stated mitigation cannot otherwise reach it.

---

## Alternativas consideradas

- **A (proposed): bounded per-cycle expired-blocker review.** Prós: attacks a verified, instanced gap; symmetric with an already-ratified mechanism, so no new concept; costs zero research spend; carve-out-safe (edits `curator.md`, never `loop-config.yml`); makes ADR-030's cycles 9–11 test interpretable instead of confounded. Contras: another judgment step in a flow that already has one — mitigated by the 1–2/cycle bound and by restricting it to rows whose reason names a *structural* property, which is a small subset.
- **B: fire only on structural-change events** (a merge that adds a capability triggers a re-read of every deferral citing the absent capability). Prós: strictly more precise, no per-cycle cost. Contras: needs an event hook nobody owns, and the-owl has no such trigger surface. **This is the better mechanism if it ever becomes cheap** — revisit.
- **C: do nothing; humans catch it.** This is the current state, and its track record is the evidence against it: a human *did* catch the capability change and *did* write the re-open condition — and the condition still went unfired after the precondition was satisfied. Catching the change is not the same as acting on it.
- **D: auto-derive from ledger rows.** Rejected for the same reason ADR-030 rejected its own option B: the ledger has no `reason`/`class` column, so this needs inference over prose and would drift silently.
- **E: treat this as part of ADR-030 and wait for cycle 11.** Rejected — ADR-030 measures *targeting of new research*. This is about *stock already held*. Waiting also means the confound goes into the experiment unannounced.

---

## Consequências

- **Mais fácil:** the loop stops paying to rediscover what it already owns, and a recorded re-open condition becomes something the system can act on rather than a note.
- **Trade-offs aceitos:** a judgment step, not a measurement — same honest limitation ADR-017 carries and the same mitigation (bounded + human-reviewed). Impact is **provisional-pending-fitness** (ADR-015); full credit only once the step re-opens an id that then clears the bar.
- **Novos riscos:** re-opening ids could erode the dedup discipline that ADR-022 and the SCHEMA rule exist to protect. **Mitigation:** re-open only via a **new suffixed id** with the changed structural fact named, exactly the rule that already governs "materially new evidence."
- **Não toca o carve-out:** the proposed edit is to `.claude/commands/agents/curator.md` (+ its `.claude/agents/curator.md` twin). `.owl/loop-config.yml`, the schedule and the gate agents are untouched.

### Owner decisions this surfaces (none taken here)

1. **Re-open `least-privilege-tool-scopes`** for the 8 non-carve-out agents — its recorded re-open condition is met. Scoring is the curator's, not this review's. **Open.**
2. ~~**ADR-030's class block:** the `least-privilege-tool-scopes` example is stale.~~ — **DONE 2026-08-07, owner-authorized.** The expired example was removed from the live block in `.claude/commands/owl/research.md`; the class kept as a structural property with an explicit "depends on today's harness" clause. ADR-030 gained a dated `## Correção` section (its Decisão text is preserved with a do-not-re-add marker) and the ledger a `human-directed` row (`hd-unstale-rejected-class-example`, ADR-027). Done **before cycle 9** so the ADR-030 experiment starts unconfounded — that deadline was the reason to act ahead of ratification.
3. **Correct the streak count** in `.owl/state/last-run.json` (and cycle-8's commit message, which repeats it) from 5 to 3, or annotate what it counts. **Open.**

**Note for cycle 9's ADR-027 step 0.5:** this is the fourth `human-directed` row with origin `reflection` dated 2026-08-07. If "correction to the loop's own machinery, found by human review" counts as a class, it is now well past the ≥2× threshold that step 0.5 uses to raise a normal candidate. That call is the curator's, not this review's.

---

## Notas de implementação

- **Nothing was edited to produce this ADR.** No agent file, no convention, no ledger row, no state file. It is a finding written for ratification; the loop does not self-approve changes to its own machinery.
- **Verification performed for this document:** `tools:` frontmatter enumerated per file across `.claude/agents/*.md` (5 of 13, listed above); merge confirmed at `dcb5e6b`/`2cb5aef`; the cycle-7 re-open condition and the 2026-07-30 *"has NOT scored"* line quoted verbatim from `research-vault/ledger.md` and `research-vault/log.md`; ledger status/origin counts computed from the table, not estimated.
- **⚠️ Antes de ratificar, leia a seção "Correção — 2026-08-07 (varredura de propriedades)" no fim deste documento: a Decisão acima (forma A) foi medida contra as 34 linhas, e a alternativa B foi rejeitada com uma premissa falsa.**
- **Premissas & questões em aberto:** the streak-count correction assumes the "5" was assembled by counting human-directed passes — consistent with cycle 7 self-reporting "4th consecutive," but the counting rule is nowhere written down, so this is inference from the sequence, not a read of the rule. Whether a re-opened `least-privilege-tool-scopes` would actually *clear* the bar is **not** claimed here — the ADR-015 haircut applies and it previously scored 66. Evidence confidence: the tree facts (frontmatter, merge, counts) are verified directly. The causal claim ("no step reads re-open conditions") is **also verified directly**, not inferred: `.claude/commands/agents/curator.md:85` scopes step 4.5 to *"uma passada REGRESSIVA sobre as convenções JÁ aceitas"* — accepted conventions only — and no other step in "🔄 Meu fluxo" reads `deferred`/`rejected` rows.

---

## Correção — 2026-08-07 (varredura de propriedades): a alternativa B foi rejeitada com um fato falso

**O achado deste ADR continua válido e verificado. O que muda é a forma recomendada — e por que a razão de descartar B não se sustenta.** Escrito depois de uma varredura única das 34 linhas `deferred`/`rejected`, encomendada pelo dono exatamente para não ratificar um custo permanente por ciclo com base em n=1. Registro em `research-vault/log.md` (`[2026-08-07] sweep`).

### 1. A alternativa B foi descartada por uma premissa falsa

Este ADR rejeita B assim: *"needs an event hook nobody owns, and the-owl has no such trigger surface."*

**Há duas superfícies de trigger ativas neste repo agora:** `.git/hooks/post-commit` e `.git/hooks/post-checkout` (instalados pelo graphify), disparando a cada commit — verificável na saída de qualquer commit desta sessão. O `post-commit` já computa `git diff --name-only HEAD~1 HEAD`, que é precisamente a lista de arquivos mudados que o gatilho precisaria. Mais `SessionStart` em `.claude/settings.local.json` e o scheduler launchd em `scripts/`.

Isto é ironia estrutural que vale nomear: **este ADR cometeu, na sua própria seção de alternativas, o defeito que ele existe para descrever** — uma decisão sustentada por uma propriedade estrutural que já tinha mudado e não foi relida.

### 2. A varredura não bateu a barra declarada — e isso está registrado como falha, não reinterpretado

A barra combinada antes de rodar era **2+ reaberturas vivas ⇒ ratificar**. Resultado nas 34 linhas: **1 clara** (`least-privilege-tool-scopes`, já reaberta) + **1 parcial** (`agent-frontmatter-fields` — o bloqueio caiu para 1 dos 3 campos do título; `Memory` e `isolation` não têm verificação nenhuma no vault, e os 13 subagents usam só `name`/`description`/`tools`). **Barra não batida.**

### 3. Mas o número que decide é outro: um evento, raio largo

O PR #17 — **um** evento — invalidou **3 linhas do ledger** (`least-privilege-tool-scopes`, `agent-frontmatter-fields`, e a premissa de `parallel-independent-work`/`isolated-workspaces`) **e 3 afirmações vivas** (o bloco de classes do ADR-030, `evolve.md:20`, e a rejeição de B aqui). Eventos estruturais são **raros**; o raio por evento é **largo**. Esse perfil favorece gatilho por evento sobre relógio: a forma A, a 1–2 linhas/ciclo, precisaria de ~17–34 ciclos para varrer o ledger uma vez e não acharia nada na maioria delas.

### 4. E a forma A não alcança onde estava o valor

**Os três defeitos mais caros não são linhas do ledger** — são um prompt injetado todo ciclo (`research.md:39`) e duas afirmações em documento. Um passo que relê **linhas** não os alcança por construção. O que os achou foi verificar **as propriedades** contra a árvore. **Propriedade é a unidade certa; linha é consequência.**

### 5. O que isto pede antes da ratificação

A seção **Decisão** acima descreve a forma A e deve ser **reescrita como forma B** antes de ser ratificada: uma regra presa ao momento em que uma mudança estrutural é **registrada** — *"ao registrar uma mudança estrutural, re-verifique a lista de propriedades declaradas e varra as linhas que citam a que mudou."* O ciclo 7 já fez a metade que este ADR dizia faltar (a detecção, escrita no ledger); a regra é a metade que faltou. Markdown, custo zero em ciclo sem mudança, carve-out-safe.

**Não reescrita aqui de propósito:** trocar a Decisão de A para B é a decisão de ratificação, e é do dono — o mesmo limite que este ADR desenha para si na abertura (*"a proposal about the loop's own machinery does not self-approve"*).

⛔ **Não proposto e não feito: editar git hooks.** Hook executa código — é superfície de segurança e decisão do dono, nunca do loop. A regra em markdown não precisa de um.

**Escopo já corrigido fora deste documento (autorizado, 2026-08-07):** `.claude/commands/owl/research.md` (a classe *Runtime-shaped* dizia "ZERO engine de orquestração"; reescrita para capacidade **+** fronteira) e `.claude/commands/owl/evolve.md:20` (afirmava que `.claude/agents/` não existe; existem 13). `.owl/loop-config.yml`, agenda e agentes-gate intocados.
