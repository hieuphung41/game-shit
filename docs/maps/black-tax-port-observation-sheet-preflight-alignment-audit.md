# Audit preflight phiếu quan sát chính — Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261105-37. Phạm vi chỉ đối chiếu preflight của [phiếu quan sát](../playtest-observation-sheet.md) với readiness/protocol và làm rõ trạng thái trước hoặc trong phiên. Nó không đổi coverage, claim, triage threshold, state machine, gameplay hay canon.

## Nguồn đối chiếu

- [Build-readiness](../vertical-slice-build-readiness.md) §§1, 7–9: nghĩa `READY`/`NOT READY`/`BLOCKER`, no-go và sequence C0–C3.
- [Kế hoạch playtest](../playtest-readability-plan.md) §§3, 5: fixture thực, coverage và nhánh triage.
- [Traceability C0/C3](black-tax-port-state-playtest-traceability.md) §1: status theo thời điểm phát hiện.
- [Phiếu quan sát](../playtest-observation-sheet.md) §§2, 6–7: preflight, evidence phiên và handoff.

## Kết quả đối chiếu

| Kiểm tra | Gap trước audit | Xử lý | Kết quả |
|---|---|---|---|
| `READY` | Preflight chỉ liệt kê nhãn, chưa buộc build `GO`, gate/fixture cần cho coverage và outcome đúng nguồn. | `READY` nay cần đủ ba điều kiện và flow thật. | `repaired` |
| Thiếu trước phiên | Câu nguồn gộp mọi state/source mâu thuẫn thành `KHÔNG TEST ĐƯỢC`. | Gate/fixture thiếu trước mời player là `NOT READY`; không mời player và mở handoff fixture/readiness hẹp. | `repaired` |
| Outcome phá invariant | Preflight không nêu hành động riêng cho outcome thật sai luật. | `BLOCKER` build/readiness nay dừng gate/phiên, ghi state → action → outcome, trả readiness `BLOCKER`, tái hiện một lần cùng build và mở task state/readiness ngay. | `repaired` |
| Thiếu chỉ lộ trong phiên | Chưa phân biệt rõ với hai trạng thái preflight. | Chỉ fixture/state thiếu phát hiện trong phiên mới là `KHÔNG TEST ĐƯỢC`, rồi readiness coverage về `NOT READY`. | `repaired` |
| Nhánh tự chọn | C0/C2 không đi một nhánh do lựa chọn player không phải fixture fail. | Giữ `chưa gặp`; không thêm nó vào preflight. | `clear` |

## Quy tắc giữ cố định

- `READY` chỉ xác nhận build/fixture đủ cho phiên readability, không xác nhận balance, accessibility hoặc release.
- `NOT READY` là gate/fixture thiếu trước phiên; `KHÔNG TEST ĐƯỢC` là thiếu chỉ phát hiện trong phiên và phải rollback readiness coverage.
- `BLOCKER` build/readiness chỉ là outcome thật của build phá invariant; hiểu sai player trong build đúng state vẫn là candidate semantic/readability đi synthesis.
- Không dùng prompt, narration, state giả hay content mới để thay fixture thiếu.

## Ngoài phạm vi

Audit không thêm hoặc sửa claim, probe, sample size, triage threshold, UI/final copy, implementation, map, lore, item, NPC, economy, balance, combat, checkpoint, Contract 2/3, difficulty, incident, boss/elite hay multiplayer.
