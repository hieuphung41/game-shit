# Traceability state → playtest — Cảng Hắc Thuế, C0/C3

**Trạng thái:** index evidence `proposed` cho TASK-20261029-26. Đây là bản đồ tra cứu giữa state build và evidence quan sát; không thay state machine, build-readiness, protocol facilitator, phiếu ghi, UI copy hay implementation plan.

## 1. Cách dùng và nguồn quyết định

Ma trận chỉ giúp một người kiểm tra trả lời: *state nào phải thấy được, observer được ghi gì, và coverage nào được phép kết luận gì?* Nó không tạo state, claim, probe hay route mới.

| Lĩnh vực | Nguồn quyết định | Vai trò của index này |
|---|---|---|
| State, transition và boundary success | [wireflow UX](../vertical-slice-wireflow.md) §§2, 5, 7–8 | Chép lại chuỗi cần đối chiếu, không đổi transition. |
| State phải tạo được và kết quả readiness | [build-readiness](../vertical-slice-build-readiness.md) G3–G5, G13–G18, §§7–9 | Chỉ rõ evidence build cần có; không tự đánh `READY`. |
| Coverage, claim và cách quan sát | [kế hoạch playtest](../playtest-readability-plan.md) §§3–4; [phiếu quan sát](../playtest-observation-sheet.md) §§3–5 | Giới hạn claim được dùng và evidence observer ghi. |
| Nghĩa initial/recovery tại bàn dispatch | [state contract](black-tax-port-dispatch-state-contract.md) §§2–5; [C3 fixture brief](black-tax-port-recovery-c3-fixture-brief.md) §§2–5 | Giữ source, placement và recovery không bị đọc thành checkpoint. |
| Guardrail E0/E1 đã audit | [beacon presentation audit](black-tax-port-beacon-presentation-audit.md) | Nhắc E0 → valid placement → E1; không tự diễn giải lại audit. |

Các nguồn trên phân vai, không có một precedence tuyến tính mới do index này tạo ra. Nếu chúng mâu thuẫn, **dừng coverage và mở handoff hẹp theo nguồn gốc**, không tự hòa giải trong ma trận.

### Quy tắc status chung

| Điều phát hiện | Kết quả bắt buộc |
|---|---|
| Trước phiên không tạo được state/fixture mà coverage cần | `NOT READY`; không mời first-time player vào coverage đó. |
| Trong phiên mới phát hiện state/fixture không có hoặc không tới được đúng flow | `KHÔNG TEST ĐƯỢC`; ghi row/state thiếu rồi trả readiness của coverage bị ảnh hưởng về `NOT READY`. Không dùng lời kể, mock text hay state giả thay thế. |
| State có nhưng outcome trái invariant | `BLOCKER`, không gọi là state thiếu. Ghi state → action → outcome và mở Task Card hẹp. |
| C0 không gặp một nhánh chỉ vì player tự chọn route khác hoặc dừng | `chưa gặp`; không là `FAIL`, `NOT READY` hay `KHÔNG TEST ĐƯỢC`. |

## 2. C0 — run tự nhiên, initial pickup

**Ranh giới:** C0 chạy trước mọi coverage có kiểm soát. Player tự chọn rút A, đi B/D, chết hoặc dừng; bảng không yêu cầu họ đi tới S10. Không route hint, không giải thích recovery. Một row extract chỉ ghi khi player tự đi theo nhánh A.

| State / transition | Điều build phải quan sát được | Observer chỉ ghi evidence trung tính | Claim/coverage được dùng | Nếu state cần cho row không có | Source anchor |
|---|---|---|---|---|---|
| **S2 initial:** bàn dispatch + Manifest source + E0 + lối B | Một góc đọc được bàn dispatch, beacon A `unavailable`, Manifest chưa thuộc inventory/hub và lối B; C/E không có input. | Action đầu tiên, lời nói đầu tiên, cue player dùng và outcome trên màn. | C0: P1, P8a. | Dùng quy tắc status chung; không thêm marker/route để bù. | [Wireflow §5](../vertical-slice-wireflow.md), [G3](../vertical-slice-build-readiness.md), [C0 log](../playtest-observation-sheet.md). |
| **O2 → placement thủ công hợp lệ** | `Nhặt và xếp` chỉ commit Manifest vào ba lô/Hộp hợp lệ; inspect, fail hoặc hủy giữ Manifest ở source. | Player mở/đóng card, chọn placement hay hủy; không ghi inspect là đã nhặt. | C0: P1; hỗ trợ P6 nhưng **chưa đủ** để P6 `PASS`. | `NOT READY` / `KHÔNG TEST ĐƯỢC` theo status chung; không auto-place/auto-seal. | [Wireflow §5](../vertical-slice-wireflow.md), [G4](../vertical-slice-build-readiness.md), [state contract §3](black-tax-port-dispatch-state-contract.md). |
| **S3 / E1:** Manifest đang mang | Chỉ placement hợp lệ mới chuyển E0 → E1 `callable`. Nếu player chọn niêm, label vẫn `đã niêm — chưa extract`; B/D vẫn là tùy chọn. | Player nói/làm gì khi thấy A callable và lựa chọn A hoặc B/D. | C0: P1, P2, P8a. C0 mới là evidence route first-time. | Không xem beacon bật sau inspect, O2, niêm hoặc mere possession là state hợp lệ. | [Wireflow §5](../vertical-slice-wireflow.md), [G4–G5](../vertical-slice-build-readiness.md), [beacon audit](black-tax-port-beacon-presentation-audit.md). |
| **E1 / O5 → S7** *(chỉ khi player tự chọn A)* | A là extract duy nhất; `Gọi thuyền` có preview/xác nhận, hủy giữ E1, xác nhận mới vào S7. | Lựa chọn call/cancel và lời nói về ý nghĩa rút sớm; không gọi A là “đường đúng”. | C0: P2, P7. | Nếu player không chọn A: `chưa gặp`. Nếu chọn A mà state không tới: dùng status chung. | [Wireflow §§6–7](../vertical-slice-wireflow.md), [G13](../vertical-slice-build-readiness.md), [C0/C1 protocol](../playtest-readability-plan.md). |
| **S8 → S9 → S10** *(chỉ khi player tự chọn extract)* | Hold có lane báo trước, boat ready cần player board, rồi summary S10. Rút sớm và full-route cùng boundary S10; Contract 2 chỉ state chưa playable. | Hành động/lời nói đầu tiên về lane, board và summary; tách control/technical confounder. | C0: P3, P7; P2 được củng cố bởi success thực tế. | Không gặp do route tự chọn: `chưa gặp`. Thiếu flow sau khi đã chọn extract: dùng status chung. | [Wireflow §§7–8](../vertical-slice-wireflow.md), [G14–G15](../vertical-slice-build-readiness.md), [C0 log](../playtest-observation-sheet.md). |

## 3. C3 — death thật → Recovery Contract

**Ranh giới:** C3 chỉ chạy **sau C0 đã kết thúc**. Đây là coverage có kiểm soát cho recovery, không được dùng để kết luận lựa chọn route first-time P1/P2, không được biến death thành lesson hay dùng summary giả.

| State / transition | Điều build phải quan sát được | Observer chỉ ghi evidence trung tính | Claim/coverage được dùng | Nếu state cần cho row không có | Source anchor |
|---|---|---|---|---|---|
| **Entry fixture → death thật** | Manifest đã niêm trong Hộp với `đã niêm — chưa extract`; có một non-evidence niêm và ít nhất một gear/loot không niêm; sau đó là death in-run thật. | State fixture, prediction/action đầu tiên trước S11, lời nói đầu tiên và confounder. | C3 eligibility; chưa tự kết luận `PASS`. | Thiếu một phần fixture hoặc không đi được death thật theo flow: `NOT READY` trước phiên; phát hiện trong phiên: `KHÔNG TEST ĐƯỢC` rồi rollback readiness. | [C3 fixture §2](black-tax-port-recovery-c3-fixture-brief.md), [G17/C3](../vertical-slice-build-readiness.md), [C3 protocol](../playtest-readability-plan.md). |
| **S11 death summary** | `Đã giữ`: non-evidence niêm; `Đã mất`: gear/loot không niêm; `Vật chứng`: Manifest `unrecovered`; action tiếp theo dẫn S12. Không completion/Archive/restore. | Player dự đoán, action/lời nói đầu tiên và outcome bốn nhóm; không diễn giải nhóm item thay player. | C3: P6, P7, P8d. | Không thay bằng narrator/summary giả; dùng status chung. Outcome trái rule là `BLOCKER`. | [Wireflow §8](../vertical-slice-wireflow.md), [C3 fixture §3](black-tax-port-recovery-c3-fixture-brief.md), [G17](../vertical-slice-build-readiness.md). |
| **S12 → S1 recovery** | Recovery Contract chưa complete; starter/recovery loadout hợp lệ không mua/restore đồ đã mất. | Action/lời nói đầu tiên khi chọn recovery và khi thấy loadout; control help tách thành `INVESTIGATE`. | C3: P6, P7. | Dùng status chung; không thêm checkpoint, gear restore hay auto-recovery. | [Wireflow §8](../vertical-slice-wireflow.md), [C3 fixture §4](black-tax-port-recovery-c3-fixture-brief.md), [G18](../vertical-slice-build-readiness.md). |
| **S2 recovery / E0:** tự thu hồi ở bàn dispatch | Cùng bàn dispatch A, Manifest vẫn `unrecovered`, beacon E0; player tự nhận ra source/thu hồi. Không spawn thứ hai, checkpoint hay auto-return. | State → action đầu tiên → lời nói đầu tiên → outcome; không chỉ location, bàn hay action. | C3: P6, P8a; P1 chỉ có thể ghi recognition state, **không** là evidence route first-time. | Dùng status chung; không thêm NPC, túi, marker hoặc route để che finding. | [State contract §§2–5](black-tax-port-dispatch-state-contract.md), [C3 mini-card](black-tax-port-dispatch-observation-card.md), [G18](../vertical-slice-build-readiness.md). |
| **Recovery placement hợp lệ → E1** | Player tự đặt Manifest vào ba lô/Hộp hợp lệ; fail/hủy giữ source; seal vẫn `đã niêm — chưa extract`; chỉ sau đó E0 → E1 callable. | Placement/label và lời nói đầu tiên; E1 không được ghi là completion. | C3: P6, P8a. | Dùng status chung; beacon trước placement hoặc completion tại E1 là `BLOCKER`. | [Wireflow §8](../vertical-slice-wireflow.md), [C3 fixture §4](black-tax-port-recovery-c3-fixture-brief.md), [beacon audit](black-tax-port-beacon-presentation-audit.md). |
| **E1 / O5 → S7 → S8 → S9 → S10** | A-only call/hold/board còn bắt buộc sau recovery; board mới success, death trước board không checkpoint. | Action/lời nói đầu tiên ở call/hold/board và summary; không dạy đường A. | C3: P6, P7; chứng minh extract vẫn cần. | Dùng status chung; không auto-board/auto-extract hay mở D/E extract. | [Wireflow §§7–8](../vertical-slice-wireflow.md), [G13–G15](../vertical-slice-build-readiness.md), [C3 protocol](../playtest-readability-plan.md). |

## 4. Bất biến của index và handoff

- Easy / Contract 1; A là extract duy nhất; B/D optional, D không extract; C/E chỉ silhouette. Early extract bằng full-route ở S10; Contract 2 chỉ state chưa playable sau S10.
- E0 chỉ thành E1 sau placement hợp lệ. E1 là callable, không phải success. Call → hold → board là các state khác nhau.
- Seal là tùy chọn trong C0, nhưng fixture C3 yêu cầu Manifest đã niêm. Trong mọi state, Manifest niêm vẫn `đã niêm — chưa extract`; death sau Manifest là `unrecovered`; non-evidence niêm giữ, gear/loot không niêm và đồ tự bỏ mất.
- Index không thêm claim, probe, player action, item/NPC/route/contract, UI/asset/final copy, implementation, checkpoint/respawn, combat/hazard/economy, Hard/Extreme, incident/boss/elite hay thay đổi canon.

**Handoff hẹp:** Một finding chỉ mở Task Card mới khi có state → action/lời nói → outcome cụ thể, classification đúng theo nguồn và discipline owner phù hợp. Không sửa map/story/economy để che một fixture, state hoặc readability failure.
