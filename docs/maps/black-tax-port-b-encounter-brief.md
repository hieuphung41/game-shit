# Encounter brief — Chợ Ngập B, vertical slice “Giữ giấy phép”

**Trạng thái:** encounter arrangement `proposed` cho Easy / Contract 1. Brief này xác định điều người chơi phải đọc và lựa chọn ở B; không là combat tuning, AI specification, layout toạ độ, asset list hay spawn table.

**Nguồn ràng buộc:** [vertical slice](../vertical-slice.md), [wireflow UX](../vertical-slice-wireflow.md), [build-readiness](../vertical-slice-build-readiness.md), [blockout A/B/D](black-tax-port-vertical-slice-blockout.md), [art/presentation direction](../art-direction.md) và [map brief Cảng Hắc Thuế](black-tax-port.md). Với cut này, nguồn vertical slice/wireflow/readiness ưu tiên hơn phần map campaign rộng hơn: Easy cố định, Contract 1, A/B/D playable, C/E chỉ silhouette và A là extract duy nhất.

## 1. Mục đích và ranh giới

B chỉ dạy một câu hỏi combat: **“Nguy hiểm đến từ lane nào, cover hoặc đường phản ứng nào còn mở, và tôi có thể tiếp tục hay quay A để extract?”** Người chơi đi B sau Manifest là lựa chọn tùy chọn; không encounter nào tại B làm rút sớm ở A trở thành success kém hơn.

| Có trong brief | Không được suy ra hoặc thêm vào |
|---|---|
| Vệ binh thuế khiên nhẹ giữ ngõ; Đốc công lao tới charge theo lane; cover/lane đọc được; gate B; cache/vùng yên; patrol nhẹ B → A đã báo trước | Damage/HP, số địch, timing/AI/spawn table, kill-all gate, combo mới, loot/item mới, checkpoint, boss/elite, C/E route, D extract, Hard/Extreme, incident, asset/audio cuối, implementation |

Một combat death không tự chứng minh player “không hiểu”. Death chỉ là outcome theo luật run hiện có: sau Manifest vẫn `unrecovered`, không checkpoint và không completion. Brief này không thay luật recovery/evidence hay inventory.

## 2. Quan hệ encounter cần đọc được

Sơ đồ chỉ diễn tả thứ tự nhìn thấy và quan hệ route/cover; không biểu thị khoảng cách, toạ độ, tile, số role hay thời lượng.

```text
                 từ A sau Manifest
                         │
                         v
          [B entry: mái đỏ, thấy lane quay A]
                         │
                         v
      [Vệ binh khiên nhẹ: giữ ngõ / thế thủ đọc được]
                         │
          cover + khoảng vòng/đường lùi còn đọc được
                         │
                         v
  [Đốc công: wind-up → vạch/lane charge có hướng → phản ứng]
                         │
                         v
          [gate B: áp lực lane đã giải quyết, không kill-all]
                         │
                         v
       [cache + vùng yên: mời card/grid, không ép nhặt]
                         │
                         └──────────────────────────→ D

  Return: D ─→ B (patrol cùng grammar báo từ xa) ─→ A / beacon extract
```

Ở B luôn giữ được một đường nhìn hoặc landmark ngược về A. C/E không xuất hiện như lối flank, cover interactable, objective hay điểm thoát; D chỉ là exit về vùng cargo, không có thuyền/extract.

## 3. Beat đi tới D — dạy combat mà không buộc dọn map

### 3.1 Vào B và đọc lựa chọn

Trước khi threat gây áp lực, player đọc được mái/awning B, ngõ có lane, ít nhất một cover và hướng quay về A. Objective ngắn chỉ là “Qua trạm thuế”; nó không gọi B/D là bắt buộc cho Contract 1 và không che beacon A trong trí nhớ route.

Player luôn có hai outcome hợp lệ trước khi qua gate:

- quay lại A để gọi extract sau Manifest;
- ở lại B để quan sát/đối phó encounter và đi D nếu lane mở.

Không dùng khóa vô hình, prompt dạy combat hay reward wording để biến B thành lựa chọn bắt buộc. Nếu player lùi về A, encounter không được đuổi thành surprise pressure ngoài lane đã đọc.

### 3.2 Vệ binh thuế khiên nhẹ — đọc ngõ bị giữ

| Người chơi phải thấy trước khi chịu áp lực | Ý nghĩa họ có thể suy ra | Counterplay hiện có được phép | Không được dùng làm điều kiện |
|---|---|---|---|
| Silhouette chắn ngõ, thế thủ/guard rõ, vị trí đứng và lane phía trước; cue shape/motion/vị trí, không chỉ mái đỏ hoặc màu địch. | Ngõ đang bị giữ, nhưng có cover/khoảng di chuyển và hướng quay A. | Di chuyển vòng khi có khoảng, dùng guard/defence đã chọn, hoặc lùi về A. | Giết role, học combo, tìm item mới, hay lao qua tín hiệu không đọc được. |

Role này tạo một ngõ đang bị kiểm soát chứ không tạo damage không báo trước. Cover và player phải còn nhìn thấy cùng telegraph; foreground/mái vải không được che mắt lane hoặc tạo cảm giác địch đánh từ ngoài camera.

### 3.3 Đốc công lao tới — đọc charge theo lane

Sau khi player đã có cơ hội đọc ngõ/cover của vệ binh, đốc công tạo beat charge thứ hai. Charge dùng **wind-up tách nền** rồi vạch/lane có hướng trên sàn; hình dạng, chuyển động, vị trí và tín hiệu âm thanh hỗ trợ nhau, để đây không là cảnh báo chỉ bằng màu.

| Trước khi pressure đến | Lựa chọn đọc được | Kết quả player cần nhận ra | Không được có |
|---|---|---|---|
| Wind-up và lane nằm trong vùng camera; cover/side space và lối lùi vẫn thấy được. | Dash ngang, giữ khoảng cách, guard hoặc phản ứng combat hiện có khác với charge. | Có thể tránh/chặn/đánh trả theo kit hiện có; sau phản ứng, route không biến thành đường cụt. | Charge từ sau lưng/ngoài camera, lane bị che bởi overlay/foreground, freeze tutorial giữa đòn, hoặc yêu cầu phản xạ precision-platforming. |

Gate B là trạng thái địa lý dễ nhận: nó mở khi áp lực lane đã được giải quyết và dẫn tới cache/D. Người chơi **không cần giết một role đã rút khỏi lane** để được đi tiếp; không hiện kill count, không biến combat thành điều kiện hoàn thành Contract và không cho gate đóng lại phía sau để ép death.

### 3.4 Cache và vùng yên sau gate

Sau gate có vùng yên **15–30 giây theo nguồn slice**. Đây là cửa sổ mời player inspect cache B, mở O2/O3 hoặc tự quyết định giữ/bỏ loot; không bắt buộc nhặt item, xoay đồ hay dùng Hộp để được sang D.

Trong vùng này, combat prompt đã biến mất. HUD tối thiểu vẫn hiển thị health, objective ngắn và mọi cảnh báo gần; card/grid không che hoàn toàn những thông tin đó. Nếu player đóng/bỏ qua card, họ vẫn đi D hoặc quay A qua B được, không bị thay item/rule ngầm.

## 4. Beat quay B → A — áp lực nhẹ, không thêm lesson

Sau D, B chỉ kiểm tra việc giữ route/extract priority, không lặp lại gate hoặc mở một content beat mới. Patrol return phải dùng cùng visual grammar đã học: cue từ xa ở lane có thể thấy, sau đó là threat/đường phản ứng có hướng rõ. Nó không thêm role kẻ địch, loot/card, combat mechanic hoặc giải thích mới.

| Điều player thấy trước | Lựa chọn hợp lệ | Điều encounter phải giữ | Không được biến thành |
|---|---|---|---|
| Cue patrol từ xa trên lane B về A; landmark mái B và hướng beacon/cầu tàu A còn nhận ra. | Né qua cover/route đang mở hoặc xử lý skirmish ngắn rồi tiếp tục A. | Manifest/extract objective được ưu tiên; route A không bị khóa; player không cần dọn B. | Gate thứ hai, patrol từ sau lưng/ngoài camera, surprise spawn, lesson loot mới hoặc nhánh map mới. |

Nếu player đã mở card/grid khi ở D, return không được tự chen combat vào overlay. Cảnh báo lane vẫn đọc được và player có thể đóng overlay bằng một action để phản ứng; không auto-drop, auto-seal, checkpoint hay reset inventory cho beat này.

## 5. Contract fairness/readability cho mọi beat B

| Điều cần kiểm tra | Đạt khi | Không đạt khi |
|---|---|---|
| **Camera/lớp cao độ** | Camera isometric hướng nhất quán; tối đa hai cao độ đọc được; foreground tự trong suốt/cắt khi che player, cover, lane, telegraph, objective hoặc exit. | Mái/quầy/cột che threat hoặc đường về, buộc người chơi đoán hướng. |
| **Tín hiệu threat** | Guard, wind-up, lane charge và return patrol đều có ít nhất shape/motion/vị trí/text hoặc audio đúng nghĩa ngoài màu. | Mái đỏ B, VFX loot, rarity hoặc một màu đơn độc bị dùng làm danger signal. |
| **Counterplay** | Mỗi threat hiện một lane/cover/side space hoặc defensive response hiện có trước pressure; player có thể lùi về A trước gate và tiếp tục A sau D. | Damage/surprise khiến không biết nguồn/hướng/cách tránh, hoặc không có đường rút. |
| **HUD/overlay** | Health, objective ngắn, telegraph/cảnh báo gần nhất còn đọc khi O2/O3/O4 mở; chỉ mời card/grid ở vùng yên. | Card/prompt che lane/health hoặc bắt player xếp đồ giữa threat. |
| **Route semantics** | B/D vẫn optional; gate dẫn D nhưng không là điều kiện extract; return dẫn A; chỉ A call/hold/board. | D có extract, C/E có input, B được gọi “đường đúng”, full-route/kill-all được thưởng như điều kiện success. |
| **Failure semantics** | Death dùng đúng death/recovery summary, không checkpoint/auto-extract; hiểu telegraph nhưng input/timing thất bại không tự là FAIL comprehension. | Death thành win, reset không báo trước hoặc bị suy thành player không hiểu mà không có evidence. |

## 6. Handoff và giới hạn mở

Prototype/art review chỉ cần xác nhận: thứ tự guard → charge → gate → vùng yên → D; B → A có patrol báo trước; và mọi cue/cover/route vẫn đọc được trên camera fixed. Không suy từ brief này ra số lượng enemy, vị trí spawn, damage, health, animation/AI timing, audio/asset cuối, toạ độ/collision/navmesh hay balance.

Các câu hỏi cố ý để mở: control phản ứng cuối, tuning/tần suất threat, vị trí chính xác cover, biểu hiện nghệ thuật cụ thể và cách implementation gate. Chúng cần Task Card khác; không giải bằng enemy mới, popup/tutorial dài, loot/reward mới, C/E access, D extract, checkpoint hay thay luật death/recovery.
