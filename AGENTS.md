# Khế Ước Tàn Vương — repository guide for agents

Mobile 2.5D action-extraction game, offline-first. This repo holds the **design docs** and the
**Godot project**. Team process, task boards and agent configuration live outside this repo.

## Layout

| Path | What |
|---|---|
| `docs/` | Design corpus. Canon order: `docs/story/MAIN_STORY.md` wins over every other story doc. |
| `docs/art/` | **Art Bible** (visual contract), templates (asset brief, prompt card, review rubric), asset manifest. |
| `game/art/` | `palette.json` (the only colours), material library and shaders (`game/art/shaders/`). |
| `game/` | Godot 4.7.2 project (`project.godot`). GDScript only, statically typed. |
| `game/src/` | Game code. `autoload/app_env.gd` = build channel + per-environment config. |
| `game/config/env/{dev,staging,production}.cfg` | Per-environment flags (debug menu, env badge, save namespace). |
| `game/tests/` | Headless tests: `unit/test_*.gd`, runner `run_tests.gd`. |
| `tools/` | `check.sh` (quality gate), `check_docs.py`, `check_art.py` (Art Bible lint), `run-staging.sh`, `serve_web.py`, `ci/*`. |
| `.github/workflows/` | `ci.yml` (PR gate), `staging.yml` (main → staging), `production.yml` (tag → production), `_build.yml` (export). |

## Engine rules

- Godot **4.7.2-stable**, renderer **GL Compatibility** (same look on Web staging and low-end Android). Do not
  switch renderer, engine version or add C# without an approved decision.
- 2.5D = 3D scene with a fixed isometric orthographic `Camera3D` (see `docs/art-direction.md`).
- Write to `user://` only (`AppEnv.save_dir()` namespaces saves per channel); `res://` is read-only in exports.
- Commit `*.uid` and `*.import` files; never commit `.godot/`, `build/`, keystores or `game/config/build_info.cfg`.
- New non-resource data files must be covered by the export presets' `include_filter` (currently `config/*.cfg`).

## Visual rules (anything that is seen on screen)

- Follow `docs/art/ART_BIBLE.md`. Its banned list (AI-01…AI-12) is an automatic fail; `tools/check_art.py` enforces
  the measurable part (matte materials, no specular/metallic, palette-only colours, no cinematic post, PNG rules,
  provenance in `docs/art/asset-manifest.json`, untouched LOCK blocks in prompt cards).
- Every asset file under `game/assets/` needs a manifest entry; generated images need a prompt card and normalisation.
- No text baked into images; no living artist/studio names in prompts or briefs.

## Environments

| Channel | Built from | Feature tag | Delivered as |
|---|---|---|---|
| dev | editor / local run | — | local only |
| staging | every push to `main` | `staging` | rolling `staging` pre-release: web zip + debug APK (`vn.hieuphung.kheuoctanvuong.staging`) |
| production | tag `vX.Y.Z` on `main`, equal to `config/version` | `production` | GitHub Release: web zip + release-signed APK |

Code reads the channel through `AppEnv` (`AppEnv.channel`, `AppEnv.get_flag(section, key, fallback)`), never through
`OS.has_feature` directly.

## Commands

```bash
GODOT_BIN=/path/to/godot tools/check.sh        # docs links + import + unit tests + smoke run (must pass)
tools/check.sh --docs-only                      # docs only
godot --headless --path game --script res://tests/run_tests.gd
tools/run-staging.sh [web|apk|info]             # play the current staging build
```

Tests: one file per subject in `game/tests/unit/`, methods `func test_x(t) -> bool` using `t.eq()` / `t.ok()` and
ending with `return true`. Never use bare `assert()` in tests.

## Content rules (design docs)

- Main story closes its conflict; later maps explore consequences, no secret retcon villain.
- Every map: a local wound, a local actor, a concrete objective, a gameplay pressure, a visible aftermath.
- Side stories may change local NPCs/routes/rewards but cannot soft-lock the main story or remove a core map.
- Story items are extractable, recoverable after death and meaningful beyond selling.
- No names, characters, terminology, plots or scenes copied from reference fiction.
- New ideas are labelled `proposed` until approved; approved rules go into the relevant story document.

## Change discipline

- Small, reviewable changes; one task = one branch = one PR into `main`. Merging to `main` deploys staging.
- `tools/check.sh` must pass before a PR. Do not edit `.github/workflows/` unless the task is a CI/release task.
- Never put secrets in the repo; signing keys are GitHub environment secrets.
