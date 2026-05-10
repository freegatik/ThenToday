#!/usr/bin/env python3
"""Fail CI if main app line coverage from xccov JSON is below COVERAGE_MIN_LINE_PERCENT."""

from __future__ import annotations

import json
import os
import sys
from typing import Any, Iterable


def walk(obj: Any) -> Iterable[tuple[str, float, int]]:
    """Yield (name, lineCoverage 0...1, executableLines) from nested xccov JSON."""
    if isinstance(obj, dict):
        name = str(obj.get("name", ""))
        cov = obj.get("lineCoverage")
        lines = obj.get("executableLines")
        if isinstance(cov, (int, float)) and isinstance(lines, int) and lines > 0:
            yield name, float(cov), lines
        for value in obj.values():
            yield from walk(value)
    elif isinstance(obj, list):
        for item in obj:
            yield from walk(item)


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else "coverage-report.json"
    minimum = float(os.environ.get("COVERAGE_MIN_LINE_PERCENT", "38"))

    with open(path, encoding="utf-8") as handle:
        data = json.load(handle)

    candidates: list[tuple[str, float, int]] = []
    for name, cov, lines in walk(data):
        if "ThenToday" not in name:
            continue
        if "Tests" in name or "UITests" in name:
            continue
        if name.endswith(".xctest"):
            continue
        candidates.append((name, cov, lines))

    if not candidates:
        print("coverage_gate: no ThenToday app target found in xccov JSON", file=sys.stderr)
        return 1

    # Prefer the bundle with the most executable lines (main app).
    name, frac, lines = max(candidates, key=lambda item: item[2])
    pct = frac * 100.0
    print(f"coverage_gate: target={name!r} lines={lines} coverage={pct:.2f}% (min {minimum:.2f}%)")

    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as summary:
            summary.write("### Coverage gate\n\n")
            summary.write(f"- **Target:** `{name}`\n")
            summary.write(f"- **Line coverage:** {pct:.2f}% (minimum {minimum:.2f}%)\n")

    if pct + 1e-6 < minimum:
        print("coverage_gate: FAILED — raise tests or adjust COVERAGE_MIN_LINE_PERCENT", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
