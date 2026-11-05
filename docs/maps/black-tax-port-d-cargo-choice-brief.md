# Cargo/Hộp decision brief — Kho Nổi D, vertical slice “Giữ giấy phép”

**Trạng thái:** brief quyết định inventory `proposed` cho Easy / Contract 1. Nó mô tả cách người chơi đọc và tự chốt lựa chọn ở D; không định nghĩa catalogue item, giá trị cuối, balance economy, UI mockup hay implementation.

**Nguồn ràng buộc:** [vertical slice](../vertical-slice.md), [inventory/loadout](../systems/inventory-and-loadout.md), [wireflow UX](../vertical-slice-wireflow.md), [build-readiness](../vertical-slice-build-readiness.md), [blockout A/B/D](black-tax-port-vertical-slice-blockout.md), [kế hoạch playtest](../playtest-readability-plan.md) và [map brief Cảng Hắc Thuế](black-tax-port.md). Khi map brief hoặc catalogue nói về map campaign rộng hơn, nguồn slice/inventory/wireflow/readiness được ưu tiên: Easy cố định, Contract 1, A/B/D, fixture cargo `2x2`, chỉ extract A; C/E là silhouette và D không có thuyền/extract.

## 1. Mục đích và fixture khóa cho slice

D phải dạy một câu hỏi, không phải cách kiếm lời tối đa:

> “Không gian ba lô và Hộp của tôi còn gì, lựa chọn nào hợp với run này, và tôi có sẵn sàng mang nó về A để extract không?”

| Fixture đang có trong slice | Ý nghĩa dùng ở D | Không được suy diễn |
|---|---|---|
| Ba lô `3x4 proposed` | Không gian chính cho Manifest và loot/cargo trong run. | Dung lượng phát hành hay weight system. |
| Hộp Công Chứng `2x2` | Lưới niêm phong riêng; từ loadout đã có một vật hồi phục **non-evidence** `1x2` đã niêm. | Ba lô thứ hai, kho hub hay bảo hiểm toàn loadout. |
| `Manifest Hàng Hóa R-17` `1x1` | Evidence của Contract 1 đang mang; có thể ở ba lô/Hộp theo placement hợp lệ. | Completion khi niêm, giá bán hay evidence cuối Act I. |
| Cargo fixture `2x2` | Lựa chọn cồng kềnh để thấy trade-off footprint. | Item catalogue/final asset/giá hay item tự vào Hộp. |
| `Dấu Thuế` fixture `1x2` | Lựa chọn gọn để so footprint/công dụng với cargo. | Claim/rarity/final price/damage hoặc loot story mới. |

Không thêm item, slot, giá, rarity, drop rate, weight/slow penalty, combat gate hay prompt ép nhặt để “làm rõ” lựa chọn này.

## 2. Quan hệ không gian và flow lựa chọn

Sơ đồ diễn tả thứ tự quan sát và state hợp lệ, không là toạ độ/tile/scale hoặc layout UI.

```text
      từ B, qua gate đã mở
                │
                v
 [D: nước/lồng kho · thấy cargo 2x2, Dấu Thuế 1x2 và cổng quay B]
                │
                ├── O2: xem card / bỏ qua ────────────────┐
                │                                         │
                └── chọn tự nguyện ─→ O3 ba lô / O4 Hộp  │
                     placement preview → commit / hủy     │
                                                        v
        mang cargo / ưu tiên Dấu Thuế / bỏ cả hai ─→ D → B (cổng luôn mở)
                                                        │
                                                        v
                                                B → A: call / hold / board
```

D là choice space chứ không là extract space: không thuyền, beacon, vòng extract, label exit hay shortcut tới C/E. Sau mọi lựa chọn hoặc khi không tương tác item, cổng/lane D → B vẫn mở; không có đường cụt, checkpoint hay combat gate mới buộc player lấy/bỏ đồ.

## 3. Điều người chơi nhìn trước khi quyết định

### 3.1 Không gian và thứ tự thông tin

Trong cùng một đoạn nhìn hoặc đường nhìn liên tục, player phải nhận ra: mặt nước/lồng kho của D, nguồn của hai fixture, và lối quay B. Foreground, phản xạ nước, HUD hay overlay không che player, objective, footprint, hazard/telegraph gần nhất hoặc lane D → B.

Khi player tự chọn inspect, card dùng đúng thứ tự:

```text
silhouette/tên → footprint/ô trống → công dụng hoặc tổng/ô theo fixture → claim → rarity → lore ngắn
```

Footprint là thông tin ra quyết định sớm, không phải chi tiết sau rarity. Claim và rarity có shape/icon/text riêng, không chỉ màu; rarity không đồng nghĩa damage, tổng giá trị hay giá trị/ô. Brief này không viết tên, lore, giá, claim hoặc rarity cuối cho cargo/Dấu Thuế.

### 3.2 Input và state placement

| Action player | Hệ thống cần cho thấy | State hợp lệ sau action |
|---|---|---|
| Xem card rồi `Bỏ qua`/đóng | Nguồn item vẫn ở D; không mất/đổi item đang mang. | Giữ state D; player quay B bất cứ lúc nào. |
| Chạm chọn rồi chạm ô ba lô | Preview footprint `2x2` hoặc `1x2`, ô trống và lý do nếu không vừa. Tap-select + tap-target là thao tác đầy đủ; drag chỉ shortcut. | Chỉ placement hợp lệ mới commit; sai/hủy giữ item nguồn và ba lô nguyên trạng. |
| Xoay item nếu fixture cho phép | Hình sau xoay và ô trống được preview trước commit. | Player commit hoặc hủy; không xoay/di chuyển item khác ngầm. |
| Mở O4 để cân nhắc niêm | Hộp chỉ hiện item/footprint có thể niêm; `đã niêm — chưa extract` tách khỏi objective completion. | Chỉ thay đổi sau placement hợp lệ và commit chủ động. |
| Không đủ chỗ / sai loại / Hộp đầy | Item nguồn, Hộp và ba lô giữ nguyên; reason có shape/text ngoài màu. | Player tự đổi, để lại hoặc hủy; system không tự giải quyết. |

Không auto-drop, auto-swap, auto-sort, auto-seal hay auto-Archive. Đóng/hủy preview chưa commit không thay container, item source hay route.

## 4. Ba outcome hợp lệ

Không outcome nào dưới đây là build “tối ưu”, điều kiện success, điểm thưởng narrative hay điều kiện rời D. Evidence Contract 1 vẫn chỉ được ghi nhận sau extract A.

| Outcome player tự chọn | Evidence hành vi đúng | Điều phải được giữ | Return cue |
|---|---|---|---|
| **Mang cargo `2x2`** | Player thấy footprint/ô trống và chủ động nhường không gian hợp lệ trong ba lô để lấy cargo. | Không thêm weight/slow penalty; cargo vẫn là loot thường, không vào Hộp và không mở thuyền D. | Cổng/lane D → B tiếp tục đọc được; player có thể quay B → A. |
| **Ưu tiên Dấu Thuế `1x2`** | Player so footprint/công dụng/tổng-ô từ card và tự placement item gọn. | Không gọi lựa chọn này là tốt hơn cargo, không dùng rarity/claim như điểm số hay auto-tịch thu. | Cùng cổng/lane D → B; không nhánh C/E và không extract D. |
| **Bỏ cả hai / giữ chỗ trống** | Player đóng/bỏ qua card, hoặc nêu trade-off để dành không gian cho Manifest/đường rút. | Không phạt, không spawn loot thay thế, không khóa đường về hay ghi là bỏ nội dung. | Lane D → B luôn mở; player vẫn quay A và success bình thường. |

Không được diễn giải một player bỏ cargo là thiếu skill hoặc không hiểu game nếu lời nói/hành vi cho thấy họ đã cân nhắc footprint/công dụng/rủi ro. Tương tự, mang cargo không chứng minh họ hiểu Hộp hay evidence nếu state đó chưa được quan sát.

## 5. Hộp, evidence và death guardrails

| State/rule | Cách D trình bày hoặc giữ luật | Không được xảy ra |
|---|---|---|
| Hộp `2x2` | Chỉ item mang nhãn niêm phong được và footprint hợp lệ mới vào; Hộp từ loadout đã có thuốc non-evidence `1x2` đã niêm. | Cargo, gear, weapon, container, ba lô hoặc túi đeo chéo vào Hộp. |
| Hộp đầy/sai loại/không vừa | Item nguồn giữ nguyên. Muốn nhường chỗ, player tự đưa item cũ tới đích hợp lệ trước rồi mới commit item mới. | Auto-swap/drop, xóa thuốc, nén cargo hoặc niêm ngầm. |
| Manifest trong Hộp | Nhãn `đã niêm — chưa extract`; objective extract A vẫn hiện. | Seal = delivery/completion, Manifest tự vào Archive/hub, hoặc D thành điểm hoàn thành. |
| Death sau Manifest | Manifest là `unrecovered`; chỉ non-evidence đã niêm được giữ; gear/loot không niêm mất theo summary. | Toàn bộ Hộp về như evidence, auto-extract/checkpoint, hay Recovery tự trả gear/loot đã bỏ/mất ngoài Hộp. |

Nếu player chọn thao tác có hậu quả khó đảo ngay, UI hiện preview/xác nhận/hủy đúng theo rule inventory. Điều này không thêm action mới và không biến mỗi di chuyển/xoay/inspect thành popup.

## 6. Checks readability và fairness trước prototype review

1. Có thể nhìn/hiểu lồng kho, hai nguồn fixture và lối D → B mà không phải đi qua hazard hoặc combat mới không?
2. Card có luôn đưa silhouette/tên rồi footprint/ô trống trước claim/rarity/lore, và có cue ngoài màu cho footprint/claim/rarity không?
3. Player có thể biết `2x2` và `1x2` khác nhau trước khi commit; placement sai, Hộp đầy và hủy có giữ nguyên state không?
4. O2/O3/O4 có còn để health, objective ngắn, telegraph/hazard và route B đọc được; có thể đóng bằng một action không?
5. Cargo/gear/container có bị loại khỏi Hộp, còn Manifest niêm có rõ là `chưa extract` không?
6. Cả ba outcome có dẫn về D → B → A mà không weight penalty, combat gate, forced pickup, death trap, reward chấm điểm hay wording “lựa chọn đúng” không?
7. D có hoàn toàn không có extract grammar/C/E affordance, trong khi A vẫn là nơi call/hold/board duy nhất không?

## 7. Handoff và giới hạn mở

Prototype/art review chỉ cần xác nhận: nguồn item, card/placement/Hộp state, ba outcome và cổng về B đều đọc được; không cần tối ưu chọn đồ hay định lượng economy. Không suy từ brief này ra item catalogue, giá, value-per-cell, drop rate, rarity, combat/hazard tuning, final asset/UI, toạ độ/collision/navmesh hay implementation.

Các câu hỏi cố ý để mở: thể hiện prop/cargo cuối, control scheme chi tiết, vị trí layout chính xác, tuning hazard/combat và kinh tế sau slice. Chúng phải qua Task Card khác; không giải bằng item mới, auto-management, thuyền D, C/E access, full-route bắt buộc, checkpoint hoặc thay luật extract/death/recovery.
