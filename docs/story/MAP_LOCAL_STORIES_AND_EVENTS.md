# Khế Ước Tàn Vương - Câu chuyện từng map và sự kiện địa phương

**Mục tiêu:** một map là một cộng đồng có vấn đề riêng, không phải sân farm loot. Người chơi có thể gặp biến cố bất ngờ, giải một nhánh cục bộ và thấy map/hub phản ứng; nhưng không lựa chọn nào làm vỡ tuyến truyện chính hoặc khóa vĩnh viễn nội dung offline.

## 1. Cấu trúc bốn lớp của một map

```text
            Main Story Contract
                    |
                    v
        Local Story (một vết thương của vùng)
              /                     \
             v                       v
  Side-story NPC/phe          Incident phát sinh theo run
             \                       /
              v                     v
          Local state + item/route/reward thay đổi
                    |
                    v
          Không thay đổi cổng hoặc canon tuyến chính
```

| Lớp | Mục đích | Có lặp lại? | Ảnh hưởng được phép |
|---|---|---:|---|
| Main Story Contract | Đẩy campaign, mở vùng/cơ chế | Không | Cổng truyện, hub lớn, lore canon |
| Local Story | Giải thích vùng này đang đau vì điều gì | Một lần/map, 2-4 contract | Map state mặc định, NPC địa phương, local hub feature |
| Side-story | Theo một NPC, nhóm dân hoặc tranh chấp tài sản | Mỗi nhánh một lần | Contract phụ, item claim, shop/route/lời thoại cục bộ |
| Incident | Biến cố ngắn trong một hoặc vài run | Tái xuất hiện theo deck | Loot, extraction, patrol, hazard, temporary map state |

Mỗi map ra mắt tối thiểu cần: **1 Local Story, 2 side-story và 4 incident**. MVP có thể làm ít hơn: Local Story + 1 side-story + 2 incident, nhưng không nên chỉ có story contract chính.

## 2. Local Story khác tuyến chính như thế nào?

Local Story có mở đầu, leo thang và kết thúc của riêng map. Nó không làm thay đổi sự thật nền tảng của Khế Ước, nhưng làm người chơi hiểu **hậu quả của sự thật đó lên người cụ thể**.

Ví dụ: Act I buộc người chơi lấy counterseal để điều tra nợ giả. Local Story của Cảng Hắc Thuế lại là việc một xóm bốc vác sống nhờ hàng cứu trợ bị Nhà Hắc Thuế giữ lại. Người chơi có thể giải quyết chuyện này trước, sau hoặc sau khi hoàn thành Act I. Kết quả là khu bến, NPC, contract và loại hàng xuất hiện đổi khác—nhưng Lò Rèn Câm vẫn mở bằng counterseal, không phụ thuộc vào nhánh này.

## 3. Luật nhánh sự kiện: có hậu quả, không soft-lock

### Ba loại state an toàn

| State | Ví dụ | Được thay đổi gì? | Không được thay đổi gì? |
|---|---|---|---|
| `LOCAL_RESOLVED` | Cứu được đội bốc vác | NPC quay lại, shop mua một loại loot, route phụ mở | Main Story, map kế tiếp, quyền truy cập core content |
| `LOCAL_COMPROMISED` | Hàng cứu trợ bị mất, nhưng bằng chứng được giữ | NPC phản ứng khác, contract recovery, reward đổi | Không xóa NPC/cả questline vĩnh viễn |
| `INCIDENT_ACTIVE` | Nước triều dâng ở run hiện tại | extraction, patrol, lane và loot trong run | Không biến map thành permanently unavailable |

Một side-story nên cho lựa chọn **cách làm**, không phải nút “thiện/ác” làm mất content:

- route nhanh/rủi ro cao để cứu người;
- route dài/an toàn để bảo toàn chứng cứ;
- giao nộp hàng cho phe A hoặc niêm phong nó chờ xác minh.

Sau kết quả, game ghi một local flag và cho thấy hậu quả. Hai nhánh có thể mở dialogue/reward khác nhau, nhưng cả hai phải có đường quay lại content trọng yếu.

### Thất bại phải tiếp diễn, không bế tắc

- Chết trong run chỉ làm mất loadout/loot không niêm phong như luật extraction; incident hoặc side-story quay về trạng thái cần xử lý.
- Thất bại một objective có thể tạo `recovery contract`, map state khó hơn hoặc giảm reward, không xóa hẳn người/quest.
- Chỉ Main Story evidence mới có quyền mở map; nó không được mất vĩnh viễn.
- Không dùng deadline thời gian thực trong bản offline. “Khẩn cấp” là một trạng thái save-game kéo dài cho tới khi người chơi giải quyết.

## 4. Incident deck: sự kiện đột xuất trong một run

Trước khi vào run, briefing hiển thị map state chính. Một incident có thể được báo trước ở mức đủ công bằng, hoặc được phát hiện trong 1-2 phút đầu qua âm thanh, đèn tín hiệu hay NPC—không spawn chết bất ngờ sau lưng người chơi.

| Nhóm | Tác động gameplay | Câu chuyện nó kể | Ví dụ |
|---|---|---|---|
| Môi trường | đổi lane, cover, tầm nhìn, điểm extract | Ward/khí hậu đang phản ứng | nước dâng, mưa tro, ray sập |
| Phe phái | đổi patrol, gate, loot claim | một nhóm đang giành kiểm soát | khám thuế, cướp hàng, truy quét người tị nạn |
| Dân sự | rescue/escort/turn-in ngắn | hậu quả con người của map | xe thuốc mắc kẹt, thợ mỏ mất liên lạc |
| Tài sản | vault, auction cache, di vật tranh chấp | vì sao phe sẵn sàng giết/cướp vì một món đồ | két niêm phong trôi dạt, kho bị cháy, relic đổi chủ |

### Quy tắc chọn incident

1. Map có một `primary map state` trước khi vào (ví dụ Nước dâng).
2. Tối đa một incident lớn và một encounter nhỏ trong một run; không chất ba biến cố lên mobile session 8-15 phút.
3. Incident phải tương thích map state: không có xe goòng chạy trong lane đã sập, không có auction công khai khi map đang giới nghiêm.
4. Sau khi giải một incident, đưa cooldown theo số run; lặp lại được nhưng cần biến thể nội dung/route.
5. Incidents liên quan Local Story có thể được ưu tiên cho tới khi nhánh đó được giải quyết.

## 5. Micro-arc: sự kiện nhỏ kéo qua 2-3 run

Không phải incident nào cũng chỉ có một run. Một `micro-arc` có thể tạo cảm giác thế giới nhớ hành động của người chơi mà không can thiệp Main Story.

```text
Tin báo / dấu hiệu
      -> run 1: xác minh hoặc lấy manh mối
      -> run 2: chọn phương án xử lý hoặc recover sau thất bại
      -> run 3: extract kết quả, map/hub đổi local state
```

Ví dụ: **Con tàu không người** ở Cảng Hắc Thuế.

1. Người chơi thấy manifest của một thuyền cứu trợ mất tích.
2. Vào kho nổi, chọn mang bộ phát tín hiệu 2x2 hoặc hàng thuốc 3x3; không thể chắc chắn mang cả hai với ba lô đầu game.
3. Sau khi extract tín hiệu, một nhóm bốc vác xuất hiện ở hub. Nếu người chơi ưu tiên thuốc, group vẫn sống nhờ đường khác nhưng tín hiệu bị bán cho Hắc Thuế; về sau họ cung cấp contract khác và lời thoại dè chừng.

Hai kết quả đều là canon cục bộ; main campaign không đổi.

## 6. Local Story và event của các map ra mắt

### 6.1 Cảng Hắc Thuế - “Bến Không Tên”

**Vết thương địa phương:** hàng cứu trợ của người tị nạn bị đổi thành tài sản tịch thu. Những người bốc vác không có giấy tờ bị xóa tên khỏi sổ thuyền và không thể đòi lương.

| Loại | Nội dung | Gameplay / item | Local state |
|---|---|---|---|
| Local Story | Bến Không Tên: giúp một cựu bốc vác tìm sổ thuyền hoặc chứng minh hàng cứu trợ bị đổi nhãn | manifest 1x2, khóa kho 1x1, hàng thuốc 2x3 | mở xưởng đóng gói nhỏ hoặc contract recovery |
| Side-story | Khiên Canh Kho Số Bảy: một cựu lính hải quan muốn biết đội của họ đã chết vì ai khóa cửa kho | khiên tím 2x2; route hầm kho | dialogue/discount đồ khiên hoặc bounty liên quan Hắc Thuế |
| Side-story | Di sản người tị nạn: gia đình tranh một rương 3x3 có giá cao với giấy tờ nhỏ 1x1 | quyết định value-per-cell | decoration hub, vendor stock, archive entry |
| Incident | Nước triều đen | hầm kho ngập, lane thuyền mở, extract thuyền dễ tiếp cận | environment state |
| Incident | Khám thuế đột xuất | patrol dày, vault có niêm phong giá cao | faction state |
| Incident | Hòm cứu trợ trôi | mục tiêu kéo/nhặt item lớn; có thể bỏ để rút | civilian/property state |
| Incident | Đấu giá bí mật | room hải quan mở; dễ gặp elite nhưng có claim item | property state |

**Kết cục cục bộ:** khu bến có người trở lại làm việc hoặc vẫn bị Hắc Thuế kiểm soát chặt. Dù vậy counterseal cho main story vẫn là mục tiêu độc lập.

### 6.2 Lò Rèn Câm - “Tiếng Gõ Dưới Đá”

**Vết thương địa phương:** thợ mỏ bị ghi thành “nợ tự nguyện”; họ biết engine cần chạy để không chết vì khí tro, nhưng ca làm không bao giờ kết thúc.

| Loại | Nội dung | Gameplay / item | Local state |
|---|---|---|---|
| Local Story | Tiếng Gõ Dưới Đá: xác minh tín hiệu từ nhóm thợ kẹt sau vách sập | bộ phát rung 1x2, cầu chì 1x1, mặt nạ 2x2 | mở shuttle/lift route, hoặc recovery contract nếu tunnel tiếp tục sập |
| Side-story | Nợ của người đốc công: đốc công từng ép người khác đi ca để cứu con mình | dữ liệu bảng chấm công 1x1; gear craft | NPC reaction và blueprint khác nhau, không xóa craft |
| Side-story | Liềm Không Chủ | xác định vũ khí của người từng tổ chức đình công | liềm tím 2x3, worker token | contract bounty hoặc memorial tại hub |
| Incident | Xe goòng tuột phanh | lane tốc độ cao/va chạm; cargo 4-6 ô | environment state |
| Incident | Hơi tro ngược gió | mask/filter có giá trị; một nhánh mỏ đóng, nhánh khác mở | hazard state |
| Incident | Kiểm tra quân khí | quân Thiết Ấn tăng patrol, ammo/weapon cache xuất hiện | faction state |
| Incident | Đèn thợ chớp tắt | encounter rescue ngắn, dẫn tới stash nhỏ | civilian state |

**Kết cục cục bộ:** một tuyến ray được cộng đồng vận hành hoặc Nhà Thiết Ấn tái chiếm nó. Map vẫn playable, nhưng route/extract và những contract worker thay đổi.

### 6.3 Tu Viện Kính Vỡ - “Tên Không Có Trong Gương”

**Vết thương địa phương:** giáo đoàn giấu người tị nạn bằng cách xóa tên họ khỏi registry. Việc này cứu họ hôm nay nhưng khiến họ không thể chứng minh gia đình/tài sản ngày mai.

| Loại | Nội dung | Gameplay / item | Local state |
|---|---|---|---|
| Local Story | Tên Không Có Trong Gương: giúp một người tị nạn chọn phục hồi tên thật hay tiếp tục ẩn danh | shard định tuyến 1x1, bản khai 1x2 | NPC name/dialogue; contract archive hoặc route ngầm |
| Side-story | Người Chép Kinh Cuối Cùng | một người giữ bản chép biết giáo đoàn từng đổi lời khai nào | mực hiện chữ, page seal | access đến archive side-room / lore item family |
| Side-story | Cung Lễ Không Dây | relic của người canh trạm gương biến mất | cung 2x3, dây cung 1x1 | cosmetic/precision contract, không khóa weapon class |
| Incident | Đám rước gương | mirror route đổi, elite đi cùng relic carrier | faction/environment state |
| Incident | Mực phản chiếu | chữ/bẫy vô hình hiện lên; secret cache có thể mở | exploration state |
| Incident | Truy quét người tị nạn | rescue route, extract phụ tạm thời | civilian state |
| Incident | Archive cháy lạnh | loot giấy tờ giảm, relic nóng giá cao, visibility đổi | hazard state |

**Kết cục cục bộ:** người chơi không “giải quyết vấn đề danh tính” cho toàn vùng; họ giúp một nhóm nhỏ chọn rủi ro nào chấp nhận. Đây là mẫu tốt cho dark-fantasy có chiều sâu mà không làm story chính bị nặng.

### 6.4 Thành Mưa Tro - “Khu Phố Sau Mặt Nạ”

**Vết thương địa phương:** bộ lọc tro được ưu tiên cho khu lõi; khu lao động nhận mặt nạ hỏng và bị đưa vào danh sách “tình nguyện” cho nghi thức.

| Loại | Nội dung | Gameplay / item | Local state |
|---|---|---|---|
| Local Story | Khu Phố Sau Mặt Nạ: lần theo một lô filter bị đánh tráo trước mùa mưa tro | filter xanh lá 1x1, hộp thuốc 2x2, voucher tro | infirmary stock, local patrol hostility hoặc local guide |
| Side-story | Danh sách người thay ca | tìm tên một người bị đưa vào nghi thức sai quota | token đỏ 1x1, ward glove | memorial/worker contract hoặc rescue follow-up |
| Side-story | Người bán tro | một merchant tích trữ filter để đổi lấy deed | item claim/đàm phán, loot lớn | vendor pricing/black-market contract |
| Incident | Mưa tro dày | tầm nhìn, damage-over-time, rooftops đóng/mở | hazard state |
| Incident | Còi sơ tán | đám đông chặn lane, extract tạm ở hầm dân sự | civilian state |
| Incident | Đội thay filter bỏ trốn | rescue hoặc take their cargo; elite pursuit | faction/civilian state |
| Incident | Ward flashover | combat area đổi, core material đỏ xuất hiện | environment/property state |

**Kết cục cục bộ:** có thể mở một trạm y tế dân sự nhỏ hoặc đường chợ đen. Không kết thúc nghi thức tro—đó là xung đột của main story—nhưng cho thấy ai phải chịu nó.

### 6.5 Kinh Đô Vô Ngai - “Những Người Không Được Xét”

**Vết thương địa phương:** sau khi người chơi ngăn Crown Audit và Hiến Ước Lâm Thời bắt đầu vận hành, nhiều người vẫn có khoản nợ hoặc quyền sở hữu lơ lửng trong hệ thống cũ. Họ không còn bị Viện Công Chứng kiểm soát hoàn toàn, nhưng cũng chưa được luật mới bảo vệ.

| Loại | Nội dung | Gameplay / item | Local state |
|---|---|---|---|
| Local Story | Những Người Không Được Xét: một nhóm người chờ phán quyết bị kẹt trong kho lưu trữ pháp lý | deed fragments 1x1, seal kit 2x2 | contract board hậu game và hub public archive |
| Side-story | Kho Bạc Rỗng | truy dấu tài sản bị chuyển đi trước hội nghị | vàng 3x3 so với ledger 1x2 | public restitution contract hoặc merchant confrontation |
| Side-story | Người Gác Cổng Cũ | một Bailiff từng thi hành tịch biên muốn giao nộp kho chìa khóa | key ring, shield unique | capital shortcut hoặc guard-themed gear path |
| Incident | Đấu giá tái định giá | vault/item claim thay đổi, nhiều phe cùng vào map | property state |
| Incident | Biểu tình Hiến Ước | lane chính tắc, route mái/hầm mở | civilian/faction state |
| Incident | Kiểm toán đêm | security construct hoạt động, archive loot tăng | faction state |
| Incident | Trụ Ước dao động | route endgame biến thể, red material có rủi ro cao | environment state |

**Kết cục cục bộ:** các nhánh làm rõ Hiến Ước Lâm Thời hoạt động thế nào, chứ không thay ending đã chọn. Đây là map tốt để đưa content sau campaign.

## 7. Sự kiện theo phiên bản cập nhật

Một update map có thể có `Map Chapter` 3 hồi: mở cảnh/catalyst -> 2-3 contract -> hậu quả. Nó phải tách khỏi main campaign bằng điều kiện mở chapter, không phải bằng vũ trụ song song.

Ví dụ cho update sau launch:

| Update | Map / event | Nhánh nhỏ | Item và tác động |
|---|---|---|---|
| Đường Mùa Vỡ | Dã Lộ: đoàn lương bị kẹt khi Ward giảm công suất | chọn bảo hộ đoàn hàng hoặc route scout | crossbow caravan, hạt giống nhiễm tro, contract convoy |
| Hội Đấu Giá Mở | Cảng Hắc Thuế: relic cũ bị đem đấu giá sau độc quyền tan | truy nguồn relic thật/giả; phe muốn mua khác nhau | seal giả, vũ khí hải quan, temporary market prices |
| Đêm Tên Trả Lại | Tu Viện Kính Vỡ: danh tính tị nạn được công bố từng phần | bảo vệ sổ tên hoặc cứu người bị truy sát | mirror cosmetics, archive tool, dialogue branches |
| Mạch Lò Thứ Bảy | Lò Rèn Câm: nhánh mỏ mới tự khởi động | ổn định engine hoặc lấy drill relic | quặng 3x3, liềm/cường hóa stagger, new extraction lane |

Mỗi update đóng mâu thuẫn địa phương của nó. Nó có thể để lại **một** hook cho map khác, nhưng không dùng cliffhanger mỗi lần.

## 8. Checklist trước khi thêm incident hoặc nhánh nhỏ

1. Nó thuộc lớp nào: Local Story, Side-story, Incident hay Map Chapter?
2. Vấn đề con người/cộng đồng cụ thể là gì, ngoài “có quái và loot”?
3. Điều gì thay đổi trong run: route, extract, hazard, claim, inventory hay enemy behaviour?
4. Người chơi biết rủi ro đủ sớm để có lựa chọn công bằng không?
5. Kết quả nào được lưu: `LOCAL_RESOLVED`, `LOCAL_COMPROMISED` hay chỉ `INCIDENT_ACTIVE`?
6. Mọi outcome có tiếp tục được nếu player chết/không chọn nó không?
7. Item reward có kể câu chuyện và không power-creep gear cũ không?
8. Nó có tránh làm thay đổi canon Main Story hoặc phải retcon update cũ không?
