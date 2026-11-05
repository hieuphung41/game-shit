"""Tests for tools/check_art.py — one violating and one clean case per rule family.

Run: python3 -m unittest discover -s tools/tests -v
"""
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest
import zlib
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CHECK = REPO / "tools" / "check_art.py"
MATTE = 'specular_mode = 2\nroughness = 1.0\nalbedo_color = Color(0.482, 0.357, 0.251, 1)\n'  # wood #7B5B40


def png_bytes(width, height, pixel, filter_type=0):
    """8-bit RGBA PNG; pixel(x, y) -> (r, g, b, a). filter_type 0 (None) or 4 (Paeth) to exercise the decoder."""
    rows, prev = [], bytes(width * 4)
    for y in range(height):
        line = bytes(c for x in range(width) for c in pixel(x, y))
        if filter_type == 4:
            enc = bytearray()
            for i, v in enumerate(line):
                a = line[i - 4] if i >= 4 else 0
                b = prev[i]
                c = prev[i - 4] if i >= 4 else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if pa <= pb and pa <= pc else b if pb <= pc else c
                enc.append((v - pred) & 255)
            rows.append(b"\x04" + bytes(enc))
        else:
            rows.append(b"\x00" + line)
        prev = line

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(b"".join(rows)))
            + chunk(b"IEND", b""))


class CheckArtTest(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        (self.tmp / "game/art").mkdir(parents=True)
        (self.tmp / "game/assets").mkdir(parents=True)
        (self.tmp / "docs/art/templates").mkdir(parents=True)
        (self.tmp / "docs/art/prompts").mkdir(parents=True)
        shutil.copy(REPO / "game/art/palette.json", self.tmp / "game/art/palette.json")
        shutil.copy(REPO / "docs/art/templates/prompt-card.md", self.tmp / "docs/art/templates/prompt-card.md")
        self.manifest([])

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def manifest(self, assets):
        (self.tmp / "docs/art/asset-manifest.json").write_text(json.dumps({"schema_version": 1, "assets": assets}))

    def entry(self, path, kind="authored", lane="env", **src):
        return {"id": Path(path).stem, "path": path, "lane": lane,
                "source": {"kind": kind, "license": "project", "url_or_tool": "test", **src}}

    def write(self, rel, content):
        p = self.tmp / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        (p.write_bytes if isinstance(content, bytes) else p.write_text)(content)
        return p

    def run_check(self, no_pil=False):
        env = dict(os.environ, CHECK_ART_NO_PIL="1") if no_pil else None
        r = subprocess.run([sys.executable, str(CHECK), str(self.tmp)], capture_output=True, text=True, env=env)
        rules = {line.split()[0] for line in r.stdout.splitlines() if line[:4].isupper() and "-" in line[:7]}
        return r.returncode, rules, r.stdout

    # ---- clean baseline
    def test_empty_project_passes(self):
        code, rules, out = self.run_check()
        self.assertEqual(code, 0, out)
        self.assertEqual(rules, set())

    # ---- materials
    def test_glossy_default_material_fails(self):
        self.write("game/art/materials/crate.tres",
                   '[gd_resource type="StandardMaterial3D" format=3]\n\n[resource]\nmetallic = 0.6\nroughness = 0.3\n')
        code, rules, out = self.run_check()
        self.assertEqual(code, 1)
        self.assertTrue({"MAT-01", "MAT-02", "MAT-03"} <= rules, out)

    def test_matte_palette_material_passes(self):
        self.write("game/art/materials/wood.tres", f'[gd_resource type="StandardMaterial3D" format=3]\n\n[resource]\n{MATTE}')
        code, rules, out = self.run_check()
        self.assertEqual(code, 0, out)

    def test_wet_material_may_use_toon_specular(self):
        self.write("game/art/materials/stone_wet.tres",
                   '[gd_resource type="StandardMaterial3D" format=3]\n\n[resource]\nspecular_mode = 1\nroughness = 0.6\n'
                   'albedo_color = Color(0.294, 0.286, 0.271, 1)\n')
        self.assertEqual(self.run_check()[0], 0)

    def test_emission_only_for_signal_and_light(self):
        self.write("game/src/a.tscn",
                   '[gd_scene format=3]\n\n[sub_resource type="StandardMaterial3D" id="1"]\nresource_name = "crate"\n'
                   f'{MATTE}emission_enabled = true\n\n[sub_resource type="StandardMaterial3D" id="2"]\n'
                   f'resource_name = "signal_beacon"\n{MATTE}emission_enabled = true\n')
        code, rules, out = self.run_check()
        self.assertEqual(rules, {"MAT-05"}, out)
        self.assertEqual(out.count("MAT-05"), 1, out)

    def test_off_palette_colour_and_rim_and_normal_map(self):
        self.write("game/src/b.tscn",
                   '[gd_scene format=3]\n\n[sub_resource type="StandardMaterial3D" id="1"]\nspecular_mode = 2\n'
                   'albedo_color = Color(0.0, 0.8, 0.8, 1)\nrim_enabled = true\nnormal_enabled = true\n')
        code, rules, out = self.run_check()
        self.assertTrue({"MAT-08", "MAT-04", "MAT-06"} <= rules, out)

    def test_shader_rules(self):
        self.write("game/src/fx/bad.gdshader", "shader_type spatial;\nvoid fragment() { ALBEDO = vec3(1.0); }\n")
        self.write("game/art/shaders/toon.gdshader", "shader_type spatial;\nrender_mode specular_disabled;\n")
        self.write("game/src/c.tscn", '[gd_scene format=3]\n\n[sub_resource type="Shader" id="1"]\ncode = "x"\n')
        code, rules, out = self.run_check()
        self.assertEqual(rules, {"MAT-07"}, out)
        self.assertEqual(out.count("MAT-07"), 3, out)  # outside dir + missing render_mode + inline

    # ---- environment
    def test_cinematic_post_processing_fails(self):
        self.write("game/src/env.tres",
                   '[gd_resource type="Environment" format=3]\n\n[resource]\nglow_enabled = true\ntonemap_mode = 3\n')
        code, rules, out = self.run_check()
        self.assertEqual(rules, {"ENV-01", "ENV-02"}, out)

    # ---- textures
    def test_gradient_texture_fails_palette_and_colour_count(self):
        self.write("game/assets/env/wall.png", png_bytes(64, 64, lambda x, y: (x * 4, y * 4, 128, 255)))
        self.manifest([self.entry("game/assets/env/wall.png")])
        code, rules, out = self.run_check()
        self.assertTrue({"TEX-01", "TEX-02"} <= rules, out)

    def test_flat_palette_texture_passes_with_both_decoders(self):
        wood, ink = (0x7B, 0x5B, 0x40, 255), (0x1F, 0x1A, 0x17, 255)
        self.write("game/assets/env/plank.png", png_bytes(32, 32, lambda x, y: ink if y % 8 == 0 else wood, filter_type=4))
        self.manifest([self.entry("game/assets/env/plank.png")])
        for no_pil in (False, True):
            code, rules, out = self.run_check(no_pil=no_pil)
            self.assertEqual(code, 0, out)

    def test_signal_colour_needs_signal_lane(self):
        danger = (0xE5, 0x48, 0x2D, 255)
        self.write("game/assets/vfx/telegraph.png", png_bytes(16, 16, lambda x, y: danger))
        self.manifest([self.entry("game/assets/vfx/telegraph.png", lane="env")])
        self.assertIn("TEX-01", self.run_check()[1])
        self.manifest([self.entry("game/assets/vfx/telegraph.png", lane="signal")])
        self.assertEqual(self.run_check()[0], 0)

    def test_size_and_format(self):
        wood = (0x7B, 0x5B, 0x40, 255)
        self.write("game/assets/env/odd.png", png_bytes(100, 64, lambda x, y: wood))
        self.write("game/assets/env/photo.jpg", b"\xff\xd8\xff")
        self.manifest([self.entry("game/assets/env/*")])
        code, rules, out = self.run_check()
        self.assertEqual(rules, {"TEX-03"}, out)
        self.assertEqual(out.count("TEX-03"), 2, out)

    # ---- provenance
    def test_unlisted_and_unprovenanced_assets_fail(self):
        self.write("game/assets/props/barrel.glb", b"glTF")
        self.write("game/assets/props/sign.glb", b"glTF")
        self.manifest([self.entry("game/assets/props/sign.glb", kind="generated")])
        code, rules, out = self.run_check()
        self.assertEqual(rules, {"SRC-01", "SRC-02"}, out)

    def test_third_party_source_needs_license(self):
        self.write("art_source/third_party/kit/model.glb", b"glTF")
        self.assertIn("SRC-03", self.run_check()[1])
        self.write("art_source/third_party/kit/License.txt", "CC0")
        self.assertEqual(self.run_check()[0], 0)

    # ---- prompt cards
    def test_prompt_card_locks_and_banned_phrases(self):
        template = (self.tmp / "docs/art/templates/prompt-card.md").read_text()
        self.write("docs/art/prompts/ok.md", template.replace("<asset-id>", "booth"))
        self.assertEqual(self.run_check()[0], 0)
        self.write("docs/art/prompts/edited.md", template.replace("no gloss, ", ""))
        self.write("docs/art/prompts/slop.md", template + "\nepic booth, trending on artstation, by Greg Rutkowski\n")
        code, rules, out = self.run_check()
        self.assertEqual(rules, {"PRM-01", "PRM-02"}, out)
        self.assertIn("edited.md", out)
        self.assertEqual(out.count("PRM-02"), 3, out)  # 'trending on artstation' + 'artstation' + artist name


if __name__ == "__main__":
    unittest.main()
