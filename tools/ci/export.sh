#!/usr/bin/env bash
# Export one platform for one channel. Used by .github/workflows/_build.yml.
#   tools/ci/export.sh <web|android> <staging|production>
# Output: build/<channel>/<platform>/...
# Android production needs ANDROID_KEYSTORE_BASE64 / _ALIAS / _PASSWORD (environment
# secrets); without them the Android export is skipped with a warning.
set -euo pipefail

PLATFORM="${1:?platform}"
CHANNEL="${2:?channel}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT="${GODOT_BIN:-godot}"
OUT="$ROOT/build/$CHANNEL/$PLATFORM"

case "$CHANNEL" in
  staging) SUFFIX="Staging" ;;
  production) SUFFIX="Production" ;;
  *) echo "unknown channel $CHANNEL" >&2; exit 2 ;;
esac
mkdir -p "$OUT"

export_preset() { # <mode> <preset> <file>
  "$GODOT" --headless --path "$ROOT/game" "$1" "$2" "$3" 2>&1 | tee "$OUT/export.log"
  test -s "$3" || { echo "export produced no file: $3" >&2; exit 1; }
}

case "$PLATFORM" in
  web)
    export_preset --export-release "Web $SUFFIX" "$OUT/index.html"
    ;;
  android)
    if [[ "$CHANNEL" == "staging" ]]; then
      # Debug export, signed with the debug keystore configured in the CI image.
      export_preset --export-debug "Android $SUFFIX" "$OUT/khe-uoc-tan-vuong-staging.apk"
    else
      if [[ -z "${ANDROID_KEYSTORE_BASE64:-}" ]]; then
        echo "::warning::ANDROID_KEYSTORE_BASE64 not set on the production environment — Android release skipped."
        exit 0
      fi
      KS="${RUNNER_TEMP:-/tmp}/release.keystore"
      echo "$ANDROID_KEYSTORE_BASE64" | base64 -d >"$KS"
      export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$KS"
      export GODOT_ANDROID_KEYSTORE_RELEASE_USER="${ANDROID_KEYSTORE_ALIAS:?}"
      export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="${ANDROID_KEYSTORE_PASSWORD:?}"
      export_preset --export-release "Android $SUFFIX" "$OUT/khe-uoc-tan-vuong.apk"
      rm -f "$KS"
    fi
    ;;
  *) echo "unknown platform $PLATFORM" >&2; exit 2 ;;
esac
rm -f "$OUT/export.log"
ls -la "$OUT"
