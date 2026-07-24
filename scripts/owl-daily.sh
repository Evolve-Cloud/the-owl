#!/usr/bin/env bash
# the-owl — daily self-improvement run.
# Invoked by launchd (see scripts/com.evolvelabs.owl.daily.plist).
# Runs one /owl:evolve cycle headless, SHADOW-ONLY by default (see the guard below).
set -euo pipefail

REPO="/Users/rafaelribeiro/Evolve Labs/the-owl"
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

{
  echo "==== [$(date)] /owl:evolve START (landing=$LANDING) ===="
  # Headless. --permission-mode bypassPermissions: no prompts (unattended).
  # Risk bounded by shadow mode + guardian/sentinel/challenger gate + NFR-SEC-1 carve-out.
  claude -p --permission-mode bypassPermissions "/owl:evolve"
  echo "==== [$(date)] /owl:evolve END (exit $?) ===="
} >> "$LOG" 2>&1
