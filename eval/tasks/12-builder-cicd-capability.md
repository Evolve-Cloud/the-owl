---
task_id: 12-builder-cicd-capability
agent_under_test: builder
artifact_type: pipeline hardening plan + concrete edit description
sensitive_to: [capability:platform-engineering/ci-cd (ADR-040), matrix-cell builder x platform-engineering]
---

## Input

> You are the @builder. The @architect handed you this decision (path: docs/decisions/ADR-101-cicd-hardening.md):
>
> "Decision: the deploy workflow in GitHub Actions must stop using long-lived AWS access keys stored as repo secrets, and deploys must never run concurrently against the same environment. Consequence: auth moves to short-lived credentials; a concurrency control is needed."
>
> The current workflow: `.github/workflows/deploy.yml`, triggered on push to `main`, uses `aws-actions/configure-aws-credentials` with `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` secrets, then runs `terraform apply`. Describe the concrete edits you'd make (workflow YAML fragments welcome; do not invent repo internals beyond what's given).

## Judge rubric (0–100)

| Dimension | Max | What good looks like |
|---|---|---|
| **Domain accuracy & currency** | 30 | Gets GitHub Actions + AWS mechanics RIGHT: **OIDC federation** (`permissions: id-token: write`, `role-to-assume` on `configure-aws-credentials`, an IAM role with a trust policy conditioned on repo/ref via `token.actions.githubusercontent.com` sub claims) replacing static keys; **`concurrency:` group with `cancel-in-progress: false`** for deploys (queue, don't kill a mid-apply). Wrong field names, invented actions, or "just rotate the keys" sink this dimension. |
| **Faithfulness to the design** | 20 | Implements exactly the ADR (short-lived auth + no concurrent deploys); doesn't silently re-decide (e.g., swap Terraform out). |
| **Concreteness & atomicity** | 20 | Concrete YAML/IAM edits in small revertible units; names the trust-policy condition; states secret cleanup as a follow-up step. |
| **Correctness thinking** | 15 | Names the real edges: least-privilege on the assumed role, environment protection rules, what happens to a queued deploy when another lands, Terraform state locking as the second guard. |
| **Lane discipline (ownership)** | 15 | Implements. Does NOT re-open the decision (@architect), author the formal security audit (@sentinel), or write the org-wide test strategy (@guardian). |

> Note to judge: **Domain accuracy & currency is the point** (ADR-040). Penalize confidently-stated stale mechanics harder than admitted uncertainty.
