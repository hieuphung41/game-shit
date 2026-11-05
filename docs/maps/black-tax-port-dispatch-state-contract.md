# State contract — bàn dispatch A, “Giữ giấy phép”

**Trạng thái:** arrangement state/readability `proposed` cho Easy / Contract 1. Tài liệu làm rõ một fixture đã có đọc khác nhau ở pickup đầu run và recovery `unrecovered`; không là UI mockup, final copy, asset brief, layout/control/implementation plan hoặc luật recovery mới.

**Nguồn ràng buộc:** [wireflow UX](../vertical-slice-wireflow.md), [vertical slice](../vertical-slice.md), [build-readiness](../vertical-slice-build-readiness.md), [protocol quan sát](../playtest-observation-sheet.md), [blockout A/B/D](black-tax-port-vertical-slice-blockout.md), [recovery brief](black-tax-port-recovery-brief.md), [fixture C3](black-tax-port-recovery-c3-fixture-brief.md) và [quyết định nguồn Recovery A](black-tax-port-recovery-source-decision.md). Khi có khác biệt, slice/wireflow/readiness ưu tiên.

## 1. Mục đích và ranh giới

Một bàn dispatch A phục vụ hai state hợp lệ, không phải hai điểm map: **lấy Manifest lần đầu** và **tự thu hồi Manifest đã `unrecovered`**. Điều phải đọc được là *tại sao action hiện tại khác*, không phải một visual/interaction mới.

| Có trong contract | Không được suy ra hoặc thêm vào |
|---|---|
| Điều kiện vào state, semantic objective/action, Manifest/beacon outcome, cue hiện có và observation check | Prop/asset/NPC/item/route/map mới; marker/minimap/prompt mới; checkpoint/respawn; combat/AI/hazard/balance/economy; final UI/copy/localization/control/layout/implementation; C/E gameplay, D extract, Contract 2 playable, Hard/Extreme, incident/boss/elite, multiplayer |

`Bàn dispatch A` luôn là landmark đã có cùng beacon A và lối B. Cùng fixture **không** tự đưa Manifest về hub/Archive, không khôi phục gear/loot, không auto-place/auto-seal và không là success.

## 2. Quan hệ state: pickup ban đầu và recovery

```text
INITIAL PICKUP
S1 → S2 A (Manifest chưa lấy; bàn dispatch; E0 unavailable)
       → mở O2 → Nhặt và xếp + placement hợp lệ
       → S3 đang mang Manifest; E1 callable

RECOVERY SAU MANIFEST
S11 (Manifest unrecovered) → S12 → S1 recovery → S2 A recovery
       (bàn dispatch; action thu hồi chỉ ở state này; E0 unavailable)
       → tự thu hồi + placement hợp lệ
       → S3 đang mang Manifest; E1 callable
       → E1 → O5 → S7 → S8 → S9 → tự board A → S10
```

Nhánh recovery không tồn tại trước pickup đầu tiên, sau death trước Manifest, hoặc chỉ vì player quay lại S2 trong run thường. Nhánh initial không được hiện lại như một pickup mới sau `unrecovered`. Cả hai chỉ chuyển beacon từ E0 sang E1 **sau** placement hợp lệ; E1 là quyền gọi thuyền, không là delivery/completion.

## 3. Contract so sánh hai interaction của bàn dispatch

Các tên dưới đây là semantic action ngắn `proposed`, không chốt label/UI cuối. Cả hai dùng cùng logic placement hiện có; không phát sinh overlay, control hay action loại mới.

| Dimension | **Pickup ban đầu** | **Recovery `unrecovered`** |
|---|---|---|
| Entry condition | S1 → S2 của Contract 1, trước khi Manifest từng được nhặt. | Chỉ sau death **sau Manifest** theo S11 → S12 → S1 recovery → S2. |
| Manifest state | Ở bàn dispatch, `chưa xác thực`; chưa thuộc inventory/hub. | `Vật chứng — unrecovered`; không ở hub/Archive, kể cả nếu đã niêm lúc death. |
| Objective/action semantics | Mục tiêu ngắn là lấy Manifest; action là **`Nhặt và xếp`** qua O2. | Mục tiêu ngắn là thu hồi Manifest; action là **`Tự thu hồi và xếp`** tại cùng fixture. |
| Placement & seal | Chỉ placement ba lô/Hộp hợp lệ mới commit; hủy/fail giữ source. Nếu niêm: `đã niêm — chưa extract`. | Cùng validation và label; không tự trả vào Hộp, auto-place, auto-seal, auto-sort hoặc trả gear/loot đã mất. |
| Beacon result | Trước placement: E0 unavailable. Sau placement: E1 callable. | Trước placement: E0 unavailable. Sau placement: E1 callable; recovery không bỏ qua extract. |
| Next transition | S3 → rút A ngay hoặc tự đi B/D rồi quay A. | S3 → cùng lựa chọn rút A hoặc B/D; A call/hold/board vẫn bắt buộc để thành S10. |
| Không được đọc thành | Pickup = auto-delivery hoặc full-route bắt buộc. | Respawn/checkpoint, auto-return evidence, restore, completion hay Contract 2 mở. |

Death trước Manifest quay về S1 với Contract 1 active; Manifest vẫn là initial source ở bàn dispatch A, không có action recovery. Death S8/S9 theo nhánh recovery sau Manifest: call/hold chưa hoàn tất, không auto-board và không checkpoint.

## 4. Readability/mobile guardrails cho fixture tái dùng

1. Góc đọc A vẫn cho thấy **bàn dispatch, beacon/cầu tàu A và lối B** trong cùng context; không thêm landmark/route/marker để phân biệt pickup và recovery.
2. Objective ngắn + action semantics + state Manifest phải cùng nói một nghĩa; dùng text kèm icon/shape/thứ tự/vị trí sẵn có, không chỉ đổi màu hay tạo prompt lore dài.
3. Beacon giữ cue E0/E1 độc lập với bàn: E0 trước placement, E1 chỉ sau placement. Như vậy player không hiểu “đến bàn” hoặc “đã niêm” là extract.
4. Placement fail/hủy để Manifest ở source; không thay item, không tự quản lý Hộp/ba lô và không che health/objective/telegraph nếu overlay đang mở.
5. Không cần action confirmation mới cho inspect/đóng/placement preview. Confirmation hiện có chỉ giữ nơi action đã có hậu quả khó đảo như gọi thuyền; không biến bàn dispatch thành chuỗi popup.

## 5. Evidence C0/C3, readiness và P6

| Coverage | Điều quan sát được | Điều facilitator/record phải giữ |
|---|---|---|
| **C0 — run tự nhiên** | Ở S2 initial, player đọc bàn dispatch là nguồn Manifest đầu run, đặt hợp lệ rồi biết beacon callable; họ vẫn tự chọn rút A hay B/D. | Không gọi tên recovery, không dạy route và không biến C0 thành C3. |
| **C3 — death → Recovery** | Sau fixture/death thật: S11 → S12 → S1 recovery → S2; player nhận ra bàn dispatch là nguồn **thu hồi**, tự lấy/đặt Manifest, rồi hiểu phải extract A. | Chạy sau C0; không chỉ location/action, không kể outcome hay dùng summary giả. Ghi state → action đầu tiên → lời nói đầu tiên → outcome → intervention/confounder. |
| **P6 / readiness** | P6 chỉ pass khi player tự tách được non-evidence niêm giữ, gear/loot không niêm mất, Manifest `unrecovered`, và extract A vẫn cần. | Fixture/state thiếu là C3 readiness `NOT READY`, không mời player. Nếu chỉ lộ trong phiên đã mở: record `KHÔNG TEST ĐƯỢC` và trả readiness về `NOT READY`; control help làm claim phụ thuộc thành `INVESTIGATE`. |

Nếu người chơi không nhận ra recovery state tại bàn dispatch, finding là problem presentation/wording của fixture tái dùng. Không tự chữa bằng túi người đưa tin, NPC, marker, route, narrator, checkpoint hay gear restore.

## 6. Invariant và giới hạn mở

- Easy / Contract 1; A là extract duy nhất. B/D optional, D không extract; C/E non-interactive. Early extract bằng full-route tại success boundary.
- Manifest niêm luôn `đã niêm — chưa extract`; death sau Manifest luôn `unrecovered`; sealed non-evidence giữ, gear/loot không niêm và đồ tự bỏ mất.
- Contract 2 chỉ là campaign state `chưa có trong vertical slice` sau S10; pickup/recovery không mở nó.
- Cùng bàn dispatch là fixture prototype; `túi người đưa tin` vẫn là khả năng map-scale ngoài slice, không được dựng/hiển thị ở cut này.

Các câu hỏi cố ý để mở: final wording/localization, visual/audio treatment, screen/layout, control, asset, persistence và implementation. Chúng cần Task Card khác; không giải bằng nội dung mới, route/extract thứ hai, checkpoint/respawn hoặc thay luật recovery/extract.
