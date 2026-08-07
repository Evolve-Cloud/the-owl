---
title: "Contract-Coding: Towards Repo-Level Generation via Structured Symbolic Paradigm"
type: source
tags: [contracts, handoff, multi-agent, code-generation, paper, acl]
sources: 1
updated: 2026-08-07
---
**Source:** [Contract-Coding: Towards Repo-Level Generation via Structured Symbolic Paradigm](https://aclanthology.org/2026.findings-acl.400/) · **Type:** paper · **Stars/credibility:** peer-reviewed, ACL Findings · primary
**Author / Org:** Yi Lin, Lujin Zhao, Yijie Shi
**Published:** July 2026 · Findings of the ACL 2026, San Diego · Anthology ID `2026.findings-acl.400`, pp. 8187–8206 · **Ingested:** 2026-08-07 (cycle 8, axis *inter-agent communication & handoff contracts*)
**Verification:** anthology landing page fetched **and** the full PDF downloaded and text-extracted locally (10,153 words) — this page is grounded in the paper body, not in an abstract or a brief table. Code released at `github.com/imliinyi/Contract-Coding` (link stated by the paper; not independently checked).

> [!important]
> **Title discrepancy in the codex brief — recorded, not laundered.** `research-brief-2026-08-07.md` cites this paper as *"…via Structured **Language Contracts**"*. The real subtitle is *"…via Structured **Symbolic Paradigm**"*. The brief paraphrased the title toward its own framing. Substance checked out (below), but the citation string was wrong — a reminder that a brief's bibliographic strings are claims to verify, not facts to copy.

## Summary
Proposes **Contract-Coding**: instead of an agent chain reasoning linearly from an ambiguous user intent, ambiguous intent is first grounded into a formal **Language Contract** that acts as a Single Source of Truth. The contract makes each module's implementation *conditionally independent* of the others, which is what buys topological parallelism. A **deterministic Contract Auditor** then continuously checks that the workspace code still matches the contract's recorded signatures. Reported result: 47% functional success on the authors' Greenfield-5 benchmark with near-perfect structural integrity, versus baseline agents that suffer structural failures.

## Key points
- **The contract is the SSOT**, not the conversation. Modules are specified with strict type signatures; NFRs (security protocols, complexity constraints) ride along via a hierarchical prompt mechanism.
- **Consistency is defined formally**, not rhetorically — `V(C)` is the conjunction over tasks of `stateC(τ) ≡ stateW(τ)`, i.e. alignment between the contract's *recorded signatures* and the *actual workspace code*.
- **The Auditor is a homeostatic controller, not a logger.** It performs Task Injection when something is missing, State Synchronization by parsing agent logs, and regresses a task's status from `DONE` to `ERROR` on a logic bug, which retriggers scheduling of the owning agent for repair.
- **The amendment mechanism** (the reason this source is in the vault) — on detecting a mismatch, the Auditor rejects the invalid state transition and forces a choice: revert, or formally amend.

## Notable quotes
_Verbatim from the extracted PDF body (§5, Intervention), the passage the candidate idea rests on:_

> "If a mismatch is detected (e.g., an agent silently modifies a function signature), the Auditor enforces Normative Alignment. It rejects the invalid state transition and injects a Synchronization Task, compelling the agent to either revert the code or formally propose a Contract Amendment (Update Action) to legitimize the change."

And the definition of consistency it enforces:

> "Consistency is defined as the alignment between the Contract's recorded signatures and the actual workspace code"

## Informs (ideas / patterns)
- [[contract-amendment-before-downstream-handoff]] — the idea this source is cited for; the amendment path is real and quoted above.
- [[handoff-and-orchestration]] — a contract that survives *after* the handoff, with a defined transition for changing it, is a different concern from initial handoff completeness.
- [[context-engineering]] — the contract as SSOT is the artifact-over-transcript pattern in a formal dress.

## Gaps / open questions
- **The mechanism is a runtime, not a convention.** The Auditor is a deterministic verifier (`V(C)`) executing over a live workspace, parsing agent logs and mutating task state. the-owl is markdown-only with no runtime — so what transfers is at most the *shape* of the amendment record, never the enforcement. The paper offers no evidence for the record without the verifier.
- **Benchmark is the authors' own** (Greenfield-5) and 47% functional success is not obviously strong in absolute terms; no independent replication.
- The ablations isolate HEG and the symbolic layer — **not** the amendment mechanism. Its contribution is unmeasured even within the paper.

## Related
- [[claude-code-subagents]] · [[handoff-and-orchestration]] · [[research-brief-2026-08-07]] · [[scout-notes-2026-08-07-cycle8]]
