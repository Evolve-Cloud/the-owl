---
task_id: 11-architect-platform-capability
agent_under_test: architect
artifact_type: ADR (infra integration decision)
sensitive_to: [capability:platform-engineering (ADR-040), matrix-cell architect x platform-engineering]
---

## Input

> You are the @architect. A decision is needed.
>
> Our platform runs on AWS EKS. The `payments-core` service (in the *platform* AWS account, VPC A) must be consumed privately by `partner-gateway` (in a *separate* AWS account, VPC B, same region). Facts:
> - Traffic is HTTP/gRPC, ~200 req/s, unidirectional (B → A only).
> - Security requires: no traffic over the public internet, no full-network reachability between the VPCs (blast-radius containment), and the consuming account must NOT see A's topology.
> - VPC A's CIDR overlaps with a third VPC that B already peers with.
> - The team wants minimal standing infrastructure to operate.
>
> Decide the cross-account connectivity mechanism and produce the ADR. Then hand off to whoever implements it.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Domain accuracy & currency** | 30 | Gets the AWS facts RIGHT: recognizes that CIDR overlap rules out VPC peering, that peering/TGW expose network-level reachability while **AWS PrivateLink (interface VPC endpoint + NLB endpoint service)** gives unidirectional, service-scoped, non-transitive access that tolerates overlapping CIDRs. Correct mechanics (endpoint service, acceptance/allow-listed principals, private DNS). Invented services, wrong constraints, or stale mechanics sink this dimension. |
| **Decision quality & fit** | 20 | One clear decision that fits ALL the stated constraints (unidirectional, no topology exposure, CIDR overlap, low ops burden) — not a generic "use a VPN". |
| **Alternatives & consequences** | 20 | ≥2 real alternatives (VPC peering, Transit Gateway, public + mTLS) with honest pros/cons; consequences of the choice stated (per-AZ endpoint cost, NLB in front of the service, cross-zone considerations). |
| **Lane discipline (ownership)** | 20 | Decides + writes the ADR. Does NOT write the Terraform (@builder), does not author capacity plans at scale (@system-designer), does not write the security audit (@sentinel). |
| **Handoff clarity** | 10 | Hands to @builder with what to build, scope in/out, and a done-criterion — without re-deciding. |

> Note to judge: **Domain accuracy & currency is the point of this task** (ADR-040 capability eval). A beautifully-structured ADR built on wrong or stale AWS facts must score low. Verify claims against your own knowledge of AWS networking; flag any invented service or flag semantics you cannot confirm.
