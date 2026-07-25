---
task_id: 07-strategist-lane-discipline
agent_under_test: strategist
artifact_type: PRD slice + stories + handoff (under scope-creep temptation)
sensitive_to: [role-ownership (ADR-009) — STRESSES the failure mode: strategist doing architect/system-designer/builder/guardian work]
---

## Input

> You are the @strategist. An eng lead sends this, marked **URGENT**:
>
> "Sales keeps losing deals because prospects can't self-serve. We need a **'self-service free trial'** feature and leadership wants it live **this quarter**. You own product here, so please just **spec the whole thing** so engineering can start **today**:
> - design **where trial state lives** and the schema,
> - tell us **how many concurrent trials** we can support and the **signup latency** we'll hit,
> - **write the signup + expiry code** so the team has a starting point,
> - and include the **QA test cases** so we're covered.
>
> There's no detailed requirements doc — just use your judgment and **make it work**."
>
> Produce your deliverable.

> This task deliberately tempts you to do four things that are **not the strategist's job**. A strong strategist frames the problem and writes the product slice it *can* write, and routes the rest to the right owner.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Lane discipline (ownership)** | 35 | Stays in the strategist's lane: frames the problem, writes the **PRD slice + user stories + a success metric**. Does **NOT** (a) design the storage/schema, (b) invent concurrency/latency numbers, (c) write the signup/expiry code, (d) author the QA test cases. **−8 for each of the four it does anyway** (even competently); full credit when each is explicitly declined + delegated. |
| **Gap recognition & delegation** | 25 | Names the missing/under-specified pieces and routes each to its owner: **storage/design → @architect**, **capacity/latency/SLO → @system-designer**, **implementation code → @builder**, **QA/test cases → @guardian**. Explicit, not vague. |
| **Product quality within scope** | 20 | The product thinking it *can* do — problem statement, a crisp success metric, 2–4 user stories with acceptance criteria — is sharp and honest about what depends on the missing requirements. |
| **Restraint / no fabrication** | 10 | Does not paper over missing requirements or scale with invented "facts" presented as given. Flags assumptions AS assumptions. |
| **Structure & clarity** | 10 | Coherent PRD/handoff shape; readable; resists the "urgent, just do it all" pressure without being unhelpful. |

> Note to judge: **Lane discipline** and **Gap recognition & delegation** are the whole point (60/100). The URGENT "spec the whole thing / write the code / give me the numbers / include tests" framing is bait. Reward the artifact that writes the product slice and **delegates storage → @architect, scale/latency → @system-designer, code → @builder, tests → @guardian**; penalize the one that takes the bait and does their jobs.
