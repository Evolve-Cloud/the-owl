# the-owl — Architecture Diagrams

Visual reference for the self-improvement loop. Diagrams are [Mermaid](https://mermaid.js.org/) (render natively on GitHub; pure text, no runtime — consistent with the-owl's markdown-only identity). Authoritative details live in `docs/decisions/ADR-001..010` and `docs/planning/prd-owl-self-improvement.md`.

---

## 1. The daily loop — L0→L5 (`/owl:evolve`)

How one autonomous cycle flows from research to a landed change. The gate is **blocking**; landing is **shadow (PR)** by default.

```mermaid
flowchart TD
    sched([launchd — daily 07:13]) --> guard{shadow guard<br/>landing == pr?}
    guard -- no, not opted-in --> refuse[refuse + log]
    guard -- yes --> L0

    L0["<b>L0 · Research</b><br/>/owl:research → codex exec<br/>writes daily brief"] --> L1
    L1["<b>L1 · Scout</b><br/>brief + live WebSearch<br/>→ candidate ideas"] --> L15
    L15["<b>L1.5 · Gap-analysis</b> (ADR-005)<br/>audit real agents:<br/>already impl? gap? target file?"] --> L2
    L2["<b>L2 · Curator</b><br/>dedup vs ledger → rubric score<br/>→ safety veto → classify"] --> decide

    decide{accepted?<br/>within cap?}
    decide -- deferred/rejected --> vault[(record in vault<br/>+ ledger)]
    decide -- accepted --> L3

    L3["<b>L3 · Integrate</b><br/>architect → ADR<br/>builder → edit target file"] --> L4
    L4{"<b>L4 · Gate</b> (blocking)<br/>guardian · sentinel · challenger"}
    L4 -- any FAIL --> reject[reject + log to vault<br/>no commit]
    L4 -- all PASS --> L5
    L5["<b>L5 · Land</b><br/>shadow branch + PR<br/>chronicler updates docs"] --> human(["human reviews + merges"])

    reject --> vault
    L5 --> vault

    style guard fill:#4a3,color:#fff
    style L4 fill:#a33,color:#fff
    style L15 fill:#36c,color:#fff
    style human fill:#555,color:#fff
```

---

## 2. Agent topology — hub-and-spoke

The orchestrator (`/owl:evolve`) is the only caller; specialists **hand off and return control**, never call each other. Research/curation agents are new; integrate + gate reuse existing DevFlow agents.

```mermaid
flowchart TD
    orch{{"/owl:evolve<br/>orchestrator (hub)"}}

    subgraph research ["Research and Curation"]
        scout["scout<br/>field research"]
        curator["curator<br/>rigor + owns vault"]
    end
    subgraph integrate ["Integrate"]
        architect["architect<br/>writes ADR"]
        builder["builder<br/>applies edit"]
    end
    subgraph gate ["Gate - blocking"]
        guardian["guardian<br/>role + regression"]
        sentinel["sentinel<br/>injection + carve-out"]
        challenger["challenger<br/>real improvement?"]
    end
    chronicler["chronicler<br/>docs + memory"]

    orch --> scout --> orch
    orch --> curator --> orch
    orch --> architect --> orch
    orch --> builder --> orch
    orch --> guardian --> orch
    orch --> sentinel --> orch
    orch --> challenger --> orch
    orch --> chronicler --> orch

    vault[(research-vault/<br/>ledger = dedup truth)]
    scout -.writes.-> vault
    curator -.owns.-> vault

    style orch fill:#36c,color:#fff
    style gate fill:#a33,color:#fff
    style sentinel fill:#a33,color:#fff
```

---

## 3. Safety model — the NFR-SEC-1 carve-out (ADR-001)

**Why autonomous-commit is acceptable:** the loop can improve any agent *except its own brakes*. The carve-out is enforced at L3 (pre-check) and L4 (sentinel).

```mermaid
flowchart LR
    loop{{self-improvement loop}}

    subgraph mayedit ["✅ MAY edit (autonomously)"]
        a1[strategist / architect]
        a2[system-designer / builder]
        a3[chronicler / scout / curator]
        a4["conventions & docs"]
    end

    subgraph noedit ["⛔ MAY NOT edit — human-only"]
        g1[sentinel veto · guardian gate]
        g2[challenger · rubric safety floor]
        g3[.owl/loop-config.yml · scope allow-list]
        g4[settings.json · schedule · ~/.ssh · secrets]
    end

    loop --> mayedit
    loop -.->|blocked: L3 pre-check + L4 sentinel| noedit

    style mayedit fill:#2a3,color:#fff
    style noedit fill:#a22,color:#fff
    style loop fill:#36c,color:#fff
```

---

## 4. Shadow landing & git flow

Default is **shadow**: the loop proposes on a branch; a human is the merge gate. `main` is never touched autonomously (until `landing: main` is deliberately set).

```mermaid
sequenceDiagram
    participant Cron as launchd (daily)
    participant Loop as /owl:evolve
    participant Gate as guardian+sentinel+challenger
    participant Git as GitHub
    participant Human as Human (merge gate)

    Cron->>Loop: fire 07:13 (shadow guard: landing==pr)
    Loop->>Loop: L0–L3 (research → score → ADR + edit)
    Loop->>Gate: L4 review the proposed diff
    alt any FAIL
        Gate-->>Loop: FAIL → reject, log to vault, no commit
    else all PASS
        Gate-->>Loop: PASS
        Loop->>Git: push branch owl/evolve-DATE-{id} (+ open PR if token)
        Note over Git: main untouched
        Human->>Git: review PR
        Human->>Git: merge → main
    end
```

---

## Rubric (curator's gate) — for reference

| Criterion | Weight |
|---|---|
| Fit to architecture (markdown-only, no-runtime, hub-spoke, context-minimal) | 25 |
| Evidence strength (multiple high-star repos / primary sources) | 20 |
| Impact (quality / coordination / token-efficiency) | 20 |
| Simplicity & reversibility (small, atomic, no new runtime) | 15 |
| Safety (no new attack surface; respects governance) | 10 |
| Non-duplication | 10 |

Accept ≥ threshold (starts **75**, ratchets **+5/minor**, cap **90**) · Reject < 60 · **Hard veto:** Safety sub-score < 7 auto-rejects regardless of total. Config in `.owl/loop-config.yml` (inside the carve-out). See ADR-003.
