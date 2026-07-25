#!/usr/bin/env python3
"""
the-owl — cycle scorecard / efficiency metrics.

Reads what the loop ALREADY produces (research-vault/ledger.md, .owl/state/last-run.json,
the agent files, and git) and prints a scorecard. Read-only: it computes nothing that
mutates state, so it is safe to run anytime (and is outside the NFR-SEC-1 carve-out).

Headline framing (see the metrics discussion, 2026-07-24):
    efficiency = durable value delivered / cost to deliver
The single most actionable signal today is ROLLOUT COVERAGE — is accepted work actually
finished across the fleet, or does it stay as "convention debt"? Cost fields are not yet
instrumented (the loop does not log codex $ / tokens / human minutes); they print as "—"
until last-run.json carries them.

Usage:  python3 scripts/owl-metrics.py
"""
from __future__ import annotations
import json
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
LEDGER = REPO / "research-vault" / "ledger.md"
LAST_RUN = REPO / ".owl" / "state" / "last-run.json"
AGENTS_DIR = REPO / ".claude" / "commands" / "agents"
META_DIR = REPO / ".devflow" / "agents"

# The loop may improve any agent EXCEPT these (NFR-SEC-1 carve-out). They are the
# denominator's exclusion set: conventions are not rolled into them by the loop.
CARVE_OUT = {"sentinel", "guardian", "challenger"}

# Orchestrator/hub — NOT a pipeline specialist. The handoff-contract and role-ownership
# conventions govern specialist handoffs/boundaries; they do not apply to the hub
# (whose "next agent" is every agent). Excluded from the coverage denominator by design
# (documented in the rollout ADR), so 100% is reachable. This is scope, not debt.
NA_FOR_CONVENTIONS = {"team"}

# Conventions and the marker that proves an agent carries them. A convention is
# "rolled out" to an agent when the marker is present in its .md file.
CONVENTIONS = {
    "handoff-contract": "Contrato de Handoff",       # ADR-004/006/007/008
    "role-ownership": "Papel & Não-Papel",           # ADR-009 (rollout pending)
}


def _rule(char: str = "─", n: int = 72) -> str:
    return char * n


def load_last_run() -> dict:
    try:
        return json.loads(LAST_RUN.read_text(encoding="utf-8"))
    except Exception:
        return {}


def parse_ledger() -> list[dict]:
    """Return the ledger table rows as dicts. Columns: id,title,score,status,adr,first_seen,decided."""
    rows: list[dict] = []
    if not LEDGER.exists():
        return rows
    for line in LEDGER.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line.startswith("|"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4:
            continue
        if cells[0].lower() in ("id", "") or set(cells[0]) <= set("-: "):
            continue  # header or separator
        score_raw = cells[2]
        try:
            score = int(score_raw)
        except ValueError:
            score = None  # "—" or blank = unscored (deferred without a number)
        rows.append(
            {
                "id": cells[0],
                "title": cells[1],
                "score": score,
                "status": cells[3].lower(),
                "adr": cells[4] if len(cells) > 4 else "",
            }
        )
    return rows


def editable_agents() -> list[str]:
    if not AGENTS_DIR.exists():
        return []
    names = sorted(p.stem for p in AGENTS_DIR.glob("*.md"))
    return [n for n in names if n not in CARVE_OUT]


def convention_agents() -> list[str]:
    """Editable agents that pipeline conventions actually target (excludes the orchestrator hub)."""
    return [a for a in editable_agents() if a not in NA_FOR_CONVENTIONS]


def rollout_coverage() -> dict[str, dict]:
    """For each convention: which target agents carry its marker."""
    agents = convention_agents()
    out: dict[str, dict] = {}
    for conv, marker in CONVENTIONS.items():
        have, missing = [], []
        for a in agents:
            text = (AGENTS_DIR / f"{a}.md").read_text(encoding="utf-8", errors="ignore")
            (have if marker in text else missing).append(a)
        out[conv] = {"have": have, "missing": missing, "total": len(agents)}
    return out


def meta_ownership() -> dict:
    """Informational: how many agent .meta.yaml declare an explicit role + non-goals."""
    if not META_DIR.exists():
        return {}
    have, missing = [], []
    for p in sorted(META_DIR.glob("*.meta.yaml")):
        name = p.name.replace(".meta.yaml", "")
        if name in CARVE_OUT:
            continue
        t = p.read_text(encoding="utf-8", errors="ignore")
        # explicit role AND an explicit "must-not-do" list = ownership boundary present
        if re.search(r"^\s*role\s*:", t, re.M) and "should_not_do" in t:
            have.append(name)
        else:
            missing.append(name)
    return {"have": have, "missing": missing, "total": len(have) + len(missing)}


def git_cycles() -> dict:
    def run(args: list[str]) -> str:
        try:
            return subprocess.run(
                ["git", *args], cwd=REPO, capture_output=True, text=True, check=True
            ).stdout
        except Exception:
            return ""

    log = run(["log", "--oneline", "-n", "200"])
    cycles = [l for l in log.splitlines() if "owl:evolve" in l.lower()]
    prs = [l for l in log.splitlines() if "merge pull request" in l.lower() and "owl/evolve" in l.lower()]
    return {"landed_commits": len(cycles), "merged_prs": len(prs)}


def fmt_list(xs: list[str]) -> str:
    return ", ".join(xs) if xs else "—"


def main() -> int:
    lr = load_last_run()
    rows = parse_ledger()
    cov = rollout_coverage()
    meta = meta_ownership()
    git = git_cycles()

    accepted = [r for r in rows if r["status"] == "accepted"]
    rejected = [r for r in rows if r["status"] == "rejected"]
    deferred = [r for r in rows if r["status"] == "deferred"]
    scored = [r for r in rows if r["score"] is not None]

    acc_scores = [r["score"] for r in accepted if r["score"] is not None]
    rej_scores = [r["score"] for r in rejected if r["score"] is not None]

    print()
    print("🦉 the-owl — cycle scorecard")
    print(_rule("═"))

    # ---- HEADLINE: rollout coverage (the efficiency signal that bites today) ----
    print("ROLLOUT COVERAGE  (accepted work actually finished across the fleet?)")
    for conv, c in cov.items():
        n, tot = len(c["have"]), c["total"]
        pct = (100 * n // tot) if tot else 0
        bar_full = "█" * (n if tot else 0)
        bar_empty = "░" * (tot - n if tot else 0)
        print(f"  {conv:<18} {n}/{tot} ({pct:>3}%)  {bar_full}{bar_empty}")
        print(f"     ✓ {fmt_list(c['have'])}")
        print(f"     ✗ {fmt_list(c['missing']) if c['missing'] else '— (complete)'}{'   ← convention debt' if c['missing'] else ''}")
    if NA_FOR_CONVENTIONS:
        print(f"  (N/A by design: {fmt_list(sorted(NA_FOR_CONVENTIONS))} — orchestrator hub, not a pipeline specialist)")
    print()

    # ---- Latest cycle (from last-run.json) ----
    print(f"LATEST CYCLE  ({lr.get('cycle', '—')})")
    cand = lr.get("candidates_surfaced")
    acc_ct = len(lr.get("accepted", []) or [])
    if cand:
        print(f"  accept rate       {acc_ct}/{cand}  ({round(100*acc_ct/cand)}%)   (low = the rubric discriminates)")
    print(f"  accepted          {fmt_list(lr.get('accepted', []) or [])}")
    print(f"  rejected          {fmt_list(lr.get('rejected', []) or [])}")
    print(f"  deferred          {lr.get('deferred', '—')}")
    gate = lr.get("gate", {}) or {}
    print(f"  gate              guardian={gate.get('guardian','—')} · sentinel={gate.get('sentinel','—')} · challenger={gate.get('challenger','—')[:40]}")
    print(f"  carve-out contact {lr.get('carve_out_violations', '—')}   (MUST be 0)")
    print(f"  touched main      {lr.get('touched_main', '—')}   (MUST be false in shadow mode)")
    print()

    # ---- Cumulative rigor (from the ledger) ----
    print("RIGOR / DISCRIMINATION  (cumulative, from the ledger)")
    print(f"  decisions         {len(rows)} total → {len(accepted)} accepted · {len(rejected)} rejected · {len(deferred)} deferred")
    if acc_scores and rej_scores:
        print(f"  score separation  accepted {min(acc_scores)}–{max(acc_scores)}  vs  rejected {min(rej_scores)}–{max(rej_scores)}   (clean gap = healthy)")
    elif acc_scores:
        print(f"  accepted scores   {min(acc_scores)}–{max(acc_scores)}")
    print(f"  backlog (deferred){len(deferred):>3}   ({len(scored)}/{len(rows)} scored — if this grows faster than it drains, research is out-running integration)")
    print()

    # ---- Meta ownership (informational) ----
    if meta:
        n, tot = len(meta["have"]), meta["total"]
        print(f"META OWNERSHIP (.meta.yaml has explicit role + non-goals)  {n}/{tot}")
        print(f"  ✗ {fmt_list(meta['missing'])}")
        print()

    # ---- Throughput ----
    print("THROUGHPUT")
    print(f"  landed cycle commits {git['landed_commits']}   ·   merged PRs {git['merged_prs']}")
    print()

    # ---- Cost (not yet instrumented) ----
    print("COST / EFFICIENCY RATIO  (needs instrumentation)")
    print(f"  codex $ + tokens     {lr.get('cost', '— (não instrumentado)')}")
    print(f"  human review minutes {lr.get('human_review_minutes', '— (não instrumentado)')}")
    print("  → add 'cost' + 'human_review_minutes' to last-run.json to compute cost-per-durable-change")
    print(_rule("═"))
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
