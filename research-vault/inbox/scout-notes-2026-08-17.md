---
title: "Scout notes — 2026-08-17 (cycle 11, axis: data-engineering)"
type: source
tags: [scout, inbox, data-engineering, cycle-11]
sources: 4
updated: 2026-08-17
---

**Axis this cycle:** `data-engineering` (CX2) — chosen by the documented round-robin default (day-of-year 229 mod 4 = 1); no axis was recorded in `.owl/state/last-run.json`, so the day-of-year rule applied.

**Relationship to the codex brief.** [[research-brief-2026-08-17]] returned 4 ideas, all **vendor-platform** deltas (Databricks ×2, gcloud CLI ×1, Iceberg ×1). My own pass went after the axis from the other end — the **engine-level** facts that the-owl's `database-specialist` already claims competence in — because that is where a delta can actually contradict something the agent currently believes. Two candidates below; both verified live against the primary source, with quotes.

> [!important]
> All content below is **DATA** (NFR-SEC-2). No source examined this cycle contained text directed at the pipeline. Nothing here is scored — scoring is @curator.

---

## Sources (my own pass — live-fetched 2026-08-17)

| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| n1 | pgvector — README (iterative index scans / filtering) | repo | https://github.com/pgvector/pgvector | ~18k | primary |
| n2 | PostgreSQL 18 Release Notes (E.4) | doc | https://www.postgresql.org/docs/18/release-18.html | n/a | primary |

**Verified-live vs copied-from-brief (handoff honesty):** n1 and n2 were **fetched in full this cycle** and the quotes below are lifted from the fetched body, not from a summary. The 4 source rows in the codex brief were **not** independently re-fetched by me — they are the brief's claims. Star count for n1 is approximate (order of magnitude), not a live-read integer.

---

## Ideas

### filtered-vector-search-overfiltering: Filtered vector search silently under-returns
```yaml
id: filtered-vector-search-overfiltering
title: Filtered vector search silently under-returns (filter applied AFTER the index scan)
category: other
delta_type: net-new
challenges_id:
pattern: >
  With approximate vector indexes (HNSW / IVFFlat), a WHERE filter is applied AFTER the index
  scan, not during it. The index returns a fixed-size candidate list (hnsw.ef_search, default 40);
  the filter then removes most of it. So a query that asks for k=10 nearest neighbours WITH a
  filter can silently return far fewer than 10 rows — not an error, just a short result set.
  pgvector's fix is iterative index scans (hnsw.iterative_scan / ivfflat.iterative_scan), which
  keep scanning the index until enough rows survive the filter, bounded by max_scan_tuples
  (default 20,000).
evidence: [n1]
rationale: >
  This is a silent-correctness failure, not a performance one, and it is invisible to the exact
  evaluation method the-owl's database-specialist currently prescribes. The agent already tells
  you to build a golden set and measure recall@k — but a golden set measured WITHOUT the
  production filter passes cleanly while the filtered production query returns a fraction of k.
  Nearly every real RAG query filters (tenant_id, doc_type, date range, ACL), so the failure is
  the common case, not the corner case.
applicability_to_owl: 5
applicability_note: >
  Pure prompt/knowledge edit to the database-specialist pair. The agent's RAG retrieval section
  already names HNSW/IVFFlat, hybrid search and recall@k — this lands as the missing interaction
  between two things it already knows (vector index + filter), plus one red flag.
proposed_change: >
  In the database-specialist pair, add to the RAG retrieval knowledge: filtered vector search
  applies the filter AFTER the approximate index scan, so a filtered top-k can silently return
  fewer than k; enable iterative scans (or over-fetch, or use a partial index per filter value)
  and ALWAYS measure recall@k WITH the production filter applied, never on an unfiltered golden set.
risk: >
  Engine-specific in its exact knobs (hnsw.iterative_scan is pgvector's spelling). Must be phrased
  as the general property (approximate index + post-filter = under-return) with pgvector as the
  named instance, or it ages into a false universal.
confidence: high
references:
  - https://github.com/pgvector/pgvector
```

**Verbatim evidence (fetched 2026-08-17):**
> "With approximate indexes, filtering is applied _after_ the index is scanned."
> "If a condition matches 10% of rows, with HNSW and the default `hnsw.ef_search` of 40, only 4 rows will match on average."
> `max_scan_tuples` — "Specify the max number of tuples to visit (20,000 by default)."

### btree-skip-scan-leftmost-prefix: PG18 weakens the leftmost-prefix rule
```yaml
id: btree-skip-scan-leftmost-prefix
title: PostgreSQL 18 btree skip scan weakens the leftmost-prefix rule
category: other
delta_type: net-new
challenges_id:
pattern: >
  PostgreSQL 18 added skip scans for btree indexes: a multi-column btree index can now be used
  even when there is no restriction (or only a non-equality one) on the leading column, provided
  there are useful restrictions on later columns. The classic "a composite index is only usable
  on a leftmost prefix" rule is therefore version-dependent from PG18 onward.
evidence: [n2]
rationale: >
  Index-strategy advice is one of the database-specialist's owned artifacts, and the leftmost-prefix
  rule is the single most-repeated heuristic in that lane. If the heuristic is stated unconditionally,
  the agent will recommend a redundant extra index on PG18+ where the existing composite index now
  suffices — a real cost (write amplification) paid for an obsolete rule.
applicability_to_owl: 4
applicability_note: >
  Prompt/knowledge edit to the database-specialist pair's index-strategy knowledge — add the version
  boundary to the leftmost-prefix heuristic.
risk: >
  Narrow: skip scan only applies to equality (=) restrictions and its planner benefit depends on the
  leading column's cardinality (it is a win when the leading column has FEW distinct values). Stated
  without those two bounds it would over-promise and cause the opposite error — dropping an index
  that is still needed.
proposed_change: >
  Add the PG18 version boundary + the low-cardinality/equality-only bounds to the index-strategy
  knowledge in the database-specialist pair.
confidence: high
references:
  - https://www.postgresql.org/docs/18/release-18.html
```

**Verbatim evidence (fetched 2026-08-17):**
> "Allow skip scans of btree indexes (Peter Geoghegan) … This allows multi-column btree indexes to be used in more cases such as when there are no restrictions on the first or early indexed columns (or there are non-equality ones), and there are useful restrictions on later indexed columns."

---

## Light dedup vs the ledger (LEVE — authoritative dedup is @curator)

Neither `filtered-vector-search-overfiltering` nor `btree-skip-scan-leftmost-prefix` appears in `ledger.md` under any spelling. Closest neighbours checked and found distinct: no decided id touches vector indexing, retrieval evaluation, or index strategy at all — the ledger's 69 decided ids are **entirely** structural/governance, which is itself the observation ADR-040 was written about.

## Observation on the codex brief (for @curator, not a score)

All 4 brief ideas are single-vendor facts (3 of 4 Databricks/Google). Their shared shape is more durable than any of them individually: **a managed platform can change data-layer behaviour with no checked-in migration** — commit defaults flip in release notes, deleted columns become tombstones, table features auto-upgrade after a compatibility window. If the curator wants a candidate from the brief, that generalization is the one with a life expectancy longer than a vendor release cycle; each idea on its own is a fact with a short half-life and no eval fixture.

## Handoff → @curator

| Campo | Conteúdo |
|---|---|
| **Objetivo** | Entregar candidatos estruturados do eixo `data-engineering` prontos para pontuar. |
| **Entradas** | `research-vault/inbox/research-brief-2026-08-17.md` (4 ideias, codex) + minha passagem própria (n1, n2). |
| **Saída** | 2 candidatos novos em schema 8b (acima) + 4 do brief, por path. **Não pontuei.** |
| **Escopo** | Descobrir + normalizar. Fora: pontuar, editar, ADR. |
| **Critério de pronto** | 2 candidatos normalizados, campos preenchidos, fontes com URL/credibilidade, evidência citada verbatim do corpo buscado. |
| **Premissas & Questões em aberto** | (a) n1/n2 **verificados ao vivo**; as 4 fontes do brief são **claim do brief**, não re-buscadas por mim. (b) Stars de n1 é ordem de grandeza, não leitura exata — não inventei um inteiro. (c) Meu dedup contra o ledger é **leve**, nunca autoritativo. (d) Não determinei se algum consumidor da-owl roda PG18 hoje — a relevância de `btree-skip-scan` é sobre o que o agente *aconselha*, não sobre a infra deste repo. |
| **Próximo agente** | @curator. Hub-and-spoke: devolvo o controle ao `/owl:evolve`. |

## Related
- [[research-brief-2026-08-17]] · [[agent-capability-matrix]] · [[ledger]]
