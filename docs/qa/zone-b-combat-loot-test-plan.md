# Test plan — Chợ Ngập (B), combat, loot, quay A, hold có địch (S03): G6, G7, G8, G12, G14 (có địch lane B)

**Trạng thái:** test plan `proposed`. Mã case `TC-ZB-xx` và mọi chi tiết kênh build là `proposed` trừ khi ghi nguồn.
Plan không viết code test (card của test-engineer), không chạy phiên playtest, không đổi luật hay số liệu và không
định nghĩa metric mới. Đây là checklist DoD của sprint S03: một gate chỉ `READY` khi mọi case của nó đạt trên bản
web-staging.

**Nguồn luật:** [Build-readiness](../vertical-slice-build-readiness.md) §6 (G6, G7, G8, G12, G14), §9 ·
[Spec combat](../specs/combat-slice-spec.md) (CMB-01…25, ENM-01…18, HLD-01…08, VFX-01…03) ·
[Spec layout/encounter B](../specs/zone-b-layout-encounter-spec.md) (§5, §6.2, §9) ·
[Spec loot B](../specs/zone-b-loot-spec.md) (ZBL-01…22) · [Spec UX khu B](../specs/zone-b-ux-spec.md) (ZBU-01…50) ·
[Chuỗi in-game](../specs/contract-1-strings.md) (mục S03) ·
[Test plan vòng A](loop-a-early-extract-test-plan.md) (định dạng, mẫu bug, TC-LA-xx) ·
[Test plan inventory](inventory-grid-test-plan.md) · [Phiếu quan sát](../playtest-observation-sheet.md).
Tên theo glossary: `retriever`, `backpack`, `notary_box`, `sling_pouch`, `manifest_r17`, `tax_guard`, `foreman`,
`cache_b`, `scraped_tax_coin`, `waterlogged_stock_ledger`, `sling_remedy`, `extract_pier_a`, `AppEnv.channel`.

## 1. Cách đọc bảng

- **Case id** `TC-ZB-xx` = case đạt (`ĐẠT`) hoặc case cấm (`CẤM`, lấy từ cột `BLOCKER` của readiness §6). `TC-ZB-Bxx` =
  biên (gồm hủy, hết máu, phục hồi). `TC-ZB-Gxx` = ảnh thang xám / màn nhỏ. `TC-ZB-Zx` = kịch bản đầu-cuối.
  `TC-ZB-Sxx` = chỉ staging.
- **Tự động?** `có` = test headless ở §11 đã chứng minh đúng ý case; `có+tay` = có test nhưng QA vẫn chạy lại tay trên
  build; `chỉ tay` = chưa có test tự động (follow-up ở §14). Một case chỉ ghi `có` khi tên test thật nằm ở §8.
- **Kênh:** mọi case chạy tay trên bản **web-staging** `https://hieuphung1qaz.itch.io/25d-game`
  (`AppEnv.channel = staging`, build từ nhánh `main`). Cột `P` = case cũng chạy được trên production (tag) bằng flow
  thật; `S-only` = cần debug menu/fixture, không chạy trên production (§10). **M** = chuột (trình duyệt desktop),
  **T** = cảm ứng (điện thoại, ngang).
- Mọi số (HP 100, đòn 15/20/30, hồi 40, wind-up 0.8 s / 1.0 s, hold 20 s, cue 3.0 s, bán kính beacon 3.0 m) là
  `proposed` trong spec; plan chỉ trích để quan sát, **không** đánh giá cân bằng. Sai số đồng hồ tay ≤ ±1 giây.
- "Không đổi" = ảnh chụp ba lô/Hộp/túi đeo chéo + HP + số thuốc trước–sau giống hệt, state flow giống hệt, không có
  chữ hay hiệu ứng mới (định nghĩa như TC-LA).
- Mỗi lần chạy ghi **build channel + version** (tên pre-release staging, hiện ở badge/nhãn build của Boot) vào đầu phiếu.
- Kiểm cue: mọi cue nguy hiểm phải đọc được **không dựa vào màu** (làn `signal_danger` chỉ là phụ) và **không có audio**
  ở S03 (combat §12.5 còn mở). Plan kiểm cue bằng hình/chuyển động: đèn, mũi tên sàn, vòng/vạch, chữ HUD.
- Nơi chạy skirmish: người test cần tới B theo đường thật (A → ngõ B). Fixture HP/loadout (nếu debug menu có) chỉ ở
  cột `S-only`.

## 2. Ma trận bao phủ nhanh

| Gate | Case đạt | Case cấm | Case biên / hủy / hồi phục | Ảnh nhỏ / xám |
|---|---|---|---|---|
| G6 | TC-ZB-01, 02, 03, 04 | TC-ZB-05, 06 | TC-ZB-B01…B06 | TC-ZB-G01, G02 |
| G7 | TC-ZB-07, 08, 09 | TC-ZB-10, 11 | TC-ZB-B07…B10 | TC-ZB-G03 |
| G8 | TC-ZB-12, 13, 14 | TC-ZB-15, 16 | TC-ZB-B11…B15 | TC-ZB-G04 |
| G12 | TC-ZB-17, 18, 19 | TC-ZB-20, 21 | TC-ZB-B16…B19 | TC-ZB-G05 |
| G14 (có địch) | TC-ZB-22, 23, 24, 25 | TC-ZB-26, 27 | TC-ZB-B20…B25 | TC-ZB-G06 |
| DoD | TC-ZB-Z1M, Z1T, Z2 (regression) | — | — | — |
| Nền | TC-ZB-28 (cỡ chạm/chữ) | — | TC-ZB-S01…S03 | — |

Nhóm theo loại: thành công = 01…04, 07…09, 12…14, 17…19, 22…25 · đầu vào sai/cấm = 05, 06, 10, 11, 15, 16, 20, 21, 26,
27 · biên = B01…B25 · hủy = B07, B08, B12, B14 · **chết/hồi phục** = B03 (hết thuốc/từ chối), B04 (thuốc bị ngắt),
B05 (HP 0 stub → Boot), B06 (HP 0 khi overlay mở), B25 (HP 0 lúc hold) · save/load = **không có lưu tiến trình ở S03**:
TC-ZB-B05 và B25 kiểm "không có file mới, không summary", TC-ZB-Z2 kiểm `Về hub` không lưu.

## 3. G6 — S4 B combat: telegraph, lane, cover, vùng yên

Tiền điều kiện chung: bản staging mới, kit mặc định, đã lấy Manifest ở A và đứng ở `BEntry` (cửa ngõ B, ngoài tầm thấy
6 m của vệ binh). Điều khiển: C1 đánh, C2 né, C3 giữ khiên, C4 thuốc (combat §3; UX §3.2). Giữ C3 = đang giữ khiên.

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-ZB-01 | ĐẠT | `BEntry`, HP 100, chưa vào ngõ | Đi chậm vào ngõ tới khi vệ binh phát hiện; đứng yên 3 giây ngoài tầm 1.8 m | Thấy vệ binh đứng post, khiên nâng, vòng giữ ngõ trên sàn; HUD objective `HUD_OBJECTIVE_CROSS_TAX_POST`; một dòng `PROMPT_COMBAT_TAX_GUARD_FIRST_SEEN` hiện một lần. Chưa mất máu khi chưa vào 1.8 m (ENM-01, 04; ZBU-15) | có+tay | M, T |
| TC-ZB-02 | ĐẠT (telegraph vệ binh) | Như TC-ZB-01, vệ binh `alert` | Bước vào ≤ 1.8 m trước mặt vệ binh, đứng yên quan sát tới khi đòn ra | Có quạt đòn + vòng telegraph hiện ≈ 0.8 giây **trước** khi trúng; đòn chỉ ra đúng vùng quạt; HP 100 → 85 nếu đứng yên (không né). Đo được khoảng ≥ 0.6 giây giữa lúc quạt hiện và lúc HP đổi (ENM-04, ENM-18) | có+tay | M, T |
| TC-ZB-03 | ĐẠT (né/khiên) | Như TC-ZB-02 | Lần 1: chạm C2 (né) ngay khi quạt hiện. Lần 2: giữ C3 chặn trực diện đòn. Lần 3: giữ C3 nhưng đi vòng sang hông vệ binh | Lần 1: không mất máu, C2 có quạt hồi ≈ 0.8 giây, chạm C2 lúc đó không dash. Lần 2: không mất máu hoặc mất ít (chip), C3 hiện icon khiên dựng. Lần 3: khiên không chặn hông/sau, mất máu; vệ binh không chặn đòn của người chơi từ hông (CMB-09…14; ENM-06; ZBU-06, 07) | có+tay | M, T |
| TC-ZB-04 | ĐẠT (đốc công) | Đã qua beat vệ binh hoặc đi vòng; thấy `foreman` ở `end_a` (z −22.5) | Đứng ngoài lane 1.0 m, đợi 5 giây; vào lane; chờ vạch charge đầy; (a) ở lại lane, (b) bước ngang ra khỏi lane khi vạch sắp đầy | Ngoài lane: đốc công không đòn. Vào lane: vạch charge bắt đầu chạy, tiến độ tăng đều 0 → đầy trong ≈ 1.0 giây rồi lao; (a) trúng, mất lượng đòn charge và bị đẩy ngang khỏi lane; (b) không trúng, đốc công dừng ở đầu kia rồi đứng nghỉ ≈ 1.5 giây (ENM-10…13; VFX-01) | có+tay | M, T |
| TC-ZB-05 | CẤM | Toàn bộ B và hold | Đếm mọi lần mất máu trong 3 skirmish (vệ binh, đốc công, patrol); ghi mỗi lần có quạt/vạch/vòng hiện trước hay không | Không lần nào mất máu mà trước đó không có telegraph ≥ 0.6 giây của đúng địch đó; không đòn từ địch ngoài khung; chỉ một địch ra wind-up tại một thời điểm (readiness G6 `BLOCKER`: damage không báo trước). Ghi `BLOCKER` kèm video nếu trúng (ENM-15, 18) | có (mô phỏng, ENM-18) + tay | M, T |
| TC-ZB-06 | CẤM | Skirmish bất kỳ | Mở overlay (card cache hoặc lưới) khi địch ở cách ≤ 9 m; xem telegraph, máu, objective | Overlay (dock phải) **không** che H2 máu, H1 objective, H5 cảnh báo, nhân vật ở tâm màn hình; D1 `HUD_DANGER_NEAR` hiện; telegraph của địch vẫn nhìn thấy (ZBU-22, 40, 41; readiness G6 `BLOCKER`: overlay biến telegraph vô hình). Dành case riêng TC-ZB-B06 cho đòn rơi lúc overlay mở | có (bố cục) + tay | M, T |
| TC-ZB-B01 | Biên: cover chặn tầm nhìn | Đứng phía tây sân sau `CoverB1` (cao 1.2 m) | Đứng im 3 giây rồi thò ra khỏi cover | Khi núp sau cover, vệ binh chưa phát hiện (chưa có quạt/`alert`); thò ra thì phát hiện. Vùng ra đòn vẫn nằm trong khung (ENM-02; layout §5.2) | có+tay | M, T |
| TC-ZB-B02 | Biên: ra khỏi leash | Vệ binh `alert`, đứng cách ≈ 3 m post | Chạy ngược về +z (lối A) 4 m, đợi 5 giây | Vệ binh dừng ở mép leash, sau ≈ 4 giây mất dấu thì về post, `idle`, **không** hồi máu (nếu đã bị đánh); không đuổi vào A (ENM-09) | có+tay | M, T |
| TC-ZB-B03 | Hồi phục: thuốc hợp lệ | HP đã giảm còn ≈ 60, có `sling_remedy` ở túi đeo chéo (badge `1`) | Chạm C4, đợi ≈ 1.0 giây | Có vòng tiến độ kênh thuốc; sau ≈ 1.0 giây HP tăng tối đa tới `100/100` (không vượt), badge `0` + gạch chéo; chạm C4 lần hai: dòng `COMBAT_REMEDY_REFUSED_NO_REMEDY`, không đổi gì (CMB-16, 19; ZBU-11, 13) | có+tay | M, T |
| TC-ZB-B04 | Hồi phục: bị ngắt / HP đầy | (a) HP 100, có thuốc. (b) HP ≈ 60, có thuốc | (a) Chạm C4. (b) Chạm C4 rồi để địch đánh trúng ở ≈ 0.5 giây | (a) Không kênh, `COMBAT_REMEDY_REFUSED_HP_FULL`, badge vẫn `1`. (b) Vòng tiến độ biến mất, `COMBAT_REMEDY_INTERRUPTED`, badge vẫn `1`, HP chỉ giảm theo đòn (CMB-17, 18; ZBU-11, 12) | có+tay | M, T |
| TC-ZB-B05 | Chết: HP 0 → stub → Boot | HP 100 | Đứng yên chịu đòn tới HP 0 | Nhân vật gục, mọi input bị khóa; hiện đúng một dòng `COMBAT_STUB_HP_ZERO` + nút về Boot bị khóa (icon khóa + vòng tiến độ) trong ≈ 2.5 giây; chạm hoặc Back trong 2.5 giây đầu không làm gì; sau đó chạm nút (hai lần nhanh) → Boot đúng một lần với `UI_LOADING`. **Không** S10, không "thành công", không recovery/S11, không file mới (CMB-24; ZBU-46…48; readiness G14 `BLOCKER`: death vẫn success) | có (`test_flow_hp_zero_opens_stub_then_returns_to_boot_without_summary`) + tay | M, T |
| TC-ZB-B06 | Chết khi overlay mở | Dock card/lưới mở, địch ≤ 9 m | Để địch đánh tới HP 0 khi dock còn mở | Dock đóng như hủy (không nhặt, cache còn món); O6 hiện; C1–C4, R5', H3, D1, H5 ẩn; joystick khóa (ZBL-17; ZBU-46, 49) | có (một phần) + tay | M, T |

## 4. G7 — O2 card loot B

Tiền điều kiện chung: đã tới `CalmZoneB`, gate B mở (vệ binh và đốc công đều rút hoặc gục), Manifest niêm vào Hộp (1,0) hoặc
ở ba lô tùy case. Đứng trong 1.5 m quanh `CacheB`: R5' hiện `WORLD_INTERACT_CACHE_B`.

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-ZB-07 | ĐẠT (card đồng xu) | Trong tầm `CacheB`, cache `full` | Chạm R5'; đọc card đầu | Dock có 2 chip (đồng xu `×2`, sổ `1×2`). Card đồng xu có đúng thứ tự dòng NAME (`×2`) → FOOTPRINT (`1×1`) → USE → CLAIM → RARITY → LORE; không tag `xoay được`; không giá/tiền; nút `Bỏ qua`, `Nhặt và xếp`, `Đóng`; R1/H2/H5 vẫn thấy; R4' `PROMPT_LOOT_COLOR_NOT_VALUE`; mở card không đổi state (ZBL-03, 05; ZBU-21, 22) | có (`test_ui_pickup_zone_b_card_has_non_colour_cues_and_skip_is_pure`) + tay | M, T |
| TC-ZB-08 | ĐẠT (card sổ) | Như TC-ZB-07 | Chạm chip 2 | Card `waterlogged_stock_ledger`: footprint `1×2` + tag `CARD_TAG_ROTATABLE`/`xoay được`, `niêm được`, bậc 3/6 (3 dấu đặc / 3 rỗng), cùng phe claim với đồng xu; Hộp hiện `no_fit` (icon ×) nếu Manifest đã niêm trong Hộp; không đổi state (ZBL-04; ZBU-23) | có+tay | M, T |
| TC-ZB-09 | ĐẠT (cue ngoài màu) | Card đồng xu rồi card sổ | Đọc claim, rarity, footprint, kết quả vừa ô; không dùng màu để phân biệt (thang xám, §8) | Claim = icon phe + chữ; rarity = số dấu đặc + chữ; footprint = số ô + `1×1`/`1×2`; vừa ô = tích / × / mũi tên xoay. Claim và rarity là hai thông tin riêng, không lẫn (readiness G7; ZBU-24) | chỉ tay | M, T |
| TC-ZB-10 | CẤM | Card bất kỳ | Rà card và dock | Không có giá bán/tiền/điểm, không biểu thị rarity bằng damage/giá trị-ô, không popup lore dài, không tự tịch thu vì claim `house_hac_thue`; lore đúng một dòng (readiness G7 `BLOCKER`; ZBL-03, 20) | chỉ tay | M, T |
| TC-ZB-11 | CẤM | Cache `full`, chưa chạm | Đứng im 10 giây trong tầm; rời tầm 1.5 m; quay lại | R5' chỉ **mời**, không tự mở; ra ngoài 1.5 m thì R5' ẩn và dock tự đóng nếu đang mở, không nhặt, không bỏ (ZBU-21; ZBL-16; layout §5.4.4) | có+tay | M, T |
| TC-ZB-B07 | Hủy: `Đóng`/Back | Dock card mở | Chạm `Đóng` (R3); mở lại; nhấn Back | Về HUD; C1–C4 hiện lại; cache vẫn `full` (cả hai món còn), không đổi inventory (ZBL-05; ZBU-26) | có+tay | M, T |
| TC-ZB-B08 | Hủy: `Bỏ qua` | Cache `full` | Chạm `Bỏ qua` ở card đồng xu rồi ở card sổ; mở lại cache | Sau lần 1 thành card sổ; sau lần 2 dock đóng; không đổi gì; mở lại → card đồng xu. Cuối run Hộp/ba lô không có món cache (ZBL-06, 21; ZBU-25) | có+tay | M, T |
| TC-ZB-B09 | Biên: cache rỗng / vừa nhặt hết | Nhặt cả hai món (hoặc bỏ qua hết rồi nhặt từng món) | Quay lại `CacheB` | Đã nhặt hết (`empty`): R5' không mời, chạm `CacheB` không mở dock. Mới nhặt một món (`partial`): chỉ còn card món kia (ZBL-07, 09, 18) | có+tay | M, T |
| TC-ZB-B10 | Biên: cache reset run mới | Run trước đã nhặt hết | `Về hub` → Boot → vào lại B | Cache lại `full` đúng 2 món (ZBL-19) | có (một phần) + tay | M, T |

## 5. G8 — O3 lưới: chạm chọn, chạm ô, xoay `1x2`, preview

Fixture ba lô 3×4 `proposed`. Để ép "cần xoay": ba lô hàng y=3 chỉ còn 1 hàng trống, nên sổ `1×2` đứng đặt (0,3) **ngoài biên**,
xoay thành `2×1` thì vừa (0,3),(1,3). Nếu ba lô thực tế còn nhiều chỗ, ghi lại vị trí chọn khác ở bước.

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-ZB-12 | ĐẠT (preview + xoay) | Card sổ, ba lô còn hàng y=3 trống | `Nhặt và xếp`; chạm `Xoay`; ngón đè (chưa nhấc) ô (0,3) | Sau `Nhặt và xếp`: dock lưới, dải S có sổ + `1×2` + tag "còn ở rương", nút `Xoay` hiện, ô y=3 gạch chéo (đứng). Sau `Xoay`: chip `2×1`, ô (0,3),(1,3) viền liền + tích, (2,3) gạch chéo, **chưa có thay đổi**. Ngón đè (0,3): bóng khung phủ (0,3),(1,3), dòng 2 `INVENTORY_PREVIEW_FITS_BACKPACK`; chưa đổi state (ZBU-27…29) | có (`test_ui_pickup_zone_b_grid_previews_rotates_and_commits_only_on_valid_release`) + tay | M, T |
| TC-ZB-13 | ĐẠT (đặt) | Như TC-ZB-12 đang đè (0,3) | Nhấc ngón ở (0,3) | Sổ nằm ngang ở ba lô (0,3),(1,3); dock đóng (cache hết) hoặc về card món còn lại; R4' `CARD_PLACED_CONFIRM_BACKPACK`; đúng một lần đặt; không O5 (ZBL-09; ZBU-31) | có+tay | M, T |
| TC-ZB-14 | ĐẠT (đặt vào Hộp, niêm) | Pickup đồng xu, Hộp còn (1,1) | Ngón đè Hộp (1,1) rồi nhấc | Đè: dòng 2 `INVENTORY_PREVIEW_FITS_NOTARY_BOX`. Nhấc: đồng xu vào Hộp, nhãn `đã niêm`; R4' `CARD_PLACED_CONFIRM_NOTARY_BOX`; không O5; Hộp đầy 4/4 nếu Manifest ở (1,0) (ZBL-11; ZBU-34) | có+tay | M, T |
| TC-ZB-15 | CẤM (auto) | Mọi bước G8 | Quan sát sau mỗi thao tác: chọn, xoay, nhấc sai chỗ, đóng | Không auto-swap, auto-drop, auto-sort, auto-seal; không bắt buộc kéo-thả pixel-perfect (chạm xuống + nhấc là đủ); mỗi lệnh chỉ đổi đúng món vừa chạm; Manifest không bị niêm lại/đẩy khỏi ô (ZBL-12, 22; ZBU-36; readiness G8 `BLOCKER`) | có (ZBL-22 ý, chưa rõ tên test — xem §11) + tay | M, T |
| TC-ZB-16 | CẤM (lưới che nguy hiểm) | Dock lưới mở, địch ≤ 9 m (S8 hoặc skirmish) | Quan sát HUD, nhân vật, đồng hồ hold | R2 đồng hồ, R1, H2, H5 không bị che; nhân vật ở tâm không bị che; dock chỉ chiếm vùng phải; một chạm D1 đóng dock và C1–C4 nhận chạm ngay (ZBU-40, 44; readiness G8 `BLOCKER`) | có (bố cục) + tay | M, T |
| TC-ZB-B11 | Sai chỗ giữ nguyên | Card sổ, chưa xoay | `Nhặt và xếp`; chạm (0,3) | Không commit; dòng 2 `tên sổ · INVENTORY_REASON_OUT_OF_BOUNDS`; sổ vẫn ở cache, vẫn ở `pickup`; chạm ô hợp lệ sau đó vẫn chạy (ZBL-08; ZBU-32) | có+tay | M, T |
| TC-ZB-B12 | Hủy: trượt ngón / chạm lại món / `Đóng` | Đang preview một ô | (a) Trượt ngón 30 px khi đang đè rồi nhấc; (b) chạm lại món đang chọn khi đã bấm `Xoay`; (c) `Đóng` trong dock lưới | (a) Bóng biến mất, không commit; (b) hủy xoay chờ, không commit; (c) về card cùng món, không đổi. **Ghi chú:** spec UX nói 30 px, tên test nói 16 px — ghi lại ngưỡng thực đo được (§14 mục 4) (ZBU-30, 35) | có+tay | M, T |
| TC-ZB-B13 | Ô bị chặn / Hộp đầy | Manifest niêm ở Hộp (1,0); pickup sổ | Ngón đè Hộp (1,1) rồi nhấc | Ô gạch chéo + icon × ở ô chặn; lý do `CELLS_OCCUPIED` hoặc `OUT_OF_BOUNDS`; nhấc không đổi; sổ vẫn ở cache (ZBL-10; ZBU-33) | có+tay | M, T |
| TC-ZB-B14 | Chế độ `view`: xoay món đã nhặt, rút khỏi Hộp | Sổ đứng ở ba lô (0,0); đồng xu đã niêm ở Hộp | (a) Chọn sổ → `Xoay` → chạm (0,0). (b) Xoay sổ ở (2,0). (c) Chọn đồng xu trong Hộp → chạm ô ba lô trống | (a) Đổi thành ngang (0,0),(1,0), không O5. (b) Không đổi, `OUT_OF_BOUNDS`. (c) Không đổi, `INVENTORY_REASON_WITHDRAW_LOCKED` (ZBL-13; ZBU-37…39) | có (`test_ui_pickup_zone_b_view_rotates_only_through_inventory_and_locks_withdraw`) + tay | M, T |
| TC-ZB-B15 | Món không thuộc ngăn / túi đeo chéo | Pickup bất kỳ | Thử đặt vào túi đeo chéo; thử nút `Xoay` ở card đồng xu | Túi đeo chéo chỉ đọc (hiện `sling_remedy`), không nhận loot (`WRONG_TARGET`); card đồng xu không có nút `Xoay` (ZBL-15; ZBU-36) | có (một phần) + tay | M, T |

## 6. G12 — S4/S5 → S3 quay A: patrol, landmark ngược, lane báo trước

Ở S03 chỉ có B (D bị chặn, gate D đọc được là bị chặn). Quay về A bắt đầu khi người chơi **rời `CalmZoneB`** lần đầu
(layout §5.5). Không chờ patrol xuất hiện.

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-ZB-17 | ĐẠT (cue patrol) | Trong `CalmZoneB`, gate mở, đã (hoặc chưa) mở cache | Đi ra khỏi `CalmZoneB` về phía gate; bấm giờ khi thoát vùng | Trong ≈ 2 giây: đèn `PatrolAlertLampB` mở dần ba phân đoạn (không chớp), H5 `HUD_ALERT_PATROL_B` + mũi tên quay về đèn; chưa thấy vệ binh patrol nào đã nhìn thấy trong khung; sau ≈ 2 giây vệ binh patrol vào khung từ phía ngoài khung, đi P0→P1→P2; R4' không có prompt combat (ENM-17; ZBU-18; VFX-03) | có (`test_patrol_cue_waits_two_seconds_before_the_brain_is_started`) + tay | M, T |
| TC-ZB-18 | ĐẠT (đường về A) | Patrol đang đi, HP bất kỳ | Chọn một trong hai: (a) lách nửa đông ngõ (x 5–8) về A; (b) đánh skirmish ngắn | (a) Về deck A không bị chặn, không gate thứ hai; (b) đánh thắng/rút thì đèn tắt. Cả hai: đèn tắt khi người chơi về deck A (x < 0), không địch theo vào A (layout §5.5.4; test flow patrol) | có (`test_flow_patrol_lamp_turns_off_for_down_withdrawn_and_deck_return`) + tay | M, T |
| TC-ZB-19 | ĐẠT (landmark ngược) | Trong `CalmZoneB`, rồi dọc đường về | Dừng ở tâm `CalmZoneB`, rồi ở sân phía tây, nhìn về phía trái-dưới màn hình | Thấy `SignToA` (mũi tên + hình đèn phao), `GateB`, mái đỏ, dây đèn lồng, `BeaconA` và cầu tàu A khi tới sân phía tây (đủ nhận ra hướng về A mà không cần minimap); không vật cao > 1 m che hướng về A. Ghi vị trí đứng + ảnh (layout §6.1; readiness G12) | có (vị trí marker: `test_zone_b_has_spec_markers_at_local_coordinates`) + tay | M, T |
| TC-ZB-20 | CẤM | Trên đường về A | Quan sát mọi lần địch xuất hiện (patrol) | Không địch spawn trong khung hoặc sau lưng; vệ binh patrol luôn vào từ ngoài khung **sau** cue ≥ 2 giây; không dead-end bắt buộc chết; không teleport/checkpoint/D extract (readiness G12 `BLOCKER`) | có (ENM-17, 18) + tay | M, T |
| TC-ZB-21 | CẤM | Trong B | Tìm vật/foreground che hết lối A hoặc làm mất hướng; tìm điểm extract ngoài A | Không marker/vật chắn mất route A; B không có nút/vùng extract; D vẫn bị chặn đọc được (không đi vào được) (readiness G12; BCN-37) | có (một phần: `test_zone_b_cover_and_blocked_route_have_honest_collision`) + tay | M, T |
| TC-ZB-B16 | Biên: không rời `CalmZoneB` | Trong `CalmZoneB` | Đứng 60 giây, mở/đóng cache, không ra khỏi vùng | Patrol **không** xuất hiện, không đèn, không prompt combat (vùng yên) (layout §5.4.3) | có+tay | M, T |
| TC-ZB-B17 | Biên: patrol chỉ một lần | Đã kích hoạt patrol một lần | Quay lại `CalmZoneB`, rời lần hai | Không cue/địch mới thứ hai (layout §5.5.1: một lần mỗi run) | có (một phần) + tay | M, T |
| TC-ZB-B18 | Biên: bỏ qua cache vs mở cache | Hai lần chạy, một lần mở cache, một lần bỏ qua | Rời `CalmZoneB` trong cả hai lần | Cue patrol giống hệt nhau (layout §5.5.1) | chỉ tay | M, T |
| TC-ZB-B19 | Biên: patrol bị đánh bại/rút | Patrol đang đi | Đánh tới khi nó rút hoặc gục | Đèn tắt, H5 trống, không patrol mới; đường A không đổi | có (như TC-ZB-18) + tay | M, T |

## 7. G14 — S8/S9 hold/board có địch lane B

Tiền điều kiện chung: đã về A, đã nhặt Manifest, đã gọi thuyền (O5 → `Gọi`), S7 ≈ 1.5 giây rồi S8 bắt đầu "còn 20 giây". Đứng
trong vòng beacon (bán kính 3.0 m). Đồng hồ hold của `ceil` giữ đúng quy tắc TC-LA-22. Theo combat §12.5 S03 **không có audio**:
cue là đèn + mũi tên sàn + H5 + chữ; ghi `KHÔNG TEST ĐƯỢC` cho phần "audio" của readiness G14 và đưa vào câu hỏi mở (§12).

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-ZB-22 | ĐẠT (cue trước địch) | S8 vừa vào, bấm giờ | Đứng trong vòng; quan sát đèn `LaneBAlertLamp`, H5, R4' | Ở t ≈ 0: đèn mở dần 3 phân đoạn trong ≈ 3 giây, H5 `HUD_ALERT_LANE_B` + mũi tên sàn từ miệng lane về `BeaconA`, R4' `EXTRACT_S8_LANE_ALERT` đúng một lần; **chưa có địch trong khung**; địch đầu (vệ binh) vào khung ở t ≈ 3 giây tức cue ≥ 2 giây trước (HLD-01, 02; ZBU-19; VFX-03) | có (HLD-02, `test_hold_director_emits_entry_only_after_actor_crosses_camera_inset`) + tay | M, T |
| TC-ZB-23 | ĐẠT (đợt hai) | S8, t ≈ 7 giây | Quan sát đèn lần hai và đốc công | Đèn lại mở dần ở t ≈ 7 giây; đốc công vào khung ở t ≈ 10 giây, vào cùng loại cue; tổng đúng 2 địch (1 vệ binh, 1 đốc công), đánh bại sớm cũng không thêm địch (HLD-03; ZBU-19) | có+tay | M, T |
| TC-ZB-24 | ĐẠT (telegraph trong vòng) | Địch đến vòng | Đứng trong vòng; thử (a) né, (b) giữ khiên, (c) đánh | Địch hold dùng cùng telegraph như B (quạt 0.8 s vệ binh, vạch charge đốc công, lane lệch tâm, chiếm ≤ 40% phần vòng trên deck — luôn còn dải ≥ 1.5 m trong vòng ngoài lane); cả hai đầu lane trong khung nhìn từ vòng; chỉ một địch ra wind-up tại một thời điểm (layout §6.2.4; ENM-10, 15; HLD-02, 03) | có (một phần) + tay | M, T |
| TC-ZB-25 | ĐẠT (boat_ready / board) | Hold chạy hết, còn địch | Đợi tới S9; vào `BoardZoneA`; chạm `Lên thuyền` | Hết 20 giây → S9: `HUD_OBJECTIVE_BOARD_BOAT`, `EXTRACT_S9_BOAT_READY`; không windup mới, đòn đang chạy xong thì địch rút về lane B, đèn tắt, H5 trống; `Lên thuyền` bật khi trong `BoardZoneA` kể cả khi địch còn sống; chạm → S10 đúng một lần (HLD-05, 06; ZBU-20) | có (`test_flow_zone_b_route_reaches_s10_with_cache_patrol_and_hold`) + tay | M, T |
| TC-ZB-26 | CẤM | S8 từ đầu đến hết | Ghi vị trí vào khung của mọi địch (cạnh nào, thời điểm); quay camera nếu có | Không địch spawn sau lưng, phía nước, hay trong khung; không địch xuất hiện ngoài lane B; địch vào khung ở **mép phải** màn hình tại thời điểm đã cue. Ghi y_norm vào khung (ước tính spec: 0.83 ở 4:3, 0.73 ở 16:9) để TASK-88 đối chiếu (layout §6.2.3; readiness G14 `BLOCKER`) | có (`test_hold_director_emits_entry_only_after_actor_crosses_camera_inset`, HLD-08) + tay | M, T |
| TC-ZB-27 | CẤM | S9, địch còn sống | Đứng trong `BoardZoneA` 5 giây không chạm; thử rời khỏi vòng; lặp 60 giây ngoài vòng | Không auto-board, không auto-win, không hủy thuyền, không checkpoint; chỉ chạm `Lên thuyền` mới S10; địch không mở/đóng state extract (hold không tự thắng) (readiness G14 `BLOCKER`; BCN-21, 23; HLD-06) | có (BCN-21, 23, HLD-06) + tay | M, T |
| TC-ZB-B20 | Biên: rời vòng khi hold | S8 còn 14 giây | Rời vòng 3 giây rồi quay lại | Đồng hồ hold tạm dừng (icon tạm dừng, `EXTRACT_S8_HOLD_PAUSED`) rồi chạy tiếp, không reset; **đồng hồ địch không dừng**: đợt hai vẫn tới đúng thời điểm (TC-LA-B11; combat §7.1.2) | có (BCN-18, 19, HLD-02) + tay | M, T |
| TC-ZB-B21 | Biên: mở overlay khi địch tới | Có sổ trong inventory, cache còn món (hoặc dùng R5'/H3 mở lưới ở A) | Mở dock lưới ở S8 khi vệ binh ≈ 5 m; để vệ binh windup; thử chạm D1 | D1 hiện `HUD_DANGER_NEAR` rồi `HUD_DANGER_WINDUP`; dock vẫn mở (thế giới không dừng, không bỏ món, không commit); đòn trúng → H2 giảm, dock vẫn mở; chạm D1 → dock đóng, C1–C4 nhận chạm ngay (ZBU-41…44; combat §12.2) | có (`test_ui_combat_hud_hides_danger_when_an_overlay_closes`) + tay | M, T |
| TC-ZB-B22 | Biên: khiên + giữ + mở dock | Đang giữ C3 | Mở dock bằng H3 | Khiên hạ; C1–C4 ẩn; phím K bỏ qua tới khi đóng dock (ZBU-45; CMB-20) | có (`test_overlay_lowers_guard_and_ignores_combat_actions`) + tay | M, T |
| TC-ZB-B23 | Biên: 4:3, cụm nút che điểm vào | Cửa sổ 1280×960 (4:3) | Quan sát điểm địch vào khung (mép phải, y_norm ≈ 0.83) so với cụm nút | Ghi lại: điểm vào có bị cụm nút C1–C4 che không; nếu che, vẫn phải thấy đèn + mũi tên + H5. **Không tự kết luận no-go**: ghi vào bug/câu hỏi mở (UX §9 câu 3; layout §10 câu 2) | chỉ tay | M (4:3), T nếu máy có tỉ lệ 4:3 |
| TC-ZB-B24 | Biên: đưa app xuống nền | S8, địch trong khung | Chuyển tab ≥ 10 giây rồi quay lại | Khiên đã hạ, C3 sẵn; không đòn "bù" trúng ngay; S8 giảm ≤ 0.25 giây ở tick đầu (BCN-34; ZBU-09) | có (BCN-34) + tay | M, T |
| TC-ZB-B25 | Chết trong hold | S8, HP thấp | Để địch hold đánh tới HP 0 giữa hold; thử rồi thử lại ở S9 | O6 stub (xem TC-ZB-B05); địch dừng `idle`, không đợt thêm (đốc công không spawn nếu mới t < 10 giây); không S10, không "success", không checkpoint; hold không tiếp tục đếm (HLD-07; CMB-24; readiness G14: death vẫn success là `BLOCKER`) | có (HLD-07, `test_flow_hp_zero_opens_stub_then_returns_to_boot_without_summary`) + tay | M, T |

## 8. Ảnh thang xám và màn nhỏ 640×360

Nguồn ảnh: `game-shit/build/lookdev/zone_b_game.png`, `zone_b_gray.png`, `zone_b_phone.png` (bản chụp greybox/lookdev sinh bởi gate,
**chưa** có HUD/card thật) kèm ảnh chụp tay trên staging khi cần. Ảnh chụp tay đặt tên `zb-<case>-<channel>-<version>.png` trong thư mục
phiên chạy (không thêm vào repo trừ khi card sau cho phép). Khi ảnh lookdev chưa có phần HUD/card/dock, ghi `KHÔNG TEST ĐƯỢC` cho phần
đó và dùng ảnh chụp tay; không coi ảnh lookdev là bằng chứng cho card/dock.

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-ZB-G01 | ĐẠT (telegraph, thang xám) | `build/lookdev/zone_b_gray.png` + ảnh tay chụp lúc quạt vệ binh/vạch charge hiện | Xem ảnh xám (hoặc bật bộ lọc thang xám của OS/trình duyệt) | Vòng giữ ngõ, quạt đòn, vạch charge và chevron vẫn phân biệt được với sàn: bằng hình (vòng, chevron, kết cấu sàn lane lát ván), không chỉ màu; mái đỏ ngõ không bị nhầm là cảnh báo nguy hiểm (readiness G6; layout §6.1; art contract `signal_danger`) | có (`test_zone_b_probes_keep_visible_surfaces_and_signal_lane`, `test_charge_lane_clamps_progress_and_reveals_chevrons`) + tay | M |
| TC-ZB-G02 | ĐẠT (640×360) | Cửa sổ trình duyệt 640×360 (hoặc điện thoại nhỏ) + `zone_b_phone.png` | Đọc HUD, nút C1–C4, H2, thuốc, telegraph | Vùng chạm mới ≥ 48×48 px thật, chữ mới ≥ 12 px thật; C1–C4 không che H2/H1/telegraph; dòng cảnh báo vẫn đọc được; telegraph vẫn thấy (ZBU-02; readiness G6) | có (`test_ui_combat_hud_s03_text_uses_the_reference_font_floor`, `test_ui_combat_hud_uses_s03_combat_regions_and_hold_input`) + tay | T |
| TC-ZB-G03 | ĐẠT (card, thang xám + 640×360) | Card đồng xu và card sổ, chụp tay | Xem ảnh xám 1280×720 và 640×360 | Claim, rarity, footprint, kết quả vừa ô vẫn phân biệt được không cần màu; chữ NAME/FOOTPRINT/USE/CLAIM/RARITY/LORE không bị cắt, không vượt giới hạn ký tự (24/32/64) (ZBU-24; strings §S03) | có (`test_ui_pickup_zone_b_s03_text_uses_the_reference_font_floor`) + tay | M, T |
| TC-ZB-G04 | ĐẠT (lưới, màn nhỏ) | Dock lưới mở ở 640×360, preview hợp lệ rồi không hợp lệ | Chụp tay | Ô lưới ≥ 48 px, viền liền vs gạch chéo phân biệt trong thang xám, lý do không che nhãn ô ở 1280×720 (ZBU-02, 29; `test_ui_pickup_zone_b_invalid_preview_status_does_not_cover_grid_labels_at_1280x720`) | có (một phần) + tay | M, T |
| TC-ZB-G05 | ĐẠT (đèn patrol/lane, thang xám) | Đèn `PatrolAlertLampB` và `LaneBAlertLamp` ở trạng thái armed/active | Chụp tay lúc 1/3 và 3/3 phân đoạn, xem thang xám | Số phân đoạn mở đếm được (1 so với 3), không dựa vào màu hoặc nhấp nháy; có mũi tên sàn/H5 kèm (VFX-03; ZBU-18, 19) | có (`test_lane_alert_counts_three_physical_segments`) + tay | M, T |
| TC-ZB-G06 | ĐẠT (cue lane lúc hold) | Hold S8, cue t=0 và địch vào ở t=3 | Chụp tay (thang xám, 640×360) | Cue = đèn + mũi tên + H5 (không audio) đủ để biết lane nào địch sẽ tới trước khi địch vào khung; H5 không bị cụm nút che (ZBU-03; layout §6.2.5) | chỉ tay | M, T |

## 9. Kịch bản đầu-cuối (DoD S03)

### 9.1 Z1 — Boot → … → khu A → Manifest → B → skirmish → loot (xoay `1x2`) → về A → hold có địch → board → S10

Hai bản chạy: **Z1-M** (chuột) và **Z1-T** (cảm ứng, điện thoại ngang, bật toàn màn hình itch.io, ghi model máy + trình duyệt).
Là kiểm tra chức năng của QA, **không** thay C1/C2 của playtest. Tiền điều kiện: mở bản `web-staging`, ghi version và `AppEnv.channel =
staging` từ nhãn build ở Boot, tải lại trang (phiên mới), kit mặc định, không dùng debug menu.

| Bước | Hành động | Kết quả mong đợi | Case |
|---|---|---|---|
| 1 | Boot: chạm nút vào game → S1 → `Vào cảng` | S1 rồi khu A (S2), HUD E0 `HUD_OBJECTIVE_TAKE_MANIFEST` | TC-LA-01, 06 |
| 2 | Đi tới bàn dispatch, nhặt Manifest vào ba lô (chạm ô hợp lệ) | E1, `HUD_OBJECTIVE_DELIVER_PIER_A`; callable | TC-LA-08 |
| 3 | Đi theo lối B vào ngõ; đọc vệ binh ở post | Vệ binh telegraph; `HUD_OBJECTIVE_CROSS_TAX_POST`, prompt vệ binh một lần | TC-ZB-01, 02 |
| 4 | Skirmish vệ binh: né, khiên, đánh; (nếu thương) dùng thuốc | Có telegraph trước mọi đòn; thuốc hồi tới ≤ 100, badge giảm | TC-ZB-02, 03, B03 |
| 5 | Qua quảng, skirmish đốc công trong lane; vệ binh/đốc công rút hoặc gục | Vạch charge 0→1 trước đòn; gate B mở; objective đổi `HUD_OBJECTIVE_DELIVER_PIER_A` | TC-ZB-04, G12 setup |
| 6 | Vào `CalmZoneB`, tới `CacheB`, mở card đồng xu; chạm chip sổ; `Nhặt và xếp` sổ | Card đủ thứ tự; sổ `1×2` có tag `xoay được` | TC-ZB-07, 08 |
| 7 | Với sổ: chạm `Xoay`; đè rồi nhấc ô (0,3) (hoặc ô hợp lệ khác nếu ba lô khác); sau đó đồng xu vào Hộp (1,1) hoặc `Bỏ qua` | Preview `2×1`, đặt đúng một lần, `CARD_PLACED_CONFIRM_*`; không auto-seal/sort | TC-ZB-12, 13, 14 |
| 8 | Rời `CalmZoneB`; xem đèn patrol; (a) lách hoặc (b) skirmish; về deck A | Đèn mở dần, patrol vào sau ≈ 2 giây; về A không bị chặn; đèn tắt ở A | TC-ZB-17, 18, 19 |
| 9 | Trong vòng beacon: `Gọi thuyền` → `Gọi` | S7 → S8 "còn 20 giây" | TC-LA-14, 19 |
| 10 | S8: quan sát đèn lane, 2 địch; né/khiên/đánh trong vòng; thử rời vòng 3 giây | Cue t=0, vệ binh t≈3, đốc công t≈10; hold tạm dừng/tiếp; địch không sau lưng | TC-ZB-22, 23, 24, B20, 26 |
| 11 | S9: địch rút; đi tới `BoardZoneA`; chạm `Lên thuyền` | S10 đúng một lần dù còn địch | TC-ZB-25, 27 |
| 12 | S10: đọc `Đã giữ` (đồng xu, sổ nếu nhặt, vật hồi phục còn lại), nhóm `Vật chứng` (Manifest), không nhóm `Đã mất` | Món đã nhặt có trong `Đã giữ`; món còn ở cache không hiện; không giá/điểm/thời gian/route (S10; ZBL-20, 21; BCN-35) | TC-LA-26 mở rộng |
| 13 | Chạm `Về hub` | Về Boot; vào lại thấy phiên mới (không lưu tiến trình) | TC-LA-B14 |

Điều kiện đạt: cả 13 bước đạt ở Z1-M **và** Z1-T. Z1-T thêm: mọi chạm bằng ngón, joystick không che C1–C4/R5', không cần zoom trình duyệt,
không cuộn trang itch thay vì game, giữ C3 bằng ngón không bị nhả khi ngón trượt ra ngoài nút (ZBU-07), xoay máy không phá bố cục.

### 9.2 Z2 — Regression rút sớm S02 (không đi B)

Tiền điều kiện như Z1. Chạy lại **C1** của [test plan vòng A](loop-a-early-extract-test-plan.md) §5, 13 bước, nhưng đọc thêm các điểm đã đổi vì S03:

| Bước | Hành động | Kết quả mong đợi (khác với TC-LA nếu có) | Case |
|---|---|---|---|
| 1…9 | C1 bước 1–9 (không đi vào B; không nhặt cache) | Giống TC-LA; không HUD combat cản joystick/nút ngữ cảnh trước khi có địch | TC-LA-01…19 |
| 10 | S8: rời/vào vòng, đứng đợi | Hold tạm dừng/tiếp **đúng như TC-LA-B11**; **khác S02:** có địch lane B (cue lamp rồi vệ binh ≈ 3 s, đốc công ≈ 10 s) — TC-LA-24 ("không địch") **không áp dụng** từ S03 trở đi, thay bằng TC-ZB-22…26 | TC-LA-B11, 22, TC-ZB-22…26 |
| 11 | S9: tới `BoardZoneA`, `Lên thuyền` | S10 một lần, địch không chặn | TC-LA-23, TC-ZB-25 |
| 12 | S10 | Không nhóm `Đã mất`; không phạt vì bỏ B; không điểm/route | TC-LA-26, 12 |
| 13 | `Về hub` | Về Boot; phiên mới | TC-LA-B14 |
| + | Gate A↔B | Không có gate/route bắt buộc đi B; extract chỉ ở A; `PROMPT_ROUTE_EXTRACT_NOW` vẫn có | TC-LA-08, 21, TC-ZB-21 |
| + | Một mô phỏng "chạy hết hold với HP 0" | HP 0 ở A cũng ra stub (không S10) | TC-ZB-B05 |

Một bước sai là `NOT READY` (hoặc `BLOCKER` nếu trúng cột `BLOCKER`) kèm mẫu bug ở §12.

## 10. Chỉ staging và production (tách riêng)

Debug menu và env badge không thuộc spec combat/loot/UX khu B. Dùng cùng khung như
[plan vòng A §9](loop-a-early-extract-test-plan.md): nếu build staging không có debug menu, ghi `KHÔNG TEST ĐƯỢC` theo
[phiếu quan sát](../playtest-observation-sheet.md) §1 thay vì bịa đường tắt.

| Case id | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|
| TC-ZB-28 | Mọi màn S03 ở 1280×720 và 640×360 | Đo vùng chạm, chữ, ô lưới; xem thang xám | C1 128×128, C2/C3 112×112, C4 96×96, R5' 224×112, R3 96×96 ở 1280×720; không rect giao nhau hoặc giao vùng joystick; ≥ 48×48 / chữ ≥ 12 px ở 640×360; không phần tử HUD ở dải x ≥ 1216, y_norm 0.55–0.80 trong S8 (ZBU-01…03, 50) | có (`test_ui_combat_hud_uses_s03_combat_regions_and_hold_input`, `test_ui_pickup_zone_b_dock_uses_the_specified_right_side_regions`) + tay | P, M, T |
| TC-ZB-S01 | Build staging | Mở Boot rồi HUD B | Nhãn `AppEnv.channel = staging` + version hiện, không che nút/ô lưới/H5/D1 | chỉ tay | S-only |
| TC-ZB-S02 | Build production (tag) | Tìm debug menu, nạp HP/loadout | Không badge staging, không debug menu, không đường nạp HP/cache/state | chỉ tay | P-only |
| TC-ZB-S03 | Staging + debug menu (nếu có) | Nạp "HP thấp", "sau skirmish", "ở S8" để rút ngắn | State nạp trùng state flow thật (cùng HUD/beacon/D1); kết quả TC-ZB-B05, B21, B25 giống chạy thật; fixture **không** thay Z1 | chỉ tay | S-only |

## 11. Bảng truy vết case ↔ test headless

Tên test thật nằm trong `game-shit/game/tests/unit/`. Cột "Phần chưa chứng minh" là chỗ test hiện có không bao phủ spec; case tay vẫn bắt buộc.
Case không có hàng trong bảng này hoặc ghi `chỉ tay` là chưa có test tự động.

| Spec | Test thật (`file::tên` hoặc file) | Case tay | Phần chưa chứng minh |
|---|---|---|---|
| CMB-01…04 | `test_combat.gd::test_health_damage_heal_clamp_and_depleted_once` | TC-ZB-B03, B05 | — |
| CMB-05…07 | `test_combat.gd::test_attack_assist_hits_once_and_ignores_enemy_behind` (+ `…ignores_withdrawing_and_down_enemies`, `…breaks_equal_distance_ties…`) | TC-ZB-03, 18 | Cảm giác tầm/hướng nhắm chỉ qua tay |
| CMB-08…15 | `test_combat.gd::test_dodge_iframe_guard_arc_and_chip_damage`, `…test_post_hit_blocks_repeat_and_remedy_consumes_after_channel`, `…test_large_delta_dodge_exposes_only_one_clamped_step_of_motion` | TC-ZB-03, B03 | Không đo trên thiết bị cảm ứng |
| CMB-16…19 | `test_combat.gd::test_post_hit_blocks_repeat_and_remedy_consumes_after_channel`, `…test_remedy_refuses_empty_or_full_without_mutating_inventory` | TC-ZB-B03, B04 | — |
| CMB-20, 22 | `test_combat.gd::test_overlay_lowers_guard_and_ignores_combat_actions`, `…test_attack_buffer_only_accepts_the_final_window` | TC-ZB-B22 | — |
| CMB-23 | (InputMap: không có test riêng trong danh sách đã đọc) | TC-ZB-28 | **Chưa rõ** — test-engineer xác nhận (§14 mục 1) |
| CMB-24 | `test_flow_zone_b.gd::test_flow_hp_zero_opens_stub_then_returns_to_boot_without_summary` | TC-ZB-B05, B06, B25 | Không kiểm "không file mới trong `user://`" |
| CMB-25 | `test_inventory.gd` (hàm `commit_consume` WRONG_SOURCE: cần xác nhận tên) | TC-ZB-B03 | Chưa xác nhận tên test (§14 mục 1) |
| ENM-01…03, 09 | `test_enemy_brain.gd::test_perception_keeps_last_known_and_requires_arc_or_proximity` | TC-ZB-01, B01, B02 | Cover thật trong scene B chỉ có tay |
| ENM-04…05, 15, 16, 18 | `test_enemy_brain.gd::test_guard_telegraphs_before_release_and_needs_camera`, `…test_token_allows_only_one_windup_and_invalid_data_is_rejected` | TC-ZB-02, 05, 24 | ENM-18 (1000 bước ngẫu nhiên): chưa xác nhận có test tên riêng |
| ENM-06…08 | `test_enemy_brain.gd::test_guard_shield_blocks_front_but_not_side_or_recover`, `…test_downed_actor_leaves_combat_target_group_and_disables_collision` | TC-ZB-03, 18 | — |
| ENM-10…14 | `test_enemy_brain.gd::test_foreman_charge_locks_lane_and_does_not_hit_a_player_who_leaves`, `…test_charge_ignored_hits_continue_but_applied_or_blocked_hits_finish`, `…test_charge_knockback_is_lateral_unblocked_and_forward_when_guarded` | TC-ZB-04 | — |
| ENM-17 | `test_enemy_director.gd::test_patrol_cue_waits_two_seconds_before_the_brain_is_started` | TC-ZB-17, 20 | — |
| HLD-01…08 | `test_enemy_director.gd::test_hold_director_shares_one_token_pool_across_both_spawned_enemies`, `…test_hold_director_emits_entry_only_after_actor_crosses_camera_inset`, `…test_enemy_scenes_have_visual_slots_and_load` | TC-ZB-22…27, B25 | HLD-04 (hold lần hai), HLD-07: chưa xác nhận test tên riêng |
| VFX-01…03 | `test_vfx_telegraphs.gd::test_charge_lane_clamps_progress_and_reveals_chevrons`, `…test_hold_ring_exposes_idempotent_guard_api`, `…test_lane_alert_counts_three_physical_segments` | TC-ZB-04, G01, G05 | Không đo thang xám/độ đọc |
| ZBL-01…22 | `test_inventory.gd` (một phần), `test_ui_pickup_zone_b.gd` (card, xoay, view, cancel) | TC-ZB-07…15 | ZBL-02 (cache full lúc load), ZBL-14, ZBL-19, ZBL-20, ZBL-21: chưa xác nhận test tên riêng |
| ZBU-01…03, 50 | `test_ui_combat_hud.gd::test_ui_combat_hud_uses_s03_combat_regions_and_hold_input`, `test_ui_pickup_zone_b.gd::test_ui_pickup_zone_b_dock_uses_the_specified_right_side_regions`, `…s03_text_uses_the_reference_font_floor` | TC-ZB-28, G02, G03 | Không đo 4:3/21:9 trong cả hai file |
| ZBU-04…14 | `test_ui_combat_hud.gd::test_ui_combat_hud_projects_health_actions_warning_and_stub`, `…remedy_refusals_show_localized_status_without_replacing_warning`, `…remedy_channel_and_each_interruption_show_status`, `…normal_root_passes_r6_touch_drag_to_joystick` | TC-ZB-03, B03, B04, G02 | ZBU-07/09 (giữ khiên bằng ngón thật, xuống nền) chỉ tay |
| ZBU-15…20 | `test_flow_zone_b.gd::test_flow_zone_b_route_reaches_s10_with_cache_patrol_and_hold` (một phần), `test_ui_combat_hud.gd::…projects_health_actions_warning_and_stub` | TC-ZB-01, 17, 22, 25 | H5/mũi tên về đèn: chỉ tay |
| ZBU-21…39 | `test_ui_pickup_zone_b.gd::test_ui_pickup_zone_b_grid_previews_rotates_and_commits_only_on_valid_release`, `…dragging_outside_pressed_cell_cancels_pickup`, `…dragging_sixteen_pixels_or_button_pressed_cancels_pickup`, `…touching_selected_item_cancels_pending_rotation_without_commit`, `…view_rotates_only_through_inventory_and_locks_withdraw`, `…grid_renders_read_only_sling_remedy` | TC-ZB-07…15, B12 | Spec ZBU-30 = 30 px, test = 16 px: **ngưỡng lệch** |
| ZBU-40…45 | `test_ui_combat_hud.gd::test_ui_combat_hud_hides_danger_when_an_overlay_closes`, `test_flow_loop.gd::test_flow_overlay_keeps_world_actions_running_but_blocks_new_combat_input`, `test_ui_pickup_zone_b.gd::…open_card_passes_r6_touch_and_drag_to_joystick` | TC-ZB-06, 16, B21, B22 | — |
| ZBU-46…49 | `test_ui_combat_hud.gd::test_ui_combat_hud_back_requests_boot_only_after_depleted_delay`, `test_flow_zone_b.gd::test_flow_hp_zero_opens_stub_then_returns_to_boot_without_summary` | TC-ZB-B05, B06 | O5 mở + HP 0 (ZBU-49): chưa xác nhận |
| Layout §3–§4 (marker), §5, §6 | `test_world_zone_b_flooded_market.gd` (5 test: marker, cover/collision, instance offset, probe, facade) | TC-ZB-19, 21, B01 | Landmark thấy được từ vị trí đứng: chỉ tay |
| Flow vòng đầy đủ | `test_flow_loop.gd::test_flow_loop_reaches_success_summary_through_context_signals`, `…test_flow_boot_to_success_summary_with_preinjected_session`, `test_flow_zone_b.gd::test_flow_zone_b_route_reaches_s10_with_cache_patrol_and_hold` | TC-ZB-Z1M, Z1T, Z2 | Test dùng signal Area3D, không chạm thật |
| Patrol/đèn | `test_flow_zone_b.gd::test_flow_patrol_lamp_turns_off_for_down_withdrawn_and_deck_return` | TC-ZB-17, 18, B19 | — |
| Bán kính beacon/board, hold | `test_extract_pier_a_flow.gd` (BCN-17…23) | TC-ZB-27, B20 | — |
| Env badge | `test_boot_scene.gd::test_boot_scene_shows_build_label` | TC-ZB-S01 | — |

Cột "chưa xác nhận test tên riêng": tôi chỉ đọc tên hàm `test_*` ở các file S03, không đọc nội dung; test-engineer đối chiếu trước khi ghi `có`.

## 12. Mẫu bug report

Dùng đúng [mẫu ở plan vòng A §10](loop-a-early-extract-test-plan.md), thêm hai dòng đặc thù S03:

```text
Build channel: staging (web-staging itch.io) / production   Version: <tên pre-release staging hoặc tag production>
Thiết bị / trình duyệt / đầu vào: chuột | cảm ứng   Tỉ lệ khung: 16:9 | 4:3 | 21:9 | 640×360
Case id: TC-ZB-xx / TC-ZB-Bxx / TC-ZB-Gxx / TC-ZB-Zx bước n
Tiền điều kiện (state, HP, thuốc, fixture, cách nạp):
Bước tái hiện:
Kết quả mong đợi (trích CMB/ENM/HLD/ZBL/ZBU-xx hoặc gate):
Kết quả thực tế (kèm ảnh/video; với telegraph ghi thời gian từ lúc quạt/vạch hiện tới lúc đòn trúng):
Địch/vị trí liên quan (tax_guard | foreman | patrol | hold; lane/post):
Severity: BLOCKER / MUST_FIX / MINOR
Tái hiện: n/m lần cùng build
```

Severity gợi ý (readiness §6, §9): **BLOCKER** = damage không báo trước/địch sau lưng hoặc ngoài camera (G6, G12, G14), overlay làm telegraph
vô hình (G6), rarity/claim lẫn nhau hoặc tự tịch thu (G7), auto-drop/swap/sort/seal hoặc bắt buộc drag (G8), dead-end bắt buộc chết hoặc teleport/
checkpoint (G12), hold board tự thắng hoặc death vẫn thành success/S10 (G14), địch chặn board. **MUST_FIX** = thiếu/sai key chữ, cue chỉ bằng màu,
vùng chạm < 48 dp, sai thứ tự card, số giây/cue < 2 giây, dock che H2/H5. **MINOR** = lỗi trình bày không đổi state.
Dừng phiên khi trúng BLOCKER: tái hiện một lần, mở một card (readiness §9).

## 13. Phiếu kết quả gate S03 (DoD)

Ghi `READY` / `NOT READY` / `BLOCKER` / `KHÔNG TEST ĐƯỢC` theo [build-readiness](../vertical-slice-build-readiness.md) §9. Mỗi gate `READY` chỉ khi
mọi case của nó đạt trên bản web-staging và cả hai bản Z1 đạt.

| Gate | Case phải đạt | Z1-M | Z1-T | Build (channel + version) | Trạng thái |
|---|---|---|---|---|---|
| G6 | TC-ZB-01…06, B01…B06, G01, G02 | | | | |
| G7 | TC-ZB-07…11, B07…B10, G03 | | | | |
| G8 | TC-ZB-12…16, B11…B15, G04 | | | | |
| G12 | TC-ZB-17…21, B16…B19, G05 | | | | |
| G14 (có địch) | TC-ZB-22…27, B20…B25, G06 | | | | |
| DoD | TC-ZB-Z1M, Z1T, Z2, TC-ZB-28 | | | | |

Truy vết gate → nguồn:

| Gate | Spec chính | Case |
|---|---|---|
| G6 | combat §3–§5, §13; layout §5.1–§5.4; UX §3, §5.1 | TC-ZB-01…06, B01…B06, G01, G02 |
| G7 | loot §7, §8; UX §5.4; strings §S03 | TC-ZB-07…11, B07…B10, G03 |
| G8 | loot §8, §9; UX §4, §5.5 | TC-ZB-12…16, B11…B15, G04 |
| G12 | layout §5.5, §6.1; combat §5.3 | TC-ZB-17…21, B16…B19, G05 |
| G14 | combat §7; layout §6.2; UX §5.2, §5.6 | TC-ZB-22…27, B20…B25, G06 |

Playtest: khi chạy phiên có người chơi, dùng nguyên [phiếu quan sát](../playtest-observation-sheet.md) và mã **P3/P8c** (vì S03 đã có địch lane B), **P7**
cho cue; **không thêm metric mới**. Các phiên có người chơi là card riêng.

## 14. Phần đưa cho test-engineer (follow-up, chưa làm)

1. **Xác nhận tên test cho các hàng "chưa xác nhận" ở §11:** ENM-18, HLD-04, HLD-07, ZBL-02/14/19/20/21, CMB-23 (InputMap), CMB-25, ZBU-49.
2. **Test "không file mới trong `user://`"** cho O6 (ZBU-48) và `Về hub` (TC-LA-B14), dùng chung tiện ích kiểm thư mục.
3. **Kiểm độ dài chuỗi S03:** strings §S03 nói độ dài đếm tay, không có test đo; thêm test so `strings.csv` với giới hạn (nút combat 10, tag 16, card B 24/32/64) và nhãn `tr(key)` không rỗng.
4. **Đồng bộ ngưỡng hủy kéo:** UX spec ZBU-30 ghi 30 px, test hiện đặt tên 16 px; test-engineer/ui-programmer báo spec hay code đúng, QA chỉ ghi giá trị đo thực.
5. **Đo bố cục 4:3/21:9:** điểm địch hold vào khung vs cụm nút (TC-ZB-B23) cần test đo khung trên greybox, vì plan chỉ quan sát tay.
6. Mọi test mới theo charter QA: failing-then-passing, headless.

## 15. Câu hỏi mở / ghi chú cho Producer

- **O6 chạm hay tự về Boot:** combat §4.4.5 nói "chạm màn hình không làm nhanh" và tự về Boot sau 2.5 s; UX spec §5.7 mặc định chờ chạm sau 2.5 s (nút bị khóa lúc đầu). Plan theo UX (TC-ZB-B05 kiểm nút bị khóa rồi chạm). Nếu Producer chọn tự về Boot, sửa TC-ZB-B05.
- **Audio cho G14:** readiness G14 ghi "light/audio/telegraph", S03 không có audio (combat §12.5). Plan chỉ kiểm đèn + mũi tên + H5; phần audio = `KHÔNG TEST ĐƯỢC` cho tới khi có audio.
- **Hold ngắn so với đường địch:** layout §10 câu 1 cảnh báo đốc công tới `HoldChargeLane` ở t ≈ 17–23 s trên một số điện thoại, có thể không kịp charge trước `boat_ready`. TC-ZB-23/24 ghi lại thời điểm đốc công thực sự vào lane; nếu không bao giờ charge được thì ghi `MUST_FIX` kèm số đo, không tự sửa số.
- **Điểm vào khung ở 4:3:** TC-ZB-B23 chỉ ghi nhận, chưa phán định.
- **`starter_remedy` đã niêm không dùng được:** S03 chỉ có một lần hồi từ `sling_remedy` (combat §12.3); TC-ZB-B03 giả định đúng một thuốc.
- **Stub nói "kể cả đồ đã niêm":** câu `COMBAT_STUB_HP_ZERO` có vẻ trái lời hứa Hộp Công Chứng (decision TASK-84). Plan chỉ kiểm câu hiển thị, không đánh giá lời hứa.
- **TC-LA-24 (không địch) hết hiệu lực** từ S03; Z2 đã thay bằng TC-ZB-22…26. Plan vòng A cần ghi chú đó trong một card docs.
- **Chưa có lượt lore-reviewer** cho các spec S03 nguồn; nếu lore-reviewer đổi tên/chữ, đồng bộ lại cột kết quả mong đợi.

## 16. Ngoài phạm vi

Viết code test; chạy phiên playtest; G9–G11, G15 full-route và G16–G18 (S04–S05); recovery/death thật (S11/S12); route D và gate quay B từ D; audio;
cân bằng số liệu (HP, sát thương, wind-up, hold 20 s); lưu/tải tiến trình thật.
