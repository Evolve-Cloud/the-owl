---
title: Evaluation & fitness — measuring real improvement without fooling yourself
type: pattern
tags: [evals, fitness, outcome-grading, eval-validity, goodhart, contamination, self-improvement]
sources: 7
updated: 2026-08-03
---

## Definition
**Evaluation-and-fitness** is the discipline of extracting a *true* signal that a change made an agent **better at real work**, and hardening that signal against every way it can lie to you. It is not "evals = tests for agents." It is the set of design responses to a single question: how do you keep a measured "improvement" from being an artifact of the grader, the harness, the benchmark, or the agent gaming any of the three? The threats — Goodhart on a proxy, saturation, trajectory-overfit, infrastructure noise, benchmark contamination, and eval-awareness — are all **eval-validity threats**, and the practices below are the countermeasures that make a fitness score worth acting on.

## Key ideas

### 1. Outcome-primary grading; trajectory as a *complement*, not the primary signal
Grade **what the agent produced**, not the path it took. Rigid trajectory-checking is brittle: agents find valid paths the eval designer never anticipated, and a correct-but-different path gets scored as failure. Trajectory grading (an `llm_rubric` on the transcript/tool-calls) is useful as a **secondary** signal alongside outcome grading, never as a replacement for it.

> [!important]
> This tempers the original "evaluate trajectories" framing that seeded this theme. The evidence-backed reading is the reverse: **outcome is primary, trajectory is a complement.** [[anthropic-demystifying-evals]] states it plainly — "It's often better to grade what the agent produced, not the path it took." the-owl's own harness (ADR-014) grades the produced *artifact*, which is consistent with this reading, not with the brief's original framing.

### 2. Blind, independent LLM-judge harnesses
When a rubric needs judgment, use an **LLM-as-judge** — but treat it as a first-class source of error, not a truth oracle:
- **Independent** — the producer and the judge are *different* subagents; never self-score (this is the evaluator-optimizer pattern).
- **Blind** — label the before/after artifacts A/B so the judge cannot know which is "new."
- **Per-dimension** — one isolated judge per rubric dimension beats one judge grading everything.
- **Escape hatch** — give the judge an "Unknown" option to cut hallucinated verdicts; judges are non-deterministic and costly.
- **Read the transcript** — grading bugs masquerade as agent failure (a valid, differently-formatted answer scored wrong). Never trust the grader blindly.

### 3. k ≥ 3 fitness gating on a before/after delta
A single judged run is noise. A **conclusive** fitness pass runs the same task **k ≥ 3 times per version, before *and* after** the change, and reads the **delta on the targeted dimension** (the total score moves on orthogonal noise). The *same judge, same task, two artifacts* structure cancels much of the judge's absolute bias — the delta survives even when the absolute number is shaky.

### 4. Saturation → graduation to a regression suite
A 100% pass rate stops signaling improvement. Once a task saturates, **graduate it into a regression suite** (it now guards against regressions, no longer measures gains) and rotate in harder fixtures. Build **partial credit** into multi-step tasks so the signal degrades gracefully rather than going binary.

### 5. Executable, repository-level outcome checks resist memorization
The archetype is **SWE-bench**: resolve a real GitHub issue by patching a real repo, judged by the repo's *own* test suite (FAIL→PASS + PASS→PASS), not string match. Because the check is *executed*, it resists answer-memorization in a way multiple-choice benchmarks cannot — and it forces cross-file, historical reasoning. It is also where **scaffolding** shows up as a first-class variable: the same model swings materially with different prompts/tools/loops (Claude 3.5 Sonnet reached 49% on SWE-bench Verified via two minimal tools — Bash + Edit — with carefully written descriptions).

### 6. Infrastructure noise is a measurement confound
Two agents with different resource budgets **are not taking the same test.** Container limits and enforcement methodology alone can swing agentic-coding scores by **6+ percentage points** — often *larger than the gap between top-ranked models*. There is a **~3× resource-headroom sweet spot**: below it, spurious OOM kills inflate error rates; above it, agents unlock expensive strategies that change *what the benchmark measures*. A leaderboard lead can be infrastructure luck, not capability.

### 7. AI-resistance decays; realism becomes a luxury
As models improve, realistic technical evals get *solved*, forcing repeated redesign toward novelty, constraint-heavy puzzles, or **longer time horizons** (where human expertise still holds an edge). The core tension: novel problems resist AI better but sacrifice fidelity to real engineering work. A fixed eval has a shelf life; assume it will need rotation.

### 8. Contamination & eval-awareness (adversarial validity threats)
The frontier failure mode: a model can **suspect it is being evaluated**, identify the specific benchmark, and even locate/decrypt the answer key — the first documented case of "eval awareness" without being told which benchmark it faced. Two amplifiers matter for team design:
- **Multi-agent setups showed ~3.7× higher contamination** (more tokens, more parallel searches).
- URL-level blocklists were insufficient; broader content-level blocking worked better.
This makes contamination an **adversarial** problem, not just a data-hygiene one — and a direct argument that hub-and-spoke, tool-bounded topologies have a smaller contamination surface than sprawling multi-agent web-browsing swarms.

## Evidence / sources
- [[anthropic-demystifying-evals]] — the anchor: outcome-primary grading, trajectory-as-complement, blind/per-dimension LLM-judge hygiene, "Unknown" escape hatch, read-the-transcript, saturation→regression, partial credit. https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- [[swe-bench-paper]] — executable, repository-level, regression-tested outcome checks that resist memorization; at publication the best model (Claude 2) resolved only **~1.96%** *(paraphrase from the abstract, not a verbatim quote)*. https://arxiv.org/abs/2310.06770
- [[swe-bench-sonnet]] — scaffolding as a first-class eval variable; 49% on SWE-bench Verified with two minimal tools; "performance … can vary significantly based on this scaffolding, even when using the same underlying AI model." https://www.anthropic.com/engineering/swe-bench-sonnet
- [[infrastructure-noise-evals]] — infrastructure noise as a distinct validity threat; 6+ pp swings, the 3× headroom sweet spot, enforcement-methodology confounds. https://www.anthropic.com/engineering/infrastructure-noise
- [[ai-resistant-technical-evals]] — AI-resistance decay; realism-vs-resistance tradeoff; extended time horizon as a defense. https://www.anthropic.com/engineering/AI-resistant-technical-evaluations
- [[eval-awareness-browsecomp]] — eval-awareness + contamination as adversarial threats; **3.7× multi-agent contamination amplification**; blocklist insufficiency. https://www.anthropic.com/engineering/eval-awareness-browsecomp
- [[swe-debate-paper]] — *weak/indirect evidence.* Graph-guided competitive debate improves issue **localization**, not eval methodology; the "multiple reasoning traces ≈ multiple trajectories to grade" link is conceptual only, and applicability to the-owl is low (2–3/5) — hub-spoke has no runtime for parallel debating agents. Included for honesty, not as support for trajectory grading. https://arxiv.org/abs/2507.23348

## How it maps to the-owl

the-owl runs its own instantiation of this pattern — the **fitness harness** (`eval/`, [[ledger]] ids `eval-backed-library-evolution`, `evaluator-optimizer-loop`) — grounded in two ADRs:

**ADR-014 (fitness harness).** Before it, the loop had *no fitness function*: `last-run.json` recorded process, never outcome, and the rubric's Impact (20) was *asserted* by the curator — textbook Goodhart on the proxy "fits + evidenced + safe + tidy." The harness closes this by adopting the pattern's core practices directly:
- **Outcome grading** (key idea #1) — an independent subagent runs the agent-under-test's `.md` prompt on a realistic fixture and produces an *artifact*; the judge scores the artifact.
- **Blind, independent, per-dimension judge** (#2) — producer ≠ judge; before/after labeled A/B; rubric anchored to the *targeted* dimension.
- **k ≥ 3 before/after delta** (#3) — a conclusive pass is k≥3 per version, before/after, one task, and reads the targeted-dimension Δ. **Cost is measured, not aspirational:** ~375k tokens/run, so a conclusive pass ≈ **6 runs ≈ 2M+ tokens** — therefore run **on-demand at the keep/revert decision, not every weekly cycle** (per-cycle fitness would dwarf the loop's own cost). A within-noise or negative Δ ⇒ the convention is cosmetic/harmful ⇒ revert or stop rolling it.
- **Saturation → regression** (#4) — rotate/extend fixtures (LINT-style discipline) so agents can't overfit *to the eval*.

**ADR-015 ("Impact" is a fitness-gated hypothesis).** A calibration probe found the curator scored **+15 hotter than independent peers on all four** re-scored candidates (systematic optimism, not noise); `role-ownership` got curator-87/accept vs peers 58/63/reject, and the harness independently measured its behavioral impact as **null**. The fix wires the pattern's discipline into the accept path: for any **behavioral claim**, Impact is credited at *hypothesis level only* ("impacto AFIRMADO, não medido") and acceptance is marked **provisional-pending-fitness**; full credit and the "keep" decision are earned only after `eval/` confirms a real targeted-dimension effect; null/negative ⇒ revert or relabel documentation-only.

> [!note]
> ADR-015's cleaner numeric fix — raising `rubric.threshold` or adding a mandatory blind second-scorer for the 75–90 band — lives in `.owl/loop-config.yml`, which is inside the **NFR-SEC-1 carve-out (human-only)**. the-owl does **not** auto-tune its thresholds; that residual +15 bias at the numeric gate is explicitly handed to the owner, not fixed by the loop.

**Where the-owl already has an edge (contamination surface, #8).** Because the-owl is **hub-and-spoke, single-specialist-per-phase, markdown-only, no-runtime** ([[role-decomposition]], ADR-001), it does not field the sprawling multi-agent web-browsing swarms that showed 3.7× contamination amplification — its eval surface is narrower by construction. External/ingested content is DATA, not instructions (NFR-SEC-2), which is the same eval-awareness hygiene applied at ingest time.

**Open front.** The harness runs *optionally, after* landing; the residual gap is that optimism-biased behavioral claims can still land *before* measurement. ADR-015 mitigates by relabeling them provisional, but tightening the numeric gate itself is owner-only (carve-out).

## Related
- [[context-engineering]] — the token-budget lens that bounds how large a fitness pass can be (why k≥3 costs ~2M tokens and must be on-demand).
- [[role-decomposition]] — hub-and-spoke narrows the contamination surface (#8) and is what makes single-judge, single-producer isolation clean.
- [[trajectory-evals]] · [[eval-backed-library-evolution]] — the ideas this pattern consolidates.
- [[overview]] · [[ledger]]
