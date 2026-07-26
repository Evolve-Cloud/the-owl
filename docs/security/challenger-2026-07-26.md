# Challenger review — ADR-017 (convention staleness review) — 2026-07-26

Independent adversarial gate of a **same-day deferred→accepted promotion** in the self-improvement loop. Reviewer: challenger (adversarial, independent of the curator who authored + scored the change).

## Challenger Assessment
**Confidence in the inline Guardian/Sentinel review:** 88%
**Overall verdict:** **Partially Agree** — the change is safe, additive, and carve-out-clean (Guardian/Sentinel correct); but the accept is **genuinely marginal** and two real gaps were found and fixed during this gate.

### Scores por Categoria
| Categoria | Score | Justificativa |
|---|---|---|
| Security | 96/100 | 0 carve-out contact (verified by grep): edits `curator.md` + docs/vault, never `.owl/loop-config.yml` or the gate agents. Never auto-reverts; reads-only + owner-decided re-fitness. No new attack surface. |
| Completeness | 82/100 | All 4 challenge axes examined against the files; two gaps (owl-fitness semantics, ceremony risk) were open at first pass, now closed. |
| Correctness | 84/100 | Claim verification (ADR-013) is real (live fetch). The rubric math is the soft spot — see challenge #2. |
| Test Coverage | 70/100 | No eval/fitness result exists for this change (correctly marked provisional-pending-first-flag). This is a process convention; fitness can only be earned once it fires. |
| **Overall** | **84/100** | Sound and safe; accept is defensible but marginal and rests on one exemption; ships as working-tree only for owner review. |

### ✅ Confirmado (inline review acertou)
- **Carve-out clean** (Sentinel): grep confirms 0 carve-out files in the diff; the edit is to `curator.md`, outside NFR-SEC-1.
- **Additive** (Guardian): one new step 4.5, nothing removed; ownership unchanged; no prose↔meta drift (ADR-013's step 2.5 is the precedent for a granular flow step with no meta line).
- **Claim verified** (ADR-013): live fetch of anthropic.com/engineering/managed-agents returned the exact quote verbatim.

### ⚠️ Pontos Desafiados
1. **Marginal accept / rubric math** (`ledger.md` integrate note; `ideas/convention-staleness-review.md`): the score (82) was assigned by the promoting curator, and ADR-015 documents a ~+15 curator optimism bias. Discounted, 82 → ~67 = **defer band**. The accept survives *only* via the "structural/process convention, so the behavioral discount barely applies" exemption (ADR-012 precedent). That exemption is legitimate **but convenient** — if it's wrong, this is a defer. Verdict: **rubric-defensible, not rubric-comfortable.** Acceptance is correctly marked provisional; keep it labeled marginal.
2. **Ceremony risk / will it fire?** (`curator.md:step 4.5`): the trigger is curator *judgment* ("plausibly redundant"), with no forcing function — risk it becomes a step nominally performed but never producing a flag (flagging your own team's conventions as dead weight is uncomfortable and unmeasured). **FIXED this gate:** step 4.5 now **requires recording, every cycle, which convention was examined + the verdict (incl. "still earns its keep")** → auditable trail, cannot be silently skipped.
3. **Actionable vs aspirational — the owl-fitness assumption** (`scripts/owl-fitness.py:6`): the "actionable framing" claimed to "trigger `owl-fitness.py`". But the script's own docstring: it **compares two run-record sets (before/after); it does not run the eval.** Re-fitnessing an old convention needs fresh with/without run-records on the *current* model first — real owner-decided work. So the original wording secretly leaned on a capability owl-fitness.py doesn't provide. **FIXED this gate:** step 4.5 / ADR-017 / the idea page now say the step **recommends** an owner re-fitness (re-run eval with/without → then owl-fitness.py compares), not "triggers owl-fitness.py". The data-independence claim now holds honestly (it produces a recommendation, reads no un-instrumented Δ).
4. **Self-referential cost** (`curator.md:step 4.5`): step 4.5 is itself a convention adding prompt surface, and by its own logic is subject to staleness review. Not a defect — it's self-consistent (the first thing a future staleness pass should check is whether 4.5 ever fired; if never, *it* is the stale convention). Cost is ~6 lines; marginal. Noted, no change.

### 🔴 Critical Gaps (blocking)
- **None.** The change lands **working-tree only** (not committed to main); the owner reviews the diff before any landing. The two gaps above were fixed within this gate, not deferred.

### 💡 Abordagens Alternativas
- If the marginal-accept discomfort (challenge #1) matters to the owner, the honest fallback is **re-defer** `convention-staleness-review` until it can be scored by an independent reviewer (ADR-015's own prescription for the optimism bias). Shipping it provisional + working-tree-only is the lighter-weight version of the same caution.

### Summary for Chronicler
Guardian/Sentinel correctly cleared ADR-017 as additive and carve-out-clean; the live ADR-013 claim check is real. Challenger's independent pass agrees it's safe but flags the accept as **marginal** — discounted for the documented ~+15 curator optimism it would be a defer, and it survives only via the ADR-012 "structural convention" exemption from the ADR-015 behavioral discount (legitimate, precedented, but convenient — keep it labeled provisional/marginal). Two real gaps were found and **fixed within the gate**: (a) step 4.5 risked being ceremonial → now requires a per-cycle `log.md` audit trail of which convention was examined + verdict; (b) the "trigger owl-fitness.py" wording leaned on a capability the script lacks (it only compares run-records, doesn't run the eval) → reworded to "recommend an owner re-fitness." Landing is working-tree only; owner reviews before committing. Priority for the team: watch that step 4.5 actually produces a flag within a few cycles — if it never does, it is itself the first stale convention.
