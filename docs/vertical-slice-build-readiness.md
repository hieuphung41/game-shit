# Build-readiness — Vertical slice “Giữ giấy phép”

**Trạng thái:** checklist readiness `proposed`, trước playtest lần đầu. Nó kiểm chứng **sự tồn tại và hành vi quan sát được** của fixture/state đã chốt; không chọn công nghệ, cách build, cách test tự động hay mức cân bằng.

**Nguồn ràng buộc:** [vertical slice](vertical-slice.md), [wireflow UX](vertical-slice-wireflow.md), [kế hoạch playtest](playtest-readability-plan.md), [inventory và loadout](systems/inventory-and-loadout.md), [art/presentation direction](art-direction.md). Tài liệu nguồn ưu tiên nếu checklist này khác luật game.

## 1. Điều kiện dùng checklist

Chỉ đánh dấu `READY` khi người kiểm tra có thể tự tạo state trong build và **nhìn thấy outcome đúng**. Không dùng mock text, giải thích miệng, ảnh mockup, trạng thái debug không theo flow hoặc “sẽ làm sau” làm evidence. Nếu một fixture chưa tạo được mà không phá luật slice, đánh dấu `NOT READY`; nếu build tạo outcome trái luật, đánh dấu `BLOCKER`.

| Trạng thái | Nghĩa | Có được mời first-time player? |
|---|---|---|
| `READY` | Fixture/state và outcome quan sát được, đúng nguồn. | Có, nếu mọi gate bắt buộc khác cũng READY. |
| `NOT READY` | Chưa tạo/không tới được state hoặc evidence chưa đủ. | Không, nếu là gate bắt buộc/C0–C3. |
| `BLOCKER` | State có nhưng phá luật campaign, mất đồ, recovery, route hoặc fairness. | Không; dừng gate và mở task sửa hẹp. |
| `OUT OF SCOPE` | Nội dung không thuộc slice và không được đưa vào để lấp chỗ trống. | Không ảnh hưởng nếu thật sự không có affordance/input. |

**No-go bắt buộc:** không mời first-time player nếu một state trong §3–§6, một bước C0–C3 trong §7, hoặc một invariant §8 là `NOT READY`/`BLOCKER`. Không thay fixture thiếu bằng prompt mới, narrator, item/map/contract mới hay explanation của facilitator.

## 2. Phạm vi readiness khóa trước playtest

| Có để kiểm tra | Phải vắng hoặc chỉ là background |
|---|---|
| Easy cố định; Contract 1; A/B/D; starter/recovery kit; ba lô `3x4 proposed`; Hộp `2x2`; loot 1x1/1x2/2x2; A call/hold/board; success/death/recovery summaries | C/E input/objective/loot; D thuyền; E cổng; Contract 2/3 playable; Hard/Extreme; incident/boss/elite; shop/craft/economy; multiplayer/live-service |

**Ký hiệu:** `S#`, `O#`, `E#` trỏ tới [wireflow](vertical-slice-wireflow.md); `C#` trỏ tới [coverage playtest](playtest-readability-plan.md). “Discipline owner” là loại thiết kế sẽ nhận task tiếp theo, không phải người hay team thực hiện.

## 3. Gate entry, A và Manifest

| Gate / state | Evidence `READY` quan sát được | Discipline owner nếu fail | `BLOCKER` nếu thấy | Không được thay bằng |
|---|---|---|---|---|
| **G1 — S0 → S1 briefing** | Một màn nêu Contract 1, Manifest tại A, extract A, Easy và rủi ro đồ không niêm; không cần đọc lore dài. | Slice flow + contract wording | Briefing gọi Manifest là bằng chứng cuối, nói seal = completion, hoặc hứa Contract 2 playable. | Cutscene/popup lore dài. |
| **G2 — O1/S1 loadout** | Starter kit, ba lô 3x4, túi quick-access và Hộp 2x2 có mặt; validation chỉ nêu lý do và giữ đồ khi sai; hủy không đổi đồ. `Vào cảng` chỉ sáng khi placement hợp lệ. | Inventory UX | Auto-buy/fill/drop/swap; level/gear-score gate; vào run với placement sai. | Shop, preset mới hoặc rule loadout mới. |
| **G3 — S2 A spawn** | Cùng góc camera thấy đèn phao/beacon A, dispatch Manifest, lối B; A không combat ép buộc; C/E là silhouette không input/marker. | Map readability + presentation | C/E nhận input/objective/loot; player không thể nhận ra dispatch/beacon A do che khuất. | Mở C/E hoặc thêm route. |
| **G4 — O2 Manifest → S3** | Card `Manifest Hàng Hóa R-17` cho 1x1, `chưa xác thực`, extract A; chỉ nhặt sau placement hợp lệ. Sau đó state `đang mang`, beacon A `callable`, B vẫn nhìn/đi được. | Inventory UX + objective/extract presentation | Manifest tự vào Archive/hub/Hộp; beacon callable trước Manifest; nhặt Manifest tự hoàn thành Contract. | Auto-seal, auto-placement hay narration giải thích outcome. |
| **G5 — S3 rút sớm** | Từ Manifest, player quay A, gọi/giữ/board và đạt success mà không tới B/D; không bị phạt, chấm thiếu route hay khóa summary. | Slice flow + extract presentation | Rút sớm bị xem abandon/fail hoặc beacon auto-win. | Ép player đi B/D hoặc thêm reward bắt buộc. |

## 4. Gate B/D, card, grid và Hộp

| Gate / state | Evidence `READY` quan sát được | Discipline owner nếu fail | `BLOCKER` nếu thấy | Không được thay bằng |
|---|---|---|---|---|
| **G6 — S4 B combat** | Vệ binh/đốc công tạo telegraph/lane/cover đọc được; combat prompt không che health/objective/telegraph; sau gate có vùng yên để mở card/grid. | Encounter + readability | Địch/spawn gây damage không báo trước/sau lưng; overlay biến telegraph vô hình. | Tăng/giảm stat, thêm enemy hay combat tutorial dài. |
| **G7 — O2 card loot B** | Có loot 1x1/1x2 và item claim; thứ tự card là silhouette/tên → footprint/ô trống → công dụng/giá → claim → rarity → lore. Claim/rarity/footprint có cue ngoài màu. | Item presentation + UI accessibility | Rarity biểu thị damage/giá trị-ô; claim lẫn rarity hoặc tự tịch thu. | Màu/glow duy nhất hay lore popup. |
| **G8 — O3 grid** | Chạm chọn + chạm ô đặt/di chuyển/rotate hợp lệ; item sai chỗ giữ nguyên và nêu lý do; đóng/hủy không đổi state. Có preview footprint 1x1/1x2/2x2. | Inventory UX | Auto-drop, auto-swap, auto-sort/seal; yêu cầu drag pixel-perfect; inventory che hết telegraph/health/objective. | Weight penalty, auto-management hoặc control scheme mới. |
| **G9 — S5 D cargo choice** | D có cargo 2x2, dấu/loot nhỏ 1x2 và lối D → B mở; card cho tổng/ô và công dụng; mang cargo, lấy đồ gọn hay bỏ đều đưa được về B. D không có extract. | Map route + inventory/item presentation | Cargo nén 1 ô; action ép chọn “tối ưu”; D thuyền/extract usable. | D extract, speed/weight rule hay Local Story. |
| **G10 — O4 Hộp Công Chứng** | Hộp 2x2 chỉ nhận item niêm/footprint hợp lệ; Hộp đầy/sai loại giữ item nguồn; nhường chỗ yêu cầu player tự rút tới đích hợp lệ. Manifest niêm có label `đã niêm — chưa extract`. | Inventory/recovery UX | Auto-swap/drop; gear/cargo/container niêm được; seal tạo success/delivery. | Bảo hiểm toàn bộ loadout hoặc extra slot. |
| **G11 — O5 action nguy cơ** | Bỏ item, rút đồ niêm, destructive gear swap/vào không vũ khí nếu có và `Gọi thuyền` đều cho preview + xác nhận/hủy. Move/rotate/inspect/close không có confirmation thừa. | Mobile interaction UX | Action phá run một chạm; gọi thuyền bắt đầu pressure không confirmation; confirmation không có cancel. | Popup cho mọi action hoặc rollback rule mới. |

## 5. Gate quay A, extract và success

| Gate / state | Evidence `READY` quan sát được | Discipline owner nếu fail | `BLOCKER` nếu thấy | Không được thay bằng |
|---|---|---|---|---|
| **G12 — S4/S5 → S3 quay A** | Từ D, cổng quay B mở; B → A dùng landmark ngược chiều; patrol/lane báo trước và không có surprise spawn sau lưng. | Map readability + encounter | Dead-end bắt buộc chết; player bị mất route A do marker/foreground; enemy spawn surprise. | D extract hoặc teleport/checkpoint. |
| **G13 — E1/S7 gọi extract** | A là điểm duy nhất callable sau Manifest; `Gọi thuyền` mở O5 preview/confirm, hủy giữ E1; xác nhận mới vào S7. | Extract presentation + mobile interaction | Auto-win khi đứng beacon; call không confirm; D/E callable. | Thêm extract point hoặc auto-call. |
| **G14 — S8/S9 hold/board** | Hold 15–25 giây đã công bố; địch từ lane B có light/audio/telegraph; thuyền tới rồi player tương tác board; death trong hold/ready đi S11, không checkpoint. | Encounter + extract presentation | Spawn sau lưng/ngoài camera; board tự win; death vẫn success/checkpoint. | Rút thời gian để bỏ fairness hoặc checkpoint giữa hold. |
| **G15 — S10 success summary** | Tách `Đã giữ`, `Đã mất` nếu có, `Vật chứng`, `Tiếp theo`; Manifest extract = giữ giấy phép/lead Kho K-7, không bán/craft/minh oan; Contract 2 state-only, nhãn chưa playable/no start. | Summary + narrative delivery | Manifest thành `Bộ Phản Niêm`, Contract 2 vào được, đồ đã bỏ tự hồi, full-route được chấm cao hơn rút sớm. | Vendor/craft/branch/economy feature. |

## 6. Gate death và recovery

| Gate / state | Evidence `READY` quan sát được | Discipline owner nếu fail | `BLOCKER` nếu thấy | Không được thay bằng |
|---|---|---|---|---|
| **G16 — S11 trước Manifest** | Death đưa về summary; Manifest vẫn tại A; Contract 1 active; unsealed gear/loot mất và sealed non-evidence được tách rõ là giữ. | Recovery UX + summary | Manifest biến mất/mở completion; sealed non-evidence bị mô tả mất. | Free completion/gear restoration. |
| **G17 — S11 sau Manifest** | Fixture trước death có **Manifest trong Hộp + một sealed non-evidence + ít nhất một gear/loot không niêm**. Summary tách đúng ba nhóm: đồ niêm thường `đã giữ`, gear/loot không niêm `đã mất`, Manifest `Vật chứng — unrecovered`; không complete. | Recovery UX + contract wording | Manifest về hub/Archive, thành success, toàn bộ Hộp về cùng Manifest, hoặc không có item không-niêm để chứng minh `Đã mất`. | Narrator tự giải thích khác outcome. |
| **G18 — S12 recovery** | `Xem Recovery Contract` → recovery briefing/loadout với kit cơ bản → **bàn dispatch A**: player tự thu hồi Manifest `unrecovered` rồi placement hợp lệ; chỉ sau đó E0 → E1 callable. E1 chưa là success: vẫn phải A call/hold/board. Không hồi gear đã tự bỏ/mất ngoài Hộp. Cùng fixture pickup không là respawn/checkpoint; action thu hồi chỉ có sau `unrecovered`. | Recovery flow + map readability | Không vào được recovery; recovery auto-complete; player phải mua gear để tiếp tục. | New checkpoint, item hay map. |

## 7. Route readiness cho C0–C3

Mỗi coverage chỉ `READY` khi mọi step trong hàng đã chạy bằng build thật, theo thứ tự, không facilitator route hint. C0 là bằng chứng hành vi tự nhiên; C1–C3 là coverage state có kiểm soát theo [protocol](playtest-readability-plan.md), không biến thành “đáp án” cho player.

| Coverage | Chuỗi readiness tối thiểu | Gate phải READY trước khi chạy | Nếu không thể chạy đúng sequence |
|---|---|---|---|
| **C0 — natural run** | S1 → S2 → O2/Manifest → kết quả player tự chọn: rút A, B/D rồi rút, hoặc death. | G1–G4 + ít nhất outcome hợp lệ (G5/G15 hoặc G16/G17). | `NOT READY`; không chỉ đường để ép một outcome. |
| **C1 — early extract** | State hợp lệ sau Manifest → E1/O5 → S7 → S8 → S9 → S10. | G1–G5, G11, G13–G15. | `NOT READY`; không auto-complete/teleport thuyền. |
| **C2 — full-route optional** | Save mới → S1 → S2 → Manifest → S4/B card → S5/D cargo/Hộp → S4 → S3 → E1/O5 → S7/S8/S9 → S10. | G1–G4, G6–G15. | `NOT READY`; không mở C/E, D extract hay bắt player làm route. |
| **C3 — death → Recovery** | State hợp lệ: Manifest đã niêm + sealed non-evidence + ít nhất một gear/loot không niêm → death thật → S11 ba nhóm giữ/mất/unrecovered → S12 → S1 recovery → S2 **bàn dispatch A: tự thu hồi → placement hợp lệ → E1**; sau đó vẫn A call/hold/board mới S10. | G1–G4, G10, G16–G18. | `NOT READY`; không thay bằng summary giả, lời kể hay tự trả Manifest về hub. |

## 8. Invariant sweep trước go/no-go

Đánh dấu từng dòng `READY`; một dòng sai là `BLOCKER`, một dòng chưa chứng minh được là `NOT READY`.

1. Easy cố định; Contract 1; A/B/D playable; A là extract duy nhất; C/E chỉ background không input.
2. Không có thuyền D/cổng E, Contract 2/3 playable, Hard/Extreme, incident/boss/elite, shop/craft/economy hoặc multiplayer trong flow test.
3. Beacon A: trước Manifest `unavailable`; sau placement hợp lệ `callable`; gọi có preview/xác nhận; hold/board khác state; không auto-win/checkpoint.
4. Card/lưới dùng footprint/claim/rarity/evidence signal ngoài màu; claim khác rarity, rarity không là stat hay giá/ô.
5. Không auto-drop/swap/sort/seal/Archive, không drag pixel-perfect bắt buộc; invalid placement giữ item nguồn và nêu lý do.
6. Manifest niêm vẫn `chưa extract`; death sau Manifest là `unrecovered`; non-evidence sealed được giữ; unsealed gear/loot mất; recovery không soft-lock/không hồi đồ đã mất.
7. HUD/telegraph/objective còn đọc được khi O2/O3/O4 mở; enemy lane có báo trước, không spawn sau lưng/ngoài camera; overlay đóng/hủy được.
8. Success/death/recovery summaries tách rõ kept/lost/evidence/next action; success chỉ lead Kho K-7 và Contract 2 `chưa có trong vertical slice`.

## 9. Triage và handoff

| Finding | Kết quả readiness | Handoff bắt buộc |
|---|---|---|
| Trước phiên, một gate không tới được hoặc fixture thiếu | `NOT READY` | Không mời first-time player vào coverage bị ảnh hưởng. Ghi gate/state/coverage thiếu và mở **một** Task Card fixture/readiness hẹp để tạo state quan sát được. |
| Trong phiên mới phát hiện gate/fixture không có hoặc không tới được đúng flow | `KHÔNG TEST ĐƯỢC`; coverage bị ảnh hưởng trở về `NOT READY` | Ghi state/gate thiếu, không mô tả outcome bằng lời và mở **một** Task Card fixture/readiness hẹp. Đây không là repair claim hay lỗi design đã xác nhận. |
| Outcome **thật của build** trái invariant: seal **tạo completion**, mất đồ không cảnh báo, recovery soft-lock/không tồn tại, C/E nhận input, hoặc D/E là extract | `BLOCKER` build/readiness | Dừng phiên, không mời tester tiếp và tái hiện cùng state → action → outcome một lần trên cùng build. Mở ngay **một** Task Card state/readiness cho đúng một invariant, gate hoặc coverage; không chờ synthesis. Player hiểu sai khi build đang đúng state là candidate semantic/readability, không phải row này. |
| Readability/control không chắc nguyên nhân | `NOT READY` hoặc `INVESTIGATE` sau khi build đủ fixture | Vào C0–C3 và playtest protocol; không sửa balance/lore/map trước evidence. |
| Mọi gate/coverage/invariant READY | `GO` cho **first-time readability session**, không phải tuyên bố slice cân bằng, stable, accessible-certified hay release-ready. | Chạy C0 trước, rồi C1–C3 theo protocol. |

Handoff record `proposed`:

```text
Build label (do not define tooling):
Classification: NOT READY (trước phiên) | KHÔNG TEST ĐƯỢC (trong phiên) | BLOCKER build/readiness | INVESTIGATE
Trigger timing: trước phiên / trong phiên
Gate/state/coverage duy nhất:
Expected invariant/source rule:
Observed state → action → outcome, hoặc fixture/state thiếu:
Reproduction (bắt buộc nếu BLOCKER): cùng state → action → outcome, một lần cùng build
Điều phải tạo hoặc quan sát lại nếu fixture/readiness:
Readiness hiện tại và coverage cần trả về `NOT READY` (nếu có):
Allowed files/sections:
Out of scope: claim repair, lore, map, economy và acceptance readability của người chơi first-time
Discipline owner:
Follow-up Task Card: một hypothesis state/readiness; đúng một invariant/gate/coverage và allowed file/scope hẹp
```

Handoff này chỉ xác nhận build/fixture cần sửa hoặc kiểm tra lại. Nó không được dùng làm repair Task Card semantic/readability; nhánh đó phải đi qua evidence gate của [kế hoạch playtest](playtest-readability-plan.md) §5 và [mẫu tổng hợp](playtest-synthesis-template.md) §§8–9.

## 10. Checklist đóng gate

1. G1–G18 có evidence build thật và không có `NOT READY`/`BLOCKER`?
2. C0–C3 chạy đúng sequence; C0 không bị facilitator dạy route?
3. Tám invariant ở §8 đã được nhìn thấy hoặc xác nhận theo fixture hợp lệ?
4. Mọi ghi chú failure có state/action/outcome và discipline owner, thay vì giải pháp ngoài scope?
5. Nhóm có hiểu `GO` chỉ cho phiên readability đầu tiên, không phải pass về balance/performance/accessibility/release?
