# Snapshot — 2026-07-23 · /owl:evolve cycle 2 (handoff-contract rollout)

**Mode:** shadow (pr) · **Branch:** `owl/evolve-2026-07-23-handoff-rollout` · **main untouched**

## What this cycle did
A same-day **continuation** cycle. Rather than re-run codex research (the cycle-1 brief was still fresh — same-day guard), the loop applied the newly-added L1.5 grounding step (ADR-005) to the **queued follow-up** that ADR-004 explicitly deferred: rolling the "Contrato de Handoff" convention into individual agents.

## L1.5 self-audit (grounded on real files)
The internal map (`.devflow/knowledge-graph.json` + `docs/wiki/`) does not exist yet → raw-file fallback. Audit of `.claude/commands/agents/*.md`:
- **architect / builder / chronicler** — no handoff-contract section (informal prose only) → **clear gap, targeted this cycle**.
- **scout / curator** — partial ("Contrato de saída" + "Coordenação") → queued.
- **strategist / system-designer** — informal prose only → queued.
- **guardian / sentinel / challenger** — carve-out, never edited by the loop.

## Decision (curator, score 94/100, safety 10/10)
Accepted `handoff-contract-rollout` — 3 edits at the circuit-breaker cap (`max_accepted_changes_per_cycle: 3`).

## Changes proposed (each atomic, 1 ADR ↔ 1 edit)
| ADR | Agent file | Change |
|---|---|---|
| ADR-006 | `.claude/commands/agents/architect.md` | + "🤝 Contrato de Handoff" (6 fields, architect I/O: PRD→ADR/design) |
| ADR-007 | `.claude/commands/agents/builder.md` | + "🤝 Contrato de Handoff" (builder I/O: design + `arquivo_alvo` → atomic diff → gate) |
| ADR-008 | `.claude/commands/agents/chronicler.md` | + "🤝 Contrato de Handoff" (chronicler I/O: artifacts → memory; never a secret value) |

Plus vault bookkeeping: `research-vault/ideas/handoff-contract-rollout.md`, `ledger.md`, `log.md`, `index.md`.

## Gate (L4, blocking) — all PASS
- **guardian:** additive-only (0 removals), role boundaries preserved (each "Escopo/Fora" mirrors existing hard-stops), convention followed, no regression, dual-use chaining intact.
- **sentinel:** 0 carve-out contact; no injection; no secrets; chronicler edit *reinforces* the "no secrets in memory" guardrail.
- **challenger:** real improvement (concrete per-agent I/O, orthogonal to the existing per-peer prose), closes ADR-004's deferred-impact caveat, disciplined scope; builder strongest, chronicler weakest-but-earns-its-place.

## Circuit breaker
- Accepted this cycle: 3 / cap 3 (stop-accepting reached exactly at cap).
- Consecutive gate failures: 0.

## Queued for next cycles
- Same rollout into scout/curator (partial) + strategist/system-designer.
- Deferred backlog (explicit-role-boundaries 84, least-privilege-tool-scopes 78, etc.) — evidence captured, not re-litigated.
