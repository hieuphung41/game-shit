#!/usr/bin/env python3
"""Validate camera-projected look-dev colour samples with CIE76 delta E."""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path


def srgb_channel_to_linear(channel: float) -> float:
    channel /= 255.0
    return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4


def hex_to_lab(value: str) -> tuple[float, float, float]:
    red, green, blue = (int(value[index : index + 2], 16) for index in (1, 3, 5))
    r, g, b = (srgb_channel_to_linear(channel) for channel in (red, green, blue))
    x = (r * 0.4124 + g * 0.3576 + b * 0.1805) / 0.95047
    y = r * 0.2126 + g * 0.7152 + b * 0.0722
    z = (r * 0.0193 + g * 0.1192 + b * 0.9505) / 1.08883

    def lab_curve(component: float) -> float:
        return component ** (1.0 / 3.0) if component > 0.008856 else 7.787 * component + 16.0 / 116.0

    fx, fy, fz = (lab_curve(component) for component in (x, y, z))
    return 116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz)


def delta_e76(first: str, second: str) -> float:
    first_lab = hex_to_lab(first)
    second_lab = hex_to_lab(second)
    return math.sqrt(sum((left - right) ** 2 for left, right in zip(first_lab, second_lab)))


def main(raw_path: Path, output_path: Path) -> int:
    payload = json.loads(raw_path.read_text(encoding="utf-8"))
    samples = payload.get("samples", [])
    valid = True
    print("vật liệu · màu đo · màu mong đợi · ΔE76")
    for sample in samples:
        projected = sample.get("projected", False)
        occluded = sample.get("occluded", False)
        expected = sample.get("expected", "")
        measured = sample.get("measured", "")
        available = projected and not occluded
        delta = delta_e76(measured, expected) if available and len(expected) == 7 else float("inf")
        sample["delta_e76"] = round(delta, 3) if math.isfinite(delta) else None
        sample["passed"] = bool(available and delta <= float(sample.get("tolerance", 0.0)))
        valid = valid and sample["passed"]
        delta_text = f"{delta:.2f}" if math.isfinite(delta) else ("occluded" if occluded else "projection error")
        print(f"{sample.get('name')} · {measured} · {expected} · {delta_text}")
    payload["passed"] = valid
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return 0 if valid else 1


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit("usage: lookdev_probe.py <probe-raw.json> <probe.json>")
    raise SystemExit(main(Path(sys.argv[1]), Path(sys.argv[2])))
