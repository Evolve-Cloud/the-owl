#!/usr/bin/env bash
# atlas-bootstrap.sh — empacota o setup do Segundo Cérebro (graphify + Obsidian).
# Doc: docs/second-brain-atlas.md
# Uso: ./scripts/atlas-bootstrap.sh {doctor|install|init [pasta]}
# Security-first: nada destrutivo. 'init' só ADICIONA (hook/config/gitignore); nunca apaga.
set -euo pipefail

say() { printf '  %s\n' "$*"; }
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
no()  { printf '  \033[31m✗\033[0m %s\n' "$*"; }

doctor() {
  echo "== doctor =="
  command -v pipx    >/dev/null 2>&1 && ok "pipx    $(pipx --version 2>/dev/null)" || no "pipx ausente — 'brew install pipx'"
  command -v graphify>/dev/null 2>&1 && ok "graphify $(graphify --version 2>/dev/null)" || no "graphify ausente — rode: $0 install"
  [ -d "$HOME/.claude/skills/graphify" ]      && ok "skill /graphify registrada" || no "skill /graphify ausente — 'graphify install'"
  [ -d "$HOME/.claude/plugins" ] && grep -rqi obsidian "$HOME/.claude/plugins" 2>/dev/null \
      && ok "plugin obsidian-skills presente" \
      || no "obsidian-skills ausente — no Claude Code: /plugin marketplace add kepano/obsidian-skills && /plugin install obsidian@obsidian-skills"
  [ -f "$HOME/.graphify/global-graph.json" ] && ok "grafo global existe ($(graphify global list 2>/dev/null | wc -l | tr -d ' ') repos)" \
      || say "grafo global ainda vazio (criado no 1º 'global add')"
}

install_engine() {
  echo "== install (motor global) =="
  if command -v graphify >/dev/null 2>&1; then ok "graphify já instalado"; else
    command -v pipx >/dev/null 2>&1 || { no "pipx ausente. 'brew install pipx && pipx ensurepath', reabra o shell, rode de novo."; exit 1; }
    say "pipx install graphifyy ..."; pipx install graphifyy
  fi
  say "graphify install (skill) ..."; graphify install >/dev/null && ok "skill /graphify registrada"
  echo
  say "As MÃOS são comandos do Claude Code (não rodam por shell). Cole no prompt do Claude Code:"
  say "  /plugin marketplace add kepano/obsidian-skills"
  say "  /plugin install obsidian@obsidian-skills"
  say "  /reload-plugins"
}

init_project() {
  local dir="${1:-.}"
  cd "$dir"
  echo "== init ($(pwd)) =="
  command -v graphify >/dev/null 2>&1 || { no "graphify ausente — rode: $0 install"; exit 1; }
  [ -d .git ] || say "aviso: não é um repo git — 'hook install' vai pular (sem post-commit)."

  say "graphify claude install (always-on no CLAUDE.md local) ..."; graphify claude install >/dev/null 2>&1 && ok "CLAUDE.md local: seção graphify + PreToolUse hook"
  if [ -d .git ]; then say "graphify hook install (post-commit) ..."; graphify hook install >/dev/null 2>&1 && ok "git hooks instalados (auto-rebuild de CÓDIGO por commit)"; fi

  # gitignore do output gerado (idempotente)
  touch .gitignore
  grep -qxF 'graphify-out/' .gitignore || { echo 'graphify-out/' >> .gitignore; ok "graphify-out/ adicionado ao .gitignore"; }

  echo
  say "Falta o 1º build (dentro do Claude Code, pra a extração semântica usar o host agent):"
  say "  /graphify . --obsidian"
  say "Depois, pra somar ao cérebro cross-projeto:"
  say "  graphify global add graphify-out/graph.json --as $(basename "$(pwd)")"
  echo
  say "Lembretes: CÓDIGO se auto-atualiza no commit (grátis, AST). DOCS = '/graphify --update' manual (LLM, só o delta)."
}

case "${1:-}" in
  doctor)  doctor ;;
  install) install_engine ;;
  init)    init_project "${2:-.}" ;;
  *) echo "uso: $0 {doctor|install|init [pasta]}"; echo "  doctor  — checa o que está instalado"; echo "  install — instala o motor global (pipx graphifyy + skill)"; echo "  init    — aplica o padrão por projeto (claude/hook install + gitignore)"; exit 1 ;;
esac
