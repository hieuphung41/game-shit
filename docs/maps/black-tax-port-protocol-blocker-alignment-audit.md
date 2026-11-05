# Audit hai nhánh `BLOCKER` trong protocol — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261031-32. Phạm vi chỉ đối chiếu triage/report của [kế hoạch playtest](../playtest-readability-plan.md) §§5–6 với build-readiness, phiếu một phiên và mẫu tổng hợp. Nó không thay claim, coverage, fixture, lore, map, gameplay canon hay scope vertical slice.

## Nguồn đối chiếu

- [Build-readiness](../vertical-slice-build-readiness.md) §§1, 8–9: outcome trái invariant là `BLOCKER`, không mời tester và mở task state/readiness ngay.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §1: phân biệt `NOT READY`, `KHÔNG TEST ĐƯỢC`, `BLOCKER` và `chưa gặp`.
- [Phiếu quan sát](../playtest-observation-sheet.md) §6: hai nhánh build/readiness và semantic/readability được ghi khác nhau trong một phiên.
- [Mẫu tổng hợp](../playtest-synthesis-template.md) §§1–2, 6–9: evidence source hợp lệ, comparability, confounder, reproduction và handoff repair/diagnostic.

## Kết quả audit

| Kiểm tra | Gap ở protocol | Xử lý | Kết quả |
|---|---|---|---|
| `BLOCKER` build/readiness | Một row `BLOCKER` gộp outcome phá invariant với hiểu sai player, khiến hành động có thể bị đọc là chờ synthesis. | Tách `BLOCKER build/readiness`: dừng phiên, readiness `BLOCKER`, mở ngay một Task Card state/readiness. | `repaired` |
| `BLOCKER` semantic/readability | Một player evidence được gọi thẳng là `BLOCKER` và mở Task Card, thiếu source hợp lệ, comparability, no-confounder và reproduction. | Đổi thành candidate; chỉ synthesis §§8–9 chốt repair readability. | `repaired` |
| `MUST_FIX` | Thiếu ràng buộc hai evidence độc lập, source/coverage hợp lệ và hai nhánh C0 hoặc combat/UI. | Chỉ ghi candidate tại protocol; synthesis chốt với hai C0 first-time hoặc hai coverage combat/UI hợp lệ cùng điều kiện. | `repaired` |
| `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` | Chưa tách hẳn diagnostic/readiness khỏi repair claim; report không liệt kê `KHÔNG TEST ĐƯỢC` trong triage. | Tách hai handoff hẹp, bổ sung label/report và cấm coi chúng là design failure đã xác nhận. | `repaired` |

## Quy tắc chốt

- Build có outcome trái invariant là `BLOCKER` vận hành ngay: dừng phiên, readiness `BLOCKER`, state/action/outcome và Task Card state/readiness. Nó không cần và không chờ evidence player hoặc synthesis.
- Khi build đúng state nhưng player hiểu sai semantic/readability, finding chỉ là candidate. Repair readability cần source/coverage hợp lệ, comparability, không confounder và reproduction theo synthesis.
- `MUST_FIX` không là hai nhãn `FAIL`; nó cần hai evidence độc lập cùng causal misunderstanding hoặc cùng signal combat/UI ở state phù hợp.
- `INVESTIGATE` chỉ chẩn đoán; `KHÔNG TEST ĐƯỢC` chỉ sửa readiness/fixture. C0 tự chọn không gặp nhánh vẫn là `chưa gặp`.

## Bất biến được giữ nguyên

- Easy / Contract 1; A-only extract; B/D optional; D không extract; C/E chỉ silhouette; Contract 2 state-only.
- E0 → placement hợp lệ → E1 callable; E1 chưa success; A call → hold → board mới S10.
- C3 cần death thật; Manifest niêm vẫn `chưa extract`, death là `unrecovered`; sealed non-evidence giữ, gear/loot không niêm mất; P6 chỉ `PASS` với full chain C3.

Audit không thêm level triage, sample-size rule, claim/probe, content, implementation hay task đang chạy. Nếu threshold thay đổi, mở audit mapping hẹp thay vì sửa lore/map/economy để che evidence thiếu.
