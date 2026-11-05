#!/usr/bin/env python3
"""Fail if a Markdown file links to a relative path that does not exist.

Usage: check_docs.py <dir-or-file>...   (stdlib only; external URLs and #anchors are skipped)
"""
import re
import sys
from pathlib import Path

LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
FENCE = re.compile(r"^(```|~~~)")


def markdown_files(args):
    for arg in args:
        p = Path(arg)
        if p.is_dir():
            yield from sorted(p.rglob("*.md"))
        elif p.suffix == ".md" and p.exists():
            yield p


def broken_links(path):
    in_fence = False
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if FENCE.match(line.strip()):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        for target in LINK.findall(line):
            if re.match(r"^[a-z][a-z0-9+.-]*:", target) or target.startswith("#"):
                continue
            rel = target.split("#", 1)[0]
            if rel and not (path.parent / rel).exists():
                yield lineno, target


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    count = files = 0
    for md in markdown_files(argv):
        files += 1
        for lineno, target in broken_links(md):
            count += 1
            print(f"{md}:{lineno}: broken link -> {target}")
    print(f"checked {files} markdown files, {count} broken links")
    return 1 if count else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
