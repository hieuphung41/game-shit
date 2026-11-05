# Bộ trang bị, ba lô và Hộp Công Chứng

**Trạng thái:** đặc tả UX/hệ thống v1.0 cho game offline-first 2.5D extraction. Nó định nghĩa quyết định và kết quả người chơi nhìn thấy; không quy định UI asset, thông số chiến đấu, giá hay cách lập trình.

**Nguồn chuẩn:** [Story Bible](../story/STORY_BIBLE.md), [tuyến truyện chính](../story/MAIN_STORY.md), [thiết kế item](../story/ITEM_NARRATIVE_DESIGN.md) và [Cảng Hắc Thuế](../maps/black-tax-port.md). Khi một item/map mới cần ngoại lệ, phải cập nhật đặc tả này trước, không tự phá quy tắc cũ.

## 1. Mục tiêu và bất biến

Vòng chơi là:

```text
Chọn contract + chuẩn bị loadout
    -> trả phí contract/bond đã hiển thị
    -> vào raid, loot và xếp đồ
    -> chọn niêm phong một vài món hoặc tiếp tục mạo hiểm
    -> extract để giữ thành quả
    -> bán / craft / trang bị / giao nộp / Archive tại hub
```

- **Ba lô là quyết định route, không phải thanh sức chứa.** Đồ gọn giá trị/ô cao cạnh tranh với cargo, giáp và vũ khí cồng kềnh. Cảng Hắc Thuế vì thế cho đồ nhỏ trên B/C và cargo lớn tại D.
- **Phí vào thuộc về contract**, không tính theo tổng giá bộ đồ đang mặc. Easy/Normal không khóa bởi level hoặc gear score; briefing chỉ nêu khuyến nghị/điều kiện chuẩn bị rõ ở Hard/Extreme.
- **Không có “junk loot” vô nghĩa.** Item phải có giá trị bán, chuẩn bị, claim/quyền lực hoặc sự thật; chi tiết xem [thiết kế item](../story/ITEM_NARRATIVE_DESIGN.md).
- **Chết là mất đồ không niêm phong, không phải mất campaign.** `Phù Hiệu Hồi Hương` chỉ đưa người về. `Hộp Công Chứng` có ít ô niêm phong đi cùng người; vật chứng Story Contract luôn có đường `unrecovered`/Recovery Contract để không soft-lock.
- **Không tự hủy đồ.** Khi không đặt vừa, người chơi chọn đổi, để lại, hoặc hủy thao tác; hệ thống không tự vứt/xóa món cũ để nhét món mới.

## 2. Thuật ngữ và nơi chứa

| Thuật ngữ | Ý nghĩa và điều không phải nó |
|---|---|
| **Bộ trang bị / loadout** | Đồ được chọn ở hub cho một run: slot đang mặc/cầm, ba lô, túi đeo chéo và đồ đã niêm phong. Không phải giá vé vào ải. |
| **Lưới ba lô** | Các ô vật lý chứa loot, dự phòng và đồ vừa tháo. Nó là nơi quyết định chính trong raid. |
| **Túi đeo chéo** | Không gian truy cập nhanh cho nhóm item tiện ích được phép; không phải ba lô thứ hai và không chứa cargo/gear/Story evidence. |
| **Hộp Công Chứng** | Lưới niêm phong rất nhỏ, khởi đầu 2x2. Chỉ item có nhãn `Niêm phong được` mới vào được. |
| **Kho hub** | Nơi quản lý đồ trước/sau run. Nó không được mở trong raid và không đồng nghĩa với Hộp Công Chứng. |
| **Archive** | Kho hồ sơ không chiếm lưới: chỉ nhận vật chứng đã extract; không thể bán, mang lại raid hoặc farm lặp. |
| **Footprint / kích thước ô** | Hình chữ nhật vật lý một item chiếm trong lưới, ví dụ 1x1, 1x2, 2x2, 2x3, 3x3. |
| **Claim / tài sản có chủ** | Phe/NPC có quyền lợi đối với item. Claim hiển thị bằng biểu tượng riêng với rarity, không phải một lớp rarity mới. |

## 3. Chuẩn bị loadout ở hub

### 3.1 Các slot

| Nhóm | Slot | Quy tắc đặt đồ |
|---|---|---|
| Giáp | Mũ, áo giáp, giáp tay, giáp chân | Chỉ trang bị đúng loại slot. Món đang mặc không chiếm lưới ba lô. |
| Chiến đấu | Vũ khí chính, tay phụ | Vũ khí chính nhận kiếm, liềm, giáo, cung, súng hoặc loại base weapon phù hợp; tay phụ nhận khiên/công cụ hợp lệ. Vũ khí hai tay khóa tay phụ và UI nói rõ trước khi xác nhận. |
| Chứa đồ | Ba lô, túi đeo chéo | Ba lô tạo lưới loot; túi đeo chéo tạo các ô truy cập nhanh bị giới hạn loại item. Không thể để trống ba lô nếu contract yêu cầu mang loot; contract starter luôn có phương án ba lô/recovery cơ bản. |
| Niêm phong | Hộp Công Chứng | Lưới riêng, khởi đầu 2x2; không phải slot giáp và không tăng theo rarity. |

`Cung` chiếm vũ khí chính khi đã trang bị. Mũi tên/bao tên là item tiện ích: ưu tiên các ô tương thích trong túi đeo chéo, nếu không thì phải chiếm footprint trong ba lô. Vì vậy cung không có đạn vô hạn và vẫn chịu áp lực không gian. Khi chưa trang bị, cung, súng, khiên, kiếm, liềm, giáo và giáp là loot vật lý theo footprint của chính chúng.

Ba lô và túi đeo chéo chỉ được thay ở hub trong MVP. Một chiếc mới nhặt được là loot để mang về; không được mặc giữa run nhằm tránh resize lưới làm mất đồ hoặc bypass sức chứa.

### 3.2 Những gì được mang vào

Người chơi có thể kéo từ kho hub vào slot tương thích, ba lô, túi đeo chéo hoặc Hộp Công Chứng. Đồ tiêu hao, vật liệu, gear và vũ khí dự phòng đều phải có vị trí vật lý hợp lệ; không có một “danh sách đồ mang theo” vô hình.

Không được mang vào:

- vật chứng đã niêm phong tại Archive;
- vật chứng đang `unrecovered` trong contract (chưa thuộc sở hữu ở hub);
- một container chứa item khác, ba lô/túi đeo chéo khác hoặc món không có nhãn `Niêm phong được` vào Hộp Công Chứng;
- item có claim/contract rule cấm rời hub, nếu một map sau này định nghĩa rõ điều đó.

Màn hình chuẩn bị luôn cho thấy: mục tiêu contract một câu, map state, extraction khả dụng/điều kiện, phí/bond, rủi ro mất đồ, lưới còn trống và cảnh báo tương thích. Người chơi có thể vào với build tối giản hoặc không có vũ khí sau một xác nhận “vào không vũ khí”; không bị từ chối vì cấp/gear score. Contract chỉ chặn nút vào khi chưa có giấy phép/bond, thiếu slot chứa đồ bắt buộc, hoặc có placement không hợp lệ.

### 3.3 Xác nhận, thay thế và loadout thiếu đồ

- Mọi thay đổi vũ khí là **atomic**: preview liệt kê mọi món bị thay hoặc bị khóa. Trang bị vũ khí hai tay từ kiếm+khiên phải có chỗ cho cả kiếm chính lẫn khiên tay phụ trước khi xác nhận; chuyển từ hai tay sang một tay chỉ mở tay phụ trống, không tự điền món vào đó. Nếu thiếu chỗ, player chỉ có thể hủy hoặc tự chọn từng món để chuyển/bỏ lại có xác nhận.
- `Trang bị` chỉ thay món đang mặc khi *mọi* món bị thay có chỗ hợp lệ ở kho hub trước raid. Nếu không có chỗ, UI báo chính xác món nào cần chuyển; không hoán đổi mơ hồ hoặc giữ một tổ hợp tay trái/tay phải trái luật.
- `Thay loadout` là thao tác ở hub: chọn một preset hoặc từng món; hệ thống chỉ tự điền từ item người chơi đang sở hữu, không tự mua/sửa/craft.
- Sau chết, màn hình loadout đánh dấu từng slot **mất**, **còn giữ** hoặc **trống**. Người chơi có thể dùng món đang có, chọn recovery/starter kit mà contract cho phép, hoặc vào run với bộ tối giản. Không có vòng lặp bắt buộc phải mua lại gear để tiếp tục Main Story.

## 4. Quy tắc lưới ba lô

### 4.1 Hình dạng, footprint và xoay

- Mỗi ba lô có một lưới cố định được thấy ngay từ loadout. Ba lô khác nhau có thể đổi tổng ô và/hoặc silhouette ô mở; không được chỉ so bằng một chỉ số “capacity”.
- Mọi item lưới có footprint chữ nhật và nhãn kích thước trực tiếp: `1x1`, `1x2`, `2x2`, `2x3`, `3x3`… `1`, `2`, `4`, `6`, `9` ô là hệ quả của footprint, không phải rarity.
- Item có thể xoay 90° nếu nhãn không ghi `không xoay`, và chỉ khi hình sau xoay nằm trọn trong ô trống. UI preview viền xanh/đỏ trước khi thả.
- Không lồng container. Ba lô, túi, hộp niêm phong hay rương nhặt được không mở để nhét đồ bên trong trong raid.

Các footprint là ngôn ngữ hệ thống, không phải catalogue cuối. Kích thước/độ hiếm/giá của từng món do item card sau này quyết định.

### 4.2 Stack, swap và sort

| Hành động | Quy tắc và kết quả |
|---|---|
| **Stack** | Chỉ item có nhãn `xếp chồng` mới stack. Chúng phải cùng loại/biến thể, trạng thái và claim tương thích; stack dừng ở giới hạn ghi trên item card. Gear, vũ khí, container, vật chứng độc nhất và item có trạng thái riêng không stack. |
| **Di chuyển** | Chọn/giữ item, rồi chạm ô đích hoặc kéo-thả. Đích hợp lệ hiển thị trước; chạm đích lỗi không làm item biến mất. |
| **Hoán đổi** | Chỉ hiện khi lấy món đang chọn ra giúp cả hai footprint đặt hợp lệ. Preview chỉ ra món nào trở về ground/lưới; không đổi dây chuyền nhiều item trong một thao tác. |
| **Tự xếp** | Chỉ sắp lại item trong *chính lưới ba lô*, gộp stack hợp lệ và tôn trọng các món bị khóa. Không chuyển item qua túi/safebox/equipment, không vứt gì, không đổi rarity/claim. Người chơi xác nhận preview nếu sort sẽ đổi vị trí item đã chọn. |
| **Bỏ lại** | Người chơi xác nhận món cụ thể; món hiện lại như loot tại vị trí hiện tại, có nhãn rõ. Không có nút “bỏ toàn bộ”. |

Món cồng kềnh là lựa chọn, không phải phạt vô hình: giao diện luôn nhìn được giá ước lượng trên mỗi ô, tổng footprint và route/extract gần nhất trước khi người chơi thay món khác.

### 4.3 Trang bị trong raid và không đủ chỗ

Trang bị trong raid áp dụng cho vũ khí/giáp nhặt được, không áp dụng cho ba lô/túi đeo chéo trong MVP:

1. Người chơi chọn `Trang bị`; UI hiển thị **tất cả** món đang mặc sẽ bị thay hoặc bị khóa, cùng footprint cần trả về ba lô. Vũ khí hai tay thay một vũ khí một tay + khiên phải preview cả hai món; chuyển từ hai tay sang một tay chỉ giải phóng tay phụ.
2. Nếu ba lô có chỗ cho mọi món bị thay, đổi diễn ra nguyên tử và từng món cũ vào đúng ô preview.
3. Nếu không có chỗ, UI cho ba lựa chọn: hủy; tự chọn loot/gear để **bỏ lại có xác nhận**; hoặc không đổi. Sau khi đã đủ chỗ, preview lại toàn bộ rồi mới đổi. Không tự thả món cũ/mới, không giữ tổ hợp hai tay + tay phụ, và không đặt tạm ngoài lưới.
4. Vũ khí nhặt/dự phòng không thể treo ngoài slot để né footprint. Khi thay vũ khí chính, mọi vũ khí/khiên bị thay đi vào ba lô theo đúng quy tắc trên.

Item trên ground chỉ được bỏ lại bởi hành động rõ ràng. Khi người chơi rời xa/không extract, luật mất đồ bình thường quyết định số phận nó; hệ thống không hứa khôi phục gear đã chủ động bỏ.

## 5. Túi đeo chéo, Hộp Công Chứng và vật chứng

### 5.1 Túi đeo chéo: tốc độ, không phải sức chứa

Túi đeo chéo có các ô truy cập nhanh loại-lọc cho thuốc, tool, key và ammo/bao tên tương thích. Nó:

- không nhận weapon, giáp, cargo, container, item bán thông thường hoặc Story evidence;
- không mở rộng bởi auto-sort ba lô và không nhận item tự động khi ba lô đầy;
- vẫn là đồ mang theo không niêm phong: item trong đó mất khi chết nếu chưa extract;
- cho phép dùng item từ quick-access mà không cần mở lưới, nhưng không thay đổi số liệu hồi phục/đạn trong đặc tả này.

### 5.2 Hộp Công Chứng: ít ô, một quyết định lớn

Hộp Công Chứng bắt đầu là 2x2. Người chơi có thể đưa vào/rút ra item trong hub và lúc raid, nhưng luôn thấy nhãn `Niêm phong được`, footprint và cảnh báo rủi ro.

Trong MVP, nhóm item có thể niêm phong gồm vật chứng, thuốc/tool nhỏ và valuables gọn có nhãn phù hợp. Gear, weapon, ba lô/túi, cargo lớn và container mặc định không niêm phong được. Item catalog có thể thêm ngoại lệ có lý do, nhưng không được biến Hộp thành bảo hiểm toàn bộ kit.

Khi chết, item **không phải vật chứng Story Contract** trong Hộp Công Chứng trở lại kho hub cùng người chơi. Khi extract, chúng đi vào kho hub như mọi item khác. Hộp không tự bán, tự craft hay tự chuyển đồ vào Archive.

| Thao tác Hộp Công Chứng | Kết quả an toàn |
|---|---|
| Đưa item vào | Chỉ hoàn tất khi item có nhãn `Niêm phong được` và footprint nằm trọn trong ô trống; preview hiển thị trước. Sai loại/không xoay vừa/hộp đầy nêu lý do, item vẫn ở nơi nguồn. |
| Rút item ra | Chỉ hoàn tất khi lưới đích hợp lệ: kho hub ở hub, hoặc ba lô trong raid. Ba lô đầy/sai footprint giữ item trong Hộp; player có thể hủy, tự sắp lại, hoặc chọn item khác để bỏ lại có xác nhận. |
| Muốn nhường chỗ khi hộp đầy | Player tự rút món cũ vào đích hợp lệ rồi mới đưa món mới vào. Không auto-swap, auto-drop, hay đẩy item Hộp sang ba lô/ground khi chưa có chỗ. |

### 5.3 Ngoại lệ rõ ràng cho vật chứng Story Contract

Mọi vật chứng có footprint nhỏ, có thể đặt trong Hộp Công Chứng để tạo lựa chọn bảo vệ thật trong run, nhưng **niêm phong không thay extract bằng một teleport miễn phí**:

| Trạng thái | Kết quả player thấy |
|---|---|
| Nhặt được, chưa extract | Vật chứng chiếm ô ba lô hoặc safebox; contract hiển thị `chưa xác thực` và mục tiêu extract còn nguyên. |
| Đặt trong Hộp Công Chứng | Tooltip nói rõ: `Bảo đảm không mất vĩnh viễn; chưa giao nộp/không hoàn thành contract nếu chết.` Người chơi vẫn phải rút đúng điểm. |
| Chết trước extract, kể cả khi đã niêm phong | Contract trở về `unrecovered`; vật chứng không thành loot ở hub và run kế tiếp chỉ rõ điểm hồi phục logic (xác người mang, bàn niêm, kho bị gác…). Không có soft-lock, không có tiến triển free. |
| Extract thành công | Hệ thống xác nhận chuỗi bàn giao của contract, chuyển item vào Archive, cập nhật hub/contract và khóa bán/mang lại raid/farm lặp. |

Đây là luật chung. Ví dụ ở Cảng Hắc Thuế, `Manifest Hàng Hóa R-17` chỉ là lead; chỉ `Counterseal R-17` cùng `Sổ Nợ Gốc R-17` extract thành công mới thành **Bộ Phản Niêm R-17**. Không tooltip nào được gọi Manifest là bằng chứng pháp lý cuối.

## 6. Nhặt loot, đọc item và quyết định giá trị

### 6.1 Card nhặt nhanh

Trước khi quyết định lấy một item, card gọn hiển thị theo thứ tự:

```text
silhouette + tên
footprint / ô còn trống -> giá ước lượng hoặc công dụng -> biểu tượng claim -> rarity -> 1 câu lore
```

- Rarity: Trắng (1), Xanh lá (2), Xanh dương (3), Tím (4), Vàng (5), Đỏ (6). Đây là **lớp thẩm định** về nguồn gốc, nguy hiểm, tính hợp pháp và giá trị; không hứa sát thương hoặc lợi nhuận/ô cao hơn.
- Claim dùng icon/tên phe riêng (Viện Công Chứng, Nhà liên quan, Liên Minh Thu Hồi, Old Wardens…), không dùng màu rarity thay thế. Card phải nói item có thể bán, craft, equip, turn-in hay là evidence.
- Nếu item có giá trị ước lượng, preview thay thế hiển thị cả giá tổng và giá/ô; item không định giá thì nêu công dụng/điều kiện thay vì giả vờ có giá.
- Inspect mở 1-2 câu provenance/lore. Phần dài chỉ ở Archive/hub, không chặn quyết định loot.

### 6.2 Các outcome khi nhặt

| Tình huống | Hành động hợp lệ | Điều không được xảy ra |
|---|---|---|
| Có ô hợp lệ | `Nhặt và xếp` đặt vào vị trí preview; stack khi hợp lệ. | Không tự chuyển vào safebox/túi đeo chéo. |
| Có chỗ sau xoay/sort | Preview dùng xoay hoặc tự xếp; người chơi xác nhận. | Không tự đảo ba lô ngay khi một enemy đang gây áp lực. |
| Không đủ chỗ | Mở so sánh `món mới ↔ món muốn bỏ`, giữ món cũ, hoặc bỏ qua. | Không tự xóa/auto-drop item cũ; không nén cargo thành slot 1 ô. |
| Evidence/cargo quan trọng | Card nhắc footprint, safebox đủ/không đủ và extract gần nhất; người chơi vẫn tự chọn. | Không tự đưa evidence vào Archive trước extract. |

## 7. Extract, chết, recovery và hậu quả

| Kết quả run | Đồ và campaign xử lý thế nào |
|---|---|
| **Extract thành công** | Đồ đang trang bị vẫn thuộc loadout/kho hub; loot từ ba lô/túi/Hộp Công Chứng được ghi nhận vào kho hub để bán, craft, equip hoặc turn-in. Vật chứng đã đủ điều kiện chuyển Archive và cập nhật contract/hub. Không tự bán bất cứ gì. |
| **Chết / Phù Hiệu Hồi Hương kích hoạt** | Người chơi về hub. Chỉ item niêm phong không-phải-evidence theo cùng; mọi gear trang bị, ba lô, túi đeo chéo và loot không niêm phong là tài sản bỏ lại. Summary chia rõ: `đã giữ`, `đã mất`, `vật chứng sẽ recovery`; không gọi đây là extract. |
| **Thoát/hủy run theo contract** | Dùng cùng summary mất/giữ như luật contract đã brief; không được là đường bỏ raid để nhân đôi loot hoặc né outcome. Chi tiết contract sẽ được định nghĩa từng map. |
| **Story evidence chưa extract** | State `unrecovered`; run sau/recovery contract đặt nó tại vị trí logic, có thể guard/map pressure cao hơn, nhưng không mất vĩnh viễn. |
| **Local Story/incident thất bại** | Có thể mở Recovery Contract, đổi local state hoặc reward; không xóa core map/Main Story. Gear không niêm phong vẫn không tự hồi. |

Màn hình hậu quả luôn có hành động kế tiếp hiểu được: `chuẩn bị lại`, `xem Recovery Contract`, hoặc `xem Archive/hub change`. Basic work contract và starter/recovery loadout phải còn tồn tại để một chuỗi chết không chặn campaign.

## 8. Quy tắc trải nghiệm mobile

- **Một quyết định trong một màn nhìn:** khi nhặt, người chơi thấy item mới, footprint, ô phù hợp, món bị thay (nếu có), giá/ô hoặc công dụng và claim; không bắt đọc lore dài để tránh sai.
- **Không đòi drag chính xác:** chạm chọn + chạm ô đích là thao tác đầy đủ; kéo-thả là lựa chọn nhanh. Nút xoay, sort, bỏ lại và hủy luôn nằm cố định, có label/icon khác nhau.
- **Không dùng màu làm dữ liệu duy nhất:** rarity có nhãn/bậc; claim có icon/họa tiết/tên; ô không vừa báo silhouette + lý do (`sai loại`, `thiếu ô`, `không niêm phong được`) thay vì chỉ viền đỏ.
- **Quản lý sâu có lúc an toàn:** direct pickup không cần mở lưới lớn. Lưới đầy đủ cảnh báo khi đang có đe dọa; sau gate có 15-30 giây vùng yên để heal/xếp đồ theo map brief. Overlay không che hẳn mini-objective, low-health hay telegraph nguy hiểm.
- **Không có thao tác phá run một chạm:** drop, rút item niêm phong, thay gear buộc bỏ lại và vào không vũ khí đều cần preview/xác nhận ngắn; sort/rotate/move có thể hủy trước khi chốt.
- **Mục tiêu truyện vẫn một câu:** inventory chỉ bổ sung nhắc `extract để xác thực`, không thay briefing/map marker bằng log nhiều trang.

## 9. Current vertical-slice cut

Current vertical slice chứng minh lựa chọn loot/extract ở Cảng Hắc Thuế, không phải hoàn thiện kho đồ của live-service hay full map Act I. Phạm vi map/contract ưu tiên theo [vertical slice](../vertical-slice.md): Easy, Contract 1, A/B/D và extract A.

**Có trong current vertical slice**

- Màn chuẩn bị contract, mũ/áo/giáp tay/giáp chân, vũ khí chính, tay phụ, một ba lô starter, một túi đeo chéo loại-lọc và Hộp Công Chứng 2x2.
- Footprint 1, 2 và 4 ô trong lát cắt; xoay item phù hợp; stack có nhãn; move, preview, swap an toàn, sort ba lô và drop có xác nhận.
- Vũ khí trang bị không chiếm grid; vũ khí/giáp nhặt chiếm footprint; bow + ammo/bao tên chịu giới hạn túi/ba lô.
- Pickup card có footprint, giá ước lượng/công dụng, rarity, claim và một dòng lore; loot nhỏ trên route B, cargo 2x2 tại D và `Manifest Hàng Hóa R-17` tại A.
- Extract A, death summary, safebox giữ item hợp lệ không-phải-evidence, Manifest `unrecovered` và một Recovery Contract rõ ràng. Contract 2/3 không playable và không dùng Counterseal placeholder.

**Không có trong current vertical slice**

- Giá bán, phí/bond, drop rate, stack cap, durability, weight, damage/armour/ammo number, catalogue đầy đủ hoặc item 9 ô;
- đổi ba lô/túi trong raid, bảo hiểm gear toàn bộ, tự mua/thay đồ, market/multiplayer/trade;
- level gate, gear-score gate ở Easy/Normal, seasonal inventory, cloud persistence hay kiến trúc/UI asset kỹ thuật;
- Normal, Hard/Extreme; route C/E playable, thuyền D, Contract 2/3, Counterseal/Sổ Nợ Gốc, elite/boss, incident/local content; toàn bộ evidence chain, toàn bộ item/micro-arc hoặc bất kỳ retcon lore nào.

## 10. Checklist cho item, map và UI sau này

1. Item có footprint, stack/rotate/seal/equip/claim rule hiển thị được trước khi nhặt không?
2. Nó có tạo một trade-off về giá/ô, công dụng, route hoặc risk-to-extract thay vì chỉ là màu cao hơn không?
3. Nếu là gear, swap trong raid có nơi hợp lệ cho món cũ không? Nếu là container, có đang tạo nested inventory không?
4. Nếu là evidence, chết có về `unrecovered`, extract có vào Archive và contract có tránh soft-lock không?
5. Túi đeo chéo/Hộp Công Chứng có đang thay thế sai ba lô hoặc xóa rủi ro chết không?
6. Người chơi mobile có thể hiểu lỗi placement, hủy thao tác và so sánh hai lựa chọn trong vài giây không?
7. Nội dung mới có giữ nguyên rule: rarity khác claim, màu cao không tự đồng nghĩa tốt hơn, và map mới mở bằng evidence/permit chứ không bằng level không?
