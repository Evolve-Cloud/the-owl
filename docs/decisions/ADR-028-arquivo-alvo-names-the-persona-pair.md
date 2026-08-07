# ADR-028 — `arquivo_alvo` names the persona *pair*, not one file

**Status:** Accepted
**Date:** 2026-08-07
**Author:** @architect (human-directed; from the drift caught while landing ADR-027)
**Tags:** [grounding, hybrid-agents, guardrails, curator, builder]
**Related:** ADR-005 (L1.5 grounding — **this ADR extends it, does not supersede it**), ADR-009 (structured and prose must agree), ADR-010 (inline execution model), ADR-027 (the change during which the drift surfaced)

## Contexto

ADR-005 introduced the L1.5 grounding contract: before scoring, the curator answers `já_implementado?` / `onde_está_o_gap` / **`arquivo_alvo`**, and `arquivo_alvo` is handed to @builder so the edit lands on the concrete gap rather than a generic target. It has worked well for eleven ADRs.

It was written when each agent persona lived in exactly **one** file. That stopped being true when PR #17 merged the hybrid model: every DevFlow persona now exists **twice** —

- `.claude/agents/<x>.md` — native subagent, used for ad-hoc invocation and auto-delegation;
- `.claude/commands/agents/<x>.md` — command persona, the canonical source for the deterministic pipeline (`/quick:*`, `/owl:evolve` inline, `scripts/pack-owl-agents.sh`).

The two are near-verbatim copies **by design** — both are kept deliberately (see the hybrid rationale: subagents buy ergonomics/isolation/tool-scoping, commands buy a guaranteed sequence).

The contract never learned this. Three places still speak in the singular:

- `.claude/commands/agents/curator.md:72` and `.claude/agents/curator.md:78` — *"`arquivo_alvo` — qual agente/arquivo a mudança tocaria"*
- `.claude/commands/owl/evolve.md:45` — *"aplica exatamente UMA edição no `arquivo_alvo`"*
- `.claude/commands/owl/evolve.md:47` — *"o diff toca exatamente o `arquivo_alvo`"*

**This is not hypothetical — it fired the same day.** Landing ADR-027, the step 0.5 edit went into `.claude/commands/agents/curator.md` only. The native `.claude/agents/curator.md` — the copy used for auto-delegation — would have run the loop **without the step its own ADR had just mandated**. Identically, the owner's `claude.com/blog` correction reached the command scout but not the native one, so the native scout would have kept searching the old surface. Both were caught by chance, while integrating `origin/main`, not by any rule. The L4 gate did not catch them either: @guardian checks role boundaries and regression in the *edited* file, and has no reason to ask "is there a second copy of this file?"

## Decisão

**When the target of a change is an agent persona, `arquivo_alvo` names the pair, not one file.** The auto-audit must list every copy that exists (today: `.claude/agents/<x>.md` **and** `.claude/commands/agents/<x>.md`), and the L3 edit applies the same logical change to all of them.

`1 ideia → 1 ADR → 1 edição` is preserved and re-read correctly: **one *logical* edit**, applied to every copy of the target. Two files changing in lockstep is one edit expressed twice — it is not two changes, and splitting it across ADRs would be worse.

The L3 verification changes accordingly: the diff must touch **every** file named in `arquivo_alvo`; touching only one is a **failed phase**, not a partial success.

Non-persona targets (a convention doc, a script, the vault) are unaffected — `arquivo_alvo` stays a single path there.

## Alternativas consideradas

- **A (escolhida): `arquivo_alvo` becomes a list; L3 verification requires all of them.** Prós: fixes the defect where it originates (the grounding contract), costs three sentences, needs no new tooling, and fails loudly instead of silently. Contras: the curator must know which personas are duplicated — mitigated because the rule is mechanical (persona ⇒ check both directories), not a judgment.
- **B: a lint script that diffs `.claude/agents/` against `.claude/commands/agents/` and reports drift.** Prós: catches drift from *any* source, including hand edits outside the loop. Contras: new tooling for a problem the contract should not create in the first place; detects after the fact rather than preventing. **Not rejected outright — recorded as the natural follow-up** once the contract fix has been exercised, and strictly better as a *complement* than as a replacement.
- **C: collapse the hybrid — keep only one copy of each persona.** Contras: re-litigates a decision made deliberately and merged two days ago (PR #17); the two copies serve genuinely different invocation paths. Rejected.
- **D: leave it, and let the next occurrence become the ≥2× signal that ADR-027's new step catches.** Prós: would be an elegant end-to-end proof of the step shipped hours earlier. Contras: **leaving a known defect in place to manufacture a test case is theater, not engineering** — and the next occurrence would land in an unattended Monday cycle with nobody watching. Rejected explicitly; ADR-027 already has its own falsifiable test (the next curator pass must record today's two `human-directed` entries).

## Consequências

- **Mais fácil:** a persona edit is correct by default. The native subagent and the command persona cannot silently disagree about a convention the loop itself just adopted.
- **Trade-offs aceitos:** slightly larger diffs (two files where one used to change) and a marginally longer auto-audit. Cheap relative to a loop running conventions it believes it adopted.
- **Novos riscos:** the rule enumerates the copies that exist **today**. A third invocation surface later would need the same treatment — which is precisely the argument for Alternative B as a follow-up.
- **Não toca o carve-out:** edits `curator.md` (×2) and `evolve.md`. `sentinel`/`guardian`/`challenger`, `.owl/loop-config.yml`, the schedule and settings are untouched.

## Notas de implementação

- **Edits (one logical change, three files):**
  1. `.claude/commands/agents/curator.md` — step 0, the `arquivo_alvo` definition.
  2. `.claude/agents/curator.md` — the same line. *(Applying this ADR to both copies is itself the rule it establishes; doing it in one file only would be the bug.)*
  3. `.claude/commands/owl/evolve.md` — L3 edit instruction (line ~45) and the L3 verification (line ~47).
- **NÃO fazer:** do not edit ADR-005 — it stands as written and this ADR extends it (decision records are append-only; supersession is declared, never retrofitted). Do not touch `scripts/pack-owl-agents.sh`: `owl-agents/` ships **no** scout/curator (verified, not assumed), so the pack is unaffected by this rule for the loop personas.
- **Provenance:** drift found 2026-08-07 while integrating `origin/main` during the ADR-027 landing; recorded in `research-vault/log.md` under `[2026-08-07] sync`.
- **Ledger:** this is a **human-directed** change, so under ADR-027 step 0.5 the next curator pass must record it as a `human-directed` row. It is a *different class* from today's other two entries by ADR-027's own definition (class = same target; this targets `curator.md`/`evolve.md`, the source-surface correction targeted `scout.md`) — so it does **not** trigger a ≥2× signal. That the rule yields the right answer on its first real input is a small piece of evidence that the definition is usable.
- **Landing:** committed to `main`, human-directed and attended, same deviation as ADR-027 (`.owl/loop-config.yml` remains `landing: pr` for autonomous cycles).
