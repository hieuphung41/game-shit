# Art Bible — "Khắc gỗ & sơn bạc màu"

**Trạng thái:** `proposed` (2026-11-05), chờ user duyệt qua scene look-dev trên staging. Đây là **hợp đồng hình ảnh**
mà mọi người và mọi agent làm hình phải tuân theo. Nó cụ thể hoá [art-direction.md](../art-direction.md) thành
luật đo được; khi hai tài liệu khác nhau về *ý đồ*, art-direction.md thắng; về *thông số*, file này thắng.

Dữ liệu máy đọc: [palette.json](../../game/art/palette.json). Bộ kiểm tra tự động: `tools/check_art.py` (chạy trong
`tools/check.sh` và CI). Template: [templates/](templates/). Nhật ký nguồn asset: [asset-manifest.json](asset-manifest.json).

## 1. Một câu định hướng

Thế giới 3D low-poly được **in như tranh khắc gỗ màu trên giấy thô**: mảng màu phẳng lấy từ palette cố định,
ánh sáng hai bậc, bóng ngả về chàm, nét mực ở viền, vết mòn được *đặt có chủ ý* (dấu thuế, sáp niêm, mụn vá, vạch nước),
mọi bề mặt **mờ, không bóng**. Chỉ tín hiệu gameplay được phát sáng.

Vì sao hướng này: nó đọc tốt trên màn điện thoại (mảng phẳng + viền), chạy được trên renderer GL Compatibility và
**ngược hẳn với các dấu hiệu của ảnh AI**: bề mặt mượt như phun sơn, bóng nhựa, gradient mềm, chi tiết li ti vô nghĩa,
ánh sáng studio và màu bão hoà.

## 2. Khung kỹ thuật (khoá)

| Hạng mục | Giá trị `proposed` |
|---|---|
| Engine / renderer | Godot 4.7.2, GL Compatibility (web staging + Android tầm thấp) |
| Camera | `Camera3D` orthographic, pitch −30°, yaw 45°, không xoay; zoom chỉ theo art-direction §2 |
| Kích thước đọc | Người chơi cao 64–80 px trên khung 1280×720; prop tương tác ≥ 24 px cạnh ngắn |
| Đơn vị | 1 unit = 1 m; nhân vật người ≈ 1.7 m; ô footprint lưới không liên quan kích thước thế giới |
| Texel density | 64 px/m cho prop và kiến trúc; 128 px/m cho nhân vật và vật tương tác cận cảnh |
| Texture | PNG 8-bit, cạnh là luỹ thừa của 2, tối đa 1024²; atlas palette dùng chung trước, texture riêng chỉ khi cần |
| Vật liệu | Từ thư viện `game/art/materials/` hoặc shader trong `game/art/shaders/` (xem §5) |
| Định dạng 3D | glTF 2.0 (`.glb`); scale/pivot đã áp dụng; collision là proxy đơn giản |

## 3. Palette và làn màu

Palette gồm 43 màu chia **5 làn**. Một màu chỉ được dùng trong làn của nó:

| Làn | Dùng cho | Phát sáng? |
|---|---|---|
| `env` (26) | mọi vật liệu và texture thế giới: mực, bóng chàm, đá, giấy dó, gỗ, dây, sắt, nước, vải, da… | không |
| `light` (2) | đèn thực tế trong cảnh (đèn treo B/C, bếp dân) | có, cường độ thấp |
| `signal` (5) | **chỉ gameplay**: `danger` (telegraph/sát thương), `beacon_dim`/`beacon` (extract), `objective`, `interact` | có |
| `ui` (4) | giao diện, thẻ, con dấu | — |
| `rarity` (6) | **chỉ trên thẻ/UI item**, không bao giờ trên vật liệu thế giới | — |

Chữ ký màu theo khu lấy từ `zones` trong palette.json: A xanh xám biển + gỗ + beacon; B đỏ son sẫm (không phải màu
sát thương); C vàng hoè xỉn + sắt; D xanh lục tối + bọt; E đồng + gỉ đồng + đá tối.

Cấu trúc sáng tối (value): ba dải trong thế giới. Tối (mực/bóng) ≤ 25% độ sáng, trung (gỗ/đá/vải) 30–60%, sáng
(giấy/bọt/điểm nhấn) ≥ 70%. Ở ảnh chụp **thang xám**, player, loot và vật tương tác phải tách khỏi nền mà không cần màu.

## 4. Hình khối và chi tiết

- **Khối chắc, hơi lệch:** cạnh không song song tuyệt đối, mái và quầy nghiêng 2–5°, cọc lệch nhịp. Cấm đối xứng hoàn
  hảo ở kiến trúc và đạo cụ thủ công.
- **Silhouette trước chi tiết:** mỗi prop đọc được chỉ bằng bóng đen ở kích thước §2. Không vát cạnh (bevel) nhỏ;
  chỉ vát ở khối lớn bằng hình học.
- **Chi tiết có tác giả:** mọi vết mòn phải trả lời được "vì sao nó ở đây": dấu thuế, sáp niêm, mụn vá, dây chằng,
  vạch nước, vết kéo hàng. Cấm lớp grunge, rỉ, bụi phủ đều khắp nơi.
- **Mật độ chi tiết theo vai trò:** vật tương tác > landmark > tường > sàn. Sàn là nơi yên nhất để telegraph và
  footprint loot đọc rõ.

## 5. Vật liệu, ánh sáng, hậu kỳ (gốc của "nhựa")

| Mã | Luật | Lint tự động? |
|---|---|---|
| MAT-01 | `metallic = 0` mọi nơi. Kim loại được *vẽ* bằng màu (`iron`, `bronze`, `verdigris`), không dùng PBR. | có |
| MAT-02 | `roughness ≥ 0.85`, trừ vật liệu ướt có hậu tố `_wet` (nước, đá ướt) | có |
| MAT-03 | Tắt specular: `specular_mode = disabled`, hoặc `toon` chỉ cho `_wet`. Không để mặc định Schlick-GGX. | có |
| MAT-04 | Ánh sáng hai bậc (toon), bóng ngả `shadow_indigo`; không có gradient mềm trên một mặt phẳng | review |
| MAT-05 | Emission chỉ cho vật liệu có tiền tố `signal_` hoặc `light_` | có |
| MAT-06 | Không normal map và không detail map trên prop (tránh vi chi tiết li ti) | có (texture tên `*_normal*`) |
| MAT-07 | Shader tự viết chỉ nằm ở `game/art/shaders/`; shader spatial phải có `specular_disabled`, `specular_toon` hoặc `unshaded` | có |
| LGT-01 | Một `DirectionalLight3D` chính, cố định hướng trên-trái (khớp camera §2), màu ấm `lamp_warm` nhạt; đèn phụ chỉ là đèn thực tế trong cảnh | review |
| LGT-02 | Fog độ sâu/độ cao ngả màu `paper` để tách lớp | review |
| ENV-01 | Cấm glow/bloom (trừ khi chỉ bắt vào vật liệu signal), DOF, SSAO, SSR, SSIL, SDFGI, lens flare, chromatic aberration, vignette | có (WorldEnvironment/CameraAttributes) |
| ENV-02 | Tonemap `linear` để màu palette ra đúng; không auto-exposure | có |
| OUT-01 | Nét mực `ink` cho nhân vật, vật tương tác và landmark; độ dày cố định theo khoảng cách, không đổi giữa các asset cùng hạng (xem WC-03) | review |
| GRN-01 | Hạt giấy là texture thế giới (triplanar), nhẹ nhưng **thấy được** (xem WC-01), không phải lớp phủ màn hình | review |

### 5a. Dấu hiệu khắc gỗ (phải thấy trên ảnh look-dev)

Đúng hết §5 mới chỉ ra "toon 3D sạch". Thứ làm hình đọc như **tranh khắc gỗ in trên giấy** là bốn dấu hiệu dưới
đây. Mỗi dấu hiệu phải nhìn thấy được trên ảnh look-dev (ảnh cận `lookdev_detail.png` nếu có, nếu không thì ảnh
game ở 100%), không chỉ tồn tại trong tham số.

| Mã | Dấu hiệu | Đủ khi | Không được thành |
|---|---|---|---|
| WC-01 | Hạt giấy dó | Sợi và đốm giấy world-space/triplanar, biên độ khoảng ±3–5% độ sáng, bật mặc định trên mọi vật liệu `env_*`; thấy ở ảnh cận, gần như biến mất ở ảnh cỡ điện thoại; đứng yên khi camera di chuyển | noise trắng đều, lớp phủ màn hình, vân ảnh chụp |
| WC-02 | Vệt đục | Nét gạch song song mảnh màu `shadow_indigo` hoặc `ink`, **chỉ** trong dải bóng và sát ranh sáng/tối của mặt lớn (tường, mái, thân quầy, khối sàn cao), hướng cố định theo thế giới, thưa | gạch trên mặt sáng, trên vật nhỏ < 0.5 m, trên vùng sàn dành cho telegraph; hoa văn dày đặc (AI-03) |
| WC-03 | Nét mực đọc được | Viền `ink` dày ≥ 2 px ở ảnh 1280×720 và vẫn thấy ở ảnh 640×360 trên nhân vật, vật tương tác, landmark; ba hạng độ dày: tương tác/nhân vật > landmark > prop thường; sàn không viền | nét mảnh mất khi thu nhỏ; độ dày khác nhau giữa hai asset cùng hạng |
| WC-04 | Khối lệch tay | Đồ thủ công và kiến trúc nghiêng 2–5° (mái, quầy, cọc, chồng thùng), nhịp cọc không đều, cạnh trên không thẳng tắp tuyệt đối (§4) | hộp vuông vức đặt thẳng trục; méo vô lý (AI-08) |

## 6. Texture và ảnh 2D

| Mã | Luật | Lint |
|---|---|---|
| TEX-01 | ≥ 97% điểm ảnh (alpha > 0) nằm trong ΔE ≤ 8 của một màu palette, thuộc làn khai báo trong manifest | có |
| TEX-02 | ≤ 48 màu riêng biệt mỗi texture. Đây là luật diệt gradient airbrush và noise AI. | có |
| TEX-03 | Chỉ PNG 8-bit trong `game/assets/` (cấm JPG/WebP vì vệt nén), cạnh luỹ thừa 2, ≤ 1024 | có |
| TEX-04 | Không chữ, không ký tự giả, không watermark trong ảnh. Mọi chữ do font trong engine vẽ. | review |
| TEX-05 | Ánh sáng không được nướng (bake) vào texture theo hướng khác LGT-01; tốt nhất là không nướng ánh sáng | review |
| ICO-01 | Icon UI là vector (SVG) vẽ tay/bằng code từ hình học; ảnh sinh ra chỉ dùng để phác ý tưởng | review |

## 7. Danh sách CẤM — dấu hiệu "AI làm" (gặp một mục là trượt)

| Mã | Dấu hiệu | Ví dụ thường gặp |
|---|---|---|
| AI-01 | Bóng nhựa: highlight bóng, phản chiếu kiểu PBR trên bề mặt khô | thùng gỗ bóng như sơn mài, đá có điểm sáng tròn |
| AI-02 | Bề mặt phun sơn: gradient mượt dài trên một mặt, da và vải mịn như sáp | tường chuyển màu êm, mặt nhân vật láng |
| AI-03 | Chi tiết vô nghĩa: hoa văn li ti, rạn và gỉ đều khắp, "hyperdetail" | sàn đầy noise, viền trang trí không chức năng |
| AI-04 | Ánh sáng studio: ánh sáng mềm từ mọi phía, rim light quanh mọi vật, nhiều hướng sáng | vật nào cũng có viền sáng xanh cam |
| AI-05 | Màu bão hoà và teal–orange, màu ngoài palette | trời cam, nước teal rực |
| AI-06 | Hậu kỳ điện ảnh: DOF, bokeh, bloom mờ, lens flare, tia sáng | nền nhoè, đèn loé |
| AI-07 | Chữ hoặc ký tự giả trong hình | biển hiệu nguệch ngoạc "gần giống chữ" |
| AI-08 | Hình học tan chảy: phối cảnh sai góc camera §2, vật dính nhau, tay hoặc ngón sai, đối xứng sai chỗ | thùng méo, lan can cong vô lý |
| AI-09 | Trope "epic" chung chung: ánh vàng kho báu, hạt lấp lánh, rune phát sáng không gắn với thế giới | rương vàng rực trong kho thuế |
| AI-10 | Trôi phong cách: viền, mật độ chi tiết, tỉ lệ khác mục tiêu đã duyệt | một prop "đẹp" nhưng thuộc game khác |
| AI-11 | Dấu upscale và nén: viền nhoè, ringing, mật độ pixel không đều | icon nhoè cạnh |
| AI-12 | Không rõ nguồn: không có dòng trong manifest | file "final_v3.png" không ai biết từ đâu |

## 8. Chính sách dùng AI tạo ảnh (generative)

- **Được dùng:** board tham khảo và concept (không ship), *phôi* texture hoặc decal để chuẩn hoá về palette, phác ý tưởng icon.
- **Không ship trực tiếp:** ảnh sinh thô, mesh sinh thô, chân dung nhân vật, bất cứ ảnh nào có chữ.
- **Bắt buộc với mọi ảnh sinh muốn vào game:** prompt card từ [templates/prompt-card.md](templates/prompt-card.md)
  (giữ nguyên khối STYLE LOCK và NEGATIVE LOCK), sau đó chuẩn hoá (quantize về palette, giảm về texel density, sửa tay
  vết lỗi), qua `check_art.py`, chụp look-dev, chấm [rubric](templates/review-rubric.md), rồi ghi manifest với
  `kind: generated`, `prompt_card`, `tool`, `date`.
- **Không bao giờ** ghi tên hoạ sĩ còn sống, studio hay game khác trong prompt hoặc brief; mô tả bằng thuộc tính
  (khối, màu, chất liệu, nét, ánh sáng).

## 9. Nguồn asset được phép

| Nguồn | Giấy phép (đã kiểm tra 2026-11-05) | Ghi chú |
|---|---|---|
| Tự làm trong repo (code, primitive, vẽ tay) | của dự án | ưu tiên |
| Kenney (kenney.nl) | CC0 1.0 | ví dụ Pirate Kit; vẫn phải qua remap palette và vật liệu |
| KayKit (Kay Lousberg) bản free | CC0 1.0 | tô bằng một texture gradient atlas, nên thay atlas bằng palette là xong |
| Quaternius | Quaternius Asset License v1.0: không cần ghi công, **cấm phát tán lại asset thô** | chỉ dùng khi repo còn private; cần duyệt lại nếu public |
| Ảnh sinh (AI) | theo điều khoản công cụ | chỉ theo §8 |
| Ảnh chụp, texture photogrammetry | — | **cấm** (lệch phong cách, AI-03) |

Bộ asset bên thứ ba nằm ở `game/assets/third_party/<pack>/` kèm file LICENSE gốc. Mỗi file dùng trong game phải có
dòng tương ứng trong manifest.

## 10. Quy trình một asset (bắt buộc với agent)

1. **Brief:** chép [templates/asset-brief.md](templates/asset-brief.md) sang `docs/art/briefs/`, điền vai trò gameplay,
   footprint, làn màu, câu chuyện của vết mòn.
2. **Nguồn:** chọn tự dựng, bộ CC0 (§9) hoặc ảnh sinh (§8, kèm prompt card).
3. **Dựng và chuẩn hoá:** vật liệu từ thư viện, texture về palette, scale/pivot đúng.
4. **Tự kiểm:** `tools/check.sh` (gồm `check_art.py`) phải xanh.
5. **Look-dev:** chụp ba ảnh (góc game, thang xám, cỡ điện thoại) và tự chấm [rubric](templates/review-rubric.md).
6. **Ghi manifest:** nguồn, giấy phép, làn màu, prompt card, điểm rubric.
7. **Review độc lập:** art director chấm lại bằng rubric. Một mục CẤM là trượt.

## 11. Định nghĩa "đạt"

Không mục AI-xx nào, `check_art.py` xanh, rubric ≥ 16/20 và không tiêu chí nào 0 điểm, đọc được ở ảnh cỡ điện thoại
và ảnh thang xám, thấy được các dấu hiệu khắc gỗ §5a, và có dòng manifest đầy đủ. Khi file này còn `proposed`,
tiêu chí 10 của rubric tối đa 1 điểm (chưa có mục tiêu đã duyệt để so).
