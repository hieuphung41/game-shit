# Audit nguồn evidence scorecard — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261029-28. Phạm vi là nguồn evidence hợp lệ khi tổng hợp scorecard P1–P8; không thiết kế claim/coverage mới, sample size hoặc triage threshold.

## Nguồn đối chiếu

- [Kế hoạch playtest](../playtest-readability-plan.md) §§3.3–4: C0 tự nhiên, C1–C3 coverage có kiểm soát và claim theo state.
- [Phiếu quan sát](../playtest-observation-sheet.md) §§3–5: row evidence thực tế, C3 full chain và P6 `PASS`.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §§2–3: state nào được phép dùng cho claim nào.
- [Audit mapping C0/C3](black-tax-port-observation-claim-coverage-audit.md): P1/P2 route-first-time chỉ C0; P6 không pass từ state riêng lẻ.

## Ma trận nguồn evidence hợp lệ

| Claim | `primary` | `supplementary` / `support only` | `not valid for that interpretation` |
|---|---|---|---|
| P1 — Objective/route first-time | C0 first-time | — | C1/C2/C3 controlled; C2 chỉ hợp lệ nếu thực tế là một C0 tự nhiên riêng. |
| P2 — Rút sớm là thắng, route-choice | C0 first-time | C1 chỉ bổ sung semantics rút sớm. | C2/C3 controlled không chốt route-choice. |
| P3 — Combat công bằng | C0/C1/C2 khi gặp đúng combat state | — | C3. |
| P4 — Loot-grid là quyết định | C0/C2 khi gặp card/grid/cargo | — | C1/C3. |
| P5 — Claim khác rarity | C0/C2/presentation khi gặp card claim-rarity | — | C1/C3. |
| P6 — Hộp/evidence/death/recovery | C3 **full chain**: death thật → S11 groups → S12/S1 → tự thu hồi/placement → E1 → A call/hold/board | C0/C2 chỉ support placement, seal, Hộp/evidence. | C1; bất cứ row/state đơn lẻ nào. |
| P7 — Extract/summary | C0/C1/C2/C3 khi gặp extract/summary/recovery state tương ứng | — | Presentation probe đơn lẻ. |
| P8a — Landmark/objective/extract A | C0/C1/C2/C3/presentation khi gặp landmark A tương ứng | Controlled coverage chỉ là state/presentation evidence, không là route-first-time. | — |
| P8b — Claim khác rarity trên card | C0/C2/presentation khi gặp item card | — | C1/C3. |
| P8c — Hazard/telegraph | C0/C1/C2/presentation khi gặp hazard | — | C3. |
| P8d — Hộp/evidence/death state | C0/C2/C3/presentation khi gặp Hộp/evidence/death state | — | C1. |
| P8 tổng | Roll-up của P8a–P8d | `PASS` chỉ khi bốn sub-state `PASS`. | Một coverage, một cue hoặc một sub-state riêng lẻ. |

## Kết quả audit synthesis template

| Vị trí | Phân loại | Xử lý |
|---|---|---|
| §3, C0 `P1–P8 khi state tự xuất hiện` | `repaired` | Chuyển P6 thành `support only`; P8 theo từng sub-state và P8 tổng không lấy từ C0 row. |
| §3/§5, C2 `P3–P8` | `repaired` | Tách P3/P4/P5/P7, P8 theo state và P6 `support only`. |
| §3/§5, C3 `P6/P7/P8d` | `repaired` | Ghi P6 full chain, P7, P8a recovery và P8d death/evidence. |
| §7, P6 `C0/C3` | `repaired` | Chỉ C3 full chain có thể chốt P6 `PASS`; C0/C2 chỉ support. |
| §7, P8a–P8d/P8 tổng | `repaired` | Mỗi sub-state có coverage/state riêng; P8 tổng là roll-up-only. |
| P1/P2 C0 route-choice limit | `aligned` | Giữ C0 first-time là source duy nhất; C1 chỉ semantics P2. |

## Bất biến khi tổng hợp

- C0 trước controlled coverage. Một voluntary branch C0 không gặp là `chưa gặp`, không phải `FAIL`, `NOT READY` hay `KHÔNG TEST ĐƯỢC`.
- C3 dùng death thật; preflight thiếu fixture là `NOT READY`, phát hiện trong phiên là `KHÔNG TEST ĐƯỢC` và rollback readiness; outcome trái invariant là `BLOCKER`.
- E0 → placement hợp lệ → E1 callable; E1 không success. A call/hold/board mới S10.
- Easy / Contract 1; A-only extract; B/D optional, D không extract; C/E silhouette; early extract bằng full-route; Contract 2 state-only. Manifest niêm vẫn `đã niêm — chưa extract`; recovery giữ/mất theo source.

Audit không thêm claim, score, probe, content hay threshold. Nếu một scorecard sau này dùng source bị ghi `not valid for that interpretation`, mở một Task Card mapping hẹp; không đổi route, lore hay UI để che lỗi tổng hợp.
