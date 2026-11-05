# Audit wording — bàn dispatch A, vertical slice “Giữ giấy phép”

**Trạng thái:** audit arrangement `proposed` cho Easy / Contract 1. Audit này chỉ xét corpus vertical-slice được nêu trong [Task Card TASK-20261029-22](../workflow/tasks/TASK-20261029-22.md); nó không audit hay thay đổi campaign/map/item canon rộng.

**Câu hỏi audit:** Có câu slice-facing nào khiến việc đến **bàn dispatch A** bị hiểu là Manifest tự quay về, respawn/checkpoint, delivery hay completion không?

## 1. Kết luận và tiêu chí đọc

Kết luận: sáu tài liệu có chín diễn đạt tóm tắt cần nối lại với state contract chi tiết. Chúng đã được sửa về cùng một chuỗi:

```text
death sau Manifest → S11 → S12 → S1 recovery → S2 bàn dispatch A
→ player tự thu hồi Manifest `unrecovered` → placement hợp lệ → E1 callable
→ A call/hold/board → S10 success
```

Chuỗi này chỉ tồn tại sau death **sau Manifest**. Lần tương tác đầu run ở cùng bàn là pickup riêng (`S1 → S2 → O2 bàn dispatch → Nhặt và xếp → placement hợp lệ → E1`), không tạo action recovery. `E1` là quyền gọi thuyền, không là delivery/completion; Manifest niêm luôn `đã niêm — chưa extract` cho tới S10.

## 2. Candidate trong corpus vertical-slice

| File / section | Candidate đã đọc | Phân loại | Evidence / xử lý |
|---|---|---|---|
| [vertical-slice](../vertical-slice.md) §4.3 | Death sau Manifest chỉ nói Recovery Contract “chỉ điểm logic” ở A. | `repaired` | Nay nêu `unrecovered → S11/S12/S1 → bàn dispatch A → tự thu hồi → placement`; E0→E1 chỉ sau placement và A call/hold/board vẫn bắt buộc. |
| [wireflow UX](../vertical-slice-wireflow.md) §2, nhánh initial | Bản đồ state cấp cao đi thẳng từ spawn tới S3, lược O2 bàn dispatch và placement đầu run. | `repaired` | Nay nêu `S2 → O2 bàn dispatch (pickup đầu run only) → Nhặt và xếp → placement hợp lệ → S3/E1`; nó không là recovery hay auto-pickup. |
| [wireflow UX](../vertical-slice-wireflow.md) §2 | Bản đồ state cấp cao dừng ở “S2 A: điểm recovery logic”. | `repaired` | Sơ đồ nay nêu bàn dispatch, self-reclaim, placement, E1 và success boundary A. |
| [wireflow UX](../vertical-slice-wireflow.md) §8 | S12/S1/S2 gọi A là “điểm logic” nhưng rút gọn action ở A. | `repaired` | Nay nêu `unrecovered`, manual reclaim, valid placement, E0→E1 và E1 không là success. |
| [build-readiness](../vertical-slice-build-readiness.md) G18 | Gate recovery nêu A là điểm logic và extract sau đó, thiếu chuỗi action tại bàn. | `repaired` | Gate nay đòi player tự thu hồi, placement hợp lệ rồi mới E1; A call/hold/board mới S10. |
| [build-readiness](../vertical-slice-build-readiness.md) C3 | Route readiness kết thúc tại “S2 điểm recovery”. | `repaired` | Route nay có bàn dispatch, self-reclaim, placement, E1 và success boundary. |
| [phiếu quan sát](../playtest-observation-sheet.md) C3 | Fixture/table kết thúc tại “S2 điểm recovery”. | `repaired` | Sequence/row nay yêu cầu tự thu hồi `unrecovered` và placement; nói rõ E1 chưa là success. Facilitator protocol không đổi. |
| [kế hoạch readability](../playtest-readability-plan.md) §3.3 C3 | “Quay A để thấy điểm recovery logic” có thể bị đọc là arrival tự giải quyết state. | `repaired` | Coverage nay ghi bàn dispatch A, self-reclaim, placement, E1 và A call/hold/board. Câu facilitator trung tính giữ nguyên. |
| [brief extract A](black-tax-port-a-extract-brief.md) §5.2 | Hàng `Next action` dừng ở “A điểm recovery logic”. | `repaired` | Nay nêu bàn dispatch A, self-reclaim, valid placement, E1 chưa success và call/hold/board. |
| [vertical-slice blockout](black-tax-port-vertical-slice-blockout.md) §§4–5 | Landmark A/đọc route và fairness của fixture. | `clear` | Không gọi arrival là recovery tự động; không tạo checkpoint/respawn/delivery/completion. |
| [brief cargo D](black-tax-port-d-cargo-choice-brief.md) §§5–7 | Safebox/evidence/death guardrails và handoff D. | `clear` | D không extract; wording giữ Manifest niêm là chưa extract và recovery không restore. |
| [recovery brief](black-tax-port-recovery-brief.md) §§1–7 | Flow S11→S12→S1→S2 và recovery table. | `clear` | Đã nêu bàn dispatch, manual reclaim, placement, E0/E1, A-only success và không checkpoint/restore. |
| [C3 fixture brief](black-tax-port-recovery-c3-fixture-brief.md) §§1–6 | Requirement/observation cho C3. | `clear` | Giữ death thật, C0 trước C3, neutral probe, `NOT READY`/`KHÔNG TEST ĐƯỢC` semantics và recovery không auto-return. |
| [source decision](black-tax-port-recovery-source-decision.md) §§1–4 | Lý do prototype chọn bàn dispatch A. | `clear` | Nêu rõ cùng fixture không là respawn/checkpoint và player tự thu hồi rồi extract bình thường. |
| [state contract](black-tax-port-dispatch-state-contract.md) §§1–6 | So sánh pickup đầu và recovery tại cùng bàn. | `clear` | Entry gates, action khác nhau, placement/E0/E1 và no-auto-success đã đầy đủ. |
| [observation mini-card](black-tax-port-dispatch-observation-card.md) §§1–5 | C0/C3 evidence tại cùng bàn. | `clear` | C0 không hint recovery; C3 tự thu hồi/placement, E1 không success, no-go/record rules rõ. |
| [kế hoạch readability](../playtest-readability-plan.md) §3.4 probe | Probe death/recovery sau run. | `clear` | Giữ câu hỏi trung tính và requirement build state thật; không đổi thành route/action hint. |

## 3. Ranh giới canon ngoài slice

Hai nguồn rộng được xem chỉ để phân loại reference của quyết định source, không nằm trong corpus sửa:

| Nguồn rộng | Candidate | Phân loại | Xử lý trong task này |
|---|---|---|---|
| [map contract rộng](black-tax-port.md) §4, Contract 1 | Death có thể đưa Manifest về bàn dispatch **hoặc túi người đưa tin** trong A. | `outside slice/canon retained` | Không sửa. Prototype chỉ chọn bàn dispatch A làm source recovery, không retcon khả năng map-scale này. |
| [item card rộng](../items/black-tax-port-items.md) §2, item 01 | Manifest `unrecovered` tại bàn A **hoặc túi người đưa tin**. | `outside slice/canon retained` | Không sửa. Túi người đưa tin không được dựng/đặt tên/hiển thị trong vertical slice. |

Không có retcon hay thay đổi canon ngoài slice.

## 4. Invariant còn hiệu lực sau audit

- Easy / Contract 1; A là extract duy nhất. B/D optional, D không extract, C/E chỉ silhouette; early extract và full-route ngang nhau tại success boundary.
- Sau death Manifest vẫn `unrecovered`, không về hub/Archive. Non-evidence niêm giữ; gear/loot không niêm và đồ tự bỏ mất. Recovery không restore hoặc auto-manage inventory.
- C0 chạy trước C3. C3 chỉ dùng death thật; P6 không đổi. Thiếu fixture trước phiên là `NOT READY` và không mời first-time player; phát hiện giữa phiên là `KHÔNG TEST ĐƯỢC` rồi trả readiness về `NOT READY`.
- Contract 2 chỉ là campaign state sau S10, chưa playable trong slice. Audit không thêm route, item, NPC, combat, UI/final copy, checkpoint/respawn hay implementation.

## 5. Handoff

Audit này là một arrangement `proposed`: mọi thay đổi sau đó về asset, visual treatment, final wording/localization, layout, control, persistence hoặc implementation cần Task Card riêng. Nếu future playtest ghi player vẫn đọc bàn dispatch là auto-return/respawn/delivery/completion, hãy mở một card chỉ cho evidence state/action cụ thể; không tự thêm NPC, marker, route, túi người đưa tin hoặc narration để che finding.
