---
name: project-registry
description: Use to discover and register the projects in the Evolve Labs workspace and see each one's state (new / scaffolded / active) — the hub's `projects.yaml` registry maintained by the-owl. Invoke when the user wants to know what projects exist, "onboard"/register a project into the model, refresh the registry, or see which projects are bare vs active. Runs a deterministic, READ-ONLY scan (filesystem + git); it never mutates any project. Not for editing project code.
version: 1.0.0
user-invocable: true
license: Apache 2.0
allowed-tools:
  - Bash(python3 *discover.py*)
  - Read
---

the-owl is the **hub** for a workspace of many projects. This skill maintains the registry at **`the-owl/.devflow/projects.yaml`** — a map of every project + its state — so you can manage them from one place without touching their code.

## Run it (report-only)
```
python3 <this skill's dir>/discover.py     # scans the workspace → rewrites projects.yaml → prints a summary
```
Then `Read` `the-owl/.devflow/projects.yaml` for the full registry. The script is **deterministic** (no LLM — the crystallized half) and **REPORT-ONLY**: it reads the filesystem + git and writes *only the-owl's registry*; it **never** creates, edits, or deletes anything in another project.

## What it records — per project
`name` · `path` (relative to the workspace) · `state` · `has_claude` · `has_devflow` · `has_docs` · `git_commits` · `last_commit`.

**State classification** (owner-confirmed, git-based):
- **active** — a git repo with ≥ 10 commits (real, worked-on project).
- **scaffolded** — has `.claude/` or `.devflow/` but light (structure present, little history).
- **new** — bare (no `.claude/`/`.devflow/`, minimal git).

## Scan rules (why the numbers are right)
- A **project root** = a dir with `.git/` **or** `.claude/` **or** `.devflow/`. A `.git/` dir is a **hard boundary** (don't descend into a repo).
- A `.claude`/`.devflow`-only dir (e.g. a **container** like `Projects/` that itself has a shared `.claude/`) is recorded *and recursed* to find nested git projects; afterwards a **container ancestor is dropped** if it holds another registered project. (This is why `Projects/octopus_idp`, `…/lambdas_qa`, etc. appear individually.)
- Depth ≤ 3; skips `node_modules`, `dist`, `build`, `.venv`, etc.

## Important: register ≠ install
The agent fleet + skills are already **global** (symlinked into `~/.claude/` from the-owl), so **every project already inherits them** — registering a project here does **not** wire agents. This skill is the **map + state report**, not an installer. To point a project's agents at a project-specific override, add a project-level `.claude/` (which wins over the global one).

## When to regenerate
After creating a new project, or when you want a fresh view. The registry is a snapshot committed to the-owl — re-run + commit when you want it current.

## Related
- Fleet source + global delivery: the-owl `.claude/commands/agents/` + `.claude/skills/` → symlinked into `~/.claude/`.
- Registry file: `the-owl/.devflow/projects.yaml`.
