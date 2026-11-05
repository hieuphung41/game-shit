#!/usr/bin/env bash
# Write game/config/build_info.cfg (read by AppEnv). Not committed.
#   tools/ci/write_build_info.sh <channel> <version> <commit>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cat >"$ROOT/game/config/build_info.cfg" <<EOF
[build]
channel="${1:?channel}"
version="${2:?version}"
commit="${3:?commit}"
built_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF
cat "$ROOT/game/config/build_info.cfg"
