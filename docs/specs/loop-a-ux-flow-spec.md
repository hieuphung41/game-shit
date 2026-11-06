# Spec UX — Luồng cảm ứng vòng A (S02): briefing → loadout → khu A → Manifest → gọi/giữ/lên thuyền → summary

**Trạng thái:** spec UX `proposed` cho ui-programmer (TASK-72 briefing/loadout, TASK-73 card/lưới/O5/HUD/summary),
gameplay-engineer (TASK-75 nối vòng), narrative-writer (TASK-71 chữ còn thiếu) và qa-planner (TASK-78). Mọi kích thước,
toạ độ, thời lượng, tên key mới (`KEY_MỚI`) và tên cue âm thanh/rung đều `proposed` cho tới playtest. Spec này **không**
đổi luật: luật nằm ở nguồn dưới đây; spec chỉ nói người chơi thấy gì, chạm vào đâu và chuyện gì xảy ra.

**Nguồn (ưu tiên khi spec này khác):** [Vertical slice](../vertical-slice.md) §2.1, §2.2, Beat 0–2, 6–8 ·
[Wireflow](../vertical-slice-wireflow.md) §2–§9 · [Build-readiness](../vertical-slice-build-readiness.md) G1–G5, G8, G10,
G11, G13–G15 · [Spec beacon/extract](beacon-extract-state-spec.md) (BCN-xx, §4, §7, §8, §10.5) ·
[Spec lưới ba lô/Hộp](inventory-grid-slice-spec.md) (§4, §5, §7, §8.4) · [Chuỗi Contract 1](contract-1-strings.md) và
[`strings.csv`](../../game/i18n/strings.csv). Tên riêng theo `memory/glossary.md` của studio.

**Quyết định S02 đã duyệt (Producer, 2026-11-06):** O1 chỉ xem và sắp lại starter kit, không kho hub, không mua, không
preset, không xoay · `Về hub` → màn Boot · không lưu tiến trình · S8 chỉ đếm giờ, không cảnh báo lane, nhưng giữ nguyên
chữ `EXTRACT_CONFIRM_BODY`.

## 1. Mục tiêu người chơi và gate phục vụ

**Mục tiêu người chơi:** Người Thu Hồi nhận Contract 1, sắp lại starter kit nếu muốn, vào Bến Ngoài (A), tự tay xếp
`Manifest Hàng Hóa R-17` vào ba lô hoặc Hộp Công Chứng, rồi tự gọi thuyền, giữ khu và lên thuyền ở Cầu tàu A để thấy
giấy phép được giữ — mỗi bước đều biết điều gì vừa xảy ra và vì sao.

| Gate | Phần của spec phục vụ |
|---|---|
| G1 — S1 briefing | §5.1 |
| G2 — O1/S1 loadout (`Vào cảng` chỉ sáng khi hợp lệ, hủy không đổi đồ) | §5.1, §5.2, §4 (lưới dùng chung) |
| G3 — S2 A spawn (dispatch, beacon đọc được; chỉ phần HUD/nhãn) | §5.3 |
| G4 — O2 Manifest → S3 | §5.4, §5.5 |
| G5 — rút sớm = success | §5.6–§5.9 |
| G8 — chạm chọn → chạm ô, sai giữ nguyên + lý do (không xoay ở S02) | §4 |
| G10 — nhãn `đã niêm — chưa extract`, không auto-swap (phần Manifest) | §4.4, §5.5 |
| G11 — O5 chỉ cho `Gọi thuyền` ở S02, không confirmation thừa | §5.7, §6 |
| G13 — E1/S7 | §5.6, §5.7 |
| G14 — S8/S9 hold/board (chưa có địch) | §5.8 |
| G15 — S10 tách nhóm, Contract 2 không có nút bắt đầu | §5.9 |

## 2. Bản đồ luồng

### 2.1 Sơ đồ

```text
Boot ──[nút vào game hiện có]──▶ S1 Briefing
S1 ──[Sắp lại đồ]──▶ O1 Loadout ──[Xong]──▶ S1 (giữ thay đổi)
                                └─[Hủy / Back]──▶ S1 (khôi phục đúng trạng thái lúc mở O1)
S1 ──[Quay lại / Back]──▶ Boot
S1 ──[Vào cảng] (chỉ khi validate() rỗng) ──▶ đang tải ──▶ S2 HUD khu A (E0)
                                                      └─lỗi tải──▶ S1 + lý do, nút bật lại (thử lại)

S2 ──[nút Bàn dispatch] (trong tầm bàn, bàn còn Manifest) ──▶ O2 card Manifest
O2 ──[Đóng / Back / rời tầm bàn]──▶ S2 (không đổi gì)
O2 ──[Nhặt và xếp]──▶ O3/O4 chế độ NHẶT (ba lô + Hộp, Manifest "còn ở bàn")
   O3/O4 nhặt ──chạm ô KHÔNG hợp lệ──▶ giữ panel, hiện lý do (thử ô khác)
   O3/O4 nhặt ──[Đóng / Back / rời tầm bàn]──▶ S2 (Manifest vẫn ở bàn, E0)
   O3/O4 nhặt ──chạm ô hợp lệ──▶ commit_pickup ok ──▶ O3/O4 chế độ XEM + PROMPT_SAFEBOX_SEAL_HINT  (= S3, E1)
O3/O4 xem ──[Đóng]──▶ S3 HUD + PROMPT_ROUTE_EXTRACT_NOW
S3 ──[nút Đồ mang theo]──▶ O3/O4 chế độ XEM ──[Đóng]──▶ S3

S3 (E1) ──vào vòng đèn phao──▶ nút Gọi thuyền ──▶ O5 ──[Hủy / Back / rời vòng]──▶ E1
                                                  └─[Gọi]──▶ S7 (1.5 giây) ──▶ S8 giữ khu (20 giây)
S8 ──rời vòng──▶ S8 tạm dừng ──vào lại──▶ S8 chạy tiếp ──hết giờ──▶ S9 thuyền cập bến
S9 ──vào chỗ lên thuyền──▶ nút Lên thuyền ──▶ S10 Summary ──[Về hub / Back]──▶ Boot
```

### 2.2 Lối vào/ra, hủy và thử lại

| Màn / overlay | Vào từ | Ra (tiến) | Hủy / Back (một chạm) | Lỗi → thử lại |
|---|---|---|---|---|
| S1 Briefing | Boot | `Vào cảng` → S2 | `Quay lại` → Boot | validate fail: nút tắt + lý do; người chơi mở O1 tự sửa. Lỗi tải scene: ở lại S1, nút bật lại. |
| O1 Loadout | S1 | `Xong` → S1 | `Hủy` → S1, đồ như lúc mở O1 | Ô sai: lý do, món giữ chỗ cũ; chạm ô khác. |
| S2/S3 HUD khu A | S1 | Bàn → O2; Gọi → O5; Lên thuyền → S10 | — (không có menu tạm dừng ở S02) | — |
| O2 card Manifest | S2 | `Nhặt và xếp` → O3/O4 nhặt | `Đóng` → S2 | — |
| O3/O4 nhặt | O2 | ô hợp lệ → O3/O4 xem | `Đóng` → S2 (về thẳng thế giới, không quay O2) | Ô sai: lý do; Manifest vẫn ở bàn; chạm ô khác. |
| O3/O4 xem | sau nhặt, hoặc nút `Đồ mang theo` | — | `Đóng` → HUD | Ô sai: lý do, món giữ chỗ cũ. |
| O5 gọi thuyền | nút `Gọi thuyền` | `Gọi` → S7 | `Hủy` → E1; rời vòng/mất Manifest = hủy | Guard sai lúc `Gọi`: O5 đóng, về E1/E0, HUD nêu lý do. |
| HUD S7/S8/S9 | O5 `Gọi` | `Lên thuyền` → S10 | Không hủy được cuộc gọi (đã xác nhận ở O5) | S8 tạm dừng khi rời vòng; quay lại để chạy tiếp. |
| S10 Summary | `Lên thuyền` | `Về hub` → Boot | Back = `Về hub` | Lỗi tải Boot: nút bật lại. |

### 2.3 Bước bị bỏ hoặc gộp so với wireflow (S02)

| Bước wireflow | Việc nó làm cho người chơi | Ở S02 việc đó nằm ở đâu |
|---|---|---|
| S0 Hub → S1 | Chọn contract, xem lead | Boot thay hub (quyết định Producer). Nút vào game hiện có của Boot phải dẫn tới S1, không vào thẳng khu A (TASK-72/75). |
| S10 → S0 hub ghi `lead: Kho K-7` | Nhắc lead sau run | Chỉ còn ở S10, nhóm `Vật chứng` (`SUMMARY_SUCCESS_EVIDENCE_LEAD`). Không lưu sau khi về Boot. |
| O1 "chọn món từ kho hub" | Đổi tổ hợp đồ | Bỏ ở S02 (không kho hub). O1 chỉ sắp lại trong cùng ngăn (§5.2). |
| O1 nút `Vào cảng` trong O1 | Vào run ngay từ loadout | Gộp: `Xong` về S1, nơi tóm tắt kit (`LOADOUT_SUMMARY_DEFAULT_KIT`) được đọc lại trước `Vào cảng`. Thêm một chạm, đổi lại người chơi luôn thấy tóm tắt trước khi vào. |
| O2 `Bỏ qua` | Từ chối loot | Với Manifest, `Đóng` làm đúng việc này (không đổi gì). `CARD_ACTION_SKIP` chỉ dùng cho loot ngoài Manifest (từ S03). |
| `PROMPT_ROUTE_GO_MARKET` | Mời đi B kiếm thêm | Ẩn ở S02 vì B chưa vào được (`proposed`, câu hỏi Q2). Chỉ hiện `PROMPT_ROUTE_EXTRACT_NOW`. |
| S7/S8 lane alert | Báo địch tới | Không có ở S02 (beacon spec §8). Câu cảnh báo vẫn nằm trong `EXTRACT_CONFIRM_BODY`. |
| Kéo-thả trên lưới | Shortcut | Không có ở S02; chạm chọn → chạm ô là thao tác đầy đủ (G8). |
| Xoay item | Đổi hướng footprint | Không có ở S02 (G8/S03); không có nút xoay. |

## 3. Khung màn hình chung (1280×720, `proposed`)

### 3.1 Vùng màn hình

Toạ độ `x0–x1 × y0–y1` tính trên khung tham chiếu 1280×720; lề an toàn 16 px quanh mép. Vùng là chỗ đặt và thứ bậc,
không phải hình dáng; hình thức thuộc Art Bible (lane `ui`) và art-director.

| Mã | Vùng | Toạ độ | Dùng cho |
|---|---|---|---|
| R1 | Trên-trái | 16–656 × 16–72 | Objective HUD (một dòng). Không overlay nào được che R1. |
| R2 | Trên-giữa | 384–896 × 84–164 | Banner extract S7/S8/S9; dòng lý do tạm dừng. |
| R3 | Trên-phải | 1168–1264 × 16–112 | Nút `Đồ mang theo` 96×96. |
| R4 | Dưới-giữa | 300–968 × 592–688 | Prompt/toast một dòng (một prompt mỗi lúc). |
| R5 | Dưới-phải | 1000–1264 × 560–704 | Nút ngữ cảnh 240×112 (bàn dispatch / Gọi thuyền / Lên thuyền). |
| R6 | Dưới-trái | 16–276 × 444–704 | Joystick hiện có (`TouchJoystick`); không đặt phần tử nào khác ở đây. |
| R7 | Panel phải | 680–1264 × 128–704 | O2 card. |
| R8 | Panel lớn | 296–1264 × 128–704 | O3/O4 trong run (joystick R6 và objective R1 vẫn thấy và dùng được). |
| R9 | Giữa | 368–912 × 192–528 | O5 (không chồng R5). |

### 3.2 Quy tắc chạm và chữ (mọi màn)

1. Vùng chạm tối thiểu 64×64; nút chính cao ≥ 96; ô lưới 96×96 (`proposed` tới playtest).
2. Chạm = ngón xuống và nhấc lên trong cùng vùng, di chuyển < 16 px. Nhấc ra ngoài vùng hoặc touch bị hủy (app xuống
   nền) = không có action. Chuột trên web chỉ giả lập chạm (click trái = chạm); không có hover.
3. Không có thao tác giữ lâu hay kéo ở S02. "Giữ khu" là đứng trong vòng đèn phao, **không** phải nhấn giữ nút.
4. Joystick và một nút có thể dùng cùng lúc bằng hai ngón (đi + chạm nút ngữ cảnh). Nút chỉ nhận ngón đầu tiên chạm vào nó.
5. Chặn chạm xuyên: mỗi overlay (O1–O5) và màn mới (S1, S10) bỏ qua chạm trong `UI_OPEN_GUARD_SECONDS = 0.3` sau khi
   hiện. Nút gây chuyển màn (`Vào cảng`, `Gọi`, `Lên thuyền`, `Về hub`) tự khóa sau chạm đầu tới khi chuyển xong.
6. Chữ thân tối thiểu 24 px, chữ phụ tối thiểu 20 px ở khung 720p; không chữ nào dưới 20 px. Không nhấp nháy: nhấn mạnh
   bằng một lần đổi viền/phóng to, tối đa một lần mỗi giây; không phần tử nào lặp sáng–tắt.
7. Trạng thái nào cũng có ít nhất một kênh ngoài màu: chữ, icon, hình dạng hoặc vị trí (G7, wireflow §9).
8. Nút Back hệ thống (Android) / phím Esc (web) = nút hủy/đóng của lớp trên cùng đang mở. Ở HUD khu A không làm gì.
9. Phản hồi âm thanh/rung chỉ đặt tên cue cho sau này; S02 có thể im lặng. Cue chung: `ui_tap`, `ui_invalid`,
   `ui_confirm_open`, `ui_cancel`; rung: `haptic_light`, `haptic_warn`, `haptic_success`.

## 4. Thành phần dùng chung: lưới đồ (O1, O3/O4)

Một thành phần lưới có ba chế độ: `loadout` (O1), `pickup` (O3/O4 nhặt Manifest) và `view` (O3/O4 xem trong run). Nó
chỉ gọi `preview_*`/`commit_*` của `RetrieverInventory` (inventory spec §9); không tự sửa inventory.

### 4.1 Phần tử

| Phần tử | Nội dung / dữ liệu | Key |
|---|---|---|
| Nhãn lưới ba lô | lưới 3x4 `backpack.size` | `LOADOUT_LABEL_BACKPACK` |
| Nhãn Hộp | lưới 2x2 `notary_box.size` + icon ổ khóa niêm | `LOADOUT_LABEL_NOTARY_BOX` |
| Nhãn túi đeo chéo | `sling_pouch` (chỉ ở `loadout` và `view`) | `LOADOUT_LABEL_SLING_POUCH` |
| Ô | 96×96; item vẽ theo footprint hiệu lực (`ItemInstance.cells()`) | — |
| Nhãn item trong Hộp | `seal_label(uid)` → `sealed` / `sealed_not_extracted` | `INVENTORY_SEAL_LABEL_SEALED` / `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED` |
| Badge vật chứng | item `evidence` ở mọi lưới: icon riêng + chữ | `CARD_MANIFEST_R17_STATE_NOT_EXTRACTED` |
| Dòng hướng dẫn | khi chưa chọn item | `KEY_MỚI LOADOUT_HINT_SELECT` |
| Dòng chọn | khi đã chọn: tên `display_name_vi` · footprint `{w}x{h}` · nhãn niêm | tên item theo §8 |
| Dòng lý do | sau chạm ô sai: nhãn `InventoryReason` + tên món | `KEY_MỚI INVENTORY_REASON_*` |

### 4.2 Quy tắc chọn → đặt

1. Chạm một item → item **được chọn** (viền dày + icon "đang chọn"; không chỉ đổi màu). Chạm lại item đó → bỏ chọn.
   Chạm item khác → đổi lựa chọn.
2. Khi một item được chọn, thành phần gọi `preview_*` cho **mọi** anchor của lưới được phép và đánh dấu mỗi ô anchor:
   hợp lệ = dấu "vừa" (khung + icon tích); không hợp lệ = gạch chéo. Người chơi thấy kết quả **trước** khi chạm.
3. Chạm ô anchor hợp lệ → `commit_*` ngay (một chạm, không O5: §6.2). Thành công: item hiện ở chỗ mới, bỏ chọn, cue
   `ui_place_ok` (vào Hộp: `ui_seal_ok`).
4. Chạm ô không hợp lệ → **không** commit; item giữ chỗ cũ, vẫn được chọn; dòng lý do hiện nhãn của `InventoryReason`
   đầu tiên (thứ tự inventory spec §7) và ô trong `blocking_cells` được viền; cue `ui_invalid`, rung `haptic_warn`.
5. Chạm ô của chính item đang chọn tại đúng anchor cũ → bỏ chọn, không lệnh nào.
6. `commit_*` trả `ok == false` dù preview nói hợp lệ (state đổi giữa chừng) → xử lý như quy tắc 4 với lý do mới.
7. Không có nút xoay, kéo-thả, tự xếp, bỏ món hay "đổi chỗ" ở S02.

### 4.3 Đích được phép theo chế độ (S02)

| Nguồn → đích | `loadout` (O1) | `pickup` (Manifest từ bàn) | `view` (trong run) |
|---|---|---|---|
| Trong cùng ba lô / cùng Hộp | được (`commit_move`) | — | được (`commit_move`) |
| Bàn → ba lô | — | được (`commit_pickup`, target `backpack`) | — |
| Bàn → Hộp | — | được (`commit_pickup`, target `notary_box`) = **niêm** | — |
| Ba lô → Hộp | khóa: `INVENTORY_REASON_CROSS_GRID_LOCKED` | — | được (`commit_seal`), không O5 |
| Hộp → ba lô (rút đồ niêm) | khóa: `INVENTORY_REASON_CROSS_GRID_LOCKED` | — | khóa ở S02: `INVENTORY_REASON_WITHDRAW_LOCKED` (S04 thêm O5) |
| Bất kỳ → túi đeo chéo | khóa: `INVENTORY_REASON_CROSS_GRID_LOCKED` | `WRONG_TARGET` (`sai loại`) | `WRONG_TARGET` (`sai loại`) |
| Túi đeo chéo → bất kỳ | khóa: `INVENTORY_REASON_CROSS_GRID_LOCKED` | — | không chọn được (dòng chọn hiện tên, không ô nào được đánh dấu) |

Lý do khóa O1 khác lưới (`proposed`): beacon spec §7.1 cấm affordance "rút đồ niêm" ở S02; giữ mọi món trong ngăn cũ
cũng giữ đúng câu `LOADOUT_SUMMARY_DEFAULT_KIT` ("Hộp 2x2 có một vật hồi phục đã niêm"). Ô bị khóa vẫn được đánh dấu
gạch chéo và vẫn nêu lý do khi chạm, để người chơi không nghĩ là chạm hỏng.

### 4.4 Đặt Manifest vào Hộp có tính là niêm phong không

**Có.** Inventory spec §5.1: "Niêm (`commit_seal`) = đặt item vào Hộp từ `backpack` hoặc từ `ground` (người chơi chọn ô
Hộp khi nhặt)"; §8.2: `sealed == (item_location == notary_box)`; §5.7 và §5.9.2: Manifest trong Hộp mang
`seal_label = sealed_not_extracted` (nhãn `đã niêm — chưa extract`) và **không** phát tín hiệu hoàn thành; §5.8: không
thao tác Hộp nào đổi contract hay gọi extract. Vì vậy UI hiện ngay nhãn `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED`
trên Manifest trong Hộp, và không chữ nào trên màn gợi ý rằng niêm là đã giao (G10). Theo §4.2.3, ô gợi ý
(`suggest_slot`) chỉ nằm trong ba lô; UI không bao giờ chọn Hộp thay người chơi.

## 5. Từng màn và overlay

### 5.1 S1 — Briefing

**Mục đích:** một màn đọc trong vài giây: mục tiêu, Easy, Cầu tàu A mở, rủi ro đồ không niêm, kit mang theo; rồi vào cảng.

| Phần tử | Vùng / cỡ chạm | Key / dữ liệu |
|---|---|---|
| Tiêu đề | trái-trên 32–720 × 32–96 | `BRIEFING_HEADER_TITLE` |
| Mục tiêu | trái, dưới tiêu đề | `BRIEFING_OBJECTIVE_MAIN` |
| Dòng luật + nút ⓘ | trái; ⓘ 64×64 cuối dòng | `BRIEFING_RULES_LINE` |
| Tooltip đồ không niêm | neo dưới dòng luật, không che nút nào | `BRIEFING_TOOLTIP_UNSEALED_LOSS` |
| Người nói + thoại | trái-dưới 32–720 × 400–560 | `BRIEFING_MENTOR_SPEAKER`, `BRIEFING_MENTOR_LINE` |
| Tóm tắt kit | phải 752–1248 × 32–200 | `LOADOUT_SUMMARY_DEFAULT_KIT` |
| Xem nhanh ba ngăn (chỉ đọc) | phải 752–1248 × 210–470; ba lưới thu nhỏ, chạm vào = mở O1 | nhãn `LOADOUT_LABEL_*`, dữ liệu `inventory.snapshot()` |
| Nút `Sắp lại đồ` | phải, 320×96 | `KEY_MỚI BRIEFING_BUTTON_EDIT_LOADOUT` |
| Nút `Quay lại` | dưới-trái 32–272 × 600–696 | `KEY_MỚI BRIEFING_BUTTON_BACK` |
| Nút `Vào cảng` | dưới-phải 968–1248 × 592–696 | `BRIEFING_BUTTON_ENTER` |
| Lý do nút tắt | ngay trên `Vào cảng` | `BRIEFING_BUTTON_ENTER_BLOCKED` + tên món + nhãn `InventoryReason` của lỗi đầu tiên |
| Đang tải / lỗi | trên nút `Vào cảng` | `KEY_MỚI UI_LOADING`, `KEY_MỚI UI_ERROR_SCENE_LOAD` |

| Trạng thái | Điều kiện | Người chơi thấy |
|---|---|---|
| Mặc định | `inventory.validate()` rỗng | `Vào cảng` bật (icon mũi tên, chữ đậm). |
| Lần đầu trong phiên | S1 hiện lần đầu từ khi mở app | Tooltip tự hiện một lần; chạm tooltip hoặc mở O1 / `Vào cảng` thì ẩn. Không lưu qua phiên (S02 không save). Ⓘ mở lại bất cứ lúc nào. |
| Disabled | `validate()` có lỗi (chỉ xảy ra với dữ liệu hỏng, INV-32) | `Vào cảng` tắt có icon khóa + `BRIEFING_BUTTON_ENTER_BLOCKED` + "tên món · nhãn lý do". Chạm nút tắt: lặp lại lý do một lần (viền), cue `ui_invalid`; không mở O1 thay người chơi, không tự sửa. |
| Đang chờ | Đã chạm `Vào cảng`, scene khu A đang tải | Mọi nút khóa; nút hiện `UI_LOADING`. |
| Lỗi | Tải scene thất bại | Ở lại S1; `UI_ERROR_SCENE_LOAD`; nút bật lại để thử lại. |
| Bị gián đoạn | App xuống nền | Không đổi; trở lại vẫn S1 như cũ. Đang tải thì tiếp tục tải. |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| ⓘ | chạm | Bật/tắt tooltip | tooltip hiện/ẩn; `ui_tap` | chạm lại |
| Tooltip | chạm | Ẩn | — | ⓘ |
| Xem nhanh / `Sắp lại đồ` | chạm | Mở O1 | O1 trượt lên; `ui_tap` | O1 `Hủy` |
| `Quay lại` / Back | chạm | Về Boot | `ui_cancel` | nút vào game của Boot |
| `Vào cảng` (bật) | chạm | `change_scene` khu A, BCN-01 | `UI_LOADING`; `ui_tap` | không (rời màn; S02 không có thoát run) |
| `Vào cảng` (tắt) | chạm | Không gì | lý do được nhấn mạnh; `ui_invalid`, `haptic_warn` | — |

### 5.2 O1 — Loadout (S02: chỉ sắp lại starter kit)

**Mục đích:** xem ba ngăn của starter kit (inventory spec §8.4: ba lô 3x4 rỗng; Hộp 2x2 có `starter_remedy` 1x2 tại
(0,0); túi đeo chéo có một vật hồi phục) và sắp lại trong cùng ngăn bằng chạm chọn → chạm ô. Không kho hub, không mua,
không preset, không xoay, không đổi gear.

| Phần tử | Vùng / cỡ chạm | Key / dữ liệu |
|---|---|---|
| Tiêu đề | trên-trái | `KEY_MỚI LOADOUT_TITLE` |
| Lưới ba lô 3x4 | trái 64–352 × 136–520 (ô 96) | §4.1 |
| Hộp 2x2 | giữa 448–640 × 136–328 | §4.1 |
| Túi đeo chéo | giữa 448–… × 392–488 (kích thước theo `sling_pouch.size`) | §4.1 |
| Dòng hướng dẫn / chọn / lý do | dưới lưới 64–960 × 540–580 | §4.1 |
| Tóm tắt kit | phải 736–1248 × 136–320 | `LOADOUT_SUMMARY_DEFAULT_KIT` |
| Nút `Hủy` | dưới-trái 32–272 × 600–696 | `KEY_MỚI LOADOUT_BUTTON_CANCEL` |
| Nút `Xong` | dưới-phải 968–1248 × 600–696 | `KEY_MỚI LOADOUT_BUTTON_DONE` |

Quy tắc:

1. Khi O1 mở, UI lấy `snapshot_open = inventory.snapshot()`. Mọi `commit_move` trong O1 ghi thẳng vào inventory.
2. `Xong` → đóng O1, giữ thay đổi, S1 đọc lại xem nhanh và `validate()`.
3. `Hủy` / Back → `inventory.load_snapshot(snapshot_open)` rồi đóng; S1 trở lại **đúng** trạng thái trước khi mở O1
   (so bằng `snapshot()`). Không hỏi xác nhận (hủy là an toàn).
4. Vì mọi commit đều nguyên tử, O1 không thể tạo placement sai; `Xong` luôn bật. Nếu `validate()` đã có lỗi lúc mở
   (dữ liệu hỏng), O1 vẫn mở, đánh dấu món lỗi bằng icon cảnh báo + nhãn lý do; người chơi tự di chuyển món đó trong
   ngăn của nó. Không tự sửa/xóa (INV-32).

| Trạng thái | Người chơi thấy |
|---|---|
| Mặc định (chưa chọn) | Ba ngăn đầy đủ; `LOADOUT_HINT_SELECT`. |
| Đã chọn item | Dòng chọn; ô anchor được đánh dấu theo §4.2–4.3. Với `starter_remedy` tại (0,0): chỉ (1,0) hợp lệ; (0,1), (1,1) gạch chéo (`OUT_OF_BOUNDS`); ô ba lô/túi gạch chéo (`CROSS_GRID_LOCKED`). |
| Lỗi chạm | Dòng lý do; món giữ chỗ cũ, vẫn được chọn. |
| Dữ liệu hỏng | Món lỗi có icon cảnh báo + nhãn lý do; S1 `Vào cảng` tắt tới khi hết lỗi. |
| Bị gián đoạn | App xuống nền: không đổi; trở lại vẫn O1, lựa chọn đang có bị bỏ (an toàn). |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| Item | chạm | Chọn / bỏ chọn | viền + icon chọn; `ui_tap` | chạm lại |
| Ô hợp lệ | chạm | `commit_move` | item tới chỗ mới; `ui_place_ok`, `haptic_light` | chạm item rồi chạm ô cũ; hoặc `Hủy` |
| Ô không hợp lệ / bị khóa | chạm | Không đổi | lý do + viền `blocking_cells`; `ui_invalid`, `haptic_warn` | — |
| `Xong` | chạm | Về S1, giữ thay đổi | `ui_tap` | mở lại O1 và sắp lại |
| `Hủy` / Back | chạm | Về S1, khôi phục `snapshot_open` | `ui_cancel` | — |

### 5.3 HUD khu A (S2, S3) và nút ngữ cảnh

**Mục đích:** luôn cho biết một objective, bàn dispatch ở đâu, beacon A đang gọi được hay chưa và vì sao, và đúng một
action ngữ cảnh khi action đó hợp lệ.

| Phần tử | Vùng | Hiện khi | Key / dữ liệu |
|---|---|---|---|
| H1 Objective | R1 | luôn (trừ S10) | theo bảng 5.3.1 |
| H3 `Đồ mang theo` | R3, 96×96 | S2, S3, S7, S8, S9 khi không có O2/O5 mở | `KEY_MỚI HUD_BUTTON_INVENTORY` (icon ba lô + chữ) |
| H4 Nút ngữ cảnh | R5, 240×112 | theo bảng 5.3.2 | theo bảng 5.3.2 |
| H5 Prompt | R4 | theo hàng đợi 5.3.3 | `PROMPT_*`, toast lý do |
| W1 Nhãn bàn (thế giới) | trên `DispatchDesk` | `desk_state == HAS_MANIFEST` | `WORLD_INTERACT_DISPATCH_DESK` + icon tương tác |
| W2 Nhãn beacon (thế giới) | trên `BeaconA`; khi ra ngoài màn hình thì thành mũi tên ở mép màn kèm nhãn ngắn | luôn | E0: icon "chưa mở" + `BEACON_E0_STATE_LABEL`; E1: icon thuyền + `BEACON_E1_STATE_LABEL`; dòng lý do bên dưới theo bảng 5.3.1 |
| W3 Vòng đèn phao | mặt sàn quanh `BeaconZoneA` | từ E1 trở đi | đường biên có hình (không chỉ màu); bán kính `BEACON_ZONE_RADIUS_M` |
| W4 Chỗ lên thuyền | mặt sàn `BoardZoneA` | chỉ S9 | dấu hình thuyền/bậc lên; bán kính `BOARD_ZONE_RADIUS_M` |

#### 5.3.1 Objective và dòng lý do beacon theo state

| State (beacon spec) | H1 Objective | W2 dòng lý do |
|---|---|---|
| BCN-01 E0, ngoài vòng | `HUD_OBJECTIVE_TAKE_MANIFEST` | — |
| BCN-02 E0, trong vòng | `HUD_OBJECTIVE_TAKE_MANIFEST` | `BEACON_E0_STATE_REASON` (cũng hiện ở R4 một lần mỗi lần bước vào vòng) |
| BCN-06/07 E1, ngoài vòng (BCN-09) | `HUD_OBJECTIVE_DELIVER_PIER_A` | `KEY_MỚI BEACON_E1_OUT_OF_ZONE_REASON` |
| BCN-10 E1, trong vòng | `HUD_OBJECTIVE_DELIVER_PIER_A` | — (nút `Gọi thuyền` thay lời nhắc) |
| S7 / S8 / S9 | xem §5.8 | — |

#### 5.3.2 Nút ngữ cảnh H4 (một nút, không bao giờ hai action cùng lúc)

| Điều kiện | Nhãn | Chạm → |
|---|---|---|
| `desk_state == HAS_MANIFEST` **và** player trong `DESK_INTERACT_RADIUS_M` (2.0 m `proposed`, level-designer chốt) | icon tương tác + `WORLD_INTERACT_DISPATCH_DESK` | mở O2 (BCN-04) |
| `can_call()` đúng | icon thuyền + `EXTRACT_E1_BUTTON_CALL` | `request_call()` → O5 (BCN-11) |
| `can_board()` đúng | icon bậc lên + `EXTRACT_S9_BUTTON_BOARD` | `board()` → S10 (BCN-24) |
| còn lại | ẩn (không hiện nút tắt) | — |

Ba điều kiện loại trừ nhau theo state (bàn chỉ khi `NOT_TAKEN`, gọi chỉ khi E1, lên thuyền chỉ khi S9), nên kể cả khi
bàn nằm sát beacon (beacon spec §11.2) cũng chỉ có một nút. Nút hiện/ẩn bằng một lần trượt vào/ra, không nhấp nháy.
Nút không bao giờ tự kích hoạt khi player bước vào vùng.

#### 5.3.3 Hàng đợi prompt R4 (một prompt mỗi lúc, vertical slice §2.2)

1. `PROMPT_SAFEBOX_SEAL_HINT` hiện trong chân panel O3/O4 ngay sau khi xếp Manifest (§5.5), không ở R4.
2. Khi panel đó đóng lần đầu: R4 hiện `PROMPT_ROUTE_EXTRACT_NOW` (kèm icon beacon). Không chặn input, không phải nút.
   Ẩn khi player vào `BeaconZoneA`, chạm vào prompt, hoặc sau `ROUTE_PROMPT_SECONDS = 8` (`proposed`).
3. `PROMPT_ROUTE_GO_MARKET` không hiện ở S02 (§2.3, Q2).
4. Toast lý do (ví dụ `EXTRACT_CONFIRM_CLOSED_LEFT_ZONE`, `BEACON_E0_STATE_REASON`) chen trước prompt route; mỗi toast
   hiện 3 giây `proposed`, không chồng nhau.

| Trạng thái HUD | Người chơi thấy |
|---|---|
| Mặc định S2 | H1 lấy Manifest; W1 trên bàn; W2 E0; H4 ẩn tới khi vào tầm bàn. |
| S3 | H1 đưa ra Cầu tàu A; W1 ẩn; W2 E1 + lý do ngoài vòng; W3 hiện; H4 ẩn tới khi vào vòng. |
| Disabled | Không có nút tắt: action không hợp lệ thì nút không hiện, và W2/R4 nói vì sao. |
| Bị gián đoạn | App xuống nền: overlay đang mở giữ nguyên; khi trở lại, chặn chạm `UI_OPEN_GUARD_SECONDS` một lần nữa. |
| Chết giữa action | Không có ở S02 (không địch). Ranh giới: mọi overlay đóng như hủy, không commit; sang S11 (ngoài spec). |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| Joystick | kéo trong R6 | Di chuyển | hiện có | — |
| H4 bàn dispatch | chạm | O2 | O2 trượt vào R7; `ui_tap` | O2 `Đóng` |
| H4 `Gọi thuyền` | chạm | O5 | O5 hiện ở R9; `ui_confirm_open` | O5 `Hủy` |
| H4 `Lên thuyền` | chạm | S10 | chuyển màn; `board_ok`, `haptic_success` | không (run kết thúc, đúng luật) |
| H3 `Đồ mang theo` | chạm | O3/O4 chế độ `view` | panel R8; `ui_tap` | `Đóng` |
| Prompt R4 | chạm | Ẩn prompt | — | — |

### 5.4 O2 — Card Manifest (bàn dispatch A)

**Mục đích:** cho người chơi đọc Manifest là gì trước khi quyết định nhặt; mở/đóng không đổi gì (BCN-04, BCN-05).

| Phần tử (đúng thứ tự trên xuống) | Vùng | Key |
|---|---|---|
| Badge vật chứng (góc trên-phải card, không chen giữa các dòng) | R7 | `CARD_MANIFEST_R17_STATE_NOT_EXTRACTED` + icon vật chứng |
| Hình dáng item + tên | R7 | `CARD_MANIFEST_R17_NAME` |
| Footprint (sơ đồ 1 ô + chữ) | R7 | `CARD_MANIFEST_R17_FOOTPRINT` |
| Công dụng | R7 | `CARD_MANIFEST_R17_USE` |
| Claim (icon phe + chữ) | R7 | `CARD_MANIFEST_R17_CLAIM` |
| Lớp thẩm định (chữ + dấu bậc 2/6, không chỉ màu) | R7 | `CARD_MANIFEST_R17_RARITY` |
| Lore một dòng | R7 | `CARD_MANIFEST_R17_LORE` |
| Nút `Nhặt và xếp` (chính) | đáy R7, phải, 264×96 | `CARD_ACTION_PICK_AND_PLACE` |
| Nút `Đóng` | đáy R7, trái, 200×96 | `CARD_ACTION_CLOSE` |

| Trạng thái | Người chơi thấy |
|---|---|
| Mặc định | Card đủ sáu dòng + badge; hai nút bật. H1, R6 joystick, W2 vẫn thấy. |
| Không còn chỗ (không ô nào hợp lệ ở ba lô lẫn Hộp; không xảy ra với kit S02) | `Nhặt và xếp` vẫn bật; panel nhặt mở ra và cho thấy mọi ô gạch chéo kèm lý do. Không auto-drop/swap/seal. |
| Rời tầm bàn khi card mở | Card đóng như `Đóng`; Manifest vẫn ở bàn. |
| Bị gián đoạn | Card giữ nguyên khi trở lại. |
| Chết giữa action | Ranh giới: card đóng như `Đóng`. |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| `Nhặt và xếp` | chạm | O2 đóng, mở O3/O4 `pickup` | panel R8; `ui_tap` | `Đóng` panel (Manifest vẫn ở bàn) |
| `Đóng` / Back | chạm | Về S2, không đổi gì | `ui_cancel` | chạm lại bàn |

### 5.5 O3/O4 — Đặt Manifest (chế độ `pickup`, rồi `view`)

**Mục đích:** người chơi tự chọn ô cho Manifest ở ba lô **hoặc** Hộp; chỉ ô hợp lệ mới chuyển Manifest; sai thì Manifest
vẫn ở bàn và người chơi biết vì sao.

| Phần tử | Vùng | Key / dữ liệu |
|---|---|---|
| Thẻ "đang cầm" (Manifest chưa nhặt) | đầu R8 | tên `CARD_MANIFEST_R17_NAME`, sơ đồ 1x1, badge vật chứng, `KEY_MỚI INVENTORY_PICKUP_SOURCE_DESK` |
| Hướng dẫn | dưới thẻ | `KEY_MỚI INVENTORY_PICKUP_HINT` |
| Lưới ba lô 3x4 | R8 trái (ô 96) | §4.1; ô `suggest_slot` có thêm icon gợi ý (chỉ ba lô) |
| Hộp 2x2 | R8 phải | §4.1; `starter_remedy` mang nhãn `đã niêm` |
| Dòng lý do | chân R8 | `INVENTORY_REASON_*` |
| Nút `Đóng` | chân R8, trái, 200×96 | `CARD_ACTION_CLOSE` |

Quy tắc:

1. Manifest coi như đã được chọn; mọi ô anchor của ba lô và Hộp được đánh dấu bằng `preview_pickup(manifest, grid,
   anchor, false)`. Với kit S02: 12 ô ba lô hợp lệ; Hộp chỉ (1,0), (1,1) hợp lệ; (0,0), (0,1) gạch chéo
   (`CELLS_OCCUPIED`).
2. Chạm ô hợp lệ → `commit_pickup(manifest, grid, anchor, false)`. `ok` → BCN-06 (ba lô) hoặc BCN-07 (Hộp): thẻ "đang
   cầm" biến mất, Manifest hiện trong ô; nếu ở Hộp thì kèm nhãn `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED`. Panel
   **không** tự đóng; nó chuyển sang `view` và chân panel hiện `PROMPT_SAFEBOX_SEAL_HINT`. H1 đổi sang
   `HUD_OBJECTIVE_DELIVER_PIER_A`, W2 đổi sang E1 ngay sau panel (thấy được qua phần thế giới còn lộ).
3. Chạm ô không hợp lệ → không commit; Manifest vẫn ở bàn (`desk_state` vẫn `HAS_MANIFEST`, E0); lý do hiện; thử ô khác.
4. `Đóng` / Back / rời tầm bàn trước khi xếp → đóng panel, về S2; không đổi gì (BCN-05). Không quay lại O2.
5. Không có lựa chọn "tự xếp" hay "xếp vào chỗ gợi ý": icon gợi ý chỉ là gợi ý, người chơi vẫn phải chạm ô.

Chế độ `view` (sau khi xếp, hoặc mở từ H3): quy tắc §4.2–4.3 cột `view`. Người chơi có thể chuyển Manifest ba lô → Hộp
(niêm, không O5) hoặc di chuyển trong cùng lưới. Chân panel hiện `PROMPT_SAFEBOX_SEAL_HINT` khi Manifest đang ở ba lô
**hoặc** Hộp (câu nhắc vẫn phải extract đúng cả hai trường hợp). Tiêu đề panel `KEY_MỚI INVENTORY_PANEL_TITLE`.

| Trạng thái | Người chơi thấy |
|---|---|
| `pickup` mặc định | Thẻ đang cầm + ô đánh dấu + gợi ý ba lô. |
| `pickup` lỗi | Lý do + viền ô chặn; Manifest vẫn ở thẻ "còn ở bàn". |
| Đã xếp (`view`) | Manifest trong ô + badge (+ nhãn niêm nếu ở Hộp) + seal hint. |
| `view` không chọn | `LOADOUT_HINT_SELECT`. |
| `view` lỗi | Lý do; món giữ chỗ cũ. Hộp → ba lô: `INVENTORY_REASON_WITHDRAW_LOCKED`. |
| Bị gián đoạn | Panel giữ nguyên; lựa chọn bị bỏ. |
| Chết giữa action | Ranh giới: panel đóng như `Đóng`, không commit. |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| Ô hợp lệ (`pickup`) | chạm | `commit_pickup` → S3/E1 | Manifest vào ô; `ui_place_ok` hoặc `ui_seal_ok`, `haptic_success` | Không trả về bàn được (bàn không quay lại `HAS_MANIFEST`); vẫn di chuyển/niêm được trong `view` |
| Ô không hợp lệ | chạm | Không đổi | lý do; `ui_invalid`, `haptic_warn` | — |
| Manifest (`view`) → ô Hộp trống | chạm, chạm | `commit_seal` | nhãn `đã niêm — chưa extract`; `ui_seal_ok` | Không ở S02 (rút ra là S04) — nêu bằng `WITHDRAW_LOCKED` khi thử |
| `Đóng` / Back | chạm | Về HUD | `ui_cancel`; lần đầu sau xếp: R4 hiện prompt route | H3 mở lại |

### 5.6 Beacon E0/E1 khi vào/ra vòng đèn phao

Không có màn riêng; xem W2, W3, H4 ở §5.3. Đứng trong vòng ở E0 không tạo extract, không mở O5, không hiện nút gọi
(BCN-02/03). Ở E1, nút `Gọi thuyền` chỉ hiện khi `can_call()` đúng (BCN-10) và không tự mở O5.

### 5.7 O5 — Xác nhận gọi thuyền

**Mục đích:** cho thấy hậu quả trước khi bắt đầu giữ khu, và cho hủy một chạm (G11, G13).

| Phần tử | Vùng / cỡ | Key / dữ liệu |
|---|---|---|
| Tiêu đề | R9 trên | `EXTRACT_CONFIRM_TITLE` |
| Thân (hậu quả) | R9 giữa | `EXTRACT_CONFIRM_BODY` với `{seconds} = EXTRACT_HOLD_SECONDS` (20) |
| Nút `Hủy` | 400–600 × 408–504 | `EXTRACT_CONFIRM_CANCEL` |
| Nút `Gọi` | 680–880 × 408–504 (icon thuyền) | `EXTRACT_CONFIRM_ACCEPT` |

Quy tắc:

1. Mở bằng `request_call()` trả `true`; O5 không dừng thế giới; joystick (R6) và H1 vẫn dùng/đọc được. H3, H4 ẩn khi O5 mở.
2. Không nút nào của O5 nằm trong R5, nên chạm đúp vào `Gọi thuyền` không thể xác nhận nhầm; thêm chặn chạm 0.3 giây.
3. `Gọi` → `confirm_call()`. `true` → O5 đóng, S7 (BCN-14). `false` → O5 đóng, HUD về E1/E0 với lý do của bảng 5.3.1
   (BCN-15).
4. `Hủy` / Back → `cancel_call()`; về E1, nút `Gọi thuyền` hiện lại (BCN-12). Chạm ra ngoài panel **không** hủy và
   không xác nhận (tránh chạm nhầm khi đang đi).
5. Rời `BeaconZoneA` khi O5 mở → O5 đóng như hủy (BCN-13); R4 hiện `KEY_MỚI EXTRACT_CONFIRM_CLOSED_LEFT_ZONE`; W2 hiện
   `BEACON_E1_OUT_OF_ZONE_REASON`. Quay lại vòng phải chạm `Gọi thuyền` lần nữa.

| Trạng thái | Người chơi thấy |
|---|---|
| Xác nhận (mặc định) | Tiêu đề, thân có số 20, hai nút. |
| Hủy | O5 đóng, E1, nút `Gọi thuyền`. |
| Đóng do rời vòng | Toast lý do; E1 ngoài vòng. |
| Lỗi (guard sai lúc `Gọi`) | O5 đóng; không vào S7; lý do qua W2/R4. |
| Bị gián đoạn | O5 giữ nguyên khi trở lại, chặn chạm 0.3 giây lại; không tự xác nhận hay tự hủy. |
| Chết giữa action | Ranh giới (BCN-30): O5 đóng, không `confirm_call`. |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| `Gọi` | chạm | S7 | banner R2 `EXTRACT_S7_CALL_ACCEPTED`; `extract_call_ok`, `haptic_success` | Không (đã xác nhận rủi ro; đúng luật) |
| `Hủy` / Back | chạm | E1 | O5 đóng; `ui_cancel` | chạm `Gọi thuyền` lại |

**Thao tác không mở O5** (beacon spec §7.2): di chuyển nhân vật · move item trong lưới · xoay (không có ở S02) ·
xem card / inspect · đóng hay hủy overlay · preview placement · `Nhặt và xếp` · niêm item vào Hộp (kể cả nhặt thẳng vào
Hộp) · `Bỏ qua` / `Đóng` card · vào/ra vòng đèn phao · giữ khu · `Lên thuyền` · `Về hub`. Ở S02 UI **không** có
affordance bỏ item, rút đồ niêm hay đổi gear; ba action đó thêm ở S04 cùng O5 của chúng.

### 5.8 HUD S7 / S8 / S9

**Mục đích:** cho biết cuộc gọi đã nhận, còn bao nhiêu giây, đồng hồ có đang chạy không và vì sao, và khi nào lên thuyền.

| State | H1 Objective | Banner R2 | W3 / W4 | H4 |
|---|---|---|---|---|
| S7 (`EXTRACT_CALL_ACK_SECONDS` = 1.5) | `HUD_OBJECTIVE_DELIVER_PIER_A` | `EXTRACT_S7_CALL_ACCEPTED` + icon thuyền đang tới | W3 | ẩn |
| S8 chạy | `HUD_OBJECTIVE_HOLD_PIER_A` | `EXTRACT_S8_HOLD_TIMER` với `{seconds} = hold_seconds_display()` + vòng tiến độ `hold_remaining / EXTRACT_HOLD_SECONDS` | W3 | ẩn |
| S8 tạm dừng, `hold_pause_reason == out_of_zone` | `HUD_OBJECTIVE_HOLD_PIER_A` | Số giây đứng yên + icon tạm dừng + dòng `KEY_MỚI EXTRACT_S8_HOLD_PAUSED` | W3 nổi rõ hơn (một lần) | ẩn |
| S8 tạm dừng, `manifest_missing` (từ S04) | như trên | icon tạm dừng + `BEACON_E0_STATE_REASON` | W3 | ẩn |
| S9 | `HUD_OBJECTIVE_BOARD_BOAT` | `EXTRACT_S9_BOAT_READY` | W4 hiện | `Lên thuyền` khi `can_board()` |
| S10 | — | — | — | — |

Quy tắc:

1. Số giây là số nguyên, không âm, đọc từ `hold_seconds_display()` mỗi khung vẽ; giá trị đầu là 20 (BCN-16).
2. Tạm dừng: số giữ nguyên (không reset), icon tạm dừng thay icon chạy, dòng lý do hiện; vào lại vòng → icon chạy, số
   giảm tiếp từ chỗ cũ (BCN-18/19). Đổi chạy ↔ dừng có cue `extract_hold_pause` / `extract_hold_resume`.
3. Không cảnh báo lane, không `EXTRACT_S8_LANE_ALERT`, không âm thanh/đèn báo địch ở S02 (beacon spec §8).
4. S9 không có đồng hồ, không timeout; rời mọi vùng không đổi gì (BCN-23). Nút `Lên thuyền` chỉ hiện trong `BoardZoneA`;
   ngoài đó H1 + W4 chỉ chỗ.
5. Cuộc gọi đã xác nhận không có nút hủy; không có checkpoint giữa S7/S8/S9.
6. H3 `Đồ mang theo` vẫn mở được trong S7–S9 (không dừng đồng hồ: panel không làm player rời vòng).

| Trạng thái | Người chơi thấy |
|---|---|
| Đang chờ (S7) | Banner nhận cuộc gọi; chưa có số. |
| Chạy / Tạm dừng | Như bảng trên. |
| Sẵn sàng (S9) | Banner thuyền cập bến; W4; nút khi đứng đúng chỗ. |
| Bị gián đoạn | App xuống nền: đồng hồ chỉ giảm tối đa `MAX_TICK_DELTA` mỗi tick, nên trở lại thấy gần đúng số cũ; không tự sang S9 khi ở nền. |
| Chết giữa action | Ranh giới (BCN-30): banner biến mất, không chữ success; S11 ngoài spec. |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| Joystick ra/vào vòng | kéo | Tạm dừng / chạy tiếp | icon + dòng lý do; cue pause/resume | vào lại vòng |
| H4 `Lên thuyền` | chạm | `board()` → S10 | `board_ok`, `haptic_success` | không |

### 5.9 S10 — Summary thành công (rút sớm)

**Mục đích:** người chơi đọc được đã giữ gì, mất gì (nếu có), vật chứng đi đâu và việc tiếp theo; không chấm điểm.

Thứ tự đọc (cũng là thứ tự focus): tiêu đề → `Đã giữ` → `Đã mất` → `Vật chứng` → `Tiếp theo` → câu của Người Thu Hồi
già → `Về hub`. Bố cục hai cột: cột trái 32–624 × 112–576 (`Đã giữ`, `Đã mất`), cột phải 656–1248 × 112–576
(`Vật chứng`, `Tiếp theo`); mỗi cột tự cuộn dọc nếu tràn (kéo dọc = cuộn, không phải action).

| Nhóm / phần tử | Key | Dữ liệu (`ExtractSummary`) |
|---|---|---|
| Tiêu đề (trên, giữa) | `SUMMARY_SUCCESS_TITLE` | — |
| `Đã giữ` | `SUMMARY_GROUP_KEPT`; dòng đầu `SUMMARY_SUCCESS_KEPT_LICENCE`; mỗi item một dòng tên `display_name_vi` (không gộp, mỗi `uid` một dòng); dòng cuối `SUMMARY_SUCCESS_KEPT_CELLS` | `kept[]`; `{used} = backpack_cells_used`, `{total} = backpack_cells_total` |
| `Đã mất` | `SUMMARY_GROUP_LOST`; mỗi item: tên + `SUMMARY_SUCCESS_LOST_LEFT_BEHIND` | `lost[]` |
| `Vật chứng` (icon vật chứng, tách khỏi item thường) | `SUMMARY_GROUP_EVIDENCE`; `SUMMARY_SUCCESS_EVIDENCE_MANIFEST`, `SUMMARY_SUCCESS_EVIDENCE_LIMIT`, `SUMMARY_SUCCESS_EVIDENCE_LEAD` | `evidence[]` |
| `Tiếp theo` | `SUMMARY_GROUP_NEXT`; card `SUMMARY_NEXT_CONTRACT2_TITLE` + tag `SUMMARY_NEXT_CONTRACT2_TAG` (icon khóa) | `next[]` với `playable == false` |
| Người nói + câu phản ứng (dưới, trái) | `BRIEFING_MENTOR_SPEAKER` (dùng lại), `SUMMARY_SUCCESS_MENTOR_LINE` | — |
| Nút `Về hub` (dưới-phải 968–1248 × 600–696) | `SUMMARY_BUTTON_HUB` | → Boot |

Quy tắc:

1. **`Đã mất` rỗng → ẩn cả nhóm** (tiêu đề lẫn khung), không hiện "không có" (`proposed`; khớp beacon spec §10.5 và
   `contract-1-strings` "S10 ẩn nếu rỗng"). Ở S02 `lost` luôn rỗng nên nhóm không bao giờ hiện; cột trái chỉ có `Đã giữ`.
2. Card Contract 2 **không** có nút bắt đầu, không phản hồi chạm (không trạng thái nhấn), có icon khóa + tag chữ.
3. Không điểm, xếp hạng, route đã đi, tổng giá trị hay thời gian (beacon spec §10.4). Rút sớm và full-route chỉ khác
   danh sách và số ô.
4. Manifest **không** nằm trong `Đã giữ`; chỉ nằm trong `Vật chứng`.
5. `Về hub` / Back → scene Boot; không lưu tiến trình (BCN-25); nút tự khóa sau chạm đầu.

| Trạng thái | Người chơi thấy |
|---|---|
| Mặc định (S02 rút sớm) | Tiêu đề; `Đã giữ` (giấy phép, các vật hồi phục, ô 1/12 hoặc 0/12); `Vật chứng`; `Tiếp theo`; câu mentor; `Về hub`. |
| Có `Đã mất` (từ S04) | Nhóm hiện giữa `Đã giữ` và `Vật chứng`. |
| Đang chờ | `Về hub` đã chạm: nút khóa, `UI_LOADING`. |
| Lỗi | Tải Boot thất bại: `UI_ERROR_SCENE_LOAD`, nút bật lại. |
| Bị gián đoạn | Không đổi; summary giữ nguyên tới khi chạm `Về hub`. |

| Phần tử | Cử chỉ | Kết quả | Phản hồi | Hoàn tác |
|---|---|---|---|---|
| Cột danh sách | kéo dọc | Cuộn | — | — |
| Card Contract 2 | chạm | Không gì | — | — |
| `Về hub` / Back | chạm | Boot | `ui_tap` | không (S02 không lưu) |

## 6. Hành động nguy cơ (G11) trong S02

### 6.1 Có O5

| Action | Preview hậu quả | Xác nhận / hủy | Sprint |
|---|---|---|---|
| `Gọi thuyền` (kể cả rút sớm) | `EXTRACT_CONFIRM_BODY` nêu số giây giữ khu và việc phải tự lên thuyền | `Gọi` / `Hủy` | **S02** |
| Bỏ item, rút đồ niêm, đổi gear | — | — | S04 (không có affordance ở S02) |

### 6.2 Không có O5 ở S02 (và vì sao an toàn)

`Nhặt và xếp` và chạm ô (pickup): người chơi đã chọn ô nhìn thấy trước · move trong lưới: đổi lại được ngay · niêm
ba lô → Hộp: món được bảo vệ hơn, không mất gì · `Xong`/`Hủy` O1: `Hủy` khôi phục đầy đủ · `Lên thuyền`: rủi ro đã
xác nhận ở `Gọi` · `Về hub`: S02 không có tiến trình để mất.

## 7. Dữ liệu đọc bởi UI

| Phần tử | Field |
|---|---|
| S1 `Vào cảng`, lý do tắt | `RetrieverInventory.validate()` (lỗi đầu tiên: `uid` → `display_name_vi`, `reason`) |
| Lưới (O1, O3/O4, S1 xem nhanh) | `backpack`, `notary_box`, `sling_pouch` (`size`, `item_at`), `ItemInstance.cells()`, `seal_label(uid)`, `ItemDef.item_category` |
| Đánh dấu ô | `preview_move` / `preview_pickup` / `preview_seal` → `InventoryResult.ok`, `reason`, `blocking_cells` |
| Ô gợi ý (pickup) | `suggest_slot(&"manifest_r17", 1)` |
| H1, W1, W2, W3, H4 | `ExtractPierAFlow.extract_state`, `contract_state`, `desk_state`, `in_beacon_zone`, `in_board_zone`, `can_call()`, `can_board()`, `call_confirm_open` |
| Banner S8 | `hold_seconds_display()`, `hold_remaining`, `hold_paused`, `hold_pause_reason` |
| O5 `{seconds}` | `EXTRACT_HOLD_SECONDS` |
| S10 | `ExtractSummary.kept`, `lost`, `evidence`, `next`, `backpack_cells_used`, `backpack_cells_total` |
| Tầm bàn dispatch | khoảng cách player ↔ `DispatchDesk` ≤ `DESK_INTERACT_RADIUS_M` (`proposed` 2.0 m) |

## 8. Chữ còn thiếu (giao TASK-71)

Mọi key dưới đây là `KEY_MỚI` `proposed`; giới hạn ký tự theo bảng loại của [contract-1-strings](contract-1-strings.md) §1.

| Key đề xuất | Màn | Ngữ cảnh / ý cần nói | Tối đa |
|---|---|---|---:|
| `BRIEFING_BUTTON_EDIT_LOADOUT` | S1 | Nút mở O1 để sắp lại đồ | 24 |
| `BRIEFING_BUTTON_BACK` | S1 | Nút về Boot | 24 |
| `UI_LOADING` | S1, S10 | Nhãn đang chuyển màn | 24 |
| `UI_ERROR_SCENE_LOAD` | S1, S10 | Không chuyển màn được; mời chạm lại | 72 |
| `LOADOUT_TITLE` | O1 | Tiêu đề màn sắp lại đồ | 32 |
| `LOADOUT_HINT_SELECT` | O1, O3/O4 | Chạm một món, rồi chạm ô có dấu vừa | 72 |
| `LOADOUT_BUTTON_DONE` | O1 | Giữ thay đổi, về briefing | 24 |
| `LOADOUT_BUTTON_CANCEL` | O1 | Bỏ thay đổi, về briefing | 24 |
| `INVENTORY_REASON_OK` … `INVENTORY_REASON_SORT_NO_FIT` (12 key, một key mỗi giá trị `InventoryReason`) | O1, O3/O4 | Nhãn lý do; chữ gợi ý là cột "Nhãn UI" của inventory spec §7 (`vừa`, `thiếu ô`, `không vừa`, `sai loại`…). Hiện code giữ nhãn trong `InventoryReason.label_vi`; UI sẽ dùng key. | 24 |
| `INVENTORY_REASON_CROSS_GRID_LOCKED` | O1 | Ở loadout chỉ sắp lại trong cùng ngăn | 72 |
| `INVENTORY_REASON_WITHDRAW_LOCKED` | O3/O4 trong run | Chưa rút được đồ đã niêm ra khỏi Hộp | 72 |
| `INVENTORY_PANEL_TITLE` | O3/O4 `view` | Tiêu đề panel đồ đang mang | 32 |
| `INVENTORY_PICKUP_HINT` | O3/O4 `pickup` | Chạm ô ba lô hoặc Hộp để xếp Manifest; Hộp = niêm | 72 |
| `INVENTORY_PICKUP_SOURCE_DESK` | O3/O4 `pickup` | Tag: Manifest còn ở bàn, chưa nhặt | 24 |
| `HUD_BUTTON_INVENTORY` | HUD H3 | Nút mở panel đồ mang theo | 24 |
| `BEACON_E1_OUT_OF_ZONE_REASON` | W2, E1 ngoài vòng | Nhắc vào vòng đèn phao để gọi (beacon spec §10.6) | 72 |
| `EXTRACT_S8_HOLD_PAUSED` | R2, S8 tạm dừng | Đồng hồ dừng vì ra khỏi vòng; quay lại để chạy tiếp (beacon spec §10.6) | 72 |
| `EXTRACT_CONFIRM_CLOSED_LEFT_ZONE` | R4, O5 đóng do rời vòng | Đã hủy gọi thuyền vì rời vòng đèn phao | 72 |
| `ITEM_STARTER_REMEDY_NAME` | O1, O3/O4, S10 | Tên vật hồi phục starter (đang là "tên cuối chưa chốt", inventory spec §8.3); tên mới cần duyệt glossary | 24 |

Key S04 đã nêu ở beacon spec §10.6 (`HUD_OBJECTIVE_PICK_UP_MANIFEST`, key O5 bỏ/rút/đổi gear) **không** cần cho S02.

## 9. Acceptance tests (given / when / then)

Tên test: `test_uxa_xx_<mô_tả>`. "Không đổi" = `inventory.snapshot()` và ba state của `ExtractPierAFlow` bằng nhau,
không có signal của flow. Test UI chạy được headless bằng cách gửi sự kiện chạm vào node; test cần nhìn (cỡ chữ, không
chỉ màu) chạy tay trên khung 1280×720.

| Mã | Given | When | Then |
|---|---|---|---|
| UXA-01 | Boot | Chạm nút vào game | S1 hiện; chưa vào khu A. |
| UXA-02 | S1, kit mặc định | Đọc màn | Có `BRIEFING_HEADER_TITLE`, `BRIEFING_OBJECTIVE_MAIN`, `BRIEFING_RULES_LINE`, `BRIEFING_MENTOR_*`, `LOADOUT_SUMMARY_DEFAULT_KIT`; `Vào cảng` bật. |
| UXA-03 | S1 lần đầu trong phiên | Mở S1 | Tooltip `BRIEFING_TOOLTIP_UNSEALED_LOSS` hiện; lần mở S1 thứ hai trong phiên thì không tự hiện; ⓘ mở lại được. |
| UXA-04 | `load_snapshot` với hai item chồng ô (INV-32) | Mở S1 | `Vào cảng` tắt, có icon khóa và `BRIEFING_BUTTON_ENTER_BLOCKED` + tên món + nhãn lý do; chạm nút không đổi scene, không đổi inventory. |
| UXA-05 | S1 | Chạm `Quay lại` / Back | Về Boot; không đổi inventory. |
| UXA-06 | O1 mở, kit mặc định | Chạm `starter_remedy` | Chỉ ô Hộp (1,0) mang dấu vừa; (0,1), (1,1) gạch chéo; mọi ô ba lô và túi gạch chéo. |
| UXA-07 | UXA-06 | Chạm Hộp (1,0) | `commit_move` ok; remedy chiếm (1,0),(1,1); nhãn `đã niêm` còn nguyên. |
| UXA-08 | UXA-06 | Chạm ô ba lô (0,0) | Không đổi; dòng lý do `INVENTORY_REASON_CROSS_GRID_LOCKED`; remedy vẫn được chọn. |
| UXA-09 | UXA-06 | Chạm Hộp (0,1) | Không đổi; lý do nhãn `OUT_OF_BOUNDS`. |
| UXA-10 | UXA-07 | Chạm `Hủy` | S1; `snapshot()` bằng snapshot lúc mở O1 (remedy về (0,0)). |
| UXA-11 | UXA-07 | Chạm `Xong` | S1; xem nhanh cho remedy ở (1,0); `Vào cảng` bật. |
| UXA-12 | O1 | Tìm nút | Không có nút xoay, kho hub, mua, preset, bỏ món hay đổi gear. |
| UXA-13 | S1 | Chạm `Vào cảng` hai lần nhanh | Đúng một lần chuyển scene; HUD BCN-01: H1 `HUD_OBJECTIVE_TAKE_MANIFEST`, W2 `BEACON_E0_STATE_LABEL`, W1 trên bàn. |
| UXA-14 | S2, player ngoài tầm bàn | Đọc HUD | H4 ẩn. |
| UXA-15 | S2, player vào `BeaconZoneA` | Đọc HUD | W2 có `BEACON_E0_STATE_REASON`; H4 không phải `Gọi thuyền`; không O5. |
| UXA-16 | S2, player trong tầm bàn | Chạm H4 | O2 mở; dòng card đúng thứ tự NAME → FOOTPRINT → USE → CLAIM → RARITY → LORE; badge `chưa extract`; nút `Nhặt và xếp`, `Đóng`; H1 vẫn hiện. |
| UXA-17 | O2 | Chạm `Đóng` | Không đổi; Manifest còn ở bàn; E0. |
| UXA-18 | O2 | Đi ra ngoài tầm bàn | O2 đóng; không đổi. |
| UXA-19 | O2 | Chạm `Nhặt và xếp` | Panel `pickup`: 12 ô ba lô hợp lệ, ô gợi ý (0,0) có icon gợi ý, Hộp (1,0),(1,1) hợp lệ, (0,0),(0,1) gạch chéo; Manifest vẫn ở bàn (không đổi). |
| UXA-20 | UXA-19 | Chạm Hộp (0,0) | Không đổi; lý do nhãn `CELLS_OCCUPIED`; thẻ "còn ở bàn" vẫn hiện; E0. |
| UXA-21 | UXA-19 | Chạm `Đóng` | Về S2; không đổi; chạm bàn lại mở O2. |
| UXA-22 | UXA-19 | Chạm ba lô (2,3) | BCN-06; panel chuyển `view`, Manifest ở (2,3), chân panel `PROMPT_SAFEBOX_SEAL_HINT`; H1 `HUD_OBJECTIVE_DELIVER_PIER_A`; W1 ẩn. |
| UXA-23 | UXA-19 | Chạm Hộp (1,1) | BCN-07; Manifest trong Hộp có nhãn `đã niêm — chưa extract`; không chữ success/hoàn thành; E1. |
| UXA-24 | UXA-22 | Chạm Manifest rồi Hộp (1,0) | `commit_seal` ok, không O5; nhãn `đã niêm — chưa extract`; state flow không đổi. |
| UXA-25 | UXA-23, panel `view` | Chạm Manifest rồi ô ba lô (0,0) | Không đổi; lý do `INVENTORY_REASON_WITHDRAW_LOCKED`. |
| UXA-26 | UXA-22 | Chạm `Đóng` | R4 `PROMPT_ROUTE_EXTRACT_NOW`; không có `PROMPT_ROUTE_GO_MARKET`; W2 E1 + `BEACON_E1_OUT_OF_ZONE_REASON`. |
| UXA-27 | S3 trong vòng | Đọc HUD | H4 `Gọi thuyền`; O5 chưa mở. |
| UXA-28 | UXA-27 | Chạm H4 | O5: tiêu đề, thân có "20", `Gọi`, `Hủy`; không nút nào của O5 giao R5; H1 vẫn hiện. |
| UXA-29 | O5 vừa mở | Chạm vào vị trí `Gọi` trong 0.3 giây đầu | Bỏ qua; vẫn O5. |
| UXA-30 | O5 | Chạm `Hủy` (hoặc Back) | E1; nút `Gọi thuyền` hiện lại; inventory không đổi. |
| UXA-31 | O5 | Chạm ra ngoài panel | Vẫn O5; không hủy, không xác nhận. |
| UXA-32 | O5 | Rời vòng | O5 đóng; R4 `EXTRACT_CONFIRM_CLOSED_LEFT_ZONE`; E1. |
| UXA-33 | O5 | Chạm `Gọi` | Banner `EXTRACT_S7_CALL_ACCEPTED`; sau 1.5 giây H1 `HUD_OBJECTIVE_HOLD_PIER_A` và banner "còn 20 giây". |
| UXA-34 | S8, trong vòng, còn 19 | Rời vòng 3 giây | Banner vẫn 19, icon tạm dừng, `EXTRACT_S8_HOLD_PAUSED`; vào lại → giảm tiếp từ 19. |
| UXA-35 | S8 hồ sơ S02 | Chạy hết S8 | Không `EXTRACT_S8_LANE_ALERT`, không địch; sang S9: H1 `HUD_OBJECTIVE_BOARD_BOAT`, banner `EXTRACT_S9_BOAT_READY`, W4 hiện. |
| UXA-36 | S9 ngoài `BoardZoneA` | Chờ 60 giây | Vẫn S9; không nút `Lên thuyền`; không timeout. |
| UXA-37 | S9 trong `BoardZoneA` | Chạm `Lên thuyền` | S10 đúng một lần. |
| UXA-38 | S10 sau UXA-22 → UXA-37 (Manifest ở ba lô) | Đọc màn | Thứ tự: tiêu đề, `Đã giữ` (giấy phép, vật hồi phục, `Ô ba lô đã dùng: 1/12`), **không** có nhóm `Đã mất`, `Vật chứng` (ba dòng), `Tiếp theo` (Contract 2 + tag, không nút), câu mentor, `Về hub`; Manifest không ở `Đã giữ`; không điểm/thời gian/route. |
| UXA-39 | S10 với Manifest trong Hộp | Đọc màn | `Ô ba lô đã dùng: 0/12`; còn lại như UXA-38. |
| UXA-40 | S10 | Chạm card Contract 2 | Không gì xảy ra. |
| UXA-41 | S10 | Chạm `Về hub` hai lần nhanh | Về Boot đúng một lần; không file mới trong `user://`. |
| UXA-42 | Mọi màn S1, O1, O2, O3/O4, O5, HUD, S10 | Đo trên khung 1280×720 | Mọi vùng chạm ≥ 64×64; ô lưới 96×96; chữ ≥ 20 px; không phần tử đặt trong R6 ngoài joystick. |
| UXA-43 | Ảnh chụp xám hóa (grayscale) của O2, O3/O4, W2 E0/E1, banner S8 chạy/dừng | Xem tay | Phân biệt được rarity, claim, footprint, vật chứng, đã niêm, E0/E1, chạy/dừng mà không cần màu. |
| UXA-44 | Lần lượt O2, panel `pickup`, O5, S8 | Đưa app xuống nền 10 giây rồi trở lại | Overlay giữ nguyên; không commit/không xác nhận ngầm; S8 giảm ≤ 0.25 giây trong tick đầu khi trở lại. |
| UXA-45 | Mọi màn | Rà mọi nút | Mỗi nút có key trong `strings.csv` hoặc trong §8; không chuỗi chữ cứng. |

## 10. Truy vết tới gate

| Gate | Mục | Test |
|---|---|---|
| G1 | §5.1 | UXA-01…03 |
| G2 | §4, §5.1, §5.2 | UXA-04…13 |
| G3 (HUD/nhãn) | §5.3 | UXA-13…15 |
| G4 | §4.4, §5.4, §5.5 | UXA-16…23 |
| G5 | §5.6–§5.9 | UXA-26…41 |
| G8 (không xoay ở S02) | §4.2–4.3 | UXA-06…09, 19…25 |
| G10 (phần Manifest) | §4.4 | UXA-23…25 |
| G11 | §5.7, §6 | UXA-24, UXA-28…32 |
| G13 | §5.6, §5.7 | UXA-15, UXA-27…33 |
| G14 | §5.8 | UXA-33…37 |
| G15 | §5.9 | UXA-38…41 |
| Wireflow §9 (không chỉ màu, overlay không che HUD) | §3.2 | UXA-16, UXA-28, UXA-42, UXA-43 |

## 11. Ngoài phạm vi và câu hỏi

**Ngoài phạm vi:** mock-up, theme, font, màu; combat HUD, máu, địch, lane B; lưới loot B (G7/G8 đầy đủ, xoay, kéo-thả);
Hộp đầy đủ (G10: rút đồ, nhường chỗ); bỏ item; death/S11/S12/Recovery; menu tạm dừng; save.

**Câu hỏi mở (không chặn spec; đều `proposed` cho tới khi Producer chốt):**

- Q1 — O1 ở S02 khóa mọi chuyển khác ngăn (kể cả Hộp → ba lô trước khi vào run). Chọn vì beacon spec §7.1 cấm
  affordance "rút đồ niêm" ở S02 và để `LOADOUT_SUMMARY_DEFAULT_KIT` luôn đúng. Nếu Producer muốn cho chuyển khác ngăn
  ngay ở S02, cần quyết định O1 có dùng O5 cho việc đó không.
- Q2 — Vertical slice Beat 2 hiện cả `PROMPT_ROUTE_GO_MARKET`; S02 chưa có B nên spec ẩn câu đó tới khi B mở (S03).
- Q3 — Nút vào game hiện có của Boot đang dẫn thẳng vào khu A; S02 cần nó dẫn tới S1 (TASK-72/75 chọn cách nối).
- Q4 — Tên vật hồi phục starter chưa có trong glossary (`ITEM_STARTER_REMEDY_NAME`); vật hồi phục ở túi đeo chéo có
  cùng `def_id` hay không cũng chưa chốt (ảnh hưởng tên ở S10).
- Q5 — `contract-1-strings` §1 ghi objective HUD "một dòng trên mobile dọc"; game chơi ngang 1280×720. Giới hạn 48 ký tự
  vẫn giữ, chỉ cần sửa chữ mô tả khi TASK-71 chạm tới file đó.
- Q6 — Vị trí `BeaconZoneA`, `BoardZoneA` và tầm bàn dispatch (`DESK_INTERACT_RADIUS_M`) do level-designer chốt; spec chỉ
  yêu cầu W3/W4 nhìn thấy được từ camera cố định.
