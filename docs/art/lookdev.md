# Look-dev — thư viện vật liệu và cảnh kiểm

Trạng thái: `proposed`. Cảnh này là mục tiêu kiểm đầu tiên cho hướng **khắc gỗ và sơn bạc màu**,
không phải một khu playable.

## Dùng lại thư viện

- Vật liệu `game/art/materials/` dùng palette đã khóa, `metallic = 0`, bề mặt khô mờ và tắt specular.
  `water_wet` là ngoại lệ ướt duy nhất: toon specular mức thấp.
- `signal_beacon`, `signal_danger` chỉ dành cho tín hiệu gameplay; `light_lamp_warm` chỉ cho nguồn đèn trong cảnh.
  Không dùng chúng cho loot, rarity hoặc trang trí.
- `art/shaders/toon_matte.gdshader` tạo hai bậc sáng/tối, bóng `shadow_indigo` và hạt giấy world-space rất nhẹ.
  `ink_outline.gdshader` dùng mực `ink` với độ dày vật lý cố định `0.04 m`.
- Cảnh kiểm dùng `ShaderMaterial` tô màu theo palette và một `next_pass` nét mực cho cargo 2×2, quầy thuế,
  beacon, bàn dispatch và Người Thu Hồi placeholder. Ba dấu dùng có lý do: dây chằng hàng, con dấu giấy thuế
  trên cargo và vạch nước/vết kéo ở mặt quầy hướng bến; sàn không có vết grunge.
- Bàn dispatch và Người Thu Hồi được chừa một khoảng sàn rõ ở ảnh điện thoại; giấy trên bàn là điểm sáng duy nhất
  của cụm tương tác đó.
- `art/env_default.tres` giữ tonemap linear, fog `paper`, không bloom, DOF, SSAO hoặc auto exposure.

## Chụp và tự kiểm

Từ thư mục studio, chạy:

```bash
GODOT_BIN=tools/bin/godot game-shit/tools/lookdev_capture.sh
```

Lệnh dùng GL Compatibility (`opengl3`), `$DISPLAY` hoặc `xvfb-run`, và phải tạo đủ:

- `game-shit/build/lookdev/lookdev_game.png` — 1280×720
- `game-shit/build/lookdev/lookdev_gray.png` — 1280×720 thang xám
- `game-shit/build/lookdev/lookdev_phone.png` — 640×360

Chấm cả ba ảnh theo [rubric](templates/review-rubric.md): kiểm cargo 2×2, thùng, quầy thuế mái nghiêng,
cọc neo, beacon, bàn dispatch, Người Thu Hồi placeholder, nước, đèn treo và dải palette ở camera orthographic
−30°/45°. Không có asset dưới `game/assets/`, nên manifest không cần dòng mới cho card này.
