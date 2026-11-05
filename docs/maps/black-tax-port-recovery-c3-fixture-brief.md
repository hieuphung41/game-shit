# C3 fixture & wording brief — death → Recovery, “Giữ giấy phép”

**Trạng thái:** arrangement quan sát và wording semantics `proposed` cho Easy / Contract 1. Tài liệu khóa điều phải thấy khi prototype chạy coverage C3; không phải UI mockup, final copy/localization, save-state specification hay implementation plan.

**Nguồn ràng buộc:** [protocol quan sát](../playtest-observation-sheet.md), [build-readiness](../vertical-slice-build-readiness.md), [wireflow UX](../vertical-slice-wireflow.md), [recovery brief](black-tax-port-recovery-brief.md), [vertical slice](../vertical-slice.md), [inventory/loadout](../systems/inventory-and-loadout.md) và [brief extract A](black-tax-port-a-extract-brief.md). Khi có khác biệt, protocol/readiness/wireflow ưu tiên.

## 1. Mục đích, phạm vi và non-goals

C3 kiểm tra một điều hẹp: sau death thật, người chơi có phân biệt được đồ giữ/mất, Manifest `unrecovered`, và việc vẫn phải extract A hay không. Nó là **coverage có kiểm soát chỉ dùng sau C0**, không phải lesson cho first-time run và không được dùng để đánh giá combat/balance.

| Có trong brief | Không được suy ra hoặc thêm vào |
|---|---|
| Entry fixture, semantic content S11/S12/S1/S2, neutral observation boundary và điều kiện claim P6 | Item/gear/NPC/route/story/contract mới; forced-death device; combat/AI/damage/timing; checkpoint/respawn; final UI/layout/asset/localization/implementation; shop/craft/economy; C/E gameplay, D extract, Contract 2 playable, Hard/Extreme, incident/boss/elite, multiplayer |

Những câu dưới đây là **semantic wording requirement**, không là câu chữ cuối hay prompt lore mới. Mỗi state phải giữ một objective/action ngắn, khác success wording và đọc được bằng text kèm icon/shape/thứ tự/vị trí — không chỉ màu.

## 2. Entry fixture C3 và ranh giới death thật

Trước C3, C0 đã kết thúc. C3 bắt đầu từ một state in-run hợp lệ đã làm lộ ba nhóm để summary có ý nghĩa so sánh:

| Thành phần trước death | Bằng chứng phải thấy | Không được làm |
|---|---|---|
| Manifest | `Manifest Hàng Hóa R-17` đã đặt **trong Hộp Công Chứng** với label `đã niêm — chưa extract`. | Đưa Manifest về hub/Archive, coi niêm là delivery, hoặc dùng Manifest chưa có placement hợp lệ. |
| Non-evidence niêm | Có **một item đã tồn tại** mang nhãn niêm hợp lệ trong Hộp và không phải Story evidence. | Đặt tên/thêm item mới chỉ để demo, hoặc để mọi đồ Hộp bị gộp thành evidence. |
| Gear/loot không niêm | Có ít nhất một gear hoặc loot hiện đang không niêm để S11 chứng minh nhóm `Đã mất`. | Auto-seal, auto-drop, auto-manage hay giả summary không có vật thật tương ứng. |

Sau fixture, player chết bằng **một death in-run thật** qua state đã tồn tại. Brief này không chỉ định enemy, hazard, damage, timing, vị trí hay cách ép chết. Nếu build không vào được death thật → S11 → S12 → S1 → S2 theo thứ tự, C3 là `NOT READY`; không thay bằng narrator, summary giả, demo bằng lời hoặc auto-return Manifest về hub.

Death ở S8/S9 cũng dùng nhánh sau-Manifest: call/hold chưa hoàn tất, thuyền không auto-board và không có checkpoint. C3 không buộc phải chọn S8/S9 làm nơi death; đó là invariant phải giữ nếu fixture đi qua state này.

## 3. S11 — semantic content phải quan sát được

S11 luôn dùng bố cục logic theo thứ tự **`Đã giữ` → `Đã mất` → `Vật chứng` → `Tiếp theo`**. Header/outcome/action phải khác S10 success bằng text, icon/shape hoặc placement; không dùng `đã giao`, Archive, success signal hay wording hoàn thành Contract 1.

| Case S11 | `Đã giữ` | `Đã mất` | `Vật chứng` | `Tiếp theo` và boundary |
|---|---|---|---|---|
| **Trước Manifest** — contrast fixture, không phải entry C3 | Item **không-phải-evidence** đã niêm hợp lệ. | Gear/loot không niêm và đồ player đã tự bỏ. | Manifest vẫn ở **bàn dispatch A**; Contract 1 active. | `Chuẩn bị lại` → S1. Không gọi death là extract/completion hay recovery checkpoint. |
| **Sau Manifest** — entry C3, kể cả niêm trong Hộp và death S8/S9 | Item **không-phải-evidence** đã niêm hợp lệ. | Gear/loot không niêm và đồ player đã tự bỏ. | `Manifest Hàng Hóa R-17 — unrecovered`; không về hub/Archive. | `Xem Recovery Contract` → S12. Seal/call/hold không là delivery, restore hay success. |

Trong C3, ba nhóm cụ thể của row sau Manifest phải phản chiếu đúng fixture §2. Summary chỉ báo state: không tự sort, place, seal, remove hoặc thay inventory decision của player.

## 4. S12 → S1 → S2 — wording/action requirements được đề xuất

| State | Semantic wording/action tối thiểu | Validation phải còn giữ | Không được hàm ý |
|---|---|---|---|
| **S12 Recovery Contract** | Nêu Manifest **chưa được bàn giao** / `unrecovered`, và một action tiếp theo `Chuẩn bị recovery`. | Action chỉ dẫn vào S1 recovery; Contract 1 chưa complete. | “Đã giao”, auto-complete, trả Manifest về hub/Archive, thuyền/checkpoint S8/S9. |
| **S1 recovery briefing/loadout** | Nêu các slot `còn giữ` / `mất` / `trống`; có một lựa chọn **basic/starter recovery loadout** hợp lệ không cần mua. | Đồ niêm non-evidence giữ theo S11; placement/loadout validation bình thường vẫn chạy. | Original gear/loot hoặc đồ tự bỏ được trả lại; auto-buy/craft/fill/sort. |
| **S2 A recovery point** | Nêu một mục tiêu ngắn: quay tới **bàn dispatch A** đã có để thu hồi Manifest. | Đây chỉ là điểm logic sau state `unrecovered`; cùng fixture pickup không là spawn thứ hai, và không có item/NPC/route thứ ba. | Điểm spawn Manifest ban đầu thứ hai, navigation puzzle, route/map hoặc extract mới. |
| **Sau thu hồi** | Nêu player phải đặt Manifest vào ba lô/Hộp hợp lệ; nếu niêm vẫn `đã niêm — chưa extract`. | Chỉ placement hợp lệ mới chuyển beacon A E0 → E1 callable. | Auto-placement/auto-seal; beacon callable trước khi mang Manifest; recovery = success. |

Nhân vật có thể về S1 sau death để chuẩn bị recovery; điều cấm là **Manifest/evidence tự về hub hoặc Archive**, hoặc đồ đã mất tự được khôi phục. Sau S2, player vẫn tự gọi/giữ/board tại A để vào S10.

## 5. Sequence quan sát C3 và quyết định P6

Facilitator không nói outcome trước S11. Probe trung tính duy nhất trước summary là: **“Đây là một state khác của build. Trước khi xem summary, bạn nghĩ điều gì xảy ra tiếp?”** Không nói Manifest sẽ `unrecovered`, không gọi death là bài học/yêu cầu và không chỉ route/icon/action.

| Bước | Observer ghi theo thứ tự | Facilitator không được làm |
|---|---|---|
| Trước S11 | State fixture → prediction/action đầu tiên → lời nói đầu tiên. | Nhắc outcome, chỉnh lựa chọn hay giải thích Hộp/evidence. |
| S11 | Outcome trên màn của bốn nhóm → action đầu tiên → lời nói đầu tiên. | Diễn giải `Đã giữ`/`Đã mất`/`unrecovered` thay player. |
| S12 → S1 → S2 | State → action đầu tiên → lời nói đầu tiên → outcome → intervention/confounder. | Chỉ đường recovery, trả lời route thay player hoặc tự thao tác inventory. |
| Technical stuckness | Ghi `CAN THIỆP CONTROL` trước hỗ trợ control trung tính. | Đổi outcome/gameplay; claim phụ thuộc hỗ trợ thành `PASS`. |

P6 chỉ `PASS` khi player tự phân biệt được: (1) non-evidence đã niêm được giữ, (2) gear/loot không niêm đã mất, (3) Manifest là `unrecovered`, và (4) vẫn cần một extract A thành công. **Thiếu fixture/state là C3 readiness `NOT READY` và không được mời player vào coverage.** Nếu lỗi đó chỉ lộ ra trong một phiên đã bắt đầu, record phiên là `KHÔNG TEST ĐƯỢC` **đồng thời** trả C3 readiness về `NOT READY`. Technical/control confounder là `INVESTIGATE`; hiểu sai state/outcome là evidence `FAIL`, không phải lý do thêm lore/popup/reward ngay trong session.

## 6. Invariant và handoff readiness

1. Easy / Contract 1 còn nguyên; A là extract thật duy nhất. B/D optional, D không extract; C/E chỉ silhouette non-interactive.
2. Early extract sau Manifest bằng full-route về success boundary. Contract 2 chỉ thành campaign state `chưa có trong vertical slice` sau S10; C3/recovery không mở nó.
3. Manifest niêm vẫn `chưa extract`; death sau Manifest vẫn `unrecovered`; sealed non-evidence giữ, unsealed gear/loot mất, không restore đồ tự bỏ.
4. G16–G18 và C3 chỉ `READY` khi sequence chạy trong build thật. Readiness/prototype handoff phải nêu state/action/outcome thực tế, không thay fixture thiếu bằng lời kể.

Các câu hỏi cố ý để mở: final copy/localization, layout/asset accessibility, control cụ thể, thành phần starter kit, persistence/save state, combat/hazard tuning và implementation. Chúng phải được mở bằng Task Card khác; không giải bằng content mới, checkpoint, restore, A/D extract khác hay thay recovery rule.
