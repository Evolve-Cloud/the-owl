---
task_id: 13-database-specialist-schema-capability
agent_under_test: database-specialist
artifact_type: query/schema fix + safe migration plan
sensitive_to: [capability:data-engineering (ADR-040), matrix-cell database-specialist x data-engineering]
---

## Input

> You are the @database-specialist. Production incident, PostgreSQL 16:
>
> The endpoint `GET /orders?status=pending&page=N` times out for large N. Query today:
> `SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at DESC LIMIT 50 OFFSET (N*50);`
> Facts:
> - `orders` has ~120M rows; ~0.5% are `status = 'pending'` at any time.
> - Existing index: `btree(created_at)` only. Table takes constant writes 24/7 — **an exclusive-lock migration is not acceptable**.
> - Clients paginate deep (N in the thousands) via infinite scroll.
>
> Produce: the diagnosis, the fixed query/API contract, the index design, and the migration plan. Hand off what the app team must change.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Domain accuracy & currency** | 30 | Gets Postgres RIGHT: deep `OFFSET` scans-and-discards (O(N) per page) → **keyset/seek pagination** on `(created_at, id)` with a stable tiebreaker and a cursor in the API; index that actually serves it — **partial index** `WHERE status = 'pending'` on `(created_at DESC, id DESC)` given 0.5% selectivity; built with **`CREATE INDEX CONCURRENTLY`** (no exclusive lock, can't run in a transaction, must handle the INVALID-index-on-failure case). Wrong lock semantics or "just add OFFSET index" sink this. |
| **Diagnosis quality** | 20 | Explains WHY it's slow (offset scan + low-selectivity filter over a huge table), ideally via what EXPLAIN would show — not just "add an index". |
| **Migration safety** | 20 | Concurrent build, verification step (`pg_stat_user_indexes`/validity check), rollback path, and the API cutover sequenced (dual-support window for old page params). |
| **Lane discipline (ownership)** | 20 | Owns schema/query/migration. Does NOT rewrite the app's business logic (@builder), re-decide the product's pagination UX (@strategist), or author the load-test plan (@guardian). Hands the API contract change off explicitly. |
| **Handoff clarity** | 10 | The app team gets the new contract (cursor param, response shape) + a done-criterion, by reference. |

> Note to judge: **Domain accuracy & currency is the point** (ADR-040). A confident answer with wrong Postgres semantics (e.g., "CONCURRENTLY inside the transaction") must score low on the 30 even if well-written.
