#!/usr/bin/env bash
# sync-persona-pair.sh — make ADR-028 mechanical instead of disciplinary.
#
# Canonical source: .claude/agents/<x>.md  (native subagent: frontmatter + body)
# Derived copy:     .claude/commands/agents/<x>.md  (command persona: body only,
#                   with relative links one level deeper)
#
# Modes:
#   --check   compare every pair after normalization; exit 1 on drift (CI/gate use)
#   --sync    regenerate every command copy from its agent copy
#   --sync X  regenerate only agent X
#
# Transformations applied when deriving the command copy:
#   1. strip the YAML frontmatter block (harness-enforced fields live ONLY on the
#      subagent half — ADR-034 asymmetry, verified 2026-08-12)
#   2. relative links gain one level: ](../../ -> ](../../../  and (../../ in
#      markdown links only (commands/agents/ is one dir deeper than agents/)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$HERE/.claude/agents"
CMDS_DIR="$HERE/.claude/commands/agents"

derive() { # $1 = agent .md path -> derived body on stdout
  awk 'BEGIN{fm=0; done=0}
    NR==1 && $0=="---" {fm=1; next}
    fm==1 && done==0 { if ($0=="---") {done=1}; next }
    {print}' "$1" \
  | sed -E 's/\]\(\.\.\/\.\.\//](..\/..\/..\//g' \
  | awk 'NR==1 && $0=="" {next} {print}'
}

MODE="${1:---check}"
ONLY="${2:-}"
fail=0

for agent_file in "$AGENTS_DIR"/*.md; do
  name="$(basename "$agent_file" .md)"
  [ -n "$ONLY" ] && [ "$name" != "$ONLY" ] && continue
  cmd_file="$CMDS_DIR/$name.md"
  if [ ! -f "$cmd_file" ]; then
    echo "✗ $name — command copy MISSING ($cmd_file)"; fail=1; continue
  fi
  case "$MODE" in
    --check)
      if diff -q <(derive "$agent_file") "$cmd_file" >/dev/null 2>&1; then
        echo "✓ $name — in sync"
      else
        echo "✗ $name — DRIFT (diff below, derived-from-agent vs command copy):"
        diff <(derive "$agent_file") "$cmd_file" | head -20 || true
        fail=1
      fi ;;
    --sync)
      derive "$agent_file" > "$cmd_file"
      echo "↻ $name — command copy regenerated from agent copy" ;;
    *) echo "usage: $0 [--check|--sync] [agent-name]"; exit 2 ;;
  esac
done

[ "$MODE" = "--check" ] && [ "$fail" -eq 1 ] && {
  echo ""; echo "ADR-028 drift detected. Fix the CANONICAL copy (.claude/agents/) then run: $0 --sync"; exit 1; }
exit 0
