#!/usr/bin/env bash
# pack-owl-agents.sh — deterministically (re)build owl-agents/ from the canonical
# sources in this repo. owl-agents/ is the PRODUCTION-READY, portable DevFlow
# pipeline (functional agents WITHOUT the owl self-improvement loop / auto-update).
#
# Source of truth = .claude/commands/agents/, docs/conventions/, etc. This script
# is the ONLY thing that writes owl-agents/ — never hand-edit the output.
# Invoked by the /update-owl-agents skill.
#
# Usage: scripts/pack-owl-agents.sh   (run from repo root)
set -euo pipefail

# --- locate repo root (script lives in scripts/) -----------------------------
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
OUT="owl-agents"

# --- MANIFEST ----------------------------------------------------------------
# Pipeline agents to port (the functional DevFlow set). scout + curator are the
# owl-loop research/scoring agents and are DELIBERATELY excluded.
PIPELINE_AGENTS=(
  strategist architect system-designer builder guardian
  sentinel challenger chronicler database-specialist mcp-builder team
)
# Conventions (each carries paths: frontmatter → path-scoped auto-load).
CONVENTIONS=( handoff-contract role-ownership consult-claude-architecture )
# Portable skills (claude-architecture is a hard dep of the consult convention).
SKILLS=( claude-architecture )

echo "▸ Rebuilding $OUT/ from canonical sources…"
rm -rf "$OUT"
mkdir -p "$OUT/.claude/commands/agents" \
         "$OUT/.claude/rules" \
         "$OUT/.claude/agent-reference" \
         "$OUT/.claude/skills" \
         "$OUT/docs/conventions" \
         "$OUT/.devflow/agents"

# --- agents ------------------------------------------------------------------
for a in "${PIPELINE_AGENTS[@]}"; do
  cp ".claude/commands/agents/$a.md" "$OUT/.claude/commands/agents/$a.md"
  [ -f ".devflow/agents/$a.meta.yaml" ] && cp ".devflow/agents/$a.meta.yaml" "$OUT/.devflow/agents/$a.meta.yaml"
done

# --- quick/ dev commands + devflow help/status -------------------------------
cp -R ".claude/commands/quick" "$OUT/.claude/commands/quick"
for c in devflow-help devflow-status; do
  [ -f ".claude/commands/$c.md" ] && cp ".claude/commands/$c.md" "$OUT/.claude/commands/$c.md"
done

# --- agent-reference (detailed refs, loaded on demand) -----------------------
cp -R ".claude/agent-reference/." "$OUT/.claude/agent-reference/" 2>/dev/null || true

# --- conventions (source of truth for the rules symlinks) --------------------
for c in "${CONVENTIONS[@]}"; do
  cp "docs/conventions/$c.md" "$OUT/docs/conventions/$c.md"
done

# --- .claude/rules symlinks (recreated relative → resolve inside the pack AND
#     at a target project root: ../../docs/conventions/*) ---------------------
for c in "${CONVENTIONS[@]}"; do
  ( cd "$OUT/.claude/rules" && ln -sf "../../docs/conventions/$c.md" "$c.md" )
done

# --- skills ------------------------------------------------------------------
for s in "${SKILLS[@]}"; do
  cp -R ".claude/skills/$s" "$OUT/.claude/skills/$s"
done

# --- clean .devflow/project.yaml TEMPLATE (NOT the-owl's own state) ----------
cat > "$OUT/.devflow/project.yaml" <<'YAML'
# DevFlow Project Metadata — TEMPLATE
# Ported from the-owl (functional pipeline, no self-improvement loop).
# Fill name/description for the host project; @chronicler maintains the rest.
project:
  name: "CHANGE-ME"
  version: "0.1.0"
  description: "Multi-agent DevFlow pipeline (ported from the-owl, no auto-update loop)"
  status: "active"

# 11 pipeline agents (scout/curator + owl loop intentionally excluded)
agents:
  - { id: strategist,          role: planning,           focus: "Planejamento & Produto" }
  - { id: architect,           role: design,             focus: "Design & Arquitetura" }
  - { id: system-designer,     role: system-design,      focus: "System Design & Escala" }
  - { id: builder,             role: implementation,     focus: "Implementação" }
  - { id: guardian,            role: quality,            focus: "Qualidade & Testes" }
  - { id: sentinel,            role: security,           focus: "Segurança & Vulnerabilidades" }
  - { id: challenger,          role: adversarial-review, focus: "Revisão Adversarial" }
  - { id: chronicler,          role: documentation,      focus: "Documentação & Memória" }
  - { id: database-specialist, role: data,               focus: "Modelagem & Banco de Dados" }
  - { id: mcp-builder,         role: implementation,     focus: "MCP servers/clients" }
  - { id: team,                role: orchestration,      focus: "Orquestração Paralela" }
YAML

# --- install.sh (drops the pack into a target project root) ------------------
cat > "$OUT/install.sh" <<'SH'
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

# copy trees (cp -R preserves the rules/ symlinks as symlinks)
cp -R "$HERE/.claude/commands/agents"       "$TARGET/.claude/commands/"
cp -R "$HERE/.claude/commands/quick"        "$TARGET/.claude/commands/"
for f in devflow-help devflow-status; do
  [ -f "$HERE/.claude/commands/$f.md" ] && cp "$HERE/.claude/commands/$f.md" "$TARGET/.claude/commands/"
done
cp -R "$HERE/.claude/agent-reference"       "$TARGET/.claude/"
cp -R "$HERE/.claude/skills/."              "$TARGET/.claude/skills/"
cp -R "$HERE/docs/conventions"              "$TARGET/docs/"
# .devflow: don't clobber an existing project.yaml
cp -R "$HERE/.devflow/agents"               "$TARGET/.devflow/"
[ -f "$TARGET/.devflow/project.yaml" ] || cp "$HERE/.devflow/project.yaml" "$TARGET/.devflow/project.yaml"

# recreate rules symlinks explicitly (robust across cp behaviors)
mkdir -p "$TARGET/.claude/rules"
for c in handoff-contract role-ownership consult-claude-architecture; do
  ( cd "$TARGET/.claude/rules" && ln -sf "../../docs/conventions/$c.md" "$c.md" )
done

echo "✓ Installed. Post-install:"
echo "  • The 'team' agent needs this in $TARGET/.claude/settings.json:"
echo '      { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }'
echo "  • Set project name in $TARGET/.devflow/project.yaml"
echo "  • Agents are slash-commands: /agents:builder, /agents:architect, … (or /quick:*)"
SH
chmod +x "$OUT/install.sh"

# --- README ------------------------------------------------------------------
AGENT_COUNT=${#PIPELINE_AGENTS[@]}
cat > "$OUT/README.md" <<MD
# owl-agents — portable DevFlow pipeline

Production-ready, **functional** multi-agent pipeline ported from **the-owl** —
**without** the self-improvement loop (\`/owl:evolve\`), research-vault, fitness
harness, or any auto-update. Pure markdown + YAML; no runtime.

> ⚠️ **Do not hand-edit this folder.** It is regenerated from the-owl by
> \`scripts/pack-owl-agents.sh\` (via the \`/update-owl-agents\` skill). Edit the
> canonical sources in the-owl, then re-pack.

## What's inside ($AGENT_COUNT agents)
- \`.claude/commands/agents/\` — the pipeline: strategist · architect · system-designer ·
  builder · guardian · sentinel · challenger · chronicler · database-specialist ·
  mcp-builder · team. (scout/curator = owl-loop only, excluded.)
- \`.claude/commands/quick/\` — /quick:* dev commands + devflow-help/status.
- \`.claude/rules/\` — 3 symlinks → docs/conventions (path-scoped auto-load).
- \`.claude/agent-reference/\` — detailed refs (loaded on demand).
- \`.claude/skills/claude-architecture/\` — dep of the consult convention.
- \`docs/conventions/\` — handoff-contract, role-ownership, consult-claude-architecture.
- \`.devflow/agents/*.meta.yaml\` + \`project.yaml\` template.

## Install
\`\`\`bash
./install.sh /path/to/your-project
\`\`\`
Then set the project name in \`.devflow/project.yaml\` and add the team-agent env to
\`.claude/settings.json\` (see install output). Invoke agents as slash-commands:
\`/agents:builder\`, \`/agents:architect\`, \`/quick:new-feature\`, …

_Generated by \`scripts/pack-owl-agents.sh\`._
MD

# --- summary -----------------------------------------------------------------
echo "✓ $OUT/ rebuilt:"
echo "  agents:      $(ls "$OUT/.claude/commands/agents" | wc -l | tr -d ' ')"
echo "  quick cmds:  $(ls "$OUT/.claude/commands/quick" 2>/dev/null | wc -l | tr -d ' ')"
echo "  conventions: $(ls "$OUT/docs/conventions" | wc -l | tr -d ' ')"
echo "  rules links: $(find "$OUT/.claude/rules" -type l | wc -l | tr -d ' ')"
echo "  skills:      $(ls "$OUT/.claude/skills" | wc -l | tr -d ' ')"
echo "  meta.yaml:   $(ls "$OUT/.devflow/agents" | wc -l | tr -d ' ')"
