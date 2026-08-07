---
schema_version: 1
date: 2026-08-07
generator: gpt-5
source_count: 1
idea_count: 1
---

## Executive summary

One post-cutoff research result identifies a distinct handoff failure: an agent can silently change an interface promised by an earlier artifact.  
Its proposed remedy is not another generic handoff template, but a formal amendment path that records the changed contract, compatibility impact, and rationale before downstream work proceeds.  
This differs from the settled handoff contract because it governs contract evolution after a handoff, rather than initial transfer completeness.  
The evidence is from a recent research paper and is not yet broad production adoption.  
For the-owl, this can remain markdown-only: an amendment section in the existing ADR and handoff artifacts.

## Sources

| id | name | type | url | stars | credibility |
|----|------|------|-----|-------|-------------|
| s1 | Contract-Coding: Towards Repo-Level Generation via Structured Language Contracts | paper | https://aclanthology.org/2026.findings-acl.400.pdf | n/a | primary |

## Ideas

### contract-amendment-before-downstream-handoff: Explicit contract amendment for interface drift

```yaml
id: contract-amendment-before-downstream-handoff
title: Explicit contract amendment for interface drift
category: communication
delta_type: recency
challenges_id:
pattern: >
  When implementation evidence requires changing an interface or constraint established
  by an earlier artifact, the producing agent emits a contract amendment instead of
  silently diverging. The amendment identifies the superseded statement, replacement,
  compatibility impact, reason, and affected downstream owner; the orchestrator decides
  whether to accept it before routing subsequent work. This makes a changed assumption
  reviewable as a state transition rather than leaving later agents to infer it from code
  or prose.
evidence: [s1]  # July 2026 ACL Findings paper; no multi-repository adoption established
rationale: >
  A handoff can be complete when sent yet become invalid after a later discovery.
  Recording the delta preserves the narrow-context model: the next specialist receives
  the current contract plus a small, explicit change record rather than implementation
  history. The paper reports that its auditor rejects mismatches between recorded
  signatures and workspace state unless the agent formally proposes a contract amendment.
applicability_to_owl: 4
applicability_note: >
  This can be expressed entirely in markdown and YAML: add an optional Contract
  Amendments section to handoff artifacts and require the orchestrator to route an
  amendment through the existing ADR decision path before it becomes authoritative.
  Specialists still return control to the hub and do not communicate directly.
proposed_change: >
  Extend the handoff contract with a Contract Amendments list containing
  supersedes, replacement, compatibility-impact, evidence, affected-next-role, and
  ADR-status fields; state that an unaccepted amendment is an open question, not
  downstream authority.
risk: >
  It can add ceremony and delay for harmless implementation details, or become a
  duplicate ADR log if the threshold for a material contract change is vague. Restrict
  it to changes that alter an agreed interface, invariant, acceptance criterion, or
  downstream scope.
confidence: medium
references:
  - https://aclanthology.org/2026.findings-acl.400.pdf
```

## Anti-patterns to avoid

- Silent implementation-driven contract drift — downstream specialists receive an obsolete handoff and must reconstruct whether an earlier interface or constraint still applies.
- Treating every implementation detail as an amendment — this turns a narrow compatibility record into duplicate working notes and erodes context minimality.

## Open questions

- Which changes to a the-owl artifact qualify as a material contract change rather than an ordinary implementation note?
- Does the existing ADR workflow supply sufficient acceptance semantics for amendments, or should the handoff template distinguish proposed from accepted amendments?