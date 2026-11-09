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
ZONE_A_ARGS=(--path "$ROOT/game" --rendering-driver opengl3 --resolution 1280x720 --scene res://src/world/zone_a_outer_pier.tscn -- "--capture-zone-a=$OUT_DIR")
ZONE_B_ARGS=(--path "$ROOT/game" --rendering-driver opengl3 --resolution 1280x720 --scene res://src/world/zone_b_flooded_market.tscn -- "--capture-zone-b=$OUT_DIR")
ZONE_D_ARGS=(--path "$ROOT/game" --rendering-driver opengl3 --resolution 1280x720 --scene res://src/world/zone_d_floating_warehouse.tscn -- "--capture-zone-d=$OUT_DIR")
HUD_SCENE="res://src/lookdev/ui_hud_capture.tscn"
HUD_RESOLUTIONS=(1280x720 2400x1080 1024x768 1367x720 1280x960)

if [[ -n "${DISPLAY:-}" ]]; then
	timeout 90 "$GODOT" "${ARGS[@]}"
	timeout 90 "$GODOT" "${ZONE_A_ARGS[@]}"
	timeout 90 "$GODOT" "${ZONE_B_ARGS[@]}"
	timeout 90 "$GODOT" "${ZONE_D_ARGS[@]}"
	for resolution in "${HUD_RESOLUTIONS[@]}"; do
		timeout 90 "$GODOT" --path "$ROOT/game" --rendering-driver opengl3 --resolution "$resolution" --scene "$HUD_SCENE" -- "--capture-ui-hud=$OUT_DIR" "--capture-ui-size=$resolution"
	done
elif command -v xvfb-run >/dev/null 2>&1; then
	timeout 90 xvfb-run -a "$GODOT" "${ARGS[@]}"
	timeout 90 xvfb-run -a "$GODOT" "${ZONE_A_ARGS[@]}"
	timeout 90 xvfb-run -a "$GODOT" "${ZONE_B_ARGS[@]}"
	timeout 90 xvfb-run -a "$GODOT" "${ZONE_D_ARGS[@]}"
	for resolution in "${HUD_RESOLUTIONS[@]}"; do
		timeout 90 xvfb-run -a "$GODOT" --path "$ROOT/game" --rendering-driver opengl3 --resolution "$resolution" --scene "$HUD_SCENE" -- "--capture-ui-hud=$OUT_DIR" "--capture-ui-size=$resolution"
	done
else
	echo "lookdev needs DISPLAY or xvfb-run" >&2
	exit 2
fi

for image in lookdev_game.png lookdev_gray.png lookdev_phone.png lookdev_detail.png zone_a_game.png zone_a_gray.png zone_a_phone.png zone_b_game.png zone_b_gray.png zone_b_phone.png zone_b_route_d_game.png zone_b_route_d_gray.png zone_b_route_d_phone.png zone_d_game.png zone_d_gray.png zone_d_phone.png zone_b_route_d_closed_game.png zone_b_route_d_closed_phone.png zone_b_route_d_open_game.png zone_b_route_d_open_phone.png ui_hud_1280x720.png ui_hud_2400x1080.png ui_hud_1024x768.png ui_hud_1367x720.png ui_hud_1280x960.png; do
	if [[ ! -s "$OUT_DIR/$image" ]]; then
		echo "lookdev capture missing or empty: $OUT_DIR/$image" >&2
		exit 1
	fi
done

for resolution in "${HUD_RESOLUTIONS[@]}"; do
	for state in s7 s8 s8_paused s9 danger warning_status_low_health prompt inventory_overlay depleted; do
		if [[ ! -s "$OUT_DIR/ui_hud_${state}_${resolution}.png" ]]; then
			echo "lookdev capture missing or empty: $OUT_DIR/ui_hud_${state}_${resolution}.png" >&2
			exit 1
		fi
	done
done

python3 "$ROOT/tools/lookdev_probe.py" "$OUT_DIR/probe-raw.json" "$OUT_DIR/probe.json"
python3 "$ROOT/tools/lookdev_probe.py" "$OUT_DIR/zone_a_probe-raw.json" "$OUT_DIR/zone_a_probe.json"
python3 "$ROOT/tools/lookdev_probe.py" "$OUT_DIR/zone_b_probe-raw.json" "$OUT_DIR/zone_b_probe.json"
python3 "$ROOT/tools/lookdev_probe.py" "$OUT_DIR/zone_d_probe-raw.json" "$OUT_DIR/zone_d_probe.json"

echo "lookdev captures written to $OUT_DIR"
