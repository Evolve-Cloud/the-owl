---
name: update-owl-agents
description: Use to (re)build the portable owl-agents/ production pack — the functional DevFlow pipeline ported from the-owl WITHOUT the self-improvement loop / auto-update. Invoke after changing any pipeline agent (.claude/commands/agents/*.md), convention (docs/conventions/), quick command, agent-reference, meta.yaml, or the claude-architecture skill, so owl-agents/ stays in sync with the canonical sources. Deterministic — it regenerates the folder from source, never hand-curates it. Not for editing agents themselves (edit the canonical source, then run this).
---

# /update-owl-agents — rebuild the portable pack

`owl-agents/` is the **production-ready, copy-anywhere** DevFlow pipeline (11 functional agents + conventions + rules + quick commands + claude-architecture skill), ported from the-owl **without** the owl self-improvement loop, research-vault, fitness harness, or scout/curator. It is **generated**, never hand-edited — the source of truth stays in the-owl's canonical files.

## What to do

1. **Run the packer** (it does a clean rebuild from source):
   ```bash
   bash scripts/pack-owl-agents.sh
   ```
   This reads the manifest inside the script (11 pipeline agents; scout/curator + owl loop excluded), wipes `owl-agents/`, and rewrites it: agents, `.devflow/agents/*.meta.yaml`, `docs/conventions/`, the 3 `.claude/rules/` symlinks, `quick/` commands, `agent-reference/`, the `claude-architecture` skill, a clean `project.yaml` template, plus `install.sh` and `README.md`.

2. **Verify the output** (the script prints counts). Confirm:
   - agents = 11 · conventions = 3 · rules links = 3 · skills = 2 · ref ADRs = 7 · meta.yaml = 11
   - `owl-agents/.claude/rules/*.md` resolve and carry `paths:` frontmatter
   - scout/curator are **absent** from `owl-agents/.claude/commands/agents/`
   - `project-registry` is **absent** from `owl-agents/.claude/skills/` (hub-specific)
   If a count is wrong, the manifest in `scripts/pack-owl-agents.sh` and the source files disagree — reconcile, don't patch the output.

3. **(Optional) smoke-test the installer** into a throwaway dir:
   ```bash
   T="$(mktemp -d)"; (cd owl-agents && ./install.sh "$T"); rm -rf "$T"
   ```

4. **Report** to the user: what changed in the pack (which agents/conventions moved), the counts, and remind them the pack is copied via `owl-agents/install.sh /path/to/project`.

## Hard rules
- **Never hand-edit `owl-agents/`** — it is disposable output. To change a ported agent, edit its canonical source (`.claude/commands/agents/<name>.md`), then re-run this skill.
- **Never add owl-loop machinery** to the pack (no `/owl:evolve`, research-vault, `.owl/`, eval/, scout, curator). That is the whole point of the port — the functional pipeline without auto-update.
- To change WHAT gets ported (add/remove an agent, include another skill), edit the **manifest arrays** at the top of `scripts/pack-owl-agents.sh`, then re-run — do not copy files into `owl-agents/` by hand.
