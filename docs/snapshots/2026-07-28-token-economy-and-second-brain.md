# Snapshot — 2026-07-28: token economy + Second Brain

Sessão human-directed (2026-07-27/28). Dois entregáveis, ambos no `main` do the-owl
(5 commits `f77e49c`..`d705413`). ADRs: **018** (token economy) e **019** (second brain).

## 1. Token economy dos agentes (ADR-018)
- **Medido, não teoria:** `custo = piso de contexto (~84k harness) × nº de turnos`. Verdade-terreno = transcript
  (o auto-report do agente mentiu). `CLAUDE.md` **não** está em subagentes. Descartados <8%: tamanho de arquivo, skill, MCP.
- **Lever `⚡ ECONOMIA DE TURNOS`** nos 4 agentes afinados (architect/builder/chronicler/system-designer) + ponteiro do reference apertado.
- **Resultado:** builder 22→6 (−57%), architect 10→3 (−49%), system-designer 9→3 (−37%), chronicler neutro. Qualidade preservada.

## 2. Second Brain — graphify + Obsidian (ADR-019)
- Tooling: `docs/second-brain-atlas.md` + `scripts/atlas-bootstrap.sh` + skill `/second-brain` (routing sobre `/graphify`).
- **UM VAULT SÓ:** research-vault = casa curada; graphify = query-engine (MCP/CLI/`graph.html`), nunca segundo vault.
- **Cérebro global:** research-vault (246 nós) + owl-agents (54) = **300 nós** em `~/.graphify/global-graph.json`. Query cross-projeto provada. research-vault intocado.
- **Auto-update assimétrico:** código = AST-on-commit (grátis, `graphify hook install`) / docs = `/graphify --update` (LLM, manual).

## Fora do repo (provenance)
- `~/.claude/CLAUDE.md` (44,5k) → split em regras-only + `~/.claude/HISTORY.md` (changelog datado) → −43k/turno no loop principal. Backup `CLAUDE.md.bak-*`.
- Global: graphify (pipx `graphifyy` + skill `/graphify`) + obsidian-skills (plugin). Grafos em `~/.graphify/`.

## Estado da doc
- CHANGELOG: bloco "Session 2026-07-27/28" em `[Unreleased]`.
- ADRs 018 + 019 escritos (docs/decisions/). ADRs anteriores 001–017 intactos.

## Próximos naturais
- `/second-brain init` num projeto de código real (atlas-portal/octopus_idp) → onde a query 71,5x paga.
- Ligar o `graphify hook install` onde o auto-update de código fizer sentido.
