# Workflow — one self-improvement cycle, end to end

What `/owl:evolve` does in a single run, and how to trigger it. Diagram: [`docs/architecture/diagrams/self-improvement-loop.md`](../../architecture/diagrams/self-improvement-loop.md) §1.

## What exists
- `.claude/commands/owl/evolve.md` — the orchestrator (L0→L5).
- `.claude/commands/owl/research.md` — L0 research (codex CLI).
- `scripts/owl-daily.sh` + `scripts/com.evolvelabs.owl.daily.plist` — the daily launchd trigger.
- `research-vault/` — where research and decisions are recorded.

## How it works (L0→L5)
1. **L0 · Research** — `/owl:research` runs `codex exec -o …` and writes `research-vault/inbox/research-brief-YYYY-MM-DD.md` (the ChatGPT-side brief).
2. **L1 · Scout** — `scout.md`, run inline: reads the brief + does its own WebSearch → candidate ideas into the vault.
3. **L1.5 · Gap-analysis** (ADR-005) — the curator audits the *real* agent files: already implemented? where's the gap? which file?
4. **L2 · Curator** — `curator.md`: dedup vs `research-vault/ledger.md` → score on the rubric → **safety veto** → classify accept/defer/reject.
5. **L3 · Integrate** — architect writes the ADR, builder edits the target file. One idea → one ADR → one atomic commit.
6. **L4 · Gate** (blocking) — guardian + sentinel + challenger; all must PASS or no commit.
7. **L5 · Land** — shadow branch + PR (default); chronicler updates docs; the `adr` is written back into the idea page and ledger.

## Why it is this way
- **Dual research** (codex + scout) gives two independent passes; the curator merges and dedups.
- **Shadow-first** (`landing: pr`) keeps a human as the merge gate while the loop earns trust.
- **Circuit breaker** caps accepted changes per cycle (`.owl/loop-config.yml`).

## How to run / arm it
- **Manually (one cycle):** invoke the `/owl:evolve` command in a Claude Code session at the repo root.
- **Headless (what the schedule uses):** `claude -p --permission-mode bypassPermissions "/owl:evolve"` (see `scripts/owl-daily.sh`).
- **Arm the daily run:**
  ```
  cp scripts/com.evolvelabs.owl.daily.plist ~/Library/LaunchAgents/
  launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.evolvelabs.owl.daily.plist
  ```
  Fires daily at 07:13. See [operations](../operations/config-and-schedule.md).
- **Test-fire now:** `launchctl kickstart -k gui/$(id -u)/com.evolvelabs.owl.daily`.

## What to watch
- A scheduled (tokenless) run pushes the branch but can't open the PR — a human opens it (ADR-010 records the compare URL in the log).
- The run is **shadow-only** unless `landing: main` AND `OWL_AUTONOMOUS_MAIN=1` are both set (guard in `owl-daily.sh`).
- Logs land in `.owl/state/daily-YYYY-MM-DD.log`.

## Source map
`.claude/commands/owl/{evolve,research}.md` · `scripts/owl-daily.sh` · `scripts/com.evolvelabs.owl.daily.plist` · `research-vault/ledger.md` · `docs/decisions/ADR-005,010`.
