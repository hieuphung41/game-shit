# Extract brief — Cầu tàu A, vertical slice “Giữ giấy phép”

**Trạng thái:** brief extraction arrangement `proposed` cho Easy / Contract 1. Nó làm rõ state, hành động và boundary success/death tại A; không là combat tuning, layout toạ độ, UI mockup, asset list hay implementation plan.

**Nguồn ràng buộc:** [vertical slice](../vertical-slice.md), [wireflow UX](../vertical-slice-wireflow.md), [build-readiness](../vertical-slice-build-readiness.md), [blockout A/B/D](black-tax-port-vertical-slice-blockout.md), [encounter B](black-tax-port-b-encounter-brief.md), [art/presentation direction](../art-direction.md) và [inventory/loadout](../systems/inventory-and-loadout.md). Khi map campaign rộng hơn khác cut này, nguồn slice/wireflow/readiness ưu tiên: Easy cố định, Contract 1, A/B/D playable, chỉ Cầu tàu A extract; C/E là silhouette và D không có extract.

## 1. Mục đích và ranh giới

Extract ở A dạy một câu hỏi cuối run: **“Tôi đã mang Manifest về đúng cầu tàu, có chủ động gọi thuyền, giữ khu khi lane B đã báo trước, rồi tự lên thuyền để giao vật chứng không?”** Rút sớm ngay sau Manifest và return từ full-route đều phải đi cùng flow/success boundary; full-route không có summary/reward branch “đúng hơn”.

| Có trong brief | Không được suy ra hoặc thêm vào |
|---|---|
| Beacon A E0/E1, O5 preview/xác nhận/hủy, S7 call accepted, S8 hold, S9 boat ready, player board, S10/S11 boundary, pressure từ lane B | Thời lượng/timing, damage/HP, AI/count/spawn table, enemy role/lesson mới, kill-all, checkpoint, D/E extract, C/E route, Contract 2 playable, Hard/Extreme, incident/boss/elite, asset/audio/UI cuối, economy, implementation |

Manifest phải được đặt hợp lệ trước khi beacon A callable. Đưa Manifest vào Hộp vẫn là `đã niêm — chưa extract`; niêm không phải gọi thuyền, completion hay cách bỏ qua flow này.

## 2. Quan hệ state và ranh giới outcome

Sơ đồ mô tả state/action nhìn thấy được, không biểu thị vị trí, scale, toạ độ, duration hay xử lý kỹ thuật.

```text
S3/S4/S5: player quay về A với Manifest
                    │
                    v
E1 beacon A callable ── chọn “Gọi thuyền” ──> O5 preview
     ^                                                   │
     └────────────────────────── hủy ───────────────────┘
                                                        │ xác nhận
                                                        v
                                              S7 call accepted
                                                        │
                                                        v
                   lane B báo trước ─────────> S8 giữ khu / cover
                                                        │ thuyền tới
                                                        v
                                              S9 boat ready
                                                        │ player board
                                                        v
                                      S10 success summary / hub

           death trong S8 hoặc S9 ─────────────────────> S11 death summary → S12 Recovery
```

Trước Manifest, beacon ở `E0 — unavailable`; đứng trong vòng A không tạo extract. `S7` xác nhận game đã nhận lời gọi, không đòi player gọi lần hai và không tự là thắng. Chỉ tương tác **board** khi thuyền đã sẵn sàng mới vào `S10`; death tại `S8` hoặc `S9` luôn vào `S11`, không checkpoint, không auto-board và không auto-extract.

## 3. Contract từng state tại Cầu tàu A

| State | Điều kiện/action của player | Hệ thống phải cho thấy | Chuyển hợp lệ / điều không được hàm ý |
|---|---|---|---|
| **E0 — unavailable** | Player chưa có Manifest đặt hợp lệ. | Beacon/cầu tàu A đọc được nhưng label nêu chưa đủ điều kiện. | Giữ state in-run; không gọi thuyền, không “win vì đứng trong vòng”. |
| **E1 — callable** | Player đang mang Manifest và vào A; chọn `Gọi thuyền`. | Beacon A, objective `extract A`, cùng O5 preview hậu quả và nút xác nhận/hủy. | O5 xác nhận → S7; hủy → E1 không mất đồ/route. D/B/C/E không nhận cùng affordance extract. |
| **S7 — call accepted** | Player đã xác nhận O5. | Một state gọi đã nhận, health/objective/lane alert vẫn trên HUD. | Vào S8; không yêu cầu gọi lại, không thay manifest thành delivered và không auto-win. |
| **S8 — hold area** | Player giữ khu, dùng cover/guard/dash hoặc phản ứng đã học với pressure từ B. | Vùng giữ khu, cover, cầu tàu và miệng lane B cùng đọc được; alert lane báo trước. | Thuyền tới → S9; death → S11. Không kill-all, checkpoint hay lesson combat mới. |
| **S9 — boat ready** | Player nhìn/tiếp cận đích board và chủ động tương tác. | Thuyền/đích board rõ, khác beacon/hold state; lane/HUD vẫn không bị che. | Board → S10; death → S11. Thuyền đến không auto-board/auto-complete. |
| **S10 — success** | Player đã board sau E1/S7/S8/S9 hợp lệ. | Summary tách `Đã giữ`, `Đã mất` nếu có, `Vật chứng`, `Tiếp theo`. | Contract 1 success; chỉ campaign state Contract 2 mở với nhãn chưa playable. |
| **S11 — death** | Death trước board tại S8/S9, hoặc death in-run theo luật nguồn. | Summary khác hình/từ success; tách giữ/mất/vật chứng `unrecovered` và action Recovery. | Không extract, completion, checkpoint hay restore ngầm. Sau Manifest → S12 Recovery Contract. |

`Gọi thuyền` là action có hậu quả khó đảo ngay nên dùng O5; preview nêu đúng action bắt đầu pressure và hai lựa chọn xác nhận/hủy. O5 không là màn new rule, không được thay `S7`, và không được dùng để thêm confirmation cho di chuyển, inspect, hold, board hay action an toàn khác.

## 4. Pressure lane B — đọc được trước khi phải phản ứng

Trong S8/S9, **chỉ lane từ B** đưa pressure đến A. Trước khi threat vào camera/đụng player, lane có cue kết hợp ánh sáng, âm thanh và telegraph/hướng nhìn; mỗi kênh phải có thể hỗ trợ hiểu hướng, không dùng màu riêng lẻ làm nghĩa danger.

| Người chơi phải đọc được đồng thời | Phản ứng đã tồn tại | Không được có |
|---|---|---|
| Beacon/vùng giữ, cover gần A, cầu tàu/đích board khi có, miệng lane B và objective/health/lane alert. | Dùng cover, guard, dash hoặc combat response đã học; ưu tiên giữ khu hay rút đường phản ứng trong A. | Pressure từ sau lưng/ngoài camera, lane khác B, role mới, combat tutorial/prompt mới, kill-all, spawn bất ngờ, checkpoint hoặc lối extract thứ hai. |

Brief này không quyết định số lượng threat, thời điểm vào lane, damage, health hay AI. Nó chỉ giữ fairness contract: player thấy nơi threat tới và ít nhất một cover/đường phản ứng trước pressure; death do input/timing khi player hiểu telegraph không tự chứng minh comprehension `FAIL`.

## 5. Success, death và Recovery boundary

### 5.1 S10 — success sau board

| Nhóm summary | Cách diễn giải phải giữ |
|---|---|
| `Đã giữ` | Manifest đã extract: Contract 1 thành công; loot hợp lệ còn mang về hub theo rule inventory. Không tự bán/craft bất cứ món nào. |
| `Đã mất` (nếu có) | Đồ player đã chủ động bỏ hoặc không mang tới extract không tự trở về. Không gọi đây là phạt vì rút sớm hay không đi full-route. |
| `Vật chứng` | Manifest là lead đã bàn giao cho Kho K-7, không là bằng chứng pháp lý cuối hay `Bộ Phản Niêm R-17`. |
| `Tiếp theo` | Contract 2 chỉ mở ở campaign state và ghi rõ `chưa có trong vertical slice`; không có nút bắt đầu. |

Rút sớm và full-route đi cùng S10. Khác biệt duy nhất có thể thấy là danh sách loot/ô đã dùng theo lựa chọn người chơi; summary không chấm “build tốt nhất”, branch, vendor hay local story mới.

### 5.2 S11/S12 — death không là extract

| State death sau Manifest, gồm S8/S9 | Summary/action đúng | Không được xảy ra |
|---|---|---|
| Manifest ở ba lô hoặc Hộp | Manifest là `Vật chứng — unrecovered`; Contract chưa complete. | Seal/hold/death thành delivery, Manifest về Archive/hub hoặc success summary. |
| Non-evidence đã niêm | Nhóm `Đã giữ` nêu item hợp lệ được giữ. | Mọi item trong Hộp bị gộp thành evidence `unrecovered`, hay item niêm bị báo mất. |
| Gear/loot không niêm và đồ đã tự bỏ | Nhóm `Đã mất`; Recovery không tự trả lại. | Restore ngầm, checkpoint nửa extract hoặc nhân đôi/hoàn đồ đã tự bỏ. |
| Next action | `Xem Recovery Contract` → S12 → briefing/loadout recovery → **bàn dispatch A**: tự thu hồi Manifest `unrecovered` → placement hợp lệ → E1. E1 chưa là success; vẫn cần A call/hold/board để thành công. | Soft-lock campaign, recovery auto-complete hoặc bắt mua gear để tiếp tục. |

Death summary dùng signal/wording khác success. Nó không tự gọi lại thuyền; chỉ đường Recovery giữ main campaign tiếp tục được, không phủ định rủi ro extraction.

## 6. Mobile readability và fairness checks

1. Camera isometric có hướng nhất quán, tối đa hai cao độ đọc được; foreground/thuyền/HUD không che player, cover, beacon, board target, lane B, telegraph hoặc objective không?
2. `unavailable`, `callable`, `call accepted`, `hold`, `boat ready` và death/success có silhouette/icon/text/vị trí/motion hoặc audio khác nhau, không chỉ đổi màu không?
3. O5 có giữ health, objective ngắn và lane alert đọc được; hủy có quay về E1 không mất đồ; chỉ `Gọi thuyền` mới cần confirmation bắt đầu pressure không?
4. Trong hold/ready, người chơi có thấy lane B và ít nhất một cover/đường phản ứng trước threat, không có spawn sau lưng/ngoài camera, kill-all hay lesson mới không?
5. Board có còn là action player chủ động sau boat ready, và death ở hold/ready có luôn đi S11 thay vì S10 không?
6. Early extract và full-route có dùng cùng A-only success flow; C/E có không input, D có không extract, và Contract 2 có giữ nhãn chưa playable không?
7. Manifest niêm có còn `chưa extract`; death summary có tách non-evidence niêm được giữ khỏi gear/loot không niêm mất và evidence `unrecovered` không?

## 7. Handoff và giới hạn mở

Prototype/art review chỉ cần xác nhận state transitions E0/E1/O5/S7/S8/S9/S10/S11, lane B fairness và summary boundary ở trên. Không suy từ brief này ra timing hold, combat tuning, số lượng threat, damage/HP, AI/spawn, audio/asset/UI cuối, toạ độ/collision/navmesh hay implementation.

Các câu hỏi cố ý để mở: biểu hiện prop/cầu tàu/thuyền cuối, control scheme, vị trí cover chính xác, tuning pressure và implementation state. Chúng cần Task Card khác; không giải bằng route/boat extract mới, C/E access, prompt/lore/reward mới, checkpoint, Contract 2 playable hay thay luật extract/death/recovery.
