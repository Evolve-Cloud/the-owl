#!/usr/bin/env bash
# install.sh — install the DevFlow pipeline into a target project.
# Usage: ./install.sh /path/to/target-project
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"
[ -z "$TARGET" ] && { echo "usage: ./install.sh /path/to/target-project"; exit 1; }
[ -d "$TARGET" ] || { echo "target not found: $TARGET"; exit 1; }

echo "▸ Installing DevFlow agents into $TARGET"
mkdir -p "$TARGET/.claude/commands" "$TARGET/.claude/skills" "$TARGET/docs" "$TARGET/.devflow"

# copy trees — all REAL files (the pack has no symlinks, so this is
# portable across machines / OSes / zip transfers)
cp -R "$HERE/.claude/commands/agents"       "$TARGET/.claude/commands/"
cp -R "$HERE/.claude/commands/quick"        "$TARGET/.claude/commands/"
# native subagents (hybrid): enable auto-delegation alongside the commands
[ -d "$HERE/.claude/agents" ] && cp -R "$HERE/.claude/agents" "$TARGET/.claude/"
for f in devflow-help devflow-status; do
  [ -f "$HERE/.claude/commands/$f.md" ] && cp "$HERE/.claude/commands/$f.md" "$TARGET/.claude/commands/"
done
cp -R "$HERE/.claude/agent-reference"       "$TARGET/.claude/"
cp -R "$HERE/.claude/rules"                 "$TARGET/.claude/"
cp -R "$HERE/.claude/skills/."              "$TARGET/.claude/skills/"
cp -R "$HERE/docs/conventions"              "$TARGET/docs/"
[ -d "$HERE/docs/decisions" ] && cp -R "$HERE/docs/decisions" "$TARGET/docs/"
# .devflow: don't clobber an existing project.yaml
cp -R "$HERE/.devflow/agents"               "$TARGET/.devflow/"
[ -f "$TARGET/.devflow/project.yaml" ] || cp "$HERE/.devflow/project.yaml" "$TARGET/.devflow/project.yaml"

echo "✓ Installed. Post-install:"
echo "  • The 'team' agent needs this in $TARGET/.claude/settings.json:"
echo '      { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }'
echo "  • Set project name in $TARGET/.devflow/project.yaml"
echo "  • Hybrid invocation: native subagents in .claude/agents/ AUTO-DELEGATE by"
echo "    description; the same personas as commands (/agents:builder, …) drive the"
echo "    deterministic pipeline (/quick:*). Restart the CLI to load the subagents."
