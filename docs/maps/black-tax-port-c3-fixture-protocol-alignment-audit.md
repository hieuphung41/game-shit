# Audit fixture C3 ↔ protocol — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261031-35. Phạm vi chỉ đối chiếu fixture C3 với protocol/readiness hiện hành để xác nhận coverage death → Recovery tạo được evidence đúng luật. Audit không đổi state machine, wording nguồn, claim, fixture, gameplay hay canon.

## Nguồn đối chiếu

- [C3 fixture brief](black-tax-port-recovery-c3-fixture-brief.md) §§1–6: entry fixture, S11, recovery và P6.
- [Kế hoạch playtest](../playtest-readability-plan.md) §§1, 3–5: invariant test, C3, probe và claim P6.
- [Build-readiness](../vertical-slice-build-readiness.md) G16–G18, C3 §7 và §9: evidence build, sequence và trạng thái readiness.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §§1, 3–4: boundary C0/C3, state cần thấy và status handoff.
- [Phiếu quan sát](../playtest-observation-sheet.md) C3, scorecard P6 và §6: fixture ghi nhận, chain evidence và triage một phiên.

## Kết quả đối chiếu

| Kiểm tra | Bằng chứng khớp | Kết quả |
|---|---|---|
| **Boundary C0 → C3** | Fixture §1 chỉ cho C3 chạy sau C0; traceability §3 và phiếu quan sát C3 giữ C3 là coverage có kiểm soát, không là death lesson hay route-first-time. | `clear` |
| **Entry ba nhóm** | Fixture §2 yêu cầu Manifest niêm trong Hộp với `đã niêm — chưa extract`, một non-evidence niêm và ít nhất một gear/loot không niêm. Protocol C3, G17 và route C3 readiness dùng cùng ba nhóm. | `clear` |
| **Death thật** | Fixture §2 chỉ chấp nhận death in-run thật theo chain S11 → S12 → S1 → S2; protocol/traceability cấm summary giả hoặc narrator thay outcome. | `clear` |
| **S11 ba nhóm** | Fixture §3 yêu cầu `Đã giữ` = non-evidence niêm, `Đã mất` = gear/loot không niêm, `Vật chứng` = Manifest `unrecovered`; protocol C3/probe, G17 và traceability S11 giữ cùng mapping. | `clear` |
| **Recovery và Beacon A** | Fixture §4 giữ S12/S1 không restore/auto-complete; tại bàn dispatch A, player tự thu hồi rồi placement hợp lệ mới E0 → E1. G18 và traceability recovery chép cùng boundary. | `clear` |
| **Success boundary** | Fixture §4–5, protocol C3 và traceability đều giữ A call → hold → board sau recovery; E1 không là success và S10 mới complete. | `clear` |
| **P6 full chain** | Fixture §5, protocol P6 và phiếu C3 đều đòi player phân biệt giữ/mất/`unrecovered`, tự thu hồi/placement và vẫn extract A; một state đơn lẻ không tự tạo P6 `PASS`. | `clear` |
| **Readiness / session status** | Fixture §2/§5 và readiness §9: thiếu trước phiên là `NOT READY`; chỉ lộ trong phiên là `KHÔNG TEST ĐƯỢC` rồi coverage C3 về `NOT READY`. Outcome thật trái invariant vẫn là `BLOCKER`, không là fixture thiếu. | `clear` |

## Kết luận

Không cần source repair: fixture C3 đã phản chiếu protocol mới, gồm gear/loot không niêm và nhóm `Đã mất`. Audit không tạo fixture item mới, không thay rule niêm phong/death/recovery, và không thay ngưỡng evidence P6.

## Ngoài phạm vi

Không thêm hoặc sửa map, lore, item, NPC, economy, balance, combat, hazard, checkpoint, control, UI/final copy, asset, implementation, Contract 2/3, difficulty, incident, boss/elite hay multiplayer.
