# Spec kỹ thuật — Lưới ba lô 3x4 và Hộp Công Chứng 2x2 (vertical slice)

**Trạng thái:** spec hệ thống `proposed` cho gameplay-engineer. Mọi con số, tên lớp/hàm và chuỗi hiển thị trong file này là `proposed` trừ khi ghi rõ nguồn. Spec không định nghĩa UI/layout màn inventory, giá trị kinh tế, stack cap final, equip/loadout ở hub hay hành vi túi đeo chéo ngoài quy tắc "không nhận loot".

**Nguồn luật (ưu tiên khi spec này khác):** [Bộ trang bị, ba lô và Hộp Công Chứng](../systems/inventory-and-loadout.md) §4, §5, §9 · [Vertical slice](../vertical-slice.md) §2.1, Beat 2/4/5, §4.3 · [Build-readiness](../vertical-slice-build-readiness.md) G2, G4, G8, G10, G17, invariant §8.5–8.6 · [Wireflow](../vertical-slice-wireflow.md) O3/O4/O5 · [Item Cảng Hắc Thuế](../items/black-tax-port-items.md) · [D cargo brief](../maps/black-tax-port-d-cargo-choice-brief.md).

## 1. Mục đích (người chơi thấy gì)

Người Thu Hồi (`retriever`) mang một **ba lô** (`backpack`) 3x4 và **Hộp Công Chứng** (`notary_box`) 2x2. Mỗi món chiếm một **footprint** hình chữ nhật. Người chơi tự quyết đặt, xoay, chuyển, niêm phong, rút ra hoặc bỏ lại từng món. Hệ thống **không bao giờ** tự vứt, tự hoán đổi, tự xếp hay tự niêm phong; mọi thao tác sai giữ nguyên món ở chỗ cũ và nói lý do. Niêm `Manifest Hàng Hóa R-17` (`manifest_r17`) chỉ bảo đảm nó không mất vĩnh viễn, **không** hoàn thành Contract 1 (`contract_keep_licence`).

## 2. Khái niệm mới và code identifier

| Khái niệm (VI) | code | Nghĩa |
|---|---|---|
| Lưới | `InventoryGrid` / `grid_kind` | Một lưới ô chữ nhật. `grid_kind ∈ {backpack, notary_box, sling_pouch}`. |
| Định nghĩa item | `ItemDef` | Dữ liệu tĩnh của một loại item (footprint, quyền niêm, stack…). |
| Bản thể item | `ItemInstance` | Một món cụ thể đang tồn tại, có `uid` riêng. |
| Ô neo | `anchor` | Ô trên-trái của footprint đã đặt, kiểu `Vector2i(x, y)`. |
| Kết quả thao tác | `InventoryResult` | `ok` + `reason` + dữ liệu preview; không bao giờ ném exception cho lỗi người chơi. |
| Lý do lỗi | `InventoryReason` | Enum lý do; mỗi giá trị có nhãn tiếng Việt cho UI. |
| Nhóm item | `item_category` | Enum loại item dùng để kiểm tra niêm/đích. |
| Vị trí item | `item_location` | `ground`, `backpack`, `notary_box`, `sling_pouch` (+ kết quả cuối run `hub_stash`, `archive`, `lost`, `unrecovered`). |
| Kết quả chết | `DeathOutcome` | Ba nhóm `kept` / `lost` / `unrecovered_evidence` cho summary S11. |
| Kết quả extract | `ExtractOutcome` | Hai nhóm `to_hub` / `to_archive` cho summary S10. |
| Gợi ý ô | `suggest_slot` | Ô hợp lệ đầu tiên trong **ba lô** để UI highlight; không tự đặt. |

## 3. Quy ước lưới và footprint

1. Ô có toạ độ `Vector2i(x, y)`: `x` là cột từ trái (0…w−1), `y` là hàng từ trên (0…h−1).
2. Ba lô slice: `size = Vector2i(3, 4)` — 3 cột × 4 hàng, tổng 12 ô `proposed` (theo vertical-slice §2.1; hướng 3 cột × 4 hàng là `proposed`).
3. Hộp Công Chứng slice: `size = Vector2i(2, 2)`, 4 ô (nguồn: inventory-and-loadout §5.2).
4. Footprint chưa xoay của `ItemDef` là `size = Vector2i(w, h)`. Quy ước tên: `1x2` = `Vector2i(1, 2)` (đứng); `2x2` = `Vector2i(2, 2)`.
5. Footprint hiệu lực: `rotated == false` → `(w, h)`; `rotated == true` → `(h, w)`.
6. Item vuông (`w == h`) luôn lưu `rotated = false`; yêu cầu xoay item vuông trả `ok` và không đổi state (no-op, không phát signal).
7. Ô bị chiếm của một item = mọi ô `anchor + (dx, dy)` với `0 ≤ dx < w_eff`, `0 ≤ dy < h_eff`.
8. Footprint slice chỉ gồm 1x1, 1x2, 2x2 (1/2/4 ô). Item 9 ô không có trong slice. Engine vẫn phải chấp nhận `size` tới `Vector2i(3, 3)` để không phải viết lại sau slice.
9. Không lồng container: không có API nào đặt item vào **bên trong** một `ItemInstance`. Item `container` chỉ là loot có footprint.
10. Đồ đang trang bị (vũ khí, khiên, giáp) không chiếm ô nào trong lưới; equip/swap gear thuộc spec khác.

## 4. Quy tắc thao tác lưới (ba lô)

### 4.1 Nguyên tắc chung

1. **Preview thuần:** mọi hàm `preview_*` không thay đổi state, không phát signal. Gọi preview rồi bỏ qua = hủy.
2. **Commit nguyên tử:** mọi hàm `commit_*` tự kiểm tra lại toàn bộ điều kiện (không tin preview cũ). Nếu `ok == false`, state sau lệnh **giống hệt** state trước lệnh (so bằng `snapshot()`), item ở nguyên chỗ nguồn, không có signal.
3. **Không tự động:** engine không có code path nào tự drop, tự swap, tự sort, tự niêm phong, tự chuyển vào túi đeo chéo hoặc tự chuyển evidence vào Archive. Mỗi thay đổi state xuất phát từ đúng một lệnh `commit_*` do người chơi kích hoạt.
4. **Một lệnh, tối đa hai item đổi chỗ:** chỉ `commit_swap` di chuyển 2 item; mọi lệnh khác di chuyển đúng 1 item (hoặc gộp 1 stack). Riêng `commit_sort` sắp lại cả ba lô sau khi người chơi xác nhận preview.
5. Lỗi luôn trả `InventoryResult` có `reason` (§7); không dùng `push_error`/assert cho lỗi người chơi.

### 4.2 Đặt / nhặt / di chuyển / xoay

1. **Đặt hợp lệ** khi và chỉ khi: (a) đích là lưới được phép cho thao tác đó; (b) item được phép vào lưới đích (§5 cho Hộp); (c) mọi ô footprint hiệu lực nằm trong biên lưới; (d) mọi ô đó trống, **trừ** ô đang bị chính item này chiếm (khi di chuyển trong cùng lưới).
2. **Nhặt** (`ground → backpack`): chỉ hoàn tất khi đặt hợp lệ tại `anchor` + `rotated` người chơi chọn. Fail/hủy: item vẫn ở `ground`, lưới không đổi (G4, G8).
3. Nhặt **không bao giờ** chọn `notary_box` hay `sling_pouch` làm đích mặc định. Nhặt thẳng vào Hộp chỉ xảy ra khi người chơi chọn ô Hộp (xem §5, thao tác niêm).
4. **Gợi ý ô:** `suggest_slot(def, quantity)` quét **chỉ ba lô**, hàng trước cột (y tăng dần, rồi x tăng dần); tại **mỗi** anchor thử chưa xoay trước, rồi xoay (nếu `rotatable` và không vuông), rồi mới sang anchor kế; trả `{anchor, rotated}` đầu tiên hợp lệ hoặc `null`. UI dùng nó để preview; vẫn cần người chơi xác nhận.
5. **Di chuyển** (`backpack → backpack`): như đặt hợp lệ; được phép chồng lên chính ô cũ của item.
6. **Xoay:** chỉ khi `ItemDef.rotatable == true`. Xoay tại chỗ giữ nguyên `anchor` (ô trên-trái); nếu footprint mới ra ngoài biên hoặc đè item khác thì fail, item giữ hướng cũ. Xoay có thể kèm di chuyển trong cùng một lệnh (`commit_move(uid, grid, anchor, rotated)`).
7. Xoay **không** làm xoay/đẩy bất kỳ item nào khác.
8. **Stack:** chỉ gộp khi cả hai đều `stackable`, cùng `def_id`, cùng `claim_id`, và `qty_nguồn + qty_đích ≤ stack_max`. Gộp là **toàn phần**: nếu không chứa hết thì fail `STACK_FULL`, không gộp một phần. Tách stack không có trong slice. Gộp chỉ xảy ra qua lệnh `stack`; `pickup`/`move`/`seal`/`withdraw` vào ô có stack tương thích trả `CELLS_OCCUPIED`, không tự gộp (UI có thể đề xuất lệnh `stack`). Nguồn của `stack` là item trong ba lô hoặc trên ground; đích là stack trong ba lô `proposed`.
9. **Hoán đổi (`commit_swap`)** chỉ khi người chơi chọn rõ hai item **cùng trong ba lô**: A đến `anchor` của B, B đến `anchor` của A (mỗi món giữ `rotated` hiện tại hoặc `rotated` do lệnh chỉ định). Hợp lệ khi, sau khi nhấc cả hai ra, cả hai đặt hợp lệ và không đè nhau. Hoán đổi giữa ba lô và Hộp, hoặc giữa lưới và `ground`, trả `SWAP_NOT_ALLOWED` — người chơi phải làm từng bước (rút/bỏ rồi đặt).
10. **Bỏ lại (`commit_drop`)** chỉ áp dụng cho item trong ba lô, sau khi UI đã hiện O5 và người chơi xác nhận. Item trở lại `ground` tại vị trí người chơi với `quantity` nguyên vẹn. Item trong Hộp phải rút ra ba lô trước (`WRONG_SOURCE`) `proposed`. Không có lệnh "bỏ tất cả".
11. **Không đủ chỗ khi nhặt:** engine chỉ trả `CELLS_OCCUPIED`/`OUT_OF_BOUNDS`; UI cho người chơi tự bỏ một món (O5) rồi nhặt lại. Engine không có lệnh "đổi món trên đất lấy món trong ba lô" trong slice `proposed`.
12. **Tự xếp (`preview_sort` / `commit_sort`)** — có trong slice theo inventory-and-loadout §9, chỉ chạy khi người chơi bấm và xác nhận preview:
    1. Chỉ sắp lại item trong **ba lô**; không đọc/ghi Hộp, túi đeo chéo, ground hay equip.
    2. Gộp các stack tương thích (quy tắc 4.2.8) trước, phần dư giữ thành stack riêng.
    3. Thứ tự đặt: diện tích footprint giảm dần → `def_id` tăng dần → `uid` tăng dần.
    4. Mỗi item đặt vào ô đầu tiên hợp lệ theo thứ tự quét của `suggest_slot`.
    5. Nếu có item không đặt được, trả `SORT_NO_FIT` và ba lô giữ nguyên layout cũ.
    6. Không đổi `claim_id`, `appraisal_class`, `quantity` tổng, không bỏ item nào. Thuật toán là `proposed`.
    7. Slice không có cờ khóa item (`locked`); sort coi mọi item ba lô là sắp được `proposed`. Khi thêm khóa sau slice, item khóa giữ nguyên `anchor`/`rotated` và được đặt trước mọi item khác.
13. **Túi đeo chéo** (`sling_pouch`): trong raid, không phải đích hợp lệ của nhặt/di chuyển/rút/swap/sort (`WRONG_TARGET`, nhãn `sai loại`). Mọi thao tác khác với túi (dùng nhanh, loadout ở hub) nằm ngoài spec này.

## 5. Quy tắc Hộp Công Chứng (`notary_box`)

1. **Niêm (`commit_seal`)** = đặt item vào Hộp từ `backpack` hoặc từ `ground` (người chơi chọn ô Hộp khi nhặt). Hợp lệ khi và chỉ khi: `ItemDef.sealable == true` **và** footprint hiệu lực nằm trọn ô trống của Hộp (được xoay nếu `rotatable`).
2. Item `sealable == false` (gear, weapon, cargo, container, ba lô/túi, mặc định theo inventory-and-loadout §5.2) bị từ chối `NOT_SEALABLE` dù Hộp trống.
3. Hộp đầy / không vừa / sai loại: item ở nguyên **nơi nguồn** (ba lô hoặc ground); không đẩy item cũ trong Hộp ra ba lô/ground (G10).
4. **Nhường chỗ:** không có auto-swap. Người chơi phải `commit_withdraw` món cũ tới ô ba lô hợp lệ, rồi mới `commit_seal` món mới.
5. **Rút (`commit_withdraw`)** trong raid: đích duy nhất là ba lô; chỉ hoàn tất khi đặt hợp lệ. UI phải qua O5 xác nhận trước khi gọi commit. Ba lô đầy/sai footprint → item vẫn trong Hộp, giữ nhãn `đã niêm`.
6. Di chuyển/xoay **bên trong** Hộp được phép theo §4.2 (không cần O5) vì item vẫn niêm.
7. Item trong Hộp có `item_location = notary_box` và trạng thái hiển thị (`seal_label`):
   - non-evidence → `sealed` (nhãn `đã niêm`);
   - evidence (`item_category == evidence`) → `sealed_not_extracted` (nhãn `đã niêm — chưa extract`).
8. Không thao tác Hộp nào đổi contract state, mở completion hoặc gọi extract.
9. **Ngoại lệ vật chứng Story Contract — `manifest_r17`** (inventory-and-loadout §5.3, vertical-slice §4.3):
   1. `manifest_r17` là `evidence`, `1x1`, `sealable = true`: được đặt ở ba lô **hoặc** Hộp.
   2. Niêm Manifest chỉ đổi `seal_label` thành `sealed_not_extracted`; không phát tín hiệu hoàn thành, không chuyển Archive/hub.
   3. Khi chết (kể cả đang ở Hộp): Manifest **không** vào `kept`; nó vào `unrecovered_evidence`. Contract xử lý `unrecovered` (ngoài spec này).
   4. Khi extract thành công: Manifest vào `to_archive`, **không** vào `to_hub`.
   5. Signal `evidence_carried_changed(def_id, true)` phát mỗi lần một evidence chuyển từ `ground` vào ba lô hoặc Hộp bằng một commit `ok` (kể cả nhặt lại sau khi đã bỏ); di chuyển ba lô ↔ Hộp hay trong cùng lưới không phát. Bỏ evidence xuống ground phát `evidence_carried_changed(def_id, false)`. Commit fail không phát. Beacon A E0→E1 lắng nghe signal này (thuộc spec extract/contract).

## 6. States và transitions

### 6.1 Vị trí item (`item_location`)

```text
ground --pickup/commit_place--> backpack
ground --commit_seal (chọn ô Hộp)--> notary_box
backpack --commit_move/rotate/swap/sort--> backpack
backpack --commit_seal--> notary_box
notary_box --commit_withdraw (sau O5)--> backpack
notary_box --commit_move/rotate--> notary_box
backpack --commit_drop (sau O5)--> ground
[death]   backpack, sling_pouch --> lost ; notary_box non-evidence --> kept ; mọi evidence --> unrecovered
[extract] backpack, sling_pouch, notary_box non-evidence --> hub_stash ; mọi evidence --> archive
lệnh fail / hủy  --> giữ nguyên vị trí nguồn
```

### 6.2 Vòng đời một lệnh

```text
idle --preview_*()--> previewing (không đổi state)
previewing --hủy / đóng O3/O4--> idle (không đổi state)
previewing --commit_*() ok--> idle (state mới + signal)
previewing --commit_*() fail--> previewing/idle (state cũ, reason)
```

Lệnh `commit_withdraw` và `commit_drop` chỉ được UI gọi sau O5 `xác nhận`; O5 `hủy` = không gọi commit.

### 6.3 Kết thúc run

1. `resolve_death() -> DeathOutcome` (G16/G17):
   - `kept`: mọi item non-evidence trong Hộp (giao cho hub stash; hub stash ngoài spec);
   - `lost`: mọi item trong ba lô và túi đeo chéo (non-evidence);
   - `unrecovered_evidence`: `def_id` mọi evidence ở ba lô hoặc Hộp;
   - sau khi gọi, ba lô, Hộp và túi đeo chéo của run đều rỗng. Đồ đang trang bị do hệ loadout tự xử lý.
2. `resolve_extract() -> ExtractOutcome`:
   - `to_hub`: mọi non-evidence ở ba lô, túi đeo chéo và Hộp;
   - `to_archive`: `def_id` mọi evidence;
   - không bán, không craft, không bỏ item nào.
3. Hai hàm trên là thuần dữ liệu; summary/contract/Archive đọc kết quả, không đọc lưới.

## 7. Lý do lỗi (`InventoryReason`)

Thứ tự kiểm tra cố định (lý do đầu tiên khớp được trả về):

| # | `InventoryReason` | Khi nào | Nhãn UI `proposed` |
|---|---|---|---|
| 0 | `OK` | Hợp lệ | `vừa` |
| 1 | `ITEM_NOT_FOUND` | `uid` không tồn tại ở nguồn đã nêu | `không tìm thấy món` |
| 2 | `WRONG_SOURCE` | Nguồn không cho thao tác này (vd. drop từ Hộp, nguồn là túi đeo chéo) | `rút ra trước` |
| 3 | `WRONG_TARGET` | Đích không hợp lệ cho thao tác (túi đeo chéo, nhét vào item, rút ra ngoài ba lô trong raid) | `sai loại` |
| 4 | `SWAP_NOT_ALLOWED` | Hoán đổi khác lưới hoặc với ground | `đổi từng món` |
| 5 | `NOT_SEALABLE` | Đích là Hộp, `sealable == false` | `không niêm phong được` |
| 6 | `NOT_ROTATABLE` | Yêu cầu xoay item `rotatable == false` (không vuông) | `không xoay` |
| 7 | `OUT_OF_BOUNDS` | Một ô footprint ra ngoài biên | `không vừa` |
| 8 | `CELLS_OCCUPIED` | Một ô footprint đã bị item khác chiếm | `thiếu ô` |
| 9 | `STACK_INCOMPATIBLE` | Gộp khác `def_id`/`claim_id` hoặc không `stackable` | `không xếp chồng` |
| 10 | `STACK_FULL` | Tổng quantity vượt `stack_max` | `chồng đã đầy` |
| 11 | `SORT_NO_FIT` | Thuật toán sort không đặt được mọi item | `không sắp được` |

Ví dụ thứ tự: niêm cargo 2x2 vào Hộp đầy → `NOT_SEALABLE` (không phải `CELLS_OCCUPIED`), vì lý do sai loại là điều người chơi cần biết trước.

## 8. Dữ liệu

### 8.1 `ItemDef` (Resource tĩnh)

| Field | Kiểu | Miền / ràng buộc | Ghi chú |
|---|---|---|---|
| `id` | `StringName` | snake_case, duy nhất | Dùng tên trong glossary nếu đã có. |
| `display_name_vi` | `String` | không rỗng | Tên trên card. |
| `size` | `Vector2i` | mỗi chiều 1…3; slice chỉ dùng (1,1), (1,2), (2,2) | Footprint chưa xoay. |
| `rotatable` | `bool` | — | Bỏ qua với item vuông. |
| `sealable` | `bool` | — | Nhãn `Niêm phong được`. |
| `stackable` | `bool` | — | Nhãn `xếp chồng được`. |
| `stack_max` | `int` | ≥1; `=1` nếu không stackable | Giá trị fixture `proposed`, không phải cap final. |
| `item_category` | `enum` | `evidence, consumable, tool, valuable, salvage, cargo, gear, weapon, ammo, key, container` | Evidence/gear/weapon/cargo/container được kiểm ở §5. |
| `claim_id` | `StringName` | rỗng hoặc id phe (vd. `house_hac_thue`) | Tách khỏi rarity. |
| `appraisal_class` | `int` | 1…6 (Trắng…Đỏ) | Chỉ hiển thị; engine không dùng để quyết định. |

Ràng buộc dữ liệu (kiểm tra khi load, lỗi = lỗi dev, không phải lỗi người chơi): `gear`, `weapon`, `cargo`, `container` phải có `sealable = false`; `evidence` phải có `stackable = false`.

### 8.2 `ItemInstance` (runtime)

| Field | Kiểu | Miền |
|---|---|---|
| `uid` | `int` | ≥1, duy nhất trong save slot |
| `def_id` | `StringName` | tồn tại trong registry |
| `quantity` | `int` | 1…`stack_max` |
| `item_location` | `enum` | §2 |
| `anchor` | `Vector2i` | hợp lệ trong lưới hiện tại; bỏ qua nếu `ground` |
| `rotated` | `bool` | luôn `false` nếu item vuông |

`sealed` không lưu riêng: `sealed == (item_location == notary_box)`.

### 8.3 Bảng item tối thiểu của slice

Tên nhân vật/item dùng glossary hoặc tài liệu nguồn; fixture chưa có tên cuối giữ id theo vai trò. Mọi giá trị dưới đây là `proposed` trừ cột có ghi nguồn.

| `id` | Tên / vai trò | `size` | `rotatable` | `sealable` | `stackable` / `stack_max` | `item_category` | `claim_id` | Nguồn / ghi chú |
|---|---|---|---|---|---|---|---|---|
| `manifest_r17` | Manifest Hàng Hóa R-17 — evidence Contract 1, bàn dispatch A | (1,1) | n/a (vuông) | **true** (nguồn: items #01) | false / 1 | `evidence` | `house_hac_thue` | Ngoại lệ §5.9. |
| `starter_remedy` | Vật hồi phục starter — đã niêm sẵn trong Hộp ở loadout | (1,2) | true | true | false / 1 | `consumable` | — | Nguồn: vertical-slice §2.1 (1x2 đã niêm). Tên cuối chưa chốt. |
| `fixture_b_small_1x1` | Loot nhỏ cache B có claim | (1,1) | n/a | true | **true / 3** `proposed` (chỉ fixture) | `valuable` | `house_hac_thue` | Ứng viên catalogue chưa chốt: items #14 Đồng Thuế Cạo Mặt. Dùng để kiểm stack. |
| `fixture_b_small_1x2` | Loot gọn cache B | (1,2) | true | true | false / 1 | `valuable` | `house_hac_thue` | Ứng viên chưa chốt: items #16 Sổ Kho Ngấm Nước. Dùng để kiểm xoay. |
| `tax_stamp_d` | `Dấu Thuế` fixture tại D | (1,2) | true | true | false / 1 | `valuable` | — (chưa chốt) | Nguồn: D brief §1; vertical-slice Beat 5 (niêm được, vướng Hộp đã có thuốc 1x2 + Manifest). |
| `cargo_d_2x2` | Cargo fixture tại D | (2,2) | n/a | **false** | false / 1 | `cargo` | — (chưa chốt) | Nguồn: D brief §1, G10 (cargo không niêm). |

Fixture **chỉ dùng trong test tự động**, không đặt vào map:

| `id` | `size` | `rotatable` | `sealable` | `stackable` | `item_category` | Mục đích |
|---|---|---|---|---|---|---|
| `test_spare_weapon_1x2` | (1,2) | true | false | false | `weapon` | Kiểm gear/weapon không niêm. |
| `test_fixed_1x2` | (1,2) | **false** | true | false | `tool` | Kiểm `NOT_ROTATABLE`. |
| `test_fixed_2x1` | (2,1) | **false** | true | false | `tool` | Kiểm `SORT_NO_FIT` (INV-30). |
| `test_stack_other_claim_1x1` | (1,1) | n/a | true | true / 3 | `valuable` (claim khác) | Kiểm `STACK_INCOMPATIBLE`. |

### 8.4 Fixture loadout mặc định (vertical-slice §2.1)

- Ba lô 3x4 rỗng.
- Hộp 2x2: `starter_remedy` tại `anchor (0,0)`, `rotated = false` → chiếm (0,0),(0,1); còn trống (1,0),(1,1).
- Túi đeo chéo: một vật hồi phục (ngoài spec này).

## 9. API đề xuất (GDScript, Godot 4.7.2) — không phải code

Tất cả `class_name` là `proposed`; engineer có thể đổi đường dẫn file nhưng giữ tên công khai để test đặt tên khớp.

| Lớp | Kế thừa | Vai trò |
|---|---|---|
| `ItemDef` | `Resource` | §8.1. |
| `ItemRegistry` | `RefCounted` | `get_def(id: StringName) -> ItemDef`, `validate_defs() -> Array[String]` (lỗi dữ liệu §8.1). |
| `ItemInstance` | `RefCounted` | §8.2; `effective_size() -> Vector2i`, `cells() -> Array[Vector2i]`. |
| `InventoryGrid` | `RefCounted` | `grid_kind`, `size`; `item_at(cell: Vector2i) -> ItemInstance`, `free_cell_count() -> int`, `check_fit(item_size: Vector2i, anchor: Vector2i, ignore_uid: int = 0) -> InventoryResult`. |
| `InventoryResult` | `RefCounted` | `ok: bool`, `reason: InventoryReason`, `reason_label_vi: String`, `blocking_cells: Array[Vector2i]`, `moved: Array[Dictionary]` (`{uid, from_location, from_anchor, to_location, to_anchor, rotated}` cho preview). |
| `RetrieverInventory` | `RefCounted` | Chủ sở hữu `backpack`, `notary_box`, `sling_pouch`; toàn bộ lệnh dưới đây. |

`RetrieverInventory` — mỗi lệnh có cặp `preview_*` (pure) và `commit_*` (atomic), cùng chữ ký, cùng trả `InventoryResult`:

| Lệnh | Tham số |
|---|---|
| `pickup` | `ground_item: ItemInstance, target: GridKind (backpack \| notary_box), anchor: Vector2i, rotated: bool` |
| `move` | `uid: int, target: GridKind, anchor: Vector2i, rotated: bool` (cùng lưới; khác lưới đi qua `seal`/`withdraw`) |
| `rotate` | `uid: int` (xoay tại chỗ) |
| `stack` | `source: Variant, target_uid: int` — `source` là `int` (uid trong ba lô) hoặc `ItemInstance` (trên ground); đích luôn là stack trong ba lô |
| `swap` | `uid_a: int, uid_b: int` |
| `seal` | `uid: int, anchor: Vector2i, rotated: bool` (ba lô → Hộp) |
| `withdraw` | `uid: int, anchor: Vector2i, rotated: bool` (Hộp → ba lô; UI gọi commit sau O5) |
| `drop` | `uid: int` (ba lô → ground; UI gọi commit sau O5; trả item qua `moved`) |
| `sort` | không tham số (ba lô) |

Hàm phụ trợ: `suggest_slot(def_id: StringName, quantity: int) -> Variant` (`{anchor, rotated}` hoặc `null`), `seal_label(uid: int) -> StringName`, `resolve_death() -> DeathOutcome`, `resolve_extract() -> ExtractOutcome`, `validate() -> Array[InventoryResult]` (chồng ô, ra biên, item không niêm trong Hộp, `uid` trùng — dùng để khóa `Vào cảng` theo G2), `snapshot() -> Dictionary` (dữ liệu so sánh trong test), `load_snapshot(data: Dictionary) -> void` (nạp loadout/save hoặc given của test, kể cả item trong túi đeo chéo và dữ liệu sai như INV-32; **không** tự sửa, không phát signal — kiểm tra bằng `validate()`).

Ground: `RetrieverInventory` không sở hữu thế giới. Item trên ground là `ItemInstance` có `item_location = ground` do world giữ; `commit_pickup` ok thì world xóa nó khỏi ground, `commit_drop` ok thì world spawn lại `ItemInstance` trả trong `moved`. Test dùng một list ground giả và đưa vào `snapshot()` khi so sánh.

Signals (chỉ phát sau commit `ok`): `item_placed(uid: int, location: StringName)`, `item_removed(uid: int, location: StringName)`, `evidence_carried_changed(def_id: StringName, carried: bool)`.

## 10. Edge cases

1. Di chuyển item sang `anchor` chồng một phần lên chính ô cũ: hợp lệ.
2. Xoay `1x2` đứng ở cột cuối (x = 2) của ba lô: footprint mới `2x1` ra ngoài biên → `OUT_OF_BOUNDS`, giữ hướng cũ.
3. Xoay item vuông (`manifest_r17`, `cargo_d_2x2`): `ok`, không đổi state, không signal.
4. Hộp có `starter_remedy` (1x2) + `manifest_r17` (1x1): còn 1 ô (1,1) → `tax_stamp_d` (1x2) luôn fail: anchor/hướng có footprint nằm trong biên trả `CELLS_OCCUPIED`, còn lại trả `OUT_OF_BOUNDS` (thứ tự §7); một item 1x1 sealable vẫn vừa tại (1,1).
5. Cargo 2x2 vào Hộp trống → `NOT_SEALABLE`.
6. Ba lô đầy, nhặt item → fail; item còn trên ground; không mở rộng sang Hộp/túi.
7. Rút item khỏi Hộp khi ba lô đầy → `CELLS_OCCUPIED`; item vẫn `sealed`.
8. Gộp stack vượt `stack_max` → `STACK_FULL`, cả hai stack giữ quantity cũ.
9. Commit không qua preview: hợp lệ, vì commit tự kiểm tra lại.
10. Preview rồi state đổi (vd. đã đặt món khác vào ô đó) rồi commit: commit fail với lý do hiện tại, không áp preview cũ.
11. Save bị hỏng có ô chồng nhau hoặc gear trong Hộp: `validate()` trả lỗi; `Vào cảng` bị khóa; engine **không** tự sửa/xóa item.
12. Chết khi Hộp chỉ chứa Manifest: `kept` rỗng, `unrecovered_evidence = [manifest_r17]`.
13. Sort khi ba lô đã tối ưu hoặc rỗng: `ok`, có thể không đổi layout.

## 11. Acceptance tests (given / when / then)

Tên test engineering: `test_inv_xx_<mô_tả_ngắn>`. "State không đổi" = `snapshot()` trước/sau bằng nhau và không có signal.

| ID | Given | When | Then |
|---|---|---|---|
| INV-01 | Ba lô 3x4 rỗng; `fixture_b_small_1x1` trên ground | `commit_pickup(item, backpack, (0,0), false)` | `ok`; item ở `backpack` anchor (0,0); ground không còn item; phát `item_placed`. |
| INV-02 | Ba lô rỗng; `fixture_b_small_1x2` trên ground | `commit_pickup(item, backpack, (0,3), false)` | `OUT_OF_BOUNDS`, nhãn `không vừa`; item vẫn trên ground; state ba lô không đổi. |
| INV-03 | Ba lô có `cargo_d_2x2` tại (0,0) | `commit_pickup(fixture_b_small_1x1, backpack, (1,1), false)` | `CELLS_OCCUPIED`, `blocking_cells` chứa (1,1); state không đổi; item vẫn trên ground. |
| INV-04 | `fixture_b_small_1x2` tại (0,0) đứng | `commit_rotate(uid)` | `ok`; `rotated = true`; chiếm (0,0),(1,0). |
| INV-05 | `fixture_b_small_1x2` tại (2,0) đứng | `commit_rotate(uid)` | `OUT_OF_BOUNDS`; vẫn đứng tại (2,0); không item nào khác dịch chuyển. |
| INV-06 | `test_fixed_1x2` trong ba lô | `commit_rotate(uid)` | `NOT_ROTATABLE`, nhãn `không xoay`; state không đổi. |
| INV-07 | `manifest_r17` trong ba lô | `commit_rotate(uid)` | `ok`; `rotated` vẫn `false`; không signal. |
| INV-08 | `fixture_b_small_1x2` đứng tại (0,0) | `commit_move(uid, backpack, (0,1), false)` | `ok`; item chiếm (0,1),(0,2) (chồng lên ô cũ của chính nó vẫn hợp lệ). |
| INV-09 | Ba lô có 2 item | gọi mọi `preview_*` (move, rotate, seal, withdraw, drop, sort) | State không đổi sau mỗi preview; không signal. |
| INV-10 | Ba lô: `fixture_b_small_1x2` A tại (0,0), `tax_stamp_d` B tại (1,0), cả hai đứng | `commit_swap(A, B)` | `ok`; A tại (1,0), B tại (0,0); không item thứ ba bị đụng. |
| INV-11 | A trong ba lô, B trong Hộp | `commit_swap(A, B)` | `SWAP_NOT_ALLOWED`; state không đổi. |
| INV-12 | Ba lô có 2 stack `fixture_b_small_1x1` qty 2 và qty 1 | `commit_stack(src, dst)` | `ok`; còn 1 stack qty 3; ô của stack nguồn trống. |
| INV-13 | Stack `fixture_b_small_1x1` qty 2 và qty 2 | `commit_stack(src, dst)` | `STACK_FULL`; cả hai giữ qty 2. |
| INV-14 | `fixture_b_small_1x1` và `test_stack_other_claim_1x1` | `commit_stack(src, dst)` | `STACK_INCOMPATIBLE`; state không đổi. |
| INV-15 | Hộp fixture loadout (§8.4); `manifest_r17` trong ba lô | `commit_seal(manifest, (1,0), false)` | `ok`; Manifest trong Hộp; `seal_label = sealed_not_extracted` (nhãn `đã niêm — chưa extract`); không có tín hiệu completion/Archive. |
| INV-16 | Hộp: `starter_remedy` tại (0,0) đứng + `manifest_r17` tại (1,0) (trống (1,1)); `tax_stamp_d` trong ba lô | `commit_seal(tax_stamp, a, r)` với mọi `a` ∈ {(0,0),(1,0),(0,1),(1,1)}, `r` ∈ {false, true} | Không lần nào `ok`; footprint trong biên → `CELLS_OCCUPIED`, ra biên → `OUT_OF_BOUNDS`; `tax_stamp_d` vẫn ở ô ba lô cũ; `starter_remedy` và Manifest không rời Hộp. |
| INV-17 | Hộp rỗng; `cargo_d_2x2` trong ba lô | `commit_seal(cargo, (0,0), false)` | `NOT_SEALABLE`, nhãn `không niêm phong được`; cargo vẫn trong ba lô. |
| INV-18 | Hộp đầy 4 ô; `cargo_d_2x2` trong ba lô | `commit_seal(cargo, (0,0), false)` | Lý do là `NOT_SEALABLE` (không phải `CELLS_OCCUPIED`) theo thứ tự §7. |
| INV-19 | Hộp rỗng; `test_spare_weapon_1x2` trong ba lô | `commit_seal(weapon, (0,0), false)` | `NOT_SEALABLE`; weapon vẫn trong ba lô. |
| INV-20 | Hộp có `starter_remedy`; ba lô đầy 12 ô | `commit_withdraw(remedy, (0,0), false)` | `CELLS_OCCUPIED`; remedy vẫn trong Hộp, `seal_label = sealed`. |
| INV-21 | Hộp chỉ có `starter_remedy` tại (0,0); ba lô có `tax_stamp_d` đứng tại (2,0), còn (0,0),(0,1) trống | `commit_withdraw(remedy, (0,0), false)` | `ok`; remedy trong ba lô; Hộp có 4 ô trống; sau đó `commit_seal(tax_stamp_d, (0,0), false)` → `ok`. |
| INV-22 | Ba lô đầy; `fixture_b_small_1x1` trên ground | `commit_pickup(item, backpack, a, r)` với mọi anchor | Fail; Hộp và túi đeo chéo không đổi; không item nào bị drop/swap; item vẫn trên ground. |
| INV-23 | Item bất kỳ trên ground | `commit_pickup(item, sling_pouch, (0,0), false)` | `WRONG_TARGET`, nhãn `sai loại`; item vẫn trên ground. |
| INV-24 | `fixture_b_small_1x2` trong ba lô | `commit_drop(uid)` | `ok`; item ở `ground` với quantity nguyên; ô ba lô trống; phát `item_removed`. |
| INV-25 | `starter_remedy` trong Hộp | `commit_drop(uid)` | `WRONG_SOURCE`; remedy vẫn trong Hộp. |
| INV-26 | `manifest_r17` trên ground, chưa từng được mang | `commit_pickup(manifest, backpack, (0,0), false)` rồi `commit_seal(manifest, (1,0), false)` | Đúng một signal `evidence_carried_changed(manifest_r17, true)` sau pickup; seal không phát lại. Pickup fail thì không phát signal nào. |
| INV-27 | Hộp: `starter_remedy` + `manifest_r17`; ba lô: `cargo_d_2x2`; túi đeo chéo: 1 vật hồi phục | `resolve_death()` | `kept = [starter_remedy]`; `lost` chứa cargo và vật hồi phục trong túi; `unrecovered_evidence = [manifest_r17]`; Manifest không có trong `kept`; ba lưới rỗng. |
| INV-28 | Như INV-27 | `resolve_extract()` | `to_hub` chứa starter_remedy, cargo, vật hồi phục trong túi; `to_archive = [manifest_r17]`; Manifest không có trong `to_hub`. |
| INV-29 | Ba lô: `fixture_b_small_1x1` tại (0,0); `fixture_b_small_1x2` đứng tại (2,0); `cargo_d_2x2` tại (1,2) | `preview_sort()` rồi `commit_sort()` | `ok`; cargo tại (0,0), 1x2 đứng tại (2,0), 1x1 tại (0,2); layout commit bằng layout preview; cùng tập `uid` và tổng quantity; Hộp/túi không đổi. |
| INV-30 | Ba lô đầy 12 ô theo layout hợp lệ: `test_fixed_2x1` tại (0,0); `tax_stamp_d` đứng tại (2,0); `fixture_b_small_1x2` xoay tại (0,1); ba `fixture_b_small_1x2` đứng tại (0,2), (1,2), (2,2) | `commit_sort()` | Thuật toán §4.2.12 đặt năm item 1x2 xoay được theo chiều đứng trước, chỉ còn (2,2),(2,3) cho `test_fixed_2x1` → `SORT_NO_FIT`; `snapshot()` không đổi. |
| INV-31 | Từng given của INV-02, 03, 05, 06, 11, 13, 14, 16–20, 22, 23, 25, 30, 33, 34 | Chạy lệnh fail tương ứng, đếm signal | `item_placed`, `item_removed`, `evidence_carried_changed` đều 0 lần; `snapshot()` của ba lô, Hộp, túi đeo chéo và ground đều không đổi (không auto-drop/swap/sort/seal). |
| INV-32 | Save có hai item chồng ô trong ba lô, hoặc `cargo_d_2x2` trong Hộp | `validate()` | Trả ít nhất một lỗi chỉ đúng `uid`; không item nào bị xóa/di chuyển; UI dùng kết quả để tắt `Vào cảng`. |
| INV-33 | Hộp rỗng; `cargo_d_2x2` trên ground | `commit_pickup(cargo, notary_box, (0,0), false)` | `NOT_SEALABLE`; cargo vẫn trên ground; ba lô và Hộp không đổi (không tự chuyển sang ba lô). |
| INV-34 | Ba lô có stack `fixture_b_small_1x1` qty 1 tại (0,0); một `fixture_b_small_1x1` qty 1 trên ground | `commit_pickup(item, backpack, (0,0), false)` | `CELLS_OCCUPIED`; không tự gộp; stack giữ qty 1; item vẫn trên ground. Sau đó `commit_stack(item, uid_stack)` → `ok`, qty 2. |
| INV-35 | `manifest_r17` trong ba lô (đã phát `true` một lần) | `commit_drop(manifest)` rồi `commit_pickup(manifest, backpack, (0,0), false)` | Signal theo thứ tự: `evidence_carried_changed(manifest_r17, false)` rồi `(manifest_r17, true)`; mỗi cái đúng một lần. |

## 12. Truy vết tới gate

| Gate / invariant | Quy tắc | Test |
|---|---|---|
| G2 (placement hợp lệ mới vào cảng) | §9 `validate()` | INV-32 |
| G4 (Manifest 1x1, chỉ nhặt sau placement hợp lệ, không auto-seal/Archive) | §4.2.2–3, §5.9 | INV-01, INV-15, INV-26, INV-35 |
| G8 (đặt/di chuyển/xoay, sai giữ nguyên + lý do, không auto) | §4 | INV-02…INV-14, INV-22, INV-31, INV-34 |
| G10 (Hộp chỉ nhận niêm hợp lệ, đầy/sai loại giữ nguồn, tự nhường chỗ) | §5 | INV-15…INV-21, INV-33 |
| G17 / invariant 8.6 (ba nhóm giữ/mất/unrecovered) | §6.3 | INV-27, INV-28 |
| Invariant 8.5 (không auto-drop/swap/sort/seal) | §4.1.3 | INV-22, INV-31 |

## 13. Ngoài phạm vi và câu hỏi mở

- Ngoài phạm vi: layout/visual O3/O4, chuỗi hiển thị cuối, giá/giá-ô, stack cap final, tách stack, equip/swap gear, loadout và kho hub, dùng nhanh từ túi đeo chéo, save format.
- Câu hỏi mở (không chặn spec): khi người chơi bỏ `manifest_r17` xuống đất trong raid, contract/beacon A phản ứng thế nào? Spec này chỉ phát `evidence_carried_changed(manifest_r17, false)`; phản ứng thuộc spec contract/extract.
