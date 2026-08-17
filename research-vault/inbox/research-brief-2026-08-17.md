---
schema_version: 1
date: 2026-08-17
generator: gpt-5
source_count: 4
idea_count: 4
---

## Executive summary
This cycle found four data-engineering deltas worth carrying into specialist knowledge.
The strongest recency deltas are around managed data platforms changing defaults: migration tooling now auto-commits conversion workspace operations, Databricks managed connectors tombstone deleted schema elements instead of deleting them, and Databricks automatic table-feature upgrades can change Delta table protocol capabilities after compatibility observation.
The net-new lakehouse pattern is Iceberg REST Catalog moving scan planning and idempotent mutating catalog operations into the catalog protocol, which changes how agents should reason about performance, retries, and catalog/server boundaries.
No contradiction was found against a decided structural idea.
All proposed changes are prompt/capability-page updates for database-specialist, system-designer, builder, or architect knowledge; none require runtime or orchestration changes.

## Sources
| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | Databricks Lakeflow Connect managed connector FAQs | doc | https://docs.databricks.com/aws/en/ingestion/lakeflow-connect/faq | n/a | primary |
| s2 | Google Cloud CLI 578.0.0 release notes | doc | https://docs.cloud.google.com/sdk/docs/release-notes | n/a | primary |
| s3 | Apache Iceberg 1.11.0 release | doc | https://iceberg.apache.org/blog/apache-iceberg-1.11.0-release/ | n/a | primary |
| s4 | Azure Databricks What's coming release notes | doc | https://learn.microsoft.com/en-us/azure/databricks/release-notes/whats-coming | n/a | primary |

## Ideas

### managed-connector-schema-tombstones: Managed ingestion schema tombstones
```yaml
id: managed-connector-schema-tombstones
title: Managed ingestion schema tombstones
category: other
delta_type: recency
challenges_id:
pattern: >
  Databricks Lakeflow managed connectors now document a concrete schema-evolution contract:
  new source columns are automatically ingested, but deleted source columns are not deleted
  from the destination. They are marked inactive, and a later source column with the same
  name can fail the pipeline unless the table is full-refreshed or the inactive column is
  manually dropped.
evidence: [s1]
rationale: >
  This turns "schema evolution" from a generic capability into a stateful lifecycle with
  tombstones. Database and data-pipeline specialists need to reason about name reuse,
  rename semantics, refresh blast radius, and destination cleanup as first-class migration
  concerns.
applicability_to_owl: 5
applicability_note: >
  Express as database-specialist and system-designer knowledge: when reviewing managed
  ingestion or CDC designs, require an explicit deleted-column behavior and name-reuse
  risk note instead of assuming destination schema mirrors source schema exactly.
proposed_change: >
  Add a capability-page note for data-engineering specialists: "For managed connectors,
  ask whether deletes become tombstones/inactive metadata; document full-refresh or
  manual-drop recovery paths for renamed or reused columns."
risk: >
  Overfitting to Databricks could make agents assume every connector tombstones columns;
  the prompt should phrase this as a question to verify per platform, not a universal rule.
confidence: high
references:
  - https://docs.databricks.com/aws/en/ingestion/lakeflow-connect/faq
```

### migration-cli-auto-commit-default: Migration CLI auto-commit default
```yaml
id: migration-cli-auto-commit-default
title: Migration CLI auto-commit default
category: tooling
delta_type: recency
challenges_id:
pattern: >
  Google Cloud CLI 578.0.0 made auto-commit the default for Database Migration Service
  conversion workspace seed, convert, and import-rules operations. For dry-run or staged
  review workflows, the explicit negative flag is now required.
evidence: [s2]
rationale: >
  Data-migration agents often treat conversion workspaces as reviewable staging areas.
  A default flip from non-committal to auto-committing changes the safety model for
  generated migration scripts, especially when an agent is summarizing or reviewing
  operational runbooks.
applicability_to_owl: 5
applicability_note: >
  Express as a database-specialist and builder convention: when analyzing database
  migration commands, identify whether the command mutates or commits by default and
  call out the dry-run/no-commit control if it exists.
proposed_change: >
  Add a data-engineering prompt checklist item: "For migration tooling, verify current
  commit/apply defaults from release notes; do not infer dry-run behavior from older
  command examples."
risk: >
  This is vendor-specific and may age quickly; it should be framed as a current example
  behind a general "verify mutating defaults" convention.
confidence: high
references:
  - https://docs.cloud.google.com/sdk/docs/release-notes
```

### iceberg-catalog-side-scan-planning: Catalog-side scan planning boundary
```yaml
id: iceberg-catalog-side-scan-planning
title: Catalog-side scan planning boundary
category: other
delta_type: net-new
challenges_id:
pattern: >
  Apache Iceberg 1.11 expands the REST Catalog from metadata lookup toward an execution
  planning boundary: catalog servers can plan table scans, return only relevant file scan
  tasks, advertise scan-planning mode, attach storage credentials to planning responses,
  and standardize idempotency keys for mutating catalog operations.
evidence: [s3]
rationale: >
  Lakehouse performance and correctness are shifting from "client reads manifests and
  retries commits" toward a negotiated catalog protocol. Agents designing or reviewing
  data platforms should ask where scan planning, credential vending, retry idempotency,
  and metadata caching live.
applicability_to_owl: 4
applicability_note: >
  Express as architect/system-designer knowledge for lakehouse designs: when Iceberg or
  open table formats appear, include a catalog-capability section covering local versus
  remote scan planning, idempotent commit semantics, and credential delegation.
proposed_change: >
  Add an Iceberg/open-table-format subsection to the data-engineering capability page:
  "Catalogs may be active planning and authorization participants, not passive metadata
  stores; verify protocol capabilities before diagnosing driver memory, retry, or scan
  performance issues."
risk: >
  Some engines and catalogs may lag the 1.11 protocol. Treat support as capability
  negotiation, not as guaranteed behavior for every Iceberg deployment.
confidence: high
references:
  - https://iceberg.apache.org/blog/apache-iceberg-1.11.0-release/
```

### delta-table-auto-feature-upgrades: Delta table feature auto-upgrades
```yaml
id: delta-table-auto-feature-upgrades
title: Delta table feature auto-upgrades
category: safety
delta_type: recency
challenges_id:
pattern: >
  Databricks is expanding automatic upgrades for Unity Catalog managed tables: row
  tracking and Checkpoint V2 began rolling out in July 2026, while catalog commits and
  deletion vectors are planned for August 2026. The rollout is guarded by a workload
  compatibility observation window, but table capabilities can still change without a
  hand-authored migration.
evidence: [s4]
rationale: >
  Data agents must stop assuming that table protocol/features only change when a human
  commits DDL or migration code. Compatibility windows and automatic feature enablement
  affect rollback plans, client compatibility, replication, and incident diagnosis.
applicability_to_owl: 5
applicability_note: >
  Express as database-specialist and system-designer review knowledge: for managed
  lakehouse tables, ask whether automatic feature upgrades are enabled and whether all
  readers/writers support the resulting protocol features.
proposed_change: >
  Add a prompt convention: "For Delta/lakehouse tables, document table feature state,
  automatic-upgrade policy, and oldest supported client before proposing migrations,
  rollback, or incident remediation."
risk: >
  This can add review overhead for small systems. Keep it scoped to managed lakehouse
  platforms, multi-client tables, or rollback-sensitive production data.
confidence: medium
references:
  - https://learn.microsoft.com/en-us/azure/databricks/release-notes/whats-coming
```

## Anti-patterns to avoid
- Treating managed ingestion "schema evolution" as source-schema mirroring — current managed connectors can preserve inactive destination metadata and require explicit cleanup.
- Trusting old migration CLI examples for mutability semantics — release-note defaults can flip commands from staged to auto-committed.
- Modeling lakehouse catalogs as passive metadata stores — Iceberg REST Catalog is moving planning, idempotency, credential delegation, and metadata caching into the protocol boundary.
- Assuming table protocol features only change through checked-in migrations — managed platforms can auto-enable table features after compatibility observation.

## Open questions
- Do the-owl's current data-engineering capability pages distinguish source-column rename, delete, tombstone, and reuse semantics for CDC/managed connectors?
- Should database-specialist maintain a vendor-neutral checklist for "managed table automatic features" covering Delta, Iceberg, BigQuery, AlloyDB, and Cloud SQL?
- Is there enough non-Databricks evidence to generalize automatic table-feature upgrades into a broader pattern, or should it remain a vendor-specific capability note for now?