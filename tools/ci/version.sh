#!/usr/bin/env bash
# Print the game version from game/project.godot (application/config/version).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
sed -n 's/^config\/version="\([^"]*\)"/\1/p' "$ROOT/game/project.godot"
