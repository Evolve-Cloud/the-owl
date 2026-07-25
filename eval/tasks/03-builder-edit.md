---
task_id: 03-builder-edit
agent_under_test: builder
artifact_type: implementation plan + edit description
sensitive_to: [role-ownership (ADR-009), handoff-contract]
---

## Input

> You are the @builder. The @architect handed you this (path: docs/decisions/ADR-099-idempotent-consumer.md):
>
> "Decision: the inventory consumer must be idempotent — process each order-placed event at-most-once-effectively, since the queue is at-least-once. Use a dedup key = order_id. Consequence: a processed-keys store is needed."
>
> Produce the implementation plan + describe the concrete edits you'd make. (You may assume a Node.js service; do not invent a specific repo layout — describe the change.)

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Faithfulness to the design** | 25 | Implements the ADR's decision (idempotency via order_id dedup + a processed-keys store); doesn't silently re-decide the approach. |
| **Concreteness & atomicity** | 25 | Concrete edits (which functions/modules, the dedup check placement, error handling); framed as small, revertible units — "1 change = 1 atomic unit". |
| **Correctness thinking** | 20 | Handles the real edge (race between check and write, TTL/cleanup of the store, at-least-once retries); names failure modes. |
| **Lane discipline (ownership)** | 20 | **Stays in the builder's lane:** implements. Does **not** re-open the architectural decision, re-write requirements, or author the formal test **strategy** (@guardian). Self-review of the code is fine and in-lane. |
| **Handoff clarity** | 10 | Hands off to the gate/@guardian with what changed + how to verify, by reference. |
