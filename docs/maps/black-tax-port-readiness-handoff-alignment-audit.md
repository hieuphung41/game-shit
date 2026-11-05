# Audit handoff build/readiness ↔ protocol — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261031-33. Phạm vi chỉ đối chiếu handoff build/readiness ở [build-readiness](../vertical-slice-build-readiness.md) §9 với protocol, phiếu một phiên và mẫu tổng hợp. Nó không thay claim, coverage, fixture, lore, map, gameplay canon hay scope vertical slice.

## Nguồn đối chiếu

- [Build-readiness](../vertical-slice-build-readiness.md) §§1, 7–9: evidence build thật, gate C0–C3 và handoff readiness.
- [Kế hoạch playtest](../playtest-readability-plan.md) §§5–6: hai nhánh `BLOCKER`, diagnostic/readiness và report nhóm phiên.
- [Phiếu quan sát](../playtest-observation-sheet.md) §6: outcome build trái invariant khác player semantic/readability candidate.
- [Mẫu tổng hợp](../playtest-synthesis-template.md) §§8–9: repair readability chỉ sau source hợp lệ, comparability, no-confounder và reproduction.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §1: phân biệt trước phiên `NOT READY`, trong phiên `KHÔNG TEST ĐƯỢC` rồi rollback readiness, và outcome trái invariant.

## Kết quả audit

| Kiểm tra | Gap trước audit | Xử lý ở build-readiness §9 | Kết quả |
|---|---|---|---|
| Outcome build vs player hiểu sai | Ví dụ `seal = completion` đứng chung với outcome build, có thể đọc player statement là readiness `BLOCKER`. | Chỉ outcome **thật của build** như seal tạo completion là `BLOCKER` vận hành; player hiểu sai khi build đúng state đi protocol/synthesis. | `repaired` |
| Fixture thiếu theo thời điểm | Chỉ có `NOT READY`, không ghi phát hiện trong phiên và rollback coverage. | Tách trước phiên `NOT READY` khỏi trong phiên `KHÔNG TEST ĐƯỢC` rồi coverage trở về `NOT READY`. | `repaired` |
| Scope task state/readiness | Handoff cũ nói sửa luật/state/readability, có thể phình sang claim/lore/map/economy. | Khóa một invariant, gate hoặc coverage; acceptance là build state quan sát được, không là hiểu biết first-time. | `repaired` |
| Record và khả năng tái kiểm | Thiếu trigger timing, phân loại, reproduction hoặc điều cần tạo lại. | Mẫu record bắt classification, timing, source rule, state → action → outcome, reproduction `BLOCKER`, điều cần re-observe, scope/out-of-scope. | `repaired` |

## Quy tắc chốt

- Outcome trái invariant là `BLOCKER` build/readiness: dừng phiên, không mời tester tiếp, tái hiện cùng sequence một lần và mở ngay task state/readiness; nó không chờ synthesis.
- Player semantic/readability trong build đúng state là candidate, không phải evidence readiness. Repair claim chỉ theo evidence gate synthesis.
- Fixture thiếu trước phiên là `NOT READY`; nếu chỉ lộ trong phiên, ghi `KHÔNG TEST ĐƯỢC` rồi trả coverage ảnh hưởng về `NOT READY`.
- Mỗi handoff state/readiness chỉ sửa hoặc tạo evidence cho một invariant/gate/coverage; không che vấn đề bằng lore, map, economy hay prompt đọc hiểu.

## Bất biến được giữ nguyên

- Easy / Contract 1; A là extract duy nhất; B/D optional; D không extract; C/E chỉ silhouette; Contract 2 state-only.
- E0 → placement hợp lệ → E1 callable; E1 chưa success; A call → hold → board mới tới S10.
- C3 cần death thật; Manifest niêm vẫn `chưa extract`, death là `unrecovered`; sealed non-evidence giữ, gear/loot không niêm mất; P6 chỉ `PASS` với full chain C3.

Audit không thêm triage level, sample-size rule, claim/probe, content, implementation hay task đang chạy. Nếu scope handoff sau này đổi, mở audit mapping hẹp thay vì sửa lore/map/economy để che evidence thiếu.
