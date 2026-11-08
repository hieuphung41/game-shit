#!/usr/bin/env bash
# Verify the debug-signed Android staging APK before it is published.
#   tools/ci/verify_apk.sh <apk>
set -euo pipefail

APK="${1:?usage: $0 <apk>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BUILD_INFO="${BUILD_INFO:-$ROOT/game/config/build_info.cfg}"
EXPECTED_PACKAGE="vn.hieuphung.kheuoctanvuong.staging"

# Android build-tools launch apksigner through `java`; tools/deploy.sh supplies
# JAVA_HOME, while CI usually already has Java on PATH.
if [[ -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]]; then
  export PATH="$JAVA_HOME/bin:$PATH"
fi

fail() {
  echo "APK verification failed: $*" >&2
  exit 1
}

resolve_android_tool() { # <apksigner|aapt>
  local name="$1" candidate
  if command -v "$name" >/dev/null 2>&1; then
    command -v "$name"
    return
  fi
  if [[ -n "${ANDROID_HOME:-}" ]]; then
    for candidate in "$ANDROID_HOME"/build-tools/*/"$name"; do
      if [[ -x "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return
      fi
    done
  fi
  fail "$name is not on PATH or in ANDROID_HOME/build-tools"
}

[[ -f "$APK" ]] || fail "file not found: $APK"
[[ -f "$BUILD_INFO" ]] || fail "missing build info: $BUILD_INFO"
APKSIGNER="$(resolve_android_tool apksigner)"
AAPT="$(resolve_android_tool aapt)"

EXPECTED_VERSION="$(sed -n 's/^version="\([^"]*\)"/\1/p' "$BUILD_INFO" | head -n 1)"
[[ -n "$EXPECTED_VERSION" ]] || fail "build info has no version"

CERTS="$("$APKSIGNER" verify --print-certs "$APK")" \
  || fail "apksigner could not verify the APK signature"
case "$CERTS" in
  *"certificate DN:"*"CN=Android Debug"*) ;;
  *) fail "signing certificate is not Android Debug" ;;
esac

BADGING="$("$AAPT" dump badging "$APK")" || fail "aapt could not read APK metadata"
PACKAGE="$(printf '%s\n' "$BADGING" | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -n 1)"
VERSION_NAME="$(printf '%s\n' "$BADGING" | sed -n "s/^package:.* versionName='\([^']*\)'.*/\1/p" | head -n 1)"

[[ "$PACKAGE" == "$EXPECTED_PACKAGE" ]] \
  || fail "package is '${PACKAGE:-missing}', expected '$EXPECTED_PACKAGE'"
[[ -n "$VERSION_NAME" && "$VERSION_NAME" == *"$EXPECTED_VERSION"* ]] \
  || fail "versionName is '${VERSION_NAME:-missing}', expected to contain '$EXPECTED_VERSION'"

echo "verified APK: $PACKAGE $VERSION_NAME (Android Debug)"
