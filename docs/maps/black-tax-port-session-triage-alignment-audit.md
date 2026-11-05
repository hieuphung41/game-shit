# Audit đồng bộ triage một phiên ↔ tổng hợp — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261031-30. Phạm vi chỉ đối chiếu triage/handoff của [phiếu quan sát](../playtest-observation-sheet.md) §6 với [mẫu tổng hợp](../playtest-synthesis-template.md) §§8–9. Nó không thay claim, coverage, fixture, lore, map, gameplay canon hay scope vertical slice.

## Nguồn đối chiếu

- [Mẫu tổng hợp](../playtest-synthesis-template.md) §§1–2, 6–9: nhóm comparable, row bị loại, ngưỡng `BLOCKER`/`MUST_FIX` và hai loại handoff.
- [Audit cổng triage](black-tax-port-triage-evidence-gate-audit.md): evidence hợp lệ, reproduction và diagnostic/readiness không là repair.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §§1–4: outcome trái invariant là `BLOCKER`; fixture thiếu là `NOT READY`/`KHÔNG TEST ĐƯỢC` theo thời điểm phát hiện.
- [Build-readiness](../vertical-slice-build-readiness.md) §9: outcome trái invariant mở ngay một Task Card state/readiness; không mời tester tiếp.
- [Kế hoạch playtest](../playtest-readability-plan.md) §5: repair card một claim/beat/hypothesis, không che triệu chứng bằng lore/map/economy.

## Kết quả audit

| Kiểm tra | Gap ở phiếu một phiên | Xử lý | Kết quả |
|---|---|---|---|
| Build/readiness `BLOCKER` | Trước đây trộn outcome phá invariant với player hiểu sai, khiến việc dừng build có thể bị chờ synthesis. | Tách C/E input, D/E extract, recovery soft-lock, mất đồ không báo trước và outcome trái invariant thành `BLOCKER` build/readiness: dừng phiên, readiness `BLOCKER`, mở ngay một Task Card state/readiness theo build-readiness §9. | `repaired` |
| Player semantic/readability `BLOCKER` candidate | Trước đây cùng nhãn `BLOCKER` có thể mở Task Card từ một row, thiếu source hợp lệ, comparability, confounder và reproduction. | Chỉ player hiểu sai khi build đang đúng state mới là candidate chuyển synthesis; synthesis chốt repair readability sau các gate evidence. | `repaired` |
| `MUST_FIX` | Một phiếu có thể bị đọc là đủ cho hai session; thiếu nhánh combat/UI và điều kiện source/state comparable. | Phiếu chỉ ghi row candidate; synthesis xác thực hai evidence độc lập, với nhánh C0 first-time hoặc combat/UI coverage hợp lệ. | `repaired` |
| `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` | Record chung có `Next Task Card`, dễ bị đọc là repair design. | Tách handoff diagnostic/readiness; chỉ khôi phục hoặc kiểm tra evidence/fixture, không xác nhận causal design failure. | `repaired` |
| Owner của handoff | Phiếu chưa chỉ rõ synthesis sở hữu ngưỡng repair và mẫu Task Card. | Candidate record trỏ sang synthesis §§8–9; chỉ repair card đã xác nhận mới dùng mẫu §9. | `repaired` |

## Quy tắc chốt

- Một session ghi evidence trước: state → action/lời nói đầu tiên → outcome → confounder. Nó không tự biến `FAIL` thành `MUST_FIX`.
- State có outcome trái invariant là `BLOCKER` build/readiness: dừng session, trả readiness về `BLOCKER` và mở ngay một Task Card state/readiness theo build-readiness §9. Nó không là player design-claim repair và không chờ synthesis.
- Player hiểu sai semantic/readability trong khi build đúng state chỉ là `BLOCKER candidate`; repair readability vẫn phải qua source/coverage hợp lệ, comparability, no-confounder và reproduction trong synthesis.
- `INVESTIGATE` chỉ mở chẩn đoán; `KHÔNG TEST ĐƯỢC` chỉ mở readiness/fixture. Cả hai không là lỗi design đã xác nhận.
- C0 route-first-time, C3 death thật/recovery, `chưa gặp`, `NOT READY` và `KHÔNG TEST ĐƯỢC` giữ đúng nghĩa ở tài liệu nguồn.

## Bất biến được giữ nguyên

- Easy / Contract 1; A là extract duy nhất; B/D optional; D không extract; C/E chỉ silhouette; Contract 2 state-only.
- E0 → placement hợp lệ → E1 callable; E1 chưa success; A call → hold → board mới tới S10.
- C3 cần death thật; Manifest niêm vẫn `chưa extract`, death là `unrecovered`; sealed non-evidence giữ, gear/loot không niêm mất; P6 chỉ pass với full chain C3.

Audit không thêm level triage, cỡ mẫu, claim/probe, content, implementation hay task đang chạy. Thay đổi threshold sau này cần audit mapping hẹp, không sửa lore/map/economy để che evidence thiếu.
