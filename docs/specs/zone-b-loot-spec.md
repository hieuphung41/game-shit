# Spec hệ thống — Loot cache B: chọn món, footprint/xoay/stack/claim, nhặt và bỏ qua (S03)

**Trạng thái:** spec `proposed` cho gameplay-engineer và ui-programmer (TASK-89). Đầu vào cho ux-designer (TASK-83:
layout card/lưới) và narrative (TASK-84: chữ). Mọi id, con số, tên lớp và hành vi dưới đây là `proposed`, trừ khi ghi
nguồn. Spec **không** chốt giá tiền, drop table, stack cap cuối, bán/craft, chữ hiển thị hay layout.

**Nguồn luật (ưu tiên khi spec này khác):** [Vertical slice](../vertical-slice.md) Beat 4, §4.2 ·
[Build-readiness](../vertical-slice-build-readiness.md) G7, G8, G10, G15 ·
[Item Cảng Hắc Thuế](../items/black-tax-port-items.md) #14, #16 ·
[Inventory spec](inventory-grid-slice-spec.md) §3–§7, §8.3 · [Inventory/loadout](../systems/inventory-and-loadout.md) §6 ·
[UX vòng A](loop-a-ux-flow-spec.md) §4.2–§4.3, §5.4–§5.5 · [Layout B](zone-b-layout-encounter-spec.md) §5.4, `CacheB` ·
[Beacon/extract](beacon-extract-state-spec.md) §10.4 · [Combat](combat-slice-spec.md) §3.6 · [Chuỗi Contract 1](contract-1-strings.md).

## 1. Mục đích (người chơi thấy gì)

Sau khi qua gate B, Người Thu Hồi (`retriever`) tới vùng yên `CalmZoneB` và gặp **cache B** (`cache_b`, node `CacheB`:
rương tịch thu của trạm thuế). Cache có **hai món** nhỏ, chọn từ bộ item có sẵn. Mỗi món có một card đọc nhanh. Người chơi
đọc card, rồi **tự** chọn: nhặt vào ba lô, niêm thẳng vào Hộp Công Chứng (`notary_box`), hoặc `Bỏ qua`. Bài học của Beat 4:

1. **footprint**: 1 ô và 2 ô; món 2 ô xoay được;
2. **claim** tách khỏi **lớp thẩm định**: hai món cùng claim Hắc Thuế nhưng khác lớp;
3. Hộp 2x2 ít ô. Món 1x2 không vừa Hộp sau khi Manifest đã niêm, còn món 1x1 vẫn vừa;
4. bỏ qua loot là hợp lệ. Rút sớm không bị phạt (vertical slice §4.1).

Hệ thống không tự nhặt, tự xếp, tự niêm hay tự bỏ món nào. Đóng/hủy không đổi gì; món chưa nhặt vẫn nằm trong cache.

## 2. Khái niệm mới và code identifier

| Khái niệm (VI) | code | Nghĩa |
|---|---|---|
| Cache B | `cache_b` (node `CacheB`) | Thùng loot cố định ở mép tây `CalmZoneB` (layout B §5.4). |
| Định nghĩa cache | `LootCacheDef` (`Resource`) | Danh sách món cố định của một cache (§5.1). |
| Cache runtime | `LootCache` (`RefCounted`) | Các món còn trong cache trong run hiện tại. Món là `ItemInstance` có `item_location = ground`, do world giữ (inventory spec §9 "Ground"). |
| Trạng thái cache | `cache_state` | `full` / `partial` / `empty` (§6.1). |
| Phiên cache | `cache_session` | Thời gian overlay cache mở: `card` hoặc `pickup` (§6.2). |
| Kết quả vừa ô | `fit_backpack`, `fit_notary_box` | Gợi ý trên card, tính thuần từ `preview_pickup` (§7.2). |
| Đồng Thuế Cạo Mặt | `scraped_tax_coin` | Item #14. Valuable 1x1, xếp chồng được. |
| Sổ Kho Ngấm Nước | `waterlogged_stock_ledger` | Item #16. Valuable 1x2, xoay được (§3.2). |

Hai id item là mới, chưa có trong glossary (đề xuất thêm: §11). Id phe dùng `house_hac_thue` như `manifest_r17`.

## 3. Chọn món và lý do

### 3.1 Bảng chọn

| # catalogue | Món | Vì sao chọn | Nguồn hợp lý ở B |
|---:|---|---|---|
| 14 | **Đồng Thuế Cạo Mặt** | Món `1x1`, vừa ô Hộp cuối cùng sau Manifest. Có claim Hắc Thuế rõ. Xếp chồng được, nên card có số lượng. | Items #14: "B/booth thuế; phí lẻ bị gom". Cache là rương tịch thu của trạm (layout B). |
| 16 | **Sổ Kho Ngấm Nước** | Món `1x2`, dạy xoay. Không vừa Hộp khi Manifest đã niêm. Lớp Xanh dương, cao hơn đồng xu, nhưng giá trị/ô không vì thế mà cao hơn. | Items #16: "B/D; registry phụ bị ném khỏi kho khi khám thuế". |

### 3.2 Món không chọn và đổi so với gợi ý của card task

1. **#12 Đèn Phao Vỡ** không được chọn. Lý do: card item ghi nguồn "A/D" (đèn tháo khỏi phao). Đặt nó trong rương của trạm
   thuế B là sai provenance (checklist items §6 câu 3). Thêm món này cũng không dạy được gì mà #14 chưa dạy (cùng `1x1`,
   cùng niêm được, cùng xếp chồng được).
2. Cache chỉ có **hai** món, mức thấp của khoảng 2–3. Hai món đã đủ cả ba yêu cầu (1x1, 1x2 xoay được, có claim). Như vậy
   card ít chữ hơn trên mobile và cache dạy đúng một quyết định Hộp (§8.2).
3. **`rotatable = true` cho #16:** card #16 không ghi "(xoay)". Đây là đề xuất của spec này, giữ theo ứng viên
   `fixture_b_small_1x2` (inventory spec §8.3, `rotatable = true`). Sổ không có hướng đọc bắt buộc trong lưới. Không có
   1x2 xoay được nào khác có nguồn ở B mà không kéo theo gear, ammo hay Local Story: #18/#19/#20 thuộc A/C/D, #21 là vũ khí,
   #23 là ammo không niêm được. Cần sửa card #16 trong `black-tax-port-items.md` cho khớp (§11, ngoài `writes` của task).
4. Không món nào là `evidence`. Sổ Kho **không** phải vật chứng Contract (items #16: "không main evidence"). Vì vậy
   không phát `evidence_carried_changed` và không có badge vật chứng.

## 4. Dữ liệu `ItemDef` (chỉ field có trong `item_def.gd`)

| Field | `scraped_tax_coin` | `waterlogged_stock_ledger` | Nguồn / ghi chú |
|---|---|---|---|
| `id` | `&"scraped_tax_coin"` | `&"waterlogged_stock_ledger"` | Mới, `proposed`. |
| `display_name_key` | `&"ITEM_SCRAPED_TAX_COIN_NAME"` | `&"ITEM_WATERLOGGED_STOCK_LEDGER_NAME"` | Chữ do TASK-84 viết. |
| `display_name_vi` (fallback) | `Đồng Thuế Cạo Mặt` | `Sổ Kho Ngấm Nước` | Tên catalogue #14/#16. |
| `size` | `Vector2i(1, 1)` | `Vector2i(1, 2)` (đứng) | Items #14/#16. |
| `rotatable` | `false` (vuông: bỏ qua, inventory §3.6) | **`true`** `proposed` | §3.2.3. |
| `sealable` | `true` | `true` | Items: "Niêm phong **Có**". |
| `stackable` | `true` | `false` | Items: #14 "xếp chồng được"; #16 "không xếp chồng". |
| `stack_max` | **3** `proposed` (giá trị fixture, không phải cap cuối) | 1 | Cùng giá trị fixture `fixture_b_small_1x1`. |
| `item_category` | `VALUABLE` | `VALUABLE` | #14 "Valuable gọn". #16 "tài sản đăng ký", không phải evidence. |
| `claim_id` | `&"house_hac_thue"` | `&"house_hac_thue"` | #14 "Hắc Thuế". #16 "Hắc Thuế có claim; bốc vác đọc được mã lô": claim chính là Hắc Thuế. |
| `appraisal_class` | **2** (Xanh lá) | **3** (Xanh dương) | Items #14/#16. |

`ItemRegistry.validate_defs()` phải trả rỗng cho cả hai (valuable được niêm; không phải evidence nên được stack).
Fixture test `fixture_b_small_1x1` / `fixture_b_small_1x2` **giữ nguyên** cho unit test inventory. Cache B trong map dùng
hai id thật ở trên, không dùng fixture.

## 5. Nội dung cache

### 5.1 `LootCacheDef` của `cache_b`

| Field | Kiểu | Giá trị `proposed` |
|---|---|---|
| `cache_id` | `StringName` | `&"cache_b"` |
| `entries` | `Array[Dictionary]` `{order: int, def_id: StringName, quantity: int}` | `{1, &"scraped_tax_coin", 2}`, `{2, &"waterlogged_stock_ledger", 1}` |

Ràng buộc khi load (lỗi dev, không phải lỗi người chơi): `def_id` có trong registry; `1 ≤ quantity ≤ stack_max`;
`order` duy nhất. Mỗi entry tạo **đúng một** `ItemInstance` (`rotated = false`, uid mới duy nhất trong run). Đồng xu là
**một** stack qty 2, không phải hai món rời. Vì vậy trong S03 không cần lệnh `stack` (không có món thứ hai cùng `def_id`).

### 5.2 Quy tắc nội dung

1. Nội dung cố định, không random, không drop table (vertical slice §2: "fixed tutorial loot fixtures").
2. Mỗi **run mới** nạp lại cache từ `LootCacheDef`. Trong một run, món đã nhặt không quay lại cache. Slice không lưu run
   nên không thể farm qua save.
3. Thứ tự hiển thị theo `order` tăng dần, chỉ tính các món còn lại.

## 6. States và transitions

### 6.1 `cache_state` (thế giới)

```text
full    --nhặt ok, còn món-->         partial
full    --nhặt ok, hết món-->         empty
partial --nhặt ok, hết món-->         empty
mọi state --mở card / Bỏ qua / Đóng / hủy / lỗi--> giữ nguyên
[run mới] --> full
```

`empty` là state cuối trong run. `cache_state` có để visual biết (vd. nắp mở). Hình dáng do art quyết, ngoài spec.

### 6.2 `cache_session` (overlay)

```text
closed --chạm CacheB (cache_state != empty, trong tầm)--> card(i = món còn lại đầu tiên)
card(i) --Bỏ qua--> card(món còn lại kế sau i) | closed nếu i là món cuối
card(i) --Nhặt và xếp--> pickup(i)
card(i) --Đóng / Back / ra ngoài tầm / chết--> closed
pickup(i) --chạm ô hợp lệ: commit_pickup ok--> card(món còn lại đầu tiên) | closed nếu cache empty
pickup(i) --chạm ô không hợp lệ / commit fail--> pickup(i) (state không đổi, hiện lý do)
pickup(i) --Đóng / Back--> card(i)
pickup(i) --ra ngoài tầm / chết--> closed (không commit)
```

1. `Bỏ qua` không quay vòng. Đến món cuối thì overlay đóng. Mở lại cache thì bắt đầu từ món còn lại đầu tiên.
2. `Đóng` trong `pickup` quay về card của cùng món, giống `Đóng` của panel Manifest không mở lại bàn (UX vòng A §5.5.4).
   Lý do: người chơi vẫn đứng ở cache và có thể chọn `Bỏ qua`. TASK-83 được phép gộp card và lưới vào một panel nếu vẫn
   giữ đúng các transition trên.
3. Chỉ một phiên mở mỗi lúc. Khi phiên mở, gọi `RetrieverCombat.set_overlay_open(true)` (combat §3.6); đóng thì `false`.

## 7. Card loot (G7)

### 7.1 Thứ tự thông tin (bắt buộc, trên xuống)

| Dòng | Nội dung | Dữ liệu | Key (chữ: TASK-84) |
|---:|---|---|---|
| 1 | Silhouette + tên (+ `×{quantity}` nếu `quantity > 1`) | `display_name_key`, `ItemInstance.quantity` | `CARD_<ID>_NAME` |
| 2 | Footprint + ô trống: sơ đồ ô `w×h` + chữ; tag `xoay được` (nếu `rotatable` và không vuông), `xếp chồng được`, `niêm được`; ba lô còn `{free}/12` ô; `fit_backpack`, `fit_notary_box` (§7.2) | `size`, `rotatable`, `stackable`, `sealable`, `backpack.free_cell_count()` | `CARD_<ID>_FOOTPRINT` |
| 3 | Công dụng + giá ước lượng **tương quan** | §7.3 | `CARD_<ID>_USE` |
| 4 | Claim: icon phe + tên phe | `claim_id` | `CARD_<ID>_CLAIM` |
| 5 | Lớp thẩm định: chữ + dấu bậc `n/6` (không chỉ màu) | `appraisal_class` | `CARD_<ID>_RARITY` |
| 6 | Một dòng lore | — | `CARD_<ID>_LORE` |
| nút | `Nhặt và xếp` · `Bỏ qua` · `Đóng` | — | `CARD_ACTION_PICK_AND_PLACE`, `CARD_ACTION_SKIP`, `CARD_ACTION_CLOSE` (đã có) |

`<ID>` = `SCRAPED_TAX_COIN` / `WATERLOGGED_STOCK_LEDGER`. Claim, rarity và footprint mỗi thứ có cue ngoài màu: icon,
chữ, dấu bậc, sơ đồ ô (G7). Màu rarity không tô lên icon claim. Không có badge vật chứng (§3.2.4).

### 7.2 Gợi ý vừa ô (tính thuần, không đổi state)

1. `fit_backpack`: gọi `preview_pickup(item, backpack, a, r)` cho mọi anchor `a`, `r ∈ {false, true}` (chỉ `true` nếu
   `rotatable` và không vuông).
   - `fits`: có anchor hợp lệ với `r = false`;
   - `fits_rotated_only`: chỉ hợp lệ khi `r = true`;
   - `no_fit`: không anchor nào hợp lệ.
2. `fit_notary_box`: tương tự trên Hộp → `fits` / `no_fit`. Nếu `sealable == false` thì là `not_sealable`. Không món
   nào của cache B rơi vào trường hợp này.
3. Đây chỉ là chữ/icon trên card. Card **không** tự chọn ô và không có nút "đặt vào chỗ gợi ý" (UX vòng A §5.5.5).

### 7.3 "Giá ước lượng" là tương quan, không phải số tiền

1. Không có field giá, không có số tiền, không có "giá/ô" bằng số trên card hay ở S10.
2. Hướng dẫn cho TASK-84 (nội dung, không phải chữ cuối):
   - Đồng Thuế: **gọn**, 1 ô, đáng giữ theo ô; claim rõ của Hắc Thuế.
   - Sổ Kho: **gọn vừa**, 2 ô; là tài sản đăng ký, không phải vật chứng Contract.
   - Không câu nào được nói lớp cao hơn nghĩa là đáng giá hơn (G7). Câu prompt Beat 4 vẫn đúng: "Màu không quyết định
     giá trị/ô; xem kích thước và công dụng."
3. Dòng công dụng không hứa tính năng không có trong slice (bán, turn-in, vendor). Nó chỉ được nói món về kho khi extract.

## 8. Luật nhặt, niêm, bỏ qua

### 8.1 Đích được phép (S03, chế độ `pickup` từ cache)

| Nguồn → đích | Lệnh | Kết quả |
|---|---|---|
| Cache → ba lô | `commit_pickup(item, backpack, anchor, rotated)` | Được. |
| Cache → Hộp | `commit_pickup(item, notary_box, anchor, rotated)` | Được. Đây là **niêm** (inventory §5.1; như Manifest ở UX vòng A §4.3). Không O5. Nhãn `đã niêm`. |
| Cache → túi đeo chéo | — | `WRONG_TARGET` (`sai loại`). |
| Ba lô → Hộp (sau, ở `view`) | `commit_seal` | Được, không O5 (luật S02). |
| Hộp → ba lô | — | **Khóa** ở S03: `INVENTORY_REASON_WITHDRAW_LOCKED` (luật S02; S04 thêm O5). |
| Ba lô → cache / ground (bỏ món) | — | Không có affordance ở S03 (bỏ món cần O5, S04). |

### 8.2 Quy tắc

1. **Nhặt từng món:** mỗi `commit_pickup` chuyển đúng một `ItemInstance` (cả stack qty 2 của đồng xu). Không có
   "nhặt tất cả".
2. **Xoay khi nhặt:** ở `pickup`, món `rotatable` không vuông có một nút bật/tắt xoay. Bật/tắt chỉ đổi `rotated` của
   preview rồi đánh dấu lại ô (gọi lại `preview_pickup`), **không** đổi state. Đồng xu (vuông) không có nút xoay. Xoay
   món đã ở trong lưới ở chế độ `view` dùng `commit_rotate` / `commit_move(…, rotated)` (G8, S03). Layout do TASK-83.
3. **Commit fail:** món vẫn ở cache, ba lô/Hộp/túi không đổi, hiện nhãn `InventoryReason` đầu tiên (inventory §7) và
   viền `blocking_cells`.
4. **Commit ok:** `LootCache` bỏ đúng uid đó. Phát `item_placed`. Không phát `evidence_carried_changed`. Các món còn lại
   trong cache không đổi.
5. **`Bỏ qua` hợp lệ:** không đổi state, không có hậu quả, không có câu trách. Đóng mọi thứ mà không nhặt gì vẫn thỏa
   Beat 4 ("player chọn `Bỏ qua` từ card").
6. **Đóng/hủy:** `Đóng`, Back, ra ngoài tầm cache (`CACHE_INTERACT_RADIUS_M` **1.5** `proposed`, cùng giá trị
   `BOARD_ZONE_RADIUS_M`), gián đoạn app hay chết đều không gọi commit nào. Đồ còn trong cache giữ nguyên.
7. **Không tự động:** không auto-sort, auto-seal, auto-drop, auto-swap, auto-stack. Không tự mở `pickup` cho món kế tiếp.
   Không tự chuyển sang Hộp khi ba lô đầy (inventory §4.1.3).
8. **Một quyết định Hộp:** Hộp mặc định có `starter_remedy` 1x2 tại (0,0), còn (1,0),(1,1).
   - Manifest đã niêm (ở (1,0) hoặc (1,1)): còn đúng 1 ô. Đồng xu vừa; Sổ Kho **không** vừa ở mọi anchor/hướng.
   - Manifest ở ba lô: Sổ Kho vừa Hộp khi đứng tại (1,0). Đồng xu vừa (1,0) hoặc (1,1). Không thể niêm cả hai món cùng
     Manifest.
   - Hộp → ba lô bị khóa ở S03, nên niêm là quyết định cho cả run. Đó là luật S02, spec này không đổi.
9. Patrol về A kích hoạt khi rời `CalmZoneB`, độc lập với cache (layout B §5.5). Cache không gate gì, không phải điều
   kiện extract.

## 9. Kiểm sức chứa và ví dụ sắp chỗ

### 9.1 Sức chứa với starter kit + Manifest (S03)

- Ba lô đầu run rỗng (inventory §8.4). Sau Manifest + cả cache: tối đa 1 (Manifest) + 1 (đồng xu) + 2 (sổ) = **4/12 ô**.
- Trong S03, ba lô 3x4 **luôn** chứa được cả cache cùng Manifest. Lối D bị chặn (layout B §5.4) nên không có cargo.
  Không cần sort. Không bao giờ xảy ra "không vừa ở đâu cả" trong S03.

### 9.2 Ví dụ cần xoay `1x2` (tại ô người chơi chọn)

Người chơi muốn đặt Sổ Kho ở hàng đáy ba lô (y = 3), để chừa cột trên:

| Lệnh | Footprint | Kết quả |
|---|---|---|
| `commit_pickup(ledger, backpack, (0,3), false)` | (0,3),(0,4) | `OUT_OF_BOUNDS` (`không vừa`); sổ vẫn ở cache. |
| `commit_pickup(ledger, backpack, (0,3), true)` | (0,3),(1,3) | `ok`. |

### 9.3 Ví dụ chỉ vừa khi xoay (fixture test; layout thật khi D mở ở sprint sau)

Món trong cache còn ở cache khi đóng (§8.2.6). Vì vậy người chơi có thể mở cache lúc quay từ D về. Fixture ba lô:

| Món | anchor | `rotated` | Ô chiếm |
|---|---|---|---|
| `cargo_d_2x2` | (0,0) | false | (0,0),(1,0),(0,1),(1,1) |
| `tax_stamp_d` (1x2) | (2,1) | false | (2,1),(2,2) |
| `manifest_r17` | (0,2) | — | (0,2) |
| `scraped_tax_coin` ×2 | (1,2) | — | (1,2) |

Ô trống: (2,0),(0,3),(1,3),(2,3). Không cặp nào xếp dọc → `fit_backpack = fits_rotated_only`. `suggest_slot` trả
`{anchor (0,3), rotated true}`.

### 9.4 Trường hợp không vừa → `InventoryReason`

| Given | Lệnh | Lý do |
|---|---|---|
| Layout §9.3 | `commit_pickup(ledger, backpack, (2,0), false)` | `CELLS_OCCUPIED` (`thiếu ô`), `blocking_cells = [(2,1)]` |
| Ba lô rỗng | `commit_pickup(ledger, backpack, (x,3), false)`, x ∈ 0..2 | `OUT_OF_BOUNDS` (`không vừa`) |
| Hộp: `starter_remedy` (0,0) đứng + `manifest_r17` (1,0) | `commit_pickup(ledger, notary_box, a, r)` với mọi `a`, `r` | `CELLS_OCCUPIED` (footprint trong biên) hoặc `OUT_OF_BOUNDS` (ra biên); không lần nào `ok` |
| Bất kỳ | `commit_pickup(item, sling_pouch, (0,0), false)` | `WRONG_TARGET` (`sai loại`) |

Mọi dòng: món vẫn ở cache, `snapshot()` của inventory và nội dung cache không đổi.

## 10. Kết thúc run

1. **Extract (S10):** `resolve_extract()` (inventory §6.3) đưa mọi non-evidence ở ba lô/túi/Hộp vào `to_hub`.
   `ExtractSummary.kept` vì thế liệt kê đồng xu và/hoặc Sổ Kho **nếu và chỉ nếu** người chơi đã nhặt (ở ba lô hay Hộp
   đều được), trong nhóm `Đã giữ`, cùng `starter_remedy` và vật hồi phục ở túi. `manifest_r17` ở `Vật chứng`, không ở
   `Đã giữ`.
2. Món còn trong cache khi rời B **không** hiện ở S10: không ở `Đã giữ`, không ở `Đã mất`. Lý do: chúng chưa từng có trong
   `carried_ever` (beacon §10.4). Ở S03 không có cách bỏ món đã nhặt, nên cache không đóng góp gì vào `Đã mất`.
3. S10 không có giá, tổng giá trị hay nút bán (G15, beacon §10.4). Mỗi uid một dòng. Hiện `×2` cho đồng xu cần field
   `quantity` trong `kept`, beacon spec hiện chưa có. Mặc định: chỉ hiện tên (§11).
4. **Chết ở S03:** theo quyết định tạm của Producer (TASK-80), S03 gọi `notify_death()`, không gọi `resolve_death()`,
   overlay đóng như hủy, rồi về Boot. Nhóm giữ/mất của S11 (món niêm là `kept`, ba lô là `lost`) theo inventory §6.3 khi
   S11 được làm.

## 11. Ngoài phạm vi và câu hỏi mở

- **Ngoài phạm vi:** chữ hiển thị (TASK-84), layout card/lưới/nút xoay (TASK-83), cargo 2x2/D, Hộp nâng cao/rút đồ/bỏ
  món (S04), giá tiền, drop table, stack cap cuối, bán/craft/turn-in, art cache.
- **Cần cập nhật ngoài `writes`:**
  1. Glossary: thêm `cache_b`, `scraped_tax_coin`, `waterlogged_stock_ledger`.
  2. `black-tax-port-items.md` #16: thêm "(xoay)".
- **Câu hỏi mở (không chặn):** S10 có hiện số lượng (`×2`) không? Nếu có, `ExtractSummary.kept` cần thêm
  `quantity: int` (beacon spec §10.4). Mặc định không thêm, S10 chỉ hiện tên.

## 12. Acceptance tests (given / when / then)

Tên test: `test_zbl_xx_<mô_tả_ngắn>`. "Không đổi" = `snapshot()` inventory + danh sách uid/qty của `LootCache` bằng nhau
trước/sau, và không có signal. Hộp mặc định = `starter_remedy` tại (0,0) đứng.

| ID | Given | When | Then |
|---|---|---|---|
| ZBL-01 | Registry có hai def §4 | `validate_defs()` | Trả rỗng. `scraped_tax_coin`: size (1,1), stackable, `stack_max` 3, claim `house_hac_thue`, class 2, `VALUABLE`, sealable. `waterlogged_stock_ledger`: size (1,2), rotatable, không stackable, class 3, `VALUABLE`, sealable. |
| ZBL-02 | Run mới | Load zone B | `cache_b` có đúng 2 `ItemInstance` theo thứ tự [đồng xu qty 2, sổ qty 1]. Cả hai `item_location = ground`, `rotated = false`, uid khác nhau. `cache_state = full`. Không def nào là `evidence`. |
| ZBL-03 | Ba lô rỗng, Hộp mặc định + Manifest (1,0) | Mở card đồng xu | Thứ tự dòng: NAME (`×2`) → FOOTPRINT → USE → CLAIM → RARITY → LORE. Không có tag `xoay được`. `free = 12`, `fit_backpack = fits`, `fit_notary_box = fits`. Không có badge vật chứng, không có field giá. |
| ZBL-04 | Như ZBL-03 | Mở card sổ | FOOTPRINT có `xoay được`, `niêm được`. `fit_notary_box = no_fit`. RARITY bậc 3/6, CLAIM cùng phe với đồng xu. |
| ZBL-05 | Cache `full` | Mở card, rồi `Đóng` | Không đổi. `cache_state = full`. `set_overlay_open` true rồi false. |
| ZBL-06 | Cache `full` | `Bỏ qua` (đồng xu), rồi `Bỏ qua` (sổ) | Card thứ hai là sổ. Sau lần hai overlay `closed`. Không đổi. Mở lại → card đồng xu. |
| ZBL-07 | Ba lô rỗng | `Nhặt và xếp` đồng xu → chạm (0,0) | `ok`. Đồng xu qty 2 ở ba lô (0,0). Cache còn [sổ], `cache_state = partial`. Đúng 1 `item_placed`. Không có `evidence_carried_changed`. Overlay về card sổ. |
| ZBL-08 | Ba lô rỗng | Pickup sổ, `rotated = false`, anchor (0,3) | `OUT_OF_BOUNDS`. Sổ vẫn ở cache. Không đổi. Vẫn ở `pickup`. |
| ZBL-09 | Đồng xu đã niêm trong Hộp; ba lô rỗng; cache chỉ còn sổ (`partial`) | Bật xoay (preview) rồi pickup sổ tại (0,3) | Bật xoay không đổi state. Pickup `ok`, chiếm (0,3),(1,3). `cache_state = empty`, overlay `closed`. |
| ZBL-10 | Hộp mặc định + Manifest (1,0); sổ ở cache | `commit_pickup(sổ, notary_box, a, r)` với mọi a ∈ {(0,0),(1,0),(0,1),(1,1)}, r ∈ {false, true} | Không lần nào `ok`. Lý do là `CELLS_OCCUPIED` hoặc `OUT_OF_BOUNDS` theo §9.4. Sổ vẫn ở cache. Hộp không đổi. |
| ZBL-11 | Như ZBL-10, đồng xu ở cache | `commit_pickup(đồng xu, notary_box, (1,1), false)` | `ok`. `seal_label = sealed` (`đã niêm`). Hộp đầy 4/4. |
| ZBL-12 | Hộp mặc định; Manifest ở ba lô | `commit_pickup(sổ, notary_box, (1,0), false)` | `ok`, sổ chiếm (1,0),(1,1), nhãn `đã niêm`. Sau đó `commit_seal(manifest, a, r)` mọi anchor → fail. Manifest ở lại ba lô. |
| ZBL-13 | Đồng xu đã niêm trong Hộp | Chế độ `view`: chọn đồng xu, chạm ô ba lô trống | Không commit. Lý do `INVENTORY_REASON_WITHDRAW_LOCKED`. Không đổi. |
| ZBL-14 | Fixture ba lô §9.3; sổ ở cache | Tính `fit_backpack`; `suggest_slot(&"waterlogged_stock_ledger", 1)`; `commit_pickup(sổ, backpack, (2,0), false)` | `fits_rotated_only`. `{(0,3), true}`. `CELLS_OCCUPIED` với `blocking_cells = [(2,1)]`, không đổi. |
| ZBL-15 | Bất kỳ món cache | `commit_pickup(item, sling_pouch, (0,0), false)` | `WRONG_TARGET`. Không đổi. |
| ZBL-16 | `pickup` sổ đang mở | Người chơi đi ra ngoài 1.5 m quanh `CacheB` | Overlay `closed`. Không commit. Không đổi. |
| ZBL-17 | `pickup` đồng xu đang mở | HP người chơi về 0 | Overlay đóng như hủy. Không commit. Cache còn đồng xu. |
| ZBL-18 | Cache `empty` | Chạm `CacheB` | Không mở overlay. `cache_state` vẫn `empty`. |
| ZBL-19 | Cache `empty` ở run trước | Bắt đầu run mới | `cache_b` lại `full`, đúng như ZBL-02. |
| ZBL-20 | Đồng xu ở ba lô, sổ niêm trong Hộp, Manifest ở ba lô | Extract thành công (`board()`) | `kept` có uid của đồng xu và sổ (cùng `starter_remedy`, vật hồi phục túi). `evidence = [manifest_r17]`. `lost` rỗng. `to_dict()` không có field giá/điểm. |
| ZBL-21 | Không nhặt gì ở cache (`Bỏ qua` hết) | Extract thành công | `kept` không chứa `scraped_tax_coin` hay `waterlogged_stock_ledger`. `lost` rỗng. |
| ZBL-22 | Ba lô có 1 món; cache `full` | Pickup đồng xu ok, rồi pickup sổ ok | Mỗi commit chỉ đổi đúng một món. Món cũ trong ba lô giữ `anchor`/`rotated`. Không gọi `commit_sort`/`commit_seal`/`commit_swap` nào ngoài lệnh người chơi chạm. |

## 13. Truy vết tới gate

| Gate | Quy tắc | Test |
|---|---|---|
| G7 — card loot B (1x1/1x2 + claim, thứ tự, cue ngoài màu) | §3, §4, §7 | ZBL-01…04 |
| G8 — grid (đặt/xoay hợp lệ, sai giữ nguyên + lý do, đóng không đổi) | §8.2, §9 | ZBL-05…09, 14…17, 22 |
| G10 — Hộp (niêm hợp lệ, đầy giữ nguồn, không auto-swap) | §8.1, §8.2.8 | ZBL-10…13 |
| G15 — S10 `Đã giữ`, không giá | §10 | ZBL-20, ZBL-21 |
| Vertical slice Beat 4 (nhặt hoặc `Bỏ qua` đều hợp lệ) | §8.2.5 | ZBL-06, ZBL-21 |
