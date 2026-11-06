# Spec UX — Khu B (S03): HUD combat cảm ứng, card loot cache B, lưới có xoay, overlay khi có nguy hiểm, stub HP 0

**Trạng thái:** spec UX `proposed` cho ui-programmer (TASK-89), narrative-writer (TASK-84: chữ theo bảng §8) và
qa-planner (TASK-91). Mọi toạ độ, kích thước, thời lượng, key mới và tên cue âm thanh/rung đều `proposed` cho tới khi
playtest. Spec này **không** đổi luật. Luật combat ở [combat spec](combat-slice-spec.md), luật loot ở
[loot B](zone-b-loot-spec.md), luật lưới ở [inventory spec](inventory-grid-slice-spec.md), vị trí trong thế giới ở
[layout B](zone-b-layout-encounter-spec.md). Spec này chỉ nói người chơi thấy gì, chạm vào đâu, và chuyện gì xảy ra.

**Nguồn:** [UX vòng A](loop-a-ux-flow-spec.md) (khung màn §3, lưới §4, HUD §5.3, O5 §5.7, S8 §5.8) ·
[wireflow](../vertical-slice-wireflow.md) §3, §5–§6, §9 · [build-readiness](../vertical-slice-build-readiness.md) G6–G8,
G10–G12, G14, invariant §8.4, §8.5, §8.7 · [combat](combat-slice-spec.md) §3, §3.6, §4.4, §5.1, §6, §7, §8.4, §12 ·
[layout B](zone-b-layout-encounter-spec.md) §1.3–§1.4, §5.4–§5.5, §6.2, §9, §10 · [loot B](zone-b-loot-spec.md) §6–§10 ·
[chuỗi Contract 1](contract-1-strings.md) §1. Tên riêng theo `memory/glossary.md` của studio.

## 1. Mục tiêu người chơi và gate phục vụ

**Mục tiêu người chơi:** ở Chợ Ngập (B), Người Thu Hồi đánh, né, giữ khiên và dùng thuốc bằng hai ngón cái mà không mất
dấu máu, objective hay cảnh báo lane. Tới vùng yên, người chơi đọc card từng món trong cache B, tự xoay và đặt món vào ba
lô hoặc Hộp Công Chứng. Nếu có nguy hiểm tới gần lúc đang mở panel, một chạm là đóng panel để phản ứng. Mỗi bước đều biết
điều gì vừa xảy ra và vì sao.

| Gate | Phần của spec phục vụ |
|---|---|
| G6 — S4 B combat: prompt không che máu/objective/telegraph | §3, §5.1, §5.2 |
| G7 — O2 card loot B: thứ tự, cue ngoài màu | §5.4 |
| G8 — O3 grid: chạm chọn + chạm ô, xoay, preview footprint, sai giữ nguyên, đóng không đổi, không che hết | §4, §5.5 |
| G10 — Hộp: niêm thẳng từ cache, không auto-swap, Hộp → ba lô khóa ở S03 | §4.3, §5.5 |
| G11 — xoay/di chuyển/xem/đóng **không** có xác nhận thừa | §4.2, §6 |
| G12 — patrol B → A báo trước (phần HUD) | §5.2 |
| G14 — cảnh báo lane B lúc hold (phần HUD) | §5.2, §5.3 |
| Invariant §8.7 — HUD/telegraph/objective đọc được khi O2/O3/O4 mở; overlay đóng được | §3.3, §5.6 |

## 2. Bản đồ luồng

### 2.1 Sơ đồ (chỉ phần mới hoặc đổi so với UX vòng A)

```text
HUD in-run (S2…S9) ── luôn có: H1 objective · H2 máu · H5 dòng cảnh báo · C1–C4 nút combat · H3 Đồ mang theo
  │
  ├─ vào tầm CacheB (1.5 m) và cache_state != empty ──▶ H4 `Mở rương` ──chạm──▶ O2B card(i = món còn lại đầu tiên)
  │     O2B ──chạm chip món j──▶ O2B card(j)                       (không đổi state)
  │     O2B ──[Bỏ qua]──▶ card(món còn lại kế sau i) | đóng nếu i là món cuối
  │     O2B ──[Đóng] / Back / ra ngoài tầm / chạm D1──▶ HUD        (không đổi state)
  │     O2B ──[Nhặt và xếp]──▶ O3B pickup(i)
  │        O3B ──[Xoay]──▶ O3B (chỉ đổi preview)
  │        O3B ──thả tay trên ô KHÔNG hợp lệ──▶ O3B + lý do (món vẫn ở cache; thử ô khác)
  │        O3B ──thả tay trên ô hợp lệ: commit_pickup ok──▶ O2B card(món còn lại đầu tiên) + toast đã xếp
  │                                                         └─ cache hết món ──▶ HUD + toast đã xếp
  │        O3B ──[Đóng] / Back──▶ O2B card(i)
  │        O3B ──ra ngoài tầm / chạm D1──▶ HUD (không commit)
  │
  ├─ H3 ──▶ O3B view (lưới có xoay) ──[Đóng] / Back / chạm D1──▶ HUD
  │
  └─ HP về 0 (bất kỳ lúc nào) ──▶ mọi overlay đóng như hủy ──▶ O6 stub ──(sau 2.5 s)[Về màn đầu]──▶ Boot
```

O2B và O3B là **một panel** (dock phải R10, §3.1) đổi nội dung giữa card và lưới. Loot spec §6.2.2 cho phép gộp như vậy
nếu giữ đúng các transition, và sơ đồ trên giữ đúng chúng.

### 2.2 Lối vào/ra, hủy và thử lại

| Màn / overlay | Vào từ | Ra (tiến) | Hủy / Back (một chạm) | Lỗi → thử lại |
|---|---|---|---|---|
| HUD combat | S2 (vào run) | — | Back không làm gì | Nút thuốc bị từ chối: R4' nêu lý do; thuốc không mất. |
| O2B card cache | H4 `Mở rương` | `Nhặt và xếp` → O3B pickup | `Đóng` (R3) / Back / D1 → HUD | — |
| O3B pickup | O2B | ô hợp lệ → O2B món kế, hoặc HUD nếu cache hết | `Đóng` / Back → O2B cùng món; D1 → HUD | Ô sai: lý do, món vẫn ở cache; thả tay ở ô khác. |
| O3B view | H3 | — | `Đóng` / Back / D1 → HUD | Ô sai: lý do, món giữ chỗ cũ. |
| O6 stub HP 0 | `Health.depleted` | `Về màn đầu` → Boot (bật sau 2.5 s) | Back = `Về màn đầu` sau 2.5 s; trước đó bỏ qua | Lỗi tải Boot: `UI_ERROR_SCENE_LOAD`, nút bật lại. |

### 2.3 Bước bị bỏ, gộp hoặc dời so với UX vòng A (S02)

| Ở S02 | Việc nó làm cho người chơi | Ở S03 việc đó nằm ở đâu |
|---|---|---|
| O2 (R7) và O3/O4 (R8) là hai panel riêng | Đọc card rồi mới xếp | Gộp vào một dock R10 (§3.1). Card và lưới đổi chỗ nhau trong cùng khung, nên người chơi không mất chỗ nhìn. R8 che gần hết thế giới; R10 chừa nhân vật và nửa trái màn hình (G8: không che hết telegraph). |
| Nút `Đóng` ở chân R8, bên trái | Thoát panel | Dời lên ô R3 (chỗ của `Đồ mang theo`). Mở và đóng cùng một chỗ. Thêm D1 làm lối đóng thứ hai khi có nguy hiểm (§5.6). |
| R4 prompt dưới-giữa (300–968) | Một prompt mỗi lúc | Dời thành R4' (296–688) để nhường chỗ hàng nút combat. Luật hàng đợi giữ nguyên (UX vòng A §5.3.3). |
| R5 nút ngữ cảnh dưới-phải | Một action theo vị trí | Dời lên R5', ngay trên hàng nút combat. Vẫn chỉ một nút, không tự kích hoạt. |
| Chạm ô = commit ngay | Đặt món bằng một chạm | Giữ một chạm. Thêm **preview khi ngón đè xuống**: footprint hiện trước, commit khi nhấc ngón trong cùng ô (§4.2). Thao tác S02 vẫn chạy như cũ. |
| §3.2.3 "không có thao tác giữ lâu" | Tránh thao tác khó trên mobile | Ngoại lệ duy nhất là nút khiên C3 (combat §12.1). "Giữ khu" vẫn là đứng trong vòng. |
| Túi đeo chéo trong O3/O4 `view` | Thấy vật hồi phục | Thành dòng chỉ-đọc trong dock (không chọn được, như S02). Số gói thuốc cũng hiện ở badge nút C4. |

## 3. Khung màn hình S03 (1280×720 tham chiếu, `proposed`)

### 3.1 Vùng

Toạ độ `x0–x1 × y0–y1` trên khung 1280×720, lề an toàn 16 px. Project dùng stretch `canvas_items` + `expand`: màn rộng
hơn thì thêm chiều ngang, màn 4:3 thì thêm chiều cao. Mỗi vùng ghi **neo** để ui-programmer biết vùng bám vào góc nào.

| Mã | Vùng | Toạ độ | Neo | Dùng cho |
|---|---|---|---|---|
| R1 | Objective | 16–656 × 16–72 | trên-trái | H1 (như S02). Không overlay nào che. |
| H2 | Máu | 16–336 × 80–120 | trên-trái | Thanh máu + số (§5.1). Không overlay nào che. |
| H5 | Dòng cảnh báo | 16–368 × 128–176 | trên-trái | Lane B / patrol (§5.2). Không overlay nào che. |
| D1 | Nút "nguy hiểm gần" | 16–304 × 192–288 | trên-trái | Chỉ khi có overlay mở và có nguy hiểm (§5.6). |
| R2 | Banner extract | 384–896 × 84–164 | trên-giữa | S7–S9 (như S02). Dock R10 lưới không che R2. |
| R3 | Ô góc trên-phải | 1168–1264 × 16–112 | trên-phải | `Đồ mang theo` khi không có panel; `Đóng` khi dock R10 mở. |
| W2' | Panel trạng thái beacon (HUD) | 976–1248 × 128–224 | trên-phải | Như W2 của S02, thu hẹp từ x 900 để không vào T. |
| T | **Vùng telegraph** | 320–960 × 232–560 | giữa màn (tâm 640, 360 = nhân vật) | **Không phần tử HUD nào** ở đây khi không có overlay (O5 và O6 là ngoại lệ đã biết). |
| R4' | Prompt/toast | 296–688 × 592–704 | dưới-trái, cạnh joystick | Một prompt mỗi lúc, tối đa 3 dòng. |
| R5' | Nút ngữ cảnh | 992–1216 × 448–560 (224×112) | dưới-phải | `Mở rương` / bàn dispatch / `Gọi thuyền` / `Lên thuyền`. |
| R6 | Joystick | 16–276 × 444–704 | dưới-trái | Như S02; không đặt gì khác. |
| C | Hàng nút combat | 720–1216 × 576–704 | dưới-phải | C1–C4 (§3.2). |
| R10c | Dock card | 704–1264 × 120–704 | phải | O2B card cache. |
| R10g | Dock lưới | 704–1264 × 176–704 | phải | O3B pickup / view. Bắt đầu từ y 176 để không che R2 ở S7–S9. |
| O6 | Stub HP 0 | 368–912 × 264–456 | giữa | §5.7. |

Vì sao dock nằm từ x 704: nhân vật luôn ở tâm màn (x 640), nên khi dock mở vẫn thấy nhân vật, mọi thứ bên trái và trên/dưới
nó, cùng R1, H2, H5, D1, R6. Ở `size` 20 m, 1 m ngang ≈ 36 px, nên vòng giữ ngõ (bán kính 2.5 m ≈ 90 px) quanh nhân vật
vẫn lộ phần lớn. Đây là cách giảm che telegraph mà không phải dừng thế giới (combat §12.2, xem §9 câu 1).

### 3.2 Hàng nút combat C và nút ngữ cảnh

| Mã | Nút | Toạ độ (1280×720) | Cỡ 1280×720 | Cỡ ở 640×360 (dp, tỉ lệ 0.5) | InputMap |
|---|---|---|---|---|---|
| C1 | `đánh` | 1088–1216 × 576–704 | 128×128 | 64×64 | `combat_attack` |
| C2 | `né` | 960–1072 × 592–704 | 112×112 | 56×56 | `combat_dodge` |
| C3 | `khiên` (giữ) | 832–944 × 592–704 | 112×112 | 56×56 | `combat_guard` |
| C4 | `dùng thuốc` + badge số | 720–816 × 608–704 | 96×96 | 48×48 | `use_remedy` |
| R5' | nút ngữ cảnh | 992–1216 × 448–560 | 224×112 | 112×56 | — |
| R3 | `Đồ mang theo` / `Đóng` | 1168–1264 × 16–112 | 96×96 | 48×48 | — |

Quy tắc bố cục:

1. **Cỡ tối thiểu 48 dp ở màn 640×360.** Trên điện thoại cao 360 dp, 1 px tham chiếu = 0.5 dp. Vì vậy mọi vùng chạm
   **mới** của S03 phải ≥ 96 px tham chiếu (= 48 dp). Mức 64 px của UX vòng A §3.2.1 chỉ còn là sàn cho phần tử cũ.
   Khoảng trống giữa hai nút ≥ 16 px (8 dp).
2. **Không chồng:** hàng C và R5' không giao R6, T, R4' hay nhau. R5' nằm **trên** C1/C2, không thay chỗ nút nào. Nút
   ngữ cảnh và nút combat **không bao giờ** dùng chung một vùng, nên chạm dồn `đánh` không thể mở rương hay lên thuyền.
3. **Chừa mép phải cho địch lane B (layout B §9, §10 câu 2):** hàng C kết thúc ở x 1216, chừa dải x 1216–1280 (khung inset
   5% của camera). Hàng C nằm ở y_norm ≥ 0.80 (16:9) và ≥ 0.85 (4:3, do neo đáy). Ở S8, R5' luôn ẩn. Vậy dải mép phải
   y_norm 0.55–0.80 không có phần tử HUD nào ở mọi tỉ lệ. Ở 4:3, điểm địch vào khung (y_norm 0.83) chạm mép trên của C1;
   đèn 3 phân đoạn, mũi tên sàn và H5 là cue chính cho trường hợp này (§9 câu 2). TASK-88 đo lại trên greybox.
4. Neo: C và R5' bám góc dưới-phải; R1, H2, H5, D1 bám góc trên-trái; R4' bám dưới-trái (cách R6 20 px).
5. Thứ tự từ góc vào trong theo tần suất dùng: `đánh` (góc, lớn nhất) → `né` → `khiên` → `thuốc` (xa nhất, nhỏ nhất, để
   khó chạm nhầm).

### 3.3 Quy tắc chạm và chữ (bổ sung UX vòng A §3.2)

1. **C1, C2, C3 kích hoạt khi ngón chạm xuống**, không đợi nhấc ngón. Lý do: wind-up địch chỉ 0.8–1.0 s. C4 và mọi nút
   khác vẫn theo UX vòng A §3.2.2 (xuống và nhấc trong cùng vùng). Lý do: thuốc chỉ có một gói, nên chạm lướt không được
   tiêu nó.
2. **C3 là thao tác giữ duy nhất** (ngoại lệ của UX vòng A §3.2.3). Ngón chạm xuống C3 nâng khiên. Khiên giữ theo
   **chính ngón đó** tới khi ngón đó nhấc, kể cả khi ngón trượt ra khỏi nút. Touch bị hủy hoặc app xuống nền = nhả. Ngón
   thứ hai chạm C3 khi đang giữ thì bị bỏ qua.
3. Đa chạm: joystick (ngón trái) + một nút combat (ngón phải) chạy cùng lúc. Khi đang giữ C3, một ngón khác chạm C2 thì
   né. Nếu ngón trên C3 còn giữ khi dash xong, khiên nâng lại (combat §3.4.5).
4. Phím (J/Space/K/Q) và tay cầm OR với cảm ứng; nút trên HUD hiện trạng thái nhấn theo cả hai nguồn. Back/Esc không dùng
   cho combat; Back vẫn đóng overlay trên cùng.
5. **Chữ:** mọi chữ mới của S03 ≥ 24 px tham chiếu (12 sp ở 640×360). Số trên badge và số máu ≥ 28 px. Chữ phụ cũ 20 px
   của S02 không dùng cho phần tử mới. Không nhấp nháy: mọi nhấn mạnh là **một** lần phóng to/đổi viền, tối đa 1 lần/giây.
6. Mỗi trạng thái có ít nhất một kênh ngoài màu: icon, hình, chữ, vị trí hoặc chuyển động một lần (G7, wireflow §9).
7. Chặn chạm xuyên `UI_OPEN_GUARD_SECONDS = 0.3` áp dụng cho O2B, O3B, O6 như mọi overlay. **Không** áp dụng cho C1–C4
   (nút HUD luôn sẵn).
8. Cue âm thanh/rung chỉ là tên cho sau (S03 không có âm thanh). Cue mới: `combat_attack`, `combat_dodge`,
   `combat_guard_up`, `combat_guard_block`, `combat_hit_taken`, `combat_remedy_start`, `combat_remedy_done`,
   `combat_remedy_interrupted`, `hud_lane_alert`, `hud_danger_near`, `ui_rotate`, `ui_preview_ok`, `ui_preview_bad`;
   rung: `haptic_light`, `haptic_warn`, `haptic_success` (như S02), `haptic_hit` (mới).

## 4. Thành phần dùng chung: lưới S03 (O3B pickup và view)

Cùng thành phần lưới của UX vòng A §4, thêm xoay, preview footprint khi ngón đè xuống, và bố cục dock. Thành phần chỉ gọi
`preview_*`/`commit_*` của `RetrieverInventory`; không tự sửa inventory.

### 4.1 Bố cục dock lưới R10g (704–1264 × 176–704)

| Phần tử | Toạ độ | Nội dung / dữ liệu | Key |
|---|---|---|---|
| Dải món S (hai dòng) | 720–1248 × 184–264 | Dòng 1: silhouette + tên + chip footprint `{w}×{h}` (vẽ ô + chữ) + `×{quantity}` nếu > 1 + tag nguồn. Dòng 2: hướng dẫn **hoặc** preview **hoặc** lý do. | §4.4 |
| Nhãn ba lô | 720–1008 × 268–296 | icon ba lô + chữ | `LOADOUT_LABEL_BACKPACK` |
| Lưới ba lô 3x4 | 720–1008 × 296–680 | ô 96×96 (48 dp ở 640×360) | — |
| Nhãn Hộp | 1056–1248 × 268–296 | icon ổ khóa niêm + chữ | `LOADOUT_LABEL_NOTARY_BOX` |
| Hộp 2x2 | 1056–1248 × 296–488 | ô 96×96; món trong Hộp mang nhãn niêm (icon + chữ) | `INVENTORY_SEAL_LABEL_*` |
| Nút `Xoay` | 1056–1248 × 504–600 (192×96) | Chỉ **hiện** khi món đang chọn/đang cầm có `rotatable` và không vuông. Nếu không thì để trống (không có nút tắt). | `INVENTORY_BUTTON_ROTATE` |
| Túi đeo chéo (chỉ đọc) | 1056–1248 × 616–680 | icon + tên vật hồi phục + `×{quantity}`. Không chọn được, không phải vùng chạm. | `LOADOUT_LABEL_SLING_POUCH` |
| `Đóng` | R3 1168–1264 × 16–112 | thay chỗ `Đồ mang theo` khi dock mở | `CARD_ACTION_CLOSE` |
| Tiêu đề (chỉ `view`) | trong dòng 1 của S khi chưa chọn món | — | `INVENTORY_PANEL_TITLE` |

Món trong ô: vẽ theo footprint hiệu lực (`ItemInstance.cells()`), gồm silhouette, `×{quantity}` (chữ) nếu là chồng > 1,
nhãn niêm nếu ở Hộp, badge vật chứng nếu là `evidence` (như S02).

### 4.2 Quy tắc chọn → preview → đặt (thay UX vòng A §4.2 cho S03)

1. **Chọn:** chạm một món → món **được chọn** (viền dày + icon "đang chọn"). Chạm lại → bỏ chọn. Chạm món khác → đổi lựa
   chọn. Ở `pickup`, món trong cache coi như đã được chọn và không bỏ chọn được.
2. **Đánh dấu anchor:** khi có món được chọn, thành phần gọi `preview_*` cho mọi anchor của mọi lưới được phép, với
   hướng **đang chờ** (`pending_rotated`, §4.3). Ô anchor hợp lệ: **viền liền + icon tích**. Ô không hợp lệ: **gạch
   chéo**. Người chơi thấy kết quả trước khi chạm.
3. **Preview khi ngón đè xuống (mới):** ngón chạm xuống một ô → vẽ **bóng footprint** đủ mọi ô mà món sẽ chiếm khi lấy ô
   đó làm anchor (ô trên-trái).
   - Hợp lệ: bóng là **khung liền dày** bao các ô footprint; dòng 2 của S hiện preview. Đặt vào ba lô dùng
     `INVENTORY_PREVIEW_FITS_BACKPACK`; đặt vào Hộp dùng `INVENTORY_PREVIEW_FITS_NOTARY_BOX` (nói rõ là niêm, và chưa
     rút lại được trong run).
   - Không hợp lệ: các ô footprint trong biên được **gạch chéo**; ô trong `blocking_cells` có thêm **icon ×**; phần ra ngoài
     biên hiện thành một mũi tên nhỏ ở mép lưới. Dòng 2 của S hiện lý do: tên món · nhãn `INVENTORY_REASON_*`.
   - Bóng vẽ lệch khỏi ngón khi cần: dòng 2 của S luôn mô tả kết quả bằng chữ, nên ngón che ô cũng không làm mất thông tin.
   - Cue: `ui_preview_ok` / `ui_preview_bad`, chưa rung.
4. **Nhấc ngón trong cùng ô** (di chuyển < 16 px) → commit nếu preview hợp lệ (`commit_pickup` / `commit_move` /
   `commit_seal` theo §4.3, với `pending_rotated`). Thành công: món hiện ở chỗ mới, cue `ui_place_ok` (vào Hộp:
   `ui_seal_ok`), `haptic_success`. Đây vẫn là **một chạm**, giống S02.
5. **Nhấc ngón trên ô không hợp lệ** → **không** commit. Món giữ chỗ cũ (hoặc vẫn ở cache), vẫn được chọn. Lý do và icon ×
   ở `blocking_cells` giữ nguyên tới lần chạm sau. Cue `ui_invalid`, `haptic_warn`.
6. **Trượt ngón ra khỏi ô** (≥ 16 px) hoặc touch bị hủy → xóa bóng, không commit, không lý do. Đây là cách "đổi ý" giữa
   chừng. Không cần kéo-thả: trượt chỉ có nghĩa là hủy.
7. Commit trả `ok == false` dù preview hợp lệ (state đổi giữa chừng) → xử lý như quy tắc 5 với lý do mới.
8. Chạm ô anchor hiện tại của món đang chọn:
   - nếu `pending_rotated` bằng hướng hiện tại → bỏ chọn, không lệnh nào (như S02);
   - nếu khác → preview/commit **xoay tại chỗ** (`commit_move(uid, cùng lưới, cùng anchor, pending_rotated)`), theo
     quy tắc 3–5.
9. Không có kéo-thả, tự xếp, `nhặt tất cả`, bỏ món, hoán đổi hay "đặt vào chỗ gợi ý" ở S03. Ô gợi ý `suggest_slot` (chỉ ở
   ba lô) có thêm icon gợi ý trong `pickup`; người chơi vẫn phải tự chạm.

### 4.3 Xoay và đích được phép (S03)

**Nút `Xoay`:**

1. Chạm `Xoay` → đảo `pending_rotated` của món đang chọn/đang cầm. Ngay trong cùng khung hình:
   - chip footprint ở dòng 1 của S đổi (vd. `1×2` đứng → `2×1` nằm, cả hình ô lẫn chữ);
   - icon trên nút `Xoay` quay 90° (một lần);
   - mọi dấu anchor được tính lại bằng `preview_*` với hướng mới.
   **Không** có lệnh `commit_*` nào chạy; state không đổi (G11: xoay không cần xác nhận). Cue `ui_rotate`.
2. `pending_rotated` bắt đầu bằng `rotated` hiện tại của món (món trong cache: `false`). Bỏ chọn, đổi món, đóng dock hoặc
   app xuống nền → bỏ `pending_rotated`.
3. Nút ở trạng thái "đã xoay" (khác hướng lưu) có viền dày + chữ chip khác. Không chỉ đổi màu.
4. Món vuông (đồng xu, Manifest) và món không xoay được: không có nút `Xoay` (vùng để trống). Vì vậy
   `INVENTORY_REASON_NOT_ROTATABLE` không xuất hiện qua UI ở S03.

**Đích được phép** (loot B §8.1, UX vòng A §4.3):

| Nguồn → đích | `pickup` (từ cache) | `view` (trong run) |
|---|---|---|
| Cache → ba lô | `commit_pickup(item, backpack, anchor, pending_rotated)` | — |
| Cache → Hộp | `commit_pickup(item, notary_box, anchor, pending_rotated)` = **niêm**, không O5 | — |
| Trong ba lô / trong Hộp (di chuyển, xoay) | — | `commit_move(uid, cùng lưới, anchor, pending_rotated)` |
| Ba lô → Hộp | — | `commit_seal(uid, anchor, pending_rotated)`, không O5 |
| Hộp → ba lô | — | gạch chéo; lý do `INVENTORY_REASON_WITHDRAW_LOCKED` |
| → túi đeo chéo | không vẽ túi như một lưới; không có đích | như `pickup` |

Đặt vào Hộp ở S03 là quyết định cho cả run vì Hộp → ba lô bị khóa (loot B §8.2.8). Spec không thêm O5 cho việc này (luật
S02, beacon §7.2). Thay vào đó, người chơi thấy câu `INVENTORY_PREVIEW_FITS_NOTARY_BOX` **trước khi nhấc ngón**, và có thể
trượt ngón ra để hủy (§4.2.6).

### 4.4 Dải món S — dòng 2 theo trạng thái

| Trạng thái | Dòng 2 hiện | Key |
|---|---|---|
| `view`, chưa chọn | hướng dẫn | `LOADOUT_HINT_SELECT` |
| `pickup`, chưa chạm | hướng dẫn nhặt | `INVENTORY_PICKUP_HINT_ITEM` |
| Ngón đè, hợp lệ | preview ba lô / Hộp | `INVENTORY_PREVIEW_FITS_BACKPACK` / `INVENTORY_PREVIEW_FITS_NOTARY_BOX` |
| Ngón đè hoặc vừa nhấc, không hợp lệ | tên món · lý do | `INVENTORY_REASON_*` |
| Món Hộp được chọn ở `view` | nhắc khóa rút | `INVENTORY_REASON_WITHDRAW_LOCKED` (chỉ khi chạm ô ba lô) |

Tag nguồn ở dòng 1: `pickup` = `INVENTORY_PICKUP_SOURCE_CACHE` (món còn ở rương). Món đã ở Hộp = nhãn niêm. Món evidence =
badge vật chứng như S02.

## 5. Từng màn, overlay và phần tử

### 5.1 HUD combat: máu, nút, objective

**Mục đích:** luôn cho biết còn bao nhiêu máu, nút nào bấm được ngay, nút nào đang hồi/khóa và vì sao, và một objective.

| Phần tử | Vùng | Hiện khi | Dữ liệu | Key |
|---|---|---|---|---|
| H1 Objective | R1 | luôn (trừ O6, S10) | theo bảng 5.1.1 | `HUD_OBJECTIVE_*` |
| H2 Máu | H2 | luôn (trừ O6, S10); **không** bị overlay che | `Health.hp`, `Health.max_hp`, signal `changed` | `HUD_HEALTH_VALUE` (`{hp}/{max_hp}`), `HUD_HEALTH_LOW` |
| C1 `đánh` | §3.2 | S2–S9, khi không có O2B/O3B/O5/O6 | `RetrieverCombat.state` | `HUD_BUTTON_ATTACK` + icon |
| C2 `né` | §3.2 | như C1 | `dodge_cooldown_changed(remaining)` | `HUD_BUTTON_DODGE` + icon |
| C3 `khiên` | §3.2 | như C1 | `state` (`guarding` `raising`/`raised`) | `HUD_BUTTON_GUARD` + icon |
| C4 `thuốc` | §3.2 | như C1 | số `sling_remedy` trong `sling_pouch` (tổng `quantity`); `state == using_remedy` + thời gian kênh | `HUD_BUTTON_REMEDY` + icon + badge số |
| H4 nút ngữ cảnh | R5' | theo 5.1.2 | như S02 + `cache_state`, khoảng cách tới `CacheB` | §5.1.2 |
| H3 `Đồ mang theo` | R3 | khi không có dock R10 hay O5/O6 | — | `HUD_BUTTON_INVENTORY` |

**Thanh máu H2:** icon máu + thanh **10 đoạn** (mỗi đoạn 10 HP, ứng với `RETRIEVER_MAX_HP` 100; nếu max khác thì
`ceil(max_hp / 10)` đoạn) + số `{hp}/{max_hp}` ≥ 28 px. Số đoạn còn đặc = `ceil(hp / 10)`; số chữ luôn là giá trị đúng.
- Mất máu: đoạn bị mất để lại một **vệt rỗng có viền** trong 0.5 s rồi biến mất (một lần, không chớp). Cue
  `combat_hit_taken`, `haptic_hit`.
- Đòn bị khiên chặn hết (chip 0): thanh không đổi; cue `combat_guard_block`.
- Hồi máu: các đoạn được tô lại bằng một lần quét.
- `hp ≤ ceil(max_hp × HUD_LOW_HP_RATIO)` với `HUD_LOW_HP_RATIO = 0.3`: icon đổi sang **hình nứt**, viền thanh dày hơn,
  có tag `HUD_HEALTH_LOW`. Không nhấp nháy, không rung lặp.

#### 5.1.1 Objective H1 trong S03 (thứ tự ưu tiên, lấy dòng đầu tiên đúng)

| # | Điều kiện | Key |
|---|---|---|
| 1 | S7 / S8 / S9 | như UX vòng A §5.8 |
| 2 | `encounter_b_engaged` (một trong `tax_guard_b`, `foreman_b` đã phát `role_first_seen`) **và** `GateB` chưa mở | `HUD_OBJECTIVE_CROSS_TAX_POST` |
| 3 | `desk_state == HAS_MANIFEST` | `HUD_OBJECTIVE_TAKE_MANIFEST` |
| 4 | còn lại (đang mang Manifest) | `HUD_OBJECTIVE_DELIVER_PIER_A` |

Đổi objective có một lần trượt chữ; không có chữ "hoàn thành". Patrol về A **không** đổi objective (Beat 6 giữ
`DELIVER_PIER_A`).

#### 5.1.2 Nút ngữ cảnh H4 ở R5' (một nút, ưu tiên từ trên xuống)

| Điều kiện | Nhãn | Chạm → |
|---|---|---|
| `can_board()` | icon bậc lên + `EXTRACT_S9_BUTTON_BOARD` | S10 |
| `can_call()` | icon thuyền + `EXTRACT_E1_BUTTON_CALL` | O5 |
| trong tầm bàn dispatch và `HAS_MANIFEST` | icon tương tác + `WORLD_INTERACT_DISPATCH_DESK` | O2 Manifest (S02) |
| trong `CACHE_INTERACT_RADIUS_M` (1.5 m) quanh `CacheB` **và** `cache_state != empty` | icon rương + `WORLD_INTERACT_CACHE_B` | O2B card |
| còn lại, hoặc S8, hoặc có overlay mở, hoặc O6 | ẩn | — |

Bốn điều kiện cách xa nhau trong thế giới, nên thực tế chỉ một đúng mỗi lúc. Thứ tự ưu tiên chỉ để code tất định. Nút
không bao giờ tự kích hoạt khi bước vào vùng.

#### 5.1.3 Trạng thái từng nút combat

Mỗi trạng thái có hình/icon/chữ riêng, không chỉ đổi màu. "Khóa" chỉ hiện cho trạng thái kéo dài > 0.5 s, để nút không
chập chờn trong `hitstun` 0.3 s hay đòn 0.5 s.

| Nút | Sẵn | Đang chạy | Hồi (cooldown) | Khóa (hiện trên nút) | Ẩn |
|---|---|---|---|---|---|
| C1 `đánh` | icon kiếm + chữ | nút lún 0.1 s khi bắt đầu đòn | — | **gạch chéo mảnh + icon khóa nhỏ** khi `guarding` hoặc `using_remedy` | overlay mở, O6 |
| C2 `né` | icon mũi tên dash + chữ | nút lún | **quạt rỗng quét lại đầy** theo `remaining / DODGE_COOLDOWN`; hết hồi: nút phóng to một lần (`combat_dodge_ready` chỉ là tên cue) | — (né được cả lúc giữ khiên và lúc dùng thuốc: sẽ ngắt thuốc) | overlay mở, O6 |
| C3 `khiên` | icon khiên hạ + chữ | đang giữ: nút lún + **icon khiên dựng** + viền dày; `raising` 0.1 s không cần hình riêng | — | không bao giờ khóa: khiên được phép ngắt thuốc (combat §3.5.3) | overlay mở, O6 |
| C4 `thuốc` | icon gói thuốc + badge số ≥ 1 | **vòng tiến độ** 0→1 trong `REMEDY_USE_SECONDS` 1.0 s quanh icon | — | badge `0` + gạch chéo khi hết thuốc; gạch chéo khi `guarding` | overlay mở, O6 |

Chạm nút đang khóa hoặc đang hồi: không làm gì với combat; nút nảy một lần + cue `ui_invalid`, không rung. Riêng C4 chạm
lúc bị từ chối (combat §3.5.1) → R4' hiện lý do (toast 3 s):

| `remedy_refused(reason)` | R4' |
|---|---|
| `no_remedy` | `COMBAT_REMEDY_REFUSED_NO_REMEDY` |
| `hp_full` | `COMBAT_REMEDY_REFUSED_HP_FULL` |
| `overlay_open` | không hiện (C4 đã ẩn; lý do chỉ cho test) |

Kênh thuốc bị ngắt (sát thương, né, khiên, overlay, HP 0) → vòng tiến độ biến mất, badge giữ nguyên số, R4' hiện
`COMBAT_REMEDY_INTERRUPTED` (nói rõ là thuốc **chưa mất**). Cue `combat_remedy_interrupted`. Dùng xong → badge giảm 1, thanh
máu tô lại, cue `combat_remedy_done`.

| Trạng thái HUD | Người chơi thấy |
|---|---|
| Mặc định (vào run) | H1, H2 đầy 10 đoạn `100/100`, C1–C4 sẵn, C4 badge `1`, H5 trống, R5' ẩn. |
| Trong combat | Như trên + trạng thái nút theo bảng; R4' có thể có prompt vai địch (§5.2). |
| Máu thấp | Icon nứt + tag `HUD_HEALTH_LOW`. |
| Hết thuốc | C4 badge `0` + gạch chéo; chạm → lý do. |
| Bị gián đoạn (app xuống nền) | Khiên hạ (touch hủy); khi trở lại, nút C3 ở trạng thái sẵn; không lệnh combat nào chạy ngầm. Tick combat kẹp 0.1 s (combat §2.2). |
| Chết giữa action | §5.7. |

### 5.2 Prompt combat, cảnh báo patrol và lane (H5, R4')

**Mục đích:** nói một lần vai địch mới là gì, và nói nguy hiểm đang tới từ đâu, mà không che telegraph.

| Sự kiện (nguồn) | H5 (dòng cảnh báo, giữ tới khi hết) | R4' (prompt/toast) |
|---|---|---|
| `role_first_seen(&"tax_guard")` lần đầu trong run | — | `PROMPT_COMBAT_TAX_GUARD_FIRST_SEEN` |
| `role_first_seen(&"foreman")` lần đầu trong run | — | `PROMPT_COMBAT_FOREMAN_FIRST_SEEN` |
| `patrol_cue_started` (layout B §5.5) | icon mũi tên + `HUD_ALERT_PATROL_B`; ẩn khi patrol `withdrawn`/`down` hoặc người chơi về deck A | — |
| `lane_alert_started` (director §7, lần đầu ở t = 0) | icon mũi tên + `HUD_ALERT_LANE_B`; giữ tới `boat_ready` hoặc `ENDED_DEATH` | `EXTRACT_S8_LANE_ALERT` một lần, 4 s |
| Đèn lane lại `armed` ở t = 7 | H5 nhấn mạnh một lần (phóng to) | — |

Quy tắc:

1. **Icon mũi tên của H5** quay về phía vị trí màn hình của đèn báo đang bật (`LaneBAlertLamp` hoặc `PatrolAlertLampB`).
   Nếu đèn ngoài màn hình thì quay về mép gần nhất. Hướng + chữ "Chợ Ngập" là hai kênh ngoài màu. Cue `hud_lane_alert`,
   `haptic_warn` một lần khi bật.
2. Prompt vai địch: tối đa **một** lần mỗi vai mỗi run (combat §5.1.9). Ẩn khi: hết `ROLE_PROMPT_SECONDS = 6` s, người chơi
   chạm vào prompt, vai đó `withdrawn`/`down`, người chơi vào `CalmZoneB`, hoặc một overlay mở. Không hiện lại. Patrol là
   `tax_guard` nên không có prompt thứ hai (Beat 6: prompt combat không quay lại).
3. Hàng đợi R4' như UX vòng A §5.3.3: một mục mỗi lúc; toast lý do (thuốc, đã xếp, rời tầm) chen trước prompt. Một prompt
   bị toast đẩy thì hiện tiếp phần thời gian còn lại.
4. Không có chữ nào ở T. Không có nhãn trên đầu địch ở S03; vai địch được đọc bằng silhouette, vòng/vạch telegraph và tư
   thế (combat §6.1).
5. Ở `CalmZoneB`: R4' không hiện prompt combat; H5 trống (patrol chỉ kích hoạt khi rời vùng).

### 5.3 S8 giữ khu khi có địch (bổ sung UX vòng A §5.8)

| State | H1 | R2 | H5 | R5' | C1–C4 |
|---|---|---|---|---|---|
| S8 trước `lane_alert_started` | `HUD_OBJECTIVE_HOLD_PIER_A` | đồng hồ | trống | ẩn | sẵn |
| S8, đèn `armed`/`active` | như trên | đồng hồ | `HUD_ALERT_LANE_B` + mũi tên | ẩn | sẵn |
| S8 tạm dừng (ra khỏi vòng, kể cả do dash) | như trên | số đứng + icon tạm dừng + `EXTRACT_S8_HOLD_PAUSED` | giữ | ẩn | sẵn |
| S9 | `HUD_OBJECTIVE_BOARD_BOAT` | `EXTRACT_S9_BOAT_READY` | trống (địch rút) | `Lên thuyền` khi `can_board()` | sẵn |

R5' ẩn suốt S8, để dải mép phải trống cho điểm địch vào khung (§3.2.3). S9 không bị chặn bởi địch: `Lên thuyền` hiện khi
`can_board()` đúng, dù còn địch trên màn.

### 5.4 O2B — Card loot cache B (dock R10c, 704–1264 × 120–704)

**Mục đích:** đọc từng món trong cache theo thứ tự G7, chuyển món bằng chạm, rồi chọn `Nhặt và xếp` hoặc `Bỏ qua`. Mở,
đổi món hay đóng không đổi state (loot B §6.2).

| Phần tử (trên xuống) | Toạ độ / cỡ | Dữ liệu | Key |
|---|---|---|---|
| Dải chip món | 720–1248 × 128–224; một chip mỗi món **còn lại** theo `order`, mỗi chip ≥ 160×96 (2 món: 256×96) | silhouette + sơ đồ ô footprint + chữ `{w}×{h}` + `×{quantity}` | `INVENTORY_FOOTPRINT_CHIP`, `CARD_QUANTITY_SUFFIX` |
| Chip đang xem | như trên | **viền dày + mấu nhọn chỉ xuống card** (hình, không chỉ màu) | — |
| Dòng 1 — silhouette + tên | dưới chip | `display_name_key`, `ItemInstance.quantity` | `CARD_<ID>_NAME` + `CARD_QUANTITY_SUFFIX` nếu > 1 |
| Dòng 2 — footprint + ô trống | 2 hàng chữ | Hàng a: sơ đồ ô `w×h` vẽ bằng ô có viền + chữ `CARD_<ID>_FOOTPRINT` + tag có icon: `CARD_TAG_ROTATABLE` (nếu `rotatable` và không vuông), `CARD_TAG_STACKABLE`, `CARD_TAG_SEALABLE`. Hàng b: icon ba lô + `CARD_BACKPACK_FREE` (`{free}/{total}`) + icon kết quả `fit_backpack` + chữ; icon Hộp + icon kết quả `fit_notary_box` + chữ | `CARD_FIT_*` (§8) |
| Dòng 3 — công dụng + giá tương quan | ≤ 2 hàng | loot B §7.3; không số tiền | `CARD_<ID>_USE` |
| Dòng 4 — claim | 1 hàng | **icon phe** (hình riêng của `house_hac_thue`) + tên phe | `CARD_<ID>_CLAIM` |
| Dòng 5 — lớp thẩm định | 1 hàng | **6 dấu con dấu, n dấu đặc + (6 − n) dấu rỗng** theo `appraisal_class` + chữ lớp | `CARD_<ID>_RARITY` |
| Dòng 6 — lore | ≤ 2 hàng | — | `CARD_<ID>_LORE` |
| Nút `Bỏ qua` | 720–904 × 600–696 (184×96) | — | `CARD_ACTION_SKIP` |
| Nút `Nhặt và xếp` | 920–1248 × 600–696 (328×96), icon tay + ô | — | `CARD_ACTION_PICK_AND_PLACE` |
| `Đóng` | R3 | — | `CARD_ACTION_CLOSE` |

Icon kết quả vừa ô (hình, không màu): `fits` = ô có dấu tích · `fits_rotated_only` = ô có mũi tên xoay + dấu tích ·
`no_fit` = ô có dấu × · `not_sealable` = ổ khóa gạch chéo. Icon phe không mang màu rarity; dấu bậc rarity không mang
icon phe (G7: claim tách khỏi rarity). Không có badge vật chứng cho hai món này (loot B §3.2.4).

Quy tắc:

1. Mở (chạm R5' `Mở rương`) → card của món còn lại đầu tiên. `RetrieverCombat.set_overlay_open(true)`. Combat bị khóa
   theo combat §3.6; C1–C4 bị dock che và ẩn.
2. **Chuyển món:** chạm chip j → card(j). Không vuốt, không cuộn ngang. Không đổi inventory/cache; cue `ui_tap`.
3. `Bỏ qua` → card(món còn lại **kế sau** i theo `order`); nếu i là món cuối → đóng dock. Không quay vòng; chip của món đã
   bỏ qua vẫn còn (món vẫn ở cache). Không có câu trách.
4. `Nhặt và xếp` → O3B `pickup(i)` trong cùng dock (§5.5).
5. Lần đầu mở card trong run: R4' hiện `PROMPT_LOOT_COLOR_NOT_VALUE` (Beat 4, tối đa một lần mỗi run). Ẩn khi đóng dock,
   khi chạm vào nó, hoặc sau 8 s.
6. Ra ngoài 1.5 m quanh `CacheB` → dock đóng như `Đóng`; R4' toast `CACHE_CLOSED_LEFT_RANGE`.

| Trạng thái | Người chơi thấy |
|---|---|
| `full` (2 món) | 2 chip; card món 1 (đồng xu `×2`, không tag xoay). |
| `partial` (1 món) | 1 chip (vẫn hiện để biết còn 1 món); card món đó. |
| `empty` | Không mở được: R5' không hiện `Mở rương`. |
| Không vừa Hộp (sổ khi Manifest đã niêm) | Dòng 2 hàng b: Hộp `no_fit` (icon × + chữ). `Nhặt và xếp` vẫn bật (ba lô luôn vừa ở S03, loot B §9.1). |
| Chỉ vừa khi xoay (`fits_rotated_only`, fixture) | Ba lô: icon mũi tên xoay + tích + chữ. |
| Bị gián đoạn | Dock giữ nguyên card khi trở lại; chặn chạm 0.3 s lại. |
| Có nguy hiểm | D1 hiện (§5.6). |
| Chết giữa action | Dock đóng như `Đóng`; sang O6. |

### 5.5 O3B — Lưới trong dock (pickup từ cache, và view từ H3)

**Mục đích:** người chơi tự chọn ô và hướng cho món ở ba lô **hoặc** Hộp. Chỉ ô hợp lệ mới chuyển món; sai thì món giữ
nguyên chỗ và người chơi biết vì sao.

**`pickup(i)`** (từ O2B):

1. Dòng 1 của S: món i + tag `INVENTORY_PICKUP_SOURCE_CACHE`. Món coi như đang cầm (§4.2.1). Anchor của ba lô và Hộp được
   đánh dấu với `pending_rotated = false`. Nếu món xoay được, nút `Xoay` hiện.
2. Nhấc ngón trên ô hợp lệ → `commit_pickup` → `ok`:
   - cache bỏ đúng uid đó;
   - dock quay về **card của món còn lại đầu tiên**, hoặc **đóng** nếu cache hết món (loot B §6.2);
   - R4' toast `CARD_PLACED_CONFIRM_BACKPACK` hoặc `CARD_PLACED_CONFIRM_NOTARY_BOX` (tên món + nơi đặt; Hộp nói "đã niêm")
     trong 3 s, để người chơi biết món đi đâu sau khi lưới khuất;
   - không tự mở `pickup` cho món kế tiếp.
3. Nhấc ngón trên ô không hợp lệ → không đổi; món vẫn ở cache; lý do ở dòng 2 của S.
4. `Đóng` / Back → card(i), không đổi. Ra ngoài tầm / D1 / chết → đóng dock, không commit.

**`view`** (từ H3, mọi nơi trong run):

1. Tiêu đề `INVENTORY_PANEL_TITLE`; chưa chọn → `LOADOUT_HINT_SELECT`.
2. Di chuyển và xoay trong cùng lưới, niêm ba lô → Hộp theo §4.3. Hộp → ba lô: gạch chéo + `WITHDRAW_LOCKED`.
3. Khi Manifest đang được mang và chưa chọn món, dòng 2 của S hiện `PROMPT_SAFEBOX_SEAL_HINT` thay `LOADOUT_HINT_SELECT`
   (S02 đặt câu này ở chân panel; dock không còn chân panel riêng).
4. `Đóng` / Back / D1 → HUD. Mở `view` không đổi state, không dừng thế giới, không dừng đồng hồ S8.

| Trạng thái | Người chơi thấy |
|---|---|
| `pickup` mặc định | Món + tag "còn ở rương" + dấu anchor + icon gợi ý ở ba lô + nút `Xoay` (nếu có). |
| Ngón đè, hợp lệ | Bóng khung liền đủ footprint + dòng preview (Hộp: câu niêm). |
| Ngón đè, không hợp lệ | Ô gạch chéo + icon × ở ô chặn + lý do. |
| Đã xoay (chưa commit) | Chip `2×1`, nút `Xoay` viền dày, dấu anchor tính lại. |
| Lỗi (nhấc trên ô sai) | Lý do giữ nguyên; món ở chỗ cũ/cache; vẫn được chọn. |
| `view` rỗng (ba lô trống) | Lưới trống + hướng dẫn; Hộp có `starter_remedy` (+ Manifest nếu đã niêm). |
| `view` đầy | Không xảy ra ở S03 (tối đa 4/12 ô, loot B §9.1); nếu xảy ra thì mọi ô gạch chéo kèm lý do, không auto gì. |
| Bị gián đoạn | Dock giữ nguyên; lựa chọn và `pending_rotated` bị bỏ (ở `pickup`, món i vẫn là món đang cầm, hướng về `false`); bóng bị xóa, không commit. |
| Có nguy hiểm | D1 hiện. |
| Chết giữa action | Dock đóng như hủy, không commit; sang O6. |

### 5.6 Overlay khi có nguy hiểm (O2B, O3B, O5) — D1

**Mục đích:** panel không tự đóng, không tự bỏ đồ, nhưng người chơi luôn biết có nguy hiểm và đóng được bằng một chạm ở
chỗ dễ với.

1. **Chỉ mời ở `CalmZoneB`:** card/lưới cache chỉ mở từ R5' `Mở rương`, và nút đó chỉ hiện trong tầm `CacheB` (nằm trong
   `CalmZoneB`). Không prompt nào mời mở lưới ở chỗ khác. H3 vẫn mở `view` ở mọi nơi theo ý người chơi (như S02).
2. **Luôn thấy khi overlay mở:** R1 (objective), H2 (máu), H5 (cảnh báo lane/patrol), R2 (banner S7–S9), R6 (joystick vẫn
   dùng được), nhân vật và nửa trái thế giới. Dock R10 không bao giờ giao với các vùng này.
3. **`danger_near`** đúng khi có ít nhất một điều sau:
   - một `EnemyBrain` ở `alert`, `windup`, `strike`, `charge` hoặc `recover`, cách người chơi ≤
     `DANGER_NEAR_RADIUS_M = 9.0` (bằng perception của `foreman`);
   - đèn lane B ở `armed`/`active`;
   - patrol đã phát `patrol_cue_started` và chưa `withdrawn`/`down`, và người chơi chưa về deck A.
4. Khi một overlay (O2B, O3B, O5) đang mở **và** `danger_near` đúng → hiện **D1** (16–304 × 192–288, 48 dp cao): icon cảnh
   báo hình tam giác + mũi tên chỉ hướng nguy hiểm gần nhất + hai dòng `HUD_DANGER_NEAR` / `HUD_DANGER_CLOSE_HINT`. D1 là
   **nút**: chạm D1 = đóng overlay trên cùng **như hủy** (giống `Đóng`/Back; ở `pickup` thì về HUD, không về card).
5. Khi một địch phát `windup_started` lúc overlay mở: chữ dòng 1 của D1 đổi sang `HUD_DANGER_WINDUP`, D1 phóng to một lần,
   cue `hud_danger_near`, `haptic_warn`. Không lặp lại cho tới windup kế tiếp, tối đa 1 lần/giây.
6. **Không tự đóng, không tự bỏ đồ:** địch tới gần, windup hay đánh trúng đều không đóng overlay, không commit, không bỏ
   món (combat §3.6.3). Ngoại lệ duy nhất: HP 0 (§5.7) và các luật đóng sẵn có (ra ngoài tầm cache/bàn, rời vòng với O5).
7. `danger_near` thành sai → D1 ẩn bằng một lần trượt ra. Overlay đóng → D1 ẩn, C1–C4 hiện lại ngay (không có chặn chạm
   0.3 s cho C1–C4).
8. Khi overlay mở, combat bị khóa (combat §3.6): khiên đang giữ hạ xuống, kênh thuốc bị hủy (thuốc không mất, R4' nêu
   `COMBAT_REMEDY_INTERRUPTED`), bộ đệm input bị xóa.

| Trạng thái | Người chơi thấy |
|---|---|
| Overlay mở, yên | Không có D1; R1, H2, H5 vẫn hiện. |
| Overlay mở, có nguy hiểm | D1 + mũi tên hướng. |
| Overlay mở, địch windup | D1 đổi chữ + phóng to một lần. |
| Bị đánh trúng khi overlay mở | H2 mất đoạn + `haptic_hit`; overlay vẫn mở. |

### 5.7 O6 — Stub HP về 0 (S03, theo quyết định tạm của Producer ở combat §4.4)

**Mục đích:** nói rõ run kết thúc vì hết máu và không có gì được lưu, rồi cho về màn đầu. Đây không phải S11 (S04).

| Phần tử | Vùng | Key |
|---|---|---|
| Lớp chặn toàn màn | 0–1280 × 0–720 (chặn mọi chạm phía sau) | — |
| Một dòng | O6 368–912 × 264–352 | `COMBAT_STUB_HP_ZERO` |
| Nút `Về màn đầu` | giữa O6, 408–872 × 360–456 (464×96) | `COMBAT_STUB_BUTTON_BOOT` |

Quy tắc:

1. `Health.depleted` → cùng frame: mọi overlay đóng **như hủy** (O2B/O3B không commit, O5 không `confirm_call`). Khiên hạ,
   kênh thuốc hủy. Ẩn C1–C4, R5', H3, D1, H5, R2. Joystick khóa (combat §4.4.1).
2. Hiện O6. Trong `STUB_END_MESSAGE_SECONDS = 2.5` s đầu, nút `Về màn đầu` **khóa**: icon khóa + vòng tiến độ lấp dần
   0→1. Chạm hoặc Back bị bỏ qua. Lý do: lúc chết ngón cái đang dồn ở C1/C2, chạm nhầm sẽ bỏ qua dòng chữ. Đồng hồ 2.5 s
   chỉ đếm khi app ở tiền cảnh.
3. Sau 2.5 s: nút bật (icon mũi tên). Chạm hoặc Back → `change_scene` về Boot; nút tự khóa sau chạm đầu và hiện
   `UI_LOADING`. Lỗi tải → `UI_ERROR_SCENE_LOAD`, nút bật lại.
4. Không summary, không danh sách giữ/mất, không chữ success (combat §4.4.4–5). Cue `combat_hit_taken` (đòn cuối), rồi
   im lặng.
5. **Khác combat §4.4.5:** combat spec tự chuyển về Boot sau 2.5 s; card TASK-83 yêu cầu có nút. Spec này giữ 2.5 s làm
   thời gian đọc tối thiểu và **không** tự chuyển, để người chơi tự đọc xong. Xem §9 câu 3.

| Trạng thái | Người chơi thấy |
|---|---|
| 0–2.5 s | Dòng chữ + nút khóa có vòng tiến độ. |
| Sau 2.5 s | Nút bật. |
| Đang chờ | `UI_LOADING`. |
| Lỗi | `UI_ERROR_SCENE_LOAD`, nút bật lại. |
| Bị gián đoạn | O6 giữ nguyên; vòng tiến độ dừng khi ở nền và chạy tiếp khi trở lại. |

## 6. Bảng tương tác

| Phần tử | Cử chỉ | Kết quả | Phản hồi (hình · cue · rung) | Hoàn tác |
|---|---|---|---|---|
| C1 `đánh` | chạm xuống | `press(&"combat_attack")` | nút lún · `combat_attack` · — | không (đòn ngắn 0.5 s) |
| C2 `né` | chạm xuống | `press(&"combat_dodge")`; hướng theo joystick lúc chạm | nút lún, quạt hồi chạy · `combat_dodge` · `haptic_light` | không |
| C2 khi đang hồi | chạm xuống | không gì | nút nảy một lần · `ui_invalid` · — | — |
| C3 `khiên` | giữ (xuống = nâng, nhấc = hạ) | `press`/`release(&"combat_guard")` | icon khiên dựng, viền dày · `combat_guard_up`; chặn đòn: `combat_guard_block`, `haptic_light` | nhấc ngón |
| C3 + C2 (hai ngón) | giữ + chạm | dash, rồi khiên nâng lại nếu còn giữ | như trên | — |
| C4 `thuốc` | chạm (xuống + nhấc) | `press(&"use_remedy")` → kênh 1.0 s hoặc `remedy_refused` | vòng tiến độ · `combat_remedy_start` / lý do R4' + `ui_invalid` | né/khiên trong lúc kênh = hủy, thuốc không mất |
| C1/C4 khi khóa | chạm | không gì | nảy một lần · `ui_invalid` | — |
| R5' `Mở rương` | chạm | O2B card(món đầu) | dock trượt vào · `ui_tap` | `Đóng` |
| Chip món | chạm | card(j) | chip viền dày + mấu · `ui_tap` | chạm chip khác |
| `Bỏ qua` | chạm | card kế / đóng | card trượt · `ui_cancel` | mở lại rương |
| `Nhặt và xếp` | chạm | O3B `pickup(i)` | lưới thay card · `ui_tap` | `Đóng` → card(i) |
| Ô lưới | chạm xuống | bóng footprint + preview/lý do | khung liền hoặc gạch chéo + icon × · `ui_preview_ok`/`ui_preview_bad` | trượt ngón ra |
| Ô lưới hợp lệ | nhấc ngón trong ô | commit | món vào ô · `ui_place_ok`/`ui_seal_ok` · `haptic_success` | ba lô: chọn lại rồi đặt chỗ khác (`view`); Hộp: không trong run (khóa rút, đã báo trước) |
| Ô lưới không hợp lệ | nhấc ngón trong ô | không đổi | lý do giữ · `ui_invalid` · `haptic_warn` | — |
| Ô lưới | trượt ≥ 16 px | hủy preview | bóng biến mất | — |
| Món trong lưới (`view`) | chạm | chọn / bỏ chọn | viền dày + icon chọn · `ui_tap` | chạm lại |
| `Xoay` | chạm | đảo `pending_rotated`, đánh dấu lại | chip đổi `1×2`↔`2×1`, icon quay 90° · `ui_rotate` | chạm `Xoay` lần nữa |
| `Đóng` (R3) / Back | chạm | O3B pickup → card(i); còn lại → HUD | dock trượt ra · `ui_cancel` | mở lại |
| D1 | chạm | đóng overlay trên cùng như hủy, về HUD | dock/O5 đóng · `ui_cancel` | mở lại |
| Prompt R4' | chạm | ẩn | — | — |
| O6 `Về màn đầu` (sau 2.5 s) / Back | chạm | Boot | `UI_LOADING` · `ui_tap` | không (S03 không lưu) |
| Joystick R6 | kéo | di chuyển (cả khi overlay mở; khóa ở O6) | như S02 | — |

Không thao tác nào trong bảng mở O5. Xoay, di chuyển, xem card, đổi chip, `Bỏ qua`, `Đóng`, D1, niêm vào Hộp đều không có
xác nhận (G11, beacon §7.2). S03 không có affordance bỏ món, rút đồ niêm hay đổi gear (S04).

## 7. Dữ liệu đọc bởi UI

| Phần tử | Field / signal |
|---|---|
| H2 | `Health.hp`, `Health.max_hp`, `changed(hp, max_hp)`, `depleted()` |
| C1–C3 | `RetrieverCombat.state_changed(state)`, `dodge_cooldown_changed(remaining)`, `DODGE_COOLDOWN` |
| C4 | `sling_pouch` (tổng `quantity` của `sling_remedy`), `state == using_remedy` + thời gian đã kênh, `remedy_used(healed)`, `remedy_refused(reason)`, `REMEDY_USE_SECONDS` |
| H1 | `extract_state`, `desk_state`, `role_first_seen` của `tax_guard_b`/`foreman_b`, trạng thái mở `GateB` |
| H5, D1 | `patrol_cue_started`, state patrol, `lane_alert_started`, state đèn (`off`/`armed`/`active`), `boat_ready`, `EnemyBrain` (state + vị trí), vị trí người chơi, vị trí màn hình của đèn |
| R5' | như S02 + `cache_state`, khoảng cách người chơi ↔ `CacheB` ≤ `CACHE_INTERACT_RADIUS_M` |
| O2B | `LootCache` (món còn lại theo `order`), `ItemDef` (`size`, `rotatable`, `stackable`, `sealable`, `claim_id`, `appraisal_class`, `display_name_key`), `ItemInstance.quantity`, `backpack.free_cell_count()`, `fit_backpack`, `fit_notary_box` (loot B §7.2) |
| O3B | `preview_pickup` / `preview_move` / `preview_seal` → `ok`, `reason`, `blocking_cells`; `ItemInstance.cells()`, `rotated`; `seal_label(uid)`; `suggest_slot(def_id, quantity)` |
| Overlay mở | `RetrieverCombat.set_overlay_open(bool)` (UI gọi khi O2B/O3B/O5 mở và đóng) |
| O6 | `Health.depleted`, `STUB_END_MESSAGE_SECONDS` |

## 8. Key chữ cần thêm (giao TASK-84 viết câu)

Mọi key là `proposed`, theo quy ước `SCREEN_CONTEXT_PURPOSE` của [chuỗi Contract 1](contract-1-strings.md) §1. Giới hạn
ký tự tính theo §1 đó. Có một loại mới: **nhãn nút combat ≤ 10** (nút 112 px). Spec chỉ ghi ý cần nói, chưa viết câu.
Placeholder mới: `{hp}`, `{max_hp}`, `{quantity}`, `{free}`, `{w}`, `{h}`, `{item}`.

| Key đề xuất | Nơi hiện | Ý cần nói | Tối đa |
|---|---|---|---:|
| `HUD_BUTTON_ATTACK` | C1 | Đánh | 10 |
| `HUD_BUTTON_DODGE` | C2 | Né | 10 |
| `HUD_BUTTON_GUARD` | C3 | Khiên (giữ) | 10 |
| `HUD_BUTTON_REMEDY` | C4 | Dùng thuốc | 10 |
| `HUD_HEALTH_VALUE` | H2 | `{hp}/{max_hp}` | 12 |
| `HUD_HEALTH_LOW` | H2 tag | Máu thấp | 16 |
| `HUD_ALERT_LANE_B` | H5 | Địch tới từ Chợ Ngập | 24 |
| `HUD_ALERT_PATROL_B` | H5 | Lính tuần đang về phía lối A | 24 |
| `HUD_DANGER_NEAR` | D1 dòng 1 | Nguy hiểm gần | 24 |
| `HUD_DANGER_WINDUP` | D1 dòng 1 khi địch windup | Địch sắp ra đòn | 24 |
| `HUD_DANGER_CLOSE_HINT` | D1 dòng 2 | Chạm để đóng và phản ứng | 24 |
| `PROMPT_COMBAT_TAX_GUARD_FIRST_SEEN` | R4', lần đầu thấy vệ binh | Khiên chặn phía trước; vòng/quạt báo đòn; đánh hông hoặc sau khi khiên hạ | 72 |
| `PROMPT_COMBAT_FOREMAN_FIRST_SEEN` | R4', lần đầu thấy đốc công | Vạch sàn là lane charge; né ngang ra khỏi vạch | 72 |
| `COMBAT_REMEDY_REFUSED_NO_REMEDY` | R4' toast | Hết thuốc trong túi đeo chéo | 72 |
| `COMBAT_REMEDY_REFUSED_HP_FULL` | R4' toast | Máu đang đầy, chưa dùng thuốc | 72 |
| `COMBAT_REMEDY_INTERRUPTED` | R4' toast | Bị ngắt; thuốc chưa mất | 72 |
| `COMBAT_STUB_HP_ZERO` | O6 dòng duy nhất | Hết máu; run kết thúc, không có gì được lưu (bản thử S03) | 72 |
| `COMBAT_STUB_BUTTON_BOOT` | O6 nút | Về màn đầu | 24 |
| `ENEMY_TAX_GUARD_NAME` | không có nhãn riêng ở S03; chỉ để TASK-84 dùng thống nhất trong prompt | Tên vai vệ binh thuế khiên nhẹ | 24 |
| `ENEMY_FOREMAN_NAME` | như trên | Tên vai đốc công | 24 |
| `WORLD_INTERACT_CACHE_B` | R5' | Mở rương tịch thu | 24 |
| `PROMPT_LOOT_COLOR_NOT_VALUE` | R4', lần đầu mở card | Nguyên văn Beat 4: màu không quyết định giá trị/ô | 72 |
| `CACHE_CLOSED_LEFT_RANGE` | R4' toast | Đã đóng rương vì đi ra xa | 72 |
| `CARD_PLACED_CONFIRM_BACKPACK` | R4' toast | `{item}` đã vào ba lô | 72 |
| `CARD_PLACED_CONFIRM_NOTARY_BOX` | R4' toast | `{item}` đã niêm trong Hộp | 72 |
| `CARD_QUANTITY_SUFFIX` | chip, dòng 1 card, ô lưới | `×{quantity}` | 6 |
| `CARD_TAG_ROTATABLE` | card dòng 2 | xoay được | 16 |
| `CARD_TAG_STACKABLE` | card dòng 2 | xếp chồng được | 16 |
| `CARD_TAG_SEALABLE` | card dòng 2 | niêm được | 16 |
| `CARD_BACKPACK_FREE` | card dòng 2 | Ba lô trống `{free}/{total}` | 24 |
| `CARD_FIT_BACKPACK_FITS` / `_ROTATED_ONLY` / `_NO_FIT` | card dòng 2 | vừa / vừa khi xoay / không vừa | 16 |
| `CARD_FIT_NOTARY_BOX_FITS` / `_NO_FIT` / `_NOT_SEALABLE` | card dòng 2 | vừa Hộp / Hộp không đủ chỗ / không niêm được | 16 |
| `CARD_SCRAPED_TAX_COIN_NAME` | card dòng 1 | tên #14 (như `ITEM_SCRAPED_TAX_COIN_NAME`) | 24 |
| `CARD_SCRAPED_TAX_COIN_FOOTPRINT` | card dòng 2a (phần tĩnh) | 1 ô | 24 |
| `CARD_SCRAPED_TAX_COIN_USE` | card dòng 3 | gọn, đáng giữ theo ô (loot B §7.3) | 64 |
| `CARD_SCRAPED_TAX_COIN_CLAIM` | card dòng 4 | Hắc Thuế có claim | 32 |
| `CARD_SCRAPED_TAX_COIN_RARITY` | card dòng 5 | lớp 2/6 (Xanh lá) bằng chữ | 32 |
| `CARD_SCRAPED_TAX_COIN_LORE` | card dòng 6 | một dòng | 64 |
| `CARD_WATERLOGGED_STOCK_LEDGER_NAME` … `_LORE` (6 key) | card dòng 1–6 | như trên cho #16; footprint 2 ô; tài sản đăng ký, không phải vật chứng; lớp 3/6 (Xanh dương) | 24 / 24 / 64 / 32 / 32 / 64 |
| `ITEM_SCRAPED_TAX_COIN_NAME`, `ITEM_WATERLOGGED_STOCK_LEDGER_NAME` | ô lưới, dải S, toast, S10 | tên item (loot B §4) | 24 |
| `INVENTORY_PICKUP_SOURCE_CACHE` | dải S tag | còn ở rương, chưa nhặt | 24 |
| `INVENTORY_PICKUP_HINT_ITEM` | dải S dòng 2, `pickup` | Chạm ô ba lô hoặc Hộp; Hộp = niêm | 72 |
| `INVENTORY_PREVIEW_FITS_BACKPACK` | dải S dòng 2, ngón đè | vừa; nhấc tay để đặt | 72 |
| `INVENTORY_PREVIEW_FITS_NOTARY_BOX` | dải S dòng 2, ngón đè | vừa; nhấc tay để niêm, chưa rút lại được trong run | 72 |
| `INVENTORY_BUTTON_ROTATE` | nút `Xoay` | Xoay | 24 |
| `INVENTORY_FOOTPRINT_CHIP` | chip footprint | `{w}×{h}` | 8 |

Dùng lại không đổi: `HUD_OBJECTIVE_CROSS_TAX_POST`, `EXTRACT_S8_LANE_ALERT`, `CARD_ACTION_PICK_AND_PLACE`,
`CARD_ACTION_SKIP`, `CARD_ACTION_CLOSE`, `INVENTORY_REASON_*`, `INVENTORY_SEAL_LABEL_*`, `LOADOUT_LABEL_*`,
`LOADOUT_HINT_SELECT`, `INVENTORY_PANEL_TITLE`, `PROMPT_SAFEBOX_SEAL_HINT`, `HUD_BUTTON_INVENTORY`, `UI_LOADING`,
`UI_ERROR_SCENE_LOAD`.

## 9. Câu hỏi mở (không chặn TASK-89; mặc định ghi bên cạnh)

1. **Overlay che telegraph (combat §12.2):** mặc định là thế giới không dừng + dock phải R10 chừa nhân vật và nửa trái
   + D1 một chạm. Spec này không đề nghị cấm địch windup khi overlay mở. Producer xác nhận.
2. **Dải mép phải lúc S8 (layout B §10 câu 2):** hàng C chừa x ≥ 1216 và y_norm < 0.80; R5' ẩn ở S8. Ở 4:3, điểm địch vào
   khung (y_norm 0.83) vẫn sát mép trên C1, nên mặc định coi đèn + mũi tên + H5 là cue chính ở 4:3. TASK-88 đo lại.
3. **O6 không tự về Boot:** combat §4.4.5 ghi "2.5 s rồi chuyển scene". Card này yêu cầu nút, nên mặc định là 2.5 s khóa
   rồi chờ người chơi chạm. Nếu Producer muốn giữ tự chuyển, chỉ cần thêm tự chuyển sau 2.5 s; nút vẫn giữ.
4. **Cỡ 48 dp:** đổi sàn vùng chạm mới từ 64 px lên 96 px tham chiếu, và chữ mới từ 20 lên 24 px. Phần tử S02 (ô 96 đã
   đạt; ⓘ 64×64 ở S1 chưa đạt) chưa được sửa trong card này.
5. **Nút thuốc khi máu đầy:** mặc định nút trông "sẵn" và chỉ báo lý do khi chạm. Phương án khác là vẽ sẵn dấu "đầy" trên
   nút; chờ playtest.

## 10. Acceptance tests (given / when / then)

Tên test: `test_zbu_xx_<mô_tả>`. Test UI chạy headless bằng cách gửi sự kiện chạm vào node. "Không đổi" =
`inventory.snapshot()` + danh sách uid/qty của `LootCache` + state `ExtractPierAFlow` bằng nhau trước/sau, không có signal
commit. Test cần nhìn (cỡ, chồng lấn, thang xám) chạy tay trên khung 1280×720 **và** cửa sổ 640×360.

| Mã | Given | When | Then |
|---|---|---|---|
| ZBU-01 | HUD S03 ở 1280×720 | Đo rect | C1 128×128, C2/C3 112×112, C4 96×96, R5' 224×112, R3 96×96; không rect nào giao nhau hay giao R6, T (320–960 × 232–560), R4'. |
| ZBU-02 | Cửa sổ 640×360 | Đo rect C1–C4, R5', R3, D1, nút O2B/O3B/O6, ô lưới | Mọi vùng chạm mới ≥ 48×48 px thật; chữ mới ≥ 12 px thật. |
| ZBU-03 | Cửa sổ 16:9, 4:3 (1280×960), 21:9 | Đo vị trí | C và R5' bám dưới-phải; R1/H2/H5/D1 bám trên-trái; không phần tử HUD nào ở dải x ≥ 1216 với y_norm 0.55–0.80 trong S8. |
| ZBU-04 | HUD, HP 100 | `Health.damage(15)` | H2 hiện `85/100`, còn 9 đoạn đặc (`ceil(85 / 10)`); đoạn mất để lại vệt rỗng 0.5 s rồi hết; không chớp. |
| ZBU-05 | HP 30 | Đọc H2 | Icon nứt + `HUD_HEALTH_LOW`; HP 31 thì không có. |
| ZBU-06 | C2 vừa dùng | Đọc C2 trong 0.8 s | Quạt hồi lấp dần; chạm C2 lúc này không dash, có cue `ui_invalid`; hết hồi nút phóng to một lần. |
| ZBU-07 | `free` | Ngón chạm xuống C3, trượt ra ngoài nút, giữ 2 s, nhấc | `guarding` suốt 2 s; nhả khi nhấc; C3 hiện icon khiên dựng khi giữ. |
| ZBU-08 | Ngón A giữ C3 | Ngón B chạm C2 | `dodging`, rồi `guarding` lại khi dash xong (ngón A còn giữ). |
| ZBU-09 | Ngón A giữ C3 | App xuống nền rồi trở lại | Khiên đã hạ; C3 ở trạng thái sẵn. |
| ZBU-10 | `guarding` | Đọc C1, C4; chạm C1 | C1, C4 có gạch chéo + icon khóa; chạm C1 không đánh. |
| ZBU-11 | HP 100, 1 thuốc | Chạm C4 | Không kênh; R4' `COMBAT_REMEDY_REFUSED_HP_FULL`; badge vẫn `1`. |
| ZBU-12 | HP 60, 1 thuốc | Chạm C4, bị đánh ở 0.5 s | Vòng tiến độ biến mất; badge `1`; R4' `COMBAT_REMEDY_INTERRUPTED`. |
| ZBU-13 | HP 60, 1 thuốc | Chạm C4, chờ 1.0 s | H2 `100/100`; badge `0` + gạch chéo; chạm lại → `COMBAT_REMEDY_REFUSED_NO_REMEDY`. |
| ZBU-14 | Ngón chạm xuống C4 rồi trượt 30 px ra ngoài và nhấc | — | Không kênh thuốc (C4 theo luật chạm thường). |
| ZBU-15 | Vào B, vệ binh `alert` lần đầu | Đọc HUD | H1 `HUD_OBJECTIVE_CROSS_TAX_POST`; R4' `PROMPT_COMBAT_TAX_GUARD_FIRST_SEEN`; không chữ nào trong T. |
| ZBU-16 | ZBU-15 | Lùi khỏi leash, vệ binh mất dấu rồi thấy lại | Prompt không hiện lại. |
| ZBU-17 | Gate B mở | Vào `CalmZoneB` | H1 `HUD_OBJECTIVE_DELIVER_PIER_A` (đã có Manifest); R4' không có prompt combat. |
| ZBU-18 | Rời `CalmZoneB` lần đầu | `patrol_cue_started` | H5 `HUD_ALERT_PATROL_B` + mũi tên quay về `PatrolAlertLampB`; không prompt combat ở R4'. |
| ZBU-19 | S8, `lane_alert_started` | Đọc HUD | H5 `HUD_ALERT_LANE_B` + mũi tên về `LaneBAlertLamp`; R4' `EXTRACT_S8_LANE_ALERT` một lần; R5' ẩn; R2 đồng hồ vẫn hiện. |
| ZBU-20 | S8 → `boat_ready` khi còn địch | Đọc HUD | H5 trống; `Lên thuyền` hiện ở R5' khi `can_board()`. |
| ZBU-21 | Trong tầm `CacheB`, cache `full` | Đọc R5' | `WORLD_INTERACT_CACHE_B`; không tự mở. Ra ngoài 1.5 m → R5' ẩn. |
| ZBU-22 | ZBU-21 | Chạm R5' | Dock R10c: 2 chip (đồng xu `×2` / sổ `1×2`), chip 1 viền dày + mấu; card thứ tự NAME → FOOTPRINT → USE → CLAIM → RARITY → LORE; nút `Bỏ qua`, `Nhặt và xếp`; R3 là `Đóng`; R1, H2, H5 vẫn hiện; R4' `PROMPT_LOOT_COLOR_NOT_VALUE`. Không đổi. |
| ZBU-23 | ZBU-22 | Chạm chip 2 | Card sổ: tag `CARD_TAG_ROTATABLE`, Hộp `no_fit` (icon ×) nếu Manifest đã niêm, 3 dấu đặc / 3 rỗng; không đổi. |
| ZBU-24 | Ảnh thang xám của card đồng xu và card sổ | Xem tay | Phân biệt được claim (icon phe + chữ), rarity (2 vs 3 dấu đặc + chữ), footprint (1 ô vs 2 ô + `1×1`/`1×2`), kết quả vừa ô (tích / × / mũi tên xoay) mà không cần màu. |
| ZBU-25 | ZBU-22 | `Bỏ qua` hai lần | Card sổ, rồi dock đóng. Không đổi. Mở lại → card đồng xu. |
| ZBU-26 | ZBU-22 | `Đóng` (R3) / Back | Về HUD; không đổi; C1–C4 hiện lại. |
| ZBU-27 | Card sổ | `Nhặt và xếp` | Dock lưới R10g: dải S có sổ + `1×2` + tag còn ở rương; nút `Xoay` hiện; chân lưới ba lô hàng y = 3 gạch chéo. Không đổi. |
| ZBU-28 | ZBU-27 | Chạm `Xoay` | Chip `2×1`, nút viền dày; ô (0,3),(1,3) thành viền liền + tích, (2,3) gạch chéo. Không có lệnh commit; không đổi. |
| ZBU-29 | ZBU-28 | Ngón chạm xuống ô (0,3) | Bóng khung liền phủ (0,3),(1,3); dòng 2 `INVENTORY_PREVIEW_FITS_BACKPACK`; chưa đổi state. |
| ZBU-30 | ZBU-29 | Trượt ngón 30 px rồi nhấc | Bóng biến mất; không commit; không đổi. |
| ZBU-31 | ZBU-28 | Chạm (xuống + nhấc) ô (0,3) | `commit_pickup(sổ, backpack, (0,3), true)` ok; dock đóng (cache hết) hoặc về card món còn lại; R4' `CARD_PLACED_CONFIRM_BACKPACK`. |
| ZBU-32 | ZBU-27 (chưa xoay) | Chạm ô (0,3) | Không commit; dòng 2 tên sổ · `INVENTORY_REASON_OUT_OF_BOUNDS`; sổ vẫn ở cache, vẫn ở `pickup`. |
| ZBU-33 | Manifest niêm ở Hộp (1,0); pickup sổ | Ngón chạm xuống Hộp (1,1) | Ô gạch chéo + icon × ở ô chặn; lý do `CELLS_OCCUPIED` hoặc `OUT_OF_BOUNDS`; nhấc → không đổi. |
| ZBU-34 | Pickup đồng xu, Hộp còn (1,1) | Ngón chạm xuống Hộp (1,1) | Dòng 2 `INVENTORY_PREVIEW_FITS_NOTARY_BOX`. Nhấc → ok, nhãn `đã niêm`; R4' `CARD_PLACED_CONFIRM_NOTARY_BOX`; không O5. |
| ZBU-35 | Pickup bất kỳ | `Đóng` | Về card cùng món; không đổi. |
| ZBU-36 | Card đồng xu | Tìm nút | Không có nút `Xoay` trong pickup đồng xu; không có kéo-thả, `nhặt tất cả`, bỏ món, tự xếp. |
| ZBU-37 | `view`, sổ trong ba lô (0,0) đứng | Chọn sổ, `Xoay`, chạm (0,0) | `commit_move(…, (0,0), true)` ok; sổ chiếm (0,0),(1,0); không O5. |
| ZBU-38 | `view`, sổ ở ba lô (2,0) đứng | Chọn, `Xoay`, chạm (2,0) | Không đổi; lý do `OUT_OF_BOUNDS`; sổ vẫn đứng ở (2,0). |
| ZBU-39 | `view`, đồng xu trong Hộp | Chọn, chạm ô ba lô trống | Không đổi; lý do `INVENTORY_REASON_WITHDRAW_LOCKED`. |
| ZBU-40 | Dock R10g mở trong S8 | Đo / đọc | R2 đồng hồ, R1, H2, H5 không bị che; nhân vật (tâm màn) không bị che. |
| ZBU-41 | Dock mở, vệ binh `alert` cách 5 m | Đọc HUD | D1 hiện với `HUD_DANGER_NEAR` + mũi tên hướng. Không còn địch ≤ 9 m, đèn tắt → D1 ẩn. |
| ZBU-42 | ZBU-41 | Vệ binh `windup_started` | D1 đổi `HUD_DANGER_WINDUP`, phóng to một lần; dock **vẫn mở**; không commit, không bỏ món. |
| ZBU-43 | ZBU-42 | Đòn trúng (HP 85) | Dock vẫn mở; H2 85. |
| ZBU-44 | Pickup sổ đang mở, D1 hiện | Chạm D1 | Dock đóng, về HUD (không về card); không đổi; C1–C4 hiện và nhận chạm ngay. |
| ZBU-45 | Đang giữ C3 | Mở dock bằng H3 | Khiên hạ; C1–C4 ẩn; phím K bị bỏ qua tới khi đóng dock. |
| ZBU-46 | Pickup đồng xu đang mở | HP về 0 | Dock đóng, không commit (cache còn đồng xu); O6 hiện; C1–C4, R5', H3, D1, H5 ẩn; joystick khóa. |
| ZBU-47 | O6 vừa hiện | Chạm nút và Back trong 2.5 s đầu | Không gì; nút có icon khóa + vòng tiến độ. |
| ZBU-48 | O6 sau 2.5 s | Chạm nút hai lần nhanh | Về Boot đúng một lần; `UI_LOADING`; không file mới trong `user://`; không summary. |
| ZBU-49 | O5 đang mở | HP về 0 | O5 đóng, không `confirm_call`; O6 hiện. |
| ZBU-50 | Mọi màn S03 | Rà mọi nút/nhãn mới | Mỗi chữ có key trong `strings.csv` hoặc §8; không chuỗi chữ cứng. |

## 11. Truy vết tới gate

| Gate | Mục | Test |
|---|---|---|
| G6 | §3, §5.1–§5.2 | ZBU-01…20 |
| G7 | §5.4 | ZBU-22…25 |
| G8 | §4, §5.5 | ZBU-27…40 |
| G10 | §4.3, §5.5 | ZBU-34, ZBU-39 |
| G11 | §4.3, §6 | ZBU-28, ZBU-34, ZBU-37 |
| G12 (HUD) | §5.2 | ZBU-18 |
| G14 (HUD) | §5.2, §5.3 | ZBU-19, ZBU-20 |
| Invariant §8.7 | §3.1, §5.6 | ZBU-40…45 |
| Stub HP 0 (combat §4.4) | §5.7 | ZBU-46…49 |
