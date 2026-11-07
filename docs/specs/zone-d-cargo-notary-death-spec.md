# Spec luật S04 — Cargo/Dấu Thuế ở Kho Nổi D, Hộp không auto-swap, bỏ/rút đồ có O5, Phù Hiệu Hồi Hương và S11

**Trạng thái:** spec luật `proposed` cho gameplay-engineer (TASK-100/101/102), ux-designer (TASK-97) và narrative
(TASK-98). Mọi con số, tên lớp/hàm/signal, node và key `KEY_MỚI?` trong file này đều `proposed`. Spec không chốt bố cục
D (đã có ở [layout D](zone-d-layout-encounter-spec.md)), layout màn hình, chữ cuối, giá tiền hay economy.

**Nguồn luật (nguồn thắng khi spec này khác):** [Vertical slice](../vertical-slice.md) Beat 5, §4.2, §4.3 ·
[Wireflow](../vertical-slice-wireflow.md) S5, O3, O4, O5, S10, S11 · [Build-readiness](../vertical-slice-build-readiness.md)
G9, G10, G11, G15, G16, G17, invariant §8.5–8.6 · [D cargo brief](../maps/black-tax-port-d-cargo-choice-brief.md) ·
[Spec lưới ba lô/Hộp](inventory-grid-slice-spec.md) · [Spec beacon/extract](beacon-extract-state-spec.md) ·
[Spec loot B](zone-b-loot-spec.md) · [Spec combat](combat-slice-spec.md) §3.5, §4.4 ·
[Chữ Contract 1](contract-1-strings.md) · [Item Cảng Hắc Thuế](../items/black-tax-port-items.md).

**Quyết định Producer đã chốt cho S04 (không mở lại):**

1. G11 ở S04 = **bỏ đồ** (ba lô → đất) và **rút đồ niêm** (Hộp → ba lô), cả hai qua O5. Đổi gear / vào run không vũ khí
   **không áp dụng ở slice** (không có gear dự phòng). O1 vẫn chỉ sắp lại trong cùng ngăn (decision TASK-70).
2. HP 0 ở S04 = Phù Hiệu Hồi Hương (`recall_sigil`) thật: gọi `resolve_death()`, không `resolve_extract()`, rồi S11.
   Stub S03 ([combat §4.4](combat-slice-spec.md)) thôi dùng.
3. S11 sau Manifest **không** có S12/Recovery chơi được (S05 làm): một nút về màn đầu, không lưu. S11 trước Manifest:
   `Chuẩn bị lại` → briefing, Contract 1 vẫn active, run mới.
4. Không save/persist: mọi thứ reset khi về Boot/briefing.

## 1. Mục đích (người chơi thấy gì)

Ở Kho Nổi D, Người Thu Hồi (`retriever`) thấy hai món: một kiện cargo `2x2` cồng kềnh và `Dấu Thuế` `1x2` gọn. Card cho
biết món nào chiếm bao nhiêu ô, tổng giá trị ước lượng và giá trị theo ô. Người chơi tự chọn: mang cargo, lấy Dấu Thuế,
hoặc bỏ cả hai. Lựa chọn nào cũng quay về B → A được, không có phạt tốc độ hay trọng lượng.

Hộp Công Chứng (`notary_box`) không bao giờ tự đổi chỗ món. Muốn niêm Dấu Thuế khi Hộp đã có thuốc `1x2` và Manifest,
người chơi phải tự **rút** một món ra ba lô (qua O5), rồi mới niêm. Bỏ một món xuống đất cũng qua O5; món nằm lại tại chỗ
và nhặt lại được trong run.

Khi HP về 0, **Phù Hiệu Hồi Hương** kích hoạt. Màn S11 tách ba nhóm: đồ niêm thường `Đã giữ`, đồ không niêm `Đã mất`,
Manifest ở `Vật chứng` (`ở bàn A` nếu chưa nhặt, `chưa thu hồi` nếu đã nhặt). Chết không bao giờ là extract.

## 2. Khái niệm mới và code identifier `proposed`

| Khái niệm (VI) | code | Nghĩa |
|---|---|---|
| Vải Cứu Trợ Đổi Nhãn (cargo D) | `cargo_d_2x2` | Cargo `2x2` ở D, gắn card items #11. Giữ id cũ vì test INV và `source_id` layout D đã dùng. |
| Dấu Thuế (fixture D) | `tax_stamp_d` | Món gọn `1x2` ở D. Tên fixture của D brief, không phải card catalogue (§3.2). |
| Nguồn cargo D | `source_cargo_d` (node `CargoD`) | `LootCacheDef` một món: `cargo_d_2x2` ×1. |
| Nguồn Dấu Thuế D | `source_tax_stamp_d` (node `TaxStampD`) | `LootCacheDef` một món: `tax_stamp_d` ×1. |
| Giá trị ước lượng tương đối | `relative_value_total` | Số nguyên không đơn vị trên `ItemDef`, chỉ để so trên card. `0` = không hiện. |
| Giá trị theo ô | `relative_value_per_cell` | `relative_value_total / (size.x * size.y)`, tính, không lưu. |
| Đồ bỏ dưới đất | `ground_drop` (node `GroundDrop`) | Một `ItemInstance` nằm ở đất sau `commit_drop` ok. Nhặt lại được trong run. |
| O5 của inventory | `inventory_confirm` | O5 cho bỏ đồ (`kind = drop`) hoặc rút đồ niêm (`kind = withdraw`). |
| Kích hoạt Phù Hiệu | `recall_sigil` | Chuỗi chết thật của S04: khóa input → `notify_death` → `resolve_death_summary` → S11. |
| Tổng kết chết | `DeathSummary` | Dữ liệu cho S11 (§7.4). |
| Biến thể S11 | `death_variant` | `before_manifest` / `after_manifest`. |
| Lý do mất | `lost_reason` | `unsealed` (còn trong ba lô/túi lúc chết) / `left_behind` (đã bỏ xuống đất, chưa nhặt lại). |

## 3. Item D

### 3.1 Bảng `ItemDef` (đủ cột như inventory spec §8.3)

| `id` | Tên / vai trò | `size` | `rotatable` | `sealable` | `stackable` / `stack_max` | `item_category` | `claim_id` | `appraisal_class` | `relative_value_total` | Giá trị/ô | Nguồn / ghi chú |
|---|---|---|---|---|---|---|---|---|---:|---:|---|
| `cargo_d_2x2` | **Vải Cứu Trợ Đổi Nhãn** — kiện vải trắng bẩn, nhãn thuế dán chồng lên chữ cứu trợ | (2,2) | n/a (vuông) | **false** | false / 1 | `CARGO` | `house_hac_thue` | 1 (Trắng) | **8** `proposed` | **2** | Items #11: `2x2` · Trắng · Niêm **Không** · nguồn D/B. |
| `tax_stamp_d` | **Dấu Thuế** — con dấu thuế dẹt dài, nằm trên bàn cân D | (1,2) | **true** | **true** | false / 1 | `VALUABLE` | `house_hac_thue` | 1 (Trắng) | **6** `proposed` | **3** | D brief §1 (`1x2`); vertical slice Beat 5 (niêm được, vướng Hộp đã có thuốc 1x2 + Manifest). |

Field có sẵn trong `item_def.gd` giữ nguyên nghĩa. `display_name_key`: `ITEM_CARGO_D_2X2_NAME`, `ITEM_TAX_STAMP_D_NAME`
(`KEY_MỚI?`, TASK-98). `display_name_vi` (fallback): `Vải Cứu Trợ Đổi Nhãn`, `Dấu Thuế`.

### 3.2 Vì sao chọn như vậy

1. **Cargo = items #11.** Đây là card duy nhất trong catalogue vừa `2x2`, vừa có nguồn D, vừa không niêm được, vừa không
   phải gear/container. #08 Khiên và #24 Mũ là gear `2x2` (gear thuộc slot, ngoài slice). #07 Hòm Thuốc là `2x3`, #09
   Rương là `3x3`. `item_category = CARGO` (không phải `SALVAGE` như chữ card) để ràng buộc dữ liệu §8.1 của inventory
   spec tự ép `sealable = false`. Card #11 nói "salvage bulky"; đó là mô tả vai trò, không đổi luật.
2. **Claim cargo = Nhà Hắc Thuế.** Card #11 ghi "Dân bến / Hắc Thuế". Slice chỉ có một `claim_id`; Hắc Thuế là phe dán
   nhãn tịch thu nên là bên đang đòi quyền. Phía dân bến đi vào dòng lore (TASK-98). Claim không phải lệnh tịch thu.
3. **Dấu Thuế không gắn card catalogue.** Card gần nhất là #15 Dấu Niêm Thuế Đã Cạo Tên, nhưng nó là `1x1`, nguồn B/E và
   claim Viện Công Chứng. Đổi footprint của #15 là sửa catalogue. #16 Sổ Kho Ngấm Nước (`1x2`) đã là loot cache B. Vì
   vậy giữ tên fixture `Dấu Thuế` của D brief và **không tạo item card mới**. Lore một dòng (TASK-98) chỉ được nói nó là
   dấu thuế để trên bàn cân, không gắn với Counterseal hay bằng chứng pháp lý.
4. **Cả hai Trắng.** Hai món cùng lớp thẩm định nên màu không phân biệt được chúng. Người chơi phải so footprint, tổng và
   theo ô. Vậy là đúng bài học Beat 4/5: "Màu không quyết định giá trị/ô".
5. **Số giá trị là fixture tương đối.** Tổng cargo 8 > Dấu Thuế 6, nhưng theo ô cargo 2 < Dấu Thuế 3 (Beat 5: "giá tổng
   cao nhưng giá trị/ô thấp hơn"). Đây không phải tiền, giá bán hay balance.

### 3.3 Hiển thị giá trị trên card (G9)

1. Chỉ món có `relative_value_total > 0` mới có dòng giá trị. Trong slice chỉ có `cargo_d_2x2` và `tax_stamp_d`. Cache B
   giữ `0` nên [spec loot B §7.3](zone-b-loot-spec.md) không đổi.
2. Dòng 3 của card (công dụng + giá ước lượng) hiện cả **tổng** và **theo ô**, mỗi số kèm chữ, không chỉ màu. Dạng số
   hay vạch là việc của TASK-97. Không ký hiệu tiền, không chữ "giá bán".
3. S10, S11, HUD và Archive **không bao giờ** hiện `relative_value_*`. Summary không chấm điểm (§8).
4. Chữ công dụng (TASK-98, nội dung không phải chữ cuối): cargo "cồng kềnh, tổng cao, theo ô thấp, không niêm được, về kho
   khi extract"; Dấu Thuế "gọn, theo ô cao hơn, niêm được". Không hứa bán, turn-in hay Local Story. Không câu nào gọi một
   lựa chọn là "đúng" hay "tốt hơn".

### 3.4 Nguồn ở D

| Node | `LootCacheDef.cache_id` | `entries` | Vòng tương tác |
|---|---|---|---|
| `CargoD` | `&"source_cargo_d"` | `{1, &"cargo_d_2x2", 1}` | 1.5 m (`CACHE_INTERACT_RADIUS_M`) |
| `TaxStampD` | `&"source_tax_stamp_d"` | `{1, &"tax_stamp_d", 1}` | 1.5 m |

1. Dùng lại `LootCache` và `cache_session` của [spec loot B §6](zone-b-loot-spec.md). Không thêm class nguồn mới.
2. Mỗi run mới nạp lại cả hai nguồn. Trong một run, món đã nhặt không quay lại nguồn. `ItemBlock` ẩn khi nguồn `empty`
   ([layout D §4](zone-d-layout-encounter-spec.md)).
3. Không random, không drop table, không spawn món thay thế.

## 4. Nhặt ở D

### 4.1 Đích hợp lệ

| Nguồn → đích | Lệnh | Kết quả |
|---|---|---|
| `CargoD` → ba lô | `commit_pickup(cargo, backpack, a, false)` | Được nếu có khối `2x2` trống. |
| `CargoD` → Hộp | `commit_pickup(cargo, notary_box, a, r)` | **Luôn** `NOT_SEALABLE` (`không niêm phong được`), kể cả Hộp trống. Cargo ở nguyên nguồn. |
| `TaxStampD` → ba lô | `commit_pickup(stamp, backpack, a, r)` | Được nếu vừa (xoay được). |
| `TaxStampD` → Hộp | `commit_pickup(stamp, notary_box, a, r)` | Đây là niêm (không O5). Được nếu Hộp có cột `1x2` hoặc hàng `2x1` trống. |
| Bất kỳ → túi đeo chéo | — | `WRONG_TARGET` (`sai loại`). |

Mọi lệnh fail: món ở nguyên nguồn D, `snapshot()` của ba lô/Hộp/túi không đổi, không signal, UI hiện nhãn
`InventoryReason` đầu tiên (inventory §7) và viền `blocking_cells`.

### 4.2 Không có auto-anything

1. Không auto-swap, auto-drop, auto-sort, auto-seal ở bất kỳ bước nào. Không tự chuyển sang ba lô khi Hộp từ chối, hoặc
   ngược lại.
2. Ba lô không còn khối `2x2` → `CELLS_OCCUPIED` / `OUT_OF_BOUNDS`. Người chơi tự **di chuyển** món (không O5) hoặc tự
   **bỏ** một món (O5) rồi nhặt lại. Engine không có lệnh "đổi món dưới đất lấy món trong ba lô".
3. Mang cargo không đổi tốc độ chạy, dash, khiên hay bất kỳ chỉ số nào (không weight/slow penalty).

### 4.3 Hộp fixture và Dấu Thuế — từ chối cụ thể

Given: Hộp có `starter_remedy` (Cuộn Băng Muối) tại (0,0) đứng (chiếm (0,0),(0,1)) và `manifest_r17` tại (1,0). Ô trống
duy nhất: (1,1). `tax_stamp_d` nằm trong ba lô.

| Lệnh | Footprint | `InventoryReason` | `blocking_cells` |
|---|---|---|---|
| `commit_seal(stamp, (0,0), false)` | (0,0),(0,1) | `CELLS_OCCUPIED` (`thiếu ô`) | (0,0),(0,1) |
| `commit_seal(stamp, (1,0), false)` | (1,0),(1,1) | `CELLS_OCCUPIED` | (1,0) |
| `commit_seal(stamp, (1,1), false)` | (1,1),(1,2) | `OUT_OF_BOUNDS` (`không vừa`) | — |
| `commit_seal(stamp, (0,1), true)` | (0,1),(1,1) | `CELLS_OCCUPIED` | (0,1) |
| `commit_seal(stamp, (1,1), true)` | (1,1),(2,1) | `OUT_OF_BOUNDS` | — |

Mọi dòng: Dấu Thuế ở nguyên ô ba lô cũ; thuốc và Manifest không rời Hộp; không signal. Nếu Manifest ở (1,1) thay vì
(1,0), kết quả đối xứng (không lần nào `ok`). Nhặt thẳng từ `TaxStampD` vào Hộp cho cùng lý do và món ở nguyên nguồn.

### 4.4 Đường hợp lệ từng bước (người chơi tự làm)

**Đường A — rút thuốc:**

1. Ba lô có Dấu Thuế đứng tại (2,0); (0,0),(0,1) trống.
2. O4: chọn Cuộn Băng Muối, chạm ô ba lô (0,0) → `preview_withdraw(remedy, (0,0), false)` `ok` → mở O5 `withdraw` (§5).
3. Xác nhận → `commit_withdraw(remedy, (0,0), false)` `ok`. Hộp còn Manifest tại (1,0); trống (0,0),(0,1),(1,1).
4. O3/O4: chọn Dấu Thuế, chạm ô Hộp (0,0) → `commit_seal(stamp, (0,0), false)` `ok`, **không O5**. Nhãn `đã niêm`.
5. Kết quả: Dấu Thuế được bảo vệ, Cuộn Băng Muối nằm trong ba lô **không niêm** (mất nếu chết).

**Đường B — rút Manifest:** như trên nhưng rút `manifest_r17` ra ba lô (O5 `withdraw`, thân câu evidence §5.2), rồi niêm
Dấu Thuế tại (1,0) đứng. Manifest vẫn `CARRYING`, beacon vẫn E1 (di chuyển Hộp → ba lô không phát
`evidence_carried_changed`). Chết thì Manifest vẫn `chưa thu hồi` dù ở đâu.

Cả hai đường đều hợp lệ và không đường nào là "đáp án". Không có đường nào để niêm Dấu Thuế mà không có một lần rút.

### 4.5 Ba outcome của D brief §4 về được B → A

| Outcome | Inventory sau D | Điều phải đúng |
|---|---|---|
| Mang cargo `2x2` | Cargo trong ba lô | Không penalty; cargo không vào Hộp; flow vẫn `CARRYING`/E1 (nếu đã có Manifest). |
| Ưu tiên Dấu Thuế `1x2` | Dấu Thuế trong ba lô hoặc Hộp | Không gọi là tốt hơn; không đổi state flow. |
| Bỏ cả hai | Không đổi | Đóng/`Bỏ qua` card không đổi gì; không câu trách; nguồn D giữ món. |

Lối D → B mở cùng lúc với GateB và không đóng lại ([layout D](zone-d-layout-encounter-spec.md), decision TASK-95). Không
lựa chọn inventory nào đóng lối, khóa beacon hay đổi `extract_state`. Lấy cả hai cũng hợp lệ nếu ba lô/Hộp đủ chỗ.

## 5. O5 trong run ở S04 (G11)

### 5.1 Bảng action cần O5

| | **Bỏ đồ** (`kind = drop`) | **Rút đồ niêm** (`kind = withdraw`) |
|---|---|---|
| Điều kiện mở | O3 đang mở ở chế độ xem; một món **trong ba lô** được chọn; chạm `Bỏ`; `preview_drop(uid)` `ok`; người chơi không ở `depleted`; flow không ở `S10_SUCCESS`/`ENDED_DEATH`. | O4 đang mở; một món **trong Hộp** được chọn; người chơi chạm một ô ba lô (có thể bật xoay); `preview_withdraw(uid, anchor, rotated)` `ok`; cùng điều kiện người chơi/flow. |
| Preview fail | Không mở O5. Hiện nhãn lý do (vd. `WRONG_SOURCE` nếu là món trong Hộp hoặc túi đeo chéo). | Không mở O5. Hiện nhãn lý do + `blocking_cells` (vd. `CELLS_OCCUPIED` khi ba lô đầy). Món giữ nhãn `đã niêm`. |
| O5 hiện gì | Tên món (+`×n` nếu stack), sơ đồ footprint, ô đang chiếm, đích "đất, chỗ đang đứng", hậu quả. Key: `INVENTORY_CONFIRM_DROP_TITLE`, `INVENTORY_CONFIRM_DROP_BODY` (món thường) hoặc `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY` (`item_category == EVIDENCE`), `INVENTORY_CONFIRM_DROP_ACCEPT`, `CONFIRM_BUTTON_CANCEL`. | Tên món, ô Hộp nguồn, **ô ba lô đích của preview**, hậu quả. Key: `INVENTORY_CONFIRM_WITHDRAW_TITLE`, `INVENTORY_CONFIRM_WITHDRAW_BODY` (món thường) hoặc `KEY_MỚI? INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY` (Manifest), `INVENTORY_CONFIRM_WITHDRAW_ACCEPT`, `CONFIRM_BUTTON_CANCEL`. |
| Xác nhận | Gọi `RetrieverInventory.commit_drop(uid)`. `ok` → world tạo `GroundDrop` từ `result.moved[0].item` (§5.4). Fail → O5 đóng, hiện lý do, không đổi. | Gọi `commit_withdraw(uid, anchor, rotated)` với đúng anchor/rotated của preview. `ok` → món vào ô đó, mất nhãn niêm. Fail → O5 đóng, hiện lý do, không đổi. |
| Hủy / Back | Không gọi commit. `snapshot()` y nguyên, ground y nguyên. Quay về O3 với món vẫn được chọn. | Không gọi commit. `snapshot()` y nguyên. Quay về O4, món vẫn ở Hộp. |
| Hậu quả đặc biệt | Bỏ Manifest → `evidence_carried_changed(manifest_r17, false)` → `DROPPED`, E1 → E0 (BCN-26); ở S8 → `hold_paused` (BCN-28); ở S9 → `can_board()` sai (BCN-29). | Rút Manifest: không signal flow, không đổi E-state. |

Nút `Bỏ` chỉ có trên món trong ba lô. Món trong Hộp có nút `Rút`, không có `Bỏ`. Món trong túi đeo chéo không có cả hai.
Bỏ món đang niêm = hai bước, hai O5: rút (O5) rồi bỏ (O5). Không có "bỏ tất cả".

### 5.2 Thân câu O5 cho Manifest

`INVENTORY_CONFIRM_WITHDRAW_BODY` nói món "sẽ mất" khi Phù Hiệu kích hoạt. Câu đó sai với Manifest: chết thì Manifest
`chưa thu hồi` dù ở Hộp hay ba lô (inventory §5.9.3). Vì vậy rút Manifest dùng key mới
`INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY` (`KEY_MỚI?`, TASK-98). Nội dung: Manifest vẫn là vật chứng chưa extract, vẫn
gọi được thuyền; nó không mất vĩnh viễn nhưng cũng không hoàn thành gì. Rút Manifest vẫn qua O5 để mọi lần rút khỏi Hộp
cùng một cử chỉ.

### 5.3 Action không có O5

Di chuyển nhân vật · move trong cùng lưới · xoay · xem/inspect card · đóng/hủy overlay · preview placement ·
`Nhặt và xếp` (vào ba lô **hoặc** vào Hộp) · **niêm từ ba lô vào Hộp** · `Bỏ qua` card · nhặt lại `GroundDrop`.
Thêm O5 cho những action này là lỗi G11 (confirmation thừa).

### 5.4 Đồ đã bỏ nằm ở đâu

1. `commit_drop` ok → world tạo một `GroundDrop` giữ **đúng** `ItemInstance` đó (cùng `uid`, `quantity`, `rotated = false`)
   tại vị trí sàn của người chơi lúc commit.
2. `GroundDrop` nhìn được (khối theo tỉ lệ footprint như `ItemBlock` ở D; art ngoài spec). Nó nằm tới hết run, không
   biến mất theo thời gian, không trôi, không về nguồn D hay về bàn dispatch.
3. Tương tác trong 1.5 m mở card O2 của món đó với `Nhặt và xếp` / `Bỏ qua` / `Đóng`, như cache B. Nhặt lại dùng
   `commit_pickup(item, backpack | notary_box, a, r)`; ok thì xóa `GroundDrop`.
4. Nhiều nguồn/`GroundDrop` trong cùng 1.5 m: mở cái có tâm gần nhất; `Bỏ qua` sang cái gần kế tiếp. Hòa: `uid` nhỏ trước.
5. Nhặt lại Manifest → `evidence_carried_changed(manifest_r17, true)` → `CARRYING`, E1 (BCN-27).
6. Món đã bỏ và **không** nhặt lại trước khi run kết thúc: S10 → `Đã mất` với `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`; S11 →
   `Đã mất` với `lost_reason = left_behind`.

### 5.5 Một O5 mỗi lúc và ngắt

1. Khi `inventory_confirm` mở: O3/O4 phía sau không nhận input; nút `Gọi thuyền` không dùng được (overlay đang mở, combat
   §3.6). Khi O5 gọi thuyền mở thì không mở được O3/O4.
2. O5 không dừng thế giới. Địch vẫn đánh được. Bị đánh không đóng O5.
3. HP về 0 khi O5 mở → O5 đóng **như hủy** (không commit), rồi chuỗi §7.1.
4. Rời D hay rời vùng không đóng `inventory_confirm` (nó không gắn vùng, khác O5 gọi thuyền).

### 5.6 O1 ở S04

Đổi gear phá placement cũ và vào run không vũ khí: **không áp dụng ở slice**. O1 không có affordance cho hai action đó;
key `LOADOUT_CONFIRM_GEAR_*` và `LOADOUT_CONFIRM_NO_WEAPON_*` không hiện. O1 vẫn chỉ sắp lại trong cùng ngăn
(`INVENTORY_REASON_CROSS_GRID_LOCKED`). Nếu một affordance đổi gear xuất hiện thì là lỗi scope, kể cả khi có O5.

### 5.7 Mở khóa rút trong run

Từ S04, lý do `INVENTORY_REASON_WITHDRAW_LOCKED` không còn hiện trong run (O3/O4). Rút Hộp → ba lô đi theo §5.1. Rút
**không** làm Cuộn Băng Muối dùng được: thuốc chỉ dùng từ túi đeo chéo ([combat §3.5.5](combat-slice-spec.md)). Card/chữ
không được hàm ý ngược lại.

## 6. States và transitions

### 6.1 Vị trí item (thêm vào inventory spec §6.1)

```text
D source (ground) --commit_pickup ok--> backpack | notary_box
backpack --O5 drop: xác nhận + commit_drop ok--> ground (GroundDrop)
notary_box --O5 withdraw: xác nhận + commit_withdraw ok--> backpack
GroundDrop --commit_pickup ok--> backpack | notary_box
O5 hủy / commit fail / chết khi O5 mở --> giữ nguyên
```

### 6.2 `inventory_confirm`

```text
closed --preview ok + chạm Bỏ/ô đích--> open(kind, uid, anchor, rotated)
open --Xác nhận--> commit_*() --> closed (ok: state mới | fail: state cũ + lý do)
open --Hủy / Back--> closed (không commit)
open --HP 0--> closed (không commit)
```

### 6.3 `ContractState` sau khi chết

| Trước khi chết | Sau `resolve_death_summary()` | Ghi chú |
|---|---|---|
| `NOT_TAKEN` | `NOT_TAKEN` | Contract 1 active; `desk_state` vẫn `HAS_MANIFEST`. |
| `CARRYING` | `UNRECOVERED` | Kể cả Manifest trong Hộp, kể cả S7/S8/S9. |
| `DROPPED` | `UNRECOVERED` | Manifest đang nằm ở `GroundDrop`. |

Không cần trạng thái mới: `UNRECOVERED` đã có trong enum ([beacon §10.1](beacon-extract-state-spec.md)) và từ S04 được set
thật. Vì không lưu, `UNRECOVERED` chỉ sống tới khi rời S11. Run kế tiếp luôn bắt đầu như BCN-01.

## 7. Phù Hiệu Hồi Hương và S11 (G16, G17)

### 7.1 Chuỗi khi HP về 0 (thay combat §4.4)

1. `Health.depleted` → người chơi `depleted`, khóa mọi input; mọi overlay đang mở (O2/O3/O4, `inventory_confirm`, O5 gọi
   thuyền) đóng **như hủy**, không commit. Preview đang dở bị bỏ; món ở nguồn vẫn ở nguồn.
2. `ExtractPierAFlow.notify_death()` → `ENDED_DEATH` (BCN-30). Không `resolve_extract()`, không `extract_succeeded`.
3. `ExtractPierAFlow.resolve_death_summary()` → gọi `RetrieverInventory.resolve_death()` **đúng một lần** và trả
   `DeathSummary` (§7.4). Set `ContractState` theo §6.3.
4. Địch về `idle`, director lane B ngừng (như combat §4.4.3). Không tick hold.
5. Trong `RECALL_SIGIL_SECONDS` = **2.5** `proposed` (bằng `STUB_END_MESSAGE_SECONDS`): không thêm sát thương, không input.
   Hiệu ứng/âm thanh Phù Hiệu là việc của TASK-97 và art. Hết thời gian → mở S11.
6. Không ghi gì vào `user://`. Chữ `COMBAT_STUB_HP_ZERO` / `COMBAT_STUB_BUTTON_BOOT` và màn O6 stub không còn hiện.

### 7.2 Bảng outcome

`resolve_death()` (inventory §6.3) cho `kept` / `lost` / `unrecovered_evidence` từ ba lưới. `resolve_death_summary()` bổ
sung đồ ở đất và Manifest đang `DROPPED`, vì `resolve_death()` không đọc ground.

| # | Thời điểm chết | `kept` | `lost` | `unrecovered_evidence` | `ContractState` sau | Manifest ở đâu | `death_variant` / nút |
|---|---|---|---|---|---|---|---|
| D1 | Trước Manifest (`NOT_TAKEN`) | Non-evidence trong Hộp | Ba lô + túi (`unsealed`); món đã bỏ chưa nhặt lại (`left_behind`) | `[]` | `NOT_TAKEN` | Bàn dispatch A (nguồn ban đầu) | `before_manifest` · `Chuẩn bị lại` → S1 |
| D2 | Sau Manifest, Manifest trong **ba lô** | Như D1 | Như D1; Manifest **không** ở `lost` | `[manifest_r17]` | `UNRECOVERED` | `chưa thu hồi`; không về hub/Archive | `after_manifest` · một nút → Boot |
| D3 | Sau Manifest, Manifest trong **Hộp** | Như D1; Manifest **không** ở `kept` | Như D1 | `[manifest_r17]` | `UNRECOVERED` | Như D2 | Như D2 |
| D4 | Manifest đang `DROPPED` (ở `GroundDrop`) | Như D1 | Như D1; Manifest **không** ở `lost` | `[manifest_r17]` (flow thêm) | `UNRECOVERED` | Như D2 | Như D2 |
| D5 | Trong S7 / S8 / S9 (hoặc khi O5 gọi thuyền đang mở) | Theo vị trí Manifest như D2/D3/D4 | Như D1 | `[manifest_r17]` | `UNRECOVERED` | Như D2 | Như D2; O5 đóng như hủy; không S10 |
| D6 | Khi `inventory_confirm` đang mở | Theo state **trước** O5 (vd. đang rút thuốc → thuốc còn ở Hộp → `kept`) | Theo state trước O5 (vd. đang bỏ cargo → cargo còn ở ba lô → `unsealed`) | Theo D1–D4 | Theo D1–D4 | Theo D1–D4 | Theo D1–D4 |
| D7 | Khi đang preview nhặt ở `CargoD`/`TaxStampD`/cache | Theo D1–D4 | Món ở nguồn **không** ở `lost` (chưa từng mang) | Theo D1–D4 | Theo D1–D4 | Theo D1–D4 | Theo D1–D4 |

Món đã tiêu (thuốc túi đeo chéo dùng hết) **không** ở `lost` (§7.4, quy tắc 5). Vũ khí + khiên đang trang bị không phải
`ItemInstance`; S11 ghi một dòng cố định cho chúng ở `Đã mất` (§7.3).

### 7.3 Màn S11 — ánh xạ dữ liệu → key

| Nhóm | Hiện khi | Key / nội dung |
|---|---|---|
| Tiêu đề | luôn | `SUMMARY_DEATH_TITLE` |
| `Đã giữ` | `kept` không rỗng (rỗng thì ẩn cả nhóm `proposed`) | `SUMMARY_GROUP_KEPT`, `SUMMARY_DEATH_KEPT_SEALED`, tên từng món |
| `Đã mất` | luôn (có dòng trang bị) | `SUMMARY_GROUP_LOST`; `SUMMARY_DEATH_LOST_UNSEALED` + tên món `unsealed`; `KEY_MỚI? SUMMARY_DEATH_LOST_LEFT_BEHIND` + tên món `left_behind`; `KEY_MỚI? SUMMARY_DEATH_LOST_EQUIPPED` (vũ khí + khiên đang trang bị) |
| `Vật chứng` | luôn | `SUMMARY_GROUP_EVIDENCE`; `before_manifest`: `SUMMARY_DEATH_EVIDENCE_AT_DESK`; `after_manifest`: `SUMMARY_DEATH_EVIDENCE_UNRECOVERED`. Cả hai: `SUMMARY_DEATH_NOT_EXTRACTED` |
| Nút | theo biến thể | `before_manifest`: `SUMMARY_DEATH_BUTTON_PREPARE` → S1. `after_manifest`: `KEY_MỚI? SUMMARY_DEATH_BUTTON_BOOT` → Boot |
| Dòng recovery (tùy TASK-98) | `after_manifest` | `KEY_MỚI? SUMMARY_DEATH_RECOVERY_UNAVAILABLE`: chỉ nói thu hồi chưa có trong vertical slice, giống nhãn Contract 2. Không hứa hồi đồ hay thời điểm. |

Không bao giờ hiện ở S04: `SUMMARY_DEATH_BUTTON_RECOVERY`, mọi `RECOVERY_*`, `SUMMARY_SUCCESS_*`, giá trị, điểm, route.
Mỗi uid một dòng. Evidence có icon/shape riêng, không chỉ màu (wireflow §3).

**Sau `Chuẩn bị lại` (D1):** S1 briefing của Contract 1, loadout mặc định (inventory §8.4), run mới như BCN-01. Cache B
và nguồn D đầy lại. Món ở `Đã giữ` **không** mang sang run mới vì slice không có kho hub hay save.
**Sau nút Boot (D2–D5):** scene Boot, không file save. Bắt đầu lại từ Boot là Contract 1 thường (BCN-01).

### 7.4 `DeathSummary` (`RefCounted`) — dữ liệu tối thiểu

| Field | Kiểu | Quy tắc |
|---|---|---|
| `kept` | `Array[Dictionary]` `{uid: int, def_id: StringName}` | `resolve_death().kept`, theo thứ tự uid. |
| `lost` | `Array[Dictionary]` `{uid, def_id, lost_reason: StringName}` | `resolve_death().lost` → `unsealed`; cộng mọi uid trong `carried_ever` không ở `kept`, `lost`, không phải evidence và không bị tiêu → `left_behind`. |
| `equipped_gear_lost` | `bool` | Slice: luôn `true`. |
| `unrecovered_evidence` | `Array[StringName]` | `resolve_death().unrecovered_evidence`, cộng `manifest_r17` nếu `contract_state_at_death == DROPPED`. Không trùng. |
| `contract_state_at_death` | `ContractState` | Đọc trước khi đổi. |
| `contract_state` | `ContractState` | Theo §6.3. |
| `death_variant` | `StringName` | `before_manifest` nếu `contract_state_at_death == NOT_TAKEN`, ngược lại `after_manifest`. |

Quy tắc:

1. `to_dict()` trả các field trên. **Cấm** field điểm, giá trị, `relative_value_*`, route, thời gian.
2. `resolve_death_summary()` chỉ chạy khi `extract_state == ENDED_DEATH` và chỉ một lần. Lần hai trả `null`, không gọi lại
   `resolve_death()`, không signal.
3. Đổi `ContractState` phát `contract_state_changed` đúng một lần (nếu đổi).
4. Sau khi gọi, ba lưới rỗng (inventory §6.3).
5. Món bị tiêu hết (`commit_consume` đưa quantity về 0) bị xóa khỏi `carried_ever`, nên không ở `lost` của S10 lẫn S11.

## 8. S10 sau full-route (G15)

1. S10 dùng đúng `ExtractSummary` của [beacon §10.4](beacon-extract-state-spec.md). Rút sớm và full-route đi **cùng** màn S10,
   cùng tập key; chỉ nội dung `kept`/`lost`/`backpack_cells_used` khác.
2. `Đã giữ`: mỗi món ở ba lô, túi đeo chéo, Hộp (trừ evidence) một dòng, cộng `SUMMARY_SUCCESS_KEPT_CELLS` với
   `{used}` = ô ba lô đang chiếm **trước** `resolve_extract()`, `{total}` = 12. Cargo trong ba lô tính 4 ô.
3. `Đã mất`: mọi món đã mang trong run rồi bỏ xuống đất và không nhặt lại (`SUMMARY_SUCCESS_LOST_LEFT_BEHIND`). Ẩn nếu
   rỗng. Món nhặt lại trước khi lên thuyền nằm ở `Đã giữ`, không ở `Đã mất`. Món tiêu hết không ở đâu cả (§7.4.5).
4. Món còn ở nguồn D/cache B (chưa từng nhặt) không hiện ở nhóm nào.
5. Không chấm điểm, không xếp hạng, không so build, không hiện giá trị/ô, không thưởng vì đi full-route.

## 9. Fixture G16 và G17 — chơi tự nhiên, không menu debug

Chết chỉ xảy ra ở B (đợt chặn ngõ, patrol về A) hoặc ở đợt lane B lúc giữ khu A. D không có địch
([layout D](zone-d-layout-encounter-spec.md)). Muốn chết thì đứng trong lane/để patrol đánh tới khi HP 0. Mỗi fixture bắt
đầu từ Boot → S1 → `Vào cảng` với loadout mặc định.

### 9.1 G16 — chết trước Manifest

| Bước | Hành động người chơi | Nội dung ngay trước khi chết |
|---|---|---|
| 1 | Ở A **không** tương tác bàn dispatch; đi vào B. | Hộp: Cuộn Băng Muối (0,0). Túi: Gói Băng Muối. |
| 2 | Qua chặn ngõ B (GateB mở); tới cache B. | — |
| 3 | Nhặt Sổ Kho Ngấm Nước **thẳng vào Hộp** tại (1,0) đứng (niêm, không O5). | Hộp: Cuộn Băng Muối + Sổ Kho (đầy). |
| 4 | Nhặt Đồng Thuế Cạo Mặt ×2 vào ba lô (0,0). Không dùng thuốc. | Ba lô: đồng xu. |
| 5 | Rời `CalmZoneB` qua GateB; để patrol đánh tới HP 0. | Như trên. |

Kỳ vọng S11: `death_variant = before_manifest`. `Đã giữ` = [Cuộn Băng Muối, Sổ Kho Ngấm Nước]. `Đã mất` = [Đồng Thuế
Cạo Mặt (`unsealed`), Gói Băng Muối (`unsealed`)] + dòng trang bị. `Vật chứng` = `SUMMARY_DEATH_EVIDENCE_AT_DESK`.
`ContractState = NOT_TAKEN`, `desk_state = HAS_MANIFEST`. Nút `Chuẩn bị lại` → S1. Nếu người chơi đã dùng thuốc, Gói Băng
Muối không có trong `Đã mất`; dòng trang bị vẫn chứng minh "đồ không niêm mất".

Giả định: B vào được khi chưa có Manifest (layout B không gate lối A → B bằng Manifest). Nếu build chặn, G16 là
`NOT READY` và cần card fixture riêng; không thay bằng menu debug.

### 9.2 G17 — chết sau Manifest, ba nhóm

| Bước | Hành động người chơi | Nội dung ngay trước khi chết |
|---|---|---|
| 1 | Ở bàn dispatch: `Nhặt và xếp` Manifest **thẳng vào Hộp** tại (1,0). | Hộp: Cuộn Băng Muối (0,0) + Manifest (1,0). `CARRYING`, E1. |
| 2 | Qua B, có thể `Bỏ qua` cache B. Vào D qua lối mở. | — |
| 3 | Ở `CargoD`: nhặt Vải Cứu Trợ Đổi Nhãn vào ba lô (0,0). | Ba lô: cargo (4 ô). |
| 4 | Quay D → B; để patrol (hoặc đợt lane lúc giữ khu A) đánh tới HP 0. | Như trên. |

Kỳ vọng S11: `death_variant = after_manifest`. `Đã giữ` = [Cuộn Băng Muối]. `Đã mất` = [Vải Cứu Trợ Đổi Nhãn
(`unsealed`), Gói Băng Muối nếu chưa dùng] + dòng trang bị. `Vật chứng` = `SUMMARY_DEATH_EVIDENCE_UNRECOVERED` (Manifest
**không** ở `Đã giữ` dù nằm trong Hộp). `ContractState = UNRECOVERED`. Không S10, không `extract_succeeded`. Một nút → Boot.

**Biến thể G17-B (chứng minh hậu quả của rút):** sau bước 3, nhặt Dấu Thuế vào ba lô (2,0) đứng; ở O4 rút Cuộn Băng Muối
tới ba lô (0,2) đứng qua O5; niêm Dấu Thuế vào Hộp (0,0) đứng (Đường A §4.4 với ô khác vì cargo chiếm (0,0)–(1,1)).
Chết → `Đã giữ` = [Dấu Thuế]; `Đã mất` có Cuộn Băng Muối và cargo (`unsealed`).

## 10. Edge cases

1. Bỏ cargo ở D rồi lấy Dấu Thuế: cargo thành `GroundDrop` ở D; nguồn `CargoD` vẫn `empty` (ItemBlock không hiện lại).
   Extract → cargo ở `Đã mất` (`left_behind`).
2. Bỏ Manifest ở A ngay cạnh bàn: Manifest là `GroundDrop`, bàn vẫn `EMPTY`, không tự về bàn.
3. Bỏ Manifest trong S8: hold tạm dừng; nhặt lại → chạy tiếp từ số giây cũ (BCN-28, BCN-19).
4. Rút khi ba lô đầy: preview fail, không có O5, món vẫn `đã niêm` (INV-20).
5. Rút → niêm lại cùng món → rút lần nữa: hợp lệ; mỗi lần rút một O5, niêm không O5.
6. Cargo vào Hộp đầy: lý do là `NOT_SEALABLE`, không phải `CELLS_OCCUPIED` (inventory §7, INV-18).
7. Hai `GroundDrop` chồng chỗ: mở cái gần nhất; `Bỏ qua` sang cái kế (§5.4.4).
8. Chết khi `Đã giữ` rỗng (đã rút và bỏ thuốc khỏi Hộp): ẩn nhóm `Đã giữ`; `Đã mất` vẫn có dòng trang bị.
9. Chết hai lần liên tiếp không thể xảy ra trong một run (`depleted` một lần, combat §4.2.3); `resolve_death_summary()`
   lần hai trả `null`.
10. Thuốc túi đeo chéo đã dùng: không ở `Đã mất` (S10/S11).
11. Lấy cả cargo và Dấu Thuế: hợp lệ nếu đủ chỗ; không có giới hạn "một lựa chọn".

## 11. Acceptance tests (given / when / then)

Tên test engineering: `test_zd_xx_<mô_tả_ngắn>`. "Không đổi" = `inventory.snapshot()`, ground/nguồn, ba state flow bằng
nhau và không có signal inventory/flow. Hộp fixture = `starter_remedy` (0,0) đứng + `manifest_r17` (1,0).

| ID | Gate | Given | When | Then |
|---|---|---|---|---|
| ZD-01 | G9 | Registry có `cargo_d_2x2`, `tax_stamp_d` | `validate_defs()` | Rỗng. Cargo: (2,2), `CARGO`, `sealable false`, class 1, `relative_value_total 8`. Dấu Thuế: (1,2), `rotatable`, `sealable`, `VALUABLE`, class 1, `relative_value_total 6`. |
| ZD-02 | G9 | Như ZD-01 | Tính giá trị/ô | Cargo 2, Dấu Thuế 3. Tổng cargo > Dấu Thuế và theo ô cargo < Dấu Thuế. `scraped_tax_coin`, `waterlogged_stock_ledger` có `relative_value_total == 0`. |
| ZD-03 | G9 | Run mới | Load zone D | `source_cargo_d` có đúng 1 `cargo_d_2x2` ở ground; `source_tax_stamp_d` có đúng 1 `tax_stamp_d`; cả hai `full`. Run mới sau khi đã nhặt → lại `full`. |
| ZD-04 | G9 | Card cargo mở, ba lô rỗng | Đọc dòng card | Thứ tự NAME → FOOTPRINT → USE (có tổng và theo ô) → CLAIM → RARITY → LORE; `fit_notary_box = not_sealable`. |
| ZD-05 | G9 | Ba lô rỗng | `commit_pickup(cargo, backpack, (0,0), false)` | `ok`; nguồn `empty`; `ItemBlock` của `CargoD` ẩn, collision tắt. |
| ZD-06 | G9/G10 | Hộp rỗng; cargo ở nguồn | `commit_pickup(cargo, notary_box, (0,0), false)` | `NOT_SEALABLE`; cargo ở nguồn; không đổi. |
| ZD-07 | G9 | Ba lô: Manifest (1,1), đồng xu (0,3), Sổ Kho đứng (2,2) | `commit_pickup(cargo, backpack, (0,0), false)`; rồi `commit_move(manifest, backpack, (2,0), false)`; rồi lại pickup | Lần 1 `CELLS_OCCUPIED`, `blocking_cells` chứa (1,1), không đổi. Move `ok`, không signal flow. Lần 3 `ok`. Không lần nào có drop/swap/sort ngầm. |
| ZD-08 | G9 | Hai run: ba lô rỗng và ba lô có cargo | Đọc tốc độ di chuyển, dash, thời gian khiên | Bằng nhau (không weight/slow penalty). |
| ZD-09 | G9 | Ở D, card cargo và Dấu Thuế mở rồi `Bỏ qua`/`Đóng` cả hai | Đi qua lối D → B tới A | Không đổi inventory; flow vẫn `CARRYING`/E1; lối D → B mở; gọi thuyền ở A được như BCN-10. |
| ZD-10 | G10 | Hộp fixture; Dấu Thuế đứng ở ba lô (2,0) | `commit_seal` với 5 dòng của §4.3 | Đúng reason và `blocking_cells` từng dòng; không lần nào `ok`; không đổi. |
| ZD-11 | G10 | Hộp fixture; Dấu Thuế ở nguồn D | `commit_pickup(stamp, notary_box, a, r)` với mọi `a`, `r` | Không lần nào `ok`; Dấu Thuế ở nguồn; không đổi. |
| ZD-12 | G10/G11 | Hộp fixture; Dấu Thuế đứng ba lô (2,0) | Đường A §4.4: preview_withdraw thuốc (0,0) → O5 → xác nhận → `commit_seal(stamp, (0,0), false)` | Withdraw `ok`, seal `ok`; `seal_label(stamp) == sealed`; thuốc ở ba lô (0,0), `seal_label` rỗng; O5 mở đúng 1 lần (withdraw), seal không O5; flow `CARRYING`/E1, không signal flow. |
| ZD-13 | G10 | Như ZD-12 | Đường B: rút Manifest tới ba lô (0,0) qua O5 rồi `commit_seal(stamp, (1,0), false)` | Cả hai `ok`; O5 dùng `INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY`; không `evidence_carried_changed`; flow vẫn E1. |
| ZD-14 | G11 | Đồng xu trong ba lô; O3 mở | Chạm `Bỏ` → O5 mở → `Hủy` | `commit_drop` không được gọi; không đổi; O3 vẫn chọn đồng xu. |
| ZD-15 | G11 | Như ZD-14 | `Bỏ` → `Xác nhận` | `commit_drop` ok; một `GroundDrop` cùng uid ở vị trí sàn người chơi; `item_removed` 1 lần. Tương tác `GroundDrop` → card → `commit_pickup(…, backpack, a, r)` ok → `GroundDrop` biến mất, cùng uid. |
| ZD-16 | G11 | Thuốc trong Hộp; O4 mở | Tìm nút `Bỏ` trên thuốc; gọi `commit_drop(remedy)` | Không có nút `Bỏ`, chỉ `Rút`. Lệnh trả `WRONG_SOURCE`; không đổi. |
| ZD-17 | G11 | Flow `CARRYING`/E1; Manifest trong ba lô | `Bỏ` Manifest → xác nhận | O5 dùng `INVENTORY_CONFIRM_DROP_EVIDENCE_BODY`; `DROPPED`, E0; HUD `HUD_OBJECTIVE_PICK_UP_MANIFEST`; bàn vẫn `EMPTY`. Nhặt lại → `CARRYING`, E1. |
| ZD-18 | G11 | Ba lô đầy 12 ô; thuốc trong Hộp | Chạm thuốc rồi chạm ô ba lô | `preview_withdraw` fail `CELLS_OCCUPIED`; **không** mở O5; thuốc vẫn `sealed`. |
| ZD-19 | G11 | Thuốc trong Hộp; ba lô (0,0),(0,1) trống | Rút → O5 → `Hủy` | Không gọi `commit_withdraw`; không đổi. |
| ZD-20 | G11 | Run có O3/O4 | Thực hiện move, rotate, xem card, đóng, preview, `Nhặt và xếp` vào ba lô và vào Hộp, niêm từ ba lô, `Bỏ qua`, nhặt `GroundDrop` | Số lần O5 mở = 0. |
| ZD-21 | G11 | S1 và O1 ở S04 | Tìm affordance đổi gear / vào không vũ khí | Không có; key `LOADOUT_CONFIRM_GEAR_*`, `LOADOUT_CONFIRM_NO_WEAPON_*` không hiện. |
| ZD-22 | G11 | Cargo trong ba lô; O5 `drop` đang mở | HP về 0 | O5 đóng không commit; cargo ở `lost` với `unsealed`; không `GroundDrop` mới. |
| ZD-23 | G11 | O5 `inventory_confirm` đang mở trong `BeaconZoneA`, E1 | Thử `Gọi thuyền` | Không mở O5 gọi thuyền; `call_confirm_open == false`. |
| ZD-24 | G15 | Full-route: Manifest nhặt vào ba lô (0,0); ở B nhặt đồng xu vào ba lô (2,3) rồi bỏ nó (O5), không nhặt lại; ở D cargo vào ba lô (1,0), Dấu Thuế nhặt thẳng vào Hộp (1,0) đứng; thuốc túi chưa dùng; về A gọi/giữ khu | `board()` | `kept` = {cargo_d_2x2, starter_remedy, tax_stamp_d, sling_remedy}; `lost` = [scraped_tax_coin]; `evidence = [manifest_r17]`; `backpack_cells_used = 5` (1 + 4), `total = 12`; S10 hiện `SUMMARY_SUCCESS_LOST_LEFT_BEHIND` cho đồng xu; không field điểm/giá trị. |
| ZD-25 | G15 | Thuốc túi đã dùng hết (`commit_consume`) | `board()` | `lost` không chứa uid thuốc túi; `kept` không chứa nó. |
| ZD-26 | G15 | Hai run: rút sớm và full-route có cargo | `board()` mỗi run | Cùng tập key `to_dict()`; không key giá trị/điểm/route/thời gian; không có `relative_value_*`. |
| ZD-27 | G16 | Fixture §9.1 | HP về 0 | `notify_death` 1 lần; `resolve_death` 1 lần; `resolve_extract` 0 lần. `DeathSummary`: `kept` = [starter_remedy, waterlogged_stock_ledger]; `lost` = [scraped_tax_coin, sling_remedy] đều `unsealed`; `unrecovered_evidence = []`; `death_variant = before_manifest`; `NOT_TAKEN`; `desk_state = HAS_MANIFEST`; `equipped_gear_lost`. |
| ZD-28 | G16 | S11 của ZD-27 | Chạm `SUMMARY_DEATH_BUTTON_PREPARE` | S1 Contract 1; loadout = inventory §8.4 (không có Sổ Kho trong Hộp); vào cảng → BCN-01; cache B `full`; không file save. |
| ZD-29 | G16 | Run mới, chưa nhặt Manifest; chết trong chặn ngõ B, chưa dùng thuốc | HP về 0 | `kept` = [starter_remedy]; `lost` = [sling_remedy]; S11 có `SUMMARY_DEATH_EVIDENCE_AT_DESK`; không có `SUMMARY_DEATH_EVIDENCE_UNRECOVERED`. |
| ZD-30 | G17 | Fixture §9.2 | HP về 0 | `kept` = [starter_remedy]; `lost` chứa `cargo_d_2x2` (`unsealed`); `unrecovered_evidence = [manifest_r17]`; Manifest không ở `kept`/`lost`; `UNRECOVERED`, `contract_state_changed` 1 lần; `after_manifest`; không S10. |
| ZD-31 | G17 | S11 của ZD-30 | Đọc màn và chạm nút | Đúng một nút (`SUMMARY_DEATH_BUTTON_BOOT`) → Boot; không `SUMMARY_DEATH_BUTTON_RECOVERY`, không key `RECOVERY_*`, không `SUMMARY_SUCCESS_*`; không file save. |
| ZD-32 | G17 | Manifest trong ba lô, cargo trong ba lô | HP về 0 | `unrecovered_evidence = [manifest_r17]`; `lost` chỉ có cargo (+ thuốc túi nếu còn). |
| ZD-33 | G17 | Manifest đã bỏ (`DROPPED`, đang là `GroundDrop`) | HP về 0 | `unrecovered_evidence = [manifest_r17]` đúng một lần; Manifest không ở `lost`; `contract_state_at_death = DROPPED`, sau = `UNRECOVERED`. |
| ZD-34 | G17 | Lần lượt S7, S8 (tạm dừng và đang chạy), S9 trong `BoardZoneA`, E1 + O5 gọi thuyền mở | HP về 0 | Mỗi lần: `ENDED_DEATH`, O5 đóng nếu mở, `resolve_extract` 0 lần, không `extract_succeeded`, `after_manifest`. |
| ZD-35 | G17 | Biến thể G17-B §9.2 | HP về 0 | `kept` = [tax_stamp_d]; `lost` chứa `starter_remedy` và `cargo_d_2x2` (`unsealed`). |
| ZD-36 | G16/G17 | Cargo bị bỏ ở D (không nhặt lại), chết sau đó | HP về 0 | Cargo ở `lost` với `lost_reason = left_behind`. |
| ZD-37 | G16/G17 | Sau ZD-30 | Gọi `resolve_death_summary()` lần hai | Trả `null`; `resolve_death` tổng 1 lần; không signal. |
| ZD-38 | G16/G17 | Mọi death | Theo dõi 2.5 s sau HP 0 | Không thêm sát thương, không tick hold; không hiện `COMBAT_STUB_HP_ZERO`; S11 mở sau `RECALL_SIGIL_SECONDS`. |
| ZD-39 | Invariant 8.5 | Given của ZD-06, 07 (lần 1), 10, 11, 16, 18, 19 | Đếm signal và so `snapshot()` | Mọi lệnh fail/hủy: 0 signal; ba lưới, ground, nguồn D đều không đổi. |

## 12. Truy vết tới gate

| Gate / invariant | Mục | Test |
|---|---|---|
| G9 — D cargo choice | §3, §4.1, §4.5 | ZD-01…09 |
| G10 — Hộp không auto-swap | §4.3, §4.4 | ZD-06, ZD-10…13 |
| G11 — O5 đúng chỗ | §5 | ZD-12…23 |
| G15 — S10 full-route | §8 | ZD-24…26 |
| G16 — S11 trước Manifest | §7, §9.1 | ZD-27…29, ZD-36…38 |
| G17 — S11 sau Manifest | §7, §9.2 | ZD-30…38 |
| Invariant §8.5 / §8.6 | §4.2, §7.2 | ZD-39, ZD-27, ZD-30 |

## 13. API còn thiếu cho engineering (chỉ thêm, `proposed`)

| # | Chỗ | Thêm | Dùng ở |
|---|---|---|---|
| 1 | `ItemDef` | `@export var relative_value_total: int = 0` (≥ 0) và `relative_value_per_cell() -> float`. Không ảnh hưởng `validation_error()`. | §3.3, ZD-01/02 |
| 2 | Item registry / `.tres` | Def `cargo_d_2x2`, `tax_stamp_d` theo §3.1 (thay fixture test cùng id, giữ hành vi INV). | §3.1 |
| 3 | `LootCacheDef` | Hai def `source_cargo_d`, `source_tax_stamp_d` (§3.4), nối node `CargoD`/`TaxStampD`. | §3.4 |
| 4 | `RetrieverInventory` | `signal item_consumed(uid: int, def_id: StringName)`: phát trong `commit_consume` khi quantity về 0 (sau `item_removed`). | §7.4.5, ZD-25 |
| 5 | `ExtractPierAFlow` | Nghe `item_consumed` → xóa uid khỏi `carried_ever`. | §7.4.5 |
| 6 | `ExtractPierAFlow` | `resolve_death_summary() -> DeathSummary` (§7.4); chỉ hợp lệ ở `ENDED_DEATH`, một lần; ngoại lệ duy nhất cho quy tắc "terminal bỏ qua input" của BCN-31. | §7.1, §7.2 |
| 7 | Class mới | `DeathSummary` (`RefCounted`) với field §7.4 và `to_dict()`. | §7.3 |
| 8 | World / adapter | `GroundDrop` (node giữ một `ItemInstance`, vòng 1.5 m, mở `cache_session` một món); spawn từ `commit_drop().moved[0].item`; chọn gần nhất khi chồng vòng. | §5.4 |
| 9 | UI (TASK-101/102) | `inventory_confirm` (`kind`, `uid`, `anchor`, `rotated`); nút `Bỏ` (ba lô) / `Rút` (Hộp); bỏ khóa `INVENTORY_REASON_WITHDRAW_LOCKED` trong run. | §5 |
| 10 | Death handler (thay combat §4.4) | Chuỗi §7.1; hằng `RECALL_SIGIL_SECONDS = 2.5`; mở S11 thay vì Boot. | §7.1 |
| 11 | Chữ (TASK-98) | `KEY_MỚI?`: `ITEM_CARGO_D_2X2_NAME`, `ITEM_TAX_STAMP_D_NAME`, `CARD_CARGO_D_2X2_{NAME,FOOTPRINT,USE,CLAIM,RARITY,LORE}`, `CARD_TAX_STAMP_D_{…}`, nhãn tổng/theo ô cho dòng 3, `INVENTORY_CONFIRM_WITHDRAW_EVIDENCE_BODY`, `SUMMARY_DEATH_LOST_LEFT_BEHIND`, `SUMMARY_DEATH_LOST_EQUIPPED`, `SUMMARY_DEATH_BUTTON_BOOT`, `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` (tùy chọn), nhãn tương tác `GroundDrop`. | §3, §5, §7.3 |

Không đổi chữ ký hàm có sẵn. `resolve_death()` giữ nguyên hành vi; phần ground do flow bổ sung.

## 14. Ngoài phạm vi và câu hỏi mở

- **Ngoài phạm vi:** bố cục D (TASK-95), layout/visual card, O5, S11 (TASK-97), chữ cuối (TASK-98), code, Recovery
  Contract/S12/bàn dispatch thu hồi (S05), Contract 2, C/E, weight/slow penalty, giá tiền, economy, save, đổi gear.
- **Cần cập nhật ngoài `writes` của card này:**
  1. Glossary: `cargo_d_2x2` = Vải Cứu Trợ Đổi Nhãn (fixture D); `tax_stamp_d` = Dấu Thuế (fixture D); `ground_drop`;
     `DeathSummary`; `relative_value_total`.
  2. [Combat §4.4](combat-slice-spec.md): ghi "thay bằng spec này §7.1 từ S04".
  3. [Beacon §9](beacon-extract-state-spec.md): trỏ tới §7 cho phần sau `ENDED_DEATH`.
- **Câu hỏi mở (không chặn):**
  1. `Đã giữ` ở S11 và S10 không mang sang run sau vì slice không có kho hub. TASK-98 cần tránh câu hứa "có ở lần sau".
  2. Dòng `SUMMARY_DEATH_LOST_EQUIPPED` theo đúng canon "gear không niêm mất", nhưng run sau vẫn có kit starter. Nếu
     playtest thấy gây hiểu lầm, TASK-98 chỉnh chữ; luật không đổi.
