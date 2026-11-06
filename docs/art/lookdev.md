# Look-dev — thư viện vật liệu và cảnh kiểm

Trạng thái: `approved` (2026-11-06). Cảnh này là mục tiêu kiểm đầu tiên cho hướng **khắc gỗ và sơn bạc màu**,
không phải một khu playable.

## Dùng lại thư viện

- Vật liệu `game/art/materials/` dùng palette đã khóa, `metallic = 0`, bề mặt khô mờ và tắt specular.
  `water_wet` là ngoại lệ ướt duy nhất: toon specular mức thấp.
- `signal_beacon`, `signal_danger` chỉ dành cho tín hiệu gameplay; `light_lamp_warm` chỉ cho nguồn đèn trong cảnh.
  Không dùng chúng cho loot, rarity hoặc trang trí.
- `art/shaders/toon_matte.gdshader` tạo hai bậc sáng/tối, bóng `shadow_indigo` và hạt giấy dó.
  **Màu in = màu palette:** mặt sáng dùng hệ số ánh sáng `vec3(1.0)` để Godot trả đúng `albedo_color` của vật liệu,
  không nhân màu vật liệu lần hai hoặc nhân với màu đèn;
  màu đèn chỉ giữ hướng và shadow map. Mặt tối, kể cả bóng trên sàn, trả `shadow_indigo` trước khi
  vệt đục được đặt lên. Vì vậy `lamp_warm` chỉ là sắc rất nhẹ ở vật liệu đèn, không nhuộm gỗ hay đá.
  Trong `light()` của GL Compatibility, `shadow_indigo` và `hatch_gouge_colour` đến dưới dạng sRGB thô còn
  `ALBEDO` là tuyến tính; shader bắt buộc gọi `srgb_to_linear()` cho cả hai trước khi chia cho `ALBEDO`.
  Không đổi `vec3` sang `vec4` để sửa lỗi này: cách đó không tuyến tính hoá màu và làm bóng sàn trôi về xám.
  world-space/triplanar. Mặc định của mọi `env_*` là `paper_grain_enabled = true`, strength `0.04`
  (dao động sáng ±4%), fibre scale `14` và speckle density `7`: chỉ thấy rõ ở ảnh cận, không là lớp phủ màn hình.
- Vệt đục là nét song song đứt đoạn theo trục thế giới, chỉ shader đặt vào dải bóng. Cargo 2×2 và thân quầy dùng
  density `2.6`, line width `0.22`, strength `0.90`: hàng vệt thưa, nét rộng và đoạn đứt dài để mực tách riêng
  khỏi hạt giấy ở ảnh điện thoại. Mép được cắt bằng `step` (không feather `smoothstep`), còn hai đầu thu hẹp theo
  hình học và có điểm bắt đầu/kết thúc lệch theo từng hàng: ảnh cận phải thấy chuyển màu không quá 1 px như nhát đục.
  `hatch_gouge_colour` mặc định là `ink` cho gỗ sáng; mặt `env_wood_dark` dưới
  khoảng 35% value dùng `paper_light` để các vệt đục sáng còn tách được trong dải bóng chàm. Mái dùng density
  `5.5`, mặc định width `0.052`, strength `0.31`. Tắt cho vật dưới 0.5 m và toàn bộ sàn telegraph.
- `ink_outline.gdshader` dùng mực `ink` theo ba hạng vật lý: `0.055 m` cho Người Thu Hồi/vật tương tác,
  `0.045 m` cho landmark và `0.035 m` cho prop thường. Sàn không có `next_pass` nét mực.
- Cảnh kiểm dùng `ShaderMaterial` tô màu theo palette và `next_pass` nét mực theo đúng hạng trên cho cargo 2×2,
  quầy thuế, beacon, bàn dispatch và Người Thu Hồi placeholder. Cargo, thân quầy và mái là ba mặt lớn có vệt đục;
  sàn không có vết grunge. Mái/quầy/cọc/chồng thùng nghiêng 2–5° và ba cọc neo cao thấp lệch nhịp.
- Bàn dispatch và Người Thu Hồi được chừa một khoảng sàn rõ ở ảnh điện thoại; giấy trên bàn là điểm sáng duy nhất
  của cụm tương tác đó.
- `art/env_default.tres` giữ tonemap linear, nền `sea_bluegrey`; fog tắt trong GL Compatibility vì fog của renderer này
  thay clear background bằng đen kể cả khi `fog_sky_affect = 0`. Màu `paper` vẫn là màu fog đã khai báo cho renderer
  hỗ trợ tách lớp mà không che nền; cảnh này không bloom, DOF, SSAO hoặc auto exposure. Với GL Compatibility, `lookdev.gd`
  lấy đúng `background_color` của resource làm clear color của viewport để PNG giữ mã palette đã khai báo.
- Beacon và đèn treo đọc bằng emission của `signal_beacon` và `light_lamp_warm`; look-dev không dùng
  `OmniLight3D`, nên không có quầng sáng tròn trên sàn, mái hoặc cargo.
- `water_wet` dùng `art/shaders/water_print.gdshader`, không còn là `StandardMaterial3D`: đây vẫn là ngoại lệ ướt
  duy nhất có `specular_toon` thấp (`0.08`, roughness `0.88`), nhưng trong `light()` dùng đúng multiplier PRT-01
  của `toon_matte`. Vì vậy nước sáng ra `water`, còn bóng ra `shadow_indigo`, không cần bật ambient và không thành
  bề mặt nhựa. `ProbeWaterShadow` nằm ở `(-3.42, 0.018, -4.5)`: đoạn WaterPatch hở camera dưới bóng của thân cọc
  beacon; đây là dải bóng nhìn thấy được cạnh cargo, không phải vùng nước sáng sát nó.

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
- `game-shit/build/lookdev/probe.json` — kết quả probe màu tự động. Sau khi ảnh game được chụp,
  `lookdev.gd` chiếu từng `Marker3D` nhóm `lookdev_probe` qua `Camera3D`, ray tới mesh `surface_path` đầu tiên,
  rồi mới lấy mẫu pixel tại toạ độ đó; một điểm bị che ghi `occluded` và làm probe lỗi.
  `tools/lookdev_probe.py` in bảng `vật liệu · màu đo · màu mong đợi · ΔE76`, ghi file này và trả lỗi
  nếu quá ngưỡng (nền ≤ 5, mặt sáng ≤ 10, bóng ≤ 12). `ProbeWaterLit` và `ProbeWaterShadow` kiểm riêng vật liệu
  không dùng `toon_matte`; hai probe đều có kiểm mesh che khuất như các probe còn lại.

Gate cũng chụp **cảnh chơi thật Bến Ngoài (A)** từ `CameraIsometric`, có Người Thu Hồi ở điểm xuất phát:

- `game-shit/build/lookdev/zone_a_game.png` — 1280×720, màu.
- `game-shit/build/lookdev/zone_a_gray.png` — 1280×720, thang xám.
- `game-shit/build/lookdev/zone_a_phone.png` — 640×360, giảm bằng nearest-neighbour.
- `game-shit/build/lookdev/zone_a_probe.json` — probe nền, mặt sàn sáng và bóng đổ sàn theo PRT-01.

Gate cũng chụp **cảnh chơi thật Chợ Ngập (B)** bằng camera isometric đúng hợp đồng, có Người Thu Hồi ở `BEntry`
và một vạch lane charge đông cứng ở `progress = 0.6` chỉ để kiểm khung hình (không phải state combat):

- `game-shit/build/lookdev/zone_b_game.png` — 1280×720, màu.
- `game-shit/build/lookdev/zone_b_gray.png` — 1280×720, thang xám để đối chiếu hình vòng/vạch/chevron.
- `game-shit/build/lookdev/zone_b_phone.png` — 640×360, giảm bằng nearest-neighbour.
- `game-shit/build/lookdev/zone_b_probe.json` — nền, sàn sáng, sàn bóng, lane yên và mái đỏ son B; mọi điểm
  ngoài nền ray-check mesh gần camera nhất nên điểm bị che làm gate lỗi.

`zone_b_flooded_market.tscn` là greybox placeholder tự dựng từ primitive và vật liệu thư viện; không có file dưới
`game/assets/`, vì vậy manifest asset không cần dòng mới cho TASK-20261106-85.

Để thêm cảnh chơi khác vào gate, đặt script capture dưới `game/src/lookdev/`, chỉ chạy khi nhận user argument
riêng, rồi gọi scene đó trong `tools/lookdev_capture.sh`. Cảnh phải dùng camera gameplay đang `current`, tự tạo
nhân vật tại spawn khi capture (không ghi vào scene ship), và có Marker3D nhóm probe riêng. Mỗi marker đặt cao hơn
0.005 m trên mặt nhìn thấy, khai báo `surface_path`, `tolerance`, `role`; mặt sáng khai báo `expected_hex`, bóng lấy
`shadow_indigo` từ ShaderMaterial. Capture phải ray-check mesh gần camera nhất, ghi `occluded`, và script shell phải
fail khi thiếu PNG hoặc probe không đạt.

Thêm điểm probe cho asset mới: thêm một `Marker3D` có tên mô tả vào `lookdev.tscn`, đặt nó nhô 0.005 m
trên mặt nhìn thấy, gán nhóm `lookdev_probe`, và metadata `surface_path`, `tolerance`, `role`. Probe mặt sáng
cần thêm `expected_hex`; probe bóng có thể bỏ `expected_hex` để lấy `shadow_indigo` từ ShaderMaterial của
`surface_path`. Chọn vùng không có nét mực hoặc ranh sáng/tối; probe sẽ fail nếu điểm nằm ngoài khung, phía
sau camera hoặc bị mesh khác che.

Chấm cả ba ảnh theo [rubric](templates/review-rubric.md): kiểm cargo 2×2, thùng, quầy thuế mái nghiêng,
cọc neo, beacon, bàn dispatch, Người Thu Hồi placeholder, nước, đèn treo và dải palette ở camera orthographic
−30°/45°. Không có asset dưới `game/assets/`, nên manifest không cần dòng mới cho card này.
