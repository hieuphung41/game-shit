# Checklist visual/readability — bàn dispatch A, “Giữ giấy phép”

**Trạng thái:** arrangement visual/readability `proposed` cho Easy / Contract 1. Đây là checklist để review blockout/prototype của **một fixture hiện có** ở hai state; không phải asset brief, UI mockup, final copy/localization, camera/layout/control specification hay implementation plan.

**Nguồn ràng buộc:** [state contract dispatch A](black-tax-port-dispatch-state-contract.md), [wireflow UX](../vertical-slice-wireflow.md), [vertical slice](../vertical-slice.md), [blockout A/B/D](black-tax-port-vertical-slice-blockout.md), [build-readiness](../vertical-slice-build-readiness.md), [fixture C3](black-tax-port-recovery-c3-fixture-brief.md), [mini-card quan sát](black-tax-port-dispatch-observation-card.md) và [quyết định nguồn recovery](black-tax-port-recovery-source-decision.md). Nếu có khác biệt, slice/wireflow/readiness ưu tiên.

**Ghi chú nguồn:** [art direction](../art-direction.md), state contract, wireflow và readiness cùng dùng một rule: beacon A chỉ E0 → E1 **sau placement Manifest hợp lệ** ở cả pickup và recovery; E1 là callable, chưa là success.

## 1. Mục đích và ranh giới

Điều cần đọc được không phải là “bàn có giao diện mới”, mà là **vì sao cùng bàn dispatch A có action khác nhau ở state hiện tại**. Checklist kiểm tra semantic cue đã có: context landmark A, state/objective/action ngắn, text kèm icon/shape/thứ tự/vị trí, source item, validation placement và beacon E0/E1.

| Checklist kiểm tra | Không được suy ra hay thêm vào |
|---|---|
| Cách player phân biệt pickup đầu run với recovery `unrecovered`; thứ bậc đọc mobile; false reading và evidence C0/C3/readiness | Prop/asset/NPC/item/map/route/marker/minimap mới; prompt, final copy hay UI mockup; checkpoint/respawn; combat/AI/hazard/balance/economy; C/E gameplay, D extract, Contract 2 playable, Hard/Extreme, incident/boss/elite, multiplayer |

## 2. Hai state cần phân biệt

```text
PICKUP ĐẦU RUN — chỉ trước lần nhặt đầu tiên
S1 → S2 A → O2 bàn dispatch → Nhặt và xếp → placement hợp lệ → S3 / E1 callable

RECOVERY SAU MANIFEST — chỉ sau death sau Manifest
S11 (`unrecovered`) → S12 → S1 recovery → S2 A
→ Tự thu hồi và xếp → placement hợp lệ → S3 / E1 callable
→ A call/hold/board → S10
```

Hai đường dùng cùng landmark **bàn dispatch A + beacon/cầu tàu A + lối B**, nhưng không dùng chung entry gate. Quay lại S2 trong run thường không tạo pickup mới; death trước Manifest cũng không tạo action recovery. Đến bàn không tự đưa Manifest về hub/Archive, không auto-place/auto-seal, không restore gear/loot, và không là success.

## 3. Semantic cue cần cùng đọc được

### 3.1 Cue dùng chung, không mang nghĩa completion

| Cue đã có | Phải giúp player hiểu | Không được bị đọc thành |
|---|---|---|
| Context A: bàn dispatch, beacon/cầu tàu A và lối B cùng một góc đọc | Đây là landmark để lấy Manifest, sau đó chọn rút A hoặc đi B/D; không có landmark recovery mới. | Bàn là checkpoint; lối B/full-route bắt buộc; C/E hoặc D là route/extract thay thế. |
| Source item còn ở bàn trước action commit | Cần một action thủ công; hủy/fail placement giữ item ở source. | Chạm/đến A là auto-pickup, auto-return hay auto-management. |
| Beacon độc lập với bàn: E0 trước placement, E1 chỉ sau placement hợp lệ | Placement mới làm A callable. | Đến bàn, nhìn Manifest hoặc niêm Manifest đã extract/delivery. |
| E1 callable | Player đã có quyền **gọi thuyền**, rồi còn call/hold/board. | E1, call accepted hoặc boat ready là success tự động. |
| Nhãn Manifest khi đã niêm | `đã niêm — chưa extract`; seal bảo vệ trạng thái, không đổi success boundary. | Seal là bàn giao, completion, hoặc miễn recovery. |

### 3.2 Cue theo state của bàn dispatch

| State / gate | Những semantic cue phải nhất quán ở cơ hội đọc | Hành động/diễn giải player cần tự hình thành | False reading cần loại |
|---|---|---|---|
| **Pickup đầu run** — S1 → S2, trước khi Manifest từng được nhặt | Manifest ở source có state `chưa xác thực`; objective/action cùng nói **lấy / `Nhặt và xếp`**; O2 và placement là bước commit. E0 vẫn unavailable trước placement. | Đây là Manifest đầu run; tự đặt vào ba lô/Hộp hợp lệ, rồi tự chọn rút A hay đi B/D. | Manifest đã thuộc inventory/hub; bàn tự giao Manifest; pickup hoàn thành Contract; B/D bắt buộc. |
| **Recovery `unrecovered`** — chỉ sau S11 → S12 → S1 recovery → S2 | S11/S12 trước đó đã chỉ Manifest `unrecovered`, không ở hub/Archive; ở bàn objective/action cùng nói **thu hồi / `Tự thu hồi và xếp`**. Cùng E0 trước placement, nhưng không có source/route/NPC thứ ba. | Đây là recovery của Manifest đã mất trong run trước; tự thu hồi rồi placement hợp lệ, sau đó vẫn phải extract A. | Respawn/checkpoint; Manifest tự quay lại; gear/loot đã mất được trả; bàn giao/completion hoặc Contract 2 mở. |

Không yêu cầu một visual/interaction mới để phân biệt hai hàng. Nếu objective/action/state Manifest mâu thuẫn với entry gate, đó là lỗi readability của fixture hiện có, không phải lý do thêm marker, narrator hay item.

## 4. Thứ bậc đọc trên mobile

Checklist này không chốt kích thước, toạ độ hay treatment cuối. Ở mỗi cơ hội đọc, reviewer chỉ xác nhận player còn nhận được các tầng nghĩa sau theo thứ tự:

1. **State hiện tại:** pickup đầu run hay recovery sau `unrecovered`, qua objective/action và state Manifest; không chỉ bằng màu.
2. **Action thủ công tiếp theo:** `Nhặt và xếp` hoặc `Tự thu hồi và xếp`, rồi placement hợp lệ. Không có cue nào nói system đã làm thay player.
3. **Boundary extract:** E0 trước placement; E1 sau placement; A call/hold/board mới S10.
4. **Context route:** bàn dispatch, beacon/cầu tàu A, lối B cùng đọc được; B/D vẫn là lựa chọn, C/E không có affordance.
5. **An toàn vận hành:** mở O2/O3/O4 không che health, objective ngắn hay telegraph/cảnh báo gần nhất; placement fail/hủy vẫn để source rõ ràng.

Nếu một tầng chỉ hiện nhờ màu, bị foreground/HUD/overlay che, hoặc chỉ được hiểu sau lời giải thích của facilitator, nó chưa pass checklist. Không chữa bằng popup lore, route hint, prompt mới hay final UI.

## 5. Checklist review state/frame

| Moment cần quan sát | Pass khi evidence trên màn cho thấy | Fail/readability finding nếu | Handoff đúng |
|---|---|---|---|
| **C0, S2 initial — trước O2** | Player tự nhận ra bàn là nguồn Manifest đầu run; beacon E0 và lối B vẫn cùng context; không cue recovery. | Player coi bàn là extract/checkpoint hoặc nghĩ Manifest đã tự thuộc inventory. | Ghi state → action/lời nói đầu tiên → cue/outcome; không giải thích recovery hay chỉ action. |
| **Initial placement** | Player tự làm placement hợp lệ vào ba lô **hoặc** Hộp; chỉ sau commit E0 → E1. Nếu player chọn niêm, label vẫn `đã niêm — chưa extract`. | Beacon/callable bật trước placement, source biến mất khi hủy/fail, hoặc seal đọc thành delivery. | Outcome thật như beacon/source sai là `BLOCKER` build/readiness; nếu build đúng state nhưng player hiểu sai, ghi candidate wording/presentation theo §6. Build không tạo được state đúng luật là `NOT READY`. |
| **C3, S2 recovery — sau death thật** | Sau S11 → S12 → S1, player đọc cùng bàn là nguồn **thu hồi** Manifest `unrecovered`; tự làm recovery placement; E1 chưa success. | Build tự trả Manifest/restore gear/tự complete tại E1, hoặc player đọc bàn là respawn/checkpoint trong build đúng state. | Outcome thật trái invariant là `BLOCKER` build/readiness; hiểu sai của player là candidate theo §6. Chạy sau C0; observer ghi state → action đầu tiên → lời nói đầu tiên → outcome → can thiệp/confounder. Không chỉ location, bàn hay action. |
| **Sau placement ở cả hai state** | Player biết A call/hold/board vẫn cần cho S10; rút sớm và đi B/D đều là lựa chọn hợp lệ. | Player chờ auto-win, tin full-route bắt buộc, hoặc D/C/E là extract. | Giữ failure trong extract/readability scope; không thêm route/extract khác. |

## 6. Readiness và phân loại finding

| Điều phát hiện | Phân loại | Điều không được làm |
|---|---|---|
| Thiếu state thật, source/placement/E0/E1 hoặc sequence C3 không tạo được trước phiên | `NOT READY`; không mời first-time player vào coverage. | Dùng mock text, narrator, state giả hoặc tự trả Manifest về hub để “test” cách đọc. |
| Thiếu fixture/state chỉ lộ trong phiên C3 | `KHÔNG TEST ĐƯỢC`; ghi state thiếu rồi trả C3 readiness về `NOT READY`. | Chấm P6 từ lời kể hoặc tự sửa UX/rule trong phiên. |
| Outcome **thật của build** tự trả Manifest/auto-pickup, restore gear/loot, làm seal/E1 completion, hoặc không còn cần extract A | `BLOCKER` build/readiness: dừng phiên, ghi state → action → outcome, trả readiness về `BLOCKER` và mở ngay một Task Card state/readiness hẹp theo [build-readiness §9](../vertical-slice-build-readiness.md). | Chờ synthesis, gọi đây chỉ là hiểu sai player, hoặc bù bằng content mới. |
| Một player, trong build đúng state, gọi bàn là checkpoint/respawn, tin auto-return/auto-pickup, seal/E1 là completion, hoặc tin không cần extract A | `BLOCKER candidate semantic/readability`: ghi state → action/lời nói đầu tiên → outcome và chuyển sang [mẫu tổng hợp](../playtest-synthesis-template.md) §§8–9. Chỉ synthesis mới chốt repair/MUST_FIX sau source/coverage hợp lệ, comparability, không confounder và reproduction. | Mở repair Task Card từ một finding/card, hoặc thêm túi người đưa tin, NPC, marker, route, narrator, checkpoint hay restore để che finding. |
| Player gán sai một nghĩa khác nhưng không gây soft-lock nhận thức hay mất đồ không được cảnh báo | `FAIL` có state → action/lời nói → cue/outcome cụ thể; follow protocol trước khi mở task. | Suy từ thao tác chậm, death, rút sớm, bỏ cargo hoặc một preference rằng player không hiểu. |
| Control/technical confounder làm action không phản ánh hiểu biết | `INVESTIGATE`; ghi `CAN THIỆP CONTROL` nếu đã hỗ trợ thao tác trung tính. | Kết luận `PASS` cho claim phụ thuộc hỗ trợ hoặc đổi gameplay outcome. |

Không có probe hay câu facilitator mới: C0 chạy trước C3; C3 dùng death thật; P6 chỉ pass khi player tách được non-evidence niêm giữ, gear/loot không niêm mất, Manifest `unrecovered`, và A extract vẫn cần.

## 7. Invariant và giới hạn mở

- Easy / Contract 1; A là extract duy nhất. B/D optional, D không extract; C/E là silhouette non-interactive. Early extract ngang full-route tại success boundary.
- Manifest niêm luôn `đã niêm — chưa extract`; death sau Manifest luôn `unrecovered`. Non-evidence niêm giữ; gear/loot không niêm và đồ tự bỏ mất.
- Contract 2 chỉ là campaign state `chưa có trong vertical slice` sau S10. Pickup/recovery không mở Contract 2.
- `Túi người đưa tin` vẫn là khả năng map-scale canon ngoài slice; checklist không dựng, đặt tên, hiển thị hay thay thế bàn dispatch A bằng túi đó.

Các câu hỏi cố ý để mở: final visual/audio treatment, asset, final copy/localization, screen/layout/camera chi tiết, control, persistence và implementation. Chúng cần Task Card khác; không giải bằng content mới, checkpoint/respawn, route/extract thứ hai hoặc thay luật recovery/extract.
