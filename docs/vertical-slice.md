# Vertical slice đầu tiên — Giữ giấy phép

**Trạng thái:** phạm vi prototype `proposed`. Đây là một lát cắt offline-first 10-15 phút để chứng minh một run extraction hoàn chỉnh; không phải bản rút gọn của toàn bộ Act I.

**Nguồn chuẩn:** [Cảng Hắc Thuế](maps/black-tax-port.md), [bộ trang bị và inventory](systems/inventory-and-loadout.md), [tuyến truyện chính](story/MAIN_STORY.md) và [tiến trình vùng](story/REGION_STORY_AND_PROGRESSION.md). Các luật canon được tham chiếu, không bị sửa ở đây.

## 1. Câu hỏi lát cắt phải trả lời

Sau một run, người chơi phải tự trả lời được:

> “Tôi đã chọn đồ mang vào, lấy `Manifest Hàng Hóa R-17`, tự quyết định tham hay rút, và chỉ giữ được thành quả khi extract.”

Lát cắt chứng minh năm điều, theo thứ tự: chuẩn bị → combat đọc được → loot/xếp grid → lựa chọn safebox và đồ cồng kềnh → gọi và giữ extract. Nó dùng **Contract 1 — Giữ giấy phép**, không giả vờ hoàn thành `Counterseal`, `Sổ Nợ Gốc` hay mở Lò Rèn Câm.

### Phạm vi chạy được

| Có trong run | Không có trong run |
|---|---|
| Easy, state cố định; Bến Ngoài **A**, Chợ Ngập **B**, Kho Nổi **D**; chỉ extract Cầu tàu A | C, E, thuyền D, cổng thuế E, Contract 2/3, boss/elite, Hard/Extreme, incident deck ngẫu nhiên, co-op/live service |
| One Starter Contract, một starter kit, combat cơ bản, loot 1/2/4 ô, safebox 2x2 và death/recovery summary | Cân bằng giá/phí/drop rate/damage/HP, catalogue item, craft/shop, gear upgrade, art/audio cuối, network hay kiến trúc kỹ thuật |

Landmark C và tường thuế E chỉ là silhouette ở xa để xác nhận thế giới còn mở rộng; chúng không nhận input, không hiển thị objective và không cho người chơi vượt phạm vi slice.

## 2. Trạng thái trước run và quy tắc prototype

### 2.1 Briefing/loadout (tối đa một màn)

Briefing luôn có đúng các thông tin sau:

```text
GIỮ GIẤY PHÉP
Lấy Manifest Hàng Hóa R-17 tại bàn dispatch A và extract ở Cầu tàu A.
Easy · Cầu tàu A mở · Đồ không niêm phong mất khi Phù Hiệu Hồi Hương kích hoạt.
```

Một câu thoại/voice ngắn của Người Thu Hồi già nối mục tiêu với stake: “Mang bản dispatch về trước kỳ thuế. Nó chỉ là đầu mối, nhưng thiếu nó ta mất quyền nhận contract.” Không dùng exposition về khoản nợ hay Act II trong run.

Loadout mặc định là một kit dùng được ngay: vũ khí một tay + khiên nhẹ đang trang bị, một vật hồi phục trong túi đeo chéo, ba lô prototype và Hộp Công Chứng 2x2 đang có **một** vật hồi phục 1x2 đã niêm phong. Người chơi có thể đổi/để trống theo [quy tắc loadout](systems/inventory-and-loadout.md), nhưng prototype không bán hay tự mua đồ.

Ba lô slice dùng một lưới **3x4 proposed**, đủ để nhìn thấy rõ khác biệt giữa loot 1x1, 1x2 và cargo 2x2. Đây chỉ là fixture kiểm thử UX, không chốt dung lượng ba lô phát hành. Túi đeo chéo không nhận loot/cargo trong run.

### 2.2 Điểm bắt đầu và fairness

- Không có level/gear-score gate, timer thực tế hoặc phí/giá cuối. Contract coi giấy phép/bond là đã hợp lệ để tester tập trung vào loop.
- A là vùng an toàn: Manifest ở bàn dispatch, Cầu tàu A nhìn thấy được nhưng chưa gọi extract trước khi cầm Manifest.
- Không có incident ngẫu nhiên. Các loot/encounter trong tài liệu này cố định để người chơi học một nguyên nhân–hệ quả mỗi lần.
- C/E không thể vào; D không mở extract thuyền. Cổng quay đầu D → B luôn mở sau khi player đã bước vào D; không có đường cụt bắt buộc chết.
- Chỉ thông báo một prompt mới khi prompt cũ đã hoàn thành, bị bỏ qua rõ ràng, hoặc player rời vùng liên quan. Prompt combat không phủ UI máu, objective hay telegraph.

## 3. Luồng chuẩn 10-15 phút

Đây là **đường kỳ vọng**, không phải điều kiện bắt buộc. Sau Beat 2 người chơi được rút sớm; đường A → B → D → B → A là lựa chọn được đề xuất để test hết lát cắt.

| Beat / nhịp dự kiến | Không gian và objective hiển thị | Hành động/lesson bắt buộc hoặc đề xuất | Bằng chứng hoàn thành beat |
|---|---|---|---|
| **0. Briefing & loadout** (0:00-1:00) | Hub → briefing một màn; objective: “Lấy Manifest R-17 ở bàn dispatch A.” | Nhìn slot weapon/shield, ba lô, túi đeo chéo và Hộp 2x2; chấp nhận kit hoặc đổi đồ hợp lệ. Tooltip một lần: đồ không niêm phong mất khi recall. | Nút `Vào cảng` chỉ sáng khi loadout hợp lệ. |
| **1. Đọc không gian A** (1:00-2:00) | Spawn tại đèn phao xanh A. Bàn dispatch, Cầu tàu A và lối mái đỏ B cùng nằm trong một góc camera. | Đi theo marker ngắn; camera/landmark dạy A là nơi rút về, không có combat hay loot ép nhặt. | Player tương tác bàn dispatch. |
| **2. Nhặt Manifest & chọn an toàn** (2:00-3:00) | Manifest `1x1` hiện card: `đầu mối contract · chưa xác thực · extract A`. Chỉ sau placement hợp lệ vào ba lô hoặc Hộp Công Chứng, beacon A đổi từ E0 `unavailable` sang E1 `callable`; fail/hủy giữ Manifest ở source và A ở E0. | Nhặt và đặt vào ba lô hoặc Hộp Công Chứng. Prompt safebox: “Niêm phong tránh mất vĩnh viễn; vẫn phải extract để giữ giấy phép.” Sau đó hiện hai lựa chọn không chặn: `Rút ngay ở A` / `Đi qua Chợ Ngập để kiếm thêm.` | Contract state là `đang mang`; route B và beacon A cùng rõ. |
| **3. Combat B: đọc telegraph** (3:00-5:00) | B là ngõ hẹp, mái vải đỏ, cover rõ. Objective ngắn: “Qua trạm thuế.” | Một skirmish đọc được: vệ binh khiên nhẹ giữ ngõ, sau đó đốc công charge vào lane có vạch sàn. Người chơi học di chuyển vòng/guard hoặc dash ngang; không cần giết kẻ đã rút khỏi lane để đi tiếp. | Gate B mở, vùng yên hiện 15-30 giây và prompt combat biến mất. |
| **4. Nhặt, xoay, giữ hay bỏ** (5:00-6:30) | Cache B chứa loot 1x1/1x2 và một item có claim, card cho footprint, công dụng/giá ước lượng, claim, rarity và lore một dòng. | Player nhặt một item nhỏ, xoay hoặc stack nếu card cho phép, rồi đóng lưới. Một prompt tối đa: “Màu không quyết định giá trị/ô; xem kích thước và công dụng.” | Có ít nhất một item ngoài Manifest trong ba lô hoặc player chọn `Bỏ qua` từ card; cả hai đều hợp lệ. |
| **5. D: hàng cồng kềnh và safebox** (6:30-9:00) | Lồng kho xanh lục D, lane nước nông và một cargo 2x2 cạnh lối quay về. Card cargo cho **giá tổng cao nhưng giá trị/ô thấp hơn** dấu thuế nhỏ 1x2; cả hai card hiện tổng giá trị, giá/ô, footprint và công dụng. | Chọn một trong ba outcome: mang cargo 2x2; ưu tiên dấu thuế nhỏ; hoặc không lấy để giữ ba lô trống. Nếu muốn niêm dấu thuế khi Hộp đã có thuốc 1x2 + Manifest 1x1, player phải tự rút/giữ/đổi chỗ qua preview hợp lệ—không auto-swap. | Player rời D qua lane quay lại B, với lựa chọn được giữ nguyên trong inventory; không áp dụng tốc độ/weight penalty chưa có trong core spec. |
| **6. Quay về dưới áp lực nhẹ** (9:00-11:00) | B → A dùng cùng landmark ngược chiều; một patrol có telegraph từ xa buộc tránh hoặc đánh skirmish ngắn. Objective: “Đưa Manifest ra Cầu tàu A.” | Đọc đường về và ưu tiên extract thay vì dọn map. Không có enemy spawn sau lưng hay sự kiện mới chồng lên inventory. | Vào vòng beacon A; combat prompt không quay lại. |
| **7. Gọi extract và giữ khu** (11:00-13:00) | Cầu tàu A hiện nút `Gọi thuyền`. | Gọi thuyền; giữ vùng theo nhịp extract đã công bố (15-25 giây). Một lane báo trước bằng âm thanh/đèn đưa địch tới từ hướng B; player có thể dùng cover/guard/dash. | Thuyền cập bến; player tương tác để rời map. |
| **8. Summary/hub** (13:00-15:00) | Màn kết quả chia `đã giữ`, `đã mất` (nếu có), `vật chứng`, và action kế tiếp. | Xác nhận Manifest đã extract, không bán/craft nó; loot thường về kho. Người Thu Hồi già phản ứng bằng một câu và bản đồ hub ghi `lead: Kho K-7`. | Contract 1 success; campaign state mở Contract 2, nhưng card mang nhãn `chưa có trong vertical slice` và không có nút bắt đầu. |

Khoảng thời gian là nhịp trải nghiệm, không phải speedrun timer. Người chơi chết, mở inventory lâu hoặc chọn rút sớm có thể tạo run ngắn hơn/dài hơn; prototype đánh giá việc hiểu quyết định thay vì ép đủ phút.

## 4. Ba kết quả hợp lệ và recovery

### 4.1 Rút sớm an toàn — sau Beat 2

Người chơi có thể bỏ qua B/D, gọi extract A ngay khi đã cầm Manifest. Kết quả:

- `Manifest Hàng Hóa R-17` được extract, Contract 1 thành công, giấy phép được giữ và item chuyển thành hồ sơ contract/hub theo luật evidence;
- không nhận loot tutorial ở B/D; không có phạt đạo đức, không mở D thuyền hay Local Story;
- hub ghi nhận lead: “Mã R-17 chỉ về Kho K-7” và **mở Contract 2 về mặt campaign state**, đúng chuỗi Act I. Trong prototype, card Contract 2 mang nhãn `chưa có trong vertical slice`, không có nút bắt đầu và không hứa content đang playable.

Đây là bài học chủ ý: **hoàn thành mục tiêu rồi rút là một chiến thắng đúng**, không phải failure vì bỏ lỡ loot.

### 4.2 Hoàn thành full-route — Beat 2 đến 8

Extract ở A thành công giữ Manifest và mọi loot đang ở ba lô/túi/Hộp Công Chứng theo rule inventory. Cargo 2x2, item nhỏ và dấu thuế chỉ là loot/prototype teaching fixtures: không tự mở craft, vendor, faction branch hay Act I local story.

Summary so sánh theo footprint (đồ giữ / ô đã dùng), không chấm điểm “build tốt nhất” và không biến màu rarity thành điểm số. Hub phản hồi đúng một việc canon: giữ giấy phép, record lead Kho K-7 và mở **state** Contract 2 ở dạng chưa playable trong prototype; `Manifest` **không** là bằng chứng pháp lý cuối, không tự thành `Bộ Phản Niêm R-17`.

### 4.3 Chết / Phù Hiệu Hồi Hương — tại B hoặc D

| Thời điểm chết | Kết quả bắt buộc |
|---|---|
| Trước khi nhặt Manifest | Phù Hiệu đưa player về hub; gear/loot không niêm phong mất theo summary. Manifest vẫn ở bàn A; Contract 1 còn active. |
| Sau khi nhặt Manifest, dù đã bỏ vào Hộp Công Chứng | Không tính extract/không giữ giấy phép. Manifest không về kho hub; Contract về `unrecovered` rồi chỉ qua `S11 → S12 → S1 recovery → bàn dispatch A`: player phải **tự thu hồi** và đặt Manifest hợp lệ. Chỉ placement hợp lệ mới đổi E0 thành E1; E1 vẫn chỉ cho gọi thuyền, nên còn phải gọi/giữ/lên thuyền A để thành công. Hộp vẫn giữ các item không-phải-evidence đã niêm phong. |
| Trong lúc giữ extract | Cùng luật mất/giữ như trên; thuyền không hoàn tất và không có checkpoint nửa chừng. |

Recovery run dùng cùng A/B/D slice và có starter/recovery kit cơ bản để chuỗi chết không khóa campaign. Nó không hồi gear/loot player đã tự bỏ hay mất ngoài Hộp. Nếu prototype chỉ cần trình diễn một lượt, menu test có thể chọn `Khởi động Recovery Contract`; nó vẫn đi qua briefing/loadout và không fake completion.

## 5. Dạy bằng UI và không gây khó chịu trên mobile

### 5.1 Nguyên tắc delivery

| Điểm dạy | Cách dạy trong slice | Không làm |
|---|---|---|
| Objective/đường đi | Một câu ở đầu màn và marker landmark; A beacon luôn nhìn lại được từ lane về. | Không popup lore dài hay minimap đè lên combat. |
| Combat | Telegraph trên sàn/đèn, cover và một câu action tối đa một lần trước mỗi role mới. | Không freeze player giữa đòn đánh, không spawn ngoài camera/sau lưng. |
| Inventory | Nhặt là card gọn; mở grid lớn chỉ khi player chủ động hoặc không đủ chỗ. Vùng yên sau B là lúc được gợi ý xếp đồ. | Không tự sort/drop/niêm phong, không bắt drag pixel-perfect. |
| Safebox/evidence | Tooltip phân biệt rõ `không mất vĩnh viễn` với `chưa extract/không hoàn thành contract`. | Không nói/ám chỉ rằng chết sau khi niêm phong là completion miễn phí. |
| Extract | Beacon A chỉ đổi E0 `unavailable` sang E1 `callable` sau placement Manifest hợp lệ vào ba lô hoặc Hộp; inspect/card, fail/hủy giữ source và E0. E1 vẫn cần gọi/giữ/lên thuyền. Lane địch có âm thanh/ánh sáng trước khi đến. | Không giấu điều kiện rút hoặc tạo spawn chết bất ngờ. |

### 5.2 Input tối thiểu cần kiểm chứng

- Di chuyển, đánh thường và một phản ứng phòng thủ/né đã được chọn ở control scheme prototype; slice không đòi combo hay precision-platforming.
- Chạm chọn + chạm ô là đủ để nhặt/đặt/rotate/niêm phong; drag-drop chỉ là shortcut. Item sai vị trí giữ nguyên chỗ cũ và nêu lý do.
- Player có thể đóng card/inventory bằng một thao tác; HUD còn thấy health, objective ngắn và telegraph khi overlay được mở.
- `Rút sớm`, `Gọi thuyền`, `Bỏ lại`, đổi safebox và vào không vũ khí có preview/xác nhận ngắn; không có một thao tác không thể hoàn tác ngay lập tức.

## 6. Ranh giới build và acceptance cho prototype

### 6.1 Nội dung bắt buộc để gọi là vertical slice

1. Một player mới hoàn tất được Contract 1 qua A → B → D → A mà không cần bất kỳ map/contract/hub feature sau slice.
2. Player có thể chọn rút A ngay sau Manifest, và game công nhận đó là success không kém full-route.
3. Combat ở B/D có telegraph, cover/lane và thời gian yên đủ để không biến học inventory thành phạt chiến đấu.
4. Có ít nhất một item 1x1/1x2, một cargo 2x2 và một quyết định Hộp 2x2 mà không tự di chuyển/xóa đồ.
5. Chết sau Manifest chứng minh đúng ba ý: mất đồ không niêm phong; đồ niêm phong không-phải-evidence được giữ; Manifest là `unrecovered`, không phải completion.
6. Extract A cần player gọi và giữ khu; summary phân biệt success/death/recovery, mở state Contract 2 đúng canon nhưng đánh dấu nó chưa playable trong prototype.

### 6.2 Tiêu chí quan sát khi playtest

| Quan sát | Tín hiệu đạt | Tín hiệu cần sửa ở task sau |
|---|---|---|
| Mục tiêu | Player tự nói được “lấy Manifest rồi rút A”; biết B/D là optional loot route. | Đi vào B/D mà không biết có thể rút, hoặc nghĩ cần dọn cả map. |
| Inventory | Player hiểu cargo 2x2 đổi lấy không gian và safebox không auto-swap. | Chờ system tự vứt đồ, không hiểu vì sao Manifest chưa hoàn thành khi đã niêm. |
| Combat | Player nhìn thấy telegraph trước hit và biết lane/cover cho phép chọn phản ứng. | Chết mà không biết nguồn damage/hướng địch. |
| Extraction | Player chủ động quay về A và gọi/giữ thuyền. | Đứng trong beacon chờ auto-win, hoặc tưởng death summary là extract. |
| Narrative | Player biết Manifest giữ giấy phép nhưng chưa minh oan gia tộc. | Tin rằng Contract 1 đã phá án/mở map 2. |

## 7. Quyết định đã khóa và câu hỏi chưa giải quyết

**Đã khóa trong scope vertical slice:** Easy cố định; A/B/D; extract A; Contract 1; đường rút sớm hợp lệ; full-route đề xuất; main evidence recovery; starter/recovery kit; fixed tutorial loot fixtures.

**Không quyết định ở đây:** tên/giá/rarity cuối của loot tutorial, kích thước ba lô phát hành, input/control scheme chi tiết, damage/HP/AI tuning, asset/camera cuối, Contract 2, toàn bộ Cảng Hắc Thuế hay hệ thống craft/economy. Các quyết định đó phải đi qua Task Card riêng.
