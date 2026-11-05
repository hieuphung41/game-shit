# Audit triage phiếu quan sát phụ — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261105-36. Phạm vi chỉ đối chiếu cách phân loại finding trong [mini-card dispatch A](black-tax-port-dispatch-observation-card.md) và [checklist visual/readability](black-tax-port-dispatch-visual-readability-checklist.md) với nguồn triage. Nó không thay đổi claim, fixture, state machine, gameplay, map, lore hay canon.

## Nguồn đối chiếu

- [Phiếu quan sát](../playtest-observation-sheet.md) §6: tách `BLOCKER` build/readiness khỏi candidate semantic/readability, và handoff một phiên.
- [Kế hoạch playtest](../playtest-readability-plan.md) §5: evidence gate, comparability, confounder, reproduction và ngưỡng repair.
- [Build-readiness](../vertical-slice-build-readiness.md) §9: `NOT READY` trước phiên, `KHÔNG TEST ĐƯỢC` trong phiên, và `BLOCKER` outcome thật trái invariant.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §1: nghĩa status chung cho coverage C0/C3.

## Kết quả đối chiếu

| Kiểm tra | Wording đã đối chiếu | Kết quả |
|---|---|---|
| Fixture thiếu trước phiên | Mini-card §1 và checklist §6 đều dừng coverage, ghi `NOT READY` và không mời player. | `clear` |
| Fixture/state chỉ lộ trong phiên | Mini-card §1 và checklist §6 đều ghi `KHÔNG TEST ĐƯỢC` rồi trả coverage về `NOT READY`. | `clear` |
| Outcome thật của build phá invariant | Checklist từng gộp auto-return/restore/E1 completion vào finding của player. | `repaired`: outcome thật nay là `BLOCKER` build/readiness, dừng phiên và mở ngay Task Card state/readiness hẹp. |
| Hiểu sai semantic/readability của player | Mini-card từng gọi một hiểu sai là `BLOCKER`; checklist từng mở Task Card ngay từ một player. | `repaired`: trong build đúng state, finding chỉ là `BLOCKER candidate semantic/readability`; đi synthesis trước repair/MUST_FIX. |
| Không mở rộng scope | Các card vẫn cấm bù bằng item/NPC/route/narrator/checkpoint/restore và audit không tạo claim hay state mới. | `clear` |

## Quy tắc giữ cố định

- `NOT READY`: fixture/state thiếu trước phiên; `KHÔNG TEST ĐƯỢC`: điều đó chỉ lộ trong phiên rồi rollback readiness.
- `BLOCKER build/readiness`: outcome thật của build phá invariant; dừng phiên và mở task state/readiness ngay.
- `BLOCKER candidate semantic/readability`: player hiểu sai trong build đúng state; chỉ synthesis được chốt repair/MUST_FIX.
- Easy / Contract 1, A-only extract, E0 → placement hợp lệ → E1, và C3 death/recovery không đổi.

## Ngoài phạm vi

Audit không thêm protocol, probe, threshold mới, UI/final copy, implementation, map, lore, item, NPC, economy, balance, combat, checkpoint, Contract 2/3, difficulty, incident, boss/elite hay multiplayer.
