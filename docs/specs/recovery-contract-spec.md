# Recovery Contract / S12 — Contract 1 “Giữ giấy phép”

**Trạng thái:** system spec `proposed` cho S05. Mọi luật mang nhãn `proposed` trong tài liệu này phải được coi là đề xuất cho tới khi Producer duyệt. Tài liệu này cụ thể hóa G18 và C3, không đổi canon của [main story](../story/MAIN_STORY.md), luật slice hay item catalogue.

**Đối tượng bàn giao:** TASK-105 (chữ), TASK-106 (gameplay), TASK-107 (test headless) và TASK-109 (QA). `S12` là màn đọc tối thiểu; S1/O1/S10 là màn có sẵn với biến thể recovery, không tạo hệ layout mới.

## 1. Mục đích, scope và bất biến

### 1.1 Mục đích người chơi

Sau khi Phù Hiệu Hồi Hương kích hoạt **sau** khi Người Thu Hồi đã từng mang `manifest_r17`, người chơi phải hiểu: đồ niêm không-phải-vật-chứng còn giữ được, đồ không niêm đã mất, Manifest Hàng Hóa R-17 là `unrecovered`, và vẫn phải tự lấy lại, xếp hợp lệ, gọi, giữ khu rồi lên thuyền tại Cầu tàu A. Recovery Contract không phải completion hay bảo hiểm hoàn lại đồ.

### 1.2 Scope bắt buộc `proposed`

1. Chỉ Contract 1 — Giữ giấy phép (`contract_keep_licence`), Easy, Bến Ngoài (A), Chợ Ngập (B), Kho Nổi (D), và Cầu tàu A (`extract_pier_a`) là extract duy nhất.
2. Recovery source duy nhất là **bàn dispatch A** (`recovery_source_dispatch_a`). Không dựng túi người đưa tin, prop, NPC, marker, route, checkpoint hay source thứ hai.
3. Recovery state chỉ sống trong tiến trình app: `RunSession`/memory. Không ghi `user://`, không save/load, không chuyển state qua Boot hay khởi động app.
4. Không có Contract 2 playable, C/E input, thuyền D, economy/shop/craft, item mới, âm thanh mới hay restore gear/loot đã mất hoặc bị người chơi tự bỏ.
5. Mọi placement vẫn theo lưới hiện có: ba lô 3×4 `proposed`, Hộp Công Chứng 2×2, túi đeo chéo không nhận loot/cargo. Sai placement giữ item ở nguồn, nêu lý do, không auto-drop/swap/sort/seal.
6. `manifest_r17` niêm vẫn là `sealed_not_extracted` / “đã niêm — chưa extract”; chỉ `board()` tại A mới đưa Contract sang `EXTRACTED` và S10.

### 1.3 Nguồn sự thật và giá trị hiện có

| Khái niệm | Giá trị / owner | Cách dùng cho recovery |
|---|---|---|
| Contract state | `ExtractPierAFlow.ContractState`: `NOT_TAKEN`, `CARRYING`, `DROPPED`, `EXTRACTED`, `UNRECOVERED` | Dùng đúng enum hiện có. Không đề xuất enum `ContractState` mới. |
| Bàn dispatch | `DeskState.HAS_MANIFEST` / `EMPTY` | Recovery dùng cùng bàn, nhưng action chỉ khác pickup thường khi `ContractState == UNRECOVERED`. |
| Extract | `E0_UNAVAILABLE`, `E1_CALLABLE`, `S7_CALL_ACCEPTED`, `S8_HOLD`, `S9_BOAT_READY`, `S10_SUCCESS` | Recovery không bỏ qua hay viết lại state extract. |
| Tuple recovery tại A | `ExtractPierAFlow`: `contract_state=UNRECOVERED`, `desk_state=HAS_MANIFEST`, `manifest_carried=false`, `extract_state=E0_UNAVAILABLE` | Tuple bắt buộc ngay khi S2 recovery được tạo. Đây là state của flow hiện có, không phải một recovery state song song. |
| Vật chứng | `manifest_r17`, footprint 1×1, `evidence`, sealable | Không ở `kept` khi death; chỉ là `unrecovered_evidence`. |
| Đồ niêm thường | `kept` từ `resolve_death()` | Chỉ non-evidence trong Hộp được đưa vào recovery inventory; placement cũ được giữ nếu còn hợp lệ. |

## 2. Dữ liệu runtime tối thiểu `proposed`

Các trường này là contract giữa session/flow/UI; tên là code identifier, không phải yêu cầu data file hoặc save format.

| Field | Type / range | Nguồn và ý nghĩa |
|---|---|---|
| `recovery_active` | `bool` | `true` từ lúc S11 after-manifest chọn recovery đến S10 hoặc Boot; phân biệt run recovery với run thường. |
| `recovery_source` | `StringName`; chỉ `&"dispatch_a"` | Bất biến nguồn của S05. |
| `recovery_retained` | `Array[ItemPlacement]`, 0…4 occupied cells | Snapshot các item sealed **non-evidence** của `DeathSummary.kept`; gồm `def_id`, `uid` mới/được cấp runtime, `anchor: Vector2i`, `rotated: bool`, `quantity: int`. Không chứa `manifest_r17`. |
| `recovery_basic_kit_applied` | `bool` | Chống thêm kit hai lần khi đóng/mở O1 hoặc quay S1. |
| `run_kind` | `StringName`: `&"normal"` hoặc `&"recovery"` | Nhánh chữ/summary; không thay luật combat, loot hoặc extract. |
| `debug_fixture_id` | `StringName`: rỗng, `&"c1"`, `&"c2"`, `&"c3"` | Chỉ dev/staging khi cờ debug hợp lệ; không xuất hiện production. |

`recovery_active`, `recovery_retained`, `recovery_basic_kit_applied` và `debug_fixture_id` bị xóa khi vào Boot, đóng app, S10 hoàn tất hoặc khởi tạo run chuẩn mới. Đây là cách bảo đảm “không save” mà không làm Contract mắc kẹt.

### 2.1 Khởi tạo recovery-run nguyên tử `proposed`

`RunSession` là owner duy nhất của public initializer `begin_recovery_run(recovery_inventory, recovery_retained, debug_fixture_id) -> ExtractPierAFlow`. Input phải là inventory S1 đã merge basic kit + `recovery_retained`, **không** chứa `manifest_r17`; input context phải có `recovery_active=true`, `recovery_source=&"dispatch_a"`, `run_kind=&"recovery"`. `RunSession` tạo đúng một instance Manifest ở source bàn A, tạo/setup `ExtractPierAFlow`, rồi gọi helper flow mới `initialize_unrecovered_at_dispatch()` trước khi trả flow hoặc dựng HUD/scene S2.

Helper của `ExtractPierAFlow` thực hiện một transition nguyên tử, không phát một frame/state trung gian cho UI: đặt đồng thời `contract_state=UNRECOVERED`, `desk_state=HAS_MANIFEST`, `manifest_carried=false`, `extract_state=E0_UNAVAILABLE`, đóng call/hold và giữ Manifest ngoài inventory tại bàn A. Output thành công của initializer luôn là flow ở tuple §1.3; lỗi input (Manifest đã có trong inventory, inventory invalid, hoặc source không phải `dispatch_a`) không trả flow nửa khởi tạo, giữ player ở S1 với reason và không vào S2.

`ExtractPierAFlow.contract_state`, `desk_state`, `manifest_carried` và `extract_state` là **nguồn sự thật duy nhất** sau initializer. Spec này chủ ý **thay thế**, không đồng bộ, `recovery_contract_state` và `recovery_manifest_available`: UI/action recovery chỉ derive availability từ tuple `UNRECOVERED + HAS_MANIFEST + !manifest_carried + E0`; không được giữ hoặc ghi một bool/state recovery song song. Sau pickup/drop/board, chỉ transition/signals hiện có của `ExtractPierAFlow` cập nhật state.

## 3. Luật Recovery Contract `proposed`

1. S11 `after_manifest` dùng nút `SUMMARY_DEATH_BUTTON_RECOVERY` để vào S12; không hiện `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` hay nút Boot của biến thể cũ.
2. S11 `before_manifest` không thay đổi: `ContractState.NOT_TAKEN`, Manifest ở bàn dispatch A, nút `SUMMARY_DEATH_BUTTON_PREPARE` đi S1 run chuẩn; không qua S12.
3. S12 chỉ có tiêu đề, đúng ba dòng đọc và **một nút**. Nút đi S1 recovery; không có Back/Cancel affordance tại S12, nên không thể xóa `UNRECOVERED` hoặc tạo run mới từ màn đọc này.
4. Khi xác nhận S12, S1 recovery tạo basic recovery kit một lần rồi merge `recovery_retained`. O1 chỉ sắp trong cùng ngăn theo luật loadout hiện có; Hủy O1 khôi phục snapshot mở O1, không khôi phục đồ đã mất.
5. Nút `Vào cảng` ở S1 recovery chỉ bật nếu `inventory.validate()` hợp lệ. Không có mua lại, fee, gear-score, auto-fill hay auto-repair.
6. S2 recovery chỉ bắt đầu từ output của `RunSession.begin_recovery_run()` (§2.1): HUD objective thu hồi, `ContractState.UNRECOVERED`, beacon E0 và bàn dispatch A là action ngữ cảnh duy nhất trong range. B/D vẫn optional sau pickup; C/E vẫn không input.
7. Tại bàn dispatch A, action **Thu hồi Manifest** chỉ hợp lệ khi flow đang ở tuple availability `UNRECOVERED + HAS_MANIFEST + !manifest_carried + E0` (§2.1). Cùng card/nhãn `CARD_MANIFEST_R17_*` và placement flow O3/O4 dùng cho pickup đầu run; khác biệt chỉ là action/HUD recovery, không phải item mới.
8. Mở/đóng card, inspect, preview, placement fail, hủy O3/O4, hoặc Hộp đầy không đổi `UNRECOVERED`, không đặt Manifest tự động và không làm E1 callable.
9. Chỉ commit placement Manifest thành công vào ba lô hoặc Hộp mới khiến flow chuyển `UNRECOVERED → CARRYING`, `HAS_MANIFEST → EMPTY`, và E0 → E1. Niêm sau đó không đổi state; drop lại làm `CARRYING → DROPPED`, E1 → E0, và nhặt lại hợp lệ mới về `CARRYING`.
10. E1 trong recovery vẫn chỉ mở O5 gọi thuyền. Xác nhận → S7 → S8 → S9 → player board → S10; không auto-complete, auto-call, auto-board, teleport hoặc checkpoint.
11. S10 recovery dùng cùng `ExtractSummary` và cấu trúc S10 hiện có; chỉ thêm biến thể câu “recovery” để phân biệt run, không thay kept/lost/evidence/next, không trả loot cũ ngoài đồ đang mang/extract.
12. B cache và D fixture nạp lại khi một run mới thực sự vào map, gồm recovery run. Chúng là item map mới của run mới, không phải trả lại một UID/item từng lost hoặc `left_behind`; item đã mang rồi chết/bỏ ở run trước vẫn chỉ xuất hiện ở S11 `lost`, không quay lại inventory/ground/source.

## 4. Basic recovery kit và merge đồ giữ lại `proposed`

### 4.1 Kit có định danh chính xác

Không được tạo item ngoài definition/fixture hiện có. `uid` runtime không ổn định nên không thuộc fixture contract; `def_id`, ngăn và anchor là nguồn kiểm thử.

| Thành phần | `def_id` | Ngăn / anchor / footprint | Nguồn trong recovery | Hậu quả nếu chết tiếp |
|---|---|---|---|---|
| Ba lô | — | `backpack`, 3×4, rỗng trước pickup | không thêm loot | không áp dụng |
| Thuốc cơ bản | `sling_remedy` | `sling_pouch`, `(0,0)`, 1×1 | tạo đúng một item basic nếu túi trống sau death | không niêm, vào `lost` nếu chưa dùng |
| Thuốc đã giữ | `starter_remedy` | `notary_box`, `(0,0)`, đứng, 1×2 trong C3 chuẩn | copy từ `recovery_retained`, **không** tạo bản thay thế | giữ lại nếu vẫn sealed non-evidence |
| Vật chứng | `manifest_r17` | không nằm inventory lúc vào S1/S2; ở source `dispatch_a`, footprint 1×1 | chỉ player thu hồi tại S2 | `unrecovered`, không ở `kept` |
| Gear cơ bản | không có `ItemDef`/`def_id` được slice hiện hữu khai báo | equipped, ngoài ba lô/túi/Hộp | cùng baseline weapon một tay + khiên nhẹ của starter kit | không có ID/ngăn để fixture này tạo hoặc restore |

Hàng gear cuối cố ý không bịa `def_id`: source hiện hữu chỉ nói slot trang bị baseline và `DeathSummary.equipped_gear_lost`, không định nghĩa item gear inventory. Engineering dùng baseline combat/loadout hiện có; không được thêm `recovery_weapon`/`recovery_shield` chỉ để thỏa fixture.

### 4.2 Merge, Hộp đầy và thứ tự

1. Bắt đầu từ layout `recovery_retained`, giữ nguyên mỗi placement sealed non-evidence hợp lệ; không có evidence trong array này.
2. Nếu `starter_remedy` đã có trong `recovery_retained`, không tạo bản thứ hai. Nếu nó không được giữ, recovery basic kit có thể đặt **một** `starter_remedy` tại `(0,0)` chỉ khi vị trí còn hợp lệ; nếu Hộp đầy bởi đồ retained thì không auto-rút/đẩy/xóa item để đưa thuốc vào.
3. `sling_remedy` basic đặt tại `(0,0)` của `sling_pouch`; nếu snapshot hợp lệ đã có item cùng slot, giữ snapshot và không duplicate. Túi không nhận Manifest.
4. Nếu Hộp đã đầy, Manifest không được auto-seal hay blocked khỏi recovery: player vẫn nhặt/đặt `manifest_r17` 1×1 vào bất kỳ ô trống hợp lệ của ba lô. Bàn chỉ empty và E1 chỉ callable sau commit ba lô đó thành công.
5. Người chơi có thể chủ động rút một item Hộp sang ba lô qua O5i khi có đích hợp lệ, rồi niêm Manifest; không có auto-swap. Nếu ba lô không còn ô 1×1, pickup fail giữ card/source, `UNRECOVERED` và E0.
6. C3 canonical layout là Hộp `starter_remedy` tại `(0,0)` đứng (chiếm `(0,0),(0,1)`) và Manifest sau khi player đã seal tại `(1,0)`; sau death chỉ `starter_remedy` được merge. Khi thu hồi lại, Manifest có thể vào ba lô hoặc người chơi tự niêm vào `(1,0)`.

## 5. State machine và thao tác cảm ứng `proposed`

`O#` là overlay phủ state nguồn; thao tác đóng/hủy luôn quay về state nguồn và không mutate nếu commit chưa thành công. Touch controls phải có một focus/action đầu tiên rõ ràng; HUD nhận update từ state event, không poll mỗi frame.

| State | Điều kiện vào / `ContractState` | Chạm hợp lệ | Thoát, hủy hoặc fail | State sau |
|---|---|---|---|---|
| S11 `after_manifest` | Death thật khi state tại death là `CARRYING` hoặc `DROPPED`, kể cả S7/S8/S9/O5; resolve thành `UNRECOVERED` | Đọc kept/lost/evidence; chạm `SUMMARY_DEATH_BUTTON_RECOVERY` sau guard | Guard chưa hết: không đổi. Không chọn/không có `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` | S12 |
| S12 | `UNRECOVERED`, `recovery_active=true`, chưa có run recovery | Đọc 3 dòng; chạm `RECOVERY_BUTTON_BRIEFING` | Không có Back/Cancel (màn đúng một nút); không reset state | S1 recovery |
| S1 recovery | S12 đã xác nhận; `UNRECOVERED`; kit merge hợp lệ | Chạm xem kit; `Sắp lại đồ`; `Vào cảng` khi validate pass | Back dùng hành vi briefing hiện có: về Boot và clear memory recovery; enter disabled nêu lỗi; không mua/tự sửa | O1 recovery hoặc S2 recovery |
| O1 recovery | Phủ S1; snapshot đã mở | Chọn item rồi chạm ô hợp lệ trong **cùng ngăn**; `Xong` | `Hủy`/Back khôi phục snapshot; invalid giữ item nguồn/overlay | S1 recovery |
| S2 recovery | `RunSession.begin_recovery_run()` trả flow tuple §2.1: `UNRECOVERED`, `DeskState.HAS_MANIFEST`, E0, objective recovery | Đi tới bàn dispatch A; chạm context action Recovery | Ra range: chỉ ẩn affordance. Không có pickup tự động; S2 không được enter từ tuple `NOT_TAKEN` | O2 recovery |
| O2 recovery | Trong range, `UNRECOVERED`, source còn available | Đọc card; `Nhặt và xếp` mở O3/O4 | `Đóng`/Bỏ qua → S2; không state mutation | O3/O4 recovery hoặc S2 |
| O3/O4 recovery | Phủ S2; card Manifest đang pending | Chọn ba lô/Hộp và anchor hợp lệ, commit pickup; sau đó move/seal theo luật hiện có | Hủy/close/fail/full giữ Manifest ở desk, state `UNRECOVERED`, E0 | S2 `CARRYING` / E1 sau commit; hoặc S2 `UNRECOVERED` |
| E1 recovery | Manifest placement thành công; `CARRYING`; player trong BeaconZoneA | `Gọi thuyền` → O5; xác nhận O5 | Hủy O5/ra zone: giữ E1 nếu vẫn mang; không auto-call | S7 |
| S7 | O5 xác nhận khi guard E1 hợp lệ; `CARRYING` | Chờ acknowledge hiện có | Death → S11 after-manifest | S8 |
| S8 | Call acknowledge hết; `CARRYING` | Giữ trong BeaconZoneA; combat normal | Ra zone/drop Manifest: pause, không reset; death → S11 after-manifest | S9 khi hold hết |
| S9 | Hold hoàn tất; `CARRYING` | Đi vào BoardZoneA; chạm `Lên thuyền` | Chờ không timeout; death → S11 after-manifest | S10 recovery |
| S10 recovery | `board()` success; `EXTRACTED` | Xem summary, về hub | Đóng/về hub → Boot; session state clear | S0 |

### 5.1 Transition cốt lõi

```text
S11 after_manifest / UNRECOVERED
  → S12 → S1 recovery ↔ O1 recovery → S2 recovery / E0
  → bàn dispatch A → O2 → O3 hoặc O4
  → placement Manifest hợp lệ / CARRYING / E1
  → O5 → S7 → S8 → S9 → S10 recovery / EXTRACTED
```

Không có mũi tên S12/S1/S2 nào trực tiếp tới S10. B/D từ S2 sau pickup dùng route thường, không phải state recovery mới.

## 6. Death lặp lại, run reset và loot `proposed`

| Thời điểm death trong recovery run | `ContractState` trước → sau | S11 / action kế | Item result |
|---|---|---|---|
| S1/O1/S2 trước pickup | `UNRECOVERED → UNRECOVERED` | `after_manifest` → S12; không biến thành before-manifest chỉ vì run này chưa nhặt | retained sealed non-evidence vẫn kept; basic `sling_remedy` không niêm bị lost nếu chưa dùng; không có Manifest copy trong lost/kept |
| O2/O3/O4, pickup chưa commit | `UNRECOVERED → UNRECOVERED` | như trên | Card/preview không coi là mang Manifest; source recovery vẫn là dispatch ở recovery attempt kế tiếp |
| Sau pickup / E1 / S7 | `CARRYING → UNRECOVERED` | `after_manifest` → S12 | Manifest là unrecovered đúng một lần; unsealed basic/loot lost; sealed non-evidence kept |
| Sau drop trong recovery | `DROPPED → UNRECOVERED` | `after_manifest` → S12 | Manifest ground cũ không tự về bàn trong run đang chết; recovery attempt mới dùng source A, không nhân bản UID |
| S8 paused/running, S9, hoặc O5 call | `CARRYING` (hoặc `DROPPED` nếu đã bỏ) → `UNRECOVERED` | `after_manifest` → S12; `resolve_extract()==0`; không S10 | Same as row phù hợp; call/hold/boat không checkpoint hay success |

Một recovery attempt mới là run map mới: cache B và fixture D xuất hiện lại ở map theo fixture cố định của run. Điều này không vi phạm hậu quả death vì chúng chưa từng là item instance/UID đã rơi hoặc bị mất ở run cũ. Không khôi phục `lost`, `left_behind`, gear, ground drop cũ, hay loot đã dùng.

## 7. Hợp đồng menu fixture C1–C3 `proposed`

### 7.1 Visibility và boundary

1. `RecoveryFixtureMenu` chỉ có ở dev/staging khi `AppEnv.get_flag("app", "debug_menu") == true`. `staging.cfg` hiện cho `true`; production không có đường mở, node/nút/shortcut/debug action này không được expose.
2. C0 không bao giờ thấy menu; C0 phải bắt đầu Boot → S1 → S2 tự nhiên. Menu không có ở briefing, HUD người chơi hoặc summary production.
3. Mỗi fixture khởi tạo `RunSession` in-memory rồi đi tới state chạy thật tương ứng: C2 dùng initializer run chuẩn; mọi recovery attempt sau C3 chỉ dùng `begin_recovery_run()` (§2.1), không được dựng normal flow rồi patch UI/state rời rạc. Không menu item nào tạo `DeathSummary` giả, phát `extract_succeeded`, nhảy thẳng S10/S11, set `EXTRACTED`, hay bỏ qua O5/S7/S8/S9.
4. Fixture chỉ là test/dev tool: không save, không tạo item production mới, không thay cache/loot contract cho C0.

### 7.2 Fixture content chính xác

| Mục | Điều kiện/state sau chọn | Inventory chính xác | Vị trí / action tiếp |
|---|---|---|---|
| C1 — early extract | `CARRYING`, `DeskState.EMPTY`, E1; Manifest placement hợp lệ | `backpack`: `manifest_r17` 1×1 tại `(0,0)`; `notary_box`: `starter_remedy` 1×2 đứng tại `(0,0)`; `sling_pouch`: `sling_remedy` 1×1 tại `(0,0)` | Retriever đứng trong `BeaconZoneA` tại A; player tự mở O5 gọi thuyền, giữ, rồi board. |
| C2 — run mới chuẩn | `NOT_TAKEN`, `DeskState.HAS_MANIFEST`, E0 | `backpack`: rỗng; `notary_box`: `starter_remedy` 1×2 đứng `(0,0)`; `sling_pouch`: `sling_remedy` 1×1 `(0,0)` | Spawn A chuẩn ngoài range/không action tự động; Manifest còn ở bàn dispatch A. |
| C3 — death → recovery | `CARRYING`, `DeskState.EMPTY`, E1; chưa gọi thuyền | `backpack`: `cargo_d_2x2` 2×2 tại `(0,0)`, không niêm; `notary_box`: `starter_remedy` 1×2 đứng `(0,0)` **và** `manifest_r17` 1×1 `(1,0)`, đều niêm; `sling_pouch`: `sling_remedy` 1×1 `(0,0)`, không niêm | Retriever đứng trong combat-capable B hoặc D, không Beacon/Board zone. Tester phải chết qua combat thật; death handler thật mới sinh S11. |
| Khởi động Recovery Contract | Chỉ enabled khi current process có S11 `after_manifest` từ death thật và `ContractState.UNRECOVERED` | Không inject item; dùng đúng `recovery_retained` và death result hiện hữu | Là alias debug của chạm `SUMMARY_DEATH_BUTTON_RECOVERY`: đi S12 → S1 recovery → S2. Không hiện trước death và không tạo S11 giả. |

`cargo_d_2x2` ở C3 là existing D fixture và là bằng chứng loot không niêm bị mất; nó không là item mới hay gear restore. C3 có thể bắt đầu ở B hoặc D để death combat thực tế có sẵn, nhưng không được thêm forced-death device, damage/timing hoặc enemy chỉ cho fixture.

## 8. Key chữ cho TASK-105 `proposed`

Nội dung Việt cuối thuộc TASK-105. Bảng này chỉ khóa key, context, nghĩa và tối đa Unicode NFC theo `contract-1-strings.md` §1.

| Key | Reuse / new | Màn / nghĩa | Max |
|---|---|---|---:|
| `SUMMARY_DEATH_BUTTON_RECOVERY` | dùng lại, **đổi từ không-hiện sang action S11** | after-manifest → S12; không dùng Boot | 24 |
| `RECOVERY_HEADER_TITLE` | dùng lại | S12 title | 32 |
| `RECOVERY_BODY_LOCATION` | dùng lại | dòng 1: Manifest unrecovered ở bàn dispatch A | 72 |
| `RECOVERY_BODY_RULE` | dùng lại | dòng 2: tự thu hồi, placement, rồi A call/hold/board; không là success | 90 |
| `RECOVERY_BODY_KIT` | dùng lại | dòng 3: kit cơ bản, không mua lại / không hứa restore | 72 |
| `RECOVERY_BUTTON_BRIEFING` | dùng lại | nút S12 → S1 recovery | 24 |
| `SUMMARY_DEATH_RECOVERY_UNAVAILABLE` | không dùng ở S05 | Ẩn ở after-manifest, giữ CSV vì key cũ có nghĩa “chưa có” | 72 |
| `SUMMARY_DEATH_BUTTON_BOOT` | không dùng ở S05 after-manifest | Không được hiện trong S11 Recovery Contract | 24 |
| `RECOVERY_BRIEFING_HEADER_TITLE` | **mới** | variant S1, nhận diện recovery chứ không completion | 32 |
| `RECOVERY_BRIEFING_OBJECTIVE` | **mới** | mục tiêu S1: quay A, không mô tả route/map mới | 80 |
| `RECOVERY_BRIEFING_RULES_LINE` | **mới** | Easy/A/loss rule, không hứa restore | 90 |
| `RECOVERY_LOADOUT_SUMMARY` | **mới** | trạng thái kit/đồ giữ/mất/trống, không hứa giữ sang phiên | 110 |
| `RECOVERY_LOADOUT_LABEL_KEPT` | **mới** | label đồ sealed non-evidence đã giữ | 24 |
| `RECOVERY_LOADOUT_LABEL_LOST` | **mới** | label đồ/gear đã mất | 24 |
| `RECOVERY_LOADOUT_LABEL_EMPTY` | **mới** | label slot trống | 24 |
| `WORLD_INTERACT_RECOVER_DISPATCH` | **mới** | context action bàn A khi và chỉ khi `UNRECOVERED` | 24 |
| `CARD_ACTION_RECOVER_MANIFEST` | **mới** | action card O2 recovery | 24 |
| `HUD_OBJECTIVE_RECOVER_MANIFEST` | dùng lại | S2 recovery trước placement | 48 |
| `HUD_OBJECTIVE_DELIVER_PIER_A` | dùng lại | sau placement recovery, route/extract | 48 |
| `SUMMARY_RECOVERY_TITLE` | **mới** | S10 variant title/tag; phải tách từ death, không thay success semantics | 32 |
| `SUMMARY_RECOVERY_NEXT` | **mới** | S10 next/action semantic; không mở Contract 2 playable | 72 |
| `DEBUG_FIXTURE_MENU_TITLE` | **mới**, debug-only | title menu dev/staging, không localized player-facing release | 32 |
| `DEBUG_FIXTURE_C1_LABEL` | **mới**, debug-only | C1 | 24 |
| `DEBUG_FIXTURE_C2_LABEL` | **mới**, debug-only | C2 | 24 |
| `DEBUG_FIXTURE_C3_LABEL` | **mới**, debug-only | C3 | 24 |
| `DEBUG_FIXTURE_RECOVERY_LABEL` | **mới**, debug-only | action alias recovery, enabled only from real S11 | 24 |

## 9. Edge cases `proposed`

1. Cùng bàn dispatch A ở run chuẩn chỉ nói pickup lần đầu; cùng bàn ở recovery chỉ nói thu hồi khi `UNRECOVERED`. Không state nào cho cả hai labels cùng lúc.
2. Closing S12/S1/O1, scene-load error S1, card close, O3/O4 fail, hoặc menu fixture close không erase `UNRECOVERED`/retained set.
3. `manifest_r17` đã drop trong recovery khiến E0; nếu died trước pickup lại, `unrecovered_evidence` vẫn có đúng một `manifest_r17`, không duplicate qua attempts.
4. Khi Hộp full nhưng ba lô có một ô 1×1 hợp lệ, pickup vào ba lô pass; system không bắt player giải safebox để được recovery.
5. Khi cả ba lô và Hộp không có placement hợp lệ, Manifest ở bàn/card source, player thấy reason và có thể tự dọn inventory hoặc cancel; không soft-lock vì basic entry ba lô rỗng.
6. `sling_remedy` đã dùng không liệt kê lost; dùng nó không thay đổi recoverability của Manifest.
7. Death khi O5 call, O3/O4 hoặc O2 đang mở đóng overlay như cancel; không gọi `resolve_extract`, không phát S10, sau S11 vẫn chọn Recovery Contract.
8. Có thể extract ngay A sau recovery pickup. B/D là optional; C/E không thành recovery route và D không thành extract.
9. Nếu app trở về Boot/thoát trước S10, memory recovery state bị clear; slice không tuyên bố persistence. Khi mở lại là run C2 chuẩn, không phải recovery soft-lock.

## 10. Acceptance tests RC-xx `proposed`

Các test nên gọi flow/inventory thuần nơi có thể; scene/UI test chỉ kiểm visible key/action. “Death thật” trong RC-C3 là integration test: gọi enemy/combat path đã tồn tại, không gọi một helper dựng S11.

| ID | Gate/source | Given | When | Then |
|---|---|---|---|---|
| RC-00 | G18 / §2.1 | S1 recovery có inventory đã merge hợp lệ, không có `manifest_r17`, và context `dispatch_a` | gọi `RunSession.begin_recovery_run()` rồi attach HUD/scene | flow được quan sát lần đầu đã là `UNRECOVERED` + `HAS_MANIFEST` + `manifest_carried=false` + E0; không có signal/frame/action `NOT_TAKEN` hay pickup lần đầu; Manifest đúng một source ở bàn A. Input có Manifest/invalid/source khác A bị từ chối, không vào S2 với flow nửa khởi tạo. |
| RC-01 | G18 / §5 | `CARRYING` hoặc `DROPPED`, death ở S3/S7/S8/S9 | resolve death | đúng một `manifest_r17` ở unrecovered; state `UNRECOVERED`; S11 after-manifest có `SUMMARY_DEATH_BUTTON_RECOVERY`, không có unavailable/Boot action. |
| RC-02 | G18 / §5 | S11 after-manifest | chạm nút recovery sau guard | S12 có title + đúng 3 body keys + một nút; không `EXTRACTED`, không S10. |
| RC-03 | G18 / §5 | S12 `UNRECOVERED` | kiểm controls rồi chạm nút duy nhất | chỉ `RECOVERY_BUTTON_BRIEFING` hiện; không có Back/Cancel; action đi S1 recovery và không reset `UNRECOVERED`. |
| RC-04 | G18 / §4 | C3 death result: retained `starter_remedy` | S12 → S1 recovery | Hộp có `starter_remedy` `(0,0)` đứng; túi có `sling_remedy` `(0,0)`; ba lô trống; không có `manifest_r17` trong inventory. |
| RC-05 | G18 / §4 | Hộp recovery đầy đồ sealed non-evidence, ba lô còn `(0,0)` | pickup Manifest vào ba lô `(0,0)` | commit ok, `CARRYING`, E1; không di chuyển/rút/niêm bất kỳ item Hộp nào. |
| RC-06 | G18 / §5 | Hộp + ba lô không có placement hợp lệ | chọn Nhặt và xếp | source/`UNRECOVERED`/E0 không đổi; reason đúng; không auto-drop/swap/sort/seal. |
| RC-07 | G18 / §5 | S2 recovery, source available | mở rồi đóng O2; hoặc preview/placement fail/hủy O3/O4 | Manifest không tự đặt, bàn vẫn available, E0, `UNRECOVERED`. |
| RC-08 | G18 / §5 | S2 recovery, ba lô có anchor 1×1 hợp lệ | `commit_pickup(manifest_r17, backpack, anchor, false)` | đúng một transition `UNRECOVERED → CARRYING`, source unavailable, E1; không complete/Archive. |
| RC-09 | Build-readiness §8.3, §8.8 | `CARRYING` recovery, player ở A | open/confirm O5; tick hold; board valid | thứ tự S7 → S8 → S9 → S10; `EXTRACTED` chỉ tại board; không auto-board. |
| RC-10 | Build-readiness §8.6 | Recovery trước pickup | death thật / resolver | `UNRECOVERED` giữ, S11 after-manifest → S12; sealed non-evidence kept, unsealed basic item lost nếu chưa dùng. |
| RC-11 | Build-readiness §8.6, §8.8 | Recovery sau pickup, lần lượt S7/S8/S9/O5 | death | no `resolve_extract`/S10; manifest unrecovered đúng một lần, state `UNRECOVERED`, recovery action available. |
| RC-12 | G18 | Recovery `CARRYING` | drop Manifest rồi nhặt lại legal | drop → `DROPPED`/E0; pickup → `CARRYING`/E1; bàn không thành normal pickup source trong cùng run. |
| RC-13 | G18 / no-save | Pending recovery rồi Boot hoặc new app session | bắt đầu run | memory recovery data absent; run C2 state `NOT_TAKEN`, Manifest ở bàn A; không file `user://` được ghi. |
| RC-14 | C1 | debug menu enabled, chọn C1 | quan sát rồi tự extract | exact C1 inventory/BeaconZoneA; player vẫn O5/S7/S8/S9/board mới S10. |
| RC-15 | C2 | debug menu enabled, chọn C2 | vào map | exact C2 inventory, `NOT_TAKEN`/E0, Manifest còn bàn A; không summary fake. |
| RC-16 | C3 / G17/G18 | debug menu enabled, chọn C3 ở B hoặc D | để combat hiện có giảm HP về 0 | S11 từ death path thật, không fixture summary; kept=`starter_remedy`, lost gồm `cargo_d_2x2`, evidence Manifest unrecovered; S12 flow qua được. |
| RC-17 | C3 | production channel hoặc `debug_menu=false` | mở Boot/S1/HUD/S11 | không có menu, shortcut, node action hay key path tới C1–C3/fixture recovery. |
| RC-18 | G18 | C3/recovery run mới | đi B/D và kiểm fixture | B cache/D fixture là instance run mới; không có old UID trong inventory/ground/source, lost/left-behind cũ không hồi. |

## 11. Ngoài phạm vi và câu hỏi mở

**Ngoài phạm vi:** code/scene, final Vietnamese copy, QA plan, persistence, Contract 2, C/E, audio, checkpoint, economy, damage/HP/AI tuning, new gear/item, đổi các S02–S04 specs.

1. **Gear baseline có cần ItemDef/ID trước release không?** Mặc định không chặn S05: dùng baseline “weapon một tay + khiên nhẹ” hiện có, không bịa ID. Nếu một card sau thêm gear inventory, card đó phải định nghĩa source/ID/loss semantics riêng.
2. **S10 recovery nên title riêng hay tag nhỏ trên title success hiện có?** Mặc định `SUMMARY_RECOVERY_TITLE` là title variant để player phân biệt run recovery nhưng giữ cùng dữ liệu success; implementation không bị chặn vì key đã được bảng §8 dành sẵn.
3. **Menu fixture nên đặt trong Boot hay một dev overlay?** Mặc định Boot debug-only, vì C0/S1/HUD/S11 người chơi không được thấy và route lifecycle dễ khóa bằng `AppEnv.get_flag`; không thay gameplay state rules.

## 12. Traceability

| Yêu cầu | Phần spec / test |
|---|---|
| G18 — S12, kit, dispatch, placement, E1, extract | §§3–6; RC-01…13 |
| C3 fixture và death thật | §7; RC-16 |
| Build-readiness §8.3 — E0/E1/call/hold/board | §§3, 5; RC-08…09 |
| Build-readiness §8.6 — seal/recovery/lost | §§3–6; RC-01, RC-04…07, RC-10…12 |
| Build-readiness §8.8 — summary boundary | §§3, 8; RC-01…03, RC-09 |
