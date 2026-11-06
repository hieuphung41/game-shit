# Spec kỹ thuật — State machine beacon và extract Cầu tàu A (vertical slice)

**Trạng thái:** spec `proposed` cho gameplay-engineer (logic beacon/contract/extract), ui-programmer (HUD, O5, S10),
ux-designer (bố cục) và qa-planner (test). Mọi hằng số, tên enum/signal/method và key `KEY_MỚI?` đều `proposed`.
Spec này **không** đổi luật hay flow; nó chỉ đóng gói luật đã có thành state machine code được.

**Nguồn luật (ưu tiên khi spec này khác):** [Vertical slice](../vertical-slice.md) Beat 2/6/7/8, §4, §5 ·
[Wireflow](../vertical-slice-wireflow.md) §5, §6 O5, §7, §8 S10 · [Build-readiness](../vertical-slice-build-readiness.md)
G4, G5, G11, G13–G15, invariant §8.3 · [Extract brief Cầu tàu A](../maps/black-tax-port-a-extract-brief.md) ·
[State contract bàn dispatch A](../maps/black-tax-port-dispatch-state-contract.md) ·
[Spec lưới ba lô/Hộp](inventory-grid-slice-spec.md) §5.9, §6.3, §9 · [Chuỗi Contract 1](contract-1-strings.md) và
[`strings.csv`](../../game/i18n/strings.csv).

Đối chiếu canon: vertical slice và wireflow thống nhất — beacon chỉ thành E1 sau placement Manifest hợp lệ (ba lô
hoặc Hộp), còn nút `Gọi thuyền` chỉ dùng được khi player ở vùng A. Không có mâu thuẫn cần quyết định.

## 1. Mục đích (người chơi thấy gì)

Người Thu Hồi (`retriever`) lấy `Manifest Hàng Hóa R-17` (`manifest_r17`) ở bàn dispatch A, rồi phải **tự** quay về
đèn phao/beacon Cầu tàu A (`extract_pier_a`), chủ động `Gọi thuyền`, xác nhận, **giữ khu** đủ thời gian đã công bố, rồi
**tự** `Lên thuyền`. Chỉ thao tác lên thuyền mới hoàn thành Contract 1 (`contract_keep_licence`) và mở màn tổng kết S10.
Đứng trong vòng beacon, niêm Manifest vào Hộp Công Chứng (`notary_box`) hay chờ thuyền đều **không** tự thắng.
Rút sớm ngay sau Manifest và quay về sau full-route đi đúng cùng một flow và cùng một màn S10.

## 2. Khái niệm mới và code identifier `proposed`

| Khái niệm (VI) | code | Nghĩa |
|---|---|---|
| Luồng extract Cầu tàu A | `ExtractPierAFlow` | Logic thuần (không phụ thuộc scene) giữ ba state machine §4–§6; test headless được. |
| State beacon/extract | `ExtractState` | E0, E1, S7, S8, S9, S10 và kết thúc do chết. |
| State contract | `ContractState` | `chưa nhận` / `đang mang` / `đã bỏ lại` / `đã extract` / `chưa thu hồi`. |
| State bàn dispatch | `DeskState` | Bàn còn Manifest hoặc trống. |
| Vùng beacon A | `beacon_zone_a` | Vùng quanh `BeaconA`; dùng để gọi thuyền (E1) và giữ khu (S8). |
| Vùng lên thuyền | `board_zone_a` | Vùng cạnh chỗ thuyền cập ở `ExtractPierA`; dùng ở S9. |
| Hộp thoại xác nhận gọi thuyền | `call_confirm` | Phiên bản O5 cho action `Gọi thuyền`. |
| Đếm giờ giữ khu | `hold_remaining` | Số giây còn lại của S8; chỉ giảm khi đủ điều kiện §6. |
| Tạm dừng giữ khu | `hold_paused` | S8 đang đứng yên đồng hồ vì player ra khỏi vùng hoặc không còn mang Manifest. |
| Tổng kết extract | `ExtractSummary` | Dữ liệu tối thiểu đưa sang S10 (§10.4). |
| Hồ sơ không địch | `s02_no_enemy_profile` | Cấu hình sprint S02: S8 chỉ đếm giờ (§8). |

`BeaconA`, `DispatchDesk`, `ExtractPierA` là tên node đã có trong `game/src/world/zone_a_outer_pier.tscn`;
`BeaconZoneA` và `BoardZoneA` (Area3D) là node mới `proposed`.

## 3. Hằng số `proposed`

| Hằng số | Giá trị | Miền cho phép | Lý do |
|---|---:|---|---|
| `EXTRACT_HOLD_SECONDS` | **20.0** `proposed` | cố định, trong 15–25 (vertical slice Beat 7, G14) | Giữa khoảng đã công bố; đủ để một đợt lane B (S03) đến và được phản ứng, không kéo dài khi S02 chưa có địch. Điền vào `{seconds}` của `EXTRACT_CONFIRM_BODY` và là giá trị đầu của `EXTRACT_S8_HOLD_TIMER`. |
| `EXTRACT_CALL_ACK_SECONDS` | 1.5 `proposed` | 0.5–3.0 | Thời gian S7 hiện `EXTRACT_S7_CALL_ACCEPTED` trước khi vào S8; đồng hồ giữ khu chưa chạy trong S7. |
| `MAX_TICK_DELTA` | 0.25 `proposed` | 0.05–0.5 | Kẹp `delta` mỗi lần `tick` để app bị nền/giật khung không tự hoàn tất S8 (§11.6). |
| `BEACON_ZONE_RADIUS_M` | 3.0 `proposed` | do level-designer chốt | Bán kính `BeaconZoneA` trên mặt sàn A; phải nhìn thấy cover gần A và miệng lane B từ trong vùng. |
| `BOARD_ZONE_RADIUS_M` | 1.5 `proposed` | do level-designer chốt | Bán kính `BoardZoneA` cạnh chỗ thuyền cập. |
| `MANIFEST_DEF_ID` | `&"manifest_r17"` | cố định | Theo inventory spec §8.3. |

Không có hằng số nào cho damage, HP, số địch, thời điểm spawn hay timeout thuyền: các giá trị đó ngoài spec này.

## 4. Quy tắc

### 4.1 Bàn dispatch và contract

1. Đầu run Contract 1 thường: `desk_state = HAS_MANIFEST`, `contract_state = NOT_TAKEN`, `extract_state = E0_UNAVAILABLE`.
2. Tương tác `DispatchDesk` khi `desk_state = HAS_MANIFEST` mở O2 card Manifest. Mở/đóng O2, inspect, preview, placement
   fail hay hủy **không** đổi ba state.
3. Nguồn sự thật duy nhất cho việc mang Manifest là signal `evidence_carried_changed(def_id, carried)` của
   `RetrieverInventory` (inventory spec §5.9.5). Flow bỏ qua mọi `def_id` khác `manifest_r17`.
4. `evidence_carried_changed(manifest_r17, true)` lần đầu (pickup vào ba lô **hoặc** Hộp, commit `ok`):
   `desk_state → EMPTY`, `contract_state → CARRYING`, `manifest_carried = true`. Bàn không bao giờ quay lại `HAS_MANIFEST`
   trong cùng run.
5. Di chuyển Manifest ba lô ↔ Hộp hoặc trong cùng lưới không phát signal nên không đổi state. Niêm Manifest chỉ đổi
   nhãn thành `đã niêm — chưa extract`; không phải completion.
6. `evidence_carried_changed(manifest_r17, false)` (bỏ Manifest xuống đất qua O5 — chỉ có từ S04):
   `contract_state → DROPPED`, `manifest_carried = false`. Nhặt lại (`true`) → `CARRYING`. Manifest trên đất **không**
   tự về bàn.
7. `contract_state → EXTRACTED` chỉ xảy ra trong `board()` thành công (§4.4).
8. Death sau khi đã nhặt Manifest → `UNRECOVERED` là **ranh giới**; xử lý S11/S12 ngoài spec này (§9).

### 4.2 Beacon E0 / E1

1. `extract_state` ở E0 hoặc E1 được suy ra từ contract: `E1_CALLABLE` ⇔ `contract_state == CARRYING`
   (tức Manifest có placement hợp lệ trong ba lô hoặc Hộp); ngược lại `E0_UNAVAILABLE`.
2. **Guard gọi thuyền** `can_call()` = `extract_state == E1_CALLABLE` **và** `manifest_carried` **và** `in_beacon_zone`
   **và** `call_confirm_open == false`. Cả hai vế là bắt buộc: Manifest ở ba lô/Hộp nhưng ngoài vùng → không gọi được;
   trong vùng nhưng chưa mang Manifest → không gọi được.
3. Ở E0, `in_beacon_zone == true` **không** tạo extract, không mở O5, không hiện nút gọi; HUD chỉ nhắc điều kiện.
4. Chỉ `BeaconZoneA` đặt `in_beacon_zone`. B, D và silhouette C/E không có vùng, nút hay marker extract.
5. Beacon E1 vẫn hiện label `callable` khi player ở B/D (để thấy được lối rút), nhưng nút `Gọi thuyền` chỉ hiện khi
   `can_call()` đúng.

### 4.3 O5 gọi thuyền, S7, S8

1. `request_call()` khi `can_call()` đúng → `call_confirm_open = true`, phát `call_confirm_opened`. `extract_state` vẫn E1.
   O5 không dừng mô phỏng thế giới (không freeze, wireflow §9).
2. `cancel_call()` → đóng O5, giữ E1; không đổi inventory, contract hay route.
3. Trong lúc O5 mở, nếu `in_beacon_zone` thành `false` hoặc `manifest_carried` thành `false`, O5 tự đóng **như hủy**
   (prompt bị bỏ khi rời vùng, vertical slice §2.2). Không có action nào khác xảy ra.
4. `confirm_call()` kiểm lại guard (không tin trạng thái lúc mở O5). Đúng → đóng O5, `extract_state → S7_CALL_ACCEPTED`.
   Sai → đóng O5, giữ E1/E0, trả `false`.
5. S7 không cần action thứ hai. Sau `EXTRACT_CALL_ACK_SECONDS` (đếm bằng `tick`) → `S8_HOLD`,
   `hold_remaining = EXTRACT_HOLD_SECONDS`, phát `hold_started(EXTRACT_HOLD_SECONDS)`.
6. Trong S8, `tick(delta)` trừ `min(delta, MAX_TICK_DELTA)` khỏi `hold_remaining` **chỉ khi** `in_beacon_zone` và
   `manifest_carried`. Ngược lại `hold_paused = true` và đồng hồ đứng yên (§6).
7. `hold_remaining <= 0` → `S9_BOAT_READY`, phát `boat_ready`. Không có checkpoint: nếu chết sau đó vẫn là S11.
8. HUD hiển thị `ceil(hold_remaining)` giây (số nguyên, không âm).

### 4.4 S9 và lên thuyền

1. **Guard lên thuyền** `can_board()` = `extract_state == S9_BOAT_READY` **và** `in_board_zone` **và** `manifest_carried`.
2. Thuyền chờ không giới hạn thời gian ở S9; rời `BeaconZoneA` hoặc `BoardZoneA` không đổi state (không timeout,
   không hủy, không auto-board).
3. `board()` khi guard đúng, theo thứ tự nguyên tử: (a) đếm ô ba lô đã dùng; (b) gọi
   `RetrieverInventory.resolve_extract()`; (c) dựng `ExtractSummary`; (d) `contract_state → EXTRACTED`;
   (e) `extract_state → S10_SUCCESS`; (f) phát `extract_succeeded(summary)` đúng một lần.
4. `board()` khi guard sai → trả `null`, không đổi gì.
5. Lên thuyền **không** cần O5: đó là action an toàn, player đã xác nhận rủi ro ở bước gọi.

### 4.5 S10 và kết thúc

1. Ở `S10_SUCCESS` và `ENDED_DEATH`, flow bỏ qua mọi input (zone, signal inventory, `request_call`, `board`, `tick`).
2. Nút `Về hub` ở S10 chuyển về scene Boot (quyết định S02 đã duyệt: `Về hub` → Boot; không lưu tiến trình). Contract
   state `EXTRACTED` chỉ sống trong bộ nhớ của run.

## 5. Bảng chuyển trạng thái

Cột HUD ghi key có sẵn trong `strings.csv`; `KEY_MỚI?` = key chưa có, đề nghị TASK-71 viết chữ. Bố cục, vị trí và
hiệu ứng beacon thuộc TASK-70 và art, không thuộc bảng này. "—" = state không đổi.

| Mã | State nguồn | Sự kiện | Guard | State đích | HUD / beacon hiện |
|---|---|---|---|---|---|
| BCN-01 | (bắt đầu run S2) | `setup()` | Contract 1 thường, Manifest chưa từng nhặt | desk `HAS_MANIFEST` · contract `NOT_TAKEN` · `E0` | `HUD_OBJECTIVE_TAKE_MANIFEST`; beacon `BEACON_E0_STATE_LABEL`; nhãn bàn `WORLD_INTERACT_DISPATCH_DESK` |
| BCN-02 | E0 | vào `BeaconZoneA` | — | — (E0) | thêm `BEACON_E0_STATE_REASON`; **không** có `EXTRACT_E1_BUTTON_CALL` |
| BCN-03 | E0 | `request_call()` | `can_call()` sai | — (E0); trả `false` | không mở O5 |
| BCN-04 | desk `HAS_MANIFEST` | tương tác bàn | player trong tầm tương tác bàn | — (O2 mở) | `CARD_MANIFEST_R17_NAME/FOOTPRINT/USE/CLAIM/RARITY/LORE`, badge `CARD_MANIFEST_R17_STATE_NOT_EXTRACTED`, `CARD_ACTION_PICK_AND_PLACE`, `CARD_ACTION_CLOSE` |
| BCN-05 | O2 trên bàn | đóng card / placement fail / hủy | — | — (desk `HAS_MANIFEST`, `E0`) | lý do fail theo `InventoryReason`; HUD như BCN-01 |
| BCN-06 | desk `HAS_MANIFEST`, `NOT_TAKEN`, E0 | `evidence_carried_changed(manifest_r17, true)` từ pickup vào **ba lô** | commit `ok` | desk `EMPTY` · `CARRYING` · `E1` | `HUD_OBJECTIVE_DELIVER_PIER_A`; beacon `BEACON_E1_STATE_LABEL`; `PROMPT_SAFEBOX_SEAL_HINT` rồi `PROMPT_ROUTE_EXTRACT_NOW` / `PROMPT_ROUTE_GO_MARKET`; nhãn bàn ẩn |
| BCN-07 | như BCN-06 | như BCN-06 nhưng pickup thẳng vào **Hộp** | commit `ok` | như BCN-06 | như BCN-06 + nhãn item `INVENTORY_SEAL_LABEL_SEALED_NOT_EXTRACTED` |
| BCN-08 | `CARRYING`, E1 | Manifest move/seal/withdraw giữa ba lô ↔ Hộp | — | — | đổi nhãn niêm theo inventory spec; beacon không đổi |
| BCN-09 | E1 | player ngoài `BeaconZoneA` | — | — | `BEACON_E1_STATE_LABEL` + `KEY_MỚI? BEACON_E1_OUT_OF_ZONE_REASON` (nhắc vào vòng đèn phao để gọi); không có nút gọi |
| BCN-10 | E1 | vào `BeaconZoneA` | `can_call()` đúng | — | `EXTRACT_E1_BUTTON_CALL` hiện |
| BCN-11 | E1 | `request_call()` | `can_call()` đúng | E1, O5 mở | `EXTRACT_CONFIRM_TITLE`, `EXTRACT_CONFIRM_BODY` với `{seconds}=20`, `EXTRACT_CONFIRM_ACCEPT`, `EXTRACT_CONFIRM_CANCEL`; health/objective vẫn hiện |
| BCN-12 | E1, O5 mở | `cancel_call()` | — | E1, O5 đóng | như BCN-10; inventory `snapshot()` không đổi |
| BCN-13 | E1, O5 mở | rời `BeaconZoneA` hoặc mất Manifest | — | E1 (hoặc E0 nếu mất Manifest), O5 đóng như hủy | như BCN-09 (hoặc BCN-26) |
| BCN-14 | E1, O5 mở | `confirm_call()` | guard kiểm lại đúng | `S7_CALL_ACCEPTED`, O5 đóng | `EXTRACT_S7_CALL_ACCEPTED`; objective vẫn `HUD_OBJECTIVE_DELIVER_PIER_A` |
| BCN-15 | E1, O5 mở | `confirm_call()` | guard kiểm lại sai | E1/E0, O5 đóng; trả `false` | như BCN-09 |
| BCN-16 | S7 | `tick` cộng dồn ≥ `EXTRACT_CALL_ACK_SECONDS` | — | `S8_HOLD`, `hold_remaining = 20` | `HUD_OBJECTIVE_HOLD_PIER_A`, `EXTRACT_S8_HOLD_TIMER` với `{seconds}=20` |
| BCN-17 | S8 | `tick(delta)` | trong vùng **và** mang Manifest | — (`hold_remaining` giảm) | `EXTRACT_S8_HOLD_TIMER` với `{seconds}=ceil(hold_remaining)` |
| BCN-18 | S8 | rời `BeaconZoneA` | — | S8, `hold_paused = true` | timer đứng yên + `KEY_MỚI? EXTRACT_S8_HOLD_PAUSED` (nhắc quay lại vòng đèn phao) |
| BCN-19 | S8 tạm dừng | vào lại `BeaconZoneA` | mang Manifest | S8, `hold_paused = false` | timer chạy tiếp từ đúng số giây cũ |
| BCN-20 | S8 | `hold_remaining <= 0` | không tạm dừng | `S9_BOAT_READY` | `HUD_OBJECTIVE_BOARD_BOAT`, `EXTRACT_S9_BOAT_READY` |
| BCN-21 | S9 | player ngoài `BoardZoneA`; `board()` | `can_board()` sai | — ; trả `null` | không có `EXTRACT_S9_BUTTON_BOARD` |
| BCN-22 | S9 | vào `BoardZoneA` | `can_board()` đúng | — | `EXTRACT_S9_BUTTON_BOARD` hiện |
| BCN-23 | S9 | rời mọi vùng, chờ bất kỳ thời gian | — | — (S9) | như BCN-21; không timeout |
| BCN-24 | S9 | `board()` | `can_board()` đúng | `S10_SUCCESS` · contract `EXTRACTED` | S10: xem §10.5 |
| BCN-25 | S10 | chạm `SUMMARY_BUTTON_HUB` | — | scene Boot | không lưu tiến trình |
| BCN-26 | `CARRYING`, E1 (S04) | `evidence_carried_changed(manifest_r17, false)` | drop commit `ok` sau O5 | `DROPPED` · `E0` | `KEY_MỚI? HUD_OBJECTIVE_PICK_UP_MANIFEST`; beacon `BEACON_E0_STATE_LABEL` + `BEACON_E0_STATE_REASON`; bàn vẫn `EMPTY` |
| BCN-27 | `DROPPED`, E0 (S04) | `evidence_carried_changed(manifest_r17, true)` | pickup `ok` | `CARRYING` · `E1` | như BCN-06 (không lặp `PROMPT_ROUTE_*`) |
| BCN-28 | S8 (S04) | Manifest bị bỏ xuống | — | S8, `hold_paused = true` | `BEACON_E0_STATE_REASON`; nhặt lại → như BCN-19 |
| BCN-29 | S9 (S04) | Manifest bị bỏ xuống | — | — (S9); `can_board()` sai | `BEACON_E0_STATE_REASON` |
| BCN-30 | E0/E1/O5/S7/S8/S9 | `notify_death()` | — | `ENDED_DEATH` (ranh giới S11) | không có chữ extract/success; O5 đóng; xem §9 |
| BCN-31 | S10 hoặc `ENDED_DEATH` | mọi input | — | — | không đổi gì, không signal |

## 6. Rời vùng beacon trong S8/S9 `proposed`

| State | Khi player rời vùng | Lý do |
|---|---|---|
| **S8** | Đồng hồ **tạm dừng** (không reset, không hủy cuộc gọi); quay lại vùng thì chạy tiếp. HUD nói rõ đang dừng và vì sao. | “Giữ khu” phải có nghĩa là đứng ở khu: nếu đồng hồ chạy khi player bỏ đi thì S8 thành auto-win. Reset phạt nặng một cú dash/né sát mép vùng trên mobile; hủy cuộc gọi là một action ngầm mà player chưa xác nhận. Tạm dừng giữ nguyên nhân–hệ quả một bước. |
| **S9** | Không đổi gì; thuyền chờ. Chỉ `BoardZoneA` + chạm `Lên thuyền` mới vào S10. | Timeout thuyền là luật thất bại mới không có trong nguồn; auto-board bị cấm. |

Không có checkpoint giữa S7/S8/S9, không auto-board, không auto-win và không lưu tiến trình hold.

## 7. Bảng G11 — action cần O5 và action không được xác nhận

### 7.1 Action cần O5 (preview + xác nhận/hủy)

| Action | Nguồn | Vì sao khó đảo ngay | Key O5 | Sprint |
|---|---|---|---|---|
| `Gọi thuyền` (kể cả rút sớm) | E1, nút `EXTRACT_E1_BUTTON_CALL` | Bắt đầu S7/S8, mang pressure lane B (từ S03) | `EXTRACT_CONFIRM_TITLE/BODY/ACCEPT/CANCEL` | **S02** |
| Bỏ một item đang mang | O3 ba lô | Item về đất, có thể mất khỏi run | `KEY_MỚI?` (TASK-71) | S04 |
| Rút đồ niêm khỏi Hộp | O4 → ba lô | Item mất bảo vệ khi chết | `KEY_MỚI?` (TASK-71) | S04 |
| Đổi gear phá placement cũ / vào không vũ khí | O1 loadout | Đổi tổ hợp đồ mang vào run | `KEY_MỚI?` (TASK-71) | S04 |

Ở S02, UI **không được hiện** affordance bỏ item, rút đồ niêm hay đổi gear (loadout S02 chỉ sắp lại starter kit).
Nếu một affordance trong ba dòng S04 xuất hiện mà không có O5, đó là `BLOCKER` G11.

### 7.2 Action không được gọi O5

Di chuyển nhân vật · move item trong lưới · rotate · inspect/xem card · đóng/hủy overlay · preview placement ·
`Nhặt và xếp` · niêm item vào Hộp · `Bỏ qua` card · vào/ra vùng beacon · giữ khu · `Lên thuyền` · `Về hub`.
Các action này hoặc chưa commit (hủy được) hoặc an toàn; thêm O5 sẽ tạo chuỗi popup cản trở mobile (wireflow §6 O5).

## 8. Hồ sơ S02 — không địch (`s02_no_enemy_profile`)

1. S8 chỉ chạy đếm giờ theo §4.3; flow phát `hold_started` nhưng ở S02 không có hệ thống nào nghe để spawn địch.
2. Không spawn kẻ địch, không lane B pressure, không hiện `EXTRACT_S8_LANE_ALERT`, không âm thanh/đèn cảnh báo lane.
3. `EXTRACT_CONFIRM_BODY` giữ nguyên chữ hiện có (kể cả câu cảnh báo địch) theo quyết định S02 đã duyệt; S03 sẽ
   làm câu đó đúng bằng encounter, không sửa chữ.
4. Hồ sơ này không thay luật: rời vùng vẫn tạm dừng, S9 vẫn cần lên thuyền chủ động.
5. Từ S03, cảnh báo lane do hệ encounter phát (ngoài spec này) và HUD mới hiện `EXTRACT_S8_LANE_ALERT`; flow không đổi.

## 9. Ranh giới S11 / death (không đặc tả)

`notify_death()` ở bất kỳ state nào trước S10 đưa flow vào `ENDED_DEATH`, đóng O5 nếu đang mở và **không** gọi
`resolve_extract()`, không phát `extract_succeeded`. Mọi thứ sau đó (`resolve_death()`, `unrecovered`, S11, S12,
Recovery Contract, chế độ thu hồi của bàn dispatch) thuộc spec khác. Spec này chỉ bảo đảm death không bao giờ đi S10.

## 10. API đề xuất cho engineering (GDScript, Godot 4.7.2) — `proposed`, không phải code

### 10.1 Enum

| Enum | Giá trị |
|---|---|
| `ExtractState` | `E0_UNAVAILABLE`, `E1_CALLABLE`, `S7_CALL_ACCEPTED`, `S8_HOLD`, `S9_BOAT_READY`, `S10_SUCCESS`, `ENDED_DEATH` |
| `ContractState` | `NOT_TAKEN` (`chưa nhận`), `CARRYING` (`đang mang`), `DROPPED` (`đã bỏ lại`, từ S04), `EXTRACTED` (`đã extract`), `UNRECOVERED` (`chưa thu hồi`, chỉ ranh giới) |
| `DeskState` | `HAS_MANIFEST`, `EMPTY` |

O5 không phải một `ExtractState`; nó là cờ `call_confirm_open` vì overlay không đổi run state (wireflow §2).

### 10.2 `ExtractPierAFlow` (`RefCounted`)

Thuộc tính chỉ đọc: `extract_state`, `contract_state`, `desk_state`, `manifest_carried: bool`, `in_beacon_zone: bool`,
`in_board_zone: bool`, `call_confirm_open: bool`, `hold_remaining: float`, `hold_paused: bool`,
`hold_pause_reason: StringName` (`&""`, `&"out_of_zone"`, `&"manifest_missing"`; nếu cả hai, `manifest_missing`).

| Method | Trả về | Hành vi |
|---|---|---|
| `setup(inventory: RetrieverInventory)` | `void` | Nối `evidence_carried_changed`; ghi `carried_ever` (uid → def_id của mọi item đang có trong ba lô/Hộp/túi đeo chéo); đặt state BCN-01. |
| `on_evidence_carried_changed(def_id: StringName, carried: bool)` | `void` | §4.1.3–6. |
| `set_in_beacon_zone(inside: bool)` | `void` | Do adapter scene gọi từ `BeaconZoneA.body_entered/exited`. |
| `set_in_board_zone(inside: bool)` | `void` | Do adapter gọi từ `BoardZoneA`. |
| `can_call()` | `bool` | §4.2.2. |
| `request_call()` | `bool` | §4.3.1. |
| `confirm_call()` | `bool` | §4.3.4. |
| `cancel_call()` | `void` | §4.3.2; no-op nếu O5 không mở. |
| `tick(delta: float)` | `void` | S7 và S8 theo §4.3.5–7; kẹp `MAX_TICK_DELTA`; state khác bỏ qua. |
| `hold_seconds_display()` | `int` | `ceil(max(hold_remaining, 0))`. |
| `can_board()` | `bool` | §4.4.1. |
| `board()` | `ExtractSummary` hoặc `null` | §4.4.3–4. |
| `notify_death()` | `void` | §9. |

`carried_ever` cũng thêm uid mỗi khi `item_placed` phát (để biết item đã từng mang trong run).

Signals (phát sau khi state đã đổi): `extract_state_changed(from: ExtractState, to: ExtractState)`,
`contract_state_changed(from: ContractState, to: ContractState)`, `desk_state_changed(to: DeskState)`,
`call_confirm_opened()`, `call_confirm_closed(confirmed: bool)`, `hold_started(duration: float)`,
`hold_paused_changed(paused: bool, reason: StringName)`, `boat_ready()`, `extract_succeeded(summary: ExtractSummary)`.
Không có signal mỗi frame: HUD đọc `hold_seconds_display()` khi vẽ.

Adapter scene (tên do engineer chọn) chỉ nối Area3D, tương tác bàn, nút HUD và `_process` → `tick`; mọi luật ở flow.

### 10.3 Kiểm tra trùng lặp và thứ tự

1. `confirm_call()` gọi hai lần liên tiếp: lần hai trả `false`, không signal.
2. `board()` gọi hai lần: lần hai trả `null`; `extract_succeeded` và `resolve_extract()` mỗi thứ đúng một lần.
3. `request_call()` khi O5 đang mở: trả `false`, không mở thêm.

### 10.4 `ExtractSummary` (`RefCounted`) — dữ liệu tối thiểu cho S10

| Field | Kiểu | Nguồn / quy tắc |
|---|---|---|
| `kept` | `Array[Dictionary]` `{uid: int, def_id: StringName}` | Mọi phần tử `ExtractOutcome.to_hub` (non-evidence ở ba lô, túi đeo chéo, Hộp). |
| `lost` | `Array[Dictionary]` `{uid: int, def_id: StringName}` | uid trong `carried_ever` không có trong `to_hub` hay `to_archive` (đồ đã tự bỏ lại). S02 luôn rỗng. |
| `evidence` | `Array[StringName]` | `ExtractOutcome.to_archive` (slice: `[&"manifest_r17"]`). |
| `next` | `Array[Dictionary]` `{contract_id: StringName, playable: bool}` | Slice: `[{contract_id: &"contract_2", playable: false}]`; không có action bắt đầu. |
| `backpack_cells_used` | `int` 0–12 | Tổng số ô bị chiếm trong ba lô, đếm **trước** `resolve_extract()`. |
| `backpack_cells_total` | `int` | `backpack.size.x * backpack.size.y` (slice: 12). |
| `contract_state` | `ContractState` | Luôn `EXTRACTED`. |

`to_dict() -> Dictionary` trả các field trên cho test. **Cấm** field điểm số, xếp hạng, route đã đi, tổng giá trị
hay thời gian chạy: rút sớm và full-route chỉ khác `kept`/`lost`/`backpack_cells_used`.

### 10.5 Ánh xạ summary → key S10

| Nhóm | Key |
|---|---|
| Tiêu đề | `SUMMARY_SUCCESS_TITLE` |
| `kept` | `SUMMARY_GROUP_KEPT`; `SUMMARY_SUCCESS_KEPT_LICENCE`; tên từng item (`display_name_vi`); `SUMMARY_SUCCESS_KEPT_CELLS` với `{used}`, `{total}` |
| `lost` | `SUMMARY_GROUP_LOST` + tên item + `SUMMARY_SUCCESS_LOST_LEFT_BEHIND`; **ẩn cả nhóm nếu rỗng** |
| `evidence` | `SUMMARY_GROUP_EVIDENCE`; `SUMMARY_SUCCESS_EVIDENCE_MANIFEST`, `SUMMARY_SUCCESS_EVIDENCE_LIMIT`, `SUMMARY_SUCCESS_EVIDENCE_LEAD` |
| `next` | `SUMMARY_GROUP_NEXT`; `SUMMARY_NEXT_CONTRACT2_TITLE`, `SUMMARY_NEXT_CONTRACT2_TAG`; không nút bắt đầu |
| Phản ứng | `SUMMARY_SUCCESS_MENTOR_LINE` |
| Nút | `SUMMARY_BUTTON_HUB` → Boot |

### 10.6 Key chưa có (`KEY_MỚI?`, chuyển TASK-71)

| Key đề xuất | Dùng ở | Sprint |
|---|---|---|
| `BEACON_E1_OUT_OF_ZONE_REASON` | BCN-09, E1 ngoài vùng | S02 |
| `EXTRACT_S8_HOLD_PAUSED` | BCN-18, S8 tạm dừng vì ra khỏi vùng | S02 |
| `HUD_OBJECTIVE_PICK_UP_MANIFEST` | BCN-26, Manifest nằm trên đất | S04 |
| Key O5 cho bỏ item / rút đồ niêm / đổi gear | §7.1 | S04 |

## 11. Edge cases

1. Nhặt Manifest thẳng vào Hộp: hợp lệ, E1 ngay (BCN-07); niêm không là completion.
2. Đang trong `BeaconZoneA` lúc nhặt Manifest (bàn sát beacon): E1 và `can_call()` đúng ngay; nút gọi hiện nhưng không
   tự mở O5.
3. Player đứng trong vùng khi E0 mãi mãi: không có gì xảy ra.
4. Rời vùng khi O5 mở: O5 đóng như hủy; quay lại vùng phải chạm `Gọi thuyền` lại.
5. Rời vùng trong S7: S7 vẫn sang S8 đúng giờ; S8 bắt đầu ở trạng thái tạm dừng nếu player còn ngoài vùng.
6. App bị đưa xuống nền rồi trở lại với một `delta` lớn: mỗi `tick` chỉ trừ tối đa `MAX_TICK_DELTA`; không hoàn tất S8
   trong một khung.
7. `hold_remaining` âm sau `tick` cuối: kẹp về 0; HUD không hiện số âm; chuyển S9 trong cùng `tick`.
8. Nhận `evidence_carried_changed` với `def_id` khác: bỏ qua.
9. Signal `true` thứ hai khi đã `CARRYING` (không xảy ra theo inventory spec): bỏ qua, không phát lại signal.
10. Death khi O5 đang mở: O5 đóng, `ENDED_DEATH`; không gọi `confirm_call`.
11. Ba lô trống, Manifest trong Hộp lúc lên thuyền: `backpack_cells_used = 0`, `total = 12`.

## 12. Acceptance tests (given / when / then)

Tên test engineering: `test_bcn_xx_<mô_tả_ngắn>`, dùng `ExtractPierAFlow` + `RetrieverInventory` thật hoặc giả
(phát cùng signal). "Không đổi" = ba state, `call_confirm_open`, `hold_remaining` và `inventory.snapshot()` bằng nhau
và không có signal của flow.

| Mã | Given | When | Then |
|---|---|---|---|
| BCN-01 | Run mới, loadout §8.4 inventory spec | `setup(inventory)` | `HAS_MANIFEST`, `NOT_TAKEN`, `E0_UNAVAILABLE`, `can_call() == false`. |
| BCN-02 | BCN-01 | `set_in_beacon_zone(true)` | Vẫn E0; `can_call() == false`; không signal. |
| BCN-03 | BCN-02 | `request_call()` | Trả `false`; `call_confirm_open == false`; không đổi. |
| BCN-04 | BCN-01, player ở bàn | UI mở O2 Manifest | Ba state không đổi. |
| BCN-05 | O2 mở | `commit_pickup` fail (ví dụ ô bị chiếm) rồi đóng O2 | Không đổi; Manifest vẫn ở bàn. |
| BCN-06 | BCN-01 | `commit_pickup(manifest, backpack, (0,0), false)` `ok` | `EMPTY`, `CARRYING`, `E1_CALLABLE`; `desk_state_changed`, `contract_state_changed`, `extract_state_changed` mỗi cái một lần. |
| BCN-07 | BCN-01 | `commit_pickup(manifest, notary_box, (1,0), false)` `ok` | Như BCN-06; `seal_label == sealed_not_extracted`. |
| BCN-08 | BCN-06 | `commit_seal(manifest, (1,0), false)` | Không đổi state flow; không signal flow. |
| BCN-09 | BCN-06, ngoài vùng | `can_call()`; `request_call()` | `false`; `false`; O5 không mở. |
| BCN-10 | BCN-06 | `set_in_beacon_zone(true)` | `can_call() == true`. |
| BCN-11 | BCN-10 | `request_call()` | `true`; `call_confirm_open`; `call_confirm_opened` một lần; vẫn E1; text `EXTRACT_CONFIRM_BODY` điền `seconds = 20`. |
| BCN-12 | BCN-11 | `cancel_call()` | E1; O5 đóng; `call_confirm_closed(false)`; inventory không đổi. |
| BCN-13 | BCN-11 | `set_in_beacon_zone(false)` | O5 đóng, `call_confirm_closed(false)`; E1. |
| BCN-14 | BCN-11 | `confirm_call()` | `true`; `S7_CALL_ACCEPTED`; `call_confirm_closed(true)`. |
| BCN-15 | BCN-11 rồi fake `evidence_carried_changed(manifest_r17, false)` | `confirm_call()` | O5 đã đóng ngay khi mất Manifest (`call_confirm_closed(false)`); `confirm_call()` trả `false`; `E0_UNAVAILABLE`, `DROPPED`; không vào S7. |
| BCN-16 | BCN-14 | `tick(0.25)` × 6 | `S8_HOLD`; `hold_remaining == 20.0`; `hold_started(20.0)` một lần; `hold_seconds_display() == 20`. |
| BCN-17 | BCN-16, trong vùng | `tick(0.25)` × 4 | `hold_remaining == 19.0`; `hold_paused == false`. |
| BCN-18 | BCN-17 | `set_in_beacon_zone(false)` rồi `tick(0.25)` × 8 | `hold_paused`, reason `out_of_zone`; `hold_remaining == 19.0`; vẫn S8. |
| BCN-19 | BCN-18 | `set_in_beacon_zone(true)`, `tick(0.25)` × 4 | `hold_paused == false`; `hold_remaining == 18.0`. |
| BCN-20 | S8 vừa vào, `hold_remaining == 20.0`, trong vùng, mang Manifest | `tick(0.25)` × 80 | `S9_BOAT_READY` ở `tick` cuối; `boat_ready` một lần; `hold_seconds_display() == 0`. |
| BCN-21 | BCN-20, `in_board_zone == false` | `board()` | `null`; vẫn S9; `resolve_extract` không được gọi. |
| BCN-22 | BCN-20 | `set_in_board_zone(true)` | `can_board() == true`. |
| BCN-23 | BCN-20 | rời mọi vùng, `tick(0.25)` × 4000 | Vẫn S9; không signal. |
| BCN-24 | BCN-22, Manifest ở ba lô (0,0), Hộp như loadout | `board()` | Trả summary; `S10_SUCCESS`; `EXTRACTED`; `evidence == [manifest_r17]`; `kept` chứa `starter_remedy` và mọi item trong túi đeo chéo, không chứa Manifest; `lost` rỗng; `backpack_cells_used == 1`, `total == 12`; `extract_succeeded` một lần. |
| BCN-25 | S10 | Chạm `Về hub` | Scene Boot; không có file save mới trong `user://`. |
| BCN-26 | BCN-06 | fake `evidence_carried_changed(manifest_r17, false)` | `DROPPED`, `E0`; `desk_state` vẫn `EMPTY`. |
| BCN-27 | BCN-26 | fake `(manifest_r17, true)` | `CARRYING`, `E1`. |
| BCN-28 | S8 trong vùng | fake `(manifest_r17, false)`, `tick(1.0)` | `hold_paused`, reason `manifest_missing`; `hold_remaining` không đổi. |
| BCN-29 | S9 trong `BoardZoneA` | fake `(manifest_r17, false)` | `can_board() == false`; vẫn S9. |
| BCN-30 | Lần lượt E0, E1 + O5 mở, S7, S8, S9 | `notify_death()` | `ENDED_DEATH`; O5 đóng nếu mở; `resolve_extract` không gọi; không `extract_succeeded`. |
| BCN-31 | S10 và `ENDED_DEATH` | gọi mọi method input + signal inventory | Không đổi; không signal. |
| BCN-32 | BCN-14 | `confirm_call()` lần hai | `false`; không signal. |
| BCN-33 | BCN-24 | `board()` lần hai | `null`; `extract_succeeded` tổng cộng một lần. |
| BCN-34 | S8 vừa vào, `hold_remaining == 20.0`, trong vùng | `tick(10.0)` | `hold_remaining == 19.75` (kẹp `MAX_TICK_DELTA`). |
| BCN-35 | Hai run: rút sớm (chỉ Manifest) và full-route (Manifest + loot) | `board()` mỗi run | Hai `to_dict()` có cùng tập key; không có key điểm/route/giá trị/thời gian. |
| BCN-36 | Scene zone A với `s02_no_enemy_profile`, flow ở S8 | Chạy hết S8 | Không node nào trong nhóm `enemy` (`proposed`) được tạo; HUD không hiện `EXTRACT_S8_LANE_ALERT`; `tr("EXTRACT_CONFIRM_BODY")` đúng chữ trong `strings.csv`. |
| BCN-37 | Scene zone A | Liệt kê Area3D gắn `set_in_beacon_zone` | Chỉ `BeaconZoneA` (con của `BeaconA`). |

## 13. Truy vết tới gate

| Gate / invariant | Mục | Test |
|---|---|---|
| G4 (beacon callable chỉ sau placement) | §4.1, §4.2 | BCN-01…08 |
| G5 (rút sớm = success) | §4.4, §10.4 | BCN-24, BCN-35 |
| G11 (O5 đúng chỗ, không thừa) | §7 | BCN-11…15 |
| G13 (E1/S7, hủy giữ E1) | §4.2, §4.3 | BCN-09…15 |
| G14 (hold/board, không checkpoint, death → S11) | §4.3–4.4, §6, §9 | BCN-16…23, BCN-30 |
| G15 (summary tách nhóm, Contract 2 chưa playable) | §10.4–10.5 | BCN-24, BCN-35 |
| Invariant §8.3 | toàn bộ | BCN-02, BCN-03, BCN-21, BCN-23 |

## 14. Ngoài phạm vi và câu hỏi mở

- Ngoài phạm vi: combat, địch, lane B, AI, khu B/C/D/E, Contract 2 playable, death/S11/S12/Recovery, bố cục màn
  hình/touch (TASK-70), chữ mới (TASK-71), hình ảnh/âm thanh beacon và thuyền.
- Câu hỏi mở (không chặn spec): vị trí chính xác `BeaconZoneA`/`BoardZoneA` trên greybox A và việc hai vùng có chồng
  nhau không — giao level-designer khi dựng greybox.
