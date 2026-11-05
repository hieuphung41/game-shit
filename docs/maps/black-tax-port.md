# Cảng Hắc Thuế - Map Brief v1.0

**Loại:** map đầu tiên của campaign, Act I; vùng extraction PvE 2.5D chơi lại được.
**Trạng thái:** brief thiết kế đã qua review; tên NPC, thông số, tỷ lệ drop, kích thước tile và asset cụ thể vẫn là `proposed`.
**Nguồn canon:** [MAIN_STORY.md](../story/MAIN_STORY.md), [MAP_LOCAL_STORIES_AND_EVENTS.md](../story/MAP_LOCAL_STORIES_AND_EVENTS.md), [ITEM_NARRATIVE_DESIGN.md](../story/ITEM_NARRATIVE_DESIGN.md).

## 1. Mục đích của map

Nhân vật chính đến Cảng Hắc Thuế vì bản đồ cháy của người thầy và mã vận chuyển trên khoản nợ chỉ vào cảng này. Nhà Hắc Thuế đang giữ bản gốc sổ nợ trong kho hải quan niêm phong, vì **counterseal** trên đó có thể phá quyền thu nợ của họ.

Người chơi không đến đây để dọn sạch quái hay cứu cả thế giới. Họ cần giữ giấy phép hành nghề, lần dấu một lô hàng, đột nhập kho giữa một đợt chuyển hàng, rồi **extract được vật chứng**.

### Player fantasy

Làm một Người Thu Hồi nghèo nhưng lanh lợi tại cảng ngập nước: luồn qua chợ thuế, leo mái dây cẩu hoặc lội kho nổi để mang một món đáng giá hơn về nhà trước khi phe giữ cảng khép lối rút.

### Map dạy gì?

| Cơ chế | Bài học tại Cảng Hắc Thuế |
|---|---|
| Extraction | Không extract thì loot và bằng chứng không có giá trị; lối rút là quyết định gameplay |
| Ba lô/grid | Đồ nhỏ giá trị/ô cao trên mái cạnh tranh với hàng cứu trợ/cargo 4-9 ô trong kho |
| Safebox | 2x2 ô có thể bảo đảm story item, nhưng phải đổi chỗ với thuốc hoặc loot quý khác |
| Route | Lối cân bằng, lối nhanh/phơi bày và lối hàng cồng kềnh đều có lý do chọn |
| Phe phái | Thuế, hàng tịch thu, quyền sở hữu và patrol cho thấy Nhà Hắc Thuế kiểm soát cảng thế nào |
| Chết/mất đồ | Phù Hiệu Hồi Hương cứu người, còn Hộp Công Chứng chỉ cứu đồ đã niêm phong |

## 2. Điều kiện vào và nhịp một run

- **Entry fiction:** Starter/Recovery/Story Contract của Người Thu Hồi, kèm phí giấy phép hoặc bond tùy contract. Không dùng giá loadout làm phí vào.
- **Session target:** 8-15 phút; người chơi không bị yêu cầu dọn toàn map.
- **Thẩm định:** Easy/Normal không khóa vì gear score. Hard/Extreme có khuyến nghị hoặc điều kiện chuẩn bị rõ trong briefing.
- **Briefing một màn hình:** đi đâu, lấy gì, lý do cần ngay, map state, điểm extract tiềm năng và điều kiện rút nếu có.
- **Nhịp:** entry an toàn → chọn route → encounter/loot → cân nhắc ba lô/safebox → extract hoặc tham thêm.

## 3. Địa lý lõi cố định

Map là một vòng bán mở; geography, landmark, shortcut và vị trí story evidence không random. Mỗi địa điểm chỉ có tối đa hai tầng cao độ đọc được trên camera chéo cố định.

```text
 [A. Bến Ngoài / spawn / extract cầu tàu]
                 |
                 | lane an toàn
                 v
 [B. Chợ Ngập] == shortcut 1 == [C. Mái Nhà & Cầu Dây]
       |                                  |
       |                                  |
 [D. Kho Nổi] == shortcut 2 == [E. Kho Hải Quan Niêm Phong]
       |                                  |
 [extract thuyền]                    [extract cổng thuế]
```

### Khu vực

| Khu | Vai trò truyện | Gameplay identity | Loot/weapon opportunity |
|---|---|---|---|
| A. Bến Ngoài | Cửa cảng còn dùng được; bàn manifest, dân bốc vác và một phần hàng hợp pháp | spawn an toàn, tutorial, khoảng yên để xếp đồ | vật tư trắng/xanh, thuốc, dây thừng, chìa khóa; extract dễ |
| B. Chợ Ngập | Thuế được thu trực tiếp, hàng cứu trợ bị đổi nhãn thành tài sản tịch thu | đường cân bằng, ngõ hẹp, cover vừa; kiếm ngắn/khiên nhẹ mạnh | thuốc, key, đồ 1-2 ô, dấu thuế và đồ dân sự |
| C. Mái Nhà & Cầu Dây | tuyến thợ cẩu và người đưa tin né trạm thuế | route nhanh, cao, ít cover, địch tầm xa; cung có vị trí tốt | gem, proof nhỏ, linh kiện/đồ 1-2 ô giá trị/ô cao |
| D. Kho Nổi | kho hàng trôi, xác thuyền và khu bốc vác bị bỏ rơi | nước, phục kích, đường hẹp và nhiều cargo; rút bằng thuyền gần | hàng cứu trợ/cargo 4-9 ô, Khiên Canh Kho Số Bảy, medicine nước mặn |
| E. Kho Hải Quan Niêm Phong | nơi Nhà Hắc Thuế giữ bằng chứng, hàng tịch thu và sổ nợ gốc | gate encounter/elite tùy chọn; pressure cao nhất, vault có chủ | counterseal, sổ nợ, két thuế, tài sản claim, gear hải quan |

### Ba route cố ý

| Route | Chuỗi khu | Phần thưởng | Giá phải trả |
|---|---|---|---|
| **Công lộ Thuế** | A → B → E | thuốc/key, cover, loot vừa, dễ học | patrol ổn định, ngõ hẹp, ít đường thoát khi bị dồn |
| **Mái Dây Cẩu** | A/B → thang ngoài cần cẩu → C → E | approach ngắn, loot nhỏ đắt, góc bắn cung | ít cover, rơi xuống route dưới tốn thời gian, địch bắn xa rõ telegraph |
| **Đường Kho Nổi** | A → B → D → E hoặc extract D | cargo lớn, local story, thuyền rút gần | nước/bẫy, phục kích, hàng nặng làm ba lô kém linh hoạt |

### Shortcut bền vững

1. **Cầu cẩu Chợ–Mái:** nối B và C. Lần đầu, người chơi đi từ A/B lên C bằng **thang ngoài cần cẩu** hẹp, có biển chỉ dẫn và một skirmish đọc được; từ phía C, họ mở tay quay để hạ cầu cẩu. Từ run sau, cầu là bypass bền vững; Hard/Extreme có thể có trạm thuế/địch gác, nhưng cầu và thang không biến mất hoặc đổi vị trí.
2. **Cống dịch vụ Kho Nổi–Kho Hải quan:** nối D và E. Sau khi mở bánh van lần đầu, đây là shortcut cố định; map state có thể biến nó thành lane ngập/hazard hoặc có cổng kiểm tra, không random topology.

### Điểm extract tiềm năng

| Điểm | Điều kiện | Bản sắc |
|---|---|---|
| A. Cầu tàu Bến Ngoài | luôn mở ở Easy; trạng thái hiển thị trước run ở độ khó khác | an toàn nhất, xa loot sâu nhất |
| D. Thuyền hàng bỏ neo | chỉ mở khi thuyền/tuyến nước hoạt động; điều kiện báo trước | hợp Đường Kho Nổi, gần cargo cồng kềnh |
| E. Cổng thuế | cần cổng hoạt động hoặc một điều kiện contract rõ | rút nhanh sau vault, áp lực patrol/elite cao |

Khi gọi extract, người chơi giữ khu 15-25 giây. Địch chỉ tiếp cận qua lane có âm thanh/ánh sáng/telegraph; không spawn sau lưng.

## 4. Story Contract của Act I

Story evidence chỉ được ghi nhận sau khi extract. Tất cả item bên dưới có footprint nhỏ, đặt được trong Hộp Công Chứng 2x2 và không mất vĩnh viễn: nếu chết, contract trở về `unrecovered`; run sau đặt evidence ở vị trí logic có guard cao hơn, không tạo soft-lock.

**Chuỗi bằng chứng Act I:** `Manifest Hàng Hóa R-17` của Contract 1 chỉ là **bản dispatch cấp thấp**; nó chứng minh mã tuyến có thật và dẫn tới Kho K-7, nhưng không có hiệu lực kháng án. Bằng chứng cuối hiển thị tại hub là **Bộ Phản Niêm R-17**, gồm `Counterseal R-17` và `Sổ Nợ Gốc R-17`. Sổ gốc chứa **manifest gốc, chuỗi bàn giao/custody chain và mã phân bổ Ward Engine**; chỉ khi extract đủ cả hai phần thì chronology fraud mới được chứng minh hợp pháp.

| Contract | Briefing cho người chơi | Objective và footprint | Route/loot decision | Thành công / chết | Hậu quả hub & campaign |
|---|---|---|---|---|---|
| 1. **Giữ giấy phép** | “Mang bản dispatch R-17 ra bến. Không có nó, tuần tới ta mất quyền nhận contract.” | `Manifest Hàng Hóa R-17`, 1x1, bản dispatch cấp thấp tại bàn A | Extract thẳng qua A để giữ run an toàn, hoặc vòng một cache ở Bến Ngoài để lấy cargo/thuốc và mạo hiểm encounter đầu tiên | success: giữ giấy phép; death: manifest quay lại bàn dispatch hoặc túi người đưa tin trong A | mở Contract 2; đây chỉ là routing lead, không phải bằng chứng pháp lý cuối |
| 2. **Dấu kho** | “Mã R-17 bị dẫn vào Kho K-7. Lấy chùm khóa trước khi Hắc Thuế đổi ca gác.” | `Chùm Khóa K-7`, 1x1, nằm ở B hoặc C tùy route contract đã báo | B là route cân bằng có medicine/key; C nhanh hơn với proof nhỏ, nhưng phơi bày trước ranged guard | success: xác định lối vào/ký hiệu Kho K-7; death: chìa khóa chuyển sang túi runner hoặc booth kiểm tra trên cùng route | mở Contract 3 và breach route tới E; không mở Lò Rèn |
| 3. **Món nợ có chủ** | “Đợt chuyển hàng che tiếng đột nhập. Lấy counterseal và sổ gốc, rồi rút trước khi kho bị niêm lại.” | `Counterseal R-17`, 1x1, và `Sổ Nợ Gốc R-17`, 1x2; sổ chứa manifest gốc/custody chain/mã Ward Engine | đi qua C để lấy tốc độ/loot nhỏ, hoặc D để lấy cargo/local-story loot và có thuyền rút; evidence cạnh tranh safebox với thuốc/loot | success: hub niêm phong **Bộ Phản Niêm R-17**; death: hai phần trở lại lồng hàng/thi thể bailiff/bàn niêm ở E theo Recovery Contract | bộ chứng minh chronology fraud, mã phân bổ chỉ tới Ward Engine ở Lò Rèn Câm; mở kho chứa/cửa hàng cơ bản và contract hợp pháp tới map 2 |

**Canon guardrail:** Counterseal không thể tự hủy bản án. Viện Công Chứng vẫn giữ tòa, cổng vùng và sổ chính thức; người chơi cần chuỗi chứng cứ của các Act sau.

## 5. Local Story, side-story và incident

Các nội dung dưới đây là độc lập với Contract 3 và không bao giờ là điều kiện mở Lò Rèn Câm.

### Local Story: Bến Không Tên

**Vết thương:** hàng cứu trợ của người tị nạn bị đổi nhãn thành tài sản tịch thu. Người bốc vác không có giấy tờ bị xóa tên khỏi sổ thuyền, mất lương và không thể chứng minh đã từng tồn tại trong cảng.

| Beat | Mục tiêu/extract | Lựa chọn gameplay | Kết quả local an toàn |
|---|---|---|---|
| 1. Tìm tên | extract `Phiếu Bốc Dỡ Không Tên`, 1x1, từ B hoặc D | route B an toàn hơn; D có cargo nhưng nhiều hazard | mở Beat 2, cho người chơi biết nguồn hàng cứu trợ |
| 2. Hàng không thuộc về ai | trong một run, ưu tiên `Dấu Lương` 1x1 hoặc `Hòm Thuốc` 2x3 | proof nhỏ dễ bảo vệ; thuốc/cargo lớn mang lợi ích tức thời nhưng chiếm chỗ | `LOCAL_RESOLVED`: người bốc vác có claim và hub có điểm đóng gói; `LOCAL_COMPROMISED`: thuốc đến được dân nhưng claim bị treo, mở Recovery Contract và lời thoại dè chừng |
| 3. Hậu quả | return/extract kết quả từ route tương ứng | không có lựa chọn thiện/ác toàn cục; chỉ là cái giá của ba lô, route và thời gian | Bến ngoài thay đổi: scaffold/đường cảnh báo hoặc mạng tiếp tế ngầm; map/playable core không mất |

### Side-story

| Nhánh | Xung đột | Gameplay/item | Hệ quả cục bộ |
|---|---|---|---|
| **Khiên Canh Kho Số Bảy** | Một cựu lính hải quan muốn biết ai đã khóa kho khiến đội của họ chết bên trong | `Khiên Canh Kho Số Bảy`, tím, 2x2 khi chưa trang bị; route D và hatch kho phụ | mở hội thoại/bounty guard hoặc ưu đãi gear khiên; không bắt buộc cho build khiên |
| **Di sản người tị nạn** | Một gia đình tranh giữa rương gia tài cồng kềnh và giấy chủ quyền có thể đưa họ vào tầm ngắm | `Rương Di Sản`, 3x3, đối lập `Giấy Chủ Quyền`, 1x1 | decor/vendor/archive reaction khác nhau; không thay cổng truyện hoặc xóa content |

### Incident deck

Mỗi run tối đa một incident lớn và một encounter nhỏ. Incident được báo trong briefing hoặc trong 1-2 phút đầu bằng nước đổi màu, còi, đèn báo hay NPC; không dùng surprise death.

| Incident | Dấu hiệu | Thay đổi run | Kể chuyện gì? |
|---|---|---|---|
| **Nước triều đen** | mực nước và đèn phao hiển thị trước run | D ngập sâu, lane thuyền mở; một số lối bộ thành hazard | Ward pressure và hàng bị bỏ lại biến cảng thành nơi nguy hiểm |
| **Khám thuế đột xuất** | còi/đội kiểm tra ở briefing | B có patrol/booth dày hơn, két niêm phong claim tăng | Nhà Hắc Thuế giữ độc quyền bằng luật và bạo lực thường nhật |
| **Hòm cứu trợ trôi** | khói hiệu/cờ cứu hộ nhìn thấy từ A hoặc D | mục tiêu kéo/nhặt cargo lớn; người chơi có thể bỏ để rút | hàng cứu trợ là loot nhưng cũng là nhu cầu của con người |
| **Đấu giá bí mật** | khách lạ, đèn vàng ở E | side room/vault có tài sản claim và elite; extract pressure cao | khi quyền sở hữu có thể mua, bằng chứng cũng có thể bị bịt miệng |

## 6. Combat, encounter và đọc trên mobile

### Enemy roles

| Role | Hành vi/đọc telegraph | Khu mạnh nhất | Counterplay |
|---|---|---|---|
| **Vệ binh thuế khiên nhẹ** | chặn ngõ, guard có cửa sổ rõ | B, E | parry/đánh vòng/địa hình rộng |
| **Đốc công lao tới** | charge có vạch sàn, đẩy khỏi cover | D, B | dash ngang, giữ khoảng cách, stagger |
| **Canh mái bắn xa** | laser/aim line ngắn trước khi bắn | C, E high ledge | cover, di chuyển, cung/súng trả góc |
| **Bailiff kho niêm** (elite tùy chọn) | gọi reinforcement/alarm và giữ vault | E | lựa chọn né, tắt alarm hoặc đánh gate encounter |

- **Skirmish:** 2-4 địch, 10-25 giây.
- **Gate:** 30-60 giây để giữ lối, mở kho hoặc qua checkpoint.
- **Major tùy chọn:** 90-150 giây ở E/vault; không bắt buộc để hoàn thành Story Contract.
- Sau gate encounter luôn có 15-30 giây vùng yên để heal, xếp ba lô và cân nhắc rút.

### Camera/readability

- Camera isometric cố định; zoom nhẹ duy nhất khi elite.
- Tối đa hai cao độ; không dùng precision-platforming.
- Lane tối thiểu rộng khoảng 2.5 nhân vật trừ ngõ hẹp cố ý cho khiên/kiếm.
- Foreground cao tự trong suốt; loot, bẫy và telegraph luôn ở layer chạm/nhìn rõ.
- Landmark màu/silhouette: đèn phao xanh A, mái vải đỏ B, cần cẩu vàng C, nước/lồng kho xanh lục D, tường dấu thuế đồng E.

## 7. Loot pressure và loadout expression

| Khu | Loot family | Pressure ba lô | Build được thưởng |
|---|---|---|---|
| A | vật tư, thuốc, dây thừng | 1-2 ô; recovery ổn định | starter kit, học extract |
| B | key, medicine, tax seal, đồ dân sự | loot trung bình; quyết định giữ utility hay giá bán | kiếm ngắn + khiên nhẹ |
| C | gem, proof, linh kiện/cung | small/high value per cell | bow/ranged và ba lô hẹp/dọc |
| D | cứu trợ, két hàng, vũ khí/giáp bỏ lại | 4-9 ô; giá tổng cao nhưng nặng và cồng kềnh | khiên/cận chiến, ba lô rộng, thuyền extract |
| E | evidence, két thuế, claim property | safebox bị cạnh tranh giữa story/medicine/valuable | loadout cân bằng; route planning |

- Vũ khí trang bị không chiếm grid; vũ khí nhặt/dự phòng chiếm grid theo footprint.
- Không ép cung, khiên hay vũ khí hai tay để hoàn thành map. Mỗi route chỉ tạo cơ hội cho build khác nhau.
- Không xác định giá bán, drop rate, damage, armor, enemy HP hoặc economy ở brief này.

## 8. Độ khó và map state

| Mode | Geography/extract | Địch/loot | Mục tiêu thiết kế |
|---|---|---|---|
| **Easy** | A luôn extract; geography/route cơ bản cố định | patrol cố định, loot thấp hơn | học combat, loot, safebox và lúc rút |
| **Normal** | 2/3 extract mở, hiển thị từ briefing | patrol/loot vị trí thay đổi trong tập cố định | farm có rủi ro và lựa chọn route |
| **Hard** | 1 primary map state + 1 incident tương thích; 1-2 extract có điều kiện rõ | patrol/elite/vault pressure tăng, route có checkpoint/hazard | dùng kiến thức map để thích nghi, không farm path tuyệt đối |
| **Extreme** | cùng topology, một route bị suy giảm vật chất nhưng không bị xóa; condition extract rõ | high claim loot, elite pressure và hazard cao | high-stakes Black Contract, không phải health sponge mode |

Ví dụ state hợp lệ: `Nước triều đen + Hòm cứu trợ trôi`; `Khám thuế đột xuất + Đấu giá bí mật`. Không kết hợp state mâu thuẫn. Hard/Extreme không random A-E, evidence logic, landmark chính hoặc shortcut location.

## 9. Current vertical-slice cut

Lát cắt hiện hành chỉ chứng minh một core loop 10–15 phút, theo [vertical slice](../vertical-slice.md); nó không thay thế brief full map A–E hay campaign Act I ở các phần trên.

- **Playable:** chỉ A, B và D; C và E là silhouette/background không nhận input, không có objective hay gate.
- **Mode và extract:** Easy, state cố định; chỉ Cầu tàu A là extract. D không có thuyền extract.
- **Combat:** combat cơ bản/telegraph tại B và D; không có elite, boss hoặc gate E.
- **Inventory:** loot 1, 2 và 4 ô; cargo 2x2 tại D; Hộp Công Chứng 2x2.
- **Story:** chỉ Contract 1 — `Manifest Hàng Hóa R-17`. Contract 2/3, `Counterseal`, `Sổ Nợ Gốc` và route evidence tới E không playable và không dùng placeholder trong lát cắt.
- **Local content:** không có Local Story, side-story hay incident; loot/encounter cố định chỉ để dạy lựa chọn route, grid, safebox và extract.

### Explicitly excluded from current vertical slice

Normal, Hard/Extreme; route C hoặc E playable; thuyền D, cổng thuế E, Contract 2/3, Counterseal/Sổ Nợ Gốc, elite/boss, incident deck; toàn bộ Local Story/side-story; toàn bộ item catalogue; final art/audio; economy numbers; multiplayer/co-op; procedural topology; implementation/technical architecture.

## 10. Acceptance checks for future content work

Một thay đổi vào map này chỉ được thêm nếu trả lời được:

1. Nó có giữ causal chain `Manifest → Chùm Khóa K-7 → Counterseal + Sổ Nợ Gốc → Lò Rèn Câm` không?
2. Nó thuộc zone/route nào và tạo quyết định về combat, inventory, route hoặc extraction nào?
3. Nó có thay map state/local state mà không gate Main Story không?
4. Nó có giữ geography A-E, shortcut và landmark học được không?
5. Nó có phù hợp một session 8-15 phút và màn hình mobile 2.5D không?
6. Nó có mở rộng loot/phe chuyện kể mà không biến thành generic treasure hoặc power creep không?
