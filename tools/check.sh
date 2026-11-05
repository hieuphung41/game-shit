#!/usr/bin/env bash
# Quality gate shared by local runs, studio workers and CI.
#   tools/check.sh              docs links + Godot import + unit tests + main-scene smoke run
#   tools/check.sh --skip-docs  Godot part only
#   tools/check.sh --docs-only  docs part only
# Godot binary: $GODOT_BIN, else `godot` on PATH (Godot 4.7.2).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT="${GODOT_BIN:-godot}"
RUN_DOCS=1
RUN_GODOT=1
case "${1:-}" in
  --skip-docs) RUN_DOCS=0 ;;
  --docs-only) RUN_GODOT=0 ;;
  "") ;;
  *) echo "usage: $0 [--skip-docs|--docs-only]" >&2; exit 2 ;;
esac

step() { printf '\n== %s\n' "$*"; }
LOG_DIR="$(mktemp -d)"
trap 'rm -rf "$LOG_DIR"' EXIT

if [[ $RUN_DOCS == 1 ]]; then
  step "docs: relative links"
  python3 "$ROOT/tools/check_docs.py" "$ROOT/docs" "$ROOT/README.md" "$ROOT/AGENTS.md"
fi

if [[ $RUN_GODOT == 1 ]]; then
  command -v "$GODOT" >/dev/null 2>&1 || { echo "Godot not found: set GODOT_BIN" >&2; exit 2; }
  step "godot: version"
  "$GODOT" --headless --version

  step "godot: import"
  "$GODOT" --headless --path "$ROOT/game" --import >"$LOG_DIR/import.log" 2>&1 || { cat "$LOG_DIR/import.log"; exit 1; }
  if grep -E "SCRIPT ERROR|Parse Error|Failed to load" "$LOG_DIR/import.log"; then
    echo "import reported errors" >&2; exit 1
  fi

  step "godot: unit tests"
  timeout 300 "$GODOT" --headless --path "$ROOT/game" --script res://tests/run_tests.gd

  step "godot: main scene smoke run (120 frames)"
  timeout 120 "$GODOT" --headless --path "$ROOT/game" --quit-after 120 >"$LOG_DIR/smoke.log" 2>&1 || { cat "$LOG_DIR/smoke.log"; exit 1; }
  if grep -E "SCRIPT ERROR|ERROR:" "$LOG_DIR/smoke.log"; then
    echo "smoke run reported errors" >&2; exit 1
  fi
  echo "smoke run clean"
fi

step "all checks passed"
