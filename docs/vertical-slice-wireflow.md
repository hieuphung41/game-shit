# Wireflow UX — Vertical slice “Giữ giấy phép”

**Trạng thái:** wireflow UX `proposed`, implementation-agnostic. Nó đặt tên state và đường chuyển giữa chúng để prototype có thể kiểm tra loop extraction trên mobile; không phải mockup, layout pixel, final copy hay tài liệu implementation.

**Nguồn ràng buộc:** [vertical slice](vertical-slice.md), [inventory và loadout](systems/inventory-and-loadout.md), [art/presentation direction](art-direction.md), [kế hoạch playtest](playtest-readability-plan.md). Nếu wireflow mâu thuẫn nguồn, tài liệu nguồn được ưu tiên.

## 1. Ranh giới và cách đọc

Mọi tên state, action label và nhóm thông tin dưới đây là **arrangement `proposed`**; các câu chữ đã khóa ở briefing/contract của vertical slice vẫn là nguồn chuẩn, không bị viết lại ở đây.

| Có trong wireflow | Không nằm trong wireflow |
|---|---|
| Contract 1, Easy cố định, A/B/D, ba lô `3x4 proposed`, Hộp Công Chứng `2x2`, loot 1/2/4 ô, rút sớm, full-route đề xuất, death/recovery, A call/hold extract và summary | C/E tương tác, thuyền D/cổng E, Contract 2/3 playable, Hard/Extreme, incident/boss/elite, craft/shop, economy/stat, multiplayer, asset/mockup, engine/API/data schema |

**Ký hiệu flow:** `S#` là state toàn màn/run; `O#` là overlay không thay run state; `→` là chuyển do action hợp lệ; `↩` là hủy/trở về không mất đồ. Một action không có state đích nghĩa là hệ thống giữ nguyên state và nêu lý do bằng text/icon, không tự sửa inventory hay route cho người chơi.

## 2. Bản đồ state ở mức cao

```text
S0 Hub
  → S1 Briefing / loadout
      ├─ chỉnh loadout ↔ O1 Loadout editor
      └─ validation hợp lệ → S2 A: spawn an toàn

S2 A: spawn → O2 bàn dispatch (pickup đầu run only)
            → Nhặt và xếp + placement hợp lệ → S3 Manifest đang mang / E1 callable
                  ├─ quay A → S7 Call extract → S8 Hold extract → S9 Boat ready → S10 Success summary
                  └─ vào B → S4 B: combat / vùng yên → S5 D: cargo & Hộp → S4 → S3 → S7

S2/S3/S4/S5/S7/S8/S9 ── Phù Hiệu Hồi Hương / death ──→ S11 Death summary
  S11 (trước Manifest) → S1 / Contract 1 còn active
  S11 (sau Manifest)  → S12 Recovery Contract → S1 recovery
                                      → S2 A: bàn dispatch A → tự thu hồi `unrecovered`
                                      → placement hợp lệ → E1 callable → gọi/giữ/board A → S10

S10 ── xem hub / đóng summary ──→ S0
```

`O2` pickup card, `O3` grid ba lô, `O4` Hộp Công Chứng và `O5` confirmation chỉ phủ lên state in-run hiện tại; đóng/hủy chúng trở về state đó. Trong lúc O2–O4 mở, HUD tối thiểu vẫn cho thấy health, objective ngắn và telegraph/cảnh báo gần nhất.

## 3. Bất biến xuất hiện ở mọi state

| Nhóm thông tin | Luôn nhìn/đọc được thế nào | Không được hàm ý |
|---|---|---|
| Objective & route | Một objective ngắn; landmark/marker chỉ cho objective hiện tại và beacon A khi callable. C/E chỉ là silhouette xa, không có affordance, marker hay input. | B/D bắt buộc; C/E đã playable; Contract 2 đang vào được. |
| Combat danger | Health và telegraph/lane gần player ưu tiên hơn card/popup. Địch extract tới bằng lane có báo trước, không xuất hiện sau lưng/ngoài camera. | Màu B đỏ là damage signal; death là dấu hiệu người chơi không hiểu luật. |
| Loot | Card theo thứ tự `silhouette/tên → footprint/ô trống → công dụng hoặc giá ước lượng → claim → rarity → lore ngắn`. Footprint, claim, rarity không chỉ dựa màu. | Rarity = damage/giá trị mỗi ô; claim = rarity hoặc tự tịch thu. |
| Evidence & Hộp | Evidence mang nhãn `chưa extract`; seal hiện là bảo vệ vận chuyển, không phải delivery. Hộp/summary dùng shape/icon/text tách evidence với item thường. | Seal = completion; mọi thứ trong Hộp đều về hub khi chết. |
| Thoát overlay | Nút đóng/hủy bằng một thao tác; action chưa chốt giữ nguyên item/state. | Đóng overlay sẽ drop, niêm phong hoặc đổi route ngầm. |

## 4. Entry: briefing và loadout

### S0 → S1: bắt đầu Contract 1

S1 là một màn briefing/loadout. Nó hiển thị đúng objective, Easy, Cầu tàu A mở và rủi ro đồ không niêm theo [vertical slice](vertical-slice.md). Người chơi có thể chấp nhận starter kit hoặc mở O1; không có shop, mua đồ, fee, level hay gear-score gate ở slice.

### O1: loadout editor `proposed`

| Action player | Validation/hệ thống hiển thị | State sau action |
|---|---|---|
| Chọn món từ kho hub để đặt vào slot/lưới hợp lệ | Slot đúng loại; mọi món bị thay có chỗ kho hợp lệ; weapon hai tay khóa tay phụ theo preview. | O1 giữ mở với preview; chỉ xác nhận thay khi toàn bộ placement hợp lệ. |
| Chọn món/sắp xếp không hợp lệ | Nêu món và lý do (sai slot, không đủ chỗ, tổ hợp tay trái/phải sai). Không tự bỏ/swap món. | O1 không đổi. |
| Chấp nhận starter/loadout hợp lệ | Hiển thị summary ngắn: weapon + shield, thuốc túi đeo chéo, ba lô 3x4, Hộp 2x2 chứa một thuốc 1x2 đã niêm. | Trở về S1. |
| Hủy chỉnh loadout | Không có thay đổi chưa xác nhận. | ↩ S1. |
| Chọn `Vào cảng` | Contract/bond fixture hợp lệ; loadout có placement hợp lệ và phương án chứa đồ bắt buộc. Không kiểm tra level/gear score. | S2. |
| `Vào cảng` khi validation fail | Nêu đúng lý do và action cần tự sửa. | Giữ S1/O1; không auto-fill/mua/sửa đồ. |

Túi đeo chéo trong slice chỉ dùng quick-access; không nhận loot/cargo. Ba lô/túi không đổi giữa run. Wireflow không thêm một preset, input scheme hay control layout cụ thể.

## 5. In-run: Manifest, route và overlay loot

### S2: A — spawn an toàn

Player nhìn được đèn phao/beacon A, bàn dispatch Manifest và lối B trong cùng ngữ cảnh camera. Beacon A hiện `chưa callable`; tương tác bàn dispatch mở O2 cho `Manifest Hàng Hóa R-17` 1x1. Không combat/loot bắt buộc tại A và không có input lên silhouette C/E.

### O2: pickup card `proposed`

| Action player | Validation/feedback | State sau action |
|---|---|---|
| Xem card/inspect ngắn | Card giữ thứ tự thông tin ở §3; Manifest nói `đầu mối contract · chưa xác thực · extract A`. | O2, rồi ↩ state nguồn khi đóng. |
| `Nhặt và xếp` Manifest hoặc loot nhỏ | Người chơi chọn ô ba lô/Hộp hợp lệ qua O3/O4. Item chỉ chuyển khi placement hợp lệ. | Manifest: S3 sau placement; loot khác: state nguồn. |
| `Bỏ qua` hoặc đóng card | Không rơi/làm mất item đang mang; ground item vẫn ở source nếu chưa nhặt. | ↩ state nguồn. |
| Không có chỗ | So sánh rõ item mới, footprint và placement; cho phép mở O3/O4 hoặc hủy. | Không auto-drop, auto-swap, auto-seal hay auto-Archive. |

Sau khi Manifest được đặt hợp lệ, contract chuyển `đang mang`, beacon A chuyển `callable`, và hai lựa chọn cùng hiện được nhưng không chặn input: quay A để rút hoặc đi B để kiếm thêm. Đây là S3; **rút sớm là success hợp lệ**.

### S4 và S5: route tùy chọn

| State | Điều người chơi đang đọc | Chuyển hợp lệ |
|---|---|---|
| **S4 — B: combat/vùng yên** | Ngõ, cover, telegraph và gate B; sau gate có 15–30 giây yên để đọc card/xếp đồ. | Combat qua/né lane theo gameplay → cache B/O2 hoặc vào D; luôn có route quay A qua B. Không có C/E input. |
| **S5 — D: cargo & Hộp** | Cargo `2x2`, dấu thuế `1x2`, lưới/công dụng/tổng giá trị–giá trị/ô và lane nước/hazard. D không có extract. | Mở O2/O3/O4; mang cargo, ưu tiên dấu nhỏ, hoặc bỏ cả hai đều hợp lệ → quay B qua cổng mở. |

Không UI nào gọi full-route là “đúng hơn” hoặc phạt rút sớm/bỏ cargo. S4/S5 chỉ là đường đề xuất để dạy combat và lựa chọn ba lô.

## 6. O3/O4: grid, Hộp và các action an toàn

### O3: grid ba lô `proposed`

Chạm chọn item rồi chạm ô đích là thao tác đầy đủ; drag-drop chỉ là shortcut. Preview dùng footprint/hình dạng + text (`vừa`, `không vừa`, `sai loại`) ngoài màu.

| Action player | Validation/feedback | Kết quả |
|---|---|---|
| Đặt/di chuyển item | Footprint nằm trọn ô trống hợp lệ. | Chạm ô hợp lệ commit placement; preview cho thấy kết quả trước chạm. Nếu fail, item ở chỗ cũ. |
| Xoay item | Item có quyền xoay và hình sau xoay vừa hoàn toàn. | Preview, rồi commit/hủy; không xoay ngầm item khác. |
| So sánh cargo 2x2 với dấu/loot gọn | Card hiện footprint, tổng/ô và công dụng; người chơi tự chọn giữ, bỏ hoặc hủy. | Không chấm “build tốt nhất”, không thêm weight/slow penalty. |
| Bỏ item đang mang | Hiện tên/món cụ thể và confirmation ngắn trước khi nó trở về ground. | O5 → state in-run; không có `bỏ tất cả`. |
| Đóng/hủy | Placement chưa commit không thay đổi. | ↩ state in-run. |

O3 không tự dọn/sort, tự bỏ, tự chuyển sang Hộp hay tự đổi gear. Nếu inventory mở khi hazard/telegraph vào vùng gần, cảnh báo vẫn còn nhìn được; người chơi có thể đóng O3 ngay để phản ứng.

### O4: Hộp Công Chứng `proposed`

Hộp slice là `2x2`; item mới chỉ vào khi có nhãn `Niêm phong được` và footprint nằm trọn. Gear, weapon, cargo, container và túi/ba lô không có affordance niêm phong trong run.

| Action player | Validation/feedback | Kết quả |
|---|---|---|
| Niêm item đủ điều kiện từ ba lô | Nhãn niêm, ô trống và footprint hợp lệ; preview nêu item/đích. | Commit placement; item đổi nhãn `đã niêm`. Với evidence: đồng thời `chưa extract`. |
| Niêm khi Hộp đầy/không vừa/sai loại | Nêu chính xác lý do; không đẩy thuốc/item cũ ra ba lô/ground. | Giữ O4 và item nguồn. |
| Rút item từ Hộp trong run | Ba lô có placement hợp lệ; preview nêu đích. | Rút sau action/confirmation phù hợp; nếu không vừa, item ở Hộp. |
| Nhường chỗ | Player tự rút món cũ tới đích hợp lệ trước, sau đó niêm món mới. | Không auto-swap/auto-drop. |
| Đóng/hủy | Hành động chưa commit không đổi state. | ↩ state in-run. |

Đưa Manifest vào Hộp **không** mở extract completion. Nếu player chết trước extract, Manifest trở thành `unrecovered`; chỉ item niêm **không-phải-evidence** trở về hub. Do đó O4 luôn kèm trạng thái evidence/safebox bằng icon/shape/text tách bạch.

### O5: confirmation ngắn `proposed`

O5 là pattern overlay dùng lại, không phải một action hoặc rule mới. Nó chỉ xuất hiện khi action có hậu quả khó đảo ngay; nội dung nêu **đúng món/state bị ảnh hưởng**, hậu quả và hai action `xác nhận` / `hủy`.

| Nguồn action | Khi nào mở O5 | Xác nhận / hủy |
|---|---|---|
| O3 bỏ item | Player chọn bỏ một item đã mang. | Xác nhận: món hiện lại trên ground; hủy: O3 giữ nguyên. |
| O4 rút món niêm | Item có placement ba lô hợp lệ và player đã chọn rút. | Xác nhận: món vào ô preview; hủy: món vẫn trong Hộp. |
| O1 vào không vũ khí / thay tổ hợp gear phá placement cũ | Chỉ khi action đang được slice cho phép và preview cho thấy rủi ro. | Xác nhận sau khi toàn bộ món có đích hợp lệ; hủy: O1 giữ nguyên. |
| E1 gọi thuyền | Luôn trước khi bắt đầu call/hold pressure. | Xác nhận: S7; hủy: E1 callable. |

Placement/move/rotate preview, đóng overlay và inspect không gọi O5: chúng không được biến thành chuỗi confirmation gây cản trở mobile.

## 7. Gọi và giữ extract ở A

### S3/S4/S5 → S7: quay về beacon A

Sau Manifest, player có thể đi/đánh/né theo đường **S5 → S4 → S3 → S7** để trở về A. Beacon A có trạng thái tuần tự dưới đây; player không thắng chỉ vì đứng vào vòng beacon.

| State extract | Player action | Hệ thống cho thấy | Chuyển |
|---|---|---|---|
| **E0 — unavailable** | Chưa có Manifest. | Beacon/label nêu chưa đủ điều kiện. | Giữ state nguồn. |
| **E1 — callable** | Có Manifest, vào vùng A và chọn `Gọi thuyền`. | Beacon A, objective `extract A`, preview hậu quả ngắn và O5 xác nhận/hủy trước khi bắt đầu pressure. | Xác nhận → S7; hủy → E1. |
| **S7 — call accepted** | Player không cần làm action thứ hai để “được tính là đang gọi”. | Nêu state gọi đã nhận; giữ health/objective/lane alert trên HUD. | S8. |
| **S8 — hold area** | Player giữ khu/lựa chọn combat, cover, guard hoặc dash. | Nhịp giữ 15–25 giây đã công bố; lane địch từ B báo trước bằng đèn/âm thanh/telegraph. | Thuyền tới → S9; death → S11. |
| **S9 — boat ready** | Player tương tác lên thuyền. | Thuyền/đích interaction đọc được; không checkpoint giữa S8/S9. | S10. |

Không có D boat extract, E tax-gate extract, spawn sau lưng hay auto-completion trong wireflow slice.

## 8. Outcome: success, death và Recovery Contract

### S10: success summary/hub `proposed`

| Nhóm summary | Diễn giải đúng | Action tiếp theo |
|---|---|---|
| `Đã giữ` | Manifest đã extract nên Contract 1 success; loot hợp lệ từ ba lô/túi/Hộp về hub theo rule item. Evidence không bán/craft trong summary. | `Về hub`/đóng summary → S0. |
| `Đã mất` (nếu có) | Item player đã chủ động bỏ lại hoặc không mang tới extract không trở về hub; summary nêu cụ thể, không gọi đó là penalty vì không đi full-route. | Không có khôi phục tự động; player chỉ có thể xem hub/chuẩn bị run khác. |
| `Vật chứng` | Manifest là lead đã bàn giao; **không** là `Bộ Phản Niêm R-17` hay minh oan gia tộc. | Hub ghi `lead: Kho K-7`. |
| `Tiếp theo` | Contract 2 chỉ mở ở campaign state. | Card luôn ghi `chưa có trong vertical slice`, không có nút bắt đầu. |

Rút sớm và full-route đều đi S10. Full-route chỉ thay danh sách loot/ô đã dùng; không thưởng một branch, vendor, local story hay điểm “build tốt nhất”.

### S11: death summary

| Thời điểm death | `Đã giữ` / `Đã mất` / `Vật chứng` hiển thị | Action tiếp theo |
|---|---|---|
| Trước Manifest | Gear/loot không niêm mất; item niêm **không-phải-evidence** được giữ; Manifest ở bàn A; Contract 1 vẫn active. | `Chuẩn bị lại` → S1 starter/loadout. |
| Sau Manifest, kể cả đang trong Hộp | Unsealed gear/loot mất; niêm **không-phải-evidence** giữ; Manifest không về hub và nằm nhóm `Vật chứng — unrecovered`. | `Xem Recovery Contract` → S12. |
| Trong S8/S9 | Cùng rule death sau Manifest; call/hold không hoàn tất. | `Xem Recovery Contract` → S12. |

Death summary không dùng cùng signal với success/extract. Nó không tự gọi lại thuyền, restore đồ đã bỏ/mất ngoài Hộp hay ngầm hoàn thành Contract 1.

### S12: Recovery Contract → S1 recovery → S2

S12 nói rõ Manifest `unrecovered` và điểm logic hiện tại: **bàn dispatch A**. Player mở recovery briefing/loadout, có starter/recovery kit cơ bản và một lựa chọn loadout hợp lệ không cần mua lại gear. Sau validation, ở S2 player phải **tự thu hồi** Manifest tại bàn rồi placement hợp lệ; chỉ khi đó E0 mới thành E1 callable. E1 không là success: campaign chỉ complete sau A call/hold/board vào S10. Cùng fixture với pickup ban đầu không biến recovery thành respawn/checkpoint: chỉ state `unrecovered` mới mở action thu hồi này.

## 9. Quy tắc mobile, accessibility và confirmation

| Tình huống | Yêu cầu `proposed` |
|---|---|
| Tín hiệu state | Objective/extract, rarity, claim, footprint, hazard/telegraph, evidence/Hộp/death dùng tối thiểu một kênh ngoài màu: shape, icon, pattern, text, vị trí, motion hoặc audio. Một kênh mất vẫn không làm state vô nghĩa. |
| Overlay & combat | O2/O3/O4 không che hoàn toàn health, objective ngắn hay telegraph. Prompt mới chỉ tới khi prompt cũ hoàn thành/bị bỏ rõ/rời vùng; không freeze player giữa đòn. |
| Tác vụ cơ bản | Tap-select + tap-target đủ cho nhặt/đặt/xoay/niêm; drag chỉ là shortcut. Dismiss/close/cancel dùng một action rõ ràng. |
| Xác nhận | Chỉ yêu cầu confirmation cho action phá run/khó đảo ngay: bỏ item, rút đồ niêm, destructive gear swap, vào không vũ khí, gọi extract nếu không thể hoàn tác. Di chuyển/rotate/đặt preview chưa commit có thể hủy. |
| Giảm quá tải | Lore dài ở inspect/Archive hub; run chỉ giữ một mục tiêu/action ngắn. Vùng yên B là thời điểm UI có thể mời người chơi xem grid, không ép mở trong combat. |

## 10. Checklist handoff trước implementation/prototype

1. Mỗi state S0–S12/O1–O5 có action vào, validation, exit hoặc cancel rõ chưa?
2. A-only early extract, full-route tùy chọn, C/E silhouette và D không-extract có còn đúng ở mọi branch không?
3. Có action nào tự drop/swap/seal/complete hoặc làm player mất item mà không có preview/confirmation không?
4. Manifest niêm có luôn là `chưa extract`, death sau Manifest có luôn `unrecovered`, còn non-evidence sealed có luôn được tách khỏi evidence không?
5. Call → hold → boat ready → board và success/death/recovery summary có phải các state khác nhau không?
6. Mỗi thông tin critical có một signal không chỉ màu và overlay có giữ ưu tiên telegraph/HUD không?
7. Có dòng nào vô tình chốt mockup, asset, input implementation, economy/stat, Contract/map hay lore mới không?
