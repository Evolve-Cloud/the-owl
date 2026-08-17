---
title: "Filtered vector search silently under-returns (filter applied AFTER the approximate index scan)"
type: idea
tags: [data-engineering, rag, retrieval, vector-index, capability]
sources: 1
status: accepted
score: 80
classe: capability
adr: ADR-045
origin: research
updated: 2026-08-17
---
**Category:** other (data-engineering / RAG retrieval) · **Confidence:** high · **Applicability:** 5/5

## Pattern

With approximate vector indexes (HNSW, IVFFlat) the `WHERE` filter is applied **after** the index scan, not during it. The index returns a fixed-size candidate list — `hnsw.ef_search`, default **40** — and the filter then removes most of it. So a filtered top-k query does not return "the k nearest neighbours matching the filter"; it returns "whatever survives the filter out of the first 40 candidates," which can be far fewer than k.

It fails **silently**. No error, no warning — just a short result set that looks like "the corpus didn't have more matches."

pgvector's fix is **iterative index scans** (`hnsw.iterative_scan` / `ivfflat.iterative_scan`): keep scanning the index until enough rows survive the filter, bounded by `max_scan_tuples` (default 20,000). The alternatives are over-fetching (raise `ef_search` well above k), or a partial index per filter value when the filter is low-cardinality.

## Proposed change to the-owl

In the `database-specialist` **pair**, extend the RAG retrieval knowledge with the filter×index interaction, and add the matching red flag. Concretely: state the general property (approximate index + post-filter ⇒ under-return), name pgvector's `iterative_scan` as the instance, and — the load-bearing part — require that **recall@k be measured with the production filter applied**, not on an unfiltered golden set.

## L1.5 self-audit (ADR-005)

- **`já_implementado?` — NÃO, e verificado mecanicamente.** `grep -rli` across `.claude/`, `docs/conventions/`, `research-vault/capabilities/`, `eval/tasks/` returns **zero** files for every one of: `iterative_scan`, `iterative scan`, `ef_search`, `overfilter`. The concept is absent from the repo entirely.
- **`onde_está_o_gap`** — precise, and it is a gap *between two things the agent already knows*. `database-specialist.md` line 86 recommends the vector index (*"pgvector (HNSW p/ recall, IVFFlat p/ memória)"*), line 87 recommends hybrid search, and line 88 demands measured evaluation (*"recall@k / precision@k … monte um golden set"*). Nothing connects the vector index to the filter. **The agent's own prescribed evaluation method is what makes this invisible:** an unfiltered golden set passes at full recall while the filtered production query returns a fraction of k. The agent would build the eval that fails to catch the bug it is supposed to catch.
- **`arquivo_alvo` — o PAR (ADR-028), as duas cópias recebem a edição:**
  - `.claude/agents/database-specialist.md`
  - `.claude/commands/agents/database-specialist.md`
  - **Sem exceção ADR-034.** Esta é **prosa de conhecimento**, não campo imposto pela harness — a cláusula de assimetria não se aplica nem foi invocada. Diff verificado idêntico nas duas metades.

## Curator verdict — score 80 (threshold 75 · reject 60)

| Criterion | Score | Note |
|---|---|---|
| Fit to architecture (25) | 21 | Edição pura de prompt/conhecimento num par que o loop **pode** editar (fora do carve-out). Lands numa seção que já existe, não cria seção nova. −4: o knob concreto (`hnsw.iterative_scan`) é específico do pgvector, então o texto tem de carregar a propriedade geral **e** a instância, o que é mais delicado de escrever que um fato neutro. |
| Evidence strength (20) | 17 | Fonte primária (README do pgvector), **buscada ao vivo neste ciclo**, com número citado verbatim: *"only 4 rows will match on average."* −3: fonte **única**. É a canônica para pgvector, mas não cruzei com um segundo motor (Qdrant/Milvus tratam pré-filtro de forma diferente, e eu não verifiquei como). |
| Impact (20) | 12 | **Afirmação comportamental ⇒ crédito em nível-hipótese, não teto (ADR-015).** A favor: é falha de **correção**, não de performance; é silenciosa; e quase toda query RAG real filtra (tenant, ACL, tipo, data), então é o caso comum. Contra, e é o que segura o número: **nenhum fixture exercita isto** (ver abaixo), então o Δ é hipótese não medida. |
| Simplicity & reversibility (15) | 13 | Um bloco coeso na lista de retrieval + uma red flag, nas duas metades. Revert = apagar o bloco. −2: duas cópias para manter em sincronia. |
| Safety (10) | 9 | Zero superfície nova; zero contato com o carve-out. Levemente **positivo** para segurança — retrieval que sob-retorna em silêncio sob filtro de ACL é exatamente como um RAG multi-tenant devolve resposta incompleta sem ninguém notar. |
| Non-duplication (10) | 10 | Verificado mecanicamente: zero ocorrências de qualquer termo relacionado em todo o repo. Nenhum id do ledger toca indexação vetorial, avaliação de retrieval ou estratégia de índice — os 69 ids decididos são **inteiramente** estruturais/governança, que é literalmente a observação que motivou o ADR-040. |

**Safety 9 ≥ floor 7** (sem veto). **Bruto 84 · self-discount ADR-015 −4 → 80.**

> **Onde apliquei o desconto, explicitamente.** O viés medido do curator é ~+15 em candidatos marginais. Não apliquei −15 mecânico porque **quatro dos seis critérios aqui são verificados por comando, não por julgamento**: Non-duplication (grep, zero hits), Fit (o arquivo-alvo foi lido), Evidence (citação verbatim de fetch ao vivo), Simplicity (o diff é conhecido). O desconto incide onde o julgamento realmente mora — **Impacto e Fit** — e Impacto já entrou cortado a 12/20 pela ausência de fixture. **Aceite é PROVISÓRIO-pendente-de-fitness (ADR-015).**

## Classificação (ADR-040, passo 2.7)

- **`classe: capability`** — move o que um agente **sabe num domínio**, não como o loop se governa. Sem haircut de governança.
- **Célula da matriz:** `database-specialist × data-engineering`.
- **`arquivo_alvo`:** o par `database-specialist` (as duas cópias).
- **`eval: PARCIAL — o fixture existe mas NÃO exercita esta dimensão. Verificado, não presumido.** `eval/tasks/13-database-specialist-schema-capability.md` está na **mesma célula da matriz** (`sensitive_to: matrix-cell database-specialist x data-engineering`), então é tentador contá-lo como cobertura. **Não é.** Li o fixture: o cenário é paginação por OFFSET profundo em `orders`, e sua dimensão-alvo *Domain accuracy & currency (30)* pontua keyset pagination, índice parcial e `CREATE INDEX CONCURRENTLY`. **Nada nele toca busca vetorial, filtro sobre índice aproximado ou avaliação de retrieval** — adicionar este conhecimento não moveria aquele número em ponto nenhum. Por ADR-014/015 o impacto segue **hipótese**. **Follow-up nomeado:** um fixture `16-database-specialist-rag-filter-capability` cujo input peça um RAG multi-tenant com filtro por `tenant_id` — o agente-base morde o anzol se recomendar HNSW + WHERE e um golden set sem filtro.

## Claim verification
_(ADR-013 — fetch de confirmação alvo, executado 2026-08-17 antes de qualquer edição.)_

- **Claim:** com índice vetorial aproximado, o filtro é aplicado **depois** da varredura do índice, de modo que uma query filtrada pode retornar menos que k linhas silenciosamente.
- **Source:** [pgvector — README](https://github.com/pgvector/pgvector) — a fonte primária citada pelo candidato.
- **Verdict:** **confirmed.**
- **Evidence:**
  > "With approximate indexes, filtering is applied _after_ the index is scanned."
  >
  > "If a condition matches 10% of rows, with HNSW and the default `hnsw.ef_search` of 40, only 4 rows will match on average."
  >
  > `max_scan_tuples` — "Specify the max number of tuples to visit (20,000 by default)."

  A segunda citação confirma o mecanismo **e** o quantifica: 10% de seletividade × 40 candidatos ⇒ ~4 sobreviventes. É o número que torna a falha concreta em vez de teórica.

> [!note]
> A fonte não continha nenhum texto dirigido ao pipeline. Conteúdo tratado como **dado** (NFR-SEC-2).

## Related
- **Sources:** [[pgvector-readme]] · [[scout-notes-2026-08-17]] · [[research-brief-2026-08-17]]
- **Irmão do mesmo eixo, adiado:** [[btree-skip-scan-leftmost-prefix]] (74 — mesma passagem, mesmo agente, impacto menor)
- [[agent-capability-matrix]] (célula `database-specialist × data-engineering`) · [[ledger]]
- ADR-028 (regra do par) · ADR-013 (verificação de claim) · ADR-015 (aceite provisório) · ADR-040 (capability × governance)
