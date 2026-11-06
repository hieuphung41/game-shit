# Test plan — Vòng A rút sớm (S02): G1, G2, G4, G5, G11 (`Gọi thuyền`), G13, G14 (không địch), G15

**Trạng thái:** test plan `proposed`. Case id `TC-LA-xx` và mọi chi tiết kênh build là `proposed` trừ khi ghi nguồn.
Plan không viết code test (card của test-engineer), không chạy phiên playtest và không định nghĩa luật hay metric mới.
Đây là checklist DoD của sprint S02: mỗi gate chỉ `READY` khi mọi case của nó đạt trên bản web-staging.

**Nguồn luật:** [Build-readiness](../vertical-slice-build-readiness.md) §6 (G1–G15), §7 (C1), §8, §9 ·
[Spec beacon/extract](../specs/beacon-extract-state-spec.md) (BCN-01…37, §12–§13) ·
[Spec luồng cảm ứng vòng A](../specs/loop-a-ux-flow-spec.md) (UXA-01…45, §9–§10) ·
[Chuỗi Contract 1](../specs/contract-1-strings.md) · [Test plan inventory](inventory-grid-test-plan.md) (định dạng,
mẫu bug) · [Phiếu quan sát](../playtest-observation-sheet.md) §4 (C1). Tên theo glossary: `retriever`, `backpack`,
`notary_box`, `sling_pouch`, `manifest_r17`, `extract_pier_a`, `AppEnv.channel`.

## 1. Cách đọc bảng

- **Case id** `TC-LA-xx` = case đạt (`ĐẠT`) hoặc case cấm (`CẤM`, lấy từ cột `BLOCKER` của readiness §6). `TC-LA-Cx` =
  kịch bản C1 trọn vòng. `TC-LA-Bx` = case biên. `TC-LA-Sx` = chỉ staging.
- **Tự động?** `có` = đã có (hoặc test-engineer cần có) test headless tên ở §6; `có+tay` = có test và QA vẫn chạy lại
  tay trên build; `không` = chỉ làm tay.
- **Kênh:** mọi case chạy tay trên bản **web-staging** `https://hieuphung1qaz.itch.io/25d-game` (`AppEnv.channel =
  staging`, build từ nhánh `main`). Cột `P` = case cũng phải chạy được trên production (tag) bằng flow thật; `S-only` =
  cần debug menu/fixture, **không** chạy trên production (§5).
- **Chuột** = trình duyệt desktop; **cảm ứng** = trình duyệt điện thoại, ngang 1280×720 hoặc tương đương. Mỗi case
  `ĐẠT` ghi `M` (chuột) và `T` (cảm ứng) trong cột kênh khi cần chạy cả hai.
- "Không đổi" = ảnh chụp ba lô/Hộp/túi đeo chéo trước–sau giống hệt, ba state flow (desk/contract/extract) giống hệt, không
  hiện chữ hay hiệu ứng mới (theo định nghĩa của beacon spec §12 và UX spec §9).
- Số giây hold lấy từ `EXTRACT_HOLD_SECONDS = 20` (`proposed`, trong 15–25 giây của G14); ack S7 = 1.5 giây. Khi
  chạy tay, sai số đo bằng đồng hồ ≤ ±1 giây là chấp nhận được; số trên HUD phải tuân đúng quy tắc `ceil`.
- Mỗi lần chạy ghi **build channel + version** (tên pre-release staging, hiện ở badge/nhãn build của Boot) vào đầu phiếu.

## 2. Ma trận bao phủ nhanh

| Gate | Case đạt | Case cấm | Case biên |
|---|---|---|---|
| G1 | TC-LA-01, 02 | TC-LA-03 | — |
| G2 | TC-LA-04, 05, 06 | TC-LA-07 | TC-LA-B01, B02, B03 |
| G4 | TC-LA-08, 09 | TC-LA-10, 11 | TC-LA-B04, B05, B06 |
| G5 | TC-LA-12 | TC-LA-13 | TC-LA-C1M, C1T |
| G11 (`Gọi thuyền`) | TC-LA-14 | TC-LA-15, 16, 17 | TC-LA-B07 |
| G13 | TC-LA-18, 19 | TC-LA-20, 21 | TC-LA-B08, B09, B10 |
| G14 (không địch) | TC-LA-22, 23 | TC-LA-24, 25 | TC-LA-B11, B12, B13 |
| G15 | TC-LA-26, 27 | TC-LA-28 | TC-LA-B14 |
| Nền | TC-LA-29 (cỡ chạm/chữ) | — | TC-LA-B13 (nền), TC-LA-S01…S03 |

Nhóm theo loại: thành công = 01, 04, 06, 08, 09, 12, 14, 18, 22, 26 · đầu vào sai/cấm = 03, 07, 10, 11, 13, 15, 16, 17,
20, 21, 24, 25, 28 · biên = B01…B14 · hủy = 05, B07, B08 · chết/hồi phục = **ngoài S02** (§7) · save/load = B03
(`load_snapshot` hỏng), B14 (`Về hub` không lưu). `TC-LA-C1M` = kịch bản C1-M, `TC-LA-C1T` = C1-T (§5).

## 3. Case theo gate

Dùng "Hộp fixture loadout" = Hộp có `starter_remedy` tại (0,0) đứng, ba lô rỗng, túi đeo chéo 1 vật hồi phục (inventory
spec §8.4). `can_call()` đúng = Manifest mang trong ba lô/Hộp **và** player trong `BeaconZoneA`.

### 3.1 G1 — S1 Briefing

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-01 | ĐẠT | Boot, save/kit mặc định | Chạm nút vào game | S1 hiện (chưa vào khu A); thấy `BRIEFING_HEADER_TITLE`, `BRIEFING_OBJECTIVE_MAIN`, `BRIEFING_RULES_LINE`, lời mentor, `LOADOUT_SUMMARY_DEFAULT_KIT`; nêu Contract 1, Manifest ở A, extract A, Easy, rủi ro đồ không niêm; `Vào cảng` bật; không cần cuộn đọc lore dài (UXA-01, 02) | có+tay | P, M, T |
| TC-LA-02 | ĐẠT | S1 lần đầu trong phiên | Mở S1; chạm `Quay lại` rồi vào lại S1 | Tooltip `BRIEFING_TOOLTIP_UNSEALED_LOSS` tự hiện lần đầu, không tự hiện lần hai, ⓘ mở lại được; `Quay lại` về Boot, đồ không đổi (UXA-03, 05) | có+tay | P, M, T |
| TC-LA-03 | CẤM | S1 | Đọc toàn bộ chữ S1 và tooltip | Không gọi Manifest là bằng chứng cuối; không nói niêm phong = hoàn thành; không hứa Contract 2 chơi được; không cutscene/popup lore dài (readiness G1 `BLOCKER`) | không | P, M, T |

### 3.2 G2 — O1/S1 loadout

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-04 | ĐẠT | S1, kit mặc định | Mở O1 (`BRIEFING_BUTTON_EDIT_LOADOUT`); chạm `starter_remedy`; chạm Hộp (1,0); chạm `Xong` | Sau chạm món: chỉ Hộp (1,0) có dấu vừa, ô khác gạch chéo; sau chạm ô: remedy chiếm (1,0),(1,1), nhãn `đã niêm` còn; `Xong` về S1, xem nhanh remedy ở (1,0), `Vào cảng` bật (UXA-06, 07, 11) | có+tay | P, M, T |
| TC-LA-05 | ĐẠT (hủy) | Như TC-LA-04, đã chuyển remedy sang (1,0) | Chạm `Hủy` (và thử Back) | S1; remedy về (0,0) đúng như lúc mở O1; ba lô/Hộp/túi giống hệt ảnh chụp trước khi mở O1 (UXA-10) | có+tay | P, M, T |
| TC-LA-06 | ĐẠT | S1 hợp lệ | Chạm `Vào cảng` hai lần nhanh | Đúng một lần chuyển scene; thấy "đang tải"; vào S2 với HUD E0: `HUD_OBJECTIVE_TAKE_MANIFEST`, `BEACON_E0_STATE_LABEL`, nhãn bàn dispatch (UXA-13, BCN-01) | có+tay | P, M, T |
| TC-LA-07 | CẤM | O1 mở | Tìm nút/hành động: xoay, kho hub, mua, preset, bỏ món, đổi gear, auto-xếp; thử chuyển remedy sang ba lô | Không có nút nào ở danh sách trên; chạm ba lô (0,0) khi đang chọn remedy: không đổi, hiện `INVENTORY_REASON_CROSS_GRID_LOCKED`, remedy vẫn được chọn (UXA-08, 12). Level/gear-score gate cũng không có | có+tay | P, M, T |

### 3.3 G4 — O2 Manifest → S3

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-08 | ĐẠT | S2, ở tầm bàn dispatch, E0 | Chạm nút bàn; xem card; `Nhặt và xếp`; chạm ba lô (2,3) | Card đủ thứ tự NAME → FOOTPRINT → USE → CLAIM → RARITY → LORE, 1x1, badge `chưa extract`, extract A; sau chạm: Manifest ở (2,3), `HUD_OBJECTIVE_DELIVER_PIER_A`, nhãn bàn ẩn, beacon `callable`, chân panel `PROMPT_SAFEBOX_SEAL_HINT`; `Đóng` → `PROMPT_ROUTE_EXTRACT_NOW`, không có `PROMPT_ROUTE_GO_MARKET` (UXA-16, 22, 26; BCN-06) | có+tay | P, M, T |
| TC-LA-09 | ĐẠT | Như TC-LA-08, chưa nhặt | `Nhặt và xếp`; chạm Hộp (1,1) | Manifest vào Hộp, nhãn `đã niêm — chưa extract`, **không** chữ success/hoàn thành; beacon `callable` ngay (UXA-23; BCN-07) | có+tay | P, M, T |
| TC-LA-10 | CẤM | S2, E0, chưa nhặt Manifest | Đứng trong vòng beacon; thử mọi cách gọi thuyền | Không có `Gọi thuyền`, không O5; W2 chỉ nhắc điều kiện `BEACON_E0_STATE_REASON`; beacon không `callable` trước Manifest (UXA-15; BCN-02, 03) | có+tay | P, M, T |
| TC-LA-11 | CẤM | Panel `pickup` mở, Manifest "còn ở bàn" | Quan sát sau khi nhặt vào ba lô/Hộp | Không auto-seal/auto-placement; Manifest không tự vào Archive/hub/Hộp; nhặt Manifest không tự hoàn thành Contract; không narration giải thích outcome | có+tay | P, M, T |

### 3.4 G5 — S3 rút sớm

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-12 | ĐẠT | State S3 sau Manifest thật (chỉ Manifest + starter kit) | Quay A, gọi → xác nhận → giữ → lên thuyền (không đi B/D) | Đạt S10 success; không phạt, không "thiếu route", không khóa summary; `ExtractSummary` không có điểm/route/thời gian (BCN-24, 35; UXA-38) | có+tay | P, M, T |
| TC-LA-13 | CẤM | Như TC-LA-12 | Đứng yên trong vòng beacon cả sau S9; để thuyền chờ | Không auto-win, không auto-board, không teleport thuyền; chỉ chạm `Lên thuyền` mới vào S10; không ép đi B/D, không reward bắt buộc (readiness G5 `BLOCKER`) | có+tay | P, M, T |

### 3.5 G11 — O5 chỉ cho `Gọi thuyền` ở S02

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-14 | ĐẠT | E1, trong vòng beacon | Chạm `Gọi thuyền` | O5: `EXTRACT_CONFIRM_TITLE`, thân có "20" giây và việc phải tự lên thuyền, `Gọi`, `Hủy`; HUD/objective vẫn hiện; thế giới không đóng băng (UXA-28; BCN-11) | có+tay | P, M, T |
| TC-LA-15 | CẤM | O5 mở | Chạm ra ngoài panel; chạm `Gọi` trong 0.3 giây đầu | Cả hai không hủy, không xác nhận; vẫn O5 (UXA-29, 31). Thử Back: hủy được (UXA-30) | có+tay | P, M, T |
| TC-LA-16 | CẤM | S2 đủ mọi màn: HUD, O1, O2, O3/O4, S10 | Rà nút/affordance | Không có affordance bỏ item, rút đồ niêm khỏi Hộp, đổi gear/vào không vũ khí ở S02; nếu xuất hiện mà không có O5 → `BLOCKER` G11. Rút remedy khỏi Hộp trong run chỉ ra `INVENTORY_REASON_WITHDRAW_LOCKED` (UXA-25) | có+tay | P, M, T |
| TC-LA-17 | CẤM | Toàn vòng | Đếm popup xác nhận trong C1 | Chỉ **một** O5 (gọi thuyền). Move/chạm ô/niêm vào Hộp/`Nhặt và xếp`/`Đóng`/`Hủy`/vào–ra vùng/`Lên thuyền`/`Về hub` không có xác nhận thừa (beacon §7.2); không gọi thuyền bắt đầu S7 mà không O5; O5 luôn có `Hủy` | có+tay | P, M, T |

### 3.6 G13 — E1/S7 gọi extract

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-18 | ĐẠT (hủy giữ E1) | O5 mở | Chạm `Hủy` | E1; O5 đóng; `Gọi thuyền` hiện lại; ảnh inventory không đổi; chạm `Gọi thuyền` lại mở O5 mới (UXA-30; BCN-12) | có+tay | P, M, T |
| TC-LA-19 | ĐẠT | O5 mở | Chạm `Gọi` | Banner `EXTRACT_S7_CALL_ACCEPTED`; objective vẫn `HUD_OBJECTIVE_DELIVER_PIER_A`; sau ≈1.5 giây `HUD_OBJECTIVE_HOLD_PIER_A` và banner "còn 20 giây" (UXA-33; BCN-14, 16) | có+tay | P, M, T |
| TC-LA-20 | CẤM | E1, đứng trong vòng | Chờ ≥ 10 giây không chạm | Không tự gọi, không O5 tự mở, không auto-win khi đứng beacon (BCN-02, invariant §8.3) | có+tay | P, M, T |
| TC-LA-21 | CẤM | E1 | Đi quanh Kho Nổi/Chợ Ngập (nếu vào được), mái nhà; tìm điểm extract khác | A là điểm duy nhất có `Gọi thuyền`; B/D/C/E không có nút/vùng/marker extract; C/E chỉ nền, không nhận input (BCN-37; readiness G13) | có (một phần) + tay | P, M, T |

### 3.7 G14 — S8/S9 hold/board (không địch)

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-22 | ĐẠT | S8 vừa vào, đứng trong vòng | Đứng đợi, đo thời gian đến S9 | Banner đếm 20→0 (HUD `ceil`), ≈20 giây ±1; S9: `HUD_OBJECTIVE_BOARD_BOAT`, `EXTRACT_S9_BOAT_READY`, vòng/marker lên thuyền hiện; `hold_started` một lần (UXA-33, 35; BCN-16, 17, 20) | có+tay | P, M, T |
| TC-LA-23 | ĐẠT | S9, đi vào `BoardZoneA` | Chạm `Lên thuyền` | Vào S10 đúng một lần; không O5 (UXA-37; BCN-22, 24) | có+tay | P, M, T |
| TC-LA-24 | CẤM | S8 chạy hết | Quan sát cảnh và HUD | Không địch, không `EXTRACT_S8_LANE_ALERT`, không đèn/âm thanh cảnh báo lane — hồ sơ S02 (beacon §8; UXA-35; BCN-36) | có (yếu — xem §6) + tay | P, M, T |
| TC-LA-25 | CẤM | S9, ở ngoài `BoardZoneA` | Chờ 60 giây | Vẫn S9; không nút `Lên thuyền`; không timeout/hủy/auto-board; không checkpoint (UXA-36; BCN-21, 23) | có+tay | P, M, T |

### 3.8 G15 — S10 summary (rút sớm)

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-26 | ĐẠT | S10, Manifest ở ba lô | Đọc từ trên xuống | Thứ tự: tiêu đề → `Đã giữ` (giấy phép, vật hồi phục, `Ô ba lô đã dùng: 1/12`) → **không** nhóm `Đã mất` → `Vật chứng` (Manifest, giới hạn, lead Kho K-7) → `Tiếp theo` (Contract 2 + tag chưa chơi được, không nút) → câu mentor → `Về hub`; Manifest không nằm ở `Đã giữ`; không điểm/thời gian/route (UXA-38; BCN-24) | có+tay | P, M, T |
| TC-LA-27 | ĐẠT | S10, Manifest nằm trong Hộp | Đọc `Đã giữ` | `Ô ba lô đã dùng: 0/12`; phần còn lại như TC-LA-26 (UXA-39) | có+tay | P, M, T |
| TC-LA-28 | CẤM | S10 | Chạm card Contract 2; đọc chữ Manifest | Không gì xảy ra; không nút bắt đầu; Manifest không thành `Bộ Phản Niêm`, không bán/craft/minh oan; đồ đã bỏ không tự hồi; rút sớm không chấm thấp hơn full-route (UXA-40; BCN-35) | có+tay | P, M, T |

### 3.9 Nền tảng (mọi gate)

| Case id | Loại | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-29 | ĐẠT | Mọi màn S1, O1, O2, O3/O4, O5, HUD, S10 trên khung 1280×720 | Đo vùng chạm, ô lưới, cỡ chữ; xem ảnh xám | Vùng chạm ≥ 64×64, ô lưới 96×96, chữ ≥ 20 px, không phần tử trong R6 ngoài joystick; grayscale vẫn phân biệt rarity/claim/footprint/vật chứng/đã niêm/E0–E1/chạy–dừng (UXA-42, 43, 45) | có (một phần: cỡ chạm) + tay | P, M, T |

## 4. Case biên

| Case id | Biên | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-LA-B01 | `Vào cảng` bấm lại khi lỗi tải | S1; ép lỗi tải scene (mạng chập chờn hoặc chặn tài nguyên trên staging) | Chạm `Vào cảng` | Ở lại S1, `UI_ERROR_SCENE_LOAD`, nút bật lại; không mất kit (§2.2 UX) | có (một phần) + tay | S-only nếu cần ép lỗi |
| TC-LA-B02 | Ô sai trong O1 | O1, chọn remedy | Chạm Hộp (0,1) (ra biên) rồi chạm ô ba lô | Cả hai không đổi, lý do hiện, remedy vẫn được chọn; chạm ô hợp lệ sau đó vẫn chạy (UXA-08, 09) | có+tay | P, M, T |
| TC-LA-B03 | `Vào cảng` khi loadout sai | S1 với inventory không hợp lệ (hai item chồng ô, INV-32) | Mở S1; chạm `Vào cảng` | `Vào cảng` tắt, icon khóa, `BRIEFING_BUTTON_ENTER_BLOCKED` + tên món + lý do; chạm không đổi scene, không đổi inventory, engine không tự sửa/xóa (UXA-04) | có (`test_ui_briefing_disables_enter_for_invalid_inventory`) | **S-only** (UI thường không tạo được loadout sai; production không có đường nạp) |
| TC-LA-B04 | Manifest đặt sai ô (bị chiếm/ngoài biên) | Panel `pickup` mở | Chạm Hộp (0,0) (remedy chiếm) | Không đổi; lý do `CELLS_OCCUPIED`; thẻ "còn ở bàn" vẫn hiện; vẫn E0; bàn vẫn còn Manifest; chạm ô hợp lệ sau đó mới E1 (UXA-20; BCN-05) | có+tay | P, M, T |
| TC-LA-B05 | Đóng card/panel không nhặt | O2 mở rồi panel `pickup` | Chạm `Đóng` ở O2; mở lại, `Nhặt và xếp` rồi `Đóng` ở panel; thử đi ra khỏi tầm bàn khi O2 mở | Về S2, không đổi gì, E0, chạm bàn lại mở O2; rời tầm bàn đóng O2 (UXA-17, 18, 21; BCN-05) | có+tay | P, M, T |
| TC-LA-B06 | Đang đứng sát/trong vòng lúc nhặt Manifest | Nhặt Manifest khi đã ở trong `BeaconZoneA` (nếu bàn đủ gần) | Hoàn tất nhặt | E1 và `Gọi thuyền` hiện ngay nhưng **không** tự mở O5 (beacon §11.2) | có (flow) + tay (nếu vị trí cho phép) | P, M, T |
| TC-LA-B07 | Hủy O5 giữ E1 / lặp | E1 trong vòng | Mở O5 → `Hủy` → mở lại → `Hủy` ×3 | Mỗi lần về E1, inventory/route không đổi, không S7 ngầm (BCN-12) | có+tay | P, M, T |
| TC-LA-B08 | Rời vòng khi O5 mở | O5 mở | Đi ra ngoài vòng (chuột/joystick) | O5 đóng như hủy; R4 `EXTRACT_CONFIRM_CLOSED_LEFT_ZONE`; E1; quay lại phải chạm `Gọi thuyền` lại (UXA-32; BCN-13) | có+tay | P, M, T |
| TC-LA-B09 | Đứng ở beacon khi E0 | E0, đứng trong vòng ≥ 30 giây | Quan sát | Không gì xảy ra: không O5, không nút gọi, không extract (§11.3; BCN-02) | có+tay | P, M, T |
| TC-LA-B10 | E1 nhưng ngoài vòng | E1, ở ngoài `BeaconZoneA` | Đọc HUD; vào vòng | Ngoài vòng: nhãn `callable` + `BEACON_E1_OUT_OF_ZONE_REASON`, không nút gọi; vào vòng: `Gọi thuyền` hiện (BCN-09, 10) | có+tay | P, M, T |
| TC-LA-B11 | Rời vòng khi S8 | S8, còn 19 giây | Rời vòng 3 giây | Banner vẫn 19, icon tạm dừng, `EXTRACT_S8_HOLD_PAUSED`; vào lại: giảm tiếp từ 19; **không** reset, **không** hủy cuộc gọi (UXA-34; BCN-18, 19) | có+tay | P, M, T |
| TC-LA-B12 | Rời vòng lúc S7 và khi S9 | (a) Đi ra ngay sau `Gọi`; (b) S9 rời mọi vùng | (a) Quan sát hết S7; (b) quay lại `BoardZoneA` | (a) S7 vẫn sang S8 đúng giờ, S8 bắt đầu ở trạng thái tạm dừng; (b) S9 không đổi, không timeout (beacon §11.5, §6; BCN-23) | có (flow) + tay | P, M, T |
| TC-LA-B13 | Đưa app xuống nền ≥ 10 giây | Lần lượt O2, panel `pickup`, O5, S8 | Chuyển tab/app khác 10 giây rồi quay lại | Overlay giữ nguyên, không commit/xác nhận ngầm; S8 giảm ≤ 0.25 giây ở tick đầu khi trở lại, không nhảy sang S9 (UXA-44; BCN-34) | có (BCN-34) + tay | P, M, T |
| TC-LA-B14 | `Về hub` hai lần nhanh / Back | S10 | Chạm `Về hub` hai lần nhanh; lần khác dùng Back | Về Boot đúng một lần; vào lại game: kit/Manifest/contract về trạng thái mới (không lưu tiến trình); thấy lại S1 từ nút vào game (UXA-41; BCN-25) | có+tay | P, M, T |

## 5. Kịch bản C1 trọn vòng (rút sớm) trên web-staging

Hai bản chạy: **C1-M** (chuột, trình duyệt desktop) và **C1-T** (cảm ứng điện thoại, ngang). Cùng một dãy bước; đây là kiểm
tra chức năng của QA, **không** thay C1 của playtest (phiếu quan sát §4, bên đó người chơi tự chạy và không có hint).

**Tiền điều kiện chung:** mở `https://hieuphung1qaz.itch.io/25d-game` ở kênh `web-staging`; ghi version (tên pre-release
staging) và `AppEnv.channel = staging` đọc từ nhãn build ở Boot; save/phiên mới (tải lại trang); kit mặc định; không dùng
debug menu. C1-T thêm: điện thoại bật chế độ ngang, bấm toàn màn hình của itch.io, ghi model máy + trình duyệt.

| Bước | Hành động | Kết quả mong đợi | Case/BCN/UXA |
|---|---|---|---|
| 1 | Boot: chạm nút vào game | S1 hiện, chưa vào khu A | TC-LA-01 · UXA-01 |
| 2 | S1: đọc briefing; (tùy chọn) mở O1, chuyển remedy sang Hộp (1,0), `Xong` | Briefing đủ ý; kit đổi đúng, `Vào cảng` bật | TC-LA-01, 04 · UXA-02, 11 |
| 3 | Chạm `Vào cảng` | Đang tải → S2: HUD E0, `HUD_OBJECTIVE_TAKE_MANIFEST`, nhãn bàn | TC-LA-06 · BCN-01 |
| 4 | (E0) đi vào vòng beacon rồi ra | Không nút gọi, không O5 | TC-LA-10, B09 · BCN-02, 03 |
| 5 | Đi tới bàn dispatch; chạm nút bàn; xem card | Card Manifest đúng thứ tự dòng | TC-LA-08 · BCN-04 |
| 6 | `Nhặt và xếp`; thử một ô sai (Hộp (0,0)); rồi ô hợp lệ | Ô sai: lý do, vẫn E0; ô hợp lệ: E1, `PROMPT_ROUTE_EXTRACT_NOW` | TC-LA-B04, 08 · BCN-05, 06 |
| 7 | (E1) ra ngoài vòng, đọc HUD; đi vào vòng | Ngoài: lý do vào vòng; trong: `Gọi thuyền` | TC-LA-B10 · BCN-09, 10 |
| 8 | Chạm `Gọi thuyền` → `Hủy` → `Gọi thuyền` lại | Hủy giữ E1; O5 có tiêu đề, "20", `Gọi`, `Hủy` | TC-LA-14, 18, B07 · BCN-11, 12 |
| 9 | O5: chạm `Gọi` (sau ≥ 0.3 giây) | S7 → sau ≈1.5 giây S8 "còn 20 giây" | TC-LA-19 · BCN-14, 16 |
| 10 | S8: rời vòng vài giây, quay lại, đứng đợi | Tạm dừng rồi chạy tiếp; không địch; hết 20 giây → S9 | TC-LA-B11, 22, 24 · BCN-18…20 |
| 11 | S9: đi tới chỗ lên thuyền, chạm `Lên thuyền` | S10 đúng một lần | TC-LA-23, 25 · BCN-22, 24 |
| 12 | S10: đọc summary; chạm card Contract 2 | Đủ nhóm theo thứ tự; Contract 2 không phản hồi | TC-LA-26, 28 · UXA-38, 40 |
| 13 | Chạm `Về hub` | Về Boot; vào lại thấy trạng thái mới | TC-LA-B14 · BCN-25 |

Kết luận bản chạy: C1-M và C1-T đều `ĐẠT` (cả 13 bước) thì mới ghi gate liên quan `READY` ở cột build; một bước sai là
`NOT READY` (hoặc `BLOCKER` nếu trúng cột `BLOCKER` ở readiness §6) kèm mẫu bug ở §9. Thêm cho C1-T: mọi chạm bằng ngón,
joystick không che nút ngữ cảnh, không cần zoom trình duyệt, không cuộn trang itch thay vì game, xoay máy không phá bố cục.

## 6. Bảng truy vết BCN-xx → test thật trong `game/tests/unit/`

Mọi tên dưới đây nằm trong `game-shit/game/tests/unit/test_extract_pier_a_flow.gd` trừ khi ghi khác. Cột "Ghi chú QA"
đánh dấu chỗ test hiện có **khác nghĩa spec** hoặc **chưa chứng minh** điều spec yêu cầu — đó là phần việc cho
test-engineer (§8) và case tay vẫn bắt buộc.

| BCN | Test thật | Case tay | Ghi chú QA |
|---|---|---|---|
| BCN-01 | `test_bcn_01_setup_starts_contract_run` | TC-LA-06 | — |
| BCN-02 | `test_bcn_02_entering_beacon_at_e0_changes_nothing` | TC-LA-10, B09 | — |
| BCN-03 | `test_bcn_03_request_call_at_e0_is_rejected` | TC-LA-10 | — |
| BCN-04 | `test_bcn_04_dispatch_card_does_not_mutate_flow` | TC-LA-08 | — |
| BCN-05 | `test_bcn_05_failed_manifest_placement_keeps_flow_at_e0` | TC-LA-B04, B05 | — |
| BCN-06 | `test_bcn_06_pickup_manifest_to_backpack_makes_e1` | TC-LA-08 | — |
| BCN-07 | `test_bcn_07_pickup_manifest_to_notary_box_makes_e1` | TC-LA-09 | — |
| BCN-08 | `test_bcn_08_sealing_manifest_does_not_change_flow` | TC-LA-11 | — |
| BCN-09 | `test_bcn_09_e1_outside_beacon_cannot_call` | TC-LA-B10 | — |
| BCN-10 | `test_bcn_10_e1_inside_beacon_can_call` | TC-LA-B10 | — |
| BCN-11 | `test_bcn_11_request_call_opens_confirmation` | TC-LA-14 | Text `{seconds}=20` của `EXTRACT_CONFIRM_BODY` kiểm ở `test_ui_confirm.gd` (xem dưới) |
| BCN-12 | `test_bcn_12_cancel_call_keeps_e1` | TC-LA-18, B07 | — |
| BCN-13 | `test_bcn_13_leaving_beacon_cancels_call_prompt` | TC-LA-B08 | — |
| BCN-14 | `test_bcn_14_confirm_call_enters_s7` | TC-LA-19 | — |
| BCN-15 | `test_bcn_15_manifest_loss_before_confirm_rejects_call` | thủ công: không (S04 mới có drop) | Không có affordance bỏ item ở S02 nên không làm tay được |
| BCN-16 | `test_bcn_16_s7_ack_starts_hold` | TC-LA-19 | — |
| BCN-17 | `test_bcn_17_hold_counts_only_while_eligible` | TC-LA-22 | — |
| BCN-18 | `test_bcn_18_leaving_beacon_pauses_hold` | TC-LA-B11 | — |
| BCN-19 | `test_bcn_19_returning_to_beacon_resumes_hold` | TC-LA-B11 | — |
| BCN-20 | `test_bcn_20_completed_hold_reaches_s9` | TC-LA-22 | — |
| BCN-21 | `test_bcn_21_board_outside_board_zone_is_rejected` | TC-LA-25 | — |
| BCN-22 | `test_bcn_22_board_zone_enables_boarding` | TC-LA-23 | — |
| BCN-23 | `test_bcn_23_s9_waits_without_timeout` | TC-LA-25, B12 | — |
| BCN-24 | `test_bcn_24_board_builds_success_summary` | TC-LA-12, 26, 27 | — |
| BCN-25 | **Không có test đúng nghĩa spec.** `test_bcn_25_s10_ignores_remaining_flow_input` thực ra kiểm "S10 bỏ qua input" (spec: BCN-31). Phần `Về hub` → Boot phủ gián tiếp bởi `test_flow_loop.gd::test_flow_boot_to_success_summary_with_preinjected_session` và `test_ui_summary.gd::test_ui_summary_hides_empty_loss_and_emits_hub_once` | TC-LA-B14 | Lệch tên/ý với spec; **không** có kiểm "không có file save mới trong `user://`" → thủ công + follow-up |
| BCN-26 | `test_bcn_26_dropped_manifest_returns_e1_to_e0` | không (S04) | — |
| BCN-27 | `test_bcn_27_repickup_manifest_returns_to_e1` | không (S04) | — |
| BCN-28 | `test_bcn_28_manifest_loss_pauses_s8` | không (S04) | — |
| BCN-29 | `test_bcn_29_manifest_loss_in_s9_prevents_boarding` | không (S04) | — |
| BCN-30 | `test_bcn_30_death_ends_flow_without_extract` | không (death ngoài S02, §7) | — |
| BCN-31 | `test_bcn_31_terminal_states_ignore_input` (+ `test_bcn_25_…` kiểm S10 giữ nguyên) | không (cần death) | — |
| BCN-32 | `test_bcn_32_confirm_call_is_idempotent` | TC-LA-15 | — |
| BCN-33 | `test_bcn_33_board_is_idempotent` | TC-LA-B14 | — |
| BCN-34 | `test_bcn_34_tick_delta_is_capped` | TC-LA-B13 | — |
| BCN-35 | `test_bcn_35_early_and_full_extract_summaries_have_only_contract_fields` | TC-LA-12, 28 | — |
| BCN-36 | `test_bcn_36_s02_flow_does_not_create_enemy_nodes` | TC-LA-24 | **Test yếu:** chỉ khẳng định `flow is RefCounted`, không chạy scene, không đếm node nhóm `enemy`, không kiểm HUD không hiện `EXTRACT_S8_LANE_ALERT`, không kiểm chữ `EXTRACT_CONFIRM_BODY` — chưa chứng minh BCN-36; phủ bằng thủ công |
| BCN-37 | `test_bcn_37_zone_adapter_remains_outside_pure_flow` | TC-LA-21 | **Test yếu:** chỉ gọi `set_in_beacon_zone(true)`, không liệt kê Area3D của scene; spec yêu cầu "chỉ `BeaconZoneA` (con của `BeaconA`)" — chưa chứng minh; phủ bằng thủ công |

Test UI/scene dùng cho các case khác (tên thật):

| Nội dung | Test | Case |
|---|---|---|
| E2E Boot → briefing → loadout → A → Manifest → gọi/giữ/lên thuyền → S10 → Boot | `test_flow_loop.gd::test_flow_boot_to_success_summary_with_preinjected_session`, `test_flow_loop_reaches_success_summary_through_context_signals` | TC-LA-C (C1) |
| Overlay dừng/nhả điều khiển Retriever | `test_flow_loop.gd::test_flow_overlay_pauses_and_restores_retriever_control` | TC-LA-14 |
| Briefing: `Vào cảng` hợp lệ/không hợp lệ, lỗi tải, tooltip chạm được | `test_ui_briefing.gd` (3 test) | TC-LA-01, 06, B01, B03 |
| Loadout: chỉ cùng ngăn, hủy khôi phục, cross-grid khóa, cỡ ô chạm | `test_ui_loadout.gd` (4 test) | TC-LA-04, 05, 07, B02, 29 |
| Card Manifest/pickup chỉ phát action rõ ràng, chỉ ô hợp lệ mới commit | `test_ui_pickup.gd` (4 test) | TC-LA-08, 09, B04, B05 |
| O5 chỉ phát accept/cancel từ nút, khóa accept sau lần đầu, R6 cảm ứng | `test_ui_confirm.gd` (3 test) | TC-LA-14, 15, 17 |
| HUD E0/E1/S7/S8/S9, không lane alert | `test_ui_hud.gd::test_ui_hud_projects_e0_e1_s7_s8_s9_without_lane_alert` | TC-LA-19, 22, 24 |
| Summary: ẩn nhóm mất rỗng, `Về hub` một lần, next/evidence theo dữ liệu | `test_ui_summary.gd` (4 test) | TC-LA-26, 27, 28, B14 |
| Tầm bàn dispatch 2 m ngang; vùng tương tác ở anchor | `test_dispatch_interaction.gd` (2 test) | TC-LA-08, B05 |
| Khu A: landmarks, camera, chỉ backdrop C/E | `test_world_zone_a_outer_pier.gd` | TC-LA-21 (một phần) |
| Badge build ở Boot | `test_boot_scene.gd::test_boot_scene_shows_build_label` | §1 (ghi version) |

## 7. Phần chưa phủ ở S02 và sprint sẽ phủ

| Hạng mục | Vì sao chưa phủ | Gate | Sprint | Ghi chú |
|---|---|---|---|---|
| Địch từ lane B có light/audio/telegraph; `EXTRACT_S8_LANE_ALERT`; spawn không sau lưng/ngoài camera | Hồ sơ S02 không địch (beacon §8) | G14 (nửa còn lại) | **S03** | Ở S02 chỉ kiểm hold/board, TC-LA-24 là case cấm ngược (không có địch) |
| Death trong hold/ready → S11, không checkpoint | S02 chưa có địch/combat/S11; chỉ có `notify_death()` ở mức logic (BCN-30/31) | G14 (phần death), G16/G17 | S03/S04+ | Không tạo case tay; chỉ test headless |
| Bỏ item (O5), rút đồ niêm (O5), đổi gear/vào không vũ khí (O5) | Không có affordance ở S02 (beacon §7.1; UX §6) | G11 (phần còn lại) | **S04** | TC-LA-16 chỉ kiểm affordance **không xuất hiện** ở S02 |
| `PROMPT_ROUTE_GO_MARKET`, đi B/D rồi quay lại A, summary có `Đã mất` | B/D chưa chơi được | G6–G9, G15 (nhóm `Đã mất`) | S03/S04 | BCN-26…29 (drop) chỉ headless; TC-LA-26 xác nhận nhóm `Đã mất` ẩn khi rỗng |
| Rotate, drag, Tự xếp, Hộp đầy/rút đồ (G8/G10 đầy đủ) | Không có ở S02 (UX §2.3) | G8, G10 | S03/S04 | Inventory plan `TC-INV-xx` vẫn là nguồn cho phần này |
| Death → S11/S12 → Recovery Contract | Ngoài phạm vi card | G16–G18, C3 | sau S04 | — |
| G3/G6–G10/G12 | Ngoài phạm vi card | — | theo sprint | — |
| Lưu/tải tiến trình thật | S02: `Về hub` → Boot không lưu | — | chưa có | TC-LA-B14 kiểm "không lưu" |

## 8. Phần đưa cho test-engineer (follow-up, chưa làm)

1. **Siết BCN-36:** dựng scene khu A với `s02_no_enemy_profile`, chạy flow qua S8, đếm node nhóm `enemy` = 0, HUD không có
   `EXTRACT_S8_LANE_ALERT`, `tr("EXTRACT_CONFIRM_BODY")` khớp `strings.csv`.
2. **Siết BCN-37:** liệt kê Area3D trong scene khu A có gắn `set_in_beacon_zone`; chỉ `BeaconZoneA` (con của `BeaconA`).
3. **Thêm BCN-25 đúng nghĩa spec:** chạm `SUMMARY_BUTTON_HUB` → scene Boot, và không file mới trong `user://`; đổi tên
   test `test_bcn_25_…` hiện có cho đúng nội dung (hoặc gộp vào BCN-31) để bảng truy vết không lệch mã.
4. **Test thiếu tên theo UXA:** hiện không có test mang tên `test_uxa_xx_*`; các UXA có `có` ở §3 cần đối chiếu với
   test UI hiện có, bổ sung thiếu (đặc biệt UXA-29 chặn chạm 0.3 giây, UXA-31 chạm ngoài panel, UXA-36 chờ 60 giây).
5. Mọi test mới theo charter QA: failing-then-passing.

## 9. Case chỉ staging và production (tách riêng)

Debug menu và env badge **không** thuộc spec. Theo [AGENTS.md của game](../../AGENTS.md) flag nằm ở
`game/config/env/{dev,staging,production}.cfg`; nội dung debug menu cụ thể chưa có tài liệu — nếu build staging thực tế
không có, ghi `KHÔNG TEST ĐƯỢC` theo [phiếu quan sát](../playtest-observation-sheet.md) §1 và để case `S-only` chuyển
thành test headless.

| Case id | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|
| TC-LA-S01 | Build staging (itch `web-staging`) | Mở Boot và HUD | Nhãn/badge `AppEnv.channel = staging` + version hiện, không che nút hay ô lưới | không | S-only |
| TC-LA-S02 | Build production (tag) | Như TC-LA-S01; tìm debug menu, `test_*`, nạp save hỏng | Không badge staging, không debug menu, không đường nạp state/loadout sai | không | P-only |
| TC-LA-S03 | Staging + debug menu (nếu có) | Nạp state "sau Manifest" để rút gọn C1 ở TC-LA-12 | State nạp trùng state sinh từ flow thật (cùng nhãn HUD/beacon); kết quả TC-LA-12 giống chạy thật. Fixture **không** thay C1 trọn vòng | không | S-only |

## 10. Mẫu bug report

```text
Build channel: staging (web-staging itch.io) / production   Version: <tên pre-release staging hoặc tag production>
Thiết bị / trình duyệt / đầu vào: chuột | cảm ứng
Case id: TC-LA-xx / TC-LA-Bxx / TC-LA-Sxx / TC-LA-Cx bước n
Tiền điều kiện (state, fixture, cách nạp):
Bước tái hiện:
Kết quả mong đợi (trích BCN-xx / UXA-xx / gate):
Kết quả thực tế (kèm ảnh/video):
Severity: BLOCKER / MUST_FIX / MINOR
Tái hiện: n/m lần cùng build
```

Severity gợi ý: **BLOCKER** = trúng cột `BLOCKER` của readiness (§6): beacon `callable` trước Manifest, gọi thuyền không có
O5, auto-win/auto-board, extract ngoài A, rút sớm bị phạt, S10 coi Manifest là `Đã giữ`, Contract 2 vào được, địch xuất
hiện ở S02, `Vào cảng` mở khi `validate()` lỗi (đi nhánh build/readiness §9: dừng phiên, tái hiện một lần, mở một card).
**MUST_FIX** = sai/thiếu key chữ, S8 reset thay vì tạm dừng, số giây sai, signal sai số lần, vùng chạm < 64. **MINOR** =
lỗi trình bày không đổi state.

## 11. Phiếu kết quả gate S02 (DoD)

Ghi `READY` / `NOT READY` / `BLOCKER` / `KHÔNG TEST ĐƯỢC` theo [build-readiness](../vertical-slice-build-readiness.md) §9.

| Gate | Case phải đạt | C1-M | C1-T | Build (channel + version) | Trạng thái |
|---|---|---|---|---|---|
| G1 | TC-LA-01, 02, 03 | | | | |
| G2 | TC-LA-04…07, B01…B03 | | | | |
| G4 | TC-LA-08…11, B04…B06 | | | | |
| G5 | TC-LA-12, 13, C1-M, C1-T | | | | |
| G11 (`Gọi thuyền`) | TC-LA-14…17, B07 | | | | |
| G13 | TC-LA-18…21, B08…B10 | | | | |
| G14 (không địch) | TC-LA-22…25, B11…B13 | | | | |
| G15 | TC-LA-26…28, B14 | | | | |

Không thêm metric playtest mới: khi chạy C1 có người chơi, dùng nguyên [phiếu quan sát](../playtest-observation-sheet.md)
§4 (claim **P2** semantics, **P7**, **P8a**; P3/P8c không áp dụng ở S02 vì chưa có địch).

## 12. Truy vết gate → case

| Gate | Case | BCN | UXA |
|---|---|---|---|
| G1 | TC-LA-01…03 | — | 01…03 |
| G2 | TC-LA-04…07, B01…B03 | 01 | 04…13 |
| G4 | TC-LA-08…11, B04…B06 | 01…08 | 14…25 |
| G5 | TC-LA-12, 13, C1-M, C1-T | 24, 35 | 26…41 |
| G11 | TC-LA-14…17, B07 | 11…15 | 24, 28…32 |
| G13 | TC-LA-18…21, B08…B10 | 09…15, 37 | 15, 27…33 |
| G14 | TC-LA-22…25, B11…B13 | 16…23, 34, 36 | 33…37, 44 |
| G15 | TC-LA-26…28, B14 | 24, 25, 35 | 38…41 |
| Invariant §8.3 | TC-LA-10, 13, 20, 25, B09 | 02, 03, 21, 23 | 15, 36 |

## 13. Ngoài phạm vi

Viết code test (test-engineer); chạy phiên playtest và điền phiếu quan sát; gate G3/G6–G10/G12/G16–G18; combat; death;
lane B; recovery; kiểm balance. Vị trí `BeaconZoneA`/`BoardZoneA` và `DESK_INTERACT_RADIUS_M` do level-designer chốt: nếu hai
vùng chồng nhau hoặc bàn quá sát beacon thì ghi vào bug report, không tự sửa plan.
