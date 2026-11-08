#!/usr/bin/env bash
# Run the current STAGING build (the rolling `staging` pre-release published by
# .github/workflows/staging.yml from main).
#   tools/run-staging.sh            download web build → serve at http://127.0.0.1:8060
#   tools/run-staging.sh apk        download Android staging APK → adb install -r (phone in USB debugging)
#   tools/run-staging.sh info       show which commit/version staging is on
# Needs: gh (logged in with access to the repo), python3; adb for `apk`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="${GAME_REPO:-$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo hieuphung41/game-shit)}"
CACHE="$ROOT/build/staging-download"
MODE="${1:-web}"

case "$MODE" in
  info)
    gh release view staging --repo "$REPO" --json name,publishedAt,targetCommitish,url \
      -q '"\(.name)\npublished: \(.publishedAt)\ncommit: \(.targetCommitish)\n\(.url)"'
    ;;
  web)
    rm -rf "$CACHE/web" && mkdir -p "$CACHE/web"
    gh release download staging --repo "$REPO" --pattern 'web-staging.zip' --dir "$CACHE" --clobber
    (cd "$CACHE/web" && python3 -m zipfile -e ../web-staging.zip .)
    exec python3 "$ROOT/tools/serve_web.py" "$CACHE/web" "${PORT:-8060}"
    ;;
  apk)
    mkdir -p "$CACHE"
    gh release download staging --repo "$REPO" --pattern '*.apk' --dir "$CACHE" --clobber
    shopt -s nullglob
    apks=("$CACHE"/*.apk)
    (( ${#apks[@]} == 1 )) || { echo "expected exactly one staging APK, found ${#apks[@]}" >&2; exit 1; }
    adb install -r "${apks[0]}"
    ;;
  *) echo "usage: $0 [web|apk|info]" >&2; exit 2 ;;
esac
