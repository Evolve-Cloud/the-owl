# Snapshot — /owl:evolve cycle 2026-07-24 (role-ownership convention)

**Mode:** shadow (`landing: pr`) · **Branch:** `owl/evolve-2026-07-24-role-ownership` · **main untouched**
**Accepted:** 1 · **Rejected:** 1 · **Deferred:** rest · **Carve-out contact:** 0 · **Gate:** PASS ×3

## What happened (L0→L5)
- **L0 research** — codex brief `research-vault/inbox/research-brief-2026-07-24.md` (22 sources, 16 ideas). The configured deep-research model is unavailable on the ChatGPT account (`400 ... not supported`); fell back to the default `gpt-5.6-luna` per the `owl-research` skill. Brief parses clean (frontmatter + Sources table + 16 `### id` yaml blocks).
- **L1 scout** — live corroboration pass (`scout-notes-2026-07-24.md`, x1–x5). Strengthened `narrow-single-owner-roles`; weakened `isolated-workspaces` (no parallel writers in a no-runtime hub-spoke lib); flagged several already-implemented dedup signals. *(The first delegated scout subagent returned 0 tool-uses / wrote nothing — redone inline; noted for reliability.)*
- **L1.5 gap analysis (ADR-005)** — grounded vs the real tree: ownership already encoded in `.meta.yaml` (`responsibilities`/`constraints`/`outputs`/`should_delegate_to`) for **8/11** agents; **scout, curator, sentinel have no `.meta.yaml`**. sentinel is NFR-SEC-1 carve-out → human-only.
- **L2 curator** — deduped vs ledger (6 brief-ids aliased to decided ids), scored, applied the safety veto. Accepted **`role-ownership` (87)**; rejected **`isolated-workspaces` (41)**. Vault fully updated (idea pages, `patterns/role-decomposition.md`, ledger, index, overview, log).
- **L3 integrate** — carve-out pre-check clear → **ADR-009** (`docs/decisions/ADR-009-role-ownership-convention.md`) + **`docs/conventions/role-ownership.md`** (one atomic edit).
- **L4 gate** — guardian (no agent edited → no regression; consistent with handoff-contract + hub-spoke), sentinel (0 carve-out paths; no injection; no secrets), challenger (real improvement — L1.5 surfaced a concrete inconsistency + adds decision-rights/forbidden-overlap). **PASS**, with a non-blocking flag: **convention debt** — two conventions now await rollout.
- **L5 land** — shadow branch + PR; main untouched. `adr: ADR-009` recorded back in `research-vault/ideas/role-ownership.md` + the ledger.

## The accepted change
`docs/conventions/role-ownership.md` — "Papel & Não-Papel": every agent declares **Possui** (decision rights + single artifact) · **Não possui** (forbidden overlap → owner) · **Entradas exigidas** · **Critério de pronto** · **Fonte da verdade** (`.md` ↔ `.meta.yaml` must agree). Rollout = tracked follow-up (1 agent/ADR); sentinel completion = human (carve-out).

## Queued for next cycle
1. **Rollout over new conventions** (challenger flag): add the "Papel & Não-Papel" section + missing `.meta.yaml` to `scout`/`curator`; roll the handoff contract into the remaining agents. sentinel/guardian/challenger = human.
2. `least-privilege-tool-scopes` (near-threshold 78) — a careful, security-adjacent cycle.
3. Evidence-log / provenance convention; extend the ADR template for prompt-surface changes.

## Verification
- Carve-out check: `git status` grep for sentinel/guardian/challenger/loop-config/settings/schedule/ssh/secret → **NONE**.
- Brief parse: 22 `| s` source rows, 16 `### ` idea headings.
- ADR-009 follows `docs/decisions/000-template.md`. One ADR → one convention file → revertible.
