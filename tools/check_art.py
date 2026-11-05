#!/usr/bin/env python3
"""Art Bible gate — enforces the measurable rules of docs/art/ART_BIBLE.md.

Usage: check_art.py [repo_root]        exit 0 = clean, 1 = violations, 2 = setup error

Rules checked (ids match ART_BIBLE.md):
  MAT-01 metallic/clearcoat/anisotropy/ORM PBR   MAT-02 roughness < 0.85 (non-_wet) / subsurface
  MAT-03 specular not disabled                    MAT-04 rim light
  MAT-05 emission outside signal_/light_          MAT-06 normal/detail/height maps
  MAT-07 shaders outside game/art/shaders or without specular_disabled|specular_toon|unshaded
  MAT-08 flat albedo/emission colour not in the palette
  ENV-01 glow/DOF/SSAO/SSR/SSIL/SDFGI/volumetric fog   ENV-02 tonemap not linear / auto exposure
  TEX-01 pixels outside palette lane   TEX-02 too many unique colours   TEX-03 format/size
  SRC-01 asset without manifest entry  SRC-02 incomplete provenance     SRC-03 third-party source without LICENSE
  PRM-01 prompt card LOCK blocks edited   PRM-02 banned phrases / artist names in prompts or briefs
Stdlib only; uses Pillow for speed when installed.
"""
from __future__ import annotations

import fnmatch
import json
import os
import re
import struct
import sys
import zlib
from collections import Counter
from pathlib import Path

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
GAME = ROOT / "game"
ASSETS = GAME / "assets"
SHADER_DIR = GAME / "art" / "shaders"
PALETTE_FILE = GAME / "art" / "palette.json"
MANIFEST_FILE = ROOT / "docs" / "art" / "asset-manifest.json"
PROMPTS = ROOT / "docs" / "art" / "prompts"
BRIEFS = ROOT / "docs" / "art" / "briefs"
PROMPT_TEMPLATE = ROOT / "docs" / "art" / "templates" / "prompt-card.md"
ART_SOURCE = ROOT / "art_source"

IGNORED_SUFFIXES = {".import", ".uid", ".md"}
IGNORED_NAMES = {".gdignore", "LICENSE", "LICENSE.txt", "License.txt"}
RASTER_OK = {".png"}
RASTER_BANNED = {".jpg", ".jpeg", ".webp", ".bmp", ".tga", ".exr", ".hdr"}
BANNED_PHRASES = [
    "trending on artstation", "artstation", "octane", "unreal engine", "ue5", "redshift", "blender render",
    "8k", "4k", "hdr", "hyperrealistic", "hyper-realistic", "photorealistic", "ultra detailed",
    "ultra-detailed", "highly detailed", "masterpiece", "best quality", "cinematic", "volumetric",
    "in the style of", "style of", "ghibli", "pixar", "disney", "dreamworks",
]
ARTIST_PATTERN = re.compile(r"\bby\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)+")

violations: list[tuple[str, str, str]] = []


def flag(rule: str, path: Path | str, msg: str) -> None:
    rel = str(path.relative_to(ROOT)) if isinstance(path, Path) and path.is_absolute() else str(path)
    violations.append((rule, rel, msg))


# --------------------------------------------------------------------------- colour
def hex_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def rgb_to_lab(rgb: tuple[int, int, int]) -> tuple[float, float, float]:
    def lin(c: float) -> float:
        c /= 255.0
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = (lin(c) for c in rgb)
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883

    def f(t: float) -> float:
        return t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = f(x), f(y), f(z)
    return 116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)


def delta_e(a, b) -> float:
    return ((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2) ** 0.5


class Palette:
    def __init__(self, data: dict):
        self.rules = data["rules"]
        self.lanes = {lane: [rgb_to_lab(hex_rgb(h)) for h in colours.values()]
                      for lane, colours in data["lanes"].items()}
        self.all = [lab for labs in self.lanes.values() for lab in labs]

    def nearest(self, rgb, lanes=None) -> float:
        labs = self.all if not lanes else [lab for ln in lanes for lab in self.lanes.get(ln, [])]
        lab = rgb_to_lab(rgb)
        return min(delta_e(lab, p) for p in labs)


# --------------------------------------------------------------------------- PNG (stdlib)
def read_png(path: Path) -> tuple[int, int, Counter]:
    """Return (width, height, Counter of opaque-ish RGB colours)."""
    if not os.environ.get("CHECK_ART_NO_PIL"):
        try:
            from PIL import Image  # type: ignore
            with Image.open(path) as im:
                w, h = im.size
                rgba = im.convert("RGBA")
                counts = Counter((r, g, b) for r, g, b, a in rgba.getdata() if a > 0)
                return w, h, counts
        except ImportError:
            pass
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    pos, idat, plte, trns = 8, b"", None, None
    width = height = depth = ctype = interlace = 0
    while pos < len(data):
        length, kind = struct.unpack(">I4s", data[pos:pos + 8])
        chunk = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b"IHDR":
            width, height, depth, ctype, _, _, interlace = struct.unpack(">IIBBBBB", chunk)
        elif kind == b"PLTE":
            plte = [tuple(chunk[i:i + 3]) for i in range(0, len(chunk), 3)]
        elif kind == b"tRNS":
            trns = chunk
        elif kind == b"IDAT":
            idat += chunk
        elif kind == b"IEND":
            break
    if depth != 8 or interlace:
        raise ValueError(f"needs 8-bit non-interlaced PNG (bit depth {depth}, interlace {interlace})")
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ctype]
    stride = width * channels
    raw = zlib.decompress(idat)
    rows, prev = [], bytearray(stride)
    for y in range(height):
        ftype = raw[y * (stride + 1)]
        line = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        for i in range(stride):
            a = line[i - channels] if i >= channels else 0
            b = prev[i]
            c = prev[i - channels] if i >= channels else 0
            if ftype == 1:
                line[i] = (line[i] + a) & 255
            elif ftype == 2:
                line[i] = (line[i] + b) & 255
            elif ftype == 3:
                line[i] = (line[i] + ((a + b) >> 1)) & 255
            elif ftype == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(line)
        prev = line
    counts: Counter = Counter()
    for line in rows:
        for x in range(width):
            px = line[x * channels:(x + 1) * channels]
            if ctype == 6:
                if px[3]:
                    counts[(px[0], px[1], px[2])] += 1
            elif ctype == 2:
                counts[(px[0], px[1], px[2])] += 1
            elif ctype == 0:
                counts[(px[0], px[0], px[0])] += 1
            elif ctype == 4:
                if px[1]:
                    counts[(px[0], px[0], px[0])] += 1
            else:
                idx = px[0]
                if trns is not None and idx < len(trns) and trns[idx] == 0:
                    continue
                counts[plte[idx]] += 1
    return width, height, counts


# --------------------------------------------------------------------------- manifest / sources
def load_manifest() -> list[dict]:
    if not MANIFEST_FILE.exists():
        return []
    return json.loads(MANIFEST_FILE.read_text(encoding="utf-8")).get("assets", [])


def entry_for(rel: str, entries: list[dict]) -> dict | None:
    for e in entries:
        if e.get("path") == rel or fnmatch.fnmatch(rel, e.get("path", "")):
            return e
    return None


def check_sources(entries: list[dict]) -> None:
    for e in entries:
        src = e.get("source", {})
        where = f"manifest:{e.get('id', '?')}"
        if src.get("kind") not in ("authored", "third_party", "generated"):
            flag("SRC-02", where, "source.kind must be authored | third_party | generated")
        if not src.get("license"):
            flag("SRC-02", where, "source.license is empty")
        if src.get("kind") == "third_party" and not src.get("url_or_tool"):
            flag("SRC-02", where, "third_party asset needs source.url_or_tool")
        if src.get("kind") == "generated":
            card = src.get("prompt_card", "")
            if not card or not (ROOT / card).exists():
                flag("SRC-02", where, "generated asset needs an existing source.prompt_card")
            if src.get("normalized") is not True:
                flag("SRC-02", where, "generated asset must be normalized (ART_BIBLE §8) before use")
    if ART_SOURCE.exists():
        for pack in sorted((ART_SOURCE / "third_party").glob("*/")):
            if not any(p.name.lower().startswith("license") for p in pack.iterdir()):
                flag("SRC-03", pack, "third-party source pack has no LICENSE file")


def check_assets(palette: Palette, entries: list[dict]) -> int:
    count = 0
    if not ASSETS.exists():
        return 0
    rules = palette.rules
    for path in sorted(p for p in ASSETS.rglob("*") if p.is_file()):
        if path.suffix in IGNORED_SUFFIXES or path.name in IGNORED_NAMES:
            continue
        count += 1
        rel = str(path.relative_to(ROOT))
        entry = entry_for(rel, entries)
        if entry is None:
            flag("SRC-01", path, "no entry in docs/art/asset-manifest.json")
        suffix = path.suffix.lower()
        if suffix in RASTER_BANNED:
            flag("TEX-03", path, f"{suffix} not allowed in game/assets — use 8-bit PNG")
            continue
        if suffix not in RASTER_OK:
            continue
        if re.search(r"(_normal|_nrm|_height|_detail)\b", path.stem, re.I):
            flag("MAT-06", path, "normal/height/detail maps are not part of this style")
        try:
            w, h, counts = read_png(path)
        except (ValueError, zlib.error, struct.error, KeyError) as exc:
            flag("TEX-03", path, f"unreadable PNG: {exc}")
            continue
        if w > rules["max_texture_size"] or h > rules["max_texture_size"] or w & (w - 1) or h & (h - 1):
            flag("TEX-03", path, f"{w}x{h}: edges must be powers of two and ≤ {rules['max_texture_size']}")
        total = sum(counts.values())
        if not total:
            continue
        if len(counts) > rules["max_unique_colors"]:
            flag("TEX-02", path, f"{len(counts)} unique colours > {rules['max_unique_colors']} "
                                 "(gradient/airbrush/noise — quantize to the palette)")
        lanes = (entry or {}).get("lane") or ["env"]
        lanes = [lanes] if isinstance(lanes, str) else lanes
        inside = sum(n for rgb, n in counts.items() if palette.nearest(rgb, lanes) <= rules["delta_e_tolerance"])
        ratio = inside / total
        if ratio < rules["min_in_palette_ratio"]:
            flag("TEX-01", path, f"only {ratio:.1%} of pixels within ΔE {rules['delta_e_tolerance']} of lane(s) "
                                 f"{'/'.join(lanes)} (need {rules['min_in_palette_ratio']:.0%})")
    return count


# --------------------------------------------------------------------------- Godot resources
SECTION = re.compile(r"^\[(\w+)([^\]]*)\]\s*$")
ATTR = re.compile(r'(\w+)="([^"]*)"')
PROP = re.compile(r"^([\w/]+)\s*=\s*(.+)$")
COLOR = re.compile(r"Color\(\s*([\d.e+-]+)\s*,\s*([\d.e+-]+)\s*,\s*([\d.e+-]+)")


def sections(text: str):
    """Yield (kind, attrs, props) for each [section] of a .tres/.tscn file."""
    current = None
    for line in text.splitlines():
        m = SECTION.match(line)
        if m:
            if current:
                yield current
            current = (m.group(1), dict(ATTR.findall(m.group(2))), {})
            continue
        if current:
            p = PROP.match(line)
            if p:
                current[2][p.group(1)] = p.group(2).strip()
    if current:
        yield current


def as_float(value: str | None, default: float) -> float:
    try:
        return float(value) if value is not None else default
    except ValueError:
        return default


def check_material(name: str, props: dict, where: Path, palette: Palette, ext: dict, kind: str) -> None:
    wet = "_wet" in name
    tag = f"{where.relative_to(ROOT)} [{name or kind}]"
    if kind == "ORMMaterial3D":
        flag("MAT-01", tag, "ORMMaterial3D is PBR — use the matte library materials")
        return
    if kind == "ShaderMaterial":
        ref = props.get("shader", "")
        m = re.search(r'ExtResource\("([^"]+)"\)', ref)
        target = ext.get(m.group(1), "") if m else ""
        if "SubResource" in ref or (target and not target.startswith("res://art/shaders/")):
            flag("MAT-07", tag, f"shader must be a file in game/art/shaders/ (got {target or 'inline shader'})")
        return
    if as_float(props.get("metallic"), 0.0) > 0:
        flag("MAT-01", tag, "metallic must be 0 — paint metal with palette colours")
    for gloss in ("clearcoat_enabled", "anisotropy_enabled"):
        if props.get(gloss) == "true":
            flag("MAT-01", tag, f"{gloss} adds PBR gloss")
    if props.get("subsurf_scatter_enabled") == "true":
        flag("MAT-02", tag, "subsurface scattering gives the waxy AI look")
    unshaded = props.get("shading_mode") == "0"
    if not unshaded:
        if as_float(props.get("roughness"), 1.0) < 0.85 and not wet:
            flag("MAT-02", tag, f"roughness {props.get('roughness')} < 0.85 (only *_wet materials may be glossier)")
        spec = props.get("specular_mode", "0")
        if not (spec == "2" or (spec == "1" and wet)):
            flag("MAT-03", tag, "set specular_mode = 2 (disabled); toon (1) only for *_wet")
    if props.get("rim_enabled") == "true":
        flag("MAT-04", tag, "rim light is banned (AI-04)")
    if props.get("emission_enabled") == "true" and not name.startswith(("signal_", "light_")):
        flag("MAT-05", tag, "emission only for signal_* or light_* materials")
    for mapping in ("normal_enabled", "detail_enabled", "heightmap_enabled"):
        if props.get(mapping) == "true":
            flag("MAT-06", tag, f"{mapping} — no micro-detail maps in this style")
    for key in ("albedo_color", "emission"):
        m = COLOR.search(props.get(key, ""))
        if not m:
            continue
        rgb = tuple(round(max(0.0, min(1.0, float(c))) * 255) for c in m.groups())
        if key == "albedo_color" and rgb == (255, 255, 255) and props.get("albedo_texture"):
            continue
        if palette.nearest(rgb) > palette.rules["delta_e_tolerance"]:
            flag("MAT-08", tag, f"{key} #{''.join(f'{c:02X}' for c in rgb)} is not a palette colour")


def check_environment(props: dict, tag: str, kind: str) -> None:
    banned = ["glow_enabled", "ssao_enabled", "ssr_enabled", "ssil_enabled", "sdfgi_enabled",
              "volumetric_fog_enabled", "dof_blur_far_enabled", "dof_blur_near_enabled"]
    for key in banned:
        if props.get(key) == "true":
            flag("ENV-01", f"{tag} [{kind}]", f"{key} is banned (cinematic post-processing)")
    if props.get("tonemap_mode", "0") != "0":
        flag("ENV-02", f"{tag} [{kind}]", "tonemap must be linear (0) so palette colours stay exact")
    if props.get("auto_exposure_enabled") == "true":
        flag("ENV-02", f"{tag} [{kind}]", "auto exposure shifts palette colours")


def check_resources(palette: Palette) -> int:
    count = 0
    for path in sorted(list(GAME.rglob("*.tres")) + list(GAME.rglob("*.tscn"))):
        if ".godot" in path.parts:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        ext, file_type = {}, None
        for kind, attrs, props in sections(text):
            if kind == "gd_resource":
                file_type = attrs.get("type")
            elif kind == "ext_resource":
                ext[attrs.get("id", "")] = attrs.get("path", "")
            rtype = file_type if kind == "resource" else attrs.get("type") if kind == "sub_resource" else None
            if rtype is None:
                continue
            name = props.get("resource_name", "").strip('"') or (path.stem if kind == "resource" else "")
            if rtype in ("StandardMaterial3D", "ORMMaterial3D", "ShaderMaterial"):
                count += 1
                check_material(name, props, path, palette, ext, rtype)
            elif rtype in ("Environment", "CameraAttributesPractical", "CameraAttributesPhysical"):
                check_environment(props, str(path.relative_to(ROOT)), rtype)
            elif rtype == "Shader":
                flag("MAT-07", path, "inline Shader sub-resource — move it to game/art/shaders/*.gdshader")
    return count


def check_shaders() -> None:
    for path in sorted(GAME.rglob("*.gdshader")):
        if ".godot" in path.parts:
            continue
        if SHADER_DIR not in path.parents:
            flag("MAT-07", path, "shaders live only in game/art/shaders/")
        text = path.read_text(encoding="utf-8", errors="replace")
        if re.search(r"shader_type\s+spatial", text):
            modes = " ".join(re.findall(r"render_mode\s+([^;]+);", text))
            if not re.search(r"\b(specular_disabled|specular_toon|unshaded)\b", modes):
                flag("MAT-07", path, "spatial shader needs render_mode specular_disabled | specular_toon | unshaded")


# --------------------------------------------------------------------------- prompts
LOCK = re.compile(r"<!-- (STYLE|NEGATIVE)-LOCK v1 BEGIN -->(.*?)<!-- \1-LOCK v1 END -->", re.S)


def locks(text: str) -> dict[str, str]:
    return {m.group(1): " ".join(m.group(2).split()) for m in LOCK.finditer(text)}


def check_prompts() -> None:
    reference = locks(PROMPT_TEMPLATE.read_text(encoding="utf-8")) if PROMPT_TEMPLATE.exists() else {}
    for folder, need_locks in ((PROMPTS, True), (BRIEFS, False)):
        if not folder.exists():
            continue
        for path in sorted(folder.glob("*.md")):
            if path.name == "README.md":
                continue
            text = path.read_text(encoding="utf-8")
            if need_locks:
                found = locks(text)
                for block in ("STYLE", "NEGATIVE"):
                    if found.get(block) != reference.get(block):
                        flag("PRM-01", path, f"{block}-LOCK block missing or edited — copy it from templates/prompt-card.md")
            free = LOCK.sub("", text)
            low = free.lower()
            for phrase in BANNED_PHRASES:
                if re.search(rf"(?<![\w-]){re.escape(phrase)}(?![\w-])", low):
                    flag("PRM-02", path, f"banned phrase '{phrase}'")
            for m in ARTIST_PATTERN.finditer(free):
                flag("PRM-02", path, f"possible artist/studio name '{m.group(0)}' — describe properties instead")


# --------------------------------------------------------------------------- main
def main() -> int:
    if not PALETTE_FILE.exists():
        print(f"setup error: {PALETTE_FILE} missing", file=sys.stderr)
        return 2
    palette = Palette(json.loads(PALETTE_FILE.read_text(encoding="utf-8")))
    entries = load_manifest()
    check_sources(entries)
    n_assets = check_assets(palette, entries)
    n_mats = check_resources(palette)
    check_shaders()
    check_prompts()
    for rule, where, msg in sorted(violations):
        print(f"{rule}  {where}: {msg}")
    print(f"art: {n_assets} asset files, {n_mats} materials checked, {len(violations)} violation(s)")
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main())
