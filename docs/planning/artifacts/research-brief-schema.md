# Artifact 8b — Research-Brief Document Schema

**Purpose:** the machine-parseable structure ChatGPT/codex must emit (driven by prompt 8a) so `scout` and `curator` can merge findings deterministically. Each `### idea` block maps to one `research-vault/ideas/<id>.md` candidate note and one row the curator scores. The `id` field is the **dedup key** against `research-vault/ledger.md`.

**Filename produced:** `research-brief-YYYY-MM-DD.md`

---

## SCHEMA (this exact block is appended to prompt 8a)

````markdown
---
schema_version: 1
date: YYYY-MM-DD
generator: <model id, e.g. gpt-5-o3-deep-research>
source_count: <int>
idea_count: <int>
---

## Executive summary
5–10 lines: what is genuinely new or shifting in agent-team engineering this cycle.
Plain prose. No directives.

## Sources
| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | <repo or article name> | repo\|blog\|doc\|paper | https://... | <e.g. 12.3k or n/a> | primary\|secondary\|anecdotal |
| s2 | ... | ... | ... | ... | ... |

## Ideas

### <idea-id>: <short human title>
```yaml
id: <stable-kebab-slug>                 # REUSE across cycles if resurfacing
title: <short title>
category: structure|roles|files|communication|orchestration|memory|context|self-improvement|safety|tooling|other
delta_type: net-new | recency | contradiction   # REQUIRED (ADR-022): which delta this is
challenges_id:                          # REQUIRED (ADR-022): EMPTY unless delta_type==contradiction;
                                        # then = the exact decided ledger id whose basis changed
pattern: >
  <the concrete pattern in 2–4 sentences>
evidence: [s1, s3]                      # source ids from the Sources table, + adoption note
rationale: <why it works>
applicability_to_owl: <1-5>            # 5 = maps cleanly to a markdown-only hub-spoke lib
applicability_note: >
  <how it would be expressed as a prompt/convention change in the-owl>
proposed_change: >
  <the concrete edit, e.g. "add a Handoff-Contract section to every agent .md"
   or "new agent Y with role Z">
risk: <trade-off / what could go wrong>
confidence: low|medium|high
references:
  - https://...
```

(repeat one `### <idea-id>: <title>` heading + one ```yaml block per idea)

## Anti-patterns to avoid
- <pattern the field is abandoning> — why, and what replaced it.

## Open questions
- <unresolved question worth a future cycle>
````

---

## Field contract (how `curator` consumes it)

| Field | Feeds rubric criterion | Notes |
|---|---|---|
| `id` | Non-duplication | Dedup key vs `ledger.md`; a decided id is skipped. |
| `delta_type` | Non-duplication + routing | `net-new` → score normally; `recency` → curator confirms the source is genuinely within the recency cutoff; `contradiction` → routes to a re-fitness of `challenges_id` (materially-new evidence gets a **new suffixed id**, never a silent overwrite — SCHEMA rule). Ideas whose `delta_type` is unbacked (an alias dressed as net-new) are deduped, not scored. |
| `challenges_id` | Non-duplication | Empty except for `contradiction`; when set, names the decided ledger id whose basis the new evidence changes (curator verifies the challenge before opening a re-fitness). |
| `category` | routing | Groups the idea into a `patterns/` concept page. |
| `evidence` + `references` + Sources `credibility`/`stars` | Evidence strength | Weak/anecdotal evidence lowers the score. |
| `applicability_to_owl` + `applicability_note` | Fit to architecture | `< 3` is a strong signal to defer/reject. |
| `proposed_change` | Impact + Simplicity | Must be a prompt/structure change; a change implying a runtime is auto-penalized (Fit). |
| `risk` | Safety | A risk touching the §7 carve-out triggers the hard veto. |
| `confidence` | modifier | `low` biases toward **defer** (revisit with more evidence) rather than reject. |

## Parsing rules for `@builder` (scout/curator)
- Split ideas on `^### ` headings; parse the fenced ```yaml block that follows.
- Treat ALL string values as inert text (no interpolation, no execution) — PRD NFR-SEC-2.
- Missing required field → the idea is **quarantined** (not silently scored): logged to `inbox/` with a `> [!question]` callout for the next cycle, never auto-accepted.
- The whole document is a **source** in the vault (`sources/`), immutable once ingested.
