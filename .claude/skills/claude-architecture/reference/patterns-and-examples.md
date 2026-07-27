# claude-architecture — Patterns & Worked Examples (production LLM systems)

Deep reference for `SKILL.md`. Load on demand. Principles + worked Q&A (CCA-style) for building reliable Claude systems in production. Source: production-architecture study material provided by the owner; aligned with Anthropic guidance except **Prompt Crystallization** (§11), which is explicitly the author's methodology, *not* an Anthropic-recommended practice.

---

## 1. Error at scale, non-determinism, and failure modes

- **Accuracy is an absolute-volume decision, not a percentage.** 97% accuracy = 3,000 misroutes per 100,000. "3% wrong" means something entirely different at 100 req/day vs 1M req/day. Error handling is sized to **absolute error volume**, never to the headline percentage.
- **Non-determinism is a property, not a bug.** Even at temperature 0, identical inputs can yield "Acme Corp" / "ACME Corporation" / "Acme". → **Exact-string unit tests don't work for LLM output.** Test with eval frameworks that score across dimensions (correctness, format, completeness, relevance) and tolerate variation.
- **Attention dilution → silent omission.** Ask for 8 entity types in one pass over a 50-page contract and the last 4 may be *silently missing* (omission, not wrong answers). Dangerous because validation catches wrong values but **cannot catch a field that isn't there**. Jaroslawicz et al.: accuracy 94–100% at 10 instructions → 6.7–68.9% at 500, omission dominant. Fix: split into focused passes; validate for presence.
- **Model tier is a cost decision, not a correctness mechanism.** A 12% inconsistency rate rarely gets fixed by Sonnet→Opus. If the root cause is architectural (ambiguous inputs, conflicting instructions, attention dilution), the bigger model shows the *same* behavior. Investigate architecture first; upgrade only when the task genuinely exceeds the tier's capability.
- **Self-review bias.** A model reviewing its own output *in the same context* defends its prior reasoning and approves flawed work. **Structured completeness checks** (objective checklist — "are all 9 clauses present?") survive self-review; **correctness/judgment review does not**. Route correctness review to a **separate reviewer instance** given the artifact + criteria but *not* the drafter's chain of thought.

---

## 2. Prompting for reliability

- **Lost in the middle (Liu et al., arXiv:2307.03172).** U-shaped attention: strong at the start and end, weak in the middle (>30% accuracy drop for mid-context facts). Order long prompts: **system instructions at the TOP → reference docs in the MIDDLE (clear section headers) → user question at the BOTTOM.** Don't bury instructions behind 12k tokens of documents.
- **XML-style section tags cut cross-contamination.** Wrap logical sections `<role>` `<policies>` `<instructions>` `<constraints>` so the model reads a policy *as a policy* (not inferred from adjacency). At ~2,800-token prose prompts, organization matters as much as content; tags also make the prompt maintainable.
- **Criteria tables beat examples alone for consistent classification.** Few-shot teaches judgment on ambiguous cases, but without **explicit written criteria** ("Critical = security vuln or data loss; High = incorrect behavior under normal conditions") the model falls back on shifting internal definitions (~40% label flips on near-identical inputs). Examples anchor to the criteria.
- **`<thinking>` blocks inside few-shot teach the decision logic, not just I/O mapping.** To override a keyword cue (model picks `lookup_order` vs `get_customer` on the word "account"), each example includes reasoning: *"'account' is a red herring; the intent is a missing order → lookup_order."* The model generalizes the reasoning pattern; without it, it only sees input→output and guesses the logic.
- **Prompt caching: breakpoint after the stable prefix, before dynamic content.** Cache the system prompt + few-shot + reference docs (never-changing); the recent turns + current message stay outside. At 5k stable tokens × 1,000 req/day that's 5M redundant tokens/day eliminated. Ordering aligns with lost-in-the-middle: stable instructions at the top are both cache-friendly *and* high-attention.

---

## 3. Context management (long conversations & multi-agent)

- **Compress upstream, not just at summarization.** An 85k-token / 22-turn convo that's 70% verbose tool results: raising the summarization threshold treats the wrong layer. **Trim tool outputs to the task-relevant fields *before* they enter history** — that shrinks *every* future turn, not just the one summarization eventually runs on.
- **Case-facts block for precise values.** Summarization is lossy for exact numbers — "$47.50 → $45", dropped order IDs — even when told "preserve all numbers." Fix: extract dollar amounts, order IDs, dates, commitments into a **persistent block included in every request that never passes through summarization**. Narrative gets compressed; transactional facts stay verbatim outside the lossy channel.
- **Section the case-facts block per issue.** With 3 open cases (return + billing + shipping), a flat block makes "$47.50 / #A-2847" ambiguous. Give each issue its own section (amounts, IDs, dates, status, pending actions); grows modestly, stays in the cached prefix.
- **Sub-agent context isolation.** A research sub-agent that read 20 docs must **return structured data (key facts + citations), not its 12k-token trail** — otherwise that trail is re-sent on *every* coordinator turn for the rest of the session (cost compounds linearly). Verbose exploration lives in the sub-agent's isolated context.
- **Handoff summary > raw transcript for resuming.** To resume a 180k-token session, a 5-field summary (original request, work done, findings, remaining work, blockers) beats re-injecting the transcript: the transcript carries stale tool results and dead ends and starts the new session under the same context pressure, with lost-in-the-middle burying the important recent decisions.

---

## 4. Structured output & constrained decoding

- **Prompt instructions are probabilistic; constrained decoding is deterministic.** "Return JSON with fields X" is a strong suggestion (~1.5% deviation → ~75 parse failures/day at 5k docs). Move format enforcement out of the prompt into the **decoding layer**: constrained decoding filters the token vocabulary at each step so only schema-valid tokens are eligible. Structure becomes a property of *generation*, not of the model's goodwill.
- **Schema size has a cost.** Deep/wide schemas (60 fields, 6 levels) add ~40% latency and *degrade* free-form field quality — the decoder spends attention tracking schema state instead of understanding the source. Past ~30–40 fields / ~4 levels, **split into multiple focused passes**.
- **"Tool use without tools" is the recommended extraction pattern.** Tool params and structured output share one mechanism: a JSON schema enforced by constrained decoding. Emit a `tool_use` block and read its `input` as the extracted data — no function need exist. Inherits the same schema guarantee as function calling.
- **`tool_choice`:** `forced` (`{"type":"tool","name":"extract_receipt"}`) removes the model's discretion — use when the type is already known upstream. `any` forces *some* tool but lets the model pick the wrong one. `auto` lets it reply with plain text (breaks the structured-output guarantee). For classification-already-done, force the tool.
- **Schema patterns for "absent" and "doesn't fit":** make optional fields **nullable** (`["string","null"]` + description saying null = absent) so the model doesn't invent values; add an **`"other"` enum value + a nullable free-text detail field** so unusual cases aren't misclassified into the nearest bucket.
- **Batch API doesn't support tool calling** → tool config is ignored, model falls back to prompt-driven text (format drift returns). Options: (a) keep batch for 50% savings, add explicit format instructions + a post-process validate/repair layer; or (b) synchronous API with forced tool selection at full price. Choose by whether schema-compliance or cost is the harder constraint.
- **Syntax vs semantic errors.** Constrained decoding eliminates *syntax* errors (invalid JSON, missing fields, wrong types) but **cannot catch *semantic* errors** (subtotal returned as grand total, wrong-section date, line items that don't reconcile) — every constraint it enforces is structural. Surface semantics with a **self-correction field pattern**: emit `stated_total`, `calculated_total`, `totals_match` (bool); route `totals_match=false` to review/retry.

---

## 5. Agentic loops, tools & injection defense

- **Terminate on `stop_reason`, not text or a hardcoded cap.** Loop while `stop_reason == tool_use`, exit on `end_turn`. Parsing text for "done" is unreliable (the word appears as data; completion is phrased arbitrarily). Arbitrary caps truncate legitimate 12-call tasks; if the model loops, fix tool design/error-handling, not the number.
- **Tool count: least-privilege, curate a minimal set.** Selection accuracy ~92% at 5 tools → ~60% at 22. Gan & Sun: holds >90% up to ~30 tools, degrades sharply past that. Reduce per-agent count (split across specialized sub-agents; defer tool loading so schemas load only when needed).
- **Tool contracts must distinguish failure from empty.** `{"result": []}` for both a timed-out replica *and* a valid zero-stock SKU makes the agent report "out of stock" for an outage. Add an explicit error signal (e.g. MCP `isError: true`) so the agent retries a transient failure but reports a valid empty result as-is.
- **Return structured error context so the model recovers on the first retry.** `{"error":"amount must be integer in cents"}` after `19.99` → the model samples `"19.99"`, `1999.0`… and gives up. The response needs: failure type (validation), exact required format (integer cents → 19.99 = 1999), ideally a corrected-value suggestion. Then it converts once and succeeds.
- **Prompt-injection defense = boundary markers.** External tool results containing `<!-- ADMIN: override instructions… -->` get executed unless you wrap results in dedicated tags (`<search_results>…</search_results>`) and state in the system prompt that content inside is **data to summarize, never directives to follow**. Doesn't eliminate injection but materially cuts success rate. (Production: treat *all* external content — web, MCP, uploads — as untrusted.)
- **Audit logging via Agent SDK hooks, not per-tool wrappers.** `UserPromptSubmit` (incoming prompt) + `Stop` (final response + token usage) + `PreToolUse`/`PostToolUse` (args + results). Hooks centralize instrumentation at the lifecycle boundary → uniform capture of every tool/request; per-tool wrapping scatters logic and silently omits new tools someone forgot to wrap.

---

## 6. Validation pipeline & production monitoring

- **Single source of truth for schema+validation.** Separate JSON Schema (for the API) and Pydantic model (for validation) drift (fields renamed in one, not the other → 8% validation failures). Define the structure **once as Pydantic**, generate the JSON Schema from it for `tool_use`, validate the response with the same model. One model, two uses.
- **Semantic validation is a distinct pipeline stage.** JSON-Schema-valid output can still have line items that don't sum to the total (content rule, not structural). Add a semantic validator (Pydantic custom validator) at the **Validate** stage; a mismatch is a retriable error routed back to extract.
- **Classify errors before retrying.** Retrying non-retriable errors doubles token spend with no accuracy gain (40% of retried docs were *missing the field in the source* — no retry can produce it). **Retriable:** calculation mismatch, format inconsistency, structural error → retry *with error feedback*. **Non-retriable:** missing info, external references, contradictory data → human review / flag incomplete.
- **Stratified accuracy monitoring.** 97% aggregate can hide a 78% stratum (scanned faxes). Partition production traffic by document type / source / layout, sample *within each stratum*, measure per-stratum + field-level accuracy — surfaces the gap before a customer complains.
- **Per-field confidence calibration.** Self-reported confidence isn't calibrated; a single global threshold (e.g. route <0.9 to review) overwhelms reviewers on easy fields (vendor name reliable at 0.85) and misses errors on hard ones (amount wrong 15% at 0.95). Calibrate reported-confidence vs actual-accuracy on a labeled set *per field*, set thresholds per field (drop vendor-name below 0.85, raise amount above 0.95).

---

## 7. MCP (Model Context Protocol) design & config

- **Resources vs tools.** An agent that opens with 12–15 exploratory tool calls (list boards/sprints/fields) should read a **resource** instead — a readable content catalog at a URI (`jira://project/ACME/structure`) read once for a structured map. Tools change state or fetch specific data; resources give the overview. 15 round-trips → 1 resource read + a few focused calls.
- **Config location = sharing scope.** `~/.claude.json` is **user-level** (personal, never in VCS) → teammates can't reproduce. Team-relied-on servers belong in **project-level `.mcp.json`** at the repo root (checked into Git, applied on clone). User-level only for personal/experimental servers.
- **Secrets via env-var expansion.** Commit `.mcp.json` safely by referencing `${GITHUB_TOKEN}` in the `env` block; the MCP client resolves it from each dev's environment at launch. The file holds only the variable name; each dev authenticates as themselves.
- **Tool descriptions are the selection interface.** A custom `run_command` ("Run a command") loses to the built-in Bash tool 95% of the time (more training familiarity + no differentiating signal). Rewrite the description to say *when it wins*: "Execute inside the project's Docker container with deps + DB creds preinstalled; use instead of Bash when the task requires containerized execution."
- **Per-agent MCP scoping (least privilege).** A web-research sub-agent accidentally given the GitHub MCP server started opening issues. Scope each agent to only the servers its role needs; state-changing integrations (GitHub) belong with the coordinator or a dedicated code agent, never every sub-agent.

---

## 8. Multi-agent architecture

- **Go multi-agent for *context management*, not capability.** 22 tools across 4 domains in one agent → 28% wrong-tool + skipped steps; a larger model shows the same. Fix = **coordinator-subagent**: each sub-agent gets one domain, a narrow tool list, a focused prompt; the coordinator tracks progress and synthesizes.
- **Hub-and-spoke: all communication through the coordinator.** Wiring sub-agent 3 to read sub-agent 1's partial output and instruct sub-agent 4 introduces (a) **race conditions** (reads incomplete output), (b) **conflicting instructions** (coordinator + peer), (c) **unclear responsibility** for the final output. Pay the extra hop.
- **Context forking keeps the coordinator clean.** A sub-agent that read 20 docs returns a ~180-token result, **not** its 40k-token reasoning trail — returning the trail refills the coordinator's context and reproduces single-agent overload. Need more detail? Spawn a targeted follow-up sub-agent.
- **Decompose broad, then refine.** Over-narrow decomposition (regulation impact → only "compliance cost" + "legal penalties", missing "market structure"/"consumer behavior") comes from committing to a narrow frame early. Enumerate candidate dimensions broadly → prune → iterate (execute, evaluate coverage vs the original question, re-delegate gaps) with explicit bounds on refinement cycles.
- **Cost pattern: Opus coordinator + Sonnet workers.** Coordinator makes the complex calls (decomposition, conflict reconciliation, synthesis, gap ID) where Opus-level judgment matters; sub-agents do well-scoped routine work (fetch, normalize, extract) that Sonnet handles reliably at a fraction of cost. Match tier to task complexity *per role*, not uniformly. (Verify current model IDs via `claude-api` — see SKILL.md §7.)

---

## 9. Claude Code configuration & tooling

- **CLAUDE.md: project vs user level.** A rule that "works for me but not teammates" is almost always in `~/.claude/CLAUDE.md` (user-level, not shared). Team standards go in the **project CLAUDE.md** at the repo root (or an imported file) so cloning brings them along.
- **`.claude/rules/` + `paths` frontmatter for scoped rules.** An 800-line CLAUDE.md firing PCI warnings on CSS files: move payment rules to `.claude/rules/payments-security.md` with `paths: ["src/payments/**/*.ts", ...]` so they load only for those files. Truly universal rules ("never commit secrets") stay in CLAUDE.md.
- **Skill precedence: enterprise > personal > project > plugin**, same-name fully overrides (no merge). "The team's new skill isn't running for me" = a personal `~/.claude/skills/<name>.md` silently winning; delete/rename it to pick up the project version.
- **`context: fork` for discovery-heavy skills.** A skill that reads 40+ manifests pollutes the main context (Claude later references unrelated packages). Frontmatter `context: fork` runs it in an isolated subcontext; only the concise summary returns. Same motivation as the Explore subagent.
- **Plan mode triggers:** ambiguous requirements **or** an architectural decision **or** multi-file scope. "Refactor auth to JWT" hits all three (token storage? refresh strategy? backward compat? + login/middleware/client/logout). Direct execution is for narrow unambiguous tasks ("add a null check on line 42").
- **Grep vs Glob:** Grep = searching file *contents* (who imports `legacy-auth`); Glob = matching *paths* by name (`packages/**/*.spec.ts`). Criterion: inside-the-file vs name-and-location. Confusing them wastes tokens.
- **Edit ambiguity fallback:** anchor appears 7× → Edit fails. Read the whole file → modify in working memory → Write it back (Write doesn't depend on anchor matching; trades tokens for determinism).
- **Don't "Read every file."** Filling the window with mostly-irrelevant material accelerates context degradation. Incremental pattern: Grep an entry point → Read it → trace imports selectively → Grep call sites. For ~25-file discovery, use the **Explore subagent** (isolated context; only a summary returns).
- **CI review noise erodes trust across categories.** FP rates: security 5% / correctness 8% / style 35% / naming 42% / docs 38% → devs ignore *everything*, including security. Disable the high-noise categories, run only security+correctness, fix the disabled prompts (explicit criteria + few-shot), re-enable one at a time. 10 findings acted on > 10 accurate ones buried among 15 false positives.

---

## 10. Headless / CI integration

- **`-p` / `--print` is mandatory for CI.** Without it Claude Code waits for interactive input and hangs until the job timeout. `-p` = non-interactive: process once, write stdout, exit.
- **`--output-format json` + `--json-schema` kills parse fragility.** Regex over prose ("on line 42" vs "at line 42") fails ~15% of runs; the schema (file/line/severity/category/description/suggestion) enforced by constrained decoding gives a parseable object every run. Guarantee is structural, not semantic — content quality still depends on the prompt.
- **Review in an independent session (self-review bias again).** Generation + review in the *same* session flags issues on 4% of PRs while a human DBA catches 30% — the reviewer rationalizes the generator's reasoning. A fresh `-p` invocation given only the diff + criteria has no prior commitment.
- **Two-pass review for attention dilution across files.** A 14-file PR: catches SQL injection in file 3, approves the identical pattern in file 11. A 1M-token window doesn't fix it (dilution, not capacity). Pass 1: per-file analysis in isolation (full attention each). Pass 2: cross-file integration (data flow, inconsistencies, architectural concerns across boundaries).

---

## 11. Prompt Crystallization *(author's methodology — NOT Anthropic-recommended; included as a useful framing of the enforcement spectrum)*

Middle path between **vibe coding** (fast, unpredictable, no specs/tests) and **spec-driven** (reliable but slow, loses LLM nuance): **build with prompts first, then incrementally replace prompt-driven behavior with code as you understand the problem.** Key insight: *a prompt is simultaneously a program and a specification* — powerful for exploration, dangerous for production.

- **Phase 1 — Prompt Architecture:** whole workflow as LLM calls with structured prompts + structured output. LLM does everything; flexible, easy to iterate.
- **Phase 2 — Crystallization pivot:** find behaviors the LLM performs *deterministically* (date parsing, currency formatting, input validation). Loop: identify candidate → ask the LLM to articulate the implicit rules → generate replacement code → test against the eval set → swap the LLM call for code.
- **Phase 3 — Incremental hardening:** hybrid — deterministic code for predictable parts, narrow LLM calls for the parts that genuinely need language understanding. This *is* the enforcement spectrum: start left (prompts), move pieces right (programmatic) as you learn which need deterministic guarantees.
- **What to crystallize first (matrix = determinism × volume):** deterministic + high-volume → crystallize immediately (cost). Deterministic + low-volume → when convenient. Judgment-requiring → keep as LLM call (optimize the prompt). **Crystallize:** format conversions (dates/currency/phone), input validation, clear-rule routing (`if amount > $500 → manager approval`), template substitution. **Keep as LLM:** semantic understanding, ambiguous categorization, natural-language generation, context-dependent reasoning.
- **Partial crystallization:** code wrapper handles the deterministic parts, a narrow LLM call handles only the ambiguous reasoning (e.g. invoice extraction: code validates format + extracts known-template fields + validates business rules; LLM only handles ambiguous line items).

---

## 12. RAG architecture patterns *(not exam-tested but ubiquitous; solves "the LLM doesn't know your data")*

**Pipeline (5 stages):** **Retrieve** (broad, 20–50 candidates; semantic / keyword / hybrid) → **Rerank** (score for relevance, narrow to top 3–5 — retrieval is noisy: same-product-different-version, outdated policy) → **Inject** (top docs into the prompt: most-relevant at *beginning and end* [lost-in-the-middle], clear headers + source labels, only what's needed) → **Generate** (prioritize retrieved context over general knowledge, cite sources, flag when context is insufficient).

- **Chunking:** too large = irrelevant context + diluted attention; too small = loses meaning. Approaches: split by section/paragraph boundaries; overlapping windows (carry last few sentences); split by semantic coherence. Start **200–500 tokens/chunk**, tune by retrieval accuracy.
- **RAG vs alternatives:** **RAG** for large, frequently-updated KBs needing cited/traceable answers (limitation: retrieval quality + latency). **Long context** for doc sets under ~200k total (limitation: cost/request + lost-in-the-middle — but sometimes including 50 pages directly beats hoping retrieval finds the paragraph). **Fine-tuning** for consistent *behavior*, not factual recall (expensive to update; doesn't reliably memorize facts). **Prompt engineering** for static small context.
- **Anti-patterns:** retrieving too much (15 docs where 3 suffice — more context ≠ better); no reranking (semantically-similar-but-irrelevant, "return policy electronics" pulls clothing); ignoring chunk boundaries (mid-sentence fragments); no source attribution (can't verify/trace — always include title/section/URL + instruct to cite). **Stale index:** index freshness must match source update frequency (daily docs, weekly index → stale retrieval).

---

## 13. Production readiness checklist *(ties the concepts into a deploy assessment)*

- **Security:** prompt-injection defense (external tool results as untrusted data, boundary markers) · PII identified/masked/excluded by classification · data residency (cloud vs local) matches regulation · input filtering (catch injection before it spends tokens) · output filtering (content policy, PII leakage).
- **Cost:** per-request/session token monitoring + spike alerts · model tier per task (Opus reasoning/coordination, Sonnet routine, Haiku classify/route — verify IDs via `claude-api`) · batch API for latency-tolerant workloads (50%) · prompt caching of stable prefixes · upstream data compression of tool/sub-agent outputs · explicit context budget per prompt.
- **Reliability:** programmatic enforcement for critical paths (financial, identity, compliance — code, not prompts) · validation layers (schema/syntax + business-rule/semantic) · retry with error feedback, non-retriable → human · graceful degradation (partial results with gap annotations) · human-escalation criteria (specific rules, not sentiment/self-confidence) · eval sets + regression testing before deploy.
- **Observability:** request/response logging (input, output, tokens, latency, model version) · per-agent/tool/session token tracking · quality metrics over time (accuracy, FP rate, confidence, escalation) · accuracy-drift alerting · stratified monitoring (per type/field/category).
- **Streaming (user-facing):** SSE token-by-token · streaming + interleaved tool use · timeout handling so long tool calls don't drop the stream.
- **Rate limiting & retry:** exponential backoff + jitter · circuit breaker on repeated downstream failures · queue-based architecture to absorb bursts · retry budget (max count + total timeout, never infinite).
- **Compliance/audit:** audit trails (asked / context / responded / action) · reasoning traces stored for regulated decisions (loans, claims, triage) · data retention + purge policies · explainability (trace a decision to specific inputs + reasoning).
