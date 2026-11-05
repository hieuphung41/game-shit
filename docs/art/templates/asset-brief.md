# Asset brief — <family / khu>

> Chép sang `docs/art/briefs/<family>.md`. Khung kỹ thuật lấy từ [ART_BIBLE §2](../ART_BIBLE.md#2-khung-kỹ-thuật-khoá);
> chỉ ghi ở đây nếu khác (và phải có lý do). Mỗi asset một mục `### <asset-id>`.

## Khung chung (đã khoá — không điền lại)

Godot 4.7.2 · GL Compatibility · camera orthographic −30°/45° · 64 px/m (prop), 128 px/m (nhân vật, vật tương tác) ·
PNG 8-bit ≤ 1024 · vật liệu từ `game/art/materials/` · palette `game/art/palette.json`.

## Gia đình asset

- Khu / chữ ký màu (palette.json `zones`):
- Mục tiêu đã duyệt để so (ảnh look-dev hoặc asset):
- Điều gì phải giống nhau trong cả gia đình (tỉ lệ, viền, mật độ chi tiết, hướng sáng):

### <asset-id>

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | (vật cản / cover / loot / landmark / tương tác / trang trí) |
| Footprint thế giới | (m × m × m) và footprint lưới nếu là loot (1x1, 1x2…) |
| Silhouette phải đọc được | (một câu: hình gì ở cỡ điện thoại) |
| Làn màu và màu chính | (ví dụ: env — `canvas_red`, `wood_dark`, `paper`) |
| Vật liệu | (tên vật liệu trong thư viện; `_wet` chỉ cho bề mặt ướt) |
| Vết mòn có tác giả | (dấu gì, vì sao: ai đóng thuế, ai vá, nước dâng tới đâu) |
| Nguồn | tự dựng / bộ CC0 `<pack>/<file>` / ảnh sinh (prompt card) |
| Không được | (điều dễ sai riêng của asset này, ví dụ: "biển giá không được giống marker objective") |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest |
