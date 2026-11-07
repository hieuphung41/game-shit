# Test plan — Kho Nổi (D), Hộp Công Chứng, bỏ/rút đồ có xác nhận, chết qua Phù Hiệu Hồi Hương (S04): G9, G10, G11, G12, G15, G16, G17

**Trạng thái:** test plan `proposed`. Mã case `TC-ZD-xx` và mọi chi tiết kênh build là `proposed` trừ khi ghi nguồn.
Plan không viết code test (card của test-engineer), không chạy phiên playtest, không đổi luật hay số liệu và không
định nghĩa metric mới. Đây là checklist DoD của sprint S04: một gate chỉ `READY` khi mọi case của nó đạt trên bản
web-staging.

**Nguồn luật:** [Build-readiness](../vertical-slice-build-readiness.md) §6 (G9, G10, G11, G12, G15, G16, G17), §7 (C0–C3), §9 ·
[Spec luật S04](../specs/zone-d-cargo-notary-death-spec.md) (`ZD-01…39`, §3–§9) ·
[Spec layout/encounter D](../specs/zone-d-layout-encounter-spec.md) (§2, §5, §9) ·
[Spec UX S04](../specs/zone-d-ux-spec.md) (`ZDU-01…45`) · [Chuỗi in-game](../specs/contract-1-strings.md) (mục S04) ·
[Test plan khu B](zone-b-combat-loot-test-plan.md) (định dạng, TC-ZB-xx) · [Test plan vòng A](loop-a-early-extract-test-plan.md)
(TC-LA-xx, mẫu bug) · [Test plan inventory](inventory-grid-test-plan.md) · [Phiếu quan sát](../playtest-observation-sheet.md).
Tên theo glossary: `retriever`, `backpack`, `notary_box`, `sling_pouch`, `manifest_r17`, `cargo_d_2x2` (Vải Cứu Trợ Đổi
Nhãn), `tax_stamp_d` (Dấu Thuế), `starter_remedy` (Cuộn Băng Muối), `sling_remedy` (Gói Băng Muối), `recall_sigil`,
`extract_pier_a`, `AppEnv.channel`. `cargo_d_2x2`, `tax_stamp_d`, `ground_drop` và `DeathSummary` là tên `proposed` trong spec
S04 (chưa vào glossary); plan chỉ dùng tên người chơi thấy trên màn hình.

## 1. Cách đọc bảng

- **Case id** `TC-ZD-xx` = case đạt (`ĐẠT`) hoặc case cấm (`CẤM`, lấy từ cột `BLOCKER` của readiness §6). `TC-ZD-Bxx` =
  biên (gồm hủy, Hộp/ba lô đầy, hết máu giữa action). `TC-ZD-Gxx` = ảnh thang xám / màn nhỏ. `TC-ZD-Zx` = kịch bản
  đầu-cuối chơi tự nhiên. `TC-ZD-Sxx` = chỉ staging / chỉ production.
- **Spec** = id `ZD-xx` (luật) và `ZDU-xx` (UX) mà case kiểm; không có id thì ghi mục.
- **Tự động?** `có+tay` = spec S04 có test headless tương ứng nhưng QA vẫn chạy lại tay trên build; `chỉ tay` = chưa có
  test tự động. Ở thời điểm viết, `game/tests/` **chưa có** test đặt tên theo `test_zd_xx_*` (tìm `zd_`/`ZD-` không ra);
  các test liên quan hiện có nằm ở §11 và chỉ là ứng viên, chưa đối chiếu từng assert. Vì vậy mọi case ở đây ghi
  `có+tay` hoặc `chỉ tay`, **không** ghi `có` (case chỉ được ghi `có` khi tên test thật chứng minh đúng ý case — việc của
  test-engineer, §12).
- **Kênh:** mọi case chạy tay trên bản **web-staging** `https://hieuphung1qaz.itch.io/25d-game`
  (`AppEnv.channel = staging`, build từ nhánh `main`). Cột `P` = case cũng chạy được trên production (tag) bằng flow thật;
  `S-only` = cần debug menu/fixture, không chạy trên production (§10). **M** = chuột (trình duyệt desktop),
  **T** = cảm ứng (điện thoại, ngang).
- Mọi số (cargo 2×2 giá trị 8 / 2 mỗi ô, Dấu Thuế 1×2 giá trị 6 / 3 mỗi ô, `RECALL_SIGIL_SECONDS` 2.5 s, khóa nút O5i
  0.3 s, khóa nút S11 1.0 s, vùng chạm ≥ 96 px, chữ ≥ 24 px, vòng tương tác 1.5 m, cue patrol 2.0 s, hold, HP, đòn) là
  `proposed` trong spec; plan chỉ trích để quan sát, **không** đánh giá cân bằng hay "lựa chọn nào đúng". Sai số đồng hồ
  tay ≤ ±1 giây (đo 0.3 s bằng tay không đáng tin: chỉ kiểm "chạm ngay lập tức không có tác dụng", xem B-case liên quan).
- "Không đổi" = ảnh chụp ba lô / Hộp / túi đeo chéo + vật dưới đất + nguồn D (còn món hay không) + HP + số thuốc +
  H1 objective trước–sau giống hệt, state flow giống hệt, không toast hay hiệu ứng mới (định nghĩa như TC-LA/TC-ZB).
- **So sánh trước/sau** (bắt buộc cho case cấm auto-anything): chụp màn hình dock ngay **trước** thao tác và ngay **sau**;
  ghi lại vị trí từng món trong ba lô (cột,hàng), Hộp (cột,hàng) và vật dưới đất.
- Mỗi lần chạy ghi **build channel + version** (tên pre-release staging, hiện ở badge/nhãn build của Boot) vào đầu phiếu.
- Cue quan trọng phải đọc được **không dựa vào màu** (hai món D cùng lớp Trắng, màu không phân biệt được chúng; phải
  phân biệt bằng footprint, số giá trị, nhãn chữ). **Ngoại lệ audio S04:** khoảnh khắc Phù Hiệu im lặng theo quyết định
  Producer (TASK-97); thiếu âm thanh **không** phải lỗi.
- **Không dùng menu debug** để đạt G16/G17 (readiness §7, spec §9). Debug menu nếu có chỉ ở cột `S-only` và không thay Z4/Z5.
- Điều khiển (đã dùng ở S03): C1 đánh, C2 né, C3 giữ khiên, C4 thuốc, R5' nút ngữ cảnh, joystick trái. Ở D: R5' mời nhặt
  khi trong 1.5 m `CargoD`, `TaxStampD` hoặc vật dưới đất.

### 1.1 Loại chỗ đứng chung ("fixture dựng bằng chơi")

Mọi fixture đều dựng bằng cách chơi tự nhiên từ Boot → S1 → `Vào cảng` với kit mặc định: Hộp có Cuộn Băng Muối
(0,0) đứng (chiếm (0,0),(0,1)); túi đeo chéo có Gói Băng Muối; ba lô 3×4 (12 ô) rỗng. Ký hiệu vị trí `(cột,hàng)`, hàng 0
ở trên. **Hộp fixture H1** = Cuộn Băng Muối (0,0) + Manifest (1,0); ô trống duy nhất (1,1) (spec §4.3).

| Fixture | Cách dựng (không menu debug) | Dùng ở |
|---|---|---|
| **F-A** (có Manifest, tới D) | Ở bàn dispatch A: `Nhặt và xếp` Manifest **thẳng vào Hộp** (1,0) → Hộp = H1, flow `CARRYING`/E1. Đi A → B (qua chặn ngõ, GateB mở, tới vùng yên `CalmZoneB`) → lối D mở → tới D. | TC-ZD-01…16, B-case D, Z1…Z3, Z5 |
| **F-B** (Manifest ở ba lô) | Như F-A nhưng `Nhặt và xếp` Manifest vào **ba lô** (0,0). | TC-ZD-13, B-case Bỏ Manifest, S8/S9 |
| **F-G16** | Spec §9.1 (xem Z4). | Z4 |
| **F-G17** | Spec §9.2 (xem Z5). | Z5 |

## 2. Ma trận bao phủ nhanh

| Gate | Case đạt | Case cấm | Case biên / hủy / chết / hồi phục | Ảnh nhỏ / xám |
|---|---|---|---|---|
| G9 — D cargo choice | TC-ZD-01, 02, 03, 04 | TC-ZD-05, 06 | TC-ZD-B01…B05 | TC-ZD-G01, G02 |
| G10 — Hộp 2×2 | TC-ZD-07, 08, 09 | TC-ZD-10, 11 | TC-ZD-B06…B09 | TC-ZD-G03 |
| G11 — O5 (bỏ đồ, rút đồ niêm; đổi gear **không áp dụng**) | TC-ZD-12, 13, 14, 15 | TC-ZD-16, 17, 18 | TC-ZD-B10…B20 | TC-ZD-G04 |
| G12 — D → B → A | TC-ZD-19, 20, 21 | TC-ZD-22, 23 | TC-ZD-B21…B24 | TC-ZD-G05 |
| G15 — S10 full-route | TC-ZD-24, 25 | TC-ZD-26 | TC-ZD-B25…B28 | TC-ZD-G06 |
| G16 — S11 trước Manifest | TC-ZD-27, 28 | TC-ZD-29 | TC-ZD-B29…B32 | TC-ZD-G07 |
| G17 — S11 sau Manifest | TC-ZD-30, 31, 32 | TC-ZD-33, 34 | TC-ZD-B33…B39 | TC-ZD-G08 |
| DoD | TC-ZD-Z1…Z7 (đầu-cuối), TC-ZD-R1…R2 (hồi quy) | — | — | — |
| Nền | TC-ZD-35 (cỡ chạm/chữ), TC-ZD-36 (chữ/key) | — | TC-ZD-S01…S03 | — |

Nhóm theo loại:
- **Thành công** = 01…04, 07…09, 12…15, 19…21, 24, 25, 27, 28, 30…32.
- **Đầu vào sai / cấm** = 05, 06, 10, 11, 16…18, 22, 23, 26, 29, 33, 34.
- **Biên** = B01…B39.
- **Hủy** = B10 (hủy bỏ), B11 (hủy rút), B13 (D1 đóng cả dock), B02 (Bỏ qua cả hai món D).
- **Chết / hồi phục** = B14 (chết khi O5 mở), B29 (chết trước Manifest ngay lúc preview nhặt), B33 (chết khi Manifest ở ba lô),
  B34 (chết khi Manifest `DROPPED`), B35…B37 (chết trong hold/board S7/S8/S9), B38 (không chết hai lần / S11 một lần),
  B39 (thử lại sau S11), TC-ZD-Z4…Z7.
- **Save/load** = **không có lưu tiến trình ở slice**: mọi case chết kiểm "không file mới, không đồ mang sang run sau",
  `Chuẩn bị lại`/Boot bắt đầu như BCN-01 (cache B và nguồn D đầy lại). Không có case "tải lại save"; đó là việc của S05 trở đi.
- **Ba outcome D → B → A** = Z1 (mang cargo), Z2 (ưu tiên Dấu Thuế), Z3 (bỏ cả hai); cả ba về tới S10.
- **Ba outcome chết** = B33 (Manifest ba lô), TC-ZD-30 (Manifest Hộp), B34 (Manifest dưới đất).

## 3. G9 — D: cargo 2×2 và Dấu Thuế 1×2, card có giá trị tổng / theo ô

Tiền điều kiện chung: F-A (đã ở D, Manifest trong Hộp H1) trừ khi ghi khác. Ở D không có địch. `CargoD` và `TaxStampD` là
hai nguồn, mỗi nguồn một món.

| Case id | Loại | Spec | Tiền điều kiện | Bước (cảm ứng) | Kết quả mong đợi quan sát được | Lỗi nếu sai | Tự động? | Kênh |
|---|---|---|---|---|---|---|---|---|
| TC-ZD-01 | ĐẠT (card cargo) | ZD-03, 04; ZDU-01, 02 | Đứng ngoài 1.5 m `CargoD`; ba lô rỗng | Đi lại gần tới trong 1.5 m, chờ 3 giây; chạm R5'; đọc card | Ngoài 1.5 m: R5' ẩn. Trong 1.5 m: R5' có icon kiện vuông + `WORLD_INTERACT_CARGO_D`, **không tự mở**. Chạm R5': dock phải có 1 chip `2×2`; thứ tự dòng NAME `Vải Cứu Trợ Đổi Nhãn` → FOOTPRINT `2×2` → USE (có số **tổng 8** và **theo ô 2**, mỗi số kèm nhãn chữ) → CLAIM (icon phe + chữ Nhà Hắc Thuế) → RARITY (1 dấu đặc, Trắng) → LORE (đúng một dòng). Hộp ở dòng 2b = icon ổ khóa gạch chéo + `CARD_FIT_NOTARY_BOX_NOT_SEALABLE`. R1, H2, H5 vẫn thấy. Không giá bán/tiền/điểm. Mở card không đổi state | BLOCKER nếu thiếu tổng hoặc theo ô (G9) hoặc có giá bán/tiền; MUST_FIX nếu sai thứ tự dòng | có+tay | M, T |
| TC-ZD-02 | ĐẠT (card Dấu Thuế) | ZD-03; ZDU-03 | Trong 1.5 m `TaxStampD` | Chạm R5'; đọc card | Chip `1×2`; tag `CARD_TAG_ROTATABLE` (xoay được) và `CARD_TAG_SEALABLE` (niêm được); dòng giá trị **tổng 6 / theo ô 3**; claim cùng phe Hắc Thuế; RARITY cũng 1 dấu đặc (giống cargo); LORE đúng một dòng. Hộp ở dòng 2b: `no_fit` (icon × + chữ) nếu Hộp là H1 (đầy). Không đổi state | MUST_FIX | có+tay | M, T |
| TC-ZD-03 | ĐẠT (cue ngoài màu, so hai card) | ZDU-04 | Đã đọc card cargo và card Dấu Thuế | Xem lần lượt hai card; **không dùng màu** để phân biệt (bật chế độ thang xám của thiết bị hoặc ảnh chụp thang xám) | Phân biệt được hai món bằng footprint (sơ đồ + chữ `2×2`/`1×2`), giá trị (số + nhãn tổng/theo ô), claim (icon + chữ). Rarity **giống nhau** ở cả hai (không dùng rarity để chọn). Không có vạch, sao hay thanh so sánh "nên chọn" | MUST_FIX nếu cue chỉ bằng màu; BLOCKER nếu có gợi ý chọn | chỉ tay | M, T |
| TC-ZD-04 | ĐẠT (nhặt cargo vào ba lô) | ZD-05, 08; ZDU-06, 08 | Card cargo mở, ba lô rỗng | `Nhặt và xếp`; quan sát lưới; đè ngón ở ba lô (0,0) rồi nhấc | Lưới `pickup`: mọi ô Hộp có ổ khóa gạch chéo; nhãn Hộp `CARD_FIT_NOTARY_BOX_NOT_SEALABLE`; **không** nút `Xoay` (vuông), **không** nút `Bỏ`. Đè (0,0): bóng khung phủ (0,0),(1,0),(0,1),(1,1). Nhấc: cargo vào ba lô (0,0) chiếm 4 ô; dock đóng; toast `CARD_PLACED_CONFIRM_BACKPACK`; khối `CargoD` trong thế giới biến mất và không chặn đường. R1 H1 vẫn `HUD_OBJECTIVE_DELIVER_PIER_A`; flow vẫn `CARRYING`/E1 | MUST_FIX; BLOCKER nếu cargo mất mà không vào ba lô | có+tay | M, T |
| TC-ZD-05 | CẤM (cargo vào Hộp) | ZD-06; ZDU-06, 07 | Card cargo mở; thử cả khi Hộp rỗng (chạy trên run khác: rút hết) và Hộp H1 | `Nhặt và xếp`; đè rồi nhấc ngón ở từng ô Hộp (0,0), (1,0), (1,1) | **Luôn** từ chối với lý do `INVENTORY_REASON_NOT_SEALABLE` (không niêm phong được), kể cả Hộp trống; **không** hiện `thiếu ô` (`CELLS_OCCUPIED`) cho cargo; cargo vẫn ở nguồn D; ba lô/Hộp không đổi | BLOCKER (readiness G10: cargo/gear/container niêm được) | có+tay | M, T |
| TC-ZD-06 | CẤM (không ép chọn, không phạt) | ZD-08; D brief | Hai lần chạy: ba lô rỗng và ba lô có cargo | Chạy thẳng 10 m, né một lần, giơ khiên; so cảm giác/thời gian giữa hai lần; đọc card và toast | Tốc độ chạy, thời gian né, giữ khiên giống hệt (so đồng hồ tay ≤ ±1 s trên cùng đoạn). Không chữ "nặng/chậm", không toast trách, không nút "tối ưu", không thứ nào bắt buộc nhặt; đi qua D → B không cần nhặt gì | BLOCKER (readiness G9: action ép chọn "tối ưu"; weight rule ngoài slice) | có+tay | M, T |
| TC-ZD-B01 | Biên: ba lô không còn khối 2×2 | ZD-07; ZDU-09 | Ba lô đã có món ở chỗ cản (vd. đồng xu (0,3), sổ (2,2) hoặc Manifest (1,1)); card cargo | `Nhặt và xếp`; chạm từng anchor (0,0)…; đọc lý do | Mọi anchor không vừa gạch chéo; lý do `thiếu ô`/`không vừa`; viền ở ô cản; R4' `INVENTORY_HINT_BACKPACK_MAKE_ROOM`; **không** nút đổi chỗ / bỏ giúp / gợi ý chỗ; không món nào tự di chuyển. Sau khi người chơi tự **di chuyển** món cản (không O5) thì nhặt lại vào được | BLOCKER nếu auto-swap/drop; MUST_FIX nếu thiếu lý do | có+tay | M, T |
| TC-ZD-B02 | Hủy: `Bỏ qua`/`Đóng` cả hai món D | ZD-09; ZDU-10 | F-A ở D | Mở card cargo → `Bỏ qua`; card Dấu Thuế → `Đóng`; đi D → B → A | Không đổi gì ở ba lô/Hộp/nguồn (cả hai nguồn còn món, khối còn hiện); H1 `HUD_OBJECTIVE_DELIVER_PIER_A` suốt đường; không toast trách; lối D → B mở; tới A gọi thuyền được như BCN-10. (Đây là **outcome "bỏ cả hai"**; tiếp tục tới S10 ở Z3.) | MUST_FIX; BLOCKER nếu mất lối về hoặc khóa beacon | có+tay | M, T |
| TC-ZD-B03 | Biên: lấy cả hai | §10.11 | F-A, ba lô đủ chỗ; Hộp H1 (đầy) | Nhặt cargo vào ba lô (0,0); nhặt Dấu Thuế vào ba lô (2,0) (xoay nếu cần) | Cả hai hợp lệ, không giới hạn "một lựa chọn"; không toast so sánh; flow `CARRYING`/E1 không đổi | MUST_FIX | có+tay | M, T |
| TC-ZD-B04 | Biên: rời tầm khi dock mở | ZDU-01 | Card cargo mở | Đi ra ngoài 1.5 m (joystick) khi dock còn mở | R5' ẩn; dock tự đóng như hủy, **không** nhặt, **không** bỏ; cargo còn ở nguồn. (Khác O5i: O5i không đóng khi rời vùng — xem B15.) | MUST_FIX | có+tay | M, T |
| TC-ZD-B05 | Biên: nhặt lại vào run sau | ZD-03 | Đã nhặt cả hai món ở D; kết thúc run (chết hoặc extract) rồi vào run mới | Vào lại D | Cả hai nguồn lại `full` (mỗi nguồn đúng 1 món); trong cùng một run, món đã nhặt không quay lại nguồn | MUST_FIX | có+tay | M, T |

## 4. G10 — Hộp Công Chứng 2×2: niêm, không auto-swap, tự rút

Tiền điều kiện chung: Hộp fixture H1 (thuốc 1×2 ở (0,0) đứng + Manifest (1,0); ô trống duy nhất (1,1)); Dấu Thuế có thể ở
ba lô (2,0) hoặc ở nguồn `TaxStampD`. Niêm từ ba lô vào Hộp và nhặt thẳng vào Hộp **không có O5**.

| Case id | Loại | Spec | Tiền điều kiện | Bước (cảm ứng) | Kết quả mong đợi quan sát được | Lỗi nếu sai | Tự động? | Kênh |
|---|---|---|---|---|---|---|---|---|
| TC-ZD-07 | ĐẠT (đường A: rút thuốc → niêm Dấu Thuế) | ZD-12; ZDU-14…18 | H1; Dấu Thuế ở ba lô (2,0) đứng; (0,0),(0,1) trống | O4: chọn thuốc → `Rút` (dải S `INVENTORY_WITHDRAW_PICK_CELL_HINT`) → đè ba lô (0,0) (bóng (0,0),(0,1), `INVENTORY_PREVIEW_WITHDRAW_BACKPACK`) → nhấc → O5i → `Rút ra`. Rồi chọn Dấu Thuế → chạm Hộp (0,0) | Withdraw đúng một lần O5i; thuốc ở ba lô (0,0) **không** còn nhãn niêm; **niêm Dấu Thuế vào Hộp (0,0) không có O5**, nhãn `đã niêm`; Manifest vẫn ở Hộp (1,0); flow vẫn `CARRYING`/E1; H1 không đổi. Dấu Thuế được bảo vệ; thuốc nằm ba lô, không niêm | BLOCKER nếu có O5 khi niêm hoặc thiếu O5 khi rút | có+tay | M, T |
| TC-ZD-08 | ĐẠT (đường B: rút Manifest → niêm Dấu Thuế) | ZD-13; ZDU-19 | H1; Dấu Thuế ở ba lô; ba lô có chỗ cho Manifest 1×1 | Chọn Manifest trong Hộp → `Rút` → chọn ô ba lô (0,0) → O5i; xác nhận; rồi niêm Dấu Thuế tại Hộp (1,0) đứng | O5i thân `INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY` (nói Manifest **vẫn là vật chứng chưa extract**, vẫn gọi được thuyền; **không** dùng thân "sẽ mất"); nhãn đổi `đã niêm — chưa extract` → badge + `INVENTORY_SEAL_LABEL_NOT_EXTRACTED`; Dấu Thuế vào Hộp (1,0); H1 vẫn `HUD_OBJECTIVE_DELIVER_PIER_A`; beacon vẫn E1 (không đổi W2'); không "success" | MUST_FIX nếu dùng thân sai (nói mất vĩnh viễn); BLOCKER nếu beacon đổi | có+tay | M, T |
| TC-ZD-09 | ĐẠT (nhãn Manifest luôn thấy) | ZDU-13 | Manifest trong Hộp | Mở O4 `view`; chọn lần lượt thuốc, một món ba lô; mở O5i rồi hủy | Nhãn vật chứng + `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED` (`đã niêm — chưa extract`) luôn hiện ở R10g-E; ô Manifest có badge + icon niêm. Không câu nào nói Manifest đã "xong/giữ được" | MUST_FIX | có+tay | M, T |
| TC-ZD-10 | CẤM (Hộp từ chối Dấu Thuế, không auto-swap) | ZD-10, 11, 39; ZDU-11, 12 | H1; Dấu Thuế đứng ở ba lô (2,0); chụp ảnh **trước** | Chọn Dấu Thuế; lần lượt đè rồi nhấc ngón ở Hộp (0,0), (1,0), (1,1) (đứng) rồi bật `Xoay` và thử (0,1), (1,1) (ngang). Chụp **sau** mỗi lần | Mỗi lần: lý do hiện đúng (`thiếu ô`, `không vừa`), icon × ở ô cản (theo bảng spec §4.3: (0,0)→cản (0,0),(0,1); (1,0)→cản (1,0); (1,1) đứng→không vừa; (0,1) ngang→cản (0,1); (1,1) ngang→không vừa); không lần nào `ok`. **So trước/sau:** thuốc (0,0), Manifest (1,0), Dấu Thuế ba lô (2,0) giống hệt. Sau lần nhấc đầu R4' `INVENTORY_HINT_NOTARY_BOX_MAKE_ROOM`. Không nút "đổi chỗ", "rút giúp", "đặt vào chỗ gợi ý" | BLOCKER (readiness G10: auto-swap/drop) | có+tay | M, T |
| TC-ZD-11 | CẤM (nhặt thẳng từ nguồn vào Hộp đầy; không niêm tạo success) | ZD-11 | H1; Dấu Thuế còn ở nguồn D | Mở card Dấu Thuế → `Nhặt và xếp` → thử mọi ô Hộp (cả xoay) | Không lần nào vào được; Dấu Thuế vẫn ở nguồn, khối còn hiện; ba lô/Hộp không đổi; chạm Hộp xong **không** có toast/hiệu ứng "hoàn thành/giao hàng"; Manifest trong Hộp không bị đẩy ra | BLOCKER (readiness G10: seal tạo success/delivery) | có+tay | M, T |
| TC-ZD-B06 | Biên: Hộp đầy với món ngoài D (đối chiếu lý do) | §10.6; ZD-06 | Hộp H1; trong tay một món cache B sealable (sổ 1×2) và cargo | Thử niêm cả hai vào Hộp đầy | Sổ: lý do `thiếu ô`/`không vừa` (thiếu chỗ). Cargo: lý do `không niêm phong được` (**không** là `thiếu ô`). Hai lý do **khác nhau**, người chơi đọc được khác biệt | MUST_FIX nếu lẫn lý do | có+tay | M, T |
| TC-ZD-B07 | Biên: rút → niêm lại → rút lại | §10.5 | H1; thuốc trong Hộp; ba lô trống (0,0),(0,1) | Rút thuốc (O5i); niêm lại vào Hộp (0,0) (không O5); rút lần nữa (O5i) | Mỗi lần rút đúng 1 O5i; niêm không O5; nhãn niêm đổi đúng sau từng bước; không món nào mất/nhân đôi | MUST_FIX | có+tay | M, T |
| TC-ZD-B08 | Biên: Hộp hết chỗ và vẫn giữ món nguồn | ZD-39 | Hộp đầy; Dấu Thuế ở nguồn | Thử niêm; thoát card bằng `Đóng` | Không đổi; nguồn còn món; không tín hiệu gì ở HUD | MUST_FIX | có+tay | M, T |
| TC-ZD-B09 | Biên: túi đeo chéo không nhận loot | spec §4.1 dòng cuối | Card bất kỳ ở D | Thử đặt cargo/Dấu Thuế vào túi đeo chéo | Từ chối với `sai loại` (`WRONG_TARGET`); túi chỉ đọc, không có `Bỏ` hay `Rút`; món ở nguyên | MUST_FIX | có+tay | M, T |

## 5. G11 — O5: bỏ đồ, rút đồ niêm (đổi gear: không áp dụng ở slice)

Đổi gear phá placement cũ và vào run không vũ khí: **không áp dụng ở slice** (spec §5.6): O1 không có affordance cho hai
action đó. Plan chỉ kiểm sự **vắng mặt** của chúng (TC-ZD-18), không viết case "xác nhận đổi gear".

Tiền điều kiện chung: F-A hoặc F-B ở A/B/D; mở O3 (ba lô) hoặc O4 (Hộp) ở chế độ `view`. O5i ở 312–608 × 184–576 (1280×720);
nút xác nhận bị bỏ qua trong **0.3 s** đầu (sau khi O5i mở); vùng chạm ≥ 96 px; chữ ≥ 24 px.

| Case id | Loại | Spec | Tiền điều kiện | Bước (cảm ứng) | Kết quả mong đợi quan sát được | Lỗi nếu sai | Tự động? | Kênh |
|---|---|---|---|---|---|---|---|---|
| TC-ZD-12 | ĐẠT (bỏ đồ thường, xác nhận) | ZD-14, 15; ZDU-21, 22 | Đồng xu (hoặc cargo) trong ba lô; O3 `view` | Chọn món → `Bỏ` → đọc O5i → đợi 1 giây → `Bỏ xuống` | O5i: `INVENTORY_CONFIRM_DROP_TITLE`, hàng món (tên, `×n` nếu có), hàng đích `INVENTORY_CONFIRM_TARGET_GROUND`, thân `INVENTORY_CONFIRM_DROP_BODY`, sơ đồ footprint với ô món nét đứt + mũi tên xuống; có nút `Hủy`. Chưa đổi gì trước khi xác nhận. Xác nhận: **đúng một** món biến mất khỏi ba lô; một khối `GroundDrop` hiện **dưới chân** nhân vật, thấy được bên trái dock; toast `CARD_PLACED_CONFIRM_DROPPED`; R5' `WORLD_INTERACT_GROUND_DROP` khi trong 1.5 m | BLOCKER nếu một chạm bỏ đồ không O5 (G11); MUST_FIX nếu thiếu `Hủy` | có+tay | M, T |
| TC-ZD-13 | ĐẠT (bỏ Manifest = bỏ vật chứng, hậu quả rõ) | ZD-17; ZDU-23 | F-B: Manifest ở ba lô, E1 (đứng trong/ngoài `BeaconZoneA`) | Chọn Manifest → `Bỏ` → O5i → xác nhận; rồi nhặt lại | O5i dùng thân `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` + icon đèn phao **gạch chéo** (nói đèn phao A báo chưa gọi được thuyền). Xác nhận: H1 `HUD_OBJECTIVE_PICK_UP_MANIFEST`, W2' E0 (icon `chưa mở`), bàn dispatch A vẫn **trống** (Manifest không tự về bàn), Manifest là `GroundDrop`. Nhặt lại (R5' → card → `Nhặt và xếp`): `CARRYING`, E1, H1 về `DELIVER_PIER_A` | BLOCKER nếu bỏ không O5 hoặc Manifest tự về bàn/Archive | có+tay | M, T |
| TC-ZD-14 | ĐẠT (rút đồ niêm, xác nhận, O5 có đích) | ZD-12; ZDU-15, 16, 17 | Thuốc trong Hộp; ba lô (0,0),(0,1) trống | Chọn thuốc → `Rút` → đè ba lô (0,0) → nhấc → O5i → chạm `Rút ra` ngay → đợi 1 giây rồi chạm lại | O5i: `INVENTORY_CONFIRM_WITHDRAW_TITLE`, hàng món, hàng đích `INVENTORY_CONFIRM_TARGET_BACKPACK` (đúng ô (0,0)), nhãn `đã niêm` gạch → `không niêm`, thân `INVENTORY_CONFIRM_WITHDRAW_BODY` (món thường); dock: Hộp (0,0) nét đứt + ổ khóa mở, ba lô (0,0),(0,1) khung dày. Chạm ngay (≈ 0.3 s đầu) **không có tác dụng**; chạm sau đó thực hiện đúng một lần; toast `CARD_PLACED_CONFIRM_WITHDRAWN`; icon niêm của thuốc biến mất. **Rút không làm thuốc dùng được ngay** (vẫn không có nút dùng từ ba lô; thuốc chỉ dùng từ túi đeo chéo) | BLOCKER nếu commit không xác nhận; MUST_FIX nếu bỏ qua 0.3 s không có hiệu lực | có+tay | M, T |
| TC-ZD-15 | ĐẠT (Hộp chỉ có `Rút`, ba lô chỉ có `Bỏ`) | ZD-16; ZDU-25 | Thuốc trong Hộp; một món trong ba lô; túi đeo chéo có Gói Băng Muối | Chọn món trong Hộp; chọn món ba lô; chọn Gói Băng Muối ở túi | Món trong Hộp: có `Rút`, **không có** `Bỏ`. Món ba lô: có `Bỏ`. Túi đeo chéo: không chọn được, không có cả hai. Muốn bỏ món niêm phải rút (O5) rồi bỏ (O5) — hai bước | MUST_FIX; BLOCKER nếu bỏ thẳng món đang niêm | có+tay | M, T |
| TC-ZD-16 | CẤM (confirmation thừa) | ZD-20; ZDU-26 | Một run có O3/O4 | Làm lần lượt: đi lại; move trong cùng lưới; xoay; xem card; đổi chip; `Đóng`; preview; `Nhặt và xếp` vào ba lô; `Nhặt và xếp` vào Hộp; niêm từ ba lô vào Hộp; `Bỏ qua`; nhặt lại `GroundDrop`; D1 | **Không lần nào** mở O5i/O5 (đếm = 0). Mọi thao tác chỉ cần chạm xuống + nhấc | BLOCKER (readiness G11: popup cho mọi action là thừa; spec §5.3) — ghi MUST_FIX nếu chỉ một thao tác nhỏ | có+tay | M, T |
| TC-ZD-17 | CẤM (action phá run một chạm; không có `Hủy`) | ZD-14, 19; readiness G11 | O5i đang mở (drop và withdraw, hai lần) | Tìm nút `Hủy`; nhấn Back; xem có cách commit không qua O5i | Cả hai O5i luôn có `Hủy` (`CONFIRM_BUTTON_CANCEL`) và Back hoạt động; không có đường drop/rút một chạm nào ngoài O5i | BLOCKER | có+tay | M, T |
| TC-ZD-18 | CẤM (không có đổi gear / vào không vũ khí) | ZD-21; spec §5.6 | Ở S1/O1 và O3/O4 | Tìm mọi nút/affordance: đổi vũ khí, đổi khiên, vào run không vũ khí; rà chữ | Không có affordance nào; không chữ `LOADOUT_CONFIRM_GEAR_*`, `LOADOUT_CONFIRM_NO_WEAPON_*`. O1 chỉ cho sắp lại trong cùng ngăn (`INVENTORY_REASON_CROSS_GRID_LOCKED` khi kéo sang ngăn khác). **Không áp dụng ở slice**: nếu xuất hiện bất kỳ affordance nào thì là lỗi scope kể cả có O5 | MUST_FIX (scope) | có+tay | M, T |
| TC-ZD-B10 | Hủy bỏ đồ | ZD-14; ZDU-21 | Đồng xu trong ba lô; O3 `view` | `Bỏ` → O5i → `Hủy`; lặp với Back | Không đổi (ảnh trước/sau giống hệt); không `GroundDrop`; O3 vẫn chọn đồng xu | BLOCKER nếu có commit | có+tay | M, T |
| TC-ZD-B11 | Hủy rút | ZD-19; ZDU-18 | Thuốc trong Hộp; ba lô trống | Rút → O5i → `Hủy`; lặp với Back | Không đổi; thuốc vẫn `đã niêm` ở Hộp, vẫn được chọn | BLOCKER nếu commit | có+tay | M, T |
| TC-ZD-B12 | Rút khi ba lô đầy: không mở O5 | ZD-18; ZDU-20 | Ba lô đầy 12 ô; thuốc trong Hộp | Chọn thuốc; chạm `Rút`; chạm ô ba lô | `Rút` gạch chéo + khóa; dải S `INVENTORY_REASON_CELLS_OCCUPIED`; **không** mở O5i; thuốc giữ icon niêm | MUST_FIX nếu mở O5 trước khi biết hợp lệ | có+tay | M, T |
| TC-ZD-B13 | D1 đóng cả dock khi O5i mở, địch gần | ZDU-28; D1 | O5i mở ở B; vệ binh `alert` cách ≈ 5 m | Đọc HUD; chạm D1 (`HUD_DANGER_NEAR`) | D1 hiện, không bị O5i che; chạm → O5i **và dock** đóng trong **một chạm**, không commit; C1–C4 nhận chạm ngay. Telegraph/H2/H5/nhân vật không bị che | BLOCKER nếu dock che telegraph (G6) | có+tay | M, T |
| TC-ZD-B14 | Chết khi O5i mở | ZD-22; ZDU-31 | O5i `drop` cargo mở (cargo ở ba lô) ở B; để địch đánh tới HP 0 | Không chạm gì | O5i đóng **như hủy** (không commit, **không** `GroundDrop` mới); O7 Phù Hiệu hiện; S11: cargo ở `Đã mất` phân nhóm "không niêm" (icon ổ khóa mở), **không** ở nhóm "bỏ lại". Vì chết khi đang **rút** thuốc thì thuốc vẫn ở Hộp → `Đã giữ` | BLOCKER nếu commit khi chết; MUST_FIX nếu sai nhóm | có+tay | M, T |
| TC-ZD-B15 | O5i còn khi rời vùng D / bị đánh | spec §5.5; ZDU-29 | O5i `drop` mở ở D | (a) rời vùng D bằng joystick; (b) ở B bị đánh khi O5i mở (HP 85) | (a) O5i **không** đóng khi rời vùng (khác card O2). (b) O5i vẫn mở, H2 đổi, không commit; telegraph/H2 vẫn thấy | MUST_FIX | có+tay | M, T |
| TC-ZD-B16 | O5i chặn Gọi thuyền | ZD-23; ZDU-27 | O5i mở, đứng trong `BeaconZoneA`, E1 | Thử `Gọi thuyền` (nút/phím) | R5' ẩn; **không** mở O5 gọi thuyền; ngược lại khi O5 gọi thuyền mở thì không mở được O3/O4 | MUST_FIX | có+tay | M, T |
| TC-ZD-B17 | App xuống nền rồi quay lại | ZDU-30 | O5i mở | Chuyển sang app khác 5 giây rồi quay lại; chạm xác nhận ngay | O5i còn nguyên; chạm trong 0.3 s đầu bị bỏ qua | MINOR | chỉ tay | T |
| TC-ZD-B18 | Bỏ rồi nhặt lại: cùng món | ZD-15 | Đồng xu đã bỏ ở B hoặc D | Đứng trong 1.5 m `GroundDrop`; R5' → card → `Nhặt và xếp` vào ba lô | Cùng món (cùng tên, `×n`), `GroundDrop` biến mất; **không O5**; nhặt vào Hộp nếu niêm được cũng không O5 | MUST_FIX | có+tay | M, T |
| TC-ZD-B19 | Hai `GroundDrop` chồng chỗ | §10.7 | Bỏ hai món ở cùng chỗ (cách nhau < 1.5 m) | Đứng giữa; mở R5'; `Bỏ qua` | Mở card của món **gần tâm nhất**; `Bỏ qua` chuyển sang món kế; hòa thì món bỏ **trước** hiện trước (theo uid nhỏ) — ghi lại thứ tự quan sát | MINOR | có+tay | M, T |
| TC-ZD-B20 | Bỏ Manifest trong S8/S9 | spec §5.1; BCN-28, 29 | F-B; đang giữ khu (S8) rồi lên thuyền (S9) | Mở O5i bỏ Manifest ở S8; ở S9 | Thêm dòng `INVENTORY_CONFIRM_DROP_EVIDENCE_S8_NOTE` / `_S9_NOTE`. Xác nhận ở S8: hold **tạm dừng**; nhặt lại → hold chạy tiếp từ số giây cũ. Ở S9: không lên thuyền được khi không giữ Manifest. Không S10 | BLOCKER nếu tự thắng | có+tay | M, T |

## 6. G12 — D → B → A: đường về, lối D luôn mở, patrol có cue

Tiền điều kiện chung: F-A (có Manifest) hoặc không có Manifest (đi D để xem). Lối D mở **cùng lúc** với `GateB` (sau chặn ngõ B)
và **không đóng lại** trong run. Patrol về A bắt đầu khi chạm `PatrolTriggerB` (lấp lối `GateB`) **sau khi** đã vào `CalmZoneB`;
đi D (rời mép bắc `CalmZoneB`) không bắn patrol. Cue 2.0 s (`PATROL_CUE_LEAD`) trước khi vệ binh patrol vào khung.

| Case id | Loại | Spec | Tiền điều kiện | Bước (cảm ứng) | Kết quả mong đợi quan sát được | Lỗi nếu sai | Tự động? | Kênh |
|---|---|---|---|---|---|---|---|---|
| TC-ZD-19 | ĐẠT (lối D đọc được đóng → mở) | layout §2.2, 2.3 | Ở quảng B trước khi qua chặn ngõ | Nhìn khung lối D (bắc B) từ quảng; đợi GateB nâng; nhìn lại | Trước: khung đầy bảy song đứng, chữ X xích, đĩa niêm, lanh tô đỏ; **không prompt/marker**. Khi GateB nâng: song/xích rời khung, ván hạ nối B với D trong ≈ 1 s cùng nhịp; ảnh thang xám: ván tách khỏi nước. Không đóng lại kể cả sau khi đi D. Từ chạm `GateB` tới lối D mở không lệch nhịp | MUST_FIX; BLOCKER nếu lối D mở muộn hơn `GateB` làm dead-end | có+tay | M, T |
| TC-ZD-20 | ĐẠT (đi B → D, không patrol khi vào D) | layout §5.2 | Đã tới `CalmZoneB`, lối D mở | Đi từ vùng yên qua mép bắc sang D; đợi 30 giây ở D | Không đèn `PatrolAlertLampB`, không H5 patrol, không địch ở D (D không có địch); không prompt combat. Không có hazard | BLOCKER nếu địch/patrol xuất hiện lúc vào D | có+tay | M, T |
| TC-ZD-21 | ĐẠT (D → B → A: landmark ngược + patrol cue) | layout §5.2, 5.3; ZDU-43 | Đứng giữa vùng yên D; chuẩn bị đồng hồ | Đi D → B: nhìn trái-dưới tìm khung lối D, `SignToA`, `GateB`, `CacheB`. Qua cầu ván về `CalmZoneB`; bấm giờ khi chạm `GateB`; đi về A | Từ D thấy lối D + lanh tô đỏ ở trái-dưới; từ mép bắc `CalmZoneB` thấy `SignToA` (mũi tên + hình đèn phao) và `GateB`; tới `GateB` thì `PatrolAlertLampB` mở dần ba phân đoạn + H5 `HUD_ALERT_PATROL_B` + mũi tên về đèn; ≥ 2 giây sau vệ binh patrol vào khung **từ ngoài khung**, đi P0→P1→P2. Mái đỏ → đèn → `BeaconA` → cầu tàu A đọc được, **không minimap**. H1 `HUD_OBJECTIVE_DELIVER_PIER_A` suốt đường (trừ dòng encounter B). Không marker chỉ đường mới. Ghi vị trí đứng + ảnh | BLOCKER (readiness G12: surprise spawn, mất route A); MUST_FIX nếu cue < 2 giây | có+tay | M, T |
| TC-ZD-22 | CẤM (surprise spawn / dead-end / D extract) | layout §5.2, §9; readiness G12 | Trên D → B → A, đi nhiều cách (thẳng, chéo đông, dash liên tiếp) | Ghi mọi lần địch xuất hiện, thời gian cue → địch vào khung; tìm nút/vùng extract ở D; tìm dead-end bắt buộc chết, teleport/checkpoint | Không địch spawn trong khung hoặc **sau lưng**; vệ binh patrol vào từ phía trước (ngoài khung) sau cue; **D không có extract** (không nút/vùng/thuyền); không dead-end bắt buộc chết; không teleport/checkpoint. (Lưu ý đã biết: đi dash liên tiếp có thể chỉ còn ≈ 1.85 s cue — ghi lại số đo nếu < 2 s, đánh MUST_FIX và gửi layout §10.3 câu hỏi mở 1, **không** tự ý đổi) | BLOCKER nếu spawn sau lưng/extract ở D | có+tay | M, T |
| TC-ZD-23 | CẤM (extract ở D, route A bị mất) | layout §9.1; BCN-37 | Ở D và B | Đứng ở mọi chỗ D; thử R5' ở `DExitToB`; xem foreground che A | Không R5' "Gọi thuyền" ở D; không bến thuyền/đèn phao A tại D; không vật > 1 m che hướng về A khi đã ở tâm `CalmZoneB`; lối D→B không đổi hướng | BLOCKER | có+tay | M, T |
| TC-ZD-B21 | Biên: patrol một lần | layout §5.2.1 | Đã bắn patrol một lần | Quay lại D rồi về B, qua `GateB` lần hai | Không cue/địch mới thứ hai (một lần mỗi run); nếu quay lại vùng yên thì patrol vẫn ở phía nam rào, **phía trước** người chơi, không vào vùng yên | BLOCKER nếu lặp surprise | có+tay | M, T |
| TC-ZD-B22 | Biên: patrol trước vùng yên (lần đi lên) | layout §5.2.1 | Đi A → B, chạm `PatrolTriggerB` **trước** khi vào `CalmZoneB` | Đi lên, quan sát | Không bắn patrol lúc đi lên (chỉ bắn khi về sau khi đã vào vùng yên) | MUST_FIX | có+tay | M, T |
| TC-ZD-B23 | Biên: chờ trong vùng yên / ở D 60 s | layout §5.2 | Ở `CalmZoneB`; ở D | Đứng 60 giây mỗi chỗ, mở/đóng card | Không patrol, không đèn, không prompt combat (vùng yên) | MUST_FIX | có+tay | M, T |
| TC-ZD-B24 | Biên: nhặt hay không nhặt ở D không đổi patrol/đường về | layout §5.2.1; ZD-09 | Hai lần chạy: một lần nhặt cargo, một lần bỏ qua | Về A cả hai lần; so cue | Cue patrol, thời gian, đường về A giống hệt; lối D → B → A không phụ thuộc inventory | BLOCKER nếu penalty/khóa đường | chỉ tay | M, T |

## 7. G15 — S10 full-route (A → B → D → B → A → S10)

Tiền điều kiện chung: F-A hoặc F-B, đã qua D, về A, gọi thuyền → giữ khu (S8) → lên thuyền (S9) → S10. S10 dùng đúng màn S10 của
S02 (cùng tập key); khác chỉ ở danh sách món. Số ô ba lô tính **trước** khi lên thuyền; cargo tính 4 ô.

| Case id | Loại | Spec | Tiền điều kiện | Bước (cảm ứng) | Kết quả mong đợi quan sát được | Lỗi nếu sai | Tự động? | Kênh |
|---|---|---|---|---|---|---|---|---|
| TC-ZD-24 | ĐẠT (fixture §11 ZD-24) | ZD-24; ZDU-41 | Manifest nhặt vào ba lô (0,0); ở B nhặt đồng xu vào ba lô (2,3) **rồi bỏ** (O5), không nhặt lại; ở D cargo vào ba lô (1,0) (cạnh Manifest), Dấu Thuế **thẳng vào Hộp** (1,0) đứng; thuốc túi chưa dùng; về A hold + lên thuyền | `board()` | `Đã giữ`: licence (Manifest), cargo (`2×2`), Cuộn Băng Muối (`1×2`, Hộp), Dấu Thuế (`1×2`), Gói Băng Muối (`1×1`), dòng `SUMMARY_SUCCESS_KEPT_CELLS` = **5/12** (1 + 4); `Đã mất`: đồng xu (icon mũi tên xuống) + `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`; nhóm `Vật chứng` đúng; **không** số giá trị, điểm, sao, route, thời gian; không "tốt hơn rút sớm". (Fixture dựng bằng chơi tự nhiên; nếu không đủ chỗ tại (1,0) do bố cục thật, ghi vị trí thật.) | BLOCKER nếu có điểm/xếp hạng/giá trị | có+tay | M, T |
| TC-ZD-25 | ĐẠT (thuốc dùng hết không ở nhóm nào) | ZD-25; §10.10 | Dùng hết Gói Băng Muối ở B | `board()` → S10 | Gói Băng Muối **không** ở `Đã mất` và **không** ở `Đã giữ` | MUST_FIX | có+tay | M, T |
| TC-ZD-26 | CẤM (chấm điểm full-route, hồi đồ bỏ, đổi Manifest) | ZD-26; readiness G15 | Hai lần S10: rút sớm (không đi B/D) và full-route có cargo | So bố cục và key hai S10; tìm giá trị, "bạn đi xa hơn", thưởng; đọc nhóm `Vật chứng`/`Tiếp theo` | Cùng bố cục, cùng tập nhóm; chỉ khác dòng danh sách; **không** `relative_value_*`, điểm, sao, route, thời gian; Manifest = giữ giấy phép/lead Kho K-7, **không** thành `Bộ Phản Niêm`, không bán/craft/minh oan; Contract 2 chỉ state-only ("chưa chơi được", không nút bắt đầu); đồ đã bỏ **không** tự hồi | BLOCKER (readiness G15) | có+tay | M, T |
| TC-ZD-B25 | Biên: đồ bỏ rồi nhặt lại trước khi lên thuyền | spec §8.3 | Bỏ đồng xu ở B rồi nhặt lại **trước** `board()` | S10 | Đồng xu ở `Đã giữ`, **không** ở `Đã mất`; ô ba lô tính đúng | MUST_FIX | có+tay | M, T |
| TC-ZD-B26 | Biên: cargo bỏ ở D | §10.1 | Bỏ cargo ở D; lấy Dấu Thuế; về A; S10 | S10 | Cargo ở `Đã mất` với `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`; nguồn `CargoD` vẫn `empty` (khối không hiện lại khi quay lại D) | MUST_FIX | có+tay | M, T |
| TC-ZD-B27 | Biên: chưa từng nhặt ở D | §8.4 | Không nhặt gì ở D; về A; S10 | S10 | Món ở nguồn D không hiện ở nhóm nào; không nhóm `Đã mất` rỗng (ẩn nếu rỗng) | MINOR | có+tay | M, T |
| TC-ZD-B28 | Biên: rút sớm vs full-route cùng màn | ZD-26 | Hai lần S10 như TC-ZD-26 | `Về hub` | Cả hai về Boot; run mới bắt đầu như BCN-01; không file mới; cache B + nguồn D đầy lại | MUST_FIX | có+tay | M, T |

## 8. G16 — S11 trước Manifest

**Fixture dựng bằng chơi tự nhiên (spec §9.1, không menu debug):** Boot → S1 → `Vào cảng` (kit mặc định). Ở A **không**
tương tác bàn dispatch → đi vào B → qua chặn ngõ (GateB mở) → tới `CacheB` → nhặt **Sổ Kho Ngấm Nước thẳng vào Hộp (1,0) đứng**
(niêm, không O5; Hộp = Cuộn Băng Muối + Sổ Kho, đầy) → nhặt **Đồng Thuế Cạo Mặt ×2** vào ba lô (0,0), **không** dùng thuốc → rời
`CalmZoneB` qua `GateB`, để patrol đánh tới HP 0. Nội dung trước khi chết: Hộp = Cuộn Băng Muối + Sổ Kho; ba lô = đồng xu; túi
= Gói Băng Muối (chưa dùng). Giả định: A → B không bị Manifest chặn; nếu build chặn, G16 là `NOT READY` và cần card fixture
riêng (**không** thay bằng menu debug).

| Case id | Loại | Spec | Tiền điều kiện | Bước (cảm ứng) | Kết quả mong đợi quan sát được | Lỗi nếu sai | Tự động? | Kênh |
|---|---|---|---|---|---|---|---|---|
| TC-ZD-27 | ĐẠT (S11 trước Manifest, đúng ba nhóm) | ZD-27, 29; ZDU-33 | Fixture §8 (xem Z4) | Để HP về 0; đọc S11 sau O7 | Tiêu đề `SUMMARY_DEATH_TITLE` + dấu Phù Hiệu; `Đã giữ` = Cuộn Băng Muối, Sổ Kho Ngấm Nước (icon niêm); `Đã mất` = Đồng Thuế Cạo Mặt, Gói Băng Muối (phân nhóm "không niêm") + dòng trang bị cố định (`SUMMARY_DEATH_LOST_EQUIPPED`); cột `Vật chứng` = `SUMMARY_DEATH_EVIDENCE_AT_DESK` (Manifest còn ở bàn dispatch A) + `SUMMARY_DEATH_NOT_EXTRACTED`; Contract 1 vẫn mở; nút `SUMMARY_DEATH_BUTTON_PREPARE` (`Chuẩn bị lại`) ở dưới-giữa; **không** dòng thu hồi, không `SUMMARY_SUCCESS_*`, không giá trị/điểm. Cột Vật chứng có icon/shape riêng (không chỉ màu) | BLOCKER nếu Manifest biến mất/hiện completion hoặc sealed non-evidence bị nói là mất (readiness G16) | có+tay | M, T |
| TC-ZD-28 | ĐẠT (`Chuẩn bị lại` → S1, run mới) | ZD-28; ZDU-34 | S11 của TC-ZD-27 | Chạm nút ở 0.5 s (bị bỏ qua: icon khóa + vòng); đợi tới sau 1.0 s; chạm | Lần đầu không gì; lần sau → S1 Contract 1 đúng một lần với `UI_LOADING`; loadout = mặc định (Hộp = Cuộn Băng Muối, **không** có Sổ Kho; túi = Gói Băng Muối); vào cảng như BCN-01; `CacheB` và nguồn D đầy lại; không file save; "Đã giữ" **không** mang sang run mới | BLOCKER nếu đồ mang sang; MUST_FIX nếu chạm sớm có tác dụng | có+tay | M, T |
| TC-ZD-29 | CẤM (success giả / S10 / chữ hoàn thành) | ZD-27, 38; ZDU-32 | Mọi death ở đầu run, trước Manifest | Đọc toàn bộ chữ O7 và S11 | Không `COMBAT_STUB_HP_ZERO`/`COMBAT_STUB_BUTTON_BOOT`; không chữ/icon success ("thành công", "hoàn thành", tích xanh); không S10; không `extract_succeeded`; không "chưa hoàn thành" hứa hồi đồ | BLOCKER (death thành success) | có+tay | M, T |
| TC-ZD-B29 | Biên: chết khi đang preview nhặt/nguồn | spec §7.2 D7 | Đang preview nhặt (giữ ngón) ở `CacheB` rồi chết | HP về 0 khi dock mở | Dock đóng như hủy (không nhặt, cache còn món); món ở nguồn **không** ở `Đã mất` (chưa từng mang); S11 theo D1 | MUST_FIX | có+tay | M, T |
| TC-ZD-B30 | Biên: đã dùng thuốc trước khi chết | spec §9.1 cuối | Fixture TC-ZD-27 nhưng dùng Gói Băng Muối (hồi 40) trước | Chết | `Đã mất` **không** có Gói Băng Muối; dòng trang bị vẫn có (chứng minh "đồ không niêm mất") | MUST_FIX | có+tay | M, T |
| TC-ZD-B31 | Biên: `Đã giữ` rỗng | §10.8; ZDU-37 | Rút Cuộn Băng Muối khỏi Hộp rồi **bỏ** (hoặc để ở ba lô) → Hộp trống non-evidence; chết | Đọc S11 | Cột `Đã giữ` ẩn; hai cột `Đã mất` + `Vật chứng`; vẫn có dòng trang bị | MINOR | có+tay | M, T |
| TC-ZD-B32 | Biên: 2.5 s Phù Hiệu | ZD-38; ZDU-32 | HP về 0 ở B | Bấm giờ 0–2.5 s; chạm/Back liên tục; xem địch | O7: lớp chặn, dấu Phù Hiệu + vòng lấp + một dòng `RECALL_SIGIL_MOMENT_LINE` (≤ 48 ký tự), **im lặng**; C1–C4, R5', H3, D1, H5, R2 ẩn; chạm/Back bị bỏ qua; không sát thương thêm, hold không tick; S11 mở ≈ 2.5 s (±1 s) | MUST_FIX | có+tay | M, T |

## 9. G17 — S11 sau Manifest

**Fixture dựng bằng chơi tự nhiên (spec §9.2):** ở bàn dispatch: `Nhặt và xếp` Manifest **thẳng vào Hộp (1,0)** (Hộp = Cuộn Băng
Muối (0,0) + Manifest (1,0); `CARRYING`, E1) → qua B (có thể `Bỏ qua` cache) → vào D → ở `CargoD`: nhặt Vải Cứu Trợ Đổi Nhãn
vào ba lô (0,0) (4 ô) → quay D → B → để patrol (hoặc đợt lane lúc giữ khu A) đánh tới HP 0. **Biến thể G17-B:** sau bước nhặt
cargo, nhặt Dấu Thuế vào ba lô (2,0) đứng; ở O4 rút Cuộn Băng Muối tới ba lô (0,2) đứng qua O5i; niêm Dấu Thuế vào Hộp (0,0)
đứng (Đường A với ô khác vì cargo chiếm (0,0)–(1,1)); chết.

| Case id | Loại | Spec | Tiền điều kiện | Bước (cảm ứng) | Kết quả mong đợi quan sát được | Lỗi nếu sai | Tự động? | Kênh |
|---|---|---|---|---|---|---|---|---|
| TC-ZD-30 | ĐẠT (Manifest trong Hộp, ba nhóm) | ZD-30; ZDU-35 | Fixture §9 (Z5) | HP về 0; đọc S11 | `after_manifest`: `Đã giữ` = Cuộn Băng Muối; `Đã mất` = Vải Cứu Trợ Đổi Nhãn (không niêm) + Gói Băng Muối nếu chưa dùng + dòng trang bị; `Vật chứng` = `SUMMARY_DEATH_EVIDENCE_UNRECOVERED` (cột tiêu đề `Vật chứng — chưa thu hồi`) + tag `chưa thu hồi` + `NOT_EXTRACTED`; **Manifest không ở `Đã giữ` dù nằm trong Hộp** và không ở `Đã mất`; Contract 1 **không** hoàn thành; không S10 | BLOCKER nếu Manifest ở `Đã giữ` hoặc `Đã mất`, hoặc success/delivery (readiness G17) | có+tay | M, T |
| TC-ZD-31 | ĐẠT (một nút Boot, không Recovery) | ZD-31; ZDU-35 | S11 của TC-ZD-30 | Đọc màn; chạm nút sau 1.0 s | Đúng **một** nút `SUMMARY_DEATH_BUTTON_BOOT` ở dưới-giữa; **không** `SUMMARY_DEATH_BUTTON_RECOVERY`, không chữ `RECOVERY_*`, không `Recovery Contract`, không `SUMMARY_SUCCESS_*`; dòng `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` (nếu có) chỉ nói chưa có trong bản này, không hứa hồi đồ/thời điểm; chạm → Boot đúng một lần; không file save; run mới như BCN-01 | BLOCKER nếu có nút/lời mời Recovery (G18 ngoài scope S04); MUST_FIX nếu nhiều nút | có+tay | M, T |
| TC-ZD-32 | ĐẠT (biến thể G17-B: hậu quả của rút) | ZD-35 | Fixture G17-B | HP về 0 | `Đã giữ` = Dấu Thuế (vừa niêm); `Đã mất` có Cuộn Băng Muối (vừa rút, không niêm) và cargo; Manifest vẫn `Vật chứng — chưa thu hồi` (kể cả vị trí Manifest). Chứng minh rút làm đồ mất khi chết | BLOCKER nếu thuốc rút vẫn `Đã giữ` | có+tay | M, T |
| TC-ZD-33 | CẤM (Manifest về hub/Archive, thành success) | readiness G17 | Sau TC-ZD-30 → Boot → vào Contract 1 mới | Kiểm bàn dispatch/Archive/Boot | Manifest **không** ở Archive/hub; run mới bắt đầu BCN-01 (Manifest ở bàn); không toàn bộ Hộp "về cùng Manifest"; không mô tả "đã nộp/giao" | BLOCKER | có+tay | M, T |
| TC-ZD-34 | CẤM (không có đồ không niêm để chứng minh mất) | readiness G17 | Fixture G17 | Đọc `Đã mất` | Luôn có ít nhất một đồ không niêm (cargo hoặc thuốc túi) trong `Đã mất` ở fixture G17; nếu `Đã mất` chỉ có dòng trang bị mà người test không thể chứng minh đồ mất, ghi `NOT READY` (fixture thiếu bước) | BLOCKER (fixture sai) | có+tay | M, T |
| TC-ZD-B33 | Biên: Manifest trong ba lô khi chết | ZD-32 | F-B + cargo ở ba lô | HP về 0 | `Vật chứng` có Manifest; `Đã mất` chỉ có cargo (+ thuốc túi nếu còn); Manifest không ở `Đã mất` | BLOCKER | có+tay | M, T |
| TC-ZD-B34 | Biên: Manifest `DROPPED` khi chết | ZD-33 | Bỏ Manifest (O5i) ở B/A rồi để HP về 0 **trước** khi nhặt lại | HP về 0 | `Vật chứng` có Manifest **đúng một lần**; không ở `Đã mất`; `ContractState` sau = unrecovered; không S10; HUD H1 trước khi chết `HUD_OBJECTIVE_PICK_UP_MANIFEST` | BLOCKER nếu trùng/không có | có+tay | M, T |
| TC-ZD-B35 | Chết trong hold (S8 tạm dừng và đang chạy) | ZD-34 | F-B; ở A gọi thuyền → S8 (một lần trong vòng, một lần ngoài vòng) | Để lane B đánh tới HP 0 | `ENDED_DEATH`; không `resolve_extract`; không S10; không hold tick; O7 → S11 `after_manifest` cả hai lần | BLOCKER (readiness G14: death vẫn thành success) | có+tay | M, T |
| TC-ZD-B36 | Chết khi S9 (`BoardZoneA`) | ZD-34 | F-B; hold xong, đang ở S9 | Bị đánh tới HP 0 trước khi lên thuyền | Như B35; `Lên thuyền` không còn dùng; không S10 | BLOCKER | có+tay | M, T |
| TC-ZD-B37 | Chết khi O5 gọi thuyền mở | ZD-34 | Ở `BeaconZoneA` E1, mở O5 gọi thuyền; bị đánh | HP về 0 | O5 đóng như hủy (không gọi thuyền); O7 → S11 `after_manifest`; không S10 | BLOCKER | có+tay | M, T |
| TC-ZD-B38 | Biên: S11 chỉ một lần, không chết hai lần | ZD-37; §10.9 | Sau S11 | Quay lại bằng Back/chạm nhiều lần | Không S11 thứ hai; không đếm `Đã giữ` hai lần; không crash | MUST_FIX | có+tay | M, T |
| TC-ZD-B39 | Biên: thử lại sau S11 (cả hai biến thể) | ZD-28 | Một lần `before_manifest` (→ S1), một lần `after_manifest` (→ Boot) | Chơi tiếp một run mới ngắn | Run mới đầy đủ: cache B + nguồn D đầy, Manifest ở bàn, Hộp/ba lô/túi mặc định, HP 100/100; không đồ/`GroundDrop` cũ | BLOCKER nếu đồ cũ còn | có+tay | M, T |

## 10. Chỉ staging và production (tách riêng)

Debug menu và env badge không thuộc spec S04. Dùng cùng khung như [plan vòng A §9](loop-a-early-extract-test-plan.md): nếu build
staging không có debug menu, ghi `KHÔNG TEST ĐƯỢC` theo [phiếu quan sát](../playtest-observation-sheet.md) §1 thay vì bịa
đường tắt. Fixture G16/G17 **không** được thay bằng debug menu.

| Case id | Tiền điều kiện | Bước | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|
| TC-ZD-S01 | Build staging | Mở Boot, HUD D, S11 | Nhãn `AppEnv.channel = staging` + version hiện, không che nút/ô lưới/H5/D1/nút S11 | chỉ tay | S-only |
| TC-ZD-S02 | Build production (tag) | Tìm debug menu, nạp fixture/HP/vị trí | Không badge staging, không debug menu, không đường nạp fixture D/HP/Manifest; G16/G17 vẫn đạt bằng chơi tự nhiên | chỉ tay | P-only |
| TC-ZD-S03 | Staging + debug menu (nếu có) | Nạp "ở D", "sau Manifest", "HP thấp" để rút ngắn | State nạp trùng state flow thật (cùng HUD/beacon/D1); kết quả B14, B33, B35 giống chạy thật; fixture **không** thay Z4/Z5 | chỉ tay | S-only |
| TC-ZD-35 | Mọi màn S04 ở 1280×720 và 640×360 | Đo `Bỏ`, `Rút`, `Xoay`, nút O5i (`Rút ra`/`Bỏ xuống`/`Hủy`), nút S11 | Mỗi vùng ≥ 96 px ở 1280×720 (≥ 48×48 px thật ở 640×360), khoảng giữa ≥ 8 px thật, chữ ≥ 24 px (≥ 12 px thật); O5i ở 312–608 × 184–576; nút S11 ở 440–840 × 608–704; không rect giao nhau hoặc giao vùng joystick (ZDU-44) | có+tay | P, M, T |
| TC-ZD-36 | Mọi màn S04 | Rà chữ trên mọi card/dock/O5i/O7/S11/S10 | Mỗi chữ có key trong `strings.csv`; không chuỗi cứng; **không hiện** `COMBAT_STUB_*`, `INVENTORY_REASON_WITHDRAW_LOCKED`, `INVENTORY_PREVIEW_FITS_NOTARY_BOX`, `SUMMARY_DEATH_BUTTON_RECOVERY`; độ dài chữ trong giới hạn (hai chuỗi sát: `INVENTORY_HINT_NOTARY_BOX_MAKE_ROOM`, `INVENTORY_PICKUP_SOURCE_D`, kiểm không bị cắt) (ZDU-45) | có+tay | P, M, T |

## 11. Ảnh thang xám và màn nhỏ 640×360

Chụp bằng cùng camera game; ghi cửa sổ, tỉ lệ và vị trí đứng. Đọc **không dùng màu**.

| Case id | Gate | Cảnh | Kết quả mong đợi | Tự động? | Kênh |
|---|---|---|---|---|---|
| TC-ZD-G01 | G9 | Hai card D cạnh nhau (thang xám) | Phân biệt footprint, giá trị (số + nhãn), claim (icon); rarity giống nhau; không vạch so sánh (ZDU-04) | chỉ tay | M, T |
| TC-ZD-G02 | G9 | Khối `CargoD` (vuông 1:1) và `TaxStampD` (dẹt 1:2) ở D, 640×360 | Hai nguồn phân biệt bằng hình khối; đọc được ở màn nhỏ; khung lối D + lanh tô vẫn trong khung | chỉ tay | M, T |
| TC-ZD-G03 | G10 | Lưới Hộp H1 và lý do từ chối (thang xám) | Ô Manifest có badge + icon niêm + mấu; ô cản icon ×; nhãn đọc được | chỉ tay | M, T |
| TC-ZD-G04 | G11 | O5i drop và withdraw ở 640×360 | Nét đứt + mũi tên/ổ khóa mở đọc được; nút đủ lớn; không che H2/H5/R2 | chỉ tay | M, T |
| TC-ZD-G05 | G12 | Ván lối D đóng/mở; patrol cue ở 640×360 | Ván tách khỏi nước tối; đèn ba phân đoạn đọc được; mũi tên H5 thấy | chỉ tay | M, T |
| TC-ZD-G06 | G15 | S10 full-route và S10 rút sớm | Cùng bố cục; không số giá trị/điểm | chỉ tay | M, T |
| TC-ZD-G07 | G16 | S11 trước Manifest ở 640×360 | Hai/ba cột đọc được; nút ở đáy; icon Vật chứng khác icon cột khác | chỉ tay | M, T |
| TC-ZD-G08 | G17 | S11 sau Manifest cạnh S10 (thang xám) | Phân biệt hai màn không cần màu: số cột, dấu Phù Hiệu vs không, vị trí nút, có/không `Tiếp theo` và câu mentor (ZDU-40) | chỉ tay | M, T |

## 12. Kịch bản đầu-cuối (DoD S04) — chơi tự nhiên

Mỗi Z bắt đầu Boot → S1 → `Vào cảng` (kit mặc định), **không menu debug**. Ghi build channel + version ở đầu phiếu.

### 12.1 Z1 — Mang cargo (outcome 1) → A → S10

| Bước | Hành động | Kết quả mong đợi | Case |
|---|---|---|---|
| 1 | S1 → `Vào cảng`; ở bàn dispatch `Nhặt và xếp` Manifest vào Hộp (1,0) | `CARRYING`, E1; Hộp H1 | TC-ZD-09 |
| 2 | Đi A → B qua chặn ngõ; tới `CalmZoneB`; `Bỏ qua` hoặc nhặt cache B | GateB + lối D mở cùng lúc | TC-ZD-19 |
| 3 | Qua cầu ván sang D | Không patrol/địch | TC-ZD-20 |
| 4 | Ở `CargoD`: đọc card; nhặt vào ba lô (0,0) | Card đủ tổng 8/ô 2; cargo vào ba lô; không vào Hộp | TC-ZD-01, 04, 05 |
| 5 | D → B → `GateB` → A | Patrol cue ≥ 2 s; không spawn sau lưng | TC-ZD-21 |
| 6 | Gọi thuyền → giữ khu → lên thuyền | S10 một lần | TC-ZD-24 |
| 7 | S10 | `Đã giữ` có cargo `2×2`; `5/12`-kiểu dòng ô đúng; không điểm/giá trị | TC-ZD-24, 26 |
| 8 | `Về hub` | Boot; phiên mới | TC-ZD-B28 |

### 12.2 Z2 — Ưu tiên Dấu Thuế (outcome 2) → A → S10

Như Z1 nhưng ở D: nhặt Dấu Thuế thay cargo. **Hộp H1 đầy** nên phải tự rút (đường A hoặc B) trước khi niêm.

| Bước | Hành động | Kết quả mong đợi | Case |
|---|---|---|---|
| 1…3 | Như Z1 bước 1–3 | — | — |
| 4 | Nhặt Dấu Thuế vào ba lô (2,0) | Card `1×2`, 6/3 | TC-ZD-02 |
| 5 | Thử niêm vào Hộp đầy | Từ chối đúng lý do; không auto-swap | TC-ZD-10 |
| 6 | Đường A: rút thuốc (O5i) → niêm Dấu Thuế (không O5) | Đúng 1 O5i; Dấu Thuế `đã niêm` | TC-ZD-07 |
| 7 | D → B → A, hold, lên thuyền → S10 | `Đã giữ`: Manifest/licence, Dấu Thuế, thuốc (ở ba lô), Gói Băng Muối | TC-ZD-21, 24 |

### 12.3 Z3 — Bỏ cả hai (outcome 3) → A → S10

| Bước | Hành động | Kết quả mong đợi | Case |
|---|---|---|---|
| 1…3 | Như Z1 | — | — |
| 4 | Mở card cargo → `Bỏ qua`; card Dấu Thuế → `Đóng` | Không đổi; nguồn còn món | TC-ZD-B02 |
| 5 | D → B → A, hold, lên thuyền → S10 | Không phạt; không `Đã mất`; không câu trách | TC-ZD-B02, B27 |

### 12.4 Z4 — G16: chết trước Manifest (chơi tự nhiên)

Dựng như §8: **không** chạm bàn dispatch; A → B → nhặt Sổ Kho vào Hộp (1,0), đồng xu ×2 vào ba lô (0,0), không dùng thuốc →
rời `CalmZoneB` → để patrol đánh tới HP 0.

| Bước | Hành động | Kết quả mong đợi | Case |
|---|---|---|---|
| 1…4 | Dựng fixture §8 | Hộp = Cuộn Băng Muối + Sổ Kho; ba lô = đồng xu; túi = Gói Băng Muối | TC-ZD-B29 |
| 5 | HP về 0 | O7 2.5 s, không âm thanh | TC-ZD-B32 |
| 6 | S11 | `before_manifest` đúng ba nhóm; nút `Chuẩn bị lại` | TC-ZD-27, 29 |
| 7 | Chạm nút sau 1.0 s | S1; run mới sạch | TC-ZD-28, B39 |

### 12.5 Z5 — G17: chết sau Manifest, ba nhóm

Dựng như §9 (Manifest vào Hộp, cargo vào ba lô ở D, quay D → B, chết ở patrol). Một lần phụ: biến thể G17-B (Z6).

| Bước | Hành động | Kết quả mong đợi | Case |
|---|---|---|---|
| 1…4 | Dựng fixture §9 | Hộp = Cuộn Băng Muối + Manifest; ba lô = cargo | TC-ZD-B33 |
| 5 | HP về 0 | O7 → S11 | TC-ZD-B32 |
| 6 | S11 | `after_manifest` ba nhóm; Manifest `chưa thu hồi`; một nút Boot | TC-ZD-30, 31, 33 |

### 12.6 Z6 — G17-B: hậu quả của rút

Như Z5 nhưng thêm: nhặt Dấu Thuế vào ba lô (2,0); rút Cuộn Băng Muối ra ba lô (0,2) qua O5i; niêm Dấu Thuế vào Hộp (0,0) đứng; chết.
Kết quả: TC-ZD-32 (`Đã giữ` = Dấu Thuế; `Đã mất` có thuốc + cargo; Manifest chưa thu hồi).

### 12.7 Z7 — Chết trong hold

Như Z5 nhưng đi tiếp tới A, gọi thuyền → S8; để lane B đánh tới HP 0 (một lần trong vòng, một lần ngoài vòng); xác nhận không S10.
Kết quả: TC-ZD-B35, B36, B37.

### 12.8 Hồi quy ngắn (vòng rút sớm S02 và vòng B S03)

| Case | Chạy lại | Điểm S04 thay đổi cần đọc | Mong đợi |
|---|---|---|---|
| TC-ZD-R1 | **C1 rút sớm S02** (13 bước, [plan vòng A](loop-a-early-extract-test-plan.md) §5), không đi B/D | Không có O5 thừa cho thao tác thường (TC-ZD-16); `Gọi thuyền` vẫn qua O5 riêng; khi chết ở A giờ ra O7 + S11 (**không** còn stub `COMBAT_STUB_HP_ZERO`); lối A → B không bắt buộc | S10 một lần, không `Đã mất`, không điểm; TC-LA-01…26 vẫn đạt; không `COMBAT_STUB_*` |
| TC-ZD-R2 | **Z1 của S03** ([plan khu B §9.1](zone-b-combat-loot-test-plan.md)): A → B → skirmish → loot (xoay `1×2`) → về A → hold → board → S10, **không** đi D | Patrol bật qua `PatrolTriggerB` (không còn `CalmZoneB.body_exited`): vẫn bắn khi về A một lần; `INVENTORY_REASON_WITHDRAW_LOCKED` không còn hiện (rút giờ qua O5i); lối D mở nhưng không bắt buộc | G6, G7, G8, G12, G14 của S03 vẫn đạt; TC-ZB-17…21 vẫn đúng; TC-ZB-14 đặt vào Hộp vẫn không O5; TC-ZB-B14(c) nay là rút O5 thay vì `WITHDRAW_LOCKED` (ghi chú thay đổi chủ ý) |

## 13. Bảng truy vết case ↔ spec ↔ test headless ứng viên

Tên test có sẵn trong `game/tests/unit/` (chưa có test `zd_xx`; ứng viên, **chưa đối chiếu từng assert**):

| Case | Spec | Test ứng viên (chưa xác nhận đúng ý) |
|---|---|---|
| TC-ZD-01…04, B01, B02, B05 | ZD-01…09 | `test_flow_zone_d_cargo_route_uses_authored_areas_then_extracts`, `test_flow_context_target_prefers_nearest_ground_drop_over_d_source`, `test_zone_d_has_locked_markers_sources_and_world_static_floor` |
| TC-ZD-05, 07…11, B06…B09 | ZD-06, 10…13 | `test_flow_zone_d_stamp_rejection_withdraw_and_seal_uses_o5` |
| TC-ZD-12…15, B10…B20 | ZD-14…23 | `test_ui_confirm_emits_accept_and_cancel_only_from_buttons`, `test_ui_confirm_locks_accept_after_first_confirmation`, `test_flow_d_source_exit_preserves_pending_drop_confirmation`, `test_flow_d_source_exit_preserves_pending_withdraw_confirmation`, `test_flow_ground_drop_overlap_reselects_and_skip_advances_by_distance_then_uid`, `test_flow_rotated_tax_stamp_drop_creates_upright_ground_drop`, `test_flow_ground_drop_is_hidden_and_rejected_during_hold` |
| TC-ZD-19…23, B21…B24 | layout §2, §5 | `test_zone_d_has_no_extract_grammar_and_its_probes_are_isolated`, `test_route_d_bridge_and_dock_share_the_same_walkable_height` (patrol cue D: chưa thấy test riêng) |
| TC-ZD-24…26, B25…B28 | ZD-24…26 | `test_flow_confirmed_ground_drop_left_behind_appears_in_s10_lost_group` |
| TC-ZD-27…29, B29…B32 | ZD-27…29, 36…38 | `test_flow_zone_d_death_resolves_s11_without_extract`, `test_flow_death_before_manifest_prepares_and_hold_and_boat_ready_deaths_never_extract`, `test_flow_recall_sigil_absorbs_back_and_touch_until_completion`, `test_ui_death_before_manifest_hides_empty_kept_and_prepares`, `test_ui_death_lock_and_recall_use_foreground_process_time` |
| TC-ZD-30…34, B33…B39 | ZD-30…37 | `test_ui_death_after_manifest_has_three_groups_and_boot_only`, `test_flow_zone_d_death_resolves_s11_without_extract`, `test_ui_death_uses_the_specified_three_and_two_column_rectangles`, `test_ui_death_hides_short_scroll_cues_and_scrolls_focused_column` |
| TC-ZD-35, G04, G07 | ZDU-44 | `test_ui_death_uses_the_specified_three_and_two_column_rectangles` (một phần) |

## 14. Mẫu bug report

Dùng đúng [mẫu ở plan vòng A §10](loop-a-early-extract-test-plan.md), cùng khung S03, thêm dòng đặc thù S04:

```text
Build channel: staging (web-staging itch.io) / production   Version: <tên pre-release staging hoặc tag production>
Thiết bị / trình duyệt / đầu vào: chuột | cảm ứng   Tỉ lệ khung: 16:9 | 4:3 | 21:9 | 640×360
Case id: TC-ZD-xx / TC-ZD-Bxx / TC-ZD-Gxx / TC-ZD-Zx bước n
Fixture đã dựng (cách chơi tự nhiên, danh sách Hộp/ba lô/túi/đất trước khi lỗi):
Bước tái hiện:
Kết quả mong đợi (trích ZD-xx / ZDU-xx hoặc gate):
Kết quả thực tế (kèm ảnh trước/sau hoặc video; với patrol ghi thời gian cue → vào khung):
Nhóm S11/S10 nếu liên quan (Đã giữ / Đã mất / Vật chứng): quan sát được gì
Severity: BLOCKER / MUST_FIX / MINOR
Tái hiện: n/m lần cùng build
```

Severity gợi ý (readiness §6, §9): **BLOCKER** = cargo/gear/container niêm được, auto-swap/drop/sort/seal, action phá run một
chạm hoặc gọi thuyền không O5, confirmation không có Hủy (G9/G10/G11); dead-end bắt buộc chết, extract/teleport ở D, địch spawn
sau lưng (G12); S10 chấm điểm hoặc hồi đồ đã bỏ (G15); Manifest biến mất/hiện completion/thành success sau death, sealed
non-evidence bị mô tả mất, không có đồ không niêm để chứng minh mất, Manifest ở `Đã giữ` hoặc về hub (G16/G17); death thành S10.
**MUST_FIX** = thiếu/sai key chữ, cue chỉ bằng màu, vùng chạm < 96 px / chữ < 24 px, sai thứ tự card, lý do từ chối sai,
cue patrol < 2 giây. **MINOR** = lỗi trình bày không đổi state. Dừng phiên khi trúng BLOCKER: tái hiện một lần, mở một card
(readiness §9).

## 15. Phiếu kết quả gate S04 (DoD)

Ghi `READY` / `NOT READY` / `BLOCKER` / `KHÔNG TEST ĐƯỢC` theo [build-readiness](../vertical-slice-build-readiness.md) §9. Mỗi
gate `READY` chỉ khi mọi case của nó đạt trên bản web-staging và các Z liên quan đạt.

| Gate | Case phải đạt | Z liên quan | Z-M | Z-T | Build (channel + version) | Trạng thái |
|---|---|---|---|---|---|---|
| G9 | TC-ZD-01…06, B01…B05, G01, G02 | Z1, Z2, Z3 | | | | |
| G10 | TC-ZD-07…11, B06…B09, G03 | Z2, Z5 | | | | |
| G11 | TC-ZD-12…18, B10…B20, G04 (đổi gear: không áp dụng) | Z2, Z6 | | | | |
| G12 | TC-ZD-19…23, B21…B24, G05 | Z1, Z2, Z3 | | | | |
| G15 | TC-ZD-24…26, B25…B28, G06 | Z1, Z2, Z3 | | | | |
| G16 | TC-ZD-27…29, B29…B32, G07 | Z4 | | | | |
| G17 | TC-ZD-30…34, B33…B39, G08 | Z5, Z6, Z7 | | | | |
| DoD | TC-ZD-Z1…Z7, R1, R2, TC-ZD-35, 36 | — | | | | |

Truy vết gate → nguồn:

| Gate | Spec chính | Case |
|---|---|---|
| G9 | luật §3, §4.1, §4.5 (ZD-01…09); UX §4.2–§4.4 (ZDU-01…10) | TC-ZD-01…06, B01…B05, G01, G02 |
| G10 | luật §4.3, §4.4 (ZD-06, 10…13); UX §4.3, §4.6 (ZDU-11…13) | TC-ZD-07…11, B06…B09, G03 |
| G11 | luật §5 (ZD-12…23); UX §4.5, §4.6 (ZDU-14…31) | TC-ZD-12…18, B10…B20, G04 |
| G12 | layout §2, §5, §9; UX §5 (ZDU-43) | TC-ZD-19…23, B21…B24, G05 |
| G15 | luật §8 (ZD-24…26); UX §4.9 (ZDU-41, 42) | TC-ZD-24…26, B25…B28, G06 |
| G16 | luật §7, §9.1 (ZD-27…29, 36…38); UX §4.7, §4.8 (ZDU-32…40) | TC-ZD-27…29, B29…B32, G07 |
| G17 | luật §7, §9.2 (ZD-30…37); UX §4.8 | TC-ZD-30…34, B33…B39, G08 |

Playtest: khi chạy phiên có người chơi, dùng nguyên [phiếu quan sát](../playtest-observation-sheet.md) và các mã đã có (**P3/P8c** cho
combat lane B, **P7** cho cue); **không thêm metric mới**. Các điểm chờ playtest của spec S04 (O5i che nửa trái thế giới; S11
ẩn `Đã giữ` khi rỗng; khóa nút S11 1.0 s sau O7 2.5 s) chỉ ghi quan sát bằng phiếu hiện có. Các phiên có người chơi là card riêng.

## 16. Phần đưa cho test-engineer (follow-up, chưa làm)

1. Thêm test headless đặt tên `test_zd_01…39_*` ánh xạ `ZD-xx` và đối chiếu từng assert với §13 (hiện chưa có test `zd_`).
2. Test đo độ dài chữ S04 so với giới hạn UX §9.1 (handoff TASK-98: độ dài đếm tay); hai chuỗi sát giới hạn: 72/72, 24/24.
3. Test cue patrol từ `PatrolTriggerB` (đi thẳng 2.75 s, chéo 2.30 s, dash liên tiếp 1.85 s) và "không bắn khi đi D" (chưa thấy test riêng).
4. Test `RECALL_SIGIL_SECONDS` = 2.5 s, khóa nút O5i 0.3 s, khóa nút S11 1.0 s theo giờ nền (đã có test O7/S11 một phần, xem §13).
5. Case chỉ tay có thể thêm ảnh chụp thang xám tự động cho hai card D và S11 (cần card art/look-dev riêng).

## 17. Quyết định, ghi chú còn mở và ngoài phạm vi

**Ghi chú (không chặn):**
- Đổi gear / vào không vũ khí **không áp dụng ở slice** (spec §5.6): chỉ kiểm vắng mặt (TC-ZD-18).
- `SUMMARY_DEATH_GROUP_EVIDENCE_UNRECOVERED` ('Vật chứng — chưa thu hồi') là key thêm ngoài UX §9.1 (TASK-98); UX §4.8.2 còn ghi
  `SUMMARY_GROUP_EVIDENCE`. Case TC-ZD-30 chấp nhận cả hai tiêu đề; nếu chữ khác cả hai, ghi MUST_FIX và hỏi producer/ui-programmer.
- Lore câu mới của Dấu Thuế chưa qua lore-reviewer; case TC-ZD-02 chỉ kiểm "đúng một dòng", không đánh giá nội dung.
- Cue patrol khi dash liên tiếp ≈ 1.85 s (< 2.0 s) là câu hỏi mở layout §10.3: nếu QA đo thấy, ghi nhận MUST_FIX kèm số đo, không tự kết luận.
- S10/S11 "Đã giữ" không mang sang run sau (slice không có kho hub/save): người test **không** kỳ vọng ngược lại.
- Dòng `SUMMARY_DEATH_LOST_EQUIPPED` đúng canon nhưng run sau vẫn có kit starter: theo dõi ở playtest, không phải lỗi.
- Vì không có lưu tiến trình, mọi nhóm "save/load" chỉ kiểm không file mới và run sau sạch.

**KHÔNG test ở S04 (ngoài phạm vi):** G18 / Recovery Contract / S12 / tự thu hồi Manifest sau chết (C3) · âm thanh (Phù Hiệu
im lặng theo quyết định, thiếu audio không phải lỗi) · Android / APK (phase 1 là staging APK sideload, case riêng) · khu C/E ·
Contract 2 chơi được (chỉ nhãn state-only) · extract ở D · weight/slow penalty · giá tiền/economy · đổi gear · lưu/tải tiến trình ·
cân bằng số (HP, đòn, giá trị) · viết test tự động · chạy phiên playtest thật.
