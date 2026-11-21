#!/usr/bin/env python3
"""Append one durable, non-sensitive learning event to the skill ledger."""
from __future__ import annotations

import argparse
import datetime as dt
import re
from pathlib import Path


def normalize(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip()).casefold()


def has_secret_like_text(value: str) -> bool:
    patterns = (
        r"sk-[A-Za-z0-9]{12,}",
        r"(?:password|passwd|token|api[_ -]?key|authorization|cookie)\s*[:=]",
        r"-----BEGIN (?:RSA |OPENSSH )?PRIVATE KEY-----",
    )
    return any(re.search(pattern, value, re.I) for pattern in patterns)


def main() -> int:
    parser = argparse.ArgumentParser(description="Record a durable lizhiguang-dev learning event.")
    parser.add_argument("--scope", required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--conclusion", required=True)
    parser.add_argument("--source", required=True)
    parser.add_argument("--date", default=dt.date.today().isoformat())
    parser.add_argument("--log", type=Path, default=Path(__file__).resolve().parents[1] / "references" / "learning-log.md")
    args = parser.parse_args()

    values = (args.scope, args.title, args.conclusion, args.source)
    if any(not value.strip() for value in values):
        parser.error("scope, title, conclusion and source must not be empty")
    if any(has_secret_like_text(value) for value in values):
        parser.error("refusing to write secret-like content to the learning ledger")

    log_path = args.log.resolve()
    log_path.parent.mkdir(parents=True, exist_ok=True)
    existing = log_path.read_text(encoding="utf-8") if log_path.exists() else ""
    signature = "|".join(normalize(value) for value in (args.scope, args.title, args.conclusion))
    if f"<!-- learning-signature:{signature} -->" in existing:
        print("duplicate: learning event already recorded")
        return 0

    entry = (
        f"\n### {args.date} · {args.title}\n"
        f"<!-- learning-signature:{signature} -->\n"
        f"- 适用范围：{args.scope}\n"
        f"- 新结论：{args.conclusion}\n"
        f"- 来源：{args.source}\n"
    )
    log_path.write_text(existing.rstrip() + "\n" + entry, encoding="utf-8")
    print(f"recorded: {log_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
