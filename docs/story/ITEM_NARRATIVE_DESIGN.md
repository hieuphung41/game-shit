# Khế Ước Tàn Vương - Thiết kế item có linh hồn

**Mục tiêu:** item phải đồng thời là quyết định loot, một dấu vết của thế giới và một phần của cốt truyện. Người chơi không cần đọc tiểu thuyết để hiểu item, nhưng một người tò mò phải có thể lần ra câu chuyện của các vùng, phe và Khế Ước qua chính những gì họ nhặt rồi quyết định giữ hoặc bán.

## 1. Luật thiết kế cốt lõi

Một item chỉ được đưa vào game nếu làm tối thiểu **một** trong bốn việc sau; item tốt nên làm hai việc trở lên.

1. **Lợi nhuận:** cho tiền hoặc trao đổi có ý nghĩa.
2. **Chuẩn bị:** craft, sửa, hồi phục, mở đường hoặc thay đổi build.
3. **Quan hệ/quyền lực:** một phe hoặc NPC công nhận nó, sợ nó hoặc cần nó.
4. **Sự thật:** nó hé lộ chuyện đã xảy ra và làm thay đổi mục tiêu, contract hay trạng thái của hub.

Không dùng “junk loot” chỉ để lấp ba lô. Một mảnh đồ rẻ có thể không thay đổi campaign, nhưng phải trả lời được: *ai từng dùng nó, vì sao nó đang ở đây, và tại sao vẫn có người trả tiền cho nó?*

## 2. Bốn lớp item

| Lớp item | Tỷ lệ loot gợi ý | Người chơi dùng để làm gì | Vai trò câu chuyện |
|---|---:|---|---|
| Hàng salvage | 55-65% | Bán lấy tiền, trả phí contract | Cho biết nền kinh tế và hậu quả của xung đột tại vùng đó |
| Vật liệu/công cụ | 20-25% | Craft, sửa đồ, thuốc, ammo, mở utility | Biến thứ bị bóc lột/tàn phá trong vùng thành sức mạnh thực tế của người chơi |
| Tài sản có chủ | 10-15% | Bán, giao nộp, đổi lấy ưu đãi hay contract | Thể hiện phe nào kiểm soát tài nguyên và ai chịu thiệt |
| Chứng cứ/di vật độc nhất | 2-5% | Hoàn thành Story Contract, mở vùng/hub/nhánh side quest | Đẩy bí ẩn của Khế Ước tiến lên |

Tỷ lệ là định hướng cho tổng thể map, không bắt buộc mỗi hòm loot phải có đủ bốn lớp.

## 3. Item identity card

Mỗi item có một record thiết kế gồm các trường dưới đây. Đây là công cụ viết content, không nhất thiết hiện tất cả lên UI.

| Trường | Câu hỏi cần trả lời |
|---|---|
| Tên và silhouette | Người chơi có nhận ra nó trong 0.5 giây trên màn hình mobile không? |
| Footprint / weight | Nó chiếm bao nhiêu ô và vì sao nó cồng kềnh hoặc gọn? |
| Appraisal class | Trắng, xanh lá, xanh dương, tím, vàng hay đỏ; lớp này nói gì về giá trị, nguồn gốc, độ nguy hiểm và tính hợp pháp? |
| Provenance | Nó thuộc vùng nào, thời kỳ nào, ai đã làm/dùng nó? |
| Claim | Phe/NPC nào có quyền lợi, sẽ mua hoặc muốn bịt miệng người giữ nó? |
| Gameplay use | Bán, craft, equip, turn-in, unlock hay thay đổi route nào? |
| Narrative line | Một câu ngắn gợi ra xung đột, không kể lể toàn bộ lore |
| Consequence | Extract/sell/turn-in nó thay đổi gì, dù chỉ là giá mua, một câu thoại hay một contract? |

Ví dụ ngắn:

> **Dấu niêm thuế đã cạo tên** — 1x1, xanh lá. Dụng cụ đồng của hải quan Cảng Hắc Thuế; biểu tượng cũ đã bị cạo đi rồi đóng lại bằng dấu của Hắc Thuế. Nó là manh mối provenance và claim—Viện Công Chứng muốn thu hồi, còn Người Thu Hồi già nhận ra dấu của một bàn kiểm nhận đã bị thay—nhưng không phải chứng cứ pháp lý và không thay `Counterseal + Sổ Nợ Gốc`.

Người chơi trước hết thấy: `1 ô · 420 bạc · Viện Công Chứng mua`. Người muốn tìm hiểu mới mở inspect và thấy câu chuyện.

## 4. Rarity là chuẩn thẩm định, không chỉ là sát thương

| Cấp | Màu | Ý nghĩa trong thế giới | Ví dụ |
|---:|---|---|---|
| 1 | Trắng | Hàng phổ thông, chưa được chứng thực hoặc còn nguyên vẹn giá trị sử dụng | vải cứu trợ, dụng cụ mỏ, mũ bảo hộ cũ |
| 2 | Xanh lá | Linh kiện/đồ có nguồn gốc rõ, có ích chuyên biệt | dấu thuế, bộ lọc tro, dây cung quân dụng |
| 3 | Xanh dương | Tài sản được đăng ký, gear chuyên dụng hoặc vật liệu hiếm | sổ kho, lưỡi giáo tuần tra, lõi điều áp |
| 4 | Tím | Di sản tranh chấp, bản ghi bị cấm hoặc trang bị định hình build | ấn xưởng, khiên đội cận vệ, mảnh lời khai |
| 5 | Vàng | Tài sản quyền lực cấp nhà/vương triều, chứng cứ có thể đổi cán cân | ấn chủ quyền, vũ khí nghi lễ, deed gốc |
| 6 | Đỏ | Di vật bị cấm hoặc bằng chứng chạm thẳng tới Khế Ước; ai giữ nó cũng gặp nguy hiểm | mảnh Khế Ước, lõi phong ấn, tên trong sổ hiến tế |

- Màu cao hơn **không tự động** có giá trị mỗi ô tốt hơn. Một tượng vàng 3x3 có thể lời tổng rất lớn nhưng thua gem xanh dương 1x1 về hiệu suất ba lô.
- Màu đỏ không được biến thành “vật phẩm bán đắt nhất” một cách máy móc. Nó nên có claim/rủi ro và mục đích truyện rõ ràng.
- Chứng cứ cốt truyện có thể là xanh lá hoặc xanh dương. Một giấy tờ nhỏ đúng ngày tháng đôi khi nguy hiểm hơn vũ khí đỏ.

## 5. Vòng đời của một item

```text
Thấy vật phẩm
   -> nhận ra silhouette, footprint, rarity và giá ước lượng
   -> cân nhắc giá trị mỗi ô / claim / công dụng
   -> xếp, xoay, bỏ lại hoặc thay bằng món khác
   -> chọn đưa vào safebox hay mạo hiểm mang trong ba lô
   -> extract
   -> bán / craft / trang bị / giao nộp / lưu archive
   -> hub, quan hệ hoặc contract thay đổi
```

Safebox không chỉ là bảo hiểm. Nó là một lựa chọn kể chuyện: trong 2x2 ô đầu game, người chơi có thể phải chọn giữa thuốc cứu run, gem 1 ô và một chứng cứ 1x2 chứng minh gia tộc bị hại.

## 6. Chứng cứ Story Contract: có rủi ro nhưng không kẹt campaign

Chứng cứ không được tự động nhảy vào kho sau khi nhặt; như vậy sẽ phá cảm giác extraction. Cũng không được mất vĩnh viễn, vì player chết không thể bị khóa cốt truyện.

- Story item có footprint nhỏ và rõ ràng (thường 1x1, 1x2 hoặc 2x2), có thể đặt vào safebox nếu người chơi muốn bảo đảm.
- Nếu người chơi chết khi chưa extract, item quay về trạng thái **unrecovered** trong cùng Story Contract. Lần sau nó ở điểm logic khác trong cùng khu (xác người mang, bàn niêm phong, kho bị tuần tra), không phải random vô lý.
- Khi item đã extract, nó được niêm phong trong Archive của hub: không thể bán nhầm, không chiếm ba lô và không thể farm lặp.
- Một Story Contract không yêu cầu nhặt 10 mẩu giấy như checklist. Mỗi act dùng 1-3 chứng cứ có tên, mỗi món trả lời một câu hỏi mới.

## 7. Vũ khí và trang bị cũng kể chuyện

Không phải mọi vũ khí là “Sword +7”. Từ lúc MVP, mỗi base weapon nên có `nguồn gốc + người từng dùng + cách chiến đấu`, sau đó rarity/affix mới làm nó đặc biệt hơn.

| Nguồn gốc | Gameplay identity | Dấu chuyện kể qua item |
|---|---|---|
| Hải quan Cảng Hắc Thuế | Kiếm ngắn/khiên nhẹ; parry, đánh trong ngõ hẹp | Dấu thuế bị sửa cho thấy ai có quyền dùng bạo lực ở cảng |
| Lò Rèn Câm | Giáo, liềm, giáp nặng; stagger và kiểm soát không gian | Mã lò, vết sửa vội và số hiệu lao động cho thấy giá của công nghiệp quân sự |
| Tu Viện Kính Vỡ | Cung, dao nghi lễ, giáp nhẹ; precision, perception | Ký hiệu gương/đoạn kinh bị bôi phản ánh việc kiểm soát ký ức |
| Thành Mưa Tro | Khiên lớn, súng/ống phun, đồ kháng hiệu ứng | Lớp tro và số phân phối nói ai được bảo vệ, ai bị bỏ lại |
| Kinh Đô Vô Ngai | Legacy gear đa dạng; build-defining nhưng có claim mạnh | Dấu triều đình cho biết vai trò của chủ cũ trong Khế Ước |

**Unique gear** chỉ cần xuất hiện thưa. Mỗi món có một mô tả ngắn, một cơ chế khác biệt và một liên hệ NPC/map; đừng viết tiểu sử dài cho hàng trăm cây kiếm ngẫu nhiên.

Ví dụ: **Khiên Canh Kho Số Bảy** (2x2 khi chưa trang bị, tím) có móc treo chìa khóa kho và vết khoan tròn từ bên trong. Nó hỗ trợ guard/stagger, đồng thời mở lời thoại với một cựu nhân viên hải quan về một đêm kho bị niêm phong.

## 8. Story loot theo vùng

| Vùng | Hàng salvage cho thấy điều gì | Item chức năng | Chứng cứ/di vật chủ đạo | Hệ quả khi mang về |
|---|---|---|---|---|
| Cảng Hắc Thuế | hàng cứu trợ bị đổi nhãn, két thuế, hành lý người tị nạn | dây thừng, chìa kho, thuốc nước mặn | `Counterseal + Sổ Nợ Gốc` thành **Bộ Phản Niêm**; dấu niêm thuế đã cạo tên chỉ kể provenance/claim | mở kho/cửa hàng; mã phân bổ Ward Engine trong Bundle dẫn tới Lò Rèn |
| Lò Rèn Câm | quặng chưa tinh luyện, giáp lỗi, dụng cụ công nhân | bộ điều áp, than đặc, phụ tùng sửa gear | Ward Engine registry (sổ kiểm định và ấn xưởng) | mở craft/sửa đồ; mã chứng thực registry cần Witness Key ở Tu Viện |
| Tu Viện Kính Vỡ | tượng vỡ, bản chép bị cạo, đồ hành hương bị tịch thu | mảnh gương định tuyến, mực hiện chữ, bandage | Witness Key xác thực registry/lời khai; Witness Mark xác nhận người thầy còn sống, giữ Field Authority Seal | mở Archive và contract phe phái; Witness Mark dẫn tới Thành Mưa Tro |
| Thành Mưa Tro | khẩu phần nhiễm tro, lệnh cưỡng bách, mặt nạ hỏng | bộ lọc tro, thuốc chống nhiễm, cầu chì nghi thức | Field Authority Seal + registry; phải giữ relay cho sơ tán rồi extract cả hai | mở Ward/Infirmary và tuyến Kinh Đô; dân có đường thoát nhưng không phải ai cũng được cứu |
| Kinh Đô Vô Ngai | đồ nghi lễ triều đình, tiền bị thu hồi, thiết bị phong ấn | lõi ward, bản đồ hầm, linh kiện legacy | mảnh Khế Ước và bằng chứng gia tộc | quyết định kết game và contract endgame |

## 9. Khi nào item được phép thay đổi story

Để không phình scope, chỉ có ba tầng hệ quả:

1. **Phổ biến:** bán/craft/equip; thay đổi kinh tế, không đổi hội thoại chính.
2. **Có chủ:** turn-in cho phe hoặc NPC để nhận contract, giá mua, cosmetic/base decoration hay một đoạn hội thoại. Ở MVP, kết quả này nên là lựa chọn nhỏ, không khóa content chính.
3. **Độc nhất:** Story evidence/relic; luôn thay đổi mục tiêu campaign, trạng thái hub hoặc lead sang vùng tiếp theo.

Không nên tạo morality meter toàn cục hay nhiều nhánh campaign từ mọi món loot ở bản đầu. Ý nghĩa đến từ việc người chơi hiểu **món đồ này thuộc về cuộc tranh chấp nào**, không nhất thiết từ việc game ghi nhớ hàng nghìn lựa chọn.

## 10. Cách trình bày lore trên mobile

- Tooltip ưu tiên theo thứ tự: footprint -> giá ước lượng -> ai quan tâm -> công dụng -> một câu lore.
- Dùng biểu tượng claim rõ cho Viện Công Chứng, mỗi Nhà, Retriever League và Old Wardens; màu rarity không thay biểu tượng phe.
- Dùng dấu đóng, mã lò, biểu tượng khắc, kiểu dây buộc và tình trạng hao mòn để kể chuyện bằng hình thay vì popup.
- Inspect cho 1-2 câu. Archive tại hub giữ mô tả dài hơn cho người muốn đọc.
- Khi extract chứng cứ quan trọng, cho phản ứng trực tiếp: NPC nói một câu, căn phòng hub mở, bản đồ cập nhật hoặc một contract mới hiện ra. Không chỉ hiện thông báo “Lore unlocked”.

## 11. Checklist khi tạo item mới

1. Item được nhặt ở vùng nào và vì sao hợp lý ở đó?
2. Nhìn silhouette/footprint, người chơi có biết đây là món gì và tốn chỗ vì sao không?
3. Giá trị tổng và giá trị mỗi ô có tạo quyết định thật không?
4. Nó thuộc về/đụng chạm phe nào, nếu có?
5. Người chơi có hành động nào sau khi extract ngoài bán vô điều kiện không?
6. Một dòng mô tả của nó có gợi ra xung đột cụ thể không?
7. Nếu là item story, chết có thể thất bại run nhưng không kẹt campaign không?
