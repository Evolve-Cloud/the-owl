# Snapshot — /owl:evolve cycle 2026-07-26 (mid-cycle checkpoint)

**Mode:** shadow (`landing: pr`) · **Branch:** `owl/evolve-2026-07-26-externalized-checkpoint-memory` · **main untouched**
**Accepted:** 1 (provisional) · **Rejected:** 2 · **Aliases:** 2 · **Deferred:** 5 · **Carve-out contact:** 0 · **Gate:** PASS ×3

## What happened (L0→L5)
- **L0 research** — codex brief `research-vault/inbox/research-brief-2026-07-26.md` (15 sources, 12 ideas). Same fallback as prior cycles: the configured deep-research model is unavailable on this ChatGPT account, so `gpt-5.6-luna` ran. The brief's own `generator:` frontmatter inaccurately self-reports a different model — noted in `scout-notes-2026-07-26.md`, not corrected in the external file itself (data, not instruction — NFR-SEC-2), but recorded accurately in `last-run.json`.
- **L1 scout** — live corroboration (`scout-notes-2026-07-26.md`, x1–x3). All 3 fetched sources verified real (including one specific arXiv id, checked via live search rather than assumed). Caught a real over-claim: the brief's `trajectory-evals` idea cites Anthropic's own evals post as support, but that post — read in full — actually argues the *opposite* emphasis (outcome-primary grading). Flagged 2 aliases of already-decided ideas and 1 exact resurfacing of a previously-deferred id.
- **L1.5 gap analysis (ADR-005)** — grounded 6 candidates directly against the real code, not assumption: confirmed `.owl/state/` has zero mid-cycle checkpoint (the accepted gap); confirmed the-owl's inline execution model (ADR-010, "no `.claude/agents/`, phases sequential") has no mechanism to enforce per-agent tool scoping — this **lowered** `least-privilege-tool-scopes`'s score despite stronger evidence this cycle; confirmed 7/7 pipeline agents already state "contexto-mínimo" and the orchestrator-is-sole-delegator rule is already verbatim in scout.md/curator.md.
- **L2 curator** — deduped vs ledger, scored all 12 + 2 re-examined existing ids, applied the ADR-015 self-haircut (the measured +15.4 curator optimism bias) explicitly rather than accepting the raw score. Accepted **`externalized-checkpoint-memory` (83 raw → 75 after haircut, provisional)** — the only candidate this cycle whose value is a structural/testable fact, not a soft behavioral claim, per ADR-015's own distinction. Rejected `trajectory-evals` (58) and `parallel-independent-work` (52).
- **L2.5 claim verification (ADR-013)** — targeted fetch confirmed LangGraph's actual checkpointer mechanism (pending writes from completed nodes are preserved so a resumed run doesn't redo them) — the exact principle the accepted idea mirrors at a much smaller scale.
- **L3 integrate** — carve-out pre-check clear → **ADR-016** (`docs/decisions/ADR-016-mid-cycle-checkpoint.md`) + one edit to `.claude/commands/owl/evolve.md` (4 insertions: Setup resume-check, per-phase checkpoint-write note, L5 cleanup, circuit-breaker note about leaving the file on abort).
- **L4 gate** — guardian (no agent `.md` edited, no downstream consumer to regress, additions don't contradict the existing verification model), sentinel (0 carve-out paths — confirmed via `git diff --stat`, 1 file; no injection; no secrets in the new JSON schema), challenger (pressed on "the risk hasn't been directly observed yet," agreed the self-haircut already covers that fairly; added a concrete falsifiable revisit trigger). **PASS.**
- **L5 land** — shadow branch + commit; main untouched. `adr: ADR-016` recorded back in `research-vault/ideas/externalized-checkpoint-memory.md` + the ledger.

## The accepted change
`.owl/state/cycle-in-progress.json` (written/read by `/owl:evolve` itself, no other file changes) — records `{cycle_date, last_phase_completed, ideas_in_flight, accepted_so_far}` after each phase's own existing verification passes. At Setup, if a same-day checkpoint exists, the orchestrator surfaces it and asks resume-vs-fresh rather than guessing. Deleted on normal completion; deliberately left in place on an aborted cycle for human inspection.

## Honest framing (provisional accept)
Score landed at exactly the self-haircut-adjusted threshold (75). The failure mode this prevents — a `/owl:evolve` cycle dying mid-flight — hasn't been directly observed yet (only a different-shaped near-miss, ADR-010's subagent no-op). Challenger's non-blocking recommendation: if the checkpoint file is never found non-stale across ~5 future cycles, that's grounds to remove it, per ADR-014/015's keep/revert framing.

## Queued for next cycle
1. Re-examine `least-privilege-tool-scopes` only if a future proposed_change addresses the enforcement-path gap this cycle found (a purely declarative "Forbidden Tools" section has the same weak-Fit problem as the rejected `isolated-workspaces`).
2. `context-budgeting` (74) and `single-agent-first` (69) are reasonable low-priority conventions; neither is urgent (no active agent-sprawl or context-overflow problem observed today).
3. **CHANGELOG gap noted, not fixed this cycle:** 2026-07-25's fitness-harness work (ADR-013/014/015, the calibration probe, the chronicler secret-fix) has no `[Unreleased]` entry — a backfill pass would keep the CHANGELOG honest, but mixing it into this cycle's atomic commit would violate the 1-idea-1-ADR-1-commit discipline.

## Verification
- Carve-out check: `git diff --stat` on the full working tree — only `evolve.md`, `docs/decisions/ADR-016-*.md`, `CHANGELOG.md`, `docs/snapshots/*`, and `research-vault/**` touched. **NONE** of sentinel/guardian/challenger/`.owl/loop-config.yml`/`.claude/settings.json`/schedule/`~/.ssh`/secrets.
- Brief parse: 15 `| s` source rows, 12 `### ` idea headings, frontmatter present.
- ADR-016 follows `docs/decisions/000-template.md`. One ADR → one file (`evolve.md`) → revertible.
