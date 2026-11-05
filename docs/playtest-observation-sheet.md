# Phiếu quan sát playtest — Vertical slice “Giữ giấy phép”

**Trạng thái:** template thao tác `proposed`. Sao chép toàn bộ từ “Phiên mới” cho **mỗi** người chơi first-time; đây là nơi ghi bằng chứng quan sát, không phải bảng chấm kỹ năng, survey, hệ thống analytics hay hồ sơ người tham gia.

**Nguồn ràng buộc:** [kế hoạch playtest](playtest-readability-plan.md), [build-readiness](vertical-slice-build-readiness.md), [wireflow UX](vertical-slice-wireflow.md), [vertical slice](vertical-slice.md). Chỉ dùng sau khi build đạt `GO` trong build-readiness. Trước phiên, gate/fixture không tạo được state đúng nguồn là `NOT READY` và không mời player; state có **outcome thật** trái invariant là `BLOCKER` build/readiness. Chỉ khi state/fixture thiếu mới lộ trong phiên, ghi `KHÔNG TEST ĐƯỢC` rồi trả readiness coverage về `NOT READY`; không dạy người chơi hay tự sửa luật.

## 1. Cách dùng nhanh

1. Một **facilitator** nói/quan sát người chơi; một **observer** ghi phiếu. Nếu chỉ có một người điều phối, ưu tiên ghi lời nói/hành vi đầu tiên rồi mới ghi chi tiết sau beat—không vừa ghi vừa giải thích gameplay.
2. C0 là run tự nhiên, ghi trước. Chỉ sau C0 mới dùng C1–C3/probe có kiểm soát; không ép rút sớm, full-route, cargo hay death vào C0.
3. Ghi điều thấy/nghe trước, suy luận sau: `state → action đầu tiên → câu nói đầu tiên → outcome trên màn → can thiệp/confounder`.
4. Một death không tự là `FAIL`; rút sớm, từ chối loot hoặc bỏ cargo sau khi cân nhắc đều có thể là `PASS`. Không ghi “chơi kém” hay “không thích” thay cho evidence.

### Lời nói và hành vi của facilitator

| Được nói `proposed` | Không được nói/làm |
|---|---|
| “Hãy chơi như bạn vừa mở game. Nếu thoải mái, hãy nói điều bạn đang cố làm hoặc điều làm bạn bối rối.” | Đọc lại mục tiêu/briefing, gọi tên route đúng, nói B/D optional, hay giải thích safebox/evidence trước khi player tự nói. |
| Khi player hỏi phải làm gì: “Bạn đang thấy thông tin nào nói về mục tiêu hoặc lựa chọn tiếp theo?” | Chỉ location, icon, nút, ô grid, cover, direction, hay đáp án “đúng”. |
| Trước state C3: “Đây là một state khác của build. Trước khi xem summary, bạn nghĩ điều gì xảy ra tiếp?” | Gọi death là required/“bài học”, nói Manifest sẽ `unrecovered`, hoặc kể outcome trước summary. |
| Có thể giới thiệu control tối thiểu, pause/quit và quyền dừng; chỉ hỗ trợ control trung tính khi player kẹt kỹ thuật. | Sửa thao tác gameplay trong run. Nếu đã hỗ trợ control, ghi `CAN THIỆP CONTROL`; claim phụ thuộc nó là `INVESTIGATE`. |

### Nhãn ghi nhận

| Nhãn | Dùng khi |
|---|---|
| `PASS` | Player tự hành động hoặc giải thích đúng ở cơ hội đầu tiên, không gameplay hint. |
| `FAIL` | Player gán sai nghĩa cho luật/tín hiệu sau khi đã có cơ hội hợp lý. |
| `INVESTIGATE` | Lỗi control/technical, death do thao tác, evidence mâu thuẫn hoặc có can thiệp khiến không biết nguyên nhân. |
| `KHÔNG TEST ĐƯỢC` | Build/state hợp lệ không có; không giả lập outcome bằng lời hay mock text. |
| `CAN THIỆP CONTROL` | Facilitator đã hỗ trợ thao tác trung tính; tách hẳn khỏi kết luận hiểu biết. |

## 2. Phiên mới — thông tin tối thiểu

```text
Mã phiên (không dùng tên/contact):
Ngày / build label / control scheme:
Observer:                               Facilitator:
Save/profile mới: Có / Không             Build GO theo readiness: Có / Không

Tự nguyện nêu kinh nghiệm: action mobile: Không / Có / Không muốn nói
Tự nguyện nêu kinh nghiệm: extraction:    Không / Có / Không muốn nói
Điều kiện dùng control mà người chơi tự nêu (nếu có):

Scope preflight: Easy · Contract 1 · A/B/D · chỉ extract A · C/E silhouette · starter kit · Hộp 2x2
Fixture preflight: Manifest 1x1 · loot B 1x1/1x2 + claim · cargo D 2x2 + item gọn 1x2 · call/hold/board · death/recovery

Preflight decision (chọn đúng một): READY / NOT READY / BLOCKER build/readiness
READY: Build GO, mọi gate/fixture cần cho coverage phiên này đều tạo được bằng flow thật và cho outcome đúng nguồn.
NOT READY (trước mời player): gate/state/coverage hoặc evidence fixture thiếu → không mời player; ghi phần thiếu và mở Task Card fixture/readiness hẹp.
BLOCKER build/readiness: outcome thật trái invariant → dừng gate/phiên; ghi state → action → outcome, trả readiness `BLOCKER`, tái hiện một lần cùng build và mở ngay Task Card state/readiness hẹp.
Nếu chỉ trong phiên mới lộ gate/fixture thiếu: coverage `KHÔNG TEST ĐƯỢC` → readiness coverage về `NOT READY`; không dùng status này cho outcome trái invariant.
```

Không ghi tên, tuổi, thông tin liên lạc, chẩn đoán, suy đoán về khả năng hay dữ liệu ngoài những dòng tự nguyện cần cho context control. Quy trình consent, recording, lưu trữ dữ liệu và tuyển người nằm ngoài template này.

## 3. Log C0 — run tự nhiên (ghi trước mọi probe)

**Luật C0:** player tự chọn rút A, đi B/D hoặc chết. Không yêu cầu full-route/cargo/death; không route hint. Ghi từng hàng khi có beat mới; thêm hàng nếu cần.

| Time/beat · state | Player action đầu tiên | Lời nói đầu tiên nguyên văn/ngắn | Cue họ nêu/dùng | Outcome trên màn | Facilitator can thiệp? | Control/technical confounder? | Claim ID để đối chiếu |
|---|---|---|---|---|---|---|---|
| S1 briefing/O1 |  |  |  |  |  |  | P1 |
| S2 A: dispatch/beacon/B route |  |  |  |  |  |  | P1, P8a |
| O2 Manifest → S3 |  |  |  |  |  |  | P1, P2, P6 |
| S4 B nếu player vào |  |  |  |  |  |  | P3, P8c |
| O2/O3 loot nếu player mở |  |  |  |  |  |  | P4, P5, P8b |
| S5 D/O4 nếu player vào |  |  |  |  |  |  | P4, P6, P8d |
| A E1/S7/S8/S9 nếu player extract |  |  |  |  |  |  | P2, P3, P7, P8a/P8c |
| S10 hoặc S11 outcome |  |  |  |  |  |  | P6/P7/P8d |

**Giới hạn mapping C0:** Reference P6/P8d trong log này chỉ ghi evidence của state đã gặp; chúng không tự tạo `PASS` P6. P6 chỉ `PASS` theo chuỗi C3 hoàn chỉnh. Ở hàng `S10 hoặc S11 outcome`, chỉ ghi P6/P7/P8d phù hợp với outcome thực tế đang hiện, không suy outcome còn lại.

**Kết quả C0:** `rút sớm success` / `full hoặc một phần route rồi extract` / `death trước Manifest` / `death sau Manifest` / `dừng player chọn` / `KHÔNG TEST ĐƯỢC`.

**Tách evidence khỏi suy diễn:**

```text
Hành vi/lời nói quan sát quan trọng:
Suy diễn tạm thời (nếu có, phải ghi lý do):
Can thiệp control/bug/timing tách riêng:
State chưa gặp trong C0:
```

## 4. Coverage có kiểm soát sau C0

Không dùng coverage này để sửa lại kết luận đầu tiên của C0. Nếu state không tạo được đúng luật, đánh dấu `KHÔNG TEST ĐƯỢC`, ghi fixture thiếu và không nói outcome thay game.

### C1 — rút sớm

**Fixture:** state S3 sau Manifest thật → E1/O5 → S7 → S8 → S9 → S10. Không vào B/D.

| Bước/state | Player action đầu tiên | Lời nói đầu tiên | Outcome | Facilitator can thiệp? | Control/technical confounder? | Claim |
|---|---|---|---|---|---|---|
| E1 beacon callable |  |  |  |  |  | P2 semantics/P7/P8a |
| O5 gọi thuyền: preview/confirm/hủy |  |  |  |  |  | P2/P7 |
| S8 hold: lane báo trước |  |  |  |  |  | P3/P7/P8c |
| S9 board → S10 |  |  |  |  |  | P7 |
| S10 summary |  |  |  |  |  | P2/P7 |

Kết luận C1: `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC`. Ghi rõ nếu player coi rút sớm là success hay abandon; không suy `FAIL` chỉ vì họ đã đi B/D ở C0. C1 chỉ bổ sung P2 **semantics**, không chứng minh P1 hay P2 route-choice first-time.

### C2 — full-route tùy chọn

**Fixture:** save mới → S1/S2 → Manifest → S4 B combat/card → S5 D cargo/Hộp → S4 → S3 → E1/O5 → S7/S8/S9 → S10. Khi C2 chạy **sau C0 của cùng người chơi**, nó chỉ phủ P3–P8/state UI; không thể ghi là bằng chứng lựa chọn route first-time P1/P2. Một run first-time tự chọn B/D không hint phải được ghi là **C0 độc lập**, không là “coverage C2 tương đương”.

| Bước/state | Player action đầu tiên | Lời nói đầu tiên | Outcome | Facilitator can thiệp? | Control/technical confounder? | Claim |
|---|---|---|---|---|---|---|
| S4 B: cover/telegraph/gate |  |  |  |  |  | P3/P8c |
| Vùng yên + O2 loot 1x1/1x2/claim |  |  |  |  |  | P4/P5/P8b |
| S5 D: cargo 2x2 ↔ item gọn 1x2 |  |  |  |  |  | P4 |
| O3/O4: rotate/placement/Hộp |  |  |  |  |  | P4/P6/P8d |
| D → B → A |  |  |  |  |  | P3/P8a *(P1 chỉ từ C0 first-time tự chọn)* |
| E1/O5 → S8/S9 → S10 |  |  |  |  |  | P3/P7 *(P2 chỉ từ C0 first-time tự chọn)* |

Kết luận C2: `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC`. `Bỏ cargo`, `lấy đồ gọn`, `không niêm` hoặc `rút khi quay về A` là outcome hợp lệ nếu player nêu trade-off; không ghi là route/build kém.

### C3 — death → Recovery Contract

**Fixture readiness:** Manifest đã niêm + một item niêm không-phải-evidence + ít nhất một gear/loot không niêm → death thật → S11 → S12 → S1 recovery → S2 **bàn dispatch A** → player tự thu hồi Manifest `unrecovered` → placement hợp lệ → E1. E1 chưa là success: vẫn phải gọi/giữ/lên thuyền A. Không mô phỏng bằng lời hay tự trả Manifest về hub.

| Bước/state | Player dự đoán/action đầu tiên | Lời nói đầu tiên | Outcome trên màn | Facilitator can thiệp? | Control/technical confounder? | Claim |
|---|---|---|---|---|---|---|
| Trước S11: hỏi prediction trung tính |  |  |  |  |  | P6/P8d |
| S11: `Đã giữ` / `Đã mất` / `Vật chứng — unrecovered` |  |  |  |  |  | P6/P7/P8d |
| S12 chọn Recovery Contract |  |  |  |  |  | P6/P7 |
| S1 recovery briefing/loadout |  |  |  |  |  | P6 |
| S2 A: bàn dispatch, tự thu hồi `unrecovered` → placement hợp lệ → E1 |  |  |  |  |  | P6/P8a |
| E1/O5 → S7/S8/S9 → S10 sau recovery |  |  |  |  |  | P6/P7 |

Recognition tại bàn dispatch trong C3 là evidence state cho recovery/P8a; **không** điền nó thành P1/P2 route-first-time trong scorecard.

Kết luận C3: `PASS` / `FAIL` / `INVESTIGATE` / `KHÔNG TEST ĐƯỢC`. Chỉ `PASS` P6 khi player phân biệt: evidence Manifest là `unrecovered`, đồ niêm **không-phải-evidence** được giữ, gear/loot không niêm đã mất, tự thu hồi/placement hợp lệ, và vẫn cần gọi/giữ/lên thuyền A để hoàn thành.

## 5. Scorecard claim — điền sau đủ evidence

Một claim chưa có state hợp lệ phải là `KHÔNG TEST ĐƯỢC`, không suy từ claim khác. `FAIL` cần một action hoặc lời nói cụ thể. `INVESTIGATE` dùng khi control/technical/can thiệp làm bằng chứng không tin cậy. Owner là discipline nhận Task Card nếu lỗi lặp, không phải người chịu trách nhiệm cá nhân.

| Claim | Kết quả | Evidence hành vi/lời nói đầu tiên | State/coverage | Phân loại khác nếu cần | Discipline owner nếu follow-up |
|---|---|---|---|---|---|
| P1 Objective/route | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  |  | Slice flow + map readability |
| P2 Rút sớm là thắng | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  |  | Slice flow + objective/extract presentation |
| P3 Combat công bằng | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | skill / control / technical / presentation | Encounter + readability |
| P4 Loot-grid là quyết định | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | skill / control / technical / presentation | Inventory UX + item presentation |
| P5 Claim khác rarity | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | presentation / lore delivery | Item presentation + lore delivery |
| P6 Hộp/evidence/death/recovery | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | technical / wording / state missing | Inventory/recovery UX + contract wording |
| P7 Extract/summary | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | skill / technical / presentation | Extract presentation + summary/narrative delivery |
| P8a Landmark/objective/extract A | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | presentation / overlay | Art/presentation + UI accessibility |
| P8b Claim khác rarity trên card | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | presentation / overlay | Art/presentation + UI accessibility |
| P8c Hazard/telegraph | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | presentation / overlay / control | Art/presentation + UI accessibility |
| P8d Hộp/evidence/death state | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC |  |  | presentation / wording / state missing | Art/presentation + UI accessibility |
| **P8 tổng** | PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC | PASS chỉ khi P8a–P8d đều PASS; một sub-state không gặp làm tổng `KHÔNG TEST ĐƯỢC`. |  |  | Art/presentation + UI accessibility |

## 6. Triage và handoff sau phiên

Phiếu này chỉ ghi evidence của **một** phiên. `BLOCKER` **semantic/readability** và `MUST_FIX` ở đây chỉ là **candidate chuyển sang mẫu tổng hợp**, không phải quyền tự mở repair Task Card. `BLOCKER` **build/readiness** ở hàng bên dưới là nhánh vận hành riêng: outcome trái invariant phải dừng phiên, trả readiness về `BLOCKER` và mở ngay một Task Card state/readiness theo [build-readiness §9](vertical-slice-build-readiness.md).

| Kết quả thấy được | Đừng kết luận | Ghi/handoff đúng |
|---|---|---|
| Player chết nhưng nêu đúng lane/telegraph và phản ứng cần làm | “Combat khó” hoặc P3 FAIL tự động. | P3 `PASS`/`INVESTIGATE` theo evidence; ghi timing/control riêng. |
| Player rút sớm hoặc từ chối cargo sau khi nói trade-off | “Bỏ content” hoặc P2/P4 FAIL. | Ghi outcome hợp lệ; claim là PASS nếu semantics đúng. |
| Player bấm sai sau hint control hoặc lỗi UI | “Không hiểu inventory”. | `CAN THIỆP CONTROL`/technical; claim `INVESTIGATE`. |
| **Build/readiness:** C/E nhận input, D/E là extract, recovery soft-lock/không tồn tại, mất đồ không báo trước, hoặc outcome khác invariant | Lỗi đọc hiểu của player, hoặc chờ synthesis mới được chặn build. | `BLOCKER` build/readiness: ghi state → action → outcome; dừng phiên, trả readiness về `BLOCKER` và mở ngay **một** Task Card state/readiness theo [build-readiness §9](vertical-slice-build-readiness.md). Đây không là player design-claim repair và không chờ synthesis. |
| **Player semantic/readability:** player tin seal = completion, death = extract, recovery không có, extract/lane không được báo, hoặc C/E playable **dù build đúng state không tương tác** | Feedback nhẹ hoặc repair đã được chốt. | Ghi `BLOCKER candidate`: state → action/lời nói đầu tiên → outcome. Chuyển sang tổng hợp để kiểm source/coverage hợp lệ, comparability, confounder và tái hiện cùng sequence trước repair Task Card readability. |
| Row có cùng hiểu sai hoặc tín hiệu combat/UI bị che như evidence ở phiên khác | `MUST_FIX` từ một phiếu, hoặc tự thêm popup/lore/reward. | Chỉ ghi row evidence/candidate. Mẫu tổng hợp mới xác thực hai evidence độc lập: hai C0 first-time cùng causal misunderstanding, **hoặc** hai coverage hợp lệ cùng combat/UI signal/state; cùng build/control/fixture, không confounder. |
| State/fixture không tạo được đúng flow | Lỗi design đã xác nhận hoặc outcome được mô tả bằng lời. | `KHÔNG TEST ĐƯỢC`; ghi state/gate thiếu và handoff readiness/fixture. Nếu lộ trong phiên, trả readiness coverage về `NOT READY`. |

### Candidate semantic/readability chuyển sang mẫu tổng hợp

```text
Mã phiên không định danh:
Claim / state / coverage và source evidence:
Build / control / fixture/readiness hiện có:
Observed action → first words → on-screen outcome:
Confounder / facilitator intervention:
Candidate: BLOCKER semantic/readability candidate / possible repeated misunderstanding or combat-UI signal
Xác nhận đây không là build/readiness BLOCKER; nếu outcome phá invariant, dùng nhánh build/readiness ở bảng trên thay vì record này
Discipline owner:
Chuyển sang [mẫu tổng hợp](playtest-synthesis-template.md) §§8–9: kiểm source hợp lệ, comparability, ngưỡng và reproduction; **không** tự tạo repair Task Card tại đây.
```

### Handoff chẩn đoán/readiness

```text
Mã phiên không định danh:
Claim hoặc state/fixture duy nhất:
Classification: INVESTIGATE / KHÔNG TEST ĐƯỢC
Evidence source / coverage và build / control / fixture hiện có:
Observed evidence hoặc gate/state thiếu:
Confounder, mâu thuẫn hoặc lý do source chưa hợp lệ:
Phạm vi kiểm tra hoặc fixture/readiness hẹp:
Điều phải quan sát lại để trở về evidence hợp lệ:
Allowed files/sections:
Out of scope:
Discipline owner:
```

Handoff này không xác nhận lỗi design và không có acceptance repair cho người chơi mới. Chỉ sau khi đạt `BLOCKER`/`MUST_FIX` ở [mẫu tổng hợp §§8–9](playtest-synthesis-template.md) mới dùng Repair Task Card ở đó.

## 7. Kết thúc phiên

```text
Coverage hoàn thành: C0 / C1 / C2 / C3
Coverage không test được + fixture thiếu:
Claims PASS / FAIL / INVESTIGATE / KHÔNG TEST ĐƯỢC:
Blocker/Must-fix candidate (không tự quyết thay nhóm):
Điều player nói hoặc làm cần giữ nguyên văn:
Technical/control incidents tách riêng:
Phiên đủ để so với build khác? Có / Không — vì:
```

Không dùng một phiếu để tuyên bố balance, performance, accessibility certification, product preference hay readiness phát hành. Sau nhiều phiên, tổng hợp theo protocol và chỉ mở Task Card sửa nhỏ khi evidence đạt ngưỡng triage đã chốt.
