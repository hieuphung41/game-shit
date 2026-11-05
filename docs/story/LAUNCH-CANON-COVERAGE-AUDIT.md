# Audit coverage canon launch — Khế Ước Tàn Vương

**Trạng thái:** audit `proposed` cho TASK-20261105-40. Đây là danh sách chênh lệch để mở Task Card sửa hẹp; nó không tự đổi canon, thêm lore, map, item, contract, UI hay phạm vi build.

## Phạm vi và thứ tự nguồn

- **Nguồn canon quyết định:** [Tuyến truyện chính](MAIN_STORY.md). Khi có mâu thuẫn về luật thế giới, chuỗi evidence, Act, ending hoặc hậu campaign, tài liệu này thắng.
- **Ràng buộc triển khai đã đồng bộ:** [tiến trình vùng](REGION_STORY_AND_PROGRESSION.md), [cast và phe](CHARACTERS_AND_FACTIONS.md), [local story và incident](MAP_LOCAL_STORIES_AND_EVENTS.md), [thiết kế item](ITEM_NARRATIVE_DESIGN.md), [Cảng Hắc Thuế](../maps/black-tax-port.md), [inventory/loadout](../systems/inventory-and-loadout.md) và [vertical slice](../vertical-slice.md).
- [Campaign Outline](CAMPAIGN_OUTLINE.md) là archive lịch sử đã có guardrail; không audit lại như nguồn canon.

## Kết quả cần sửa

| ID | Severity | Vị trí | Finding và failure scenario | Sửa nhỏ nhất |
|---|---|---|---|---|
| LCA-01 | `MUST_FIX` | [REGION_STORY_AND_PROGRESSION.md](REGION_STORY_AND_PROGRESSION.md) §3, §§5–9 | Sơ đồ mở vùng vẽ Lò Rèn → Thành Mưa Tro và Tu Viện → Kinh Đô thay vì tuyến Act I → II → III → IV → V. Act I/II/IV còn gọi chủ vùng là “Nhà Thương nhân”, “Nhà Quân phiệt”, “Nhà cầm quyền”, trong khi canon là Hắc Thuế, Thiết Ấn, Tro Thành. Designer có thể cho player đi Thành Mưa Tro trước Witness Key/Mark hoặc tạo thêm ba nhà ngoài Sáu Ghế. | Đổi sơ đồ thành `Cảng Hắc Thuế → Lò Rèn Câm → Tu Viện Kính Vỡ → Thành Mưa Tro → Kinh Đô Vô Ngai`, vẫn giữ return loop; thay ba nhãn chung bằng Ghế canon. |
| LCA-02 | `MUST_FIX` | [REGION_STORY_AND_PROGRESSION.md](REGION_STORY_AND_PROGRESSION.md) §§5–6 | Act I chỉ đòi Sổ Nợ Gốc, và Act II cho “dấu thợ trên sổ” xác nhận tổ tiên là kiểm định viên. Canon yêu cầu `Counterseal + Sổ Nợ Gốc` mới tạo chứng cứ chronology fraud; Ward Engine registry Act II mới chứng minh vai trò kiểm định. Nếu giữ nguyên, Contract 3 có thể chỉ cần một item và reveal Act II đến sai thời điểm. | Nêu Bundle hai phần ở Act I; đổi dấu trên vật chứng Act I thành lead tới Lò Rèn, để registry Act II xác nhận nghề kiểm định. |
| LCA-03 | `MUST_FIX` | [MAP_LOCAL_STORIES_AND_EVENTS.md](MAP_LOCAL_STORIES_AND_EVENTS.md) §6.5 | Vết thương Kinh Đô viết “sau Crown Audit”, như thể Crown Audit đã thành công. Canon là player **ngăn** Crown Audit, rồi Hiến Ước Lâm Thời xử lý hậu quả. Nội dung hậu game có thể vô tình phủ nhận thắng lợi Act V. | Đổi thành “sau khi ngăn Crown Audit” hoặc “sau khủng hoảng Crown Audit”; giữ trạng thái quyền/nợ chưa được luật mới bảo vệ. |
| LCA-04 | `MUST_FIX` | [STORY_BIBLE.md](STORY_BIBLE.md) header, §3.1, §4 | Bible vẫn là working draft nhưng thiếu câu nhường canon cho `MAIN_STORY.md`. Dòng map access cho phép “faction permission” quá rộng so với evidence/permit/điều kiện được định nghĩa. Một map có thể bị mở bằng thiện cảm/reputation, đứt chuỗi vật chứng. | Thêm guardrail rằng `MAIN_STORY.md` thắng mọi mâu thuẫn luật/evidence/ending; giới hạn permission thành permit/điều kiện đã ghi rõ, không phải quan hệ. |
| LCA-05 | `MUST_FIX` | [black-tax-port.md](../maps/black-tax-port.md) §9; [inventory-and-loadout.md](../systems/inventory-and-loadout.md) §9 | Hai phần cùng gọi phạm vi là MVP/vertical slice nhưng cho E, elite, Counterseal/Contract 3 và Easy+Normal, trái [vertical slice](../vertical-slice.md) hiện hành: Easy, Contract 1, A/B/D, C/E chỉ silhouette và không input. Team có thể build/test nhầm một artifact rộng hơn, phá test scope đang khóa. | Đồng bộ hai phần về vertical slice hiện hành **hoặc** đổi nhãn rõ thành prototype map mở rộng trong Task Card tương lai. Không để hai định nghĩa cùng mang nhãn vertical slice/MVP. |
| LCA-06 | `MUST_FIX` | [ITEM_NARRATIVE_DESIGN.md](ITEM_NARRATIVE_DESIGN.md) §§3, 8 | Ví dụ và bảng story-loot còn rút gọn/cũ: Act I coi dấu niêm thuế + sổ gốc là evidence, Act III thiếu Witness Key/Witness Mark, Act IV dùng Ấn Chủ Quyền + danh sách hiến tế thay Seal + registry. Ví dụ còn gọi chủ cảng là “Nhà Thương nhân” và ám chỉ dấu niêm là bằng chứng ngày tháng. Team item có thể tạo sai vật chứng mở map hoặc bỏ mất lead người thầy. | Đổi bảng thành bundle Act I `Counterseal + Sổ Nợ Gốc`; Act III `Witness Key + Witness Mark`; Act IV `Field Authority Seal + registry`. Chỉ giữ dấu niêm thuế là manh mối provenance của Hắc Thuế, không thay evidence chính. |

## Cần quyết định, không tự giải

| ID | Severity | Vị trí | Finding và failure scenario | Sửa nhỏ nhất |
|---|---|---|---|---|
| LCA-07 | `OPTIONAL` | [STORY_BIBLE.md](STORY_BIBLE.md) §4; [ITEM_NARRATIVE_DESIGN.md](ITEM_NARRATIVE_DESIGN.md) §10 | **Old Wardens** chỉ xuất hiện ở Bible/UI claim, không có local wound, actor, map hay contract launch trong canon hiện hành. Team có thể hiểu icon claim là authorization để thêm một phe/antagonist launch mới. | Nếu còn giữ nhãn, ghi rõ `world-facing/proposed at launch`: không map, actor, contract hay campaign gate cho tới Task Card riêng. |

## Kiểm tra đã đạt

- Act III–V ngoài các surface được nêu ở LCA-06 giữ đúng `Witness Key/Witness Mark → Field Authority Seal → relay/sơ tán + Seal/registry extract → Cải Ước/Hoàn Trả/Giữ Ấn → Hiến Ước Lâm Thời`.
- Người thầy, Người Thu Hồi già, Thanh tra trưởng, Liên Minh và Sáu Ghế có động cơ/cái giá nhất quán; không có mastermind, ending thứ tư hay quan hệ thay evidence.
- Side-story/incident chỉ đổi local state, route, reward hoặc recovery; không soft-lock Main Story. Map update bám hậu quả của ending, không retcon.
- Item/story evidence vẫn extract được, chết là `unrecovered` chứ không khóa campaign hoặc auto-complete; rarity, claim, safebox và inventory vẫn tạo lựa chọn mobile đọc được.
- Không dùng level/XP/gear score để mở Easy/Normal hay map; phí contract tách giá trị loadout; cốt truyện và UI briefing vẫn ưu tiên một mục tiêu hành động ngắn.

## Ngoài phạm vi

Audit không thay source canon, không harmonize archive, không đặt tên riêng final, không thêm lore/actor/map/item/incident, không đổi kinh tế/combat/UI/implementation, không chỉnh file playtest/build/readiness, và không quyết định xử lý `OPTIONAL`.
