# Spec layout + encounter — Kho Nổi (D), vertical slice “Giữ giấy phép” (S04)

**Trạng thái:** `proposed`. Mọi kích thước, toạ độ, thời gian và bán kính mới trong file là `proposed`. Số combat lấy
nguyên từ [combat-slice-spec](combat-slice-spec.md), khung camera và luật che khuất lấy nguyên từ
[spec B §1](zone-b-layout-encounter-spec.md). File này không đổi số nào của hai spec đó.
**Nguồn:** [brief cargo/Hộp D](../maps/black-tax-port-d-cargo-choice-brief.md) ·
[blockout A/B/D](../maps/black-tax-port-vertical-slice-blockout.md) · [spec B](zone-b-layout-encounter-spec.md) ·
[vertical slice](../vertical-slice.md) · [readiness G9/G12/G13](../vertical-slice-build-readiness.md) ·
[map brief](../maps/black-tax-port.md) · [Art Bible](../art/ART_BIBLE.md) · `game/src/world/zone_b_flooded_market.tscn`
và `game/src/flow/outer_pier_run.gd` (chỉ đọc).

Ngoài phạm vi: luật cargo/Hộp/death và chữ card (TASK-96/98), UX/HUD (TASK-97), dựng scene (TASK-99), code.

## 0. Vai trò của khu

| Mục | Nội dung |
|---|---|
| Vai trong contract | Chỗ chọn tùy ý sau B: mang cargo `2x2`, lấy `Dấu Thuế` `1x2` hoặc bỏ cả hai, rồi về A. Không phải chỗ extract. Rút sớm ở A, hay về A thẳng từ B, vẫn là success ngang hàng (brief D §4). |
| Thời lượng ước tính | Ở D khoảng 1–2 phút (đọc nguồn, card, Hộp). Cả vòng A → B → D → B → A khoảng 5–6 phút. |
| Vết thương tại chỗ | Hàng trên kho nổi bị giữ trong lồng chờ cân thuế, kho bị bỏ lại trên nước. Lore cụ thể do narrative quyết, file này không thêm. |
| Người giữ tại chỗ | Không có vai địch ở D. Dấu vết của Nhà Hắc Thuế (bàn cân, niêm lồng, xích lối D) thay cho người giữ (narrative xác nhận, §10). |
| Mục tiêu | Tự chọn trong ba outcome của brief D §4, rồi đi D → B → A. |
| Áp lực | Không gian ba lô `3x4` và Hộp `2x2` (brief D §1). Lượt về có patrol báo trước ở B (§5.2). Không có hazard, địch hay weight penalty trong D. |
| Dấu vết thấy được | Lối D ở B đổi từ khung song có xích sang khung rỗng có cầu ván. Cửa lồng mở, pallet và bàn cân còn lại sau khi món đã được nhặt. |

## 1. Gốc D, cao độ, camera

1. **Scene và root:** `game/src/world/zone_d_floating_warehouse.tscn`, root `ZoneDFloatingWarehouse` (Node3D), metadata
   `zone = "zone_d_floating_warehouse"` (id glossary).
2. **Offset:** gốc D đặt tại **B (4.75, 0, −34.5)**, tức **world (11.75, 0, −36.95)** so với gốc khu A, **không xoay**.
   Quy đổi: **B = D + (4.75, 0, −34.5)** và **world = D + (11.75, 0, −36.95)**. Gốc D là tâm mép nam của sàn D, ngay đầu
   bắc của cầu ván (§2).
3. **Cao độ:** mặt sàn D ở **y = 0.09**, bằng sàn B và `PierDeck` A. Không bậc, không dốc, không nhảy. Mặt nước ở
   y = −0.12 như `WaterB`. Chỉ có hai cao độ đọc được: sàn và nước (blockout §3.1). Sàn không dập dềnh trong slice.
4. **Khung kích thước:** sàn D nằm trong hộp D x −5.0…+4.5, z 0…−12.5 (9.5 × 12.5 m). Mặt nước D phủ ít nhất
   D x −8…+8, z +2…−16, liền với `WaterB`.
5. **Nối B ↔ D:** đi bộ liền, **không màn tải**. Scene D được nạp cùng A và B đầu run. Camera bám người chơi như S03:
   `CameraIsometric` trực giao, pitch −30°, yaw 45°, `size` 20, offset **(15.45, 13.05, 11.6)**. Không đổi zoom, không
   có camera riêng cho D.
6. **Quy đổi màn hình, khung và luật che khuất:** dùng nguyên spec B §1.3–§1.5. Với điểm sàn lệch (gx, gz) so với chân
   người chơi: `L = 0.707·(gx − gz)`, `D = −0.707·(gx + gz)`. Vật cao h hiện cao thêm như D + 1.73·h, ghi là “đỉnh”.
   Kiểm “trong khung” dùng khung inset 4:3: L ∈ [−9.3, +14.7], D ∈ [−13.0, +22.9]. Kiểm “ngoài màn hình” dùng
   viewport thật: D < −15.1, hoặc L ngoài mép 21:9 cộng 0.5 m.
7. **Chữ ký màu D** (Art Bible §3, `zones.D` trong palette.json: `water_deep`, `water`, `foam`, `iron`, `wood_dark`):
   - lồng kho là song sắt `iron` trên khung `wood_dark`;
   - nước xanh lục tối `water_deep`/`water` quanh sàn;
   - một viền bọt `foam` dọc mép phao;
   - không có mái đỏ son hay đèn `light_` trong D;
   - không dùng vật liệu `signal_` ở D (giống `CacheB`).
   Đỏ son chỉ xuất hiện ở lối D thuộc B (lanh tô, niêm thuế; §2.2), để đánh dấu đường về chợ.

## 2. Lối D ở B

### 2.1 Đo lại: mặt tiền tây không che lối D

Inbox TASK-93/94 nghi `BlockedRouteD` bị mặt tiền tây che. Đo trên transform thật của scene B:

| Vật | B (x; z) | Cao |
|---|---|---|
| `WestFacade/Wall` | x −0.8…0.0; z −32.0…−3.0 | 2.7 |
| `BlockedRouteD` (khung) | x 2.55…6.95 (hai cột ở 2.70 và 6.80); z −32.0 | cột 3.0, song 2.4 |
| `DistantWarehouseSilhouetteD` | x 1.55…7.95; z −35.65…−34.85 | 4.0 |

1. **Phép chiếu:** tia camera đi theo hướng (−0.612, −0.5, −0.612). Vật O chỉ che được điểm P khi P = O + t·hướng
   với t > 0. Khi đó P.x < O.x, P.z < O.z và P.x − P.z = O.x − O.z.
2. **Với mặt tiền tây:** O.x ≤ 0, nên nó chỉ che được điểm có x < 0. Lối D có x ≥ 2.55. **Mặt tiền tây không thể che
   lối D từ bất kỳ chỗ đứng nào.** Camera trực giao nên chỗ đứng chỉ đổi khung, không đổi việc che.
3. **Với sàn D:** điểm D có B x < 0 chỉ là dải mép tây (D x −5.0…−4.75), có x − z ≥ 34.25. Mặt tiền chỉ che dải
   x − z ∈ [2.2, 32.0]. **Mặt tiền tây không che phần nào của D.**
4. **Từ tâm `CalmZoneB` B (4.5, −28.75)**, mọi điểm đều trong khung 4:3:

   | Thấy | L / D | Đỉnh |
   |---|---|---|
   | Khung lối D | +2.5 / +2.1 | +7.7 (lanh tô 3.2 m) |
   | `DEntry` | +5.0 / +4.6 | — |
   | `CargoD` | +8.8 / +12.0 | — |
   | `TaxStampD` | +10.3 / +7.1 | — |
   | `CageRowNorthD`, đầu tây | +9.0 / +15.7 | +20.9 (≤ 22.9) |
   | `CageRowNorthD`, đầu đông | +14.0 / +10.8 | — |

   Lối D nằm gần giữa màn, hơi trên-phải người chơi. Không vật nào cao hơn 1.0 m nằm trong dải
   x − z ∈ [34.6, 38.9] phía nam lối D. Trong vùng yên chỉ có `CacheB`, thấp 0.7 m và nằm ở dải x − z = 31.3.
5. **Nguyên nhân khả dĩ của nghi ngờ:** từ `BEntry` B (3.0, −1.0), lối D ở L +23.2 / D +20.7. Điểm này **ngoài khung**
   4:3, 16:9 và 19.5:9, chứ không bị che. Ảnh `zone_b_game.png` đứng ở `BEntry` nên không thể thấy lối D.
6. **Cách sửa đã chọn:** không cutaway mặt tiền, không dời cổng. Ba việc cụ thể:
   - (a) **Dời silhouette D:** xoá `DistantWarehouseSilhouetteD` (B (4.75, 2.0, −35.25)). Nó nằm đè lên sàn D mới tại D
     (0, −0.75). Vai trò của nó chuyển sang `CageRowNorthD` thật ở D z −11.0…−12.5 (§4).
   - (b) Thêm lanh tô đỏ son và cầu ván cho trạng thái mở (§2.2).
   - (c) Chụp `zone_b_route_d_*` bằng **camera game thật** (size 20, offset trên) đứng ở tâm `CalmZoneB`, không dùng
     khung cận cảnh riêng (§10.1).

### 2.2 Hai trạng thái

Cả hai trạng thái đọc bằng hình khối và chuyển động. Không prompt, không marker, không vật liệu `signal_`, không
collision lừa. Node `BlockedRouteD` giữ tên và transform (B (4.75, 0.9, −32.0)) để test và capture cũ còn tìm được nó.
Trạng thái do API của root B đổi: `set_route_d_open(open: bool)`.

| Phần | `closed` (mặc định khi `_ready`) | `open` |
|---|---|---|
| Khung | Hai cột 3.0 m, `FrameTop`, `FrameBottom` như đã dựng | Giữ nguyên |
| `RouteDLintel` (mới) | Tấm vải `canvas_red` 4.6 × 0.45 × 0.12 m trên đỉnh cột, đỉnh ≤ 3.2 m, nghiêng 3° | Giữ nguyên: landmark cố định của đường về B |
| Song + xích + niêm | `SlatWest`, `Slat01…06`, `Chain`, `ChainCross`, `TaxSeal*` hiện | Ẩn hết |
| `RouteDOpenDebris` (mới) | Ẩn | Xích đứt treo dọc cột tây (đỉnh ≤ 1.0 m). Niêm rách nằm phẳng trên sàn B tại B (6.6, −31.7), ngoài lối đi. |
| Khe nước `MissingPlankWaterGapD` | Hiện, không có ván: thấy nước giữa B và D | Vẫn hiện quanh hai mép cầu |
| `RouteDPlanks` (mới, StaticBody3D) | Ẩn, collision tắt | Hiện, collision bật. Ván 2.5 × 2.0 m tại B (4.75, −33.5), mặt trên y 0.09, lệch nhịp 2–3°. Phủ khe B z −32.5…−34.5. |
| `RouteDSideRails` (mới) | Lan can thấp 0.5 m dọc B x 3.5 và x 6.0, z −32.5…−34.5, có collision | Giữ nguyên |
| Collision `BlockedRouteD` | Bật, **nới ra cả khung** B x 2.7…6.8 (4.1 m), cao 1.8 m | Tắt |

- **Đọc ở cỡ điện thoại.** Khi đóng, khung đầy bảy song đứng, có chữ X xích và đĩa niêm. Khi mở, khung rỗng với một dải
  ván nối liền hai mặt sàn. Ở ảnh thang xám, ván (gỗ, tông trung) tách khỏi nước tối.
- **Mép bắc của B.** Ngoài khung (B x 0…2.7 và 6.8…9.0 ở z −32.5), mép sàn B phải có lan can thấp ≤ 0.6 m có collision.
  Lý do: collision cũ chỉ rộng 2.5 m nên có thể đi vòng qua cột ra mép nước.
- **Che người chơi.** Lanh tô và khung cao hơn 1.0 m. Khi người chơi ở trên cầu ván, phần trên khung có thể che đầu người
  chơi. Chúng phải mờ dần như mọi vật ≥ 1.0 m của B (spec B §1.5).

### 2.3 Điều kiện mở

1. **Mở cùng khung hình với `GateB`:** khi điều kiện gate B (spec B §5.4) lần đầu đúng, flow gọi
   `set_route_d_open(true)` trong cùng lần cập nhật đó.
   - Không muộn hơn `GateB`.
   - Người chơi chỉ tới được lối D sau khi qua `GateB`. Lúc đó người chơi cách lối D ≥ 7 m, nên chưa thể đứng trên cầu.
2. **Chuyển động 1.0 s** (`proposed`), cùng nhịp thanh chắn `GateB` nâng lên: song và xích rời khỏi khung, ván hạ vào
   khe. Lúc bắt đầu chuyển động, collision cổng tắt và collision ván bật cùng lúc.
3. **Không bao giờ đóng lại** trong run. Không có lệnh `set_route_d_open(false)` nào sau khi đã mở. Đầu run mới, scene
   dựng lại ở `closed`.
4. **Không phải điều kiện extract.** A callable chỉ phụ thuộc Manifest (E0/E1). Đi hay không đi D không đổi beacon.
5. Từ quảng (beat đốc công), người chơi đã thấy lối D đóng. Ví dụ tại `end_a` lối D ở L +6.9 / D +6.5. Lúc gate B
   nâng, người chơi thấy cả hai lối cùng mở trong một khung.

## 3. Sơ đồ D (nhìn từ trên, theo trục D)

Mỗi ký tự rộng 0.5 m theo x (D −6.0…+6.5). Mỗi dòng cao 1 m theo z, nhãn ở đầu dòng. Bắc (−z) ở trên cùng của sơ đồ
và hiện thành **chéo lên-phải** trên màn hình. Đi về +z (về B, về A) là **chéo xuống-trái**. Toạ độ chuẩn nằm ở §4,
hình vẽ chỉ minh hoạ.

```text
  z(D)   x: -6  -4  -2   0   2   4   6
 -13     ~~~~~~~~~~~~~~~~~~~~~~~~~~      ~ nước D (xanh lục tối)  = sàn yên CalmZoneD (trơn)
 -12     ~~###############...:~~~~~      # lồng kho cao 3.0       . sàn thường (ván wood_dark)
 -11     ~~###OOOO########....:~~~~      O cửa lồng mở            W chồng lồng tây cao 2.6
 -10     ~~WW================.:~~~~      C CargoD (khối 1×1 m)    T TaxStampD trên bàn cân
  -9     ~~WW==CC============.:~~~~      o tâm CalmZoneD          : lan can thấp ≤ 0.6 m
  -8     ~~WW================.:~~~~      E DEntry   X DExitToB    P RouteDPlanks (thuộc B)
  -7     ~~WW=======o===TT===.:~~~~      | cột khung lối D (B)    D song/xích khi closed
  -6     ~~WW===========TT===.:~~~~      b sàn vùng yên B (CalmZoneB)
  -5     ~~WW================.:~~~~
  -4     ~~WW================.:~~~~
  -3     ~~..================.:~~~~
  -2     ~~~~~~~:..........:~~~~~~~
  -1     ~~~~~~~:....E.....:~~~~~~~
   0     ~~~~~~~:::..X..::::~~~~~~~
  +1     ~~~~~~~~~:PPPPP:~~~~~~~~~~
  +2     ~~~:::::|DDDDDDD|::::~~~~~
  +3     ~~~bbbbbbbbbbbbbbbbbb~~~~~
```

| Đoạn | Phạm vi D (x; z) | Rộng đi được | Ghi chú |
|---|---|---|---|
| Cầu ván (B) | x −1.25…+1.25; z +2.0…0 | 2.5 m | Chokepoint duy nhất B ↔ D. Không combat, không hazard. |
| Bến đỗ | x −2.5…+3.0; z 0…−3.0 | 5.5 m | Lan can thấp ba phía. Đứng ở `DEntry` thấy cả D (§6.1). |
| Sàn chính | x −5.0…+4.5; z −3.0…−12.5, vát góc đông-bắc theo đường x − z = 16 từ (4.5, −11.5) tới (3.5, −12.5) | 8.5 m giữa chồng lồng tây và mép đông | Vật cao chỉ ở mép tây (`CageWestD`) và mép bắc (`CageRowNorthD`). Mép đông chỉ có lan can ≤ 0.6 m. |
| Vùng yên `CalmZoneD` | x −4.0…+3.5; z −3.0…−10.5 | 7.5 × 7.5 m | Chứa trọn hai vòng tương tác (§4). |

Luật che khuất trong D lấy theo spec B §1.5, đã kiểm trên sơ đồ:
- vật cao chỉ đứng ở mép tây/bắc, sau lưng chúng là nước (người chơi không đi ra phía sau được);
- vật trong vùng yên cao ≤ 1.0 m (`CargoD` 0.9, bàn cân + món 1.0);
- bóng che 1.73·h của bàn cân (tới khoảng D (0.4, −8.3)) không chạm `CargoD`; bóng che của `CargoD` chỉ phủ dải sàn trống trước
  lồng;
- người chơi luôn ở phía nam/đông (gần camera) của mọi vật cao trong D, nên không bao giờ bị lồng che.

## 4. Bảng marker

Toạ độ theo D (x, z); y = 0 trên sàn, trừ khi ghi khác. Cột B = D + (4.75, −34.5); world = D + (11.75, −36.95). Loại
node chỉ là gợi ý. Collision tĩnh dùng layer `world_static` (layer 2 như B).

| Node | D (x, z) | B (x, z) | World (x, z) | Mục đích |
|---|---|---|---|---|
| `ZoneDFloatingWarehouse` (root) | (0, 0) | (4.75, −34.5) | (11.75, −36.95) | Gốc D, không xoay. Metadata `placement_contract = "Parent at world (11.75, 0.0, -36.95), rotation zero."` |
| `FloorD` + `FloorCollisionD` | bến đỗ + sàn chính (§3) | — | — | Mặt trên y 0.09, liền mép với `RouteDPlanks` ở D z 0. Không hở, không gờ. |
| `WaterD` | phủ D x −8…+8, z +2…−16, y −0.12 | — | — | Nước `water_deep`/`water` |
| `DExitToB` (Marker3D) | (0, 0), rộng 2.5, facing +z | (4.75, −34.5) | (11.75, −36.95) | Mép nam sàn D, đầu bắc cầu ván. Đích của đường về B. |
| `DEntry` (Marker3D) | (0, −1.0), facing −z | (4.75, −35.5) | (11.75, −37.95) | Bước đầu tiên trên D. Chỗ đứng kiểm D brief §6 check 1 (§6.1). |
| `CalmZoneD` (Area3D) | tâm (−0.25, −6.75), hộp 7.5 × 2.0 × 7.5 | (4.5, −41.25) | (11.5, −43.7) | Vùng sàn yên D, rộng 56 m². Không decal, không vệt đục, không prop rải. |
| `CargoD` (anchor, `source_id = "cargo_d_2x2"`) | (−2.5, −9.0) | (2.25, −43.5) | (9.25, −45.95) | Nguồn cargo `2x2`. `Pallet` (1.2 × 1.2 × 0.12, ở lại sau khi nhặt) + `ItemBlock` (khối vuông 1.0 × 1.0 × 0.78, có collision riêng, ẩn và tắt collision khi đã nhặt). Hình vuông nói “2x2”. |
| `TaxStampD` (anchor, `source_id = "tax_stamp_d"`) | (2.0, −6.5) | (6.75, −41.0) | (13.75, −43.45) | Nguồn `Dấu Thuế` `1x2`. `Desk` (bàn cân thấp 0.8 × 1.2 × 0.75, ở lại) + `ItemBlock` (khối dẹt dài 0.3 × 0.6 × 0.25 nằm dọc z, ẩn khi đã nhặt). Tỉ lệ 1:2 nói “1x2”. Tổng cao 1.0 m. |
| Vòng tương tác `CargoD` / `TaxStampD` | bán kính **1.5 m** quanh anchor | — | — | Bằng `CACHE_INTERACT_RADIUS_M` của B. Hai tâm cách nhau 5.15 m nên hai vòng không chồng. Mỗi vòng cách `DExitToB` > 6.5 m. |
| `CageRowNorthD` (StaticBody3D) | x −5.0…+2.0; z −11.0…−12.5; cao 3.0 | tâm (3.25, −46.25) | tâm (10.25, −48.7) | Lồng kho: landmark D, thay `DistantWarehouseSilhouetteD`. Song `iron`, khung `wood_dark`, cạnh lệch 2–5°. |
| `CageOpenD` (con của hàng lồng) | cửa x −3.5…−2.0 ở z −11.0, cánh áp vào mặt lồng | — | — | Cửa lồng mở ngay sau `CargoD`, cho biết cargo được kéo ra từ đây. Cánh cửa không thò ra sàn. |
| `CageWestD` (StaticBody3D) | x −5.0…−4.0; z −3.5…−10.5; cao 2.6 | tâm (0.25, −41.5) | tâm (7.25, −43.95) | Chồng lồng tây. Đổ bóng lên sàn yên. |
| `RailD` (StaticBody3D) | mép bến đỗ; mép đông x 4.5; đường vát; mép bắc x 2.0…3.5 ở z −12.5 | — | — | Lan can 0.5–0.6 m, có collision. Không chừa lối ra nước. |
| `FoamEdgeD` | dọc chân phao, sát mặt nước | — | — | Viền bọt `foam`, không phải decal trên sàn. |
| `ProbeZoneDFloorLit` | (1.0, y 0.095, −5.0) | (5.75, −39.5) | (12.75, −41.95) | `lit_face` của sàn D (`wood_dark`), tolerance 10 |
| `ProbeZoneDFloorShadow` | (−3.6, y 0.095, −7.0) | (1.15, −41.5) | (8.15, −43.95) | `shadow` trong bóng `CageWestD`. TASK-99 đo lại theo hướng đèn thật, dời nếu không nằm trong bóng. Tolerance 12. |
| `ProbeZoneDWater` | (6.0, y −0.12, −7.0) | (10.75, −41.5) | (17.75, −43.95) | Mặt nước `water`/`water_deep`, tolerance 10 |
| `ProbeZoneDBackground` | như `ProbeZoneBBackground` | — | — | `background`, tolerance 5 |

Node mới **trong B** (đều là con của root B):

| Node | B (x, z) | World (x, z) | Mục đích |
|---|---|---|---|
| `RouteDLintel` | (4.75, −32.0), đỉnh ≤ 3.2 m | (11.75, −34.45) | Lanh tô đỏ son của lối D, có ở cả hai trạng thái (§2.2) |
| `RouteDPlanks` | (4.75, −33.5), 2.5 × 2.0 | (11.75, −35.95) | Cầu ván, chỉ có ở `open` |
| `RouteDSideRails` | x 3.5 và 6.0; z −32.5…−34.5 | — | Lan can hai bên cầu |
| `RouteDOpenDebris` | xích ở cột tây; niêm rách ở (6.6, −31.7) | — | Dấu vết mở, chỉ có ở `open` |
| `PatrolTriggerB` (Area3D) | tâm (4.5, y 1.0, −25.25), hộp 2.5 × 2.0 × 0.5 (x 3.25…5.75; z −25.0…−25.5) | (11.5, −27.7) | Trigger patrol về A (§5.2). Lấp đúng lối mở `GateB`, giáp mặt nam `CalmZoneB`, không chồng lên nó. |

## 5. Encounter và đường về

### 5.1 D không có địch

- **Quyết định `proposed`:** D không có `tax_guard` hay `foreman`, không hazard, không spawn.
- **Lý do:**
  - brief D §2 và check 1/6 cấm combat gate, death trap và việc phải đi qua combat để nhìn nguồn;
  - O2/O3/O4 cần một chỗ không có đòn đang tới (blockout §4, dòng D).
  - Áp lực của D là chỗ trống trong ba lô/Hộp, không phải đòn đánh.
- **Không địch nào vào được D:**
  - patrol về A với tới xa nhất z −23.8 (spec B §5.4.3), tức phía nam rào gate B;
  - đốc công có leash dừng ở z −24.0;
  - đợt hold chỉ đi trên lane B → A (spec B §6.2).
  Vì vậy D và `CalmZoneB` an toàn bất kể patrol đã chạy hay chưa.

### 5.2 Patrol về A: trigger mới

S03 bật patrol ở lần đầu `CalmZoneB.body_exited`. Có D thì cách này hỏng: người chơi rời `CalmZoneB` qua mép bắc để
**vào** D, nên patrol sẽ bắn đúng lúc đi D. Trigger mới (`proposed`):

1. **Trigger:** `PatrolTriggerB.body_entered` với body là Retriever, khi `_calm_visited` đã là true từ trước, và patrol
   chưa chạy trong run này.
   - `PatrolTriggerB` lấp lối mở `GateB`. Rào thuế chắn phần còn lại của bề ngang, nên mọi đường về A từ vùng yên hay
     từ D đều phải đi qua nó. Mọi người chơi đã vào vùng yên đều kích hoạt patrol khi về, dù có đi D hay không.
   - **Lần đi lên:** người chơi chạm `PatrolTriggerB` trước khi chạm `CalmZoneB`. Lúc đó `_calm_visited` còn false nên
     không bắn.
   - **Lần đi D:** người chơi rời `CalmZoneB` ở mép bắc (z −32) và không chạm `PatrolTriggerB`, nên không bắn.
   - **Chỉ một lần mỗi run** (`_patrol_started`). Có mở cache B hay nhặt món ở D thì cũng vậy.
   - `CalmZoneB.body_exited` chỉ còn lo trạng thái UI, không bật patrol nữa.
2. **Diễn biến:** giữ nguyên spec B §5.5.2: spawn tại `PatrolSpawnB` = P0 B (7.0, +1.0), `PatrolAlertLampB` `armed` 2.0 s
   (`PATROL_CUE_LEAD`), sau đó đi P0 → P1 → P2 ở 1.6 m/s. P0 không dời.
3. **Spawn ngoài màn hình, có cue trước:**
   - **Lúc trigger bắn:** capsule (r 0.4) chạm mặt bắc hộp, tâm người chơi ở B (4.5, −25.9). P0 có gx + gz = 2.5 + 26.9
     = 29.4, tức D −20.8. Như vậy P0 ngoài viewport thật (−15.1) 5.7 m, với mọi tỉ lệ màn hình.
   - **Đi thẳng về A ở 4.0 m/s:** P0 vào khung inset sớm nhất ở t = (29.4 − 18.4) / 4 = **2.75 s**, dư 0.75 s so với
     2.0 s (ENM-17).
   - **Đi chéo về đông** (x tới 7.6) rồi thẳng: **t ≈ 2.30 s**. Vẫn đạt.
   - **Dash nối tiếp** (3 m / 0.3 s, hồi 0.8 s): t ≈ **1.85 s**, thiếu 0.15 s. Trigger S03 trong cùng tình huống là
     1.75 s, nên trigger mới không tệ hơn S03. Đây là câu hỏi mở 1 (§10.3).
   - Đèn `PatrolAlertLampB` và chữ HUD bắt đầu ở t = 0 trong mọi trường hợp. Sát thương sớm nhất không sớm hơn S03
     (≈ 5.8 s).
4. **Nếu người chơi bắn trigger rồi quay lại vào vùng yên hoặc D:** patrol vẫn đi lặp P0–P2 ở phía nam rào và không
   vào được vùng yên. Lúc người chơi về, patrol đã ở **phía trước** họ, thấy được từ tâm `CalmZoneB` (P2 ở L −8.0 /
   D −5.8). Không có spawn sau lưng.
5. **Lựa chọn khi về:** như spec B §5.5.4. Lách nửa đông của ngõ/quảng (x 5–8), hoặc đánh một skirmish ngắn. Không có
   gate thứ hai.

### 5.3 Bảng landmark ngược chiều

Mọi số đo theo khung 4:3 (L ∈ [−9.3, +14.7], D ∈ [−13.0, +22.9]). L/D là vị trí landmark so với chân người chơi.

**D → B**

| Đứng tại | Thấy được | L / D (m sàn) | Ghi chú |
|---|---|---|---|
| `DEntry` D (0, −1.0) | Khung lối D + `RouteDLintel` đỏ son | −2.5 / −2.5 (đỉnh +3.1) | Trái-dưới, sát người chơi |
| `DEntry` | `SignToA` (mũi tên + hình đèn phao) | −8.6 / −5.8 | Từ bến đỗ đã thấy biển về A |
| `DEntry` | `GateB` | −7.6 / −7.3 | — |
| `DEntry` | `CacheB` | −6.3 / −2.2 | Vật đã quen ở vùng yên B |
| Đứng nhặt `CargoD`, D (−1.5, −8.0) | Khung lối D + lanh tô | −6.4 / −8.5 | Trái-dưới |
| Đứng nhặt `TaxStampD`, D (0.8, −6.0) | Khung lối D + lanh tô | −6.6 / −5.4 | Trái-dưới |
| Giữa vùng yên D (0, −6.5) | Khung lối D + lanh tô | −6.4 / −6.4 (đỉnh −0.8) | Trái-dưới |
| Giữa vùng yên D (0, −6.5) | Đầu bắc mặt tiền tây B (cao 2.7) | −10.0 / −2.7 | Ngoài khung inset 4:3 0.7 m. Trong viewport thật 4:3 và khung 16:9. |
| Giữa vùng yên D (0, −6.5) | `SignToA` / `GateB` | −12.5 / −9.7 · −11.5 / −11.1 | Ngoài 4:3, trong 16:9 |

Phạm vi khung của lối D: với điểm D (px, pz), lối D có L = −0.707·(px − pz + 2.5).
- **Trong khung 4:3** khi px − pz ≤ 10.65. Vùng này gồm cả bến đỗ, `DEntry`, cả hai vòng tương tác (lớn nhất 8.6 và
  10.6) và nửa tây vùng yên.
- **Trong khung 16:9** khi px − pz ≤ 16.3. Cả sàn D thoả, vì mép đông x 4.5 và góc vát giữ px − pz ≤ 16.0.
- Lối D không bao giờ ra khỏi mép dưới (D ≥ −13 ở mọi điểm sàn đi được).

**B → A** (sau khi qua cầu ván về B)

| Đứng tại | Thấy được | L / D (m sàn) | Ghi chú |
|---|---|---|---|
| Mép bắc `CalmZoneB`, B (4.75, −31.0) | `SignToA` | −5.4 / −2.7 | Trái-dưới, là landmark đầu tiên khi bước khỏi cầu |
| Mép bắc `CalmZoneB` | `GateB` | −4.4 / −4.1 | Lối ra duy nhất về nam |
| `GateB` B (4.5, −25.0) | `CageRowNorthD` (tâm) | +14.1 / +15.9 (đỉnh +21.1) | D còn ở mép phải-trên rồi rời khung |
| `PatrolReturnPath/P2` B (3.0, −19.0) | `CageRowNorthD` (tâm) | +19.4 / … | Đã rời khung 4:3 và 16:9: “lồng kho rời khung → mái đỏ” (blockout §4) |
| Từ tâm `CalmZoneB` trở về A | mái đỏ quảng → `PatrolAlertLampB` → `LandmarkEntryLantern` → `SeamAB` → `BeaconA`/cầu tàu A | theo spec B §6.1 | Không đổi |

Không landmark nào trong hai bảng nằm sau vật cao hơn 1.0 m theo hướng nhìn: D chỉ có vật cao ở mép tây/bắc, B đã kiểm
ở spec B §6.1. Không dùng silhouette C/E để chỉ đường. Lanh tô đỏ son là màu khu B (`canvas_red`), không phải màu báo
nguy hiểm.

## 6. Đường nhìn và check D brief §6.1

### 6.1 Một chỗ đứng thấy cả lồng kho, hai nguồn và lối quay B

Chỗ đứng: `DEntry` D (0, −1.0), bước đầu tiên khi vào D. Người chơi tới đây chỉ qua cầu ván, không qua hazard hay combat.

| Thấy | L / D | Đỉnh |
|---|---|---|
| `CargoD` | +3.9 / +7.4 | — |
| `TaxStampD` | +5.3 / +2.5 | — |
| `CageRowNorthD` (tâm) | +6.5 / +8.7 | +13.9 |
| `CageRowNorthD` (đầu tây) | +4.1 / +11.1 | +16.3 |
| Lối quay B (khung + lanh tô) | −2.5 / −2.5 | +3.1 |
| Mặt nước (`ProbeZoneDWater`) | +8.5 / 0.0 | — |

Cả sáu điểm nằm trong khung 4:3. Ba hướng tách rời nhau trên màn hình:
- lồng kho và cargo ở trên;
- Dấu Thuế ở phải;
- lối B ở trái-dưới.

Nhờ vậy foreground không che lane D → B. Từ tâm `CalmZoneB` (trước khi vào D) cũng đã thấy được hai nguồn và lồng kho
(§2.1.4).

### 6.2 Che khuất trên đường đi

- Cầu ván rộng 2.5 m, không có vật nào cao hơn 0.5 m trên cầu.
- Khung lối D và lanh tô có thể che đầu người chơi trong khoảng 1 m cuối của cầu. Chúng mờ dần theo luật B.
- Không có foreground nào giữa camera và vùng yên D: phía nam/đông D là nước và lan can thấp.

## 7. Nhịp

| Beat | Thời điểm (ước tính) | Cường độ 0–5 | Nghỉ / ghi chú |
|---|---|---|---|
| Đốc công, thấy lối D đóng ở xa | 1:10–2:00 | 4 | Như spec B §7 |
| Gate B nâng + lối D mở cùng lúc | 2:00 | 1 | Một khung, hai lối mở |
| Vùng yên B, cache | 2:00–2:30+ | 0 | Điểm nghỉ 1 |
| B → D qua cầu ván (≈ 12 m) | 2:30–2:40 | 0 | Không cue, không địch |
| D: đọc nguồn, card, ba lô/Hộp | 2:40–3:40+ | 0–1 | **Điểm nghỉ 2**, không giới hạn. Áp lực chỉ là chỗ trống. |
| D → B → qua `GateB` | 3:40–3:50 | 1 | `PatrolTriggerB` bắn, đèn 2.0 s |
| Patrol / lách | 3:50–4:30 | 2–3 | Patrol ở phía trước, đi chéo màn hình |
| Về sân → thấy `BeaconA` → deck A | 4:30–4:50 | 1 | Nghỉ trên deck A |
| Gọi thuyền (S7) → hold 20 s (S8) | 4:50–5:15 | 3–4 | Như spec B §7. Hold 15–25 s (G14). Lane B là nguồn áp lực duy nhất. |
| Thuyền tới (S9) → lên thuyền | 5:15–5:30 | 1 | Kết thúc ở A, không ở D |

## 8. Loot và story item

| Vật | Vị trí | Footprint thế giới | Vì sao ở đây |
|---|---|---|---|
| `CargoD` (fixture cargo `2x2`) | D (−2.5, −9.0), ngay trước `CageOpenD` | pallet 1.2 × 1.2; khối 1.0 × 1.0, cao 0.9 tổng | Hàng bị giữ trong lồng chờ cân, đã được kéo ra tới cửa. Pallet đặt lệch khoảng 10° so với lồng. Vết kéo hàng là khối ván thấp, chỉ chạy từ cửa lồng tới mép vùng yên (D z −11.0…−10.5), không vào `=`. |
| `TaxStampD` (fixture `Dấu Thuế` `1x2`) | D (2.0, −6.5), trên bàn cân thấp | bàn 0.8 × 1.2; khối 0.3 × 0.6, cao 1.0 tổng | Dấu nằm ở bàn cân, chỗ hàng bị đóng dấu trước khi vào lồng. Món nhỏ, gọn, đối trọng với cargo cồng kềnh. |

- Không có story item ở D. Manifest R-17 ở A (bàn dispatch). Không có item mới, giá, rarity hay claim trong file này.
  Chữ card và luật nhặt thuộc TASK-96/98.
- Sau khi nhặt, `ItemBlock` biến mất. Pallet hoặc bàn cân còn lại làm dấu vết, không spawn món thay thế.
- Không có vết mòn trong vùng `=`. Vết mòn có lý do được phép đặt ngoài vùng `=`:
  - vạch nước 0.3 m trên chân lồng;
  - xích niêm cắt treo ở `CageOpenD`;
  - dấu thuế khắc trên mặt bàn cân.

## 9. Không extract ở D

### 9.1 Điều cấm trong scene D và lối D

| Cấm | Kiểm bằng |
|---|---|
| Beacon, đèn phao, vật liệu `signal_beacon`/`beacon_dim` | Test: không node tên chứa `beacon`/`Beacon`. Không vật liệu `signal_*` trong D. |
| Thuyền, xác thuyền có thể lên, cầu tàu, bậc lên thuyền | Không node tên chứa `boat`/`Boat`/`Pier`/`board`. Mép nước D chỉ có lan can liền. |
| Vùng gọi/giữ/lên thuyền (Area3D extract, `BeaconZone*`, `BoardZone*`) | Không node tên chứa `extract`/`Extract`. Flow không tạo zone extract ngoài A. |
| Nhãn exit, chữ “Gọi thuyền”, marker objective ở D | Không có prompt/marker world trong D. HUD do TASK-97. |
| Lối, thang, cửa, cống hay affordance tới C/E (cống van D–E của map brief không có trong slice) | Không mở lan can, không có gờ thả xuống nước, không có bánh van, không có silhouette C/E đặt trong D. |
| Checkpoint, teleport, dead-end bắt buộc | Lối D → B luôn mở sau khi đã mở (§2.3). D không có cửa nào đóng sau lưng. |

### 9.2 Đối chiếu D brief §6

| # | Check | Spec này |
|---|---|---|
| 1 | Nhìn/hiểu lồng kho, hai nguồn và lối D → B mà không qua hazard/combat mới | ✓ §6.1: cả bốn trong khung 4:3 từ `DEntry`. D không có địch hay hazard (§5.1). |
| 2 | Card: silhouette/tên → footprint → … ; cue ngoài màu | Ngoài phạm vi layout (TASK-96/97). Layout góp phần bằng hình khối nguồn: vuông 1:1 cho `2x2`, dẹt 1:2 cho `1x2` (§4). |
| 3 | Biết `2x2`/`1x2` khác nhau trước commit; sai/Hộp đầy/hủy giữ nguyên state | Ngoài phạm vi layout (TASK-98). Layout không có cơ chế tự nhặt: chỉ nhặt trong vòng 1.5 m và khi người chơi chủ động. |
| 4 | O2/O3/O4 vẫn để HP, objective, telegraph và route B đọc được; đóng bằng một action | Layout: không telegraph nào trong D. Lối B nằm ở trái-dưới, xa vùng card. Phần UI thuộc TASK-97. |
| 5 | Cargo/gear/container không vào Hộp; Manifest niêm hiện `chưa extract` | Ngoài phạm vi layout (TASK-96/98) |
| 6 | Cả ba outcome về D → B → A, không weight penalty/combat gate/forced pickup/death trap | ✓ Một đường về duy nhất, luôn mở. Không địch, không hazard. Patrol B chỉ chạy một lần, có cue (§5.2). Không chấm điểm lựa chọn. |
| 7 | D không có extract grammar/C/E affordance; A là nơi duy nhất call/hold/board | ✓ §9.1 |

## 10. Bàn giao và câu hỏi mở

### 10.1 TASK-99 (technical-artist): greybox

1. **Scene D:**
   - tạo `zone_d_floating_warehouse.tscn` với root `ZoneDFloatingWarehouse`, metadata `zone`, `placement_contract`,
     `greybox_status = "placeholder"`;
   - đặt mọi node ở §4 (tên đúng, vị trí ±0.1 m);
   - collision layer 2 cho sàn, lồng, lan can, pallet, bàn và `ItemBlock`;
   - sàn D liền mép với `RouteDPlanks` ở D z 0 (B z −34.5): không hở, không gờ, không kẹt capsule r 0.4.
2. **Vật liệu:**
   - chỉ dùng vật liệu thư viện hoặc vật liệu `env_*` mới tạo từ `water_deep`/`water`/`foam`/`iron`/`wood_dark` trong
     palette.json (thư viện hiện chưa có `foam`);
   - không `signal_`, không `light_` trong D;
   - D không mang `WorldEnvironment` hay đèn riêng; camera chụp đặt trong `LookdevOnly`, không `current` khi chạy.
3. **Sửa B:**
   - thêm `set_route_d_open(open: bool)` trên script root B (mặc định `closed` trong `_ready`), cùng các node
     `RouteDLintel`, `RouteDPlanks`, `RouteDSideRails`, `RouteDOpenDebris` và `PatrolTriggerB` theo §2.2/§4;
   - nới collision closed ra cả khung (4.1 m);
   - thêm lan can mép bắc B ngoài khung;
   - **xoá** `DistantWarehouseSilhouetteD` và sửa test B tương ứng;
   - cho lanh tô/khung mờ dần khi che người chơi;
   - giữ tên/transform `BlockedRouteD`, `BEntry`, `CalmZoneB`, `CacheB`, `GateB*`, `PatrolReturnPath/*`,
     `HoldLaneBSpawn`, `HoldLaneBPath/*`.
4. **Ảnh chụp** (scene chụp instance cả B và D đúng offset; camera game: trực giao, rotation (−30, 45, 0), size 20, vị trí
   = chỗ đứng + (15.45, 13.05, 11.6), thân y 0.95):
   - `zone_b_route_d_closed_{game,phone}.png`: đứng tâm `CalmZoneB` B (4.5, −28.75), sau `set_route_d_open(false)`;
   - `zone_b_route_d_open_{game,phone}.png`: cùng chỗ đứng, sau `set_route_d_open(true)` và hết chuyển động 1.0 s;
   - `zone_d_game.png`, `zone_d_gray.png` (1280×720), `zone_d_phone.png` (640×360): đứng `DEntry`;
   - probe D theo §4 vào group `zone_d_lookdev_probe`, ghi `zone_d_probe.json`.
   Ảnh cận cảnh cũ `zone_b_route_d_{game,gray,phone}.png` có thể bỏ. Ảnh mới thay vai trò đó.
5. **Test** `test_world_zone_d*.gd`:
   - marker/Area3D/offset đúng §4;
   - không node tên chứa extract/beacon/boat/board/pier trong D;
   - với B: `set_route_d_open(false)` thì collision cổng bật, ván tắt; `(true)` thì ngược lại;
   - từ B qua cầu sang D đi bộ được (raycast sàn liên tục từ B (4.75, −32.0) tới D (0, −1.0)).

### 10.2 TASK-102 (gameplay-engineer): nối vòng

1. Instance D tại world (11.75, 0, −36.95), không xoay, không sửa file world.
2. **Mở lối D:** trong nhánh làm `_gate_open = true` (hiện ở `_update_gate()`), gọi `_zone_b.set_route_d_open(true)`
   cùng lần cập nhật. Không gọi `(false)` sau đó. Lối D không tham gia điều kiện E0/E1 hay extract.
3. **Trigger patrol:**
   - bỏ việc bật patrol khỏi `CalmZoneB.body_exited`;
   - nối `PatrolTriggerB.body_entered` → nếu là Retriever, `_calm_visited` đã true và `_patrol_started` còn false thì
     `_start_patrol_return()`;
   - `CalmZoneB` vẫn lo `_calm_inside` và route UI.
4. **D:**
   - `CalmZoneD.body_entered/exited` → beat D cho route UI (chữ do TASK-97);
   - vòng tương tác 1.5 m quanh anchor `CargoD`/`TaxStampD` mở card TASK-100, ra khỏi vòng thì đóng như cache B;
   - nhặt xong thì ẩn `ItemBlock` và tắt collision của nó; pallet/bàn ở lại;
   - D không có call/board.
5. **Test qua Area3D/signal công khai:**
   - đi B → D (rời `CalmZoneB` mép bắc) thì patrol **không** chạy;
   - D → B → vào `PatrolTriggerB` thì patrol chạy đúng một lần;
   - vào `PatrolTriggerB` lần đầu (trước vùng yên) thì không chạy;
   - lối D `open` khi và chỉ khi gate B đã mở;
   - vòng S02 (rút sớm) và S03 (B → A, không D) vẫn xanh: S03 nay bật patrol qua `PatrolTriggerB`.

### 10.3 Câu hỏi mở

Không câu nào chặn TASK-99.

1. **ENM-17 có tính dash nối tiếp không?** (game-designer / ai-programmer)
   - Đi bộ thì trigger mới đạt (2.30–2.75 s).
   - Dash liên tiếp cho 1.85 s, S03 cho 1.75 s.
   - Nếu phải tính dash, hướng sửa nằm ở dữ liệu patrol, không ở layout D. Ví dụ: P0 dời xa hơn về +z ngoài deck B
     (cần đổi marker TASK-90), hoặc patrol đứng nấp sau `CoverB1` tới hết cue.
2. **Narrative:** xác nhận dòng “vết thương / người giữ tại chỗ” ở §0 và lý do đặt bàn cân, lồng niêm ở §8, hoặc thay
   bằng câu khác. Layout không phụ thuộc chữ.
3. **Art-director:** lanh tô đỏ son ở lối D dùng màu khu B. Cần xác nhận người chơi không đọc nhầm nó là “hướng về A”.
   Hướng về A vẫn do `SignToA` có hình đèn phao nói.
