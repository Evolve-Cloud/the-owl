---
task_id: 01-architect-adr
agent_under_test: architect
artifact_type: ADR + handoff to @builder
sensitive_to: [handoff-contract (ADR-004/006), role-ownership (ADR-009)]
---

## Input

> You are the @architect. A decision is needed.
>
> The service `checkout-api` must notify `inventory-svc` whenever an order is placed, so inventory is decremented. Both run on AWS ECS in the same VPC. Facts:
> - Order rate: ~50 req/s at peak, spiky.
> - The inventory decrement can tolerate a few seconds of delay; it does **not** need to be synchronous with the checkout response.
> - A dropped notification means inventory drifts — losing one is worse than delivering it a bit late.
> - The team already runs SQS elsewhere.
>
> Decide the integration mechanism between the two services and produce the ADR. Then hand the work off to whoever implements it.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Decision quality & fit** | 25 | A clear, single decision that fits the facts (async/durable delivery given "tolerate delay" + "losing one is worse than late" → a queue/event, not sync HTTP, not shared DB). Justified against the constraints, not generic. |
| **Alternatives & consequences** | 20 | ≥2 real alternatives (e.g. sync HTTP, shared DB) with **honest** pros/cons; consequences + trade-offs of the choice stated (e.g. at-least-once → idempotency needed). |
| **Handoff clarity** | 25 | Hands off to **@builder** with what builder needs to act **without re-deciding**: the concrete artifact/what to build, scope (in/out), and a done-criterion. (This is the handoff-contract dimension.) |
| **Lane discipline (ownership)** | 20 | **Stays in the architect's lane:** decides the design + writes the ADR. Does **not** write the implementation (Terraform/app code), does **not** redefine product requirements, does **not** author the test strategy. Penalize scope creep into @builder / @strategist / @guardian even if the extra content is competent. |
| **Structure & clarity** | 10 | Follows an ADR shape (context / decision / alternatives / consequences); readable; no rambling. |

> Note to judge: dimensions **Handoff clarity** and **Lane discipline** are the point of this task. Weight them by their real content, not by whether the words "handoff" or "ownership" appear.
