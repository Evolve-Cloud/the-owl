#!/usr/bin/env bash
# the-owl — self-improvement run (scheduled WEEKLY, Mondays 07:13; was daily until 2026-07-24).
# Invoked by launchd (see scripts/com.evolvelabs.owl.daily.plist — legacy "daily" name, weekly cadence).
# Runs one /owl:evolve cycle headless, SHADOW-ONLY by default (see the guard below).
# This wrapper is cadence-agnostic: it runs exactly one cycle per invocation; launchd sets the frequency.
set -euo pipefail

# ⚠️ 2026-08-12: este path estava SEM o nível "Evolve Labs" duplicado e apontava para
# ~/Evolve Labs/the-owl — uma casca (só .owl/ + venv/, sem git). O launchd disparava toda
# segunda 07:13 desde ~24/jul, o cd na casca FUNCIONAVA, e a run morria no grep do
# loop-config abaixo, em silêncio. 3 semanas de cadência semanal morta; todo ciclo desde
# então foi disparado por humano. O plist irmão carregava o mesmo erro em 3 paths.
REPO="/Users/rafaelribeiro/Evolve Labs/Evolve Labs/the-owl"
if [ ! -f "$REPO/.owl/loop-config.yml" ]; then
  echo "FATAL: REPO=$REPO não parece ser o the-owl (falta .owl/loop-config.yml)." >&2
  exit 4
fi
# nvm node (codex + claude), homebrew, system paths
export PATH="$HOME/.nvm/versions/node/v20.19.0/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/github -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

cd "$REPO"
mkdir -p "$REPO/.owl/state"
LOG="$REPO/.owl/state/daily-$(date +%F).log"

# --- Safety guard: unattended runs are SHADOW-ONLY by default ----------------
# Headless runs bypass permission prompts AND ingest untrusted web/codex content.
# Containment = shadow mode (the loop opens PRs; never touches main). Going
# straight-to-main from cron must be a DELIBERATE opt-in (OWL_AUTONOMOUS_MAIN=1).
LANDING="$(grep -E '^landing:' "$REPO/.owl/loop-config.yml" | awk '{print $2}')"
if [ "$LANDING" != "pr" ] && [ "${OWL_AUTONOMOUS_MAIN:-0}" != "1" ]; then
  echo "[$(date)] REFUSING: landing='$LANDING' and OWL_AUTONOMOUS_MAIN!=1 — unattended run is shadow-only." >> "$LOG"
  exit 3
fi

START_EPOCH=$(date +%s)
STARTED_AT="$(date -u +%FT%TZ)"
echo "==== [$(date)] /owl:evolve START (landing=$LANDING) ====" >> "$LOG"
# Headless. --permission-mode bypassPermissions: no prompts (unattended).
# Risk bounded by shadow mode + guardian/sentinel/challenger gate + NFR-SEC-1 carve-out.
# --output-format json (ADR-043): stdout vira o result-JSON da sessão (inclui
# total_cost_usd + usage) — capturado em OUT_JSON; o texto final + resumo vão pro LOG.
OUT_JSON="$REPO/.owl/state/last-run-output.json"
set +e
claude -p --permission-mode bypassPermissions --output-format json "/owl:evolve" > "$OUT_JSON" 2>> "$LOG"
RUN_EXIT=$?
set -e
END_EPOCH=$(date +%s)
echo "==== [$(date)] /owl:evolve END (exit $RUN_EXIT, $((END_EPOCH - START_EPOCH))s wall) ====" >> "$LOG"

# Cost instrumentation (ADR-043, closes ADR-012 FP5): parse REAL numbers from the
# session result-JSON. Parse failure => nulls + note (never fabricate, ADR-012).
# Note: subscription-auth runs may report cost 0.0 — tokens are the durable signal.
python3 - "$OUT_JSON" "$REPO/.owl/state/last-cycle-metrics.json" "$STARTED_AT" "$((END_EPOCH - START_EPOCH))" "$RUN_EXIT" "$LOG" <<'PYEOF'
import json, sys, datetime
out_json, metrics_path, started_at, wall_s, run_exit, log = sys.argv[1:7]
cost = tokens = None; note = "parsed from claude -p --output-format json"
try:
    d = json.load(open(out_json))
    cost = d.get("total_cost_usd")
    u = d.get("usage") or {}
    parts = [u.get(k) for k in ("input_tokens","output_tokens","cache_read_input_tokens","cache_creation_input_tokens")]
    tokens = sum(p for p in parts if isinstance(p, (int, float))) or None
    result_text = d.get("result") or ""
    open(log, "a").write("\n--- session result (from JSON) ---\n" + result_text[-4000:] + "\n")
except Exception as e:
    note = f"cost parse FAILED ({type(e).__name__}) — nulls kept, never fabricated"
json.dump({
    "started_at": started_at,
    "ended_at": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "wall_clock_s": int(wall_s), "run_exit": int(run_exit),
    "cost_usd": cost, "tokens": tokens, "note": note,
}, open(metrics_path, "w"), indent=2)
PYEOF
exit $RUN_EXIT
