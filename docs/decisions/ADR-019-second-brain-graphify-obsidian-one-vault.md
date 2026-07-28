# ADR-019 — Segundo Cérebro: graphify (mapa) + Obsidian (mãos), um vault só

**Status:** Accepted
**Date:** 2026-07-28
**Author:** @chronicler (sessão human-directed)
**Tags:** [knowledge-graph, obsidian, tooling, second-brain, security]
**Related:** ADR-017 (research vault / curator), ADR-013 (claim verification — as tags de honestidade), ADR-018 (token economy — "paga 1x, economiza sempre nas queries")

## Contexto
Queríamos (a) um cérebro **consultável** sobre nosso código/docs (perguntar "como funciona X?" sem re-ler o repo) e (b) um lugar durável para **acumular** conhecimento. Duas ferramentas locais (100% na máquina, sem servidor/cloud/key):
- **graphify** (github.com/Graphify-Labs/graphify, Apache-2.0) — AST determinístico (tree-sitter) + o host agent como LLM para docs — transforma pasta em grafo de conhecimento com tags de honestidade (EXTRACTED/INFERRED/AMBIGUOUS) e query/path/explain (+ `graphify-mcp`);
- **obsidian-skills** (kepano/obsidian-skills, MIT, do CEO do Obsidian) — dão ao agente as mãos p/ operar um vault Obsidian (markdown/Bases/Canvas/CLI).

O risco central: os dois **parecem** fazer a mesma coisa, e já temos um vault **curado** (`research-vault`, com `SCHEMA.md`/index/ledger). Rodar `graphify export obsidian` cria um **segundo vault** que fragmenta e polui o curado com stubs auto-gerados (que o graphify ainda regenera/sobrescreve a cada rebuild).

## Decisão
1. **graphify = MOTOR DE QUERY** (via `graphify-mcp` / `graphify query` / `graph.html`), não um vault. O `graph.json` é a fonte consultável; a query do agente **não precisa de stubs no Obsidian**.
2. **UM VAULT SÓ — o `research-vault` é a casa humana.** Nunca criar segundo vault nem despejar stubs no vault curado. Papéis, sem redundância: **graphify = leitura/mapa** (files→grafo, read-only); **Obsidian research-vault = escrita/humano** (síntese autorada respeitando o SCHEMA). Default do `init` = query-mode (sem `--obsidian`); export de vault só p/ subpasta dedicada (`--obsidian-dir <vault>/maps/<proj>`), nunca o root.
3. **Empacotar:** `docs/second-brain-atlas.md` (processo), `scripts/atlas-bootstrap.sh` (doctor/install/init), skill `/second-brain` (orquestrador *routing* sobre `/graphify`, moldado pela skill `claude-architecture`).

## Auto-update (assimétrico — decisão factual)
Um git post-commit hook roda **fora** do Claude Code → só o que não precisa de LLM: **código** re-extrai via AST a cada commit (grátis, automático); **docs** precisam de LLM → `/graphify --update` manual (barato, só o delta, cache SHA256). `graphify check-update` avisa quando há re-extração semântica pendente.

## Alternativas consideradas
- **A (escolhida): graphify=query-engine + research-vault único.** Sem redundância; vault curado intocado.
- **B: um vault graphify separado.** Rejeitada — 2 vaults fragmentam; stubs auto-gerados poluem o research-vault e furam o SCHEMA.
- **C: só Obsidian (sem graphify).** Rejeitada — sem query estrutural do código.
- **D: só graphify (sem Obsidian).** Rejeitada — sem casa de escrita/acúmulo humano.

## Consequências
- **Provado:** research-vault (70 docs) → grafo de **246 nós**; agentes (13) → **54 nós**; ambos no cérebro global `~/.graphify/global-graph.json` (**300 nós**) — query cross-projeto funcionando. research-vault **100% intocado**.
- **Economia:** query no grafo ~71,5x menos token que re-ler arquivos (mesmo princípio do ADR-018).
- **Gotcha registrado:** ao indexar um vault existente, passar `root=<vault>` faz o graphify criar `<vault>/graphify-out/cache/` — buildar num dir dedicado **fora** do vault e limpar qualquer `graphify-out` que apareça dentro.
- **Segurança (security-first):** local-only; graphify pula `skipped_sensitive`; código=AST não vaza valor; docs passam pelo LLM → segredo fora de doc; o vault humano nunca recebe stubs auto-gerados.
