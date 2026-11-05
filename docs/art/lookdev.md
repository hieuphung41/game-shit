# Look-dev — thư viện vật liệu và cảnh kiểm

Trạng thái: `proposed`. Cảnh này là mục tiêu kiểm đầu tiên cho hướng **khắc gỗ và sơn bạc màu**,
không phải một khu playable.

## Dùng lại thư viện

- Vật liệu `game/art/materials/` dùng palette đã khóa, `metallic = 0`, bề mặt khô mờ và tắt specular.
  `water_wet` là ngoại lệ ướt duy nhất: toon specular mức thấp.
- `signal_beacon`, `signal_danger` chỉ dành cho tín hiệu gameplay; `light_lamp_warm` chỉ cho nguồn đèn trong cảnh.
  Không dùng chúng cho loot, rarity hoặc trang trí.
- `art/shaders/toon_matte.gdshader` tạo hai bậc sáng/tối, bóng `shadow_indigo` và hạt giấy dó
  world-space/triplanar. Mặc định của mọi `env_*` là `paper_grain_enabled = true`, strength `0.04`
  (dao động sáng ±4%), fibre scale `14` và speckle density `7`: chỉ thấy rõ ở ảnh cận, không là lớp phủ màn hình.
- Vệt đục là nét song song đứt đoạn theo trục thế giới, chỉ shader đặt vào dải bóng. Cargo 2×2 và thân quầy dùng
  density `2.6`, line width `0.22`, strength `0.90`: hàng vệt thưa, nét rộng và đoạn đứt dài để mực tách riêng
  khỏi hạt giấy ở ảnh điện thoại. `hatch_gouge_colour` mặc định là `ink` cho gỗ sáng; mặt `env_wood_dark` dưới
  khoảng 35% value dùng `paper_light` để các vệt đục sáng còn tách được trong dải bóng chàm. Mái dùng density
  `5.5`, mặc định width `0.052`, strength `0.31`. Tắt cho vật dưới 0.5 m và toàn bộ sàn telegraph.
- `ink_outline.gdshader` dùng mực `ink` theo ba hạng vật lý: `0.055 m` cho Người Thu Hồi/vật tương tác,
  `0.045 m` cho landmark và `0.035 m` cho prop thường. Sàn không có `next_pass` nét mực.
- Cảnh kiểm dùng `ShaderMaterial` tô màu theo palette và `next_pass` nét mực theo đúng hạng trên cho cargo 2×2,
  quầy thuế, beacon, bàn dispatch và Người Thu Hồi placeholder. Cargo, thân quầy và mái là ba mặt lớn có vệt đục;
  sàn không có vết grunge. Mái/quầy/cọc/chồng thùng nghiêng 2–5° và ba cọc neo cao thấp lệch nhịp.
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
- `game-shit/build/lookdev/lookdev_detail.png` — 1280×720, camera cùng góc −30°/45°, orthographic size 5,
  khung cận cargo 2×2 và quầy thuế để soi hạt giấy/vệt đục.

Chấm cả ba ảnh theo [rubric](templates/review-rubric.md): kiểm cargo 2×2, thùng, quầy thuế mái nghiêng,
cọc neo, beacon, bàn dispatch, Người Thu Hồi placeholder, nước, đèn treo và dải palette ở camera orthographic
−30°/45°. Không có asset dưới `game/assets/`, nên manifest không cần dòng mới cho card này.
