# Spec UX — S04: card cargo/Dấu Thuế ở Kho Nổi D, Hộp trong run (rút/bỏ qua O5), khoảnh khắc Phù Hiệu, S11 ba nhóm, S10 full-route

**Trạng thái:** spec UX `proposed` cho ui-programmer (TASK-100, TASK-101), narrative (TASK-98: chữ theo bảng §9) và
QA. Mọi toạ độ, kích thước, thời lượng, key mới và tên cue âm thanh/rung đều `proposed` tới khi playtest. Spec này
**không** đổi luật. Luật item, Hộp, O5, chết và summary nằm ở [spec luật S04](zone-d-cargo-notary-death-spec.md) (gọi tắt
"luật S04"). Vị trí trong thế giới nằm ở [layout D](zone-d-layout-encounter-spec.md). Spec này chỉ nói người chơi thấy gì,
chạm vào đâu, và chuyện gì xảy ra.

**Nguồn:** [UX khu B](zone-b-ux-spec.md) (khung §3, lưới §4, card §5.4, D1 §5.6, O6 §5.7) · [UX vòng A](loop-a-ux-flow-spec.md)
(§3.2, O5 §5.7, S10 §5.9) · [wireflow](../vertical-slice-wireflow.md) O3, O4, O5, S10, S11 ·
[build-readiness](../vertical-slice-build-readiness.md) G9–G11, G15–G17, invariant §8.4–§8.8 ·
[D cargo brief](../maps/black-tax-port-d-cargo-choice-brief.md) §3.1, §6 · [chữ Contract 1](contract-1-strings.md) §1, S04 ·
code hiện có trong `game/src/ui/` (`confirm/confirm_dialog.gd`, `summary/extract_summary_screen.gd`, `pickup/loot_cache_panel.gd`,
`common/inventory_grid_widget.gd`). Tên riêng theo `memory/glossary.md` của studio.

## 1. Mục tiêu người chơi và gate phục vụ

**Mục tiêu người chơi:** ở Kho Nổi D, Người Thu Hồi so hai món bằng footprint, tổng và theo ô rồi tự chọn mang gì; tự rút
hay bỏ đồ khi Hộp Công Chứng hoặc ba lô hết chỗ, và luôn thấy trước hậu quả; khi chết, biết ngay vì sao run dừng, món nào
được giữ, món nào mất và Manifest đang ở đâu.

| Gate | Phần của spec phục vụ |
|---|---|
| G9 — S5 D cargo choice: card tổng/ô, ba outcome về B | §4.1, §4.2, §5.1 |
| G10 — Hộp: không auto-swap, Hộp đầy giữ món nguồn, tự rút, nhãn `đã niêm — chưa extract` | §4.3, §4.4 |
| G11 — O5 đúng chỗ: bỏ đồ, rút đồ niêm có preview + xác nhận/hủy; không O5 thừa | §4.5, §4.6 |
| G15 — S10 full-route: ô đã dùng, `Đã mất` có đồ đã bỏ, không chấm điểm | §4.9 |
| G16 — S11 trước Manifest | §4.7, §4.8 |
| G17 — S11 sau Manifest, ba nhóm | §4.7, §4.8 |
| Invariant §8.4–§8.8 — cue ngoài màu, không auto, HUD đọc được khi overlay mở, summary tách nhóm | §3.2, §4.6, §4.8 |

G18 (S12 Recovery) **không** thuộc spec này: S11 sau Manifest chỉ có một nút về Boot (luật S04, quyết định 3).

## 2. Bản đồ luồng

### 2.1 Sơ đồ (chỉ phần mới hoặc đổi so với UX khu B)

```text
HUD in-run (S2…S9) ── H1 objective · H2 máu · H5 cảnh báo · C1–C4 · H3 Đồ mang theo · R5' nút ngữ cảnh
  │
  ├─ trong 1.5 m quanh CargoD / TaxStampD / GroundDrop (nguồn gần nhất còn món) ──▶ R5' ──chạm──▶ O2D card (1 món)
  │     O2D ──[Bỏ qua]──▶ card nguồn gần kế tiếp | đóng nếu không còn        (không đổi state)
  │     O2D ──[Đóng] / Back / ra ngoài tầm / chạm D1──▶ HUD                   (không đổi state)
  │     O2D ──[Nhặt và xếp]──▶ O3D pickup (lưới dock, như O3B)
  │        O3D ──nhấc ngón trên ô hợp lệ──▶ commit_pickup ok ──▶ HUD + toast (nguồn D chỉ có 1 món)
  │        O3D ──nhấc ngón trên ô sai / Hộp không niêm được / Hộp không đủ chỗ──▶ O3D + lý do + gợi ý (món ở nguồn)
  │        O3D ──[Đóng] / Back──▶ O2D ;  ra ngoài tầm / D1 ──▶ HUD
  │
  ├─ H3 ──▶ O3D view (ba lô + Hộp, như O3B view)
  │     chọn món ở ba lô ──[Bỏ]──▶ O5i drop ──[Bỏ xuống]──▶ commit_drop ──▶ view + toast + GroundDrop dưới chân
  │                                         └─[Hủy] / Back──▶ view, món vẫn được chọn (không đổi)
  │     chọn món ở Hộp ──[Rút] (hoặc chạm thẳng ô ba lô)──▶ chọn ô ba lô ──nhấc ngón ô hợp lệ──▶ O5i withdraw
  │                                         O5i ──[Rút ra]──▶ commit_withdraw ──▶ view + toast, món hết niêm
  │                                         O5i ──[Hủy] / Back──▶ view, món vẫn ở Hộp (không đổi)
  │     chọn món niêm được ở ba lô ──chạm ô Hộp hợp lệ──▶ commit_seal (KHÔNG O5)
  │                                 ──chạm ô Hộp sai──▶ lý do + gợi ý "tự rút một món" (món ở ba lô)
  │     O5i ──chạm D1──▶ đóng O5i như Hủy **và** đóng dock ──▶ HUD
  │
  └─ HP về 0 (bất kỳ đâu, kể cả khi O2D/O3D/O5i/O5 gọi thuyền mở) ──▶ mọi overlay đóng như hủy
        ──▶ O7 khoảnh khắc Phù Hiệu (2.5 s, không chạm được) ──▶ S11
              S11 before_manifest ──[Chuẩn bị lại]──▶ S1 (Contract 1, run mới)
              S11 after_manifest  ──[Về màn đầu]──▶ Boot

S9 ──[Lên thuyền]──▶ S10 (rút sớm hay full-route: cùng một màn) ──[Về hub]──▶ Boot
```

O2D và O3D là **cùng một dock R10** của UX khu B (O2B/O3B): cùng thành phần, khác nguồn món. O5i là O5 của inventory
(`inventory_confirm`, luật S04 §5); O5 gọi thuyền không đổi.

### 2.2 Lối vào/ra, hủy và thử lại

| Màn / overlay | Vào từ | Ra (tiến) | Hủy / Back (một chạm) | Lỗi → thử lại |
|---|---|---|---|---|
| O2D card D | R5' trong tầm nguồn | `Nhặt và xếp` → O3D pickup | `Đóng` (R3) / Back / D1 / ra ngoài tầm → HUD | — |
| O3D pickup | O2D | ô hợp lệ → HUD + toast | `Đóng` / Back → O2D; D1 / ra ngoài tầm → HUD | Ô sai: lý do + gợi ý, món ở nguồn; thả ngón ở ô khác, hoặc `Đóng` rồi dọn chỗ ở `view`. |
| O3D view | H3 | — | `Đóng` / Back / D1 → HUD | Ô sai: lý do, món giữ chỗ cũ. |
| O5i drop | `Bỏ` trên món ở ba lô | `Bỏ xuống` → view | `Hủy` / Back → view; D1 → HUD | Commit fail: O5i đóng, lý do ở dải S, không đổi. |
| O5i withdraw | Nhấc ngón trên ô ba lô hợp lệ khi món Hộp đang chọn | `Rút ra` → view | `Hủy` / Back → view; D1 → HUD | Preview fail: **không** mở O5i, lý do + ô chặn. Commit fail: như drop. |
| O7 Phù Hiệu | `Health.depleted` | tự sang S11 sau 2.5 s | không có (chạm, Back bị bỏ qua) | — |
| S11 | O7 | nút → S1 hoặc Boot | Back = nút (sau khi nút bật) | Lỗi tải scene: `UI_ERROR_SCENE_LOAD`, nút bật lại. |
| S10 | S9 `Lên thuyền` | `Về hub` → Boot | Back = `Về hub` | như UX vòng A §5.9. |

### 2.3 Bước bị bỏ, gộp hoặc dời so với S03

| Ở S03 | Việc nó làm cho người chơi | Ở S04 việc đó nằm ở đâu |
|---|---|---|
| O6 stub HP 0 (`COMBAT_STUB_HP_ZERO` + nút `Về màn đầu` khóa 2.5 s) | (a) nói run dừng vì hết máu; (b) chặn ngón cái đang dồn ở C1/C2 bấm nhầm; (c) nói không có gì được lưu; (d) cho về màn đầu | (a) O7 một dòng + tiêu đề S11 `SUMMARY_DEATH_TITLE`; (b) O7 2.5 s không nhận chạm + nút S11 khóa thêm 1.0 s ở chỗ khác hẳn C1/C2 (§4.8); (c) S11 nêu chính xác giữ/mất/vật chứng thay cho câu chung "không lưu"; (d) nút S11. |
| `INVENTORY_REASON_WITHDRAW_LOCKED` (Hộp → ba lô gạch chéo) | Báo niêm là quyết định cho cả run | Rút mở bằng O5i (§4.5). Câu niêm đổi sang `INVENTORY_PREVIEW_SEAL_NOTARY_BOX` (nói rút lại cần xác nhận), vì câu cũ "chưa rút ra lại được" sai từ S04. |
| `INVENTORY_PREVIEW_FITS_NOTARY_BOX` | Cảnh báo trước khi nhấc ngón vào Hộp | Thay bằng key mới cùng chỗ (dải S dòng 2); key cũ giữ, không hiện (§9.3). |
| Dòng túi đeo chéo chỉ-đọc 1056–1248 × 616–680 | Thấy còn bao nhiêu thuốc khi C4 bị dock che | Dời xuống 1024–1248 × 672–704 (một dòng) để nhường chỗ nút `Bỏ`/`Rút` và dải trạng thái Hộp (§3.1). Nội dung không đổi. |
| Nút `Xoay` 1056–1248 × 504–600 (192×96) | Đổi hướng chờ của món | Dời vào hàng R10g-A, 1024–1128 × 568–664 (104×96, vẫn ≥ 96), cạnh `Bỏ`/`Rút`. Luật xoay không đổi (UX khu B §4.3). |
| Tag `INVENTORY_PICKUP_SOURCE_CACHE` ("còn ở rương") | Cho biết món chưa nhặt | Ở D dùng `INVENTORY_PICKUP_SOURCE_D`; với đồ đã bỏ dùng `INVENTORY_PICKUP_SOURCE_GROUND`. D không có rương. |

Không bước nào của S03 bị bỏ mà không có chỗ mới. O5i là bước **thêm** (G11), chỉ cho hai action ở luật S04 §5.1.

## 3. Khung màn hình và quy tắc chung

### 3.1 Vùng mới hoặc đổi (1280×720 tham chiếu)

Mọi vùng khác giữ nguyên UX khu B §3.1 (R1, H2, H5, D1, R2, R3, W2', T, R4', R5', R6, C, R10c, R10g).

| Mã | Vùng | Toạ độ | Neo | Dùng cho |
|---|---|---|---|---|
| R10g-E | Dải trạng thái Hộp | 1024–1248 × 496–560 | phải | Dưới lưới Hộp: nhãn Manifest `đã niêm — chưa extract`, hoặc nhãn "không niêm được" khi đang cầm cargo (§4.3). Chỉ đọc, không chạm. |
| R10g-A | Hàng nút món | 1024–1248 × 568–664 | phải | `Xoay` 1024–1128 (104×96) · `Bỏ` **hoặc** `Rút` 1144–1248 (104×96). Khoảng giữa 16 px. |
| R10g-P | Túi đeo chéo (chỉ đọc) | 1024–1248 × 672–704 | phải | icon túi + tên vật hồi phục + `×{quantity}` (dời từ 616–680). |
| O5i | Xác nhận inventory | 312–608 × 184–576 (296×392) | trên-trái, sát D1 | §4.6. Nằm **bên trái** dock để dock thật vẫn hiện bóng đích. |
| O7 | Khoảnh khắc Phù Hiệu | 0–1280 × 0–720 (lớp chặn), nội dung 368–912 × 248–472 | giữa | §4.7. |
| S11 | Death summary | toàn màn | — | §4.8. |

Lưới Hộp vẫn 1056–1248 × 296–488 và lưới ba lô vẫn 720–1008 × 296–680 (UX khu B §4.1). Hàng R10g-A bắt đầu ở x 1024 (cách
lưới ba lô 16 px).

**Vì sao O5i không ở R9 như O5 gọi thuyền:** O5i cần cho thấy **ô đích thật** trong lưới (luật S04 §5.1). Nếu O5i nằm giữa
màn (R9 368–912), nó che cột 0–1 của ba lô. Ở 312–608, O5i không che dock, R1, H2, H5, D1 (16–304), R4' (y ≥ 592) hay
joystick R6 (x ≤ 276, y ≥ 444). Nó che một phần nửa trái thế giới, giống R9. Nút xác nhận của O5i (x 472–592) không nằm
trên nút `Bỏ`/`Rút` (x 1144–1248) hay bất kỳ ô lưới nào, nên chạm đúp không thể xác nhận nhầm (cùng nguyên tắc UX vòng A
§5.7.2).

### 3.2 Quy tắc chạm, chữ và kênh ngoài màu (áp dụng mọi phần tử mới của S04)

1. Vùng chạm mới ≥ 96×96 px tham chiếu (48 dp ở 640×360), khoảng trống giữa hai nút ≥ 16 px (UX khu B §3.2.1).
2. Chữ mới ≥ 24 px tham chiếu; số trên card ≥ 28 px. Không chữ nào dưới 20 px. Không nhấp nháy: nhấn mạnh là **một** lần
   phóng to/đổi viền, tối đa 1 lần/giây.
3. Chạm = xuống và nhấc trong cùng vùng, di chuyển < 16 px (UX vòng A §3.2.2). Ô lưới theo UX khu B §4.2 (bóng khi đè,
   commit khi nhấc, trượt ≥ 16 px = hủy).
4. `UI_OPEN_GUARD_SECONDS = 0.3` cho O2D, O3D, O5i, S11 và S10. O7 không nhận chạm nên không cần.
5. Mỗi trạng thái có ít nhất một kênh ngoài màu: icon, hình, chữ, vị trí hoặc chuyển động một lần (G7, invariant §8.4).
6. Back (Android) / Esc (web) = nút hủy/đóng của lớp trên cùng. Ở O7 bỏ qua. Ở S11 = nút chính, chỉ sau khi nút bật.
7. Tay cầm/bàn phím (bài học TASK-79): mọi màn toàn màn hình (S10, S11) có **một focus owner** ngay khi mở;
   `ui_accept` trên nút đang focus = chạm; danh sách tràn thì cuộn được bằng cả kéo dọc và `ui_up`/`ui_down`.
8. Cue âm thanh/rung chỉ là **tên** cho sau (S04 không có âm thanh). Cue mới: `ui_drop_confirm_open`,
   `ui_withdraw_confirm_open`, `ui_drop_ok`, `ui_withdraw_ok`, `ui_unseal`, `recall_sigil_start`, `summary_death_open`.
   Rung: dùng lại `haptic_light`, `haptic_warn`, `haptic_success`; không rung trong O7.

## 4. Từng màn, overlay và phần tử

### 4.1 R5' nút ngữ cảnh ở D và đồ dưới đất

Bổ sung bảng UX khu B §5.1.2 (thứ tự ưu tiên từ trên xuống, lấy dòng đầu đúng):

| Điều kiện | Nhãn | Chạm → |
|---|---|---|
| `can_board()` / `can_call()` / bàn dispatch / `CacheB` | như UX khu B §5.1.2 | như cũ |
| Trong 1.5 m quanh `CargoD`, nguồn còn món | icon kiện hàng vuông + `WORLD_INTERACT_CARGO_D` | O2D card `cargo_d_2x2` |
| Trong 1.5 m quanh `TaxStampD`, nguồn còn món | icon con dấu dẹt + `WORLD_INTERACT_TAX_STAMP_D` | O2D card `tax_stamp_d` |
| Trong 1.5 m quanh một `GroundDrop` | icon món + mũi tên lên + `WORLD_INTERACT_GROUND_DROP` | O2D card của món đó |
| còn lại, S8, có overlay mở, O7, S11 | ẩn | — |

1. Nhiều nguồn/`GroundDrop` trong cùng tầm: R5' trỏ tới cái có tâm gần nhất; hòa thì `uid` nhỏ trước (luật S04 §5.4.4).
   Icon trên R5' đổi theo đúng món đó, để người chơi biết sẽ mở món nào.
2. Không tự kích hoạt khi bước vào vòng. Nguồn `empty` không hiện R5' (khối `ItemBlock` đã ẩn, layout D §4).
3. D không có prompt, marker hay chữ nào trong thế giới (layout D §9.1). Mọi chữ ở HUD.

### 4.2 O2D — Card món ở D và đồ dưới đất (dock R10c, như O2B)

**Mục đích:** đọc một món theo đúng thứ tự D brief §3.1 rồi chọn `Nhặt và xếp`, `Bỏ qua` hay `Đóng`. Mở, xem, bỏ qua và
đóng không đổi state (luật S04 §4.5).

Dùng lại nguyên bố cục O2B (UX khu B §5.4), với các điểm khác:

| Phần tử (trên xuống) | Toạ độ / cỡ | Nội dung / dữ liệu | Key |
|---|---|---|---|
| Dải chip món | 720–1248 × 128–224 | **Một chip** (nguồn D có 1 món), 256×96: silhouette + sơ đồ ô + `{w}×{h}`. Vẫn hiện để giữ chỗ nhìn quen. | `INVENTORY_FOOTPRINT_CHIP` |
| Dòng 1 — silhouette + tên | dưới chip | `display_name_key` | `CARD_<ID>_NAME` |
| Dòng 2 — footprint + ô trống | 2 hàng | Hàng a: sơ đồ ô `w×h` (ô có viền) + `CARD_<ID>_FOOTPRINT` + tag có icon. Hàng b: icon ba lô + `CARD_BACKPACK_FREE` + icon kết quả `fit_backpack`; icon Hộp + icon kết quả `fit_notary_box` + chữ. | `CARD_TAG_*`, `CARD_FIT_*` |
| Dòng 3 — công dụng + giá trị | 2 hàng | Hàng a: `CARD_<ID>_USE`. Hàng b: **hai ô số** cạnh nhau (§4.2.1). | `CARD_VALUE_TOTAL`, `CARD_VALUE_PER_CELL` |
| Dòng 4 — claim | 1 hàng | icon phe `house_hac_thue` + tên phe | `CARD_<ID>_CLAIM` |
| Dòng 5 — lớp thẩm định | 1 hàng | 6 dấu con dấu: 1 đặc + 5 rỗng (Trắng) + chữ lớp | `CARD_<ID>_RARITY` |
| Dòng 6 — lore | ≤ 2 hàng | — | `CARD_<ID>_LORE` |
| `Bỏ qua` / `Nhặt và xếp` / `Đóng` | như O2B | — | `CARD_ACTION_SKIP`, `CARD_ACTION_PICK_AND_PLACE`, `CARD_ACTION_CLOSE` |

`<ID>` = `CARGO_D_2X2` hoặc `TAX_STAMP_D`. Với `GroundDrop`, card là card của chính món đó (vd. `CARD_SCRAPED_TAX_COIN_*`,
Manifest dùng card O2 của S02) và dải S của O3D mang tag `INVENTORY_PICKUP_SOURCE_GROUND`.

#### 4.2.1 Dòng giá trị (G9, luật S04 §3.3)

1. Chỉ hiện khi `relative_value_total > 0` (trong slice: hai món D). Món khác không có hàng b của dòng 3, kể cả khi nằm
   dưới đất.
2. Hai ô số, mỗi ô ≥ 200×56: ô trái **icon khối nhiều ô** + chữ `CARD_VALUE_TOTAL` (`{value_total}`); ô phải **icon một ô**
   + chữ `CARD_VALUE_PER_CELL` (`{value_per_cell}`). Số ≥ 28 px.
3. Dạng **số + nhãn chữ**, không vạch, không sao, không thanh so sánh. Vạch dài/ngắn sẽ đọc như điểm hay xếp hạng; spec
   không muốn card nói món nào "tốt hơn". Không ký hiệu tiền, không chữ "giá bán".
4. `{value_per_cell}` = `relative_value_total / (w × h)`: số nguyên thì không có phần thập phân; còn lại một chữ số thập
   phân, dấu phẩy kiểu Việt (vd. `2,5`). Slice cho cargo `8` / `2`, Dấu Thuế `6` / `3`.
5. Hai món cùng lớp Trắng: dòng 5 giống hệt nhau. Đây là chủ ý (luật S04 §3.2.4): người chơi so dòng 2 và dòng 3.

#### 4.2.2 Hai card ở D

| Hàng | `cargo_d_2x2` (Vải Cứu Trợ Đổi Nhãn) | `tax_stamp_d` (Dấu Thuế) |
|---|---|---|
| Chip | sơ đồ 2×2 + `2×2` | sơ đồ 1×2 đứng + `1×2` |
| Dòng 2a tag | không tag xoay (vuông); **không** `CARD_TAG_SEALABLE` | `CARD_TAG_ROTATABLE`, `CARD_TAG_SEALABLE` |
| Dòng 2b ba lô | `fits` nếu còn khối 2×2; `no_fit` nếu không | `fits` / `fits_rotated_only` / `no_fit` |
| Dòng 2b Hộp | **luôn** icon ổ khóa gạch chéo + `CARD_FIT_NOTARY_BOX_NOT_SEALABLE` | `fits` / `no_fit` (icon × + `CARD_FIT_NOTARY_BOX_NO_FIT`) với Hộp có thuốc + Manifest |
| Dòng 3b | `8` · `2` | `6` · `3` |
| Dòng 4 | icon phe + Hắc Thuế | icon phe + Hắc Thuế |
| Dòng 5 | 1 đặc / 5 rỗng + chữ Trắng | 1 đặc / 5 rỗng + chữ Trắng |

**Không im lặng về Hộp:** với cargo, ô "Hộp" ở dòng 2b **không bao giờ ẩn** và luôn có lý do bằng hình + chữ. Nút
`Nhặt và xếp` vẫn bật khi ba lô vừa; nếu ba lô cũng `no_fit`, nút vẫn bật (người chơi vào lưới sẽ thấy lý do và gợi ý
§4.3.3), vì luật không có lối tắt nào khác và card không được chặn quyền xem lưới.

| Trạng thái | Người chơi thấy |
|---|---|
| Mặc định | 1 chip, card đủ 6 dòng, hai nút. |
| Ba lô không đủ chỗ | Dòng 2b ba lô icon × + `CARD_FIT_BACKPACK_NO_FIT`. |
| Hộp không đủ chỗ (Dấu Thuế) | Dòng 2b Hộp icon × + `CARD_FIT_NOTARY_BOX_NO_FIT`. |
| Đồ dưới đất | Card của món đó, không có dòng 3b (trừ hai món D). |
| Bị gián đoạn | Card giữ nguyên khi trở lại; chặn chạm 0.3 s lại. |
| Có nguy hiểm | D1 (UX khu B §5.6). D không có địch; patrol B có thể tới gần lối D. |
| Chết giữa action | Dock đóng như `Đóng`; O7. |

### 4.3 O3D — Lưới trong dock ở S04 (pickup từ D/đồ dưới đất, và view)

Dùng lại nguyên quy tắc chọn → preview → đặt và xoay của UX khu B §4.2–§4.3. Phần dưới chỉ ghi điểm khác.

#### 4.3.1 Đích được phép ở S04 (thay bảng UX khu B §4.3)

| Nguồn → đích | `pickup` (nguồn D / `GroundDrop`) | `view` (trong run) |
|---|---|---|
| Nguồn → ba lô | `commit_pickup(item, backpack, a, pending_rotated)` | — |
| Nguồn → Hộp | `commit_pickup(item, notary_box, a, r)` = niêm, **không** O5i | — |
| Trong cùng lưới (di chuyển, xoay) | — | `commit_move`, không O5i |
| Ba lô → Hộp | — | `commit_seal`, **không** O5i |
| Hộp → ba lô | — | `preview_withdraw` khi đè; nhấc ngón trên ô hợp lệ → **mở O5i withdraw** (không commit) |
| Ba lô → đất | — | nút `Bỏ` → O5i drop |
| → túi đeo chéo | không có đích | không có đích |

#### 4.3.2 Dải S dòng 2 (thay/bổ sung bảng UX khu B §4.4)

| Trạng thái | Dòng 2 | Key |
|---|---|---|
| `pickup` ở D, chưa chạm | hướng dẫn nhặt | `INVENTORY_PICKUP_HINT_ITEM` (dùng lại) |
| Ngón đè ô ba lô hợp lệ | preview ba lô | `INVENTORY_PREVIEW_FITS_BACKPACK` (dùng lại) |
| Ngón đè ô Hộp hợp lệ | preview niêm (rút lại cần xác nhận) | `INVENTORY_PREVIEW_SEAL_NOTARY_BOX` (mới) |
| Món Hộp đang chọn, ngón đè ô ba lô hợp lệ | preview rút | `INVENTORY_PREVIEW_WITHDRAW_BACKPACK` (mới) |
| Sau khi chạm `Rút` | chọn ô ba lô | `INVENTORY_WITHDRAW_PICK_CELL_HINT` (mới) |
| Ngón đè/vừa nhấc ô sai | `{item}` · lý do | `INVENTORY_REASON_*` |
| `view`, Manifest đang mang, chưa chọn | nhắc niêm | `PROMPT_SAFEBOX_SEAL_HINT` (như S03) |

Tag nguồn ở dòng 1: nguồn D = `INVENTORY_PICKUP_SOURCE_D`; `GroundDrop` = `INVENTORY_PICKUP_SOURCE_GROUND`.

#### 4.3.3 Khi không có chỗ: lý do, ô chặn và gợi ý (không có nút "đổi chỗ")

| Tình huống | Lưới hiện | Dải S dòng 2 | R4' toast (một lần mỗi lần mở dock cho món đó) |
|---|---|---|---|
| Cargo, ngón đè bất kỳ ô Hộp (kể cả Hộp trống) | Mọi ô Hộp đã có **ổ khóa gạch chéo** từ lúc vào `pickup`; bóng footprint gạch chéo + icon khóa | `{item}` · `INVENTORY_REASON_NOT_SEALABLE` | — |
| Cargo đang cầm (cả lúc chưa chạm) | R10g-E hiện icon ổ khóa gạch chéo + `CARD_FIT_NOTARY_BOX_NOT_SEALABLE` (thay nhãn Manifest trong lúc cầm cargo) | — | — |
| Cargo, ba lô không còn khối 2×2 | Mọi anchor ba lô gạch chéo; ô chặn có icon × khi đè | `{item}` · `INVENTORY_REASON_CELLS_OCCUPIED` / `_OUT_OF_BOUNDS` | `INVENTORY_HINT_BACKPACK_MAKE_ROOM` |
| Dấu Thuế → Hộp có thuốc 1x2 + Manifest (luật S04 §4.3) | Ô Hộp gạch chéo; ô chặn (thuốc hoặc Manifest) có icon × | `{item}` · `INVENTORY_REASON_CELLS_OCCUPIED` / `_OUT_OF_BOUNDS` | `INVENTORY_HINT_NOTARY_BOX_MAKE_ROOM` |

Quy tắc:

1. Món nguồn **giữ nguyên** (ở nguồn D, ở ô ba lô cũ, hay dưới đất); thuốc và Manifest không rời Hộp; không signal.
2. Gợi ý chỉ là **chữ**: nói người chơi tự rút một món khỏi Hộp (ở `Đồ mang theo`) rồi niêm lại, hoặc tự dời/bỏ một món ở
   ba lô. Không có nút "đổi chỗ", "rút giúp", "đặt vào chỗ gợi ý" hay "bỏ món này để lấy món kia". Toast không chọn hộ món
   nào để rút.
3. Gợi ý Hộp chỉ hiện sau khi người chơi **đã thử** một ô Hộp và bị từ chối (nhấc ngón trên ô sai), không hiện trước. Gợi ý
   ba lô hiện khi vào `pickup` cargo mà không còn anchor ba lô hợp lệ nào.
4. Đường hợp lệ (luật S04 §4.4) ở `pickup` từ nguồn D: `Nhặt và xếp` Dấu Thuế vào ba lô → H3 → chọn thuốc (hoặc Manifest)
   trong Hộp → rút qua O5i → chọn Dấu Thuế → chạm ô Hộp (không O5i). Hoặc: `Đóng`, rút ở `view`, rồi quay lại nguồn và
   nhặt thẳng vào Hộp.

#### 4.3.4 Nhãn trong Hộp và R10g-E (G10)

1. Mỗi món trong Hộp có **icon dấu niêm** trên ô (hình, không chỉ màu). Manifest thêm **badge vật chứng** như S02.
2. **Nhãn Manifest luôn thấy:** khi Manifest nằm trong Hộp, R10g-E hiện badge vật chứng + `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED`
   (tối đa 2 dòng, 24 px), ở mọi chế độ của dock (`pickup`, `view`, đang chọn món khác, đang mở O5i). Ô 96 px không đủ chỗ
   cho 22 ký tự, nên chữ nằm ở R10g-E thay vì trong ô; ô Manifest có thêm một **mấu nối** hướng xuống R10g-E để biết nhãn
   thuộc món nào.
3. Ngoại lệ duy nhất: khi đang cầm cargo, R10g-E nói "không niêm được" (§4.3.3). Nhãn Manifest quay lại ngay khi thả cargo
   hoặc rời `pickup`. Trong lúc đó ô Manifest vẫn có badge vật chứng + icon dấu niêm.
4. Manifest không ở Hộp → R10g-E trống (trừ ngoại lệ trên).
5. Món vừa rút: icon dấu niêm biến mất bằng một lần thu nhỏ (cue `ui_unseal`); ô ba lô mới không có icon niêm.

#### 4.3.5 Hàng nút món R10g-A

| Món đang chọn | Nút trái (1024–1128) | Nút phải (1144–1248) |
|---|---|---|
| Không chọn | trống | trống |
| Món ở ba lô, xoay được, không vuông | `Xoay` | `Bỏ` |
| Món ở ba lô, vuông hoặc không xoay được (cargo, Manifest, đồng xu) | trống | `Bỏ` |
| Món ở Hộp | `Xoay` (nếu xoay được; chỉ đổi hướng chờ cho lần rút/di chuyển) | `Rút` |
| `pickup` (món nguồn) | `Xoay` nếu xoay được | **trống** (không có `Bỏ` cho món chưa nhặt) |
| Túi đeo chéo | không chọn được | — |

1. `Bỏ`: icon tay thả + mũi tên xuống + `INVENTORY_BUTTON_DROP`. Chạm → gọi `preview_drop(uid)`; `ok` → mở O5i drop (§4.6).
   Fail → dải S dòng 2 `{item}` · lý do; không mở O5i.
2. `Rút`: icon mũi tên ra khỏi ổ khóa + `INVENTORY_BUTTON_WITHDRAW`. Chạm → nút vào trạng thái "đang chọn chỗ" (viền dày +
   icon ngón trỏ), dấu anchor **chỉ** vẽ ở ba lô (theo `preview_withdraw` với `pending_rotated`), dải S dòng 2
   `INVENTORY_WITHDRAW_PICK_CELL_HINT`. Chạm `Rút` lần nữa hoặc chạm lại món = thoát, không đổi gì.
3. Không cần `Rút`: khi món Hộp đang chọn, chạm thẳng một ô ba lô cũng đi đúng đường đó (luật S04 §4.4 bước 2). `Rút`
   là lối dễ thấy, không phải bước bắt buộc.
4. Ô ba lô hợp lệ khi rút: ngón đè → bóng khung liền + `INVENTORY_PREVIEW_WITHDRAW_BACKPACK`; nhấc trong ô → **mở O5i
   withdraw** với đúng `anchor`/`pending_rotated` đó. Không commit trước khi xác nhận.
5. Không anchor ba lô nào hợp lệ (ba lô đầy): `Rút` vẫn hiện nhưng có **gạch chéo + icon khóa**; chạm → mọi ô ba lô gạch
   chéo, dải S dòng 2 `{item}` · `INVENTORY_REASON_CELLS_OCCUPIED`; món giữ icon niêm. Không mở O5i (ZD-18).
6. Không có nút `Bỏ` trên món trong Hộp; bỏ một món đang niêm = rút (O5i) rồi bỏ (O5i). Không có "bỏ tất cả".

| Trạng thái `view` S04 | Người chơi thấy |
|---|---|
| Mặc định (đầu run) | Ba lô trống; Hộp: Cuộn Băng Muối (icon niêm); R10g-E trống; R10g-A trống; R10g-P thuốc `×1`. |
| Manifest trong Hộp | Ô Manifest: badge vật chứng + icon niêm + mấu; R10g-E nhãn `đã niêm — chưa extract`. |
| Món ba lô được chọn | Viền dày + icon chọn; `Bỏ` hiện (và `Xoay` nếu có). |
| Món Hộp được chọn | `Rút` hiện; anchor ba lô và Hộp được đánh dấu. |
| Đang chọn chỗ rút | `Rút` viền dày; chỉ anchor ba lô; hint. |
| Ba lô đầy khi rút | `Rút` gạch chéo + khóa; lý do khi chạm. |
| Lỗi | Lý do ở dải S; món giữ chỗ cũ, vẫn được chọn. |
| Bị gián đoạn | Lựa chọn, chế độ "đang chọn chỗ" và `pending_rotated` bị bỏ; bóng xóa; không commit. |
| Có nguy hiểm | D1. |
| Chết giữa action | Dock đóng như hủy; O7. |

### 4.4 Ba outcome ở D (G9) — người chơi thấy gì

| Outcome | Khi rời D | Sau đó |
|---|---|---|
| Mang cargo | Toast `CARD_PLACED_CONFIRM_BACKPACK`; ba lô 4 ô bị chiếm (thấy ở `view`). | Không đổi tốc độ, không icon "nặng", không chữ cảnh báo nào trên HUD. |
| Lấy Dấu Thuế (ba lô hoặc Hộp) | Toast `CARD_PLACED_CONFIRM_BACKPACK` / `_NOTARY_BOX`. | Không chữ khen. |
| Bỏ cả hai | Không toast, không câu trách. | Nguồn vẫn còn món; R5' vẫn hiện khi quay lại tầm. |

H1 không đổi theo lựa chọn ở D (§5.1).

### 4.5 Rút đồ niêm và bỏ đồ — tóm tắt cử chỉ (G11)

| Action | Cử chỉ | O5i | Không O5i |
|---|---|---|---|
| Bỏ món ở ba lô | chọn món → `Bỏ` | `drop` | — |
| Rút món ở Hộp | chọn món → (`Rút`) → chạm ô ba lô hợp lệ | `withdraw` | — |
| Niêm từ ba lô vào Hộp | chọn món → chạm ô Hộp | — | ✓ |
| Nhặt từ nguồn D / `GroundDrop` vào ba lô hoặc Hộp | `Nhặt và xếp` → chạm ô | — | ✓ |
| Di chuyển, xoay, xem card, đổi chip, `Bỏ qua`, `Đóng`, D1, preview, chọn/bỏ chọn | — | — | ✓ |

Luật S04 §5.3: thêm O5i cho bất kỳ dòng "Không O5i" nào là lỗi G11.

### 4.6 O5i — Xác nhận bỏ / rút (312–608 × 184–576)

**Mục đích:** cho thấy đúng món, đúng chỗ đích và hậu quả trước khi commit; một chạm để hủy.

| Phần tử | Toạ độ | Drop (`kind = drop`) | Withdraw (`kind = withdraw`) |
|---|---|---|---|
| Tiêu đề | 328–592 × 196–260 (≤ 2 dòng, 28 px) | `INVENTORY_CONFIRM_DROP_TITLE` | `INVENTORY_CONFIRM_WITHDRAW_TITLE` |
| Hàng món | 328–592 × 264–304 | silhouette + tên + `×{quantity}` nếu > 1 + chip `{w}×{h}` | như drop |
| Hàng đích | 328–592 × 308–348 | icon chân + mũi tên xuống + `INVENTORY_CONFIRM_TARGET_GROUND` | icon ba lô + `INVENTORY_CONFIRM_TARGET_BACKPACK` |
| Hàng nhãn đổi (chỉ withdraw) | trong hàng đích, dòng 2 | — | chip `INVENTORY_SEAL_LABEL_SEALED` (gạch ngang) → chip `INVENTORY_SEAL_LABEL_UNSEALED`; Manifest: chip `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED` → badge vật chứng + `INVENTORY_SEAL_LABEL_NOT_EXTRACTED` |
| Thân (hậu quả) | 328–592 × 352–464 (≤ 4 dòng, 24 px) | `INVENTORY_CONFIRM_DROP_BODY`; Manifest: `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` + icon đèn phao gạch chéo; ở S8 thêm `INVENTORY_CONFIRM_DROP_EVIDENCE_S8_NOTE`, ở S9 thêm `_S9_NOTE` | `INVENTORY_CONFIRM_WITHDRAW_BODY`; Manifest: `INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY` |
| `Hủy` | 328–456 × 472–568 (128×96) | `CONFIRM_BUTTON_CANCEL` | `CONFIRM_BUTTON_CANCEL` |
| Nút xác nhận | 472–592 × 472–568 (120×96), icon riêng | `INVENTORY_CONFIRM_DROP_ACCEPT` (icon tay thả) | `INVENTORY_CONFIRM_WITHDRAW_ACCEPT` (icon ổ khóa mở) |

**Bóng đích trong dock thật (preview):** khi O5i mở, dock vẫn hiện nhưng không nhận chạm.

- Drop: các ô của món trong ba lô có **viền nét đứt + icon mũi tên xuống** (sẽ trống). Không có bóng nào trong Hộp.
- Withdraw: ô nguồn trong Hộp có **viền nét đứt + icon ổ khóa mở**; footprint đích trong ba lô có **khung liền dày + icon
  mũi tên vào** (đúng `anchor`/`rotated` của preview). Chữ ở hàng đích nói cùng điều đó, nên ai không nhìn được dock
  vẫn biết.

Quy tắc:

1. Mở O5i: dock khóa input, H3/R5' ẩn (như O5 gọi thuyền), C1–C4 vẫn ẩn (dock đang mở). `set_overlay_open(true)` giữ nguyên.
   Cue `ui_drop_confirm_open` / `ui_withdraw_confirm_open`, chưa rung.
2. Chặn chạm 0.3 s sau khi hiện (`confirm_dialog.gd` đã có). Nút xác nhận tự khóa sau chạm đầu tới khi commit trả về.
3. Xác nhận → `commit_drop(uid)` hoặc `commit_withdraw(uid, anchor, rotated)` với **đúng** tham số đã preview.
   - `ok`: O5i đóng; dock về `view`, bỏ chọn món; R4' toast `CARD_PLACED_CONFIRM_DROPPED` hoặc
     `CARD_PLACED_CONFIRM_WITHDRAWN` 3 s; cue `ui_drop_ok` / `ui_withdraw_ok`, `haptic_success`. Drop: `GroundDrop` hiện dưới
     chân nhân vật (bên trái dock, không bị che).
   - Drop Manifest `ok`: thêm H1 đổi sang `HUD_OBJECTIVE_PICK_UP_MANIFEST` (một lần trượt chữ), W2' về E0.
   - Fail (state đổi giữa chừng): O5i đóng; dock về `view` với món **vẫn được chọn**, dải S `{item}` · lý do mới; không đổi;
     cue `ui_invalid`, `haptic_warn`.
4. `Hủy` / Back → không commit; O5i đóng; dock về `view` với món **vẫn được chọn** (drop) hoặc món Hộp vẫn chọn, thoát
   "đang chọn chỗ" (withdraw). Cue `ui_cancel`.
5. Chạm ra ngoài O5i: không hủy, không xác nhận (như UX vòng A §5.7.4).
6. D1 hiện khi `danger_near` (UX khu B §5.6). Chạm D1 = `Hủy` **và** đóng dock → HUD, để một chạm là phản ứng được.
7. O5i không dừng thế giới; bị đánh không đóng O5i; H2 vẫn mất đoạn. Rời D hay rời vùng không đóng O5i (luật S04 §5.5.4).
8. Khi O5i mở: `Gọi thuyền` không dùng được (R5' ẩn). Khi O5 gọi thuyền mở: H3 ẩn nên không mở được dock/O5i.

| Trạng thái O5i | Người chơi thấy |
|---|---|
| Xác nhận (mặc định) | Tiêu đề, hàng món, hàng đích (+ nhãn đổi), thân, hai nút; bóng đích trong dock. |
| Manifest | Thân vật chứng + icon đèn phao gạch chéo (drop) / badge vật chứng (withdraw). |
| Manifest ở S8/S9 (drop) | Thêm dòng S8/S9 note. |
| Đang chờ commit | Nút xác nhận khóa (một khung hình). |
| Lỗi | O5i đóng, lý do ở dải S. |
| Bị gián đoạn | Giữ nguyên khi trở lại; chặn chạm 0.3 s lại; không tự xác nhận hay hủy. |
| Có nguy hiểm | D1 bên trái O5i. |
| Chết giữa action | Đóng như `Hủy` (luật S04 §5.5.3, D6); không `GroundDrop` mới; O7. |

### 4.7 O7 — Khoảnh khắc Phù Hiệu Hồi Hương (thay O6 stub)

**Mục đích:** cho biết ngay run dừng vì Phù Hiệu Hồi Hương kích hoạt (không phải extract), và cho mắt người chơi một nhịp
trước khi đọc S11; chặn ngón cái đang bấm dồn.

Thứ tự từ `Health.depleted` (luật S04 §7.1):

| t | Chuyện xảy ra | Người chơi thấy |
|---|---|---|
| 0 (cùng frame) | Mọi overlay đóng **như hủy**: O2D/O3D không commit, O5i không commit, O5 gọi thuyền không `confirm_call`. Khiên hạ, kênh thuốc hủy, bộ đệm input xóa, joystick khóa. | Dock/O5 biến mất; C1–C4, R5', H3, D1, H5, R2, W2' ẩn. H1 ẩn. H2 còn `0/{max_hp}` (đoạn cuối mất như thường). |
| 0 | Lớp chặn toàn màn hiện; O7 hiện. | Thế giới vẫn thấy phía sau, **làm tối một mức cố định** (không nhấp nháy, không đổi dần nhiều lần). Ở giữa: **dấu Phù Hiệu** (hình riêng, không phải icon thuyền hay ổ khóa) với **một vòng** lấp dần 0 → 1 trong `RECALL_SIGIL_SECONDS`, và một dòng `RECALL_SIGIL_MOMENT_LINE` dưới dấu. |
| 0–2.5 s | Không thêm sát thương, không input. Chạm, Back, phím bị bỏ qua. | Vòng lấp đều. Không âm thanh (S04 im lặng; tên cue cho sau: `recall_sigil_start`). Không rung thêm (đòn cuối đã có `haptic_hit`). |
| 2.5 s | S11 mở (chuyển cảnh một lần, không nhấp nháy). | S11 §4.8. |

Quy tắc:

1. `RECALL_SIGIL_SECONDS = 2.5` `proposed` (luật S04 §7.1.5). Đồng hồ chỉ đếm khi app ở tiền cảnh; vòng dừng khi ở nền và
   chạy tiếp khi trở lại.
2. O7 không có nút. Nó không phải màn đọc; dòng chữ ≤ 48 ký tự để đọc được trong 2.5 s.
3. O7 không bao giờ dùng chữ, icon hay bố cục của S7–S10 (banner thuyền, `Lên thuyền`, `SUMMARY_SUCCESS_*`).
4. `COMBAT_STUB_HP_ZERO`, `COMBAT_STUB_BUTTON_BOOT` và màn O6 không còn hiện (ZD-38).

### 4.8 S11 — Death summary (toàn màn)

**Mục đích:** đọc được trong một lần nhìn: món nào được giữ, món nào mất và vì sao, Manifest đang ở đâu, Contract 1 còn
hay không, rồi đi tiếp bằng **một** nút.

#### 4.8.1 Bố cục (khác hẳn S10)

| Phần tử | Toạ độ | Nội dung | Key / dữ liệu |
|---|---|---|---|
| Dải tiêu đề | 32–1248 × 24–96 | **dấu Phù Hiệu** (cùng hình O7) bên trái + tiêu đề, căn trái | `SUMMARY_DEATH_TITLE` |
| Cột `Đã giữ` | slot 1 | icon dấu niêm ở tiêu đề nhóm | §4.8.2 |
| Cột `Đã mất` | slot 2 | icon túi mở gạch chéo ở tiêu đề nhóm | §4.8.2 |
| Cột `Vật chứng` | slot 3 | badge vật chứng ở tiêu đề nhóm | §4.8.2 |
| Dòng thu hồi (chỉ `after_manifest`, tùy TASK-98) | 32–1248 × 552–592, căn giữa | icon khóa + chữ | `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` |
| Nút duy nhất | **giữa-dưới** 440–840 × 608–704 (400×96) | xem §4.8.4 | `SUMMARY_DEATH_BUTTON_PREPARE` / `SUMMARY_DEATH_BUTTON_BOOT` |
| Dòng trạng thái nút | trong nút (thay icon) | `UI_LOADING` / `UI_ERROR_SCENE_LOAD` | — |

Slot cột: ba cột 32–416, 448–832, 864–1248 × 112–544 (mỗi cột 384×432). Khi `Đã giữ` ẩn (§4.8.3): hai cột 32–624 và
656–1248, vẫn theo thứ tự `Đã mất` → `Vật chứng`.

**S11 khác S10 ở mọi kênh, không chỉ màu:** S10 có hai cột (trái `Đã giữ`/`Đã mất`, phải `Vật chứng`/`Tiếp theo`), câu
của Người Thu Hồi già và nút `Về hub` ở dưới-phải. S11 có **ba nhóm ngang hàng**, dấu Phù Hiệu ở tiêu đề, **không** có nhóm
`Tiếp theo`, **không** có câu mentor, nút ở **giữa-dưới** với chữ khác. S11 không dùng `ExtractSummary`,
`extract_succeeded` hay `extract_summary_screen.gd`; nó đọc `DeathSummary` (luật S04 §7.4). ui-programmer có thể dùng chung
helper vẽ nhóm/cuộn, nhưng scene và tên node riêng (`DeathSummaryScreen`).

#### 4.8.2 Nội dung từng nhóm (thứ tự dòng trong cột, trên xuống)

| Nhóm | Dòng | Key / dữ liệu | Kênh ngoài màu |
|---|---|---|---|
| `Đã giữ` | tiêu đề | `SUMMARY_GROUP_KEPT` | icon dấu niêm |
| | câu nhóm | `SUMMARY_DEATH_KEPT_SEALED` | — |
| | mỗi `uid` trong `kept` (theo uid) | silhouette + tên item + icon dấu niêm | icon niêm trên từng dòng |
| `Đã mất` | tiêu đề | `SUMMARY_GROUP_LOST` | icon túi mở gạch chéo |
| | phân nhóm a (nếu có `lost_reason = unsealed`) | `SUMMARY_DEATH_LOST_UNSEALED`, rồi mỗi món: silhouette + tên + **icon ổ khóa mở** | icon ổ khóa mở |
| | phân nhóm b (nếu có `left_behind`) | `SUMMARY_DEATH_LOST_LEFT_BEHIND`, rồi mỗi món: silhouette + tên + **icon mũi tên xuống đất** | icon mũi tên xuống |
| | dòng trang bị (luôn, `equipped_gear_lost`) | icon kiếm + khiên + `SUMMARY_DEATH_LOST_EQUIPPED` | icon kiếm + khiên |
| `Vật chứng` | tiêu đề | `SUMMARY_GROUP_EVIDENCE` | badge vật chứng |
| | `before_manifest` | badge + `SUMMARY_DEATH_EVIDENCE_AT_DESK` (Manifest ở bàn dispatch A, Contract 1 còn hiệu lực) | icon bàn |
| | `after_manifest` | badge + `SUMMARY_DEATH_EVIDENCE_UNRECOVERED` + tag `chưa thu hồi` dạng **dấu hỏi trong khung** | tag hình |
| | luôn | `SUMMARY_DEATH_NOT_EXTRACTED` | icon thuyền **gạch chéo** |

1. Mỗi uid một dòng; không gộp; không số lượng tổng, không giá trị, không `relative_value_*`, không điểm, route hay thời gian.
2. Manifest **không bao giờ** nằm ở `Đã giữ` hay `Đã mất`, kể cả khi nó ở Hộp lúc chết (D3) hay đang dưới đất (D4).
3. Tên item lấy từ `ITEM_*_NAME` / `display_name_key`; không ghép câu trong code.

#### 4.8.3 Nhóm rỗng

| Nhóm | Khi rỗng | Vì sao |
|---|---|---|
| `Đã giữ` | **Ẩn cả cột** (tiêu đề lẫn khung); hai cột còn lại chia đôi màn | Luật S04 §7.3 (`proposed`), khớp S10 "ẩn nếu rỗng". Không hiện "không có gì" để tránh đọc như lời trách. |
| `Đã mất` phân nhóm a / b | Ẩn phân nhóm đó (câu nhóm + danh sách) | Không có dòng rỗng. |
| `Đã mất` | Không bao giờ rỗng (dòng trang bị luôn có) | Chứng minh "đồ không niêm mất" (G16, G17). |
| `Vật chứng` | Không bao giờ rỗng | Luôn có vị trí Manifest + `NOT_EXTRACTED`. |

#### 4.8.4 Nút, thời gian khóa, cuộn và focus

| Biến thể | Nút | Đi tới | Dòng thu hồi |
|---|---|---|---|
| `before_manifest` | icon vòng quay lại + `SUMMARY_DEATH_BUTTON_PREPARE` | S1 Contract 1, loadout mặc định, run mới | không |
| `after_manifest` | icon cửa + `SUMMARY_DEATH_BUTTON_BOOT` | scene Boot | `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` (nếu TASK-98 viết) |

1. **Khóa nút:** `SUMMARY_DEATH_BUTTON_LOCK_SECONDS = 1.0` `proposed` sau khi S11 hiện (gồm cả 0.3 s chặn chung). Trong lúc
   khóa: icon khóa + **vòng tiến độ** lấp 0 → 1 trên nút; chạm, Back, `ui_accept` bị bỏ qua. Lý do: O7 đã cho 2.5 s không
   chạm, nên 1.0 s đủ để ngón vừa nhấc khỏi C1/C2 không đi tiếp ngay; nút ở giữa-dưới, xa C1/C2 (x ≥ 960).
   Đồng hồ chỉ đếm ở tiền cảnh.
2. Sau khóa: icon khóa đổi sang icon của nút (một lần phóng to). Chạm / Back / `ui_accept` khi nút có focus → chuyển
   scene; nút tự khóa sau chạm đầu, hiện `UI_LOADING`. Lỗi tải → `UI_ERROR_SCENE_LOAD`, nút bật lại.
3. **Cuộn:** mỗi cột là một vùng cuộn dọc riêng (`ScrollContainer`, tắt cuộn ngang), cao 432 px. Tràn → ở đáy cột hiện
   **mũi tên xuống trong khung** (icon, không chỉ màu) tới khi cuộn hết; kéo dọc trong cột = cuộn, không phải action. Cột
   không bao giờ đè dòng thu hồi hay nút. Tràn xảy ra khi `Đã mất` có nhiều món (vd. full-route rồi chết: cargo, Dấu
   Thuế, đồng xu, Sổ Kho, thuốc, dòng trang bị).
4. **Focus (bài học TASK-79):** khi S11 dựng xong, nút nhận focus (`grab_focus`) dù đang khóa. Thứ tự `ui_focus_next` /
   `ui_right`: nút → cột `Đã giữ` (nếu hiện) → `Đã mất` → `Vật chứng` → nút. Cột đang focus có **viền dày**; `ui_up` /
   `ui_down` cuộn cột đó. `ui_accept` chỉ có tác dụng trên nút. Chạm/chuột không đổi focus của cột.
5. S11 không lưu gì (`user://` không có file mới). `Đã giữ` **không** mang sang run sau; chữ không được hứa điều đó (luật
   S04 §14, câu hỏi 1).

| Trạng thái S11 | Người chơi thấy |
|---|---|
| `before_manifest` (G16) | Ba cột; `Vật chứng` = Manifest ở bàn A; nút `Chuẩn bị lại`. |
| `after_manifest` (G17) | Ba cột; `Vật chứng` = chưa thu hồi; dòng thu hồi; nút về màn đầu. |
| `Đã giữ` rỗng | Hai cột. |
| Tràn | Mũi tên "còn nữa" ở đáy cột; cuộn được. |
| 0–1.0 s | Nút khóa + vòng tiến độ. |
| Đang chờ | `UI_LOADING`. |
| Lỗi | `UI_ERROR_SCENE_LOAD`, nút bật lại. |
| Bị gián đoạn | Không đổi; đồng hồ khóa dừng ở nền. |

### 4.9 S10 sau full-route (G15)

S10 giữ nguyên bố cục, focus và cuộn của UX vòng A §5.9 + TASK-79. Rút sớm và full-route dùng **cùng** màn, **cùng** tập
key; chỉ danh sách khác (luật S04 §8).

1. **`Đã giữ`**: mỗi uid một dòng: silhouette + tên + **chip footprint `{w}×{h}`** (sơ đồ ô + chữ, dùng
   `INVENTORY_FOOTPRINT_CHIP`) để người chơi hiểu số ô. Dòng cuối `SUMMARY_SUCCESS_KEPT_CELLS` (`{used}/{total}`, cargo tính 4).
   Thứ tự: `SUMMARY_SUCCESS_KEPT_LICENCE` → món theo uid → dòng ô.
2. **`Đã mất`**: hiện khi `lost` không rỗng, giữa `Đã giữ` và `Vật chứng` (đã có trong code). Mỗi món: silhouette + tên +
   icon mũi tên xuống đất + `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`. Món nhặt lại trước khi lên thuyền không ở đây. Món tiêu hết
   không ở đâu cả.
3. **Không thêm:** điểm, xếp hạng, sao, "full-route", tổng giá trị, giá trị/ô, thời gian, route đã đi hay câu khen chọn đúng.
   Dòng 3b của card D không bao giờ xuất hiện ở S10.

### 4.10 Interrupted và chết giữa action — bảng gộp

| Đang làm | App xuống nền rồi trở lại | HP về 0 |
|---|---|---|
| O2D card | Card giữ nguyên; chặn 0.3 s | Dock đóng; món ở nguồn không ở `lost` (D7) |
| O3D pickup, ngón đang đè | Bóng xóa, không commit; món vẫn ở nguồn | Không commit (D7) |
| O3D view, "đang chọn chỗ rút" | Thoát chế độ, bỏ chọn | Dock đóng; món vẫn ở Hộp → `kept` |
| O5i drop | Giữ nguyên; chặn 0.3 s | Đóng như hủy; món còn ở ba lô → `lost` `unsealed` (ZD-22) |
| O5i withdraw | Giữ nguyên; chặn 0.3 s | Đóng như hủy; món còn ở Hộp → `kept` (D6) |
| O7 | Vòng tiến độ dừng | — (đã chết) |
| S11 | Không đổi; đồng hồ khóa dừng | — |

## 5. HUD objective ở D và đường về

### 5.1 H1 (thay bảng UX khu B §5.1.1, lấy dòng đầu đúng)

| # | Điều kiện | Key |
|---|---|---|
| 1 | S7 / S8 / S9 | như UX vòng A §5.8 |
| 2 | `encounter_b_engaged` và `GateB` chưa mở | `HUD_OBJECTIVE_CROSS_TAX_POST` |
| 3 | `contract_state == DROPPED` | `HUD_OBJECTIVE_PICK_UP_MANIFEST` |
| 4 | `desk_state == HAS_MANIFEST` | `HUD_OBJECTIVE_TAKE_MANIFEST` |
| 5 | còn lại (đang mang Manifest) | `HUD_OBJECTIVE_DELIVER_PIER_A` |

1. **Ở D và trên đường D → B → A dùng lại `HUD_OBJECTIVE_DELIVER_PIER_A`**; không thêm key. Câu đó đã đúng ở mọi chỗ: D là
   nhánh tùy chọn, đích vẫn là Cầu tàu A. Thêm objective riêng cho D sẽ biến D thành bước bắt buộc hoặc "đáp án" (G9).
2. Không có mũi tên chỉ đường, marker hay khoảng cách trên HUD. Đường về đọc bằng landmark (layout D §5.3: lanh tô đỏ son
   của lối D, `SignToA`, `GateB`).
3. Chết trước Manifest ở B/D: H1 là `HUD_OBJECTIVE_TAKE_MANIFEST` (dòng 4) — vẫn đúng.
4. Patrol B trên đường về: H5 `HUD_ALERT_PATROL_B` (UX khu B §5.2), H1 không đổi.

## 6. Bảng tương tác

| Phần tử | Cử chỉ | Kết quả | Phản hồi (hình · cue · rung) | Hoàn tác |
|---|---|---|---|---|
| R5' ở nguồn D / `GroundDrop` | chạm | O2D card | dock trượt vào · `ui_tap` | `Đóng` |
| `Bỏ qua` (O2D) | chạm | card nguồn gần kế / đóng | card trượt · `ui_cancel` | mở lại |
| `Nhặt và xếp` | chạm | O3D pickup | lưới thay card · `ui_tap` | `Đóng` → card |
| Ô Hộp khi cầm cargo | chạm xuống / nhấc | không đổi; lý do `NOT_SEALABLE` | gạch chéo + icon khóa · `ui_preview_bad` / `ui_invalid` · `haptic_warn` | — |
| Ô Hộp hợp lệ (niêm) | nhấc ngón trong ô | `commit_pickup`/`commit_seal`, không O5i | icon niêm hiện · `ui_seal_ok` · `haptic_success` | rút lại qua O5i |
| Ô Hộp không đủ chỗ | nhấc ngón | không đổi; lý do + toast gợi ý | icon × ở ô chặn · `ui_invalid` · `haptic_warn` | — |
| Món ở ba lô (`view`) | chạm | chọn; `Bỏ` hiện | viền dày · `ui_tap` | chạm lại |
| `Bỏ` | chạm | O5i drop (nếu `preview_drop` ok) | O5i hiện, bóng nét đứt · `ui_drop_confirm_open` | `Hủy` |
| Món ở Hộp (`view`) | chạm | chọn; `Rút` hiện | viền dày · `ui_tap` | chạm lại |
| `Rút` | chạm | chế độ chọn chỗ (chỉ anchor ba lô) | viền dày + icon ngón · `ui_tap` | chạm `Rút` lại |
| `Rút` khi ba lô đầy | chạm | không đổi; lý do | gạch chéo · `ui_invalid` · `haptic_warn` | — |
| Ô ba lô hợp lệ (món Hộp chọn) | chạm xuống / nhấc | bóng + preview / mở O5i withdraw | khung liền · `ui_preview_ok` / `ui_withdraw_confirm_open` | `Hủy` |
| O5i `Bỏ xuống` / `Rút ra` | chạm (sau 0.3 s) | commit | toast · `ui_drop_ok`/`ui_withdraw_ok` · `haptic_success` | drop: nhặt lại `GroundDrop`; withdraw: niêm lại (không O5i) |
| O5i `Hủy` / Back | chạm | đóng, không commit | O5i biến mất · `ui_cancel` | mở lại |
| Ngoài O5i | chạm | không gì | — | — |
| D1 khi O5i mở | chạm | hủy O5i + đóng dock → HUD | `ui_cancel` | mở lại |
| O7 | chạm / Back | không gì | — | — |
| Cột S11 | kéo dọc / `ui_up`·`ui_down` khi focus | cuộn | mũi tên "còn nữa" ẩn khi tới đáy | — |
| Nút S11 (sau 1.0 s) / Back | chạm | S1 hoặc Boot | `UI_LOADING` · `ui_tap` | không (không lưu) |
| Chip footprint S10 | — | chỉ đọc | — | — |

## 7. Dữ liệu đọc bởi UI

| Phần tử | Field / signal |
|---|---|
| R5' ở D | khoảng cách tới `CargoD`/`TaxStampD`/`GroundDrop` ≤ 1.5 m, `cache_state` của nguồn, `uid` của `GroundDrop` |
| O2D | `ItemDef` (`size`, `rotatable`, `sealable`, `claim_id`, `appraisal_class`, `display_name_key`, `relative_value_total`), `relative_value_per_cell()`, `fit_backpack`, `fit_notary_box`, `backpack.free_cell_count()` |
| O3D | `preview_pickup` / `preview_move` / `preview_seal` / `preview_withdraw` / `preview_drop` → `ok`, `reason`, `blocking_cells`; `seal_label(uid)`; `ItemInstance.cells()`, `rotated`, `item_category` |
| R10g-E | Manifest có trong `notary_box` không (`seal_label == sealed_not_extracted`); món đang cầm có `sealable == false` không |
| O5i | `inventory_confirm` (`kind`, `uid`, `anchor`, `rotated`), `item_category == EVIDENCE`, `extract_state` (S8/S9 note); `commit_drop` / `commit_withdraw` → `ok`, `reason`, `moved` |
| H1 | `extract_state`, `contract_state`, `desk_state`, encounter B, `GateB` |
| O7 | `Health.depleted`, `RECALL_SIGIL_SECONDS` |
| S11 | `DeathSummary.kept`, `.lost[].lost_reason`, `.equipped_gear_lost`, `.unrecovered_evidence`, `.death_variant`, `SUMMARY_DEATH_BUTTON_LOCK_SECONDS` |
| S10 | `ExtractSummary.kept`, `.lost`, `.backpack_cells_used`, `.backpack_cells_total`, `ItemDef.size` cho chip |

## 8. Thông báo cho ui-programmer (TASK-100/101)

1. Dùng lại `confirm_dialog.gd` cho O5i nếu nó nhận được rect, hàng món/đích và nút có icon; nếu không, tạo
   `InventoryConfirmPanel` riêng nhưng giữ `UI_OPEN_GUARD_SECONDS` và khóa sau chạm đầu. O5 gọi thuyền giữ R9.
2. S11 là scene riêng (`DeathSummaryScreen`), không phải `extract_summary_screen.gd` với cờ. Tên node gợi ý cho test:
   `KeptScroll`, `LostScroll`, `EvidenceScroll`, `PrimaryButton`, `RecoveryLine`.
3. Lưới và card: thêm vào `inventory_grid_widget.gd` / `loot_cache_panel.gd`; không fork bản D.

## 9. Bảng key chữ (giao TASK-98)

Quy ước `SCREEN_CONTEXT_PURPOSE` của [chữ Contract 1](contract-1-strings.md) §1. Spec chỉ ghi **ý cần nói**, chưa viết câu.
Placeholder mới: `{value_total}`, `{value_per_cell}` (§4.2.1). Mọi key mới `proposed`.

### 9.1 Key mới

| Key | Nơi hiện | Ý cần nói | Placeholder | Tối đa |
|---|---|---|---|---:|
| `ITEM_CARGO_D_2X2_NAME` | ô lưới, dải S, toast, S10, S11 | Vải Cứu Trợ Đổi Nhãn | — | 24 |
| `ITEM_TAX_STAMP_D_NAME` | như trên | Dấu Thuế | — | 24 |
| `CARD_CARGO_D_2X2_NAME` | O2D dòng 1 | tên #11 | — | 24 |
| `CARD_CARGO_D_2X2_FOOTPRINT` | O2D dòng 2a | 4 ô, vuông | — | 24 |
| `CARD_CARGO_D_2X2_USE` | O2D dòng 3a | cồng kềnh, tổng cao, theo ô thấp, không niêm được (luật S04 §3.3.4) | — | 64 |
| `CARD_CARGO_D_2X2_CLAIM` | O2D dòng 4 | Hắc Thuế có claim (không phải lệnh tịch thu) | — | 32 |
| `CARD_CARGO_D_2X2_RARITY` | O2D dòng 5 | lớp 1/6 (Trắng) bằng chữ | — | 32 |
| `CARD_CARGO_D_2X2_LORE` | O2D dòng 6 | nhãn thuế dán chồng lên chữ cứu trợ; phía dân bến | — | 64 |
| `CARD_TAX_STAMP_D_NAME` … `_LORE` (6 key) | O2D dòng 1–6 | Dấu Thuế; 2 ô, xoay được; gọn, theo ô cao hơn, niêm được; Hắc Thuế; Trắng; dấu để trên bàn cân (không nối Counterseal) | — | 24 / 24 / 64 / 32 / 32 / 64 |
| `CARD_VALUE_TOTAL` | O2D dòng 3b, ô trái | Tổng ước lượng: `{value_total}` (không tiền) | `{value_total}` | 24 |
| `CARD_VALUE_PER_CELL` | O2D dòng 3b, ô phải | Theo ô: `{value_per_cell}` | `{value_per_cell}` | 24 |
| `WORLD_INTERACT_CARGO_D` | R5' | Xem kiện vải | — | 24 |
| `WORLD_INTERACT_TAX_STAMP_D` | R5' | Xem dấu thuế | — | 24 |
| `WORLD_INTERACT_GROUND_DROP` | R5' | Xem món dưới đất | — | 24 |
| `INVENTORY_PICKUP_SOURCE_D` | dải S tag, `pickup` ở D | còn ở Kho Nổi, chưa nhặt | — | 24 |
| `INVENTORY_PICKUP_SOURCE_GROUND` | dải S tag, `pickup` từ `GroundDrop` | dưới đất, chưa nhặt lại | — | 24 |
| `INVENTORY_PREVIEW_SEAL_NOTARY_BOX` | dải S dòng 2, đè ô Hộp hợp lệ | Vừa; nhấc ngón để niêm; rút ra lại cần xác nhận | — | 72 |
| `INVENTORY_PREVIEW_WITHDRAW_BACKPACK` | dải S dòng 2, đè ô ba lô khi rút | Vừa; nhấc ngón để xem xác nhận rút vào ô này | — | 72 |
| `INVENTORY_WITHDRAW_PICK_CELL_HINT` | dải S dòng 2 sau `Rút` | Chạm ô ba lô có dấu vừa để chọn chỗ rút | — | 72 |
| `INVENTORY_HINT_NOTARY_BOX_MAKE_ROOM` | R4' toast sau khi Hộp từ chối | Hộp không đủ chỗ; tự rút một món ra ba lô (Đồ mang theo) rồi niêm lại | — | 72 |
| `INVENTORY_HINT_BACKPACK_MAKE_ROOM` | R4' toast khi ba lô không có chỗ | Ba lô không đủ chỗ; tự dời hoặc bỏ một món (Đồ mang theo) rồi nhặt lại | — | 72 |
| `INVENTORY_BUTTON_DROP` | R10g-A | Bỏ | — | 24 |
| `INVENTORY_BUTTON_WITHDRAW` | R10g-A | Rút | — | 24 |
| `INVENTORY_CONFIRM_TARGET_GROUND` | O5i hàng đích (drop) | Xuống đất, chỗ bạn đứng | — | 32 |
| `INVENTORY_CONFIRM_TARGET_BACKPACK` | O5i hàng đích (withdraw) | Vào ba lô, ô có khung | — | 32 |
| `INVENTORY_SEAL_LABEL_UNSEALED` | O5i nhãn đổi | không niêm | — | 24 |
| `INVENTORY_SEAL_LABEL_NOT_EXTRACTED` | O5i nhãn đổi (Manifest) | chưa extract (vẫn là vật chứng) | — | 24 |
| `INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY` | O5i thân, rút Manifest | Manifest vẫn là vật chứng chưa extract, vẫn gọi được thuyền; không mất vĩnh viễn nhưng cũng chưa hoàn thành gì (luật S04 §5.2) | — | 90 |
| `INVENTORY_CONFIRM_DROP_EVIDENCE_S8_NOTE` | O5i dòng thêm, bỏ Manifest ở S8 | Đồng hồ giữ khu dừng tới khi nhặt lại | — | 72 |
| `INVENTORY_CONFIRM_DROP_EVIDENCE_S9_NOTE` | O5i dòng thêm, bỏ Manifest ở S9 | Chưa lên thuyền được tới khi nhặt lại | — | 72 |
| `CARD_PLACED_CONFIRM_DROPPED` | R4' toast sau drop | `{item}` nằm dưới đất, nhặt lại được | `{item}` | 72 |
| `CARD_PLACED_CONFIRM_WITHDRAWN` | R4' toast sau withdraw | `{item}` đã vào ba lô, không còn niêm | `{item}` | 72 |
| `RECALL_SIGIL_MOMENT_LINE` | O7 | Phù Hiệu Hồi Hương kéo bạn về (không nhắc giữ/mất) | — | 48 |
| `SUMMARY_DEATH_LOST_LEFT_BEHIND` | S11 `Đã mất` phân nhóm b | Đồ đã bỏ xuống đất, chưa nhặt lại | — | 72 |
| `SUMMARY_DEATH_LOST_EQUIPPED` | S11 `Đã mất` dòng trang bị | Vũ khí và khiên đang mang (không niêm) | — | 72 |
| `SUMMARY_DEATH_BUTTON_BOOT` | S11 nút `after_manifest` | Về màn đầu | — | 24 |
| `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` | S11 dòng thu hồi (tùy chọn) | Thu hồi Manifest chưa có trong vertical slice; không hứa hồi đồ hay thời điểm | — | 72 |

### 9.2 Dùng lại (14 key S04 có sẵn và key khác)

| Key | Trạng thái ở S04 |
|---|---|
| `HUD_OBJECTIVE_PICK_UP_MANIFEST` | **Dùng** (H1 dòng 3). |
| `INVENTORY_CONFIRM_DROP_TITLE`, `_DROP_BODY`, `_DROP_ACCEPT` | **Dùng** nguyên chữ. |
| `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` | **Dùng**. TASK-98: chữ hiện nói "không gọi được thuyền"; nên nói thêm đèn phao A tắt tới khi nhặt lại (cùng nghĩa E0, đổi chữ giữ key). |
| `INVENTORY_CONFIRM_WITHDRAW_TITLE`, `_WITHDRAW_BODY`, `_WITHDRAW_ACCEPT` | **Dùng**; `_BODY` chỉ cho món thường, không cho Manifest. |
| `CONFIRM_BUTTON_CANCEL` | **Dùng** cho O5i. |
| `LOADOUT_CONFIRM_GEAR_TITLE`, `_GEAR_BODY`, `_GEAR_ACCEPT`, `LOADOUT_CONFIRM_NO_WEAPON_TITLE`, `_NO_WEAPON_BODY` | **Không hiện** ở slice (luật S04 §5.6). Giữ. |
| `HUD_OBJECTIVE_DELIVER_PIER_A` | Dùng ở D và đường về (§5.1). |
| `SUMMARY_DEATH_TITLE`, `_KEPT_SEALED`, `_LOST_UNSEALED`, `_EVIDENCE_AT_DESK`, `_EVIDENCE_UNRECOVERED`, `_NOT_EXTRACTED`, `_BUTTON_PREPARE`, `SUMMARY_GROUP_KEPT`/`_LOST`/`_EVIDENCE` | Dùng ở S11. |
| `SUMMARY_SUCCESS_KEPT_CELLS`, `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`, `INVENTORY_FOOTPRINT_CHIP` | Dùng ở S10 full-route. |
| `CARD_FIT_*`, `CARD_TAG_*`, `CARD_ACTION_*`, `CARD_BACKPACK_FREE`, `INVENTORY_REASON_*`, `INVENTORY_SEAL_LABEL_SEALED`, `_SEALED_NOT_EXTRACTED`, `INVENTORY_PICKUP_HINT_ITEM`, `INVENTORY_PREVIEW_FITS_BACKPACK`, `CARD_PLACED_CONFIRM_BACKPACK`/`_NOTARY_BOX`, `PROMPT_SAFEBOX_SEAL_HINT`, `UI_LOADING`, `UI_ERROR_SCENE_LOAD`, `HUD_DANGER_*` | Dùng nguyên. |

### 9.3 Key không còn dùng từ S04 (giữ trong `strings.csv`, **không xóa**)

| Key | Vì sao |
|---|---|
| `COMBAT_STUB_HP_ZERO` | O6 stub thay bằng O7 + S11 (luật S04 §7.1.6). |
| `COMBAT_STUB_BUTTON_BOOT` | Như trên; S11 dùng `SUMMARY_DEATH_BUTTON_BOOT`. |
| `INVENTORY_REASON_WITHDRAW_LOCKED` | Rút mở trong run (luật S04 §5.7). |
| `INVENTORY_PREVIEW_FITS_NOTARY_BOX` | Câu "trong run chưa rút ra lại được" sai từ S04; nghĩa đổi → key mới `INVENTORY_PREVIEW_SEAL_NOTARY_BOX`. |
| `SUMMARY_DEATH_BUTTON_RECOVERY` | Chưa dùng ở S04 (S12 thuộc S05). Giữ cho S05. |

## 10. Acceptance tests (given / when / then)

Tên test: `test_zdu_xx_<mô_tả>`. "Không đổi" = `inventory.snapshot()`, ground/nguồn D, state `ExtractPierAFlow` bằng nhau
trước/sau và không có signal commit. Hộp fixture = Cuộn Băng Muối (0,0) đứng + Manifest (1,0). Test cần nhìn (cỡ, chồng
lấn, thang xám) chạy tay ở 1280×720 **và** 640×360.

| Mã | Gate | Given | When | Then |
|---|---|---|---|---|
| ZDU-01 | G9 | Đứng trong 1.5 m `CargoD`, nguồn `full` | Đọc R5' | Icon kiện vuông + `WORLD_INTERACT_CARGO_D`; không tự mở. Ra ngoài 1.5 m → ẩn. |
| ZDU-02 | G9 | ZDU-01 | Chạm R5' | Dock R10c: 1 chip `2×2`; dòng thứ tự NAME → FOOTPRINT → USE (+ `8` / `2` có nhãn) → CLAIM → RARITY → LORE; Hộp dòng 2b = icon ổ khóa gạch chéo + `CARD_FIT_NOTARY_BOX_NOT_SEALABLE`; R1, H2, H5 vẫn hiện. Không đổi. |
| ZDU-03 | G9 | Card Dấu Thuế, Hộp fixture | Đọc | Chip `1×2`; tag `CARD_TAG_ROTATABLE`, `CARD_TAG_SEALABLE`; dòng 3b `6` / `3`; Hộp `no_fit` (icon × + chữ). |
| ZDU-04 | G9/G7 | Ảnh thang xám hai card D | Xem tay | Phân biệt được footprint (sơ đồ + chữ), giá trị (số + nhãn), claim (icon phe), rarity (1 dấu đặc, giống nhau ở cả hai) không cần màu. Không vạch/sao/thanh so sánh. |
| ZDU-05 | G9 | Card đồng xu ở `GroundDrop` | Đọc | Không có dòng 3b; tag dải S `INVENTORY_PICKUP_SOURCE_GROUND` khi vào `pickup`. |
| ZDU-06 | G9 | Card cargo, ba lô rỗng | `Nhặt và xếp` | Lưới `pickup`; mọi ô Hộp có ổ khóa gạch chéo; R10g-E = `CARD_FIT_NOTARY_BOX_NOT_SEALABLE`; R10g-A không có `Bỏ`; không `Xoay`. |
| ZDU-07 | G9/G10 | ZDU-06, Hộp trống | Đè rồi nhấc ngón ở Hộp (0,0) | Dải S `{item}` · `INVENTORY_REASON_NOT_SEALABLE`; cargo ở nguồn; không đổi. |
| ZDU-08 | G9 | ZDU-06 | Nhấc ngón ở ba lô (0,0) | `commit_pickup(…, backpack, (0,0), false)` ok; dock đóng; toast `CARD_PLACED_CONFIRM_BACKPACK`; R10g-E về nhãn Manifest nếu Manifest trong Hộp. |
| ZDU-09 | G9 | Ba lô không còn khối 2×2 | `pickup` cargo | Mọi anchor ba lô gạch chéo; R4' `INVENTORY_HINT_BACKPACK_MAKE_ROOM`; không nút đổi/bỏ/gợi ý chỗ. |
| ZDU-10 | G9 | Mở rồi `Bỏ qua`/`Đóng` cả hai card D | Đi D → B → A | Không đổi; H1 `HUD_OBJECTIVE_DELIVER_PIER_A` suốt đường; không toast trách. |
| ZDU-11 | G10 | Hộp fixture; Dấu Thuế đứng ba lô (2,0); `view` | Chọn Dấu Thuế; đè/nhấc lần lượt Hộp (0,0), (1,0), (1,1) | Mỗi lần: dải S lý do đúng luật S04 §4.3; icon × ở `blocking_cells`; sau lần nhấc đầu R4' `INVENTORY_HINT_NOTARY_BOX_MAKE_ROOM`; thuốc + Manifest ở Hộp; Dấu Thuế ở (2,0); không đổi. |
| ZDU-12 | G10 | ZDU-11 | Rà toàn dock | Không có nút "đổi chỗ", "rút giúp" hay "đặt vào chỗ gợi ý"; không món nào tự di chuyển. |
| ZDU-13 | G10 | Manifest trong Hộp | Mở `view`; chọn lần lượt thuốc, một món ba lô; mở O5i | R10g-E luôn hiện badge vật chứng + `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED`; ô Manifest có badge + icon niêm + mấu. |
| ZDU-14 | G10/G11 | Hộp fixture; ba lô (0,0),(0,1) trống | Chọn thuốc → `Rút` | `Rút` viền dày; dải S `INVENTORY_WITHDRAW_PICK_CELL_HINT`; chỉ anchor ba lô được đánh dấu. Không đổi. |
| ZDU-15 | G11 | ZDU-14 | Đè ô ba lô (0,0) | Bóng khung liền (0,0),(0,1); dải S `INVENTORY_PREVIEW_WITHDRAW_BACKPACK`; chưa có O5i. |
| ZDU-16 | G11 | ZDU-15 | Nhấc ngón trong ô | O5i withdraw ở 312–608 × 184–576: `INVENTORY_CONFIRM_WITHDRAW_TITLE`, hàng món, hàng đích `INVENTORY_CONFIRM_TARGET_BACKPACK`, nhãn `đã niêm` gạch → `không niêm`, `INVENTORY_CONFIRM_WITHDRAW_BODY`; dock: Hộp (0,0) nét đứt + ổ khóa mở, ba lô (0,0),(0,1) khung dày. Không commit. |
| ZDU-17 | G11 | ZDU-16 | Chạm `Rút ra` trong 0.3 s đầu, rồi sau 0.3 s | Lần đầu không gì; lần sau `commit_withdraw(remedy, (0,0), false)` đúng 1 lần; toast `CARD_PLACED_CONFIRM_WITHDRAWN`; icon niêm của thuốc biến mất. |
| ZDU-18 | G11 | ZDU-16 | `Hủy` / Back | Không commit; O5i đóng; thuốc vẫn ở Hộp, vẫn được chọn; không đổi. |
| ZDU-19 | G11 | Rút Manifest tới ba lô | O5i mở | Thân `INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY`; nhãn đổi `đã niêm — chưa extract` → badge + `INVENTORY_SEAL_LABEL_NOT_EXTRACTED`; không có `INVENTORY_CONFIRM_WITHDRAW_BODY`. |
| ZDU-20 | G11 | Ba lô đầy; thuốc trong Hộp | Chọn thuốc; chạm `Rút`; chạm ô ba lô | `Rút` có gạch chéo + khóa; dải S `INVENTORY_REASON_CELLS_OCCUPIED`; **không** O5i; thuốc giữ icon niêm. |
| ZDU-21 | G11 | Đồng xu trong ba lô; `view` | Chọn → `Bỏ` | O5i drop: hàng đích `INVENTORY_CONFIRM_TARGET_GROUND`, thân `INVENTORY_CONFIRM_DROP_BODY`; ô đồng xu nét đứt + mũi tên xuống. Không commit. |
| ZDU-22 | G11 | ZDU-21 | `Bỏ xuống` | `commit_drop` 1 lần; `GroundDrop` dưới chân, thấy được bên trái dock; toast `CARD_PLACED_CONFIRM_DROPPED`; R5' `WORLD_INTERACT_GROUND_DROP` khi trong tầm. |
| ZDU-23 | G11 | Manifest trong ba lô, E1 | `Bỏ` → O5i | Thân `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` + icon đèn phao gạch chéo. Xác nhận → H1 `HUD_OBJECTIVE_PICK_UP_MANIFEST`, W2' E0. |
| ZDU-24 | G11 | Như ZDU-23 nhưng ở S8 / S9 | `Bỏ` → O5i | Thêm dòng `INVENTORY_CONFIRM_DROP_EVIDENCE_S8_NOTE` / `_S9_NOTE`. |
| ZDU-25 | G11 | Món trong Hộp được chọn | Đọc R10g-A | Có `Rút`, không có `Bỏ`. Món túi đeo chéo không chọn được. |
| ZDU-26 | G11 | Một run S04 | Move, xoay, xem card, đổi chip, `Bỏ qua`, `Đóng`, preview, `Nhặt và xếp` vào ba lô và Hộp, niêm từ ba lô, nhặt `GroundDrop`, D1 | Số lần O5i/O5 mở = 0. |
| ZDU-27 | G11 | O5i đang mở, đứng trong `BeaconZoneA` E1 | Đọc R5'; thử `Gọi thuyền` (phím) | R5' ẩn; không mở O5 gọi thuyền. |
| ZDU-28 | G11/§8.7 | O5i mở; vệ binh `alert` cách 5 m | Đọc; chạm D1 | D1 hiện (16–304), không giao O5i; chạm → O5i đóng không commit **và** dock đóng; C1–C4 hiện ngay. |
| ZDU-29 | G11 | O5i drop cargo mở | Bị đánh (HP 85) | O5i vẫn mở; H2 85; không commit. |
| ZDU-30 | G11 | O5i mở | App xuống nền rồi trở lại; chạm xác nhận ngay | O5i còn nguyên; chạm trong 0.3 s đầu bị bỏ qua. |
| ZDU-31 | G16/G17 | O5i drop cargo mở | HP về 0 | O5i đóng không commit; O7 hiện; S11 cargo ở `Đã mất` phân nhóm a (icon ổ khóa mở); không `GroundDrop` mới. |
| ZDU-32 | G16/G17 | Mọi death | Theo dõi 0–2.5 s | O7: lớp chặn, dấu Phù Hiệu + vòng lấp + `RECALL_SIGIL_MOMENT_LINE`; C1–C4, R5', H3, D1, H5, R2 ẩn; chạm/Back bị bỏ qua; không `COMBAT_STUB_HP_ZERO`; không chữ/icon success; S11 mở ở 2.5 s. |
| ZDU-33 | G16 | Fixture luật S04 §9.1 | Tới S11 | Tiêu đề `SUMMARY_DEATH_TITLE` + dấu Phù Hiệu; ba cột; `Đã giữ` = Cuộn Băng Muối, Sổ Kho Ngấm Nước (icon niêm); `Đã mất` = đồng xu, Gói Băng Muối (phân nhóm a) + dòng trang bị; `Vật chứng` = `SUMMARY_DEATH_EVIDENCE_AT_DESK` + `SUMMARY_DEATH_NOT_EXTRACTED`; nút `SUMMARY_DEATH_BUTTON_PREPARE` ở 440–840 × 608–704; không dòng thu hồi. |
| ZDU-34 | G16 | ZDU-33 | Chạm nút ở 0.5 s; rồi sau 1.0 s | Lần đầu không gì (icon khóa + vòng); lần sau → S1 Contract 1 đúng một lần; `UI_LOADING`. |
| ZDU-35 | G17 | Fixture luật S04 §9.2 | Tới S11 | `Đã giữ` = Cuộn Băng Muối; `Đã mất` có Vải Cứu Trợ Đổi Nhãn + dòng trang bị; `Vật chứng` = `SUMMARY_DEATH_EVIDENCE_UNRECOVERED` + tag `chưa thu hồi` + `NOT_EXTRACTED`; Manifest không ở cột khác; nút `SUMMARY_DEATH_BUTTON_BOOT`; không `SUMMARY_DEATH_BUTTON_RECOVERY`, không `RECOVERY_*`, không `SUMMARY_SUCCESS_*`. |
| ZDU-36 | G17 | Cargo bỏ ở D (không nhặt lại), đồng xu trong ba lô; chết | Đọc `Đã mất` | Phân nhóm a: đồng xu (ổ khóa mở); phân nhóm b `SUMMARY_DEATH_LOST_LEFT_BEHIND`: cargo (mũi tên xuống); dòng trang bị cuối. |
| ZDU-37 | G16/G17 | Chết khi Hộp trống non-evidence (luật S04 §10.8) | Đọc S11 | Cột `Đã giữ` ẩn; hai cột 32–624 / 656–1248 theo thứ tự `Đã mất`, `Vật chứng`. |
| ZDU-38 | G17 | `Đã mất` ≥ 9 dòng | Đọc S11; kéo dọc trong cột | Mũi tên "còn nữa" ở đáy cột; cuộn được; cột không đè dòng thu hồi hay nút. |
| ZDU-39 | G16/G17 | S11 vừa mở; bàn phím/tay cầm | `ui_focus_next` lặp; `ui_down` khi cột `Đã mất` focus; `ui_accept` khi nút focus (sau 1.0 s) | Focus đầu ở nút; thứ tự nút → `Đã giữ` → `Đã mất` → `Vật chứng` → nút; cột focus có viền dày và cuộn; `ui_accept` đi tiếp đúng một lần. |
| ZDU-40 | G16/G17 | Ảnh thang xám S10 và S11 cạnh nhau | Xem tay | Phân biệt được hai màn không cần màu: số cột, dấu Phù Hiệu vs không, vị trí nút, có/không `Tiếp theo` và câu mentor. |
| ZDU-41 | G15 | Fixture ZD-24 (luật S04 §11) | S10 | `Đã giữ`: licence, cargo (`2×2`), thuốc Hộp (`1×2`), Dấu Thuế (`1×2`), Gói Băng Muối (`1×1`), dòng `5/12`; `Đã mất`: đồng xu + mũi tên xuống + `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`; không số giá trị, điểm, sao, route, thời gian. |
| ZDU-42 | G15 | Hai run: rút sớm và full-route | So rect và node S10 | Cùng bố cục, cùng tập key; chỉ khác dòng danh sách. |
| ZDU-43 | G9/G12 | Đang mang Manifest | Đi A → B → D → B → A | H1 `HUD_OBJECTIVE_DELIVER_PIER_A` suốt (trừ encounter B dòng 2); không marker/mũi tên chỉ đường mới. |
| ZDU-44 | — | Cửa sổ 640×360 | Đo `Bỏ`, `Rút`, `Xoay`, nút O5i, nút S11 | Mỗi vùng ≥ 48×48 px thật; khoảng giữa ≥ 8 px thật; chữ mới ≥ 12 px thật. |
| ZDU-45 | — | Mọi màn S04 | Rà chữ | Mỗi chữ có key trong `strings.csv` hoặc §9.1; không chuỗi cứng; `COMBAT_STUB_*`, `INVENTORY_REASON_WITHDRAW_LOCKED`, `INVENTORY_PREVIEW_FITS_NOTARY_BOX` không hiện ở đâu. |

## 11. Truy vết tới gate

| Gate | Mục | Test |
|---|---|---|
| G9 | §4.1, §4.2, §4.3.3, §4.4, §5 | ZDU-01…10, ZDU-43 |
| G10 | §4.3.3, §4.3.4 | ZDU-07, ZDU-11…14 |
| G11 | §4.3.5, §4.5, §4.6 | ZDU-14…31 |
| G15 | §4.9 | ZDU-41, ZDU-42 |
| G16 | §4.7, §4.8 | ZDU-31…34, ZDU-37…40 |
| G17 | §4.7, §4.8 | ZDU-31, ZDU-32, ZDU-35…40 |
| Invariant §8.4, §8.5, §8.7, §8.8 | §3.2, §4.3.3, §4.6, §4.8 | ZDU-04, ZDU-12, ZDU-28, ZDU-40 |

## 12. Câu hỏi mở (không chặn TASK-100/101; mặc định ghi bên cạnh)

1. **O5i che một phần nửa trái thế giới** (312–608). Mặc định giữ, vì cần thấy ô đích thật trong dock, và D không có địch.
   Nếu playtest thấy mất telegraph ở B/A, phương án khác là thu O5i thành dải 704–1264 phía trên dock với lưới thu nhỏ.
2. **`Đã giữ` rỗng ở S11 bị ẩn** theo luật S04 §7.3. Nếu playtest thấy người chơi tưởng "Hộp không giữ gì", TASK-98 có thể
   thêm một dòng nói Hộp không có đồ niêm; luật không đổi.
3. **Khóa nút S11 1.0 s** sau O7 2.5 s: tổng 3.5 s trước khi đi tiếp. Chờ playtest; ngắn hơn 0.6 s thì bỏ vòng tiến độ.
