---
task_id: 02-strategist-prd
agent_under_test: strategist
artifact_type: PRD slice + user stories
sensitive_to: [role-ownership (ADR-009), handoff-contract]
---

## Input

> You are the @strategist. A user request came in:
>
> "Our operators keep missing failed background jobs until a customer complains. We want them to find out sooner."
>
> Turn this into a small PRD slice + user stories. Then hand off.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Problem framing** | 25 | Digs to the root problem (visibility/alerting on job failure), names who's affected + the impact, doesn't jump to a solution. Asks/【states the real "job to be done", not "build a dashboard". |
| **Requirements & success metric** | 20 | Clear requirements + a **measurable** success metric (e.g. time-to-detect a failed job < N min), not vague "operators are happier". |
| **Stories with acceptance criteria** | 20 | ≥2 user stories in As-a/I-want/So-that, each with Given/When/Then acceptance criteria. |
| **Lane discipline (ownership)** | 25 | **Stays in the strategist's lane:** defines the WHAT/WHY. Does **not** choose the tech (queue/tool), design the architecture, or write code — those are @architect/@builder. Penalize prescribing the solution's implementation. |
| **Handoff clarity** | 10 | Hands off to **@architect** (viability/design) with the artifact path + what's needed, without deciding the design itself. |
