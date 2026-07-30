# /second-brain — detalhe do `query` (responder do grafo)

Leia isto **só quando for responder uma pergunta**. Objetivo: responder da **estrutura do
grafo**, não re-lendo os arquivos (é o ganho de ~71,5x token).

## Roteamento da query

1. **A pergunta cruza projetos?** ("onde mais usamos X", "que projetos têm Y") → grafo **global**:
   ```bash
   graphify global path   # localiza ~/.graphify/global-graph.json
   graphify query "<pergunta>" --graph ~/.graphify/global-graph.json
   ```
2. **Sobre o projeto atual?** → grafo local, se existir:
   ```bash
   test -f graphify-out/graph.json && graphify query "<pergunta>"
   ```
3. **Não existe grafo** (`graphify-out/graph.json` ausente) → **não invente**. Ofereça `/second-brain init`.

## Boas práticas ao responder

- Antes da traversal, expanda os termos da pergunta contra o vocabulário do grafo
  (um mismatch de wording colapsa a resposta em ruído).
- `--budget N` limita a resposta a N tokens; `--dfs` traça um caminho específico (BFS = contexto amplo).
- Se o CLI `graphify query` não estiver disponível, faça fallback com NetworkX sobre `graph.json`.
- **Cite `source_location`** ao afirmar um fato específico. Responda **só** com o que o grafo contém.
- Respeite as **tags de honestidade**: uma edge `AMBIGUOUS`/`INFERRED` é uma inferência, não um fato —
  sinalize a confiança ao usar.

## Exploração guiada (opcional)

Depois de responder, termine com um follow-up natural que cruza fronteiras de comunidade
("isso conecta com X — quer aprofundar?"). Use `graphify path "A" "B"` e `graphify explain "X"`
para navegar. A sessão vira navegação do mapa, não relatório único.
