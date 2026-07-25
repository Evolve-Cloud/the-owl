# Operations — config, schedule, landing modes

Running and tuning the loop safely. Config: `.owl/loop-config.yml`. Schedule: `scripts/`.

## What exists
- `.owl/loop-config.yml` — the loop's control surface (the "brake pedal").
- `scripts/owl-daily.sh` — the headless wrapper (PATH, ssh key, shadow guard, `claude -p`).
- `scripts/com.evolvelabs.owl.daily.plist` — the launchd job (weekly, Mondays 07:13; the `daily` label/filename is legacy).
- `scripts/owl-metrics.py` — read-only cycle scorecard (rollout coverage, accept rate, rigor, backlog, safety). Run: `python3 scripts/owl-metrics.py`.
- `.owl/state/` — run logs + `last-run.json` (git-ignored runtime state).

## How it works
- **`.owl/loop-config.yml` keys** (reference by name; never store secrets here):
  - `landing` — `pr` (shadow, default) or `main` (autonomous). Default is shadow.
  - `circuit_breaker.max_accepted_changes_per_cycle` — cap per cycle (currently 3).
  - `circuit_breaker.halt_on_consecutive_gate_failures` — abort threshold.
  - `rubric.threshold` (accept ≥), `rubric.reject_below`, `rubric.safety_floor` (< floor = auto-reject).
  - `research.model`, `research.budget_usd_per_call`.
- **The schedule** — `owl-daily.sh` sets PATH (nvm/homebrew), `GIT_SSH_COMMAND` (`~/.ssh/github`), enforces the **shadow-only guard** (refuses to run unless `landing: pr`, unless `OWL_AUTONOMOUS_MAIN=1`), then runs `claude -p --permission-mode bypassPermissions "/owl:evolve"`. launchd fires it **weekly, Mondays at 07:13** (`StartCalendarInterval Weekday=1`; was daily until 2026-07-24 — weekly gives each change a week to be absorbed before the next cycle).

## Why it is this way
- **`.owl/loop-config.yml` is inside the NFR-SEC-1 carve-out** (`docs/decisions/ADR-001-self-improvement-loop.md`) — the loop cannot edit its own brake pedal; changes are human-only.
- **Shadow-only default** contains the risk of an unattended run that bypasses permission prompts and ingests untrusted web/codex content (ADR-010).

## Common operations
- **Arm:** `cp scripts/com.evolvelabs.owl.daily.plist ~/Library/LaunchAgents/ && launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.evolvelabs.owl.daily.plist`
- **Disarm:** `launchctl bootout gui/$(id -u)/com.evolvelabs.owl.daily`
- **Test-fire:** `launchctl kickstart -k gui/$(id -u)/com.evolvelabs.owl.daily`
- **Go fully autonomous (deliberate):** set `landing: main` in `.owl/loop-config.yml` **and** add `OWL_AUTONOMOUS_MAIN=1` to the plist env. Both required.
- **Watch:** `tail -f .owl/state/daily-$(date +%F).log`

## What to watch (known follow-ups)
- **codex deep-research model** unavailable on the account → falls back to `gpt-5.6-luna`. Point `research.model` at an available model if wanted.
- **Tokenless launchd** can't open PRs — a human opens the pushed branch.
- **Mac must be awake** Monday 07:13 (launchd runs at next wake if asleep; missed runs are not stacked).
- `.devflow/knowledge-graph.json` is referenced in `project.yaml` but absent → regenerate via `/agents:chronicler /graph regenerate`.

## Source map
`.owl/loop-config.yml` · `scripts/owl-daily.sh` · `scripts/com.evolvelabs.owl.daily.plist` · `docs/decisions/ADR-001,010` · `CHANGELOG.md` (follow-ups).
