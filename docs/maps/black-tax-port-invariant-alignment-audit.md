# Audit đồng bộ bất biến vertical slice — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261031-34. Phạm vi chỉ đối chiếu bất biến vận hành giữa [wireflow UX](../vertical-slice-wireflow.md), [build-readiness](../vertical-slice-build-readiness.md), [kế hoạch playtest](../playtest-readability-plan.md) và [traceability C0/C3](black-tax-port-state-playtest-traceability.md). Nó không thay đổi story canon, map, item, economy, balance, gameplay, fixture hay threshold evidence.

## Nguồn đối chiếu

- [Wireflow UX](../vertical-slice-wireflow.md) §§2–3, 5–8: state machine A/B/D, Manifest, extract, death và Recovery Contract.
- [Build-readiness](../vertical-slice-build-readiness.md) §§7–9: sequence C0–C3, invariant go/no-go và handoff readiness.
- [Kế hoạch playtest](../playtest-readability-plan.md) §§1, 3–5: bất biến test, coverage/probe, claim và triage.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §4: index bất biến và quy tắc handoff; §1 giữ nghĩa bốn status.
- [Audit hai nhánh `BLOCKER`](black-tax-port-protocol-blocker-alignment-audit.md) và [audit handoff readiness](black-tax-port-readiness-handoff-alignment-audit.md): hai nhánh triage và ranh giới task state/readiness.

## Kết quả đối chiếu

| Bất biến | Wording nguồn đã đối chiếu | Mismatch | Xử lý / kết luận |
|---|---|---|---|
| **Phạm vi slice** | Wireflow §§2–3: Easy / Contract 1, A/B/D; A-only extract; C/E silhouette, D không extract. Readiness §8.1 sweep lại cùng phạm vi. Protocol §1 khóa A/B/D và C/E không tương tác. Traceability §4 ghi early/full-route cùng S10, Contract 2 state-only. | Không có. | `clear`: B/D là optional; C/E không có input; Contract 2 không playable. |
| **Beacon và boundary success** | Wireflow §5 chỉ chuyển E0 sang E1 sau placement hợp lệ; §7 định nghĩa E1 callable, O5 → S7 → S8 → S9 → S10; §8 giữ chuỗi này sau recovery. Readiness G4, G13–G14, G18 và C3 §7 đòi cùng transition. Protocol C1/C3 §3.3 nêu placement → E1 rồi call/hold/board. Traceability §4 chốt E1 không là success. | Không có. | `clear`: E0 → placement hợp lệ → E1 callable; E1 không là completion; chỉ call → hold → board tới S10. |
| **Death, recovery và C3** | Wireflow §6/§8: Manifest niêm vẫn `chưa extract`; death sau Manifest là `unrecovered`; sealed non-evidence giữ, unsealed gear/loot mất. Readiness G17–G18 và C3 §7 buộc fixture đủ ba nhóm cùng death thật. Traceability §4 chốt P6 chỉ pass với full chain C3. | Protocol C3 §3.3 trước đây chỉ nêu Manifest niêm và sealed non-evidence, nên summary không buộc có gear/loot không niêm để chứng minh `Đã mất`; probe/P6 cũng không ghi rõ group mất. | `repaired`: C3, probe Safebox/evidence/death và P6 nay bắt fixture có ít nhất một gear/loot không niêm, summary ghi `Đã mất`, đồng thời giữ death thật, `unrecovered` và recovery không restore/tự complete. |
| **Nghĩa status và handoff** | Wireflow chỉ là state source, không đặt status test. Readiness §9: fixture thiếu trước phiên = `NOT READY`; phát hiện trong phiên = `KHÔNG TEST ĐƯỢC` rồi coverage về `NOT READY`; outcome thật trái invariant = `BLOCKER`. Protocol §5 giữ nhánh build/readiness khác candidate semantic/readability. Traceability §1 quy định C0 tự chọn không đi một nhánh = `chưa gặp`. | Protocol C2 §3.3 từng gán `KHÔNG TEST ĐƯỢC` cho việc player không tự đi full-route, dù build/fixture có thể đúng; điều này lẫn với `chưa gặp`. | `repaired`: C2 nay ghi `chưa gặp — C2 route choice` khi player chọn route khác/dừng; chỉ dùng `KHÔNG TEST ĐƯỢC` khi build không tạo được C2 đúng luật. `BLOCKER` vẫn chỉ là outcome thật phá invariant. |
| **Không mở rộng canon** | Wireflow §1 loại trừ map/contract/difficulty/economy/content ngoài slice. Readiness §2 và §9 cấm dùng content mới để lấp fixture; task state/readiness khóa một invariant/gate/coverage. Protocol §§1, 5 cấm đổi map/lore/economy để che evidence. Traceability §4 loại trừ map/story/economy và thay đổi canon. | Không có. | `clear`: audit và patch chỉ phân loại evidence; không tạo content, rule gameplay hay scope mới. |

## Quy tắc được giữ cố định

- Easy / Contract 1; chỉ A extract; B/D optional, D không extract; C/E chỉ silhouette.
- E0 chỉ thành E1 sau placement hợp lệ. E1 là callable; A call → hold → board mới là S10 success.
- C3 cần death thật. Fixture có Manifest niêm, một non-evidence niêm và ít nhất một gear/loot không niêm; summary phải cho thấy nhóm `Đã giữ`/`Đã mất`/`unrecovered`. Manifest niêm vẫn `chưa extract`, sau death là `unrecovered`; P6 cần full chain C3.
- `NOT READY` là fixture/state thiếu hoặc sai được phát hiện trước phiên; `KHÔNG TEST ĐƯỢC` là điều đó chỉ được phát hiện trong phiên, rồi coverage trở về `NOT READY`; `BLOCKER` là outcome thật phá invariant; `chưa gặp` là nhánh tự chọn không xảy ra.

## Ngoài phạm vi

Audit không thêm claim/probe, sample size, triage level, implementation, mockup, asset, map, lore, item, NPC, economy, balance, difficulty, incident, boss/elite hay contract playable mới. Nếu một nguồn sau này đổi state hoặc threshold, mở một audit mapping hẹp thay vì dùng audit này để sửa canon.
