# ADR-026 — Edge-density > 2.0 é o critério errado para o corpus de prosa do research-vault

**Status:** Proposed — **awaiting human ratification** (recommend-to-human; ver Carve-out). Este ADR foi autorado por @curator DENTRO do próprio ciclo de verificação do `/owl:evolve` (auto-avaliação). Um avaliador independente trata a decisão como **documentada-mas-em-aberto**, não passada: só a ratificação humana fecha o gap. Não é `Accepted` até então.
**Date:** 2026-08-03
**Author:** @curator (proposto no ciclo de verificação do `/owl:evolve`)
**Tags:** [graphify, knowledge-graph, semantic-bar, research-vault, verification, recommend-to-human]

## Contexto
A verificação do build self-learning-memory checou se o grafo do `research-vault` (`graphify-out/graph.json`) é **semântico** por três sub-critérios:

| Sub-critério | Alvo | Medido | Passa? |
|---|---|---|---|
| Comunidades temáticas com nomes reais | > 0 | **25** (MCP Architecture, Agent Role Design, Context Engineering, …), 15 finas omitidas | ✅ |
| God nodes (hubs) | > 0 | **10** (MCP Architecture spec = 30 edges, Research Vault Master Index = 15, …) | ✅ |
| Token cost de extração | > 0 | **33.329 input / 434 output** (GRAPH_REPORT); marker de extração = 87.149 tokens | ✅ |
| Zero nós de obsidian-dump (engine-only) | 0 | **0** (só o motor, sem stub de vault) | ✅ |
| **Densidade de arestas** | **> 2,0 edges/node** | **291 links / 185 nós = 1,573** (1,638 incluindo as 12 hyperedges) | ❌ |

Por comunidade, hub, token-cost e engine-only o grafo **é** semântico. O **único** sub-critério não cumprido é a densidade de arestas: 1,573 < 2,0. Este ADR registra a decisão sobre esse gap — é a razão pela qual o functional_score não fecha em 100.

## Decisão
**O piso de 2,0 edges/node é um critério de _código_ aplicado a um corpus de _prosa/pesquisa_, e é inapropriado aqui.** O `research-vault` são ~185 nós de notas de pesquisa, briefs, páginas de padrão e fontes externas — não símbolos de código com grafos densos de call/import. Páginas de prosa **naturalmente linkam menos densamente** que código: um call-graph tem N chamadas por função; uma nota de pesquisa referencia poucos conceitos adjacentes. Um grafo de prosa a 1,57–1,64 edges/node, **com 25 comunidades temáticas reais, 10 hubs e 92% de arestas EXTRACTED (não INFERRED)**, é um grafo semântico saudável — não um grafo raso.

Registramos, portanto: **para o corpus de prosa do `research-vault`, o critério de qualidade semântica é comunidade-temática + god-nodes + token-cost + engine-only (os quatro cumpridos), NÃO o piso de densidade de 2,0.** O piso de 2,0 permanece válido para grafos de **código** (onde call/import edges o justificam), mas não se aplica a este corpus.

## Alternativas consideradas
- **Alternativa A (escolhida): registrar a decisão de que >2,0 é inapropriado para prosa; manter os quatro critérios cumpridos como a barra semântica deste corpus.** Prós: honesto (a densidade de prosa é intrinsecamente menor que a de código); durável (vira um ADR, a disciplina do repo); custo-zero e determinístico; não arrisca regredir as 25 comunidades boas. Contras: um sub-critério declarado fica formalmente não-cumprido — mitigado por este registro explícito e pela ratificação humana pendente.
- **Alternativa B: re-rodar `graphify … --mode deep` (extração agressiva de arestas INFERRED) para empurrar a densidade acima de 2,0.** Prós: cumpriria a letra do critério. Contras: (1) **aritmética contra** — 185 × 2,0 = 370 arestas; estamos em 291; precisaríamos de **+79 arestas (+27%)** com o denominador **crescendo** (deep mode adiciona nós), um coin-flip genuíno; (2) `--mode deep` **re-clusteriza** e pode **regredir** as 25 comunidades reais e os 10 hubs — trocar 1,57 com comunidades boas por 2,1 com comunidades lixo é um resultado **pior**; (3) inflar com arestas INFERRED (hoje só 24/291 = 8%) baixaria a taxa EXTRACTED de 92%, degradando a honestidade do grafo para satisfazer um número; (4) sem `GEMINI_API_KEY`, a extração semântica cai para o host-LLM via subagentes despachados — indisponível de forma confiável no contexto headless deste ciclo, e caro em turnos (ADR-018). Rejeitada: alto custo, alto risco de regressão, ganho incerto, e otimiza um proxy (o número) contra o alvo real (grafo útil e honesto).
- **Alternativa C: não registrar nada e deixar o gap implícito.** Rejeitada — viola a disciplina ADR do repo (toda decisão vira um ADR) e deixaria um reviewer futuro sem saber se o gap foi analisado ou ignorado.

## Consequências
- **Fica mais fácil:** a barra semântica deste corpus fica explícita e defensável — quatro critérios cumpridos, densidade reconhecida como métrica de código não aplicável a prosa. Um reviewer futuro lê a decisão em vez de reabrir o gap.
- **Trade-off:** um sub-critério declarado (`>2,0`) fica formalmente não-cumprido. Aceito e registrado, não silenciado.
- **Reversível:** se um humano ratificar que a densidade **deve** subir mesmo em prosa, o caminho é a Alternativa B (deep mode) num ciclo dedicado — com backup do `graphify-out/` atual (feito neste ciclo) e o gate de não-regressão: só trocar o grafo se `--mode deep` **clarear 2,0 E preservar** as 25 comunidades, os 10 hubs e o 0-dump. O backup vive no scratch deste ciclo.
- **Sem runtime, sem carve-out tocado:** este ADR é markdown; não altera `.owl/loop-config.yml`, o schedule, nem os agentes do carve-out.

## Carve-out / recommend-to-human
Esta é uma decisão sobre **o que conta como "semântico o suficiente"** — um julgamento de qualidade, não uma mudança de mecanismo. Marcada **recommend-to-human**: o status é `Proposed` (proposta do loop, auto-avaliação), **não** `Accepted` — a ratificação de que "o piso de 2,0 não se aplica a prosa" é **do humano** e está pendente. Enquanto pendente, o sub-critério de densidade permanece formalmente em aberto e o functional_score não fecha em 100 — resultado correto, não um bug a mascarar. Se o humano preferir empurrar a densidade, executar a Alternativa B num ciclo dedicado, com o gate de não-regressão acima.

## Notas de verificação
- `nodes=185 · links=291 · hyperedges=12 · ratio=1,573 · ratio_incl_hyperedges=1,638` (medido de `graph.json`, 2026-08-03).
- 25 comunidades nomeadas, 10 god-nodes, 92% EXTRACTED / 8% INFERRED (24 arestas, confiança média 0,84), 0 nós de obsidian-dump (`GRAPH_REPORT.md`).
- Backup do `graphify-out/` atual preservado antes de qualquer re-extração, para permitir a Alternativa B sem risco de perda.
