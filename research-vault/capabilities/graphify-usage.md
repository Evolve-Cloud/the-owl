---
title: graphify usage (claude-cli backend, one-shot CLI)
type: capability
tags: [graphify, second-brain, knowledge-graph, claude-cli, backend]
verified_on: 2026-07-30
verified_by: user-memory correction 2026-07-30 (`--update` failed "no LLM API key found"; fix = `--backend claude-cli`); binary path observed on nvm node bin
status: verified
---

## What it is

`graphify` is the knowledge-graph engine under the `/graphify` and `/second-brain` skills: it turns any input (code, docs, papers) into a persistent graph with god nodes, community detection, and query/path/explain tools. In this environment it is invoked **as a one-shot CLI** (an allowed action under the hard constraints — a CLI call, *not* a running service/daemon).

## How the-owl uses it

- Invoked on demand by the `second-brain` / `graphify` skills to build or refresh a graph, then export Obsidian stubs into a per-project map dir (never the vault root): `graphify export obsidian --dir <vault>/maps/<proj>`.
- The binary lives on the **nvm node path**, not the default `PATH`. Export it first:
  ```bash
  export PATH="$HOME/.nvm/versions/node/$(ls $HOME/.nvm/versions/node | tail -1)/bin:$PATH"
  ```
- Every extract/update/label call passes the backend explicitly:
  ```bash
  graphify <path> --update --backend claude-cli
  ```

## Verified facts

- **Backend MUST be `claude-cli`.** `--backend claude-cli` shells out to the authenticated `claude` CLI (Claude Pro Max subscription), so extraction runs at **$0 / no key**. There is **no** `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` in this environment — the system is OAuth/subscription-based. (Evidence: 2026-07-30 a `graphify … --update` failed with *"no LLM API key found"*; the correct fix was `--backend claude-cli`, not supplying a key.)
- **One-shot, not a service.** graphify is run as a CLI and exits — compatible with the "markdown/YAML/JSON only, NO runtime/daemon/python-service" constraint precisely because it is invoked, not left running.
- **claude-cli extraction is less granular** than the original backend (the the-owl agents graph went 54→19 nodes on re-extract). This is a **backend difference, not content loss** — do not treat the smaller node count as a bug.
- **Engine-only output.** Emit the engine graph; do **not** dump an Obsidian stub tree into curated vault dirs. `graphify export obsidian` **regenerates and overwrites** stubs (verified 2026-07-28) — authored vault content must live outside the export target so a refresh never clobbers it.

## Pitfalls

- **Asking for / setting an API key.** The reflex to "supply a key" when extraction fails is wrong here — always `--backend claude-cli`. A key is neither present nor needed.
- **Forgetting the PATH export** → `command not found`, because the binary is off the default path.
- **Exporting stubs over curated notes.** `export obsidian` is destructive to its `--dir`; point it at a dedicated `maps/<proj>` dir, never a hand-authored vault folder.

## Related

- [[ADR-019-second-brain-graphify-obsidian-one-vault]] — one-vault second-brain decision
- [[self-improvement-and-memory]] — graphify as durable, queryable memory
- user-memory: `graphify-uses-claude-cli-not-api-key`, `second-brain-atlas-graphify-obsidian`, `owl-agents-pack-no-symlinks`
