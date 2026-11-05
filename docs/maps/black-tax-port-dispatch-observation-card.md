# Mini-card quan sát — bàn dispatch A, C0/C3

**Trạng thái:** observer-only arrangement `proposed` cho một phiên playtest Easy / Contract 1. Sao chép card trống này cho một phiên; nó bổ sung cách ghi evidence cho bàn dispatch A, không thay [phiếu quan sát](../playtest-observation-sheet.md), không thêm facilitator script và không tạo claim ID mới.

**Nguồn ràng buộc:** [phiếu quan sát](../playtest-observation-sheet.md), [build-readiness](../vertical-slice-build-readiness.md), [wireflow UX](../vertical-slice-wireflow.md), [state contract dispatch A](black-tax-port-dispatch-state-contract.md), [fixture C3](black-tax-port-recovery-c3-fixture-brief.md) và [quyết định nguồn Recovery A](black-tax-port-recovery-source-decision.md). Nếu có khác biệt, phiếu quan sát/readiness/wireflow ưu tiên.

## 1. Scope và preflight của phiên

```text
Build label / control scheme:
Observer / facilitator:
Build GO theo readiness: Có / Không
C0 đã ghi trước C3: Có / Không / Chưa chạy

C0 source: save/profile mới, Easy · Contract 1 · A/B/D · A là extract duy nhất
C3 fixture: Manifest niêm + non-evidence niêm + gear/loot không niêm + death thật: READY / NOT READY
```

Card không ghi tên/contact người chơi, không ghi kết quả test sẵn và không mời/recruit/run test. C0 là run tự nhiên: không buộc death, B/D, full-route hay rút sớm. C3 chỉ bắt đầu sau C0 và khi fixture thật `READY`.

| State build | Hành động đúng của facilitator/observer |
|---|---|
| C3 fixture/state thiếu trước phiên | C3 **và readiness của first-time session** là `NOT READY`; không mời player vào phiên và không mô phỏng bằng lời/summary giả. |
| Thiếu fixture/state chỉ lộ khi phiên đang chạy | Ghi coverage `KHÔNG TEST ĐƯỢC`, nêu state thiếu, rồi trả C3 readiness về `NOT READY`. |
| Player kẹt control/kỹ thuật | Chỉ hỗ trợ control trung tính theo protocol, ghi `CAN THIỆP CONTROL`; claim phụ thuộc là `INVESTIGATE`. |

## 2. C0 — ghi initial pickup, không thêm probe

**Facilitator không nói thêm câu hỏi nào riêng cho bàn dispatch trong C0.** Không nói recovery, death, kết quả Manifest, route đúng hay action cần chạm. Observer chỉ ghi evidence theo thứ tự `state → action đầu tiên → lời nói đầu tiên → cue/outcome → can thiệp/confounder`.

| Beat/state cần gặp | Player action đầu tiên | Lời nói đầu tiên | Cue/outcome trên màn | Can thiệp/confounder | Claim hiện có |
|---|---|---|---|---|---|
| `S2 A`: bàn dispatch + beacon E0 + lối B |  |  |  |  | P1, P8a |
| `O2`: Manifest source/pickup |  |  |  |  | P1, P6 |
| Placement hợp lệ → `S3` / beacon E1 |  |  |  |  | P1, P2, P6, P8a |

Evidence cần thấy ở cơ hội đầu tiên: player đọc bàn dispatch là nguồn Manifest đầu run; placement hợp lệ làm beacon callable; sau đó họ tự chọn rút A hoặc đi B/D. Chơi chậm, đi B/D, từ chối B/D hay rút sớm không tự là `FAIL`.

## 3. C3 — ghi recovery tại cùng bàn dispatch

Chỉ sau C0, run fixture hợp lệ dẫn đến **death thật** rồi đi `S11 → S12 → S1 recovery → S2 bàn dispatch A → tự thu hồi → placement hợp lệ → E1`. Không narrator, auto-return Manifest về hub/Archive hay summary giả.

Trước khi S11 hiện, facilitator chỉ được nói **nguyên văn** câu đã có trong protocol:

> “Đây là một state khác của build. Trước khi xem summary, bạn nghĩ điều gì xảy ra tiếp?”

Trước khi player tạo evidence, không gọi tên recovery, `unrecovered`, outcome Manifest, bàn dispatch, icon, action, route hay đáp án.

| Beat/state cần gặp | Player prediction/action đầu tiên | Lời nói đầu tiên | Cue/outcome trên màn | Can thiệp/confounder | Claim hiện có |
|---|---|---|---|---|---|
| Trước S11, sau death thật |  |  |  |  | P6, P8d |
| S11: `Đã giữ` / `Đã mất` / `Vật chứng` |  |  |  |  | P6, P7, P8d |
| S12 → S1 recovery |  |  |  |  | P6, P7 |
| S2: bàn dispatch A, state thu hồi |  |  |  |  | P1, P6, P8a |
| Tự thu hồi + placement → E1 |  |  |  |  | P6, P7, P8a |

Ở S2 recovery, observer chỉ nhìn xem player có tự nhận ra bàn dispatch là nguồn thu hồi và thực hiện placement hợp lệ không. Facilitator không chỉ location, bàn, action hay beacon; không tự đặt/niêm/sắp xếp Manifest cho player.

## 4. Phân loại evidence cho bàn dispatch

| Kết quả | Evidence tối thiểu | Không được suy diễn |
|---|---|---|
| `PASS` cho pickup/route liên quan P1/P8a | Ở C0, player tự hiểu bàn là pickup source đầu run và placement hợp lệ làm A callable; action/lời nói đầu tiên không cần gameplay hint. | Player bắt buộc đi B/D hay rút sớm mới chứng minh hiểu. |
| `PASS` cho P6 | Ở C3, player tự tách được non-evidence niêm **đã giữ**, gear/loot không niêm **đã mất**, Manifest `unrecovered`; tự thu hồi/placement hợp lệ và biết vẫn cần extract A. | Một câu facilitator giải thích thay player, hoặc chỉ biết một phần outcome. |
| `FAIL` | Sau cơ hội state hợp lý, player gán nghĩa sai cụ thể: seal/death/recovery là completion; bàn là checkpoint/respawn; Manifest tự về hub; hoặc E1 là success. Ghi action/lời nói nguyên văn ngắn. | Death, thao tác chậm, rút sớm, không đi B/D hoặc không nhặt cargo tự là fail. |
| `INVESTIGATE` | Control/technical issue, `CAN THIỆP CONTROL`, timing/death hay evidence mâu thuẫn làm không biết nguyên nhân. | Khẳng định player không hiểu hoặc tự sửa wording/state trong phiên. |
| `KHÔNG TEST ĐƯỢC` | State/build hợp lệ không tới được trong phiên; ghi fixture/state cụ thể. | Dùng narration, mock text hoặc lời tưởng tượng để chấm claim. |

Không dùng card này để tạo claim mới hay thay scorecard P1/P6/P7/P8a/P8d. Khi build đang đúng state, một hiểu sai recovery/evidence chỉ là `BLOCKER candidate semantic/readability`: ghi evidence rồi chuyển sang [mẫu tổng hợp](../playtest-synthesis-template.md) §§8–9; không mở repair Task Card từ card hay một phiên. `MUST_FIX` chỉ do synthesis chốt sau evidence hợp lệ. Nếu **outcome thật của build** phá invariant, dùng `BLOCKER build/readiness` theo [build-readiness §9](../vertical-slice-build-readiness.md) thay vì câu này.

## 5. Invariant và non-goals

- Easy / Contract 1; A là extract duy nhất. B/D optional, D không extract; C/E non-interactive. Early extract bằng full-route tại S10.
- Manifest niêm vẫn `đã niêm — chưa extract`; death sau Manifest là `unrecovered`; non-evidence niêm giữ, gear/loot không niêm và đồ tự bỏ mất. Recovery không checkpoint, respawn, restore hay completion.
- Contract 2 chỉ state `chưa có trong vertical slice` sau S10; pickup/recovery không mở nó.
- Không thêm spoken probe, survey, score, item/NPC/route/marker, final UI/copy/localization, asset, combat/AI, economy, implementation hoặc kết quả playtest vào card này.

Mọi finding phải đi theo `state → action → lời nói → outcome → confounder`, rồi mới phân loại. Nếu cần sửa state/readability sau evidence, mở một Task Card với một claim/hypothesis; không thêm lore/popup/reward để che lỗi.
