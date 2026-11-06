# Spec combat tối thiểu + control scheme cảm ứng — vertical slice “Giữ giấy phép” (S03)

**Trạng thái:** spec hệ thống `proposed` cho gameplay-engineer (TASK-87), ai-programmer (TASK-88), technical-artist
(TASK-85 VFX, TASK-86 nhân vật) và ux-designer (TASK-83). **Mọi con số trong file này là `proposed`** (chưa cân bằng,
chưa duyệt); Easy cố định, không có Hard/Extreme. Định danh `tax_guard` / `foreman` là `proposed` cho tới khi Producer
đưa vào glossary.

**Nguồn ràng buộc (ưu tiên khi file này khác):** [vertical slice](../vertical-slice.md) Beat 3, 6, 7, §5 ·
[build-readiness](../vertical-slice-build-readiness.md) G6, G12, G14, invariant §8.7 ·
[encounter brief B](../maps/black-tax-port-b-encounter-brief.md) §3–§5 ·
[beacon/extract](beacon-extract-state-spec.md) §3, §4.3, §6, §8, §9 · [UX loop A](loop-a-ux-flow-spec.md) §3 ·
[lưới inventory](inventory-grid-slice-spec.md) §2, §8.4 · [Art Bible](../art/ART_BIBLE.md) §3, §4, §5.

## 0. Mục đích (phía người chơi)

Người chơi học **một** câu: *“Nguy hiểm đến từ lane nào, và tôi tránh/chặn nó bằng gì?”* Mỗi đòn địch được báo trước
bằng hình trên sàn + tư thế + vị trí, đủ lâu để phản ứng bằng một trong ba hành động: **đánh**, **né**, **khiên**; thêm
một lần **dùng thuốc** để sửa sai. Không combo, không stamina, không ammo, không vũ khí thứ hai.

| Có trong spec | Không có (thuộc card khác hoặc ngoài slice) |
|---|---|
| 4 action của Người Thu Hồi, InputMap, HP/thuốc, stub HP 0; 2 vai địch `tax_guard`, `foreman` (+ biến thể patrol của `tax_guard`); đợt địch lane B lúc giữ khu; 3 VFX telegraph; danh sách animation logic | Toạ độ khu B, cover, marker, điều kiện mở gate (TASK-81); luật loot (TASK-82); vị trí/hình nút, HUD (TASK-83); mọi chữ hiển thị (TASK-84); âm thanh (không có ở S03); death/recovery thật, S11 (S04); boss/elite, vai địch thứ ba |

## 1. Thuật ngữ và định danh mới (`proposed`)

| Tên | Code | Nghĩa |
|---|---|---|
| Vệ binh thuế khiên nhẹ | `tax_guard` | Vai địch giữ ngõ, có khiên chặn phía trước. |
| Đốc công | `foreman` | Vai địch charge thẳng theo một lane cố định. |
| Gói Băng Muối | `sling_remedy` | Vật hồi phục 1x1 trong túi đeo chéo (đã có trong code, key `ITEM_SLING_REMEDY_NAME`). |
| Mặt hướng | `facing` | Hướng nhìn của nhân vật trên mặt XZ (vector đơn vị). |
| Cung trước | `front_arc` | Góc quanh `facing` mà khiên/đòn có hiệu lực. |
| Wind-up | `windup` | Pha báo trước của đòn địch; không gây sát thương. |
| Lane charge | `charge_lane` | Hình chữ nhật cố định trên sàn mà `foreman` charge dọc theo. |
| Lượt tấn công | `attack_token` | Quyền duy nhất cho một địch được ở pha `windup`/đòn tại một thời điểm. |
| Áp lực lane đã giải | `lane_pressure_resolved` | Mọi vai của encounter đều ở `withdrawn` hoặc `down`. |
| Đạo diễn lane B lúc hold | `hold_lane_b_director` | Đưa đợt địch lane B tới A trong S8. |
| Vòng giữ ngõ | `guard_hold_ring` | VFX telegraph của `tax_guard`. |
| Vạch lane charge | `charge_lane_stripe` | VFX telegraph của `foreman`. |
| Đèn báo lane B | `lane_b_alert_lamp` | VFX/đèn báo trước đợt địch lúc hold. |
| Kết thúc stub HP 0 | `combat_stub_end` | Kết thúc run S03 khi HP về 0 (§4.4). |

Hằng số viết `UPPER_SNAKE`; engineer đặt chúng trong `Resource` tuning (§9), không rải trong code.

## 2. Luật chung

1. Đơn vị: mét (1 unit = 1 m, Art Bible §2), giây, góc độ (°) trên mặt XZ. HP và sát thương là `int`.
2. Logic combat (người chơi lẫn địch) là GDScript thuần chạy bằng `tick(delta)`; mỗi `tick` kẹp
   `delta = min(delta, COMBAT_MAX_TICK_DELTA)` với `COMBAT_MAX_TICK_DELTA = 0.1` `proposed`, để app xuống nền/giật khung
   không làm một wind-up trôi qua mà người chơi không thấy (cùng tinh thần `MAX_TICK_DELTA` của beacon spec §3).
3. Overlay **không** dừng thế giới (UX loop A §5.7 “O5 không dừng thế giới”, §3.1 R8 “joystick vẫn dùng được”). Khi
   O1–O5 đang mở, xem §3.6.
4. Không âm thanh ở S03. Mọi cảnh báo phải đọc được bằng **hình trên sàn + chuyển động/tư thế + vị trí**; chữ chỉ là kênh
   phụ (TASK-84). Màu cảnh báo chỉ dùng làn `signal_danger` (Art Bible §3); đỏ son của mái B **không** là màu nguy hiểm.
5. **Telegraph trước sát thương:** không đòn địch nào gây sát thương nếu (a) wind-up của nó chưa chạy đủ thời gian ở
   bảng §5, hoặc (b) địch không nằm trong khung camera lúc bắt đầu wind-up (§5.1.4).
6. **Một lượt tấn công:** tại mỗi thời điểm chỉ một địch giữ `attack_token`; địch khác đợi ở `alert`. Token được trả khi
   địch đó vào `recover`, `withdraw`, `down` hoặc mất dấu người chơi. Đây là luật Easy, `proposed`.
7. Không có friendly fire: đòn địch không trúng địch; đòn người chơi chỉ trúng địch.
8. Mỗi đòn (một lần `strike`/`charge`/`slash`) trúng một mục tiêu **tối đa một lần**.

## 3. Người chơi — Người Thu Hồi

### 3.1 Mặt hướng và nhắm

1. `facing` = hướng di chuyển khác 0 gần nhất (camera-relative, như `RetrieverMovement.camera_relative_direction`).
   Lúc vào run: hướng về phía lối B trong camera (TASK-81 đặt marker); nếu không có, `Vector3.FORWARD` của camera chiếu
   xuống XZ.
2. **Chọn một kiểu nhắm cho slice: auto-aim mềm.** Khi bắt đầu `đánh`, nếu có địch *hợp lệ* trong
   `ATTACK_ASSIST_RADIUS = 2.5` m **và** trong cung ±`ATTACK_ASSIST_HALF_ARC = 90`° quanh `facing`, nhân vật quay ngay
   về địch gần nhất trong số đó; nếu không có, đánh theo `facing`. Địch hợp lệ = không ở `withdraw`, `withdrawn`, `down`.
   Không cần đường nhìn cho auto-aim (tầm quá ngắn để cover nằm giữa).
3. `khiên` dùng cùng ý: §3.4.3.

### 3.2 Bảng hành động

| Action | Code InputMap | Kiểu | Thời lượng | Cooldown | Tầm / hướng | Di chuyển trong lúc | Khóa khi overlay mở |
|---|---|---|---|---|---|---|---|
| Đánh (vũ khí một tay) | `combat_attack` | chạm (tap) | windup 0.15 + active 0.10 + recover 0.25 = **0.50 s** | không thêm; đòn kế tiếp chỉ bắt đầu sau recover | cung 120° (±60°) quanh hướng đánh, tầm 1.6 m; auto-aim §3.1.2 | đứng yên trong windup+active; đi 50% tốc độ trong recover | có |
| Né (dash ngang) | `combat_dodge` | chạm | **0.30 s**, quãng 3.0 m | 0.8 s tính từ lúc dash kết thúc | theo joystick nếu `|stick| > 0.2`; joystick trung tính → lùi ngược `facing` | bị thay bằng dash; dừng sớm nếu va tường | có |
| Khiên (khiên nhẹ) | `combat_guard` | **giữ** (nhấn = nâng, nhả = hạ) | nâng 0.10 s rồi giữ bao lâu tùy ý | không | chặn đòn đến từ cung ±60° quanh `facing`; `facing` bám địch §3.4.3 | 40% tốc độ, không đổi `facing` theo joystick | có (đang giữ thì hạ) |
| Dùng thuốc | `use_remedy` | chạm | kênh **1.0 s** rồi hồi | không (chỉ có 1 gói) | — | 50% tốc độ | có |

Tốc độ đi gốc là `movement_speed = 4.0` m/s hiện có của `RetrieverController`.

### 3.3 Đánh

1. Chạm `combat_attack` khi state `free` (hoặc trong `attack.recover`, xem 3.3.4) → `attacking`.
2. Pha `active` kiểm mọi hurtbox địch trong hình quạt tầm `ATTACK_RANGE = 1.6` m, cung `ATTACK_ARC = 120`°; mỗi địch
   nhận một `HitInfo` (§8) với `damage = ATTACK_DAMAGE = 20`, `kind = &"retriever_slash"`, `origin = vị trí người chơi`.
3. Đòn người chơi **không** ngắt wind-up của địch (địch không bị choáng); địch chỉ chơi animation `hit` cộng thêm.
4. Bộ đệm input: một lần chạm `combat_attack` hoặc `combat_dodge` trong `INPUT_BUFFER_SECONDS = 0.15` cuối của
   một hành động được giữ lại và chạy ngay khi hành động đó kết thúc. Chỉ giữ một lệnh (lệnh sau thay lệnh trước).
5. `combat_dodge` hủy được `attack.recover` (không hủy được windup/active).
6. Đánh vào `tax_guard` trong cung khiên của nó khi khiên đang nâng → bị chặn (§5.2.5); người chơi bị đẩy lùi 0.3 m,
   không mất HP.

### 3.4 Né và khiên

1. **Né:** trong `DODGE_IFRAME_SECONDS = 0.25` đầu của dash, mọi `HitInfo` tới người chơi bị bỏ qua (`ignored: iframe`).
   Dash dùng `move_and_slide`: va tường thì dừng, không xuyên cover. Dash ra khỏi `BeaconZoneA` trong S8 tạm dừng đồng
   hồ đúng như beacon spec §6 (không có ngoại lệ cho combat).
2. Quãng dash 3.0 m > nửa rộng lane charge (0.8 m) + bán kính người chơi (0.4 m): dash ngang từ giữa lane luôn ra khỏi
   lane nếu không có tường chặn (TASK-81 phải để ≥ 1.5 m sàn trống hai bên lane, §6.3).
3. **Khiên:** khi nhấn, trong 0.10 s đầu (`GUARD_RAISE_SECONDS`) chưa chặn. Sau đó `facing` tự quay (tốc độ 360°/s) về
   địch đang `alert`/`windup`/đòn gần nhất trong `GUARD_TRACK_RADIUS = 6.0` m; không có địch như vậy → `facing` giữ
   nguyên. Joystick chỉ dịch chuyển (đi ngang), không xoay.
4. Một `HitInfo` bị khiên chặn khi: khiên đã nâng xong **và** góc giữa `facing` và vector (người chơi → `origin` của
   đòn) ≤ `GUARD_HALF_ARC = 60`°. Chặn → nhận `floor(damage × chip_ratio)`, không vào `hitstun`, chơi `guard_hit`:
   - đòn `tax_guard`: `chip_ratio = 0.0` (chặn hoàn toàn);
   - charge `foreman`: `chip_ratio = 0.3` (30 → 9 HP) + đẩy lùi 1.5 m theo hướng charge. Chặn được nhưng tệ hơn né:
     đó là bài học “dash ngang”.
5. Khi đang giữ khiên: không đánh, không dùng thuốc (input bị bỏ qua, không đệm). `combat_dodge` được: hạ khiên và dash;
   nếu nút khiên còn được giữ khi dash xong, khiên nâng lại (lại mất 0.10 s).
6. Khiên không có độ bền/stamina trong slice.

### 3.5 Dùng thuốc (`sling_remedy`)

1. Chạm `use_remedy` khi `free` → kiểm điều kiện theo thứ tự, trả lý do đầu tiên sai (để HUD TASK-83 hiện):
   1. overlay đang mở → `&"overlay_open"` (thực tế input đã bị khóa, lý do chỉ cho test);
   2. không có `sling_remedy` trong `sling_pouch` → `&"no_remedy"`;
   3. `hp == max_hp` → `&"hp_full"`.
   Sai → không làm gì, không tiêu thuốc.
2. Đúng → state `using_remedy` trong `REMEDY_USE_SECONDS = 1.0` (animation `use_remedy`, đi 50% tốc độ).
3. Bị ngắt (thuốc **không** bị tiêu) khi: nhận sát thương thực > 0 (không tính đòn bị chặn hoàn toàn hay bị i-frame),
   hoặc người chơi bấm `combat_dodge` / `combat_guard`, hoặc overlay mở, hoặc HP về 0.
4. Hết 1.0 s không bị ngắt → gọi `RetrieverInventory.consume(uid)` (hàm **mới**, chỉ thêm; xem §8.3) rồi
   `heal(REMEDY_HEAL = 40)`, kẹp ở `max_hp`. Thứ tự: tiêu item thành công trước, rồi mới hồi; tiêu fail → không hồi.
5. `starter_remedy` đã niêm trong Hộp **không** dùng được trong run S03 (rút đồ niêm chỉ có ở S04; inventory spec §5).
   Vì vậy slice S03 có đúng **một** lần hồi. Xem §12 câu hỏi 3.

### 3.6 Khóa khi overlay mở

1. Khi bất kỳ O1–O5 hoặc S1/S10 đang mở: `combat_attack`, `combat_dodge`, `combat_guard`, `use_remedy` bị bỏ qua (kể cả
   phím/tay cầm). Joystick vẫn dùng được (UX loop A R6).
2. Lúc overlay mở: khiên đang giữ bị hạ; kênh thuốc bị hủy (không tiêu); đòn đang ở windup/active vẫn chạy nốt; dash
   đang chạy vẫn chạy nốt; bộ đệm input bị xóa.
3. Thế giới vẫn chạy: địch vẫn có thể tấn công. Overlay đóng bằng một chạm/Back (UX loop A §3.2.8). Không tự đóng
   overlay khi bị tấn công (trừ HP 0, §4.4). HUD TASK-83 cần cue “nguy hiểm gần” khi overlay che telegraph (§12 câu 2).

### 3.7 State người chơi

| State | Vào khi | Ra khi |
|---|---|---|
| `free` | mặc định | action hợp lệ / bị đánh / HP 0 |
| `attacking` (`windup` → `active` → `recover`) | `combat_attack` | hết 0.50 s → `free`; dodge trong `recover` → `dodging`; bị đánh → `hitstun` |
| `dodging` | `combat_dodge` khi `free`/`attack.recover`/`guarding`, cooldown xong | hết 0.30 s → `guarding` nếu nút khiên còn giữ, không thì `free` |
| `guarding` (`raising` → `raised`) | nhấn `combat_guard` khi `free` | nhả → `free`; dodge → `dodging`; overlay mở → `free`; đòn không chặn được → `hitstun` |
| `using_remedy` | §3.5 | xong/ngắt → `free` (ngắt do sát thương → `hitstun`) |
| `hitstun` | nhận sát thương thực > 0 không bị chặn | sau `HITSTUN_SECONDS = 0.3` → `free` (khiên còn giữ → `guarding`) |
| `depleted` | HP về 0 | không ra; §4.4 |

Sau một lần nhận sát thương thực, người chơi miễn sát thương thêm `POST_HIT_INVULN_SECONDS = 0.5` (`ignored:
post_hit`), để hai địch hoặc một hitbox kéo dài không trừ HP chồng.

## 4. Máu, hồi phục, HP 0

### 4.1 Số liệu (`proposed`, chưa cân bằng)

| Hằng số | Giá trị | Ghi chú |
|---|---|---|
| `RETRIEVER_MAX_HP` | 100 | HP lúc vào run luôn đầy. |
| `REMEDY_HEAL` | 40 | Một `sling_remedy`. |
| `REMEDY_USE_SECONDS` | 1.0 | Bị ngắt theo §3.5.3. |
| Hồi máu tự nhiên | **không** | Không hồi theo thời gian, không hồi khi vào vùng yên hay khi gọi thuyền. Lý do: thuốc là quyết định có giá. |
| `TAX_GUARD_STRIKE_DAMAGE` | 15 | ~7 đòn không chặn mới hết máu. |
| `FOREMAN_CHARGE_DAMAGE` | 30 | Chặn bằng khiên: 9. |
| `ATTACK_DAMAGE` (người chơi) | 20 | |

### 4.2 Luật HP

1. `Health.damage(n)`: `n ≤ 0` bỏ qua; `hp = max(0, hp − n)`; phát `changed(hp, max_hp)` nếu đổi.
2. `Health.heal(n)`: `n ≤ 0` hoặc `hp == 0` bỏ qua (không hồi sinh); `hp = min(max_hp, hp + n)`; phát `changed`.
3. `hp` từ > 0 về 0 → phát `depleted()` **đúng một lần**; mọi `damage`/`heal` sau đó bị bỏ qua.

### 4.3 Thứ tự xử lý một `HitInfo` tới người chơi

1. `depleted` → bỏ qua (`ignored: depleted`).
2. trong i-frame dash → `ignored: iframe`.
3. trong `POST_HIT_INVULN_SECONDS` → `ignored: post_hit`.
4. khiên chặn (§3.4.4) → sát thương chip, `blocked = true`.
5. còn lại → sát thương đủ, `hitstun`, ngắt thuốc.

### 4.4 HP về 0 ở S03 = stub (`combat_stub_end`)

**Đây là quyết định tạm của Producer cho S03, không phải luật cuối.** S04 thay bằng death/recovery thật (S11/S12).

1. Khi `Health.depleted` của người chơi phát: state `depleted`, chơi animation `down`, khóa mọi input (joystick, combat,
   nút ngữ cảnh, H3); overlay đang mở đóng **như hủy** (không commit gì, UX loop A §5.3 “Chết giữa action”).
2. Gọi `ExtractPierAFlow.notify_death()` nếu flow tồn tại → `ENDED_DEATH` (beacon spec §9): không S10, không
   `extract_succeeded`, nút `Lên thuyền` biến mất.
3. Mọi địch chuyển `idle` tại chỗ và trả token; `hold_lane_b_director` ngừng.
4. **Không** gọi `resolve_death()` hay `resolve_extract()`, không đổi inventory, không lưu gì, không summary.
5. Hiện một dòng chữ (key do TASK-84 viết, đề nghị `COMBAT_STUB_HP_ZERO`) ở R4 trong
   `STUB_END_MESSAGE_SECONDS = 2.5` s, rồi chuyển scene về **Boot** (như `Về hub` của S10). Chạm màn hình không làm nhanh.
6. Trong 2.5 s đó không đòn nào gây thêm sát thương, không tick hold.

## 5. Địch

### 5.1 Luật chung cho cả hai vai

1. **Perception:** người chơi bị “thấy” khi (a) trong `perception_radius` **và** trong cung ±`view_half_arc` quanh
   `facing` của địch **và** có đường nhìn (raycast từ mắt địch cao 1.5 m tới ngực người chơi cao 1.0 m, chỉ va layer
   `world_static`/cover); hoặc (b) trong `PROXIMITY_RADIUS = 2.0` m có đường nhìn (bất kể cung); hoặc (c) địch vừa bị
   người chơi đánh trúng.
2. **Mất dấu:** không thấy liên tục `LOSE_TRACK_SECONDS = 4.0` → trả token, đi về điểm gốc (post / đầu lane), `idle`.
   HP **không** hồi khi về gốc.
3. **Không đuổi ra khỏi vùng của mình:** mỗi vai có leash (bảng). Ra khỏi leash thì dừng ở mép leash, tiếp tục `alert`
   tại chỗ. Người chơi lùi về A không bị đuổi theo (encounter brief §3.1).
4. **Trong khung camera:** địch chỉ được bắt đầu `windup` khi tâm của nó nằm trong viewport camera với lề trong
   `ON_CAMERA_INSET = 0.05` (5% mỗi cạnh). Ngoài khung → chỉ được `alert`/di chuyển.
5. **Chuỗi tấn công:** `alert` → (đủ điều kiện đòn + có token + trong khung camera) → `windup` (telegraph chạy) →
   đòn (`strike`/`charge`) → `recover` → `alert`. Wind-up đã bắt đầu thì **luôn** chạy hết và ra đòn theo hình đã báo
   (không đổi hướng, không hủy giữa chừng), trừ khi địch vào `down` hoặc stub §4.4.
6. **Rút lui:** khi `hp ≤ ceil(max_hp × WITHDRAW_HP_RATIO)` với `WITHDRAW_HP_RATIO = 0.34`, sau khi đòn/recover hiện
   tại xong → `withdraw`: trả token, tắt telegraph, đi tới marker `WithdrawPoint` của vai đó (TASK-81) với tốc độ đi, rồi
   `withdrawn` (đứng yên, không perception, không tấn công, quay mặt khỏi lane). Ở `withdraw`/`withdrawn` vẫn nhận đòn
   (không đánh trả); HP 0 → `down`.
7. **`down`:** tắt collision với người chơi và hurtbox, xác nằm lại (animation `down`), không loot (TASK-82 quyết), không
   tương tác.
8. Mỗi vai phát signal: `alerted`, `windup_started(attack_kind, duration)`, `attack_released(attack_kind)`,
   `withdrew`, `downed`. `is_lane_pressure_resolved()` trả `true` khi state ∈ {`withdrawn`, `down`}. **Điều kiện mở gate
   B do TASK-81 chốt** dựa trên hàm này; không có kill count.
9. Lần đầu mỗi vai vào `alert` trong run: phát `role_first_seen(role_id)` để UX/TASK-84 hiện tối đa **một** prompt cho
   vai đó (vertical slice §5.1).

### 5.2 `tax_guard` — Vệ binh thuế khiên nhẹ

| Trường | Giá trị `proposed` |
|---|---|
| `max_hp` | 60 (3 đòn; rút lui sau đòn thứ 2 vì 20 ≤ ceil(60 × 0.34) = 21) |
| `move_speed` | 1.6 m/s (đi), quay 270°/s |
| `perception_radius` / `view_half_arc` | 6.0 m / 60° (cung 120°), cần đường nhìn |
| Điểm gốc / leash | marker `GuardPost` (TASK-81); `LEASH_RADIUS = 3.0` m quanh post |
| `HOLD_RING_RADIUS` | 2.5 m quanh post (vòng giữ ngõ, chỉ là cue, không phải hitbox) |
| Điều kiện đòn | người chơi trong `STRIKE_RANGE = 1.8` m và trong cung ±50° |
| `windup` | **0.8 s** (≥ 0.6) |
| `strike` (active) | 0.15 s; hình quạt tầm 1.8 m, cung 100° (±50°) theo `facing` lúc bắt đầu windup; `damage = 15` |
| `recover` | 0.9 s; **khiên hạ** |
| Khoảng tối thiểu giữa hai lần bắt đầu windup | 2.0 s |
| Khiên | chặn đòn người chơi có `origin` trong ±60° quanh `facing` khi state ∈ {`idle`, `alert`, `windup`}; **không** chặn ở `strike`, `recover`, `withdraw`, `withdrawn`, hay từ hông/sau |

1. `idle`: đứng ở post, `facing` dọc lane được giữ (marker hướng của TASK-81), khiên nâng.
2. `alert`: quay về người chơi, đứng trong leash, `guard_hold_ring` bật ở mode `hold`. Nếu người chơi trong leash nhưng
   ngoài `STRIKE_RANGE`, tiến lại gần (không ra ngoài leash).
3. `windup` 0.8 s: hạ người, kéo khiên về sau (tư thế khác rõ `idle`); `guard_hold_ring.show_strike_arc(100, 1.8)` và
   `set_strike_progress(t)` 0→1.
4. `strike` 0.15 s: đòn đập khiên; `HitInfo{kind=&"guard_strike", damage=15, blockable=true}`.
5. `recover` 0.9 s: khiên hạ (cửa sổ phản đòn trực diện), quạt tắt, vòng về mode `hold`.
6. Counterplay đọc được: (a) giữ khiên chặn hết đòn, phản đòn trong `recover`; (b) né ra ngoài tầm/quạt; (c) đi vòng ra
   hông/sau để đánh không bị khiên chặn; (d) lùi khỏi leash về A.

### 5.3 `tax_guard` biến thể patrol (beat B → A)

Không phải vai mới: cùng `tax_guard`, khác điểm gốc.

1. Khi được kích hoạt (TASK-81/90 quyết thời điểm: sau vùng yên — quyết định Producer S03 §1): bắt đầu cue patrol
   **`PATROL_CUE_LEAD = 2.0` s trước** khi nó vào khung camera — `guard_hold_ring` mode `patrol` đi kèm và phát
   `patrol_cue_started` — rồi đi theo `PatrolReturnPath` ở 1.6 m/s, lặp đi lặp lại giữa hai đầu path.
2. Khi thấy người chơi: điểm gốc của nó trở thành vị trí hiện tại (post tạm), leash 3.0 m; hành xử như §5.2. Mất dấu →
   tiếp tục path từ điểm gần nhất.
3. Số lượng: **1** `proposed`. Không spawn phía sau người chơi; path nằm trên lane B → A mà người chơi nhìn thấy trước.

### 5.4 `foreman` — Đốc công

| Trường | Giá trị `proposed` |
|---|---|
| `max_hp` | 90 (rút lui sau đòn thứ 3 vì 30 ≤ ceil(90 × 0.34) = 31) |
| `move_speed` | 1.8 m/s (đi); charge 9.0 m/s |
| `perception_radius` / `view_half_arc` | 9.0 m / 70° (cung 140°), cần đường nhìn |
| Lane | marker `ForemanChargeLane` (TASK-81): hai đầu `end_a`, `end_b`; `CHARGE_LANE_WIDTH = 1.6` m (hình vẽ); độ dài do TASK-81, khuyến nghị 7–10 m |
| Hitbox charge | hộp rộng `CHARGE_HITBOX_WIDTH = 1.2` m (hẹp hơn vạch vẽ), sâu 0.8 m trước thân, di chuyển cùng `foreman` |
| Điều kiện charge | người chơi được thấy **và** tâm người chơi nằm trong hình chữ nhật lane (rộng 1.6 m + lề `LANE_TRIGGER_MARGIN = 0.4` m mỗi bên) **và** `foreman` đang đứng ở một đầu lane, quay về đầu kia |
| `windup` | **1.0 s** (≥ 0.6) |
| `charge` | từ đầu đang đứng tới đầu kia, thẳng, không đổi hướng; `damage = 30`, `blockable = true` (chip 0.3) |
| `recover` | 1.5 s (thở dốc, đứng yên: cửa sổ đánh) |
| Khoảng tối thiểu giữa hai lần windup | 2.5 s |
| Leash | chính lane + 1.5 m quanh nó |

1. `idle`: đứng ở `end_a`, quay dọc lane.
2. `alert`: quay về phía người chơi trong phạm vi lane; nếu không đứng ở một đầu lane thì đi về đầu gần nhất. Nếu người
   chơi áp sát ≤ 1.5 m mà **không** ở trong lane, `foreman` lùi về đầu lane gần nhất (không có đòn cận chiến thứ hai).
3. `windup` 1.0 s: cúi người, dậm chân/cào đất tại chỗ, `charge_lane_stripe.set_lane(...)` + `set_progress(t)` 0→1;
   hướng charge chốt lúc bắt đầu windup (từ đầu đang đứng sang đầu kia).
4. `charge`: dừng tại điểm **sớm nhất** trong:
   1. **trượt** — tới đầu kia của lane: dừng đúng tại marker đầu kia (`end_b` hoặc `end_a`), vào `recover`; lần charge
      sau sẽ theo chiều ngược lại;
   2. **trúng người chơi không chặn** — người chơi nhận 30 + đẩy 2.0 m ra **ngang** khỏi lane (phía gần hơn), `foreman`
      dừng tại chỗ va, vào `recover`;
   3. **bị khiên chặn** — người chơi nhận 9 + đẩy lùi 1.5 m theo hướng charge, `foreman` dừng tại chỗ va, `recover`
      (animation `stagger`);
   4. **va collision tĩnh** (cover/tường lọt vào lane) — dừng tại chỗ va, `recover`.
   Charge bỏ qua thân các địch khác (collision exception), không trúng chúng.
5. `recover` 1.5 s xong: nếu không ở đầu lane, đi về đầu lane gần nhất trước khi được windup lần sau.
6. Counterplay đọc được: (a) **dash ngang** ra khỏi lane trong windup hoặc đầu charge; (b) đứng ngoài lane — `foreman`
   không bao giờ charge người ngoài lane; (c) giữ khiên (mất 9); (d) đánh trong `recover`.

### 5.5 State machine chung (cả hai vai)

```text
idle ──thấy──▶ alert ──đủ điều kiện + token + trong khung camera──▶ windup ──hết giờ──▶ strike|charge ──▶ recover
 ▲               │  ▲                                                                                      │
 │               │  └───────────────────────────────── hết recover ◀───────────────────────────────────────┘
 └──mất dấu 4 s──┘
bất kỳ state sống ──hp ≤ ngưỡng (sau đòn/recover)──▶ withdraw ──tới WithdrawPoint──▶ withdrawn
bất kỳ ──hp = 0──▶ down          bất kỳ ──stub §4.4──▶ idle (đóng băng)
patrol (chỉ tax_guard §5.3) ──thấy──▶ alert   ·   alert ──mất dấu──▶ patrol
```

## 6. Telegraph và VFX (cho TASK-85)

### 6.1 Luật telegraph

1. Mỗi đòn địch có **ít nhất ba kênh ngoài màu**: hình trên sàn (shape) · tư thế/chuyển động wind-up · vị trí (địch trong
   khung camera, trước mặt, lane cố định). Màu chỉ là kênh thứ tư (`signal_danger`).
2. Hình trên sàn luôn **phủ trùm** hitbox thật (quạt vẽ ≥ quạt đòn; vạch lane 1.6 m ≥ hitbox 1.2 m).
3. Không nhấp nháy (UX loop A §3.2.6): tiến độ thể hiện bằng **lấp đầy dần** (fill/chevron tiến), không bằng chớp.
4. Vật liệu VFX dùng tiền tố `signal_` (chỉ vật liệu `signal_`/`light_` được emission — MAT-05); unshaded hoặc toon,
   không bloom (ENV-01). Vùng sàn chứa telegraph không có vệt đục WC-02 và không decal làm nhiễu (Art Bible §4).
5. Phải đọc được ở ảnh thang xám: viền telegraph có value tương phản với sàn B (sàn trung, viền sáng ≥ 70% hoặc nét mực).

### 6.2 Ba VFX

| VFX | Node đề xuất | Hình | API tham số |
|---|---|---|---|
| **Vòng giữ ngõ** `guard_hold_ring` | `TelegraphHoldRing` (Node3D, decal/mesh phẳng trên sàn) | Vòng tròn quanh post bán kính `HOLD_RING_RADIUS`. Mode `patrol`: **nét đứt**, không fill, đi theo địch. Mode `hold`: nét liền + vạch gạch ngắn hướng vào trong, cố định quanh post. Khi windup: thêm **quạt** (wedge) trước mặt địch, viền đủ ngay từ đầu, fill quét từ thân địch ra mép trong 0→1. | `set_radius(r: float)`, `set_mode(mode: StringName)` (`&"off"`, `&"patrol"`, `&"hold"`), `show_strike_arc(arc_deg: float, range_m: float)`, `set_strike_progress(t: float)` (0..1, kẹp), `hide_strike_arc()` |
| **Vạch lane charge** `charge_lane_stripe` | `TelegraphChargeLane` | Hình chữ nhật dài × rộng trên sàn: viền liền hai cạnh dài + dãy **chevron** chỉ hướng charge. `progress` 0 = chỉ viền; tăng dần chevron được tô từ đầu `foreman` đứng về đầu kia; 1 = tô đủ đúng lúc charge bắt đầu. Trong charge giữ 1; khi `foreman` dừng, tắt dần 0.2 s (một lần, không chớp). | `set_lane(origin: Vector3, direction: Vector3, length_m: float, width_m: float)`, `set_progress(t: float)` (0..1, kẹp), `set_active(on: bool)` |
| **Đèn báo lane B** `lane_b_alert_lamp` | `LaneBAlertLamp` (đèn thế giới ở miệng lane B nhìn từ `BeaconZoneA` + mũi tên trên sàn chỉ từ lane B về beacon) | Đèn có **ba cửa chớp/phân đoạn** mở dần theo tiến độ (đếm được bằng mắt, không cần màu), và mũi tên sàn hiện khi `armed`. `active` = cả ba phân đoạn mở + mũi tên đủ, giữ nguyên tới khi tắt. Ánh sáng emission `signal_danger`, không nhấp nháy. | `set_state(state: StringName)` (`&"off"`, `&"armed"`, `&"active"`), `set_progress(t: float)` (0..1 trong `armed`; số phân đoạn mở = `floor(t × 3)`, 1 ⇒ ba phân đoạn), `set_arrow_target(world_pos: Vector3)` |

Các VFX chỉ là hiển thị: logic (TASK-87/88) gọi API; VFX không đọc state combat. Mọi hàm gọi lặp với cùng tham số phải
idempotent; `t` ngoài 0..1 bị kẹp.

## 7. Đợt địch lane B lúc giữ khu (S8)

### 7.1 Luật

1. `hold_lane_b_director` nghe `ExtractPierAFlow.hold_started(seconds)` (chỉ đọc; không sửa flow). Tính thời gian từ
   lúc signal đó phát (`t = 0`), cộng dồn bằng `tick(delta)` kẹp như §2.2. Lần phát thứ hai trong cùng run bị bỏ qua.
2. Đồng hồ director **không** dừng khi hold tạm dừng (người chơi ra khỏi vòng): áp lực lane không phụ thuộc người chơi
   đứng đâu; nhưng mọi địch vẫn theo luật camera/token §2, §5.1.
3. Kịch bản cố định (`EXTRACT_HOLD_SECONDS = 20.0`, beacon spec §3):

| `t` (s) | Sự kiện | Ghi chú |
|---|---|---|
| 0.0 | `lane_b_alert_lamp.set_state(&"armed")`, `set_progress` 0→1 trong `HOLD_CUE_LEAD = 3.0` s; phát `lane_alert_started` (HUD hiện `EXTRACT_S8_LANE_ALERT`) | Cue ≥ 2 s trước khi địch vào khung camera. |
| 3.0 | Lamp `active`. `tax_guard` #H1 **vào khung camera** từ miệng lane B, đi `HoldLaneBPath` tới `HoldGuardPost` (TASK-81: sát mép `BeaconZoneA` phía lane B), rồi hành xử như §5.2 với post đó | Spawn ngoài khung trong lane B ngay trước đó, sao cho bước vào khung đúng `t = 3.0`; không bao giờ spawn trong khung hay phía không phải lane B. |
| 7.0 | Lamp lại `armed`, progress 0→1 trong 3.0 s (đợt hai) | |
| 10.0 | Lamp `active`. `foreman` #H2 vào khung camera từ lane B, đi tới đầu `HoldChargeLane` (TASK-81) và hành xử như §5.4 trên lane đó | Lane hold đi **lệch tâm** qua `BeaconZoneA`, che ≤ 40% diện tích vòng, luôn còn dải ≥ 1.5 m trong vòng ngoài lane. |
| hold xong (`boat_ready`) | Không windup mới; đòn đang chạy xong thì cả hai vào `withdraw` theo `HoldLaneBPath` về lane B; lamp `off` | S9 và `Lên thuyền` **không** bị chặn khi còn địch. |

4. Tổng số địch lúc hold: **2** (`tax_guard` ×1, `foreman` ×1). Không thêm địch nếu người chơi đánh bại chúng sớm.
5. Nếu `ExtractState` là `ENDED_DEATH` (stub §4.4) → director ngừng ngay, không spawn tiếp.
6. Đánh bại/đẩy rút cả hai trước `boat_ready` không làm hold nhanh hơn (hold chỉ là đồng hồ beacon spec).
7. Địch hold không được mở hay đóng bất kỳ state extract nào; chúng chỉ gây sát thương.

## 8. Interface dữ liệu (GDScript, Godot 4.7.2) — `proposed`, không phải code

### 8.1 Lớp

| Lớp | Kế thừa | Vai trò |
|---|---|---|
| `Health` | `RefCounted` | `max_hp: int`, `hp: int`; `damage(n: int) -> int` (lượng thực trừ), `heal(n: int) -> int`, `is_depleted() -> bool`; signals `changed(hp: int, max_hp: int)`, `depleted()` |
| `HitInfo` | `RefCounted` | `source_id: int`, `kind: StringName` (`&"retriever_slash"`, `&"guard_strike"`, `&"foreman_charge"`), `damage: int` (≥ 0), `origin: Vector3`, `direction: Vector3` (hướng đòn, dùng cho đẩy lùi), `knockback_m: float`, `blockable: bool` |
| `HitResult` | `RefCounted` | `applied: int`, `blocked: bool`, `ignored_reason: StringName` (`&""`, `&"iframe"`, `&"post_hit"`, `&"depleted"`, `&"friendly"`) |
| `CombatTarget` (interface/duck-typing) | — | `receive_hit(hit: HitInfo) -> HitResult`, `get_team() -> StringName` (`&"retriever"`, `&"enemy"`), `get_combat_position() -> Vector3` |
| `RetrieverCombat` | `RefCounted` | State §3.7; `tick(delta)`, `press(action: StringName)`, `release(action: StringName)`, `set_overlay_open(open: bool)`, `set_move_input(v: Vector2)`; signals `state_changed(state: StringName)`, `attack_released(hit_targets: Array)`, `remedy_used(healed: int)`, `remedy_refused(reason: StringName)`, `dodge_cooldown_changed(remaining: float)` |
| `EnemyBrain` | `RefCounted` | State §5.5; `tick(delta)`, `set_player(pos: Vector3, visible: bool, on_camera: bool)`; signals §5.1.8 |
| `AttackTokenPool` | `RefCounted` | `try_acquire(enemy_id: int) -> bool`, `release(enemy_id: int)`, `holder() -> int` (0 = trống) |
| `HoldLaneBDirector` | `Node` | §7; `tick(delta)`, `on_hold_started(seconds: float)`, `on_boat_ready()`, `on_run_ended()` |

Scene nhân vật (người chơi + địch) có slot `Visual`; nếu node trong slot có `play_state(name: StringName)` thì gọi với tên
logic §10, không có thì bỏ qua (capsule placeholder vẫn chạy).

### 8.2 Tuning (`Resource`)

| Resource | Trường (kiểu, khoảng hợp lệ để validate) |
|---|---|
| `RetrieverCombatTuning` | `max_hp: int` (1–999) · `attack_damage: int` (0–999) · `attack_windup/active/recover: float` (0.0–2.0) · `attack_range: float` (0.5–4.0) · `attack_arc_deg: float` (10–360) · `assist_radius: float` (0–6) · `assist_half_arc_deg: float` (0–180) · `dodge_duration: float` (0.1–1.0) · `dodge_distance: float` (0.5–6.0) · `dodge_iframe: float` (0–`dodge_duration`) · `dodge_cooldown: float` (0–5) · `guard_raise: float` (0–1) · `guard_half_arc_deg: float` (0–180) · `guard_move_ratio: float` (0–1) · `guard_track_radius: float` (0–12) · `remedy_heal: int` (0–999) · `remedy_use_seconds: float` (0.1–5) · `hitstun: float` (0–2) · `post_hit_invuln: float` (0–3) · `input_buffer: float` (0–0.5) |
| `EnemyRoleDef` | `role_id: StringName` (`&"tax_guard"`, `&"foreman"`) · `max_hp: int` · `move_speed: float` · `perception_radius: float` · `view_half_arc_deg: float` · `leash_radius: float` · `windup_seconds: float` (**≥ 0.6**, validate lỗi nếu nhỏ hơn) · `active_seconds: float` · `recover_seconds: float` · `min_attack_interval: float` · `damage: int` · `attack_range: float` · `attack_arc_deg: float` · `chip_ratio_vs_guard: float` (0–1) · `withdraw_hp_ratio: float` (0–1) · `shield_half_arc_deg: float` (0 = không khiên) · `charge_speed: float` (0 = không charge) · `charge_hitbox_width: float` · `lane_width: float` |
| `HoldWaveDef` | `cue_lead_seconds: float` (**≥ 2.0**) · `entries: Array[Dictionary]` `{role_id: StringName, enter_camera_at: float, path: NodePath, post: NodePath}`; validate: mỗi `enter_camera_at ≥ cue bắt đầu tương ứng + 2.0` và `< EXTRACT_HOLD_SECONDS` |

### 8.3 Hàm inventory mới (chỉ thêm, không đổi hàm cũ)

`RetrieverInventory.preview_consume(uid: int) -> InventoryResult` / `commit_consume(uid: int) -> InventoryResult`:
item phải ở `sling_pouch` và có `item_category == consumable`, nếu không → `WRONG_SOURCE`. `ok` → giảm `quantity` 1;
về 0 thì xóa khỏi lưới và phát `item_removed(uid, &"sling_pouch")`. Đây là thao tác do người chơi kích hoạt (một lệnh
`commit_*`), không vi phạm luật “không tự động” của inventory spec §2.3. Item đã tiêu không vào `kept`/`lost` của bất kỳ
outcome nào.

### 8.4 InputMap

| Action | Bàn phím (staging/web) | Tay cầm | Cảm ứng (vị trí: TASK-83) |
|---|---|---|---|
| `move_left/right/up/down` | A/D/W/S (đã có) | stick trái (thêm) | joystick R6 (đã có) |
| `combat_attack` | **J** (`physical_keycode` 74) | nút trái **X** (`JOY_BUTTON_X` = 2) | nút tap |
| `combat_dodge` | **Space** (32) | nút dưới **A** (`JOY_BUTTON_A` = 0) | nút tap |
| `combat_guard` | **K** (75), giữ | vai phải **RB** (`JOY_BUTTON_RIGHT_SHOULDER` = 10), giữ | nút **giữ**: nhấn = nâng, nhả = hạ |
| `use_remedy` | **Q** (81) | nút trên **Y** (`JOY_BUTTON_Y` = 3) | nút tap, có badge số gói còn lại |

Ràng buộc cho TASK-83 (chỉ chức năng, không vị trí): mỗi nút ≥ 64×64 vùng chạm (UX loop A §3.2.1), dùng song song với
joystick bằng hai ngón; nút khiên giữ trạng thái nhấn theo **ngón đã chạm nó** tới khi ngón đó nhấc (trượt khỏi nút vẫn
giữ khiên), touch bị hủy/app xuống nền = nhả. Đây là thao tác “giữ” đầu tiên của game: UX loop A §3.2.3 (“không giữ lâu ở
S02”) cần cập nhật cho S03. Phím và cảm ứng OR với nhau. Back/Esc không dùng cho combat.

## 9. Bảng hằng số người chơi (tổng hợp, mọi giá trị `proposed`)

| Hằng số | Giá trị | Hằng số | Giá trị |
|---|---|---|---|
| `RETRIEVER_MAX_HP` | 100 | `DODGE_DURATION` | 0.30 s |
| `ATTACK_DAMAGE` | 20 | `DODGE_DISTANCE` | 3.0 m |
| `ATTACK_WINDUP` / `ACTIVE` / `RECOVER` | 0.15 / 0.10 / 0.25 s | `DODGE_IFRAME_SECONDS` | 0.25 s |
| `ATTACK_RANGE` / `ATTACK_ARC` | 1.6 m / 120° | `DODGE_COOLDOWN` | 0.8 s |
| `ATTACK_ASSIST_RADIUS` / `HALF_ARC` | 2.5 m / 90° | `GUARD_RAISE_SECONDS` | 0.10 s |
| `INPUT_BUFFER_SECONDS` | 0.15 s | `GUARD_HALF_ARC` | 60° |
| `HITSTUN_SECONDS` | 0.3 s | `GUARD_MOVE_RATIO` | 0.4 |
| `POST_HIT_INVULN_SECONDS` | 0.5 s | `GUARD_TRACK_RADIUS` | 6.0 m |
| `REMEDY_HEAL` / `REMEDY_USE_SECONDS` | 40 / 1.0 s | `STUB_END_MESSAGE_SECONDS` | 2.5 s |
| `COMBAT_MAX_TICK_DELTA` | 0.1 s | `ON_CAMERA_INSET` | 0.05 |

## 10. Animation tối thiểu (tên logic cho TASK-86)

Tên dưới đây là **tên logic** truyền vào `play_state(name)`. TASK-86 map sang clip gốc của gói CC0; nếu gói không có
clip riêng, dùng clip ở cột “dự phòng” (chuỗi thử theo thứ tự). Clip lặp ghi “loop”.

| Nhân vật | Tên logic | Khi nào | Dự phòng |
|---|---|---|---|
| Retriever | `idle` (loop) | `free`, đứng | — |
| | `run` (loop) | `free`, đang đi | `walk` |
| | `attack` | `attacking` (một lần, 0.5 s) | — |
| | `guard` (loop) | `guarding` | `block`, `idle` |
| | `guard_hit` | khiên chặn đòn | `guard` |
| | `dodge` | `dodging` | `roll`, `run` |
| | `hit` | `hitstun` | — |
| | `use_remedy` | `using_remedy` | `interact`, `idle` |
| | `down` | `depleted` (giữ khung cuối) | `death` |
| `tax_guard` | `idle` (loop) | `idle`/`withdrawn`, khiên nâng | — |
| | `walk` (loop) | patrol, tiến trong leash, `withdraw` | `run` |
| | `alert` (loop) | `alert` đứng | `guard`, `idle` |
| | `windup` | `windup` 0.8 s (kéo khiên về sau, hạ thấp) | `attack` (phát chậm phần đầu) |
| | `strike` | `strike` | `attack` |
| | `recover` | `recover`, khiên hạ | `idle` |
| | `block` | khiên chặn đòn người chơi | `hit` |
| | `hit` | trúng đòn (cộng thêm, không đổi state) | — |
| | `down` | `down` | `death` |
| `foreman` | `idle` (loop) | `idle`/`withdrawn` | — |
| | `walk` (loop) | về đầu lane, `withdraw` | `run` |
| | `alert` (loop) | `alert` | `idle` |
| | `windup` | `windup` 1.0 s (cúi, dậm chân) | `idle` + nghiêng thân (code) |
| | `charge` (loop) | `charge` | `run` |
| | `recover` | `recover` 1.5 s (thở dốc) | `idle` |
| | `stagger` | charge bị khiên chặn | `hit`, `recover` |
| | `hit` | trúng đòn | — |
| | `down` | `down` | `death` |

Tư thế `windup` phải khác `idle`/`alert` rõ ở silhouette (bóng đen ở cỡ điện thoại, Art Bible §4), vì đây là một kênh
telegraph bắt buộc.

## 11. Edge case

1. Hai địch cùng đủ điều kiện windup → chỉ địch lấy được token trước (theo thứ tự `tick`) windup; địch kia đợi.
2. Địch đang giữ token thì `down`/`withdraw`/mất dấu → token được trả trong cùng `tick`.
3. Người chơi dash xuyên qua `foreman` đang charge trong i-frame → không trúng; charge chạy tiếp tới đầu kia.
4. Người chơi rời lane sau khi windup bắt đầu → charge vẫn chạy (hướng đã chốt) và trượt (§5.4.4.1).
5. `foreman` bắt đầu windup khi người chơi trong lane nhưng `tax_guard` đang đứng trong lane → charge xuyên qua thân
   `tax_guard` (không va, không trúng).
6. Người chơi đứng sau `tax_guard` (ngoài cung 100°) lúc strike → không trúng; khiên guard không chặn đòn từ phía sau.
7. HP người chơi = 1, đòn chặn bằng khiên của `foreman` (9) → HP 0 → stub §4.4 (chip có thể giết).
8. Dùng thuốc khi HP 95 → hồi 5 (kẹp 100), gói vẫn bị tiêu.
9. Bị đánh trúng ở 0.9 s của kênh thuốc → hủy, gói **không** mất.
10. Mở O3 giữa lúc `tax_guard` windup → khiên hạ (nếu đang giữ); đòn vẫn ra; đóng O3 bằng một chạm.
11. HP về 0 khi O5 đang mở → O5 đóng như hủy, `notify_death()`; không vào S7.
12. HP về 0 ở S9 khi đã đứng trong `BoardZoneA` → `Lên thuyền` biến mất trong cùng frame; không S10.
13. App xuống nền giữa windup → khi về, mỗi `tick` chỉ tiến ≤ 0.1 s; wind-up vẫn hiện ≥ 0.6 s thời gian game.
14. Người chơi lùi về A trước gate B → `tax_guard`/`foreman` dừng ở mép leash rồi mất dấu, về gốc; không đuổi.
15. `hold_started` phát khi người chơi đang ở ngoài vòng (S8 tạm dừng ngay) → director vẫn chạy kịch bản §7.
16. Người chơi đánh `tax_guard` #H1 tới `withdraw` trước `t = 10` → `foreman` #H2 vẫn vào đúng `t = 10`.
17. Không có `sling_remedy` (người chơi đã dùng) → chạm `use_remedy` trả `no_remedy`, HUD nêu lý do, không animation.
18. Auto-aim với hai địch cùng khoảng cách → chọn địch có góc nhỏ hơn so với `facing`; vẫn bằng → `instance_id` nhỏ hơn.

## 12. Câu hỏi mở (không chặn S03; mặc định ghi bên cạnh)

1. **Thao tác giữ:** khiên là thao tác giữ đầu tiên; UX loop A §3.2.3 nói “không giữ lâu ở S02”. Mặc định: S03 cho phép
   giữ chỉ với nút khiên; TASK-83 cập nhật quy tắc chạm.
2. **Overlay che telegraph:** O3/O4 (R8) che gần hết màn; địch vẫn có thể windup khi overlay mở. Mặc định: giữ luật thế
   giới không dừng + cue HUD “nguy hiểm gần” (TASK-83). Phương án khác cần Producer chọn: cấm địch bắt đầu windup khi
   overlay mở (dễ bị lợi dụng để né đòn).
3. **Thuốc niêm trong Hộp:** `starter_remedy` không dùng được trong run cho tới S04 (rút đồ niêm). Có cần một đường dùng
   trực tiếp từ Hộp không? Mặc định: không — Hộp là bảo hiểm, không phải túi dùng nhanh.
4. **Tên hiển thị** `tax_guard` / `foreman` / prompt combat / dòng stub HP 0: TASK-84.
5. **G14 ghi “light/audio”:** S03 không audio; đèn báo lane B + mũi tên sàn được coi là đủ cue. QA (TASK-91) xác nhận.

## 13. Acceptance test cho engineering

Tên test: `test_cmb_xx_*` (TASK-87, `test_combat*.gd`), `test_enm_xx_*` / `test_hld_xx_*` (TASK-88, `test_enemy*.gd`).
Mọi test dùng logic thuần + `tick(delta)`; “bước 0.05” = gọi `tick(0.05)` lặp.

### 13.1 Người chơi (TASK-87)

| ID | Given | When | Then |
|---|---|---|---|
| CMB-01 | `Health(100)`, hp 100 | `damage(30)`; `damage(0)`; `damage(-5)` | hp 70; `changed` phát đúng 1 lần |
| CMB-02 | hp 10 | `damage(25)` rồi `damage(5)` | hp 0; `depleted` phát đúng 1 lần; lần 2 trả 0 |
| CMB-03 | hp 90 | `heal(40)` | hp 100 (kẹp); trả 10 |
| CMB-04 | hp 0 (depleted) | `heal(40)` | hp 0; không signal |
| CMB-05 | `free`, một địch giả ở 1.2 m, góc 30° so `facing` | `press(combat_attack)`, bước 0.05 tới 0.5 s | đúng 1 `HitInfo` damage 20 tới địch, phát ở khoảng [0.15, 0.25] s; state về `free` sau 0.5 s |
| CMB-06 | địch giả ở 2.0 m góc 80° (trong assist), không địch nào khác | `press(combat_attack)` | `facing` quay về địch trước pha active; địch nhận hit |
| CMB-07 | địch giả ở 2.0 m sau lưng (180°) | `press(combat_attack)` | `facing` không đổi; địch không nhận hit |
| CMB-08 | `free`, joystick (1,0) | `press(combat_dodge)`, bước 0.05 tới 0.3 s | dời ≈ 3.0 m theo hướng camera-relative của (1,0) (sai số 0.05 m, không tường) |
| CMB-09 | đang dodge ở 0.1 s | hit damage 30 | `ignored_reason == iframe`; hp không đổi |
| CMB-10 | dodge vừa kết thúc | `press(combat_dodge)` ở 0.5 s sau | bị bỏ qua (cooldown 0.8); ở 0.85 s → dash |
| CMB-11 | nhấn giữ `combat_guard`, đã 0.15 s, hit `guard_strike` 15 từ origin trước mặt | `receive_hit` | `blocked`, `applied 0`, state vẫn `guarding` |
| CMB-12 | như CMB-11 nhưng origin sau lưng | `receive_hit` | không chặn; `applied 15`; `hitstun` |
| CMB-13 | nhấn giữ `combat_guard` mới 0.05 s | hit `guard_strike` trước mặt | không chặn (chưa nâng xong) |
| CMB-14 | guard đã nâng | hit `foreman_charge` 30 trước mặt | `blocked`, `applied 9` |
| CMB-15 | vừa nhận hit thực | hit thứ hai sau 0.3 s | `ignored_reason == post_hit` |
| CMB-16 | hp 50, túi có 1 `sling_remedy` | `press(use_remedy)`, bước 0.05 tới 1.0 s | `commit_consume` ok; hp 90; túi rỗng; `item_removed(uid, sling_pouch)` 1 lần |
| CMB-17 | hp 50, đang kênh thuốc 0.6 s | hit thực 15 | kênh hủy; túi còn thuốc; hp 35 |
| CMB-18 | hp 100, có thuốc | `press(use_remedy)` | `remedy_refused(hp_full)`; túi không đổi |
| CMB-19 | hp 50, túi rỗng | `press(use_remedy)` | `remedy_refused(no_remedy)` |
| CMB-20 | `set_overlay_open(true)`, đang giữ khiên | `press` mỗi action | khiên hạ; mọi action bị bỏ qua; joystick vẫn đổi vận tốc |
| CMB-21 | đang `attack.recover` | `press(combat_dodge)` | `dodging` ngay |
| CMB-22 | đang `attack.active` (0.2 s), bấm `combat_attack` | bước tới 0.5 s | đòn thứ hai bắt đầu ngay khi đòn đầu xong (buffer); bấm ở 0.2 s và 0.3 s chỉ tạo 1 đòn thêm |
| CMB-23 | InputMap của project | đọc | có `combat_attack` (J, JOY 2), `combat_dodge` (Space, JOY 0), `combat_guard` (K, JOY 10), `use_remedy` (Q, JOY 3) |
| CMB-24 | flow S8, hp 10 | hit thực 15 | `depleted`; `notify_death` gọi 1 lần; không `resolve_death`/`resolve_extract`; snapshot inventory không đổi; sau 2.5 s yêu cầu đổi scene Boot đúng 1 lần |
| CMB-25 | `RetrieverInventory`, item `starter_remedy` ở Hộp | `commit_consume(uid)` | `WRONG_SOURCE`; Hộp không đổi |

### 13.2 Địch (TASK-88)

| ID | Given | When | Then |
|---|---|---|---|
| ENM-01 | `tax_guard` idle, player 5 m trong cung, có LOS | `tick` | `alerted` 1 lần |
| ENM-02 | như ENM-01 nhưng cover chặn raycast | `tick` 2 s | không alert |
| ENM-03 | player 5 m ngoài cung (sau lưng), ngoài 2 m | `tick` | không alert; đưa player vào 1.8 m (LOS) → alert |
| ENM-04 | `tax_guard` alert, player 1.5 m trước mặt, token trống, on_camera | bước 0.05 | `windup_started(guard_strike, 0.8)`; không hit nào trước 0.8 s; hit 15 phát trong [0.8, 0.95] s |
| ENM-05 | như ENM-04 nhưng `on_camera = false` | `tick` 3 s | không windup, không hit |
| ENM-06 | `tax_guard` ở `alert`, hit người chơi từ origin trước mặt | `receive_hit` | blocked, applied 0; từ hông 90° → applied 20 |
| ENM-07 | `tax_guard` ở `recover`, hit trước mặt | `receive_hit` | applied 20 |
| ENM-08 | `tax_guard` hp 60 | nhận 2 hit 20 | sau recover hiện tại → `withdrew`; `is_lane_pressure_resolved()` true khi tới `WithdrawPoint` |
| ENM-09 | player rời leash (post 3 m) | `tick` | guard dừng ở mép leash; sau 4 s không thấy → về post, `idle`, hp giữ nguyên |
| ENM-10 | `foreman` ở `end_a`, player trong lane | bước 0.05 | `windup_started(foreman_charge, 1.0)`; lane stripe nhận `set_progress` tăng đơn điệu 0→1; không hit trước 1.0 s |
| ENM-11 | player ở ngoài lane (cách mép 1.0 m), được thấy | `tick` 5 s | không windup |
| ENM-12 | windup bắt đầu, player rời lane | bước tới hết charge | không hit; `foreman` dừng tại `end_b` (sai số 0.1 m); `recover` 1.5 s |
| ENM-13 | charge trúng player không khiên | — | applied 30; player bị đẩy ngang khỏi lane; foreman dừng tại chỗ va, `recover` |
| ENM-14 | charge trúng player đang khiên trước mặt | — | applied 9; foreman `stagger` → `recover` |
| ENM-15 | hai địch cùng đủ điều kiện | `tick` | chỉ một `windup_started`; địch kia windup chỉ sau khi token trả |
| ENM-16 | `EnemyRoleDef` với `windup_seconds = 0.5` | validate | báo lỗi dữ liệu |
| ENM-17 | patrol `tax_guard` kích hoạt ngoài khung camera | bước 0.05 | `patrol_cue_started` phát ≥ 2.0 s trước khi `on_camera` lần đầu true |
| ENM-18 | mọi role, 1000 bước ngẫu nhiên vị trí player (seed cố định) | ghi mọi hit | mọi hit có `windup_started` của cùng địch trước đó ≥ windup tối thiểu, và địch `on_camera` lúc bắt đầu windup |

### 13.3 Đạo diễn lane B lúc hold (TASK-88)

| ID | Given | When | Then |
|---|---|---|---|
| HLD-01 | director, chưa có `hold_started` | `tick` 30 s | không lamp, không địch |
| HLD-02 | `on_hold_started(20.0)` | bước 0.05 | lamp `armed` ở t=0, progress đạt 1 ở t=3.0; `tax_guard` `on_camera` lần đầu tại t ∈ [3.0, 3.1] |
| HLD-03 | như HLD-02 | bước tới 10.1 | lamp `armed` lại từ t=7; `foreman` on_camera lần đầu t ∈ [10.0, 10.1]; tổng địch = 2 |
| HLD-04 | như HLD-02 | gọi `on_hold_started` lần 2 ở t=5 | không thêm địch, không reset lịch |
| HLD-05 | hold đang chạy, t=15, `foreman` ở windup | `on_boat_ready()` | đòn đang chạy xong; sau đó cả hai `withdraw`; không windup mới; lamp `off` |
| HLD-06 | `boat_ready`, địch còn sống | `can_board()` trong `BoardZoneA` | true (địch không chặn board) |
| HLD-07 | hold đang chạy t=5 | `on_run_ended()` (stub HP 0) | không spawn tiếp `foreman` dù tick tới t=20 |
| HLD-08 | `HoldWaveDef` có entry vào khung trước cue 2.0 s | validate | báo lỗi dữ liệu |

### 13.4 VFX (TASK-85, test scene load)

| ID | Given | When | Then |
|---|---|---|---|
| VFX-01 | `TelegraphChargeLane` | `set_lane(o, d, 8, 1.6)`, `set_progress(-1)`, `set_progress(2)` | không lỗi; progress kẹp 0 và 1 |
| VFX-02 | `TelegraphHoldRing` | lần lượt mọi `set_mode` + `show_strike_arc(100, 1.8)` + `set_strike_progress(0.5)` + `hide_strike_arc()` | không lỗi; vật liệu có tiền tố `signal_` |
| VFX-03 | `LaneBAlertLamp` | `set_state(armed)`, `set_progress(0.34)` | đúng 1 phân đoạn mở; `set_progress(1)` → 3 phân đoạn |
