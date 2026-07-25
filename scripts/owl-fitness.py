#!/usr/bin/env python3
"""
the-owl fitness reporter (ADR-014).

Aggregates per-run judge scores into a per-version mean + spread, and — when a task has
two versions to compare (e.g. a convention's before/after) — reports the delta of means
and whether it EXCEEDS run-to-run noise. This is what turns a single anecdotal run into a
measurement: k>=3 runs per version, compare means, discount deltas smaller than the spread.

Reads:  eval/results/runs/*.json   (one file per run — see the record format below)
Usage:  python3 scripts/owl-fitness.py

Run-record JSON (written after a judge scores an artifact):
  {
    "task": "01-architect-adr",
    "version": "old",              # any label; two distinct labels on one task = a comparison
    "run": 1,
    "total": 91,
    "scores": {"decision": 24, "alternatives": 18, "handoff": 22, "lane": 17, "structure": 10}
  }
"""
from __future__ import annotations
import json
import statistics as st
from collections import defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
RUNS = REPO / "eval" / "results" / "runs"


def load_runs() -> list[dict]:
    out = []
    if RUNS.exists():
        for p in sorted(RUNS.glob("*.json")):
            try:
                out.append(json.loads(p.read_text(encoding="utf-8")))
            except Exception:
                pass
    return out


def summarize(totals: list[float]) -> dict:
    n = len(totals)
    mean = sum(totals) / n if n else 0.0
    lo, hi = (min(totals), max(totals)) if totals else (0, 0)
    spread = hi - lo
    stdev = st.pstdev(totals) if n > 1 else 0.0
    return {"n": n, "mean": mean, "min": lo, "max": hi, "spread": spread, "stdev": stdev}


def main() -> int:
    runs = load_runs()
    print()
    print("🦉 the-owl — fitness report  (ADR-014)")
    print("═" * 68)
    if not runs:
        print("  no run records in eval/results/runs/ — run a fitness pass first.")
        print("  (see eval/README.md; a run record is written per judged artifact.)")
        print("═" * 68)
        return 0

    # group: task -> version -> {totals: [], dims: {dim: []}}
    g: dict = defaultdict(lambda: defaultdict(lambda: {"totals": [], "dims": defaultdict(list)}))
    for r in runs:
        t, v = r.get("task", "?"), str(r.get("version", "?"))
        g[t][v]["totals"].append(float(r.get("total", 0)))
        for d, s in (r.get("scores") or {}).items():
            g[t][v]["dims"][d].append(float(s))

    for task in sorted(g):
        print(f"TASK  {task}")
        versions = g[task]
        summaries = {v: summarize(versions[v]["totals"]) for v in versions}
        for v in sorted(versions):
            s = summaries[v]
            band = f"±{s['spread'] / 2:.1f}" if s["n"] > 1 else "(n=1, no spread)"
            print(f"  {v:<10} mean {s['mean']:.1f} / 100   (n={s['n']}, range {s['min']:.0f}–{s['max']:.0f} {band}, σ={s['stdev']:.1f})")

        # comparison when exactly two versions exist (baseline first, so Δ = after − before)
        if len(versions) == 2:
            baseline = {"old", "before", "baseline"}
            va, vb = sorted(versions, key=lambda v: (v not in baseline, v))
            sa, sb = summaries[va], summaries[vb]
            delta = sb["mean"] - sa["mean"]
            noise = max(sa["spread"], sb["spread"]) / 2 if (sa["n"] > 1 and sb["n"] > 1) else float("inf")
            print(f"  Δ ({vb} − {va})  =  {delta:+.1f}")
            # per-dimension delta
            dims = sorted(set(versions[va]["dims"]) | set(versions[vb]["dims"]))
            for d in dims:
                da = versions[va]["dims"].get(d, [])
                db = versions[vb]["dims"].get(d, [])
                if da and db:
                    dd = (sum(db) / len(db)) - (sum(da) / len(da))
                    if abs(dd) >= 0.05:
                        print(f"      {d:<14} {dd:+.1f}")
            # worst-case (reliability): a convention can prevent failures without moving the mean
            dmin = sb["min"] - sa["min"]
            print(f"  worst-case min: {va} {sa['min']:.0f} · {vb} {sb['min']:.0f}   →  Δmin {dmin:+.0f}")
            # verdict
            if sa["n"] < 3 or sb["n"] < 3:
                print(f"  VERDICT: not conclusive — need k≥3 per version (have {sa['n']}/{sb['n']}).")
            elif abs(delta) <= noise:
                print(f"  VERDICT: mean WITHIN run-to-run noise (|Δ| {abs(delta):.1f} ≤ band {noise:.1f}).")
                # worst-case can carry a signal the mean hides — but sign matters:
                #   +Δmin ≫ mean  → the change lifts the WORST run (a reliability WIN a guardrail gives)
                #   −Δmin ≫ mean  → the new version's worst run is LOWER: could be a regression OR just
                #                    higher run-to-run variance. n=3 can't separate — say so, don't spin it.
                if dmin >= 3 and (dmin - abs(delta)) >= 3:
                    print(f"           ⚠ but worst-case Δmin {dmin:+.0f} ≫ mean Δ — likely a RELIABILITY WIN")
                    print(f"             (lifts the worst run) the mean test under-detects; check per-run notes.")
                elif dmin <= -3 and (-dmin - abs(delta)) >= 3:
                    print(f"           ⚠ worst-case Δmin {dmin:+.0f} while mean flat — new version's worst run is lower.")
                    print(f"             Could be a reliability REGRESSION or just higher variance; n=3 can't tell — add runs.")
            else:
                print(f"  VERDICT: EXCEEDS noise (|Δ| {abs(delta):.1f} > band {noise:.1f}) — real directional effect.")
        print()

    print("═" * 68)
    print("Reminder: 5-task sample + LLM judge. A delta is evidence, not proof. Rotate tasks.")
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
