# Cảng Hắc Thuế — Bộ item Act I đầu tiên

**Trạng thái:** 24 item identity card `proposed` cho production/content thử nghiệm. Tên, footprint và vai trò của item đã có trong [map brief](../maps/black-tax-port.md) được giữ nguyên; rarity cụ thể, silhouette, claim phụ và outcome dưới đây là đề xuất cho tới khi duyệt. Không card nào là bảng giá, drop table, stat combat hay asset brief.

**Nguồn chuẩn:** [thiết kế item](../story/ITEM_NARRATIVE_DESIGN.md), [Cảng Hắc Thuế](../maps/black-tax-port.md), [inventory/loadout](../systems/inventory-and-loadout.md), [cast và phe](../story/CHARACTERS_AND_FACTIONS.md).

## 1. Cách đọc bộ card

Mỗi dòng đánh số là **một item card**. Card nhặt nhanh trên mobile chỉ ưu tiên: `silhouette/tên → footprint → công dụng hoặc giá ước lượng → claim → rarity → một dòng lore`. "Giá trị" bên dưới là tương quan (gọn/cồng kềnh, tổng/ô), không có giá tiền hoặc tỷ lệ rơi.

| Nhãn | Nghĩa |
|---|---|
| **Lớp thẩm định** | Trắng → Xanh lá → Xanh dương → Tím → Vàng → Đỏ; nói về provenance, nguy hiểm, pháp lý và độ được thẩm định. Nó không hứa sát thương hay giá trị/ô cao hơn. |
| **Niêm phong** | `Có` nghĩa là item được phép đặt vào Hộp Công Chứng nếu footprint vừa; không biến chết thành extract. `Không` nghĩa là không thể bảo hiểm bằng Hộp. Tất cả item phải theo flow placement an toàn của inventory spec. |
| **Dự phòng** | Gear đang trang bị không chiếm lưới. Khi nhặt/chưa trang bị, gear chiếm footprint ghi trên card. Đổi gear phải trả mọi món bị thay vào lưới hợp lệ, không tự thả/xóa đồ. |
| **Claim** | Hiển thị icon/tên phe riêng với màu rarity. Claim nói ai quan tâm/đòi quyền, không tự là lệnh tịch thu hoặc route gate. |
| **Outcome** | Chỉ xảy ra sau extract, sell hoặc turn-in hợp lệ. Side/local outcome không mở map chính; Story evidence vào Archive và không thể bán/farm. |
| **Xếp chồng** | Card ghi `xếp chồng được` khi item thuộc nhóm đó; stack cap là thông số final ngoài phạm vi task này. |

### Phân bố có chủ đích

| Nhóm | Card | Lựa chọn người chơi phải thấy |
|---|---:|---|
| Story/Local evidence và tài sản tranh chấp | 10 | Safebox, proof nhỏ so với thuốc/valuables, và trách nhiệm claim. |
| Salvage/tài sản có chủ | 6 | Đồ gọn, claim và provenance cạnh tranh với tổng giá trị cargo. |
| Tool/utility | 4 | Chuẩn bị/route phụ cục bộ thay vì chỉ bán mọi thứ. |
| Gear/ammo | 4 | Chọn slot/build, footprint dự phòng và không ép một vũ khí để qua map. |

## 2. Story Contract và Local Story — 10 card

| # | Item / silhouette đọc nhanh | Nguồn hợp lý | Inventory: footprint · lớp · niêm phong | Claim | Công dụng gameplay | Một dòng narrative | Outcome khi extract / turn-in |
|---:|---|---|---|---|---|---|---|
| 01 | **Manifest Hàng Hóa R-17** — dispatch nhỏ, sợi chỉ đỏ cháy sém | Bàn dispatch A; bản routing cấp thấp của Hắc Thuế. | `1x1` · Xanh lá · **Có** · không xếp chồng | Hắc Thuế; Viện Công Chứng theo dõi mã tuyến | Evidence Contract 1; đặt ba lô hoặc Hộp để mang về A. | “Mã tuyến còn thật, chỉ người ký đã biến mất khỏi bản sao.” | Extract giữ giấy phép và mở lead/Contract 2. Chết trước extract: `unrecovered` tại bàn A hoặc túi người đưa tin. **Không** là bằng chứng pháp lý cuối, không bán. |
| 02 | **Chùm Khóa K-7** — vòng chìa ba răng, dây niêm màu đồng | Booth kiểm tra B hoặc runner route C theo briefing Contract 2. | `1x1` · Xanh lá · **Có** · không xếp chồng | Hắc Thuế / kho K-7 | Evidence Contract 2; xác định breach route vào E. | “Ba chìa, một kho; răng thứ ba mới bị mài sau ngày bản án.” | Extract mở Contract 3/breach route theo map brief. Chết: `unrecovered` cùng route logic. Không bán, không mở Lò Rèn. |
| 03 | **Counterseal R-17** — ấn đồng hai mặt, mép có vết cạy | Kho Hải Quan Niêm Phong E, dưới quyền Hắc Thuế. | `1x1` · Xanh dương · **Có** · không xếp chồng | Hắc Thuế muốn thu hồi; Viện Công Chứng có lợi ích pháp lý | Nửa thứ nhất của evidence Contract 3; cạnh tranh ô Hộp với thuốc/valuable. | “Dấu phản niêm xác nhận một bàn tay đã đóng lại thứ tòa nói chưa từng mở.” | Chỉ cùng Sổ Nợ Gốc R-17 extract mới tạo Bundle Archive. Chết: `unrecovered` tại vị trí recovery logic; không bán/không tự lật án. |
| 04 | **Sổ Nợ Gốc R-17** — sổ bìa dầu, gáy kẹp đồng, hai trang rộng | Vault/kho niêm E; bản gốc bị giấu để chuỗi custody không bị kiểm tra. | `1x2` · Xanh dương · **Có** · không xếp chồng | Hắc Thuế; Viện Công Chứng tranh quyền lưu giữ | Nửa thứ hai Contract 3; chứa manifest gốc, custody chain và mã phân bổ Ward Engine. | “Các cột nợ giữ nguyên, riêng ngày kết tội được viết sau mực niêm.” | Cùng Counterseal extract thành **Bộ Phản Niêm R-17** trong Archive; mở contract hợp pháp tới Lò Rèn. Chết: `unrecovered`; không bán. |
| 05 | **Phiếu Bốc Dỡ Không Tên** — thẻ ca ẩm nước, ô tên bị cạo trống | B hoặc D; người bốc vác Bến Không Tên giữ/đánh rơi khi tránh khám thuế. | `1x1` · Xanh lá · **Có** · không xếp chồng | Nhóm bốc vác; Hắc Thuế phủ nhận claim | Beat 1 Local Story; proof gọn mở lựa chọn về hàng cứu trợ. | “Có giờ công, có lương thiếu, chỉ không còn ai được phép nhận.” | Extract mở Beat 2 Bến Không Tên. Chết: local recovery đặt lại hợp lý; không gate Counterseal hay map 2. |
| 06 | **Dấu Lương** — thẻ đồng dập nửa tên tổ đội | Cache B/D, nơi một lô cứu trợ bị đổi nhãn. | `1x1` · Xanh lá · **Có** · không xếp chồng | Nhóm bốc vác; Hắc Thuế có claim đối nghịch | Proof nhỏ của Beat 2, cạnh tranh trực tiếp với Hòm Thuốc. | “Một mặt gọi là tiền công, mặt kia gọi là hàng tịch thu.” | Turn-in sau extract hỗ trợ `LOCAL_RESOLVED`: claim của bốc vác có cơ sở, hub có điểm đóng gói. Không thay story evidence. |
| 07 | **Hòm Thuốc** — thùng gỗ niêm sáp xanh, quai vải nặng | D; hàng cứu trợ bị giam trong lồng kho nổi. | `2x3` · Xanh lá · **Không** · container không mở/nested | Dân bến / Hắc Thuế tranh claim | Cargo Local Story; cứu trợ bulky đối trọng Dấu Lương gọn. | “Tên thuốc bị gạch đi để thùng hàng có thể bị gọi là tài sản.” | Turn-in sau extract đưa thuốc tới dân, tạo `LOCAL_COMPROMISED` nếu claim còn treo; có Recovery Contract/lời thoại khác, không gate main story. |
| 08 | **Khiên Canh Kho Số Bảy** — khiên nhẹ có móc chìa, lỗ khoan từ mặt trong | D/hatch kho phụ; di vật đội canh bị khóa trong kho. | `2x2` khi chưa trang bị · Tím · **Không** · tay phụ khi equip | Cựu lính hải quan Kho Số Bảy; Hắc Thuế có thể đòi lại | Gear khiên/guard; cũng là vật đối chiếu dấu kho side-story. | “Móc chìa khóa vẫn hướng vào trong, nơi người cầm nó đã không ra được.” | Extract mở dialogue, bounty guard hoặc ưu đãi gear khiên cục bộ; không bắt buộc build khiên hay Contract 3. |
| 09 | **Rương Di Sản** — rương gỗ đỏ 3x3, khóa gia đình bị cưa dở | D/cargo route; tài sản một gia đình người tị nạn bị bỏ lại khi kiểm hóa. | `3x3` · Vàng · **Không** · container không mở/nested | Gia đình người tị nạn; Hắc Thuế ghi là tịch thu | Cargo giá trị tổng cao nhưng hiệu suất ô thấp; đối trọng Giấy Chủ Quyền. | “Nặng vì gỗ, nặng hơn vì mọi thứ gia đình chưa dám khai tên.” | Extract tạo decor/vendor/claim reaction cục bộ nếu gia đình còn tìm; không xóa content hay đổi cổng truyện. Sau Act III, Archive có thể ghi nhận nhánh đã chọn. |
| 10 | **Giấy Chủ Quyền** — tờ deed gấp tư, dấu nhà đã lấm nước | Cùng side-story Di sản người tị nạn, ở route đã báo. | `1x1` · Vàng · **Có** · không xếp chồng | Gia đình người tị nạn; Viện/Hắc Thuế có quyền lợi pháp lý đối nghịch | Proof gọn ưu tiên giá trị/ô và an toàn safebox thay vì Rương 3x3. | “Một dòng mực đủ trả lại nhà, cũng đủ dẫn người đòi nợ đến cửa.” | Extract đổi vendor/dialogue/claim reaction của nhánh Di sản; ghi chú Archive chỉ được thêm sau khi Archive mở ở Act III. Không mở map hay loại bỏ gia đình/nhánh kia. |

### Kết quả Archive, không phải card loot thứ 25

**Bộ Phản Niêm R-17** không nằm trong 24 card vì nó không xuất hiện để nhặt/đặt lưới. Nó là record Archive được niêm phong sau khi **cả** `Counterseal R-17` và `Sổ Nợ Gốc R-17` extract thành công. Bundle xác nhận chronology fraud và mã Ward Engine, nhưng không tự hủy bản án hay thay chuỗi evidence các Act sau.

## 3. Salvage và tài sản có chủ — 6 card

| # | Item / silhouette đọc nhanh | Nguồn hợp lý | Inventory: footprint · lớp · niêm phong | Claim | Công dụng gameplay | Một dòng narrative | Outcome khi extract / sell / turn-in |
|---:|---|---|---|---|---|---|---|
| 11 | **Vải Cứu Trợ Đổi Nhãn** — kiện vải trắng bẩn, nhãn thuế chồng lên chữ cứu trợ | D và B; lô hàng bị Hắc Thuế đổi nhãn. | `2x2` · Trắng · **Không** · không nested | Dân bến / Hắc Thuế | Salvage bulky: tổng giá trị vừa, hiệu suất ô thấp hơn valuables gọn; có thể giữ cho turn-in cục bộ. | “Nhãn mới biến chăn mùa mưa thành tang vật hợp pháp.” | Sell là salvage thường; turn-in đúng nhánh chỉ đổi dialogue/claim reaction cục bộ, không thay Hòm Thuốc hoặc evidence. |
| 12 | **Đèn Phao Vỡ** — chụp kính xanh nứt, lõi đèn tắt | A/D; đèn chỉ luồng hàng từng bị tháo khỏi phao. | `1x1` · Trắng · **Có** · xếp chồng được | Không claim mạnh; Hắc Thuế từng quản lý phao | Salvage gọn, tập cho người chơi so footprint với cargo; linh kiện/đổi lấy vật tư sau này. | “Đèn tắt trước khi thuyền mất tích được ghi là đã đến.” | Extract/sell tạo hub dialogue hoặc vendor reaction nhỏ về tuyến luồng; không mở quest mới. Archive note chỉ có thể được thêm sau Act III. |
| 13 | **Móc Neo Đồng** — móc chữ J xanh rỉ, dây thừng đã mục | D/bến tàu hỏng; dụng cụ của đội bốc dỡ cũ. | `1x1` · Trắng · **Không** · xếp chồng được | Nhóm bốc vác có claim đạo đức, không phải proof pháp lý | Salvage/material gọn; nhắc công việc cảng có giá trị ngoài combat. | “Dây mục trước, người cầm nó bị xóa tên sau.” | Extract/sell có phản ứng nhỏ từ bốc vác nếu Local Story active; không thay Phiếu Bốc Dỡ. |
| 14 | **Đồng Thuế Cạo Mặt** — đồng xu méo, chân dung cũ bị đục | B/booth thuế; phí lẻ bị gom từ người qua cảng. | `1x1` · Xanh lá · **Có** · xếp chồng được | Hắc Thuế | Valuable gọn, áp lực safebox: dễ giữ nhưng claim rõ. | “Mặt cũ bị cạo để người trả thuế không nhớ ai đã hứa bảo hộ họ.” | Extract/sell là lợi nhuận/claim reaction, không đóng góp Counterseal hay legal proof. |
| 15 | **Dấu Niêm Thuế Đã Cạo Tên** — con dấu đồng, huy hiệu cũ bị chà phẳng | B/E; công cụ hải quan bị thay chủ qua nhiều lần niêm. | `1x1` · Xanh lá · **Có** · không xếp chồng | Viện Công Chứng muốn thu hồi; Hắc Thuế sợ provenance lộ | Claim/provenance gọn; có thể turn-in lấy dialogue về ngày tháng bị sửa. | “Dấu này không mở kho, nhưng ai cạo nó biết chính xác họ đang xóa điều gì.” | Extract/turn-in gợi Elder/hub reaction; Archive note chỉ thêm sau Act III. **Không** thay Counterseal, Sổ Nợ Gốc hay cổng map. |
| 16 | **Sổ Kho Ngấm Nước** — sổ kê hàng xanh lam, góc đã mốc | B/D; một registry phụ bị ném khỏi kho khi khám thuế. | `1x2` · Xanh dương · **Có** · không xếp chồng | Hắc Thuế có claim; bốc vác đọc được mã lô | Tài sản đăng ký gọn vừa; bán/turn-in/giữ làm claim reaction, không main evidence. | “Mực nhòe gần hết, trừ số pallet không ai muốn thấy quay về.” | Extract/sell/turn-in đổi claim hoặc vendor reaction; ghi chú Archive chỉ sau Act III. Không xác minh fraud và không mở Contract 3. |

## 4. Tool và utility — 4 card

| # | Item / silhouette đọc nhanh | Nguồn hợp lý | Inventory: footprint · lớp · niêm phong | Claim | Công dụng gameplay | Một dòng narrative | Outcome khi extract / sell / turn-in |
|---:|---|---|---|---|---|---|---|
| 17 | **Thuốc Nước Mặn** — chai thủy tinh quấn dây xanh, nhãn liều tay | A/D; y cụ pha cho người làm nước lạnh. | `1x1` · Xanh lá · **Có** · xếp chồng được | Không claim mạnh; bến ngoài nhận ra nhãn pha | Consumable/hồi phục, phù hợp túi đeo chéo hoặc Hộp; không quy định chỉ số hồi. | “Nước mặn cầm máu rẻ hơn thuốc chuẩn, nên người bốc vác luôn biết mùi nó.” | Dùng trong run hoặc giữ qua chết nếu đã niêm; extract có thể vào kho. Không thành evidence/local-state shortcut. |
| 18 | **Cuộn Dây Cẩu Tẩm Nhựa** — cuộn dây hổ phách, móc sắt bọc vải | A/C/D; vật tư thợ cẩu chống nước và ma sát. | `1x2` (xoay) · Xanh lá · **Không** · xếp chồng được | Thợ cẩu/bốc vác | Material/tool: dùng cho repair/utility hoặc turn-in hậu extract; không bắt buộc main route. | “Nhựa giữ dây không mục, không giữ được người bị bỏ lại trên mái.” | Sell/material use hoặc turn-in cục bộ có thể đổi reaction/utility cache sau này; không là chìa khóa shortcut main. |
| 19 | **Bộ Lọc Nước Nổi** — ống gốm lưới bạc, vòng cao su dày | D; thiết bị lọc nước dùng khi kho nổi bị ngập. | `1x2` (xoay) · Xanh lá · **Có** · không xếp chồng | Dân kho nổi / Tro Thành có quan tâm gián tiếp | Tool chuẩn bị, ưu tiên ô Hộp với thuốc/valuable; không áp đặt một hazard stat. | “Lưới lọc được bùn, không lọc được lý do nước độc chảy về kho nghèo.” | Extract giữ tool/craft material hoặc turn-in local reaction; không giải quyết Nước Triều Đen vĩnh viễn. |
| 20 | **Mỏ Lết Van Cống** — mỏ lết đen, tay cầm bọc dây vàng | D/cống dịch vụ; bỏ lại trong lần bảo trì vội. | `1x2` (xoay) · Xanh lá · **Không** · không xếp chồng | Đội bảo trì Hắc Thuế / bốc vác biết chỗ dùng | Tool mở cache/điều chỉnh hazard phụ *đã được báo trong briefing*; không thay chìa K-7 hay mở cổng main. | “Van còn chạy vì người thợ bị ghi là chi phí, không phải là người.” | Extract/sell/material use hoặc utility interaction cục bộ; shortcut D–E vẫn theo Story Contract/map state, không bị item này gate. |

## 5. Gear và ammo — 4 card

| # | Item / silhouette đọc nhanh | Nguồn hợp lý | Inventory: footprint · lớp · niêm phong | Claim | Công dụng gameplay | Một dòng narrative | Outcome khi extract / sell / turn-in |
|---:|---|---|---|---|---|---|---|
| 21 | **Kiếm Ngắn Hải Quan** — kiếm một tay, guard có rãnh đóng dấu | B/E; gear tuần tra của Hắc Thuế. | `1x2` (xoay) khi dự phòng · Xanh dương · **Không** · vũ khí chính một tay khi equip | Hắc Thuế; cựu lính nhận ra lô trang bị | Cận chiến/guard trong ngõ hẹp; thay gear theo flow atomic, không nêu damage/affix. | “Rãnh dấu thuế nằm ngay nơi tay cầm, để bạo lực và quyền sở hữu thành cùng một cử chỉ.” | Extract cho phép equip/bán/claim dialogue; không bắt buộc cho B/E hay Story Contract. |
| 22 | **Cung Thợ Cẩu** — cung gỗ ngắn, dây tháo nhanh, dấu móc neo | C/mái và kho cẩu; tool tự vệ của thợ tránh trạm thuế. | `1x3` (xoay) khi dự phòng · Xanh dương · **Không** · vũ khí chính hai tay khi equip | Thợ cẩu; Hắc Thuế kiểm soát cung quân dụng | Ranged/precision; equip khóa tay phụ theo inventory spec và cần Bao Tên tương thích trong túi/ba lô. | “Dây cung có thể tháo để qua cổng, nhưng vết chai trên tay người bắn thì không.” | Extract cho phép equip/bán/claim dialogue; không ép route C hay build cung. |
| 23 | **Bao Tên Niêm Dầu** — bao da hẹp, đầu tên bọc sáp dầu | C/B; vật tư đưa tin/thợ cẩu lén mang qua mưa. | `1x2` (xoay) · Xanh lá · **Không** · ammo item, xếp chồng được | Thợ cẩu / patrol Hắc Thuế quan tâm | Ammo/bao tên của Cung Thợ Cẩu; ưu tiên ô túi đeo chéo tương thích, nếu không chiếm ba lô. | “Dầu giữ tên khô cho đến khi người bắn phải chọn ai được cảnh báo trước.” | Extract giữ/bán như utility; không có đạn vô hạn, không thêm con số ammo hoặc đổi Contract. |
| 24 | **Mũ Bảo Hộ Bến Ngoài** — mũ sắt thấp, đèn kẹp đã tắt | A/D; đồ bảo hộ của bốc vác trước khi định mức an toàn bị cắt. | `2x2` khi chưa equip · Trắng · **Không** · slot mũ khi equip | Nhóm bốc vác; Hắc Thuế từng cấp phát | Gear head slot; một lựa chọn equip/carry, không nêu armor value. | “Vết lõm trên vành chứng minh người cầm nó từng đứng dưới hàng treo không có dây an toàn.” | Extract cho phép equip/bán/turn-in reaction; không thay thuốc, gear starter hay chặn recovery. |

## 6. Ma trận lựa chọn và guardrail content

| Tình huống | Item tạo lựa chọn | Luật không được phá |
|---|---|---|
| Hộp Công Chứng 2x2 | Manifest/Counterseal/Sổ Nợ/phiếu/dấu lương/deed/thuốc/filter/valuable gọn cạnh tranh ô. | Vật chứng niêm phong chết vẫn `unrecovered`; item khác niêm phong mới về hub. Không auto-swap/drop. |
| Giá trị theo ô | Rương 3x3, Hòm 2x3 và Vải 2x2 đổi lấy tổng giá trị/utility; deed/dấu/coin/proof 1x1–1x2 gọn hơn. | Không có giá final; item lớn không tự tốt hoặc tệ hơn mọi item nhỏ. |
| Claim | Dấu niêm, Sổ kho, đồng thuế và gear Hắc Thuế cho lore/reaction khác hàng vô chủ. | Claim icon tách rarity; claim không phải cổng chính hoặc tịch thu tự động. |
| Build | Kiếm/khiên, cung/bao tên, mũ cho slot và route opportunity khác nhau. | Không ép vũ khí/class; gear dự phòng chiếm grid; gear/cargo không vào Hộp. |
| Local story | Phiếu → Dấu Lương/Hòm Thuốc; Khiên; Rương/Deed. | Mọi outcome chỉ đổi route/reward/dialogue/state cục bộ; Counterseal + Sổ Gốc mới mở map 2. |

### Checklist khi mở rộng set này

1. Card mới có làm ít nhất một việc: lợi nhuận, chuẩn bị, claim/quyền lực hoặc sự thật không?
2. Trước khi nhặt, player mobile thấy được footprint, công dụng/giá ước lượng, claim và rarity không?
3. Nó thuộc zone nào; vì sao người/cơ quan đó lại để nó ở đó?
4. Nếu là gear/ammo/container, nó có tuân thủ slot, footprint và không-nested inventory không?
5. Nếu là evidence, chết có tạo `unrecovered`, extract có vào Archive và outcome có không soft-lock không?
6. Item có vô tình biến rarity thành damage/value-per-cell, tạo main gate mới, hay làm Local Story thành điều kiện cốt truyện không?
