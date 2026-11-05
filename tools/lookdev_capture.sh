#!/usr/bin/env bash
# Capture the fixed look-dev scene at review, grayscale, and phone scales.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT/build/lookdev"
GODOT="${GODOT_BIN:-}"

if [[ -z "$GODOT" ]]; then
	if command -v godot >/dev/null 2>&1; then
		GODOT="$(command -v godot)"
	elif [[ -x "$ROOT/../game-studio/tools/bin/godot" ]]; then
		GODOT="$ROOT/../game-studio/tools/bin/godot"
	else
		echo "Godot not found: set GODOT_BIN to a Godot 4.7.2 binary" >&2
		exit 2
	fi
fi

mkdir -p "$OUT_DIR"
ARGS=(--path "$ROOT/game" --rendering-driver opengl3 --resolution 1280x720 --scene res://src/lookdev/lookdev.tscn -- "--capture-dir=$OUT_DIR")

if [[ -n "${DISPLAY:-}" ]]; then
	timeout 90 "$GODOT" "${ARGS[@]}"
elif command -v xvfb-run >/dev/null 2>&1; then
	timeout 90 xvfb-run -a "$GODOT" "${ARGS[@]}"
else
	echo "lookdev needs DISPLAY or xvfb-run" >&2
	exit 2
fi

for image in lookdev_game.png lookdev_gray.png lookdev_phone.png lookdev_detail.png; do
	if [[ ! -s "$OUT_DIR/$image" ]]; then
		echo "lookdev capture missing or empty: $OUT_DIR/$image" >&2
		exit 1
	fi
done

echo "lookdev captures written to $OUT_DIR"
