# Blockout 2.5D — Vertical slice “Giữ giấy phép”

**Trạng thái:** brief blockout `proposed`, dùng để giữ quan hệ không gian, readability và fairness của prototype. Đây không phải layout Cảng Hắc Thuế hoàn chỉnh, bản đồ tile, toạ độ, asset list hay kế hoạch implementation.

**Nguồn ràng buộc:** [vertical slice](../vertical-slice.md), [wireflow UX](../vertical-slice-wireflow.md), [build-readiness](../vertical-slice-build-readiness.md), [art/presentation direction](../art-direction.md), [kế hoạch playtest](../playtest-readability-plan.md) và [map brief Cảng Hắc Thuế](black-tax-port.md). Khi map brief nói về map campaign rộng hơn, nguồn vertical slice/wireflow/readiness được ưu tiên cho cut hiện tại: Easy cố định, Contract 1, A/B/D playable và chỉ extract tại A.

## 1. Ranh giới blockout

Blockout chỉ cần làm rõ năm tình huống trên một camera isometric cố định: nhận mục tiêu ở A, chọn rút sớm tại A hoặc đi B, chiến đấu và quyết định loot ở B, lựa chọn cargo/Hộp ở D, rồi quay A để gọi/giữ extract. Mọi quan hệ dưới đây là arrangement `proposed` ở mức **zone và screen contract**, không là kích thước/độ dài/pathfinding cụ thể.

| Có trong cut | Phải vắng hoặc chỉ làm nền |
|---|---|
| A/B/D; Manifest; đường rút A; combat B; cửa sổ yên cho overlay; lựa chọn cargo/Hộp D; quay B → A; call/hold/board tại A | C/E có input, marker, loot hoặc route; thuyền D; cổng E; Contract 2/3; Hard/Extreme; incident, boss/elite; shop/craft/economy; loot/enemy placement cuối; multiplayer/live operation |

`Manifest Hàng Hóa R-17` chỉ làm A callable sau khi placement hợp lệ. Niêm Manifest không phải extract, và chết sau khi mang nó vẫn là `unrecovered`; blockout không thay đổi quy tắc evidence/recovery này.

## 2. Quan hệ không gian cần đọc được

Sơ đồ là quan hệ hướng/nhìn, không biểu thị khoảng cách, tile hay scale. Mũi tên liền là đường hợp lệ trong vertical slice; nét chấm chỉ skyline không tương tác.

```text
             · · · [C: cần cẩu xa] · · ·
                        silhouette, không input

 [A: Bến Ngoài]
 dispatch · beacon/cầu tàu · lối mái đỏ B
      │  ╲
      │   ╲── sau Manifest: rút sớm → call / hold / board tại A
      │
      └── lối đi ra ──> [B: Chợ Ngập]
                             │ combat → vùng yên/card
                             v
                       [D: Kho Nổi]
                       nước · cargo/Hộp · cổng quay B luôn mở
                             │
                             └──────── quay D → B → A ────────┐
                                                               v
                                                [A: chỉ extract]

             · · · [E: tường thuế xa] · · ·
                        silhouette, không input
```

Hai route đều là success hợp lệ sau khi lấy Manifest:

```text
Rút sớm:    A (Manifest) → A (call / hold / board) → summary
Đi tùy chọn: A (Manifest) → B → D → B → A (call / hold / board) → summary
```

B/D là phần thưởng/rủi ro tùy chọn, không phải đường để “xứng đáng” với success. D không có thuyền, nút extract hay affordance tương đương A. C/E chỉ được dùng để mở sâu cảnh và hứa map tương lai: không highlight, label objective, collision lừa người chơi hoặc đường nhìn khiến chúng trông như exit hiện tại.

## 3. Camera, landmark và lớp đọc

### 3.1 Contract chung

- Camera chéo/isometric giữ hướng đọc nhất quán; zone chỉ có tối đa **hai cao độ đọc được**. Không dùng leap/precision-platforming để dạy route.
- Mỗi camera frame phải ưu tiên theo thứ tự: player + nguy hiểm tức thời → telegraph/lane → objective/extract state → interaction/card. Foreground cao tự trong suốt hoặc được cắt để không che player, cover, telegraph, objective hay lối ra.
- Landmark phải có shape/vị trí/texture/text/icon đọc được ngoài màu: beacon và cầu tàu A; mái/awning B; nước và lồng kho D. C/E không nhận cùng grammar affordance với landmark đang tương tác.
- Overlay O2/O3/O4 chỉ được khuyến khích tại vùng yên. Nếu player chủ động mở overlay ngoài vùng yên, HUD tối thiểu, telegraph và cảnh báo lane vẫn còn đọc được; blockout không dùng overlay để pause hoặc che combat.
- Một lối nhìn ngược chiều luôn nhắc lại landmark đã học: từ D nhìn thấy cổng quay B; từ B về A đọc lại trình tự mái đỏ → beacon/cầu tàu, không cần marker dẫn qua một route mới.

### 3.2 C/E là framing, không phải route

| Silhouette xa | Điểm được thấy | Điều được phép kể | Điều tuyệt đối không được tạo |
|---|---|---|---|
| C — cần cẩu/mái cao | Skyline từ A hoặc B | cảng còn chiều cao và lối về sau | thang usable, marker, loot glow, cover/combat gate hoặc nhánh vào C |
| E — tường thuế/kho niêm | Background sau D hoặc một vista B | quyền kiểm soát của Hắc Thuế nằm sâu hơn Contract 1 | cổng usable, prompt, thuyền/exit, objective hoặc bước Contract 2/3 |

## 4. Screen contracts cho prototype

Các “screen” là nhịp camera/readability, không bắt buộc bằng số scene hay số màn hình kỹ thuật.

| Nhịp blockout | Entry / exit hợp lệ | Landmark phải cùng đọc được | Bài học hoặc quyết định | Áp lực, cover và cửa sổ overlay | Cue quay lại / outcome thấy được |
|---|---|---|---|---|---|
| **A — spawn, dispatch, Manifest** | Vào từ briefing/loadout. Trước placement hợp lệ: beacon A **hiện nhưng E0/unavailable**, cùng bàn dispatch và lối B; chỉ placement Manifest hợp lệ vào ba lô hoặc Hộp mới đổi A sang E1/callable để người chơi có thể quay ngay Cầu tàu A hoặc đi B. | Cùng một góc camera cho player, bàn dispatch, beacon/cầu tàu A và mái đỏ/lối B. | “Lấy Manifest rồi tự chọn rút A hay mạo hiểm thêm.” Không combat/loot ép buộc. | A là vùng an toàn; không đặt combat/telegraph cần phản ứng tại đây. O2 placement hợp lệ phải đóng/hủy được; fail/hủy giữ Manifest ở source và A ở E0, không đổi route. | Beacon chỉ đổi E0/chưa callable sang E1/callable sau placement hợp lệ; quay body/camera là thấy ngay cầu tàu A, nên rút sớm đọc như success chứ không là quay đầu. |
| **B — ngõ ra, combat và cache yên** | Lần đầu vào từ A; sau đó được quay lại từ D. Qua skirmish, player đi D hoặc quay A qua chính corridor đã học. Không có lối C/E. | Mái/awning B, cửa ngõ hẹp, cover rõ và điểm gate cùng nằm trong một reading direction. | Đọc lane/telegraph/cover; sau đó đọc card/footprint và tự giữ/bỏ loot. | Telegraph bắt đầu từ direction nhìn thấy; cover không bị foreground che. Qua gate có vùng yên theo source để O2/O3 được đọc; không có prompt combat chồng card. | Gate mở thành lối đọc được tới D; khi quay lại, landmark B vẫn chỉ về A thay vì tạo junction mới. |
| **D — kho nổi, cargo và Hộp** | Vào từ B; sau quyết định quay về chỉ qua cổng/lane D → B đã mở. Không exit tại D. | Mặt nước, lồng kho/cargo và cổng quay B cùng đọc được hoặc được nối bằng một đường nhìn liên tục không mơ hồ. | Cargo lớn, item gọn hoặc không lấy đều hợp lệ; tự xếp/niêm qua rule Hộp hiện có. | Không mở card/grid giữa hazard hoặc đòn đang tới. Khu lựa chọn là khoảng nhìn rõ item source, footprint và lối B; không tự drop/swap/seal. | Cổng D → B mở và có landmark B ở hướng return; không có thuyền, beacon, UI label hoặc shape extract tại D. |
| **B → A — return dưới áp lực nhẹ** | Chỉ là backtrack D → B → A, không thành route/zone mới; đến A không bị chặn. | Chuỗi ngược: lồng kho/nước D rời khung → mái đỏ B → beacon/cầu tàu A. | Ưu tiên mang Manifest về rút, không cần dọn map. | Nếu có patrol, nó vào lane nhìn thấy trước với cue nguồn; không spawn sau lưng/ngoài camera. Không thêm inventory teaching mới tại đây. | Beacon/cầu tàu A tái xuất hiện trước khi player chạm vùng extract, để người chơi tự nhận ra đã quay đúng. |
| **A — call, hold, board** | Chỉ vào sau Manifest; `Gọi thuyền` có preview/xác nhận, rồi call accepted → hold → boat ready → board. | Beacon/cầu tàu, vùng giữ khu, cover gần A và miệng lane B cùng rõ; board target chỉ hiện khi thuyền đã tới. | Gọi/giữ extract là action chủ động; board mới kết thúc run. | Pressure chỉ đến từ lane B, báo bằng ánh sáng/âm thanh/telegraph trước khi địch vào camera. Cover và player không bị thuyền/foreground/UI che; death vẫn đi summary thường, không checkpoint. | Thuyền sẵn sàng ≠ auto-win; board dẫn success summary tách `Đã giữ`/`Đã mất`/`Vật chứng`/`Tiếp theo`. |

## 5. Checks fairness và mobile readability trước khi blockout được dùng

Đây là acceptance check cho một blockout/prototype review, không phải test case kỹ thuật hay thông số render.

1. Từ A có thể đọc đồng thời dispatch, beacon/cầu tàu và lối B không, mà C/E vẫn không có affordance?
2. Sau Manifest, player có một đường ngắn, rõ về A để rút sớm; B/D không có barrier hoặc wording khiến route tùy chọn trông bắt buộc không?
3. Ở B, lane/telegraph và ít nhất một cover có nhìn thấy trước khi damage; sau gate có vùng yên để card/grid không cạnh tranh màn hình với danger không?
4. Ở D, player có thấy item/cargo decision và lối D → B, nhưng không thấy bất kỳ extract grammar nào không?
5. Khi quay D → B → A, landmark có đảo chiều hợp lý và có thể nhận ra A trước vùng beacon không; patrol/lane có bao giờ tạo surprise sau lưng hoặc ngoài camera không?
6. Trong A hold, lane B có phải nguồn pressure duy nhất, được báo trước; `call`, `hold`, `boat ready` và `board` có còn là state khác nhau không?
7. Trên mọi frame, cao độ/foreground/HUD/overlay có che player, hazard, telegraph, objective, footprint hoặc đường rút không? Nếu có, đây là lỗi readability cần sửa blockout, không sửa bằng prompt/lore/item mới.

## 6. Handoff và giới hạn quyết định

Khi chuyển brief này cho prototype/art review, chỉ cần xác nhận quan hệ A/B/D và screen contracts ở trên. Không suy từ nó ra toạ độ, tile, số enemy, vị trí loot, damage/HP, tầm camera, timing mới, asset cuối hay một luật hệ thống mới.

Các câu hỏi cố ý để mở: chiều dài/độ cong route, vị trí chính xác của cover/cargo, style prop cụ thể, control scheme, tuning encounter và art/âm thanh cuối. Chúng cần Task Card khác và không được giải bằng cách mở C/E, thêm extract D, ép full-route hoặc biến seal/recovery thành completion.
