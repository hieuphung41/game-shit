# Test plan — Lưới ba lô 3x4 và Hộp Công Chứng 2x2 (vertical slice)

**Trạng thái:** test plan `proposed`. Case id, nhóm kênh build và mọi chi tiết debug menu là `proposed` trừ khi ghi nguồn. Plan không viết code test (card của test-engineer) và không định nghĩa luật mới.

**Nguồn luật:** [Spec lưới inventory](../specs/inventory-grid-slice-spec.md) (INV-01…INV-35, §4–§7, §10) · [Build-readiness](../vertical-slice-build-readiness.md) G2, G4, G8, G10, G17 · [Phiếu quan sát playtest](../playtest-observation-sheet.md) (P4, P6, P8d). Tên glossary: `backpack`, `notary_box`, `sling_pouch`, `manifest_r17`, `AppEnv.channel`.

## 1. Cách đọc bảng

- **Case id** `TC-INV-xx` = đúng một case chính cho `INV-xx`. `TC-BND-xx` = case biên/đầu vào sai suy ra từ spec §4, §7, §10. `TC-STG-xx` = chỉ staging.
- **Tự động?** `có` = test-engineer viết test headless `test_inv_xx_*` (tên theo spec §11). `không` = chỉ làm tay. `có+tay` = có test tự động và QA vẫn chạy lại tay một lần trên build.
- **Kênh:** `P` = chạy trên production (tag); `S` = chạy trên staging (nhánh `main`). Case không có `S-only` chạy được ở cả hai kênh bằng flow thật của game. Case `S-only` cần debug menu/fixture nạp state nên **không** được chạy trên production (xem §5).
- Kết quả "state không đổi" = `snapshot()` (hoặc, khi chạy tay, ảnh chụp ba lô/Hộp/túi trước-sau giống hệt) và không có signal/animation đặt-bỏ.
- Với test tay, "Hộp fixture loadout" = Hộp có `starter_remedy` tại (0,0) đứng, ba lô rỗng (spec §8.4).

## 2. Ma trận bao phủ nhanh

| Nhóm | Case | Ghi chú |
|---|---|---|
| Thành công | TC-INV-01, 04, 08, 10, 12, 15, 21, 24, 26, 28, 29, 35 | Nhặt, xoay, di chuyển, swap, stack, niêm, rút, bỏ, sort, extract |
| Đầu vào sai / bị từ chối | TC-INV-02, 03, 06, 11, 13, 14, 17, 19, 23, 25, 33, 34 · TC-BND-01…04 | Có `reason` + nhãn UI |
| Biên | TC-INV-05, 16, 18, 20, 22, 30 · TC-BND-05…09 | Lưới đầy, Hộp đầy, xoay ở mép, sai loại vào Hộp |
| Hủy thao tác | TC-INV-09 · TC-BND-10…12 | Preview thuần, hủy O5, state đổi sau preview |
| Chết / hồi phục | TC-INV-27, 28 · TC-BND-13, 14 | `kept` / `lost` / `unrecovered_evidence` |
| Save / load | TC-INV-32 · TC-BND-15…17 · TC-STG-03 | `load_snapshot`, `validate()`, khóa `Vào cảng` |

## 3. Case theo INV (thủ công + tự động)

| Case id | INV | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-INV-01 | INV-01 | Ba lô rỗng; `fixture_b_small_1x1` trên ground | Nhặt item, chọn ô (0,0), xác nhận | `ok`; item ở ba lô (0,0); ground hết item; có `item_placed` | có+tay | P, S |
| TC-INV-02 | INV-02 | Ba lô rỗng; `fixture_b_small_1x2` trên ground | Nhặt, đặt anchor (0,3) đứng | `OUT_OF_BOUNDS`, nhãn `không vừa`; item còn trên ground; ba lô không đổi | có+tay | P, S |
| TC-INV-03 | INV-03 | Ba lô có `cargo_d_2x2` tại (0,0) | Nhặt `fixture_b_small_1x1` đặt tại (1,1) | `CELLS_OCCUPIED`; `blocking_cells` chứa (1,1); UI tô ô (1,1); state không đổi | có+tay | P, S |
| TC-INV-04 | INV-04 | `fixture_b_small_1x2` đứng tại (0,0) | Xoay | `ok`; `rotated = true`; chiếm (0,0),(1,0) | có | P, S |
| TC-INV-05 | INV-05 | `fixture_b_small_1x2` đứng tại (2,0) | Xoay | `OUT_OF_BOUNDS`; vẫn đứng tại (2,0); item khác không dịch | có+tay | P, S |
| TC-INV-06 | INV-06 | `test_fixed_1x2` trong ba lô | Xoay | `NOT_ROTATABLE`, nhãn `không xoay`; state không đổi | có | S-only (fixture chỉ dùng test) |
| TC-INV-07 | INV-07 | `manifest_r17` trong ba lô | Xoay | `ok`; `rotated` vẫn `false`; không signal | có+tay | P, S |
| TC-INV-08 | INV-08 | `fixture_b_small_1x2` đứng tại (0,0) | Kéo sang anchor (0,1) | `ok`; chiếm (0,1),(0,2) dù chồng ô cũ | có | P, S |
| TC-INV-09 | INV-09 | Ba lô có 2 item | Mở preview của move, rotate, seal, withdraw, drop, sort rồi đóng/hủy từng cái | Sau mỗi preview state không đổi, không signal | có+tay | P, S |
| TC-INV-10 | INV-10 | A=`fixture_b_small_1x2` (0,0), B=`tax_stamp_d` (1,0), đều đứng | Swap A↔B | `ok`; A tại (1,0), B tại (0,0); không item thứ ba bị đụng | có | P, S |
| TC-INV-11 | INV-11 | A trong ba lô, B trong Hộp | Swap A↔B | `SWAP_NOT_ALLOWED`, nhãn `đổi từng món`; state không đổi | có+tay | P, S |
| TC-INV-12 | INV-12 | 2 stack `fixture_b_small_1x1` qty 2 và qty 1 | Stack nguồn vào đích | `ok`; 1 stack qty 3; ô nguồn trống | có | S-only (stack fixture) |
| TC-INV-13 | INV-13 | 2 stack `fixture_b_small_1x1` qty 2 + qty 2 | Stack | `STACK_FULL`, nhãn `chồng đã đầy`; cả hai giữ qty 2 | có | S-only |
| TC-INV-14 | INV-14 | `fixture_b_small_1x1` + `test_stack_other_claim_1x1` | Stack | `STACK_INCOMPATIBLE`; state không đổi | có | S-only |
| TC-INV-15 | INV-15 | Hộp fixture loadout; `manifest_r17` trong ba lô | Niêm Manifest vào (1,0) | `ok`; Manifest trong Hộp; nhãn `đã niêm — chưa extract`; không completion/Archive | có+tay | P, S |
| TC-INV-16 | INV-16 | Hộp: `starter_remedy` (0,0) + `manifest_r17` (1,0); `tax_stamp_d` trong ba lô | Thử niêm `tax_stamp_d` ở cả 4 anchor × đứng/xoay (8 lần) | Không lần nào `ok`; trong biên → `CELLS_OCCUPIED`, ra biên → `OUT_OF_BOUNDS`; `tax_stamp_d` vẫn ở ba lô; 2 item trong Hộp không rời | có (8 vòng) + tay 2 lần mẫu | P, S |
| TC-INV-17 | INV-17 | Hộp rỗng; `cargo_d_2x2` trong ba lô | Niêm cargo (0,0) | `NOT_SEALABLE`, nhãn `không niêm phong được`; cargo vẫn ba lô | có+tay | P, S |
| TC-INV-18 | INV-18 | Hộp đầy 4 ô; `cargo_d_2x2` trong ba lô | Niêm cargo (0,0) | Lý do `NOT_SEALABLE`, **không** `CELLS_OCCUPIED` (thứ tự §7) | có | S-only (cần Hộp đầy tự dựng) |
| TC-INV-19 | INV-19 | Hộp rỗng; `test_spare_weapon_1x2` trong ba lô | Niêm weapon | `NOT_SEALABLE`; weapon vẫn ba lô | có | S-only |
| TC-INV-20 | INV-20 | Hộp có `starter_remedy`; ba lô đầy 12 ô | Rút remedy về (0,0), xác nhận O5 | `CELLS_OCCUPIED`; remedy còn trong Hộp, nhãn `đã niêm` | có+tay | P, S |
| TC-INV-21 | INV-21 | Hộp chỉ có `starter_remedy`; ba lô có `tax_stamp_d` đứng (2,0) | Rút remedy về (0,0) (O5 xác nhận) → niêm `tax_stamp_d` vào (0,0) | Rút `ok`, Hộp trống 4 ô; niêm `ok` | có+tay | P, S |
| TC-INV-22 | INV-22 | Ba lô đầy; `fixture_b_small_1x1` trên ground | Thử nhặt vào mọi anchor | Mọi lần fail; Hộp và túi không đổi; không auto-drop/swap; item còn ground | có+tay (mẫu 3 ô) | P, S |
| TC-INV-23 | INV-23 | Item bất kỳ trên ground | Thử nhặt vào `sling_pouch` | `WRONG_TARGET`, nhãn `sai loại`; item còn ground | có | S-only (UI production không có đích này; kiểm API) |
| TC-INV-24 | INV-24 | `fixture_b_small_1x2` trong ba lô | Bỏ, O5 xác nhận | `ok`; item ở ground quantity nguyên; ô ba lô trống; có `item_removed` | có+tay | P, S |
| TC-INV-25 | INV-25 | `starter_remedy` trong Hộp | Thử bỏ trực tiếp | `WRONG_SOURCE`, nhãn `rút ra trước`; remedy vẫn trong Hộp | có+tay | P, S |
| TC-INV-26 | INV-26 | `manifest_r17` trên ground, chưa từng mang | Nhặt vào (0,0), rồi niêm vào (1,0) | Đúng 1 `evidence_carried_changed(manifest_r17, true)` sau nhặt; niêm không phát lại; nhặt fail không phát | có | P, S (tay: quan sát beacon A E0→E1) |
| TC-INV-27 | INV-27 | Hộp: `starter_remedy` + `manifest_r17`; ba lô `cargo_d_2x2`; túi 1 vật hồi phục | Chết | `kept=[starter_remedy]`; `lost` có cargo + vật hồi phục túi; `unrecovered_evidence=[manifest_r17]`; ba lưới rỗng; S11 hiện đúng 3 nhóm | có+tay | P, S |
| TC-INV-28 | INV-28 | Như INV-27 | Extract thành công | `to_hub` có remedy, cargo, vật hồi phục; `to_archive=[manifest_r17]`; Manifest không vào hub; S10 khớp | có+tay | P, S |
| TC-INV-29 | INV-29 | Ba lô: 1x1 (0,0); 1x2 đứng (2,0); `cargo_d_2x2` (1,2) | Bấm Tự xếp → xem preview → xác nhận | `ok`; cargo (0,0), 1x2 (2,0), 1x1 (0,2); layout commit = preview; cùng `uid` và tổng quantity; Hộp/túi không đổi | có+tay | P, S |
| TC-INV-30 | INV-30 | Ba lô đầy 12 ô theo layout §11 INV-30 | Tự xếp | `SORT_NO_FIT`, nhãn `không sắp được`; layout cũ giữ nguyên | có | S-only (layout dựng sẵn) |
| TC-INV-31 | INV-31 | Từng given của INV-02, 03, 05, 06, 11, 13, 14, 16–20, 22, 23, 25, 30, 33, 34 | Chạy lệnh fail, đếm signal, so `snapshot()` | 3 signal đều 0 lần; ba lô, Hộp, túi, ground không đổi | có (1 test lặp theo bảng) | P, S (tay: quan sát không có đổi chỗ ngầm) |
| TC-INV-32 | INV-32 | Save có 2 item chồng ô ba lô, hoặc `cargo_d_2x2` trong Hộp | Gọi `validate()` / mở màn chuẩn bị | Ít nhất 1 lỗi chỉ đúng `uid`; không item nào bị xóa/dời; `Vào cảng` bị khóa | có + tay | S-only (cần nạp save hỏng) |
| TC-INV-33 | INV-33 | Hộp rỗng; `cargo_d_2x2` trên ground | Nhặt thẳng vào ô Hộp | `NOT_SEALABLE`; cargo vẫn ground; không tự sang ba lô | có+tay | P, S |
| TC-INV-34 | INV-34 | Ba lô có stack 1x1 qty 1 tại (0,0); 1 item 1x1 qty 1 trên ground | Nhặt vào (0,0); sau đó dùng lệnh stack | Nhặt: `CELLS_OCCUPIED`, không tự gộp; stack: `ok`, qty 2 | có | P, S |
| TC-INV-35 | INV-35 | `manifest_r17` trong ba lô (đã phát `true` 1 lần) | Bỏ (O5 xác nhận) rồi nhặt lại | Signal đúng thứ tự `false` rồi `true`, mỗi cái 1 lần | có | P, S |

## 4. Case biên và đầu vào sai ngoài INV (suy từ spec)

| Case id | Nguồn spec | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|---|
| TC-BND-01 | §7 #1 | Ba lô rỗng | Gọi lệnh move/rotate/drop với `uid` không tồn tại | `ITEM_NOT_FOUND`, nhãn `không tìm thấy món`; state không đổi; không crash | có | S-only (gọi API) |
| TC-BND-02 | §4.2.1, §7 #7 | `fixture_b_small_1x1` trong ba lô | Move tới anchor âm (-1,0) và (3,0), (0,4) | `OUT_OF_BOUNDS` cả ba; item giữ chỗ | có | S-only |
| TC-BND-03 | §3.9 | `fixture_b_small_1x1` + 1 item khác trong ba lô | Thử đặt item vào "bên trong" item khác (không có đường UI) | Không có thao tác nào làm lồng container; state không đổi | không (kiểm tay trên UI: kéo thả lên card item) | P, S |
| TC-BND-04 | §4.2.8 | Stack 1x1 trong ba lô và stack `test_stack_other_claim_1x1` | Gộp một phần khi tổng > `stack_max` | Gộp toàn phần hoặc fail; không bao giờ gộp một phần | có | S-only |
| TC-BND-05 | §10.1 | Item 1x2 đứng tại (0,0) | Move tới (0,1) chồng một phần ô cũ | `ok` (đã phủ bởi TC-INV-08); thêm kiểm 2x2 `cargo_d_2x2` dịch 1 ô | có | P, S |
| TC-BND-06 | §10.4 | Hộp: `starter_remedy` + `manifest_r17`, trống (1,1) | Niêm một item 1x1 sealable vào (1,1) | `ok` (1x1 vừa); `tax_stamp_d` 1x2 vẫn fail như INV-16 | có | S-only (cần item 1x1 sealable trong ba lô) |
| TC-BND-07 | §4.2.6 | `fixture_b_small_1x2` đứng tại (0,3) hàng cuối | Xoay (2x1 vẫn trong biên) rồi xoay về | Xoay `ok` ở hàng cuối, cột 0–1; không `OUT_OF_BOUNDS` sai | có | P, S |
| TC-BND-08 | §4.2.4 | Ba lô đầy 12 ô | `suggest_slot` cho mọi def slice | Trả `null`; UI không highlight; không tự đặt | có | S-only |
| TC-BND-09 | §10.6 | Ba lô đầy; Hộp còn chỗ | Nhặt item sealable | Fail; không tự sang Hộp/túi; item còn ground (khác TC-INV-22 ở Hộp có chỗ) | có+tay | P, S |
| TC-BND-10 | §4.1.1, §6.2 | Đang preview move | Đóng O3/O4 giữa chừng | State không đổi; không signal; mở lại preview mới bình thường | có+tay | P, S |
| TC-BND-11 | §5.5, §6.2 | Hộp có `starter_remedy` | Mở O5 rút → bấm `hủy` | Không gọi commit; remedy vẫn `đã niêm`; không signal | có (UI hook) + tay | P, S |
| TC-BND-12 | §10.10 | Preview đặt vào ô X; sau đó đặt item khác vào X | Commit theo preview cũ | Fail với lý do hiện tại (`CELLS_OCCUPIED`); không áp preview cũ | có | S-only |
| TC-BND-13 | §10.12 | Hộp chỉ chứa `manifest_r17` | Chết | `kept` rỗng; `unrecovered_evidence=[manifest_r17]`; S11 không hiện Manifest ở nhóm `Đã giữ` | có+tay | P, S |
| TC-BND-14 | §5.9.3, §6.3 | Manifest ở ba lô (không niêm) | Chết | Manifest vào `unrecovered_evidence`, không vào `lost`; recovery contract nhận đúng 1 Manifest | có+tay | P, S |
| TC-BND-15 | §8.4 | Save mới | Mở màn chuẩn bị | Ba lô 3x4 rỗng; Hộp có `starter_remedy` (0,0); túi 1 vật hồi phục; `Vào cảng` mở | có+tay | P, S |
| TC-BND-16 | §9 `snapshot`/`load_snapshot` | Layout ba lô + Hộp bất kỳ hợp lệ | `snapshot()` → thoát → vào lại / `load_snapshot` | Layout, `rotated`, `uid`, quantity giống hệt; không signal khi load | có+tay | P, S |
| TC-BND-17 | §10.11 | Save hỏng có gear trong Hộp | Nạp save; thử `Vào cảng` | `validate()` lỗi; `Vào cảng` khóa; engine không tự sửa/xóa gear | có | S-only |

## 5. Case chỉ staging (staging-only) tách khỏi production

Debug menu và env badge **không** thuộc spec; mọi mục dưới đây là `proposed` và chỉ hợp lệ nếu build staging thực sự có chúng (test-engineer/ui-programmer xác nhận trước). Nếu debug menu chưa có, ghi `KHÔNG TEST ĐƯỢC` theo [phiếu quan sát](../playtest-observation-sheet.md) §1 và các case `S-only` ở §3–§4 chuyển thành test headless (không chạy tay).

| Case id | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|
| TC-STG-01 | Build staging | Mở game, nhìn màn chính và màn inventory | Badge `AppEnv.channel = staging` hiện rõ; không che ô lưới | không | S-only |
| TC-STG-02 | Build production | Như TC-STG-01 | **Không** có badge staging, không có debug menu | không | P-only |
| TC-STG-03 | Staging + debug menu | Nạp save hỏng (TC-INV-32/BND-17) bằng debug | Lỗi `validate()` hiện; `Vào cảng` khóa; tắt debug xong state vẫn nguyên | không | S-only |
| TC-STG-04 | Staging + debug menu | Spawn các fixture §8.3 (kể cả `test_*`) vào ba lô/ground | Item spawn đúng footprint; mọi case `S-only` chạy được | không | S-only |
| TC-STG-05 | Build production | Tìm cách spawn `test_*` hoặc nạp save hỏng qua UI thường | Không có đường nào; `test_*` không xuất hiện trong ba lô thật | không | P-only |

## 6. Phần đưa cho test-engineer (follow-up)

Các case `Tự động? = có` là danh sách việc cho card test-engineer; mỗi INV đã có tên `test_inv_xx_*` trong spec §11. Phần cần thêm ngoài tên spec: `test_bnd_01…17` cho TC-BND có `có`, và một test lặp bảng cho TC-INV-31. Tất cả phải ở dạng failing-then-passing theo charter QA.

## 7. Chạy tay và playtest

- Chạy tay theo thứ tự: nhặt/đặt (01–03) → xoay/di chuyển/swap (04–11) → stack (12–14, S-only) → Hộp (15–21, 33) → fail không đổi state (22–25, 31) → evidence/chết/extract (26–28, BND-13/14) → sort (29–30) → save/load (32, BND-15…17).
- Playtest first-time dùng nguyên [phiếu quan sát](../playtest-observation-sheet.md): claim **P4** (loot-grid là quyết định), **P6** (Hộp/evidence/death/recovery), **P8d**. Không thêm metric mới; case plan này không thay C0/C1–C3.
- Case tay dùng để kiểm outcome thật; không dùng lời mô tả thay state (quy tắc `KHÔNG TEST ĐƯỢC`).

## 8. Mẫu bug report

```text
Build channel: staging / production   Version: <tên pre-release staging hoặc tag production>
Case id: TC-INV-xx / TC-BND-xx / TC-STG-xx
Tiền điều kiện (state, fixture, cách nạp):
Bước tái hiện:
Kết quả mong đợi (trích spec §/INV):
Kết quả thực tế (kèm ảnh/snapshot nếu có):
Severity: BLOCKER / MUST_FIX / MINOR
Tái hiện: n/m lần cùng build
```

Severity gợi ý: **BLOCKER** = mất đồ vĩnh viễn trái §6.3, auto-drop/swap/sort/seal (invariant 8.5), Hộp nhận item không niêm được, Manifest vào `kept`, hoặc `Vào cảng` mở khi `validate()` lỗi (nhánh build/readiness theo [build-readiness](../vertical-slice-build-readiness.md) §9). **MUST_FIX** = sai `reason`/nhãn, signal sai số lần. **MINOR** = lỗi trình bày không đổi state.

## 9. Truy vết spec → case

| Gate / invariant | INV | Case |
|---|---|---|
| G2 | INV-32 | TC-INV-32, TC-BND-17, TC-STG-03 |
| G4 | INV-01, 15, 26, 35 | TC-INV-01, 15, 26, 35 |
| G8 | INV-02…14, 22, 31, 34 | TC-INV-02…14, 22, 31, 34 · TC-BND-01…12 |
| G10 | INV-15…21, 33 | TC-INV-15…21, 33 · TC-BND-06, 09 |
| G17 / 8.6 | INV-27, 28 | TC-INV-27, 28 · TC-BND-13, 14 |
| Invariant 8.5 | INV-22, 31 | TC-INV-22, 31 |

Câu hỏi mở (không chặn plan): phản ứng của contract/beacon A khi người chơi bỏ `manifest_r17` xuống đất — TC-INV-35 chỉ kiểm signal, chờ spec contract/extract để thêm case hiệu ứng.
