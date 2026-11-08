# S05 — Test plan readiness Recovery Contract (G18, C0–C3)

**Trạng thái:** `proposed` · **Mục đích:** TASK-110 chạy tay build thật và kết luận `READY` / `NOT READY` / `BLOCKER` cho G18, C0–C3 và §8. Plan không thay test headless, không sửa luật, không là playtest first-time.

**Nguồn:** [Build-readiness](../vertical-slice-build-readiness.md) §§1, 6–10 · [Recovery Contract](../specs/recovery-contract-spec.md) RC-00…18 · [chuỗi chữ S05](../specs/contract-1-strings.md) · [brief C3](../maps/black-tax-port-recovery-c3-fixture-brief.md) · [plan A](loop-a-early-extract-test-plan.md) · [plan B](zone-b-combat-loot-test-plan.md) · [plan D/death](zone-d-notary-death-test-plan.md).

## 1. Kênh, thiết bị, kết luận

Chạy mỗi case dưới đây trên hai build staging thật. Trước khi chạy, ghi badge `staging` và version dạng `0.1.0-staging+<sha>`; hai bản phải cùng version mới được đối chiếu. Lệch version: `NOT READY` bản lệch và tải đúng artifact.

| Cột | Bản phải chạy | Ghi bắt buộc |
|---|---|---|
| **Web** | `web-staging` pre-release | URL, browser/version, input desktop/cảm ứng, độ phân giải, badge/version. |
| **APK** | APK debug-signed `android-staging` | Model, Android version, orientation/độ phân giải, badge/version. |

**Cài APK:** tải Android từ kênh `android-staging` trên itch.io; cho phép ứng dụng mở file cài nguồn không rõ; xác nhận cài. Nếu lỗi chữ ký, gỡ **bản staging cũ** rồi cài lại. Đây không phải Google Play và dùng save namespace staging riêng.

`C1`–`C3` chỉ dùng menu fixture ở **staging** (debug menu bật), không chạy production. `C0` không được mở menu fixture, không route hint, không thao tác thay người chơi. Kiểm production tách riêng: menu/shortcut/node action/key path C1–C3 phải vắng (`RC-17`).

Một state/evidence chưa tự tạo được là `NOT READY`; outcome thật trái luật là `BLOCKER`. Với BLOCKER, dừng coverage ảnh hưởng, tái hiện đúng một lần trên cùng build, điền §6. Không thay fixture thiếu bằng lời kể, ảnh, summary giả, teleport hay checkpoint.

## 2. G18 — case Recovery Contract

| ID / loại | Tiền điều kiện | Bước cảm ứng | Expected trên màn | Sai là | RC / tự động? | Web | APK |
|---|---|---|---|---|---|---|---|
| TC-RC-01 / thường | C3: death thật sau Manifest; có non-evidence niêm và gear/loot không niêm. | S11 chạm `Xem Recovery Contract`; S12 chạm `Chuẩn bị recovery`. | S11 tách `Đã giữ` / `Đã mất` / `Vật chứng — chưa thu hồi`; S12 đúng 3 body lines, chỉ 1 action, vào S1 recovery chứ không S10. | BLOCKER: success, hub/Archive, không S12/S1. | RC-01…04; có+tay `test_recovery_end_to_end_follows_death_s12_briefing_dispatch_and_extract` | ☐ | ☐ |
| TC-RC-02 / thường | S1 recovery từ RC-01. | Xác nhận loadout → A; quan sát HUD, bàn A, beacon trước pickup. | Kit cơ bản; starter remedy niêm ở Hộp, sling remedy ở túi, ba lô chưa có Manifest; objective thu hồi, chỉ bàn dispatch A là source, beacon E0. | BLOCKER: mua đồ, source/checkpoint thứ hai, E1 trước placement. | RC-00,04; có+tay `test_recovery_initializer_rejects_invalid_inputs_and_exposes_only_unrecovered_tuple` | ☐ | ☐ |
| TC-RC-03 / biên | (a) run thường `NOT_TAKEN`; (b) recovery `UNRECOVERED`; (c) sau pickup `CARRYING`. | Mở card bàn ở từng state; sau pickup mở lại bàn. | Chỉ (b) hiện `Thu hồi Manifest`; (a) là nhặt thường; (c) không action/source thu hồi lần hai. | BLOCKER: recovery action run thường hoặc sau placement. | RC-00,07,08; có+tay `test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset` | ☐ | ☐ |
| TC-RC-04 / biên | Recovery S2; `UNRECOVERED`. | `Thu hồi Manifest` → chọn túi đeo chéo/ô chiếm → đóng → mở lại bàn. | Lý do hiện; Manifest còn bàn; `UNRECOVERED` và E0 không đổi; không auto-drop/swap/sort/seal. | BLOCKER: tự đặt/mất, state đổi hoặc E1. | RC-06,07; có+tay `test_recovery_end_to_end_follows_death_s12_briefing_dispatch_and_extract` | ☐ | ☐ |
| TC-RC-05 / thường | Như RC-04, có ô ba lô 1x1 trống. | Thu hồi → chạm ô ba lô hợp lệ. | Đúng một Manifest được đặt; bàn hết source; E0 → E1, trong beacon có `Gọi thuyền`; không Archive/completion. | BLOCKER: E1 trước placement, duplicate, auto-complete. | RC-05,08; có+tay `test_recovery_end_to_end_follows_death_s12_briefing_dispatch_and_extract` | ☐ | ☐ |
| TC-RC-06 / biên | Hộp đầy non-evidence niêm, ba lô còn (0,0). | Chụp Hộp; thu hồi vào ba lô (0,0); so trước/sau. | E1; toàn bộ item Hộp tại ô cũ, không tự rút/di chuyển/niêm. | BLOCKER: tự sửa Hộp hoặc không dùng được ba lô hợp lệ. | RC-05; có+tay `test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset` | ☐ | ☐ |
| TC-RC-07 / thường | Recovery `CARRYING`, trong beacon A. | `Gọi thuyền` → O5 confirm → giữ đến S9 → `Lên thuyền`. | O5 preview/hủy; thứ tự S7 → S8 → S9; chỉ board mới S10. E1/S9 đứng yên không tự thắng. | BLOCKER: E1/confirm/hold tự success, auto-board, thiếu O5. | RC-09; có+tay `test_recovery_end_to_end_follows_death_s12_briefing_dispatch_and_extract` | ☐ | ☐ |
| TC-RC-08 / thường | Recovery `CARRYING` sau placement hợp lệ, trong B hoặc D trước `Gọi thuyền`. | Dùng combat/death path thật để HP = 0; tại S11 chạm recovery → S12 → S1 → S2. | Death thứ hai vẫn là `after-Manifest`; không S10/checkpoint; S12 rồi run recovery mới E0 tại bàn A với đúng một Manifest chưa thu hồi và action thu hồi còn dùng được. | BLOCKER: success/checkpoint, duplicate/mất Manifest, không S12/S1/S2 hoặc soft-lock. | RC-10; có+tay `test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset` | ☐ | ☐ |
| TC-RC-09 / biên | Recovery `UNRECOVERED`, trước pickup. | Dùng combat/death path thật để HP = 0; S11 → recovery → S2. | S11 after-Manifest; sealed non-evidence giữ, unsealed sling/basic item mất; đúng một Manifest unrecovered; recovery còn chạy. | BLOCKER: mất context, success, soft-lock. | RC-10; có+tay `test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset` | ☐ | ☐ |
| TC-RC-10 / biên | Recovery `CARRYING`, lần lượt S7/S8/S9. | Chết thật trước board; vào recovery lần nữa. | Không S10; đúng một unrecovered Manifest, recovery action còn, run sau E0 tại bàn A. | BLOCKER: death thành success/checkpoint, Manifest mất/nhân đôi. | RC-11; có+tay `test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset` | ☐ | ☐ |
| TC-RC-11 / thường | C3 có cargo/gear không niêm trước death. | Death → S12 → S1/loadout; đối chiếu S11 với inventory recovery. | Chỉ non-evidence niêm giữ; ba lô không trả cargo/gear/đồ đã bỏ; kit cơ bản, không mua/hoàn đồ. | BLOCKER: đồ không niêm/đã bỏ quay lại. | RC-04,10,18; có+tay `test_recovery_end_to_end_follows_death_s12_briefing_dispatch_and_extract` | ☐ | ☐ |
| TC-RC-12 / biên | Recovery `CARRYING`, action drop Manifest hiện có. | Xác nhận bỏ → quan sát E0 → nhặt lại hợp lệ. | Drop = `DROPPED`/E0; nhặt legal = `CARRYING`/E1; bàn không thành source normal pickup. | BLOCKER: duplicate/auto-complete/sai source. | RC-12; có+tay `test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset` | ☐ | ☐ |
| TC-RC-13 / biên | Pending recovery trước S10. | Về Boot/đóng app; mở session mới và run thường. | Context recovery biến mất; run chuẩn `NOT_TAKEN`, Manifest bàn A; không soft-lock/save recovery. | BLOCKER: persistence hỏng run chuẩn. | RC-13; có+tay `test_recovery_flow_covers_full_inventory_cancel_drop_repeat_deaths_and_memory_reset` | ☐ | ☐ |
| TC-RC-14 / biên | C3 đã death thật, vào run recovery mới từ S12 → S1 → S2; tại S11 ghi **tên, footprint, container và anchor** của mọi cargo/gear/loot `Đã mất` hoặc đã bỏ trước death. | Không thu hồi Manifest trước. Mở toàn bộ inventory/ground/source; đi B rồi D bằng route thật, mở cache B và fixture/source D; đối chiếu với record trước death. | Trước khi nhặt source mới, inventory chỉ có retained/basic kit theo S11, không có cargo/gear/loot `Đã mất` hay đã bỏ. Cache B/D xuất hiện như source của run mới; chúng không tự đặt item vào inventory/ground. **UID không hiển thị trên staging và không có evidence UI/debug hợp lệ: mục identity UID của RC-18 phải ghi `NOT READY`, không suy diễn từ nhãn trùng.** | BLOCKER: một item `Đã mất`/đã bỏ xuất hiện lại trước khi player nhặt source mới, source tự cấp item, hoặc fixture/cache cũ dùng được. `NOT READY`: không thể chứng minh identity UID của RC-18. | RC-18; chỉ tay (hành vi nhìn thấy được) | ☐ | ☐ |

## 3. C0–C3 theo readiness §7

| Coverage | Entry / menu fixture | Chuỗi build thật | READY khi | Web | APK |
|---|---|---|---|---|---|
| C0 — natural run | Session mới, **không menu fixture**; facilitator không hint. | S1 → S2 → O2/Manifest → player tự chọn rút A, B/D rồi rút, hoặc death. | Route/outcome do player tự tạo; ghi action đầu tiên/outcome, không shortcut ép hướng. | ☐ | ☐ |
| C1 — early extract | Staging debug menu: **C1 — rút sớm**. | Sau Manifest → E1/O5 → S7 → S8 → S9 → S10. | Fixture chỉ vào state; tester tự O5/confirm/hold/board; không auto-complete/teleport. Regression: [TC-LA-C1M/C1T](loop-a-early-extract-test-plan.md#5-kịch-bản-c1-trọn-vòng-rút-sớm-trên-web-staging). | ☐ | ☐ |
| C2 — full-route optional | Staging debug menu: **C2 — full route** (hoặc save mới cho full sequence). | S1 → S2 → Manifest → B card → D cargo/Hộp → B → A → E1/O5 → S7/S8/S9 → S10. | Route C2 đầy đủ; C/E không mở input, D không extract; C0/C1 không bị ép route. | ☐ | ☐ |
| C3 — death → Recovery | Staging debug menu: **C3 — chết sau Manifest**; fixture có Manifest niêm + non-evidence niêm + loot/gear không niêm. | Death **thật** combat → S11 → S12 → S1 recovery → S2 bàn A → tự thu hồi/placement → E1 → call/hold/board → S10. | Không summary giả; ba nhóm đúng, E1 chưa success, đồ mất không trở lại. | ☐ | ☐ |

## 4. Invariant §8

`có+tay`: test headless có thật trong `game/tests/unit/test_readiness_contract.gd`, nhưng QA vẫn xem build. `chỉ tay`: không có test `test_readiness_inv_*` tương ứng.

| # | Tự động | Bước tay / evidence | Web | APK |
|---:|---|---|---|---|
| 1 | có+tay: `test_readiness_inv_1_route_stays_contract_1_easy_with_a_as_only_extract` | A/B/D playable, C/E silhouette không input; chỉ A extract; briefing Easy/Contract 1. | ☐ | ☐ |
| 2 | có+tay: `test_readiness_inv_2_flow_exposes_no_out_of_scope_completion_path` | Rà Boot/briefing/HUD/summary: không D boat/E gate, Contract 2/3 playable, Hard/Extreme, incident/boss/elite, shop/craft/economy/multiplayer. | ☐ | ☐ |
| 3 | có+tay: `test_readiness_inv_3_beacon_call_hold_and_board_are_distinct_states` | E0 trước/E1 sau placement; O5 confirm/cancel; hold và board khác state; không auto-win/checkpoint. | ☐ | ☐ |
| 4 | chỉ tay: không có `test_readiness_inv_4_*` | Card/lưới có footprint/claim/rarity/evidence cue ngoài màu; claim ≠ rarity; rarity không stat/giá/ô. | ☐ | ☐ |
| 5 | có+tay: `test_readiness_inv_5_invalid_placement_preserves_the_source_without_automation` | Đặt sai giữ item nguồn/nêu lý do; không auto-drop/swap/sort/seal/Archive, không bắt drag pixel-perfect. | ☐ | ☐ |
| 6 | có+tay: `test_readiness_inv_6_sealed_manifest_death_is_unrecovered_and_keeps_non_evidence` | C3: niêm vẫn chưa extract; death = unrecovered; sealed giữ/unsealed mất; recovery không restore/soft-lock. | ☐ | ☐ |
| 7 | chỉ tay: không có `test_readiness_inv_7_*` | O2/O3/O4 mở vẫn đọc HUD/objective/telegraph; lane báo trước, không spawn sau lưng/ngoài camera; overlay đóng/hủy. | ☐ | ☐ |
| 8 | có+tay: `test_readiness_inv_8_success_death_and_recovery_summaries_keep_their_separate_contract` | So success/death/recovery: kept/lost/evidence/next tách rõ; success chỉ lead Kho K-7, Contract 2 `chưa có trong vertical slice`. | ☐ | ☐ |

## 5. Regression S02–S04

| Scope | Nguồn case | Web | APK |
|---|---|---|---|
| S02 C1 rút sớm | [Plan A](loop-a-early-extract-test-plan.md): TC-LA-08, 12, 14, 18, 19, 22, 23, 26; C1-M/C1-T. | ☐ | ☐ |
| S03 full-route B | [Plan B](zone-b-combat-loot-test-plan.md): combat/card/loot B vẫn quay A extract được. | ☐ | ☐ |
| S04 G16/G17 | [Plan D/death](zone-d-notary-death-test-plan.md): death trước/sau Manifest, Hộp/summary/return route; không summary fixture giả. | ☐ | ☐ |

## 6. Phiếu kết quả trống — TASK-110 điền

**Web:** URL/pre-release: __________ · Browser/version: __________ · Input: __________ · Độ phân giải: __________ · Badge/version: __________

**APK:** Artifact/link: __________ · Model: __________ · Android: __________ · Orientation/độ phân giải: __________ · Badge/version: __________

| Nhóm | ID / gate / coverage / invariant | Web: kết quả | APK: kết quả | Bằng chứng: state → action → outcome, ảnh/video | Handoff readiness §9 / owner |
|---|---|---|---|---|---|
| G18 | TC-RC-01…14; identity UID RC-18 phải ghi `NOT READY` nếu build không có evidence UI/debug hợp lệ |  |  |  |  |
| Coverage | C0 |  |  |  |  |
| Coverage | C1 |  |  |  |  |
| Coverage | C2 |  |  |  |  |
| Coverage | C3 |  |  |  |  |
| Invariant | §8.1 |  |  |  |  |
| Invariant | §8.2 |  |  |  |  |
| Invariant | §8.3 |  |  |  |  |
| Invariant | §8.4 |  |  |  |  |
| Invariant | §8.5 |  |  |  |  |
| Invariant | §8.6 |  |  |  |  |
| Invariant | §8.7 |  |  |  |  |
| Invariant | §8.8 |  |  |  |  |
| Regression | S02 C1 / S03 B / S04 G16–G17 |  |  |  |  |

**Quyết định:** ☐ READY / GO cho first-time readability session · ☐ NOT READY · ☐ BLOCKER build/readiness · ☐ KHÔNG TEST ĐƯỢC · ☐ INVESTIGATE

```text
Build label (do not define tooling):
Classification: NOT READY (trước phiên) | KHÔNG TEST ĐƯỢC (trong phiên) | BLOCKER build/readiness | INVESTIGATE
Trigger timing: trước phiên / trong phiên
Gate/state/coverage duy nhất:
Expected invariant/source rule:
Observed state → action → outcome, hoặc fixture/state thiếu:
Reproduction (bắt buộc nếu BLOCKER): cùng state → action → outcome, một lần cùng build
Điều phải tạo hoặc quan sát lại nếu fixture/readiness:
Readiness hiện tại và coverage cần trả về NOT READY (nếu có):
Allowed files/sections:
Out of scope: claim repair, lore, map, economy và acceptance readability của người chơi first-time
Discipline owner:
Follow-up Task Card: một hypothesis state/readiness; đúng một invariant/gate/coverage và allowed file/scope hẹp
```

`READY` chỉ khi mọi hàng bắt buộc có outcome quan sát được đúng nguồn. `GO` chỉ mở first-time readability session, không xác nhận balance, performance, accessibility hay release-ready.
