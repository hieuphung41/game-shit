# Quyết định nguồn Recovery A — “Giữ giấy phép”

**Trạng thái:** quyết định fixture prototype `proposed` cho Easy / Contract 1. Quyết định này thu hẹp một alternative wording đã có thành một điểm recovery đọc được; không thêm prop, NPC, route, item, story hay cơ chế recovery.

**Nguồn đối chiếu:** [vertical slice](../vertical-slice.md), [wireflow UX](../vertical-slice-wireflow.md), [build-readiness](../vertical-slice-build-readiness.md), [blockout A/B/D](black-tax-port-vertical-slice-blockout.md), [recovery brief](black-tax-port-recovery-brief.md), [fixture C3](black-tax-port-recovery-c3-fixture-brief.md), [map contract rộng](black-tax-port.md), [item card rộng](../items/black-tax-port-items.md) và [inventory/loadout](../systems/inventory-and-loadout.md).

## 1. Quyết định

**Chọn `bàn dispatch A` làm nguồn thu hồi Manifest của prototype sau state `unrecovered`.**

Đây là cùng fixture contract đã được người chơi thấy trước khi nhặt Manifest; nó **không** có nghĩa Manifest “respawn”, checkpoint hay tự quay về hub/Archive. State recovery vẫn bắt buộc đi `S11 → S12 → S1 → S2`, player tự thu hồi, đặt Manifest hợp lệ, rồi tự gọi/giữ/board ở A để extract thành công.

## 2. So sánh hai phương án đã có

| Tiêu chí | Bàn dispatch A | Túi người đưa tin A | Kết luận cho prototype |
|---|---|---|---|
| Hỗ trợ từ nguồn | Là vị trí Manifest ban đầu trong briefing, spawn A, wireflow và blockout; player đã tương tác nó. | Là khả năng map-scale trong [map contract rộng](black-tax-port.md) và [item card rộng](../items/black-tax-port-items.md), nhưng chưa có fixture trong tài liệu vertical-slice. | Dispatch có evidence fixture prototype mạnh hơn. |
| First-read/mobile | Cùng camera với player, beacon A và lối B; landmark đã dạy trước recovery. | Chưa có landmark, camera contract hay affordance riêng. | Dispatch không đòi player học một điểm mới. |
| Causality recovery | Nhãn S12/S1 làm rõ state `unrecovered`; quay về bàn để **tự thu hồi** không là extract. | Muốn dùng được phải định nghĩa/cho thấy prop, source hoặc lời giải thích bổ sung. | Dispatch giữ recovery là state transition, không mở content mới. |
| C3 observability | Observer có một fixture A đã biết để kiểm tra `unrecovered → thu hồi → placement → E1`. | Mơ hồ liệu player có nhận ra/đến đúng túi mà không facilitator hint. | Dispatch giảm confounder presentation trong C3. |
| Rủi ro scope | Không cần asset, route, NPC, item hay navigation puzzle mới. | Dễ kéo theo prop mới, naming/visual treatment và một landmark thứ hai. | Dispatch là phương án tối thiểu. |

`Túi người đưa tin A` không được dựng, đặt tên, hiển thị hay dùng trong prototype hiện tại. Map/item documentation rộng hơn vẫn giữ nó như khả năng map-scale; card này chỉ chọn bàn dispatch A cho vertical slice, **không** retcon canon ngoài slice.

## 3. Contract sau quyết định

| State | Điều player thấy/làm | Boundary giữ nguyên |
|---|---|---|
| Trước Manifest | `Manifest Hàng Hóa R-17` ở **bàn dispatch A**; beacon E0 unavailable. | Đây là pickup ban đầu, không phải recovery. |
| Death sau Manifest | S11 nêu Manifest `Vật chứng — unrecovered`; không về hub/Archive, dù đã niêm. | Đồ niêm không-phải-evidence giữ; gear/loot không niêm và đồ tự bỏ mất. |
| S12 → S1 → S2 | Recovery Contract dẫn player quay **bàn dispatch A** để tự thu hồi Manifest. | Không checkpoint, không auto-complete, không restore lost/dropped gear. |
| Sau thu hồi | Player đặt Manifest vào ba lô/Hộp hợp lệ; nếu niêm vẫn `đã niêm — chưa extract`. | Chỉ placement hợp lệ mới E0 → E1 callable; actual success vẫn cần A call/hold/board. |

Easy / Contract 1 không đổi: A là extract duy nhất; B/D optional, D không extract; C/E non-interactive; early extract bằng full-route tại success boundary. Contract 2 chỉ là campaign state `chưa có trong vertical slice` sau S10, không mở bởi recovery.

## 4. Handoff và giới hạn mở

Readiness/C3 chỉ cần xác nhận bàn dispatch A vẫn đọc được như landmark và recovery source mà không cần facilitator route hint. Nếu player không nhận ra điểm recovery, finding là presentation/readability của fixture hiện có; không được tự thêm túi, NPC, marker, route hay narration để che lỗi.

Các câu hỏi cố ý để mở: final prop/asset, final wording/localization, layout chính xác, control, save-state và implementation. Chúng cần Task Card khác; không thay bằng checkpoint, thuyền D, mở C/E, content mới hay sửa luật extract/death/recovery.
