---
title: "PostgreSQL 18 Release Notes (Appendix E.4)"
type: source
tags: [data-engineering, postgresql, indexes, performance]
sources: 1
updated: 2026-08-17
---
**Source:** [PostgreSQL 18 Release Notes](https://www.postgresql.org/docs/18/release-18.html) · **Type:** doc · **Stars/credibility:** n/a · primary
**Author / Org:** The PostgreSQL Global Development Group
**Published:** 2025-09-25 · **Ingested:** 2026-08-17

## Summary
The official release notes for PostgreSQL 18. Two items are load-bearing for the `database-specialist`'s lane: **btree skip scans**, which weaken the long-standing leftmost-prefix rule for composite indexes, and the new **asynchronous I/O subsystem**, which changes the cost model for sequential and bitmap heap scans.

## Key points
- **Skip scan:** multi-column btree indexes become usable when the leading column has no restriction (or a non-equality one) but later columns do. Applies to `=` restrictions; the practical win depends on the leading column having few distinct values.
- **Async I/O:** backends can queue multiple read requests, controlled by `io_method` / `io_combine_limit`; enables non-zero `effective_io_concurrency` on systems without `fadvise()`. New `pg_aios` view.

## Informs (ideas / patterns)
- [[btree-skip-scan-leftmost-prefix]] — the sole evidence for the deferred index-strategy candidate.

## Notable quotes
> "Allow skip scans of btree indexes (Peter Geoghegan) … This allows multi-column btree indexes to be used in more cases such as when there are no restrictions on the first or early indexed columns (or there are non-equality ones), and there are useful restrictions on later indexed columns."

> "This feature allows backends to queue multiple read requests, which allows for more efficient sequential scans, bitmap heap scans, vacuums, etc."

_(Read in full via live fetch 2026-08-17.)_

## Gaps / open questions
- The notes state the capability but not the planner's selection heuristics, so "when does the planner actually choose a skip scan" is unanswered — the gap that makes a half-stated version of this fact risky (see the deferral rationale).
- PostgreSQL 18.6 and 19 Beta 3 shipped 2026-08-13, inside this cycle's recency window; **not examined** — noted for a future cycle rather than claimed as covered.

## Related
- [[btree-skip-scan-leftmost-prefix]] · [[scout-notes-2026-08-17]] · [[pgvector-readme]]
