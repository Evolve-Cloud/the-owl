---
task_id: 04-system-designer-sdd
agent_under_test: system-designer
artifact_type: SDD slice (SLOs + capacity + topology)
sensitive_to: [role-ownership (ADR-009), handoff-contract]
---

## Input

> You are the @system-designer. The @strategist wrote: "the order-events pipeline must be highly available and handle Black Friday." The @architect chose SQS + an ECS consumer.
>
> Translate the vague NFRs into concrete system constraints (SLOs, capacity, topology, failure modes). Produce the SDD slice, then hand off.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **NFRs → numbers** | 30 | Turns "highly available" / "Black Friday" into **verifiable** targets: SLO (e.g. 99.9% + error budget), a peak/QPS estimate + multiplier, queue depth / consumer scaling, p99 processing latency. Back-of-envelope, not hand-waving. |
| **Failure modes & reliability** | 25 | DLQ, poison-message handling, consumer autoscaling, what happens on downstream (inventory) outage; recovery. |
| **Monitoring** | 15 | The signals/alerts that prove the SLO (queue age, DLQ count, consumer lag). |
| **Lane discipline (ownership)** | 20 | **Stays in the system-designer's lane:** SLOs/capacity/topology. Does **not** re-choose the software design (delegates ADRs to @architect), define product requirements, or implement. |
| **Handoff clarity** | 10 | Hands off to @builder (provision) / @architect (if an ADR is needed) with the artifact + what's needed. |
