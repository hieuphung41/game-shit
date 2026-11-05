# Audit claim ↔ coverage — Phiếu quan sát C0/C3

**Trạng thái:** audit `proposed` cho TASK-20261029-27. Phạm vi chỉ là các reference claim ở row C0/C3 của [phiếu quan sát](../playtest-observation-sheet.md). Nó không audit C1/C2, không thiết kế claim mới và không thay protocol, readiness hay wireflow.

## Nguồn đối chiếu

- [Kế hoạch playtest](../playtest-readability-plan.md) §§3.3–4: C0 là run tự nhiên; C3 là recovery sau C0 và death thật.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §§2–3: mapping state/evidence được phép và distinction `chưa gặp` / `NOT READY` / `KHÔNG TEST ĐƯỢC` / `BLOCKER`.
- [Mẫu tổng hợp](../playtest-synthesis-template.md) §§1, 5, 7: P1/P2 route first-time chỉ lấy từ C0; C3 bổ sung P6/P7/P8d.
- [C3 fixture brief](black-tax-port-recovery-c3-fixture-brief.md) §§2–5: chain P6 phải có death thật, ba nhóm S11, self-recovery/placement và extract A còn bắt buộc.

## C0 — row mapping đã audit

| Row phiếu quan sát | Claim reference | Phân loại | Giới hạn/evidence |
|---|---|---|---|
| S1 briefing/O1 | P1 | `aligned` | Objective/route bắt đầu tại briefing; C0 là evidence route first-time. |
| S2 A: dispatch/beacon/B route | P1, P8a | `aligned` | Đúng initial source, landmark A và extract cue. |
| O2 Manifest → S3 | P1, P2, P6 | `qualified` | P6 chỉ là support cho placement/seal; không thể `PASS` nếu thiếu chain C3. |
| S4 B | P3, P8c | `aligned` | Đúng state combat telegraph/hazard. |
| O2/O3 loot | P4, P5, P8b | `aligned` | Đúng state card/grid, claim và rarity. |
| S5 D/O4 | P4, P6, P8d | `qualified` | P6/P8d chỉ record state Hộp/evidence; không tự chứng minh recovery. |
| A E1/S7/S8/S9, nếu player extract | P2, P3, P7, P8a/P8c | `aligned` | Chỉ ghi khi player tự chọn A; nhánh không gặp là `chưa gặp`, không là failure/readiness failure. |
| S10 hoặc S11 outcome | P6/P7/P8d | `qualified` | Chỉ record claim tương ứng outcome đang hiện. S10 không tự chứng minh recovery; S11 chỉ là một phần P6. |

## C3 — row mapping đã audit

| Row phiếu quan sát | Claim reference | Phân loại | Giới hạn/evidence |
|---|---|---|---|
| Trước S11, sau death thật | P6, P8d | `qualified` | Fixture/death thật là entry evidence, chưa tự đủ P6 `PASS`. |
| S11: `Đã giữ` / `Đã mất` / `Vật chứng — unrecovered` | P6, P7, P8d | `aligned` | Đúng ba nhóm recovery và summary boundary. |
| S12 chọn Recovery Contract | P6, P7 | `aligned` | Đúng recovery availability, chưa completion. |
| S1 recovery briefing/loadout | P6 | `aligned` | Đúng starter recovery/no-restore state. |
| S2 A self-recovery → placement → E1 | P6, P8a | `repaired` | Đã bỏ P1: recognition recovery không là evidence P1/P2 route first-time. E1 vẫn callable, không success. |
| E1/O5 → S7/S8/S9 → S10 sau recovery | P6, P7 | `repaired` | Row mới ghi evidence bắt buộc rằng A call/hold/board vẫn cần để hoàn thành P6. |

## Rule chốt khi ghi scorecard

- Chỉ C0 first-time dùng cho P1/P2 **route-choice**. C3 có thể ghi recognition recovery như evidence state, nhưng không được điền nó thành P1/P2 trong scorecard.
- P6 chỉ `PASS` khi một C3 hợp lệ nối đủ: death thật → S11 tách non-evidence niêm giữ / gear-loot không niêm mất / Manifest `unrecovered` → S12/S1 → tự thu hồi và placement hợp lệ → E1 callable → A call/hold/board thành công.
- C0 tự chọn không đi một nhánh là `chưa gặp`. Fixture thiếu trước phiên là `NOT READY`; lộ khi chạy là `KHÔNG TEST ĐƯỢC` và trả readiness về `NOT READY`; outcome trái invariant là `BLOCKER`.
- Không thêm route hint, facilitator hint, probe, claim, checkpoint, auto-recovery hay content để lấp evidence thiếu.

## Invariant và handoff

- Easy / Contract 1; A-only extract; B/D optional, D không extract; C/E silhouette; early extract bằng full-route tại S10; Contract 2 state-only.
- E0 chỉ đổi E1 sau placement hợp lệ; E1 không success. Manifest niêm vẫn `đã niêm — chưa extract`; death sau Manifest là `unrecovered`; sealed non-evidence giữ và gear/loot không niêm mất.
- Nếu scorecard sau này lại có reference P1/P2 từ C3 hoặc P6 `PASS` từ một row riêng lẻ, mở một Task Card audit hẹp cho mapping đó; không sửa protocol hay lore để che lỗi record.
