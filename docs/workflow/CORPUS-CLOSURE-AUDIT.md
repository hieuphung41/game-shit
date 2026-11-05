# Audit khép corpus — Khế Ước Tàn Vương

**Trạng thái:** current-state closure audit `PASS` sau `TASK-20261105-50` và recheck `TASK-20261105-53`. Tài liệu này kiểm tra khả năng bàn giao của corpus Markdown hiện có; nó không phải nguồn canon, không xác nhận build/playtest đã chạy, và không tự thay đổi luật, nội dung hay backlog.

## 1. Phạm vi, cách phân loại và thứ tự nguồn

Phạm vi là mọi Markdown dưới `docs/` tại thời điểm recheck: **78 file**. Audit đối chiếu nguồn đang hiệu lực, không suy kết từ checkbox của Task Card cũ.

| Loại | File/family đang hiệu lực | Nguồn quyết định hoặc ràng buộc | Cách dùng trong closure |
|---|---|---|---|
| Canon campaign | [tuyến truyện chính](../story/MAIN_STORY.md), [vùng truyện](../story/REGION_STORY_AND_PROGRESSION.md), [cast/phe](../story/CHARACTERS_AND_FACTIONS.md), [local story/event](../story/MAP_LOCAL_STORIES_AND_EVENTS.md), [item narrative](../story/ITEM_NARRATIVE_DESIGN.md) | `MAIN_STORY.md` thắng khi khác luật thế giới, evidence, Act, ending hoặc hậu campaign. | Chốt nhân quả campaign, quyền mở vùng và ràng buộc expansion. |
| Bản nháp/record lịch sử | [Story Bible](../story/STORY_BIBLE.md) là working draft có nhường canon; [Campaign Outline](../story/CAMPAIGN_OUTLINE.md), các `*-AUDIT.md` story/map và Task Card cũ là archive/audit record. | Mỗi file tự ghi status/guardrail; không dùng audit cũ hay outline archive để mở lại canon. | Giữ trace quyết định, không là nguồn thiết kế mới. |
| Map, item và system | [Cảng Hắc Thuế](../maps/black-tax-port.md), brief A/B/D/recovery/dispatch/C3/blockout, [24 item card Act I](../items/black-tax-port-items.md), [inventory/loadout](../systems/inventory-and-loadout.md), [art direction](../art-direction.md) | Canon campaign ở trên; với cut hiện hành, slice/wireflow/readiness ưu tiên hơn map campaign rộng. | Chuyển story thành objective, route, loot, loss/recovery và presentation mà không lẫn full map với slice. |
| Slice và build state | [vertical slice](../vertical-slice.md), [wireflow](../vertical-slice-wireflow.md), [build readiness](../vertical-slice-build-readiness.md) | Slice → wireflow/readiness; các brief chỉ làm rõ arrangement, không đổi state machine. | Khóa cut, success/death boundary và gate trước phiên. |
| Quan sát, tổng hợp, triage | [playtest plan](../playtest-readability-plan.md), [observation sheet](../playtest-observation-sheet.md), [synthesis template](../playtest-synthesis-template.md), traceability/observation/triage audit map | Source theo từng claim/state; synthesis chỉ tổng hợp evidence đủ điều kiện. | Tách observation, diagnostic/readiness và repair evidence-backed. |
| Workflow | [workflow](WORKFLOW.md), [external references](EXTERNAL_SKILLS.md), [task queue](TASK_QUEUE.md), task cards | Root `AGENTS.md` và repo-local skill là protocol vận hành. | Giữ ownership, review gate, handoff và trạng thái công việc rõ ràng. |

`proposed` có nghĩa arrangement/content chưa được duyệt final, **không** đồng nghĩa thiếu tài liệu. Những text như `chưa có trong vertical slice`, `NOT READY`, `KHÔNG TEST ĐƯỢC` hoặc fixture là giới hạn scope/trạng thái test có chủ đích, không phải placeholder cần bịa nội dung để lấp.

## 2. Chuỗi story → map → item → system

| Kiểm tra current-state | Bằng chứng nguồn | Kết quả |
|---|---|---|
| Campaign có kết hiện tại nhưng còn cửa mở rộng | Main story §§5–13; region progression §§1–10; local-story §7 | `PASS`: Act I–V đóng Crown Audit bằng Hiến Ước Lâm Thời; map update khai thác hệ quả, không retcon một phản diện/kết thúc bí mật. |
| Map có local wound, actor, objective, pressure và aftermath | Main story §§7–11; local-story §§1–8; map brief §§1–10 | `PASS`: Cảng Hắc Thuế có vết thương/actor/route/incident riêng và vẫn giữ main contract extract evidence. |
| Evidence mở campaign đúng thứ tự | Main story §5; region progression §§5–9; map brief §4; item narrative §§3, 8 | `PASS`: `Manifest → K-7 → Counterseal + Sổ Nợ Gốc → Bộ Phản Niêm → Ward Engine registry → Witness Key/Mark → Field Seal + registry → ngăn Crown Audit`. Manifest không phải vật chứng cuối hoặc quyền vào Act II. |
| Item/loss có ý nghĩa gameplay và chuyện kể | Item narrative §§1–11; inventory/loadout §§1–8; item card §§1–7 | `PASS`: item có value/preparation/power/truth; vật chứng extractable và death không soft-lock campaign. 24 card là content `proposed`, không bị nhầm với fixture slice. |
| Full map không lẫn với playable cut | Map brief §9; inventory/loadout §9; vertical slice; briefs A/B/D/recovery | `PASS`: map campaign A–E/Contract rộng được ghi riêng; cut chỉ là Easy, Contract 1, A/B/D, A-only extract. |

## 3. Chuỗi slice → state/recovery → readiness

| Invariant kiểm tra | Bằng chứng nguồn | Kết quả |
|---|---|---|
| Phạm vi build | Vertical slice; wireflow §§1–2; build-readiness §§2–7; blockout §§1–6 | `PASS`: Easy cố định, Contract 1, A/B/D playable; C/E silhouette không input; D không extract; không Contract 2/3, Hard/Extreme, incident, elite hoặc boss. |
| Extract là success có hành động | Wireflow §§5–8; extract A brief §§1–6; traceability §2 | `PASS`: chỉ placement Manifest hợp lệ mới tạo E1; `call → hold → board` mới tới S10. E1/niêm không phải completion; rút sớm và full-route cùng boundary success. |
| Death/recovery không thành checkpoint | Inventory §7; wireflow §8; recovery/C3/dispatch brief; traceability §3 | `PASS`: sau Manifest, death để evidence `unrecovered`; chỉ sealed non-evidence trở về, gear/loot unsecured mất; S11 → S12 → S1 → S2, tự thu hồi tại bàn dispatch A, placement hợp lệ rồi vẫn extract A theo flow bình thường. |
| Readiness khác outcome test và lỗi invariant | Build-readiness §§7–9; plan §5; observation sheet §§1, 6; synthesis §§1–3 | `PASS`: fixture thiếu trước phiên là `NOT READY`; phát hiện trong phiên là `KHÔNG TEST ĐƯỢC` rồi rollback readiness; outcome thật trái invariant là `BLOCKER` build/readiness. |

## 4. Chuỗi observation → synthesis → triage

| Kiểm tra | Bằng chứng nguồn | Kết quả |
|---|---|---|
| C0 giữ vai trò first-time, C1–C3 chỉ coverage có kiểm soát | Plan §§3–5; observation sheet §§3–6; synthesis §§1, 3–7; scorecard evidence audit | `PASS`: P1/P2 route-choice chỉ dùng C0 first-time/no-hint; C1 chỉ bổ sung P2 semantics; một full-route first-time/no-hint được record là C0 độc lập, không là C2. Xem CCA-01 recheck. |
| P6/recovery cần full chain đúng nguồn | Traceability §3; observation C3; synthesis §§3, 5, 7 | `PASS`: C3 death thật → recovery → self-reclaim → placement → call/hold/board mới đủ P6 `PASS`; C0/C2 chỉ support. |
| Chỉ evidence đủ gate mới mở repair | Plan §5; synthesis §§8–9; triage and session audits | `PASS`: build/readiness blocker dừng phiên ngay; semantic/readability candidate đi qua source, comparability, confounder và reproduction trước repair card; diagnostic không giả làm lỗi design. |

## 5. Liên kết và text cần phân loại

- Resolver local Markdown đã kiểm **366** link target tương đối: `PASS` — không có target file Markdown thiếu.
- `git diff --check --no-index /dev/null` trên file audit này và whitespace scan Markdown: không có diagnostic whitespace.
- Scan `TODO`, `TBD`, `FIXME`, `[[`, `{{` trong nguồn active: không có placeholder chưa phân loại. Các occurrence `proposed`, fixture, `chưa có trong vertical slice`, `NOT READY` và `KHÔNG TEST ĐƯỢC` là nhãn status/scope có nguồn. Cụm “Tên là placeholder” ở [Main Story §4](../story/MAIN_STORY.md) là quy ước naming có chủ đích: header Main Story và [cast/phe §1](../story/CHARACTERS_AND_FACTIONS.md) đã khóa vai trò canon, đồng thời giữ tên riêng/chân dung/lời thoại là `proposed`; đây không phải lore/content gap.
- `CAMPAIGN_OUTLINE.md`, các audit trước và task card là record archive/audit; finding `repaired` hoặc `MUST_FIX` được lưu ở đó không phải finding active nếu nguồn được audit đã phản ánh sửa. Chúng không được dùng để override nguồn ở §§1–4.

## 6. Recheck finding đã xử lý

| ID | Trạng thái recheck | Location đã kiểm lại | Evidence resolution | Ranh giới giữ nguyên |
|---|---|---|---|---|
| CCA-01 | `repaired` by TASK-51 | [playtest plan](../playtest-readability-plan.md) §3.3 C1/C2; [observation sheet](../playtest-observation-sheet.md) §4 C1/C2 | C1 ghi P2 semantics/P7, cấm dùng cho P1/P2 route-choice; C2 sau C0 chỉ state/UI; run full-route first-time/no-hint được record là C0. Điều này khớp [synthesis](../playtest-synthesis-template.md) §§1, 3, 5, 7 và [scorecard audit](../maps/black-tax-port-scorecard-evidence-source-audit.md). | Không đổi claim ID, threshold, fixture, state, C0-before-C3, P6 full-chain, triage hay recovery. |
| CCA-02 | `repaired` by TASK-52 | [task queue](TASK_QUEUE.md) §§Completed baseline, Current closure sequence | TASK-02…07 có output link và trạng thái completed baseline/history; dependency được ghi là historical/non-scheduling; closure cards và recheck được phân biệt với design backlog. | Không đổi task card lịch sử, source design, canon hay tự khởi động task mới. |

## 7. Kết luận closure

Corpus có coverage đầy đủ cho narrative, campaign-region, map/item/system, vertical-slice state/readiness và observation/triage; map/item/system và state/recovery chain không có contradiction active. Review độc lập của TASK-53 xác nhận CCA-01 và CCA-02 đều `repaired`; trong phạm vi audit này không còn `BLOCKER` hay `MUST_FIX`. Closure tổng thể là **`PASS`** cho corpus tài liệu hiện có. Đây không phải xác nhận build, implementation, balance hay playtest outcome; những việc đó chỉ bắt đầu bằng Task Card mới do user chọn. Không có finding nào cho phép tự thêm lore, map, item, economy, combat, UI, implementation hay gameplay scope mới.
