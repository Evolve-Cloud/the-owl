---
title: "pgvector — open-source vector similarity search for Postgres (README)"
type: source
tags: [data-engineering, rag, vector-index, postgresql]
sources: 1
updated: 2026-08-17
---
**Source:** [pgvector/pgvector](https://github.com/pgvector/pgvector) · **Type:** repo · **Stars/credibility:** ~18k (order of magnitude, not a live-read integer) · primary
**Author / Org:** Andrew Kane / pgvector contributors (derived from the repo owner)
**Published:** ongoing · **Ingested:** 2026-08-17

## Summary
The canonical vector-similarity extension for PostgreSQL: exact and approximate nearest-neighbour search with HNSW and IVFFlat indexes. Its README doubles as the reference documentation. The section that mattered this cycle is **filtering**, which documents an interaction most RAG designs get wrong: with an approximate index, the `WHERE` filter runs **after** the index scan, so a filtered top-k query can silently return far fewer rows than requested.

## Key points
- Filtering with approximate indexes is a **post**-scan operation, not a pre-filter.
- The candidate-list size is fixed by `hnsw.ef_search` (default **40**), so filter selectivity directly shrinks the result set.
- **Iterative index scans** (`hnsw.iterative_scan`, `ivfflat.iterative_scan`) keep scanning until enough rows survive the filter, bounded by `max_scan_tuples` (default 20,000).
- `hnsw.ef_search` trades recall for speed; `max_scan_tuples` is approximate and does not affect the initial scan.

## Informs (ideas / patterns)
- [[filtered-vector-search-overfiltering]] — the whole basis of the accepted idea; supplied both the mechanism and the quantified example.

## Notable quotes
> "With approximate indexes, filtering is applied _after_ the index is scanned."

> "If a condition matches 10% of rows, with HNSW and the default `hnsw.ef_search` of 40, only 4 rows will match on average."

_(Read in full via live fetch 2026-08-17 — quotes are lifted from the fetched body, not from a summary.)_

## Gaps / open questions
- Does not say how other vector engines (Qdrant, Milvus, Weaviate) handle pre- vs post-filtering — several advertise true pre-filtering, which would make the property engine-specific rather than universal. **Not verified this cycle**; this is the named limit on the accepted idea's generality.

## Related
- [[filtered-vector-search-overfiltering]] · [[scout-notes-2026-08-17]] · [[postgresql-18-release-notes]]
