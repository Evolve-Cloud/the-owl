#!/usr/bin/env bash
# the-owl — daily self-improvement run.
# Invoked by launchd (see scripts/com.evolvelabs.owl.daily.plist).
# Runs one /owl:evolve cycle headless. Landing mode (pr|main) is read from
# .owl/loop-config.yml by the loop itself — this wrapper does not decide it.
set -euo pipefail

REPO="/Users/rafaelribeiro/Evolve Labs/the-owl"
# nvm node (codex + claude), homebrew, system paths
export PATH="$HOME/.nvm/versions/node/v20.19.0/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/github -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

cd "$REPO"
mkdir -p "$REPO/.owl/state"
LOG="$REPO/.owl/state/daily-$(date +%F).log"

{
  echo "==== [$(date)] /owl:evolve START ===="
  # Headless Claude Code run of the loop command.
  claude -p "/owl:evolve"
  echo "==== [$(date)] /owl:evolve END (exit $?) ===="
} >> "$LOG" 2>&1
