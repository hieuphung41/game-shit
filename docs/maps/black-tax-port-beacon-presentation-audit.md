# Audit presentation beacon A — Vertical slice Cảng Hắc Thuế

**Trạng thái:** audit `proposed` cho TASK-20261029-25. Phạm vi chỉ là corpus presentation/UX của vertical slice, không audit toàn bộ campaign, bản đồ hay item canon.

## Chuỗi chuẩn dùng để đối chiếu

```text
E0 unavailable
→ player tự commit Manifest vào một ô hợp lệ của ba lô hoặc Hộp Công Chứng
→ E1 callable
→ gọi thuyền → giữ khu → lên thuyền A → S10 success
```

Inspect, mở O2, shorthand “nhặt”, placement fail/hủy, niêm Manifest, hoặc chỉ tới A không đổi E0. Khi fail/hủy, Manifest vẫn ở source. Niêm (nếu người chơi chọn) chỉ là `đã niêm — chưa extract`. Cùng gate áp dụng cho recovery sau death thật `S11 → S12 → S1 → S2`; E1 không là success.

## Kết quả theo candidate

| Phân loại | File / section | Evidence hoặc xử lý |
|---|---|---|
| `repaired` | [vertical slice](../vertical-slice.md) §3, Beat 2 | Thay “Cầu tàu A bật beacon” bằng gate placement hợp lệ vào ba lô/Hộp, E0 → E1 và fail/hủy giữ source/E0. |
| `repaired` | [vertical slice](../vertical-slice.md) §5.1, Extract | Thay “đổi trạng thái ngay sau Manifest” bằng cùng gate; ghi E1 vẫn cần gọi/giữ/lên thuyền. |
| `repaired` | [blockout](black-tax-port-vertical-slice-blockout.md) §4, `A — spawn, dispatch, Manifest` | Thay hai shortcut “sau Manifest” về callable/đổi beacon bằng placement hợp lệ, source/E0 khi fail/hủy và E1 callable. §2 route shorthand `sau Manifest: rút sớm` giữ nguyên vì không mô tả transition và §1 đã khóa placement hợp lệ. |
| `clear` | [art direction](../art-direction.md) §6, A: Manifest và rút sớm | Đã nêu placement hợp lệ vào ba lô/Hộp; inspect, mở card, fail/hủy giữ E0. |
| `clear` | [wireflow](../vertical-slice-wireflow.md) §§2, 3, 5, 8 | Graph và action O2 đặt placement trước E1; cancel giữ source; call/hold/board mới tới S10. |
| `clear` | [build readiness](../vertical-slice-build-readiness.md) G4, G18, §8.3 | Nêu placement hợp lệ cho pickup/recovery, E1 callable và boundary call/hold/board. |
| `clear` | [playtest plan](../playtest-readability-plan.md), [observation sheet](../playtest-observation-sheet.md), [synthesis template](../playtest-synthesis-template.md) | Fixture dùng state sau placement/E1, giữ C0 trước C3, death thật và `NOT READY`/`KHÔNG TEST ĐƯỢC` khi không tạo được state. |
| `clear` | [A extract brief](black-tax-port-a-extract-brief.md), [D cargo brief](black-tax-port-d-cargo-choice-brief.md), [dispatch state contract](black-tax-port-dispatch-state-contract.md), [visual checklist](black-tax-port-dispatch-visual-readability-checklist.md), [dispatch observation card](black-tax-port-dispatch-observation-card.md), [recovery brief](black-tax-port-recovery-brief.md), [C3 fixture brief](black-tax-port-recovery-c3-fixture-brief.md), [recovery source decision](black-tax-port-recovery-source-decision.md), [dispatch wording audit](black-tax-port-dispatch-wording-audit.md) | Mỗi nguồn hoặc nêu valid placement/E0/E1, hoặc chỉ mô tả extract sau E1; không có cue inspect/pickup tự mở beacon. |
| `outside slice/canon retained` | `black-tax-port.md` §4 Contract 1; `items/black-tax-port-items.md` §2 item 01 | Map-scale recovery “bàn dispatch A hoặc túi người đưa tin” chỉ được tham chiếu gián tiếp qua dispatch wording audit, không thuộc corpus. Fixture slice dispatch-only không retcon canon này. |

## Invariant và handoff

- Easy / Contract 1; A là extract duy nhất; B/D tùy chọn, D không extract; C/E chỉ silhouette; rút sớm là success đầy đủ ở S10.
- C0 chạy trước C3; C3 cần death thật. Thiếu fixture trước session là `NOT READY`; phát hiện trong session là `KHÔNG TEST ĐƯỢC` rồi trả readiness về `NOT READY`.
- Contract 2 chỉ state chưa playable sau S10. Không có checkpoint, respawn, auto-recovery hoặc auto-complete.
- Audit không thêm item, NPC, route, UI, asset, combat/hazard/economy, incident hay thay đổi canon.

**Handoff hẹp:** Nếu build sau này cho E1 xuất hiện trước placement hoặc completion trước A call/hold/board, mở một Task Card implementation/readiness riêng; không sửa story hay mở route để che lỗi state.
