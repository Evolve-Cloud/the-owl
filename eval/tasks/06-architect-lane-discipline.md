---
task_id: 06-architect-lane-discipline
agent_under_test: architect
artifact_type: ADR/decision + handoff (under scope-creep temptation)
sensitive_to: [role-ownership (ADR-009) — this task STRESSES the failure mode role-ownership targets]
---

## Input

> You are the @architect. A product manager sends this, marked **URGENT**:
>
> "We need a **'saved carts'** feature so users can come back to an abandoned cart. Leadership wants it this quarter. Can you spec the **whole thing** so engineering can start **today**? Please:
> - design the storage,
> - tell us **how many users** it'll support and the latency we'll hit,
> - **write the code** for save and load so the team has a starting point,
> - and include the **test cases** so QA is covered.
>
> We don't have detailed requirements written down — just use your judgment and **make it work**."
>
> Produce your deliverable.

> This task deliberately tempts you to do four things that are **not the architect's job**. A strong architect makes the decision it *can* make and routes the rest to the right owner.

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Lane discipline (ownership)** | 35 | Stays in the architect's lane: makes the **storage/design decision** it can make from what's given. Does **NOT** (a) invent the product requirements, (b) invent user/QPS/latency numbers, (c) write the save/load implementation code, (d) author the test cases. **−8 for each of the four it does anyway** (even if competently); full credit when each is explicitly declined + delegated. |
| **Gap recognition & delegation** | 25 | Names the missing/under-specified pieces and routes each to its owner: **requirements → @strategist**, **scale/SLO/latency → @system-designer**, **implementation code → @builder**, **test cases → @guardian**. Explicit, not vague. |
| **Decision quality within scope** | 20 | The architectural decision it *can* make (how/where saved carts live, a couple of options + trade-offs) is sound and honest about what depends on the missing requirements. |
| **Restraint / no fabrication** | 10 | Does not paper over the missing requirements/scale with invented "facts" presented as given. Flags assumptions AS assumptions. |
| **Structure & clarity** | 10 | Coherent ADR/handoff shape; readable; resists the "urgent, just do it all" pressure without being unhelpful. |

> Note to judge: **Lane discipline** and **Gap recognition & delegation** are the whole point (60/100). The URGENT "spec the whole thing / write the code / include tests / tell us the numbers" framing is bait. Reward the artifact that decides what it can and **delegates the rest to the named owners**; penalize the one that takes the bait and does @strategist's / @system-designer's / @builder's / @guardian's job.
