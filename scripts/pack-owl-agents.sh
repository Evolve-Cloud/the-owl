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
# Portable skills. claude-architecture is a hard dep of the consult convention.
# second-brain is included but depends on the /graphify engine being installed
# in the host (noted in the README). project-registry is Evolve-hub-specific
# (reads the workspace projects.yaml) and is intentionally EXCLUDED.
SKILLS=( claude-architecture second-brain )
# Reference ADRs — the "why" behind the shipped conventions + agent design.
# Convention ADRs (004/006/007/008/009), the turn-economy design law (018),
# and second-brain (019, since we ship that skill). Owl-loop governance ADRs
# (001/002/003/005/010-017/020) are NOT shipped.
REFERENCE_ADRS=(
  ADR-004-handoff-contract-convention
  ADR-006-architect-handoff-contract-section
  ADR-007-builder-handoff-contract-section
  ADR-008-chronicler-handoff-contract-section
  ADR-009-role-ownership-convention
  ADR-018-agent-cost-is-context-floor-times-turns
  ADR-019-second-brain-graphify-obsidian-one-vault
)

echo "▸ Rebuilding $OUT/ from canonical sources…"
rm -rf "$OUT"
mkdir -p "$OUT/.claude/commands/agents" \
         "$OUT/.claude/agents" \
         "$OUT/.claude/rules" \
         "$OUT/.claude/agent-reference" \
         "$OUT/.claude/skills" \
         "$OUT/docs/conventions" \
         "$OUT/.devflow/agents"

# --- agents (hybrid: command-personas for the deterministic pipeline + ---------
#     native subagents for ad-hoc auto-delegation; same 11, scout/curator excluded)
for a in "${PIPELINE_AGENTS[@]}"; do
  cp ".claude/commands/agents/$a.md" "$OUT/.claude/commands/agents/$a.md"
  [ -f ".claude/agents/$a.md" ] && cp ".claude/agents/$a.md" "$OUT/.claude/agents/$a.md"
  [ -f ".devflow/agents/$a.meta.yaml" ] && cp ".devflow/agents/$a.meta.yaml" "$OUT/.devflow/agents/$a.meta.yaml"
done

# --- quick/ dev commands + devflow help/status -------------------------------
cp -R ".claude/commands/quick" "$OUT/.claude/commands/quick"
for c in devflow-help devflow-status; do
  [ -f ".claude/commands/$c.md" ] && cp ".claude/commands/$c.md" "$OUT/.claude/commands/$c.md"
done

# --- agent-reference (detailed refs, loaded on demand) -----------------------
cp -R ".claude/agent-reference/." "$OUT/.claude/agent-reference/" 2>/dev/null || true

# --- conventions (also the content for the rules) ----------------------------
for c in "${CONVENTIONS[@]}"; do
  cp "docs/conventions/$c.md" "$OUT/docs/conventions/$c.md"
done

# --- .claude/rules — REAL COPIES, NOT symlinks. The pack is copied to OTHER
#     machines (zip/scp/git-archive), where symlinks break or don't transfer.
#     The conventions already carry paths: frontmatter, so a plain copy is a
#     valid path-scoped rule. (In the-owl itself, .claude/rules/ uses symlinks;
#     the pack deliberately does not.) -----------------------------------------
for c in "${CONVENTIONS[@]}"; do
  cp "docs/conventions/$c.md" "$OUT/.claude/rules/$c.md"
done

# --- skills ------------------------------------------------------------------
for s in "${SKILLS[@]}"; do
  cp -R ".claude/skills/$s" "$OUT/.claude/skills/$s"
done

# --- reference ADRs (the "why" behind the conventions/agent design) ----------
mkdir -p "$OUT/docs/decisions"
for adr in "${REFERENCE_ADRS[@]}"; do
  [ -f "docs/decisions/$adr.md" ] && cp "docs/decisions/$adr.md" "$OUT/docs/decisions/$adr.md"
done
[ -f "docs/decisions/000-template.md" ] && cp "docs/decisions/000-template.md" "$OUT/docs/decisions/000-template.md"

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
- \`.claude/commands/agents/\` — the pipeline personas (command form): strategist ·
  architect · system-designer · builder · guardian · sentinel · challenger ·
  chronicler · database-specialist · mcp-builder · team. (scout/curator = owl-loop
  only, excluded.) These drive the **deterministic** pipeline (/quick:* call them by name).
- \`.claude/agents/\` — the **same $AGENT_COUNT personas as native subagents** (name+description
  frontmatter) for **auto-delegation**: the model picks the right specialist by task,
  no need to remember a command. Hybrid — commands + subagents coexist; restart the CLI
  to load the subagents.
- \`.claude/commands/quick/\` — /quick:* dev commands + devflow-help/status.
- \`.claude/rules/\` — 3 path-scoped rule files (**real copies** of the conventions,
  no symlinks — the pack is portable across machines).
- \`.claude/agent-reference/\` — detailed refs (loaded on demand).
- \`.claude/skills/\` — \`claude-architecture\` (dep of the consult convention) +
  \`second-brain\` (⚠️ requires the \`/graphify\` engine installed in the host to work;
  omit that folder if the host lacks it). \`project-registry\` is NOT shipped
  (Evolve-hub-specific).
- \`docs/conventions/\` — handoff-contract, role-ownership, consult-claude-architecture.
- \`docs/decisions/\` — reference ADRs (the "why"): handoff-contract (004) + its
  rollout (006/007/008), role-ownership (009), agent turn-economy (018),
  second-brain (019), + the ADR template. Owl-loop governance ADRs are excluded.
- \`.devflow/agents/*.meta.yaml\` + \`project.yaml\` template.

## Install
\`\`\`bash
./install.sh /path/to/your-project
\`\`\`
Then set the project name in \`.devflow/project.yaml\` and add the team-agent env to
\`.claude/settings.json\` (see install output). Two ways to invoke: let the model
**auto-delegate** to a native subagent by task, or call a persona explicitly as a
slash-command \`/agents:builder\`, \`/agents:architect\`, \`/quick:new-feature\`, …
(restart the CLI after install so the subagents load).

_Generated by \`scripts/pack-owl-agents.sh\`._
MD

# --- summary -----------------------------------------------------------------
echo "✓ $OUT/ rebuilt:"
echo "  agents:      $(ls "$OUT/.claude/commands/agents" | wc -l | tr -d ' ')"
echo "  quick cmds:  $(ls "$OUT/.claude/commands/quick" 2>/dev/null | wc -l | tr -d ' ')"
echo "  conventions: $(ls "$OUT/docs/conventions" | wc -l | tr -d ' ')"
echo "  rules files: $(ls "$OUT/.claude/rules" | wc -l | tr -d ' ') (real copies, 0 symlinks: $(find "$OUT" -type l | wc -l | tr -d ' '))"
echo "  skills:      $(ls "$OUT/.claude/skills" | wc -l | tr -d ' ')"
echo "  ref ADRs:    $(ls "$OUT/docs/decisions"/ADR-*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "  meta.yaml:   $(ls "$OUT/.devflow/agents" | wc -l | tr -d ' ')"
