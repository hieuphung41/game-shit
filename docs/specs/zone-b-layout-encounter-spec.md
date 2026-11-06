# Spec layout + encounter — Chợ Ngập (B), vertical slice “Giữ giấy phép” (S03)

**Trạng thái:** `proposed`. Mọi kích thước, toạ độ, thời gian trong file là `proposed`. Số combat (HP, sát thương, tầm,
wind-up, tốc độ) lấy nguyên từ [combat-slice-spec](combat-slice-spec.md); file này không đổi số nào của nó.
**Nguồn:** [encounter brief B](../maps/black-tax-port-b-encounter-brief.md) ·
[blockout A/B/D](../maps/black-tax-port-vertical-slice-blockout.md) · [vertical slice](../vertical-slice.md) ·
[readiness G6/G12/G14](../vertical-slice-build-readiness.md) · [beacon spec](beacon-extract-state-spec.md) ·
[Art Bible](../art/ART_BIBLE.md) · `game/src/world/zone_a_outer_pier.tscn` (chỉ đọc).

## 0. Vai trò của khu

| Mục | Nội dung |
|---|---|
| Vai trong contract | Route tùy chọn sau Manifest. Rút sớm ở A vẫn là success ngang hàng (brief B §1). |
| Thời lượng ước tính | Lượt đi khoảng 3–5 phút (slice §3, nhịp 3), lượt về A khoảng 1–2 phút |
| Vết thương tại chỗ | Chợ đã ngập nhưng trạm thuế vẫn chắn ngõ. Chi tiết lore do narrative quyết, file này không thêm. |
| Người giữ tại chỗ | `tax_guard` (Vệ binh thuế khiên nhẹ) giữ ngõ, `foreman` (Đốc công) giữ lane trước trạm |
| Mục tiêu | “Qua trạm thuế” (chữ do TASK-84 viết) → gate B → cache ở vùng yên → quay về A |
| Áp lực | Theo thứ tự guard → charge → gate → vùng yên. Lượt về có một patrol báo trước. Lúc hold có đợt địch từ lane B. |
| Dấu vết thấy được | Rào thuế hạ/nâng ở gate, vạch nước trên mặt tiền, lối D bị chặn (cửa song + xích + thiếu ván) |

## 1. Hệ toạ độ, camera, khung đọc

1. **Gốc B:** scene `game/src/world/zone_b_flooded_market.tscn`, root `ZoneBFloodedMarket` (Node3D). Khi chạy, gameplay
   (TASK-90) đặt root tại **world (7.0, 0, −2.45)** so với gốc khu A, **không xoay**. Toạ độ “B” trong file này là toạ
   độ local của root: **world = B + (7.0, 0, −2.45)**. Mặt sàn B ở y = 0.09, bằng mặt `PierDeck` của A. Phần sàn B
   chồng lên deck A thì hạ 0.01 m để không bị z-fight.
2. **Camera (đo từ code S02):** `CameraIsometric` trực giao, pitch −30°, yaw 45°, `size` 20 m (giữ chiều cao). Camera bám
   thân người chơi với offset không đổi **(15.45, 13.05, 11.6)**. Offset này bằng vị trí camera (14, 14, 14) trừ vị trí
   spawn của Retriever (−1.45, 0.95, 2.4).
3. **Quy đổi sang màn hình.** Với điểm sàn lệch (gx, gz) so với chân người chơi:
   - lệch ngang `L = 0.707·(gx − gz)`, dương là sang phải;
   - lệch sâu `D = −0.707·(gx + gz)`, dương là lên trên;
   - trên màn hình, 1 m của D chỉ cao 0.5 m. Vật cao h được đẩy lên thêm 0.866·h.
   - Đi về −z trên sàn là đi chéo **lên-phải** trên màn hình. Đi về +z (về A) là đi chéo **xuống-trái**.
4. **Khung camera** (inset 5% theo `ON_CAMERA_INSET`), tính bằng mét sàn quanh chân người chơi. Theo chiều sâu, khung
   luôn là D ∈ [−13.0, +22.9]. Theo chiều ngang, khung đổi theo tỉ lệ màn hình:

   | Tỉ lệ màn hình | L (ngang) |
   |---|---|
   | 4:3 | [−9.3, +14.7] |
   | 16:9 | [−13.3, +18.7] |
   | 19.5:9 | [−16.8, +22.2] |
   | 21:9 | [−18.3, +23.7] |

   Mọi kiểm tra “trong khung” dưới đây dùng **4:3** (khung hẹp nhất), nên đúng với mọi tỉ lệ rộng hơn.
   **Viewport thật** (không inset) rộng hơn khung trên 5% mỗi cạnh: D ∈ [−15.1, +24.9]; L ∈ [−10.6, +16.1] (4:3) …
   [−20.6, +26.1] (21:9). Mọi kiểm tra “ngoài màn hình” (điểm spawn, không pop-in) dùng **viewport thật 21:9 + 0.5 m**.
5. **Luật che khuất.** Vật cao h che phần sàn nằm sau nó, dài 1.73·h m về hướng (−x, −z), tức là phía trên màn hình.
   Từ đó có ba luật:
   - Vật cao > 1.0 m chỉ được đặt ở **mép tây** (x nhỏ) của dải chơi.
   - Mép đông (x lớn) và mọi vật nằm ngang đường đi chỉ cao ≤ 1.0 m.
   - Vật ≥ 1.0 m trong dải chơi phải mờ dần khi che người chơi, địch hoặc telegraph (brief B §5, blockout §3.1).
6. **Hai cao độ đọc được:** sàn chợ (y 0.09) và mặt nước thấp hơn. Không có tầng, bậc hay nhảy.

## 2. Nối A ↔ B

| Mục | Giá trị `proposed` |
|---|---|
| Kiểu nối | Đi bộ liền, **không màn tải**. Scene B được nạp cùng A ngay đầu run. |
| Chỗ nối `SeamAB` | Mép đông deck A (world x = 7.0) ↔ sân đầu chợ B. Lối mở rộng **3.0 m**, từ B (0, −1.5) tới B (0, +1.5), tức world z từ −3.95 tới −0.95. Đối diện `RouteToB` (world (5.3, −2.45), tức B (−1.7, 0)). |
| Hai bên lối mở | Có lan can dây thấp 0.5 m, nằm trong scene B. Không sửa A. Deck A hiện chưa có collision ở mép: ghi cho TASK-85/90 ở §9. |
| Hướng nhìn đầu run | `facing` ban đầu (combat §3.1.1) hướng về `RouteToB` (đã có trong A). Không thêm marker mới. |
| Lối D bị chặn (`BlockedRouteD`) | Ở đầu bắc vùng yên, B (3.5…6.0, −32.0). Người chơi đọc được là lối đóng nhờ cửa song gỗ đóng, xích và thẻ niêm thuế. Sau cửa là một khe nước 1.5 m thiếu ván, xa hơn là silhouette lồng kho D. Không prompt, không marker, không vật liệu `signal_`, không collision lừa. Lối này mở ở S04. |

## 3. Sơ đồ (nhìn từ trên, theo trục B)

Mỗi ký tự rộng 0.5 m theo x (từ −2.0 tới 9.5). Mỗi dòng cao 1 m theo z, nhãn ở đầu dòng. Bắc (−z) ở trên. Khi lên màn
hình, phía trên của sơ đồ thành **chéo lên-phải** (↗), còn camera nhìn về ↖ của sơ đồ. Toạ độ chuẩn nằm ở bảng §4;
hình vẽ chỉ để minh hoạ.

```text
  z     x: -2  0   2   4   6   8
 -34   ~~~~~~~~~~~~~~~~~~~~~~~~      ~ nước        # mặt tiền cao (tây)   : lan can thấp ≤0.6 m
 -32   ~~~~#######DDDDDD###~~~~      D lối D bị chặn (cửa song + xích)    - rào thuế 1.0 m
 -31   ~~~~##==============:~~~      = sàn yên (không decal/vệt đục)      . sàn thường
 -30   ~~~~##KK============:~~~      K CacheB        o tâm CalmZoneB      S biển chỉ về A
 -29   ~~~~##KK=====o======:~~~      X GateB (thanh chắn)                 W WithdrawPoint
 -28   ~~~~##==============:~~~      F/f ForemanChargeLane end_a/end_b     L lane vẽ 1.6 m
 -27   ~~~~##==============:~~~      G GuardPost     1-4 CoverB1…B4       p PatrolReturnPath
 -26   ~~~~##===S==========:~~~      ! đèn báo (lamp)  * đèn lồng mái đỏ   h HoldLaneBPath
 -25   ~~~~##-----XXXXX----:~~~      E BEntry   R RouteToB (A)   A deck A
 -24   ~~~~.W..==========h.:~~~
 -23   ~~~~....=====F====..:~~~
 -22   ~~~~##..===LLLL===..:~~~
 -21   ~~~~##33===LLLL===..:~~~
 -20   ~~~~##33===LLLL===..:~~~
 -19   ~~~~##..==pLLLL===.4:~~~
 -18   ~~~~#!..===LLLL===.4:~~~
 -17   ~~~~##..===LLLL===.4:~~~
 -16   ~~~~##22===LLLL===..:~~~
 -15   ~~~~##22===LLLL===..:~~~
 -14   ~~~~##..===LLLL===..:~~~
 -13   ~~~~##..=====f====..:~~~
 -12   ~~~~##..==========..:~~~
 -11   ~~~~##..............:~~~
 -10   ~~~~##.W==========:~~~~~
  -9   ~~~~##..==========:~~~~~
  -8   ~~~~####===h=G====:~~~~~
  -7   ~~~~####==========:~~~~~
  -6   ~~~~####==p=======:~~~~~
  -5   ~~~~####==========:~~~~~
  -4   ~~~~##*............:~~~~
  -3   ~~~~:...111........:~~~~
  -2   AA!A:..............:~~~~
  -1   AAAA......E........:~~~~
   0   RAAA....h..........:~~~~
  +1   AAAA..............p:~~~~
  +2   AAAA::::::::::::::::~~~~
```

| Đoạn | Phạm vi B (x; z) | Rộng đi được | Ghi chú |
|---|---|---|---|
| Sân đầu chợ | x 0–7.5; z +1.5…−4 | 7.5 m | Nối A. Ngoài tầm thấy (6 m) của vệ binh. Là điểm nghỉ. |
| Ngõ trạm thuế | x 2–7; z −4…−11 | 5.0 m | Chokepoint thứ nhất. Mặt tiền tây cao, mép đông là quầy/lan can 0.6 m. |
| Quảng chợ (lane) | x 1–8; z −11…−25 | 7.0 m | Lane charge chạy dọc giữa, hai bên còn 2.7 m sàn trống. |
| Rào thuế + GateB | z −25; lối mở x 3.25–5.75 | 2.5 m | Chokepoint thứ hai. Rào cao 1.0 m, cột cổng 2.4 m. |
| Vùng yên | x 1–8; z −25.5…−32 | 7.0 × 6.5 m | Cache nằm ở mép tây, lối D bị chặn ở phía bắc. |

## 4. Bảng marker

Toạ độ ghi theo B (x, z); y = 0 trên sàn, trừ khi có ghi khác. Cột world = B + (7.0, −2.45). Loại node chỉ là gợi ý.

| Node | B (x, z) | World (x, z) | Mục đích |
|---|---|---|---|
| `SeamAB` | (0, 0), rộng 3.0 | (7.0, −2.45) | Lối nối liền với A |
| `BEntry` (Marker3D) | (3.0, −1.0) | (10.0, −3.45) | Vào B. Từ đây thấy cả GuardPost và BeaconA (BeaconA trong viewport thật mọi tỉ lệ; trong khung inset 4:3 khi đứng x ≤ 2.5). |
| `LandmarkEntryLantern` | (1.0, −3.6), cao 4.5 | (8.0, −6.05) | Cột đèn lồng mái đỏ đầu chợ (`light_`). Landmark chỉ hướng A. |
| `CoverB1` (StaticBody3D) | (2.6, −2.8), 1.2×1.2, cao 1.2 | (9.6, −5.25) | Chặn tầm nhìn từ GuardPost ra sân. Chỗ đứng đọc vòng giữ ngõ. |
| `GuardPost` + `GuardPostFacing` | (4.5, −7.5), facing (0, 0, +1) | (11.5, −9.95) | Gốc của `tax_guard`, quay về phía A. Leash 3.0 → z −4.5…−10.5. |
| `WithdrawPointGuard` | (1.5, −9.75), facing −x | (8.5, −12.2) | Hốc ở mặt tiền tây, rộng 1.5, sâu 1.0, quay mặt khỏi lane. |
| `ForemanChargeLane/end_b` | (4.5, −13.5) | (11.5, −15.95) | Đầu lane phía A |
| `ForemanChargeLane/end_a` | (4.5, −22.5) | (11.5, −24.95) | Chỗ `foreman` đứng `idle`, quay về +z |
| `ForemanChargeLane` (rộng) | 1.6 m vẽ, dài 9.0 m | — | Hai bên còn 2.7 m sàn trống. Không có collision tĩnh trong x 3.7–5.3. |
| `CoverB2` / `CoverB3` | (1.6, −16.0) / (1.6, −20.5), 1.2×1.2, cao 1.2 | (8.6, −18.45) / (8.6, −22.95) | Cover sát mép tây. Sàn trống giữa cover và lane ≥ 1.5 m. |
| `CoverB4` | (7.7, −18.0), 0.6×1.6, cao 0.6 | (14.7, −20.45) | Thúng cá thấp ở mép đông, báo “phía này an toàn”, không che lane. |
| `WithdrawPointForeman` | (0.5, −23.25), facing −x | (7.5, −25.7) | Hốc ở mặt tiền tây, nằm ngoài lối gate |
| `GateB` (+ `GateBBarrier`) | (4.5, −25.0), lối mở 2.5 | (11.5, −27.45) | Thanh chắn thuế dài 2.5 m. Hạ xuống thì có collision, nâng lên thì đứng dọc. |
| `SignToA` | (2.8, −25.3), cao 1.8–2.2, mặt quay về bắc | (9.8, −27.75) | Biển hình mũi tên chỉ +z, có hình đèn phao. Landmark ngược. |
| `CalmZoneB` (Area3D) | tâm (4.5, −28.75), 7.0 × 6.5 | (11.5, −31.2) | Vùng sàn yên (§5.4) |
| `CacheB` | (1.8, −29.5), 0.7 × 1.0, cao 0.7 | (8.8, −31.95) | Cache B. Item do TASK-82 quyết. Chạm từ phía đông. |
| `BlockedRouteD` | (4.75, −32.0), lối 2.5 | (11.75, −34.45) | Lối D bị chặn (§2) |
| `PatrolReturnPath/P0` = `PatrolSpawnB` | (7.0, +1.0) | (14.0, −1.45) | Spawn của patrol, góc đông-nam sân đầu chợ (đầu A của lane B), cách `SeamAB` 7 m, không chắn lối về A |
| `PatrolReturnPath/P1` | (3.0, −6.0) | (10.0, −8.45) | Patrol đi nửa tây của ngõ |
| `PatrolReturnPath/P2` | (3.0, −19.0) | (10.0, −21.45) | Điểm quay đầu. Tầm với tối đa z −23.8, chưa tới gate. |
| `PatrolAlertLampB` | (0.8, −17.5), cao 3.2 | (7.8, −19.95) | Một instance khác của `LaneBAlertLamp` (§6) |
| `WithdrawPointPatrolB` | (7.0, −3.6), facing +x | (14.0, −6.05) | Góc đông-bắc của sân, không chắn đường về A |
| `HoldLaneBSpawn` (H0) = `WithdrawPointHold` | (7.0, −24.5) | (14.0, −26.95) | Góc đông-bắc quảng, phía nam rào gate (không cần gate mở). Ngoài viewport thật 21:9 ≥ 0.9 m với mọi chỗ đứng trong vòng beacon trên deck. |
| `HoldLaneBPath/H1`, `/H2`, `/H3` | (3.5, −8.0), (2.0, 0.0), (−0.8, 0.0) | (10.5, −10.45), (9.0, −2.45), (6.2, −2.45) | Ngõ → sân → miệng lane trên deck A |
| `HoldLaneBPath/HG1` | (−3.0, −1.85) | (4.0, −4.3) | Nhánh của vệ binh, đi dưới lane hold |
| `HoldGuardPost` | (−8.85, −2.0), facing −x | (−1.85, −4.45) | Cách mép `BeaconZoneA` 0.48 m, ở phía lane B |
| `HoldChargeLane/end_a` | (−3.2, 0.05) | (3.8, −2.4) | Đầu gần miệng lane |
| `HoldChargeLane/end_b` | (−12.6, 0.05) | (−5.6, −2.4) | Dài 9.4 m, rộng 1.6 m |
| `LaneBAlertLamp` | (−0.7, −1.95), cao 3.2 | (6.3, −4.4) | Đèn báo đặt trên deck A cạnh miệng lane. Mũi tên sàn chỉ từ H3 tới `BeaconA`. |
| `ProbeZoneBFloorLit` | (5.5, y 0.095, −28.0) | (12.5, −30.45) | `lit_face` của sàn vùng yên; `expected_hex` lấy màu gỗ sàn B trong palette.json, tolerance 10 |
| `ProbeZoneBFloorShadow` | (1.6, y 0.095, −27.5) | (8.6, −29.95) | `shadow`: nằm trong bóng của mặt tiền tây (đèn chiếu về +x, −z), tolerance 12 |
| `ProbeZoneBLaneFloor` | (4.5, y 0.095, −18.0) | (11.5, −20.45) | `lit_face`: sàn telegraph phải yên (không WC-02), tolerance 10 |
| `ProbeZoneBAwning` | (0.6, y 2.6, −14.0) | (7.6, −16.45) | Mặt sáng của mái đỏ son (`zones.B` trong palette.json) |
| `ProbeZoneBBackground` | đặt như `ProbeZoneABackground` so với camera chụp | — | `background`, tolerance 5 |

Các probe vào group `zone_b_lookdev_probe` với metadata giống A. Camera chụp look-dev đặt tại vị trí người chơi + (15.45,
13.05, 11.6) (thân y 0.95), xoay (−30, 45, 0), size 20, ở ba chỗ đứng: B (3.5, −3.0) (beat guard), B (4.5, −12.5)
(beat lane), B (4.5, −27.0) (vùng yên).

## 5. Encounter (theo thứ tự guard → charge → gate → vùng yên)

### 5.1 Vào B

- **Cái người chơi đọc được trước khi có áp lực.** Đứng tại `BEntry` (cách post 6.7 m, ngoài perception 6.0 m) thấy được:
  - vệ binh đứng post, khiên nâng: L +5.7, D +3.5;
  - `CoverB1`: L +1.0, D +1.6;
  - mái đỏ ngõ;
  - `BeaconA` phía sau: L −9.5, D +12.0 (đèn cao 3.7 m nên trên màn hình tương đương D +18.4). Trong viewport thật
    mọi tỉ lệ (mép 4:3 là −10.6); lệch 0.2 m ra ngoài khung inset 4:3, vào hẳn khi đứng ở x ≤ 2.5. Với 16:9 luôn trong khung.
- **Lựa chọn:** quay A (lối 3 m ngay sau lưng, không có địch nào đuổi) hoặc vào ngõ.

### 5.2 Beat 1 — Vệ binh giữ ngõ

| Mục | Giá trị |
|---|---|
| Vị trí | `GuardPost` B (4.5, −7.5), giữa ngõ rộng 5 m. Vòng giữ ngõ r 2.5 phủ gần hết bề ngang. |
| Kích hoạt | Perception 6 m / ±60° / có đường nhìn. Người chơi vào tới z ≈ −1.5 thì bị thấy. `CoverB1` cao 1.2 m chắn tia từ mắt 1.5 m tới ngực 1.0 m khi người chơi đứng phía tây sân. |
| Telegraph | Vòng `hold` + quạt wind-up 0.8 s. Luôn trong khung vì đòn chỉ ra khi người chơi ở trong 1.8 m. |
| Cover / side space | Mỗi bên vệ binh còn 2.5 m để vòng ra hông. Tầm với tối đa = leash 3.0 + đòn 1.8 = 4.8 m, nên sân đầu chợ (z ≥ −2.7) ngoài tầm. |
| Đường lùi về A | Lùi theo hướng +z (chéo xuống-trái màn hình). Ra khỏi leash thì vệ binh dừng ở z −4.5. Lối A cách 4–8 m. |
| Lùi + telegraph cùng khung | Đi về +z thêm d m thì L = D = −0.707·d; khung 4:3 chứa tới d = 13.2 m. Từ mọi chỗ trong leash (z −4.5…−10.5), `SeamAB` (z ≤ +1.5) cách ≤ 12 m nên lối A, vòng giữ ngõ và vệ binh cùng nằm trong một khung. |
| Kết thúc | Vệ binh vào `withdraw` (HP ≤ 34%) rồi đi tới hốc `WithdrawPointGuard`, hoặc vào `down` |

### 5.3 Beat 2 — Đốc công charge theo lane

| Mục | Giá trị |
|---|---|
| Vị trí | `foreman` `idle` ở `end_a` B (4.5, −22.5), quay về +z. Lane dọc z −13.5…−22.5. |
| Tách khỏi beat 1 | Tầm đòn của vệ binh hết ở z −12.3; `end_b` ở z −13.5. Leash hai vai không chồng nhau. Lúc người chơi đang ở ngõ (z ≥ −11), khoảng cách tới đốc công ≥ 11.5 m (> 9 m), nên nó chưa thấy người chơi. |
| Đọc trước | Từ cửa ngõ (z −11) đã thấy đốc công ở L +8.1, D +8.1 trước khi nó thấy người chơi. Đề xuất cho TASK-88: bật viền lane (`progress 0`) từ lúc `alert`. Sàn lane lát ván chạy dọc lane, khác hướng ván phần còn lại của quảng. Đây là chi tiết hình khối, không phải decal. |
| Kích hoạt đòn | Người chơi đứng trong lane (rộng 1.6 + 0.4 mỗi bên) và cách ≤ 9 m. Đốc công ở đầu kia luôn trong khung: lệch tối đa L ±6.4, D ±6.4. |
| Cover / side space | Mỗi bên lane còn 2.7 m sàn. `CoverB2`/`CoverB3` ở mép tây, giữ ≥ 1.5 m sàn tới lane. `CoverB4` thấp ở mép đông. Phần sàn bị cover che (1.73·h) không chồng lên lane. |
| Phản ứng | Dash ngang (lên/xuống trên màn hình), đứng ngoài lane, giữ khiên, hoặc đánh trong lúc `recover` |
| Đường lùi về A | Ngõ thẳng hướng +z. Đốc công không rời lane quá 1.5 m. |
| Lùi + telegraph cùng khung | Từ mọi chỗ trên lane (z −13.5…−22.5), cửa ngõ (z −11) cách 2.5–11.5 m (< 13.2 m), nên cửa ngõ, hai đầu lane và vạch charge cùng nằm trong một khung 4:3. Lùi ngang khỏi lane (2.7 m mỗi bên) không làm lane ra khỏi khung. |
| Kết thúc | Đốc công vào `withdraw`, đi tới hốc `WithdrawPointForeman`, hoặc vào `down` |

### 5.4 Gate B và vùng yên

1. **Điều kiện mở `GateB`:** `tax_guard_b.is_lane_pressure_resolved() and foreman_b.is_lane_pressure_resolved()`.
   - Mỗi vai chỉ cần rút lui (`withdrawn`) hoặc gục (`down`). Không cần giết, không đếm số địch đã hạ.
   - Ngõ rộng 5 m với vùng tầm thấy 2 m (proximity) của vệ binh làm người chơi không thể lén qua beat 1.
2. **Hiển thị:** thanh chắn nâng lên trong 1.0 s, kèm thẻ niêm thuế rơi xuống. Gate được đọc bằng hình (thanh ngang
   chuyển thành dọc) và chuyển động. Collision tắt ngay khi bắt đầu nâng.
   - Gate **không bao giờ đóng lại**.
   - Gate không phải điều kiện để extract.
3. **`CalmZoneB`:** rộng 45 m². Không vai địch nào với tới được:
   - leash của đốc công dừng ở z −24.0, có rào ở giữa;
   - tầm với tối đa của patrol là z −23.8.
   Vì vậy người chơi yên trong vùng này bao lâu tùy ý (≥ 15–30 s theo slice). Prompt combat tắt khi người chơi ở trong
   vùng.
   - Sàn tại `=` không có decal, vệt đục hay prop rải.
   - Phía đông `CacheB` còn ≥ 4 m sàn trống, để thẻ/lưới O2/O3 không cạnh tranh với nguy hiểm nào.
4. `CacheB` chỉ mời người chơi tương tác. Có thể không mở mà quay về A.

### 5.5 Patrol về A (G12)

1. **Kích hoạt:** lần đầu người chơi rời `CalmZoneB` (body_exited) sau khi đã vào vùng.
   - Lối ra duy nhất là `GateB`, vì D bị chặn.
   - Kích hoạt như nhau dù đã mở cache hay bỏ qua.
   - Chỉ kích hoạt một lần mỗi run.
2. **Diễn biến:**
   - `t = 0`: một `tax_guard` biến thể patrol (combat §5.3) xuất hiện tại `PatrolSpawnB`, đứng yên. Phát
     `patrol_cue_started`. `PatrolAlertLampB` chuyển `armed`, progress 0→1 trong 2.0 s (`PATROL_CUE_LEAD`).
   - `t = 2.0`: đèn chuyển `active`, patrol bắt đầu đi P0 → P1 → P2 rồi quay lại, lặp mãi, 1.6 m/s.
   - Đèn tắt khi patrol `withdrawn`/`down` hoặc khi người chơi về lại deck A (B x < 0).
3. **Vì sao spawn ở P0:** điểm sàn lệch (gx, gz) vào khung inset khi `gx + gz ≤ 18.4` (D ≥ −13.0), với mọi tỉ lệ màn
   hình. Lúc người chơi rời `CalmZoneB` (mép bắc gate, B (4.5, −25.5)), P0 có gx + gz = 2.5 + 26.5 = 29.0, tức ngoài cả
   viewport thật (D −20.5 < −15.1): không pop-in.
   - Kể cả khi người chơi chạy 4 m/s về A, patrol vào khung sớm nhất ở **t ≈ 2.65 s** ((29.0 − 18.4) / 4), dư 0.65 s
     so với `PATROL_CUE_LEAD` 2.0 s (ENM-17). P0 cũ ở x 5.5 chỉ dư 0.03 s nên được dời sang x 7.0.
   - Tới tầm đòn 1.8 m sớm nhất ở **t ≈ 5.0 s**.
   - Sát thương sớm nhất ở **t ≈ 5.8 s** (cộng wind-up 0.8 s).
4. **Lựa chọn:** lách qua nửa đông của ngõ và quảng (x 5–8). Patrol đi nửa tây và chỉ leash 3 m quanh chỗ nó thấy người
   chơi. Hoặc đánh một skirmish ngắn. Đường về A không bị khóa và không có gate thứ hai.
5. **Đèn này dạy trước grammar của lúc hold.** Đây là cùng loại `LaneBAlertLamp`: ba phân đoạn mở dần, không nhấp nháy.

## 6. Landmark và đường nhìn

### 6.1 Chuỗi landmark ngược về A

Mọi số đo theo khung 4:3. L/D là vị trí của landmark so với chân người chơi.

| Đứng tại | Thấy được | L / D (m sàn) | Ghi chú |
|---|---|---|---|
| Tâm `CalmZoneB` | `SignToA` (mũi tên + hình đèn phao) | −3.6 / −1.2 | Trái-dưới |
| Tâm `CalmZoneB` | `GateB` | −2.7 / −2.7 | Trái-dưới |
| Tâm `CalmZoneB` | Đầu bắc mái đỏ quảng | −6.2 / −0.5 | Trái-dưới |
| Tâm `CalmZoneB` | Dây đèn lồng `LanternStringB` chạy dọc mặt tiền tây tới `LandmarkEntryLantern` | liên tục | Trái-dưới |
| `PatrolReturnPath/P2` | Mái đỏ ngõ (x 0–2, z −4…−11) | −7.8 / −2.1 | Mái quảng nằm ngay cạnh |
| `PatrolReturnPath/P2` | `PatrolAlertLampB` | −2.6 / +0.5 | — |
| `PatrolReturnPath/P1` | `LandmarkEntryLantern` | −3.1 / −0.3 | Đèn cao 4.5 m nên hiện cao trên màn hình |
| `PatrolReturnPath/P0` | `LandmarkEntryLantern` | −1.0 / +7.5 | Ngay trên-trái người chơi |
| `PatrolReturnPath/P0` | `SeamAB` + lan can dây hai bên | −4.2 / +5.7 | Lối A mở rộng 3 m |
| `PatrolReturnPath/P0` | `BeaconA` (đèn ở độ cao 3.7 m) | −11.0 / +16.3 | Ngoài 4:3, trong khung từ 16:9. Đi về tây tới x ≤ 4.5 là vào khung 4:3. |
| Sân phía tây (B x 1.0–2.5, z −1) | `BeaconA` | −8.1…−9.2 / +10.6…+11.7 | Thấy hẳn ở mọi tỉ lệ |
| Sân phía tây (B x 1.0–2.5, z −1) | Cầu tàu A (`ExtractPierA`) | −7.9…−8.9 / +10.2…+11.2 | — |
| Spawn A (−1.45, 2.4) | `LandmarkEntryLantern` | +12.7 / −0.7 | Từ A thấy được lối B (G3) |

Không landmark nào trong bảng nằm sau vật cao hơn 1.0 m theo hướng nhìn ↖: mọi vật cao đều ở mép tây. Không dùng
silhouette C/E để chỉ đường. Mái đỏ son không bao giờ là màu báo nguy hiểm. Landmark được đọc bằng hình răng cưa của
mái, cột đèn và biển mũi tên, không chỉ bằng màu.

### 6.2 Hold lane B (G14) — bán kính và đường địch

1. **Chốt bán kính** (giữ đúng như code):
   - `BEACON_ZONE_RADIUS_M = 3.0`, tâm tại `BeaconA` world (−5.25, −5.2).
   - `BOARD_ZONE_RADIUS_M = 1.5`, tâm tại `ExtractPierA` (−4.75, −5.1), nằm trọn trong vòng beacon.
   - Phần vòng beacon nằm trên deck (z ≥ −5, x ≥ −7) rộng khoảng **11.1 m²**. Phần còn lại ở trên nước.
2. **Đường địch:** `HoldLaneBSpawn` (H0) → H1 → H2 → H3 (miệng lane) rồi chia hai:
   - vệ binh: → HG1 → `HoldGuardPost`;
   - đốc công: → `HoldChargeLane/end_a`.
   Đường đi hoàn toàn trên lane B. Không có điểm nào ở sau lưng hay phía nước.
3. **Spawn ngoài khung:** director chọn điểm trên `HoldLaneBPath` gần A nhất mà vẫn nằm ngoài viewport thật ít nhất
   0.5 m. Nếu không có điểm nào như vậy thì dùng H0. Từ mọi chỗ đứng trong vòng beacon trên deck (z ≥ −5), H0 có
   L ≥ 27.0, tức ngoài viewport thật 21:9 (mép +26.1) ít nhất 0.9 m. (H0 cũ ở B (4.5, −24.0) chỉ có L ≥ 24.9, nằm
   trong viewport thật 21:9: pop-in, nên dời sang góc đông.)
   - Điểm địch vào khung luôn ở **mép phải** màn hình. Độ cao tuỳ tỉ lệ: y_norm 0.83 (4:3), 0.73 (16:9), 0.64
     (19.5:9), 0.60 (21:9). Số 19.5:9/21:9 là ước tính (điểm vào nằm trên đoạn H0→H1 vừa dời); TASK-88 đo lại trên
     greybox.
   - Từ lúc vào khung, địch còn đi 12–25 m trong tầm nhìn rồi mới tới vòng.
4. **`HoldChargeLane`:** dải z −3.2…−1.6, đi lệch tâm qua nửa bắc của vòng.
   - Che **27%** phần vòng trên deck (11% nếu tính cả vòng). Phải ≤ 40%.
   - Phần vòng còn lại ngoài lane là dải z −5.0…−3.2, rộng **1.8 m**. Phải ≥ 1.5 m.
   - Không cắt `BoardZoneA` (cách 0.4 m).
   - Nhìn từ vòng, cả hai đầu lane đều trong khung: `end_a` ở L +4.4 / D −8.4, `end_b` ở L −2.2 / D −1.7.
5. **`LaneBAlertLamp`:** đứng ở bất kỳ đâu trong vòng, đèn hiện ở x_norm 0.61–0.77, y_norm 0.65–0.72 (4:3), nằm trên
   cụm nút góc phải-dưới. Mũi tên sàn đi từ H3 tới `BeaconA`.

## 7. Nhịp

| Beat | Thời điểm (ước tính) | Cường độ 0–5 | Nghỉ / ghi chú |
|---|---|---|---|
| A → sân đầu chợ, đọc ngõ | 0:00–0:20 | 1 | Nghỉ ở sân (ngoài perception) |
| Vệ binh | 0:20–1:00 | 3 | Lùi được về sân |
| Cửa ngõ, đọc lane | 1:00–1:10 | 1 | Nghỉ ngắn ở z −11…−12 |
| Đốc công | 1:10–2:00 | 4 | Đỉnh của lượt đi |
| Gate mở → vùng yên, cache | 2:00–2:30+ | 0 | **Điểm nghỉ chính**, ≥ 15–30 s, không giới hạn |
| Cue patrol (2.0 s) → patrol / lách | 2:30–3:10 | 2–3 | Đèn báo, sau đó tự chọn lách hay đánh |
| Về sân → thấy BeaconA → deck A | 3:10–3:30 | 1 | Nghỉ trên deck A |
| Gọi thuyền (S7) → hold 20 s (S8) | 3:30–3:55 | 3–4 | Đèn báo t 0–3 → vệ binh t 3 → đèn t 7–10 → đốc công t 10. Hold 15–25 s (G14). |
| Thuyền tới (S9) → lên thuyền | 3:55–4:10 | 1 | Địch rút, không chặn S9 |

## 8. Loot và story item

| Vật | Vị trí | Footprint thế giới | Vì sao ở đây |
|---|---|---|---|
| `CacheB` (rương tịch thu của trạm) | B (1.8, −29.5), mép tây vùng yên | 0.7 × 1.0 m, cao 0.7 | Sau trạm thu là chỗ trạm cất hàng giữ lại. Nó nằm ở chỗ yên để người chơi đọc thẻ/lưới (G7/G8). Item do TASK-82 quyết, chữ do TASK-84 viết. |

Không có story item ở B; Manifest R-17 nằm ở A. Địch gục không rơi loot (combat §5.1.7). Vết mòn có lý do được phép đặt:
- vạch nước trên mặt tiền ở 0.4 m;
- dấu thuế trên rào gate;
- vết kéo hàng ở mép tây.

Không đặt vết mòn trong vùng `=`.

## 9. Kiểm fairness theo brief B §5

Ký hiệu: ✓ đạt theo layout này; ✗ chưa đạt, kèm việc cần làm.

| Beat | Camera / cao độ | Tín hiệu threat | Counterplay | HUD / overlay | Ý nghĩa route | Khi thất bại |
|---|---|---|---|---|---|---|
| Vào B | ✓ vật cao chỉ ở mép tây | ✓ silhouette + post | ✓ lối A 3 m sau lưng | ✓ chưa có prompt | ✓ B tùy chọn, có thể quay A | ✓ chưa có đòn |
| Vệ binh | ✓ vòng r 2.5 không bị cover che | ✓ vòng + quạt + tư thế | ✓ vòng hông, khiên, lùi khỏi leash | ✓ đòn chỉ ra khi ≤ 1.8 m nên luôn trong khung | ✓ không cần giết | ✓ HP 0 theo stub §4.4 |
| Đốc công | ✓ lane không bị che, trong khung ±6.4 m | ✓ viền + chevron + wind-up 1 s | ✓ hai bên lane còn 2.7 m, đứng ngoài lane là an toàn | ✓ lane nằm giữa màn | ✓ rút lui là đủ | ✓ |
| Gate + vùng yên | ✓ rào 1.0 m, mờ khi che | ✓ thanh chắn đổi hình | ✓ gate không đóng lại | ✓ chỉ mời mở thẻ ở `=` | ✓ gate không phải điều kiện extract, D bị chặn rõ | ✓ |
| Patrol B → A | ✓ vào từ phía trước, đi chéo màn | ✓ đèn 2.0 s + vòng nét đứt + chữ | ✓ lách nửa đông hoặc đánh, leash 3 m | ✓ tắt thẻ được bằng một thao tác | ✓ không có gate thứ hai | ✓ |
| Hold lane B | ✓ lane hold lệch tâm, che ≤ 40% | ✓ đèn 3 phân đoạn + mũi tên + telegraph cũ | ✓ còn dải 1.8 m ngoài lane | ✗ ở 4:3, địch vào khung tại y_norm 0.83 sát mép phải, có thể nằm dưới cụm nút. **Sửa:** TASK-83 để trống dải mép phải y_norm 0.55–0.85 trong S8, hoặc chấp nhận đèn + mũi tên là cue chính (§10, câu 2). | ✓ chỉ A có call/hold/board | ✓ S9 không bị chặn |

Kiểm thêm: không địch nào bắt đầu đòn khi ngoài khung. Mọi vị trí wind-up đều trong ±9 m quanh người chơi, kết hợp
luật `ON_CAMERA_INSET`.

## 10. Bàn giao và câu hỏi mở

**TASK-85 (technical-artist):**
- Dựng greybox theo §3–§4, collision layer `world_static` cho mặt tiền, lan can, cover, rào và `GateBBarrier`.
- Lan can thấp ở hai bên `SeamAB`.
- Cơ chế làm mờ cho vật ≥ 1.0 m khi che người chơi, địch hoặc telegraph.
- Instance thứ hai của `LaneBAlertLamp`.
- Đèn lồng dùng vật liệu `light_`.
- Probe `zone_b_*` và camera chụp đặt trong `LookdevOnly`. Camera đó không `current` khi B được instance vào run, và
  B không mang theo `WorldEnvironment` hay đèn riêng.

**TASK-88 (ai-programmer):**
- Đặt hai vai ở `GuardPost`/`end_a` và các `WithdrawPoint*`.
- Viết điều kiện gate ở §5.4.
- Patrol: spawn, chờ 2 s, lặp đi lặp lại theo §5.5.
- Hold: chọn điểm spawn ngoài khung theo §6.2.3.
- Bật viền lane khi `alert` (đề xuất).

**TASK-90 (gameplay-engineer):**
- Instance B tại (7.0, 0, −2.45), không xoay.
- Thêm collision cho mép deck A: hiện chưa có, nên vòng beacon/board đi ra được tới trên nước.
- Nối `CalmZoneB.body_exited` vào kích hoạt patrol.

**TASK-83 (ux):** dải mép phải ở §9.

**Câu hỏi mở cho Producer / game-designer** (không chặn greybox):
1. **Hold quá ngắn so với đường đi.** Từ vòng beacon, điểm ngoài khung gần nhất cách vòng 13–24 m. Với 1.6/1.8 m/s:
   - vệ binh tới post ở t ≈ 14.9 (4:3), 18.4 (16:9), 21.5 (19.5:9);
   - đốc công tới `end_a` ở t ≈ 17.1 (4:3), 20.2 (16:9), 22.9 (19.5:9).
   Trên phần lớn điện thoại, đốc công không kịp charge trước khi `boat_ready` ở t = 20. Rút ngắn B không giúp được, vì
   khoảng cách này do khung camera quyết định, không do layout. Hướng sửa thuộc số liệu của TASK-80, ví dụ:
   - a) địch hold đi nhanh hơn trên `HoldLaneBPath` cho tới khi `alert`;
   - b) director bắt đầu sớm hơn so với `hold_started`.
2. Dải HUD mép phải trong S8 (§9): để trống, hay chấp nhận đèn + mũi tên là cue chính?
