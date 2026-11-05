# Recovery brief — Cảng Hắc Thuế, vertical slice “Giữ giấy phép”

**Trạng thái:** arrangement recovery `proposed` cho Easy / Contract 1. Brief này chỉ làm rõ hậu quả death, Recovery Contract và đường thu hồi `Manifest Hàng Hóa R-17`; không tạo checkpoint, content, item hay route mới.

**Nguồn ràng buộc:** [vertical slice](../vertical-slice.md), [wireflow UX](../vertical-slice-wireflow.md), [build-readiness](../vertical-slice-build-readiness.md), [inventory/loadout](../systems/inventory-and-loadout.md), [protocol quan sát](../playtest-observation-sheet.md), [brief extract A](black-tax-port-a-extract-brief.md) và [brief cargo D](black-tax-port-d-cargo-choice-brief.md). Nếu có khác biệt, luật slice/wireflow/readiness ưu tiên.

## 1. Mục đích và ranh giới

Recovery giữ Campaign không soft-lock, nhưng **không xóa hậu quả của một run thua**. Câu hỏi người chơi cần hiểu là: **“Tôi giữ được gì, đã mất gì, Manifest đang `unrecovered` ở đâu, và phải làm gì để quay lại A?”**

| Có trong brief | Không được suy ra hoặc thêm vào |
|---|---|
| S11 phân biệt death trước/sau Manifest; S12 Recovery Contract; S1 recovery loadout; điểm thu hồi logic tại A; placement hợp lệ rồi extract A bình thường | Checkpoint/respawn mới, return đồ miễn phí, item/NPC/route/loot/story/contract mới, combat/AI/hazard/balance/economy, UI mockup/implementation, C/E playable, D extract, Hard/Extreme, incident/boss/elite, multiplayer |

`Niêm phong` luôn chỉ là bảo vệ trạng thái item; với Manifest, nó luôn ghi `đã niêm — chưa extract`. Nó không là delivery, success hay vé bỏ qua recovery/extract.

## 2. Quan hệ state được đề xuất

Sơ đồ là contract state có thể đọc được; không biểu thị toạ độ, tile/layout, respawn kỹ thuật hay implementation.

```text
                         death trước Manifest
S1 → S2 A ── không có Manifest ──> S11
                                      │
                                      └─ Contract 1 active; Manifest vẫn ở A
                                         → Chuẩn bị lại → S1 → S2 A

                         death sau khi đã nhặt Manifest
S2/S3/S4/S5, hoặc S8/S9 ─────────────> S11
                                      │
                                      v
                           S12 Recovery Contract
                                      │
                                      v
                         S1 recovery briefing/loadout
                                      │
                                      v
                        S2 A: bàn dispatch A
                                      │ tự thu hồi + placement hợp lệ
                                      v
                  Manifest đang mang; beacon A E1 callable
                                      │
                                      v
                     O5 → S7 → S8 → S9 → tự board A → S10
```

Death tại S8/S9 dùng nhánh **sau Manifest**: call/hold chưa hoàn tất, không checkpoint, không auto-board và không auto-extract. Nhánh trước Manifest không cần S12 vì Manifest vẫn nằm ở fixture ban đầu tại A và Contract 1 chưa đổi state.

## 3. S11 — death summary và hậu quả item

S11 phải khác rõ S10 success bằng tiêu đề, icon/hình trạng thái, wording và action tiếp theo; màu đơn lẻ không mang nghĩa quyết định. Cả hai hàng đều **không** là extract hay completion.

| Thời điểm death | `Đã giữ` | `Đã mất` | `Vật chứng` | Action tiếp theo / điều không được xảy ra |
|---|---|---|---|---|
| **Trước Manifest** | Item **không-phải-evidence** đã niêm hợp lệ. | Gear, ba lô/túi, loot không niêm và mọi đồ người chơi đã tự bỏ. | `Manifest Hàng Hóa R-17` vẫn ở **bàn dispatch A**; Contract 1 vẫn active, chưa có state `unrecovered` của run này. | `Chuẩn bị lại` → S1. Không tự đưa Manifest về hub/Archive, không restore đồ mất và không mở completion. |
| **Sau Manifest**, kể cả Manifest trong Hộp; gồm death ở **S8/S9** | Item **không-phải-evidence** đã niêm hợp lệ. | Gear, ba lô/túi, loot không niêm và mọi đồ tự bỏ; Recovery không trả lại chúng. | `Manifest Hàng Hóa R-17 — unrecovered`; không về hub/Archive, dù trước đó đã niêm. | `Xem Recovery Contract` → S12. Không coi seal/call/hold là delivery, checkpoint hay success. |

`Đã giữ`, `Đã mất`, `Vật chứng — unrecovered` và `Tiếp theo` là bốn nhóm luôn có label riêng, icon/shape riêng và thứ tự cố định. Summary chỉ liệt kê state thực tế; nó không auto-sort, auto-seal, auto-place hay tự quản lý lưới thay player.

## 4. S12 → S1 → S2 — Recovery Contract được đề xuất

| Chặng | Player thấy/làm | Contract phải giữ | Không được hàm ý |
|---|---|---|---|
| **S12: Recovery Contract** | Đọc ngắn: Manifest `unrecovered`, route quay A và action `Chuẩn bị recovery`. | Đây là đường tiếp tục Contract 1, không phải “đã giao vật chứng”. | Tự hoàn thành, tự trả Manifest về hub/Archive, tự đưa thẳng player lên thuyền hoặc checkpoint S8/S9. |
| **S1: recovery briefing/loadout** | Có một **basic/starter recovery loadout** hợp lệ để vào lại mà không mua lại original gear đã mất. Slot/lưới vẫn chỉ rõ `còn giữ`, `mất`, `trống`. | Kit chỉ cho một lựa chọn tối giản để tiếp tục; đồ niêm không-phải-evidence giữ theo S11. | Khôi phục gear/loot ban đầu, đồ tự bỏ, auto-buy/craft/fill hoặc sửa lại inventory hộ player. |
| **S2: điểm recovery A** | Player quay lại **bàn dispatch A** — fixture đã đọc ở pickup ban đầu — để tự thu hồi Manifest. | Đây là điểm thu hồi của vật chứng `unrecovered`, không phải fixture/nhân vật/item thứ ba; cùng bàn không biến nó thành respawn/checkpoint. | Gọi nó là “respawn” của Manifest, thêm navigation puzzle/route khác hoặc biến nó thành extract. |
| **Placement sau thu hồi** | Player phải đưa Manifest vào vị trí hợp lệ trong ba lô hoặc Hộp theo rule hiện có. Nếu niêm, label vẫn `đã niêm — chưa extract`. | Chỉ **sau placement hợp lệ**, beacon A chuyển từ E0 sang E1 callable. | Auto-placement/auto-seal, beacon callable khi chưa mang Manifest hoặc niêm = completion. |

Luồng này cho phép nhân vật về màn S1 sau khi chủ động chọn recovery; điều bị cấm là **Manifest/evidence tự trở về hub hoặc Archive**, và recovery tự đưa player qua state success. Không có “mua lại để được chơi tiếp” hay forced death để dạy recovery.

## 5. Sau thu hồi: route và success boundary

Sau khi lấy lại và đặt Manifest hợp lệ, player có quyền rút ngay hoặc đi tiếp:

| Lựa chọn sau S2 A | Kết quả hợp lệ |
|---|---|
| Quay về beacon A | `E1 → O5 → S7 → S8 → S9 → player board → S10`. A vẫn là extract duy nhất; extract sớm là success ngang full-route. |
| Đi B/D trước khi quay A | B/D vẫn optional; item/route decision bình thường vẫn áp dụng. D không có thuyền hay extract. |
| Nhìn C/E | C/E chỉ là silhouette non-interactive; không objective, input hay recovery branch. |

Chỉ S10 sau board A mới hoàn thành Contract 1. Khi đó Manifest mới được extract theo luật hệ thống; Contract 2 chỉ mở ở **campaign state** với nhãn `chưa có trong vertical slice`, không có nút bắt đầu. Recovery không mở Contract 2 và không đổi giá trị giữa early extract/full-route.

## 6. Kiểm tra đọc hiểu mobile và fairness

1. Trước khi chọn action ở S11, player có phân biệt được `Đã giữ`/`Đã mất`/`Vật chứng — unrecovered`/`Tiếp theo` bằng text + icon/shape/vị trí, không chỉ màu không?
2. S11 có khác S10 bằng outcome wording và action: không có tín hiệu `success`, `đã giao`, Archive hay “về hub với Manifest” không?
3. S12 có nêu đúng **một** hành động tiếp theo và S1 có một loadout recovery tối giản không cần mua, mà không tự restore/auto-manage item không?
4. Từ S1, player có thể đọc được route trở lại S2 A bằng landmark **bàn dispatch A** đã có, không cần puzzle điều hướng, route/map mới hay hướng dẫn lore dài không?
5. Placement sai/Hộp đầy có giữ nguồn item nguyên trạng và nêu lý do; sau placement hợp lệ beacon mới callable, trong khi Manifest niêm vẫn `chưa extract` không?
6. Real C3 có đi đúng `death thật → S11 → S12 → S1 → S2 → tự thu hồi → A extract`; không thay bằng narration, summary giả hay auto-return không?

## 7. Handoff và giới hạn mở

Prototype/readiness chỉ cần chứng minh G16–G18 và coverage C3: một death trước Manifest, một death sau Manifest với non-evidence đã niêm + gear/loot không niêm, starter recovery option, fixture A recovery và một success A sau thu hồi. C3 chỉ pass khi player tự phân biệt ba nhóm item và biết vẫn phải extract A.

Các câu hỏi cố ý để mở: biểu hiện cuối của bàn dispatch, wording/asset UI, control chi tiết, tuning combat/hazard, balance starter kit và implementation/save state. Nguồn recovery prototype đã chọn là **bàn dispatch A**; không thêm túi người đưa tin vào cut này. Các câu hỏi còn lại cần Task Card khác; không giải bằng checkpoint, restore, extract D, mở C/E, content mới hay thay rule death/recovery.
