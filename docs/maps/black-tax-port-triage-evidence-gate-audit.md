# Audit cổng bằng chứng triage — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261031-29. Phạm vi chỉ kiểm tra cổng `BLOCKER`/`MUST_FIX` và handoff ở [mẫu tổng hợp playtest](../playtest-synthesis-template.md) §§8–9. Nó không thay đổi claim, coverage, gameplay canon, fixture, lore, map hay scope của vertical slice.

## Nguồn đối chiếu

- [Mẫu tổng hợp](../playtest-synthesis-template.md) §§1–2, 6–7: comparability, evidence bị loại và source/coverage hợp lệ của từng claim.
- [Audit nguồn evidence scorecard](black-tax-port-scorecard-evidence-source-audit.md): C0-only cho P1/P2 route-choice, C3 full chain cho P6 và P8 theo sub-state.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §§1–4: `NOT READY`/`KHÔNG TEST ĐƯỢC`/`BLOCKER`, state thực tế và bất biến recovery.
- [Build-readiness](../vertical-slice-build-readiness.md) §§1, 7–9: fixture thiếu khác outcome phá invariant; readiness handoff không là evidence readability.
- [Kế hoạch playtest](../playtest-readability-plan.md) §§4–5: evidence first opportunity, triage threshold và repair card một claim/beat/hypothesis.

## Audit cổng triage

| Kiểm tra | Gap trước audit | Xử lý ở mẫu tổng hợp | Kết quả |
|---|---|---|---|
| `BLOCKER` có evidence hợp lệ | Đã có mã phiên/build và tái hiện, nhưng chưa bắt buộc source/coverage hợp lệ theo claim, comparability hay confounder sạch. | §8 buộc source §7, cùng build/control/fixture, không confounder và record state → action/lời nói đầu tiên → outcome; tái hiện state → action → outcome một lần cùng build. | `repaired` |
| `MUST_FIX` có hai tín hiệu độc lập | Đã nêu hai C0 hoặc hai coverage, nhưng chưa dẫn rõ nguồn §7 và baseline comparability cho cả hai nhánh. | §8 buộc hai evidence độc lập cùng build/control/fixture/state, source §7 và không confounder; tách điều kiện C0 first-time với combat/UI coverage. | `repaired` |
| `INVESTIGATE` / `KHÔNG TEST ĐƯỢC` không giả làm lỗi design | §8 nói được sửa fixture/bug, còn §9 gom bốn classification vào một Task Card nên có thể bị đọc thành repair đã được chứng minh. | §8 và §9 tách repair Task Card khỏi handoff chẩn đoán/readiness/fixture; hai nhãn này không chứng minh design failure và không mở repair cho claim. | `repaired` |
| Handoff đủ để kiểm tra lại | Mẫu cũ thiếu evidence source, comparability/confounder và reproduction; classification gộp confirmed với diagnostic. | §9 có hai mẫu riêng; repair card buộc source, comparability/confounder, exact state và reproduction `BLOCKER`; diagnostic chỉ ghi điều cần làm rõ/tạo fixture. | `repaired` |

## Quy tắc chốt sau audit

- Row bị loại ở [§6 của mẫu tổng hợp](../playtest-synthesis-template.md) không góp vào ngưỡng `BLOCKER`/`MUST_FIX`, dù có cùng nhãn `FAIL`.
- `BLOCKER` là outcome thật phá invariant hoặc semantic/fairness critical ở evidence hợp lệ; một player statement không có state/action/outcome hợp lệ, hoặc chưa tái hiện cùng sequence, vẫn là `INVESTIGATE`.
- `MUST_FIX` không là hai lần thấy bất kỳ `FAIL` nào. Hai evidence phải chỉ cùng causal misunderstanding hoặc cùng signal combat/UI ở đúng claim/beat/state, và không bù source không hợp lệ bằng coverage controlled.
- `INVESTIGATE` có thể dẫn đến một task chẩn đoán; `KHÔNG TEST ĐƯỢC` có thể dẫn đến task readiness/fixture. Cả hai task chỉ khôi phục/kiểm tra evidence và không tuyên bố repair design claim.
- C0 voluntary branch `chưa gặp` vẫn không là `FAIL`, `KHÔNG TEST ĐƯỢC` hay `BLOCKER`. Fixture thiếu trước phiên là `NOT READY`; phát hiện trong phiên là `KHÔNG TEST ĐƯỢC` rồi trả readiness coverage về `NOT READY`.

## Bất biến được giữ nguyên

- Easy / Contract 1; A là extract duy nhất; B/D optional; D không extract; C/E chỉ silhouette; Contract 2 state-only.
- E0 chỉ thành E1 sau placement hợp lệ; E1 callable nhưng chưa success; A call → hold → board mới đi tới S10.
- C3 cần death thật; Manifest niêm vẫn `chưa extract` và sau death là `unrecovered`; sealed non-evidence giữ, gear/loot không niêm mất; P6 chỉ pass với C3 full chain.

Audit không thêm triage level, sample-size rule, claim/probe, content, implementation hay task đang chạy. Nếu nguồn evidence hoặc threshold thay đổi sau này, mở audit mapping hẹp thay vì sửa lore/map/economy để che evidence thiếu.
