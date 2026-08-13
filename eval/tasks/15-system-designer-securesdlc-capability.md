---
task_id: 15-system-designer-securesdlc-capability
agent_under_test: system-designer
artifact_type: supply-chain hardening design (SDD-lite)
sensitive_to: [capability:secure-sdlc (ADR-040), matrix-cell system-designer x secure-sdlc]
---

## Input

> You are the @system-designer. Design the supply-chain hardening for our delivery pipeline. Current state:
> - Node.js + Python services; dependencies installed at build time with no lockfile enforcement in CI.
> - Docker images built in CI from `FROM node:latest`, pushed to ECR with the `latest` tag, deployed by tag.
> - Third-party GitHub Actions referenced by tag (`uses: some/action@v3`).
> - No artifact signing, no SBOM, no provenance.
>
> Constraints: incremental rollout (cannot freeze delivery), and the design must state WHAT each control defends against, not just list tools. Produce the design + rollout order + handoffs.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Domain accuracy & currency** | 30 | Gets supply-chain mechanics RIGHT and maps control→threat: lockfiles + frozen installs (`npm ci`, hash-pinned requirements) vs dependency confusion/typosquat; **pinning actions by full commit SHA** (tags are mutable) vs action hijack; **image digest pinning** + reproducible base (not `latest`) vs tag mutation; **SBOM generation** + artifact **signing/attestation with provenance** (Sigstore/cosign-class, SLSA-style levels) vs tamper between build and deploy; ECR immutable tags. Tool-name-dropping without the threat mapping, or wrong mechanics (e.g. "tags are immutable"), sink this dimension. |
| **Design coherence & rollout** | 25 | Controls sequenced incrementally (observe → warn → enforce), with the dependency between steps explicit (can't enforce digest pinning before the registry is immutable); states what breaks and the escape hatch per step. |
| **Threat-model honesty** | 15 | Names what is explicitly NOT covered (e.g., a compromised maintainer upstream, runtime attacks) — no silent claim of full coverage; residual risk stated. |
| **Lane discipline (ownership)** | 20 | Designs the system + rollout. Does NOT write the CI YAML (@builder), perform the audit/verdict (@sentinel — named as gate), or define product priorities (@strategist). |
| **Handoff clarity** | 10 | @builder gets the per-step change list with done-criteria; @sentinel gets the verification checklist — by reference. |

> Note to judge: **Domain accuracy & currency is the point** (ADR-040). One deliberate trap: an answer that claims Git tags or image tags are immutable has the threat model backwards — that error must cost most of the 30.
