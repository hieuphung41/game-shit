# Khế Ước Tàn Vương — Art & Presentation Direction

**Trạng thái:** `proposed`. Đây là brief định hướng cho prototype/vertical slice offline-first 2.5D; không phải asset list, style guide cuối, hay thông số kỹ thuật dựng hình.

**Nguồn ràng buộc:** [Cảng Hắc Thuế](maps/black-tax-port.md), [vertical slice](vertical-slice.md), [inventory và loadout](systems/inventory-and-loadout.md), [thiết kế item](story/ITEM_NARRATIVE_DESIGN.md), [Story Bible](story/STORY_BIBLE.md). Khi tài liệu này khác các luật hệ thống hoặc story đã có, tài liệu nguồn được ưu tiên.

## 1. Lời hứa trình bày

Hình ảnh cần làm rõ cảm giác của một Người Thu Hồi nghèo nhưng chủ động: đi vào một vùng bị quản thúc, nhìn được lối về, nhận ra vật nào đáng đổi chỗ trong ba lô, rồi tự chọn lúc rút. Cảng không phải một kho tàng fantasy vô chủ; dấu thuế, vết niêm, hàng cứu trợ và những lối đi bị kiểm soát phải khiến quyền lực hiện hữu ngay cả khi người chơi không mở lore.

Ba trụ hình ảnh `proposed`:

1. **Quyền lực có dấu vết.** Dấu niêm, bảng kiểm, cổng, thẻ hàng, dây chặn, số kho và đồ sửa vội kể ai đang kiểm soát một khu. Sự giàu có không bóng bẩy: đồng oxy hóa, vải bẩn nước, gỗ vá chằng vá đụp và giấy đã bị đóng lại.
2. **Phiêu lưu u tịch nhưng còn người sống.** Nước tối, kiến trúc lún và kho bỏ hoang tạo áp lực; đèn dẫn đường, bếp dân bốc vác, thuốc cứu trợ và phản ứng ở hub giữ lại hơi ấm. Không biến khổ đau của dân thường thành décor hoặc gore để gây sốc.
3. **Quyết định đọc được trong một nhịp.** Silhouette, landmark, mặt sàn, hướng địch và footprint phải nhìn/hiểu trước chi tiết trang trí. Mỗi khung hình combat ưu tiên vị trí player, telegraph, lane và mục tiêu hơn hiệu ứng đẹp.

Mọi quy ước bên dưới là `proposed` cho tới khi được test trên màn hình điện thoại mục tiêu.

## 2. Camera và hợp đồng đọc không gian

| Thành phần | Quy ước trình bày `proposed` | Điều cần tránh |
|---|---|---|
| Góc nhìn | Camera isometric cố định, hướng nhất quán xuyên A–E; chỉ được zoom nhẹ ở elite khi vẫn thấy lane thoát và telegraph. | Xoay camera tự do, rung/zoom mạnh, đổi hướng map khiến người chơi mất trí nhớ route. |
| Cao độ | Tối đa hai tầng đọc được. Mép mái/cầu/lan can có silhouette đủ khác mặt đất để biết đường đi, nhưng không đòi nhảy chính xác. | Chồng ba tầng dày, cầu che lane, nền lát quá chi tiết làm lẫn ranh giới. |
| Che khuất | Vật foreground che player, loot, hazard hoặc objective sẽ chuyển trong suốt/outline; marker không bị tường/cột nuốt. | Lá cờ, mái vải, cần cẩu hay hiệu ứng nước che telegraph/đồ nhặt. |
| Đường đi | Mặt sàn, hàng rào, cover và điểm tương tác dùng hình khối/cạnh sáng ổn định để phân biệt walkable, cover và vật cản. | Dùng chỉ màu nền để nói chỗ đi được, fake route thành ngõ cụt hoặc precision-platforming. |
| Landmark | Một landmark lớn luôn giữ được vị trí tương quan: A là đèn phao, B mái chợ, C cần cẩu, D lồng kho/nước, E tường dấu thuế. | Thay silhouette landmark theo incident hoặc dùng cùng một hình khối cho hai khu. |

Mỗi encounter phải còn đọc được câu hỏi “địch đến từ lane nào, tôi có cover/đường rút nào?” trong một cái liếc ngắn. Khi inventory mở, HUD vẫn để lại ít nhất health, objective ngắn và cảnh báo nguy hiểm; không có hiệu ứng trình bày nào được che thông tin đó.

## 3. Ngữ pháp hình ảnh của Cảng Hắc Thuế

Đây là một hệ thống nhận diện theo **silhouette + vật liệu + nhịp ánh sáng + signage**, không chỉ palette. Các màu/đối tượng là dấu hiệu định hướng, không phải thêm lore, loot tier hay quy tắc combat.

| Khu | Dấu nhận diện `proposed` | Điều người chơi phải đọc được | Tránh |
|---|---|---|---|
| **A — Bến Ngoài** | Đèn phao xanh lam, cọc bến cao, dây neo thẳng, mặt nước mở và bảng dispatch. Ánh sáng ổn định, ít clutter. | spawn an toàn, bàn Manifest, lối vào B và Cầu tàu A là nơi quay về/extract. | Nước/đèn đẹp nhưng beacon lẫn với loot hoặc NPC; tạo combat décor cạnh điểm học đầu tiên. |
| **B — Chợ Ngập** | Mái vải đỏ sẫm, quầy thuế nghiêng, biển giá bị đóng dấu, ngõ hẹp có cover thấp. Nhịp ánh sáng cục bộ và có khe nhìn về A. | đây là route cân bằng, địch có thể chặn lane; loot nhỏ và vật có claim nằm trong không gian dân sự bị kiểm soát. | Vải treo dày che camera, biển hiệu giống objective marker, đỏ sẫm thành màu cảnh báo damage. |
| **C — Mái Nhà & Cầu Dây** | Cần cẩu vàng xỉn, dây chéo, mái sáng gió, khoảng trời rộng và đèn treo cao. Silhouette đứng cao tách rõ từ B/D. | route cao, nhanh, phơi bày; có góc bắn/ranged và đường shortcut, không phải mê cung mái nhà. | Dây/cầu chỉ để trang trí, drop không thấy, chi tiết vàng giống rarity vàng. |
| **D — Kho Nổi** | Nước xanh lục tối, lồng cargo vuông lớn, thân thuyền cũ, phao/van/rào chắn thấp. Ánh sáng phản xạ giúp tách lane nông khỏi hazard. | hàng cồng kềnh, route nước/hazard, lối trở lại B và tiềm năng thuyền extract. | Mặt nước phản chiếu nuốt telegraph/loot; lồng hàng che footprint hoặc làm mọi cargo cùng đọc như một item. |
| **E — Kho Hải Quan Niêm Phong** | Tường đá đồng/xám, dấu niêm lớn, cửa sắt phân lớp, đèn kiểm tra có nhịp và bàn niêm hồ sơ. Ít clutter hơn nhưng áp lực rõ hơn. | đây là khu kiểm soát/evidence/claim, pressure cao và có lối cổng thuế khi contract cho phép. | Biến E thành kho báu vàng rực; hình dấu niêm lẫn với icon objective/evidence. |

Ở vertical slice, chỉ **A/B/D** là không gian tương tác. Cần cẩu C và tường niêm E chỉ hiện như silhouette xa: đủ hứa một thế giới rộng hơn, không có highlight, marker, loot glow hay affordance khiến người chơi nghĩ chúng đã mở.

## 4. Tín hiệu gameplay không phụ thuộc riêng vào màu

Màu hỗ trợ nhịp đọc, nhưng một trạng thái phải còn phân biệt được khi màn hình nhỏ, độ sáng thấp hoặc người chơi có suy giảm nhận biết màu. Icon, hình, chuyển động, vị trí và text ngắn cùng gánh nghĩa.

| Thứ cần đọc | Lớp tín hiệu chính `proposed` | Lớp dự phòng và ranh giới |
|---|---|---|
| **Loot và footprint** | Silhouette đúng vật thể trên ground; card nhặt cho footprint bằng hình lưới `1x1`, `1x2`, `2x2`… trước lore. Item lớn có base/outline theo kích thước để không trông như pickup 1 ô. | Tên/footprint dạng chữ và preview placement. Không dùng glow mạnh để che việc đồ lớn tốn chỗ. |
| **Rarity/appraisal** | Viền thẻ + nhãn bậc 1–6 + tên lớp thẩm định; swatch màu trắng/xanh lá/xanh dương/tím/vàng/đỏ chỉ là lớp phụ. | Không đổi silhouette hoặc effect combat theo rarity; rarity không thay giá/ô, damage hoặc claim. |
| **Claim/tài sản có chủ** | Con dấu/icon phe, pattern dây niêm/thẻ treo và nhãn ngắn trên card/inspect. | Icon claim luôn ở vị trí khác rarity; không dùng cùng màu/shape với bậc item, objective hay trạng thái bị truy nã. |
| **Evidence và trạng thái safebox** | Dạng tài liệu/niêm chuyên biệt + icon contract. Khi niêm phong: dấu hộp đóng và label `đã niêm — chưa extract`; khi chết: summary `unrecovered`. | Không dùng cùng glow với loot hiếm; không bao giờ trình bày safebox như hoàn thành contract hay teleporter về hub. |
| **Hazard** | Hình dạng nền/cảnh báo có hướng: nước sâu có ranh gợn + cọc cảnh báo; bẫy có cơ cấu nhìn thấy; khu nguy hiểm có âm thanh/nhịp chuyển động báo trước. | Không chỉ phủ màu đỏ/xanh lên sàn; hazard không che lối về hay telegraph của địch. |
| **Combat telegraph** | Hình vạch/lane trên sàn, arc/aim-line định hướng và animation wind-up tách nền. Âm thanh hỗ trợ hướng trước đòn hoặc địch vào lane extract. | Telegraph ưu tiên layer cao nhất gần combat; không dùng VFX loot/objective cho hình dạng đòn đánh. |
| **Objective và interaction** | Marker hình học riêng, label một câu và đường dẫn ngắn khi cần. Manifest/bàn dispatch dùng affordance giấy tờ/bàn làm việc, không phải cột sáng generic. | Marker không đè loot/card; một thời điểm chỉ nổi bật objective hiện tại và extract khả dụng. |
| **Extract** | Beacon có silhouette cố định + vòng khu vực + tín hiệu trạng thái `chưa mở / có thể gọi / đang giữ / sẵn sàng rời`; A dùng đèn phao/cầu tàu quen thuộc. | Địch extract chỉ tới từ lane đã báo sáng/âm thanh. Không dùng beacon giống giá trị loot hay safebox. |

## 5. UI mobile và thứ tự chú ý

### 5.1 HUD trong run

HUD `proposed` chỉ duy trì bốn lớp ưu tiên: (1) health/trạng thái nguy hiểm, (2) telegraph/lane trước mắt, (3) objective hoặc extract state một câu, (4) interaction/loot card ngắn. Notification về lore, vendor hay reward có thể đợi tới vùng yên hoặc summary; không chen lên combat.

Mỗi card nhặt tuân thứ tự đã chốt: **silhouette/tên → footprint/ô trống → công dụng hoặc giá ước lượng → claim → rarity → một dòng lore**. Card chỉ mở rộng inspect theo hành động chủ động. Icon luôn có label/textual fallback; tap target và chữ phải còn đọc được bằng một tay, không yêu cầu kéo-thả pixel-perfect.

### 5.2 Inventory, safebox và hậu quả

Lưới ưu tiên shape/footprint và khoảng trống hợp lệ. Preview placement dùng outline + trạng thái chữ (`vừa`, `không vừa`, `sai loại`, `không niêm phong được`), không chỉ viền xanh/đỏ. Chạm chọn rồi chạm ô là thao tác đầy đủ; kéo-thả là shortcut. Rotate, sort, drop, swap gear và rút safebox phải có icon/label ổn định, preview và xác nhận đúng luật inventory.

Summary sau extract/death chia thành nhóm hình và chữ: `đã giữ`, `đã mất`, `vật chứng — unrecovered`, `bước tiếp theo`. Đồ niêm phong không-phải-evidence trở về hub khi death phải nhìn khác evidence chưa extract; người chơi không được hiểu nhầm một dấu hộp đóng là chiến thắng story.

### 5.3 Khả năng tiếp cận và nhịp chú ý

- Không có thông tin sống/chết, claim, rarity, extract hay hazard nào chỉ dùng màu, rung, âm thanh hoặc chữ quá nhỏ.
- Cho phép giảm rung camera/flash/VFX dày; tín hiệu hướng địch/extract có cả visual và audio, nhưng mỗi kênh độc lập vẫn đủ hiểu.
- Overlay inventory/card có thể đóng bằng một thao tác; không che hoàn toàn cảnh báo low-health hay telegraph đang có.
- Text trong run là mệnh lệnh/đích đến ngắn. Lore dài chỉ ở inspect/Archive tại hub; người chơi không bị buộc đọc để biết hành động.
- Sau gate có vùng yên 15–30 giây như map brief, tạo thời điểm hợp lý để việc đọc item sâu hơn không trở thành phạt combat.

## 6. Nhịp trình bày của vertical slice

| Beat slice | Tín hiệu trình bày phải chứng minh | Không được hứa |
|---|---|---|
| Briefing/loadout | Một màn sạch: Contract 1, rủi ro đồ không niêm, slot/loadout và beacon A. | Giá, phí, stat hay hệ thống map sau slice. |
| A: Manifest và rút sớm | Bàn dispatch, Manifest 1x1 và Cầu tàu A cùng đọc được; beacon A chỉ đổi từ `chưa callable` (E0) sang `có thể gọi` (E1) sau khi player hoàn tất placement Manifest hợp lệ vào ba lô hoặc Hộp. Inspect, mở card, placement fail/hủy giữ E0. | Manifest là bằng chứng cuối hoặc phải đi B/D mới được thắng. |
| B: combat + loot nhỏ | Lane/cover/telegraph rõ trên mái vải; card cho loot/claim/footprint mà không làm màu đỏ B thành damage indicator. | Mọi loot màu cao tốt hơn hoặc B là bắt buộc. |
| D: cargo và safebox | Lồng cargo 2x2 nhận ra là cồng kềnh từ ground/card; safebox 2x2 cho thấy chỗ trống và hậu quả tự chọn. | Auto-sort, auto-swap, weight penalty hay thuyền extract playable. |
| Quay A/extract | Landmark theo chiều ngược, lane địch báo trước, beacon đổi state tuần tự. | Spawn sau lưng, auto-win khi đứng vào vòng, checkpoint nửa extract. |
| Summary/hub | Phân biệt extract/death/recovery và ghi lead Kho K-7 bằng thay đổi nhỏ, dễ hiểu. | Contract 2 đang playable, Archive/economy/campaign content chưa nằm trong slice. |

## 7. Ranh giới scope và mở rộng

### 7.1 Cut art/presentation cho MVP

MVP chỉ cần một camera/readability kit nhất quán; A/B/D, player/enemy cơ bản, loot có footprint 1/2/4 ô, trạng thái Hộp Công Chứng/evidence/extract và UI đọc được Contract 1. C/E là backdrop không tương tác. Ranh giới khả thi theo art: ưu tiên prop mô-đun, signage/decal claim và landmark tái dùng có chủ ý; giữ foreground, phản xạ nước và screen effect đủ tiết chế để silhouette/telegraph còn ưu tiên. Một bộ ngữ pháp rõ tốt hơn số lượng prop lớn hay một môi trường hoàn toàn độc nhất từng screen.

Không chốt ở brief này: concept art cuối, model/texture/shader/VFX/audio cuối, render pipeline, hiệu năng theo thiết bị, mật độ asset, animation timing, độ phân giải UI, ngân sách hay kiến trúc implementation. Khi production cần các quyết định đó, chúng phải đi qua task/card riêng sau test readability.

### 7.2 Nguyên tắc cho map và update sau

Map mới mở theo evidence/permit phải có **một chữ ký hình ảnh** dễ nhớ (landmark, vật liệu, nhịp ánh sáng và dấu kiểm soát) cùng bộ quy ước chung cho claim, loot, hazard, combat và extract. Update có item/event mới chỉ được thêm một visual grammar mới nếu vẫn giữ nghĩa ổn định cho các grammar cũ; không reskin rarity thành claim, evidence thành quest trinket hoặc extract thành checkpoint.

Nội dung sau slice được phép mở rộng cảnh quan/đạo cụ để kể chuyện địa phương, nhưng không được dùng trang trí để phá geography cố định, landmark, route hợp lý hoặc readability đã hứa với người chơi.

## 8. Ranh giới tham khảo và originality

Brief này chỉ mượn **mục tiêu thiết kế**: sự nặng nhẹ của đồ nhặt, không gian phiêu lưu u tịch, và combat có tín hiệu công bằng. Nó không được sao chép tên, nhân vật, phe, thuật ngữ, lore, plot, cảnh, layout đặc trưng, costume, UI, icon, palette nhận diện hoặc visual identity của tiểu thuyết/trò chơi tham khảo.

Mọi sketch, asset, UI và audio về sau phải bắt đầu từ những mâu thuẫn riêng của Khế Ước Tàn Vương: nợ có chứng thực, quyền sở hữu bị tranh chấp, vùng bị quản thúc, và Người Thu Hồi phải mang vật chứng ra khỏi đó. Nếu một proposal chỉ mô tả bằng tên/reference bên ngoài thay vì chức năng/câu chuyện riêng, proposal đó chưa đủ để sản xuất.

## 9. Checklist trước khi đưa một presentation element vào build

1. Nó có giúp người chơi đọc route, rủi ro, ownership, loot choice hoặc extraction trong vài giây không?
2. Nó có còn hoạt động khi không nhận biết màu, không nghe âm thanh, hoặc UI scale nhỏ không?
3. Nó có che player, telegraph, loot footprint, objective hay lane thoát ở camera cố định không?
4. Nó có nói sai về rarity, claim, safebox/evidence, death/recovery hay trạng thái extract không?
5. Nó có phù hợp A/B/D vertical-slice cut, thay vì giả vờ C/E hoặc Act sau đã playable không?
6. Nó có dựa trên visual language riêng của game thay vì nhận diện/cảnh/thuật ngữ của tác phẩm khác không?
