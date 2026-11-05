# Kế hoạch playtest & readability — Vertical slice “Giữ giấy phép”

**Trạng thái:** protocol quan sát `proposed` cho bản vertical slice đang chạy được. Nó kiểm tra người chơi hiểu gì từ build hiện có; không thay quy tắc, không là specification telemetry, không là bằng chứng cân bằng hay chứng nhận accessibility.

**Nguồn ràng buộc:** [vertical slice](vertical-slice.md), [inventory và loadout](systems/inventory-and-loadout.md), [Cảng Hắc Thuế](maps/black-tax-port.md), [art/presentation direction](art-direction.md). Nếu trước phiên phát hiện test fixture mâu thuẫn nguồn hoặc không tạo được state đúng luật, không chạy coverage đó; ghi `NOT READY` và mở Task Card fixture/readiness hẹp nếu cần. Nếu chỉ phát hiện trong phiên, ghi `KHÔNG TEST ĐƯỢC`, trả coverage bị ảnh hưởng về `NOT READY` rồi mở handoff tương ứng.

## 1. Câu hỏi cần trả lời

Một người chơi mới có tự hiểu và thực hiện được câu này không:

> “Lấy Manifest R-17, tự chọn rút A hay mạo hiểm thêm, và chỉ giữ được kết quả khi extract.”

Protocol chỉ đánh giá sáu học phần đã có trong slice: briefing/loadout, route A–B–D, combat telegraph, loot-grid, Hộp Công Chứng/evidence, và gọi/giữ extract rồi đọc summary. Không đo kỹ năng action, tốc độ run, giá trị loot hay độ khó cân bằng.

### Bất biến khi test

- Build test là **Easy cố định**, Contract 1, A/B/D, chỉ extract Cầu tàu A. C/E là silhouette không tương tác; không thử Hard/Extreme, incident, boss/elite, Contract 2/3 hay thuyền D.
- Rút A ngay sau Manifest là success hợp lệ ngang đường đầy đủ. Từ chối loot, không niêm phong hoặc bỏ cargo sau khi đọc card cũng là lựa chọn hợp lệ.
- `Manifest Hàng Hóa R-17` đặt trong Hộp Công Chứng vẫn cần extract; chết trước extract là `unrecovered`. Đồ niêm phong **không-phải-evidence** mới là đồ trở về hub.
- Không thêm prompt, item, route, checkpoint hay rule “tạm cho tester” để khiến test pass. Nếu build chưa có trạng thái cần quan sát, ghi thiếu coverage thay vì cho người chơi tưởng tượng kết quả.

## 2. Đơn vị test, vai trò và dữ liệu tối thiểu

Mỗi phiên là một lần quan sát một người **chưa chơi slice này**. Không số lượt test, tỷ lệ pass tổng hay cỡ mẫu nào được khóa ở tài liệu này; nhóm chỉ so các phiên cùng build và cùng điều kiện test.

| Vai trò | Được làm | Không được làm |
|---|---|---|
| Người chơi | Chơi theo cách mình cho là hợp lý; nói to điều đang nghĩ nếu thấy thoải mái; có thể dừng bất cứ lúc nào. | Không nhận chỉ đường, lời giải loot-grid hay giải thích lore trước khi tự thử. |
| Facilitator | Giới thiệu control cơ bản đã chọn, mời nói to suy nghĩ, nhắc mục tiêu của **bài test** khi chuyển probe, dừng khi cần an toàn/thoải mái. | Không nói route đúng, không nói B/D optional, không giải thích safebox/evidence, không gợi ý chạm vào UI nào để “qua”. |
| Observer | Ghi time/beat, hành vi đầu tiên, lời nói nguyên văn ngắn, trợ giúp đã dùng và trạng thái build. | Không trả lời câu hỏi gameplay, không diễn giải hộ người chơi trong lúc run. |

**Phiếu ghi tối thiểu `proposed`:** build/phiên bản và control scheme; người chơi đã từng chơi game action mobile/extraction hay chưa; đường thực tế; death/extract; mỗi claim ID ở §4: `PASS`, `FAIL`, `INVESTIGATE`, `KHÔNG TEST ĐƯỢC`; hành vi/lời nói quan sát; mọi can thiệp facilitator; lỗi kỹ thuật tách riêng lỗi hiểu biết.

Không ghi nhận hay suy đoán dữ liệu nhạy cảm, danh tính, khả năng y tế hay thông tin ngoài những gì người chơi tự nguyện nêu để giải thích khả năng dùng control/accessibility. Mọi recording, nếu có, cần consent và quy trình riêng; tài liệu này không yêu cầu recording.

## 3. Protocol một phiên

### 3.1 Trước khi chạy

1. Dùng save/profile mới, starter kit và trạng thái Easy cố định; xác nhận A, B, D, Manifest, Hộp 2x2, cargo 2x2, call/hold extract, death summary và Recovery Contract đang có đúng theo slice.
2. Chỉ giải thích control tối thiểu, thao tác pause/quit và quyền dừng. Không đọc lại briefing bằng lời hoặc giải nghĩa các icon trước khi player nhìn thấy chúng.
3. Nói: “Hãy chơi như bạn vừa mở game. Hãy nói điều bạn đang cố làm hoặc điều gì làm bạn bối rối; tôi sẽ không hướng dẫn cách qua.” Câu này là lời mời quan sát, không phải objective bổ sung.

### 3.2 Run tự nhiên — nguồn bằng chứng chính

Cho player đi từ briefing đến một kết quả tự nhiên: extract sớm, extract sau B/D, hoặc death. Không yêu cầu full-route, cargo, safebox hay death. Observer đánh dấu lúc player lần đầu:

- tự nói objective/rủi ro hoặc đọc briefing;
- nhận ra bàn dispatch, beacon A và đường B;
- đọc/reaction với telegraph/counterplay;
- mở card/ba lô, so item và quyết định giữ/bỏ;
- mô tả safebox/evidence/death nếu player chọn tương tác;
- gọi/giữ extract hoặc diễn giải summary/death/recovery.

Nếu player hỏi “tôi phải làm gì?”, facilitator chỉ đáp: “Bạn đang thấy thông tin nào nói về mục tiêu hoặc lựa chọn tiếp theo?” Nếu cần trợ giúp control để tránh kẹt kỹ thuật, đưa đúng một hướng dẫn control trung tính, đánh dấu `CAN THIỆP CONTROL`; mọi claim phụ thuộc hành động đó chuyển thành `INVESTIGATE`.

### 3.3 Ma trận coverage theo route/state

Run tự nhiên là nguồn bằng chứng chính về **quyết định route**. Các coverage dưới đây có thể nằm ở các phiên/người chơi khác nhau; không ép một người chơi phải đi đủ mọi path. Observer ghi từng coverage độc lập, theo đúng thứ tự, trước khi kết luận một claim đã được test.

| Coverage | Chuỗi state bắt buộc quan sát | Cách chạy không dẫn dắt | Claim chính có thể kết luận | Khi thiếu |
|---|---|---|---|---|
| **C0 — Run tự nhiên** | Briefing → A → kết quả player tự tạo (rút sớm, B/D rồi rút, hoặc death). | Không route hint; không yêu cầu full-route/death/cargo. | Ý định P1/P2/P4 và nhận biết P3/P7 nếu state xuất hiện. | Không suy từ route này sang route khác. |
| **C1 — Rút sớm** | State sau Manifest → quay A → `Gọi thuyền` → giữ khu → lên thuyền → summary. | Sau C0/reload đúng state, hỏi duy nhất: “Bạn sẽ làm gì tiếp?” Không gọi đây là đường an toàn/đường đúng. | P2 **semantics**, P7; A là extract duy nhất. | Nếu player không tự chọn A và build không có state hợp lệ khác, ghi coverage chưa đủ, không dạy đường. Không dùng C1 cho P1 hoặc P2 route-choice first-time. |
| **C2 — Full-route** | Save mới → briefing → A/Manifest → B combat/card → D cargo/Hộp → B → A → gọi/giữ extract → summary. | Một run first-time, không route hint, tự chọn đi đủ chuỗi này phải được ghi và đánh giá là **C0 độc lập**, không phải C2. C2 sau C0 chỉ quan sát UI/card/cargo/state, không gọi kết quả đó là bằng chứng route tự chọn. | P3, P4, P5, P7 và P8 cho các state đã gặp. | Nếu player tự chọn route khác hoặc dừng trước full-route, ghi state/coverage C2 `chưa gặp`; không ép player đi B/D hoặc coi rút sớm là thiếu. Chỉ ghi `KHÔNG TEST ĐƯỢC` nếu build không tạo được state C2 đúng luật. |
| **C3 — Death → Recovery** | State hợp lệ: Manifest đã niêm + một đồ niêm không-phải-evidence + ít nhất một gear/loot không niêm → death thật → summary tách đồ niêm thường `Đã giữ`, gear/loot không niêm `Đã mất`, Manifest `unrecovered` → chọn Recovery Contract → briefing/loadout recovery → **bàn dispatch A** để player tự thu hồi Manifest `unrecovered` → placement hợp lệ → E1; sau đó vẫn gọi/giữ/lên thuyền A mới success. | Facilitator báo đây là “một state khác của build”, hỏi dự đoán trước summary, rồi để player tự đọc/chọn action. Không kể outcome trước. | P6 và phần death/recovery của P7/P8. | Nếu build chưa tạo được state chết hoặc Recovery Contract đúng luật, ghi `KHÔNG TEST ĐƯỢC — C3`, không mô phỏng outcome bằng lời. |

`C2` là coverage của **đường đề xuất**, không phải điều kiện thắng hoặc điều kiện pass của người chơi. `C3` không biến death thành một hành vi bị yêu cầu trong run tự nhiên; nó chỉ kiểm tra semantic recovery sau khi dữ liệu run tự nhiên đã được chốt.

### 3.4 Probe sau run — coverage có kiểm soát

Chỉ sau khi ghi xong run tự nhiên và câu trả lời đầu tiên mới dùng các probe. Probe không thay kết quả của run tự nhiên và không được gọi là “đáp án”. Dùng save/state có sẵn của chính build; không tạo state giả bằng UI text hoặc kể kết quả thay game.

| Probe | Khi nào dùng | Lời mời trung tính `proposed` | Bằng chứng muốn thấy |
|---|---|---|---|
| **Rút sớm** | Player đã đi B/D hoặc chưa tự rút A sau Manifest. | Từ state sau Manifest: “Nếu bạn chỉ muốn hoàn thành việc cấp bách, bạn sẽ làm gì tiếp?” | Player chỉ A/beacon, gọi rồi giữ extract; coi đó là success, không là bỏ dở. |
| **Đi tiếp có cân nhắc** | Player rút sớm hoặc chưa tới D. | Từ state sau Manifest: “Bạn sẽ làm gì tiếp, và dựa vào đâu?” | Player có thể chọn B/D hoặc từ chối; nhận ra phải quay A và không cần dọn map. |
| **Grid/cargo** | Player chưa chạm loot 1x1/1x2/cargo 2x2 hoặc chưa gặp thiếu chỗ. | Tại fixture slice: “Bạn nghĩ lựa chọn nào hợp với run của mình, và vì sao?” | Lý do có footprint/ô trống/công dụng/giá trị-ô/route; lấy hoặc bỏ đều hợp lệ. |
| **Safebox/evidence/death** | Run tự nhiên chưa chết sau Manifest, hoặc semantics chưa được nói ra. | Dùng state chết **thực sự có trong build** sau khi Manifest đã niêm, cùng một đồ niêm không-phải-evidence và ít nhất một gear/loot không niêm: “Trước khi xem summary, bạn nghĩ điều gì được giữ, điều gì mất, điều gì chưa hoàn thành, và bước kế tiếp là gì?” | Evidence là `unrecovered`; đồ niêm không-phải-evidence được giữ; gear/loot không niêm ở fixture là `Đã mất`; Recovery Contract, không phải completion/soft-lock. |
| **Presentation/accessibility** | Sau player đã gặp landmark/card/telegraph/extract. | “Bạn dựa vào dấu hiệu nào để biết đây là A/extract, đồ có claim, rarity, hazard hoặc đòn sắp tới?” | Player nêu shape/icon/text/motion/âm thanh/landmark chứ không chỉ màu; nếu một kênh không hiện trong build, đánh dấu coverage thiếu. |

Nếu player đã có một giải thích đúng từ run tự nhiên, chỉ hỏi lại để xác nhận ngắn, không thử làm họ đổi ý. Nếu fixture không tồn tại hoặc hành vi không thể xuất hiện đúng luật slice, ghi `KHÔNG TEST ĐƯỢC` cùng state thiếu; không “giả lập” bằng lời kể.

### 3.5 Debrief không dẫn dắt

Sau màn summary, hỏi lần lượt: “Nhiệm vụ này kết thúc khi nào?”, “Bạn có thể rút lúc nào?”, “Điều gì xảy ra với Manifest nếu chết khi nó ở Hộp?”, “Bạn sẽ làm gì khác ở run sau?” Sau mỗi câu, ghi câu trả lời đầu tiên trước khi hỏi “Điều gì trên màn hình khiến bạn nghĩ vậy?”.

Không hỏi “Bạn có hiểu rằng…?” hoặc “Bạn có thích…?” như bằng chứng hiểu. Phản hồi về gu thẩm mỹ, combat khó/dễ hay giá trị item chỉ ghi là feedback, không ghi đè hành vi/diễn giải quan sát.

## 4. Ma trận claim, pass/fail và owner xử lý

`PASS` = player tự hành động hoặc giải thích đúng ở lần đầu phù hợp, không cần hint gameplay. `FAIL` = họ hành động/diễn giải sai rule cốt lõi, hoặc không thấy tín hiệu sau khi đã có cơ hội hợp lý; ghi nguyên nhân theo lời/hành vi, không suy đoán. `INVESTIGATE` = death do kỹ năng, lỗi control/kỹ thuật, trạng thái không xuất hiện, hoặc bằng chứng mâu thuẫn. `KHÔNG TEST ĐƯỢC` = build không tạo được probe đúng luật.

| ID / claim cần học | Cơ hội quan sát và bằng chứng ghi | PASS | FAIL | Owner cho task sửa nếu lỗi lặp |
|---|---|---|---|---|
| **P1 — Objective và route** | Briefing → A; hỏi player đang làm gì trước/sau Manifest. | Nói/làm được “lấy Manifest rồi extract A”; biết B/D là route loot tùy chọn. | Tin cần dọn map, B/D bắt buộc, hoặc C/E đang vào được. | Slice flow + map readability |
| **P2 — Rút sớm là thắng** | Từ post-Manifest, quan sát lựa chọn và debrief. | Tự tin gọi/giữ A hoặc mô tả đó là success hợp lệ. | Gọi rút sớm là abandon/fail hoặc chờ game tự extract. | Slice flow + objective/extract presentation |
| **P3 — Combat công bằng** | Skirmish B, patrol về A hoặc hold extract; ghi hướng nhìn, death và lời nói. | Nhìn ra lane/telegraph/cover và chọn né, guard, dash, rút hoặc đánh. | Không biết nguồn/hướng nguy hiểm vì tín hiệu bị che, địch xuất hiện vô báo trước, hoặc combat UI che route. | Encounter/readability |
| **P4 — Loot-grid là quyết định** | Card B và cargo D; đủ/chật ô, rotate hoặc bỏ item. | Dựa footprint + ô trống + công dụng/giá trị/ô để lấy, đổi, xoay hoặc bỏ; không cần chọn “tối ưu”. | Chờ auto-drop/auto-swap, cho rarity là giá trị/ô hoặc damage mặc định, hay không biết món lớn tốn chỗ. | Inventory UX + item presentation |
| **P5 — Claim khác rarity** | Card item có claim; probe presentation. | Chỉ được claim bằng icon/tên/pattern riêng với rarity và nói nó là quyền lợi, không phải bậc sức mạnh. | Dùng rarity để suy claim hoặc coi claim là auto-tịch thu/gate main route. | Item presentation + lore delivery |
| **P6 — Hộp, evidence, death và recovery** | Khi niêm Manifest và state chết sau Manifest; summary/debrief. | Phân biệt seal với extract; Manifest chết là `unrecovered`; đồ niêm không-phải-evidence giữ, gear/loot không niêm mất; biết có recovery, không soft-lock. | Tin seal = giao nộp/completion; Manifest về hub; toàn bộ đồ Hộp đều về; hoặc campaign bị khóa. | Inventory/recovery UX + contract wording |
| **P7 — Extract và summary** | Call/hold A và result screen. | Tự gọi/giữ extract, nhận ra lane địch có báo trước; summary phân biệt kept/lost/evidence/recovery và lead Kho K-7 chưa là Contract 2 playable. | Đứng chờ auto-win, death bị hiểu là extract, hoặc Manifest bị hiểu là minh oan/mở content đang chơi. | Extract presentation + summary/narrative delivery |
| **P8 — Tín hiệu mobile không chỉ màu** | Bốn sub-state: **P8a** landmark/objective/extract A; **P8b** claim khác rarity trên card; **P8c** hazard/telegraph; **P8d** Hộp/evidence/death state. | Mỗi sub-state đã gặp có một tín hiệu đúng nghĩa ngoài màu (silhouette, icon, pattern, text, vị trí, motion hoặc audio) và không bị HUD/overlay che. P8 chỉ `PASS` khi P8a–P8d đều PASS. | Với một sub-state đã gặp: player chỉ phân biệt bằng màu, hoặc tín hiệu bị che/lẫn. Với sub-state chưa gặp trong coverage hợp lệ: sub-state và P8 tổng là `KHÔNG TEST ĐƯỢC`, không suy PASS từ tín hiệu khác. | Art/presentation + UI accessibility |

Một death do timing/input nhưng player biết rõ đòn đến từ đâu và cách tránh là dữ liệu P3 `PASS` hoặc `INVESTIGATE` theo bằng chứng, **không** tự là FAIL. Tương tự, bỏ cargo hay rút sớm khi player nêu trade-off là P4/P2 `PASS`, không phải dấu hiệu chơi thiếu nội dung.

## 5. Triage và vòng sửa giới hạn

Sau một nhóm phiên cùng build, observer tách **lỗi build/readiness**, **lỗi kỹ thuật**, **lỗi kỹ năng**, **feedback sở thích** và **hiểu sai luật**. Outcome phá invariant là nhánh vận hành build/readiness; hiểu sai luật hoặc tín hiệu bị mất là evidence player và không được lẫn hai nhánh.

| Mức | Điều kiện `proposed` | Hành động được phép |
|---|---|---|
| **BLOCKER build/readiness** | Build có outcome trái invariant: C/E nhận input, D/E là extract, recovery soft-lock/không tồn tại, mất đồ không báo trước, hoặc state/gate phá luật đã khóa. | Dừng phiên, trả readiness về `BLOCKER` và mở ngay **một** Task Card state/readiness theo [build-readiness §9](vertical-slice-build-readiness.md). Ghi state → action → outcome; đây không là player design-claim repair và không chờ synthesis. |
| **BLOCKER candidate semantic/readability** | Một player, trong state build đúng, hiểu sai campaign/failure theo cách critical: seal = completion, death = extract, không có recovery, extract/lane không được báo, hoặc C/E bị tưởng playable. | Chỉ ghi candidate và chuyển sang [mẫu tổng hợp §§8–9](playtest-synthesis-template.md): chỉ thành repair Task Card khi source/coverage hợp lệ, build/control/fixture comparable, không confounder và tái hiện cùng sequence. Trước đó là `INVESTIGATE`. |
| **MUST_FIX candidate** | Có row cùng causal misunderstanding hoặc tín hiệu combat/UI bị che như evidence ở phiên khác. | Mẫu tổng hợp mới chốt `MUST_FIX`: hai C0 first-time độc lập cùng causal misunderstanding, **hoặc** hai coverage hợp lệ cùng combat/UI signal/state; cùng build/control/fixture, không confounder. Không mở repair Task Card từ một row hay đổi economy/map/lore để che triệu chứng. |
| **INVESTIGATE** | Một lần hiểu sai không chắc nguyên nhân, failure do skill/input, bug kỹ thuật, hint/control, evidence mâu thuẫn hoặc source/coverage không hợp lệ. | Chỉ mở handoff chẩn đoán hẹp để kiểm tra control/bug/fixture hoặc quan sát lại đúng claim; không kết luận design failure và không mở repair Task Card cho claim. |
| **KHÔNG TEST ĐƯỢC** | Build không tạo được probe/state đúng luật hoặc fixture không tới được theo flow thật. | Chỉ mở handoff readiness/fixture hẹp; không mô phỏng outcome bằng lời, không coi là lỗi design đã xác nhận. Nếu phát hiện trong phiên, trả readiness coverage về `NOT READY`. |
| **PASS / không mở task** | Claim được hiểu đúng bằng hành vi/câu trả lời đầu tiên, hoặc lựa chọn khác mục tiêu nhưng có lý do đúng. | Giữ nguyên; không “tối ưu hóa” thêm UI/prompt chỉ vì player không đi full-route. |

`BLOCKER` build/readiness dùng handoff state/readiness của build-readiness, không phải repair claim. Repair card semantic/readability chỉ dùng mẫu ở [mẫu tổng hợp §9](playtest-synthesis-template.md) sau khi đạt `BLOCKER`/`MUST_FIX`; phải nêu **một claim ID**, vị trí/beat, hypothesis, file/scope và cách kiểm tra lại trên người chơi mới. Tối đa hai repair pass cho một claim trong cùng card; nếu vẫn lỗi, dừng `NEEDS_DECISION` thay vì thêm popup, lore hoặc reward ngoài scope.

## 6. Báo cáo sau mỗi nhóm phiên

```text
Build / control scheme:
Coverage đã chạy: C0 run tự nhiên | C1 rút sớm | C2 full-route | C3 death-recovery | presentation
Không test được: <state/fixture thiếu; gồm P8a/P8b/P8c/P8d nếu áp dụng>

P1–P8: PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC
Evidence: <hành vi và câu nói ngắn, không diễn giải thay player>
Can thiệp / lỗi kỹ thuật: <tách khỏi hiểu biết>
Triage: BLOCKER build/readiness / BLOCKER candidate semantic/readability / MUST_FIX candidate / INVESTIGATE / KHÔNG TEST ĐƯỢC / không mở task
Handoff: build/readiness ngay / candidate sang synthesis §§8–9 / diagnostic-readiness hẹp / không có
```

Report không được kết luận “slice đã cân bằng”, “đã accessibility-compliant” hay “player thích game” chỉ từ protocol này. Mục đích hoàn thành của task là biết chính xác **điều người chơi hiểu sai ở beat nào và tác nhân trình bày/system nào cần được sửa**, trước khi mở rộng map hay content.

## 7. Checklist trước khi chạy test

1. Build có đúng Easy, Contract 1, A/B/D và chỉ extract A không?
2. Save/profile đã mới, không mang knowledge/state của người test trước không?
3. Facilitator có cam kết không hint route, item, safebox hay extraction không?
4. Có thể quan sát ít nhất run tự nhiên và các state đang định probe mà không phá luật slice không?
5. Phiếu ghi có tách control/bug/skill khỏi hành vi hiểu rule không?
6. Nếu claim lỗi, nhóm có thể mở **một** task sửa hẹp thay vì thêm content, lore hay balance không?
