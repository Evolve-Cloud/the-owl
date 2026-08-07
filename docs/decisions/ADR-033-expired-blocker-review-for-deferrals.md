# ADR-033 — Deferrals and rejections need their own staleness review: ADR-017 only reads *accepted* conventions

**Status:** **Accepted — forma B** · **Ratificado:** 2026-08-07 (dono). Proposto na **forma A** (revisão por ciclo); ratificado na **forma B** (disparo por evento) depois que uma varredura única das 34 linhas mediu a forma A e mostrou que a rejeição da alternativa B repousava numa premissa falsa — ver a seção *Correção — 2026-08-07* no fim. Escrito numa revisão de saúde do loop dirigida pelo dono, fora do `/owl:evolve`: pelo precedente do ADR-017 e ADR-026, proposta sobre a própria maquinaria do loop **não se auto-aprova** — e esta não se aprovou, foi ratificada.
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

## Decisão (ratificada — forma B)

Adicionar uma **revisão de bloqueio expirado** que dispara **por evento**, não por ciclo. É o espelho do passo 4.5 do ADR-017, com a cadência corrigida: o 4.5 relê convenções **aceitas**, que decaem devagar e continuamente conforme o modelo melhora — relógio é a cadência certa. Esta relê linhas **`deferred`/`rejected`** cujo bloqueio é uma **propriedade estrutural da-owl**, que muda de forma **rara e discreta** — evento é a cadência certa. Espelhar o relógio numa coisa que muda por evento era o erro da forma A.

**Duas peças, ambas necessárias:**

**1. Um registro das propriedades** — `docs/conventions/structural-properties.md` (novo). Lista cada propriedade estrutural que a-owl afirma sobre si, seu **estado verificado**, a **data** da verificação, e os **caminhos-prova** cujo estado a demonstra. Sem esse registro a regra não tem alvo: a varredura de 2026-08-07 teve que reconstruir a lista à mão, e é justamente essa reconstrução que não pode depender de alguém lembrar.

**2. A regra que o consome** — passo **4.6** do `curator.md` (o par, ADR-028). Dispara **se, e só se**, um dos dois:
- (a) o ciclo tocou ou observou um caminho da coluna `Prova` do registro (`.claude/agents/`, `scripts/`, `.claude/settings.json`, `.claude/commands/owl/evolve.md`, `.git/hooks/`) — mecanicamente verificável por `git log --name-only` sobre esses paths; **ou**
- (b) o @scout ou o @curator registrou um **achado de capacidade** em `ledger.md`/`log.md` ("campo X é imposto pela harness", "a plataforma agora faz Y") — que foi exatamente a forma do achado do ciclo 7.

**Nenhum dos dois ⇒ custo zero:** não roda, não loga, não gasta julgamento.

**Se disparou:** re-verificar as propriedades afetadas contra a árvore e atualizar estado + data no registro; varrer as linhas `deferred`/`rejected` cuja razão cita a propriedade mudada; para cada bloqueio caído, **reabrir como candidato**.

**A forma de reabrir é obrigatória** — errar aqui faz a reabertura virar no-op que parece feita, e isso foi verificado na prática em 2026-08-07:
- **id novo com sufixo** (SCHEMA: evidência materialmente nova nunca sobrescreve);
- arquivo em `research-vault/ideas/<id-novo>.md` **nomeando o fato estrutural que mudou** e as questões que ele deixa abertas;
- **NENHUMA linha no `ledger.md` até ser pontuado** — o passo 1 do curator pula id que já está no ledger, então uma linha prematura mata a reabertura em silêncio;
- o **ato** de reabrir ganha linha própria `human-directed` (ADR-027), com id distinto.

**Reabrir ≠ aceitar.** Volta como candidato normal: rubrica, veto de segurança, haircut do ADR-015, gate. **Nunca auto-aceito, nunca auto-revertido** — a mesma fronteira que o ADR-017 desenha.

**Cláusula herdada da proposta original:** todo id citado como **exemplo vivo** dentro do bloco `## REJECTED CLASSES` do ADR-030 entra nesta revisão automaticamente. Foi a ausência dela que deixou o bloco nascer com um exemplo expirado.

**Acoplamento nos dois sentidos:** o registro aponta para o bloco de classes e o bloco aponta de volta para o registro. Desacoplados, eles voltam a divergir — e o defeito "ZERO engine" reaparece em três meses.

## Alternativas consideradas

- **B (ESCOLHIDA, ratificada): disparo por evento estrutural.** Prós: casa a cadência com o fenômeno — propriedade estrutural muda raro e de repente, então relógio chega tarde e gasta atenção em ciclo parado; **custo zero** em ciclo sem mudança; o gatilho é mecanicamente verificável (`git log` sobre os caminhos-prova) em vez de julgamento; e a **lista de propriedades**, que a forma A não exigia, é o que permite alcançar afirmações que **não são linhas do ledger** — foi onde estavam os 3 defeitos mais caros. Contras: exige manter o registro em sincronia — mitigado pelo acoplamento bidirecional com o bloco de classes e por o registro ser curto (8 linhas) e mudar tão raro quanto o fenômeno.
  - **Por que a razão original de rejeitar B não valia:** este ADR descartou B por *"needs an event hook nobody owns, and the-owl has no such trigger surface"*. **Falso** — há dois git hooks ativos, e o `post-commit` já computa `git diff --name-only`. Mas o gatilho ratificado **não usa hook**: usa uma checagem em markdown sobre os caminhos-prova. Editar hooks está explicitamente fora (superfície de segurança, decisão do dono).
- **A (proposta originalmente, REJEITADA por medição): revisão por ciclo, 1–2 linhas do ledger.** A barra combinada antes da varredura era **2+ reaberturas vivas ⇒ ratificar**. Resultado nas 34 linhas: **1 clara** + **1 parcial** (`agent-frontmatter-fields`, bloqueio caído em 1 dos 3 campos do título). **Barra não batida.** E dois defeitos estruturais mais fundos: (1) a 1–2 linhas/ciclo, precisaria de ~17–34 ciclos para varrer o ledger uma vez, achando nada na maioria das passagens; (2) **não alcança onde estava o valor** — os 3 defeitos mais caros são um prompt injetado todo ciclo e duas afirmações em documento, nenhum deles uma linha do ledger. Um passo que relê **linhas** não os alcança por construção. **Propriedade é a unidade certa; linha é consequência.**
- **C: não fazer nada; humanos pegam.** Era o estado corrente, e o histórico é a evidência contra: um humano *pegou* a mudança de capacidade e *escreveu* a condição de reabertura — e a condição seguiu sem disparar depois de satisfeita. Pegar a mudança não é o mesmo que agir sobre ela.
- **D: auto-derivar das linhas do ledger.** Rejeitada pela mesma razão que o ADR-030 rejeitou a própria opção B: o ledger não tem coluna `reason`/`class`, então isto exigiria inferência sobre prosa e derivaria em silêncio.
- **E: tratar como parte do ADR-030 e esperar o ciclo 11.** Rejeitada — o ADR-030 mede *targeting de pesquisa nova*; isto é sobre *estoque já pago*. Esperar também mandaria o confound para dentro do experimento sem aviso.

## Consequências

- **Mais fácil:** the loop stops paying to rediscover what it already owns, and a recorded re-open condition becomes something the system can act on rather than a note.
- **Trade-offs aceitos:** a judgment step, not a measurement — same honest limitation ADR-017 carries and the same mitigation (bounded + human-reviewed). Impact is **provisional-pending-fitness** (ADR-015); full credit only once the step re-opens an id that then clears the bar.
- **Novos riscos:** re-opening ids could erode the dedup discipline that ADR-022 and the SCHEMA rule exist to protect. **Mitigation:** re-open only via a **new suffixed id** with the changed structural fact named, exactly the rule that already governs "materially new evidence."
- **Não toca o carve-out:** os arquivos alterados são `.claude/commands/agents/curator.md` + o gêmeo `.claude/agents/curator.md` (o par, ADR-028) e o registro novo `docs/conventions/structural-properties.md`. `.owl/loop-config.yml`, a agenda, `.claude/settings.json`, os agentes-gate e **os git hooks** seguem intocados.
- **Custo real, honesto:** em ciclo sem mudança estrutural, **zero** — o gatilho não dispara. Em ciclo com mudança, uma re-verificação de 8 linhas + a varredura das razões que citam a propriedade mudada. O custo de manutenção é o registro ficar sincronizado, mitigado pelo acoplamento bidirecional com o bloco de classes.

### Owner decisions this surfaces — TODAS RESOLVIDAS 2026-08-07

1. ~~**Re-open `least-privilege-tool-scopes`**~~ — **DONE 2026-08-07, owner-authorized.** Reaberto como id sufixado em `research-vault/ideas/`, **sem pontuação e sem linha no ledger** (uma linha faria o passo 1 do curator pulá-lo como decidido). O candidato carrega o conflito com o ADR-028 achado ao escrevê-lo: **0 de 13** personas-comando têm frontmatter, então metade do par estruturalmente não recebe `tools:`. @curator pontua no ciclo 9.
2. ~~**ADR-030's class block:** the `least-privilege-tool-scopes` example is stale.~~ — **DONE 2026-08-07, owner-authorized.** The expired example was removed from the live block in `.claude/commands/owl/research.md`; the class kept as a structural property with an explicit "depends on today's harness" clause. ADR-030 gained a dated `## Correção` section (its Decisão text is preserved with a do-not-re-add marker) and the ledger a `human-directed` row (`hd-unstale-rejected-class-example`, ADR-027). Done **before cycle 9** so the ADR-030 experiment starts unconfounded — that deadline was the reason to act ahead of ratification.
3. ~~**Correct the streak count**~~ — **DONE 2026-08-07, owner-authorized.** Corrigido **e** anotado em `.owl/state/last-run.json` (as duas metades da opção), carregando a ressalva de que a regra de contagem não está escrita. A prosa datada do ciclo 7 ("4th consecutive") **não** foi reescrita — é registro do que se acreditava na data; foi nomeada como fonte da propagação. O commit do ciclo 8 também não: mesma razão.

4. **Surgidas depois, e também resolvidas no mesmo dia** — 3 afirmações **vivas** sobre a estrutura da-owl, achadas pela varredura e falsas: `research.md:39` ("ZERO engine de orquestração", injetada no prompt do codex todo ciclo), `evolve.md:20` (".claude/agents/ não existe"), e **a rejeição da alternativa B dentro deste próprio ADR**. As três corrigidas; a terceira é a razão desta ratificação ser em forma B.

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

**RESOLVIDO — 2026-08-07:** o dono ratificou na forma B. A Decisão acima foi reescrita, o Status virou `Accepted — forma B`, e as Alternativas foram invertidas (B escolhida; A rejeitada **por medição**, com a barra declarada e não batida registrada). Esta seção fica como o rastro de auditoria de **por que** a forma ratificada difere da proposta — não é para ser apagada.

⛔ **Não proposto e não feito: editar git hooks.** Hook executa código — é superfície de segurança e decisão do dono, nunca do loop. A regra em markdown não precisa de um.

**Escopo já corrigido fora deste documento (autorizado, 2026-08-07):** `.claude/commands/owl/research.md` (a classe *Runtime-shaped* dizia "ZERO engine de orquestração"; reescrita para capacidade **+** fronteira) e `.claude/commands/owl/evolve.md:20` (afirmava que `.claude/agents/` não existe; existem 13). `.owl/loop-config.yml`, agenda e agentes-gate intocados.
