# game-shit

Game mobile 2.5D action-extraction, offline-first: **Khế Ước Tàn Vương**.

- [docs/](docs/): tài liệu thiết kế (cốt truyện, map, item/inventory, vertical slice, playtest, workflow).
- [game/](game/): project Godot 4.7.2 (GDScript, renderer GL Compatibility).
- [AGENTS.md](AGENTS.md): layout, môi trường, lệnh build/test cho người và agent.

## Môi trường

| Môi trường | Khi nào build | Lấy bản chạy |
|---|---|---|
| **staging** | mỗi lần push/merge vào `main` | pre-release [`staging`](https://github.com/hieuphung41/game-shit/releases/tag/staging) · chạy local: `tools/run-staging.sh` (web) hoặc `tools/run-staging.sh apk` |
| **production** | push tag `vX.Y.Z` (khớp `config/version` trong `game/project.godot`) | GitHub Release `vX.Y.Z` |

## Chạy ở máy

```bash
GODOT_BIN=/đường/dẫn/godot tools/check.sh   # kiểm tra docs + import + test + smoke run
godot --path game                            # mở game (channel dev)
```
