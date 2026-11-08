#!/usr/bin/env bash
# Export one platform for one channel. Used by .github/workflows/_build.yml.
#   tools/ci/export.sh <web|android> <staging|production>
# Output: build/<channel>/<platform>/...
# Phase 1 ships only the staging debug APK. Android production signing is deferred
# until phase 2, after sideload testing approval.
set -euo pipefail

PLATFORM="${1:?platform}"
CHANNEL="${2:?channel}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT="${GODOT_BIN:-godot}"
OUT="$ROOT/build/$CHANNEL/$PLATFORM"
PRESET_BACKUP=""

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

set_android_staging_version() {
  local build_info="$ROOT/game/config/build_info.cfg"
  local version
  [[ -f "$build_info" ]] || { echo "missing build info: $build_info" >&2; exit 1; }
  version="$(sed -n 's/^version="\([^"]*\)"/\1/p' "$build_info" | head -n 1)"
  [[ -n "$version" && "$version" != *'"'* && "$version" != *$'\n'* ]] \
    || { echo "invalid staging version in build info" >&2; exit 1; }

  PRESET_BACKUP="$(mktemp)"
  cp "$ROOT/game/export_presets.cfg" "$PRESET_BACKUP"
  STAGING_VERSION="$version" python3 - "$ROOT/game/export_presets.cfg" <<'PY'
import os
import re
import sys

path = sys.argv[1]
text = open(path, encoding="utf-8").read()
pattern = r'(?ms)(\[preset\.2\.options\].*?^version/name=")[^"]*(")'
updated, count = re.subn(pattern, r'\g<1>' + os.environ["STAGING_VERSION"] + r'\g<2>', text)
if count != 1:
    raise SystemExit("Android Staging version/name setting not found exactly once")
open(path, "w", encoding="utf-8").write(updated)
PY
}

restore_android_staging_preset() {
  if [[ -n "$PRESET_BACKUP" ]]; then
    cp "$PRESET_BACKUP" "$ROOT/game/export_presets.cfg"
    rm -f "$PRESET_BACKUP"
    PRESET_BACKUP=""
  fi
}

case "$PLATFORM" in
  web)
    export_preset --export-release "Web $SUFFIX" "$OUT/index.html"
    ;;
  android)
    if [[ "$CHANNEL" == "staging" ]]; then
      # Debug export, signed with the debug keystore configured in the CI image.
      set_android_staging_version
      trap restore_android_staging_preset EXIT
      export_preset --export-debug "Android $SUFFIX" "$OUT/khe-uoc-tan-vuong-staging.apk"
      "$ROOT/tools/ci/verify_apk.sh" "$OUT/khe-uoc-tan-vuong-staging.apk"
      restore_android_staging_preset
      trap - EXIT
    else
      echo "::notice::Android production export is deferred until phase 2."
    fi
    ;;
  *) echo "unknown platform $PLATFORM" >&2; exit 2 ;;
esac
rm -f "$OUT/export.log"
ls -la "$OUT"
