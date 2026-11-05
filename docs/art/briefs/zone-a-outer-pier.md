# Asset brief — Bến Ngoài (A) `zone_a_outer_pier`

> Chép từ [templates/asset-brief.md](../templates/asset-brief.md). Khung kỹ thuật lấy từ
> [ART_BIBLE §2](../ART_BIBLE.md#2-khung-kỹ-thuật-khoá); chỉ ghi ở đây chỗ khác (kèm lý do). Mỗi asset một mục
> `### <asset-id>`.

**Trạng thái:** `proposed` (2026-11-05). Mọi kích thước, tỉ lệ, ngưỡng và tên vật liệu trong file là `proposed` cho
tới khi look-dev trên staging được duyệt. Brief này không đổi luật gameplay: trạng thái beacon, bàn dispatch,
Manifest và extract lấy nguyên từ [vertical slice](../../vertical-slice.md),
[wireflow](../../vertical-slice-wireflow.md) và
[checklist đọc bàn dispatch](../../maps/black-tax-port-dispatch-visual-readability-checklist.md).

**Nguồn ràng buộc:** [Art Bible](../ART_BIBLE.md), [art direction §3](../../art-direction.md),
[map brief Cảng Hắc Thuế](../../maps/black-tax-port.md), [palette.json](../../../game/art/palette.json).

## Khung chung (đã khoá — không điền lại)

Godot 4.7.2 · GL Compatibility · camera orthographic −30°/45° · 64 px/m (prop), 128 px/m (nhân vật, vật tương tác) ·
PNG 8-bit ≤ 1024 · vật liệu từ `game/art/materials/` · palette `game/art/palette.json`.

**Khác khung chung (có lý do):**

1. `prop_a_manifest_r17` phóng to ~1.3× so với kích thước giấy thật để còn thấy được trên bàn ở cỡ điện thoại
   (xem mục của nó). Nó **không** là đích chạm riêng: đích chạm là bàn dispatch (O2 trong wireflow), nên ngưỡng
   24 px của Art Bible áp lên bàn, còn Manifest chỉ cần ≥ 16 px cạnh ngắn `proposed` như một dấu hiệu "còn/không còn".
2. Thư viện `game/art/materials/` chưa có. Tên vật liệu dưới đây (`env_*`, `signal_*`) là `proposed`;
   technical-artist tạo chúng theo MAT-01…MAT-07 và giữ đúng tên, hoặc ghi tên mới vào handoff.

## Phạm vi

| Có trong brief | Không có (card khác) |
|---|---|
| 10 prop của A trong vertical slice + 2 phôi decal dùng chung (dấu thuế, sáp niêm) | NPC/dân bốc vác, thuyền extract (S9), vòng khu vực beacon (UI/VFX do engine vẽ), marker objective, icon UI, prop khu B–E, dựng hình Local Story "Bến Không Tên", hình ảnh incident (Nước triều đen…), loot pickup |

## Gia đình asset

- **Khu / chữ ký màu** (palette.json `zones.A`): `sea_bluegrey`, `wood`, `rope`, `paper`, `beacon`.
  Tỉ lệ diện tích mặt trên màn hình A `proposed`: gỗ (`wood`/`wood_dark`/`wood_light`) ~50%, `sea_bluegrey` + nước
  ~30%, `rope`/`hemp` ~10%, `paper` ≤ 8%, đỏ dấu thuế (`canvas_red`/`canvas_red_dark`) ≤ 2%, `beacon` chỉ ở đèn phao.
- **Mục tiêu đã duyệt để so:** chưa có. Asset đầu tiên của gia đình đạt [rubric](../templates/review-rubric.md)
  ≥ 16/20 (đề xuất: `prop_a_dispatch_desk`) trở thành mục tiêu so cho các asset còn lại (chống AI-10).
- **Điều phải giống nhau trong cả gia đình:**
  1. **Tỉ lệ:** đo theo người 1.7 m. Không prop nào trong A cao hơn đèn phao (`prop_a_beacon`), để landmark A còn
     là đỉnh silhouette khi nhìn từ B lúc quay về.
  2. **Hướng sáng:** chỉ `DirectionalLight3D` trên-trái (LGT-01); không nướng sáng vào texture (TEX-05). A **không có
     đèn thực tế** (`light` lane): nguồn phát sáng duy nhất của A là đèn phao, để không có gì tranh tín hiệu extract.
  3. **Viền mực (OUT-01):** chỉ `prop_a_dispatch_desk`, `prop_a_manifest_r17` và `prop_a_beacon` có nét `ink`.
     Prop trang trí và sàn không có viền, để thứ bậc đọc "tương tác > landmark > tường > sàn" (Art Bible §4) giữ nguyên.
  4. **Hình khối:** lệch 2–5°, cọc lệch nhịp, không đối xứng hoàn hảo; vát chỉ ở khối lớn; không normal map (MAT-06).
  5. **Ngân sách vết mòn:** dấu thuế chỉ xuất hiện ở **điểm kiểm soát** — bàn dispatch, Manifest, biển thuế, kiện
     hàng đã thông quan, nắp thùng, biển phí trên cột đèn phao. Cọc, ván sàn, cuộn dây và vạch mực nước **không** mang
     dấu thuế. Tối đa một dấu thuế mỗi mặt prop; tối đa một sáp niêm mỗi chồng hàng.
  6. **Làn màu:** mọi vật liệu là `env`, trừ kính đèn phao (`signal`). Không `rarity` lane trên bất kỳ vật liệu nào;
     không `ui` lane trong thế giới (đỏ dấu thuế thế giới là `canvas_red_dark`, không phải `ui_stamp_red`).
  7. **Giữ màu riêng:** trong A, `paper_light` chỉ dành cho `prop_a_manifest_r17`; mọi giấy khác dùng `paper`. Lý do:
     ở ảnh thang xám Manifest phải là mảng sáng nhất trên bàn và trong khung spawn.
  8. **Nước:** mặt nước dưới cầu tàu dùng `water`/`water_deep`; chỉ chân cọc chìm dùng vật liệu `_wet`. Mặt gỗ khô
     luôn mờ, roughness ≥ 0.85 (MAT-02).

### Câu chuyện chung của vết mòn

Ba tác giả để lại dấu ở A, và mọi vết mòn phải thuộc về một trong ba (khớp
[MAIN_STORY §7](../../story/MAIN_STORY.md) và [map brief §1, §3](../../maps/black-tax-port.md)):

| Tác giả | Họ làm gì ở A | Dấu họ để lại |
|---|---|---|
| **Nhà Hắc Thuế** (`house_hac_thue`) | Giữ cảng hải quan, thu phí người thu hồi độc lập, cho phép một phần hàng hợp pháp qua Bến Ngoài | Dấu thuế mực đỏ sẫm, sáp niêm trên hàng đã thông quan, biểu tượng hải quan cũ bị cạo rồi đóng đè dấu Hắc Thuế |
| **Dân bốc vác** | Kéo hàng, buộc thuyền, vá đồ bằng gỗ thừa và dây | Vết kéo hàng trên ván, ván vá khác màu, dây chằng vá, đầu dây được quấn lại |
| **Nước** | Cảng ngập và lún dần; nước từng dâng cao hơn mặt cầu tàu hiện tại | Vạch muối (`foam`) ở chân cọc, mảng gỗ sẫm dưới vạch, chân bàn/thùng thay mới vì mục |

**Mức nước dâng cao nhất của khu A — `flood_line_a`:** một độ cao duy nhất, **cao hơn mặt ván cầu tàu hiện tại
~0.25 m `proposed`**, đo từ mặt trên của `prop_a_pier_plank`. Đây là lần nước dâng từng phủ qua cầu tàu. Mọi vạch
nước cao, vạch muối cao, mảng gỗ sẫm hay mép giấy ngấm nước ở A đều nằm **đúng** ở `flood_line_a` (sai số ±0.02 m để
khớp lưới mesh); không mục nào được tự đặt một mức nước dâng cao nhất khác. Nếu số này đổi, chỉ sửa ở đây. Mức triều
thường (vạch thấp) nằm dưới mặt ván, chỉ thấy trên phần cọc chìm, và không phải `flood_line_a`.

Không dùng vết mòn để kể Local Story "Bến Không Tên" (tên bị xoá, hàng cứu trợ đổi nhãn): nội dung đó không có trong
lát cắt và thuộc khu B/D. Không đặt máu, xác hay khổ đau dân thường làm décor (art direction §1).

---

### prop_a_dispatch_desk

Bàn dispatch A — nơi lấy Manifest đầu run và nơi tự thu hồi Manifest sau death (cùng một fixture, hai state).

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Tương tác (O2 bàn dispatch) + landmark nhỏ của A. Đích chạm cho cả pickup đầu run và recovery; không là checkpoint, không là điểm extract. |
| Footprint thế giới | 1.6 × 0.8 × 1.0 m `proposed` (mặt bàn cao 0.95 m); phía sau có giá nghiêng ~20° cao thêm 0.25 m, quay mặt về camera, để đặt Manifest. Không phải loot. |
| Silhouette phải đọc được | Một quầy gỗ thấp, rộng, có giá nghiêng phía sau như bục viết — đọc là "bàn làm giấy tờ", khác hẳn thùng/kiện hàng. |
| Làn màu và màu chính | env — `wood_dark` (thân, chân), `wood` (mặt bàn), `wood_light` (chân thay mới), `canvas_red_dark` (dấu thuế), `ink` (viền). |
| Vật liệu | `env_wood_dark`, `env_wood`, `env_wood_light` (`proposed`); decal `decal_tax_stamp_hac_thue`. |
| Vết mòn có tác giả | (1) Mép trước có một mảng gỗ bị bào phẳng, trên đó đóng đè **dấu thuế Hắc Thuế**: biểu tượng hải quan cũ đã bị cạo, bàn giờ là bàn có phép của Nhà Hắc Thuế. (2) Mặt bàn có một mảng lõm sáng hơn (`wood_light`, hình phẳng, không gradient) đúng chỗ người giữ bàn đóng dấu mỗi ngày. (3) Một chân trước là gỗ mới `wood_light`, buộc dây vào chân cũ: chân gốc mục vì nước dâng tới `flood_line_a` (xem "Câu chuyện chung của vết mòn"); ba chân còn lại có vạch sẫm ở đúng `flood_line_a`. |
| Nguồn | Tự dựng (primitive + chỉnh tay). Bộ CC0 §9 chỉ dùng nếu có quầy tương đương và remap đủ palette/vật liệu. |
| Không được | Không có đèn, nến, lồng đèn trên bàn (A không có `light` lane; không tranh beacon). Không có giấy rải khắp mặt bàn: ngoài Manifest chỉ một chồng giấy `paper` gọn ở góc xa, để Manifest là mảng sáng duy nhất trên giá. Không có chữ, số hay ký tự giả trên giấy hoặc gỗ (TEX-04). Không có hình dạng hay màu nào gợi checkpoint/teleporter (vòng sáng, cột sáng, ký hiệu tròn trên sàn). |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest · ảnh thang xám: bàn (tối) tách khỏi ván sàn (trung) và Manifest (sáng) nổi lên trên bàn. |

### prop_a_manifest_r17

Vật thể `Manifest Hàng Hóa R-17` (`manifest_r17`) nằm trên giá bàn dispatch — **bản dispatch cấp thấp**, không phải
bằng chứng pháp lý cuối.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Dấu hiệu trạng thái của source item: còn trên giá = chưa nhặt / chưa tự thu hồi; giá trống = đã placement hợp lệ. Không là đích chạm riêng (đích chạm là bàn). |
| Footprint thế giới | 0.45 × 0.35 × 0.06 m `proposed` (~1.3× tờ giấy gập thật, xem "Khác khung chung"). Footprint lưới: **1x1**. Mesh riêng, tách khỏi bàn, để engine ẩn/hiện theo state. 128 px/m. |
| Silhouette phải đọc được | Một xấp giấy gập đôi buộc dây chéo, nằm nghiêng trên giá, quay mặt về camera — đọc là "giấy tờ rời", không phải sách, hộp hay đồ quý. |
| Làn màu và màu chính | env — `paper_light` (giấy; màu riêng của Manifest trong A), `hemp` (dây buộc), `canvas_red_dark` (dấu dispatch nhỏ), `ink` (viền). |
| Vật liệu | `env_paper_light`, `env_hemp` (`proposed`); decal `decal_tax_stamp_hac_thue` thu nhỏ. |
| Vết mòn có tác giả | (1) Một **dấu thuế nhỏ** ở góc: bản sao do bàn dispatch của Hắc Thuế cấp, nên nó mang dấu phát hành cấp thấp, không mang dấu đối ấn. (2) Một góc gập (hình gấp phẳng, một mặt tam giác) vì người giữ bàn lật xem nhiều lần. (3) Khô, sạch nước: nó được để trên giá cao, khác với mọi thứ khác ở A — chính sự sạch đó nói "giấy này được giữ cẩn thận". |
| Nguồn | Tự dựng (một mesh gập + dây). |
| Không được | Không có sáp niêm (sáp niêm thế giới là của hàng đã thông quan; Manifest có sáp dễ bị đọc thành `sealed` trong Hộp Công Chứng hoặc thành "đã bàn giao"). Không đóng bìa thành sổ, không bìa da, không ruy băng (không lẫn với `Sổ Nợ Gốc` 1x2 hay `Counterseal`, cả hai ngoài lát cắt). Không glow, không cột sáng, không màu `objective` trên vật thể — objective marker là hình học UI riêng do engine vẽ (art direction §4). Không màu `rarity`. Không chữ "R-17" hay ký tự nào trên giấy: tên và mã chỉ hiện trên card/UI bằng font engine. |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest · ảnh cỡ điện thoại: thấy được có/không có Manifest trên giá mà không cần zoom; ảnh thang xám: Manifest là mảng sáng nhất trong khung spawn ngoài đèn phao. |

### prop_a_beacon

Đèn phao A (beacon A) ở đầu Cầu tàu A (`extract_pier_a`) — landmark của khu và tín hiệu extract duy nhất của lát cắt.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Landmark + tín hiệu extract. Hiển thị state theo wireflow §7: E0 `unavailable` → E1 `callable` → S7 → S8 → S9. Brief chỉ cấp **phần mesh cho phép engine đổi state**; luật chuyển state không đổi ở đây. |
| Footprint thế giới | Cột 0.4 m đường kính, cao tổng 4.0 m `proposed`; hộp đèn 0.6 × 0.6 × 0.8 m trên đỉnh; chân cột dựng trên cụm 3 cọc ở đầu cầu tàu. Mặt ván quanh chân để trống bán kính ~2 m `proposed` cho vòng khu vực do engine vẽ. |
| Silhouette phải đọc được | Một cột cao, hơi nghiêng, đỉnh là hộp đèn có mái chóp và cửa chớp — dáng thẳng đứng cao nhất A, nhận ra từ B khi quay về. |
| Làn màu và màu chính | env — `sea_bluegrey` (cột sơn), `iron` (hộp đèn, đai), `rope` (dây chằng), `foam` (vạch muối ở chân), `ink` (viền); signal — `beacon_dim` / `beacon` (chỉ ở kính đèn). |
| Vật liệu | `env_sea_bluegrey`, `env_iron`, `env_rope`, `env_wood_wet` (chỉ phần cọc chìm); kính đèn dùng `signal_beacon_dim` và `signal_beacon` (emission; MAT-05). |
| Vết mòn có tác giả | (1) **Biển phí** bằng sắt bắt ở cột, ngang tầm mắt người (~1.5 m), mang dấu thuế dập nổi: đánh dấu bến này thuộc quyền thu phí của Nhà Hắc Thuế, phe thu phí những người thu hồi độc lập (MAIN_STORY §7). Biển trống, không chữ; không gắn luật phí nào vào lát cắt. Biển phí nằm thấp, xa hộp đèn. (2) Sơn `sea_bluegrey` bong thành mảng lớn (hình phẳng, cạnh gãy) ở mặt hướng ra biển, lộ `wood` bên dưới. (3) Dây chằng giữ cột có một đoạn vá bằng nút buộc của dân bốc vác. (4) Chân cột có vạch muối `foam` ở đúng `flood_line_a` (mức nước dâng cao nhất của khu). |
| Nguồn | Tự dựng. |
| Không được | **Không được giống loot:** không phát sáng ở tầm thấp gần sàn, không lấp lánh/hạt sáng, không cùng màu `interact` hay `objective`; phần phát sáng duy nhất là kính đèn ở trên cao. Không dùng màu làm tín hiệu state duy nhất: mesh phải có **cửa chớp tách node riêng (pivot ở bản lề)** để engine đóng một nửa ở E0 và mở hết từ E1 — hình dạng đổi được khi không nhận biết màu (art direction §4–§5). Không dùng `lamp_warm`/`lamp_cold`. Không có tia sáng, quầng mờ hay bloom (ENV-01). Không giống cổng thuế E hay thuyền D (không có ở lát cắt). |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest · look-dev chụp riêng E0 và E1: ảnh thang xám vẫn phân biệt được hai state nhờ cửa chớp. |

### prop_a_mooring_pile

Cọc neo — cọc bến cao và cọc buộc thuyền dọc mép Bến Ngoài.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Vật cản / viền mép cầu tàu (cho biết chỗ nào là mép nước); trang trí landmark "cọc bến cao, dây neo thẳng" của A. |
| Footprint thế giới | Ba biến thể `proposed`: cọc cao Ø0.4 m × 3.0 m trên mặt ván; cọc trung Ø0.35 m × 1.8 m; cọc buộc thuyền Ø0.4 m × 0.6 m. Phần dưới nước kéo dài thêm 1.5 m. |
| Silhouette phải đọc được | Hàng cọc tròn đứng lệch nhịp và lệch góc vài độ, đỉnh cọc cao bị mòn tròn — đọc là "mép bến, không đi qua". |
| Làn màu và màu chính | env — `wood_dark` (thân), `foam` (vạch muối), `rope` (dây quấn), `water_deep` (phần chìm sẫm). |
| Vật liệu | `env_wood_dark`, `env_wood_wet` (chỉ đoạn dưới vạch nước), `env_rope`. |
| Vết mòn có tác giả | (1) Rãnh mòn quanh đầu cọc buộc, đúng chỗ dây neo cọ hàng năm. (2) Một vài cọc có ống gỗ ốp mới (`wood`) đóng đinh quanh thân: dân bốc vác ốp lại chỗ cọc mục. (3) Hai vạch muối `foam`: vạch thấp là mức triều thường (dưới mặt ván, trên phần cọc chìm), vạch cao nằm đúng `flood_line_a` — lần nước dâng từng phủ qua cầu tàu. |
| Nguồn | Tự dựng, hoặc mesh cọc của bộ CC0 §9 sau remap palette/vật liệu. |
| Không được | Không mang dấu thuế (ngân sách vết mòn, mục 5). Không sọc xen kẽ, không màu `danger`: sọc là ngữ pháp **cọc cảnh báo nước sâu** (hazard) theo art direction §4, không dùng cho cọc thường. Không đặt cọc chắn giữa lane spawn → bàn dispatch → beacon. |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest. |

### prop_a_pier_deck_planks

Ván cầu tàu — sàn mô-đun của Bến Ngoài và Cầu tàu A.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Sàn đi được. Bề mặt **yên nhất** trong A để telegraph (khi giữ extract S8) và vòng beacon đọc rõ. |
| Footprint thế giới | Mô-đun 2 × 2 × 0.1 m `proposed`, ván rộng ~0.25 m chạy một hướng. Bốn biến thể: trơn, có vết kéo hàng, có ván vá, mép ngoài có khe hở thấy nước. |
| Silhouette phải đọc được | Mặt phẳng gỗ sọc ván dài theo một hướng; mép ngoài có viền dầm sẫm để biết chỗ hết sàn. |
| Làn màu và màu chính | env — `wood` (ván), `wood_light` (vết kéo hàng, ván vá), `wood_dark` (khe, dầm mép), `water` (nhìn qua khe). |
| Vật liệu | `env_wood`, `env_wood_light`, `env_wood_dark`. Không `_wet` trên mặt ván. |
| Vết mòn có tác giả | (1) **Vết kéo hàng:** dải `wood_light` phẳng, song song hướng từ cầu tàu vào kho, do dân bốc vác kéo kiện qua mỗi ngày. (2) **Ván vá:** vài tấm ngắn khác tông đóng chéo đè lên ván gãy — đồ vá của dân bốc vác bằng gỗ thừa. (3) Mép ngoài có ván thiếu, để lộ nước: chỗ nước dâng đã đánh bật ván mà chưa ai thay. |
| Nguồn | Tự dựng (mô-đun lát được). |
| Không được | Mật độ chi tiết thấp nhất trong gia đình: không thớ gỗ li ti, không đinh rải đều, không lớp bẩn phủ đều (AI-03). Không mang dấu thuế. Vết kéo hàng không được giống vạch telegraph: không có đầu mũi tên, không màu `signal`, độ tương phản thấp hơn mọi telegraph. Không vệt bóng ướt (MAT-02/03). |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest · ảnh thang xám: footprint loot và telegraph đặt thử trên ván vẫn tách khỏi nền. |

### prop_a_cargo_stack_cleared

Chồng hàng hợp pháp đã thông quan (cargo 2x2 dạng tĩnh) — "một phần hàng hợp pháp" của A theo map brief.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Vật cản / cover tiềm năng khi giữ extract (S8); **không phải loot**, không có tương tác. Chiều cao cover cuối do level design quyết định. |
| Footprint thế giới | Mỗi kiện 1.0 × 1.0 × 0.8 m `proposed`, cùng tỉ lệ đế với cargo 2x2 loot ở D để người chơi quen kích thước "kiện cỡ này = 2x2" trước khi tới D. Hai biến thể, luôn trên pallet 2.1 × 1.1 × 0.15 m: thấp (2 kiện cạnh nhau, ~0.95 m) và cao (2 tầng × 2 kiện, ~1.75 m). |
| Silhouette phải đọc được | Một khối hàng vuông **trên pallet, buộc dây chéo vào nhau** — đọc là "hàng đã chằng, không nhấc lên được". |
| Làn màu và màu chính | env — `hemp` (bao bố), `rope` (dây chằng), `wood` (pallet), `paper` (thẻ hàng), `canvas_red` + `canvas_red_dark` (sáp niêm, dấu thuế). |
| Vật liệu | `env_hemp`, `env_rope`, `env_wood`, `env_paper` (`proposed`); decal `decal_tax_stamp_hac_thue`, `decal_customs_wax_seal`. |
| Vết mòn có tác giả | (1) Mỗi chồng có **một sáp niêm** ở nút dây chằng và một thẻ hàng `paper` đóng dấu thuế: hải quan Hắc Thuế niêm hàng đã đóng phí để không ai mở trước khi kiểm. (2) Pallet sẫm toàn bộ và kiện tầng dưới có dải sẫm ở đáy lên tới đúng `flood_line_a` (tính từ mặt ván, không tính từ mặt pallet): chồng hàng đã đứng ở bến khi nước dâng phủ qua cầu tàu. (3) Một góc bao bố rách được khâu lại bằng dây to mũi thưa (dân bốc vác vá). |
| Nguồn | Tự dựng. |
| Không được | **Không được giống cargo loot ở D:** luật phân biệt `proposed` — hàng trang trí luôn ≥ 2 kiện, trên pallet, buộc dây vào nhau; **một kiện đơn đứng riêng trên sàn, không pallet** là hình dành cho loot. Không viền `ink`, không outline `interact`, không base/outline theo footprint (đó là ngữ pháp loot, art direction §4). Không dùng hình lồng sắt (lồng cargo là chữ ký D). Sáp niêm không dùng `ui_stamp_red` và không giống icon niêm của Hộp Công Chứng (icon đó là UI). Không kể chuyện hàng cứu trợ bị đổi nhãn (thuộc B). |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest. |

### prop_a_crate

Thùng gỗ hàng nhỏ, xếp chồng quanh kho và cạnh bàn dispatch.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Trang trí / cover thấp; không tương tác trong lát cắt. |
| Footprint thế giới | Hai biến thể `proposed`: 0.6 × 0.6 × 0.5 m và 0.5 × 0.4 × 0.4 m; xếp chồng 2–3 cái, chồng lệch nhau vài độ. |
| Silhouette phải đọc được | Hộp nan gỗ có quai dây hai bên, chồng lệch — đọc là "thùng hàng", khác kiện bao bố của chồng cargo. |
| Làn màu và màu chính | env — `wood` (nan), `wood_dark` (khung góc), `rope` (quai), `canvas_red_dark` (dấu thuế trên nắp). |
| Vật liệu | `env_wood`, `env_wood_dark`, `env_rope`; decal `decal_tax_stamp_hac_thue`. |
| Vết mòn có tác giả | (1) Dấu thuế trên nắp thùng đã qua kiểm (một dấu/nắp, không phải mọi thùng). (2) Một góc mẻ thành khối lớn (hình học, không texture): thùng bị thả mạnh khi bốc dỡ. (3) Thùng dưới cùng của chồng có dải sẫm từ đáy lên tới đúng `flood_line_a` (thùng đặt thẳng trên ván); các thùng tầng trên nằm cao hơn mức đó nên không có vạch nước. |
| Nguồn | Tự dựng, hoặc mesh thùng bộ CC0 §9 sau remap palette/vật liệu (giữ độ lệch 2–5° bằng cách xếp, không bằng cách bóp méo mesh). |
| Không được | Không có thùng đơn lẻ nằm riêng giữa lối đi (dễ bị đọc là pickup). Không bóng như sơn mài (AI-01). Không mép kim loại sáng hay đinh vàng (AI-09). Không chữ hay số stencil trên thùng (TEX-04). |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest. |

### prop_a_rope_coil

Cuộn dây neo quấn quanh cọc buộc thuyền.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Trang trí; nối thị giác giữa cọc buộc và mép bến (dây neo thẳng ra nước). |
| Footprint thế giới | Ø0.6 × 0.2 m `proposed`, luôn đặt sát chân `prop_a_mooring_pile` (biến thể cọc buộc), một đầu dây quấn lên cọc. |
| Silhouette phải đọc được | Vòng dây dày, dẹt, dính vào chân cọc bằng đoạn dây quấn — đọc là "dây của cọc này". |
| Làn màu và màu chính | env — `rope` (dây), `hemp` (đầu dây quấn lại), `wood_dark` (cọc). |
| Vật liệu | `env_rope`, `env_hemp`. |
| Vết mòn có tác giả | (1) Đầu dây được quấn chặt bằng sợi nhỏ `hemp` cho khỏi tưa — việc của dân bốc vác. (2) Đoạn dây chạm nước sẫm hơn một bậc (mảng phẳng `wood`, không gradient). |
| Nguồn | Tự dựng. |
| Không được | **Không được giống pickup dây thừng** (dây thừng là loot family của A theo map brief): không có cuộn dây rời nằm riêng trên ván, luôn dính cọc và lớn hơn pickup; không outline/highlight. Không xoắn sợi li ti (AI-03) — xoắn dây chỉ thể hiện bằng vài khía lớn. |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest. |

### prop_a_tide_gauge

Vạch mực nước — thước đo triều sơn trên một cọc bến.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Trang trí kể chuyện: cảng ngập và lún dần. **Không** báo trạng thái nước hiện tại trong lát cắt (incident Nước triều đen không có trong slice). |
| Footprint thế giới | Tấm ván 0.2 × 2.2 m `proposed` bắt dọc một cọc cao, phần dưới chìm nước. |
| Silhouette phải đọc được | Một dải ván dọc gắn vào cọc, có khía ngang đều — đọc là "thước", không phải biển báo. |
| Làn màu và màu chính | env — `paper` (nền sơn đã bạc), `ink` (khía), `foam` (vạch muối), `wood_dark` (cọc). |
| Vật liệu | `env_paper`, `env_wood_dark`, `env_wood_wet` (đoạn chìm). |
| Vết mòn có tác giả | (1) Dãy khía cũ ở thấp bị cạo mờ, dãy khía mới sơn lại cao hơn: người giữ cảng của Nhà Hắc Thuế phải sơn lại thước khi mặt bến lún và nước lên. (2) Một khía khắc tay lệch hàng ở trên cùng, sâu hơn các khía khác: dân bốc vác đánh dấu lần nước dâng phủ qua cầu tàu (nằm đúng `flood_line_a`, cùng độ cao với vạch muối cao trên cọc neo). |
| Nguồn | Tự dựng. |
| Không được | **Không được giống cọc cảnh báo nước sâu** (hazard): không sọc xen kẽ, không màu `danger`/`signal`, không đứng riêng trong nước ở mép lane — luôn bắt trên cọc kết cấu. Không có số hay ký tự (TEX-04); chỉ khía. Không chuyển động/không đổi theo state. |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest. |

### prop_a_tax_notice_board

Bảng thông báo thuế của Nhà Hắc Thuế ở Bến Ngoài.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Trang trí kể quyền lực; **không tương tác** trong lát cắt. Nếu sau này cần đọc nội dung, chữ do font engine vẽ (Label3D/UI) ở card riêng. |
| Footprint thế giới | Tấm bảng 1.2 × 0.9 m trên hai cột, tổng 1.4 × 0.15 × 2.0 m `proposed`, có thanh mái nhỏ phía trên. |
| Silhouette phải đọc được | Bảng chữ nhật nằm ngang trên hai chân, mái che mỏng, giấy chồng lớp mép lởm chởm — đọc là "bảng dán cáo thị". |
| Làn màu và màu chính | env — `wood_dark` (khung, cột), `paper` (giấy dán, **không** `paper_light`), `canvas_red_dark` (dấu thuế), `iron` (đinh), `ink`. |
| Vật liệu | `env_wood_dark`, `env_paper`, `env_iron`; decal `decal_tax_stamp_hac_thue`. |
| Vết mòn có tác giả | (1) Giấy dán chồng lớp: tờ mới nhất ở trên mang **một dấu thuế lớn**, đè lên tờ cũ bị xé dở còn lại mép giấy — mỗi kỳ thuế Hắc Thuế dán biểu phí mới lên biểu phí cũ. (2) Đinh sắt to đóng lại nhiều lần, có lỗ đinh cũ trên khung. (3) Hai chân cột của bảng có vạch sẫm ở đúng `flood_line_a`, và một tờ cũ dán thấp trên chân cột có mép dưới sẫm ở cùng mức đó: giấy dán thấp từng ngấm nước dâng. Các tờ trên tấm bảng nằm cao hơn `flood_line_a` nên không có viền nước. |
| Nguồn | Tự dựng. Giấy là mặt phẳng trống; không vẽ chữ. |
| Không được | **Không có chữ nướng vào ảnh**, kể cả chữ giả, dòng kẻ giả chữ hay số (TEX-04, AI-07). **Không được giống marker objective:** không màu `objective`/`interact`, không phát sáng, không lơ lửng, không hình thoi/mũi tên/dấu chấm than; luôn đứng trên hai cột chạm đất. Không đặt trên đường nhìn chính spawn → bàn dispatch → beacon (không tranh chú ý với ba fixture đó). Không dùng `ui_stamp_red`. |
| Kiểm tra | `tools/check.sh` xanh · look-dev 3 ảnh · rubric ≥ 16/20 · dòng manifest · ảnh thang xám: giấy của bảng tối hơn Manifest rõ rệt. |

### decal_tax_stamp_hac_thue

Phôi decal dấu thuế Nhà Hắc Thuế — dùng chung cho bàn dispatch, Manifest, biển phí đèn phao, thẻ hàng, nắp thùng, biển thuế.

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Trang trí kể quyền lực ("quyền lực có dấu vết", art direction §1). Là nguồn hình cho icon claim Hắc Thuế sau này (icon đó vẽ vector riêng theo ICO-01, card khác). |
| Footprint thế giới | Decal phẳng 0.1–0.4 m tuỳ prop `proposed`. Texture cuối: PNG 8-bit 64 × 64 px (bản lớn 128 × 128 cho biển thuế) `proposed`, alpha trong suốt. |
| Silhouette phải đọc được | Khung vuông dày cụt một góc, bên trong là một móc cẩu hàng — còn đọc được ở 32 × 32 px. |
| Làn màu và màu chính | env — `canvas_red_dark` (mực dấu), mép mực loang dùng chính `canvas_red_dark` với alpha cắt cứng (không gradient). |
| Vật liệu | Decal trên vật liệu `env_*` của prop; không emission. |
| Vết mòn có tác giả | Mực đóng không đều: một cạnh khung nhạt/khuyết vì con dấu ấn lệch tay — dấu do người đóng, không phải in máy. |
| Nguồn | Ảnh sinh làm phôi theo [prompt card](../prompts/decal_tax_stamp_hac_thue.md), sau đó chuẩn hoá ART_BIBLE §8; tự vẽ lại tay nếu phôi không đạt. |
| Không được | Không chữ, chữ giả, số hay hoa văn li ti (TEX-04, AI-03). Không dùng hình thoi, mũi tên, ghim bản đồ (hình dễ trùng marker objective). Không màu `danger`, `objective` hay `ui_stamp_red`. Tối đa 3 hình bên trong khung. |
| Kiểm tra | `tools/check.sh` xanh (TEX-01/02/03) · thu về 32 × 32 vẫn nhận ra · dòng manifest `kind: generated` + `prompt_card` + `normalized: true`. |

### decal_customs_wax_seal

Phôi decal sáp niêm hải quan — chỉ dùng trên hàng đã thông quan (`prop_a_cargo_stack_cleared`).

| Trường | Giá trị |
|---|---|
| Vai trò gameplay | Trang trí: "hàng này đã đóng phí và bị niêm, không ai được mở". |
| Footprint thế giới | Decal 0.12–0.18 m `proposed` đặt ở nút dây chằng. Texture cuối: PNG 8-bit 64 × 64 px `proposed`, alpha trong suốt. |
| Silhouette phải đọc được | Một giọt sáp tròn méo, mép chảy thành 3–4 thuỳ lớn, giữa ép hình móc cẩu nhỏ, một đoạn dây ngắn luồn qua — còn đọc được ở 32 × 32 px. |
| Làn màu và màu chính | env — `canvas_red` (sáp), `canvas_red_dark` (vết ép, bóng), `hemp` (dây), `ink` (viền ngoài mảnh). |
| Vật liệu | Decal trên vật liệu `env_*`; sáp mờ, không bóng (MAT-02/03). |
| Vết mòn có tác giả | Một thuỳ sáp bị nứt mẻ: kiện đã bị xô khi xếp lên pallet, nhưng dấu ép vẫn nguyên — niêm còn hiệu lực. |
| Nguồn | Ảnh sinh làm phôi theo [prompt card](../prompts/decal_customs_wax_seal.md), sau đó chuẩn hoá ART_BIBLE §8; tự vẽ lại tay nếu phôi không đạt. |
| Không được | Không highlight bóng trên sáp (AI-01). Không dùng trên `prop_a_manifest_r17` hay bất cứ vật evidence/loot nào. Không giống icon niêm của Hộp Công Chứng (`sealed`, UI, làn `ui`). Không ánh vàng/kim loại quý (AI-09). Không chữ hay ký tự trong vết ép. |
| Kiểm tra | `tools/check.sh` xanh (TEX-01/02/03) · thu về 32 × 32 vẫn nhận ra · dòng manifest `kind: generated` + `prompt_card` + `normalized: true`. |

---

## Kiểm tra chấp nhận cho cả gia đình (art-director / test-engineer)

Các kiểm tra dưới đây chạy trên scene look-dev khu A với toàn bộ prop đã đặt, ở camera §2, khung 1280×720.

1. **Given** khung spawn A, **when** chụp ảnh thang xám, **then** Manifest trên giá bàn dispatch là mảng sáng nhất
   ngoài kính đèn phao, và bàn dispatch tách khỏi ván sàn mà không cần màu.
2. **Given** khung spawn A, **when** thu ảnh về cỡ điện thoại, **then** bàn dispatch, đèn phao và lối vào B cùng nằm
   trong một khung và nhận ra được (khớp Beat 1 của vertical slice).
3. **Given** đèn phao ở E0 và ở E1, **when** chụp hai ảnh thang xám, **then** hai state khác nhau nhờ cửa chớp, không chỉ
   nhờ màu.
4. **Given** toàn bộ vật liệu khu A, **when** chạy `tools/check.sh`, **then** chỉ vật liệu tiền tố `signal_` (kính đèn
   phao) có emission; không vật liệu nào thuộc làn `light`, `ui` hay `rarity`.
5. **Given** một pickup 1x1 và một cargo 2x2 loot đặt thử trên `prop_a_pier_deck_planks` cạnh
   `prop_a_cargo_stack_cleared`, `prop_a_crate` và `prop_a_rope_coil`, **when** người xem chưa biết luật chỉ vào
   "vật nhặt được", **then** họ chỉ đúng hai vật thử, không chỉ vào prop trang trí.
6. **Given** `prop_a_tax_notice_board` và `prop_a_tide_gauge`, **when** so với marker objective và cọc cảnh báo hazard
   của slice, **then** không có màu signal, sọc xen kẽ, phát sáng hay hình mũi tên/thoi trên hai prop này.
7. **Given** mọi texture khu A, **when** soát bằng mắt, **then** không có chữ, số hay ký tự giả (TEX-04).
8. **Given** mọi dấu thuế trong khu A, **when** kiểm danh sách, **then** dấu chỉ nằm trên bàn dispatch, Manifest, biển
   phí đèn phao, thẻ hàng/nắp thùng và biển thuế — không trên cọc, ván, dây hay thước nước.
9. **Given** `prop_a_manifest_r17`, **when** đặt cạnh icon niêm của Hộp Công Chứng trên UI, **then** vật thể không có sáp
   niêm và không lặp hình icon đó.
10. **Given** mỗi asset khu A, **when** art-director chấm, **then** rubric ≥ 16/20, không tiêu chí 0 điểm, không mục
    AI-01…AI-12, và có dòng trong `docs/art/asset-manifest.json`.
