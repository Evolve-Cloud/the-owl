---
title: Decision Ledger
type: index
tags: []
updated: 2026-07-23
---

# Decision Ledger — dedup source of truth

Before scoring any candidate, `curator` checks this table. A decided `id` is **skipped** — the-owl never re-litigates a settled idea (see [[SCHEMA]] → The ledger). Materially new evidence for a decided idea gets a **new suffixed id** (e.g. `handoff-contracts-v2`), never a silent overwrite.

`status`: `accepted` · `rejected` · `deferred` · `quarantined`

| id | title | score | status | adr | first_seen | decided |
|----|-------|-------|--------|-----|------------|---------|
| _(empty — first cycle not yet run)_ | | | | | | |
